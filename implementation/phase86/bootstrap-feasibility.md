# Phase86: native compiler bootstrap feasibility

Read-only review, 2026-10-14. No compiler build, target workload, production edit,
installation or benchmark was performed for this note. The current frontier is
[Phase85](../phase85/README.md); Phase82 remains installed. Historical Phase6/68
working files were read where relevant and left untouched.

**A checked C-hosted compiler experiment is feasible, but the historical native
host is not a current executable recipe.** Its useful evidence is that the Bend
compiler has previously run natively with real file IO and exact cross-backend
output agreement. It does not establish current native speed or current native
self-reproduction. Start with a small current entry into the existing Bend
pipeline, not a wholesale revival of the old driver.

## Current pin and checked construction

`selfhost/src/compiler.json` lists 132 modules and upstream
`059266225b77c8ca256ac6b25ee5c21449bab151`. The active reference source is
`selfhost/.bootstrap/upstream-phase66/bend2/`. Freeze that source identity, Base,
effects, current compiler modules and the new Bend entry before emission.

The old `selfhost/tools/performance/rapid/native-component.mjs` hard-codes
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`, requires that checkout HEAD, and calls
`C.book_owned(book, C.SYNTH)`. Neither export exists in the current `comp.ts`.
Its `book.hols + book.open` guard also must not be copied: the current CLI checks
`book.hols`, without the obsolete `open` field.

The checked current upstream sequence, matching `main.ts:816` and
`comp.ts:2768`, is structurally:

```js
const book = B.book_nil();
await B.book_load(book, frozenEntry, '', new Map());
B.book_valid(book);
if (book.hols > 0) throw Error('Unresolved holes');
const c = C.compile_book(book);
```

Preserve separate load/check/emission results, exception diagnostics, complete C
bytes and all consumed identities. `compile_book` performs current backend
entry/layout/owned-name checks through `show_main` and `file_book`; do not bypass
those by extracting an internal emitter. A sibling `C.js_book(book)` can provide
a same-source, same-entry JS execution control. These upstream-emitted artifacts
are bootstrap products; they are not genuine native B2 until a separate native
self-emission chain has been checked.

Use `selfhost/tools/assemble.mjs` to assemble current modules plus a small
experiment-local Bend entry. Keep checking/C emission separate from Clang so an
optimization timeout does not repeat the frontend. `selfhost/tools/native-build.mjs`
contains the current CPU link contract (`-std=c11`, pthread and libm; optional
effect-specific libraries). `rapid/native-compile-c.mjs` or the content-addressed
`rapid/native-compiler-cache.mjs` can reuse already emitted C with fresh outputs,
but retain the external resource guard and pin the actual Clang executable.

## What can be reused and what has drifted

The historical bundle preparer freezes modules and appends
`rapid/native-graph.bend` and `rapid/native-bundle.bend`. The latter still calls
`driver_owned`, absent from the current API (`driver_emit_owned` exists instead).
It composes the old JS `j_program_selected`/`j_library_selected` path, fully checks
Base each request, and lacks modern report, native-request and prepared-prefix
contracts. Renaming a missing symbol would not prove equivalent gate order.

There is also a concrete CLI ABI change: current `IO.args()` includes the invoked
program as its first element (`base.bend:183`, `effs/args.c`), whereas the old
bundle's `main` forwards the whole list to a five-argument matcher. A new native
entry must explicitly consume the executable-name element and account for the
runtime's own options. A copied old launcher is not a passing control.

For a C-emitting compiler entry, reuse current Bend products:
`selfhost/src/back/native/request.bend` defines `nr_prepare_annotated`, `NR_Request`
and `nr_compile_prepared`. The ordinary host orchestration is in
`selfhost/tools/typed-driver.mjs:927–954`. Reproduce its required source checking,
annotation and effect inputs in Bend; do not serialize host-owned JS objects and
assume they become trusted native facts. A first explicitly scoped pure or
main-plus-Base fixture can falsify native execution cost before full import/asset
discovery and the ordinary report contract are implemented.

## Effects and runtime constraints

Current Base already supplies native `IO.args`, `IO.now`, print/error output,
`File.open/read/size/write/close` and process execution. Their C sources are under
the pinned `bend2/effs/`. No foreign implementation of parsing, checking or code
generation is needed. `comp.ts:2744` includes only reachable effects, requires a
matching `.c` import, rewrites `CID`/`FID` references and rejects the same effect
file imported under conflicting namespaces. Keep effect files and canonical
paths in the frozen identity set.

`File.read` is a single bounded OS read and may return fewer bytes than requested;
retain a complete-read/EOF check or a bounded read loop. Close handles on both
success and failure. The old bundle's transport checks are reusable ideas, not
current conformance evidence. `IO.now` returns milliseconds (`effs/now.c`);
external monotonic process clocks are needed for short end-to-end comparisons.

The current native runtime is materially different from V8, not V8 without JIT:

- Tagged terms, affine ownership, borrowed parameters, atomic sharing counts,
  reuse and per-lane allocation replace JavaScript objects and GC. Shared ASTs
  may incur `term_keep`/`term_drop` and copying costs; historical counts are not
  current time fractions (`comp.ts:3788–3950`).
- Layout selection, flat functions and tail-cycle lowering can unbox or avoid
  generic dispatch, while closure/segment paths still use a runtime calling
  convention. The C compiler matters: optimized Clang 19+ can use both
  `preserve_none` and `preserve_most`; the runtime deliberately disables them
  at O0 (`comp.ts:3310–3380`). The build helper accepts Clang 14+, so acceptance
  alone does not establish equivalent performance. Pin one verified toolchain.
- CPU mode initially reserves **8 GiB of virtual address space** and grows in
  place; each runtime stack reserves **2 GiB**, using `MAP_NORESERVE`
  (`comp.ts:4666–4690`, `5201–5271`). These are not resident-memory claims.
  Guard aggregate RSS/available memory, not a 2 GiB virtual-address limit.
- Pass `--threads 1 --gpu off` for the first controlled native sample and retain
  the same external affinity. Default threads follow detected CPU count, not
  necessarily the single allowed CPU. More threads do not automatically
  parallelize a sequential Bend compiler. Count emitted bangs/fork sites before
  attributing any gain to parallel execution.

## Bounded decision sequence

1. Freeze a small entry and fully check/emit it with the current pin. First prove
   Base/effect ABI and one exact accepted output plus one rejected input. Use a
   sibling same-entry JS control to separate runtime from pipeline differences.
2. Preserve C; build O0 only as a feasibility gate if needed. Do not use O0 to
   reject native speed, because it changes both Clang optimization and runtime
   calling convention. Then make one guarded O2 build with a fresh output.
3. Measure two or three representative small requests, complete output consumed,
   with build/preparation, file IO, report, Base policy and execution separately
   identified. Compare the current cached installed compiler separately from an
   uncached same-source control; native historically lost the cached small loop.
4. Stop before full-source self-compilation, PGO, LTO or broad native-host work if
   small complete-request latency is unpromising. Exact output and bounded
   startup/resource behavior precede any proposed integration.

Historical bounds help schedule a first attempt, not forecast today's build:
[Phase4](../phase4/native-final.md) emitted 6.09 MB C with JS/checking in 48.6 s,
then built O2 in 85.4 s; its old native compiler took about 245 s on full source.
[Phase2](../phase2/native-host.md) found native slower than the cached JS host on
small inputs. Current source, backend, runtime and 132-module scope differ.
Use an initial 180 s checked-emission / 300 s O2 ceiling and the existing 2 GiB
RSS guard as **abort budgets**, not expected times or permission to exceed memory.
If either stage hits a bound, preserve the precise phase and evidence before
deciding whether a smaller reachable entry can answer the question.

Phase85's V8 CPU attribution supplies motivation, not a native speed bound.
Eliminating JIT may exchange it for tagged-term execution, reference counting,
code size or cold-cache costs. There is no defensible current native gain estimate
until the first checked, scope-matched executable comparison completes.
