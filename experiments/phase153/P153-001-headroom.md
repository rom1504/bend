# P153-001 — consequential cold-build headroom

Starting commit: `0a16bb7`. Hypothesis: large gains require removing shared
representation/ownership work across stages rather than tuning another helper.

Measured: one exact-output full Phase152 N2 profile, 7,406 usable samples,
236.947s staged CPU. Raw lowering + initial optimization + rendering/cleanup
occupy 101.452s. Disjoint physical samples identify 42.71% in reclamation,
ownership/products, allocation and register transport; selected string workers
add 9.92%. These are affected costs, not demonstrated removable fractions.

A complete small request records 24.69M allocation calls, mostly pooled reuse.
Source audits identify numeric identities lost across lowering/analysis/rendering,
missing lifetime-tied borrowed-descendant results, and repeated definition-world
canonicalization. The last is a bounded smaller opportunity, not a 20% claim.

Decision: prototype a complete producer-to-final-consumer backend unit. Require
roughly 2× complete-region improvement before full compiler acquisition. Keep
Phase152 qualified and all production source unchanged. Reject late conversion,
allocator-only and blanket optimization-disable campaigns as major-gain routes.

[Design](../../design/phase153/README.md) ·
[Report and limits](../../implementation/phase153/README.md) ·
[Metrics](../../implementation/phase153/metrics.json).
