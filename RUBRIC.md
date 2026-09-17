# PS2 grading rubric

Every problem set in CHEME 4800/5800 is worth a maximum score of `4`.
This assignment has **48 public checks**, split evenly between the two parts.
A check not reached because an earlier error stops a suite counts as failed.

| Score | PS2 condition |
|:---:|---|
| `0` | Something was submitted, but the grading harness could not execute any checks or none of the 48 checks passed. |
| `1` | The tests ran and 1–23 checks passed. |
| `2` | The tests ran and 24–47 checks passed. |
| `3` | All 48 checks passed, but at least one applicable completion requirement was missing or unacceptable. |
| `4` | All 48 checks passed and all completion requirements were accepted. |

The initial-submission and infinite-revision rules in [README.md](README.md)
also apply. Passing both suites is feedback, not an automatically assigned grade.

## Official test procedure

For grading, the instructor copies the student's entire submitted `src`
directory and [`responses.md`](responses.md) into a clean copy of the released
assignment. The instructor runs the original tests, support functions, checker,
and maps. Student changes to those files are ignored. The public suites are the
48-check grading target; instructor development checks validate the assignment
itself and do not add undisclosed student grading requirements.

Route checks accept any legal shortest route. Neighbor and state-transition
checks accept any ordering without duplicates. Each complete-route check
verifies the return contract, endpoints, legal steps, keycard behavior when
applicable, and the independently established minimum move count.

## Completion review

To earn a `4`, the submission must meet all these requirements:

- The four requested functions follow the interfaces in
  [`src/Compute.jl`](src/Compute.jl) and the rules in [README.md](README.md).
- Both solvers implement breadth-first search through the supplied
  [`MyQueue`](src/Queue.jl) interface. Shared private helpers are allowed.
  The ordinary search uses geometric neighbors, and the keycard search uses
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

If all checks pass but completion review is still needed, record the result as
**pending review**, not as a provisional `3`. The final score becomes `4` when
all completion requirements are accepted, or `3` when at least one is actually
found incomplete or unacceptable.
