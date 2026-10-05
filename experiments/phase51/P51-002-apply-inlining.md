# P51-002: a smaller generic apply body

Hypothesis: extracting cold branches without changing property/evaluation order
allows V8 to inline common application and reduces dispatch/temporary cost.
See the [design](../../design/phase51/v8-guided-runtime.md).

Falsifiers: changed public observations, continued size refusal, or no useful
clean speedup despite inlining. Source-specific recognizers are excluded.
Outcomes: implementation/phase51/dispatch.md.

State at design freeze: proposed, unmeasured, unqualified, not installed.
