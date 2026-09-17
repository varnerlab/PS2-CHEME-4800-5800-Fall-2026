# PS2 authoring and release notes

**Assignment:** Escape from Olin — The Missing Keycard.

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

The initial release targets are:

- Repository: `varnerlab/PS2-CHEME-4800-5800-Fall-2026`.
- Tag: `ps2-cheme-4800-5800-2026.1`.
- Release title: `PS2: Escape from Olin — The Missing Keycard`.

Keep the reference solution untracked for the initial release; `solution/` is
listed in `.gitignore`. The `.gitattributes` file excludes instructor material
and solutions from Git-generated source archives. Tag the validated starter
commit, then publish the GitHub release for that tag. Later corrections should
use a new tag and updated instruction links rather than moving the original tag.

The validation script only creates temporary test copies. It does not create
a remote repository, tag, GitHub release, or Canvas assignment. The links in
the student README and [Canvas description](canvas-assignment-description.html)
target the planned initial tag; publish that release before posting the Canvas
description. Students still ZIP their completed work and upload it to Canvas,
as they did for PS1.

## What the checks establish

The 48 public grading checks are split into 24 per part. Complete-route checks
validate the route against the original cell matrix, independently of the
student's neighbor functions, and compare its length with a known minimum.
They accept all equally optimal routes and do not enforce neighbor ordering.
The public data include cycles, boundaries, unreachable exits, optional keys,
a key behind a locked door, reusable cards, and a required return through an
already visited junction.

The development suite adds 151 checks of supplied infrastructure, independent
route validation, and reference behavior. Of these, 120 compare small generated
maps with a solver that explicitly constructs states and edges and uses repeated
edge relaxation, rather than the reference implementation's queue search.
These are assignment-development checks, not hidden grading requirements.

The validation driver also checks the command-line renderer and complete,
unfinished, Part-1-only, and syntax-error submissions. The checker intentionally
finishes and writes a manifest even after failed tests. Its process exit code
alone does not certify a completed submission; read its printed status.

## Maps and discussion review

The four maps are synthetic. Their source and digests are described in
[the data README](../data/README.md). The generator in
[make_maps.py](make_maps.py) uses fixed seeds. Regenerating maps should reproduce
their bytes; changing the generator requires recomputing move counts, digests,
public expected results, and the assignment text.

The small keycard map forces the route to visit `(2, 4)` first without the card
and then with it. The three discussion prompts assess state identity, the queue's
shortest-path guarantee, and the bound of at most `P` or `2P` states for `P`
non-wall cells. Sample responses are in the private solution directory.

For grading, copy the submitted `src` tree and `responses.md` into a clean
student distribution and use the original public tests. Apply the completion
review only after all 48 checks pass. Do not assign a provisional score of `3`
while that review is pending.
