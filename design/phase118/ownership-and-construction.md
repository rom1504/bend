# Phase118 — preserve ownership and construction plans in QBE

Start: 2026-10-21 09:47 UTC. Parent: `c6a0564` (Phase117).
Work for at least three hours, using evidence to select extensions. Research
ambition levels below describe scope, never promised speedup factors.

## Question and baseline

Can projecting the mature Bend-written C backend's construction and borrowing
plans into structured QBE eliminate entire categories of native runtime work?
Phase117 selected source improves the original44 timed points from5.308 to4.240
times pinned upstream C execution time. Its array cases gain up to5x, while
tree/list/map/lexer retain substantial ownership and continuation costs.
The eight-program Phase116 diagnostic has mature selfhost C at1.089x upstream,
but is neither a broad45 result nor an isolated machine-backend ablation.

Keep Phase117 array gains and runtime capability3. Preserve the Phase114 native
qualified checkpoint and installed production selection. No native compiler
throughput or recursive-improvement claim without corresponding measurement.

## 1x: one useful, general construction transformation

Trace list building/mapping from checked source through its semantic construction
plan, QBE continuations and generated machine code. Reuse mature structural
admission and sequencing where possible. Implement destination passing: construct
into a private pending destination, retain complete initialization/sealing rules,
and publish only complete results. If soundly available, reuse a consumed unique
cell; shared/static inputs retain the ordinary ownership behavior.

First test a tiny ordinary source plus the original list workload. Require
machine evidence that continuation/reconstruction work disappears, independently
checked complete outputs, and a repeatable runtime benefit. Do not specialize
on benchmark names, invent a second host-language compiler, assume uniqueness
from layout, or silently weaken stack safety. Reject a small helper-only result
before a full compiler build. Retain failed attempts and unchanged baselines.

## 10x: reusable ownership-aware region interface

If the construction experiment pays off, make the plan reusable across builders,
mappers and unrelated string/tree cases. Carry field layout, owned versus
borrowed use, destination state and return shape through a private structured
region interface. Investigate borrowed observer workers as a separate ablation:
avoid ownership transfer when an observer only reads a structure and returns a
scalar. Compare map/tree against their existing mature-C implementations.

Use precise argument/capture transport where it follows from the same verified
region, rather than copying/clearing an entire generic register bank. Unknown
calls, effects, escaped destinations and unsupported shapes retain the original
path. Keep the final independent IR verifier and ordinary shared/captured/deep
recursion controls. Measure compilation cost and code growth as well as runtime.

## 100x: remove intermediate data and research work

Consider a compositional producer/consumer or destination contract that permits
eliminating intermediate lists and their lifetime operations entirely. A second
possibility is reuse of the same ownership-aware plan across C and QBE, reducing
duplicated optimizer decisions and enabling the compiler itself as a workload.
These are conditional probes, not mandatory rewrites. Only attempt a small
projection if the lower-scope evidence supplies the necessary semantics and a
cheap independent oracle. Preserve strictness, evaluation order and sharing.

A convincing extension needs transfer to an unrelated program and accounting
for acquisition/validation cost. Recompiling unchanged compiler source or making
successive commits is not evidence of recursive acceleration.

## Execution and cost discipline

1. First hour: recover disk headroom without losing evidence; inspect actual
   plans; compose/check a minimal Bend candidate; run a decisive list experiment.
2. Second hour: refine or reject the first mechanism; run ordinary ownership and
   recursion controls; pursue one evidence-supported10x extension or borrowing
   experiment. Two bounded offline audits may assist; root alone runs targets.
3. Third hour: test transfer, compare selected candidates to fresh parent/upstream
   observations, run original45 once if justified, measure compiler cost, and
   record the result. Continue beyond three hours if needed to finish a coherent
   candidate/report, without launching speculative large campaigns.

Use the existing serial CPU3 process-tree guard,2GiB ordinary RSS and16GiB
available-memory floor. No concurrent benchmarks. Fresh immutable output names;
never overwrite frozen/hardlinked products. Disk is currently244MiB: first
coalesce exact duplicate generated artifacts with byte/mode verification and an
audit receipt. No large native image acquisition without adequate disk and a
measured reason. Preserve unrelated worktree changes.

## Evidence and selection gates

- Pin compiler source/API, runtime, source fixtures, oracle, QBE and executables.
- Separate static code counts, statistical profiles and clean runtime clocks.
- Use original complete-output/count checks, rotated order and longer repeats
  only for ambiguous results; keep rejected observations.
- Controls exercise empty/small/deep inputs, shared references, captured values,
  scalar and boxed fields, destination completion and ordinary fallback behavior.
- Report44-point geometric runtime ratio, per-family changes, hosted compilation
  cost, source/code-size change and precise qualification scope. Do not replace
  the45-program corpus with an easier subset.
- Keep production unchanged unless separately justified qualification completes.
- Commit design, useful implementation and final report; push without posting
  any PR comment.

## Initial hypothesis ordering

1. Destination passing/cell reuse removes pending frames and reconstruction.
2. Borrowed observers remove avoidable shared-RFC ownership transfers.
3. Known layout and direct region transport remove generic helper/bank work.
4. Typed floating-point call transport is a separate numeric fallback direction.

The first two have mature implementations in this repository. Their existing C
results demonstrate headroom, but do not predict an isolated QBE speedup.
