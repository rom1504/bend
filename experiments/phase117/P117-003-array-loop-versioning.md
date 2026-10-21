# P117-003 — keep cold fallback calls outside the hot loop

At07:06UTC the packed+hoisted candidate improves fold2.73×; edit1.14×.
Actual fold instructions still contain generic fallback calls inside the loop.
They force scratch stores, branch joins and call-preserved live ranges even when
never executed. Hypothesis: one entry admission check and a separate original
fallback worker allow a call-free hot loop to remain in registers.

Only version a function when every array access resolves to an entry handle,
every backedge preserves those handles, all original proofs pass, and bounded
size/stack limits hold. Cache pure metadata at entry; check all required original
raw/dynamic predicates once; only the passing branch omits per-access guards.
Fallback runs the original complete worker with the original arguments/output
ABI. No payload load/store moves across a semantic boundary. All unknown cases
retain per-access guarded emission. New symbols use a distinct emitter namespace.

Measure pair first; inspect machine shape and complete outputs. Then ordinary
array controls and broad original45. Preserve any regression/failed attempt.
