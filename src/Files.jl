"""
    readmaze(path::AbstractString) -> MyMazeModel

Read a text map and construct its validated maze model. Each physical line is
one map row; blank rows, spaces, and comments are not part of the map syntax.

### Arguments

- `path::AbstractString`: Path to the map file. Unix and Windows line endings
  are accepted, and a final newline is optional.

### Returns

- `MyMazeModel`: The map returned by `build(MyMazeModel, lines)`, including its
  character matrix and one-based start and exit positions.

### Errors

- `ArgumentError`: The file contents fail the map validation in `build(...)`.
- `SystemError`: The file cannot be opened or read.
"""
function readmaze(path::AbstractString)::MyMazeModel
    return build(MyMazeModel, readlines(path));
end
