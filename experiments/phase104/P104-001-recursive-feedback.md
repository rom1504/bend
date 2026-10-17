# P104-001: Does faster compilation accelerate compiler research?

Status: baseline complete; causal feedback hypothesis untested.

Hypothesis: adopting general compiler improvements reduces the cost of subsequent
experiments enough to increase held-out validated progress per wall time or
compute, after charging upgrade and evaluation cost.

The [design](../../design/phase104/recursive-improvement.md) distinguishes fixed
source bootstrapping, evolving optimizer state and source research. Initial
[evidence](../../implementation/phase104/README.md) authenticates candidate04's
existing emitted-C fixed point and records 16 fresh passing B1/B2 requests.
No new generation beyond the recorded B2 executable was built.

The historical 151s Bend / 374s Clang envelope bounds compiler-only feedback:
2× faster Bend predicts only 1.168× emit/build throughput under fixed remaining
cost. This is a model calculation, not an observed research speedup.

Falsifiers: little compiler-dependent critical-path work; no extra completed
experiments after charging costs; no additional confirmed improvement from
extra experiments; or improvements confined to repeatedly exposed benchmarks.

Next: instrument complete fast-loop attempts; controlled identical-candidate
latency replay; only then replicated adaptive frozen/updating-builder campaigns.
No production, acceptance rule or trusted benchmark was changed. No PR comment.
