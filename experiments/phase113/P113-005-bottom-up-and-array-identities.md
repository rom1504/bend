# P113-005: bottom-up simplification and array identity experiments

Snapshot: 2026-10-20, 19:37 UTC. Source20 and source21 have checked API receipts;
this record asserts **no completed native or runtime qualification for either**.
Heap-base hoisting is a separate pending proposal and is explicitly absent from
source21 (`heap:false`). The
[interim03 capsule](../../implementation/phase113/interim03/index.json) preserves
these source-check boundaries without copying a running campaign as a success.

## Hypothesis A: simplify before admitting the next inline callee

The [wide18 audit](../../implementation/phase113/interim03/files/042-report.json)
shows a concrete limit: expanding `cell.f3` grows `cell` to 391 nodes, above the
widened 384-node ceiling, leaving the whole `cell` call in its loop caller.
Across 45 functions, nodes grow from 1,799 to 4,961 while direct-call sites fall
from 35 to 20. Raising limits alone moves the boundary and increases code size.

[Bottom-up composition](../../selfhost/tools/performance/phase113/scalar-facts/bottom-up.md)
instead simplifies each completed inline candidate before eligibility/table
insertion. Later callers can reuse a smaller callee. Source20 retains the
original 192-node candidate, 512-node growth and 16-site policy, stack limits,
fresh namespaces, result snapshots and final verification/rollback. The final
range pass remains because caller arguments can expose further facts. This is
distinct from the already tested scalar wrapper-chain inliner: the new hook
composes range simplification with admission.

[API20](../../implementation/phase113/interim03/files/021-report.json) establishes
source checking only here. Required next gates are the independent inliner and
range suites on this exact composition, before/after admission audits, native
aliases/result permutations, and a matched screen. Reject if hot boundaries
remain, if code/stack growth escapes the budgets, or if simplification introduces
changed traces or verifier failures. A smaller eligible body without a reachable
caller change is not sufficient performance evidence.

## Hypothesis B: preserve array identity, then test stable heap state separately

Source21 preserves the exact runtime array handle across array-pair operations
and `array_set`. A full-U64 snapshot precedes the call and any output-buffer
writes. The original call, effects and second result remain; only the known
first result is supplied from that snapshot. This transfers the existing result
ownership credit and creates no additional owner. It does not assert uniqueness,
scalar cells or permission to bypass the guarded array path. See the
[identity builder](../../selfhost/tools/performance/phase113/array-fast/identity-entry.bend)
and [API21 source-check snapshot](../../implementation/phase113/interim03/files/022-report.json).

The separate [heap proposal](../../selfhost/tools/performance/phase113/array-fast/heap.bend)
would load the context's heap base once before the private self-loop label.
It keeps per-operation handle/scalar guards, address masking, payload loads and
fallback helpers. It requires an authenticated stable context/base across all
calls and iterations under the single-thread CPU contract. Allocation or a
callback that could replace that base invalidates the premise. Source21's
[composition](../../implementation/phase113/interim03/files/009-composition21.json)
excludes this overlay; no heap benefit is claimed.

Qualify identity and heap as separate variants before combining them. Require
exact source/runtime admission, snapshot-before-write and result-permutation
checks, shared/static handle fallbacks, owned String cells, both release orders,
wrapped indices and native complete outputs. Heap checks must additionally show
one pre-loop base load, unchanged guards and safe calls across loop backedges.
Reject on changed handle bits, duplicated/lost ownership, fallback mutation,
stale heap addresses or changed failure order.

The prerequisite array17 controls passed, including 23 structural checks and a
completed [matched fixture batch](../../implementation/phase113/interim03/files/036-report.json).
Earlier fixture attempts are retained: an unsupported negative-literal form
and a shared-capture type mismatch failed at the frontend, before native
execution. They are not runtime ownership failures. Successful array17 controls
do not qualify the new source21 identity transfer or pending heap overlay.

All timing uses the frozen inputs and complete-output oracle. The tiny
one-round development screen cannot resolve small changes or establish broad
parity. Full corpus, compiler-time and successive-generation gates remain
separate. This documentation/evidence audit executed no targets and changed no
build artifacts or installed selection.
