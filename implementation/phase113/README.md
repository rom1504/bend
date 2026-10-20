# Phase113 — complete native functions and QBE program performance

**Campaign in progress.** Started 2026-10-20 at18:07 UTC; the requested
three-hour window ends at21:07 UTC. No parity, full45, or new self-hosting
qualification is claimed by this interim report.

The [committed design](../../design/phase113/qbe-program-parity.md) records
the1×,10× and100× ambition levels before implementation. The target is the runtime
of compiled Bend programs. Compiler request time, image construction and
self-hosting consistency are separate gates.

## First finding: preserve complete functions before creating continuations

The new Bend-written path lowers the existing checked, erased core into
structured ordinary functions, direct calls, local branches and parallel
self-tail assignments. It reuses the existing scalar operations, ownership
partition, original checked types, runtime and generic fallback.

The first source-checked version passed all12 execution fixtures but admitted
only3 functions in the scalar benchmark. This was not evidence that the hot
loop had improved. A separate checked-API inspection found28 refusals caused by
applied `Efq` in generated final match branches. The original runtime aborts
when evaluating that callee, before evaluating its arguments. Preserving that
same fail-stop behavior let the new path admit19 functions, including the loop.

The actual `mit` body then contained0 runtime frames,0 runtime jumps and7
ordinary calls, versus7 static frame sites in the previous private body. Its
text shrank from18,636 to6,473 bytes. An audit followed the real benchmark
call chain and retained public/private wrappers to this new implementation;
the change is not merely an unused optimized function. See
[the structural witness](../../selfhost/tools/performance/phase113/direct/structural-witness08.md).

## Early runtime observations

These are **one-round development diagnostics**, using the new frozen
six-program15ms screen. Every role uses the same original workload arguments,
repetitions, warmups and complete-output checks. They are not full45 results
or statistically resolved small improvements.

| Program | Upstream ms | Frozen facts ms | Complete functions08 ms | Enhanced09 ms |
|---|---:|---:|---:|---:|
| scalar-region8192 |15|181|161|140|
| local-pair |19|2149|670|690|
| editdist |15|2328|675|674|
| active ray256 |16|927|428|363|
| lexer |14|212|134|130|
| closures256 |19|193|204|192|

Source: `selfhost/build/phase112/p113-enhanced-screen09/phase113-report.json`.
The enhanced version adds conservative primitive/closed-result ownership facts,
the existing Word-pattern and known-selector semantic plans, and cached
liveness. Its58 finite fact controls pass. Small differences between08 and09
remain provisional.

The scalar result is informative: removing frames alone is insufficient.
The loop still makes7 helper calls and5 ownership calls before result facts.
The next experiments address ordinary-call optimization and the unnecessary
boxed tuple carriers returned by array operations.

## Independent controls and current scope

- The frozen baseline, scalar08 and enhanced09 each pass the12 new actual-source
  observations, including deep tail loops, argument rotation, strict versus
  lazy overflow, shared arrays, owned strings and retained generic fallbacks.
- The scalar verifier passes45 independent structural controls:11 acceptances
  and34 refusals. These are not an arbitrary ownership proof.
- The additive array-result runtime retains the exact runtime04 source prefix,
  state layout and underlying array operations. Its18 independent observations
  pass, including actual shared handles, Unicode contents, release orders,
  buffer overlap and exact invalid-ABI failures.
- The product compiler passes 20 finite representation controls and the same
  12 actual-source observations.
- The bounded scalar and product inliners now pass independent reflected
  execution, scratch-boundary, namespace and native-source gates.
- Full45, native compiler acquisition and successive generations remain
  pending. The existing production selection is unchanged.

All target work is serialized on CPU3 under the process-tree guard. The first
large source checks used approximately1.2GiB peak tree RSS. Exact-byte
deduplication recovered1,051,717,632 allocated bytes across1,178 generated
artifact paths without removing any path or content.

The [fast-loop README](../../selfhost/tools/performance/phase113/bench/README.md)
documents diagnostic versus paired grades, and
[the full45 adapter](../../selfhost/tools/performance/phase113/bench/HOSTED45.md)
preserves the original broad corpus and profile.

## Second checkpoint: allocation and ordinary-call boundaries

The product path uses the mature layout plan and caller-owned result slots.
The additive runtime returns array result fields without allocating a tuple.
Diagnostic local-pair counts, for the same two workload evaluations:

| Event | Frozen facts | Complete functions | Flat products |
|---|---:|---:|---:|
| Heap allocations | 657,030 | 657,030 | 126 |
| Continuation frames | 262,727 | 60 | 59 |
| Underlying term keeps | 527,888 | 527,888 | 524,811 |

These are event counts, not CPU shares; nested counters overlap. They explain
both the large allocation win and the remaining array access work.

The next inliner handles verified acyclic calls and result vectors with
two-phase assignment, fresh names and bounded code/stack growth. A fresh
one-round diagnostic gives:

| Program | Upstream ms | Frozen facts ms | Products + facts14 ms | Product inliner15 ms |
|---|---:|---:|---:|---:|
| scalar-region8192 | 16 | 178 | 139 | 76 |
| local-pair | 15 | 2,148 | 378 | 235 |
| editdist | 20 | 2,203 | 376 | 238 |
| active ray256 | 15 | 926 | 351 | 300 |
| lexer | 15 | 211 | 116 | 116 |
| closures256 | 15 | 190 | 186 | 191 |

This remains a six-point diagnostic, without a qualified aggregate. Source:
`selfhost/build/phase112/p113-inline-screen15/phase113-report.json`. Removing
all 17 keep/drop sites from one ray worker barely changes runtime, so helper
counts alone are not a speed estimate.

Facts14 passes 148 finite controls and six actual Nat observations, including
48-bit values, four exact overflow failures and a retained String alias. The
first mixed-owner fixture used prohibited computed-value destructuring and
failed at the frontend; its corrected version and rejected receipt are retained.

Scalar inlining passes 19 independent interpretation/shape cases. Its first
harness incorrectly compared JSON property order; an independent structural
comparison established that defect, and the corrected version retains every
semantic expectation. Product inlining passes eight independent executions,
11 scratch-footprint checks, 17 namespace cases and six verifier boundaries.
Inline15 also passes the 12 actual-source controls.

Source16 adds canonical Nat extraction and known-combinator reuse; all 185
finite controls pass and its native campaign is ongoing. Source17's guarded
array prototype checks, but still awaits execution. These are experimental
sources, not new native compiler generations. Full45 and self-host gates remain
pending. See the [second receipt index](evidence/interim02/index.json), the
[ownership experiment](../../experiments/phase113/P113-002-preserve-ownership-facts.md)
and [inlining experiment](../../experiments/phase113/P113-003-bounded-ir-inlining.md).
