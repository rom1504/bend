# P39-003 — Preserve known recursive calls inside a private component

- Owner: applications agent; root executes and chooses promotion.
- Started: 2026-10-01. Correctness unchecked; measurement not run.
- Decision: investigate. This frozen proposal is not a compiler change.
- Design: [components](../../design/phase39/components.md).
- Report: [components](../../implementation/phase39/components.md).

Hypothesis: checked03's generic saturated recursive `warp` traffic can be
replaced by an explicit-frame worker at the existing whole-bench private
boundary, producing a clear incremental execution gain without changing tagged
representation or algorithm. A second asymmetric expression producer tests
whether the same recursion/continuation idea transfers.

Cheapest disproof: full-tree/alias/event/error controls, then a 20-second paired
screen. Reject any changed public observation or absent private entry before
measuring. No source-level admission follows from manually rewritten JavaScript.

The baseline API is checked03 SHA256
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.
The derivation will bind input source, checked emission, attempt, runtime, Base,
driver and clean/diagnostic outputs. The original clean role stays byte-identical.
Only root executes; jobs remain serial, CPU3, Node heap <=1 GiB, supervised
process tree <=2 GiB. Timed program execution excludes acquisition/profiling.

Current source, direct warp/generic leaf, direct warp/direct leaf, and pinned TS
are independent roles. Scope setup is inherited unchanged from checked03.
Expression's existing direct eval fold stays intact; its private constructor
producer is the separately changed factor. Generic public stages remain intact.

Complete oracle trees, shared aliases, demand order/first error, public mutations,
raw/staged/overapplied entries, reentry, proof cleanup and deep stack controls
precede timing. Full results and exact commands belong in the report. Failed
versions stay preserved; timing sources contain no diagnostic counters.
