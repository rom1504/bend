# Self-hosted compiler: current architecture and development

For installed last01, see the [Phase58 report](../../implementation/phase58/README.md),
[source accounting](../../implementation/phase58/source-complexity-last.md) and
[direct JavaScript guide](../../selfhost/docs/direct-javascript.md). The emitted
B2 freshly type-checks its complete source in 11.712 seconds and emits a
byte-identical B3 in 39.199 seconds. Its 3,055 unsafe declarations still cause
the expected proof-trust refusal. The installed package remains checked B1;
legacy compiler-image clients are retained.

The [allocation guide](compiler-allocation.md) explains six general changes and
their fallback boundaries. B1/B2 raw emissions agree on all 23 benchmark sources
and 45 observed points. The phase report separates this equality from compiler
latency, allocation and program timing. [Phase56 results](../../implementation/phase56/README.md)
remain historical; its old ratios are not assigned to last01.

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
| [Compiler allocation](compiler-allocation.md) | Six Phase58 changes: final-live-field record syntax, constructor queries, scalar residuals, literal choices, distinct dependency edges and shared recursive dispatch; proof and fallback boundaries. |
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
