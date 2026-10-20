# Phase114: QBE parity through visible semantics and bounded compilation

Started 2026-10-20 21:31 UTC at `6259718`, `selfhost/bootstrap`.
This design precedes Phase114 compiler changes. The user authorizes continued
optimization, ambitious architectural experiments, documentation and pushes.
No PR comments. Use ordinary compiler tests and bounded benchmarks; do not
resume the custom failure reproductions stopped in Phase113.

## Baseline and question

The compiler remains written in Bend. Candidate31 emits QBE directly from checked
source and structured IR; a cached C runtime remains. QBE, assembler and linker
produce executables without per-program C or cproc. The candidate's checked API
is hosted by Bun. Its native self-hosting is **not qualified**: full acquisition
stopped after600 seconds during lowering. Phase112 facts remains the qualified
native checkpoint and installed production selection is unchanged.

The frozen45 program corpus has44 timed points and a zero-work control. Candidate31
averages7.087588× pinned upstream C/Clang-O3 runtime, with270 complete-output/count
observations passing. The previous facts campaign averaged15.943239×. The paired
six-development-case campaign improved6.505× but is a selected denominator.
List pipelines still cost about14×, tree/collection workloads roughly8–13×,
scalar loops roughly2×. Several families barely changed. Full-source size is
48,839lines,10.03% above facts. These are starting observations, not new results.

The mature self-hosted C path already showed approximately1.115× upstream on the
historical45 runtime corpus in Phase93. The Bend language alone therefore does
not explain the new QBE gap. Determine which optimizations/representation facts
are lost by the direct path and which surviving runtime boundaries obstruct QBE.
Do not assume that more ordinary inlining is sufficient.

Primary objective: reduce broad generated-program runtime toward1× upstream
without sacrificing complete outputs. Secondary integration objective: make
the improved backend compile its own full source in bounded time and memory.
Record compiler requests, native image construction, generated runtime, finite
conformance and complexity separately. Ambition levels below describe scope,
not guaranteed speed multipliers.

## 1×: measure the obstruction and compose exact improvements

1. Freeze source31/API/runtime/products and retain the qualified facts fallback.
   Reuse exact products and benchmark definitions. Capture code/receipt pins.
2. Split the existing lowerer into ordinary timed stages on one checked request:
   product/whole-function planning, inlining, range propagation, array facade,
   final verification and emission. First use real small and medium workloads.
   Host code only calls existing Bend functions and records time/metadata.
3. Reuse immutable verification results inside the optimizer. Source31 performs
   four full static/direct verifications inside lowering, including consecutive
   checks of the same graph. An internal session may verify the original once,
   retain stable IDs and recheck changed functions after transformations. Preserve
   failed-candidate fallback and the independent final verifier. An externally
   supplied certificate must not become a trust bypass.
4. Audit common runtime calls against exact upstream/mature C helper bodies.
   Inline narrowly proved tag/ownership/projection fast paths into typed IR,
   retaining complex/shared cases in the existing runtime. Compare actual
   instructions and complete outputs. Prefer one general helper over bespoke
   benchmark recognition.
5. Qualify each change on ordinary boundary tests and short paired runtime
   samples. A verified same-output compiler optimization must also establish
   unchanged final QBE for the fixed request before any speed attribution.

Hypotheses: verification reuse can remove a material fraction of large lowering,
but its share is unknown; visible runtime fast paths may remove repeated calls
and expose downstream optimization broadly. Measure rather than promise these
gains. A failed full build is not evidence that verification caused the timeout.

## 10×: optimize representations and call regions together

Move beyond adding independent peepholes. Choose the most supported of these
capabilities after the first ordinary kernels identify costs:

- **Specialized runtime regions.** Keep Term/ownership facts, tag tests, field
  projections and ordered RC effects in one structured region. Lower the common
  branch directly, call the existing runtime for the general branch. Reuse facts
  across operations rather than repeatedly unpacking the same Term. The initial
  experiment should span multiple ordinary list/tree/array workloads.
- **Array descriptors across loops.** Preserve immutable handle identity and
  representation facts across row iterations. Hoist/reuse checks only with a
  valid producer/alias contract or explicit loop versioning. A larger inlining
  threshold alone is not a descriptor proof.
- **Flat tagged state and constructor spines.** Extend flat products to explicit
  tagged unions and narrowly admitted destination-passing for recursive
  reconstruction. Preserve ownership, ordering and stack safety; arbitrary
  native recursion is not an acceptable substitute for the trampoline.
- **Mature backend capability reuse.** Trace a remaining slow computation from
  checked semantics through the mature C decisions and direct QBE. Factor an
  actual shared decision into structured operations where it removes duplicate
  analysis or unlocks a missing function/loop capability. Do not parse generated
  C or revive cproc as the optimization path.

Select by demonstrated generality and maximum removable work. A cheap structural
witness plus actual output is required before a large refactor. Implement at
least a meaningful slice when supported, not merely a document proposing it.

## 100×: a compiler and runtime that specialize together

The larger architecture is a shared typed effect/ownership IR whose operations
represent values, products/tagged state, ownership transfers, memory access,
ordinary calls, continuations and scheduling explicitly. A program-specific
runtime is a partially evaluated lowering of those operations. Runtime/helper
boundaries become implementation choices rather than permanent opaque calls.

One semantic decision layer could serve C and QBE; backend-specific rendering
and machine lowering would follow it. Continuation regions could use local loops
or explicit state machines while retaining the established generic fallback.
Optimization would jointly choose representation and control boundaries. This
could remove categories of allocation/RC/dispatch work rather than relocating
them between files. It might also simplify the duplicated backend code.

The small falsifiable slice is one real owning computation with a loop and
shared fallback, emitted from the same structured operations into baseline and
specialized routes. It must improve complete runtime and expose reusable
contracts before expanding. No new assembly backend, GPU backend, e-graph system
or autonomous optimizer infrastructure is justified merely by the ambition label.
Parity on a slice is not parity on the corpus. Recursive acceleration remains a
research question, not an observed outcome.

## Execution strategy and cost control

The coordinator owns one serial CPU3 target lane. Agents work in disjoint new
Phase114 modules: scaling/verification, runtime visibility, architectural review
and independent controls as needed. They prepare source and experiments; they
do not run target campaigns concurrently. Preserve Phase113 frozen modules and
all unrelated working changes. Agents should return concrete candidates and
source evidence promptly rather than launch another broad literature survey.

Use existing compiler research and upstream code first. Source-level evidence,
observed counters, machine code and timing answer different questions. Read-only
analysis may overlap target execution. Small runs use a2GiB tree cap, full runs
4GiB,16GiB available floor, explicit file/time caps and fresh output paths.
There is about1.1GiB free disk at start: avoid duplicate compiler products and
large raw trace campaigns. Preserve failed receipts; no global cleanup.

Iteration ladder:

1. Checked API and source/ABI admission; meaningful focused controls.
2. Small actual programs, unchanged output and structural witnesses.
3. Paired three-round selected kernels, including an ownership-heavy workload
   outside Phase113's development six. Use frozen repetition settings.
4. Larger source only after stage scaling is understood. A full acquisition is
   justified once smaller results establish a credible integrated candidate.
5. Original45 broad runtime and native generations at integration, not per edit.

Stop or revise a hypothesis when it cannot remove significant measured work,
fails outputs, exceeds resource bounds or only moves complexity elsewhere.
No fixed percentage target justifies weaker semantic gates. Prefer improving
experiment throughput and whole workload families to accumulating variants.

## Evidence and acceptance

Each hypothesis gets an experiment file with exact source/runtime/tool pins,
smallest test, expected falsifier and outcome. Keep output correctness,
measurement completion and native promotion separate. Report current ratios
against the same pinned upstream method, paired old/new figures when available,
three-round limitations, untouched families and regressions. Freeze any new
diagnostic subset before looking at candidate timings; broad45 remains fixed.

Final report must state which ambition levels were actually implemented, whether
the full native chain passed, what remains slower, source size and time/resource
accounting. Commit the design before new optimization implementation and push
useful implementation/evidence checkpoints. Installed promotion requires its
normal gates; no inferred success from API checking or source hashes.
