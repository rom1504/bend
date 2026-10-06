# Phase59: attribute the current compiler first-request gap

## Question and fixed scope

The user requests another information-gathering pass before optimization. Explain
why the qualified Phase58 last01 self-generated B2 takes approximately 2.6 times
the pinned TypeScript compiler's time on the existing small compiler workload.
Do not change compiler source, runtimes, the ordinary driver, the installed
release, emitted-program semantics or the upstream pin. Do not post to the PR.

The measured subject is compilation of Lexer and Evening source into JavaScript
libraries, not execution of the 45 generated-program benchmark points. The exact
primary window is compiler-module import + explicit API load + the first ordinary
library request, in a fresh process using a previously prepared private Base disk
cache. It excludes provenance checking, process launch, cache preparation and
output hashing/saving. This is not a cold filesystem measurement. Three later
requests remain a separate, still-warming statistic.

Pinned B2: `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Source: `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
Checked B1: `641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
TypeScript: `018751270e800bc222a93dad7f257083ee53a5f7`.
Node: 24.18.0, exact binary pinned by the runner. Keep existing heap/stack settings.

## Sequential evidence plan

1. Preserve current release identities, closed Phase58 evidence and the existing
   protected-file inventory. Create a fresh Phase59 tree. Derive versioned methods
   from consumed Phase58 tools without modifying their originals.
2. Prepare private B2 and TypeScript compiler inputs and full catalog oracles for
   Lexer/Evening. Use the genuine B2 emission lineage; never invent a checked B2
   sidecar. Keep private Base caches separate and byte-bound.
3. Repeat clean measurements with three rotated fresh-process rounds, two roles
   and two inputs: 12 processes, 48 compilation requests. Preserve all sequences;
   no steady-state assertion or pooling with Phase58.
4. In separate processes, capture CPU and cumulative sampled allocation from
   immediately before compiler import through ONE first compile completion.
   Stop the capture before output verification. No compiler load, request or API
   setup may precede this window in the measured process. CPU uses 1 ms sampling;
   allocation uses 128 KiB sampling including minor/major collected objects.
   First run a pilot pair, then finish both inputs if resource bounds pass.
5. Add monotonic stage clocks only in diagnostic private copies. Record import,
   API load, cache preparation/validation, discovery/elaboration, bundled checking,
   emission setup, source reach, annotation, emitted reach, layout validation,
   foreign handling and rendering. TypeScript has different boundaries: load,
   book validation and library generation. Do not call unlike stages equivalent.
   Nested intervals must be represented as inclusive and exclusive observations;
   only disjoint intervals plus residual may be summed.
6. Add narrowly scoped counters only in diagnostic copies for remaining hypotheses:
   repeated primitive table creation/lookup; generated-string use/reference scans;
   generic versus stable substitution and persistent-index copying; quantity-merge
   visits where practical. Prove exact injection inversion and require the same
   prepared complete output. Count operations without per-node logs or strings.
7. Join profiles to actual source/generated function spans. Shared dispatcher
   frames do not identify a single source member without a PC-aware counter.
   Keep sampled bytes, CPU sample/time weights, wall durations and operation
   counts separate. Disclose negative timestamp deltas and unattributed samples.
8. Publish a report and diagrams ranking opportunities by measured absolute cost,
   likely removable work, cheap falsifier and semantic boundary. Record failures
   unchanged. Verify preservation, close writers, archive the complete campaign,
   commit and push within standing authorization.

## Hypotheses and falsifiers

| Hypothesis | Observation that would support it | Falsifier / limit |
| --- | --- | --- |
| First-request overhead differs from warmed profiles | Fresh-window CPU/stage distribution differs materially from Phase58's after-warmup capture | No timing ratio may be derived from instrumented runs; old warm shares are not first-request shares |
| Base cache processing is a material first-request cost | Explicit cache read/decode/hash/span intervals consume a substantial portion of the first request | A persistent in-memory memo only helps later requests and cannot be credited to this metric |
| Emission repeats analyses in text form | High repeated render/search/scanner counts and substantial emitted-reach/library stage times | Stage names do not isolate graph work; facts must preserve actual erased/dead-expression demand |
| Immutable reconstruction creates avoidable work | Many generic substitutions/index copies relative to useful changes and existing stable-path hits | Variable absence alone does not prove safe reuse: core_rebuild may canonicalize or beta-reduce |
| Fixed primitive metadata is repeatedly allocated | Repeated 89-entry table construction in the first compile and relevant profile weight | Entry counts do not themselves predict an equivalent time saving |
| Two inputs hide different bottlenecks | Lexer and Evening disagree materially by stage or allocation | This pass does not establish universal compiler throughput or full language workload coverage |

## Resource and iteration discipline

Root alone runs targets, serially on CPU3. Each command has exactly one guard:
1 GiB Node heap, 2 GiB observed process-tree RSS limit, 4 GiB available-memory floor.
Use existing 4 MiB Node stack. Agents prepare methods, inspect source and analyze
saved data on CPU0. No concurrent heavy targets, no nested guards, no escalating
limits after a profile refusal. Preserve a failed partial capture and choose a
smaller or coarser successor if needed.

Do not rebuild or requalify the unchanged compiler, repeat the 45-point program
execution campaign, or regenerate its full compiler image just to gather these
small-request profiles. Additional measurements require a specific unresolved
question from the first results. Small negative/oracle controls apply to the
instrumentation, not a new compiler conformance claim.

## Deliverable

`implementation/phase59/README.md` will separate the clean 2.6x replication,
first-window profiles, stage diagnostics, counters and conclusions. Each proposed
optimization must identify whether it helps startup, first compilation, later
requests or full-image emission. This investigation ends with evidence and ranked
next experiments, without implementing those optimizations.
