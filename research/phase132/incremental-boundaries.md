# Phase132: native identity, reuse and final reachability boundaries

This is a source and retained-artifact audit at `2227ce264dc138d524990e27ef458abbee67a384`.
No compiler, runtime, installed selection or executable was changed or run. The
[metadata inventory](incremental-boundaries.json) pins the exact Q2/Q3 QBE and
runtime object. Its producer is [inventory.py](../../selfhost/tools/performance/phase132/boundaries/inventory.py).
The selected source is the [qualified Phase131 capsule](../../implementation/phase131/final/README.md),
SHA256 `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
Line numbers below refer to that reconstructed `compiler.bend`, not a later edit.

The most useful architectural boundary already exists: named structured values
before final numeric-ID/static-image binding. Reuse at that boundary could avoid
lowering and rendering, but only with explicit checked-book, specialization and
admission dependencies. Reusing complete emitted function bytes is much easier
and is a useful stability experiment; it cannot avoid the present full frontend.

## Concrete identity hazards

| Identity/fact | Actual selected implementation | Consequence for reuse |
|---|---|---|
| Source-derived global symbols | `nt_fid` at31015 encodes every character of a semantic name; `p111q_symbol` at40584 adds a prefix | Names such as `p113d_FID_$direct.foo` can remain stable when unrelated definitions change. A compact build-local ordinal is not equivalent to stable identity. |
| Anonymous continuation names | `p111_name` at39791 names `$p111.k.<fresh>`; `p111_compile_defs` at40048 starts each definition from the previous definition's `fresh`, propagated by `p111_compile_step` at40040 | One earlier body edit can rename later continuations and local variable IDs even when their semantics are unchanged. Owner-plus-local identity is a possible future repair; it is not implemented. |
| QBE block/local fresh names | `p111q_segment` at40722 resets `P111QCode` to0; `p113e_private` at45208 does likewise | Final QBE block numbering is function-local. It is not the main global identity problem. Input variable IDs can still inherit earlier global fresh state. |
| Runtime function IDs | `p111q_function_ids` at40737 enumerates the final segment list; `p111q_value` at40602 resolves `N111FuncId` to an integer | Insertions, deletions and segment-count changes invalidate numeric immediates in closures, continuation frames and jumps, even if symbolic callees remain unchanged. |
| Constructor IDs | `p111q_constructor_ids` at40744 enumerates constructor order; `nc_add_ctors` at35725 preserves first encounter | Adding/reordering constructors may change tag words, branches, layout metadata and static values. Arity/hotness changes also invalidate ownership and borrowing decisions. |
| Static pool addresses | `p112s_intern` at42160 assigns offsets in encounter order with deduplication and a65536-word budget; `p112s_word` at42103 embeds offset and CID into tagged integer constants | Symbol relocation alone does not repair an unchanged cached function using an old static Term word. Pool-size/admission changes can also change whether construction is static or dynamic. |
| Private-worker admission | `p113d_pass_function` at44644 and `p113d_passes` at44671 close candidate dependencies through an evolving ready index, with32-pass fuel | A callee becoming admitted/refused can change callers. Cache a negative dependency too: previously absent worker/interface facts can matter. |
| Borrowed/product composition | `p128raw_prepared` at56427, `p128raw_br_compose` at56618 and `p131p_closed` at57631 combine retained candidates and the actual emitted helper bundle | Source-call edges alone miss dependencies on helper summaries, representation choices, retry admission and fallback composition. Phase131's eligible-but-unused helpers demonstrate this experimentally. |
| Final validation | `p126bp_complete` at54641 validates composed functions and the final program before emission | A cache receipt cannot replace this gate without a separately justified validation boundary. Keep the final verifier for the initial experiment. |

The relevant original modules include [segment lowering](../../selfhost/tools/performance/phase111/segment/lower-book.bend),
[QBE IDs and tables](../../selfhost/tools/performance/phase111/qbe/program.bend),
[QBE values](../../selfhost/tools/performance/phase111/qbe/emit.bend), and
[private/direct composition](../../selfhost/tools/performance/phase113/direct-emit/program.bend).
Selected later overrides are authoritative; the names and source lines above
identify the actual capsule rather than assuming every original module remains
the active entry point.

## What can be cached independently now?

1. **Exact emitted QBE unit → machine object.** Key the complete function/unit
   bytes, required declarations, target, QBE/as flags and binary identities,
   symbol visibility decisions and runtime ABI. Every embedded FID/CID/static
   address is already in those bytes, so a content change invalidates the unit.
   Always regenerate/link global descriptor/table data. This is a backend cache,
   not an incremental compiler.
2. **Checked named IR → emitted unit, under a fixed binding environment.** A
   conservative first contract includes the entire ID map, static image and
   ready-signature/ownership-layout summary identities. This over-invalidates but
   is defensible. Measuring how often it hits is necessary before narrowing it.
3. **Per-definition checked/lowered facts.** This is the valuable future boundary,
   but current lowering reads the whole book, performs specialization and shares
   global freshness/static allocation. The practical unit is an owner plus its
   generated closures/continuations, private alternatives and explicit imported
   facts; not merely the textual source declaration.

For split objects, every cross-unit private function/data reference needs a
link-visible symbol or a unit grouping that keeps it local. Preserve the original
link order and record this explicit visibility change. QBE's local labels are
safe across objects; assembler-generated local literals are local too. The
current image uses scalar QBE signatures, but a general splitter must carry any
referenced type declarations rather than assuming that permanently. Grouped
units amortize many tiny QBE/as invocations; grouping by unstable list position
can cause unnecessary cache misses.

The retained N2 build took8.728s QBE +4.824s assembly +0.265s link =13.816s.
Even eliminating that entire build saves only about2.7–3.5% of an emission+build
loop whose emission costs382–491s. This is a conditional cost ceiling using
separate recorded observations, not a paired incremental speed measurement.
Large gains require avoiding earlier work, not only caching machine objects.

## A concrete redundant-emission opportunity

The frozen107,059,385-byte QBE contains63,239 functions:

| Kind | Count |
|---|---:|
| Exported dispatch segments (`p111`) |48,911|
| Private legacy workers/forwarders (`p112w`) |12,275|
| Private direct/borrowed workers (`p113d`) |1,974|
| Private recursive regions (`p114r`) |78|
| Exported `main` |1|

**All48,911 dispatch segments have zero direct textual call sites.** The runtime
selects them through `program->segments[next]` (`runtime.c:1404`), including
numeric FIDs stored in closures (`3922`), frames (`3932`) and jump state (`3947`).
No-direct-call pruning would therefore remove almost the complete compiler.
The dispatch table is a real conservative root, not evidence every registered
segment is dynamically exercised.

After including *all* function global references, data relocations, every export,
`main` and the descriptor,12,048 **private** functions remain outside that
conservative graph:11,707 `p112w` and341 `p113d`. Their complete function text is
9,073,516 bytes,8.48% of the full QBE;5,399,251 bytes are legacy workers and
3,674,265 direct workers. This is a static opportunity, not a measured improvement
or deletion proof. No functions were removed.

There is a source explanation. `p113e_old_private_chunks` at45266 emits every
registry entry. `p113e_registered` and `p113a_registered` append those entries
alongside the selected final public and direct functions. The original module
explicitly preserves them for generic/fused fallback callers. Later public
selection can instead call a direct worker or a stack-safe region, leaving old
workers and their private dependencies unused. Some old workers remain needed;
removing the entire legacy family would be incorrect.

The cheapest follow-up is a **closed-image private-function reachability ceiling**,
with all dispatch entries, public functions, metadata and runtime unchanged. Its
proof obligations are stronger than this scanner: extract edges from the actual
final verified emission plan, include symbol-valued arguments/address-taking and
data references, establish that runtime/foreign code cannot synthesize a private
code pointer, and retain unknown edges conservatively. Check the emitted graph
independently, build it and compare compiler-request outputs and ordinary semantic
oracles. Never equate code removal with a runtime gain: layout can change, and
late omission alone does not save prior candidate analysis or verification.

## Compact-symbol ABI audit

The pinned `runtime-borrow01/runtime.o` has no undefined generated function/data
symbols. Its undefined symbols are system-library calls; the inventory preserves
the full list. Runtime source contains no dynamic lookup of generated functions.
Effects bind through constructor-name strings (`runtime.c:3743–3885`), so those
strings and constructor IDs must remain unchanged. Runtime execution observes
function pointers through the descriptor, not their linker spellings.

The conservative experiment may rename only nonexport definitions with a
bijective full-reference map. Preserve unresolved/runtime names, all exports,
`main`, `p111_program`, constructor/effect/show text and the profiler's
`p111_segments` anchor. This excludes the48,911 exported segment names and is
therefore a deliberately partial size ceiling.

A separately labeled **closed linked-image experiment** may rename generated
exported `p111_FID_` symbols too, preserving unknown exports and the true ABI
anchors. That changes the ELF symbol ABI; it is not a drop-in object/library
replacement. The pinned program+runtime+system-library link has no identified
external consumer of those generated spellings. This does not certify arbitrary
foreign objects or debugger scripts. Profiling tools currently decode the old
prefixes, so retain and authenticate the inverse map for attribution. The sampler
looks up the independent `bend_profile_dispatch_get` runtime accessor, which must
not be renamed.

Validation should compare all executable/allocated section bytes and sizes,
descriptor/table values, and relocations after inverse-name normalization
(offset, relocation kind, addend and target binding). Preserve function ordering,
target flags and branch alignment. Nonallocated `.strtab`/`.symtab` and build-ID
differences must not be mistaken for runtime work changes. A shorter source text
does not guarantee identical QBE code generation; machine comparison establishes
that for the frozen experiment.

## Smallest realistic one-function edit experiment

Start with a real diagnostic-only body edit to `p111_uint` at39813: change its
invalid-U32 diagnostic while retaining the exact signature and success branch.
Freeze old/new source, an independent `None`-case expected diagnostic and `Some`
boundary-value controls. This is deliberately capable of exposing static-string
pool churn; do not select only a synthetic constant-return function that hides it.
Use the existing checked API for the tiny semantic oracle. A full rebuilt
candidate is the reference for output and artifact stability.

The coordinator's alternate first edit, changing both occurrences of `%result`
to `%answer` in the QBE text returned by `p111q_main`, is also appropriate. It is
an alpha-renaming of one emitted local and preserves generated-program semantics.
However, rebuilding the compiler containing this edited String literal can
perturb static interning and offsets beyond one native function. Separately
measure the compiler-image artifact churn and the eventual emitted program's
one-local text change. A hand-edited QBE `main` alone is only a backend control,
not evidence of source-level incremental reuse.

First compare old/new complete emissions by source owner and exact function
bytes: ordinary/private/continuation symbols, numeric IDs, local alpha-renaming,
static constants, admission choices and data. Only then attempt exact-content
object reuse. The initial conservative cache should reject any byte mismatch;
compare the final linked compiler's ordinary and affected negative behavior with
the independently rebuilt candidate. Record frontend, hashing, misses, object
builds, link and verification separately.

Then deliberately challenge one dependency at a time: insert an earlier
continuation-producing definition; change a callee signature; insert/change a
constructor; change a static literal; flip private admission; change runtime ABI.
A cache hit on stale affected code is failure, regardless of benchmark output.
If the first diagnostic edit causes widespread fresh-name/pool churn, report that
falsifier before implementing an elaborate cache. The next narrow architectural
repair would be owner-local generated identities and deferred binding of symbolic
FIDs/static references, each tested independently against a full rebuild.

## Recommendation

Proceed with compact names and exact-artifact reuse as cheap, bounded experiments.
Investigate the9.07MB unrooted private-emission category before adding cache
infrastructure. For substantial compiler-time gains, prefer one checked immutable
book summary or independently reusable named lowering result, keeping the final
verifier, over a general cache whose invalidation graph is not yet understood.
Stable identities and smaller text are enabling properties; neither demonstrates
incremental frontend work or recursive research acceleration by itself.
