# P107-009 — closed-allocation scalar field promotion

2026-10-18. P107-006 passes the bounded memory controls but invariant-load
forwarding alone leaves owned-observer runtime around3.3× raw Clang. Hypothesis:
promoting fully understood private scalar fields into locals exposes ordinary
scalar arithmetic optimization, including balanced counter updates, without
recognizing reference counts or inventing a borrowed ABI.

Prototype `nx_scalar_promote(program)` performs whole-function legality analysis
before publication. Only scalar parameters/results, fresh constant nonzero-size
allocations outside loops, resolved pointer copies/constant offsets, exact disjoint
field layouts and simple loops are admitted. Unknown accesses, calls/indirect calls,
pointer returns/loads, branches/nested loops, escaping pointers, use after free and
partial/mixed-width overlaps refuse the entire function unchanged. Apply existing
load forwarding first to expose known pointer copies.

Promote U32/U64 fields to fresh, typed-zero locals. Keep every allocation/free and
pointer-field store physically present; retain pointer identities, byte layout and
allocation-failure behavior. No ownership policy, call ABI or runtime changes.
Loop pointer provenance must hold for every iteration; values of scalar locals
naturally follow actual load/store control flow, including zero iterations.

Before speed claims: independent whole-result checks, exact refusal controls for
unknown aliases/mixed widths/escapes, scalar and pointer dependency changes,
loop-carried payload updates, zero-trip and allocation/free controls, fresh-name
collisions and admitted mutants that conflate aliased or overlapping fields.
Check that physical effects other than promoted scalar accesses are unchanged.
Validate both original and transformed graphs, retaining every failed attempt.

Measure optimizer time, scalar memory-access reduction, backend object cost and
runtime on the same frozen memory workloads. The experiment concerns bounded
sequential well-defined IR, not a proof of the compiler or automatic promotion of
arbitrary escaping/concurrent allocations. Defaults remain unchanged.

## Bounded result

[`promotion-audit02`](../../selfhost/build/phase107/promotion-audit02/report.json)
passes27 fixture/workload families,444 native outputs and326 distinct independent
model executions. Two output mutations are detected. The second audit specifically
mutates a newly generated field local in the zero-initialization case; the first
audit accidentally targeted the pre-existing collision-test local. Audit01 is
retained but is not evidence for that stronger mutation check. GCC controls use
`-O2 -fno-strict-aliasing` for the explicit mixed-width byte-memory witness.

The three-round [`measure07`](../../selfhost/build/phase107/measure07/report.json)
screen gives the owned shared workload a2.65× QBE speedup over its unoptimized QBE
graph; optimized runtime is1.26× raw Clang C O2, versus the preceding approximately
3.3× barrier. Cranelift remains2.55× raw Clang. These are results for the composed
pipeline recorded in `artifacts06`, not an isolated pass ablation, a whole-compiler
benchmark or upstream compiler parity. The complete composed optimizer costs about
11.44ms on this graph; its IR shrinks117 to112 counted nodes. This supports further
study of general scalar replacement and backend code quality, not default promotion.

## No-allocation fast refusal

Kernel02 exposes avoidable qualification cost on the allocation-free helper-chain
graph: adding promotion returns identical IR but repeats structural verification
and function analysis. Before changing that evidence, test a necessary-condition
prefilter: if no function contains `NxSet(_, NxAlloc(_))`, including inside either
conditional arm or any loop, return the exact input immediately. The existing pass
can acquire allocation provenance only through that statement form, so it cannot
promote an allocation-free graph. Returning an invalid allocation-free graph
unchanged also preserves the previous invalid-input behavior.

Validate the new source against all old promotion JSON and dedicated predicate
controls for absent, direct, conditional-only and loop-only allocations. Then
measure matched fast/promote invocations in a new kernel03 receipt. Keep kernel02
unchanged. This improves optimizer selection overhead, not generated-code speed;
backend execution need not be repeated when emitted IR is byte-identical.
