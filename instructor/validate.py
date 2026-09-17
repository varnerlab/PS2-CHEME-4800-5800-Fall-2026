"""Validate isolated reference, starter, partial, and syntax-error submissions."""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
STUDENT_FILES = (
    "README.md", "RUBRIC.md", "responses.md", "LICENSE", "Project.toml",
    "Include.jl", "runmaze.jl", "check_submission.jl", "test_support.jl",
    "testme_part_1.jl", "testme_part_2.jl",
)
STUDENT_DIRECTORIES = ("src", "data", "figs")


def copy_student_tree(destination):
    """Create an isolated student copy for testing, without building an archive."""
    files = [ROOT / name for name in STUDENT_FILES]
    for name in STUDENT_DIRECTORIES:
        files.extend(p for p in (ROOT / name).rglob("*") if p.is_file() and p.name != ".DS_Store")
    for path in sorted(files):
        if path.is_symlink() or not path.is_file():
            raise ValueError(f"Expected a regular student file: {path}")
        target = destination / path.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)


def run(tree, script, expected=0, label=None, extra=()):
    """Run Julia from another working directory and save the complete output."""
    label = label or script.stem
    result = subprocess.run(["julia", "--startup-file=no", str(script), *map(str, extra)],
                            cwd=tree.parent, text=True, capture_output=True, timeout=120)
    output = result.stdout + result.stderr
    logs = ROOT / "instructor/validation-output"
    logs.mkdir(exist_ok=True)
    (logs / f"{label}.log").write_text(output)
    if expected == 0 and result.returncode != 0:
        raise RuntimeError(f"{label} failed:\n{output}")
    if expected != 0 and result.returncode == 0:
        raise RuntimeError(f"{label} unexpectedly succeeded")
    print(f"{label}: expected exit status confirmed")
    return output


def main():
    with tempfile.TemporaryDirectory(prefix="ps2-validation-") as temporary:
        tree = Path(temporary) / "student"
        copy_student_tree(tree)
        starter = (tree / "src/Compute.jl").read_text()
        solution = (ROOT / "solution/src/Compute.jl").read_text()

        # Confirm that all public checks can run against a completed submission -
        (tree / "src/Compute.jl").write_text(solution)
        for part in (1, 2):
            output = run(tree, tree / f"testme_part_{part}.jl", label=f"solution-part-{part}")
            if not re.search(r"24\s+24", output):
                raise RuntimeError(f"Part {part} did not report 24 passing checks")
        run(tree, ROOT / "instructor/verify_solution.jl", label="development", extra=(tree,))
        output = run(tree, tree / "check_submission.jl", label="solution-checker")
        assert "All 48 public checks passed" in output
        manifest = (tree / "MANIFEST.txt").read_text()
        assert manifest.count("all tests passed") == 2 and "responses.md" in manifest
        run(tree, tree / "runmaze.jl", label="solution-cli",
            extra=("2", tree / "data/test_part_2.txt", tree / "outputs/keycard-route.svg"))
        shutil.copy2(tree / "outputs/keycard-route.svg", ROOT / "instructor/validation-output/keycard-route.svg")

        # Confirm that the student starter fails visibly without stopping the checker -
        (tree / "src/Compute.jl").write_text(starter)
        for part in (1, 2):
            run(tree, tree / f"testme_part_{part}.jl", expected=1, label=f"starter-part-{part}")
        output = run(tree, tree / "check_submission.jl", label="starter-checker")
        assert "CHECKS NEED ATTENTION" in output
        assert (tree / "MANIFEST.txt").read_text().count("some tests failed") == 2

        # A finished Part 1 must still earn its checks when Part 2 is incomplete -
        marker = '"""\n    nextstates'
        partial = solution.split(marker)[0] + marker + starter.split(marker)[1]
        (tree / "src/Compute.jl").write_text(partial)
        output = run(tree, tree / "check_submission.jl", label="partial-checker")
        manifest = (tree / "MANIFEST.txt").read_text()
        assert "testme_part_1.jl: all tests passed" in manifest
        assert "testme_part_2.jl: some tests failed" in manifest

        # Syntax errors must be distinguished from ordinary failed assertions -
        (tree / "src/Compute.jl").write_text("function broken(\n")
        output = run(tree, tree / "check_submission.jl", label="syntax-error-checker")
        assert "Status: TESTS COULD NOT RUN" in output
        assert (tree / "MANIFEST.txt").read_text().count("tests could not run") == 2
    print("Reference solution, supporting code, and checker scenarios passed.")


if __name__ == "__main__":
    main()
