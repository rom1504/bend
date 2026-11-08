# Compiler written in Bend: maintained navigation

Use the [current workflow](workflow.md) for source assembly, explicit compiler
assets, cold requests/builds, bootstrap generations and public-entry boundaries.
The authoritative Bend module tree is [`selfhost/src/`](../../selfhost/src/),
ordered by its [source manifest](../../selfhost/src/compiler.json). Different
entry profiles share this tree; generated compiler images are authenticated
artifacts rather than additional editable compiler implementations.

| Task | Guide or tool |
| --- | --- |
| Source, builds and actual N1/N2 reproduction | [Maintained workflow](workflow.md) · [build tools](../../selfhost/tools/build/) |
| Compiler latency and generated JS/C/QBE speed | [Benchmark entry, catalogs and budgets](../../selfhost/tools/bench/README.md) |
| Optional passes and development-build tradeoffs | [Bend optimization policies](optimization-policies.md) |
| Prepared values across native selector expansion | [Semantic contract](prepared-constants.md) · [Phase152 evidence](../../implementation/phase152/README.md) |
| CPU samples, physical callers, runtime events and source owners | [Profiling](PROFILING.md) · [generic profiler](../../selfhost/tools/profiler/README.md) |
| Exact stage boundaries | [Profiler stage contract](../../selfhost/tools/profiler/STAGES.md) |
| Generated JS syntax and V8 allocation/CPU profiles | [Benchmark diagnostics](../../selfhost/tools/bench/README.md#profiles-and-generated-code-inspection) |
| Compiler/target/lineage and clock definitions | [Workflow metrics](workflow.md#keep-the-metrics-separate) |
| Semantic, ownership and proof limits | [Conformance](../../selfhost/CONFORMANCE.md) · [compiler laws](COMPILER_LAWS.md) · [analysis/proof boundaries](analysis-and-proof-boundaries.md) |
| Focused/broad JS/C/QBE and public CLI regression gates | [Maintained qualification](../../selfhost/tools/conformance/qualification.md) |
| Output/disk/process lifetime | [Build retention](build-retention.md) |
| Historical findings and replay | [History tools](../../selfhost/tools/history/README.md) · [experiment frontier](../../experiments/STEERING.md) |
| Compiler research | [Architecture and techniques](../../research/compilers_architecture_and_techniques/README.md) |
| Bounded compact frontend migration | [Authoritative status](projects/compact-frontend/STATUS.md) · [Scope and completion gates](projects/compact-frontend/PLAN.md) |

The old architecture and phase guides remain research records with dated
identities and qualification scopes. They are not a second set of current build
instructions. Numerical results apply to their recorded source, image, runtime,
inputs and clock boundaries; a file move is not a new speed measurement.

Installed JS/native public selectors remain separate from the newly maintained
source and tool validation. Only an image's explicit capability/qualification
binding establishes its supported host, target, preparation mode and lineage.
See [the workflow](workflow.md#installed-commands-and-current-source) before
assuming a newly assembled profile is an installed release.
