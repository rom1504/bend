# Self-hosted compiler: current architecture and development

**Phase63 State09** combines a prepared Base world and parser indexes, shared
validated graph transport, one library lowering plan, retained arity facts and
shared host-field analysis. It also carries actual completed source fragments
instead of rediscovering them through Base. The
[compiler-request guide](compiler-request-pipeline.md) explains these mechanisms,
their source/host boundaries and their fallback contracts.

The [State09 results](../../implementation/phase63/state09-results.md) pass all
**207 workers across 23 sources, three roles and three rotated rounds**. Genuine
B2 compilation becomes faster than the Phase61 baseline in the same campaign:

| Clock | Phase61 B2 / TypeScript | State09 B2 / TypeScript |
| --- | ---: | ---: |
| Compilation alone | 2.05505× | **1.63275×** |
| Host/API import plus first compilation | 1.40665× | **1.15092×** |

These are equal-source geometric means of per-source three-run median ratios.
Each sample uses a fresh process with a prepared persistent Base cache;
preparation and full output verification are outside the clocks. They do not
measure cold OS caches or the installed checked-B1 CLI. Compilation-only parity
remains unfinished. All emitted modules pass their qualified byte oracle; this
is not a new generated-program runtime measurement or speedup claim.

**State09 is installed and verified as an equality-derived checked-B1 release.**
Legacy42, default24 including relocation, and five helper-integrity controls pass. The
[final qualification index](../../selfhost/build/phase63/final-state09/qualification.json)
separates source checks, genuine B2/B3 reproduction, output/behavior checks and
installation. Failed predecessor receipts remain preserved separately. The
[Phase61 results](../../implementation/phase61/state08-results.md) retain the
previous release's identities and completed gates; its historical benchmark
ratios remain separate from the fresh comparison above.

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
| [Architecture](architecture.md) | Dated Phase45 source organization, representations, pipeline and complexity; use backend boundaries for the current backend split. |
| [Optimization inventory](optimization-inventory.md) | Existing transformations, where they live, how generally they apply, and missing analyses. |
| [Compiler requests](compiler-request-pipeline.md) | Phase63 State09 ready world, graph transport and lowering plan, with the retained Phase61 foundation; source/host boundaries, measured request costs and fallbacks. |
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
- This release is a checked B1 derivative, not a newly established self-emitted
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
