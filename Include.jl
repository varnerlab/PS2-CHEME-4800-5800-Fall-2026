# Load Include.jl from a script or the Julia REPL to access the PS2 code.
# Keep all library-file include calls inside the OlinEscape module.
module OlinEscape

# Load the supplied types and utilities -
# @__DIR__ anchors each source path to the folder containing Include.jl,
# so loading the code does not depend on the terminal's working directory.
include(joinpath(@__DIR__, "src", "Types.jl")); # maze model and search-state aliases
include(joinpath(@__DIR__, "src", "Factory.jl")); # construct and validate map models
include(joinpath(@__DIR__, "src", "Files.jl")); # read a map from a text file
include(joinpath(@__DIR__, "src", "Queue.jl")); # supplied first-in, first-out queue

# Load optional student helper files -
# TODO (optional): Add include calls for your helper files here.
# Store helper files in src/. Replace MyHelpers.jl with your filename and
# uncomment the example after creating the file. Load dependencies first.
# include(joinpath(@__DIR__, "src", "MyHelpers.jl"));

# Load the student solvers and supplied renderers -
include(joinpath(@__DIR__, "src", "Compute.jl")); # student neighbor and search implementations
include(joinpath(@__DIR__, "src", "Visualization.jl")); # text and SVG map renderers

# Export the types and functions used by the tests and runmaze.jl -
export Position, EscapeState, MyMazeModel, MyQueue;
export build, readmaze, neighbors, nextstates, escape_part_1, escape_part_2;
export rendermaze, savemaze;

end

using .OlinEscape; # make the assignment's public interface available to scripts
