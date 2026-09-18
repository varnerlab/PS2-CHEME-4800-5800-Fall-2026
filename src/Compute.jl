# Complete the four public functions below. You may add private helpers in
# Compute.jl or separate files inside src/. Load helper files from Include.jl;
# all library-file include calls belong in Include.jl. Document helper contracts.

"""
    neighbors(maze::MyMazeModel, position::Position) -> Vector{Position}

Find the non-wall cells one orthogonal move from `position`. This function
checks the map geometry; Part 2's `nextstates(...)` applies the door-access rule.

### Arguments

- `maze::MyMazeModel`: The maze to inspect. Its cell matrix is not modified.
- `position::Position`: The current `(row, column)`, using one-based indices.
  The position must be inside the map and must not be a wall.

### Returns

- `Vector{Position}`: Distinct in-bounds, non-wall cells one step up, down,
  left, or right, in any order. Treat `S`, `E`, `K`, and `D` as non-wall cells.
  Return an empty vector when there are no such neighbors.

### Errors

- `ArgumentError`: `position` is outside the map or identifies a wall.
"""
function neighbors(maze::MyMazeModel, position::Position)::Vector{Position}

    # TODO 1: Check that position is inside the map and is not a wall.
    # Throw an ArgumentError if either condition fails.

    # TODO 2: Inspect the four orthogonal positions and collect the in-bounds,
    # non-wall neighbors. Return each position once; door access is checked later.

    throw(ErrorException("neighbors is not implemented yet"));
end

"""
    escape_part_1(maze::MyMazeModel) -> Union{Nothing, Vector{Position}}

Find a route from the start to the exit with the fewest moves using breadth-first
search and `MyQueue`. Every orthogonal move has unit cost.

### Arguments

- `maze::MyMazeModel`: A maze containing only `#`, `.`, `S`, and `E`. The model
  and its cell matrix are not modified.

### Returns

- `Vector{Position}`: A shortest route in travel order, including the start
  and exit. Consecutive positions must be legal neighbors. Any shortest route
  is accepted, and its move count is `length(route) - 1`.
- `nothing`: The exit is unreachable from the start.

### Errors

- `ArgumentError`: The map contains `K` or `D`, which require the Part 2 solver.
"""
function escape_part_1(maze::MyMazeModel)::Union{Nothing, Vector{Position}}

    # TODO 3: Reject maps containing K or D. Initialize a MyQueue{Position},
    # a discovered set, and a predecessor dictionary; discover and enqueue the start.

    # TODO 4: Remove positions in first-in, first-out order and inspect their
    # neighbors. Record each new position and its predecessor before enqueueing it,
    # so another parent cannot add a second queue entry for the same position.

    # TODO 5: Reconstruct a route by following predecessors from the exit to the
    # start, then reverse the sequence. Return nothing if the queue empties first.

    throw(ErrorException("escape_part_1 is not implemented yet"));
end

"""
    nextstates(maze::MyMazeModel, state::EscapeState) -> Vector{EscapeState}

Find the states reachable in one legal move from `state`. Entering `K` collects
the card automatically; entering `D` requires the card before the move. Card
possession persists, and the same card works on every door.

### Arguments

- `maze::MyMazeModel`: The maze to inspect. Its cell matrix is not modified.
- `state::EscapeState`: The current `(row, column, has_cornell_id)`, recorded after
  entering the cell. Validate its location and card flag locally; the function
  need not establish whether the state is reachable from the start.

### Returns

- `Vector{EscapeState}`: Distinct legal states after one orthogonal move, in
  any order. Each flag includes the effect of entering the destination cell.
  Return an empty vector when no legal move is available.

### Errors

- `ArgumentError`: The current position is outside the map or is a wall, or
  its cell is `K` or `D` while `has_cornell_id` is `false`.
"""
function nextstates(maze::MyMazeModel, state::EscapeState)::Vector{EscapeState}

    # TODO 6: Validate the current state and use neighbors to find geometrically
    # adjacent cells. A state on K or D must already have the card.

    # TODO 7: Exclude doors when the card is absent. For each remaining neighbor,
    # retain the current flag or set it to true when entering K.

    throw(ErrorException("nextstates is not implemented yet"));
end

"""
    escape_part_2(maze::MyMazeModel) -> Union{Nothing, Vector{EscapeState}}

Find a route with the fewest moves using breadth-first search over full
`(row, column, has_cornell_id)` states. Use `MyQueue` for the frontier and
`nextstates(...)` for legal moves. Every move has unit cost.

### Arguments

- `maze::MyMazeModel`: A maze with at most one CornellID and any number of doors.
  Ordinary maps without either symbol are also accepted. The model and its
  cell matrix are not modified.

### Returns

- `Vector{EscapeState}`: A shortest route in travel order, starting at
  `(maze.start[1], maze.start[2], false)` and ending at the exit with either
  card flag. Include both endpoints; the move count is `length(route) - 1`.
  Any shortest route is accepted. Collecting the card is optional when no door
  is needed, and a physical position may recur with a different card flag.
- `nothing`: No legal escape route exists. An unreachable exit is a search
  result, not an input error.
"""
function escape_part_2(maze::MyMazeModel)::Union{Nothing, Vector{EscapeState}}

    # TODO 8: Initialize a MyQueue{EscapeState}, discovered set, and predecessor
    # dictionary. Start at S without the card; all three collections use full states.

    # TODO 9: Search in first-in, first-out order using nextstates. Mark each
    # full state when enqueueing it and record the predecessor that discovered it.

    # TODO 10: Reconstruct a shortest route to the exit with either card flag.
    # Return nothing if every reachable state is processed without reaching E.

    throw(ErrorException("escape_part_2 is not implemented yet"));
end
