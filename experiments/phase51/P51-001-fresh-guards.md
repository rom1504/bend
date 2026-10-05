# P51-001: cheaper equivalent fresh guards

Hypothesis: batched descriptor acquisition or another small equivalent-check
shape reduces the measured String guard cost without weakening observations.
See the [design](../../design/phase51/v8-guided-runtime.md).

Falsifiers: changed mutation/refusal/error/reentry behavior, no clean gain,
or materially increased overhead on unaffected calls. No guard bypass or
cross-call permission cache is eligible. Outcomes: implementation/phase51/guards.md.

State at design freeze: proposed, unmeasured, unqualified, not installed.
