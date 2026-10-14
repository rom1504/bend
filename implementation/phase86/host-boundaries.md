# Phase86 current compiler native-host boundary audit

Read-only source audit at repository HEAD
`39171f3fff9dc2abc7b42487d70c797f57395a49`; no compiler, executable or build ran
in this lane. Read `AGENTS.md`, the experiment workflow, ledger and current
Phase85 frontier first. Historical native prototypes are evidence and reusable
transport patterns, not current release measurements.

## Finding and smallest useful prototype

The current compiler's semantic pipeline is already in Bend. A small Bend entry
can compose it and be compiled by pinned upstream TypeScript to C. The Node host
does file acquisition, source/cache identity checks, ABI transport, reporting
orchestration and process execution; none requires rewriting the checker or C
emitter in C. Start with one module and its optional Base import, then add an
explicit module/foreign-asset manifest. Keep unsupported inputs explicit.

Use the **current** `selfhost/src/compiler.json` manifest, append a new experimental
Bend IO entry and assemble with `selfhost/tools/assemble.mjs`. The active upstream
pin is `059266225b77c8ca256ac6b25ee5c21449bab151`. Its `comp.ts:2768`
exports `compile_book`; its loader/checker remain in `bend.ts`. Check the assembled
program before emission, preserve generated C, then compile that C separately so
a failed or slow Clang attempt does not repeat Bend checking/emission. Emitting
the identical entry to upstream JS gives the most direct execution-backend
control. Whole-manifest assembly does not imply every function is reachable in
the emitted executable.

This produces a **C-hosted Bend implementation of our compiler**, initially built
by upstream TypeScript. It is distinct from the installed JavaScript-hosted B2
compiler that emits C programs, and it is not yet native self-reproduction or a
native bootstrap fixed point. Keep compiler hosting language, compiler producer,
and output target as three separate labels.

## Exact reusable request pipeline

The reference orchestration is `selfhost/tools/typed-driver.mjs:800–958`.
For an initial uncached pure entry, accept canonical source identities, supplied
`List<&2,FSource>`, runtime text/prepared runtime, and foreign asset bytes:

1. `f_load_graph_trace(mainPath, sources): FLoadTrace`; reject its `FResult.error`.
2. `check_program_diagnostic(loaded.book, Nil{}, Nil{}): DResult`; reject its
   error and use its returned `book`. This already performs program completion
   and specialization through `driver_program_checked`; do not add the old
   independent specialization pipeline again.
3. When reports are requested, obtain `driver_report_data(loaded.book)` from the
   original loaded declarations, as the current driver does. Report work and
   unsafe-definition status must match the reference timing scope.
4. Preserve `driver_emit_owned(book)` then `j_compile_error(book)` checks before
   native lowering. These names do not mean that the output must be JavaScript.
5. `context = book_context(book)`;
   `stops = nc_annotation_stops(context)`;
   `selected = reach_book(context, ["main"], stops)`;
   `annotated = annotate_selected(context, selected, stops)`;
   require empty `jl_checked_error(context, annotated, ["main"], stops)`.
6. `plan = nr_prepare_annotated(context, annotated): NR_Request`. The product
   carries `source`, erased/indexed `book`, reachable `names`, foreign `paths`,
   foreign `scope` and exact freshness `bound`. Preserve this current route.
7. For each first-occurrence foreign path, acquire its bytes, run
   `kf_source(plan.source, plan.scope, path, bytes)` and reject its error, then
   `nc_foreign_source(plan.source, plan.scope, path, bytes, parsed)`. Join in
   declared order. Missing required assets must fail; unused assets need not load.
8. `nr_compile_prepared(plan, preparedRuntime, requests, effectsSafe): NC_Result`;
   require empty error and consume the complete emitted source before stopping
   the compiler-work timer. Writing and host C compilation are separate clocks.

`preparedRuntime = ne_runtime_prepare(runtimeText): NE_Runtime` is also pure
Bend. Prepare it once outside matched request clocks if both sides are intended
to match Phase82's retained runtime chunks. Passing `NE_Text` every time invokes
a different fallback cost. The current driver verifies the canonical runtime
artifact and its chunks before granting reuse; a prototype can instead retain
the exact in-memory product produced from its own frozen runtime bytes.

## Matching the prepared Base path without a Node cache codec

All required producer and consumer functions are present in current Bend source.
Construct `FSource{"Base", basePath, baseText}` and locate it with
`f_source_located(source, 1, baseEnd)`. The host interval convention is **UTF-16
units**: `baseEnd = 1 + dg_width(baseText) + 1`, with checked U32 bounds.
`String.length` counts characters and is not interchangeable on non-BMP text.
The main starts at `baseEnd`, ending at `baseEnd + dg_width(mainText) + 1`.
The current host reserves the Base interval even when main does not import it.

Preparation, outside the request clock when explicitly selected:

```text
baseLoaded = f_load_graph("Base", [locatedBase])
require baseLoaded.error == ""
require check_book(baseLoaded.book) == ""
checked = base_prefix_prepare(baseLoaded.book)       : KBasePrefixState
fresh = f_fresh_prefix_prepare(baseLoaded.book)      : FFreshPrefixState
ready = f_ready_prefix_prepare(baseLoaded.book)      : FReadyPrefixState
world = base_prefix_world_prepare(baseLoaded.book, checked) : KBasePreparedWorld
```

For a main whose header actually imports Base and no other module:

```text
carrier0 = f_prefix_graph_empty()
seed = f_prefix_complete_ready_seed(locatedBase, "", carrier0,
         basePath, baseText, baseLoaded.book, ready)
completed = f_prefix_complete_source(locatedMain, "", f_source_header(locatedMain),
              [locatedMain, locatedBase], seed.carrier, f_path_dir(mainPath))
load = f_prefix_graph_trace(completed.carrier, [locatedMain, locatedBase], fresh)
checkedResult = check_program_diagnostic_world(load, Nil{}, world)
context = book_context_world(checkedResult.book, load, world)
```

Check every intermediate parse/check error before later work. Preserve normal
fallbacks when prepared states are ineligible. Do not inject Base for a module
that does not import it. These private calls are justified only because the entry
itself retains the exact producer results from the same bytes, identities and
intervals; fabricated certificates or arbitrary deserialized caller data do not
qualify. Public `f_load_graph_seed_trace` is a valid simpler fallback, but it does
not reproduce the current fast prefix-carrier/parser/world path.

## Concrete host and foreign boundaries

`typed-driver.mjs` imports Node `fs`, `os`, `path`, `crypto`, `child_process` and
URL helpers. Its graph discovery canonicalizes physical paths, detects aliases,
loads dependency headers, assigns disjoint source intervals and supplies Bend
completion operations in dependency order. An explicit immutable source manifest
can replace discovery for the prototype while preserving Bend graph semantics.
General filesystem discovery and exact diagnostic rendering remain follow-up
host work, not a reason to rewrite the compiler.

The cache frame/arena codec, `WeakMap` identity admissions and image-hash bindings
in the Node host are not a portable native memory image. In-memory Bend producer
products avoid this codec initially. A distributable native executable with cold
prepared Base still needs a native serialization/loading policy or generated
static data; this audit does not establish one.

There are two different sets of foreign C sources: effects used to run the
**compiler executable's own IO**, and foreign/effect bytes embedded in the
**program C it emits**. The former come from the upstream backend building the
host. The latter must match the current selfhost runtime ABI and files.
The driver remaps canonical Base effects to `selfhost/src/runtime/native/effs`.
It grants `effectsSafe` only for the exact pinned Base and audited unchanged
`args.c`, `print.c`, `now.c` handlers. Do not infer safety from a basename or set
the flag unconditionally; a false flag may change generated representation/C
even while preserving behavior, invalidating an exact-output comparison.

The upstream native runtime represents strings as `SCon` chains (see `comp.ts`
`io_cbuf`/`io_cstr` and `io_str` construction), whereas JS lowering supplies
primitive strings. Removing V8 first-use work can therefore expose different
text allocation/traversal costs. Native hosting is a hypothesis, not a speed
guarantee, even after matching algorithm and cache scope.

## What the old rapid host contributes—and cannot establish

`tools/performance/rapid/native-bundle.bend` offers bounded sized reads with EOF
verification, handle cleanup, full output consumption, timing and a small CLI.
`native-graph.bend` offers versioned source/asset transport. The wrappers preserve
old destinations and retain failure evidence. These are useful patterns.

Its semantic entry emits **JavaScript**, uses older `check_book`/owned/TODO/
specialize orchestration and has no prefix cache. `native-component.mjs` and
measurement tools hardcode old upstream `6018e28…` and an old JS export/entry
shape. They cannot be pointed at the current source and treated as an unchanged
current-host comparison. Do not edit these sealed historical tools; adapt a
small Phase86 entry/tool instead. Historical full-source timing and exact JS
emission establish neither current C-target speed nor native self-hosting.

## Fair comparison and stop gate

First compare identical current Bend entry/source emitted to upstream JS and C,
with equal inputs, complete output consumption, CPU affinity/thread count,
resource bounds and exact output checks. Use a tiny non-IO fixture first, then
one Base/IO fixture, Functions65 and Numeric before large source/build attempts.
Report C-emission and Clang build cost separately from compiler execution.

Keep preparation, first request, repeated requests and complete process wall
separate. Preparing Base in memory before the JS request also executes and
tier-compiles frontend helpers: that is a **prepared-session** comparison, not
Phase82's fresh request from an already prepared disk artifact. An uncached
Base comparison is useful only when both sides perform that same full work.
Neither may be relabeled as the existing 1.328× installed B2/TypeScript metric.

Then compare the adapted entry's emitted C against current `typed-driver` output
to establish pipeline fidelity, and compare latency with handwritten TypeScript
under matched work. Upstream-produced JS of the Bend entry is a B1 host control;
installed B2 has a different producer. Native execution of this entry is not a
native B2 claim. Stop if the first small equal-work pair is materially slower or
cannot satisfy output identity; preserve the cause before committing to a broad
native-host migration.

## Experimental entry delivered to the coordinating lane

[`entry.bend`](../../selfhost/tools/performance/phase86/entry.bend) now composes
the current prepared prefix/world, report and native-request APIs described
above. Root owns checking, image acquisition and execution; this lane has only
written and statically audited the entry. No success or speed claim follows
from its existence.

Its internal CLI is `INPUT BASE RUNTIME EFFECTDIR OUTPUT COUNT`, with absolute
paths, a leading executable argument from current `IO.args`, and count restricted
to 1 or 5. It reports Base/runtime preparation separately, consumes source/error/
verdict before each request's second clock, and writes `OUTPUT.N.c` after that
request clock. Every request therefore has a separately hashable C artifact.
It requires `import Base`, rejects other imports/foreign paths, and accepts only
the three scalar Base effect names from the exact original Base effects directory.
The coordinating harness must authenticate the pinned Base/runtime/effect bytes;
the experimental entry is not a public permission to accept arbitrary effect
files with those names. File IO limits inputs to 16 MiB and checks EOF after sized
reads. Affine file handles are selected through direct matches, never duplicated
between alternative closure arguments. The entry is frozen for root acquisition.

The subsequent host-only revision loads five sibling files `RUNTIME.part0` through
`RUNTIME.part4` and constructs `NE_Parts`, instead of running the scanner in each
new process. Root must bind these files to the existing Bend-produced canonical
`runtime-template.json` and verify that concatenation reproduces the authenticated
raw runtime. Their file reads belong to `runtime_prepare_ms`; raw runtime text
is no longer read by the entry. This mirrors retained runtime preparation without
changing scanner/emitter algorithms. The earlier live-scanner entry and its
acquired images remain separate evidence, not overwritten results.

Final root acquisition08 additionally accepts both exact Base effect spellings
`effs/NAME.c` and `./effs/NAME.c`; the admitted names and authenticated bytes do
not change. Its entry digest is
`3e6707ab55094c5ef7140652f43c25483833de4860921c91e97b606afa7eba4f`.
The [completed report](README.md) supersedes this feasibility audit for measured
behavior: native Map fails in reference counting and Lexer is substantially
slower. No default-host migration is qualified.
