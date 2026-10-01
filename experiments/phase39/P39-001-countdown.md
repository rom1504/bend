# P39-001 — private scalar countdown narrowing

Status: prototype and actual-source controls passed; minimal source implementation
checked; five-round target timing confirms gains. Full campaign acceptance pending.

Claim: extending the existing one-use private Number countdown to scalar loops
reduces numeric recurrence cost without changing observable behavior.

Baseline: installed Phase37 checked03; exact numeric module and semantic scope
are in [the design](../../design/phase39/countdown.md).
Candidate roles: unchanged output, nested helper only, both private loops.
Keep guarded casts, floating literals, recurrence arithmetic and public fallback.

Correctness: saved-output controls pass (50 oracles, 18 admission, 32 bounded,
56 boundary cases); actual-source controls v2 pass 66 oracles, 12 admission and
25 boundaries. V1's wrong TypeScript Nat result expectation is preserved and
corrected against the actual pinned public wrapper. Measurement: checked01
five-round target timing shows 1.075×/1.222× incremental gains at numeric
256/1,024 and 1.262× at scalar 8,192; all ranges disjoint. Decision: retain the
minimal existing proof extension subject to broader campaign gates.
Root owns all target execution; agents inspect and author only.
No existing evidence directory is modified. Record all actual attempts in
[the report](../../implementation/phase39/countdown.md), including rejected ones.

Falsifiers: a boundary event changes, the counter escapes, narrowing is inactive,
timing does not improve, or compile/complexity cost exceeds the small rule's value.
Large-bound controls must use capped diagnostic steps, not full countdowns.
