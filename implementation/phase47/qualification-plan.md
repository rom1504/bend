# Phase 47 bounded qualification commands

Prepared runner: [qualify.py](../../selfhost/tools/performance/phase47/qualify.py).
It adapts the eight-suite [Phase44 runner](../../selfhost/tools/performance/phase44/qualify.py)
without changing historical tools or results. This preparation includes static
syntax/review only; the root agent owns execution and candidate selection.

## The unchanged eight-suite gate

From the repository root, set the exact checked attempt and a fresh output path:

```bash
P47_ATTEMPT=/absolute/path/to/the/selected/checked-attempt
P47_QUAL_OUT=/home/ai/bend2/build/publish/bend/selfhost/build/phase47/qualify-selected01
python3 selfhost/tools/performance/phase47/qualify.py "$P47_ATTEMPT" "$P47_QUAL_OUT"
```

The runner is already the resource supervisor. **Do not put it inside another
`ExecutionGuard` or a launcher that acquires the same execution lock.** It uses
one shared guard and eight serial Node children: CPU3, Node24.18.0,
`--stack-size=4096`, 1024MiB heap, 2048MiB polled process-tree RSS ceiling,
4096 MiB available-memory floor, 120s deadline per child. Polling is not a kernel
memory hard limit. Signals, deadlines, low headroom, excessive RSS and nonzero
exits fail the gate and preserve process logs.

| Order | Maintained script | Required result |
| --- | --- | --- |
| 1 | `selfhost/src/back/js/ir/test.mjs ATTEMPT OUT/ir --expect-statements --expect-folds` | Complete PASS, exact candidate API, all37 checks. |
| 2 | `selfhost/src/back/js/test.mjs` | Successful exit; maintained backend observations. |
| 3 | `selfhost/src/back/js/test-global-initializers.mjs` | Successful exit; initializer demand/order. |
| 4 | `selfhost/src/back/js/test-choice.mjs` | Successful exit; choice/erasure behavior. |
| 5 | `selfhost/src/back/js/test-arm.mjs OUT/arm-config.json OUT/arm` | Complete PASS; selected `expectExactArms:false`, all arm semantics. |
| 6 | `selfhost/tools/performance/phase29/controls-guards.mjs OUT/arm-config.json OUT/primitive-guards` | Complete PASS,1129 guards and25 observations. |
| 7 | `selfhost/src/back/js/test-provenance.mjs` | Checked PASS,10 same-named user constructors. |
| 8 | `selfhost/src/back/js/test-foreign.mjs` | Successful exit; foreign boundary behavior. |

Every child command has the exact prefix
`taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024`.
The generated `report.json` records complete argument vectors and environment
before the first child starts. Test scratch under maintained `selfhost/build`
locations may be refreshed; the provenance receipt is copied into the fresh
qualification output. No closed Phase 45/46 evidence is used as a scratch path.

Bindings come from `attempt.json`: candidate API, runtime, Base, and frozen
typed driver. The runner verifies the exact focused-validation attempt and API,
checked compiler/bootstrap/derivation artifacts, Node identity, current/frozen
host tools, and **current `selfhost/src/compiler.json` versus that attempt's
frozen manifest**. The manifest comparison does not claim equality of every
working-tree Bend file with an intentionally isolated candidate source tree.
All pinned inputs, including runtime and proof artifacts, are rehashed through
the run. Fresh child receipts are also retained and rechecked. No API-only
identity is used to substitute a different runtime.

## Minimal Array-specific additions

These are separate scoped gates, not a reason to repeat the eight suites for
each small oracle case. Reuse fresh checked acquisitions of the same fixture
with selected23 and the actual candidate, retaining exact runtime identities.

1. Run [array-view-controls-v2.mjs](../../selfhost/tools/performance/phase47/controls/array-view-controls-v2.mjs)
   against the [existing independent fixture](../../selfhost/tools/performance/phase47/controls/array-view-v1.bend).
   It requires 24 scalar oracles,39 boundary comparisons, a separately instrumented
   raw-entry witness, and zero raw entries for guarded/refused cases. It covers
   aliases, escaped/public storage, zero trips, ignored-read demand, descriptor
   replacement, proxy/getter storage, Number/Array/fill/safe-integer hooks,
   inherited numeric setters, errors, reentry and a self-restoring reflection
   hook. The diagnostic derivative is not a timing module.
2. Run the independently renamed **two-Array** fixture/controller when its author
   supplies the final checked source/catalog. Require positive raw activation,
   independent expected values, separate stores, parameter permutation and
   read-after-write visibility. This adds structural coverage absent from a
   single backing store, without another broad framework. Do not mark it passing
   or invent a command path before those assets exist.
3. For statement expansion specifically, confirm that array, index and value
   expressions execute exactly once in their original order before conversion
   and store; preserve the same returned array and zero-trip demand. A candidate
   may validly keep hostile/public cases on its unchanged path, but controls must
   actually activate the new statement form on a normal closed input. Record
   the new source shape separately from semantic agreement.

The exact existing controller argv is:

```text
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --stack-size=4096 --max-old-space-size=1024 selfhost/tools/performance/phase47/controls/array-view-controls-v2.mjs BASELINE_MODULE.mjs CANDIDATE_MODULE.mjs FRESH_OUTPUT_DIRECTORY
```

Root should schedule that child once through the existing serial `ExecutionGuard`
with the same 2048/4096 MiB limits and a 120s deadline. Do not nest the eight-suite
runner in that guard. Controller syntax/oracle acceptance is not acquisition:
its two checked-emission receipts must identify the actual frozen candidate and
predecessor products before execution.

## Historical Array suites: useful contracts, incompatible launch layouts

[Phase30 native Array controls](../../selfhost/tools/performance/phase30/prototype-array-controls.mjs)
cover helper-level native descriptors, coercions, forcing and public partial
calls, but require four specially derived modules exposing `A_get`/`A_set`.
[Phase30 owned-row controls](../../selfhost/tools/performance/phase30/review-owned-row-controls.mjs)
require four named historical variants and a `derive.json`; they test deferred
raw/forged/construct calls, bounce reuse, aliases and prototype getters.
Neither is directly runnable against two ordinary fresh checked libraries.

[Phase36 array-refusal v2](../../selfhost/tools/performance/phase36/guard-array-controls-v2.mjs)
requires its historical derivation cohort and an exact private-tree marker.
Its16 small oracles and four fill/safe-integer mutation/error/reentry boundaries
are valuable source contracts. The new controller covers these host-callback
hazards without pretending that the old marker/layout belongs to Phase 47.

Therefore the minimal new Array gate is the fresh v2 suite plus the independent
two-store witness, with focused statement-order/activation evidence. If public
raw-code demand or bounce behavior is changed, add those precise deferred-demand
observations from Phase 30 in a separately reviewed successor controller; do not
silently rewrite a consumed historical harness. These scoped gates do not claim
full frontend conformance, performance improvement or installation readiness.
