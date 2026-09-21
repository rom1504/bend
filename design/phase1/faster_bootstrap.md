# Phase 1: a much faster Bend compiler written in Bend

Status: proposed implementation plan; no optimization is implemented by this document.

Code reviewed: `88d509f`, on `selfhost/bootstrap`, with upstream pinned at
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`. Paths below are relative to the repository
root. The compiler sources remain Bend; JavaScript continues to provide the host
shell and primitive runtime. Ordinary compilation must not delegate compiler
algorithms to the upstream TypeScript implementation.

## 1. Decision and success criteria

We will optimize three things separately: repeated work in the driver, the cost
of running generated Bend code, and the compiler's own algorithms. We will retain
the frozen baseline and promote changes individually, with correctness evidence.
A faster small CLI invocation is useful, but the principal bootstrap target is a
**complete checked compilation of the compiler's assembled source**, followed by
a successful checked fixed point.

Initial engineering targets, not predicted results:

- At least **3× lower median self-emitted pipeline time** on each of the three
  existing uncached JS workloads: Base/U32, tree/IO, and list sort.
- At least **2× lower complete self-compilation time** against a newly reproduced
  local control with the same source, cache policy and resource limits. A 10×
  full-build improvement is a stretch target requiring execution and algorithmic
  improvements; driver caching alone cannot deliver it.
- No unexplained correctness change, timeout increase, or material regression in
  cached CLI latency, declaration scaling, peak RSS, or generated-code size.
  Investigate regressions above 10%; do not accept them by averaging across cases.
- A newly identified self-emitted artifact passes the compatibility gates and
  reproduces its own bytes from the same frozen source and path layout.

These targets are planning thresholds. Revisit their feasibility after profiling;
never change workloads, omit phases, or weaken the checker to meet them.

## 2. What the evidence actually says

### Controlled local measurements

The [baseline report](../../selfhost/docs/PERFORMANCE-BASELINE.md) and
[raw samples](../../selfhost/benchmarks/baseline-2026-09-21.json) identify all inputs
and artifacts. Three fresh processes per implementation ran serially on one
logical CPU with Node 24.18.0, a 4 MB JS stack and a 4 GB old-space ceiling.
Base caching was disabled. Imports/startup and generated-program execution were
excluded from the following median pipeline times:

| Workload | Upstream TypeScript | Upstream-emitted Bend API | Self-emitted Bend API |
|---|---:|---:|---:|
| Tiny datatype, check | 0.006 s | 0.049 s | 0.110 s |
| 256 declarations, check | 0.019 s | 1.363 s | 4.065 s |
| Base/U32, JS | 0.358 s | 8.031 s | 43.057 s |
| Tree/IO, JS | 0.359 s | 8.316 s | 44.495 s |
| List sort, JS | 0.446 s | 9.460 s | 50.366 s |

All 45 samples passed; all 27 generated programs produced the expected output.
The three rejection probes also passed. This is useful performance evidence on
selected workloads, not proof of complete compiler equivalence.

The tree's self-emitted time includes 8.488 s in discovery's `f_parse`, 11.900 s
in `f_load_graph`, 16.063 s in `check_book`, and 4.717 s across public `j_stops`
calls. The roughly 5.35× gap between the two Bend artifacts motivates studying
execution overhead. It does **not** attribute that entire gap to the runtime:
the artifacts have different generated code and host ABIs as well.

### Full self-rebuild evidence is different

The archived [seed verification report](../../selfhost/dist/selfhost/seed-verification/report.json)
records a successful 2,950.443 s checked self-emission, using the seeded loader,
validated-prefix checking, a 12 GB heap ceiling and a different historical host.
It is not a controlled comparison with our current machine or the 4 GB benchmark.
Its invocation timings nevertheless identify where a full build spent time:

| Entry point | Recorded invocation time | Share of recorded total |
|---|---:|---:|
| `annotate_selected` | 843.952 s | 28.6% |
| `check_from_exact_prefix` | 802.323 s | 27.2% |
| `j_library_selected` | 744.567 s | 25.2% |
| `j_layout_error` | 232.117 s | 7.9% |
| `f_load_graph_seed` | 92.960 s | 3.2% |
| `reach_book` | 76.118 s | 2.6% |

The first four account for about **89%** of that run. Removing discovery parsing
entirely would save only its recorded 36.859 s, about 1.2%. Reusing declaration
names could also avoid the 46.497 s `f_main_names` parse. These are worthwhile,
but they cannot explain an order-of-magnitude bootstrap improvement.

For the small tree, even eliminating all measured discovery parsing and all
`j_stops` work would yield only approximately `44.495 / (44.495 - 8.488 - 4.717)
= 1.42×`. Actual savings would be smaller because some work must remain. We must
improve the expensive compiler computations and the code executing them.

## 3. Existing optimizations we must preserve

The implementation is already substantially optimized. This plan does not
propose rediscovering these mechanisms:

- [The name index](../../selfhost/src/core/index.bend) is a persistent 32-bit hash
  trie with exact collision buckets. `lookup` uses it when the book starts with a
  `BookCache`. It preserves first-match semantics and old snapshots.
- [The loader seed](../../selfhost/src/load/seed.bend) verifies Base path and text;
  [prefix checking](../../selfhost/src/check/prefix.bend) compares complete IR
  definitions and falls back to full checking on mismatch.
- [The compiler ABI](../../selfhost/tools/compiler-abi.mjs) already passes compiler
  graphs through lazy read-only views and unwraps them without copying. Arbitrary
  host-created inputs are re-encoded per call so later host mutations remain
  visible. Reintroducing eager whole-graph conversion would revive the recorded
  annotation OOM failure.
- [Strong normalization](../../selfhost/src/core/graph.bend) already has shared
  lazy cells and a persistent memo heap. Freshening and portions of normalization
  already use explicit work stacks.
- [The JS emitter](../../selfhost/src/back/js/emit.bend) already uses lexical binder
  variables, batches applications up to proven leading-lambda arity, caches
  leading-lambda globals, and uses closure factories beyond nesting depth 32.
  [Historical patches](../../selfhost/src/back/js/experiments/README.md) are already
  incorporated; they are evidence, not a queue of unapplied optimizations.
- [The runtime](../../selfhost/src/runtime/js/core.mjs) already avoids some bounce
  allocations and unnecessary pending-frame arrays. Its remaining argument copy
  is intentional: the public ABI permits a callee to mutate its argument vector.

## 4. Milestone A — make candidate comparisons trustworthy

Do this before changing compiler algorithms. Preserve the baseline tag
`selfhost-baseline-2026-09-21` and its reports.

The [current runner](../../selfhost/tools/performance/run.py) refuses any change
to archive-manifest files, and its [worker](../../selfhost/tools/performance/worker.mjs)
hardcodes the two supplied API paths. It is an immutable baseline recorder, not
yet a candidate comparison framework. Extend the framework in a separate commit:

1. Accept explicit control/candidate API, runtime, driver and ABI paths from a
   recorded configuration. Candidate source manifests are generated from their
   actual inputs; do not rewrite the historical archive manifest to make its
   verification pass. Preserve clean, pinned upstream verification.
2. Keep a source snapshot and hashes for the assembled compiler, module manifest,
   emitted compiler, embedded runtime, output runtime, host, Base and workload.
   Parameterize workloads independently from the implementation checkout so
   controls and candidates read identical files and canonical paths.
3. Measure three independent modes: **full work without Base reuse**, **first CLI
   use with an empty isolated Base cache**, and **fresh-process CLI use with an
   explicitly primed cache**. The current no-cache adapter does not exercise
   first-use cache construction. Add a separate warm-JIT API experiment where
   needed; label its warmups and do not mix it with fresh-process latency.
4. Add parser-only, load, check, annotate, layout and library-emission workloads,
   plus full-source compilation. Use selected real modules and assembled source;
   add 64/256/1,024/4,096 declaration scaling and higher-order/match-heavy cases.
   A single 256-declaration point cannot establish a complexity class.
5. Collect public-call counts as well as time, CPU profiles, allocation/GC
   evidence and ABI encode/invoke/decode counters. Profile runs are diagnostic
   runs; performance acceptance uses unprofiled samples. Time shared-context
   construction and cache priming somewhere explicit, never make them disappear.
6. For inexpensive cases use at least seven paired samples with balanced ordering
   and report medians, ranges and paired ratios. For full builds use one control
   and candidate initially, then repeat a proposed winner; report the smaller
   sample count and any timeout or resource failure. Use the same flags within
   each comparison, with a separately declared full-build resource budget.

Keep TypeScript as the external control. Build each candidate source both through
upstream and through the Bend emitter where feasible: an improvement in both
suggests an algorithmic benefit; an improvement confined to the self-emitted
artifact points toward generation/runtime/ABI effects. This is a diagnostic
factorization, not a perfect isolation of every variable.

## 5. Milestone B — remove repeated driver work

### B1. Parse each physical source once per compilation

In [the driver](../../selfhost/tools/typed-driver.mjs), `discoverSources` already
retains each `FResult` in its `physical` map, but returns only source text and
paths. [Graph loading](../../selfhost/src/load/graph.bend), through
`f_graph_cached`, calls `f_parse` again. `f_main_names` parses the main source yet
again when a declaration report is requested.

Add a parsed-source input alongside the existing `FSource` representation, with
canonical path, exact text identity, raw unqualified parse result and import/main
name metadata. The host carries these opaque compiler values back through the
lazy ABI; Bend code still resolves imports, qualifies names, elaborates,
validates and freshens. Keep existing entry points as compatibility wrappers.
Avoid adding a second JavaScript parser or scanning imports with regexes.

The graph loader must consume the same raw parse result at the same semantic
point as before. Never reuse a qualified or freshened result across namespaces.
Retain cycle detection, one namespace per physical source, import order, foreign
path resolution, source origins and first-error behavior. Scope this cache to
one compilation initially; cross-request invalidation is a separate problem.

Acceptance: identical loaded books, binder IDs, main names and source diagnostics
for seeded/unseeded, alias, repeated-import, cycle, relative-path and FFI fixtures;
one parse per distinct non-seeded physical file on the successful path. Error
rendering may legitimately request extra provenance work and must be counted.

### B2. Reuse emission roots and stop sets

`inspect` asks `j_stops` for the full specialized context, then for the selected
book, then for the full context again during layout validation. These are not
three identical arguments. Initially memoize the full-context result and preserve
a separately computed selected result. A later change may use one full stop set
throughout only after proving that the selected-stop intersection is equivalent
for annotation. Cache roots by both context and executable/library mode.

Do not reuse native stop sets for JS. Keep the full context for type lookup even
when emitted definitions are pruned. Use the same explicit selection metadata in
reachability, annotation and layout validation, and verify emitted bytes remain
unchanged for this host-only optimization.

### B3. Avoid redundant first-use Base work

With no cache present, `inspect` first loads the whole graph and subsequently
calls `prepareBase`, which loads and checks Base again before prefix checking.
Measure this distinct path. A parsed-source handoff can reuse raw Base parsing;
then consider preparing and injecting a validated Base seed once, or extracting
and validating the exact Base prefix already loaded. Do not reorder user-visible
load errors or assume that Base is always the first declarations in a graph.

Preserve exact-prefix comparison, fallback behavior and cache invalidation on
compiler/Base/path/schema changes. Include runtime/ABI identity in a new cache
schema when those independently influence representation or checking behavior.
A JSON checksum detects corruption, not the truth of a type-check verdict; do not
broaden the existing local-cache trust boundary or bypass compiler validation.

## 6. Milestone C — use the primitive runtime we already have

There is a concrete dispatch mismatch worth testing before a large backend
rewrite. [Runtime Base support](../../selfhost/src/runtime/js/base.mjs) installs
native `String.contains`, `String.reverse`, `List.reverse` and many other helpers.
The emitter's `j_intrinsic` list is narrower. `j_def` preserves an installed
runtime definition only when both `db(d)` and `j_intrinsic(dn(d))` hold.

`String.contains` is absent from that list. The actual
[self-emitted seed](../../selfhost/dist/selfhost/seed-verification/seed.mjs)
contains an unguarded `G["String.contains"]=...` assignment replacing the native
helper with generated Bend code. Meanwhile `j_intrinsic` itself implements
membership using `String.contains` over a long delimiter-separated string. Thus
building stop sets repeatedly invokes precisely this slower generated path.
This is an observed dispatch fact; its contribution inside other phases still
needs profiling.

Audit `String.contains` first, then additional hot helpers individually. Require
exact agreement with pinned Base, including empty strings, non-BMP text, invalid
host strings where accepted by the ABI, numeric limits and error behavior.
A JavaScript helper's existence does not establish semantic compatibility.

Use one audited primitive classification for emission preservation, reachability
stops and annotation/layout decisions. It can be a Bend table with generated
consistency tests against runtime registrations; the host must not decide Bend
semantics. Preserve native/Base provenance: a user definition with the same name
must not silently become a primitive. Keep nonapproved helpers on the Bend path.
A faster exact membership implementation is a separate small candidate, useful
if long-string scanning remains costly after dispatch is corrected.

Acceptance: primitive differential tests, user-override and constructor-provenance
fixtures, unchanged phase reachability, full output checks, and a rebuilt
self-emitted compiler demonstrating that the intended native helper survives.

## 7. Milestone D — keep a prepared context through the backend

Indexing exists but its benefit is not carried through the entire pipeline:

- `specialize_book` canonicalizes into a list; `sp_finish` returns that list after
  removing its temporary `BookBound` stamp. It does not return a `BookCache`.
- `annotate_selected` builds an indexed context internally, annotates selected
  definitions and returns only those definitions.
- `j_layout_error` builds indexes again for the context and selected definitions.
- `j_library_selected` and `j_program_selected` take the original specialized
  context from the driver. They do not call `book_cached`. Their `lookup` calls
  consequently fall back to list scanning in this normal driver path.
- `j_find_ctor` and reachability's `kr_parent` scan definition/constructor lists;
  the existing top-level name index does not answer constructor-owner queries.

Introduce a **Bend-owned prepared context for a fixed specialized book**. Reuse
the existing exact-name index first, add constructor-to-owner information and a
fresh-binder bound, and retain the complete ordered book separately. Add internal
entry points that consume this context without rebuilding it. Let compatibility
wrappers construct it when called independently.

Stage the change: first index the emitter's context once and measure it, then
share construction across annotation/layout/emission, then add constructor
lookup and dependency-set improvements. Account for index construction and
retained memory. Avoid nested `BookCache` sentinels; never include index nodes as
source declarations, emitted schemas or compiler roots. A zero bound used for a
lookup-only table is not a valid bound for normalization/freshening.

Keep old context versions immutable. Rebuild or explicitly update indexes after
specialization adds/replaces definitions; never key a cache only by a name across
books. Preserve first-match behavior, exact hash-collision handling, definition
order and the full type context. The source event list used for checking remains
separate from the final canonical book.

Acceptance: [index tests](../../selfhost/tests/index.mjs), constructor ownership,
reachability and layout cases; byte-identical output for an index-only change;
per-phase lookup/index-build counters; improved scaling and full-source emission.
The 744.567 s historical emission cost makes this a priority experiment, not a
promise that indexing alone recovers all of it.

## 8. Milestone E — reduce generated-code execution overhead

The port currently emits calls through `get(G, name)`, `call`/`jump`, boxed
function records, argument arrays, and `apply`/`force`. `apply` handles partial
application and oversaturation generically. Top-level matching functions can
remain zero-arity initializer thunks: `j_lambda_count` only counts leading `Lam`
nodes, while a leading `Mat` introduces another application stage.

For example, the seed's `kc` has one initial lambda followed by a matcher, and
`j_stops` initializes a matcher through a zero-arity thunk. Their generated uses
contain chains of generic applications. This gives concrete profiling targets
across parsing, checking, annotation and emission. Upstream's
[`js_call`](../../bend2/comp.ts) provides a useful design reference: it emits
known calls and primitive expressions with more specific calling conventions.
We will implement the corresponding optimization in our Bend backend.

### E1. Cheap branch and known-call lowering

Start with a compiler-proven internal call class. Recognize transparent choice
functions such as `kc`/`f_choose` by validated definition identity/body, never by
an unqualified spelling. Lower eligible selection to a JS conditional that
executes only the chosen thunk, retaining evaluation of the condition and any
observable argument construction in the original order.

Add a direct worker entry for statically known, fully saturated functions where
the application stages have been proven safe to combine. Keep a generic wrapper
for exported APIs, partial applications, dynamic callees, foreign calls and
unproven cases. Build on current application-spine analysis; do not simply use
the declared type's argument count. An intermediate curried application may
compute, throw or perform an effect before the next argument is evaluated.

Keep tail calls stack-safe. Direct ordinary JS recursion is not a replacement
for the trampoline. Optimize self-tail calls to loops where proven, and retain
bounce/continuation handling for mutual and higher-order recursion. Preserve
forward references and global initialization ordering; do not resolve a `G`
entry before its definition is installed.

### E2. Specialize internal representations only where measured

If allocation profiles support it, add owned internal call paths or small-arity
workers that avoid argument-vector copies and repeated function-box creation.
The public `call`/`apply` contract must retain isolation: the
[apply tests](../../selfhost/src/runtime/js/test-apply.mjs) intentionally mutate
callee arrays, source arrays and oversaturated arguments. Deleting `args.slice()`
from public `apply` is incorrect. An internal no-copy path needs a proven
ownership boundary and must not expose buffers to foreign/public callees.

Preserve null ABI slots for erased arguments without evaluating erased
expressions, partial/oversaturated application behavior, constructor field
forcing order, foreign marshalling, and computed-global reevaluation. Leading
lambda reuse is already implemented; globally memoizing every initializer would
break the [initializer tests](../../selfhost/src/back/js/test-global-initializers.mjs).
Keep the deep-closure path and its parser-depth protection.

Acceptance: backend/runtime/foreign tests and deep closures, parser output
identity, both cold and warm profiles, smaller allocation counts, and measured
improvements in newly emitted compiler artifacts. Reject generated-code bloat
that merely trades execution time for prohibitive parsing or memory costs.

## 9. Milestone F — stop reconstructing the same compiler facts

This follows the low-risk changes and profiles. It matters most for full rebuilds.

### F1. Annotation, layouts and emission

[Annotation](../../selfhost/src/check/annotate.bend) returns `Ann`-wrapped terms,
but computing those annotations calls `ka_type`, `wnf`, `subst` and `core_beta`
repeatedly. It does not repeat full kernel validation. The emitter's `j_type`
already uses an `Ann` node's type when present; the problem is not simply “types
are thrown away everywhere.” Layout validation and emission still normalize
those types and rediscover constructor telescopes, application arities and
representations.

Count these operations by definition and node before adding caches. Then make
annotation produce, or feed a separate Bend lowering pass that produces, a
backend plan with the exact facts consumers need: application stages, erased
slots, constructor layout/provenance, field descriptors and closure captures.
Layout validation checks this plan, and emission prints it without re-inferring
its facts. Keep source terms and provenance for diagnostics; retain the old
pipeline as a differential oracle while moving one node form at a time.

Start with repeated application spines and constructor facts, not a wholesale
new IR. Share work from `j_l_walk` and `j_expr` only when profiling shows repeated
traversals matter. If string assembly/flattening is hot, test a Bend chunk builder
that joins once; do not assume every `++` is a full string copy in the JS engine.

Any type/normal-form memo must include the immutable book version and relevant
binder/context/substitution state. Keying a dependent term's type only by its
printed text, name, or term identity is insufficient across contexts. Scope
memoization to a phase/request initially, and measure retained memory. Keep the
existing graph reducer's sharing rather than adding a second unbounded heap.

### F2. Checker event processing and book maintenance

[The checker](../../selfhost/src/check/kernel.bend) has indexed lookup, but
`book_put` updates the index **and** calls `index_remove` over the persistent
list. Successful declaration processing normally installs a declared form and
then a filled form. `signature_mode` searches later events, and
`constructor_exists` scans previous declarations. Specialization's `sp_canonical`
and `sp_put` also filter lists through `book_without`.

These operations provide specific possible quadratic costs as declaration counts
grow. Verify them with counters and scaling inputs before redesigning the book.
Separate the lookup environment, declaration/event order, outstanding laws and
constructor ownership instead of rebuilding a canonical list on every update.
Materialize an ordered canonical book at a deliberate boundary. Preserve the
first-visible declaration and law/fill rules, recursion checks, quantities,
template instances, and first-error order. If `signature_mode` gets a lookahead
index, it must preserve which later event the old list lookup selected; it must
not make future definitions visible to ordinary type checking.

Memoizing checker acceptance across changed books, parallelizing sequential
checks, or using hashes as evidence of validity are outside this phase. Rewrite
remaining non-tail scans such as `count_open` only with equivalent traversal and
stack tests; raising stack/heap limits is not an algorithmic speedup.

### F3. Lexer improvements if profiles still justify them

[The lexer](../../selfhost/src/front/lexer.bend) repeatedly calls `f_head`/`f_tail`
while scanning words and builds reversed character accumulators. The JS runtime
represents strings natively, but `SCon` elimination slices a remainder and returns
fields. Prototype a Bend-owned cursor or code-point buffer that decodes once and
advances explicitly. Charge buffer construction and memory to the parser. Retain
Unicode scalar semantics, line/column origins, quote escapes and all error cases.
Do not turn host UTF-16 code-unit positions into Bend character positions. This
is secondary for the historical full build, even if valuable for small inputs.

## 10. Build the compiler that is actually being timed

Do not benchmark changed Bend source against an old generated API. Do not assume
`BEND_TYPED_RUNTIME` changes the compiler's execution runtime: the loaded
self-emitted API already embeds its own runtime; that variable supplies runtime
text for the **next output**. Edit runtime fragments, regenerate the concatenated
runtime, and rebuild candidate compiler artifacts before measuring their effect.
Never hand-edit the frozen seed's generated JavaScript as a production change.

For candidate source `S1` and runtime `R1`:

1. Assemble and freeze `S1`, including its source map; bootstrap a candidate API
   `B1` through the pinned TypeScript compiler. Hash the exact modules and exports.
2. Use `B1` to fully check and emit `S1` with `R1`, obtaining self-emitted `H1`.
3. Use `H1` to fully check and emit the same `S1` with the same `R1` and host,
   obtaining `H2`. Require `H1 == H2` byte for byte and identify both artifacts.
4. Time and validate the converged candidate; keep generation/build cost separate
   from the compiler invocation measurements, and also report total bootstrap
   turnaround as a useful development metric.

If using the old self-emitted compiler as the transition seed, the first output
may still be emitted by the old backend. A backend change may require another
generation before comparison. Record this transition explicitly and compare
successive stages that implement the same candidate; never weaken the existing
fixed-point check to declare differing bytes a success.

Canonical source and foreign paths affect output bytes. Reproduce a local seed
in one stable path layout and keep that layout fixed throughout each chain. The
[existing self-host runner](../../selfhost/tools/conformance/selfhost.mjs) and
[direct seed verifier](../../selfhost/tools/conformance/verify-seed.mjs) are the
starting point, with explicit resource budgets and failures retained as failures.

## 11. Validation and promotion gates

Use existing targeted tests for each change, adding regressions for newly altered
behavior. Then promote a candidate through the following gates:

| Change area | Required focused evidence |
|---|---|
| Parse/seed reuse | `tests/frontend/seed-cache.mjs`, `main-names.mjs`, `origins.mjs`, freshening tests; complete IR/error comparisons |
| Index/context changes | `tests/index.mjs`, `reach.mjs`, `prefix.mjs`, `normalize.mjs`; collisions, shadowing, immutable snapshots and binder bounds |
| Intrinsics and generated calls | JS backend tests, `test-provenance.mjs`, `test-string-eq.mjs`, `test-global-initializers.mjs`, runtime `test-apply.mjs`, FFI and deep-closure cases |
| Annotation/kernel changes | `tests/kernel.mjs`, `specialize.mjs`, diagnostics and layout validation; dependent and affine negative cases |
| ABI changes | `tools/test-compiler-abi.mjs` against a self-emitted artifact, graph sharing/identity, host-input mutation and bounded handoff allocation |
| Stack behavior | `tests/selfhost-stack.mjs` and large parser/compiler books with recorded JS/native stack settings |

Paths in this table are under `selfhost/`. Some component suites need a freshly
built export-specific API; follow [component verification](../../selfhost/tools/verify.mjs)
and the [backend instructions](../../selfhost/src/back/js/README.md), rather than
pointing every suite at an API missing its exports.

Run the complete pinned fixture inventory for a promotion candidate, including
eligible interpreter/JS/native CPU routes and the negative audit. Full-corpus
coverage of the old bootstrap API is not coverage of the new self-emitted API.
Compare rejection phases and intended rules as well as exit codes; known
compatibility limitations remain explicit. GPU execution remains unverified
without hardware evidence. Runtime/backend changes require emitted-program
semantics, not only a successful self-check.

Finish with the controlled performance matrix and a complete checked fixed point.
Retain raw samples, environment, phase counts, compiler/source/runtime/host hashes,
output identities and failed attempts. Host-only work reuse and pure indexing
should preserve generated bytes. Intentional backend changes may change bytes
relative to the baseline, but still require semantic comparisons and a new
internally byte-identical fixed point. No old report is relabeled as candidate
validation.

## 12. Commit order and stopping rules

Recommended sequence of independently reviewable changes:

1. Candidate-aware measurement and local full-build control (A).
2. Reuse roots/stop computations and parsed-source handoffs; fix first-use
   duplication only after its behavior is measured (B).
3. Audit and repair hot primitive dispatch, beginning with `String.contains` (C).
4. Indexed emitter context, then shared backend context and constructor index (D).
5. Safe choice/known-call lowering, then allocation improvements justified by
   profiles (E).
6. Focused annotation/backend-plan and checker-maintenance changes in the order
   new full-build profiles indicate; lexer work only when its remaining share
   warrants it (F).
7. Full validation, fixed-point verification, published performance comparison,
   and a new candidate tag. Preserve the baseline tag unchanged.

Each commit states a falsifiable hypothesis, the changed invariant, before/after
measurements and correctness evidence. Stop or revert a candidate that changes
semantics, shifts work outside timing, grows memory unacceptably, or fails to
improve its measured target. Re-profile after each accepted structural change;
individual speedup factors must not be multiplied as if their savings were
independent.

A native compiler executable, GPU work, broad incremental compilation, a new
trusted JS checker/parser, and unrestricted global memoization are deferred.
The initial objective is to make the existing Bend implementation and its own
JS backend efficient while preserving the checked self-hosting chain.
