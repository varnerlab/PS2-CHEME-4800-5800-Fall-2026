"""Build and test the Git source archive without access to the private solution."""
import argparse
import hashlib
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_FILES = {
    "README.md", "RUBRIC.md", "responses.md", "LICENSE", "Project.toml",
    "Include.jl", "check_submission.jl", "runmaze.jl", "test_support.jl",
    "testme_part_1.jl", "testme_part_2.jl", "data/README.md",
    "data/test_part_1.txt", "data/production_part_1.txt",
    "data/test_part_2.txt", "data/production_part_2.txt",
    "src/Types.jl", "src/Factory.jl", "src/Files.jl", "src/Queue.jl",
    "src/Compute.jl", "src/Visualization.jl",
}


def require(condition, message):
    """Stop the release if a required check fails."""
    if not condition:
        raise RuntimeError(message)


def git(*arguments):
    """Read the committed release tree."""
    return subprocess.check_output(["git", *arguments], cwd=ROOT, text=True).strip()


def run_julia(script, student):
    """Run Julia outside the assignment folder and retain failures for diagnosis."""
    result = subprocess.run(
        ["julia", "--startup-file=no", str(script), str(student)],
        cwd=student.parent, text=True, capture_output=True, timeout=120,
    )
    output = result.stdout + result.stderr
    require(result.returncode == 0, f"{script.name} failed:\n{output[-8000:]}")
    return output


def check_contents(student, names):
    """Check archive exclusions, student instructions, and unchanged map data."""
    files = {name for name in names if not name.endswith("/")}
    require(REQUIRED_FILES <= files, f"Missing student files: {sorted(REQUIRED_FILES - files)}")
    prohibited = {".git", ".github", "instructor", "solution", "outputs", "__pycache__"}
    for name in names:
        path = Path(name)
        require(not path.is_absolute() and ".." not in path.parts, f"Invalid archive path: {name}")
        require(not prohibited.intersection(path.parts), f"Instructor or generated file in archive: {name}")
        require(path.name not in {"MANIFEST.txt", ".DS_Store"}, f"Generated file in archive: {name}")
        require(path.suffix not in {".zip", ".pyc"}, f"Generated file in archive: {name}")

    source = (student / "src/Compute.jl").read_text()
    for function in ("neighbors", "escape_part_1", "nextstates", "escape_part_2"):
        require(f'{function} is not implemented yet' in source, f"Missing starter placeholder: {function}")
    responses = (student / "responses.md").read_text()
    require(responses.count("TODO: Write your response.") == 3, "Expected three unanswered discussion prompts")

    for markdown in student.rglob("*.md"):
        for target in re.findall(r"\]\(([^)]+)\)", markdown.read_text()):
            if target.startswith(("https:", "http:", "mailto:", "#")):
                continue
            require((markdown.parent / target.split("#")[0]).exists(),
                    f"Broken local link in {markdown.name}: {target}")

    readme = (student / "README.md").read_text()
    examples = re.findall(r"```text\n(.*?)```", readme, flags=re.S)
    require(len(examples) == 2, "Expected two numbered ASCII examples")
    for part, block in enumerate(examples, 1):
        rows = ["".join(re.findall(r"[#.SEKD]", line)) for line in block.splitlines()]
        expected = (student / f"data/test_part_{part}.txt").read_text().splitlines()
        require([row for row in rows if row] == expected, f"Part {part} ASCII example differs from its map")

    digests = re.findall(r"([0-9a-f]{64})  (\S+)", (student / "data/README.md").read_text())
    require(len(digests) == 4, "Expected four map digests")
    for digest, filename in digests:
        actual = hashlib.sha256((student / "data" / filename).read_bytes()).hexdigest()
        require(actual == digest, f"Map digest changed: {filename}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", default="HEAD", help="Committed tree to check")
    parser.add_argument("--tag", help="Release tag, which must identify the same commit")
    arguments = parser.parse_args()
    if arguments.tag:
        require(git("rev-parse", f"{arguments.tag}^{{commit}}") ==
                git("rev-parse", f"{arguments.ref}^{{commit}}"), "Release tag does not match the checked commit")

    with tempfile.TemporaryDirectory(prefix="ps2-release-") as temporary:
        directory = Path(temporary)
        archive = directory / "student.zip"
        subprocess.run(["git", "archive", "--format=zip", f"--output={archive}", arguments.ref],
                       cwd=ROOT, check=True)
        student = directory / "student"
        with zipfile.ZipFile(archive) as bundle:
            names = bundle.namelist()
            bundle.extractall(student)
        check_contents(student, names)
        if arguments.tag:
            require(f"/releases/tag/{arguments.tag})" in (student / "README.md").read_text(),
                    "README release link does not match the tag")
        print("Archive contents, local links, ASCII examples, and map digests passed.", flush=True)

        run_julia(ROOT / "instructor/verify_starter.jl", student)
        print("20 checks of the starter and supplied code passed.", flush=True)
        output = run_julia(student / "check_submission.jl", student)
        require("Status: TESTS NEED ATTENTION" in output, "Starter did not report unfinished code")
        require("Status: READY TO PACKAGE" not in output and "YOU ESCAPED OLIN!" not in output,
                "Starter incorrectly reported completion")
        for number in (1, 2, 3):
            require(f"Question {number} still has a TODO" in output, f"Missing warning for question {number}")
        require("Canvas submission steps:" in output, "Checker did not print submission instructions")
        manifest = (student / "MANIFEST.txt").read_text()
        require(manifest.count("some tests failed") == 2, "Manifest did not record both unfinished parts")
        require("responses.md: NEEDS ATTENTION" in manifest, "Manifest omitted the discussion warning")
        include_digest = hashlib.sha256((student / "Include.jl").read_bytes()).hexdigest()
        require(f"{include_digest}  Include.jl" in manifest, "Manifest omitted the Include.jl digest")
        require(not list((student / "outputs").glob("escape-part-*.svg")), "Starter produced a completed route")
        print("Starter failures, discussion warnings, and submission instructions passed.", flush=True)

        output = run_julia(ROOT / "instructor/verify_discussion.jl", student)
        require(re.search(r"Discussion answer warnings\s*\|\s*20\s+20", output),
                "Discussion warning tests did not all pass")
        print("20 discussion warning checks passed.", flush=True)
    print("The student source archive is ready for a draft GitHub release.")


if __name__ == "__main__":
    main()
