# Bend native backend

All parsing-independent native compiler decisions in this directory are Bend
code. `manifest.txt` specifies deterministic source assembly order. The backend
consumes the checked, specialized, annotated first-order core used by the other
compiler modules. It does not invoke the upstream TypeScript native emitter.

Public entries:

- `nc_compile(book, runtime, requests) -> NC_Result{source, error}`.
- `nc_compile_checked(book, runtime, requests, effects_safe) -> NC_Result`
  additionally consumes the checked scalar-array preconditions below.
- `nc_foreign_paths(book) -> List<String>` selects reachable C effects.
- `nc_foreign_source(book, scope, path, source, parsed) -> String` scopes source-local
  constructor macros to the linked program's qualified IDs.
- `nc_annotation_stops(book) -> List<String>` supplies replaced intrinsic names
  for reachability and selective annotation.
- `nc_annotated_context(full, annotated) -> List<KDef>` merges annotated live
  definitions into their complete type context and rebuilds its name index.

The host only loads requested C text, writes emitted source and invokes Clang.
The retained Apache-2.0 C runtime is in `src/runtime/native`, with its original
CPU scheduler, Metal and CUDA dialects, heap, arrays and foreign IO event loop.
The host effect-boundary fairness adaptation is documented in `ORIGIN.md`.
GPU builds require the platform SDK and the host flags described by the runtime;
CPU-only builds retain the same generated segments.

`erase.bend` removes type/proof arguments using checker annotations.
`bridge.bend` lowers constructors, matches, closures, applications and cuts to
segments. Environment liveness controls captures and drops; shared values are
retained before a split, constructor children are sealed, and matching consumes
nodes through `ctr_take`. `parallel.bend` emits parallel child tasks and their
join, retaining a sequential path. `direct.bend` fuses saturated leading-lambda calls while retaining partial
applications and matcher evaluation boundaries.
`pattern.bend` lowers Nat decision chains to flat word tests. `identity.bend`
encodes user constructors independently of Base ABI names and preserves their
printed spelling. `array.bend` implements the array primitives.
`show.bend` builds a memoized graph of readback descriptors for instantiated
recursive datatypes. `tables.bend` emits the shared host/device register ABI,
function tables and scheduling metadata. `validate.bend` rejects ID collisions,
overwide arities and overlapping source/temporary binder ranges.

General values use one runtime word and boxed constructors. Specialized native
workers can flatten selected product arguments/results, and checked scalar arrays
use the policy below. Closed immutable constructor graphs can use the static
image; general upstream borrowing is not yet reproduced. GPU execution has not been tested
on physical hardware in this workspace. Unprintable/dependent result types and
unlowered core forms return explicit diagnostics.

Run compiler-owned native regressions with:

```
CC=clang-19 BEND_UPSTREAM=/path/to/pinned/Bend node src/back/native/tests.mjs
```

The test builds a Bend compiler API, emits C, compiles it, then checks execution
with one and four CPU threads. It covers closures, sharing, reclamation, recursive
trees, readback, forks, arrays and bang dispatch on the CPU fallback.

After bootstrapping the full compiler API, run representative upstream source
programs through parsing, checking, native emission, Clang and both thread counts:

```
CC=clang-19 BEND_UPSTREAM=/path/to/pinned/Bend node src/back/native/fixtures.mjs
```

This writes generated sources and a machine-readable result report under
`build/native-fixtures`. Optional positional arguments select individual fixture
names such as `compile/float_compare` or `reg/array_clone_boxed`.

The implementation ports algorithms and runtime interfaces from HigherOrderCO
Bend commit `6018e28ecc67cf1fffc0c20c64b11023474c2df8`, Apache-2.0. The license is
retained at `src/runtime/native/LICENSE`.

The original twenty native failure regressions and the seven final IO checks
have dedicated selectors:

```
node src/back/native/fixtures.mjs --baseline-fixes
node src/back/native/fixtures.mjs --io-fixes
```

Set `BEND_TYPED_API`, `BEND_UPSTREAM`, and `CC` as above. These runs record API,
runtime, source and driver hashes with each report. Historical targeted evidence
is preserved in `tests/conformance/native-fixes.json`; it explicitly distinguishes
retained binary re-execution from a single-snapshot full compilation sweep.

### Checked scalar-array policy (Phase68 source candidate)

The checked driver now calls `nc_compile_checked` after checking, specialization,
annotation and layout validation. `scalar-array.bend` computes two separate
whole-program facts: all arrays have U32/F32/Char elements, and no array-containing
value is duplicated. The first selects packed 32-bit buffers; the second permits
direct buffer locations. A failed proof retains ordinary storage/access. This is
not enabled by program names, timing fixtures or unchecked user annotations.

The host authenticates the pinned Base and the audited args/print/now effect
bytes. Changed/custom effects and Base versions decline these policies. The
low-level `nc_compile` entry stays conservative; callers of `nc_compile_checked`
must establish its documented checked-book and trusted-runtime preconditions.
Unknown types, user aggregates, captured functions/IO and proof rewrites can
prevent admission. This conservative analysis trades coverage for a small,
reviewable correctness boundary. Sharing and element width are independent.

Array access helpers in the C runtime serve both ordinary and product-result
lowering. Clone, split, join, leaf matching, atomics and readback must agree on
representation; a global layout decision prevents mixed-width joins. The source
also contains guarded constructor packing and flat product results; the original
one-word description above describes the generic fallback.

See the [design](../../../../design/phase68/checked-scalar-arrays.md),
[results](../../../../implementation/phase68/checked-scalar-arrays.md) and
[fast-loop instructions](../../../tools/performance/phase68/scalar-layout/README.md).
The installed release remains separately identified by `dist/release.json`.

### Ordinary fallback and compilation cost

`flat.bend` admits host workers through a dependency closure; tail self calls
become local jumps and dependency cycles stay on the scheduler. Product workers
are optional. If a product route fails its demand proof, dependency-blocked
ordinary workers get one retry using only admitted product signatures. Already
admitted bodies stay unchanged. This preserves the boxed ABI and original
demand/ownership rules instead of guessing that raw constructor matches are
exhaustive. Device segments retain their previous fallback bodies.

The scalar-array admission walk uses explicit `nt_choose` branches. Bend Boolean
operators evaluate their arguments, so an `or` expression alone does not avoid
an expensive use-count scan. Non-variable nodes and proven array-free values
skip that scan; unknown values still use the original saturated branch-aware
count. No new cached analysis state is introduced.

Foreign `FID(Clo~apply)` names the existing runtime closure dispatcher and is
rendered as `BEND_CLO_APPLY`. Ordinary namespace resolution, unknown-ID errors
and comment/string shields remain shared with JavaScript.

See [native facts and fallback results](../../../../implementation/phase68/native-facts-and-calls.md)
for separate runtime, B1/B2 compilation, conformance and size measurements.

### Retained Phase69 native integration

Main-reachable bang facts now drive both scheduler metadata and worker
admission. `static.bend` interns closed immutable constructor graphs in the
existing static image and shares request-local prepared bodies across lowering
routes. Its fresh BookCache payload preserves the original source index; raw
forged/static and interior-cache inputs retain explicit rejection/fallback.
The image is bounded at 65,536 words, with ordinary allocation after refusal.

Known partial applications and bounded linear combinators avoid redundant
closure factories while preserving argument demand and capture identities.
Checked no-sharing facts permit cold user-constructor stores, and private
worker signatures retain proven U32/F32/Char/Bool widths through `N_Param`.
Raw calls and scheduler registers keep the generic Term ABI. Product fields
remain opaque, and general product-storage reuse remains a separate
experiment. Phase70 adds the bounded root borrowing described below. Register new native modules in both `manifest.txt` and
`src/compiler.json` for a full compiler build.

The [native performance guide](../../../../docs/self_hosted/native-parity.md)
explains contracts, the historical typed10 six-family 1.0332× upstream result,
remaining individual gaps and reproducible fast loops. The
[design](../../../../design/phase69/native-parity.md) and
[report](../../../../implementation/phase69/README.md) separate measured source
candidates, conformance, B1/B2 latency and installed release status.

### Historical Phase70 root-preserving observers

The optional checked CPU observer pass checks that a bounded immutable-list
traversal returns its original roots, computes the scalar answer with borrowed
cursors, then uses ordinary owned lowering for the result wrapper. It hooks
eligible scheduler entries after ordinary worker admission; existing private
worker calls can bypass it. Explicit checked/effect permission, raw and device
fallback, demand preservation and the analysis bounds are documented in
[Native root-preserving observers](../../../../docs/self_hosted/NATIVE_OBSERVERS.md).
Compiler03 was installed as checked B1 `386ae358…`; genuine B2 `d069204f…`
passes fresh self-check and exact B3 reproduction. Checked Bool-array admission,
lazy product demand and compact-body reuse are selected. The occurrence shortcut
was removed after its performance gate failed; skipping observer planning for
ordinary-ready entries was declined.

The [Phase70 runtime campaign](../../../../implementation/phase70/native-runtime-results.md)
measures 1.12124× upstream on the original six families and 1.84036× on six
additions, with an optional equal-weight twelve-family score of 1.43649×.
Compiler02 supplied the timed C; all 24 compiler03 B1/B2 emissions match those
twelve complete programs and the 56 pinned host/runtime/effect files remain
unchanged. This is finite inherited execution evidence, separate from the
three-source C-emission ratios of 3.41827× for B1 and 2.16517× for B2.
The observer guide keeps earlier Map/String/Tape checkpoints separate and
explains the remaining fallback and correctness boundaries.

## Product transport across calls and loop backedges

Phase72 extends the existing product path in two places. Result-shape queries
recognize a matching constructor argument before argument sequencing converts it
to a virtual bundle. This avoids reboxing a flat result between named calls.
The checked, effect-admitted host path also permits private product workers whose
exit can discard a parameter. Calls to those workers still require exact,
already-evaluated bundles; no new adapter unpacks an unknown boxed argument.
Existing lowering materializes shared, dropped or opaque products at their
original use, so a loop can stay flat on its backedge and box only on exit.

Raw compilation retains its prefix-demand admission, and device/scheduler
interfaces remain boxed. There is no new IR, runtime representation or JS
optimization. See the [Phase72 report](../../../../implementation/phase72/README.md)
for measured scope and qualification status; candidate measurements alone do
not identify an installed release.

## Phase73 ownership and scalar facts

`sharing.bend` tracks actual duplicated checked values and complete datatype
instantiations, so proven unshared constructors avoid redundant RFC wrappers.
Scalar-result observers borrow shared recursive roots; all-consumer and saturated-
use proofs allow cold recursive children. `NC_Binding` carries existing word
kinds through aliases and continuations, replacing the post-lowering argument
rewrite. Monomorphic product fields and instantiated match fields reuse one
bounded scalar-field proof. Compiler algorithms remain in Bend.

See [Native ownership and scalar facts](../../../../docs/self_hosted/NATIVE_OWNERSHIP_FACTS.md)
for invariants, refusal boundaries and maintenance requirements, and the
[Phase73 report](../../../../implementation/phase73/README.md) for actual measured
and installed status. Historical descriptions above refer to their own versions.
