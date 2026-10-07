# P63-003: use one owned lowering plan

Status at registration: prototype written; no target executed.

Hypothesis: one canonical annotated context can own call analysis, reference
discovery and emitted definitions, avoiding duplicate lowering. Preserve source
order, reach budgets, demand, SCCs, refusals and host representation. The old
pruned context restores raw aliases, so cross-context equivalence is an explicit
proof obligation, not inferred from23 matching outputs.

Use graph controls plus real alias/native/host/SCC/budget witnesses, then exact
raw modules and runtime qualification. Preserve old APIs for fallback/ablation.
Measure end-to-end savings before broad validation.

[Design](../../design/phase63/ready-world-and-lowering-plan.md) ·
[Report](../../implementation/phase63/README.md).

State05 passes reach controls, six valid real-context fixtures and23 exact raw
benchmark modules. Genuine B2 two-source compilation improves12–14% with the
combined architecture. Profile-guided follow-ups are registered separately:
[P63-004](P63-004-reuse-derived-type-work.md). No isolated lowering attribution is
claimed. Full release qualification remains necessary before replacing installed
Phase61; changing canonical context has wider semantic scope than these screens.
