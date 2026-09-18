# Test the PS2 implementation and write MANIFEST.txt. Run from the assignment root:
#
#   julia --startup-file=no check_submission.jl
#
# Run testme_part_1.jl and testme_part_2.jl, then write MANIFEST.txt with the
# test results and SHA-256 digests of every file in src/ and of responses.md
# when present. Test failures are reported without stopping the submission
# instructions. No files are uploaded to Canvas.

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

# Explain the boundary between this local check and the Canvas submission -
println("""
==================== important ====================
check_submission.jl runs testme_part_1.jl and testme_part_2.jl, then writes MANIFEST.txt.
check_submission.jl does NOT upload anything to Canvas.
You must still create a zip archive and upload it through Canvas yourself.
""");

# Run testme_part_1.jl and testme_part_2.jl and record each script's result -
results = Dict{String, Symbol}(); # test filename => :passed, :failed, or :error
for part ∈ ["testme_part_1.jl", "testme_part_2.jl"]
    println("\n==================== running $(part) ====================");
    status = :passed; # optimistic status, changed if `include(...)` propagates a failure
    try
        sandbox = Module(gensym(:PS2Part)); # each test script gets a fresh copy of the source definitions
        Base.include(sandbox, joinpath(@__DIR__, part));
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

# Write the submission manifest -
manifest_path = joinpath(@__DIR__, "MANIFEST.txt"); # generated beside this script
open(manifest_path, "w") do io
    println(io, "PS2 CHEME 4800/5800 Fall 2026 submission manifest");
    println(io, "generated: ", Dates.now()); # local wall-clock timestamp

    # Record the test outcomes -
    for part ∈ sort(collect(keys(results)))
        println(io, part, ": ", _MANIFEST_STATUS[results[part]]); # sort for reproducible output order
    end

    # Discover every regular source file, including files inside helper directories -
    source_files = String[];
    for (directory, _, filenames) ∈ walkdir(joinpath(@__DIR__, "src"))
        for filename ∈ filenames
            file = joinpath(directory, filename);
            isfile(file) && push!(source_files, file); # skip directories and unusable filesystem entries
        end
    end

    # Include the written responses in the submission fingerprint -
    response_path = joinpath(@__DIR__, "responses.md");
    if isfile(response_path)
        push!(source_files, response_path);
    else
        println(io, "responses.md: MISSING");
    end

    # Fingerprint the complete submitted source tree and written responses -
    for file ∈ sort(source_files)
        digest = bytes2hex(open(sha256, file)); # lowercase hexadecimal SHA-256 digest
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
println("Written responses and documentation are reviewed separately; this script does not grade them.");
all_suites_passed = all(status -> status == :passed, values(results)); # both test scripts must finish successfully
any_suite_errored = any(status -> status == :error, values(results)); # at least one test script could not complete setup

# Explain the next steps based on the test results -
if all_suites_passed == true
    println("""

Status: READY TO PACKAGE
All 48 tests in testme_part_1.jl and testme_part_2.jl passed.
Complete responses.md and review RUBRIC.md.
The final score remains pending completion review. Follow the steps below.
""");
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
