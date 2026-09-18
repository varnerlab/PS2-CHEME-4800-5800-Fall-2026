include(joinpath(@__DIR__, "Include.jl")); # load the model, student solvers, and rendering functions

# Read the command-line request -
length(ARGS) in (2, 3) || error("Usage: julia --startup-file=no runmaze.jl <1|2> <map.txt> [output.svg]");
ARGS[1] in ("1", "2") || error("the part must be 1 or 2");
part = parse(Int, ARGS[1]); # select the ordinary or Part 2 search
maze = readmaze(ARGS[2]); # map path supplied by the caller

# Compute the route -
route = part == 1 ? escape_part_1(maze) : escape_part_2(maze);

# Display the computed route -
println(rendermaze(maze; route=route));
if route === nothing
    println("\nNo escape route found.");
else
    println("\nMoves: ", length(route) - 1);
    println("Route (including the start and exit):");
    foreach(println, route);
end

# Save the route drawing -
default_name = splitext(basename(ARGS[2]))[1] * "-part$part.svg";
output = length(ARGS) == 3 ? ARGS[3] : joinpath(@__DIR__, "outputs", default_name);
println("\nMap saved to ", savemaze(maze, output; route=route));
