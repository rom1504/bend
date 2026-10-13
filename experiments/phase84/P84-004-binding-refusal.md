# Refuse at the actual non-tail binding boundary

Follow-up to the Phase84 actual-refusal screen; indexed retrospectively.
[Patch](prototypes/refusal-binding.patch) · [Routing/consumer audit](../../implementation/phase84/refusal-binding-notes.md) · [Results](../../implementation/phase84/README.md).

Hypothesis: an exact saturated self call with no product signature, used as a
binding value, will inevitably refuse the ordinary worker. Stop before building
the continuation, preserving scheduler and unknown/product routes.

Checked B1 compiler05 and frontend36 pass; all16 screen C files remain exact.
The four-source time ratio is0.9776×, but Numeric contains a baseline outlier and
simple held-outs have no shortcut hits. The disposable counter image records
28 actual Map hits, one Numeric hit and zero on Functions65/Small, with exact C.

Correctness: finite checked/frontend/output gates plus static consumer audit;
no broad qualification. Measurement: exploratory, no B2 timing for this variant.
Decision: defer and restore production. This does not meet the phase's general
20–25% reduction target. Failed private-worker payload identity is intentionally
not retained; public observations/emitted C remain the required contract.
