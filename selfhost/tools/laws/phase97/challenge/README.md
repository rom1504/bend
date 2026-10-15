# Independent Phase97 challenges

The [frozen manifest](manifest.json) contains **eight semantic faults and two
equivalent changes**, selected from maintained helper implementations before any
Phase97 suite outcomes. Seven faults are synthetic; one restores an exact
historical defect. Production files were not edited and no compiler or program
target was run by the challenge author.

Manifest SHA-256:
`4ae912048532e59fb3f058a69f69893b560c7defedac070c07ce6c13ebd977a3`.
Source commit: `52065f4e1a793805698803873c51234f79f35ed9`.
Freeze: `2026-10-15T19:15:24.050375+00:00`.

Each `{id}.json` has flat `id`, `kind`, `file`, `function`, `before`, `after`,
`expectedBehavior`, `witness` and `provenance` fields. Its `edits` entry also pins
the original source, requires exactly one replacement and records the complete
changed source hash and size. Apply each recipe independently to a private copy
of its pinned original. `kind` is `bad`, `historical` or `good`; the first two
count toward the eight semantic challenges.

Each `{id}.witness.bend` supplies an actual expression and both complete expected
values as typed functions. These source-reasoned witnesses have not been run.
They are small helper harness fragments, to append to an assembly containing the
maintained dependencies; they are not complete compiler-source assemblies. The
baseline corpus should run unchanged first. If a challenge escapes or its helper
is absent, retain that result before adding its targeted witness. A missing
helper is an explicit coverage gap, not a detected semantic fault.

Selection did **not** inspect Phase96 law bodies, mutation recipes, case corpus
or `reference.py`. The broad task and high-level totals in `STEERING.md` were
known, so this is independent selection rather than rigorous blinding. A second
offline agent searched only Git history for the permitted helper paths. The
exact historical fixing diff is [preserved here](historical-fid-fix.patch).

`freeze.py` records all choices and validates unique edits/source stability
without applying them. It refuses existing outputs: do not rerun it over the
frozen set or revise choices after viewing outcomes. Keep execution/admission
failures, observed semantic differences, uncovered helpers and rejection of
legitimate equivalent controls as separate categories.

The [review](../../../../../implementation/phase97/challenge-review.md) explains
the distinguishing cases and historical provenance. No universal correctness,
performance, formal proof or detection-rate claim is made by these artifacts.
