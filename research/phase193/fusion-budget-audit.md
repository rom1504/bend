# Optional fusion budget: source audit

Inspected `public-fusion-budget-experimental.bend`, its replacement
`public-fusion-budget-hook.bend`, and the existing full consumer. This optional
filter adds no semantic admission and leaves the frozen full-candidate
source snapshot `6a3c990b…` unchanged. No compiler or target was executed by
this reviewer.

The unchanged `p112c_plan_index` first constructs its complete admitted plan.
If no site fused, the wrapper uses the existing consumer without counting.
For a plan with a fused site, it counts both original and full candidate
statements using existing `p112f_size`, including nested branch nodes. If the
candidate size is at most twice the original plus sixteen, it passes the exact
original plan to `x193f_candidate`. If rejected, it calls `x193f_tail` on the
original segment and the original ready registry. No fused prefix or partly
rewritten body escapes rejection.

The replacement remains inside `x193f_plan`'s original local-name hygiene
guard and `x193f_checked` result validation. The ready-tail metadata gates,
self-transfer refusal, helper availability checks, public `rt_return`, and
whole-original-segment machine-selector fallback are unchanged. The budget
therefore restricts profitability selection; it does not relax verifier,
ownership, continuation, or runtime-stack requirements. The independent tail
optimization may still apply when fusion is declined, by explicit design.

The arithmetic guard admits original sizes only through 2,147,483,639, exactly
`floor((2^32-1-16)/2)`. For such inputs, multiplication by two plus sixteen
cannot wrap. The count function's own U32 semantics remain unchanged; even a
misleading profitability count would choose between the existing admitted
full candidate and original/tail routes, not admit an unchecked body.

`selfhost/tests/phase193/budget-controls.mjs` transports the already checked
`x193fb_controls` export and compares its entire seven-string result with
independent literal expectations. It authenticates checked B1, source parent,
module/hook membership, replacement provenance and pinned engine, and requires
the root's guarded CPU3 lane. It does not emit or execute generated programs.

The seven existing checks cover zero-size slack at16/17, a32-node original at
80/81, accepted200→250 growth, rejected100→600 growth, and rejected original
size2,147,483,640. They do not execute the composition/fallback branches or
prove a runtime or compiler-speed benefit. Those composition properties are
source-audited above; a useful size/time threshold remains an empirical
question. No new controls export or consumed source change was introduced.
