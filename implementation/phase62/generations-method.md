# Same-source compiler generations: investigation method

This compares the selected State08 Bend compiler as checked B1 and genuine B2
against the pinned hand-written TypeScript implementation. It changes no
compiler source and installs no image. The purpose is to distinguish the cost
shared by our Bend implementation from cost associated with its generated image.
Results belong in the Phase62 report; this file specifies the method.

## Controlled identities and remaining differences

Both Bend roles use the exact source SHA256
`268b3cf2e1f1c2810c372925ccd1ad7eb91225853d432ca9517f05f2ecefd42e`,
the State08 frozen driver, Base and host helper snapshots, and the same 86
exports. The existing preparation setup independently verifies checked-attempt
and self-emission lineage, source, roots and explicit supplementary-export
admission. No checked sidecar is manufactured for B2.

| Role | Selected implementation |
| --- | --- |
| `b1` | Checked State08 **equality-profile derivative** of the TypeScript-generated bootstrap; API SHA `97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8` |
| `b2` | State08 compiler emitted by that B1; API SHA `23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477` |
| `typescript` | Hand-written compiler at upstream `018751270e800bc222a93dad7f257083ee53a5f7` |

B1 is not pristine upstream output: the checked `equality` profile applies
qualified generated-image transformations. Its actual derivation receipt is
pinned in the recipe. B1 and B2 also differ in generated runtime, ABI adapters,
module size, JS initialization and V8 optimization behavior. This measures
complete image cost under a shared host workflow; a ratio does not isolate a
single emitter optimization. It can motivate a further pristine-B1 experiment
if the image difference is large enough to matter.

TS is a different implementation and does not pass through the Bend host driver.
Both perform ordinary checked library compilation with their existing defaults;
stage partitions must account for differing eager and lazy work. Equal source
and requested output purpose do not imply equal internal operation counts.

## Minimal reuse of the established method

[prepare.py](../../selfhost/tools/performance/phase62/generations/prepare.py)
is a data-only factory. It verifies the exact frozen Phase61 method06 hashes,
copies its four files, and changes only their references to the copied method
and their writable boundary from `selfhost/build/phase61` to Phase62. The
profile module's changed path necessarily changes its pinned hash in the runner.
Every exact replacement and parent/output identity is recorded in a derivation.
Schemas retain their Phase61 kind strings for compatibility; this does not make
the new receipts Phase61 evidence. Closed Phase61 files are read only.

The factory binds both generation roles to the same checked attempt and checks
that the genuine B2 subject source is exactly the B1 source before writing any
method. Target preparation retains the full existing lineage checks. Profiles
retain the 1 ms CPU interval, 128 KiB allocation sampling with collected objects,
signed-delta admission policy and independent sample-count view.

## Reproduction

Run from the repository root. The first command performs only file operations;
root owns every subsequent compiler target.

```sh
taskset -c 0 python3 selfhost/tools/performance/phase62/generations/prepare.py \
  selfhost/build/phase62/generations01
```

This writes `recipe.json` with machine-readable argv and `commands.txt` with
equivalent shell commands. Execute `prepare` first. Its destination is a fresh
Phase62 project for each Bend image, with an API-keyed persistent Base cache.
Preparation covers all 23 sources so the same receipt serves the broad
diagnostics and four-source clean comparison. It verifies retained qualified
raw module references; it does not rerun generated programs or fabricate new
runtime observations.

Run the recorded `clean36` command for Numeric recurrence, MapSet, Lexer and
active raytrace. Each input receives three cyclically rotated rounds across
`b1,b2,typescript`: 36 fresh measurement processes, with each role in every
position once for each source. Source order stays fixed. There are zero later
requests. Use per-source medians and equal-source geometric means; retain all
failures and report variation rather than claiming significance from three
samples. Preparation has a 180 s deadline; the clean comparison has its own
180 s deadline. Expected target wall is roughly 15–30 s preparation and 60–90 s
measurement, estimates only, not guaranteed deadlines.

The recorded `cpu46` and `allocation46` commands each use all 23 sources,
`b2,typescript`, one fresh first request per role/input and a 300 s deadline.
These are separate diagnostic processes. Their durations must not enter the
clean speed comparison. All runners use the existing single process-tree guard,
CPU3, 1 GiB Node heap, 2 GiB tree RSS and 4 GiB available-memory floor. Do not
wrap a second guard around them or inherit CPU0 affinity for a target launch.

Every measurement verifies complete emitted raw bytes after the timing or
profile window. The measured combined window is host/compiler import + ordinary
API load + first checked compilation. The compilation-only window begins after
API load. Preparation, historical audits, input hashing and post-return output
verification remain outside those windows. The OS cache is not claimed cold.

## Interpretation

- If B1 and B2 are close, changing their common Bend data structures and work
  schedule is more promising than optimizing the self-hosted emitter alone.
- If B2 is substantially slower, inspect matched hot functions and ABI/runtime
  costs before changing algorithms. The checked B1 profile remains a confounder.
- If B2 is faster, that is useful evidence that another broad backend rewrite
  need not be the first move. It does not prove optimal generated code.
- In every case, compare the excess stage milliseconds and logical work counts
  against TS before predicting the gain from a proposed optimization.

This four-input diagnostic does not replace the 23-input broad speed result,
establish compiler correctness, or measure emitted user-program execution speed.
