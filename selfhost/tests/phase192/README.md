# Phase192 controls and experiment ladder

Selected scope is unary F32/U32 conversion with existing staging removal,
bounded shared addressing, canonical predicates and the original checked H-plan
consumer. See [selection](../../build/phase192/selection01.json) and
[correctness boundaries](../../../implementation/phase192/correctness-boundaries.md).
This index records focused evidence; full native45/native reproduction and
installed release qualification are separate gates.

| Controls / adapter | Purpose and retained result |
|---|---|
| `float-conversion-controls.{bend,c,s}`, `controls.mjs` |6 encoding/data checks and529,280 observations per direct/assembly/independent route in [controls01](../../build/phase192/controls01/report.json). Real pinned runtime, integer IEEE oracle and masked-MXCSR comparisons; no unmasked trap-handler claim. |
| `staging-controls.bend`, `controls.mjs` |27 compiler-data checks in controls01. Verify unary eight-byte buffers, conversion/arithmetic composition, source mutation, overlapping reads/writes, setup, branches, escapes and same-name destinations. These are not27 target executions. |
| `predicate-controls.{bend,c}`, `controls.mjs` |11 shape checks and1,331 C observations per generated route in controls01; exact0/1 facts, overwritten/noncanonical values, joins/calls and ordered destination writes. |
| `shared-address-controls-v2.bend`, `shared-machine-controls.{bend,c}`, `controls-v2.mjs` |25 data checks and2,400 C observations per route in [controls02](../../build/phase192/controls02/report.json). Twenty emitted functions span joint/legacy/stack/oversize-fallback placement. Original eight-row fixture/driver remain retained; real fold required eleven rows, motivating the certified16-row cap. |
| `recursive-worker-controls.bend`, `.c`, `.mjs` |Reuse immutable Phase186 stacked-frame verifier/planner families; six admission checks and84 state/result observations per route through depth100001 in [recursive-workers03](../../build/phase192/recursive-workers03/report.json). Attempts01/02 retain API/fixture-authority failures. |
| `recursive-source-controls-v3.mjs`, `recursive-controls-v3.json` |Six ordinary sources, literal stdout and actual H admission/refusal probes. [02](../../build/phase192/recursive-controls02/report.json) completes one/two/tree/ready; [03](../../build/phase192/recursive-controls03/report.json) completes corrected sharing; [04](../../build/phase192/recursive-controls04/report.json) completes corrected fallback.02/03 are incomplete reports; only their explicit completed rows compose the six-case evidence. |

`recursive-controls-oracle.py` is an independent explicit-frame/integer/tree
oracle; source-driver receipts record `oracleExecuted=false` and compare the
frozen complete literal outputs. Do not infer H selection from source syntax:
the actual fallback probe records dynamic apply and old-H=0/view-H=0. Worker
controls check the original verifier before querying the planner, rather than
manufacturing a plan with `valid=true`.

The first source driver exceeded the unchanged2GiB process-tree RSS budget.
The v2/v3 drivers bound emission temporaries to `emitCase`, then run full host
collection before child execution; retained memory observations explain the
fix. The original sharing source had an invalid binding inside `do IO`; the
original fallback attempted duplicable closure typing. Corrected v2 fixtures
preserve output oracles, while original files and failures remain. Details:
[host memory](recursive-source-controls-v2.md),
[sharing](recursive-source-controls-v3.md),
[affine fallback](recursive-controls-fallback-v2.md).

## Excluded experimental lanes

`path-facts-experimental.bend` and `controls-path.mjs` have17 data checks and2,873
C observations per route in [path-controls01](../../build/phase192/path-controls01/report.json).
They have no measured production runtime result and are not selected. The
`float-regions-experimental.bend` widening prototype is not selected either;
mixed integer/F32 definitions still block its intended hot XMM placement.

`scoped-frames-experimental-v2.bend` strengthens scope validation to one exact
definition across parameters/nested setup/body. Scope-off objects are byte-equal
to the original H products for tree/expression/lexer
([receipt](../../build/phase192/scoped-default-identity01.json)); scoped expansion
remains excluded after mixed runtime benefit and added compiler work.
`scoped-reentry01` failed because its observer used the real runtime frame helper
before activation. `scoped-reentry-controls-v2.mjs`/`.c` activate a complete
descriptor with public `p111_rt_main` and retain all84 observations. **That v2
machine gate is pending at this index's cutoff.** See its
[runtime-activation explanation](scoped-reentry-controls-v2.md); do not count the
failed first observer as a semantic compiler mismatch or a passing gate.

## Replay and authority

Use fresh guarded run roots and explicit disk/time/RSS budgets under the
[build-retention workflow](../../../docs/self_hosted/build-retention.md).
Root owns the single CPU3 compiler/target execution lane. Adapters authenticate
the checked API receipt and exact fixture membership before emission; a source
file appended after checking is not authorized by that receipt. Preserve pinned
runtime/toolchain, source metadata and full stdout. `--cases` source subsets
record selection completion separately from full-catalog completion.

`prepare-experiment.py`, `emit-programs.mjs`, `references.py`, `summarize.py` and
`qualification-plan.py` support acquisition/measurement/qualification;
`diagnostic.bend`/`.mjs` emit data-only preselection evidence and must never be
rendered or linked as target programs. Read [diagnostic usage](diagnostic-usage.md).
Historical integration notes describe their authoring-time status; current
selection and actual run receipts take precedence. Finite tests, source checking,
exact machine reproduction and independent kernel proof are distinct evidence.
