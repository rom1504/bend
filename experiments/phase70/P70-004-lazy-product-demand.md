# P70-004: avoid product-demand scans after an earlier refusal

Registered before production editing or candidate execution. The baseline
profiles from P70-003 and source inspection show that `nq_bind_choose` eagerly
evaluates both body-use predicates even when the value has no fixed product
shape. This is a different consumer from Phase68's ownership-demand fix.

Replace eager Boolean conjunction with nested `nt_choose` branches: discover
the shape, then count uses, then check minimum branch demand. Every predicate
is a pure analysis; the exact final choice and generated code must stay equal.
Do not weaken the one-use or every-branch demand requirements.

The source proposal is `selfhost/tools/performance/phase70/product-demand/lazy-v1.patch`.
First gate: checked B1 build and exact complete C on numeric/array/lexer. Then
12 alternating baseline/candidate requests and a candidate numeric profile.
The compiler-speed candidate may combine this with P70-005 while the larger
observer implementation is developed independently; attribute only the combined
result until an isolated intervention measures a component. No B2 result follows
from a B1 screen. Full qualification follows selection.

Status: combined compiler01 passes the checked build,12 exact-C clean requests
and155 exact compaction queries per image. Three-source B1 screen0.9642× baseline;
two samples per cell and no ablation. Product-count profile union90→18ms supports
the mechanism. [Report](../../implementation/phase70/compiler01-screen.md).
