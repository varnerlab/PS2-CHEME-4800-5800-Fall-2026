# Support testme_part_1.jl and testme_part_2.jl by validating routes directly
# from the map. Route validation does not call the student's neighbors or
# nextstates functions to decide whether a returned move is legal.
module PS2Checks

using ..OlinEscape: Position, EscapeState, MyMazeModel; # assignment types used to check return contracts
export matches_neighbors, matches_states, solves_part_1, solves_part_2;
export valid_part_1, valid_part_2;

"""
    matches_neighbors(actual, expected) -> Bool

Check that a returned neighbor vector contains exactly the expected positions,
without prescribing an order or accepting duplicates.

### Arguments

- `actual`: The value returned by the student's neighbor function.
- `expected`: A collection of distinct positions defining the expected result.

### Returns

- `Bool`: `true` if `actual` is a `Vector{Position}` with the expected entries
  and count; `false` otherwise.
"""
matches_neighbors(actual, expected) = actual isa Vector{Position} &&
    length(actual) == length(expected) && Set(actual) == Set(expected);

"""
    matches_states(actual, expected) -> Bool

Check that a returned state vector contains exactly the expected states,
without prescribing an order or accepting duplicates.

### Arguments

- `actual`: The value returned by the student's state-transition function.
- `expected`: A collection of distinct states defining the expected result.

### Returns

- `Bool`: `true` if `actual` is a `Vector{EscapeState}` with the expected entries
  and count; `false` otherwise.
"""
matches_states(actual, expected) = actual isa Vector{EscapeState} &&
    length(actual) == length(expected) && Set(actual) == Set(expected);

"""
    valid_part_1(maze::MyMazeModel, route) -> Bool

Check a Part 1 route against the original map, independently of the student's
neighbor function. This check establishes legality, not minimum length.

### Arguments

- `maze::MyMazeModel`: The original map. It is not modified.
- `route`: A proposed return value from `escape_part_1(...)`.

### Returns

- `Bool`: `true` if `route` is a nonempty `Vector{Position}` from the start to
  the exit with legal orthogonal moves through `.`, `S`, and `E`; `false`
  otherwise. The value `nothing` is not a route and returns `false`.
"""
function valid_part_1(maze::MyMazeModel, route)::Bool

    # Check the route type and endpoints -
    route isa Vector{Position} && !isempty(route) || return false;
    first(route) == maze.start && last(route) == maze.goal || return false;
    # Check each cell and consecutive move directly from the map -
    for (i, (r, c)) in enumerate(route)
        checkbounds(Bool, maze.cells, r, c) || return false;
        maze.cells[r, c] in ('.', 'S', 'E') || return false;
        if i > 1
            a = route[i - 1];
            abs(r - a[1]) + abs(c - a[2]) == 1 || return false;
        end
    end
    return true;
end

"""
    valid_part_2(maze::MyMazeModel, route) -> Bool

Check a Part 2 route against the original map, including automatic key pickup,
persistent card possession, and door access. This check is independent of the
student's state-transition function and does not establish minimum length.

### Arguments

- `maze::MyMazeModel`: The original map. It is not modified.
- `route`: A proposed return value from `escape_part_2(...)`.

### Returns

- `Bool`: `true` if `route` is a nonempty `Vector{EscapeState}` beginning at the
  start without the card and ending at the exit, with legal moves and card
  flags at every step; `false` otherwise. The value `nothing` returns `false`.
"""
function valid_part_2(maze::MyMazeModel, route)::Bool

    # Check the route type and endpoints -
    route isa Vector{EscapeState} && !isempty(route) || return false;
    first(route) == (maze.start[1], maze.start[2], false) || return false;
    (last(route)[1], last(route)[2]) == maze.goal || return false;
    # Check movement and card possession at every step -
    for (i, (r, c, has_card)) in enumerate(route)
        checkbounds(Bool, maze.cells, r, c) || return false;
        symbol = maze.cells[r, c];
        symbol != '#' || return false;
        if i > 1
            a = route[i - 1];
            abs(r - a[1]) + abs(c - a[2]) == 1 || return false;
            symbol == 'D' && !a[3] && return false; # a door requires the card before entry
            has_card == (a[3] || symbol == 'K') || return false; # the destination flag includes pickup
        end
    end
    return true;
end

"""
    solves_part_1(solver, maze, expected) -> Bool

Check the Part 1 solver's returned route for legality and minimum move count.
Validate against a copy of the original map so a changed map cannot conceal
an illegal route.

### Arguments

- `solver`: A callable with the `escape_part_1(maze)` interface.
- `maze::MyMazeModel`: The input passed to the solver.
- `expected`: The independently established minimum move count, or `nothing`
  when the exit is known to be unreachable.

### Returns

- `Bool`: `true` for a legal route of the expected length, or for `nothing`
  when no route is expected; `false` otherwise.

### Errors

- Exceptions raised by `solver(maze)` propagate to the calling test.
"""
function solves_part_1(solver, maze, expected)::Bool
    original = deepcopy(maze); # retain the map used by the independent route validator
    route = solver(maze);
    expected === nothing && return route === nothing;
    return valid_part_1(original, route) && length(route) - 1 == expected;
end

"""
    solves_part_2(solver, maze, expected) -> Bool

Check the Part 2 solver's returned route for legal state transitions and minimum
move count, using a copy of the original map for validation.

### Arguments

- `solver`: A callable with the `escape_part_2(maze)` interface.
- `maze::MyMazeModel`: The input passed to the solver.
- `expected`: The independently established minimum move count, or `nothing`
  when the exit is known to be unreachable.

### Returns

- `Bool`: `true` for a legal state route of the expected length, or for `nothing`
  when no route is expected; `false` otherwise.

### Errors

- Exceptions raised by `solver(maze)` propagate to the calling test.
"""
function solves_part_2(solver, maze, expected)::Bool
    original = deepcopy(maze); # retain the map and CornellID locations before calling the solver
    route = solver(maze);
    expected === nothing && return route === nothing;
    return valid_part_2(original, route) && length(route) - 1 == expected;
end

end
