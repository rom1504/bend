# Phase159 — source-grounded bendc pipeline and profile map

This is the pre-experiment audit. The completed [report](../../implementation/phase159/README.md)
supersedes its initial GC interpretation: a bounded reuse search explains and
removes the dominant Phase157 runtime cost on the common computation. Historical
self-emission and source traces below remain a separate revision and workload.

Audit at `53e2371`, no compiler or benchmark executions. Inputs: authenticated
`selfhost/build/phase158/historical` at bendc
`9c54842eb5756803af599583ca49870d1e09186a`; `selfhost/build/phase158/current`
at `56edcc65b3527a75838011682c231072d5b46097`; maintained Phase152 compiler and
the Phase153 complete-source profile. Input hashes and reproduction policy are
in [Phase158 method](../phase158/published-method.md). Historical source line
numbers below refer to `bendc.bend` unless another file is named.

**Main finding:** bendc's reachable C emission follows whole-loaded-program
lowering and optimization. It is not evidence of lazy optimization. Its smaller
output, direct C execution model, tracing-only self-image, and fewer independent
backend checks are distinct hypotheses; none yet explains a speed ratio on the
same input.

## Historical request boundaries

| Boundary | Concrete functions and scope |
|---|---|
|Load/parse|`Main.build`19447 reads Base and calls `Main.load`9421. `Main.load.go` recursively parses imports, qualifies their names with `Mod.qualify`, resolves foreign paths with `Eff.decls`, and appends imported declarations. Base is parsed separately and appended to user/import declarations. This is whole-module loading, not reachable-body loading.|
|Token/layout/expression parse|`Main.parse`8265 → `P.file`3295 → `Lex.all`858 → `Lex.lines`, `Lay.lines`, `Lay.finish`; then `P.decls`/`P.decls.sel` and `P.expr` parser workers. Tokens, layout and parsed expressions are separate materialized representations.|
|Optional source check|Checked CLI first uses separate `Main.chk.load`/`Chk.parse_file` and `Chk.check_book`; then its IO entry reloads using `Main.build`. `--no-check` skips this path. `Chk.VJob.all.go` is the seed's only executable parallel-fork site; unchecked emission and historical GC marking are serial.|
|Law/selection rewriting|`Main.emit.to.sh`19430 applies `LM.decls(ds,ds)` to the combined list; `Gen.program`15274 then applies `Pick.decls`. Both walk definitions before reachable generation.|
|Core lowering|`Lo.program`15230 builds `G.new`, `Lo.masks`, then `Opt.lowers` on every declaration. Runtime `DDef`s go through `Core.Lo.def` and `Core.Def.erase`; type-level definitions remain `OKeep`, as do other declaration kinds (`Opt.lower`13353).|
|Core transforms|`Opt.rank`, `Opt.ctx`, `Opt.inls`, `Opt.simps`, `Opt.spec`, `Opt.fuse`, `Opt.finish`, `Opt.raises`. `Opt.inl` always runs `Inl.def`, `Core.Def.red`, `known`, `lit`, `dead`; optional letters only control selected additional work. `Up.def`12791 converts the core representation back to expression declarations.|
|Metadata/DPS|`Par.auto`7169 is off for the reproduced NO_FREE/default policy. `G.new`3879 rebuilds constructor/definition/body maps. `Dps.build`7414 still traverses all definitions, constructs tail-call edges/reverse edges and destination-passing groups. `free=false` is stored as policy, not an early exit from DPS analysis.|
|Reachable code generation|Only now `Gen.program.m`15269 starts `Gen.all(g,["main"],Set.new())`. `Gen.all.go`6648 emits each unseen name through `Gen.def`, collects `Gen.take_refs`, and extends its work queue. Generated wrappers, closures, DPS workers and native/foreign definitions are not one-to-one with source declarations.|
|Text/effects/write|`Gen.program.fin`15236 flattens prototype/body Docs. `Main.emit.ok`8455 reads selected effect sources through `Main.effs`, resolves their CID/FID spelling, scans constructors and calls `IO.write` with the combined text. This includes a full Bend String and UTF-8 host-buffer conversion before stdout.|

Reachability does not justify dropping earlier checks or definitions. Type-level
bodies remain available to printers, laws supply signatures, constructor order
affects IDs, native definitions have external behavior, and specialization/fusion
may create references. Historical `Opt.dead`15199 only removes unused generated
`%f` fused names, over three rounds; it is not a general root-based reachability
filter for the original program.

## Physical-profile names and honest work counts

Use mutually exclusive physical-PC classes; a caller-inclusive stage attribution
is a separate view. Preserve unmapped PCs and C-library time. Name-based classes
do not recover inlined code automatically.

| Class | Historical Bend names / generated C anchors |
|---|---|
|Loader/parser|`Main.load.*`, `Main.parse`, `Mod.*`, `Eff.*`, `Lex.*`, `Lay.*`, `P.*`; e.g. `F_Main_dload_dgo`, `F_Lex_dall`, `F_P_ddecls_dsel`.|
|Checker|`Chk.*`, `Main.chk.*`, `Main.check*`; `F_Chk_dVJob_dall_dgo` forks at seed44789. Keep checker parser `F_Chk_dP_*` separate from emission parser `F_P_*`.|
|Book/representation setup|`LM.*`, `Pick.*`, `G.build/add/new/laws`, `Lo.masks`, `Opt.lower/lowers`, `Core.Lo.*`, `Core.Def.erase`, `Core.Up.*`, `Up.def`.|
|Optimization|`Inl.*`, `Core.Tm.*`/`Core.Def.red/known/lit/dead`, `Opt.*`; distinguish `Opt.sp.*`, `Opt.fu.*`, `Opt.go`, `Opt.refs.*`, `Opt.inls`. Core functions also include lowering/raising helpers, so prefix-only assignment needs exceptions.|
|DPS/generation|`Dps.*`, `Gen.all*`, `Gen.def*`, `Gen.expr*`, `Gen.stmt*`, `Gen.pat*`, `Ty.*`, `Use.n`, `FV.*`; `Gen.code.go`/`Gen.proto.go` accumulate Docs.|
|Text and names|`Doc.go/flat`, `String.append`, `Gen.mangle`, `Main.ids*`, `Main.effs`, `Ctors.scan`; map exact C workers such as `F_Doc_dgo`, `F_String_dappend`. Generic String/Map/List work is shared across stages and cannot be assigned solely by its leaf name.|
|Runtime|`gc_alloc_x`, `gc_new_small`, `gc_collect_locked`, `gc_mark`, `gc_drain`, `gc_sweep`, closure `apply/mk_clo`, `io_cstr`, `io_out`, libc copy/allocation/write. Inline allocation may be charged to generated C functions. The historical compiler uses tracing without early freeing, not Phase157's later RC machinery.|

`Gen.mangle`3898 escapes `.` as `_d` and `_` as `__`; use the authenticated
seed's actual names instead of assuming an ambiguous reverse mapping. `W_*`
wrappers and numbered `L*` closures require their C bodies/callers to identify
source ownership. Clang may inline, clone or remove those functions. Use the
actual profiled image's symbols/DWARF/addresses, not the seed's text line numbers
as machine locations.

Potential observation points, if counts later justify instrumentation: total
loaded declarations at `Main.compile`; `OCore` versus `OKeep` after `Opt.lowers`;
generated definitions after specialization/fusion; unique names in `Gen.all`'s
done set; emitted body bytes and effects. There are no existing public counters
for those stages. `--ast` parses the named file, not the full import closure;
counting source `def` lines or C `F_` functions is not a substitute. The current
revision's `--parse-only` uses the checker loader and is not historical
emission-parser timing. Static counts and dynamic samples answer different
questions.

## Doc and ownership boundaries

`Gen.code.go`3982 and `Gen.proto.go`3990 append by constructing `DCat`, so they
do not repeatedly flatten the entire accumulated program. `Doc.go`30 visits
the right subtree first and appends each `DStr` leaf to the accumulated suffix;
it copies a leaf's linked String spine, not the already-built suffix. This is
linear in Doc leaf text for one flatten, subject to previously built/copied
fragments. Inner expression printers still perform ordinary string appends.
`Main.effs`8404 appends to a growing effect accumulator; effect count/size bounds
that separate cost. Finally `IO.write`'s foreign callback calls `io_cstr` to
allocate/encode the full host byte buffer, writes it, then frees the buffer.
Thus bendc has copying and full-output residency despite using a rope.

With `BEND_NO_FREE=1`, `Gen.shares.if`4861 bypasses sharing code and its per-bound-
variable `Use.n` walks; emitted match-take work is disabled too. This does not
remove closure free-variable analysis, all maps, all persistent structure, or
GC. It also does not mean the generator's `+` arguments implement our explicit
borrowed-result/ownership contracts. The fixed seed's code-generation and runtime
policy must remain distinct from policy selected for the compiler it emits.

## Current56 revision adds work, not an explanation of the old result

Current `Gen.program`26462 still does whole-list `Pick`/`Lo.program`, preceded
by `Arrw.decls`. It then performs `Par.auto`, `Unb.sum.program`, `Nest.program`,
**two** `Unb.program` rounds, optional RC `RO.program`, representation selection
`G.li`/`G.hless`/`RP.program`, `Dps.build`, `Unb.sret`, and `KX.flow.build` before
reachable `Gen.all`. Its optional optimizer set is `i..spufwhtm`, with unrolling,
tail pushing, match-reuse and extra substitution/representation work. Historical
default is `i..spf`. The current no-check result is not the historical workload.

Current `Gen.program.fin`25944 has `Arrn.program` validation and a thunk that can
build a separate GPU-oriented book via `Gen.program.g`; do not count that thunk
as executed without a profile/call-site observation. Current automatic RC policy
also has `HY.default/HY.program`, absent historically. These additions, plus
flat parameters/results and borrowed RC calls (`Unb.*`, `Bor.*`, `RC.wrap.*`),
are useful future profile categories, not features present in the2.13s claim.
The current seed's actual `F_HY_ddefault`108410 branches around `HY.program`
when `free=false`, so automatic-RC eligibility is not expected work under the
reproduced NO_FREE policy. A source occurrence alone is not dynamic exposure.

## Cheapest policy tests on one fixed historical input

Keep the same already-built seed, matching2.0.32 Base, `BEND_NO_FREE=1`, worker
policy and output sink. Change only `BEND_OPT` during emission:

| Value | What disappears relative to default `i..spf` |
|---|---|
|`i..sp`|Four bounded fusion rounds and their three dead-fused-definition cleanup rounds.|
|`i..s`|Additionally four bounded specialization rounds; preserves the original eight-node general-inlining budget.|
|empty String|General size-based inlining and optional s/p/f passes. Mandatory monadic inlining, core red/known/lit/dead, lowering/raising, reference repair, metadata, DPS and generation remain. This is not “no optimization.”|

Unsetting OPT selects the default; setting it empty selects the last row.
Dots affect the inlining budget (`4+2*dot_count`), so preserve them when removing
one letter. Reductions have interactions: total timing deltas are effects of
the whole changed request, not exclusive pass costs. Changed C bytes are expected.
Baseline runs must still reproduce the seed; variants need separately retained
outputs and semantic execution oracles before any correctness or generated-
program speed claim. Repeating emission establishes determinism only. Changing
flags while executing the fixed compiler measures output acquisition, not the
execution speed of a newly built compiler. Do not automatically trigger a costly
Clang rebuild for each screen. Changing current OPT additionally changes value
representation via `w/h`; keep that experiment separate.

## Comparison with our selected compiler and strongest next falsifiers

Our selected source is `027e1504…`, Phase152 N2 `d6271295…`; qualification is in
`implementation/phase152/qualification.json`. Phase153's7,406-sample profile
has236.947s staged CPU and exact118,227,421-byte QBE. Its101.45s raw lowering +
initial optimization + output/cleanup region is a measured envelope, not
comparable to bendc's2.8MB self-C or a guarantee of removable work. Physical
ownership/reclamation/allocation/register transport42.71% overlaps those stages.

Our `p86_plan_context` selects reachable annotation before native preparation.
`p144o_prepare_annotated`/`p144o_source_ready` build constructor facts and a
reachable request; `p144o_lower_bangs` produces generic segments and private
candidates. `p113d_passes`, `p113a_verify`/`p113e_function`, and
`p128raw_*`/`p126bp_complete` perform transformations plus independent admission.
`p134e_prepare` builds emission registries; `p134e_next` streams private, legacy,
public and table pieces. `p144e_body_tail` already flattens body chunks directly
onto their suffix. A proposal to add “streaming” or remove an extra whole-body
append must account for these existing mechanisms.

The strongest immediate tests are: (1) source-mapped baseline profiling to learn
whether whole-program optimization, parser, metadata, or output dominates the
historical request; (2) one optional-pass removal justified by that profile,
with retained changed output and no speed/correctness extrapolation; (3) if
allocation/Doc/String costs dominate, quantify complete output conversion and
representation work before proposing a runtime change. Our final verifier and
public/private ABI production are real extra obligations; never bypass them to
manufacture equivalence. Phase157's common extracted computation did not favor
bendc GC, and Phase149's reduced optimization regressed compiler execution, so
neither tracing nor fewer passes is a pre-established compiler win.

Primary sources: historical [pipeline](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/bendc.bend),
[core representation](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/core.bend),
[runtime](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/rt/bendrt.h),
current [pipeline](https://github.com/Lulzx/bendc/blob/56edcc65b3527a75838011682c231072d5b46097/bendc.bend),
and local `implementation/phase153/{README.md,metrics.json}`.

## Diagnostic preparation

`tools/stage-seed.py --allocations --out FRESH_DIRECTORY` verifies the exact
historical seed/header hashes and each selected C signature, then writes private
`program.c`, `bendrt.h`, `p159-diagnostic.h`, and `preparation.json`. It performs
no compilation or target execution. Prepared instance:
`selfhost/build/phase159/stage-prepare01`; manifest binds all generated hashes,
the script hash,15 original function-body hashes and the detailed method.

Thirteen synchronous function wrappers report thread-CPU inclusive time and
time after subtracting nested measured child intervals. Inclusive rows overlap;
exclusive rows cover only instrumented intervals, not the entire process.
`Opt.inls+simps.fused` wraps the actual fused seed worker, so its time is not
standalone simplification time. `Gen.def` counts calls returning a Gen action;
its deferred action is not separately timed. `Opt.lower` counts calls and its
actual OCore/OKeep results. Known List<Decl>/List<OD> lengths are aggregate
observations across calls, not unique program cardinalities.

The allocation-capable image enables relaxed atomic `gc_alloc_x` call/requested-
word counters only when `P159_COUNT_ALLOCS=1`; unset/0 disables increments but
retains a branch. Attribution uses the innermost active synchronous TLS stage,
with outside work in its own row. Counts precede size-class rounding and do not
measure system malloc calls, live bytes or allocation lifetimes. Extra list
walks, clocks, wrapper boundaries, atomics and changed stack roots perturb the
program; counted timing is diagnostic, and the uncounted image still needs an
overhead comparison against the clean seed. Only root executes those gates.

The exit hook prints one JSON object to stderr. Require successful exit, exact
seed stdout, exactly one valid report, and `diagnostic_errors=0`. An abort or
signal can prevent the report; never treat that as zero measured work. Static
preparation validation restored all15 renamed bodies byte-for-byte and verified
all generated/script hashes. No generated C was compiled in this audit.
