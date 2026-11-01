# P151-001 — scalar U32 dispatch versus expanded literal patterns

Status: investigating. [Plan](../../design/phase151/README.md).

Hypothesis: scalar comparisons reduce acquisition cost for existing fixed-result
U32 dispatch functions while preserving complete outputs and execution speed.
Primary witness `p88_roles`; unrelated transfer `p112fp_binary`.

Falsifiers: no meaningful fresh-process acquisition difference, execution
regression that offsets the gain, any table/fallback/consumer mismatch, or a
complete-consumer effect too small to justify integration. No production source
change or whole-build result is implied by the experiment.
