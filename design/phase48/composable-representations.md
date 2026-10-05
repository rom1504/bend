# Phase48: efficient values across calls and public boundaries

2026-10-05. Authorized scope: design, implement and report the recommendations
following Phase47, with intermediate commits/pushes. No PR comment is authorized.
The installed baseline is Phase47 array06 at `ee54723f87db81cce64b9f762fdd116805068c8a`.
This design precedes new measurements. Estimates below are hypotheses, not results.

## Objective and baseline

Reduce generated-program execution time across independent Bend programs while
preserving the current public semantics, making the backend easier to extend,
and retaining a fast, bounded development loop. Target parity with the pinned
upstream TypeScript emitter; treat 0.5 times its execution time as an ambitious
research objective rather than a promised campaign result. Compiler latency,
generated size, source complexity and iteration time are separate measured costs.

Exact baseline API: `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
Runtime: `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
Upstream: `018751270e800bc222a93dad7f257083ee53a5f7`.
Base: `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.
Node24.18.0; all comparisons bind both API and runtime, not API alone.

The previous full45/23-source/669-sample comparison measured 2.919418 times
TypeScript by equal point and 3.995808 by equal source. Six points at roughly
50–61 times reference speed account for half the logarithmic point gap. If
those six alone reached parity, all other points unchanged, the overall ratio
would still be 1.703. This arithmetic prioritizes coverage and existing-worker
quality together; it is not a prediction or a share of total execution time.
The maintained corpus informed development and is not an untouched holdout.

Baseline source: 23,254 physical Bend lines, 19,175 code lines, 2,622 definitions,
87 types, 86 modules. Preserve the previous short-fold regression (1.93 times
its predecessor) and tree regressions in all comparisons; do not hide them by
averaging only selected wins. Historical full frontend/backend conformance
remains historical until rerun. Checked B1 qualification is not a new fixed point.

## Research lessons made concrete

The existing JIR/JW already supports first-order calls, layouts, exact SCCs,
tail loops, bounded native recursion, Number-Nat and selected callback/fusion
paths. Work must extend that investment, not claim those mechanisms as new.

- Lean LCNF: carry known functions/captures, specialize with bounded identities,
  simplify before duplicating continuations, and preserve demand when reducing
  arity. Keep branch suffixes shared rather than expanding them exponentially.
- Go: interleave call-target discovery and transformations that expose targets.
  Make operation effects and alias boundaries explicit before moving work.
- LLVM/Rust: expose aggregates, propagate fields, eliminate nonescaping shells,
  then clean up. A use/escape fact is useful only when a consumer removes work.
- V8: direct stable JS shapes let the existing machine optimizer help. Static
  allocation counts do not establish remaining machine allocations; test the
  surviving opportunity after warmup with separate diagnostic derivatives.
- Zig: explicit operand lifetimes and stable semantic summaries can reduce
  repeated compiler work. Their existence does not itself accelerate programs.
- Pinned upstream Bend: simple direct calls/native values demonstrate available
  output shapes. They do not waive selfhost public descriptor, host mutation,
  partial application, error or stack contracts.

The [source studies](../../research/compilers_architecture_and_techniques/README.md)
and [comparison](../../docs/remaining_opportunities/comparison.md) retain exact
source references. Phase47's 405-line rejected inliner removed calls but left
the intended aggregate shells. Its failure specifically motivates value
transport across private call/return boundaries, not a larger local inliner.

## Workstreams and dependencies

| ID | General mechanism | Concrete first falsifier | Conditional reach |
| --- | --- | --- | --- |
| H | Known local function target/capture transport | Renamed factory → helper → returned callback; demonstrate direct private execution and preserved prefix demand | Morning and other currently generic higher-order graphs; hypothesized 3–15x on affected paths |
| V | Shared use/layout/effect facts and private aggregate transport | Executed state tuple returned across a helper becomes scalar fields; retain throwing fields and shared list consumers | RLE/Map/records and broader private graphs; hypothesized 1.1–1.5x where material cost remains |
| A | Typed array operation effects | U32/F32 new/get/set/size/swap under exact native identities, with aliases and conversion order | Wider arrays and Evening; several-fold possible only for newly covered generic work |
| R | Owned composite-result reconstruction | Return repeated/distinct local arrays inside structural result while retaining tags, handle sharing and later mutation | Generic row and other escaping composite results; enables A, no independent multiplier |
| P | Boundary-aware profitability and admissible guard reduction | Same source across zero/small/large work; retain host mutation/reentry and capture timing | Recover regressions and short-call costs; no broad multiplier promised |

All ranges are unmeasured, overlap and may be zero or negative. No result is
accepted merely because it makes an outlier less extreme. General source/type
properties select transformations; benchmark/program names never do.

H may expose a graph to the existing first-order proof. V begins inside already
admitted graphs so admission and optimization errors remain separable. A first
handles internal arrays and scalar roots; R adds a separately justified public
boundary. P must not silently cache mutable-host permission or replace the
existing API with a sealed API. Unknown effects remain refusal boundaries.
Broader partial regions are allowed only when each crossing has an explicit
representation/effect/revalidation contract; they are not an initial shortcut.

Add only analysis facts needed by an actual transformation: value origins and
uses, finite targets/captures, representation/layout, escape and demand/effect
permissions. Distinguish discard, duplicate, move and shell-removal permission.
An unused value can still throw or cause an observable read. Bound analysis
fuel, specialization counts and code growth; refusal preserves the old path.

## Sequential campaign stages

1. **Freeze and diagnose.** Retain baseline portable outputs and exact source
   identities, protect unrelated work, derive a current coverage/cost map. Use
   data-only inspection before generating more artifacts. Separate actual
   executed entries from static markers. Commit this design first.
2. **Discriminate each mechanism.** Independent agents prepare the five slices,
   controls and saved-output ablations. Use roughly 20-minute investigation
   checkpoints with a concrete artifact or a falsified hypothesis. Root executes
   serial bounded jobs. A failed/no-gain probe narrows the design rather than
   triggering a large speculative framework.
3. **Implement and integrate sequentially.** Build immutable source snapshots,
   one independently attributable candidate per substantive change where useful.
   Run focused semantic/activation gates before timing. Preserve independent
   revisions and rejection reasons; combine only qualified compatible changes.
4. **Compose and test transfer.** Exercise renamed helpers, alternative values,
   multiple consumers, recursive callers, unused F32 arguments, returning aliases,
   and neighboring workload sizes. Verify the actual private path, including
   tree callers, rather than only the exported wrapper. Check old selected paths.
5. **Measure one final selection broadly.** Use cheap rejection/core screens
   during iteration; run the complete45-point protocol only after mechanism and
   transfer evidence survives. Compare frozen baseline/TypeScript/candidate
   within fresh runs. Report point/source/family weighting and every regression.
   Measure compiler request latency, output size and source changes separately.
6. **Qualify, publish, report.** Renew relevant maintained semantic suites,
   installation identity and ordinary/relocated CLI checks for a selected image.
   Publish portable benchmark artifacts, documentation and retained experiment
   evidence. Preserve failed/unselected attempts. Commit/push the usable compiler
   and report; explicitly record remaining gaps and rejected hypotheses.

## Correctness contract

Preserve exact source arithmetic, F32 rounding and special values, bounded Nat
errors, argument evaluation and partial-call prefix order. Keep strict native
identity/arity/erasure checks. Array effects preserve index conversion, length
reads, aliases, original public handles, callbacks and mutations. Composite
materialization preserves constructor tags/prototypes, demanded fields and
same-versus-distinct identity. No cloning of persistent shared nodes is erased
without a valid use/escape proof. Shared immutable code must not share mutable
invocation/capture/continuation state or reset the recursion budget.

Host snapshots retain their early pre-foreign-initializer boundary. Public
entry revalidates needed identities; nested/reentrant execution cannot inherit
stale permission. Unknown public objects/getters/proxies take the existing path.
Optimizing zero work must not skip an otherwise observable computation.

Tests combine independent oracles, paired exact outputs/error traces, aliases,
host mutation, reentry and structural/entry counters. Counters and profiling
remain separate from clean timing. A successful check/compiler bootstrap is
not proof of whole-language correctness or external kernel soundness.

## Parallelism and time discipline

Root owns integration, all target execution, selection, commits and publication.
Eight agents cover H, V, A, R, P, semantic validation tooling, quantitative
diagnostics and adversarial review. File ownership avoids shared source edits;
new modules integrate centrally. Agents may run data-only tools, but no target
compiler or generated-program jobs without explicit root scheduling.

Heavy jobs and clean timing are serial on CPU3, 1024MiB Node heap, 2048MiB
process-tree RSS limit and 4096MiB available-memory floor through the maintained
ExecutionGuard. This is a polling supervisor, not a hard cgroup limit. No agent
launches independent Node compilation. Data-only compression occurs after
timing. Preserve all process receipts and record overlapping intervals once.

Reuse exact frozen acquisition when emitted bytes did not change. Nominal
20/60/300/600 profiles control measurement depth, not total wall guarantees.
Core8 includes a positive-depth private tree and RLE; additional mechanism
screens cover relevant outliers. Full45 requires three serial batches with
669 fresh samples under the maintained protocol. Do not run that after every
edit. Stop an avenue when no hot consumer or safe invariant is demonstrated;
finish its report while advancing independent avenues.

## Preservation and reporting

All new raw evidence belongs under `selfhost/build/phase48`; Phase47 and older
closed trees never receive new files. Preserve the authoritative103-file
unrelated baseline and four protected historical release directories. Stage
explicit owned paths; never sweep the workspace. Every hypothesis gets a file
under `experiments/phase48` and a result linked from `implementation/phase48`.

Reports must distinguish design, diagnostic ablation, checked candidate,
measured selection and installed release. Record baseline drift and scope,
errors/timeouts, refusals, allocation observations, source/generated growth,
compiler cost, elapsed work and validation cost. A failed mechanism can be a
completed experiment; it cannot be described as an installed optimization.
No backend migration, upstream repin or PR comment is part of this campaign.
