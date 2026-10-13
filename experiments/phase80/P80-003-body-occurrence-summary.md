# P80-003: one occurrence summary per native body

Status: measured and deferred; finite correctness gates pass, not promoted.
Registered after counts02. [Report](../../implementation/phase80/README.md).

The original type-retention variants are rejected. Numeric's unchanged-B1
diagnostic records271 top-level `nq_uses` queries on45 distinct root terms,
49,732 recursive calls on2,243 distinct terms. Only1,099 complete argument
tuples repeat: many walks ask about different binder IDs. A term-and-ID memo
would miss this opportunity. Diagnostic timings are not gain estimates.

Prototype: compute all saturated binder occurrence counts once for each body
consumed by `nh_terms` or `ns_unshared_terms`. Reuse the checker's existing
`uses_merge`/`uses_get` algebra: sequential children add, capped at two; two-arm
Mat and NWPattern alternatives take maximum. Var is a leaf, including malformed
raw Vars. Preserve the existing fallback behavior for other node shapes.

Scope is the exact immutable erased/compacted body supplied by the caller.
No new expression identity, global table, frontend annotation, serialized product
or host semantic code. The small map is local to one consumer invocation.
This is a revised stage-four experiment supported by the new counts, not a
continuation of the failed whole-book representation.

Use checked B1/frontend36, complete-C three-source screen, and held-out2. Require
a clear net gain without a material regression before broad qualification.
Compare the summary with `nq_uses` over generated finite term trees, including
branches, NWPattern rows, malformed Vars and saturated sequential uses. Preserve
all attempts. Only promote after the design's applicable integration gates.

Compiler04's list representation passes15,678 generated comparisons and36
clean exact-C requests across the screen/held-outs, but its aggregate screen
gain is only0.39% (one Array sample is substantially slower). Before repeating
measurement, compiler05 replaces lists of generic KTerm counters with a pair
of the existing NU_Set integer tries: used and multiply-used. Sequential visits
saturate counts; branch results union each set. This remains the same query
semantics and body-local lifetime. Run the generated-tree comparison again and
use five fresh rounds to make the final selection decision less noise-sensitive.

Final05:45 clean screen requests save2.147%;18 held-outs give small0.26% less
time and functions65 1.31% more. All C remains exact. Both summary variants pass
15,678 differential binder queries each. The integer-set variant adds66 physical
lines/one private datatype. Preserve both patches but defer production selection:
the small mixed result does not warrant expanding this into a larger IR rewrite.
No new B2, full qualification or installed speed improvement is claimed.
