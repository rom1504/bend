# P194-002 — predicate-to-select composition

Hypothesis: compare→Boolean→copy→test→select loses useful condition identity across otherwise empty scaffolding. Reusing existing pure-arm selection and whole-original read counts can preserve the original comparison through direct CMOV.

Prediction: remove three materialized predicate chains in unrelated row computations; preserve comparison/selection widths separately, old-value snapshots, protected locals, effects and alias fallbacks. No additional whole-function analysis. Original adjacent-branch counts remain separate from new corridor read counts.

Implementation: versioned `predicate-select-v3.bend` and hook; checked API `predicate-api03`. `predicate-controls01` passes mixed-width structural controls and7,260 independent machine observations per object/assembly route. Initial fixture computed-match and affine annotation errors remain in api01/api02 evidence.

First causal screen: `ablation-runtime01/report.json`, five rotated roles. local-pair takes0.9077×baseline, editdist0.9502×; other four within~1%. Both hot loops shrink93→77 instructions with all three SETcc/TEST chains removed, preserving three CMOV. This is not broad parity or universal equivalence. Additional repeated-definition and protected-name machine stress is required before integration.

Raw-selector stress v3 now actually exercises repeated definitions, protected
locals and fuel boundaries:1,210 machine observations per route plus10 pattern
assertions. The earlier full-preparation stress did not establish this admission.
Integrated maintained source passes N1/N2 products and N2/N3 reproduction; the
final ordinary transfer is retained in `implementation/phase194/runtime-summary.md`.
