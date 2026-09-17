"""
    rendermaze(maze::MyMazeModel; route = nothing) -> String

Draw a text map, optionally marking the supplied route. Repeated visits overlap
in this view; inspect the route vector to recover their travel order.

### Arguments

- `maze::MyMazeModel`: The map to draw. Its cell matrix is not modified.

### Keyword Arguments

- `route`: `nothing` to draw the map alone, or a vector of `Position` or
  `EscapeState` entries to mark. Entries must contain in-bounds coordinates.
  The renderer does not check whether the route is legal or shortest.

### Returns

- `String`: Map rows separated by newlines. Ordinary floor cells on the route
  are marked with `*`; `S`, `E`, `K`, `D`, and walls retain their symbols.
  No newline is added after the last row.

### Errors

- `ArgumentError`: A route entry lies outside the map.
"""
function rendermaze(maze::MyMazeModel; route=nothing)::String

    # Mark a copy of the map -
    cells = copy(maze.cells); # preserve the caller's floor cells and marked locations
    if route !== nothing
        for step in route
            r, c = step[1], step[2];
            checkbounds(Bool, cells, r, c) || throw(ArgumentError("route leaves the map"));
            cells[r, c] == '.' && (cells[r, c] = '*');
        end
    end
    # Assemble the map rows -
    return join((join(cells[r, :]) for r in axes(cells, 1)), "\n");
end

"""
    savemaze(maze::MyMazeModel, path::AbstractString; route = nothing) -> String

Write a labeled map as a Scalable Vector Graphics (SVG) file. Route segments
are blue before collecting the card and orange afterward; Part 1 position
routes are blue throughout. Use the public tests to establish route legality
and optimality, since the drawing does not check either property.

### Arguments

- `maze::MyMazeModel`: The map to draw. Its cell matrix is not modified.
- `path::AbstractString`: Destination file path. Create its parent directory
  if necessary and overwrite an existing file at that path.

### Keyword Arguments

- `route`: `nothing` to draw the map alone, or a vector of `Position` or
  `EscapeState` entries to overlay. All route coordinates must be in bounds.

### Returns

- `String`: The absolute path to the written SVG file.

### Errors

- `ArgumentError`: A route entry lies outside the map.
- File-system errors from directory creation, opening the file, or writing
  its contents are propagated to the caller.
"""
function savemaze(maze::MyMazeModel, path::AbstractString; route=nothing)::String

    # Check the route and initialize the drawing dimensions -
    rendermaze(maze; route=route); # check route coordinates before writing a file
    rows, columns = size(maze.cells);
    tile, top = 32, 96; # cell size and top margin, in SVG coordinate units
    width, height = max(640, tile * columns + 88), top + tile * rows + 104;
    left = (width - tile * columns) ÷ 2; # center the grid in the drawing
    fills = Dict('#' => "#293c47", '.' => "#f5f3ec", 'S' => "#c8e5ff",
                 'E' => "#bce7cd", 'K' => "#ffe1a3", 'D' => "#e7c4c1");
    # Open the destination and write the drawing header -
    mkpath(dirname(abspath(path)));
    open(path, "w") do io
        println(io, "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$width\" height=\"$height\" viewBox=\"0 0 $width $height\" role=\"img\" aria-labelledby=\"title description\">");
        println(io, "<title id=\"title\">Escape from Olin: the missing keycard</title>");
        println(io, "<desc id=\"description\">Fictional maze. S is the start, E the exit, K the keycard, and D a locked door. Row and column labels use one-based indices.</desc>");
        println(io, "<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>");
        println(io, "<g font-family=\"Arial, Helvetica, sans-serif\" fill=\"#1c303a\">");
        println(io, "<text x=\"24\" y=\"32\" font-size=\"21\" font-weight=\"bold\">Escape from Olin</text>");
        caption = route === nothing ? "Fictional map · $rows rows × $columns columns" : "$(length(route) - 1) moves · route shown on a fictional map";
        println(io, "<text x=\"24\" y=\"56\" font-size=\"14\">$caption</text>");
        # Label the columns and draw the map cells -
        for c in 1:columns
            x = left + (c - 0.5) * tile;
            println(io, "<text x=\"$x\" y=\"84\" text-anchor=\"middle\" font-size=\"11\">$c</text>");
        end
        for r in 1:rows
            y = top + (r - 0.5) * tile + 4;
            println(io, "<text x=\"$(left - 15)\" y=\"$y\" text-anchor=\"middle\" font-size=\"11\">$r</text>");
            for c in 1:columns
                x, ycell = left + (c - 1) * tile, top + (r - 1) * tile;
                fill = fills[maze.cells[r, c]];
                println(io, "<rect x=\"$x\" y=\"$ycell\" width=\"$tile\" height=\"$tile\" fill=\"$fill\" stroke=\"#ffffff\" stroke-width=\"1\"/>");
            end
        end
        # Overlay consecutive route segments -
        if route !== nothing
            for i in 2:length(route)
                a, b = route[i - 1], route[i];
                has_card = length(a) == 3 && a[3]; # card possession before taking this step
                color = has_card ? "#c86210" : "#1675b8";
                offset = has_card ? 3 : -3; # separate outward and returning segments
                x1, y1 = left + (a[2] - 0.5) * tile + offset, top + (a[1] - 0.5) * tile + offset;
                x2, y2 = left + (b[2] - 0.5) * tile + offset, top + (b[1] - 0.5) * tile + offset;
                println(io, "<line x1=\"$x1\" y1=\"$y1\" x2=\"$x2\" y2=\"$y2\" stroke=\"$color\" stroke-width=\"4\" stroke-linecap=\"round\"/>");
            end
        end
        # Draw markers after the route so their letters remain readable -
        for r in 1:rows, c in 1:columns
            symbol = maze.cells[r, c];
            symbol in ('S', 'E', 'K', 'D') || continue;
            x, y = left + (c - 0.5) * tile, top + (r - 0.5) * tile;
            fill = fills[symbol];
            println(io, "<circle cx=\"$x\" cy=\"$y\" r=\"11\" fill=\"$fill\"/>");
            println(io, "<text x=\"$x\" y=\"$(y + 5)\" text-anchor=\"middle\" font-size=\"15\" font-weight=\"bold\">$symbol</text>");
        end
        # Add the map legend -
        baseline = top + rows * tile; # lower edge of the grid
        println(io, "<text x=\"24\" y=\"$(baseline + 30)\" font-size=\"13\">S = Start · E = Exit · K = Keycard · D = Locked door</text>");
        println(io, "<text x=\"24\" y=\"$(baseline + 52)\" font-size=\"12\">Dark cells are walls. Move up, down, left, or right; each move costs one.</text>");
        if route !== nothing
            println(io, "<text x=\"24\" y=\"$(baseline + 76)\" font-size=\"12\">Blue: without card. Orange: carrying card. Read the route vector for visit order.</text>");
        end
        println(io, "</g></svg>");
    end
    return abspath(path);
end
