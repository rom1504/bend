# Final-image integration

Installed and verified image: `selfhost/build/phase39/checked05`, API SHA256
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
All final gates refer to this image. Earlier checked01/checked04 successes are
development evidence and cannot close its release obligations.

The 45-point preparation is `final-candidate01`; `historical-final01` is a
verified metadata-only subset of its original emissions and receipts. The
frozen inherited plan is `final-plan01`. Root runs target jobs serially on CPU3,
with Node24.18, a 1 GiB heap, 2 GiB process-tree RSS ceiling and 2 GiB available
memory floor. Output paths below are under `selfhost/build/phase39/` unless
otherwise stated.

## Preserved audit and control failures

`final-launch01` stopped at the inherited counter structural control. All 35
input-oracle rows passed before it required `count.scalar` to retain BigInt.
That expectation describes the previous vector-only optimization. The new
source deliberately narrows a proved private scalar countdown too. The first
three structural observations already showed that `count.keep` narrows and
the observable/stored predecessors retain BigInt.

The independently reviewed Phase39 counter-control successor requires Number
for both `count.keep` and `count.scalar`, keeps the observable/stored predecessor
and alias refusals, and retains all value and five live mutation checks. The
versioned rebinder requires identical original oracle results and unchanged
first three structural rows. It also binds the successful bounded command,
consumed control bytes, checked cohort and final compiler. It replaces only
the counter entry in a new owner mapping. The original plan, failed reports and
old test remain immutable.

`final-launch02` resumed independent owner groups after that counter test, then
stopped when the old aggregate correctly refused its failed counter report.
`final-launch03` resumed at `frontend-main`. These are explicit partial launch
receipts, not a claim that either failed launcher completed. A new aggregate and
the final gate audit now close the preserved successful groups plus the
versioned counter successor: `counter-owner-rebind01/owner-report.json` accepts
all 15 inherited Phase35 owner groups, and `final-audit01/gates.json` accepts
all 14 pre-install gate groups.

The new-owner auditor v2 independently failed on a receipt schema assumption:
TypeScript records `status=ok`, `checked=true`, `mode=library`, but does not have
the Bend receipt's `phase`/`exitCode` fields. Reviewed v3 still requires Bend's
compile phase and zero exit code, preserves TS pin/source/library checks, and
requires zero-status acquisition processes for every role. No semantic count or
checked-emission obligation was removed. The failed v2 receipt and consumed
tools remain at `new-owner-close01` and `new-owner-close-run01`.

V3 then accepted the countdown owner but stopped on a bootstrap module identity
such as `src/core/term.bend`. Bootstrap reports do not have a `kind` field, and
their relative module names refer to the assembled compiler snapshot. V4 adds
that explicit namespace: it binds the report to its sibling checked attempt,
verifies the assembled source inside the frozen snapshot, and checks every
module against both its absolute provenance and matching frozen source bytes.
It continues to reject unknown namespaces. Independent review confirmed that
the semantic, observation-count and resource assertions are unchanged. The v3
failure remains at `new-owner-close02` and `new-owner-close-run02`; root's v4
closure passes at `new-owner-close03/report.json`.

## Completed final-image checks

| Gate | Final checked05 result | Raw receipt |
|---|---|---|
| Inherited Phase35 owners | 15 groups pass, including reviewed counter successor | `counter-owner-rebind01/owner-report.json` |
| Inherited Phase36 owners | 7 groups pass; 982 file identities and 15 pinned Git blobs verified | `phase36-owner-close01/report.json` |
| Inherited Phase37 owners | Cast, DataView and finite groups pass; 710 file identities and 15 pinned Git blobs verified | `phase37-owners01/closure/report.json` |
| New Phase39 owners | 4 groups pass; 775 file identities and 15 pinned Git blobs verified | `new-owner-close03/report.json` |
| Pre-install correctness closure | All 14 gate groups accepted; all 227 canonical/frozen source pairs match | `final-audit01/gates.json` |
| Expanded application correctness | 154/154 observations pass, zero failed or pending | `expanded-correctness01/report.json` |

These denominators overlap and must not be added into a unique test total.
The 14-group closure includes the Phase35 owner aggregate; the three subsequent
owner closures remain separate. The expanded application check covers all 45
catalog points plus 32 small application controls, each under the final Bend
compiler and pinned TypeScript compiler. It is an untimed correctness gate.

The main frontend sweep matches all **3,026 observations exactly**; the broader
sweep matches all **196**, with zero behavioral or extra-field differences.
The main sweep's recorded fixture statuses remain 2,525 passes, 497 observations
and four shared failures. Exact agreement does not turn those failures into
fixture passes. Backend pilot agreement is **81/81 exact**, comprising 69 passes,
four shared failures and eight not-applicable rows. Other retained gates include
36 focused probes, 15 selected upstream probes, 127 corpus points across 23
libraries, scalar/worker/guard controls and the retained HVM witness. This is
the stated backend scope, not full backend or GPU conformance.

The [four-owner closure](new-owner-gates.md) completed in 3.516 seconds with
27,500,544 bytes peak process-tree RSS. Its report SHA256 is
`5be69ea17b8e97afb5b8fe30a96a2ac3ec5df54a9cbc6333375c58aefaaa017a`.
The [pre-install audit](../../selfhost/build/phase39/final-audit01/gates.json)
SHA256 is `c5bb978b4ac9afcb87cc04358bcaa27c9a6196ec0b9c7ead44a5587cc9c079db`.
These costs and identity checks do not establish generated-program speed.

[Canonical source verification](canonical-preinstall.json) independently
confirms all 227 original/frozen source file pairs match the selected attempt.
The new backend documentation lives outside the checked snapshot in
[backend-rules.md](backend-rules.md), avoiding an unnecessary rebuild solely
for documentation. The canonical backend README matches its frozen bytes.

## Installed release and preserved smoke retry

`postinstall-launch01/report.json` records successful `release-install` and
`release-verify` steps for checked05. Its initial smoke step failed: all six
ordinary/relocated CPU build rows reported `spawnSync clang-16 EPERM`. The JS,
interpreter and other reached checks passed. The incomplete launcher and all
failure logs remain unchanged; the missing CPU execution rows are not counted
as passes.

Root reran the **unchanged** frozen
`final-plan01/tools/release-smoke-launch.mjs` with permission to launch the
native toolchain, under the same CPU and memory bounds, into
`release-smoke-retry01`. The new `checks/report.json` passes **42/42 ordinary
and relocated CLI checks**. Its bounded receipt,
`release-smoke-retry-run01/run.json`, records 41.797 seconds and 602,902,528 bytes
peak process-tree RSS. This is release-validation workflow cost.

The independently reviewed
[`final-gate-audit-v1.py`](../../selfhost/tools/performance/phase39/final-gate-audit-v1.py)
adds an explicit `--release-smoke-report` selection. Every original semantic
gate function, including the 42-check CLI validator, is unchanged. The
successor separately verifies the original Phase37 audit ancestry and its own
[derivation](../../selfhost/tools/performance/phase39/final-gate-audit-v1.json),
binds the retry to the exact frozen plan launcher/runner, consumed launcher,
selected Node/API, inner and outer commands and resource bounds, and retains
identities for the failed launcher, failed check report and all six EPERM logs.
It neither remaps the old failure nor substitutes a reduced smoke test.

The final [post-install closure](final-conformance/gates.md) passes **15/15 gate
groups**, verifies **227 canonical source files**, and records
`postInstallChecked=true`. Its [machine-readable receipt](final-conformance/gates.json)
has SHA256 `da56bf23a3dbb97af3bf22a772ad3f55c00a57d112c9d5ee1a73c50fd8f77e9f`;
the bounded audit execution remains at `postinstall-audit-run01`. The three
subsequent owner closures and their separate denominators remain as listed
above.

The [45-point execution report](execution/report.md),
[compiler-request study](compiler-cost.md) and
[performance admission](performance-admission.md) complete the separate
performance decision with their measured costs and limitations. Ignored raw
paths above can be restored from the phase evidence capsule once published.
