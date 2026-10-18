# Closed-allocation scalar field promotion

The optional Bend API `nx_scalar_promote(program)` implements the bounded
experiment in [P107-009](../../experiments/phase107/P107-009-scalar-promotion.md).
It promotes fully understood U32/U64 heap fields to fresh typed locals, exposing
ordinary scalar optimization. It does not recognize reference counts or remove
ownership operations according to a borrowed convention.

Every function receives a complete legality pass before any candidate is returned.
Parameters and results must be scalar. Every accessed heap object must come from
a fresh, nonzero constant-size allocation outside loops. Pointer copies and
constant offsets must resolve to a live allocation and a bounded byte range.
All field accesses, including physically retained pointer stores, participate in
layout checking; partial or mixed-width overlaps refuse the entire function.
Calls/indirect calls, pointer loads/results, unknown pointer values/offsets,
branches, nested loops and allocation/free inside loops also refuse the function.

The second traversal uses the complete accepted field table. Scalar stores become
assignments to fresh locals, and scalar loads read those locals. The locals start
at typed zero, matching the existing zero-filled allocation contract. Allocation
and free statements, pointer stores, pointer identity and physical layout remain
unchanged. No allocation is elided or moved, so this pass does not introduce a new
allocation-failure policy. Under the closed-function restrictions, no external
observer can inspect a scalar field whose physical access was replaced.

For a loop, remove every assigned pointer variable from incoming provenance and
analyze the body sequentially from only stable outer roots. In-body copies/resets
are tracked normally, but only stable outer provenance survives the loop. This
prevents a first-iteration pointer assumption from becoming a loop-carried alias
assumption and preserves zero-trip behavior. Scalar field locals themselves carry
exactly the stores executed by the original loop. Free drops every alias to its
allocation root; a later allocation receives a new identity and new fields.

Bounds are4096 nodes per eligible body,128 distinct accessed fields,64 fresh-name
attempts,256 functions and65536 initial program nodes. Whole-program structural
verification gates both input and final candidate. A failed second traversal or
unexpected field-table growth returns the original function. Pointer and lifetime
reasoning remains a reviewed finite prototype, not a full formal memory-safety or
compiler-correctness proof.

`promotion-controls.json` freezes148 full-result cases across19 families. Its
`expectedChanged` and `exactRefusal` maps refer to direct application to the raw
fixture, without implicit preprocessing. Seven positive families cover aliases,
pointer-store preservation, U64 overflow beyond32 bits, zero-initialized fields,
zero-trip loops, fresh-name collisions, scalar-value dependencies, pointer
reassignment and allocation/free reuse. Twelve negative families exercise the
deliberate scope limits. The mixed-width overlap witness retains the previously
documented C oracle requirement: explicit `-fno-strict-aliasing`, or the byte-memory
interpreter/QBE/Cranelift semantics.

Root separately evaluates `nx_memory_forward` followed by promotion on broad
workloads. That composition can expose known pointer copies before promotion,
while the raw pointer-load fixture must still refuse directly. Do not conflate
the two admission results. Structural gates compare all allocation/free and pointer
store nodes in their original order and positions, then independent/native oracles
compare full outputs. Optimizer cost, scalar-access reduction, backend build cost
and runtime remain separate measurements.

The parent-run qualification in
[`promotion-audit02`](../../selfhost/build/phase107/promotion-audit02/report.json)
passes27 families,444 native outputs and326 distinct independent model executions.
The19 direct-pass control families are supplemented by eight broader IR workloads
under explicitly recorded preprocessing. Two scalar-typed output mutations fail the
unchanged oracle: alias-field corruption changes101 to32969; corruption of a newly
generated zero-field update changes5 to1002. Audit01 incorrectly selected the
pre-existing collision-test variable for the second mutation. That report remains
historical evidence; audit02 is the qualified field-mutation result. The GCC control
recipe explicitly includes `-fno-strict-aliasing` for the byte-overlap witness.

The parent-run three-round
[`measure07`](../../selfhost/build/phase107/measure07/report.json) screen shows the
owned shared workload at13.336ms for optimized QBE versus35.356ms unoptimized QBE
and10.586ms raw Clang C O2:2.65× faster than raw QBE and1.26× raw Clang time.
Cranelift improves to27.025ms but remains2.55× raw Clang. The pipeline uses
`nx_inline_demand` and the composed `promote` route in
[`artifacts06`](../../selfhost/build/phase107/artifacts06/report.json), whose recorded
optimizer time on shared is11.44ms and counted IR size117→112. These timings include
the benchmark's repeated execution protocol and are not single-call latencies.
The remaining Cranelift gap shows that exposing scalar structure does not guarantee
equal machine-code optimization across backends.

The screen supports the general representation change in this bounded memory
slice. It is not a standalone promotion-pass ablation, production compiler timing,
upstream Bend comparison, broad source-language memory coverage or a formal proof.
The installed compiler and backend defaults remain unchanged.
