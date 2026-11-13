# Phase190: discover reusable register and memory optimizations

Start:2026-11-13 15:46:55UTC, parent57dc784. Work for at least one hour;
target a useful result by16:47, with up to17:47 for demonstrated opportunities.
The user's target is direct-object x86 runtime at most2× our mature C backend,
with0.5× as a stretch. The last matched broad assembly score was4.00353× C;
these targets are aspirations, not predicted results or current measurements.

## Hypotheses and competing candidates

The current source retains a four-home fixed saved-register allocator with
static read counts, plus a temporary allocator limited to straight-line regions.
Phase186's fold witness has66 instructions/21frame references against QBE17/0.
Reinspect the exact current object before extrapolating. Stack references are
not cache misses; no claim of DRAM latency follows from these counts.

H1: loop-weighted placement can eliminate repeated scalar stack transport.
Compare static baseline, loop use weighting, and invariant/parameter weighting,
keeping fixed-home legality unchanged.
H2: adjacent one-use comparisons can feed branches directly. Admit using whole
function read/write facts; preserve widths, unsigned semantics, loops and aliases.
H3: a bounded liveness/interference plan can keep call-free loop state in caller
registers across branches and backedges. Validate the allocation before emission;
fall back on unsupported calls, excessive size, interference or incoming ABI risk.

Compiler algorithms and legality checks stay in Bend. Host scripts freeze inputs,
transport checked API bytes, build/link, observe independent outputs and time.
Candidates have explicit source-level switches for immutable ablations. No
benchmark-name recognizers, changed oracles, verifier weakening or selected
release changes during investigation. Keep old native images and rollback.

## Experiment ladder and time budget

0. Minutes: inspect retained code, freeze all sources/oracles and capture current
   machine instructions. Prepare source snapshots and exact baseline products.
1. Seconds: independently check extracted Bend APIs and small adversarial
   machine-function observers (aliases, calls, parallel moves, widths, backedges).
   One root-owned resource lane; subagents implement/audit independent changes.
2. Tens of seconds: evaluate6 development programs. Inspect the predicted work
   removal and repeated balanced clean timing. Reject candidates that only shrink
   text or move work without runtime improvement. Keep failed receipts.
3. Minutes: select a candidate using development evidence, then expose39 held-out
   programs once. Fresh C/baseline/candidate timings use frozen executable products,
   exact outputs and per-role calibrated batches. Report44 eligible cases, geometric
   mean, positive log deficit, cases>1.1×/>2×, largest regressions and compiler cost.
4. Only after transfer: actual native candidate, byte-compare checked/native
   products; native64/runtime controls as relevant; self-reproduction only when
   warranted by the demonstrated gain and resource/time budget. No install unless
   separately qualified. Retain current release if qualification is unfinished.

First15minutes acquire mechanism/controls; next20–35minutes compare alternatives;
next15–25minutes transfer/qualification; final time consolidate findings and
report. If an early hypothesis fails, use its actual machine evidence to choose
the next candidate. Do useful work for at least the requested hour, not sleep.
Reserve validation proportionally to change risk; avoid full rebuild per candidate.

## Reusable discovery record and limits

Each experiment records hypothesis, legality scope, candidate source hash,
compiler/runtime/toolchain, development/held-out status, actual machine products,
clean timing, compilation costs and rejection/promotion decision. Existing native45
and runtime-loop tools remain the evaluator; frozen inputs cannot be edited by
candidate code. The small wrappers are orchestration, not a new optimizer in Python.

Bend source acceptance and structural allocation checks are not end-to-end proofs.
Finite independent C observers/differential whole-output gates complement them.
For successful compiler changes, replay an identical acquisition/validation batch
under old/new native producers if economical, and include build/qualification cost.
Cheaper experiments are not evidence of more discoveries; causal recursive
acceleration needs a later controlled research-policy experiment.
