# P37-003: remove a guarded native conversion call

Status: prospective, investigate. Discovered after the expanded Phase36 baseline,
before any conversion experiment or production change. Numeric recurrence is
16.62–19.90 times slower than TypeScript in the completed development comparison.
Its existing private Nat loop still calls F32.to_u32 through generic dispatch on
every iteration. The dependency already has a checked signature and captured
descriptor; host guards already include Number.isFinite and Math.trunc.

Hypothesis: emit the exact conversion body only inside the existing guarded
private region, retaining the public descriptor and generic fallback. This could
remove repeated dispatch without introducing a new private-worker architecture.
Do not add an unconditional global primitive rewrite: mutable public bindings,
math hooks, argument evaluation and exact numeric edge semantics must survive.

First use frozen output, once-only operand and numerical boundary controls,
actual entry and live mutation witnesses, then unprofiled rotated timing. Only
implement if the general rule is smaller and its gain survives checked output.
Keep this separate from the finite-sum tree experiment and preserve all attempts.

Evidence: selfhost/build/phase37/development-reference01/report.json and
baseline01/modules/numeric-recurrence.mjs. Outcome belongs in the Phase37 report.
