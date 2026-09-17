"""
    build(::Type{MyMazeModel}, lines::AbstractVector{<:AbstractString}) -> MyMazeModel

Construct a maze from its text rows and validate the map symbols and marked
locations. The map may contain any number of doors, including zero, and its
border cells need not be walls. Validation does not establish reachability.

### Arguments

- `MyMazeModel::Type{MyMazeModel}`: The model type to construct.
- `lines::AbstractVector{<:AbstractString}`: Map rows in top-to-bottom order.
  Each row must be nonempty and have the same number of characters. The input
  vector and its strings are not modified.

### Returns

- `MyMazeModel`: A new character matrix and the one-based positions of its
  unique start and exit.

### Errors

- `ArgumentError`: The map is empty, a row is empty, row lengths differ, a
  symbol is outside `#`, `.`, `S`, `E`, `K`, and `D`, the map does not contain
  exactly one `S` and one `E`, or it contains more than one `K`.
"""
function build(::Type{MyMazeModel}, lines::AbstractVector{<:AbstractString})::MyMazeModel

    # Check the row dimensions -
    isempty(lines) && throw(ArgumentError("the map must contain at least one row"));
    rows = collect.(lines); # character vectors allow consecutive integer indices
    width = length(first(rows)); # number of columns in the character matrix
    width > 0 || throw(ArgumentError("map rows must not be empty"));
    all(row -> length(row) == width, rows) ||
        throw(ArgumentError("every map row must have the same number of characters"));

    # Initialize -
    cells = Matrix{Char}(undef, length(rows), width); # one map symbol per row-column position
    starts, goals = Position[], Position[]; # retain every marker so duplicates can be rejected
    key_count = 0; # at most one keycard is allowed

    # Populate the map and record its marked cells -
    for r in eachindex(rows), c in 1:width
        symbol = rows[r][c];
        symbol in ('#', '.', 'S', 'E', 'K', 'D') ||
            throw(ArgumentError("unrecognized map symbol $(repr(symbol)) at row $r, column $c"));
        cells[r, c] = symbol;
        symbol == 'S' && push!(starts, (r, c));
        symbol == 'E' && push!(goals, (r, c));
        symbol == 'K' && (key_count += 1);
    end
    # Check the start, exit, and keycard counts -
    length(starts) == 1 || throw(ArgumentError("the map must contain exactly one S"));
    length(goals) == 1 || throw(ArgumentError("the map must contain exactly one E"));
    key_count <= 1 || throw(ArgumentError("the map may contain at most one K"));
    return MyMazeModel(cells, only(starts), only(goals));
end
