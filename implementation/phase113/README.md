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
- The product compiler source checks and passes20 finite representation
  controls. Its native candidate campaign is still in progress.
- The proposed bounded IR inliner is source-only at this checkpoint.
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
