# Development checks for the supplied code and reference solution. ARGS[1]
# points to an isolated student tree with the reference Compute.jl installed.
using Test   # verify the assignment's contracts and supporting infrastructure
using Random # reproducible small-map comparisons with an independent oracle
include(joinpath(ARGS[1], "Include.jl"));
include(joinpath(ARGS[1], "test_support.jl"));
using .PS2Checks; # independent validators for returned routes

"""
    oracle_distance(maze, part)

Construct the finite state graph directly from cell symbols and compute
minimum distances by repeated edge relaxation. This development oracle does
not call the student's neighbor, state-transition, queue, or search functions.

### Arguments

- `maze::MyMazeModel`: A small validated map. Its cell matrix is not modified.
- `part::Int`: `1` for an ordinary map without keycards or doors, or `2` for
  a map using the keycard rules.

### Returns

- `Int`: The minimum number of moves from the start to the exit.
- `nothing`: No legal escape route exists.
"""
function oracle_distance(maze, part)

    # Enumerate locally valid vertices -
    states = EscapeState[]; # Part 1 uses only the false flag to represent each position once
    for r in axes(maze.cells, 1), c in axes(maze.cells, 2), card in (false, true)
        part == 1 && card && continue;
        tile = maze.cells[r, c];
        tile == '#' && continue;
        tile in ('K', 'D') && !card && continue;
        push!(states, (r, c, card));
    end
    # Build every legal directed edge independently of the student functions -
    state_set = Set(states);
    edges = Tuple{EscapeState, EscapeState}[]; # source state => destination state, stored as pairs
    for a in states, b in states
        abs(a[1] - b[1]) + abs(a[2] - b[2]) == 1 || continue;
        tile = maze.cells[b[1], b[2]];
        tile == 'D' && !a[3] && continue;
        b[3] == (a[3] || tile == 'K') || continue;
        push!(edges, (a, b));
    end
    # Relax edges until distances stop improving -
    distances = Dict(state => Inf for state in state_set); # Inf denotes a state not yet reached
    distances[(maze.start[1], maze.start[2], false)] = 0.0;
    for _ in 1:(length(states) - 1)
        changed = false;
        for (a, b) in edges
            candidate = distances[a] + 1;
            if candidate < distances[b]
                distances[b] = candidate;
                changed = true;
            end
        end
        changed || break;
    end
    # Accept either card flag at the exit -
    distance = minimum(get(distances, (maze.goal[1], maze.goal[2], card), Inf) for card in (false, true));
    return isfinite(distance) ? Int(distance) : nothing;
end

@testset "Assignment development validation" begin
    @testset "Supplied queue" begin
        q = MyQueue{Int}();
        @test isempty(q) && length(q) == 0
        @test_throws ArgumentError popfirst!(q)
        @test_throws ArgumentError peek(q)
        push!(q, 7); push!(q, 9);
        @test peek(q) == 7 && length(q) == 2
        @test popfirst!(q) == 7
        push!(q, 11);
        @test [popfirst!(q), popfirst!(q)] == [9, 11]
        push!(q, 13);
        @test popfirst!(q) == 13 && isempty(q)
    end

    @testset "Supplied map validation" begin
        for rows in (String[], [""], ["S", "..E"], ["S E"], ["S?E"], ["..E"], ["S.."], ["SSE"], ["SEE"], ["SKKE"])
            @test_throws ArgumentError build(MyMazeModel, rows)
        end
        @test size(build(MyMazeModel, ["SKDDE"]).cells) == (1, 5)
        mktemp() do path, io
            write(io, "S.\r\n.E\r\n"); close(io);
            @test readmaze(path).goal == (2, 2)
        end
    end

    @testset "Independent shortest-path comparisons" begin
        rng = MersenneTwister(48005800);
        for part in 1:2, trial in 1:60
            rows, columns = rand(rng, 2:6), rand(rng, 2:7);
            cells = [rand(rng) < 0.30 ? '#' : '.' for _ in 1:rows, _ in 1:columns];
            cells[1, 1], cells[end, end] = 'S', 'E';
            if part == 2
                candidates = [(r, c) for r in 1:rows for c in 1:columns if cells[r, c] == '.'];
                shuffle!(rng, candidates);
                if !isempty(candidates)
                    r, c = pop!(candidates); cells[r, c] = 'K';
                end
                for (r, c) in candidates[1:min(3, length(candidates))]
                    cells[r, c] = 'D';
                end
            end
            maze = build(MyMazeModel, [join(cells[r, :]) for r in 1:rows]);
            expected = oracle_distance(maze, part);
            if part == 1
                @test solves_part_1(escape_part_1, maze, expected)
            else
                @test solves_part_2(escape_part_2, maze, expected)
            end
        end
    end

    @testset "Route validators reject plausible wrong answers" begin
        maze = build(MyMazeModel, ["SKE"]);
        @test !valid_part_2(maze, [(1, 1, false), (1, 2, false), (1, 3, false)])
        @test !valid_part_2(maze, [(1, 1, false), (1, 2, true), (1, 3, false)])
        @test !valid_part_2(build(MyMazeModel, ["SDE"]), [(1, 1, false), (1, 2, true), (1, 3, true)])
        @test !valid_part_1(build(MyMazeModel, ["S.E"]), [(1, 1), (1, 3)])
        @test !valid_part_1(build(MyMazeModel, ["S#E"]), [(1, 1), (1, 2), (1, 3)])
        @test !valid_part_1(build(MyMazeModel, ["SE"]), Position[])
    end

    @testset "Keycard example and rendering" begin
        maze = readmaze(joinpath(ARGS[1], "data", "test_part_2.txt"));
        route = escape_part_2(maze);
        @test (2, 4, false) in route && (2, 4, true) in route
        @test length(route) - 1 == 16
        @test occursin('K', rendermaze(maze; route=route)) && occursin('*', rendermaze(maze; route=route))
        @test rendermaze(maze) == chomp(read(joinpath(ARGS[1], "data", "test_part_2.txt"), String))
        output = savemaze(maze, joinpath(ARGS[1], "outputs", "validated-keycard.svg"); route=route);
        @test isfile(output) && occursin("16 moves", read(output, String))
        @test_throws ArgumentError rendermaze(maze; route=[(0, 1)])
    end
end
