# Phase84 prototype fast loops

[Design](../../../../design/phase84/replace-native-work.md) ·
[Results](../../../../implementation/phase84/README.md).

Root runs one guarded CPU3 target tree. Agents prepare source patches and
controls without running compilers. Do not overwrite a completed output
directory or mutate frozen method inputs.

## Checked builds and fresh request screens

Use `development.json` through `tools/development/workflow.mjs run` inside
`phase46/job.py`. The equality profile requires checked B1 and36 frontend cases.
Create a new `selfhost/build/phase84/compilerNN` directory per source attempt.

`prepare-screen.py ATTEMPT_JSON NEW_OUTPUT` binds the actual checked snapshot
to the frozen Phase83 baseline (Phase82 compiler). Default cases are Numeric,
Map, Functions65 and Small with two rotated rounds. Candidate preparation is
new and API-keyed; baseline preparation is reused with its exact original plan
identity. `--stage b2 --images IMAGE_PINS --typescript` selects genuine B2
and the pinned upstream role. `--cases` and `--rounds` expand a new plan.

Run `run.py --plan PLAN --group prepare`, then `--group clean`. Every target
uses the guard and every complete C file must match its per-role oracle.
`summarize-screen.py PLAN OUTPUT_JSON` retains all clean samples and computes
medians and equal-source ratios. Preparation and imports are separately
recorded, not included in the request clock. There is no process reuse. The
upstream comparator includes Base load/check but not its CLI proof-report
helper; Bend requests retain ordinary reports.

## Diagnostic controls

- `report-controls-v2.mjs PLAN OUT [candidate]`: full report product equality,
  readiness fallback, explicit API isolation, unsafe dependencies and refusals.
  V1 remains preserved with its malformed Data/Type fixture.
- `fusion-controls.mjs PLAN CASE OUT`: full annotated definitions and complete
  NR_Request equality, exact C, owned route and unchanged cache/input checks.
- `fusion-controls-v4.mjs PLAN CASE_OR_all OUT`: six runnable pinned fixtures,
  full owned fusion-disabled comparison. Earlier v2/v3 preserve fixture and
  explicit/raw-contract mistakes; their failed runs are not positive gates.
- `selection.mjs PLAN CASE OUT`: baseline diagnostic of conservative annotation
  versus actual runtime names. Its flat erased-fact scan cannot see nested
  caches; zero there is not evidence of missing caching.

Diagnostics repeat work and are not clean speed samples. Run them through the
same bounded guard, serially. Structural comparisons preserve metadata and
cache products, rather than assuming equal final C proves all behavior.

`prepare-bootstrap.py` is a source-hash-bound derivative of Phase82's genuine
B2 recipe. Export additions need explicit admission; tiny split/unsplit output
identity and eight actual driver observations remain required. Image generation
is distinct from full self-check/reproduction and release qualification.

`profile-worker.mjs`/`run-profile.py` are separately pinned derivatives that
observe the actual fusion stages. `prepare-refusal-counts.py` creates a
disposable B1 wrapper counting exact predicate results, with prior C required.
Those images/clocks never count as clean compiler measurements.

`summarize-evidence.py` validates completed receipts and includes failed guards
in resource accounting. `seal.py` archives every new raw artifact and verifies
all members; parent inputs remain retained by their existing evidence capsules.
