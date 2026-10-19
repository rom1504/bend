# P112-003: compose private calls with continuation fusion

Status: initial ranked, repeated and wide32 variants pass focused controls but
show no material six-program runtime gain. Pure-assignment gap extension now passes focused/native gates and improves the six-case screen16.7%; composed facts integration now passes exact self-hosting and all45 one-shot outputs.

Hypothesis: a callee becomes a direct worker after its calls are fused, enabling
its callers in later immutable ranks. Freeze each first-admitted body and plan;
private dependencies must point to earlier ranks, with only local self-tail loops.
Non-tail/mutual recursion and unsupported effects retain generic semantics.
Bounds remain six ranks, eight fused sites and128 copied continuation statements.

The first three compositions increase emitted private workers without removing
hot runtime frames. Width32 alone emits identical inspected lexer/ray/map QBE to
width8 repeated fusion. This is a negative result, not grounds to increase limits.

Exact emitted-code inspection found a more specific obstruction: a continuation
frame often precedes constant assignments, then argument stores. The matcher
accepts only the stores. Ray's isect.t/sx/sy and compiler string equality exhibit
this shape. Profiled inner ray continuations account for143,136 frames (42.85% of
its measured frame calls); compiler p88_string_eq_go has964,973 such frames.
These are potential event counts, not promised eliminations or speed factors.

New narrow experiment: retain at most32 numeric Set/Bin assignments in their
original order between capture snapshots and argument snapshots. Exclude calls,
memory, pointer/state/scratch use and control flow. Preserve capture values when
the gap redefines a local. Qualify independent order/lifetime/refusal controls
before fresh runtime measurement. Keep the prior candidates and their failures.

See [ranked composition](../../selfhost/tools/performance/phase112/regions/README.md),
[repeated composition](../../selfhost/tools/performance/phase112/region-multi/README.md)
and [campaign report](../../implementation/phase112/README.md).
