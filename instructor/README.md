# PS2 authoring and release notes

**Assignment:** Escape from Olin Hall with a missing CornellID.

**Confirmed dates:** Release September 19, 2026; initial submission due
October 3, 2026 at 11:59 PM ET. Both dates are Saturdays.

The student workload is four functions in `src/Compute.jl` and three short
responses. Map reading, model construction, the FIFO queue, plotting, and the
submission checker are supplied. No Julia packages outside the standard library
are needed. The queue retains Week 3's public operations but uses a moving front
index internally; student code should depend only on the interface.

## Validate and prepare the GitHub release

From the authoring root, run:

```bash
python3 instructor/validate.py
```

Validation uses temporary copies, so it never completes the student starter in
place. Complete logs are written to the ignored `instructor/validation-output`
directory. The reference implementation lives in the ignored `solution`
directory; keep it private until the solution release.

Use the same distribution workflow as PS1: publish a tagged GitHub release and
have students download its automatic **Source code (zip)** archive from the
release's **Assets** section. A separately built or uploaded ZIP is not needed.

The [PS2 release Action](../.github/workflows/release-ps2.yml) follows the weekly
bundle workflow: pushing a release tag runs validation and creates a **draft**
GitHub release. The Action checks a temporary Git source archive, including
the starter functions, supplied code, discussion warnings, map data, and local
links. It does not require or upload the private reference solution. Run the
full local validation above before committing and tagging the release.

The initial release targets are:

- Repository: `varnerlab/PS2-CHEME-4800-5800-Fall-2026`.
- Tag: `ps2-cheme-4800-5800-2026.1`.
- Release title: `PS2: Escape from Olin Hall with a missing CornellID`.

Keep the reference solution untracked for the initial release; `solution/` is
listed in `.gitignore`. The `.gitattributes` file excludes GitHub workflows,
instructor material, and solutions from Git-generated source archives.

After committing the validated starter, check the committed archive and push
the branch and release tag:

```bash
python3 instructor/validate_release.py
git push origin main
git tag -a ps2-cheme-4800-5800-2026.1 -m "PS2 student assignment"
git push origin ps2-cheme-4800-5800-2026.1
```

Wait for the Action to finish, then review the draft release and publish it
when ready. The release notes come from [release-notes.md](release-notes.md).
Later corrections should use a new tag and updated instruction links rather
than moving the original tag.

The local validation scripts only create temporary test copies. They do not create
a remote repository, tag, GitHub release, or Canvas assignment. The links in
the student README and [Canvas description](canvas-assignment-description.html)
target the planned initial tag; publish that release before posting the Canvas
description. Students still ZIP their completed work and upload it to Canvas,
as they did for PS1.

## What the test scripts verify

The [`testme_part_1.jl`](../testme_part_1.jl) and
[`testme_part_2.jl`](../testme_part_2.jl) scripts contain 24 tests each, for 48
tests used in grading. Route tests validate the route against the original
cell matrix, independently of the
student's neighbor functions, and compare its length with a known minimum.
They accept all equally optimal routes and do not enforce neighbor ordering.
The test mazes include cycles, boundaries, unreachable exits, optional keys,
a key behind a locked door, reusable cards, and a required return through an
already visited junction.

The [`verify_solution.jl`](verify_solution.jl) script adds 151 tests of the
supplied code, route validation, and reference solution. Of these, 120 compare
small generated maps with a solver that explicitly constructs states and edges
and uses repeated edge relaxation, rather than the reference implementation's
queue search. The tests in `verify_solution.jl` validate the assignment and do
not affect student grades.

The [`validate.py`](validate.py) script also tests the command-line renderer and
complete, unfinished, Part-1-only, and syntax-error submissions. The
[`check_submission.jl`](../check_submission.jl) script finishes and writes a
manifest even after failed tests. Its process exit code alone does not certify
a completed submission; read its printed status.

The submission script warns about missing discussion questions, empty answers,
and TODO placeholders. The [`verify_discussion.jl`](verify_discussion.jl)
script tests those warnings, including answers with Windows line endings.
Validation also checks missing and unreadable response files. The manifest
records SHA-256 digests of `Include.jl`, the files in `src`, and `responses.md`
when readable.
The warnings do not grade the writing or change the 48 test results. If code
passes but discussion answers appear unfinished, the submission status is
`DISCUSSION QUESTIONS NEED ATTENTION`.

After all 48 tests pass, the submission script displays the student's routes
through both production maps as ASCII art and saves `outputs/escape-part-1.svg`
and `outputs/escape-part-2.svg`. Missing discussion answers do not hide the
routes. A drawing error does not prevent the manifest or submission instructions
from being written. Validation checks both behaviors.

## Maps and discussion review

The four maps are synthetic. Their source and digests are described in
[the data README](../data/README.md). The generator in
[make_maps.py](make_maps.py) uses fixed seeds. Regenerating maps should reproduce
their bytes; changing the generator requires recomputing move counts, digests,
public expected results, and the assignment text.

The small Part 2 map forces the route to visit `(2, 4)` first without the card
and then with it. The three discussion prompts assess state identity, the queue's
shortest-path guarantee, and the bound of at most `P` or `2P` states for `P`
non-wall cells. Sample responses are in the private solution directory.

For grading, copy the submitted `src` tree, `Include.jl`, and `responses.md`
into a clean student distribution and run the released `testme_part_1.jl` and
`testme_part_2.jl` scripts. Preserve the submitted `Include.jl` so additional
helper files are loaded. Apply the completion review only after all 48 tests
pass. Do not assign a provisional score of `3`
while that review is pending.
