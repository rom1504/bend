# Native IR: a three-hour campaign with 1×, 10× and 100× ambitions

2026-10-18. Status: execution authorized; campaign started at 06:37 UTC.
The user requested three ambition levels, with larger extensions selected as
the three-hour campaign progresses. This document defines that selection.
The labels describe scope and leverage, **not promised speed factors or three
independent projects to finish in three hours**.

## Execution extension: remove Clang constraints

The user explicitly authorized alternatives beyond C and Cranelift. Evaluate
QBE 1.3 as a third consumer of the same Bend IR, using its official pinned source,
GNU assembler and linker. Also link existing Cranelift objects without Clang.
Compare complete source-to-result cost and generated runtime separately; a fast
backend does not earn promotion merely by accepting the graph. A small C test
runner compiled once with GCC is an explicit host dependency, not a Clang
dependency. Production self-hosting remains a separate gate.

The first integration experiment captures checked and annotated KTerm graphs
from the existing compiler written in Bend, hosted in JavaScript. Lowering and
optimization remain Bend functions. Graph replay accelerates backend edits;
fresh source checking is included in separate complete-loop measurements.
This bridge is deliberately not described as native frontend integration.

## The objective

Make real Bend compiler changes cheap to build, check and measure, while improving
generated-code quality and keeping the implementation understandable. Build one
architecture that can grow from useful scalar programs to the compiler itself.
Every extension must add a usable capability or answer a consequential question.

The immediate milestone is ordinary Bend source flowing automatically through
the existing checker, a structured native IR, and both C and Cranelift consumers.
Do not stop at another collection of manually reconstructed IR workloads.

Related work in this repository:

- [Phase106 results](../../implementation/phase106/README.md) and
  [code-shape findings](../../implementation/phase106/backend-analysis.md).
- [Native backend architecture](../phase105/fast-native-backend.md).
- [Recursive-improvement model and experimental controls](../phase104/recursive-improvement.md).
- [Current five-metric definitions](../../docs/self_hosted/METRICS.md).

## What the current evidence permits

Phase106 has a Bend-written IR model, verifier, folding pass, C/JSON emitters,
and a pinned Rust/Cranelift consumer. It supports structured control, scalars,
pointers, direct/indirect calls and explicit memory operations. Its workloads
construct IR directly; its memory and closure conventions are experimental.
The actual compiler connection is two reconstructed lexical algorithms.

Cranelift object generation was 10–17× faster than Clang O2 on that slice.
Fresh one-shot build/check component-cost estimates were 0.476×/0.504× on
training/held-out families. These sum component clocks and exclude supervision;
they are not directly observed complete edit-to-result wall latencies.
Repeated evaluation sometimes reverses the benefit. Cranelift retains helper
calls that Clang removes; the many-functions workload was 5.615× slower.

The matrix used 77.839s elapsed for 11.796s of child work. Batched supervision
is therefore worth a bounded first intervention. Separately, a full native
compiler sample took 142.160s and its clean Clang image build took 375.644s.
Those costs justify investigating larger architectural changes, but do not
predict the speed of a compiler built through the new IR.

## The three destinations

| Level | Destination | What would constitute completion |
| --- | --- | --- |
| **1×** | A real experimental development backend | Ordinary Bend programs automatically lower through IR to both consumers; a useful general pass works; correctness, coverage and complete iteration costs are measured |
| **10×** | A practical native backend with reusable compilation units | A declared CPU language/runtime surface, representative compiler modules, justified reuse after edits, and explicit ABI/ownership/tail contracts pass their gates |
| **100×** | A self-hosting incremental compiler-research system | The compiler builds through this backend; edits reuse unchanged work; constrained optimization search improves real code; a protected evaluation loop measures whether feeding improvements back increases research yield |

The three-hour commitment is the 1× campaign, plus the best justified pieces of
the larger levels. Full 10×/100× completion extends beyond this timebox unless
the required capabilities and evidence actually become available. A small seed
does not earn the label of a completed larger system.

## 1× — connect the real compiler, then remove demonstrated overhead

### Architecture and implementation

Reuse the existing checked/specialized `KTerm`/`KDef` boundary. Consume type,
erasure, primitive provenance and existing admission facts; do not write a second
parser or infer language semantics from generated C. Keep lowering and semantic
optimizations in Bend. The Rust consumer remains a machine-code adapter.

Initially admit a complete first-order scalar call graph: U32/Bool values,
bindings, direct calls, supported branches and explicitly supported loops or
self-tail recurrence. Expand only when an actual source program requires it.
Any unsupported reachable operation refuses the experimental route with a
specific reason. The user can explicitly choose the existing backend; there is
no invisible mixture of experimental and legacy functions.

Pay particular attention to erased parameters, argument evaluation order,
unsigned wraparound, primitive identity and return values. Phase106's masked
IR shifts are not automatically equivalent to Base shifts at large counts.
Lower that distinction correctly or refuse the operation. A well-typed IR graph
alone does not establish correct source lowering.

Build a focused driver using only the required types/lowering modules. Where
useful, capture authenticated checked graphs from real source once and replay
them for backend edits. Such replay is a lowering test, not fresh frontend
validation. Keep an end-to-end source-to-executable gate as well. Rebuilding the
entire compiler image after every IR edit would defeat the experiment.

Once real outputs expose the expected calls, add bounded pure-function inlining:
fresh local identities, exactly-once argument evaluation, preserved sequencing,
cycle rejection and explicit expansion/depth limits. Follow it with folding and
safe local cleanup. Do not inline by program name or introduce benchmark-specific
rewrites. Functions that allocate, drop values, trap or perform effects need
separate legality analysis; a guessed purity label is insufficient.

### Three-hour default allocation

| Elapsed time | Work | Exit evidence |
| --- | --- | --- |
| 0–20 min | Freeze baseline/corpus and batch supervision | Recorded complete iteration wall time; guarded per-child receipts; no more than 20 minutes spent on infrastructure |
| 20–80 min | Checked Bend → IR → C/Cranelift | Several complete real scalar programs pass both paths; unsupported graphs refuse; provenance from source to executable is recorded |
| 80–120 min | Bounded inlining and local cleanup | Retained calls demonstrably disappear, semantic controls pass, runtime/build/code-size effects are measured |
| 120–150 min | Grow coverage or take one larger-level seed | A new real program family works, or a reusable-unit/search experiment meets its declared gate |
| 150–180 min | Qualification, consolidation, report and push | Held-out results, complete cost accounting, supported-feature matrix and retained failures; no unfinished integration presented as complete |

These are time budgets, not instructions to wait. Move to the next useful task
when a milestone is complete. If integration is unexpectedly hard, spend the
extension budget on completing the real-source path. Preserve the final
30-minute consolidation reserve.

### Success criteria

- Both consumers execute the same real source programs with independent expected
  answers and agreement with the existing compiler where applicable.
- At least one actual compiler helper is lowered automatically from its checked
  definition, without rewriting its algorithm as an IR fixture.
- A frozen small corpus includes unrelated held-out source families and boundary
  inputs. Unsupported programs stay in the denominator of the coverage report.
- A practical target is a routine edit/build/check loop of **20 seconds or less**,
  and **at least 25% lower complete wall time** on a declared development workload.
  These are goals to test, not already observed gains. Report a miss honestly.
- Distinguish a successful semantic integration from a performance success. If
  the new path is correct but slower, retain the result as opt-in evidence and
  identify the cost rather than promoting it.

## 10× — make the IR own native execution and enable incremental builds

The larger opportunity is to avoid repeatedly rediscovering high-level facts
inside Clang and rebuilding code that did not change. Turn the small IR into a
usable native backend, one source-language family and compilation unit at a time.

### Destination

1. **Real runtime contracts.** Represent allocation, constructor layout, field
   ownership, retain/drop/borrow, closure environments, effect calls, static roots
   and tail transfer explicitly. Reuse existing implementation facts wherever
   possible. Do not substitute the prototype's malloc/free model for Bend's ABI.
2. **Shared semantic optimization.** Port relevant direct-worker composition,
   observer/projection and constructor-loop facts into IR operations and function
   summaries. Separate legality from profitability; C and Cranelift may use
   different budgets while sharing the correctness reasoning.
3. **Reusable units.** Give functions stable symbolic identities and code/data
   dependencies. Cache checked/lowered artifacts only at justified boundaries,
   then cache machine objects. A first implementation can rebuild a whole object
   for one changed function and relink; it need not invent a linker.
4. **Compiler modules as real workloads.** Progress from scalar helpers to a
   representative allocation-heavy compiler module. Track why remaining modules
   fail admission. Complete module boundaries are preferable to arbitrary mixtures
   of incompatible calling conventions.
5. **A deliberate development/release interface.** Expose opt-in fast and optimized
   profiles with recorded costs. Keep the existing implementation as a reference
   until the declared compatibility and performance gates pass.

Cache identities must include semantics-relevant checked input, lowering/pass
versions, dependency summaries, target/flags, runtime and call ABI, layouts,
static-data identities and backend version. Inlining makes callers depend on
callee bodies; an ordinary out-of-line call may depend only on the interface.
Global erasure/specialization/type facts can invalidate apparently local changes.
Start conservatively and prove reuse with invalidation controls.

The current native runtime uses special tail-transfer and program-dependent
metadata. Ordinary C calls do not preserve its guarantees. Choose and test an
explicit backend-local tail convention or trampoline before claiming deep or
mutual tail safety. Mixed-backend execution requires explicit tested adapters;
simple function-name matching is not an ABI bridge.

### Small 10× extensions available inside the three hours

| Seed | Incremental budget | Concrete experiment | Continue when |
| --- | ---: | --- | --- |
| **Reusable function objects** | 20–30 min | Compile three real source-derived functions, edit one, reuse the other two; change a relevant ABI/dependency and require invalidation | Outputs remain correct, expected reuse/invalidation is observed, warm machine-build work is at least 2× cheaper; report complete frontend/link costs too |
| **One real data/ownership family** | 25–40 min | Lower a small constructor/list consumer using a documented existing runtime boundary, with shared/unique-owner controls | Both consumers preserve full outputs and reclamation on the declared cases; no synthetic ownership assumption is mistaken for the production contract |
| **A compiler-kernel slice** | 20–30 min | Compile an actual closed helper group such as lexical predicates plus its caller | No handwritten algorithm reconstruction, explicit reachable-feature coverage, and measured iteration/runtime costs |

Choose at most one substantial seed at a time. Prefer reusable objects when the
call ABI is already stable; prefer a compiler-kernel slice when source integration
is the main uncertainty. Memory/ownership work is appropriate only when an exact
existing boundary makes it a bounded extension.

Completing one seed is progress toward 10×. Completing 10× requires declared CPU
coverage, real compiler-module use, tested ABI/ownership/tail behavior and reusable
builds across meaningful edits. GPU support and complete language conformance
remain separate claims unless actually implemented and measured.

## 100× — a compiler that makes its own optimization experiments cheaper

The long-term ambition is a compiler whose normal architecture supports
incremental rebuilding, interchangeable execution tiers and constrained search
over useful optimizations. Its own source becomes a large customer of that path.

### Destination

- **Self-host through the IR.** Compile the actual compiler source into a native
  executable through the new path, then use that compiler to compile the same
  source again. Establish source/tool identities, a declared fixed-point boundary,
  semantic controls and distinct B1/B2 latency measurements. Success on a compiler
  helper is not self-hosting.
- **Change-proportional experimentation.** A local compiler edit recompiles the
  affected semantic and machine-code units, reusing the remainder. Persistent
  execution or JIT/link reuse may remove repeated startup/link costs. An ambitious
  eventual target is subsecond machine-code update for a small edit and a complete
  focused validation loop in seconds. This is a hypothesis, not a forecast from
  the current small-object measurements.
- **Optimization as a budgeted process.** Start from a correct cheap output, then
  spend additional effort where profiles and expected future executions justify
  it. Search inlining budgets, local simplification schedules, proven scalar
  transformations and eventually ownership-certified choices. Record policy,
  profile, seed and work budget so output remains reproducible from explicit state.
- **Verified facts survive lowering.** Use checkable facts about types, ownership,
  effects and transformations to avoid redundant work and to constrain search.
  Formal helper laws, finite translation checks and runtime tests retain their
  distinct scopes. A collection of local laws is not a whole-compiler proof.
- **Protected research evaluation.** An agent or deterministic search proposes
  changes; an independently versioned harness builds, checks, measures and retains
  them. Candidate edits cannot weaken the oracle, alter held-outs or rewrite the
  acceptance rule. Qualification happens before the winner becomes a new tool.

This could eventually combine fast development compilation with strong optimized
code, rather than forcing one fixed optimization budget on every function and
every research iteration. Share semantic facts with JS where they genuinely
apply; do not force JS into a native memory/scheduler representation.

### Small 100× seeds available inside the three hours

**Seed A: search a real transformation budget, with measured payback.** After
the real-source path and legal inliner pass their gates, try a small frozen set
of budgets: disabled, conservative and wider bounded inlining. Use existing
folding uniformly unless a separate order experiment is declared. Select on
training sources only, then evaluate a frozen held-out set and fresh sizes.
Compare total build/check/runtime cost and code growth with a fixed policy.
Charge all attempted candidates, failed checks and search startup. Allocate
15–25 minutes only if the loop is already short. A useful continuation gate is
at least 10% held-out cycle improvement, with the observed spread supporting the
claim, and search payback within a preregistered horizon of 20 future cycles.
Otherwise retain the fixed policy and the negative result.

**Seed B: replay three local compiler edits through reusable units.** If the 10×
cache seed works, apply a frozen sequence of three independent edits to a real
compiler helper group. Compare cold rebuild and authenticated reuse with identical
correctness checks. Record checked/recompiled units, invalidations, wall/CPU time
and memory. This tests whether cost tracks changed work; it does not yet establish
an autonomous system or full self-hosting. Budget 20–30 minutes.

**Seed C: a testable borrowing summary.** If a real ownership boundary already
works, give one observer a checked or otherwise explicitly validated summary of
the owner lifetime it requires. Compare retained versus borrowed access through
the same lowering, including aliasing, escaping-value and invalid-lifetime controls.
This targets the native profile's shared-field cost. It is higher risk than A/B;
only attempt it with 30–40 minutes and a clear semantic contract. No generic
borrowing pass may be claimed from one successful fixture.

Choose one seed that existing evidence makes cheap. A persistent/JIT infrastructure
rewrite, equality-saturation engine, GPU backend or new assembly emitter is not
a default task inside this timebox. Those are possible later tools, not prerequisites
for testing the feedback hypothesis.

### What would demonstrate recursive improvement?

Three successful edits or a faster compiler do not establish accelerating research.
Compare otherwise matched campaigns with a frozen builder against campaigns that
adopt qualified improvements into their builder. Keep candidate streams/seeds,
hardware and evaluation budgets comparable; separate wall-budget and fixed-work
experiments. Count all failures, search and qualification costs.

Report experiments per hour and transferable quality gain per total budget,
including agent compute when telemetry is available. Faster compiler execution
does not accelerate the external model's inference directly. Do not invent quota
or token accounting when the service exposes none. The three-hour seed can create
the mechanism and logging; a causal acceleration claim needs further experiments.

## Adaptive execution: how we choose an extension

Use capability gates rather than enthusiasm or the clock alone:

1. **By about minute 20:** freeze baseline identities, small real-source corpus,
   expected outputs, held-outs and clocks. If batching is unfinished, use the
   existing guarded loop and proceed; infrastructure cannot consume the campaign.
2. **At the first real-source milestone, around minute 80:** require a complete
   accepted source graph through both consumers. If this fails, keep working on
   that boundary. Optimizing manually constructed substitutes does not satisfy it.
3. **Around minute 120:** check correctness, code shape and complete costs. If the
   1× milestone is healthy, choose one 10× seed or a cheap 100× budget-search seed.
   If we reach this gate early, use the saved time for a deeper extension.
4. **Before each extension:** reserve its minimum experiment budget plus the final
   30 minutes. Write one hypothesis file naming the change, expected mechanism,
   controls, stop condition and evidence paths. A newly discovered failure is a
   result; it does not authorize silently moving the goalposts.
5. **At minute 150:** stop widening interfaces. Finish the best coherent version,
   qualify it, document limitations and push. Extra ambition must leave a usable
   result, not several incomplete architectures.

A productive fast run might complete the source bridge early, remove classifier
calls, demonstrate cache reuse and run a small inlining-budget search. A harder
run might finish only a reliable source bridge plus the inliner. Both have clear
completion criteria; neither should be reported as a complete 100× system.

## Iteration, evaluation and resources

The unit of progress is **real failing program → missing general capability →
implementation → independent check → measured cost → retained result**.
Keep the following loops distinct:

| Loop | Intended frequency/budget | Work |
| --- | --- | --- |
| Focused | Each edit, target ≤20s | Changed lowering/pass, selected real inputs, full answers, verifier/refusal checks, relevant code-shape inspection |
| Comparison | Each promising candidate, about 60s | Shuffled repeated costs, unrelated families and fresh sizes; all candidate attempts retained |
| Integration | Coherent interface/pass boundary | Applicable broader source cases, unchanged-backend regressions, independent proofs for changed proved code, memory/tail/ABI controls |
| Self-hosting | Only after actual coverage permits it | Full compiler source and bootstrap boundary; not a routine test of every small pass |

Cache unchanged baselines and proof evidence by exact identity. Do not substitute
cached checking for validation of changed inputs. Batch resource supervision while
retaining per-child timing, exit, timeout, memory and output records. Keep arbitrary
compiler defects from turning one batched job into an unbounded run.

Track all five established metrics: generated-program runtime, B1 compilation
latency, B2 compilation latency, conformance and simplicity. Early slice results
do not create new B1/B2 measurements. Also record complete research-loop wall time,
machine-build time, memory, emitted bytes, IR/pass sizes, invalidation/reuse and
unsupported features. Report cold acquisition, warm reuse and runtime separately.

Root owns integration and serial guarded target scheduling. Up to two agents can
prepare independent tests/laws and audit lowering/ABI/cache dependencies in disjoint
paths. Add another bounded task only if it shortens the critical path; idle agents
do not run speculative full builds. No model escalation is assumed by this design.
Honor memory/disk floors and preserve historical evidence. No GPU is required.

## Deliverables and promotion

Keep implementation modular: shared IR and transformations, source lowering,
verifier, each consumer, and experimental evaluation have separate responsibilities.
Reuse facts from the effective selected compiler profile; a module edit must be
shown to reach the tested executable. Prefer one canonical lowering over a new
set of parallel ad hoc emitters. Remove superseded experimental duplication once
the replacement has evidence, without deleting historical results.

During execution, commit/push coherent design, implementation and evidence steps.
Write the final report under `implementation/phase107/`, with an explicit table
of attempted/completed/unattempted 1×/10×/100× items, failures, cost breakdown and
next highest-value experiment. Link user-facing usage from the compiler docs.

Keep the existing default unless actual compatibility, generated-program speed,
compiler-speed and host-interface gates justify replacement. This is an evidence
requirement, not a request for another user permission prompt. A partially supported
IR route can be useful and explicitly opt-in while the full migration continues.
