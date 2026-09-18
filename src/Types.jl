"""
    Position

Alias for `Tuple{Int, Int}`, representing a maze location as `(row, column)`.
Both indices are one-based: rows increase downward and columns increase to the
right. Read the corresponding map symbol with `maze.cells[row, column]`.
"""
const Position = Tuple{Int, Int};

"""
    EscapeState

Alias for `Tuple{Int, Int, Bool}`, representing a Part 2 search vertex as
`(row, column, has_cornell_id)`. The first two entries locate a cell using the
`Position` convention. The Boolean records CornellID possession after entering that
cell; it becomes `true` on entering `K` and remains `true` for the rest of a route.
"""
const EscapeState = Tuple{Int, Int, Bool};

"""
    MyMazeModel

Represent a rectangular maze and the locations of its start and exit. Construct
a validated model with `build(MyMazeModel, lines)` or `readmaze(path)`. Search
functions must leave the model and its cell matrix unchanged.

### Fields

- `cells::Matrix{Char}`: Map symbols `#`, `.`, `S`, `E`, `K`, and `D`, indexed
  as `cells[row, column]`.
- `start::Position`: Row and column of the unique `S` cell.
- `goal::Position`: Row and column of the unique `E` cell.
"""
struct MyMazeModel
    # Data fields -
    cells::Matrix{Char}
    start::Position
    goal::Position
end
