# The Bend compiler written in Bend

The compiler in [`selfhost/`](../selfhost/README.md) implements the frontend,
dependent checker, normalizer, interpreter and JavaScript/native emitters in
Bend. JavaScript handles filesystem and process orchestration, primitives and
the public-data adapter. Ordinary compilation runs Bend code without a
TypeScript fallback.

**Phase43 checked14 is installed and verified.** Its installed API is
`222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb`.
The [Phase43 report](../implementation/phase43/README.md) records qualification
and release status. The [release manifest](../selfhost/dist/release.json)
binds the installed artifact. All 42 ordinary/relocated CLI checks, 15
postinstall gates and 227 canonical source bindings pass; the composite
postinstall closure covers 41 groups. Phase42 checked16 is the retained
comparison baseline.

Phase43 extends guarded direct execution across complete String and typed Map
operations, known scalar callback construction/application, bounded numeric
countdowns and private pair state. Exact typed admission and live dependency/host
checks preserve generic fallback. See the
[complete-operation architecture](PHASE43_DIRECT_EXECUTION.md) and the inherited
[generated-JavaScript architecture](PHASE42_GENERATED_JS.md).

The final selected frontend agrees on 3,026 main and 196 broader observations,
with zero result or extra-field differences. This is a measured conformance
scope, not proof of all language behavior or native/device coverage. The
[conformance record](../selfhost/CONFORMANCE.md) retains shared failures,
unavailable platforms and proof-trust limits. Source and API remain a checked
B1 derivative, not a new self-emitted fixed point. The upstream target remains
[`018751270e800bc222a93dad7f257083ee53a5f7`](https://github.com/bendlang/bend/tree/018751270e800bc222a93dad7f257083ee53a5f7),
after Bend 2.0.34.

The maintained production graph contains **21,440 physical Bend lines, 2,413
definitions and 70 modules**. Relative to Phase42's same graph, this adds 1,384
lines and 164 definitions. These counts exclude generated images and experiment
tools. The [accounting report](../implementation/phase43/accounting.md) records
complexity and campaign costs; the [compiler request costs](../implementation/phase43/compiler-cost.md)
are separate from generated-program speed.

The final [45-point / 23-source comparison](../implementation/phase43/results.md)
completes all 669 fresh samples on the selected image. The point-weighted
geometric ratio to TypeScript improves from 8.876 to 6.161 times, a 1.441 times
gain over checked16. Equal-family ratios improve from 11.534 to 8.544 times;
equal-source ratios improve from 11.431 to 8.434 times. There are 25 strict
median wins and 20 regressions against checked16; two points beat TypeScript.
These descriptive results retain variation and do not establish statistical
significance, typical-program speed or universal parity.

The [portable Phase43 guide](../selfhost/tools/performance/phase43/README.md)
explains reproduction. The
[current program bundle](../selfhost/tools/performance/phase43/current/manifest.json)
contains all 45 points, with reopened archive verification and byte-exact
agreement with the selected emissions. Portable timing smoke is a separate
check and is not claimed here. Use the
[validation guide](../selfhost/tools/performance/phase43/validation/README.md)
for the checked-attempt and release workflow.

## Historical release results: Phase42

[Phase42 checked16](../implementation/phase42/integration.md) passed its installed
release verification, 42 ordinary/relocated CLI checks, 15 postinstall groups and
227 canonical source bindings. Its [45-point results](../implementation/phase42/results.md)
record a point-weighted ratio of 8.86 times pinned TypeScript, with one point
faster than TypeScript. These are historical Phase42 results with Phase41 as
baseline, not Phase43 measurements. Their [portable bundle](../selfhost/tools/performance/phase42/current/manifest.json)
and raw receipts remain preserved.

## Historical measured results: Phase40

The [report](../implementation/phase40/README.md) compares generated programs
against Phase39 and pinned TypeScript. Coverage is **45 points / 23 sources**.
Forty-two comparisons retain complete checked05 timing rotations after verifying
that their modules exactly equal fresh checked06 emissions; three corrected ray
points have fresh checked06 rotations. The
[full table](../implementation/phase40/execution/report.md) preserves both
measurement and selected API identities, protocols, ranges and rejected results.
There is no pooling or claim of 45 newly timed checked06 points.

| Selected points | Phase39 / Phase40 time | Phase40 / TypeScript time |
| --- | ---: | ---: |
| List pipeline 128 / 512 | 9.973× / 13.113× | 6.516× / 4.512× |
| Tree depth 6 / 8 / 9 | 2.031× / 2.176× / 1.829× | 21.540× / 17.153× / 17.332× |
| Historical symbolic regression | 1.069× | 2.040× |

These points win all five pairs with disjoint observed ranges; tree warmup drift
remains explicit. Thirty final points have byte-identical Phase39/Phase40 modules,
so their timing changes are controls, not optimizer effects. The smallest
Mandelbrot point has a 9.68% slower median with overlapping ranges. An earlier
2.43× raytrace regression was rejected; the corrected ray modules exactly match
Phase39. These are fixed-program results, not typical Bend speed or parity.

[Normal checked request cost](../implementation/phase40/compiler-cost.md) rises
24.45% for tree and 19.09% for list (about 0.485 and 0.317 seconds); local has a
noisy 18.44% increase, while numeric is approximately unchanged. Requests remain
4.66–8.37× TypeScript on four sources. Compiler throughput and generated-program
execution are separate metrics. All 36 measured requests reproduce their expected
bytes. Separate [profiles](../implementation/phase40/profile-findings.md) show
sampled allocation per call falling 81.8% for list512 and 46.9% for tree8.

Frontend agreement covers 3,026 main + 196 broader exact observations. Backend
outcomes remain 69 pass / 8 not applicable / 4 shared failures. Fresh inherited
and new semantic owners and 154 expanded application observations pass on the
selected image. Counts overlap; [conformance](../selfhost/CONFORMANCE.md) retains
shared failures, unavailable platforms and proof-trust limits. Full backend/GPU
and independent proof validity remain unestablished; `--verdict` is unsupported.

## Historical Phase40 implementation

The existing structural frame engine now supports canonical Nat producers with
data results, proper-descendant tail transfers, and one-child constructor or
known-combiner continuations. It admits the exact built-in `List<&2,U32>` layout.
Complete typed graph/dependency proofs, original argument and child order,
intermediate tagged data, aliases and public fallback remain intact. No fusion,
new runtime representation or general optimizer IR is added. New Nat-first
admission excludes scalar results to preserve existing stronger scalar islands.
Read the [backend rules](../implementation/phase40/backend-rules.md) before
extending these boundaries.

The historical Phase40 source snapshot contains 18,863 physical / 16,156
nonblank Bend lines in 70 modules,
2,104 definitions, 71 types and 640 laws. That adds 141 lines and 17 definitions
to Phase39, with unchanged runtime/modules/types/laws. The
[admission decision](../implementation/phase40/performance-admission.md) records
this cost; the phase does not claim a line-count reduction. A roughly 2× lexer
prototype is deferred pending broader String/Char/Sigma proof support.

The portable [Phase40 loop](../selfhost/tools/performance/phase40/README.md)
provides 20/60/300/600-second presets, case selection, profiles and generated-code
comparisons without rebuilding. The five-point portable smoke passes in 20.36
seconds including runner overhead. A checked build plus 36 focused probes takes
45.845 seconds in the recorded run. Full frontend/backend and broad timing gates
belong at release boundaries, not after every experimental edit.

[Phase39](../implementation/phase39/README.md) and
[Phase37](../implementation/phase37/README.md) retain their historical baselines,
results and costs; do not multiply their ratios into a new current speedup.

## Analyzing emitted-program performance

The [generated-program performance guide](BEND-IN-BEND-PERFORMANCE.md) explains
the private region machinery, bounded admission, public entry guards and fast
validation loop. The [Phase40 campaign](../implementation/phase40/README.md)
retains rejected experiments as well as accepted mechanisms. It builds on
[Phase37 finite selectors/native casts](../implementation/phase37/README.md), the
[Phase35 regions](../implementation/phase35/README.md) and
[Phase36 guard reuse and tree production](../implementation/phase36/README.md):

- Inline selected vector producers and carry private countdown state in field
  locals, preserving complete state, aliases and ordered updates. Use a Number
  countdown only when its predecessor cannot escape or be observed.
- Extend direct regions to F32, finite Nat decisions and a final Bool loop stage,
  preserving the original public partial-application stages and delayed fields.
- Prove a bounded closed source graph so direct traversal can retain a complex
  generic leaf under one dependency guard. The residual proof excludes effects,
  arrays, foreign calls and function-valued interfaces.
- Consume eligible locally produced recursive tagged data with an explicit
  postorder stack, retaining its representation and child/combine order.
- Build eligible trees through the same explicit continuation frames. Preserve
  ordered independent children, parent scalar state and shared child identity;
  finite Nat and Bool decisions select original constructors and their fields.
- Reuse validated host and dependency checks within a scalar-input tree region
  only after proving its entire original source graph pure. Restore the previous
  proof scope on every exit and suspend it during mutable Error construction;
  graphs with native array hooks remain ineligible.
- Consume eligible finite match prefixes inside that proof without changing
  tagged data or field sharing. Require a useful selector touching non-scalar
  data before paying for a new scope; keep the outer trampoline as scope owner.
- Call the exact native F32-to-U32 helper directly inside admitted regions,
  retaining its descriptor guard and shared DataView mutation checks.

Exact-entry, host-intrinsic and live dependency checks select the fast path;
unsupported source shapes and changed public descriptors retain ordinary
execution. There is no new public record, array or Nat representation. See the
[architecture](../selfhost/docs/ARCHITECTURE.md) and the
[complete-operation architecture](PHASE43_DIRECT_EXECUTION.md) and
[generated-JavaScript architecture](PHASE42_GENERATED_JS.md) for selected
proof boundaries, the historical
[Phase40 backend rules](../implementation/phase40/backend-rules.md), and [Phase37 design](../design/phase37/README.md) for its additions.
Broad private helper inlining was rejected after regressions, so copying more
code is not itself an optimization criterion.

Use the [Phase43 validation guide](../selfhost/tools/performance/phase43/validation/README.md)
and the maintained program runner to select **20, 60, 300 or 600 second** budgets independently from case coverage.
Prepare checked compiler output once, then reuse those exact modules for short
screens. An incomplete budgeted run stays incomplete. The
[diagnostics guide](../selfhost/tools/performance/programs/DIAGNOSTICS.md) adds
separate CPU/allocation profiles, source-attributed frames, generated-code AST
statistics and side-by-side TypeScript comparisons. Profiled durations and
instrumented counters do not become speed ratios.

Keep three steps separate: saved-output mechanism experiments, actual checked
compiler output with focused controls, and broad integration/transfer. Historically,
Phase37 checked03 plus its 36 focused controls took 42.175 seconds in one supervised acquisition;
that is an observed development cost, not a rotated compiler-speed benchmark.
Do not rerun a multi-second full application for every hypothesis. Validate a
small complete component and its actual fast-path admission, then test the
unchanged application after the mechanism survives.

Historical findings remain in their own reports: the
[Phase25 analysis](../implementation/phase25/generated-code-analysis.md) established
paired generated-code diagnostics; the
[Phase28 comparison](../implementation/phase28/broader-program-comparison.md)
established the broad execution deficit; [Phases29–30](../implementation/phase30/README.md)
introduced guarded arithmetic/regions and isolated generic-runtime costs; and
[Phase32](../implementation/phase32/README.md) added direct private field vectors
and typed immediate-read bridges. Their inputs, protocols and ratios must not be
combined into a current speedup. Compiler throughput, imports, native/device
execution and self-reproduction remain separate measurements.

## Current frontend and release architecture

Phase19 checks and produces live template instances inside the ordinary checker,
removing the separate specialization traversal and fixing saved first-error
differences. It retains the exact-prefix correction for compact literal payloads
and lambda quantity presence, preventing reuse of an old prefix for a changed proof.
Phase20 corrects constructor admission and whitespace, decorator diagnostics,
and empty match heads/patterns through existing parser workers. Constructor names
are validated before alias/duplicate checks and the opening brace. Comments and
newlines can precede the brace; semicolons cannot replace it. Optional match
separators retain the pinned behavior. Phase21 gives grouped locals the first
binder's origin and constructs typed-local annotations from their original body
and returned RHS cursors. These changes reuse existing producers and workers.
Phase17’s direct lookup loop and Phase16’s compact literals, exact specialization
keys, source ranges and contextual module parsing remain.
The [development history](../implementation/phase16/full_conformance.md) retains
its separate prototypes and failures. Phase22 closes the remaining measured
frontend differences on the final main corpus and broader parser selection.

The [Phase22 contextual frontend](../implementation/phase22/contextual-conformance.md)
closes those measured gaps by carrying the actual lexical environment, module
aliases, namespace and fresh counter through parsing. It validates patterns and
completed groups before their continuations, and resolves simultaneous RHS
expressions before opening their binders. One higher/lower materializer preserves
the pin's eager-child and deferred-binder demand, including first-error order.
Phase23 retains this frontend and updates conversion and runtime compatibility.

Its load ABI2 carries completed terms through the trusted internal
`FCompletedSource` handoff. Text still enters as `FSource`; the old raw-parser and
`FParsedSource` replay APIs are retired rather than maintained as a second
frontend. Dependency ordering, canonical imported-law eligibility and checking
remain enforced at their existing boundaries. Supplied completed IR is not an
authentication mechanism. The compiler's `--checkup` command follows the pinned
textual import order, prepares Base once, checks each imported module independently
and continues after errors, including a missing-file read.

The current source retains S4's shared loader, provenance, structured checking
result and list operations. It adds upfront datatype/signature visibility while
keeping definition bodies chronological. The [architecture](../selfhost/docs/ARCHITECTURE.md)
explains these boundaries. Rejected generic binder and semantic-value experiments
remain research artifacts; neither is installed. Historical 50% and 75% source
reduction targets remain unachieved.

The [release manifest](../selfhost/dist/release.json) binds the installed compiler
to source, checked bootstrap, Base, runtime and host. The installed API is a
guarded native-equality/literal-choice derivative of a genuine checked B1. Its original checked
parent and exact transformation are preserved separately. This is not a new
self-hosting fixed point. [Conformance](../selfhost/CONFORMANCE.md) distinguishes acceptance,
proof trust, exact diagnostics, execution and unavailable platforms.

Phase23 reuses the existing graph evaluator for conversion. It compares rigid
terms before unfolding definitions, then memoizes only proved equality between
cells. Successful subtype checks never establish symmetric cell sharing; forcing can
still cache evaluated heads. This prevents
repeated traversal of shared terms: two depth-32 checks that previously exhausted
a 1 GiB heap now complete within that limit. Its historical ordinary-checking
comparison was around three times the pinned TypeScript compiler. That scope
differs from the historical Phase32 library compile requests and the current
[Phase43 compiler-cost study](../implementation/phase43/compiler-cost.md);
these ratios must not be substituted for each other.

The backend now supports all nine `Array.atomic` operations in its existing
uniform arrays, correct original/copy ordering for `Array.clone`, shared array
ownership, wide U32-to-Nat conversion, comment/string-safe foreign substitutions,
zero-length TCP refusal and the CPU scheduler row correction. This retains one
array representation. Concurrent structural reads during atomic mutation and GPU
execution are outside the demonstrated coverage.

## Run the compiler

Use Node.js 24 or newer. From the repository root:

```sh
cd selfhost
npm run verify:release
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --check-only
node cli.mjs tests/conformance/typed-smoke/base-u32.bend --run
node cli.mjs tests/conformance/typed-smoke/base-u32.bend -o program.mjs
node program.mjs
```

With Clang 14 or newer, `node cli.mjs FILE --cpu --run` compiles and executes
native CPU code. `CC` selects Clang. GPU execution requires its own SDK/hardware
and remains outside the measured coverage here. Without `--run`, the default
checks the program and interprets `main`.

`verify:release` checks installed bytes, current source/runtime/host identities,
and its genuine checked-bootstrap lineage, including exact versioned transformation
replay. It works after moving
the checkout; original bootstrap reports retain their historical paths and are
not relabeled as new proofs. This verifies integrity and lineage, not another
run of all conformance tests. Normal CLI execution does not rebuild source.

## Rebuild the default

The supplied artifact runs without TypeScript or a local upstream checkout.
Rebuilding explicitly uses the pinned upstream bootstrap tool. On a fresh
checkout, prepare it once from `selfhost/`:

```sh
mkdir -p .bootstrap
git clone https://github.com/bendlang/bend.git .bootstrap/upstream-phase23
git -C .bootstrap/upstream-phase23 checkout --detach 018751270e800bc222a93dad7f257083ee53a5f7
```

Then build and verify from `selfhost/`:

```sh
npm run build
npm run verify:release
```

The build creates a fresh immutable attempt, checks all compiler source, applies
the guarded equality profile, runs the maintained focused paired selection, then
installs the result. A failed selected gate prevents installation. To choose a
different upstream location or selection, use a development JSON config:

```sh
npm run build -- /absolute/release-config.json /absolute/new-attempt
```

Config fields and selection semantics are documented in the
[maintained workflow guide](PHASE5_DEVELOPMENT.md). Broad conformance and checked
self-reproduction are release/integration gates, not every small edit's build.
The [Phase43 report](../implementation/phase43/README.md) records current
qualification and installed-release status. The historical [Phase32 release report](../implementation/phase32/release-03.md)
retains its own evidence, limits and ordinary/relocated CLI closure.

## Work on the current source

For new compiler edits, use the [Phase 5 development workflow](PHASE5_DEVELOPMENT.md).
It builds a genuinely checked compiler, freezes source/runtime/host identities,
prepares a validated Base cache and runs selected tests against pinned TypeScript.
The workflow's `validate` command reuses that frozen compiler for fixture-only
changes; run a new build when compiler source changes. The development workflow
defaults to `checked`; release builds default to `equality`. Set `"profile":
"checked"` explicitly to build an unchanged upstream-emitted API. The equality
profile recognizes the reviewed current and historical contracts and rejects
unknown runtime, dependency or public-ABI changes. Version5 includes native
literal choices and a restricted branch transformation: one-return branches with
call-free terminal arguments become scoped blocks, with generated tail calls
using the existing trampoline message. Other branches keep their closure
boundary. Runtime bytes and public forcing wrappers stay unchanged; private
unforced message identity is outside this contract. Version6 recognizes the new Base dependency chain with the same transformation
contract. Historical versions1–5 retain exact byte replay. The normalizer seed change and broader branch
transformation failed stack controls and are excluded.

The [release manifest](../selfhost/dist/release.json) gives the installed artifact
identities. Keep experiments isolated by selecting a frozen attempt explicitly:

```sh
# From selfhost/, after creating build/dev/attempt-01 with the maintained workflow.
BEND_TYPED_API="$PWD/build/dev/attempt-01/api.mjs" \
BEND_TYPED_RUNTIME="$PWD/build/dev/attempt-01/snapshot/src/runtime.mjs" \
BEND_BASE="$PWD/.bootstrap/upstream-phase23/bend2/base.bend" \
  node build/dev/attempt-01/snapshot/tools/typed-driver.mjs \
  tests/conformance/typed-smoke/base-u32.bend --check-only
```

For an equality-profile attempt, its selected API is recorded in `attempt.json`;
the original `api.mjs` remains the checked parent. The maintained `validate`
command follows the selected artifact automatically. Full checked self-reproduction
is a separate integration gate, not a prerequisite for every small edit.

## Artifact history and advanced selection

`BEND_TYPED_API=/absolute/compiler.mjs` selects an experimental compiler API.
`BEND_BASE=/absolute/base.bend` selects Base; `BEND_TYPED_RUNTIME` supplies runtime
text for generated JavaScript and does not replace the runtime embedded in an
already generated compiler. Historical artifacts under `dist/phase1/` and
`dist/selfhost/` keep their original evidence. See the
[Phase 1 report](../implementation/phase1/report.md) for their historical limits.

The installed checked API and original bootstrap report are in
`dist/release-lineage/`. Previous defaults and their original lineage are under
`dist/release-history/`. Original reports retain historical paths; relocated
integrity checks do not manufacture new bootstrap evidence. The separately
self-emitted compiler retains its historical
[checked fixed-point proof](../implementation/phase5/final-selfhost.md).

## Full self-reproduction and component checks

`src/compiler.json` gives the ordered module list and upstream pin.
`tools/assemble.mjs` links those modules into one source file, ordering types,
laws and definitions. It does not parse user programs or implement compilation.

Compiler helpers can use typed `def` headers when their signatures need no
earlier forward declaration. Preserve parameter quantities and use the assembled
definition order when deciding whether a law is needed. Bootstrap capability
selection also currently depends on the literal laws for `j_layout_error`,
`annotate_selected` and `j_program_selected`; retain them. A declaration edit
must preserve the complete selected export set, even when focused checking tests
pass. The [S4 report](../implementation/phase7/s4-report.md) records the caught
capability loss and the corrected source-authoring trial.

The pinned upstream compiler is used explicitly as the initial bootstrap tool:

```sh
BEND_UPSTREAM=/absolute/pinned/upstream \
BEND_TYPED_API="$PWD/build/candidate-api.mjs" \
  node tools/typed-driver.mjs --bootstrap
```

This writes a checked API plus the assembled source and provenance in
`build/typed/`. Keep source, API, runtime and host snapshots immutable during
validation. Full H-to-H self-reproduction has not been rerun for the current
compiler. The advanced runner, separate from the checked release build, is:

```sh
BEND_TYPED_API="$PWD/build/candidate-api.mjs" \
BEND_SELFHOST_HEAP_MB=12288 BEND_SELFHOST_TIMEOUT=10800000 \
  node tools/conformance/selfhost.mjs \
  "$PWD/build/typed/compiler.bend" "$PWD/build/candidate-fixedpoint"
```

The runner performs two complete checked compilations. Stage 2 is emitted by the
bootstrap API; stage 3 is emitted by stage 2. Their bytes must match. The default
4 MiB JavaScript stack needs an OS stack limit of at least 8 MiB. The 12 GiB heap
ceiling is a resource limit, not a claim that every compilation needs that much
memory. Canonical paths affect foreign metadata and emitted bytes; regenerate a
local chain after relocating the checkout. A successful upstream bootstrap alone
is not evidence of self-hosting.

Run component checks from `selfhost/` with a fresh output directory:

```sh
BEND_COMPONENT_DIR="$PWD/build/components/attempt-01" npm run verify
```

The runner uses the pinned reference and current completed-source handoff. A
fresh directory preserves previous results; `BEND_COMPONENT_REPORT=/absolute/report.json`
can choose a separate report path. Backend and runtime tests are documented in
[`src/back/js/README.md`](../selfhost/src/back/js/README.md). Complete fixture
runs, frozen hosts, artifact identity and GPU gates are described in the
[conformance protocol](../selfhost/tools/conformance/README.md). For a self-emitted
API, pass `--stack-kb 4096 --heap-mb 4096` to the conformance runner so its isolated
workers receive the same large-book resource settings; parent Node flags alone
do not propagate to them.

Self-host reports now record canonical source and Base identities, the compiler,
runtime, driver and consumed host helpers, and verify them before and after each
stage. Use a fresh output directory for a new proof. Reports from the older
format cannot be resumed because they lack this provenance. Preserve the same
canonical Base path when comparing output bytes across native and JS hosts.

## Historical performance and current boundaries

The [Phase23 controlled comparison](../implementation/phase23/final-cost-screen.json)
checks the same frozen compiler source in **11.01 s**, versus **10.97 s** for
Phase22 and **3.55 s** for the new pinned TypeScript compiler: a **3.10×**
remaining gap. Process/request costs rise0.39%/0.52% in this two-sample screen;
ordinary checking remains near-neutral. Peak RSS rises7.52% against Phase22,
but is0.80% below unchanged compiler source refreshed at the new pin/profile.
Fresh processes run serially on CPU0 without competing compiler work. Each
bundle has its actual host, runtime and Base; Bend uses validated Base caches
and TypeScript checks Base. Startup and identity hashing are included in process
time. Emission and generated-program performance are excluded.

The larger gain is in shared-term conversion. Two depth-32 programs that exhausted
a 1 GiB heap in Phase22 now complete in1.36 s and1.41 s under the same cap, with
peak RSS across the two processes of123.4 MiB. Those are concurrent correctness
controls, not controlled timing ratios from the earlier failed runs.

The [Phase17 lookup worker](../implementation/phase17/find-worker.md) measured a
separate 6.55% reduction by eliminating per-miss dispatch allocations. The earlier
[Phase16 measurement](../implementation/phase16/consolidation.md) records its
separate 2.48× gain and 62.70% RSS reduction; ratios from different sources and
windows must not be multiplied into a current result.

Compact `KLiteral` nodes keep Nat, U32, F32 bits and string payloads intact until
a constructor view is needed. A separate, earlier-source census found **92.97%
fewer freshened terms**. Explicit lambda quantity presence and canonical JSON
specialization keys preserve distinctions that a compact representation must
not erase. The [architecture](../selfhost/docs/ARCHITECTURE.md) describes these
contracts, source ranges, capability negotiation and Base cache version6.

Phase23 targets 1,513 fixtures and 3,026 parse/check observations, including
15 new upstream fixtures. The [historical report](../implementation/phase23/upstream-graph-conversion.md)
records the final image's exact agreement, broader 196-case parser suite,
request histories, native/JavaScript execution and installed/relocated CLI checks.
Counts overlap; the four raw frontend failures expect errors at later emission.
Read [conformance](../selfhost/CONFORMANCE.md) for the precise verdicts and limits.

The historical Phase39 source snapshot contains **18,722 physical / 16,031 nonblank Bend lines, 2,087
definitions, 640 laws, 71 types and 70 modules**. Relative to Phase37, that adds
364 physical lines (1.98%), 322 nonblank lines and 42 definitions; module, type,
law and runtime counts remain unchanged. The
[source accounting](../implementation/phase39/source-size-checked05.json) and
[admission](../implementation/phase39/performance-admission.md) record the added
recursive rules and measured costs. These counts exclude generated images and
experiment tools; line counts do not measure conceptual complexity.
Historical 50% and 75% source reduction goals remain unachieved. Load ABI2 remains current.

Routine development uses checked B1 and 36 focused controls; reuse a frozen
attempt for fixture-only edits. The long string stays first. The selection adds
six exact upstream checks and four separate illegal-path witnesses with explicit
refusal-at-parse oracles; full diagnostics remain under the strict corpus gate.
Phase22 source11/12 checked builds plus these36 controls took roughly33–35
seconds in their observed runs; this is not a controlled loop-speed benchmark.
Keep full-source and broad frontend/backend gates for integration. Phase32's
checked acquisitions take about 40 seconds with one worker and a 1 GiB heap
setting. Its execution supervisor serializes heavy jobs and monitors the whole
process tree against RSS/deadline limits and a 2 GiB free-memory floor. Independent
[supervisor controls](../implementation/phase32/supervisor-controls.md) check
termination and child cleanup. Polling can overshoot the RSS threshold, so this
is not a hard allocation ceiling. Use these bounded runs for routine experiments;
the separate multi-gigabyte fixed-point example above is an integration task.

The [architecture](../selfhost/docs/ARCHITECTURE.md) describes the first-order
`KTerm`/`KDef` core and component responsibilities. These boundaries distinguish
the current contracts:

- Phase22 reuses `FCompletedSource` results within one invocation; their terms
  are already contextually completed. The host requires load ABI2 and its full entry-point
  set; it does not fall back to the old raw route. This remains a trusted internal
  handoff, separate from persistent Base-cache validation.
- After specialization, `book_context` prepares one immutable exact-name index
  and binder bound. Annotation, layout validation and emission reuse that full
  context while independently selecting live definitions. Native compilation
  retains its backend-specific flow.
- The emitter preserves audited native Base string operations using the same
  classification used for reachability. Names alone never grant Base provenance.
- Proven single-constructor field accessors use a direct worker while retaining
  the generic ABI and field-vector copy. Erased fields, computed arms and
  eta-short arms retain ordinary matcher behavior.
- Pure top-level matcher wrappers are cached; arm bodies and global references
  remain delayed until application. Computed matcher-producing initializers still
  run on every reference. This does not increase application-spine arity.
- Transparent Boolean-choice calls with literal lambda thunks become JavaScript
  conditionals. Structural validation, currying, evaluation order, erased slots
  and the tail-call trampoline remain part of the contract.

The [phase 1 plan](../design/phase1/faster_bootstrap.md) records the original
hypotheses. The [implementation report](../implementation/phase1/report.md)
records actual changes, measured improvements, remaining costs and validation.
Use the [explicit-artifact harness](../selfhost/tools/performance/README.md) for
new comparisons. Benchmark a rebuilt self-emitted compiler against a frozen
control with the same input, Base, cache policy, Node flags and CPU affinity.

The `selfhost-baseline-2026-09-21` tag and original archive reports preserve the
supplied implementation. Historical conformance or fixed-point evidence applies
to its recorded artifact hashes; it is never evidence for a later compiler merely
because the source files have the same names.

For historical raw/parsed-loader refactors through ABI1, the cross-version
boundary test compares complete ordered results, error precedence, cached parse
payloads, seed selection and input immutability. With matching genuinely checked
named-field APIs, its command remains, from `selfhost/`:

```sh
node --stack-size=4096 tests/frontend/shared-operations.mjs \
  /absolute/baseline/api.mjs /absolute/candidate/api.mjs /absolute/new-results
```

That test observes existing checked private bodies; it neither rewrites them nor
establishes self-reproduction. Its raw API assumptions do not validate ABI2.
Use the Phase22 report's completed-source, actual-host, request-history and
execution controls for that boundary; retained older reports keep their original
scope. S4's A02 declaration-source proof
is a genuine checked B1→H→H fixed point. Historical S4 B02 has its own
checked bootstrap and byte-identical B01 behavioral/performance evidence; A02's
full-source fixed point is not relabeled as B02's.
