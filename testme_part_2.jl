using Test # compare function results with expected values and report failures
isdefined(@__MODULE__, :OlinEscape) || Base.include(@__MODULE__, joinpath(@__DIR__, "Include.jl"));
isdefined(@__MODULE__, :PS2Checks) || Base.include(@__MODULE__, joinpath(@__DIR__, "test_support.jl"));
using .PS2Checks; # compare returned states and validate complete routes

@testset verbose=true "PS2 Part 2 (24 tests)" begin
    @testset "Legal state transitions (10)" begin
        @test matches_states(nextstates(build(MyMazeModel, ["S.KDE"]), (1, 2, false)), [(1, 1, false), (1, 3, true)])
        @test matches_states(nextstates(build(MyMazeModel, ["S.KDE"]), (1, 3, true)), [(1, 2, true), (1, 4, true)])
        @test matches_states(nextstates(build(MyMazeModel, ["S.KDE"]), (1, 4, true)), [(1, 3, true), (1, 5, true)])
        @test matches_states(nextstates(build(MyMazeModel, ["SDEK"]), (1, 1, false)), EscapeState[])
        @test matches_states(nextstates(build(MyMazeModel, ["S.KDE"]), (1, 2, true)), [(1, 1, true), (1, 3, true)])
        @test matches_states(nextstates(build(MyMazeModel, ["SE"]), (1, 1, false)), [(1, 2, false)])
        @test_throws ArgumentError nextstates(build(MyMazeModel, ["S#E"]), (1, 2, false))
        @test_throws ArgumentError nextstates(build(MyMazeModel, ["SE"]), (0, 1, false))
        @test_throws ArgumentError nextstates(build(MyMazeModel, ["SKE"]), (1, 2, false))
        @test_throws ArgumentError nextstates(build(MyMazeModel, ["SDE"]), (1, 2, false))
    end

    @testset "Shortest routes through state space (12)" begin
        cases = [
            ("ordinary map also works", ["SE"], 1),
            ("required door with no CornellID", ["SDE"], nothing),
            ("CornellID behind the locked door", ["SDKE"], nothing),
            ("unnecessary CornellID", ["S.E", "...", "K.."], 2),
            ("card works on two doors", ["SKD.DE"], 5),
            ("automatic pickup without a door", ["SKE"], 2),
            ("revisit the start carrying the card", ["K.SDE"], 6),
            ("card cannot cross a wall", ["SK#E"], nothing),
            ("open detour beats collecting the card", ["S.DE", ".##.", "....", "K###"], 7),
            ("optimal exit states with either flag", ["S..", ".K.", "..E"], 4),
        ];
        for (label, rows, expected) in cases
            @testset "$label" begin
                @test solves_part_2(escape_part_2, build(MyMazeModel, rows), expected)
            end
        end
        @test solves_part_2(escape_part_2, readmaze(joinpath(@__DIR__, "data", "test_part_2.txt")), 16)
        @test solves_part_2(escape_part_2, readmaze(joinpath(@__DIR__, "data", "production_part_2.txt")), 178)
    end

    @testset "Map preservation and independent calls (2)" begin
        @test begin
            maze = build(MyMazeModel, ["SKDE"]);
            original = deepcopy(maze);
            nextstates(maze, (1, 1, false));
            escape_part_2(maze);
            maze.cells == original.cells && maze.start == original.start && maze.goal == original.goal
        end
        @test begin
            a = build(MyMazeModel, ["SKDE"]);
            b = build(MyMazeModel, ["SDE"]);
            first_ok = solves_part_2(escape_part_2, a, 3);
            blocked_ok = solves_part_2(escape_part_2, b, nothing);
            first_ok && blocked_ok && solves_part_2(escape_part_2, a, 3)
        end
    end
end
