module OlinEscape

# Load the assignment code in dependency order -
include(joinpath(@__DIR__, "src", "Types.jl")); # maze model and search-state aliases
include(joinpath(@__DIR__, "src", "Factory.jl")); # construct and validate map models
include(joinpath(@__DIR__, "src", "Files.jl")); # read a map from a text file
include(joinpath(@__DIR__, "src", "Queue.jl")); # supplied first-in, first-out queue
include(joinpath(@__DIR__, "src", "Compute.jl")); # student neighbor and search implementations
include(joinpath(@__DIR__, "src", "Visualization.jl")); # text and SVG map renderers

# Expose the assignment's public interface -
export Position, EscapeState, MyMazeModel, MyQueue;
export build, readmaze, neighbors, nextstates, escape_part_1, escape_part_2;
export rendermaze, savemaze;

end

using .OlinEscape; # make the assignment's public interface available to scripts
