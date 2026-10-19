# Phase112: make the direct QBE compiler and its programs fast

Started 2026-10-19 00:41 UTC. Work window: three hours, through at least 03:41 UTC.
Baseline commit: `d2b9069a7fd03ed9c226d4032af2465215428e3d`.

## Objective and measurement contract

Reach upstream parity in compiler request time and generated-program execution,
then investigate a 0.5 time ratio. This phase makes measured progress toward that
objective; it does not promise parity within three hours. Ratios always mean our
elapsed time divided by the matched reference elapsed time. Keep five axes:
generated-program runtime, native compiler generation N1 request time, N2 request
time, correctness, and source/architectural simplicity. Experimental N1/N2 do not
replace production B1/B2 labels.

Phase111 proves full direct self-hosting and 45 corpus outputs, not broad runtime
parity. Native self-emission was 944.818 seconds (including 4.18 seconds of sampling
pauses); QBE/assembly/link took 10.260 seconds. Its hosted diagnosis attributed
138.776 seconds to frontend, 148.245 to lowering, 47.994 to verification, and
7.256 to emission. Do not transfer hosted percentages to native execution.

Compare the same frozen Bend sources, outputs, worker count, hardware affinity,
tool versions and flags. Upstream means pinned Bend's TypeScript compiler under
Bun, producing C/Clang programs. Record request time separately from executable
construction and program execution; label prepared Base versus live Base.
Inherited artifacts require exact provenance and output checks. No silent new
benchmark definitions or omitted unfavorable points. Report per-program ratios,
equal-original-program aggregation where applicable, and zero-work exclusions.

## Source evidence and ranked hypotheses

1. `p111_intrinsic` turns every primitive into argument stores plus an opaque
   `p111_rt_op` call. Emit exact scalar operations directly into structured IR.
   Potential: 2–5x on dispatch-heavy computations; total compiler gain unknown.
2. `p111_jump` and `p111_params` route known functions through scratch buffers,
   register banks and a dispatcher. Restore general structured direct workers
   and loops using mature admission rules, with generic fallback. Potential:
   2–5x on transition-heavy workloads; overlapping with scalar exposure.
3. Two let helpers recompute body-use sets; empty environments scan unnecessarily.
   Reuse results with exact-QBE preservation, then investigate one-pass liveness
   rather than repeatedly scanning suffixes. A 5–20% total compiler reduction is
   a planning hypothesis, not a measurement or bound.
4. Preserve ownership, product layouts, constants and known shapes until after
   optimization. Reuse Phase110 law-constrained ownership results and mature
   NF/NQ admission rather than translating C strings. Possible 1.3–3x on affected
   allocation-heavy paths. Phase110's 0.8531x reverse-worker/production-Clang
   result is a narrow precedent, not an upstream or whole-program result.
5. Compact compiler representations and reusable summaries can remove allocation
   and repeated graph work. Numeric identities, dense local tables and retained
   analysis facts are hypotheses to test on measured hot paths. Estimated 1.5–3x
   on affected analysis phases; no blanket representation rewrite without evidence.

These are conditional estimates, overlap, and must not be multiplied. Losing a
small experiment is useful evidence. Preserve rejected variants and real costs.

## 1x ambition: transfer understood capabilities

Freeze a small matched baseline; remove duplicate analysis; expose scalar
operations; add a general structured worker ABI; transfer selected ownership
and layout optimizations; reacquire and qualify a faster compiler. The initial
worker slice may admit bounded acyclic scalar functions and self-tail loops,
with generic fallback for unsupported effects, closures or representations.
Compiler algorithms and transformation legality remain in Bend. Host tools only
transport source, supervise processes and measure evidence.

First decisive experiments: exact scalar edge cases plus a runtime loop, known
call chain, constructor traversal, and actual compiler use-set/lookup workload.
Compare IR/machine structure as well as time: helper calls, transitions,
allocations and instruction shape. Fixes should generalize by structural rules,
never names of benchmark programs.

## 10x ambition: optimize before runtime commitments

Retain typed functions, join points, ownership and effects in a functional IR,
then lower to the existing machine IR and QBE. Delay boxing, closure allocation,
continuations and layout choices. Share function summaries between admission,
specialization, fusion and lowering. A consumed traversal returning a product
should be able to become a loop with direct arguments and scalar results, removing
continuations, copies, pair allocation and unnecessary reference counting jointly.

Preserve unbounded-recursion stack safety, effects and scheduling semantics.
Bound specialization/code growth and retain the complete generic route. QBE
already constructs SSA; another general SSA implementation is not required.
Use source slices only as explicitly different development inputs, never disguise
removing compiler functionality as a same-source compilation speedup.

## 100x ambition: coordinated program/runtime optimization

Explore verified alternatives for hot function groups: representation, ownership,
calling convention, loops, specialization and allocation policy chosen together.
Combine profiles with bounded search, cache validated transformations and compiled
functions, and distinguish fast development from deeper optimization modes.
Eliminate whole intermediate structures and repeated traversals where lawful.

A trusted frozen evaluator, held-out inputs, mutation controls and explicit
search/compute budgets constrain an autonomous research loop. Optimize validated
improvement per hour. A faster generated compiler can increase experiment rate;
measure that effect separately from compiler speed. 100x describes research scope,
not a claimed performance multiplier. 0.5x upstream needs less useful-work overhead
or algorithmic advantages beyond reproducing upstream's existing transformations.

## Three-hour execution and delegation

* 00:41–01:01: freeze plan, authenticate/recover disk headroom, prepare existing
  checked-API fast loop and six representative matched cases. Source review and
  preparation run concurrently; root owns serial CPU3 execution.
* 01:01–01:41: scalar lowering and use-set reuse, independent arithmetic/lifetime
  controls, exact-QBE checks for analysis-only changes, first paired measurements.
  Worker agent prepares structured direct calls/loops concurrently.
* 01:41–02:31: integrate strongest general worker/ownership change supported by
  small experiments. Acquire candidate image only after focused checks justify it;
  overlap target execution with source audit, report and next experiment design.
* 02:31–03:21: broader held-out/runtime/compiler screen, qualified bootstrap gate
  when feasible, reject regressions or retain explicitly experimental candidates.
* 03:21–03:41+: seal evidence, final report, documentation/frontier, commits/push.
  Use remaining time for the strongest unfinished experiment rather than padding.

Root handles integration, use-set change, target scheduling and final decisions.
Three bounded agents own scalar lowering, structured workers and benchmark
preparation; a short read-only disk audit prevents another space failure. No
agent runs heavy targets independently. No extra research agents unless needed.

## Correctness and promotion gates

Keep Phase111 sources/images immutable as references; compose additive candidate
modules with explicit provenance. Analysis-only changes must preserve complete QBE.
Codegen changes need independent output/edge-case controls, upstream comparisons,
and shared/static ownership cases where relevant. Division by zero, modulo,
overflow, shift masks, Bool/Term encodings, evaluation order and stack safety are
explicit boundaries. Do not remove runtime checks without proven premises.

Use seconds-to-minutes focused execution for iterations. Broad 45-program and
self-hosting checks happen at integration milestones, not every patch. Require
all relevant correctness gates and repeatable gains before selecting a candidate;
installed production stays unchanged until its own qualification is complete.
Small unmatched timings are observations, not performance claims.

Process-tree memory cap <=4GiB and >=16GiB available for full jobs; CPU3; existing
guard/lock, bounded deadlines and 128MiB generated-file cap. Disk is initially
nearly full: authenticate archived/duplicate bytes before removing regenerable
artifacts. Preserve failures and never delete unrelated work. Record wall-clock
spending, target time, abandoned experiments, source growth and remaining gaps.
Commit and push design, implementation and report. No PR comments.

## Deliverables

Additive Bend implementations, reproducible fast-loop commands, raw paired
evidence, independent controls, honest comparisons with upstream, and
`implementation/phase112/README.md`. Update the direct-QBE guide and experiment
frontier with selected versus unqualified capabilities. Record the next cheapest
experiment when a larger ambition is not completed in this window.

## Evidence-driven extension at01:18 UTC

The first six-program controlled runtime screen is22.01x upstream geometrically,
with6.5–211.8x per-program ratios despite a16x arithmetic-kernel improvement.
This is the new direct generic QBE path, not the older mature C backend. Its
missing optimizer capabilities are now measured. Prioritize typed static images,
private direct workers and bounded continuation fusion. Keep exact ownership and
fail-stop boundaries. Investigate direct IEEE binary32 intrinsic expansion at
the backend, where the verified atomic runtime operation already carries its
semantics; preserve NaNs/rounding/zero and fall back for unqualified conversions.
Do not infer that simply changing assemblers will close this architectural gap.

## Profile-driven pivot at 01:48 UTC

Authenticated runtime counters explain a much larger compiler opportunity:
1,625,654 U32 special-takes in the lexer compiler request call `p111_native_word`.
Each creates32 WCon nodes and31 nontrivial child wrappers, mechanically accounting
for102,416,202 of124,677,389 heap allocations (82.14%). Counts are not CPU shares.
The prepared cache's character/newline and numeric-role patterns expand into
thousands of QBE lines. Reuse the existing general NW_Rows recognizer and emit
low32 mask/equality branches before materializing Word. Retain ordered rows,
raw F32 bit semantics, fresh identities and exact generic fallback. Initially
refuse any row whose Word tail still escapes after the existing reconstruction
rewrite; do not add an ABI solely for rare residual cases.

The mature selector rewrite can likewise return ordinary KTerm directly to
P111 lowering. Keep its closed-body, use-count, strict-argument and freshness
premises. This is a small reuse adapter, not a new name-based optimization.

The first fusion/F32/wide32 screen lowers the six-case upstream gap from21.21x
to14.69x, but ray remains150.81x. Profiles show334,018 frames and483,445 jumps for
two ray evaluations; scalar expansion alone cannot remove function boundaries.
Try a bounded, typed region composition: each immutable rank fuses calls only
to previously admitted private workers, then admits the resulting whole body.
Freeze its transformed body/plan on first admission. Never re-plan an admitted
worker using the final larger index, which could create machine-call cycles.
Keep self-tail loops local and non-tail/mutual recursion on the generic path.
Bound ranks/native call depth, code growth and copied continuations. Qualify
nested calls, captured ownership, pending outer frames and recursive refusals
before benchmarking. This realizes a slice of the10x ambition by letting two
existing transformations enable each other.
