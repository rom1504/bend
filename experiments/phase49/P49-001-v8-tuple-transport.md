# P49-001: physical allocation and transport after V8 optimization

Status at design freeze: investigate. No new execution result.

Hypothesis: Phase48's failed tuple-removal pass either removed source objects
already eliminated by V8, or exchanged real allocation savings for extra hot
transport/inlining costs. Tiering and fixed public-entry work are alternatives.
The evidence must distinguish these claims rather than assume one is true.

Use the [design](../../design/phase49/v8-aware-diagnostics.md) and exact frozen
values03 RLE comparison. Run separate clean, CPU, sampled-allocation, tier/inlining
and filtered optimized-code diagnostics. A constructor counter is insufficient
and can itself inhibit optimization. Preserve all adverse or inconclusive runs.

Owner: root execution/integration; independent agents handle static output
analysis, driver construction and review. No compiler-source promotion planned.
Final outcome belongs in `implementation/phase49/README.md` and the experiment
ledger; this pre-execution hypothesis remains a dated input.
