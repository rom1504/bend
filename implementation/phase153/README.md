# Phase153 — substantial cold-build headroom

**The strongest large opportunity is removing representation and ownership work
across the backend, rather than adding another optimization pass.** The current
compiler spends 101.45 diagnostic CPU seconds in raw lowering, initial
optimization and output generation/cleanup. Halving that complete region would
save about 51 seconds, approximately 20% of the 249-second cold-build reference.
That is a testable target, not an achieved speedup or a guarantee that all work
in those stages is removable.

This investigation uses the qualified Phase152 N2 at starting commit `0a16bb7`.
Production compiler source and installed selections are unchanged. There were
**zero compiler self-builds and zero broad program-runtime campaigns**. One full
sampled emission, one small output gate and one small event capture establish
the following evidence. [Design](../../design/phase153/README.md),
[metrics](metrics.json), [evidence/replay](evidence/README.md).

## Current costs, rather than old hotspots

The retained N2 object was relinked against the existing diagnostic runtime;
only runtime/sampler support was compiled. Fresh FIDs, source ownership, ELF
bindings and libc unwind ranges were authenticated. The compiler processed its
exact 3,085,157-byte qualified source, using the same prepared Base and serial
CPU3 configuration. Its entire 118,227,421-byte QBE output matches the existing
N3 oracle. No compiler algorithm or verification gate was disabled.

The capture took 238.762s wall, with 236.947s in disjoint stage intervals and
7,406 samples. Loss/overruns are zero, sampled-thread/process CPU coverage is
99.432%, delivery is plausible, and all required stage boundaries pass. There
is one capture at 32ms, not a repeated performance comparison or confidence
interval. The diagnostic clock excludes QBE machine construction and differs
from the 249.222s clean source-to-executable reference.

| Disjoint stage | Diagnostic CPU seconds |
| --- | ---: |
| Raw generic/private lowering | 39.27 |
| Output generation and cleanup | 38.63 |
| Checking/publication | 33.57 |
| Parse/load | 29.64 |
| Initial optimizer | 23.55 |
| Observer composition and selected final admission | 19.42 |
| Registry preparation | 16.23 |
| First independent verifier | 7.93 |
| Annotation/reach | 6.40 |
| Erasure/finalization | 6.20 |

The conditional final verifier is another 9.22s **inside** observer composition;
it must not be added again. Output generation includes late analysis and teardown,
not merely writing bytes. The full table and unknown samples remain in metrics.

## Where the machine spends time

These are disjoint physical-PC categories across the entire capture. They overlap
the stage/owner view above and must never be added to it.

| Physical work | All-sample share |
| --- | ---: |
| Reclamation (`term_drop`, `span_fade`) | 17.65% |
| Existing ownership/product helper group | 16.10% |
| Allocation helper group | 1.85% |
| Register transport, including recovered libc copies | 7.12% |
| Three borrowed string equality/hash/comparison workers | 9.92% |
| Scheduler group | 4.55% |

The first four categories total **42.71%**. Adding the three string workers gives
52.63%. These are real costs, but not a claim that 53% can simply be deleted:
necessary data access, preservation of sharing, conversions and replacement
operations still cost time. All 313 eligible libc samples recover the
`p111_set_regs` caller through the exact CFI table; no unresolved sample is
silently assigned to copying. Unknown physical and active contexts remain in
their denominators.

Replacing the allocator alone has a direct sampled ceiling of only 1.85%.
The larger opportunity is preventing temporary objects, their ownership
transitions, name processing and transport from existing in the first place.
This distinction explains why smaller helper optimizations have underdelivered.

### A cheap event probe makes the work concrete

An 8,202-byte ordinary compiler request, producing 1,237,299 QBE bytes, performs:

- 24,687,184 heap-allocation calls, and the same number of frees.
- 46,298,317 requested words, about 370 MB of cumulative size-class capacity
  (already including allocator rounding).
- 25,566,523 `term_drop` entries and 27,830,296 constructor takes.
- 20,445,463 dispatcher visits and 36,418,475 requested register-copy words.

This is a complete fresh request, including loading the prepared Base, parsing,
compilation, output and cleanup. It is not a statement about only the small user
source or a full-compiler extrapolation. Allocation calls mostly reuse pooled
cells: only 1,334 lane-refill calls occur. Requested bytes are cumulative, not
peak memory or millions of system `malloc` calls. Hook counts can omit inlined
operations; active dispatch is not allocation origin or a logical call stack.

`String.append` and `p144e_body_tail` account for 40.99% of the allocation calls
in this probe. `p111v_get`, `lookup` and `p113k_get` account for 27.20% of drop
entries. `p111v_name_chars` alone receives 2.86 million dispatcher visits. These
observations support investigation of text/identity/fact representation; they
are not corresponding percentages of elapsed time. The 3.09s event-instrumented
clock is not a performance result.

## Ranked opportunities

### 1. Produce numeric identities and compact facts directly, keep them to output

**Largest credible experimental scope: roughly 20–30% less cold-build time if
the complete affected backend region becomes about twice as fast.** There is
no demonstrated gain yet. The smallest three-stage envelope is 101.45s; the
broader backend envelope including composition, registry and first verification
is about 145s. Neither envelope consists entirely of avoidable work.

The information is already structured before it becomes text:

- `back/qbe/lower.bend:p111_load_fields` and `p111_bind_value` form local names from
  numeric binder IDs using `U32.show`; continuations use a numeric fresh counter.
- `back/qbe/model.bend:N111Value` stores local, function and constructor references
  as Strings. Statements and argument lists are separately boxed.
- `back/qbe/verify-segments.bend:p111v_get/put` rehash names and build generic
  `KDef` records for small width/capacity facts.
- `back/qbe/scalar-facts.bend:p113k_put` encodes scalar facts with a `KDef` and
  nested `KTerm` payloads; subsequent passes recover them through more lookups.
- `back/qbe/emit.bend:p111q_local/id/value` rebuilds spellings and resolves IDs
  again during rendering.

The experiment should start at one real lowering producer, retain local IDs,
operator enums and compact fact rows through its existing transformations, and
render original spellings only at output/diagnostic boundaries. Preserve source
origin, ownership, capacities, version epochs, branch joins and exact public
names. Unknown forms retain their supported fallback. This is a bounded complete
computation, not a wholesale universal IR or another new backend.

**First decision budget: 1–2 hours.** Use actual compiler owners plus unrelated
Map owners, with a substantial mix of branches and calls. Compare old/new in the
same small native executable. Include production, analysis, final independent
verification conversion, emission and destruction. Inspect actual machine reads:
Phase148's nominally compact arrays retained significant runtime transport.
Demand close to 2× on a sufficiently representative complete region before
claiming a 20% cold-build opportunity. A lookup-only win does not pass. If new
conversions consume the saving, stop before a full image build.

Implementation across the pipeline would be a larger, uncertain project—roughly
one or more focused days after a convincing prototype, not another promised
one-hour rewrite. It should preserve emitted QBE initially, making generated-code
preservation cheaper to establish. This is my recommended major direction.

### 2. Preserve borrowed descendants across helper returns

This could remove ownership work across multiple stages with less representation
migration. Current borrowed readers admit scalar observations or original-root
identity; they do not generally return a selected descendant tied to a held root.
`p128br_call`, `p128br_eligible`, `p128bl_result`, `noa_finish_value` and
`p131p_virtual` expose the boundary. The shallow width limit is already 16;
repeating the old width-nine experiment would add nothing. Recursive `KDef`
shapes also exceed the simple recursive-spine admission.

A private result-origin summary could preserve which caller-held root owns the
returned subtree. The root must stay alive through every borrowed use; owning
escape requires acquiring ownership before the root is released. Start with a
scalar final observer, not arbitrary stored borrowed words. Ordinary lookup ABI
must remain correct. This is a real missing capability identified in earlier
Phase131/136 research, not a newly invented concept.

**First decision budget: 45–90 minutes.** Compare current lookup-plus-observations,
an explicit held-root selector/consumer, and separate helpers carrying the result
origin. Include hits, misses, collisions, legacy forms, root observation afterward
and full cleanup. Require the ownership operations to disappear in machine code
and unrelated transfer. A rough 5–15% whole-build hypothesis merits testing, but
is lower confidence: the global reclamation share cannot be assigned to lookup
results. It currently lacks a demonstrated 20% whole-build ceiling.

### 3. Avoid repeated complete-world materialization during publication

There is a concrete remaining repeated-work path:

`p143cp_walk → p143cp_publish → p143cp_put_log → book_put(p143cp_canon(book), d)`.

In `check/compact-schedule.bend`, publications outside the childless-Def shortcut,
notably ADTs, canonicalize the whole accumulated world. That reverses the event
list, validates names, builds a fresh seen index, filters rows and reverses again.
The world already includes suffix headers. The actual source contains 369 type
declarations, 201 in the QBE model; these are static exposure counts, not measured
canonicalization invocations.

Named `book_final_*` contexts take 243 of the checking stage's 1,047 samples,
about 7.78 sample-period seconds, with unassigned shared index/reclamation work
in addition. Canonicalization is not shown to dominate the whole stage. Its
33.57s total gives an impossible upper bound of about 13.5% of the cold build;
this cannot independently deliver the 20–30% objective.

Test postponing canonicalization while retaining ordinary `book_put` and final
`p143cp_result`. The obligation is
`C(book_put(B,d)) = book_put(C(B),d)` for the admitted cached world, with identical
cache/index, ordered ADT visibility, diagnostics and final failure worlds. Do
not log obsolete ADTs or broaden malformed-input admission. Template and
specialization routes already use ordinary `book_put` on logged worlds, which
makes the hypothesis plausible but is not its proof.

**First decision budget: 20–40 minutes** using genuine publication replay and
complete book/index equality, then checking only if it wins. A 3–8% cold-build
hypothesis is plausible and inexpensive to falsify; it should not become another
large qualification campaign or displace the larger representation experiment.

## What not to spend another campaign on

- A parser-only or renderer-only optimization cannot reach 20% even under
  impossible complete elimination of its current stage. Combine boundaries only
  when the same change genuinely removes work across them.
- Phase149 disabled optimization and saved about 51s, but produced a compiler
  running 1.831× slower. That trade does not meet the objective.
- Phase148 packed an already-built IR, analyzed it, then unpacked it. Conversion
  cost rose 16.2%; complete-region results were neutral or worse. Numeric storage
  must replace producer-to-consumer work, not become a temporary extra format.
- Ready private workers do not imply generic bodies are disposable. Public ABI,
  continuation/closure/static references, ordered IDs and optimizer dependencies
  must be established first. The raw-lowering stage combines generic and private
  work; its 39s is not a measured duplicate-code budget.
- Parallel backend units may offer a larger wall-clock gain, but ordering,
  freshness, publication and the qualified single-mutator runtime are real
  boundaries. No unmeasured multicore speedup is counted here.

Reaching 100 seconds from 249 needs roughly 60% less complete time. A backend
region twice as fast is a credible first target; it cannot establish 100 seconds
by itself. We need a prototype that demonstrates the missing factor, not a more
ambitious label for a small pass.

## Time and evidence discipline

Five guarded jobs total 281.46s: preparation 12.81s, diagnostic support build
6.04s, small clean/diagnostic output gate 10.48s, full profile/analysis 248.47s,
and event capture 3.66s. Only the small gate is preliminary output qualification;
the full run gathers the requested information. No new compiler was acquired.
Two bounded agents audited source independently; root owned the target lane.
Agent/review/documentation time is separate and quota billing is unavailable.

One event command was refused by CLI resource admission because its file cap
was below the tool's supported minimum; no target or run root was created. The
corrected command succeeded. All five executed jobs pass, peak RSS is about
1.13 GB, and all are closed without pruning. Raw output, exact commands, method
identities, counter caveats and negative reasoning are preserved in the capsule.
