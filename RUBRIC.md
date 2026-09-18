# PS2 grading rubric

Every problem set in CHEME 4800/5800 is worth a maximum score of `4`.
The [`testme_part_1.jl`](testme_part_1.jl) and
[`testme_part_2.jl`](testme_part_2.jl) scripts contain **24 tests each, for 48
tests total**. A test that cannot run because of an earlier error counts as failed.

| Score | PS2 condition |
|:---:|---|
| `0` | Something was submitted, but neither test script could run or none of the 48 tests passed. |
| `1` | 1–23 tests passed. |
| `2` | 24–47 tests passed. |
| `3` | All 48 tests passed, but at least one applicable completion requirement was missing or unacceptable. |
| `4` | All 48 tests passed and all completion requirements were accepted. |

The initial-submission and infinite-revision rules in [README.md](README.md)
also apply. Passing all 48 tests does not automatically assign a grade; the
instructor also reviews the completion requirements listed below.

## Official test procedure

For grading, the instructor copies the student's entire submitted `src`
directory, [`Include.jl`](Include.jl), and [`responses.md`](responses.md) into
a clean copy of the released assignment. The submitted `Include.jl` preserves
the loading of any additional helper files. The instructor runs the released
versions of [`testme_part_1.jl`](testme_part_1.jl),
[`testme_part_2.jl`](testme_part_2.jl), [`test_support.jl`](test_support.jl), and
[`check_submission.jl`](check_submission.jl), using the original map files.
Student changes to the test scripts, test support code, submission script,
and maps are ignored. Only the 48 tests in `testme_part_1.jl` and
`testme_part_2.jl` count toward the test results used for grading.

Route tests accept any legal shortest route. Tests of `neighbors` and
`nextstates` accept results in any order, without duplicates. Each route test
verifies the return type, start and exit, legal moves, CornellID pickup and
door access when applicable, and the known minimum number of moves.

## Completion review

To earn a `4`, the submission must meet all these requirements:

- The four requested functions follow the interfaces in
  [`src/Compute.jl`](src/Compute.jl) and the rules in [README.md](README.md).
- Both solvers implement breadth-first search through the supplied
  [`MyQueue`](src/Queue.jl) interface. Shared private helpers are allowed.
  The ordinary search uses geometric neighbors, and the Part 2 search uses
  legal state transitions. Neither solver substitutes hard-coded routes or
  map-specific answers for an algorithm.
- The discovered set and predecessor records use the correct vertex type for
  each part. Input maps remain unchanged.
- Public function documentation accurately describes purpose, inputs, outputs,
  and errors. Private helpers have concise contracts, and non-obvious logic
  has useful comments. The supplied docstrings may be retained when accurate.
- No unresolved implementation `TODO`, placeholder error, or knowingly
  incomplete required task remains.
- All three written responses give relevant, internally consistent, good-faith
  explanations. They need not match a single model answer. Missing, nonsensical,
  or unrelated responses do not satisfy this requirement.

If all 48 tests pass but completion review is still needed, record the result as
**pending review**, not as a provisional `3`. The final score becomes `4` when
all completion requirements are accepted, or `3` when at least one is actually
found incomplete or unacceptable.
