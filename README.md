# PS2: Escape from Olin — The Missing CornellID

Problem set 2 connects the queues from Week 3 with breadth-first search from
Week 4. You will write a program that reads a maze and returns a route to its
exit with the fewest moves. Then you will extend the search to handle locked
doors, where the available moves depend on whether you have collected a CornellID.

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

This assignment is supported with Julia `1.12.7` and uses only standard
libraries. There are no external packages to install and no dependency on your
PS1 solution or the course repository.

1. Download the `Source code (zip)` archive from the tagged
   [PS2 GitHub release](https://github.com/varnerlab/PS2-CHEME-4800-5800-Fall-2026/releases/tag/ps2-cheme-4800-5800-2026.1)
   and extract it.
2. In VS Code, open the extracted folder containing
   [`Project.toml`](Project.toml), `README.md`, and
   [`check_submission.jl`](check_submission.jl). This is the PS2 assignment
   root. Open a terminal in the assignment root and run all shell commands
   from the assignment root.
3. Complete the implementation of the four functions in
   [`src/Compute.jl`](src/Compute.jl). Keep any additional helper files inside
   [`src`](src) and load the helper files from [`Include.jl`](Include.jl).
   All library-file `include(...)` calls belong in `Include.jl`.
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

The four starter functions in `src/Compute.jl` intentionally raise errors.
Tests will fail until you supply your implementation of the four functions.
Do not edit [`testme_part_1.jl`](testme_part_1.jl),
[`testme_part_2.jl`](testme_part_2.jl), [`test_support.jl`](test_support.jl),
[`check_submission.jl`](check_submission.jl), or the map files to make an
incomplete solution appear to pass.

## The story

It is late in Olin, you have finished working in the lab, and you are ready to
go home. You're tired and disoriented, the building seems like a maze of corridors and rooms. You have
a floor plan showing your starting location, the walls, and the exit. Your task
is to write a program that uses that floor plan to find a route to the exit
with the fewest moves.

You will develop the program in two parts.

* In **Part 1**, there are no locked
doors, so the program only needs to track your location as it searches.
* In **Part 2**, some routes pass through locked doors that use your CornellID
for access. You start without your CornellID, but its location is marked on the
floor plan. Reaching the exit may require a detour to collect your CornellID and
then a return through a corridor you have already visited. The program must now
track both your location and whether you have the card.

## Reading the map

Each part of PS2 has its own solver: [the `escape_part_1(...)` function](src/Compute.jl)
for Part 1 and [the `escape_part_2(...)` function](src/Compute.jl) for Part 2.

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
the results and file hashes to `MANIFEST.txt`. See
[Checking and submitting your work](#checking-and-submitting-your-work) for
the submission instructions.

### Maze file format

Each line of a maze file is one row of the maze, and each character is one cell.
All rows have the same number of characters. The supplied
[map reader](src/Files.jl) returns a
[`MyMazeModel`](src/Types.jl) with a character matrix `cells` and two positions,
`start` and `goal`.

| Symbol | Meaning | Movement rule |
|:---:|---|---|
| `#` | Wall | You cannot enter this cell. |
| `.` | Open floor | You may enter this cell. |
| `S` | Start | Begin here; you may return later. |
| `E` | Exit | The route ends when you reach this cell. |
| `K` | CornellID | Entering this cell automatically collects your CornellID. |
| `D` | Locked door | You may enter only if you already have your CornellID. |

A position is `(row, column)`, using Julia's one-based indices. Row numbers
increase downward; column numbers increase to the right. For example, `(2, 4)`
means row 2, column 4, and its symbol is `maze.cells[2, 4]`.
The ASCII examples label rows on the left and columns across the top.
The labels and spaces between cells are added for readability; the map files
contain only the maze characters.

You may move one cell **up, down, left, or right**. Diagonal moves, moves through
walls, and moves outside the map are forbidden. Each legal move costs one.
The objective is to minimize the number of moves, not the number of distinct
physical cells visited. Waiting in place is not a move.

Every map has exactly one `S` and one `E`. The reader allows at most one `K`
and any number of `D` cells. It checks the file format, but it does not promise
that an escape route exists. Borders need not consist of walls, so your code
must check array bounds explicitly.

The model types, map construction, file loading, queue, and drawing functions
are supplied. Leave the input maze unchanged throughout a search: record
discoveries and card possession in separate collections.

## Part 1: Find the shortest escape route

In this part, implement the search for mazes without a CornellID to collect or
doors to unlock.
These maps contain only `#`, `.`, `S`, and `E`. Represent each non-wall position
as a graph vertex and each legal move as an edge. Compute the neighbors of a
position when the search reaches it; you do not need to store the entire graph
before beginning the search.

Start with the small Part 1 example,
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
   `Vector{Position}` containing the in-bounds, non-wall cells one orthogonal
   move from `position`.
   Return each neighbor once, in any order. Return an empty vector when no move
   is possible. Throw a descriptive `ArgumentError` if the given position is
   outside the map or is itself a wall.

   The `neighbors` function checks geometry only. Treat `K` and `D` as non-wall
   cells too; Part 2 will decide which geometrically possible moves are legal.

2. **[The `escape_part_1(maze)` function](src/Compute.jl)** uses breadth-first
   search to return a shortest route as a `Vector{Position}`. Include the start and exit, in travel
   order. Return `nothing` if the exit is unreachable. Throw a descriptive
   `ArgumentError` if the map contains any `K` or `D` cell, because those symbols
   require Part 2's state representation.

Use the supplied [`MyQueue`](src/Queue.jl) interface to hold discovered positions
waiting to be explored. This collection is called the search frontier. The
queue operations are the same as in the Week 3 lecture:

```julia
queue = MyQueue{Position}();
push!(queue, maze.start); # append to the back
position = popfirst!(queue); # remove from the front
```

Use `isempty(queue)` before removing an item. The queue's fields are internal;
use its public operations rather than accessing its storage directly.

Your search needs a record of discovered positions and predecessor links.
For each discovered position except the start, its predecessor is the position
from which the search first reached it.
Mark a position as discovered when you add it to the queue, so two different
parents cannot enqueue the same position. When you find the exit, follow the
predecessors back to the start and reverse that sequence. A traversal order is
not an escape route: consecutive entries in the returned route must be joined
by legal moves.

To test `neighbors` and `escape_part_1`, run
[`testme_part_1.jl`](testme_part_1.jl):

```bash
julia --startup-file=no testme_part_1.jl
```

The larger [`data/production_part_1.txt`](data/production_part_1.txt) map has a
minimum escape length of **84 moves**. The tests accept any route achieving
the minimum; they do not prescribe a neighbor ordering or a particular route.

## Part 2: Collect the missing CornellID

Now extend the route finder to handle a CornellID and locked doors. The Part 2
maps may also contain `K` and `D`. Start without the card. Entering `K` collects
it automatically, with no extra move, and you keep it for the rest of the route.
The card is reusable and opens every door in the map. Entering a door cell
while carrying the card costs one move, just like entering a floor cell.
You do not need to collect the card when an escape route avoids all doors.

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

In this maze, `D` blocks the corridor from `S` to `E`, and your CornellID `K`
is at `(4, 2)`. From `S`, move right to the junction at `(2, 4)`, down to row 4,
and left to collect `K`. Return to `(2, 4)`, then follow row 2 to the right,
through `D` to `E`. A shortest escape takes **16 moves**. You visit the junction
twice: once without your CornellID and once carrying it.

> **What identifies a search state?**
>
> In Part 1, your location determines all possible next moves. In Part 2, door
> access also depends on whether you have your CornellID. Use
> `(row, column, has_cornell_id)` as the graph vertex, where `has_cornell_id` is a
> Boolean value. The states `(2, 4, false)` and `(2, 4, true)` describe the same
> physical junction with different access to the rest of the map. Your queue,
> discovered set, and predecessor dictionary must distinguish those states.

The supplied [`EscapeState`](src/Types.jl) alias names the tuple type
`Tuple{Int, Int, Bool}`.
States describe your situation **after entering the cell**, so any state on
`K` must already carry the card. Do not erase `K` or change `D` in the map;
the state records their effect on a particular route.

Complete the remaining functions in [`src/Compute.jl`](src/Compute.jl):

1. **[The `nextstates(maze, state)` function](src/Compute.jl)** returns a
   `Vector{EscapeState}` containing every distinct legal state after one move,
   in any order. Use [the `neighbors(...)` function](src/Compute.jl) for geometric
   candidates, reject entry to a door without the card, and update card possession
   when entering `K`. Once true, the flag remains true.

   Throw `ArgumentError` if the current position is outside the map or is a
   wall, or if the current cell is `K` or `D` while the flag is `false`. You
   only need to check this local validity; you need not prove that a supplied
   state could actually be reached from `S`.

2. **[The `escape_part_2(maze)` function](src/Compute.jl)** uses breadth-first
   search over full states and returns a shortest route as a `Vector{EscapeState}`. Begin with
   `(maze.start[1], maze.start[2], false)` and end at the exit with either flag.
   Use [`MyQueue{EscapeState}`](src/Queue.jl) and
   [the `nextstates(...)` function](src/Compute.jl). Return `nothing` when the exit
   is unreachable, including when the only CornellID is behind a required locked
   door. The `escape_part_2` function must also handle ordinary maps without a
   CornellID or door.

You may reuse private search or route-reconstruction helpers between the two
parts. The `escape_part_1` and `escape_part_2` functions must retain their
documented input and output contracts. A route may revisit a physical position
with a different card flag; that does not repeat a vertex in the state graph.

To test `nextstates` and `escape_part_2`, run
[`testme_part_2.jl`](testme_part_2.jl):

```bash
julia --startup-file=no testme_part_2.jl
```

The larger [`data/production_part_2.txt`](data/production_part_2.txt) map requires
**178 moves** for a shortest escape. The route tests in `testme_part_2.jl`
verify the returned route's start and exit, every move, CornellID possession,
and the minimum number of moves.

## Display your escape route

The supplied [`runmaze.jl`](runmaze.jl) script prints your route and saves an SVG
map. After completing the relevant solver, run:

```bash
julia --startup-file=no runmaze.jl 1 data/test_part_1.txt
julia --startup-file=no runmaze.jl 2 data/test_part_2.txt
```

Open the generated SVG file in the `outputs` folder with a browser. Blue lines
show travel without the card; orange lines show travel while carrying it.
The text view marks visited floor cells with `*`. Repeated visits can overlap
in a picture, so use the printed state sequence to inspect their exact order.
The renderer draws the route you supply; it does not establish that the route
is legal or shortest. No screenshots or drawings are required for submission.

To inspect a map before implementing the solvers, use the Julia REPL:

```julia
include("Include.jl");
maze = readmaze("data/test_part_2.txt");
println(rendermaze(maze));
savemaze(maze, "outputs/keycard-map.svg");
```

Restart Julia after editing source files before rerunning REPL examples. Each
command-line test invocation starts a fresh Julia process automatically.

## Explain your choices

Complete the three prompts in [`responses.md`](responses.md). A short paragraph
per question is enough. Explain why the state must include card possession,
why the queue finds a route with the fewest moves, and how many states the
search might discover. These explanations are part of the completion review;
`check_submission.jl` does not grade the written responses automatically.

## Checking and submitting your work

Run [`check_submission.jl`](check_submission.jl) from the PS2 assignment folder
containing [`Project.toml`](Project.toml), `README.md`, and `check_submission.jl`:

```bash
julia --startup-file=no check_submission.jl
```

The [`check_submission.jl`](check_submission.jl) script runs
[`testme_part_1.jl`](testme_part_1.jl) and
[`testme_part_2.jl`](testme_part_2.jl), with **24 tests per script and 48 tests
total**. It prints the results and writes `MANIFEST.txt` containing test
outcomes and SHA-256 digests of your source files and written responses.
**The `check_submission.jl` script does not connect to Canvas or upload your
work.** After all 48 tests pass, your code, documentation, and written
responses still require the instructor review described in [RUBRIC.md](RUBRIC.md).

Zip the entire problem-set folder, including your source files, maps,
[`responses.md`](responses.md), and the generated `MANIFEST.txt`. Name the ZIP
archive
`CHEME-4800-5800-PS2-<your netid>.zip`, replacing the complete placeholder,
including angle brackets, with your NetID. For example, `abc123` submits
`CHEME-4800-5800-PS2-abc123.zip`. Upload the ZIP archive to the PS2 Canvas assignment.

If you cannot resolve every failure by the deadline, submit your current work
anyway. Partial solutions earn partial credit, and an initial submission is
required for the infinite-revision policy.
