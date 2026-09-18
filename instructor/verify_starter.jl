# Check the code supplied to students without loading a reference solution.
using Test # verify the starter functions, queue, map reader, and drawings
include(joinpath(ARGS[1], "Include.jl"));

@testset "Student starter and supplied code" begin
    # Confirm that all four student functions are still unfinished -
    maze = readmaze(joinpath(ARGS[1], "data", "test_part_1.txt"));
    @test_throws ErrorException neighbors(maze, maze.start)
    @test_throws ErrorException escape_part_1(maze)
    @test_throws ErrorException nextstates(maze, (maze.start..., false))
    @test_throws ErrorException escape_part_2(maze)

    # Exercise the supplied queue -
    queue = MyQueue{Position}();
    @test isempty(queue)
    push!(queue, (1, 1));
    push!(queue, (1, 2));
    @test peek(queue) == (1, 1) && length(queue) == 2
    @test popfirst!(queue) == (1, 1)
    @test popfirst!(queue) == (1, 2) && isempty(queue)

    # Read and draw each supplied map -
    for (filename, dimensions) in (("test_part_1.txt", (5, 9)),
                                   ("production_part_1.txt", (17, 25)),
                                   ("test_part_2.txt", (5, 11)),
                                   ("production_part_2.txt", (21, 31)))
        path = joinpath(ARGS[1], "data", filename);
        maze = readmaze(path);
        @test size(maze.cells) == dimensions
        @test rendermaze(maze) == chomp(read(path, String))
        output = savemaze(maze, joinpath(ARGS[1], "outputs", "$filename.svg"));
        @test isfile(output)
    end
end
