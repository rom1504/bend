# Phase161 frontend, core and checker architecture comparison

This is an offline source audit at our starting commit `d3588cf`, against
bendc `56edcc65b3527a75838011682c231072d5b46097`. It is not a benchmark,
qualification or proposal to move the compiler out of Bend. No compiler target
was run for this audit. The historical bendc `9c` self-emission results are a
different revision and input; they do not supply timings for the current code
compared here.

The strongest simplification opportunity is **separating semantic declarations
from our list/index/cache bookkeeping and carrying typed identities and facts
between stages**. Both implementations already memoize evaluation, expose
declaration signatures before bodies, and distinguish rigid comparison from
comparison that unfolds definitions. Reimplementing those capabilities would
not be a new optimization. Nor is bendc universally a simpler frontend: its
checking and emission paths have separate parsers and term representations.

## Size inventory and its limits

Counts below read `.bend` files, with exact UTF-8 bytes and `splitlines()` physical
lines. “Code lines” means nonblank lines whose stripped text does not begin with
`#`. It includes type signatures, laws, annotations, braces and multiline
formatting. Declaration counts use the existing
[`source.py` block extractor](../../selfhost/tools/build/source.py). These are
an auditable inventory, **not concepts, executable instructions, dependency
closure sizes or estimates of runtime**.

| Our maintained responsibility | Files | Bytes | Physical lines | Code lines | Defs / laws / types |
| --- | ---: | ---: | ---: | ---: | ---: |
| `selfhost/src/front` | 16 | 229,478 | 5,524 | 3,991 | 546 / 169 / 17 |
| `selfhost/src/load` | 7 | 68,399 | 1,716 | 1,179 | 166 / 46 / 13 |
| `selfhost/src/core` | 12 | 136,329 | 4,204 | 3,123 | 360 / 109 / 14 |
| `selfhost/src/check` | 11 | 162,843 | 4,310 | 3,090 | 427 / 116 / 14 |
| `selfhost/src/diagnostic` | 5 | 39,668 | 1,014 | 715 | 93 / 35 / 8 |
| Selected envelope | 51 | **636,717** | **16,768** | **12,098** | **1,592 / 475 / 66** |

The 475 law blocks occupy 68,149 bytes, 3,585 physical lines and 2,623 code
lines. Another 1,569 code lines are standalone `@unsafe` annotations. This makes
raw line comparisons sensitive to our explicit declaration discipline. It does
not establish that these declarations are unnecessary or safe to remove.

The matching bendc responsibility boundary is not just its `check.bend` file:
emission also has a separate frontend in `bendc.bend`.

| Current bendc source envelope | Bytes | Physical lines | Code lines | Boundary |
| --- | ---: | ---: | ---: | --- |
| Entire `check.bend` | 310,429 | 8,581 | 7,419 | Checking parser, terms, normalization, quantities, termination, diagnostics, templates and checking |
| Emission lexer/layout/surface parser | 105,406 | 3,261 | 2,792 | Declaration blocks beginning at lines 88–3348 of `bendc.bend` |
| Selected load/qualification/check-driver families | 27,100 | 653 | 555 | Explicit families listed below |
| `Core.Pat`, `Core.Expr`, `Core.Param` declarations | 960 | 36 | 26 | Surface data constructors in `core.bend` |
| Selected envelope | **443,895** | **12,531** | **10,792** | Not a complete dependency closure |

The driver selection uses prefixes `Main.chk.`, `Main.check`, `Main.load`,
`Main.parse`, `Main.resolve`, `Mod.`, `Eff.`, `Path.`, `CS.`, `ChkSel.` and
`LoadSel.`, and exact types `CS`, `ChkSel`, `LoadSel`, `Qual`. The selection is
reproducible but excludes some CLI/IO helpers. Conversely, our `core` includes
helpers shared with later compilation. Generic Base/runtime code is excluded
from both tables. The selected envelopes therefore should not be promoted into
a precise “our frontend is X times more complex” ratio. They provide no evidence
of an order-of-magnitude source difference in comparable frontend work.

For orientation, current bendc's whole `bendc.bend` is 1,187,548 bytes / 31,028
physical lines; whole `core.bend` is 69,163 bytes / 2,352 lines. The latter is
primarily a backend IR implementation, **not** the counterpart of our entire
`core/` directory. Use the existing [Phase160 census](../phase160/comparison-boundaries.md)
for complete source and root-closure comparisons rather than adding overlapping
counts from this audit.

The [offline census tool](tools/responsibility-census.py) and its
[recorded JSON](responsibility-census.json) reproduce both frontend tables and
the supporting-source inventory. The JSON pins every read source, the extractor
and the tool itself; selected bendc blocks include kind/name, byte bounds, header
line and SHA256. It requires the three pinned bendc source hashes before counting.
Whole-file selections are explicitly recorded. Run from the repository root:

```sh
python3 experiments/phase161/tools/responsibility-census.py --check
```

This performs only offline file reads and in-memory counting. Omitting `--check`
writes a new census; it does not execute a compiler. Restore the pinned bendc
sources if their retained build directory is cold. Backend responsibility counts
remain in the separate backend audit and are not silently merged into this
frontend envelope.

## Representations and ownership of facts

| Concern | Our maintained implementation | Current bendc implementation |
| --- | --- | --- |
| Parsed/checkable terms | `KTerm` with string tag, name, numeric binder identity, quantity and generic child list; specialized lambda/literal constructors also exist | Typed `Chk.Tm` constructors with named fields; explicit closure/environment constructors share this union |
| Book | Ordered definition list plus cache sentinel, persistent hash index and generic `KDef` encodings | Typed `Book` separates declaration map, constructor map, order, holes/open items, template state and files |
| Parser state | Token stream plus explicit scope/environment/fresh counter, producing the same KTerm/KDef family used by checking | Checker uses a character cursor and parser state; emitter independently lexes/layouts tokens into `Core.Expr`/`Decl` |
| Normalization | Explicit graph heap/state, numeric cells, continuation frames, persistent heap updates | Explicit closures and memo cells, with real memo operations supplied by native intrinsics |
| Publication | Ordered event schedule, whole-book/list/index coherence, final-definition materialization | Persistent typed maps plus last-event flags and event order; parallel checks use snapshots and conservative fallback |
| Typed emission input | Separate annotation/reach after checking, with prepared Base products and recorded checked definitions | Checked CLI compilation calls the emission loader/parser again before lowering |

Source anchors:

- Our [`term.bend:5`](../../selfhost/src/core/term.bend#L5) defines `KTerm`;
  line 11 defines semantic `KDef` and index variants. `lookup` at line 378
  accepts a cached book or falls back to its list.
- [`index.bend:116`](../../selfhost/src/core/index.bend#L116) accepts both typed
  index nodes and legacy index encodings. `book_cached` at line 332 creates the
  `$kernel.cache` sentinel; `book_put` at 343 updates list/index representations;
  `book_final` around 411–468 materializes latest definitions.
- bendc [`check.bend:222`](../../selfhost/build/phase158/current/check.bend#L222)
  defines `Tm`; lines 262–300 define `Tld`, `Book`, cursor and parser state.
  Closure/context constructors remain in `Tm`, partly because of the language's
  mutually recursive representation constraints. This is typed representation,
  not a claim that all support state disappeared.
- bendc [`P.file`](../../selfhost/build/phase158/current/bendc.bend#L3346)
  starts the emission lexer/parser, whose surface types are in
  [`core.bend:2026`](../../selfhost/build/phase158/current/core.bend#L2026).
  `Main.check` loads/checks a `Chk.Book` at line 16101; the successful non-normalizing
  checked path at 30822 calls `Main.build`, which loads/parses for emission again.

## Equivalent computation 1: declaration visibility and publication

Both compilers must make declared types/constructors available while preventing
an ordinary live reference to a not-yet-filled law body. This is language
semantics, not avoidable bookkeeping.

Our [`check_declarations`](../../selfhost/src/check/kernel.bend#L1127) installs
signatures and constructors with bodies erased as required. `infer_ref` at 794
checks missing names, ADT parameters, live unfilled laws and template restrictions.
The compact schedule builds next-event information and preserves duplicate,
law/fill and diagnostic ordering. Its [`p143cp_put_log`](../../selfhost/src/check/compact-schedule.bend#L59)
has a childless logged-insertion shortcut; other publication calls canonicalize
the book before `book_put`. That canonicalization must keep the observable raw
list and index coherent.

bendc [`book_reset`](../../selfhost/build/phase158/current/check.bend#L7447)
likewise starts from declaration signatures. `valid.def` at 7581 checks the type
and body, then publishes. `book_valid.lasts` at 7781 computes last-event flags in
a reverse set pass. [`book_set`](../../selfhost/build/phase158/current/check.bend#L4765)
updates the typed declaration map without rebuilding a generic cache sentinel or
ordered declaration list. Constructor facts have their own map. Parallel jobs
snapshot persistent books; templates and failures can force sequential fallback.

This is a concrete place where our representation maintains more coherence than
the underlying semantic operation requires. It does **not** justify ignoring
constructor, failure-restoration, template or event-order effects. The
[Phase156 publication experiment](../../implementation/phase156/README.md)
already demonstrated a narrower invariant-based reduction: **4.62% less median
full-source request time**, across two reversed pairs with exact complete QBE.
That experimental result is not a promoted compiler or a projected gain for a
larger book redesign.

## Equivalent computation 2: dependent application

Our [`infer_app`](../../selfhost/src/check/kernel.bend#L803) infers and weak-head
normalizes the function type, requires an `All`, checks the argument at its
quantity, and substitutes it into the codomain. Template consumption is tracked.
bendc's [`check.run`](../../selfhost/build/phase158/current/check.bend#L6990)
`SInferAppGo` performs the same dependent checking computation with typed `All`
fields and `clo_apply`; its reference path also checks live unfilled laws and
template restrictions.

The distinction is the representation and lifetime of environments, terms and
results, not whether checking is performed. Our implementation already has
[batched substitutions](../../selfhost/src/check/env-substitution.bend#L35)
and [bounded deferred telescope environments](../../selfhost/src/check/env-telescope.bend#L58),
with conservative fallback. “Use environments instead of substitution” is
therefore not a sufficiently specific new proposal. A valid experiment must
identify a remaining producer/consumer round trip and preserve quantities,
dependency order, binding capture and error behavior.

## Equivalent computation 3: sharing normalized values

Our [`GHeap`/`GState`](../../selfhost/src/core/graph.bend#L3) already memoize graph
evaluation. `g_share` at 323 creates a cell identity; `g_get` at 293 and `g_put`
at 305 traverse/update the persistent heap by numeric identity. `g_cache` and
`g_wnf` use it during normalization. Proven equality can update sharing in
[`norm_cmp_loop`](../../selfhost/src/core/normalize.bend#L644).

bendc wraps terms in [`Cel`](../../selfhost/build/phase158/current/check.bend#L1763).
`wnf` at 2194 checks a memo before forcing the term; line 2239 stores the result;
`cmp` at 5423 compares cell identity or forces comparison, and 5431 links proven
equal cells. The apparently tiny `memo.*` Bend bodies at 1741–1761 are no-op
fallbacks: [`Natives`](../../selfhost/build/phase158/current/bendc.bend#L3840)
registers native replacements.

The real implementation is [`bendrt.h:3085–3135`](../../selfhost/build/phase158/current/rt/bendrt.h#L3085):
`memo.new` allocates a two-slot array; `memo.has` compares a retained key;
`memo.get/set` preserve the appropriate reference-counting or GC sharing;
`memo.same` compares cell addresses; `memo.link` shares the value of cells already
found equal. Stores include array/collector bookkeeping and an atomic key
publication. This work was moved into the runtime, not eliminated.

Both normalizers first try a rigid comparison before unfolding:
our [`norm_convert`](../../selfhost/src/core/normalize.bend#L628) and bendc
[`term_compare`](../../selfhost/build/phase158/current/check.bend#L5525).
Our separate states prevent opaque-world values from contaminating the full-book
comparison. Any cell/arena change must preserve that scope, branch snapshots and
ownership; an unrestricted global mutable cache would not be an equivalent
replacement. The falsifiable question is **whether a cheaper scoped cell
representation removes measured persistent-heap/transport work**, not whether
memoization should be added. Static source inspection does not establish its
time share.

## Supporting code is part of the design

| Inspected supporting source | Bytes | Physical lines |
| --- | ---: | ---: |
| bendc `rt/bendrt.h` | 196,009 | 4,941 |
| bendc `rt/native.c` | 5,693 | 117 |
| Ours `runtime/qbe/runtime.c` | 150,560 | 4,806 |
| Ours `runtime/qbe/runtime.h` | 4,518 | 88 |
| Ours `runtime/qbe/primitives.h` | 3,067 | 108 |
| Ours `runtime/native/runtime.c` | 83,683 | 3,134 |

These are support inventories, **not complete or additive comparable runtime
totals**. Our QBE provider uses shared native support; bendc's header contains
multiple execution/platform paths, while `native.c` supplies external wrappers
for its native ABI and is not an extra C-backend algorithm. Generic Base,
effects, intrinsic registration, backend and build support also matter.
For example, bendc registers native Map and String operations alongside memo
cells. A rewrite that reduces Bend lines by adding C intrinsics must report both
sides and qualify the trusted/native boundary; it cannot claim the operation or
its complexity vanished.

## Remaining work-reduction hypotheses

1. **One typed checker book, with explicit publication provenance.** Separate
   declaration lookup, constructor metadata, order and template state internally;
   materialize the legacy/public ordered book only at a boundary that requires it.
   This targets concrete canonicalization/coherence work and implicit invariants.
   Start from the already-tested Phase156 invariant rather than inventing another
   replay-only shortcut. Preserve old snapshots, law/fill/error order, duplicate
   names, failed templates, collision handling and supported public cache forms.

2. **Typed identities/facts from producer through consumer.** Replace selected
   string tags/generic payload decoding with typed variants and direct fields,
   retaining numeric binder/name identities until diagnostics or output requires
   spelling. This can reduce conceptual contracts as well as temporary products,
   but only if it crosses the complete affected path. Packing a compact form and
   immediately reconstructing `KDef`/`KTerm` can lose; the earlier dense/transport
   experiments are a reason to demand complete-consumer evidence. Typed source
   variants alone do not guarantee a faster generated representation.

3. **Retain facts established by the real loader/checker producer.** The remaining
   [`f_graph_finish_indexed`](../../selfhost/src/load/graph.bend#L332) pipeline
   fills definitions, validates names, qualifies modules and rewrites paths;
   annotation later traverses selected checked definitions. Establish which
   identities/type facts can survive these transitions instead of being recovered.
   Keep validation and first-error order. Ready-prefix suffix validation, prepared
   checked Base products and batched substitutions already exist; do not count
   those as new opportunities or assume annotation is redundant checking.

4. **Scoped memo storage, only after demonstrating its cost.** Compare the same
   normalization/comparison with current `GHeap` and a representation preserving
   equivalent cell identity/lifetime. Include construction, sharing, cleanup and
   all fallback behavior. If native cells are needed, account for runtime source
   and proof obligations. This is a representation experiment, not more GC-policy
   tuning, and currently has no measured gain estimate.

The source-root closure experiment owned by the parent is separate: it can remove
unneeded input work while retaining the same implementation. The
[Phase160 closure census](../phase160/comparison-boundaries.md) is not proof of
native output equivalence or a frontend-algorithm speedup.

## What existing profiles do and do not support

[Phase153's accepted full-stage capture](../../implementation/phase153/README.md)
reported 29.64 diagnostic CPU seconds in parse/load and 33.57 in
checking/publication: **63.21 seconds together**. Annotation/reach was another
6.40 seconds. Those are stage envelopes, not attribution to the data structures
above, and come from one sampled capture of the qualified implementation. The
same report assigns 101.45 seconds to raw lowering, initial optimization and
output/cleanup. A frontend-only rewrite cannot be credited with deleting backend
work. Halving the 63.21-second frontend envelope would save roughly 31.6 diagnostic
seconds in that capture; deleting it completely is neither possible nor claimed.

[Phase159's historical self observer](../../implementation/phase159/README.md)
and [Phase160's same-implementation cross-build](../../implementation/phase160/README.md)
have different source, compiler and execution boundaries. The latter demonstrates
that generated execution/runtime representation materially affects this same
algorithm, but does not attribute a difference to frontend source length or to
any one representation proposed here. Current bendc may do work differently and
also delegate operations to native helpers. Neither its compact source nor its
historical self-emission time proves that our required checking can be skipped.

The best next architectural candidate from this audit is the typed book and
publication boundary, followed by a complete producer-to-consumer identity/fact
path. Both have identifiable redundant bookkeeping to remove. A wholesale
frontend transplant or a new mutable memo subsystem needs stronger evidence
before displacing those experiments.

## Interpreting an exact-output source-closure result

If reducing the input from 3.085 MB to 1.698 MB still produces the same complete
118 MB QBE in roughly 194 seconds, the immediate conclusion is limited: dead or
unneeded declarations were removed from **input processing**, while the emitted
compiler implementation remained identical. Under the same machine toolchain,
this is a cheaper way to acquire that compiler, not a faster executable compiler.
Use the paired measured inputs and stage receipts to determine the acquisition
saving; the hypothetical 194-second observation alone provides neither a ratio
nor attribution. The full original source remains a useful held-out workload for
an actual algorithm change.

Two architectural changes can instead remove work from the running compiler:

- **Typed Book/publication:** change the live data structure and publication
  operation so updating one declaration does not entail preserving two redundant
  book representations or repeated canonicalization. Its scope is mostly
  checking/publication, with lookup consumers benefiting only if the typed
  contract survives those boundaries. Constructor facts, event order, template
  state and snapshot semantics are necessary; the sentinel encoding is not.
- **Downstream lowering, analysis and materialization:** compacted body preparation
  is **already shared**. [`p112s_defs`](../../selfhost/src/back/qbe/static-data.bend#L162)
  prepares reachable ordinary definitions and stores `NativeStaticBody` facts;
  [`nc_compact_definition`](../../selfhost/src/back/native/book.bend#L104)
  returns `dv(fact)` when that prepared fact exists. Calls from both generic and
  candidate consumers do not establish repeated compaction. The remaining
  architectural question is whether their subsequent lowerings and analyses can
  reuse more authenticated facts or avoid intermediate materialization. This
  attacks executed compiler work rather than merely reducing its input. The
  generic fallback, direct ABI, ownership semantics and independent final verifier
  remain real obligations; removing them requires a replacement contract and
  generated-program evidence. The [corrected backend audit](backend-architecture.md)
  distinguishes this existing cache from the downstream work still performed.

Prefer proving one complete downstream lowering/analysis computation before a
broad backend rewrite, while treating the demonstrated publication invariant as a
smaller, better-supported integration opportunity. Neither source counts nor
unchanged output size tells us how much of either operation is executed. Merely
renaming modules, moving helpers into C, deleting unrelated backends, or dropping
required checks does not establish an algorithmic simplification with preserved
functionality.
