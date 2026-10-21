# Narrower necessary syntax filter

`prefilter08.bend` overrides only `p120w_prefilter_scalar`,
`p120w_prefilter_scalars`, `p120w_prefilter_body`, and `p120w_function`.
It adds `p120wpf_count`; include after model07, retaining model07's two laws.
The law-backed definitions copy the checked inferred-parameter/match-first form.

A replacement requires mode3 sign provenance, mode2 logical-shift provenance,
and an OR consumer. The only producers of those modes are shr31 and shr1..30.
A literal count with nonzero high word, zero, or >=32 cannot produce either mode.
Local counts conservatively admit both; other value constructors are opaque to
`p120w_value` and cannot be constant facts. The filter traverses both branch
kinds and may admit impossible combinations across branches; that is safe.

The existing <1024 size bound, full fact analysis, independent verification,
fallbacks and emission are unchanged. This is only a refusal of functions where
model07 cannot rewrite anything. Require byte-identical emitted QBE and measure
the fixed prepared stage before retaining. `p120wpf_controls(Unit)` provides
thirteen pure filter checks, including Local counts, nested branches, and exact
literal boundaries. No compilation, target execution or cost claim by author.

Root follow-up: prepare.py replaces a complete law/definition group, so the
original instruction to retain model07's laws was insufficient. Version09
includes both law declarations explicitly; controls09 also adds the required
constructor type annotation. Checked word18 passes, but the complete combined03
cost screen does not demonstrate an aggregate win. This refinement remains
unselected; see results.md and the Phase120 report.
