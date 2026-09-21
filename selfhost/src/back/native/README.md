# Bend native backend

All parsing-independent native compiler decisions in this directory are Bend
code. `manifest.txt` specifies deterministic source assembly order. The backend
consumes the checked, specialized, annotated first-order core used by the other
compiler modules. It does not invoke the upstream TypeScript native emitter.

Public entries:

- `nc_compile(book, runtime, requests) -> NC_Result{source, error}`.
- `nc_foreign_paths(book) -> List<String>` selects reachable C effects.
- `nc_foreign_source(book, path, source) -> String` scopes source-local
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

This implementation deliberately uses one runtime word per live value and boxed
general constructors. The upstream flat-layout, borrow and static-data optimizations have not been reproduced. GPU execution has not been tested
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
