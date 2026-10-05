# Private tuple transport checkpoint

Date: 2026-10-05. Baseline: installed array06 (`ee54723`).
Status: source implementation and independent static review in progress.
No candidate compiler, generated-program execution or timing has been run by
this owner. The root agent owns serial execution and promotion.

The [design](../../design/phase48/aggregate-transport.md) targets an allocation
that the deferred Phase47 inliner did not remove. In the exact array06 RLE
library, `rle.step` returns two nested state tuples. Its false arm also creates a
pair and list cell containing an encoded run; its true arm creates only the two
state tuples. `rle` immediately passes this result through its next tail
iteration. The encoded list is subsequently consumed by both `llenp` and
`expand`, so those persistent objects remain necessary.

The implementation adds private argument and result decomposition over typed
JW, followed by local removal of projection-only tuple shells. It retains the
function list, indices, names, source guards, public entry signature and public
result layout. Tagged records are not scalarized: a tuple transporting a record
can disappear while the record itself remains allocated and shared.

Multiple results use explicit `JWCallValues` / `JWReturnValues` instructions.
The first field is returned normally; up to three additional fields use private
lexical return registers. Every producer evaluates all leaves into its own
locals before committing registers. Every caller captures them into locals
before another call or frame write. The continuation emitter restores its
frame before committing results. Consequently the proposal does not replace
each tuple with a result buffer or callback allocation.

The pass is bounded to 32 formal-parameter cuts and 32 result cuts per graph,
four formal cuts per function, at most 12 parameters and four result fields,
and 64 dominated tuple-shape facts. It trusts the existing typed lowering;
function `valid` flags are not an independent verifier for arbitrary malformed
IR. Unknown shape or unsupported use retains the original convention.

Static review identified one concrete draft bug: a direct inline constructor
in a return position could have its field expressions duplicated during
decomposition. The implementation now accepts only an already evaluated slot
with a dominated canonical tuple-shape fact. The ordinary lowerer already
produces that form, but the refusal is explicit and independently testable.

Field evaluation is retained even when a shell disappears. Each original field
is assigned once, in order, at the former allocation site. Branch-local slot
facts do not flow into another branch. Result rewriting cleans only the affected
producer after each cut, avoiding repeated cleanup of unrelated functions.

The source fixture and controller under
`selfhost/tools/performance/phase48/controls/aggregate-transport-*` cover a
renamed run-state graph, two consumers of its persistent encoded list,
non-tail recursive multiple returns through depth 513, a tuple containing a
record, checked overflow in an unused field, error-hook reentry, public shared
child identity and mutable descriptor fallback. Diagnostic AST instrumentation
counts executed array literals inside the exact selected public assignments.
That establishes constructor evaluation, not physical heap allocation after
V8 escape analysis; GC/allocation profiling remains separate evidence.
Its required state witness is removal of `2*n + 2` allocations: two per
transition and two for the initial state. This is an unexecuted requirement,
not an observed result. A separate owner supplies independent synthetic JW
interpreter controls.

This change adds more compiler code than the rejected 405-line local cleanup.
It is justified only if actual across-call allocation removal, correctness and
useful runtime benefit survive measurement. Compilation cost, generated size,
representative benefit and regressions are all currently unknown. A failed
activation witness or negligible benefit should lead to a narrowed or deferred
patch, not a claim of architectural progress alone.
