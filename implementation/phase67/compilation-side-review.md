# Bounded compilation-speed review

**Decision: defer a new compiler patch in this phase.** The source/data review
found no low-complexity candidate with credible evidence for at least 5% less
affected-source compilation time. It ran no compiler targets, changed no
production code and leaves the native optimization queue available. This is a
prioritization decision, not a claim that compilation cannot improve further.

The [data-only receipt](evidence/latency-review.json) pins the selected actual B2,
reviewed source and historical evidence. Phase66's current compilation result
is **1.321100× TypeScript**, requiring approximately **24.31% less time** for
parity. Map/set remains the largest relative gap: **947.08 ms versus 508.08 ms**.
The import-inclusive 0.990389× ratio is a different clock.

## The one remaining small hypothesis examined

`jd_calls_rows` computes each definition's arity once and saves it for later
emission. While analyzing that definition's tail calls, `jd_calls_named` still
computes target arities with the raw query. A two-pass scheme could calculate
all arities first and reuse them during call-body traversal. The reuse would
belong to one exact immutable annotated context; native, foreign and malformed
inputs must retain the original behavior and budgets.

This is real repeated work, but its measured budget is too small to justify a
build now. In the last matching detailed Phase65 baseline profile, all raw
`jd_arity` ancestry accounts for **40.841 sampled ms** on Map. Only **17.088 ms**
has the repeated `jd_calls_named` ancestor; **16.914 ms** belongs to the required
per-definition query, and **6.839 ms** belongs to emitter fallback. A new index
cannot erase the required computation and has its own setup/lookup cost.
The samples include imports and are diagnostic, not clean request timings or
hard upper bounds. They nevertheless do not support a credible 5% net saving.
Zero named `jd_live_arity` samples are not proof that the helper is free.

The larger existing Base-product hypothesis can retain whole local call scans,
but the earlier census attributed just **35.01 instrumented ms** of Map work to
65 Base scans. Its context, native-stop, fuel, edge-order and optional-artifact
contracts make it a larger change than an arity cache. Do not add this value to
the overlapping arity samples, or subtract either from a different compiler's
clean timing. Reusing emitted Base text is harder still because SCC membership,
component widths and request policy affect output.

## Why not repeat previous small experiments

Phase65 already measured normalized annotation-head retention (**−0.23%**), a
constructor index (**−0.20%**), shallow substitution (**+0.20%**, Map +4.24%), and
leaf-only substitution (**+2.22%**, with mixed source results) in bounded B1
screens. These do not establish B2 effects, but they are concrete reasons not
to rebuild and requalify the same ideas without new evidence. Successful Base
annotation retention and static decoder readers are already present.

Current source inspection confirms the retained lower-once `JDPlan`, existing
arity facts after call analysis, retained host telescope/field plans, and
prepared Base annotations. The detailed profiles predate the last two selected
improvements; treating their old stage percentages as current would overstate
what remains removable.

## Cheap condition for reopening this lane

Use the existing Phase66 prepared fresh-process latency method and actual
`bootstrap-b2-07/image-pins.json`; clone into a new Phase67 raw directory, never
write into the sealed Phase66 tree. Start with Numeric and Map, collect one
current stage/CPU diagnostic each, and require a concrete general mechanism
with a plausible net saving above 5% on the affected source before building.
Then use a two-role, two-rotation exact-output screen, hold Lexer/raytrace out,
and stop before genuine-B2/broad/release work if the signal fails.

This review consumed source/data inspection only. No new gain is claimed, no
timing sample was rerun, and no new cache representation or compiler concept
was added. [Method provenance](../../selfhost/tools/performance/phase67/latency/review.py).
