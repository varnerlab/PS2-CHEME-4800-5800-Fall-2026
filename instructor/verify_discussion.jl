# Run the submission script in an isolated student tree, then test its answer warnings.
using Test # compare warnings for unfinished and filled response files
include(joinpath(ARGS[1], "check_submission.jl"));

@testset "Discussion answer warnings" begin
    template = read(joinpath(ARGS[1], "responses.md"), String);
    placeholder = "TODO: Write your response.";
    filled = replace(template, placeholder => "I used examples from my code to explain my reasoning.");

    mktempdir() do directory
        path = joinpath(directory, "responses.md");
        @test occursin("missing", only(_discussion_issues(path)))

        write(path, template);
        warnings = _discussion_issues(path);
        @test length(warnings) == 3
        @test all(occursin("Question $number still has", warnings[number]) for number in 1:3)

        # Deleting TODO must not make an unanswered question appear finished -
        write(path, replace(template, placeholder => ""));
        @test length(_discussion_issues(path)) == 3
        @test all(occursin("has no answer", warning) for warning in _discussion_issues(path))

        write(path, replace(template, placeholder => "<!-- I will answer later. -->"));
        @test all(occursin("has no answer", warning) for warning in _discussion_issues(path))

        write(path, "");
        @test all(occursin("Question $number is missing", _discussion_issues(path)[number]) for number in 1:3)

        # Written text is recognized without claiming that its reasoning is correct -
        write(path, filled);
        @test isempty(_discussion_issues(path))
        write(path, replace(filled, "\n" => "\r\n"));
        @test isempty(_discussion_issues(path))
        write(path, replace(template, placeholder => "I replaced the TODO stubs and checked my routes."));
        @test isempty(_discussion_issues(path))

        # Report the question that still needs an answer -
        partial = replace(template, placeholder => "An answer paragraph."; count=2);
        write(path, partial);
        @test occursin("Question 3 still has", only(_discussion_issues(path)))

        write(path, replace(filled, r"(?ms)^2\. .*?(?=^3\. )" => ""));
        @test occursin("Question 2 is missing", only(_discussion_issues(path)))

        write(path, replace(filled, "3. **" => "2. **"));
        @test any(occursin("Question 2 appears more than once", warning) for warning in _discussion_issues(path))
        @test any(occursin("Question 3 is missing", warning) for warning in _discussion_issues(path))

        for marker in ("todo: Write your response.", "TBD", "Your answer here.")
            write(path, replace(template, placeholder => marker));
            @test length(_discussion_issues(path)) == 3
            @test all(occursin("placeholder", warning) for warning in _discussion_issues(path))
        end
    end
end
