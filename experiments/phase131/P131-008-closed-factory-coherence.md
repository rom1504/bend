# P131-008 — expose static factories without duplicating their source

Status: checked data-only prototype; no production integration or speed claim.

Hypothesis: the existing static preparation walk could interpret a small closed
constructor factory before pooling, retaining source abstraction while exposing
exact immutable values. This could replace419 explicit atom expansions in the
qualified source and recover17KB of repeated syntax.

A checked Bend evaluator accepts only closed constructor/scalar actuals, known
ordinary bodies, small callees/literals and bounded call depth. Seventeen positive
and refusal controls pass. Evaluating the actual missing→atom→KTerm factory
produces the exact complete literal graph; an unrelated Packet factory agrees too.
No new production pass, host compiler or unbounded partial evaluator is added.

Per-callee size and recursion fuel alone do not bound expansion through duplicated
arguments. An aggregate result/work budget is mandatory before integration.
Dynamic actuals require ordered let bindings and fresh IDs; they do not justify
static pooling. Keep this first version closed and cheap, in the existing walk.

[Prototype and replay](../../selfhost/tools/performance/phase131/usage/factories/README.md) ·
[Constant audit](../../research/phase131/immutable-constants.md).
