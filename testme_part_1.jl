using Test # public assertions and per-check error reporting
isdefined(@__MODULE__, :OlinEscape) || Base.include(@__MODULE__, joinpath(@__DIR__, "Include.jl"));
isdefined(@__MODULE__, :PS2Checks) || Base.include(@__MODULE__, joinpath(@__DIR__, "test_support.jl"));
using .PS2Checks; # compare returned neighbors and validate complete routes

@testset verbose=true "PS2 Part 1 (24 checks)" begin
    @testset "Geometric neighbors (8)" begin
        @test matches_neighbors(neighbors(build(MyMazeModel, ["S..", "...", "..E"]), (1, 1)), [(1, 2), (2, 1)])
        @test matches_neighbors(neighbors(build(MyMazeModel, ["S..", "...", "..E"]), (2, 2)), [(1, 2), (3, 2), (2, 1), (2, 3)])
        @test matches_neighbors(neighbors(build(MyMazeModel, ["S#E"]), (1, 1)), Position[])
        @test matches_neighbors(neighbors(build(MyMazeModel, ["S.E"]), (1, 2)), [(1, 1), (1, 3)])
        @test matches_neighbors(neighbors(build(MyMazeModel, ["SKDE"]), (1, 2)), [(1, 1), (1, 3)])
        @test matches_neighbors(neighbors(build(MyMazeModel, ["SE"]), (1, 2)), [(1, 1)])
        @test_throws ArgumentError neighbors(build(MyMazeModel, ["SE"]), (0, 1))
        @test_throws ArgumentError neighbors(build(MyMazeModel, ["S#E"]), (1, 2))
    end

    @testset "Shortest routes (12)" begin
        # Each case contributes one check of the complete returned route -
        cases = [
            ("adjacent exit", ["SE"], 1),
            ("one column", ["S", ".", "E"], 2),
            ("several equally short routes", ["S..", "...", "..E"], 4),
            ("detour around a wall", ["S#E", "..."], 4),
            ("cycles in the corridors", ["S...", "..#.", "...E"], 5),
            ("unreachable exit", ["S#E"], nothing),
            ("isolated start", ["S#.", "###", "..E"], nothing),
            ("open boundary", ["S..E", "####"], 3),
            ("dead-end branch", ["S...#", "##.##", "E..##"], 6),
            ("long corridor", ["S" * repeat(".", 38) * "E"], 39),
        ];
        for (label, rows, expected) in cases
            @testset "$label" begin
                @test solves_part_1(escape_part_1, build(MyMazeModel, rows), expected)
            end
        end
        @test solves_part_1(escape_part_1, readmaze(joinpath(@__DIR__, "data", "test_part_1.txt")), 10)
        @test solves_part_1(escape_part_1, readmaze(joinpath(@__DIR__, "data", "production_part_1.txt")), 84)
    end

    @testset "Part boundary and independent calls (4)" begin
        @test_throws ArgumentError escape_part_1(build(MyMazeModel, ["SKE"]))
        @test_throws ArgumentError escape_part_1(build(MyMazeModel, ["SDE"]))
        @test begin
            maze = build(MyMazeModel, ["S..", ".#.", "..E"]);
            original = deepcopy(maze);
            neighbors(maze, maze.start);
            escape_part_1(maze);
            maze.cells == original.cells && maze.start == original.start && maze.goal == original.goal
        end
        @test begin
            a = build(MyMazeModel, ["S.E"]);
            b = build(MyMazeModel, ["S#E"]);
            first_ok = solves_part_1(escape_part_1, a, 2);
            blocked_ok = solves_part_1(escape_part_1, b, nothing);
            first_ok && blocked_ok && solves_part_1(escape_part_1, a, 2)
        end
    end
end
