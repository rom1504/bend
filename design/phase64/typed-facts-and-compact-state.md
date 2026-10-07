# Phase64: retained typed facts and compact compiler state

Authorized October 7, 2026 after Phase63 State09, commit `fd01066`.
The compiler stays implemented in Bend. This phase targets compilation time,
while preserving language behavior and generated-program performance.

## Baseline and objective

State09's controlled 23-source/three-role/three-round campaign measures genuine
B2/TypeScript compilation at **1.63275×**, and host/API import plus first
compilation at **1.15092×**. These are distinct clocks. Parity requires another
38.75% reduction in compilation time; 0.5× requires 69.38%. Neither is a forecast.
Reference: [State09 report](../../implementation/phase63/state09-results.md).

The baseline compiler, source, driver, runtime, prepared cache and full output
oracles remain immutable. Phase63's evidence tree is closed. New experiments
and failed attempts belong exclusively to `selfhost/build/phase64/`.
The pinned upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.

## Sequence and decision gates

1. Rebind existing clean, stage, CPU and allocation recipes to actual State09 B2.
   Start with Numeric, Map and held-out Lexer, plus the pinned TypeScript path.
   Measure new residual costs before assigning old profile shares to new code.
   Diagnostic counters/profilers remain separate from clean clocks.
2. Prototype additional Base completion/policy facts and shared typed backend
   facts independently. Begin with the cheapest semantic discriminator, then
   build a genuine checked B1, focused controls and short clean comparisons.
   Measure isolated changes where practical; do not multiply overlapping gains.
3. Choose an indexed Base artifact or compact representation from measured
   remaining cost and demanded data. A small correct but immaterial optimization
   is not evidence for the larger architecture. Remove unsuccessful prototypes.
4. Combine only surviving changes. Produce genuine B2, qualify self-hosting and
   program behavior, compare all 23 sources in balanced rounds, and install only
   a fully qualified version. Commit and push design, checkpoints and final report.

## Registered hypotheses

### H1: completion and emission-policy facts

Prepared Base worlds currently avoid rechecking Base but do not remove the
later original-event completion scan. `driver_todos` finalizes declarations and
recursively counts holes. Emission additionally scans for reserved names and
foreign/constructor collisions. Retain facts at an authenticated producer where
the original events and checked context are known; inspect only admitted suffix
events when their independence is proved. Start with TODO-count reuse if policy
intersection/error-order proof would make the first experiment larger.

Counts must describe the original final prefix, not elaborated values. Prefix
shadowing/fills, constructor intersections, stale API/Base/source identities,
invalid bounds, first-error order and generic public inputs retain full fallback.
Wire-schema changes require a versioned or exact API-bound admission boundary;
no optional cached value becomes a new checking certificate by assertion.

Planning hypothesis: 3–8% whole-request time, 20–40 minute first discriminator,
2–5 hours qualified implementation if the boundary remains small. Unmeasured.

### H2: one set of typed facts across consumers

State09 already retains arity and lowers each reachable definition once. The
remaining opportunity is repeated signature normalization, annotation/type
reconstruction and layout validation surrounding that lowering. Begin with
facts at an existing demand point: raw formal signatures and host signatures
instantiated with erased/absent arguments are distinct and cannot share an
unqualified cache entry. Extend toward a compact typed runtime plan only when
the new profile and exact differential tests justify the consumers removed.

Preserve dependent substitutions, affine/erased demand, terminal normalization,
malformed-telescope behavior, source origins, alias context, native/foreign
boundaries, fuel and diagnostic ordering. Public arbitrary-book query helpers
retain their meaning. No eager global memoization or second generic framework.

Planning hypothesis for the larger pipeline: 15–30% whole compilation time,
1–3 hours decisive prototype, 8–24 hours qualified implementation. A local
signature win alone does not establish this full benefit. State07's unsuccessful
typed-spine reuse is a mandatory negative reference, not a result to repeat.

### H3: selectively accessed compiled Base information

Go's indexed export data motivates retaining checked information and loading
only required bodies. Our frame3 still parses and reconstructs all its records.
First count which records are consumed by actual requests. Full-Base scans may
make selective materialization unprofitable until H1 removes them.

Any alternative must preserve mandatory malformed-data rejection and optional
accelerator fallback. Avoid moving hidden work into import/preparation or using
warm decoder throughput as a fresh-request claim. The previously rejected binary
decoder needs a materially different design and falsifier before reconsideration.
Planning hypothesis: 6–15%, 1–2 hours discriminator, 8–24 hours implementation.

### H4: compact representation and owned scratch storage

Potential costs include string tags and repeatedly hashed names, linked child
lists, annotation wrappers, linear binder lookup and persistent scratch-heap
updates. Use a small measured representation ablation before changing trusted
core values. Private per-request storage must not mutate shared prepared Base.
Dense IDs and fixed-field nodes are possible; algorithm ownership stays Bend.
Planning hypothesis: 8–20%, 2–4 hours discriminator, 16–40 hours implementation.
An owned normalization arena is a later, higher-risk extension, not prerequired.

The estimates above overlap, are not guarantees and may yield zero or negative
gain. All percentages refer to current whole compilation, not the affected stage.

## Fast loop and resource ownership

Root alone runs compiler targets, serially on CPU3 under one process-tree guard:
1 GiB Node heap, 4 MiB stack, 2 GiB RSS ceiling, 4 GiB available-memory floor.
Independent agents handle disjoint source/tooling, review and data work on CPU0.
No nested guards, concurrent compiler timing, unbounded builds or silent retries.
Freeze source and consumed tools before each run; immutable old snapshots allow
baseline measurements to overlap source editing without changing their inputs.

The inner loop is a local exact oracle, checked B1 and two/three-source screen.
The final broad campaign takes roughly 4.5 minutes after images/preparation;
full bootstrap, semantic and release matrices are integration gates, not edits'
default iteration cost. Retain commands, elapsed intervals, memory, failures and
rejections. Agent counts do not substitute for attribution of elapsed time.

## Qualification and release

Require strict checked36, source-backed export admission, relevant focused
differentials, full checked/B2 semantic gates, native controls, 45-point runtime
correctness, fresh own-source type acceptance with expected unsafe-trust refusal,
exact B2/B3 reproduction and full 23-source output comparisons. Reuse existing
reviewed factories through explicit fresh derivations; never edit consumed tools.

Prefer identical complete generated modules and runtimes. If generated code
changes, first qualify new artifacts and then run the representative execution
benchmark; changed code cannot inherit old timing evidence. Preserve previous
installed artifacts, the 110 inherited unrelated files and closed historical
evidence. Installation requires final ordinary/relocated CLI and identity checks.
No upstream migration or PR comment is authorized by this phase.

## Research grounding

Go's [export format](https://github.com/golang/go/blob/go1.26.0/src/cmd/compile/README.md#7a-export),
[dense SSA values](https://go.dev/src/cmd/compile/internal/ssa/value.go) and
[reusable storage](https://go.dev/src/cmd/compile/internal/ssa/cache.go) motivate
retained facts and cheaper data access. Bend's dependent normalization and affine
semantics require independent justification. Existing research and rejected
experiments remain in `research/compilers_architecture_and_techniques/` and the
Phase61–63 reports. No Go-to-Bend speed multiplier is inferred.
