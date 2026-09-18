# Test the PS2 implementation and write MANIFEST.txt. Run from the assignment root:
#
#   julia --startup-file=no check_submission.jl
#
# Run testme_part_1.jl and testme_part_2.jl, then write MANIFEST.txt with the
# test results and SHA-256 digests of Include.jl, every file in src/, and
# responses.md when readable. Warn about unanswered discussion questions.
# After all tests pass, display the student's routes through the two larger mazes. Test
# failures do not stop the submission instructions. No files are uploaded.

import Dates # timestamp written to the submission manifest
using SHA    # SHA-256 digests used to identify the submitted source files
using Test   # distinguish ordinary test failures from errors that prevent a suite from running

const _MANIFEST_STATUS = Dict(
    :passed => "all tests passed",
    :failed => "some tests failed",
    :error => "tests could not run",
);
const _SUMMARY_STATUS = Dict(
    :passed => "all tests passed",
    :failed => "SOME TESTS FAILED",
    :error => "TESTS COULD NOT RUN",
);

"""
    _rootcause(caught)

Remove nested `LoadError` wrappers so the checker can distinguish failed test
assertions from syntax or load errors that prevent a test script from running.

### Arguments

- `caught`: The exception captured while running `testme_part_1.jl` or
  `testme_part_2.jl`.

### Returns

- The first exception that is not a `LoadError`, or `caught` itself when it
  has no load-error wrapper. The exception is inspected without being modified.
"""
function _rootcause(caught)
    cause = caught; # `include(...)` can add one wrapper at each nested include
    while cause isa LoadError
        cause = cause.error;
    end
    return cause;
end

"""
    _discussion_issues(path::AbstractString) -> Vector{String}

Find missing answers and unfinished placeholders in the three numbered
questions in `responses.md`. Check the answer paragraphs after each question;
the question text itself does not count as an answer. Do not grade the writing.

### Arguments

- `path::AbstractString`: Path to the student's `responses.md` file.

### Returns

- `Vector{String}`: Messages naming missing questions, empty answers, or
  remaining placeholders. An empty vector means no unfinished answers were
  detected; it does not establish that the answers are correct or complete.
  A missing or unreadable file produces a warning instead of an exception.
"""
function _discussion_issues(path::AbstractString)::Vector{String}

    isfile(path) || return ["responses.md is missing. Restore the file and answer all three questions."];
    text = try
        replace(read(path, String), "\r\n" => "\n"); # accept Windows and Unix line endings
    catch
        return ["responses.md could not be read. Check that the file can be opened."];
    end

    # Separate each numbered question from its answer -
    answers = Dict{Int, String}();
    issues = String[];
    pattern = r"(?ms)^[ \t]{0,2}([1-3])\.[ \t]+\*\*.*?(?=^[ \t]{0,2}[1-3]\.[ \t]+\*\*|\z)";
    for section in eachmatch(pattern, text)
        number = parse(Int, section.captures[1]);
        if haskey(answers, number)
            push!(issues, "Question $number appears more than once. Keep one copy of each question.");
        end
        paragraphs = split(section.match, r"\n[ \t]*\n"; limit=2);
        answer = length(paragraphs) == 2 ? paragraphs[2] : "";
        answers[number] = strip(replace(answer, r"(?s)<!--.*?-->" => "")); # comments are not written answers
    end

    # Report unfinished answers without guessing whether the reasoning is correct -
    placeholder = r"(?im)^[ \t]*(?:[-*>][ \t]+)?(?:TODO\b[^\n]*|TBD[.!]?|Write your response[.!]?|Your answer here[.!]?)[ \t]*$";
    for number in 1:3
        if !haskey(answers, number)
            push!(issues, "Question $number is missing. Keep the numbered questions in responses.md.");
        elseif !occursin(r"[\p{L}\p{N}]", answers[number])
            push!(issues, "Question $number has no answer. Write your response below the question.");
        elseif occursin(placeholder, answers[number])
            push!(issues, "Question $number still has a TODO or answer placeholder. Replace it with your response.");
        end
    end
    return issues;
end

# Explain the boundary between this local check and the Canvas submission -
println("""
==================== important ====================
check_submission.jl runs testme_part_1.jl and testme_part_2.jl, then writes MANIFEST.txt.
It also checks responses.md for unanswered questions.
check_submission.jl does NOT upload anything to Canvas.
You must still create a zip archive and upload it through Canvas yourself.
""");

# Run testme_part_1.jl and testme_part_2.jl and record each script's result -
results = Dict{String, Symbol}(); # test filename => :passed, :failed, or :error
tested_modules = Dict{String, Module}(); # reuse the student's code that passed each test script
for part ∈ ["testme_part_1.jl", "testme_part_2.jl"]
    println("\n==================== running $(part) ====================");
    status = :passed; # optimistic status, changed if `include(...)` propagates a failure
    try
        sandbox = Module(gensym(:PS2Part)); # each test script gets a fresh copy of the source definitions
        Base.include(sandbox, joinpath(@__DIR__, part));
        tested_modules[part] = sandbox;
    catch caught
        cause = _rootcause(caught); # inspect the original exception beneath nested include wrappers
        if cause isa Test.TestSetException
            status = :failed; # Test has already printed the individual failed tests
            println(stderr, "\n$(part): one or more tests failed; review the test output above.");
        else
            status = :error; # make syntax, include, and setup failures visible instead of swallowing them
            println(stderr, "\n$(part) could not run because of the following error:");
            showerror(stderr, caught, catch_backtrace());
            println(stderr);
        end
    end
    results[part] = status; # preserve one status for each test script
end

# Check whether the written responses still need attention -
response_path = joinpath(@__DIR__, "responses.md");
discussion_issues = _discussion_issues(response_path);
discussion_status = isempty(discussion_issues) ? "no unanswered prompts detected" : "NEEDS ATTENTION";

# Write the submission manifest -
manifest_path = joinpath(@__DIR__, "MANIFEST.txt"); # generated beside this script
open(manifest_path, "w") do io
    println(io, "PS2 CHEME 4800/5800 Fall 2026 submission manifest");
    println(io, "generated: ", Dates.now()); # local wall-clock timestamp

    # Record the test outcomes -
    for part ∈ sort(collect(keys(results)))
        println(io, part, ": ", _MANIFEST_STATUS[results[part]]); # sort for reproducible output order
    end
    println(io, "responses.md: ", discussion_status);
    for issue in discussion_issues
        println(io, "  - ", issue);
    end

    # Discover every regular source file, including files inside helper directories -
    source_files = [joinpath(@__DIR__, "Include.jl")]; # include student helper-file loading in the fingerprint
    for (directory, _, filenames) ∈ walkdir(joinpath(@__DIR__, "src"))
        for filename ∈ filenames
            file = joinpath(directory, filename);
            isfile(file) && push!(source_files, file); # skip directories and unusable filesystem entries
        end
    end

    # Include the written responses in the submission fingerprint -
    if isfile(response_path)
        push!(source_files, response_path);
    else
        println(io, "responses.md: MISSING");
    end

    # Fingerprint the complete submitted source tree and written responses -
    for file ∈ sort(source_files)
        digest = try
            bytes2hex(open(sha256, file)); # lowercase hexadecimal SHA-256 digest
        catch
            file == response_path || rethrow();
            println(io, "responses.md: UNREADABLE"); # preserve the discussion warning and submission instructions
            continue;
        end
        relative_path = replace(relpath(file, @__DIR__), '\\' => '/'); # stable path separators across platforms
        println(io, digest, "  ", relative_path);
    end
end

# Display the status and student packaging instructions -
println("\n==================== submission summary ====================");
for part ∈ sort(collect(keys(results)))
    println(part, ": ", _SUMMARY_STATUS[results[part]]);
end
println("wrote ", manifest_path);
println("responses.md: ", discussion_status);
for issue in discussion_issues
    println("  WARNING: ", issue);
end
println("The instructor still reviews your answers and code. This script does not grade the writing.");
all_suites_passed = all(status -> status == :passed, values(results)); # both test scripts must finish successfully
any_suite_errored = any(status -> status == :error, values(results)); # at least one test script could not complete setup

# Explain the next steps based on the test results -
if all_suites_passed == true
    println("\nAll 48 tests in testme_part_1.jl and testme_part_2.jl passed.");
    if isempty(discussion_issues)
        println("Status: READY TO PACKAGE");
        println("Review your answers and RUBRIC.md before submitting. The final score still requires instructor review.");
    else
        println("Status: DISCUSSION QUESTIONS NEED ATTENTION");
        println("Your code passed the tests. Answer the questions listed above in responses.md before submitting.");
    end
elseif any_suite_errored == true
    println("""

Status: TESTS COULD NOT RUN
testme_part_1.jl or testme_part_2.jl could not finish because of a syntax,
file-loading, or setup error. See the result for each script above.

Recommended next steps:
1. Read the error and source location printed above.
2. Fix that error before interpreting any other test results.
3. Run check_submission.jl again and read the new results.

Deadline safeguard: If you cannot fix every error before the deadline, submit
your current work anyway. A submission is required for the infinite-revision
policy. Do not miss the deadline solely because the tests cannot run.
""");
else
    println("""

Status: TESTS NEED ATTENTION
One or more tests in testme_part_1.jl or testme_part_2.jl failed.

Recommended next steps:
1. Review the failure messages above.
2. Fix as many issues as you can.
3. Run check_submission.jl again and read the new results.

Deadline safeguard: If you cannot fix every failure before the deadline, submit
your current work anyway. A submission is required for partial credit and for the
infinite-revision policy. Do not miss the deadline solely because a test is failing.
""");
end

# Show the routes computed by the student's passing solvers -
if all_suites_passed
    println("\n==================== YOU ESCAPED OLIN! ====================");
    println("Your routes through the two larger mazes are shown below. * marks visited floor cells.");
    for (part, expected_moves) in ((1, 84), (2, 178))
        try
            sandbox = tested_modules["testme_part_$part.jl"];
            assignment = getfield(sandbox, :OlinEscape);
            checks = getfield(sandbox, :PS2Checks);
            filename = "production_part_$part.txt";
            maze = assignment.readmaze(joinpath(@__DIR__, "data", filename));
            original = deepcopy(maze); # draw the original floor plan even if a solver changes its input
            solver = part == 1 ? assignment.escape_part_1 : assignment.escape_part_2;
            validator = part == 1 ? checks.valid_part_1 : checks.valid_part_2;
            route = solver(maze);
            validator(original, route) && length(route) - 1 == expected_moves ||
                error("the solver did not return a shortest route on this call");

            println("\nPart $part: data/$filename — $(length(route) - 1) moves");
            println(assignment.rendermaze(original; route=route));
            output = joinpath(@__DIR__, "outputs", "escape-part-$part.svg");
            drawing = assignment.savemaze(original, output; route=route);
            println("Open in a browser: ", drawing);
        catch caught
            println("Part $part route display could not be completed: ", sprint(showerror, caught));
            println("The test results and MANIFEST.txt are still available.");
        end
    end
    if !isempty(discussion_issues)
        println("\nBefore submitting: finish the questions listed above in responses.md.");
    end
end

# Repeat the manual Canvas boundary immediately before the upload instructions -
println("""
check_submission.jl has NOT uploaded anything to Canvas.

Canvas submission steps:
1. Zip the assignment folder containing Project.toml, README.md, and check_submission.jl:
   - macOS: right-click the folder in Finder and choose "Compress".
   - Windows: right-click the folder and choose "Send to" -> "Compressed (zipped) folder".
2. Rename the zip to CHEME-4800-5800-PS2-<your netid>.zip
   Replace the entire <your netid> placeholder, including the angle brackets,
   with your actual NetID (for example, CHEME-4800-5800-PS2-abc123.zip).
3. Upload the zip to the PS2 assignment on Canvas before the deadline.
""");
