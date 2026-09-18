# Problem Set 2 (PS2): Escape from Olin Hall with a missing CornellID

It is late in Olin. You have finished working in the lab and are ready to go
home, but you're tired and disoriented. The corridors and rooms seem like a
maze. You have a floor plan showing your starting location, the walls, and the
exit. Write a program that uses the floor plan to find a route to the exit
with the fewest moves.

This problem set combines queues from Week 3 with breadth-first search from
Week 4. In Part 1, your program tracks your location. In Part 2, locked doors
require your missing CornellID, so the program must also track whether you
have collected it. Reaching the exit may require a detour to collect your ID
and a return through a corridor you have already visited.

## Logistics

- **Dates:** Release: Saturday, September 19, 2026. Submit a ZIP archive to
  Canvas by **11:59 PM ET on Saturday, October 3, 2026**.
- **Infinite-revision policy:** You must submit something by the initial
  deadline to participate. After that deadline, eligible students may revise
  and resubmit until the end of the semester; the highest score is retained.
  No initial submission means a score of `0` and no access to later revisions.
- **Reference solution:** The reference solution will be released after the
  initial deadline. You may consult it to understand mistakes and debug your
  work, but you may not copy it. Copying the reference solution results in a
  score of `0` for this assignment.
- **Group and AI policy:** Submit independent work. You may discuss ideas with
  classmates but may not share code or solutions directly. You may use Julia
  documentation, AI tools, and internet resources. You are responsible for
  understanding and explaining your submitted implementation.
- **Grading:** The maximum score is `4`; see the
  [grading rubric](RUBRIC.md) for how your test results, code, and written
  responses determine your score.

## Getting started

Use Julia `1.12.7` for this assignment. There are no external packages to
install. You do not need your PS1 solution or the course repository.

1. Download the `Source code (zip)` archive from the tagged
   [PS2 GitHub release](https://github.com/varnerlab/PS2-CHEME-4800-5800-Fall-2026/releases/tag/ps2-cheme-4800-5800-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [`Project.toml`](Project.toml), `README.md`, and
   [`check_submission.jl`](check_submission.jl). This is the PS2 assignment
   root. Open a terminal in the assignment root. Run all shell commands in
   this README from the assignment root.
3. Complete the implementation of the four functions in
   [`src/Compute.jl`](src/Compute.jl). Keep any additional helper files inside
   [`src`](src) and load the helper files from [`Include.jl`](Include.jl).
   Put all `include(...)` calls that load files from `src` in `Include.jl`.
4. Answer the three questions in [`responses.md`](responses.md).
5. Run [`check_submission.jl`](check_submission.jl) to test your implementation
   as you work. The script runs [`testme_part_1.jl`](testme_part_1.jl) and
   [`testme_part_2.jl`](testme_part_2.jl):

   ```bash
   julia --startup-file=no check_submission.jl
   ```

Each test script calls your functions with example inputs and compares the
results with the assignment requirements:

| Test script | What the 24 tests cover |
|---|---|
| [`testme_part_1.jl`](testme_part_1.jl) | `neighbors` and `escape_part_1`: adjacent cells, shortest routes, unreachable exits, invalid inputs, preserving the map, and repeated calls on different mazes. |
| [`testme_part_2.jl`](testme_part_2.jl) | `nextstates` and `escape_part_2`: CornellID pickup, door access, shortest routes, unreachable exits, invalid states, preserving the map, and repeated calls on different mazes. |

The four starter functions in [`src/Compute.jl`](src/Compute.jl) raise errors
because their implementations are missing.
Tests will fail until you supply your implementation of the four functions.
Do not edit [`testme_part_1.jl`](testme_part_1.jl),
[`testme_part_2.jl`](testme_part_2.jl), [`test_support.jl`](test_support.jl),
[`check_submission.jl`](check_submission.jl), or the map files to make an
incomplete solution appear to pass.

## The problem

You will develop your maze search program in two parts.

* In **Part 1**, there are no locked doors, so the program only needs to track
  your location as it searches.
* In **Part 2**, some routes pass through locked doors that require your CornellID
  for access. You start without your CornellID, but its location is marked on the
  floor plan.

## Reading the map

Each part of PS2 has its own solver:
[the `escape_part_1(...)` function](src/Compute.jl) for Part 1 and
[the `escape_part_2(...)` function](src/Compute.jl) for Part 2.

Test each solver on its part's small floor plan, where you can check the route
by hand, then on its part's larger floor plan. The input files are in the
[`data`](data) directory:

| Assignment part | Small example | Larger test maze |
|---|---|---|
| Part 1: corridors without locked doors | [`test_part_1.txt`](data/test_part_1.txt) | [`production_part_1.txt`](data/production_part_1.txt) |
| Part 2: corridors, a CornellID, and a locked door | [`test_part_2.txt`](data/test_part_2.txt) | [`production_part_2.txt`](data/production_part_2.txt) |

The [`testme_part_1.jl`](testme_part_1.jl) script runs `escape_part_1` on both
Part 1 map files. The [`testme_part_2.jl`](testme_part_2.jl) script runs
`escape_part_2` on both Part 2 map files. Both scripts also test small mazes
defined within the scripts.

The [`check_submission.jl`](check_submission.jl) script runs both
`testme_part_1.jl` and `testme_part_2.jl`, prints the test results, and writes
the results to `MANIFEST.txt`. It also warns about unanswered questions in
[`responses.md`](responses.md). See
[Checking and submitting your work](#checking-and-submitting-your-work) for
the submission instructions.

### Maze file format

Each line of a maze file is one row of the maze, and each character is one cell.
All rows have the same number of characters. The supplied
[`readmaze`](src/Files.jl) function loads a file into a
[`MyMazeModel`](src/Types.jl). The `maze.cells` matrix stores the map symbols.
The `maze.start` and `maze.goal` fields store the row and column of the start
and exit.

| Symbol | Meaning | Movement rule |
|:---:|---|---|
| `#` | Wall | You cannot enter this cell. |
| `.` | Open floor | You may enter this cell. |
| `S` | Start | Begin here; you may return later. |
| `E` | Exit | The route ends when you reach this cell. |
| `K` | CornellID | Entering this cell automatically collects your CornellID. |
| `D` | Locked door | You may enter only if you already have your CornellID. |

A [`Position`](src/Types.jl) holds `(row, column)`. Row and column numbers start
at 1. Rows increase downward; columns increase to the right. For example,
`(2, 4)` means row 2, column 4. The symbol at that position is
`maze.cells[2, 4]`.

The four maps are fictional layouts created for this assignment.
The ASCII examples label rows on the left and columns across the top.
The labels and spaces between cells are added for readability; the map files
contain only the maze characters.

Each move takes you one cell **up, down, left, or right**. You cannot move
diagonally, through walls, or outside the map. Each move costs `1` unit of
effort, so the route with the fewest moves takes the least effort.

Every map has exactly one start `S` and one exit `E`. Each maze may
contain at most one CornellID (`K`) and any number of locked doors (`D`),
including none. The [`readmaze`](src/Files.jl) function checks the file format.
A correctly formatted maze may still have no route to the exit. An edge cell
may be open floor, so your search must stay inside the map even without walls
along the border.

The model types, map construction, file loading, queue, and drawing functions
are supplied for your use. __Do not change the maze file.__

## Part 1: Find the shortest escape route

Part 1 maps contain only `#`, `.`, `S`, and `E`. There is no CornellID to
collect and no door to unlock.

Represent each cell that is not a wall as a graph vertex. Each move between
neighboring cells is an edge. Start with the small Part 1 example,
[`data/test_part_1.txt`](data/test_part_1.txt):

```text
      column
        1  2  3  4  5  6  7  8  9
row 1   #  #  #  #  #  #  #  #  #
    2   #  S  .  .  #  .  .  E  #
    3   #  .  #  .  #  .  #  .  #
    4   #  .  .  .  .  .  .  .  #
    5   #  #  #  #  #  #  #  #  #
```

The start is `(2, 2)` and the exit is `(2, 8)`. The wall between them prevents
a straight walk across row 2. A shortest escape takes **10 moves** and contains
**11 positions**, including the start and exit.

Complete two functions in [`src/Compute.jl`](src/Compute.jl):

1. **[The `neighbors(maze, position)` function](src/Compute.jl)** returns a
   `Vector{Position}` listing the cells one step up, down, left, or right from
   `position`. Leave out walls and cells outside the map. Include each
   position once. The order does not matter. Return an empty `Vector{Position}`
   if there are no neighboring cells to include. Throw `ArgumentError` with a
   message explaining the problem if `position` is outside the map or on a wall.

   Include neighboring `K` and `D` cells in the results. The
   [`nextstates`](src/Compute.jl) function in Part 2 handles CornellID pickup
   and decides whether you can enter a door.

2. **[The `escape_part_1(maze)` function](src/Compute.jl)** uses breadth-first
   search to find a route with the fewest moves. Return a `Vector{Position}`
   listing the positions in the order you would walk through them, from the
   start to the exit. Each step must move one cell up, down, left, or right.
   Return `nothing` if there is no route to the exit. Throw `ArgumentError`
   with a message explaining the problem if the map contains `K` or `D`.

Use the supplied [`MyQueue`](src/Queue.jl) to hold positions waiting to be
explored. The queue operations are the same as in the Week 3 lecture:

```julia
queue = MyQueue{Position}();
push!(queue, maze.start); # append to the back
position = popfirst!(queue); # remove from the front
```

Use `isempty(queue)` before removing an item. Use the queue functions instead
of reading or changing the queue's fields directly.

Record each position in a set when you add it to the queue. Add each position
only once. Use a dictionary to record each position's predecessor: the
position from which the search first reached it. The start has no predecessor.

To test `neighbors` and `escape_part_1`, run
[`testme_part_1.jl`](testme_part_1.jl):

```bash
julia --startup-file=no testme_part_1.jl
```

The larger [`data/production_part_1.txt`](data/production_part_1.txt) map has a
shortest route of **84 moves**. The tests accept any route that follows the
movement rules and uses the fewest moves.

## Part 2: Collect the missing CornellID

Part 2 maps may also contain a CornellID (`K`) and locked doors (`D`). You
start without your CornellID. Entering `K` collects your ID automatically,
with no extra effort. You keep the ID for the rest of the route and can use
it to open every door in the map. Moving into `D` costs one move, just like
moving into a floor cell. A route that avoids all doors can reach the exit
without collecting the ID.

Start with the small Part 2 example,
[`data/test_part_2.txt`](data/test_part_2.txt):

```text
      column
        1  2  3  4  5  6  7  8  9 10 11
row 1   #  #  #  #  #  #  #  #  #  #  #
    2   #  S  .  .  .  .  D  .  .  E  #
    3   #  #  #  .  #  #  #  #  #  #  #
    4   #  K  .  .  #  #  #  #  #  #  #
    5   #  #  #  #  #  #  #  #  #  #  #
```

In this maze, a door `D` blocks the corridor from `S` to `E`, and your CornellID
`K` is at `(4, 2)`. From the start `S`, move right to the junction at `(2, 4)`,
down to row 4, and left to collect the ID `K`. Return to `(2, 4)`, then follow
row 2 to the right, through `D` to `E`. A shortest escape takes **16 moves**.
You visit the junction twice: once without your CornellID and once carrying it.

> **What identifies a search state?**
>
> In Part 1, your location determines where you can move next. In Part 2, you
> also need to know whether you have your CornellID. Use
> `(row, column, has_cornell_id)` as the graph vertex. The value of
> `has_cornell_id` is `false` before collecting the ID and `true` afterward.
> The states `(2, 4, false)` and `(2, 4, true)` place you at the same junction,
> but only the second lets you pass through a door. Your queue, set of
> discovered states, and predecessor dictionary must store all three values.

An [`EscapeState`](src/Types.jl) holds three values: **row, column, and whether
you have your CornellID**. For example, `(4, 2, true)` means you are at row 4,
column 2, carrying your CornellID. Entering `K` collects the card immediately,
so the state recorded at `K` must have `true` as its third value.

Complete the remaining functions in [`src/Compute.jl`](src/Compute.jl):

1. **[The `nextstates(maze, state)` function](src/Compute.jl)** returns a
   `Vector{EscapeState}` listing the states you can reach in one move. Include
   each state once. The order does not matter. Use
   [the `neighbors(...)` function](src/Compute.jl) to find adjacent cells.
   You can enter `D` only if you have your CornellID. Set `has_cornell_id` to
   `true` when entering `K`. Keep `has_cornell_id` set to `true` for the rest of
   the route. Return an empty `Vector{EscapeState}` if you cannot move to any
   neighboring cell.

   Throw `ArgumentError` if the current position is outside the map or is a
   wall. Also throw `ArgumentError` if the current cell is `K` or `D` and
   `has_cornell_id` is `false`. A state passed to `nextstates` does not have to
   be reachable from `S`.

2. **[The `escape_part_2(maze)` function](src/Compute.jl)** uses breadth-first
   search to find a route with the fewest moves. Return a
   `Vector{EscapeState}` listing the states in the order you would walk through
   them. Include the start and exit. The first state is
   `(maze.start[1], maze.start[2], false)`: you start at `S` without your
   CornellID. The last state is at `E`, with or without your CornellID.

   Use [`MyQueue{EscapeState}`](src/Queue.jl) to hold states waiting to be
   explored. Use [the `nextstates(...)` function](src/Compute.jl) to find the
   states you can reach in one move. Return `nothing` if there is no route to
   the exit. For example, you cannot escape if the only route requires a door
   and the CornellID is behind that door. The function must also work on maps
   with neither a CornellID nor a door.

You may share helper functions between Parts 1 and 2. Keep the specified
arguments and return types for `escape_part_1` and `escape_part_2`.

To test `nextstates` and `escape_part_2`, run
[`testme_part_2.jl`](testme_part_2.jl):

```bash
julia --startup-file=no testme_part_2.jl
```

The larger [`data/production_part_2.txt`](data/production_part_2.txt) map requires
**178 moves** for a shortest escape. The route tests in
[`testme_part_2.jl`](testme_part_2.jl) verify that the route starts at `S`,
ends at `E`, follows the movement and CornellID rules, and uses the fewest moves.

## Display your escape route

When all 48 tests pass, [`check_submission.jl`](check_submission.jl) prints
your routes through `production_part_1.txt` and `production_part_2.txt` as
ASCII maps. The `*` symbols mark the floor cells your code visits. The script
also saves `outputs/escape-part-1.svg` and `outputs/escape-part-2.svg`, which
you can open in a browser. The routes are shown even if you still need to
finish the discussion questions.

The supplied [`runmaze.jl`](runmaze.jl) script prints an ASCII map and the route
returned by your solver. It also saves a drawing as an SVG file. After
implementing `escape_part_1`, run:

```bash
julia --startup-file=no runmaze.jl 1 data/test_part_1.txt
```

After implementing `escape_part_2`, run:

```bash
julia --startup-file=no runmaze.jl 2 data/test_part_2.txt
```

The ASCII map marks visited floor cells with `*`. The printed route lists
each step in order, including repeated visits to a cell.

To view the drawings, open `outputs/test_part_1-part1.svg` or
`outputs/test_part_2-part2.svg` in a browser. Blue lines show travel without
your CornellID; orange lines show travel while carrying it. The drawing can
hide repeated visits to a cell, so use the printed route to follow every step.
Drawing a route does not check whether it follows the movement rules or uses
the fewest moves. No screenshots or drawings are required for submission.

To view a map before implementing the solvers, run the following commands in
the Julia REPL from the assignment root:

```julia
include("Include.jl");
maze = readmaze("data/test_part_2.txt");
println(rendermaze(maze));
savemaze(maze, "outputs/keycard-map.svg");
```

Restart Julia after editing source files before rerunning the REPL commands.
The terminal commands start Julia again each time you run them.

## Explain your choices

Complete the three prompts in [`responses.md`](responses.md). A short paragraph
per question is enough. Explain why the state must record whether you have
your CornellID, why a queue finds a route with the fewest moves, and how many
states the search could visit. The instructor reads and grades your responses;
[`check_submission.jl`](check_submission.jl) only looks for missing questions,
empty answers, and remaining TODO placeholders. Keep the three numbered
questions and replace each `TODO: Write your response.` with your answer.

## Checking and submitting your work

Run [`check_submission.jl`](check_submission.jl) from the PS2 assignment folder
containing [`Project.toml`](Project.toml), `README.md`, and `check_submission.jl`:

```bash
julia --startup-file=no check_submission.jl
```

The [`check_submission.jl`](check_submission.jl) script runs
[`testme_part_1.jl`](testme_part_1.jl) and
[`testme_part_2.jl`](testme_part_2.jl), with **24 tests per script and 48 tests
total**. It prints the results and records them in `MANIFEST.txt`.
The script also lists questions in [`responses.md`](responses.md) that appear
unfinished. If your code passes but answers are missing, the status is
`DISCUSSION QUESTIONS NEED ATTENTION`. After you fill in the answers, run
`check_submission.jl` again. Finding text under each question does not mean
the answers are correct; the instructor still grades the writing.

**The `check_submission.jl` script does not connect to Canvas or upload your
work.** After all 48 tests pass, your code, documentation, and written
responses still require the instructor review described in [RUBRIC.md](RUBRIC.md).

Zip the entire problem-set folder, including your source files, maps,
[`responses.md`](responses.md), and the generated `MANIFEST.txt`. Name the ZIP
archive `CHEME-4800-5800-PS2-<your netid>.zip`. Replace `<your netid>`, including
the angle brackets, with your NetID. For example, a student with NetID `abc123`
submits `CHEME-4800-5800-PS2-abc123.zip`. Upload the ZIP archive to the PS2
Canvas assignment.

If you cannot resolve every failure by the deadline, submit your current work
anyway. Partial solutions earn partial credit, and an initial submission is
required for the infinite-revision policy.
