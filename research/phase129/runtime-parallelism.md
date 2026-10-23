# Phase129: runtime parallelism, ownership and compiler work

Static audit at fork HEAD `a4ecad0`, 2026-10-23. No target execution, builds,
compiler edits or new qualification. This report distinguishes the selected
Phase128 experimental compiler from installed production selections.

**Recommendation:** keep QBE and first expose one measured, immutable,
per-function analysis boundary. Do not try to recover compiler throughput by
turning on runtime threads. The selected direct-QBE ABI deliberately supports
one Bend evaluator; Phase128 additionally contains an optimization whose memory
ordering argument depends on that restriction. A small shared semantic contract
can help sequential work reuse now and make parallelism possible later.

## Identities and scope

The local upstream language/compiler last changed at
`059266225b77c8ca256ac6b25ee5c21449bab151` (October 8). The coordinator separately
verified October 23 upstream HEAD
`5150fe296f70a918026de20b808d24d2a521a7d7`; this audit did **not** inspect that
newer revision's source differences. “Upstream” below means the pinned local
revision, not an assertion that HEAD has identical behavior.

| Inspected artifact | SHA256 |
| --- | --- |
| `bend2/comp.ts` | `2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c` |
| `bend2/bend.ts` | `1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49` |
| Phase128 `native-source02/compiler.bend`, 2,609,331 bytes | `6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d` |
| Phase128 `runtime-borrow01/runtime.c`, 149,279 bytes | `6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a` |
| Phase128 runtime object | `9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749` |

[Candidate identity](../../implementation/phase128/candidate.json) and
[native qualification](../../implementation/phase128/native-qualification.json)
bind these assets to the qualified N1/N2 and exact 102,187,679-byte reproduced
QBE. Qualification does not add a parallel-execution guarantee.

## What Bend2 parallelism means

The source primitive is a simultaneous call group, such as
`left right = visit(a) visit(b)`. It exposes independent calls and promises
roughly balanced work. A normal call does not automatically create parallelism;
`f!(x)` marks offload of a computation containing explicit parallel calls.
The guide specifies sequential JavaScript, native CPU fork-join, and native
Metal/CUDA offload. Its missing-GPU fallback preserves the result on CPU.
[Guide, parallelism](../../guide/GUIDE.md#L128),
[GPU mark witness](../../tests/run/gpu_mark.bend#L1).

The actual upstream C emitter has both paths at a fork: `if (!seq)` allocates a
join and child tasks, while the sequential path uses continuation frames and
ordinary transitions. Fork reachability is propagated to segment metadata.
The scheduler grows a frontier, then drains work sequentially inside each lane;
even a multicore execution therefore needs correct sequential fork lowering.
[Emitter](../../bend2/comp.ts#L2537),
[reachability metadata](../../bend2/comp.ts#L2834),
[sequential flat-result regression](../../tests/run/fork_shared_flat.bend#L1).

The author-maintained BendRT paper source describes a 128×128 task cube,
row/column phases, per-lane allocation, join countdowns and **no work stealing**.
Equal function counts do not imply equal work: a compiler workload with very
different AST sizes could leave most workers idle at phase boundaries. The
paper explicitly makes balance the programmer's obligation.
[Task cube and scheduling](../../bend2/docs/BendRT/main.typ#L405).

This is Bend2/BendRT, not the old HVM interaction-net evaluator. The paper
explicitly says the new runtime drops interaction-net graph reduction and
optimal sharing of redexes in favor of affine ownership and native sequential
code. Do not import HVM's “parallelism at every redex” model into this compiler.
[Paper introduction](../../bend2/docs/BendRT/main.typ#L142),
[related work](../../bend2/docs/BendRT/main.typ#L573).

GPU support is more than QBE producing an object: upstream emits host/device
code from common C, computes the bang-reachable segment closure, generates a
device executable, and manages the same heap/task protocol on Metal/CUDA.
The paper's offload loop does not run CPU and GPU computation concurrently.
Its strong GPU figures are specific author-reported workloads/hardware, not
compiler-AST performance forecasts.
[Device reachability](../../bend2/comp.ts#L2808),
[GPU implementation model](../../bend2/docs/BendRT/main.typ#L473).

## The qualified QBE path is deliberately sequential

This is established by inspected executable inputs, not inferred from a
benchmark command:

1. The selected runtime sets `BEND_METAL=0`, `BEND_CUDA=0`, and `BANGS=0`.
2. `p111_rt_main` defaults to one thread/GPU off and rejects any other setting
   at runtime line 4494.
3. `P111State` is the scalar bank/stack/transition ABI. Its public operations
   include frame, jump, return and closure apply, but no fork/join constructor.
4. `p111_rt_apply` requires `state->seq`; `p111_bind` accepts only descriptors
   containing the sequential capability and permits one program per process.
5. The frontend reduces a parallel let to the common multi-binding `Let`.
   Direct-QBE lowering sends both `Let` and `NSeqLet` through `p111_lets`, which
   recursively emits sequential cuts. The GPU marker does not enable a device
   execution path in this capsule.

[Selected runtime](../../selfhost/build/phase128/runtime-borrow01/runtime.c#L4494),
[runtime materialization](../../selfhost/tools/performance/phase111/runtime/materialize.py#L76),
[public ABI](../../selfhost/tools/performance/phase111/runtime/runtime.h#L9),
[parallel flattening](../../selfhost/src/front/flatten.bend#L120),
[QBE let dispatch](../../selfhost/tools/performance/phase112/static/original.bend#L17),
[sequential let lowering](../../selfhost/tools/performance/phase111/segment/lower-control.bend#L67).

Consequently, accepted pure parallel syntax can retain its sequential result
without providing multicore execution. A successful `#|` output comparison
alone cannot establish parallel conformance. The retained CPU pool and IO helper
code inside the runtime source also do not establish an admitted second Bend
evaluator. The fixed foreign-provider admission excludes `IO.fork`/`IO.join`;
upstream asynchronous IO tests are a separate capability boundary.
[Effect admission](../../selfhost/tools/performance/phase111/segment/lower-book.bend#L92),
[upstream IO overlap test](../../tests/io/process_run_parallel.bend#L1).

Historical Phase71 did demonstrate 3.753× speedup on four physical cores and
near-upstream throughput for a balanced compute-heavy fork tree. That was the
**mature self-hosted C backend**, not QBE, not the compiler's own execution,
and not an irregular/shared-AST workload. It is a useful retained experimental
route and proves that all parallel infrastructure need not be invented anew.
[Exact scope and measurements](../../implementation/phase71/README.md#L38),
[mature C fork lowering](../../selfhost/src/back/native/parallel.bend#L1).

## Affinity is useful evidence, not a runtime uniqueness certificate

Three distinct claims must remain separate:

| Claim | What it establishes | What it does not establish |
| --- | --- | --- |
| Checked affine use | A source binding is consumed at most once unless explicitly reusable; `+` needs Data | A physical Term is raw, unaliased, RFC-count-one, or uniquely owned by this thread |
| Checked mathematical law | Equality/behavior of the checked source/model within its stated assumptions | Correct lowering, actual retain counts, publication ordering, C/QBE memory behavior |
| Runtime/backend admission | Specific representation, retained roots, buffer provenance, helper and scheduling obligations | Unqualified multicore/GPU compatibility or whole-compiler correctness |

An affine parameter can receive one owned **counted handle** to a shared graph.
An unmarked local use therefore does not authorize unconditional in-place
mutation/freeing of the underlying graph. Upstream `ctr_take` distinguishes raw
and RFC terms, while keep/drop implement actual reference transitions.
[Quantities](../../guide/GUIDE.md#L198),
[runtime sharing operations](../../bend2/comp.ts#L3905),
[concrete take](../../bend2/comp.ts#L4034).

Borrowing can avoid most reader-side RC work if a parent/join holds the root
until all children finish. Upstream has particularly relevant tests:

- [Two borrowed readers held by the join](../../tests/reg/borrow_fork_hold.bend#L1).
- [Borrowed reader plus owning child consumer](../../tests/reg/brw_fork_cross.bend#L1).
- [Two owning consumers of a shared tree](../../tests/rfc/share_forked.bend#L1).
- [Shared flat value across fork frames](../../tests/run/fork_shared_flat.bend#L1).

These are source witnesses with independent expected outputs, not evidence that
the selected QBE runtime has passed multicore execution. They show why “copy the
book into each worker” and “borrow the book while the join owns it” have very
different costs and correctness obligations.

**A current hard boundary:** selected Phase128 `p128bf` field-read expansion
replaces the helper's atomic RFC metadata reads/acquire with ordinary loads.
Its audit explicitly relies on the single-Bend-worker runtime. Enabling workers
without disabling this expansion or establishing an adequate memory-order
contract invalidates that justification. Ordinary concurrent reads plus atomic
writes cannot simply be assumed safe because location bits are logically
constant. Keep the original helper first in any parallel prototype.
[Expansion](../../selfhost/tools/performance/phase128/borrow/field-read/template.bend#L55),
[sequential premise](../../implementation/phase128/borrow-field-template-audit.md#L68).

The scalar borrowed-observer guard is also narrower than general ownership: it
accepts retained shared/static roots, rejects certain aliases, and uses stable
owner counts to predict cheap final drops. Retaining a root protects lifetime;
concurrent external drops could still invalidate the constant-time-drop
profitability prediction. That is distinct from memory unsafety.
[Guard and limits](../../implementation/phase128/borrow-audit.md#L70).

The repository already states that its laws do not verify the generated code,
runtime or scheduler. Phase97's missing-retain mutation passed a source-model
boundary and failed concretely, demonstrating this gap rather than closing it.
[Law/proof boundary](../../docs/self_hosted/COMPILER_LAWS.md#L9).

## Where compiler parallelism could actually fit

The compiler is not an embarrassingly parallel map over source definitions.
Upstream checking walks declaration events in order, exposing only bodies
validated so far; first errors and on-demand instances are observable. Checking
every definition against the final fully unfolded book would change semantics.
Upstream code generation itself has a global `FL` and iterative ownership/hot
facts; running its existing loop concurrently would require separate state and
deterministic merging too.
[Checker visibility](../../bend2/bend.ts#L3779),
[compiler fixed point](../../bend2/comp.ts#L2768).

There are better boundaries in our backend, **after** checking and common
preparation:

| Work | Independent part | Required ordered/global part |
| --- | --- | --- |
| `p113pl_candidates` | Per-function candidate computation against a frozen prepared book/signatures | Candidate order and first-error semantics; ready/dependency closure |
| `p118b_rederive` and similar observers | Per-owner legal read-plan analysis | Helper dependencies, capability agreement and final verification |
| `p111_compile_defs` | Most body lowering after identities are assigned | Currently threads fresh segment IDs through previous results; requires local IDs plus deterministic relocation or counted prefix allocation |
| `p112s_defs` | Some local analysis of static values | Threads static-image offsets, deduplication and facts; not a safe naive parallel map |
| Direct-function verification | Body/schema checks against fixed authenticated inputs | Current `ready` prefix changes after each function; preserve dependency visibility, duplicate checks and first error |
| Final emission | Per-function text against frozen IDs/metadata | Stable ordered concatenation; no shared mutable fresh-name counter |

Exact selected-source locations are `p113pl_candidates` 46021,
`p113d_passes` 44702, `p112s_defs` 42268, `p113e_functions` 45093,
`p118b_rederive` 51482 and `p128raw_prepared` 56450 in the pinned source above.
Maintained boundaries:
[raw shared preparation](../../selfhost/tools/performance/phase128/sharedprep/raw-session.bend#L14),
[sequential segment naming](../../selfhost/tools/performance/phase111/segment/lower-book.bend#L33),
[static-image threading](../../selfhost/tools/performance/phase112/static/plan.bend#L90),
[verifier ready prefix](../../selfhost/tools/performance/phase113/direct-emit/verify.bend#L184).

The smallest useful interface is a frozen request context plus indexed work
items returning local facts and candidate results. A deterministic reducer
assigns identities and resolves dependencies. Preserve legality separately
from representation and profitability. This can run sequentially first and
pay for itself through less recomputation. It needs neither a universal IR nor
a new backend. Do not call a serial implementation a parallel speedup.

## Ranked experiments and conditional bounds

These are planning estimates, not measured gain predictions. Keep one controlled
target lane unless a specific core-scaling experiment deliberately reserves
multiple physical cores. More concurrent experiments also consume more memory
and CPU; they do not automatically reduce total research cost.

1. **Measure one per-function boundary and retain immutable inputs.** Estimated
   30–90 minutes for a census/proxy; another 1–3 hours for a small sequential
   contract/reuse change if the boundary is clean. Record time distribution by
   function, input AST size, dependency count and peak live data. Require exact
   QBE and unchanged independent verifier. There is no supported gain estimate
   until the refreshed profile identifies its fraction of complete request cost.

2. **Balanced parallel proxy through the existing C runtime.** Estimated 1–3
   hours after extraction, excluding environment repair. Run the same checked
   Bend analysis with identical one/two/four-core inputs, outputs and flags;
   measure shared-book RC traffic and preparation separately. Compare balanced
   AST-cost partitions with equal-count partitions. This cheaply tests whether
   the analysis and retained-root strategy scale; it does not qualify QBE
   multicore or improve the installed compiler.

3. **Direct-QBE two-worker fork/join proof of capability.** Rough estimate
   1–3 engineering days for a bounded prototype with existing runtime machinery;
   broad ownership/scheduler qualification could take longer. It needs checked
   fork/join IR and ABI, per-worker stacks/banks/allocators, correct captures,
   result widths, publication/countdown rules, bounded-stack/error behavior,
   mode-aware admissions, and disablement/requalification of sequential-only
   field loads. Just removing the CLI guard is not a valid experiment.

4. **GPU compiler analysis.** Defer. QBE here emits host amd64 code; a device
   compiler/runtime interface, memory protocol and capability gates remain.
   At least a multi-day exploratory project, with no defensible gain estimate
   for pointer-heavy irregular AST traversals. First prove substantial uniform
   CPU-scalable work and amortization. A new CUDA backend is not the cheapest
   way to learn that.

For a fraction `f` of request time that really scales over `p` workers,
`T_p / T_1 = (1-f) + f/p + h`, where `h` includes partitioning, joins, sharing,
extra preparation and imbalance as a fraction of original request time.
If `f=0.5`, four perfect workers give 0.625× time (1.6× speedup) before costs;
if `f=0.75`, they give 0.4375× (2.286×). Starting near 1.94× upstream request
time, four workers need over 64.6% perfectly scalable work even to reach 1×,
before overhead. This would be a **four-core versus one-core latency result**,
not single-core parity or improved CPU efficiency. Approximately 0.5× would
require essentially the entire request to scale on four workers and almost no
overhead; there is no evidence for that premise today.

The decisive early falsifier is therefore a same-source, complete-cost scaling
proxy plus a measured fraction of actual compiler work—not a scheduler rewrite.
If the useful scalable fraction is small, improving shared queries and avoiding
repeated preparation remains the higher-return path. Preserve the qualified
sequential QBE image and its existing proof/ownership contracts throughout.
