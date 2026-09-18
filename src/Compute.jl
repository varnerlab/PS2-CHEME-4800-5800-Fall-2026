# Complete the four functions below. You may add helper functions in
# Compute.jl or separate files inside src/. Load helper files from Include.jl;
# all library-file include calls belong in Include.jl. Document each helper's
# purpose, arguments, and return value.

"""
    neighbors(maze::MyMazeModel, position::Position) -> Vector{Position}

Find the cells one step up, down, left, or right from `position`, excluding
walls. Part 2's `nextstates(...)` checks whether you can enter a door.

### Arguments

- `maze::MyMazeModel`: The maze to inspect. Its cell matrix is not modified.
- `position::Position`: The current `(row, column)`, using one-based indices.
  The position must be inside the map and must not be a wall.

### Returns

- `Vector{Position}`: Neighboring cells inside the map that are not walls.
  Include each position once, in any order. Include neighboring `S`, `E`, `K`,
  and `D` cells. Return an empty vector when there are no such neighbors.

### Errors

- `ArgumentError`: `position` is outside the map or identifies a wall.
"""
function neighbors(maze::MyMazeModel, position::Position)::Vector{Position}

    # TODO 1: Check that position is inside the map and is not a wall.
    # Throw an ArgumentError if either condition fails.

    # TODO 2: Inspect the cells one step up, down, left, and right. Leave out
    # walls and cells outside the map. Return each remaining position once.

    throw(ErrorException("neighbors is not implemented yet"));
end

"""
    escape_part_1(maze::MyMazeModel) -> Union{Nothing, Vector{Position}}

Find a route from the start to the exit with the fewest moves using breadth-first
search and `MyQueue`. Each move goes one cell up, down, left, or right.

### Arguments

- `maze::MyMazeModel`: A maze containing only `#`, `.`, `S`, and `E`. The model
  and its cell matrix are not modified.

### Returns

- `Vector{Position}`: A shortest route in travel order, including the start
  and exit. Each step moves to a neighboring cell without entering a wall.
  Any shortest route is accepted. Its move count is `length(route) - 1`.
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

Find the states you can reach in one move from `state`. Entering `K` collects
your CornellID automatically. You can enter `D` only if you already have your
CornellID. You keep the ID for the rest of the route and can open every door.

### Arguments

- `maze::MyMazeModel`: The maze to inspect. Its cell matrix is not modified.
- `state::EscapeState`: The current `(row, column, has_cornell_id)`, recorded after
  entering the cell. Check for the invalid inputs listed under Errors. The
  state does not have to be reachable from the start.

### Returns

- `Vector{EscapeState}`: States you can reach by moving one cell up, down,
  left, or right. Include each state once, in any order. Set `has_cornell_id`
  to `true` when entering `K` and keep it `true` afterward. Return an empty
  vector when you cannot move to any neighboring cell.

### Errors

- `ArgumentError`: The current position is outside the map or is a wall, or
  its cell is `K` or `D` while `has_cornell_id` is `false`.
"""
function nextstates(maze::MyMazeModel, state::EscapeState)::Vector{EscapeState}

    # TODO 6: Check the current state and use neighbors to find adjacent cells.
    # A state on K or D must already have the CornellID.

    # TODO 7: Exclude doors when the card is absent. For each remaining neighbor,
    # retain the current flag or set it to true when entering K.

    throw(ErrorException("nextstates is not implemented yet"));
end

"""
    escape_part_2(maze::MyMazeModel) -> Union{Nothing, Vector{EscapeState}}

Find a route with the fewest moves using breadth-first search over
`(row, column, has_cornell_id)` states. Use `MyQueue` to hold states waiting
to be explored and `nextstates(...)` to find the states you can reach next.

### Arguments

- `maze::MyMazeModel`: A maze with at most one CornellID and any number of doors.
  Maps without a CornellID or doors are also accepted. The model and its
  cell matrix are not modified.

### Returns

- `Vector{EscapeState}`: A shortest route in travel order, starting at
  `(maze.start[1], maze.start[2], false)` and ending at the exit, with or
  without your CornellID. Include the start and exit; the move count is
  `length(route) - 1`. Any shortest route is accepted. The route may skip the
  CornellID if no door is needed, or revisit a cell after collecting the ID.
- `nothing`: There is no route to the exit. Return `nothing` rather than
  throwing an error when the exit is unreachable.
"""
function escape_part_2(maze::MyMazeModel)::Union{Nothing, Vector{EscapeState}}

    # TODO 8: Initialize a MyQueue{EscapeState}, discovered set, and predecessor
    # dictionary. Start at S without the CornellID. Store (row, column,
    # has_cornell_id) in all three collections.

    # TODO 9: Search in first-in, first-out order using nextstates. Mark each
    # state when enqueueing it and record the predecessor that discovered it.

    # TODO 10: Reconstruct a shortest route to the exit, with or without the ID.
    # Return nothing if every reachable state is processed without reaching E.

    throw(ErrorException("escape_part_2 is not implemented yet"));
end
