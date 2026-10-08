# Self-hosted compiler: current architecture and development

The active source targets upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
The [Phase66 report](../../implementation/phase66/README.md) is the current
status and five-metric index. Read [the compiler guide](../BEND-IN-BEND.md) for
usage, the [direct guide](../../selfhost/docs/direct-javascript.md) for the
new namespace/effect interfaces, and [prepared Base artifacts](prepared-base-artifacts.md)
for new-Base invalidation and optional-product qualification.

## Historical Phase64 installed baseline

**Phase64 State09 was installed and verified at that checkpoint.** The release extends the
prepared-world/lowering-plan architecture with original Base TODO counts, an
exact checked-output bound, retained host signatures, omitted discarded argument
rendering and indexed frame4 transport. The
[request pipeline](compiler-request-pipeline.md#phase64-state09-retained-facts-and-indexed-transport)
and [prepared Base guide](prepared-base-artifacts.md) explain the boundaries.

The [Phase64 State09 comparison](../../implementation/phase64/state09-results.md)
passes **207 exact-output workers across 23 sources, three roles and three
rotated rounds**. Genuine-B2 ratios in the same campaign are:

| Clock | Phase63 State09 / TypeScript | Phase64 State09 / TypeScript | Time reduction |
| --- | ---: | ---: | ---: |
| Compilation alone | 1.64387× | **1.43894×** | 12.47% |
| Host/API import plus first compilation | 1.18920× | **1.06173×** | 10.72% |

All 23 sources improve on both clocks. These are equal-source geometric means
of per-source three-run median ratios, using fresh processes with prepared
persistent Base caches. Preparation and full output verification are outside the
clocks. They do not measure cold OS caches, the installed checked-B1 CLI or
compiled-program execution. Aggregate compilation parity remains unfinished.
The [previous campaign](../../implementation/phase63/state09-results.md) retains
its own ratios; its measurements are not combined with this comparison.

The compiler has **28,279 physical / 23,199 code lines across 114 Bend modules**:
164 more physical lines, 19 more definitions and one more type than Phase63.
This is not a reduction in source complexity. Runtime and host-tool accounting
remain separate from the compiler's Bend modules.

The packaged compiler is equality-derived checked B1 (`a2f8b021…`); the measured
genuine B2 (`b09fe54a…`) is separately qualified. Full checked suites and the B2
source96/numeric34/composition18/overapplication2 matrix pass, with native3 and
runtime45 controls. B2 freshly type-checks all 3,254 unsafe definitions in
11.90 seconds and reproduces an identical **4,040,799-byte B3** in 33.42 seconds.
These are diagnostic gate durations. Expected unsafe proof-trust refusal remains;
type acceptance and a fixed point do not establish mathematical proof validity.

Install, verification before and after CLI testing, legacy42, default24 including
relocation, and five helper-integrity controls pass. The
[qualification index](../../implementation/phase64/evidence/state09-qualification.json),
[release receipt](../../implementation/phase64/evidence/state09-release.json) and
[final results](../../implementation/phase64/state09-results.md) retain their
separate evidence. [Phase63](../../implementation/phase63/state09-results.md) and
[Phase61](../../implementation/phase61/state08-results.md) are historical releases.

The [allocation guide](compiler-allocation.md) describes six retained Phase58
changes and their fallback boundaries. Historical
[Phase58 generated-program timing](../../implementation/phase58/program-performance.md)
applies only to retained identical artifacts. Compiler latency, generated-program
execution, checked B1 packaging and self-reproduction are distinct results.

The [Phase51 V8-guided runtime](v8-guided-runtime.md) describes the retained
compatibility mode. The source survey below remains a dated Phase45 baseline;
its counts and timings are historical.

For the current separation between shared checking, backend facts, direct
JavaScript, legacy JavaScript and native C, read
[Backend boundaries](backend-boundaries.md). The
[compiler-image guide](compiler-image-generation.md) explains direct image
generation, its fast validation loop and the remaining bootstrap gates. It distinguishes implemented source
from the proposed extension point for LLVM or assembly. The legacy IR is not a
target-neutral compiler IR.

This survey describes the selected **Phase45 worker23** compiler at repository
commit `55e5b79dc9ac3e02436a712e34722f2eb519e5df`, inspected on 2026-10-04.
It separates implemented behavior, historical experiments and proposed work.
The survey changes documentation only; it does not qualify a new compiler.

| Document | Read it for |
| --- | --- |
| [Backend boundaries](backend-boundaries.md) | Shared checked core and facts, backend-local representations, retained native contracts, and the incremental runtime-IR proposal. |
| [Direct JavaScript backend](../../selfhost/docs/direct-javascript.md) | Current callable/data interface, ordered prefix/value lowering, 4,096-definition analysis bound and qualification limits. |
| [Native value lowering](native-value-lowering.md) | Phase68 working09 shared arity, local values, ordinary C workers, admission and fallback; separate from the installed Phase67 release. |
| [Architecture](architecture.md) | Dated Phase45 source organization, representations, pipeline and complexity; use backend boundaries for the current backend split. |
| [Optimization inventory](optimization-inventory.md) | Existing transformations, where they live, how generally they apply, and missing analyses. |
| [Compiler requests](compiler-request-pipeline.md) | Phase64 retained facts and frame4 transport, with the Phase63 lowering plan and Phase61 foundation; source/host boundaries, measured request costs and fallbacks. |
| [Prepared Base artifacts](prepared-base-artifacts.md) | Phase64 State09: original TODO and checked-output facts, frame4 layout, complete validation, identity coupling, fallback and timing boundaries. |
| [Compiler allocation](compiler-allocation.md) | Six retained Phase58 changes: final-live-field record syntax, constructor queries, scalar residuals, literal choices, distinct dependency edges and shared recursive dispatch; proof and fallback boundaries. |
| [Private array regions](private-array-regions.md) | Phase47 closed-array representation, ordered operations, host guards and research limits; separate from release qualification. |
| [Phase48 representations](phase48-representations.md) | RNFA04 mechanisms, composition controls and original-path mutation contracts; the phase report records release status. |
| [V8-guided runtime](v8-guided-runtime.md) | Phase51 small IO helper, same-entry String proof, and the warmup/inlining limits. |
| [Prior experiments](prior-experiments.md) | What we already tried, what failed, and the genuinely new scope of familiar ideas. |
| [Parallel validation plan](parallel-validation.md) | Bounded parallel correctness work, isolated timings, artifact reuse and better accounting. |
| [External compiler research](../../research/compilers_architecture_and_techniques/README.md) | Source-based Rust, Go, Zig, LLVM, V8, Lean and pinned Bend TypeScript comparisons. |
| [Remaining opportunities](../remaining_opportunities/README.md) | Cross-compiler comparison, ranked proposals and the next discriminating experiments. |
| [Backend strategy](../remaining_opportunities/backend-strategy.md) | JavaScript, existing C/Clang, direct LLVM IR and custom machine-code tradeoffs. |

For everyday usage, use the [compiler guide](../BEND-IN-BEND.md). For exact
legacy JavaScript node and ABI contracts, use the maintained
[legacy JavaScript IR guide](../../selfhost/docs/JAVASCRIPT_IR.md). The survey explains
the architecture; it does not replace those operational references.

## Snapshot and evidence boundaries

- The compiler is written in Bend. The host shell provides files/processes and
  ABI adaptation; ordinary compilation has no TypeScript fallback.
- This historical Phase45 release is a checked B1 derivative, not a newly established self-emitted
  fixed point. Its upstream target remains
  `018751270e800bc222a93dad7f257083ee53a5f7`.
- The manifest-listed Bend source graph has 23,007 physical lines, 18,983 code
  lines, 2,594 definitions, 87 types and 85 modules. Runtimes, tools and generated
  images are separate; declaration counts are not conceptual complexity.
- The maintained execution corpus has 45 points from 23 source programs.
  Selected output takes **3.0787×** pinned TypeScript time with equal-point
  weighting and **4.1467×** with equal-source weighting. This corpus informed
  optimization and is not an untouched holdout or every possible Bend program.
- Compiler requests are a different metric: the four Phase45 probes regressed
  1.20–28.55% against Phase44. The source survey does not establish their cause.
- Shared conformance failures, proof-verifier limitations and untested GPU
  execution remain explicit in the validation record.

See the [release report](../../implementation/phase45/README.md),
[execution measurements](../../implementation/phase45/results.md),
[compiler costs](../../implementation/phase45/compiler-cost.md) and
[conformance record](../../selfhost/CONFORMANCE.md) for their distinct scopes.

## Maintaining this survey

After a compiler change, update the implemented inventory and its source symbols.
Move a proposal into the implemented category only with the checked artifact and
scoped validation evidence. Preserve old research pins and experiment outcomes.
Do not rewrite historical ratios as if they were measured on the new artifact.

The [parallelization document](parallel-validation.md) is a proposal: the current
production policy remains serial until its scheduler/resource/isolation pilot is
implemented and validated. A larger `jobs` value alone is not that implementation.

For the initial architecture-survey commit `8961ca3`, the source survey and recommendations received
independent technical review. The manifest counts were reproduced, all 328 local
links across the 16 new Markdown documents resolved, and whitespace/reference
checks passed. External chapters identify their actual inspected revisions and
source sections. No compiler build, generated-program execution or fresh
performance/conformance result is claimed by those documentation checks.
