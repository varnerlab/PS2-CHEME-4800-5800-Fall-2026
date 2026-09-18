# PS2 grading rubric

PS2 is worth a maximum of **4 points**.
The [`testme_part_1.jl`](testme_part_1.jl) and
[`testme_part_2.jl`](testme_part_2.jl) scripts contain **24 tests each, for 48
tests total**. A test that cannot run because of an earlier error counts as failed.

| Score | Requirements |
|:---:|---|
| `0` | No tests passed. This includes submissions where neither test script could run. |
| `1` | 1–23 tests passed. |
| `2` | 24–47 tests passed. |
| `3` | All 48 tests passed, but one or more requirements below were not met. |
| `4` | All 48 tests passed and all requirements below were met. |

The initial-submission and infinite-revision rules in [README.md](README.md)
also apply. The instructor reviews your code, documentation, and written
answers before assigning a `3` or `4`.

The [`check_submission.jl`](check_submission.jl) script warns about missing
answers and TODO placeholders in [`responses.md`](responses.md). These warnings
do not change the number of passing tests. The instructor grades the written answers.

## How the tests are run

The instructor copies your submitted [`src`](src) directory,
[`Include.jl`](Include.jl), and [`responses.md`](responses.md) into a clean copy
of the released assignment. Copying your `Include.jl` ensures that your helper
files are loaded.

The instructor runs the released [`check_submission.jl`](check_submission.jl),
which runs both test scripts. Grading uses the original test scripts,
[`test_support.jl`](test_support.jl), submission checker, and map files.
Student edits to the tests, checker, and maps are not used for grading. Only the 48 tests in
`testme_part_1.jl` and `testme_part_2.jl` count toward the test score.

Route tests accept any shortest route that follows the movement rules. Tests
of `neighbors` and `nextstates` accept results in any order, without duplicates.
Each route test verifies the return type, start and exit, movement rules,
CornellID pickup and door access when applicable, and the minimum move count.

## Requirements for a score of 4

After all 48 tests pass, the instructor checks the following:

- The four functions use the arguments and return types specified in
  [`src/Compute.jl`](src/Compute.jl) and follow the rules in [README.md](README.md).
- Both solvers implement breadth-first search using the supplied
  [`MyQueue`](src/Queue.jl) operations. Part 1 uses `neighbors`; Part 2 uses
  `nextstates`. The solvers may share helper functions. They must compute
  routes rather than return hard-coded answers for particular maps.
- The discovered set and predecessor dictionary store `(row, column)` in
  Part 1 and `(row, column, has_cornell_id)` in Part 2. Searches leave the
  input maps unchanged.
- Docstrings describe the four functions' purpose, arguments, return values,
  and errors. Helper functions have documentation describing their purpose,
  arguments, and return values. Comments explain code that is difficult to
  follow. You may keep the supplied docstrings if they describe your code.
- All required code is complete. No unfinished implementation TODOs or
  placeholder errors remain.
- All three answers in [`responses.md`](responses.md) address the questions
  and explain your reasoning. Missing answers or answers that are unrelated,
  contradictory, or nonsensical do not meet this requirement. Your answers
  do not need to match the instructor's sample wording.

After all 48 tests pass, your grade is **pending review** until the instructor
finishes checking these requirements. Pending review does not mean a score
of `3`. You earn `4` if all requirements are met, or `3` if any are not met.
