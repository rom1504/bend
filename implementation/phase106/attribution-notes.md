# Full-self native attribution

The selected candidate04 B2 compiled its complete 1,788,947-byte source in one
unchanged-ELF capture. The [receipt](../../selfhost/build/phase106/fullself-profile01/report.json)
and [address analysis](../../selfhost/build/phase106/fullself-profile01/analysis.json)
retain 8,879 physical CPU samples at 16 ms. There were zero dropped samples or
timer overruns, valid thread lifecycle accounting and 99.99999% sampled-thread
CPU coverage. Complete emitted C and clock-stripped diagnostics match their
frozen oracles. The sampled process took 142.160 s and peaked at 1,321.8 MiB RSS;
its time is a profile observation, not a new clean performance comparison.

| Physical leaf | Samples | CPU sample share |
|---|---:|---:|
| `term_drop` |3,019|34.00%|
| `span_fade` |1,904|21.44%|
| `p88_string_eq` |1,553|17.49%|
| `p98_tag_eq_read` |272|3.06%|
| `rfc_wrap` |158|1.78%|

The first three leaves account for **72.94%** of samples. These are disjoint
instruction-location counts, not parse/check/lower phase timings, inclusive
caller costs, allocated-byte counts, or percentages that can all be eliminated.
Inlining can place several source helpers inside one reported ELF symbol.

## What the dominant functions actually do

The exact [generated runtime](../../selfhost/build/phase102/native-chain04/b1-self/execution/output.1.c:22440)
shows `term_drop` releasing ownership: it decrements reference counts, frees the
last reference cell, iteratively walks owned constructor/closure/task/array
children and releases their storage. It is not merely a `free` call or a tracing
garbage collector. Its samples include this traversal and inlined runtime work;
the capture does not identify which compiler phase caused each release.

[`span_fade`](../../selfhost/build/phase102/native-chain04/b1-self/execution/output.1.c:22531)
is the **shared constructor consumption path**. `ctr_take` first copies fields
to its output. When the parent has multiple references, `span_fade` increments
each reference-counted child's count, rejects a nontrivial unsealed child, then
drops the consumed parent reference. It preserves independently owned fields
while other owners retain the parent; it does not copy a text span or allocate
an entire new constructor. Samples inside its nested `term_drop` call belong
to the `term_drop` row, so the two rows sum without double counting. Together,
55.45% is direct evidence of substantial ownership traffic, not proof that
55.45% of total compilation time is avoidable.

The [source equality wrapper](../../selfhost/build/phase102/projection-cost-source01/compiler.bend:18)
retains both roots around a consuming equality traversal and its finish step.
The [actual C wrapper](../../selfhost/build/phase102/native-chain04/b1-self/execution/output.1.c:136552)
still performs two `term_keep` operations. Its walker has an admitted shared-root
observer path: the [borrowed worker](../../selfhost/build/phase102/native-chain04/b1-self/execution/output.1.c:23921)
reads linked String cells through `term_peek` without `ctr_take`, retain or drop
operations; the owning adapter disposes retained roots after observation.
Thus the equality hotspot does **not** establish that borrowed traversal failed
to activate. Generic `KTerm` tag projection still consumes eight fields and
disposes seven before comparing its String tag in
[`p98_tag_eq_read`](../../selfhost/build/phase102/native-chain04/b1-self/execution/output.1.c:135472).

## Implications for the structured-IR experiment

The strongest inference is to reduce ownership and repeated comparison work,
alongside improving machine-code generation. Interned identifier/tag IDs,
borrowed immutable node inspection, and explicitly owned regions or index-based
graphs could avoid repeated linked-String comparisons and shared-field retain/
drop cycles. The profile does not establish their coverage, safety or gain.
Generic String equality must retain its full character semantics; identifier
interning is a separate representation contract.

The [new IR slice](ir-notes.md) already compares the same typed algorithms through
C and Cranelift, but its experimental malloc/free workloads do not reproduce
the current compiler's reference-counted sharing. Add a narrow representative
workload before drawing compiler conclusions: repeated name membership plus
early/late equality mismatches, and repeated single-field inspection of a
retained multi-field tree/DAG. Compare unique versus shared ownership, preserved
roots, exact results and matched logical work. This tests the observed mechanism
more directly than scalar arithmetic or lexer classification alone. A new
backend can shorten Clang construction without removing these runtime costs;
Clang time remains a separate measurement.

[Phase98's earlier matched profiles](../phase98/origin-stage-profile-comparison.md)
and [generated-C inspection](../phase98/own-backend-mechanism.md) independently
identified these ownership/equality boundaries. They used different images,
source and request windows, so their percentages are context, not a current
speedup calculation. This capture supports prioritizing those mechanisms on
full-self compilation; it does not yet supply phase attribution or a broad
program-performance claim. No production change follows from this note.
