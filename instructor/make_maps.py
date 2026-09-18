"""Rebuild the four synthetic teaching maps using fixed random seeds."""
from collections import deque
from pathlib import Path
import random

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"


def adjacent(grid, point):
    """Yield non-wall orthogonal neighbors of one zero-based cell."""
    r, c = point
    for dr, dc in ((-1, 0), (1, 0), (0, -1), (0, 1)):
        rr, cc = r + dr, c + dc
        if 0 <= rr < len(grid) and 0 <= cc < len(grid[0]) and grid[rr][cc] != "#":
            yield rr, cc


def distances(grid, start, blocked=None):
    """Return distances and parents, optionally treating one cell as blocked."""
    distance, parent = {start: 0}, {start: None}
    pending = deque([start])
    while pending:
        point = pending.popleft()
        for neighbor in adjacent(grid, point):
            if neighbor != blocked and neighbor not in distance:
                distance[neighbor] = distance[point] + 1
                parent[neighbor] = point
                pending.append(neighbor)
    return distance, parent


def maze(rows, columns, seed):
    """Carve a connected maze with exactly one path between any two open cells."""
    rng = random.Random(seed)
    grid = [["#"] * columns for _ in range(rows)]
    grid[1][1] = "."
    stack = [(1, 1)]
    while stack:
        r, c = stack[-1]
        candidates = [(r + dr, c + dc) for dr, dc in ((-2, 0), (2, 0), (0, -2), (0, 2))
                      if 0 < r + dr < rows - 1 and 0 < c + dc < columns - 1
                      and grid[r + dr][c + dc] == "#"]
        if not candidates:
            stack.pop()
            continue
        rr, cc = rng.choice(candidates)
        grid[(r + rr) // 2][(c + cc) // 2] = "."
        grid[rr][cc] = "."
        stack.append((rr, cc))
    return grid


def write(name, grid):
    """Save one rectangular map with a final newline."""
    (DATA / name).write_text("\n".join("".join(row) for row in grid) + "\n")


def main():
    DATA.mkdir(exist_ok=True)
    write("test_part_1.txt", ["#########", "#S..#..E#", "#.#.#.#.#", "#.......#", "#########"])
    write("test_part_2.txt", ["###########", "#S....D..E#", "###.#######", "#K..#######", "###########"])

    # Part 1 includes loops and several competing routes -
    grid = maze(17, 25, 48005800)
    candidates = [(r, c) for r in range(1, 16) for c in range(1, 24)
                  if grid[r][c] == "#" and sum(1 for _ in adjacent(grid, (r, c))) == 2]
    random.Random(20260919).shuffle(candidates)
    for r, c in candidates[:10]:
        grid[r][c] = "."
    grid[1][1], grid[-2][-2] = "S", "E"
    write("production_part_1.txt", grid)

    # Part 2 puts a door on the only exit route and the CornellID on an upstream branch -
    grid = maze(21, 31, 20261003)
    start, goal = (1, 1), (19, 29)
    distance, parent = distances(grid, start)
    path, point = [], goal
    while point is not None:
        path.append(point)
        point = parent[point]
    path.reverse()
    door = path[(3 * len(path) // 5) | 1] # an intermediate corridor cell
    accessible, _ = distances(grid, start, blocked=door)
    off_path = set(accessible) - set(path)
    key = max(sorted(off_path), key=lambda p: accessible[p])
    grid[start[0]][start[1]], grid[goal[0]][goal[1]] = "S", "E"
    grid[door[0]][door[1]], grid[key[0]][key[1]] = "D", "K"
    write("production_part_2.txt", grid)


if __name__ == "__main__":
    main()
