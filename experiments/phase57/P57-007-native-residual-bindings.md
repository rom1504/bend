# P57-007: retain scalar origin through residual numeric bindings

Discovered while following the sampled allocation hotspot `sk_char`.
Both images already test U32 rows as native scalars, but demanded default
bindings reconstruct Word fragments. `u32_to_word` builds temporary linked
bit nodes. Existing whole-view cancellation does not recognize reconstruction
from residual prefix/field pieces; constant lookup tables do not cover this
default expression.

Hypothesis: preserve typed scalar-origin facts through partial views and
recomposition, avoiding an inverse conversion when its exact bit identity is
known. Test masks, widths, captured/default bindings, demand order and negative
controls before measuring allocation and ordinary request latency.

Evidence: [source comparison](../../implementation/phase57/implementation-comparison.md).
Measurement: static mechanism plus allocation hotspot; causal gain unmeasured.
Decision: investigate; no source change or promotion in Phase57.
