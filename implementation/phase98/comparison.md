# Phase98 comparison and ownership lane

This lane prepares source candidates; root performs all compiler, native and
timing executions. No canonical source, upstream compiler or generated C has been
edited here. Current first choice is a **ten-line held-root equality wrapper**.
The separate literal recognizer candidate is a fallback with materially larger
source cost. Neither is a compiler speed result until the actual request screen.

## Mechanism and existing evidence

The unchanged D04 native source begins with safe `p88_string_eq_go(a,b,same)`.
It destructures both strings before inspecting the carried Boolean. The admitted
structural recursive order is important: Phase88's Bool-first arguments failed
the decrease rule; Phase89's same-first match with strings-first arguments failed
match ordering. Repeating those rearrangements is not a new experiment.

Phase95's accepted Map profile attributes8.52% of request samples to equality
cleanup. Its rejected full-self profile has27.08% equality cleanup and31.88%
including disjoint own leaves. The latter is an explicitly exploratory lead,
not an accepted measurement or a removable-time estimate. Equality appears
across unrelated compiler paths; the neutral Phase95 membership and Phase97
lookup screens show why another isolated helper gain is insufficient.

The pinned upstream C compiler already performs borrowed-parameter inference.
`comp.ts:1193` (`brw_of`) begins eligible boxed parameters as borrowed;
`val_own` at1641 and `emit_args` at2091 propagate ownership/lending requirements.
`compile_book` at2770 repeatedly emits to a fixed point, and promotes parameters
without a lending witness to owned at2800. Borrowing therefore depends on the
whole set of callers. One ownership-demanding use can make every call to a
generic helper consume. This is a concrete upstream mechanism, not a proposal
to alter the human-written compiler.

Actual D04 C at `selfhost/build/phase92/upstream-checked01/compiler.c:14245`
(`spin_3`) consumes both String cells using `ctr_take`, sinks their tails and
releases spares. The wrapper `spin_2` at14301 delegates to this worker. Fixed
literal arguments are **already static** `STAT_OFF` values: removing their
construction is not a B1 opportunity. The avoidable candidate work is their
generic traversal plus shared dynamic-node ownership traffic.

Reverting to Base `String.eq` is not supported by the code evidence. Base
`String.cmp` at1893–1923 reconstructs the returned strings; `String.order`
at1952 discards that pair; `String.eq` extracts an equality result. D04 generated
C still contains its continuation path and pair disposal around596270–596350.
There is no name-specific String.eq fast intrinsic in pinned `comp.ts`. Phase88
removed this representation/reconstruction work with a safe consuming helper.

## Candidate A: preserve roots while a private walker observes them

The source implementation is
[`held-helpers01.bend`](../../selfhost/tools/performance/phase98/comparison/held-helpers01.bend).
Its private walker is the exact Phase88 safe recursive body under an explicit
rename. `p98_eq_observe(+a,+b)` computes the Boolean first and returns the complete
original roots in `P98EqHeld{same,left,right}`. `p98_eq_finish` then consumes those
roots and returns the Boolean. No pointer escapes, new foreign effect, runtime
permission or global observer switch is introduced.

The full compiler derivative reuses **the existing p88_string_eq_go unchanged**,
so it needs only ten extra physical lines and308bytes. Its exact recipe and
candidate are `selfhost/build/phase98/held-source01/{changes.json,compiler.bend}`;
candidate SHA256 `81c017c841fde5491eeac8f260d9194028127d8ddf391baad5decc151960f5fd`.
[`prepare-held.py`](../../selfhost/tools/performance/phase98/comparison/prepare-held.py)
records a full source replay and inverse. It accepts another frozen source for
later composition but does not change canonical modules.

The intended mechanism is to provide a lending witness at every entry to the
recursive observer: the roots remain owned by the outer call while all recursive
visits only observe their children. The wrapper then releases each root once.
The generated C must show `term_peek` in the worker and no per-character
`ctr_take`/`term_sink`/`spare_free`. Source-level semantic equivalence alone cannot
establish that the backend selects this representation. It may inline away the
holder or retain a conflicting ownership requirement; either outcome falsifies
the proposed mechanism and stops a full candidate build.

**The first actual code-shape gate passes.** The checked standalone acquisition
at `held-control-checked01` has zero holes. Its emitted `spin_2` at1328 contains
three static `term_peek` sites and zero `ctr_take`, `term_sink`, `spare_free` or
heap allocations. `spin_5` at1400 calls that worker and returns exactly three
words: Boolean, original left root, original right root. `spin_6` at1419 sinks
each original root once after the observation. No heap carrier is allocated.
Exact C/source/acquisition pins, function bodies and operation counts are in
[`held-code-shape01.json`](../../selfhost/tools/performance/phase98/comparison/held-code-shape01.json).
Root reports all1,444 native full-product controls and five exact-candidate
BendTT laws pass. These are separate finite/runtime and source-proof boundaries;
the full compiler code shape and initial request screen subsequently pass as recorded below.

Correctness input
[`held-controls01.bend`](../../selfhost/tools/performance/phase98/comparison/held-controls01.bend)
reuses all38 Phase88 strings and1,444 pair observations. It observes equality,
ordering, copied/shared inputs, lengths and codepoint sums after comparison.
Expected full stdout remains the qualified85,349-byte Phase88 product. The
proof lane is asked to cover exact D04 walker and new wrapper names, preserving
both roots and Boolean result. It must explicitly distinguish source preservation
from runtime lifetime correctness.

This candidate affects upstream-built native B1 and potentially own-built B2
through source. The own backend may not infer the same borrowing and needs a
separate emitted-code and timing gate. It is not an own-emitter-only change.

## Candidate B: direct recognizers for fixed equality literals

An offline token/parenthesis scan finds2,725 of2,891 compiler equality call sites
have an exact literal operand;425 distinct literals occur. Of these,1,403 sites
use three-character literals. Common literals include `All`183, `Lam`132,
`ADT`126, `Ctr`114, `Def`100, `Absent`96, `Mat`96 and `Var`95. These are static
site counts, not measured invocation counts or a timing attribution.

The safe helper for `Var` matches exactly
`SCon{Chr{86},SCon{Chr{97},SCon{Chr{114},SNil{}}}}`, otherwise False. It consumes or
borrows according to the existing compiler's ordinary rules. It does not compare
hashes, truncate characters, normalize Unicode or accept prefixes. The helper
source is [`literal-helpers01.bend`](../../selfhost/tools/performance/phase98/comparison/literal-helpers01.bend).

Root reports that the first standalone check/native control passes all ten full
products, including Unicode, mismatched suffixes and retained input. Actual C
`literal-smoke01/program.c:1300` lowers `p98_eq_var` to borrowed `term_peek` reads,
while the Unicode helper at1457 consumes via `ctr_take`: the latter is the last
comparison/use in the control. The contrast directly illustrates call-site
ownership inference. The control is finite evidence, not broad compiler timing.

[`prepare-literals.py`](../../selfhost/tools/performance/phase98/comparison/prepare-literals.py)
replaces only exact tokenized calls with a literal operand. It keeps comments,
unselected source, dynamic comparisons and escaped literals unchanged. Default
thresholds are at least two occurrences and at most16codepoints. It produces176
helpers covering2,460 call sites, with882 extra physical lines and53,775bytes.
The candidate is `selfhost/build/phase98/literal-source01/compiler.bend`, SHA256
`81cf0e9cc1789f81722f278849ba238e04fe786673c582bc420a2a6d5db58294`.
The receipt records every exact replacement and verifies forward/inverse replay.

This is useful as a mechanism ablation, but maintaining176 hand-authored helpers
would violate the simplicity goal. Prefer Candidate A if effective. A successful
literal experiment could instead motivate a narrow ordinary backend specialization
for exact immutable literal comparison, with the existing generic call as fallback;
that route would affect own-built B2/products, not upstream-built B1. Alternatively
an explicitly generated native build profile may preserve maintained source size,
but it adds a source-transport concept and requires honest reporting of generated
size. Neither integration choice is decided before measured benefit.

## Ranking and stop criteria

1. Held-root wrapper: broad equality coverage; the first measured ten-line variant
   reduces six-case request time by14.1%. A three-line variant removes its carrier
   type and has passed small controls/proofs; its real compiler timing is pending.
   Full image acquisition/build costs roughly four minutes. Further gain remains
   a hypothesis, limited to the removable part of ownership work.
2. Literal recognizers: broad static coverage but larger generated source and
   potential code size/checking cost. Use as fallback or independent ablation,
   then require compiler screens before expanding maintained architecture.
3. Restricted own-backend observation: only if source mechanisms cannot obtain
   correct borrowing. Requires owner-liveness, child nonescape and effect/fork
   obligations; cannot improve upstream-built native B1. No implementation here.

Neither helper ratios nor cleanup percentages justify promotion. Require the
six-source balanced screen with full C and diagnostics first; use full self and
broader products only after a material screen win. Preserve rejected controls,
all aliases and the historical pin. No canonical source or release promotion has
occurred in this lane at this report revision.


## Measured full B1 result and simpler derivative

The full held compiler keeps the private equality worker borrowed. Its `spin_4`
in `held-checked01/program.c` contains three static `term_peek` sites and no
`ctr_take`, `term_sink`, `term_keep`, `spare_free` or allocation. The outer
observe/finish calls carry original roots as flattened words and release them
once. Full source/C/acquisition pins and worker bodies are retained in
[`held-code-shape-full01.json`](../../selfhost/tools/performance/phase98/comparison/held-code-shape-full01.json).
This verifies that other compiler callers did not invalidate the ownership
inference seen in the small control.

The completed four-balanced-round, six-source native **B1** comparison at
`selfhost/build/phase98/held-screen01/report.json` passes all48 complete C outputs
and all48 complete diagnostics; its recorded inputs are unchanged. Both images
use the same upstream pin, Clang O2 policy, prepared cache and runtime/effects.
Request time excludes preparation, while process wall includes startup,
preparation, writes and teardown.

| Source | Baseline request median ms | Held median ms | Held / baseline |
|---|---:|---:|---:|
| small | 58 | 48.5 | 0.8362 |
| numeric_closed | 99 | 82 | 0.8283 |
| lexer_original | 357 | 318 | 0.8908 |
| map_closed | 1406 | 1292.5 | 0.9193 |
| functions65 | 227 | 190.5 | 0.8392 |
| unicode | 57 | 48 | 0.8421 |

The equal-case geometric request ratio is **0.85866**, a14.1% reduction;
process wall ratio is **0.91831**, an8.2% reduction. These are improvements over
our previous native B1, not ratios against upstream's TypeScript compiler and
not measurements of generated-program execution. Lexer candidate requests range
317–350ms, so retain all rounds rather than treating a single run as definitive.

The simpler candidate in
[`held-helpers02.bend`](../../selfhost/tools/performance/phase98/comparison/held-helpers02.bend)
uses `finish(same,left,right): same` and
`finish(p88_string_eq_go(a,b,True{}),a,b)`. It removes the carrier type and observe
function. The full derivative at `held-source02/compiler.bend` changes only the
public wrapper plus the finish helper: **+3 physical lines / +99bytes**, SHA256
`5debb63d0c3f2fdd2b096cff9fd30e6770c06438a26216e6daa3af9569b26c46`.
[`prepare-held-simple.py`](../../selfhost/tools/performance/phase98/comparison/prepare-held-simple.py)
records exact forward/inverse transport. Root reports1,444 native products and
four exact-source universal laws pass. Its public Boolean contract is unchanged;
the obsolete carrier's observation law disappears with the helper itself. Its full compiler screen subsequently passes as recorded below.

## Stage boundary: own C does not yet inherit the full mechanism

The own backend's pure control emits `NATIVE_READONLY_OBSERVERS=1` and an actual
borrowed `$observer.p98_eq_walk`. Its ordinary wrapper redirects shared roots
through an adapter and uses flattened product workers. This small successful
case does **not** justify a full native B2 speed claim.

The real IO control
[`held-io-smoke01.bend`](../../selfhost/tools/performance/phase98/comparison/held-io-smoke01.bend)
uses ordinary `IO.print_err` plus preserved string outputs. Its emitted C has
`NATIVE_READONLY_OBSERVERS=0` and `NATIVE_TYPED_SCALARS=0`, like the full native
compiler. There is no equality observer worker. The recursive walker contains
three static `ctr_take` sites and24 static sink sites; the held wrapper adds two
keeps and the finish helper later sinks the original roots. These are static
operation sites, not dynamic counts. The source change alone can therefore
leave B2 with the original consuming traversal plus extra ownership operations.
It needs a separately measured B2 gate before any stage-independent promotion.

Exact C/source pins and bodies are in
[`held-code-shape-own01.json`](../../selfhost/tools/performance/phase98/comparison/held-code-shape-own01.json)
and
[`held-code-shape-own-io01.json`](../../selfhost/tools/performance/phase98/comparison/held-code-shape-own-io01.json).
The current observer permission is coupled to the scalar/array whole-program
certificate (`back/native/request.bend`, `scalar-array.bend`, `book.bend`). A
future independent observer certificate must establish layout, child nonescape,
root liveness and effect safety. Flipping a global read-only flag would not
establish these obligations.

## Next bounded source experiment: fused tag observation

`tg(term)` returns an owned String projection and may visit/drop the other
fields of an8-field KTerm/KLambda or5-field KLiteral. Equality is only a scalar
observation, so a fused helper can keep the entire term alive until the Boolean
is known. It must still release the root afterward and cannot assume unique
input disposal is free.

The first tag helper uses private equality plus structural Lam/Lit recognizers.
Its first control context could poison the private walker's borrowing through
the old public wrapper; `tag-controls02` corrects that context but retains the
literal proof complication. Both are preserved, with no target result claimed.
The preferred
[`tag-helpers03.bend`](../../selfhost/tools/performance/phase98/comparison/tag-helpers03.bend)
uses the proved public held equality in **all three constructor branches** and
an ordinary three-argument finish. It adds no literal recognizer or carrier type.
The hoped-for code shape is borrowed access to the term, with at most a
retain/drop of its selected String field and no traversal of unrelated fields.
This remains a falsifiable code-shape and timing hypothesis.

[`prepare-tag-controls-v3.py`](../../selfhost/tools/performance/phase98/comparison/prepare-tag-controls-v3.py)
extracts the exact production datatype and tag projection into
`tag-controls03/{baseline.bend,candidate.bend}`. Its96 complete products cover
all three constructors, arbitrary generic tags, Unicode, empty/prefix/suffix
keys, children, removals, spans, quantities and literal payloads. Both versions
return the original term/key and two Boolean results; baseline computes the
reference twice. Require complete native stdout equality and actual borrowed
code shape before a full compiler derivative. The intended universal law is
`tag_eq(term,key) == p88_string_eq(tg(term),key)` for arbitrary terms and strings.


The bounded full derivative is now prepared, with no compiler execution by this
lane: `selfhost/build/phase98/tag-source03/compiler.bend`, SHA256
`21bfd3764a88286bae0f1538df1fd58c399429a936585bddf0ffe50cd6a86fce`.
[`prepare-tag-full.py`](../../selfhost/tools/performance/phase98/comparison/prepare-tag-full.py)
selects1,366 exact **left-operand** `p88_string_eq(tg(term), key)` sites. It preserves
operand order and all unselected text. The recipe starts from original D04,
replays the held-simple wrapper, then records descending source-offset call
substitutions and an explicit helper append as another ordinary offset change.
Independent forward replay and exact inverse recovery pass. Relative to D04 the
candidate has22 more physical lines but8,745 fewer bytes; relative to held-simple
it adds19 physical lines. This is one shared helper, not1,366 specialized helpers.

A possible maintained integration is one `k_tag_eq` helper beside `tg` in
`selfhost/src/core/term.bend`, using ordinary `String.eq`, plus exact corresponding
caller substitutions. The existing native assembly adaptation would map that
ordinary equality to the qualified held wrapper. This is an integration plan,
not an implemented canonical change: JS source/image timing and full own-C B2
qualification remain necessary because those backends need not infer the same
borrowing. Keeping the source transformation in an explicit native profile is a
narrow alternative if cross-target cost regresses. The candidate changes only
how a tag is observed and retains all term constructors/payloads; it does not
remove metadata or alter the KTerm representation.


The simpler full compiler now also passes the shape and real-screen gates.
`held-simple-checked01/program.c` uses `spin_3` at14239 with three `term_peek`
sites and zero ownership operations; `spin_5` at14288 drops the two original
roots after comparison. Exact pins/bodies are in
[`held-simple-code-shape-full01.json`](../../selfhost/tools/performance/phase98/comparison/held-simple-code-shape-full01.json).
Its completed48-request balanced screen passes complete C and diagnostic equality
with unchanged inputs. Equal-case geometric ratios are **0.856190 request** and
**0.917094 process**, a14.4% and8.3% reduction respectively. Per-case medians,
ranges and paired values are retained in
[`held-simple-screen-summary01.json`](../../selfhost/tools/performance/phase98/comparison/held-simple-screen-summary01.json).
The simpler version therefore preserves the measured benefit without a new
carrier datatype. No native B2 or whole-self speed conclusion follows from this
B1 screen alone.

Tag v3's correctness proof passes, but its emitted code **falsifies the proposed
whole-term borrowing mechanism**. `spin_4` takes all three term variants,
drops unrelated fields and frees their shells just like the original projection.
The owning public equality call propagates ownership of the selected child back
to the entire term. Exact code is preserved in
[`tag-code-shape03.json`](../../selfhost/tools/performance/phase98/comparison/tag-code-shape03.json).
The prepared full v3 source is retained without launching its expensive build.

Two tiny follow-ups preserve v3: `tag-helpers04.bend` calls the private borrowed
walker only for the generic KTerm tag, while static Lam/Lit branches use public
held equality; `tag-helpers05.bend` additionally holds the key through that private
call, preventing a last-use key in the generic branch from potentially poisoning
the shared walker's inference. Their96-product controls are separately frozen as
`tag-controls04` and `tag-controls05`. Neither changes the intended universal tag
law; each must first pass actual code-shape and native complete-product gates.


Tag v4 now passes the tiny emitted-code mechanism gate. In
`tag-control-checked04/program.c`, the private equality walker `spin_0` at1221
and the tag read `spin_4` at1304 each contain three `term_peek` sites and zero
`ctr_take`, `term_sink`, `term_keep`, `spare_free` or heap allocations. All three
term variants are observed without taking their fields. Exact bodies/pins are in
[`tag-code-shape04.json`](../../selfhost/tools/performance/phase98/comparison/tag-code-shape04.json).
The actual96-product runtime comparison and full-context inference remain separate
gates. The key-held v5 fallback remains prepared but unexecuted.

The full v4 derivative is `selfhost/build/phase98/tag-source04/compiler.bend`,
SHA256 `2811d3c3329587cbc2278f1ed5660986b6b3ebf9bccd9c50441c5a05f2e8a805`.
It has the same1,366 selected calls; relative to D04 it adds23 physical lines and
removes8,661bytes. Its helper is exact `tag-helpers04.bend`; the extra line versus
v3 is an explanatory comment. `prepare-tag-full-v4.py` records the same complete
D04-based composite replay and exact inverse, with per-module call counts.
This preparation alone does not claim a compiler speedup.


The full v4 acquisition also passes its shape gate, resolving the caller-context
uncertainty. `tag-full-checked04/program.c` has zero holes; `spin_2` at14269 reads
all three term variants through `term_peek` and never takes their fields. Its
generic branch calls the borrowed `spin_3` then releases the key once; no
unrelated term fields are dropped. The private equality worker remains three
peek sites with zero ownership operations. Exact bodies/pins are in
[`tag-code-shape-full04.json`](../../selfhost/tools/performance/phase98/comparison/tag-code-shape-full04.json).
Upstream therefore handles the key as a call followed by root cleanup; the feared
ownership poisoning does not occur in this actual full compiler. Full v5 source
is preserved as an unexecuted fallback at `tag-source05` (26 extra physical lines),
but its acquisition/build is unnecessary for the already obtained v4 mechanism.

## Separate scalar observation candidate

Actual held-simple compiler C still consumes all three term variants in `ix`
(`spin_8` at14418) and `qt` (`spin_9` at14473), each with three take and nine sink
sites. Scalar origin readers nearby already borrow; not every projection needs
the same treatment. Returning an ID or quantity does not require a child String
or List to escape, making these two a bounded reuse of the retained-root pattern.

[`scalar-helpers01.bend`](../../selfhost/tools/performance/phase98/comparison/scalar-helpers01.bend)
adds one shared `finish(value,term): value`, calls unchanged renamed readers while
holding the original term, and preserves public `ix`/`qt` signatures. The full
source derivative `scalar-source01/compiler.bend`, SHA256
`28ff9f5dc79b4c59ef9ca1d87170a0a79b681ae248b42943743f65b435f4699c`, composes
held-simple plus these two wrappers:14 extra physical lines versus D04,11 versus
held-simple. It does not rewrite callers. Exact replay/inverse and production
body extraction are recorded by `prepare-scalars.py` and `changes.json`.

The separately frozen `scalar-controls01` baseline/candidate return10 complete
records including original full terms, old/new IDs and quantities, and reads of
reconstructed expressions. Inputs cover every constructor, zero/U32-max fields,
Unicode, nested children, duplicate removals, spans and literal payloads. This
hypothesis has no execution or speed claim at this revision. The universal
obligations are equality of both projections for arbitrary original KTerm values;
actual borrowed C and native full-product equality remain additional gates.


## Combined equality and tag screen

The completed `tag-full-screen04` screen verifies48 full C outputs and48 complete
diagnostics, all against the original qualified products, with unchanged inputs.
The checked source is exact tag-v4 SHA256
`2811d3c3329587cbc2278f1ed5660986b6b3ebf9bccd9c50441c5a05f2e8a805`.
Four balanced rounds give:

| Source | Baseline request median ms | Held equality + fused tag median ms | Ratio |
|---|---:|---:|---:|
| small | 58.0 | 48.5 | 0.8362 |
| numeric_closed | 104.5 | 78.0 | 0.7464 |
| lexer_original | 356.0 | 302.5 | 0.8497 |
| map_closed | 1430.5 | 1208.5 | 0.8448 |
| functions65 | 227.0 | 184.0 | 0.8106 |
| unicode | 57.5 | 46.0 | 0.8000 |

Equal-case geometric ratios are **0.813832 request** and **0.878177 process**:
18.6% and12.2% less time than the original native B1. This combined candidate is
promising across all six sources. Its screen is separate from the held-simple
screen, so the difference between0.856190 and0.813832 is not a paired causal
measurement of tag fusion alone. All sample ranges and individual paired ratios
are retained in
[`tag-screen-summary04.json`](../../selfhost/tools/performance/phase98/comparison/tag-screen-summary04.json).
The independent exact-source tag proof at `tag-proof-check04` accepts six laws.
Native full-product controls, B2 inheritance and whole-self timing remain distinct
qualification stages.

A minimal stable release plan is recorded in
[`promotion-plan.md`](../../selfhost/tools/performance/phase98/comparison/promotion-plan.md).
It preserves the installed JS source/image and historical native07 launcher,
uses explicit native profile source replay, and proposes one stage-selectable
compact manifest only after actual source-bound B1/B2 gates. No public release is
admitted merely by this screen or by source proof acceptance.


The scalar candidate passes its first real gates: root reports10 native complete
records and two independent universal laws accepted. Full acquisition has zero
holes. `scalar-full-checked01/program.c` uses `spin_9` at14418 for the ID reader
and `spin_12` at14490 for the quantity reader; each has three `term_peek` sites
and zero take/sink/keep/free/allocation sites. Shared finish `spin_10` drops the
original term once after scalar evaluation. Exact C/source/body evidence is in
[`scalar-code-shape-full01.json`](../../selfhost/tools/performance/phase98/comparison/scalar-code-shape-full01.json).
This obtains the intended ownership mechanism in the full compiler context;
compiler speed remains unmeasured until its balanced screen.


## Public native host preparation

The proposed small host is now prepared at `selfhost/native.py` and
`selfhost/tools/native/{launch.py,assets.py,README.md}`. It consumes the admission
collector's agreed versioned schema and a separate explicit selection pointer.
No selection file/default has been created by this lane. Historical native07 and
the installed JavaScript release remain unchanged.

The launcher authenticates selected source/image/transport assets before and
after execution, preserves the existing resource guard and no-overwrite atomic
output behavior, and supports separately labeled B1/B2 argv conventions. The
archive method is an explicit derivative of the preserved Phase90 public-assets
code, with streaming full-byte hashes, exact modes/members, same-root restoration
and missing-only writes. It seals both qualified images and optional pinned
profile-reproduction inputs, without copying the large historical gate closure.

`comparison/public-host-preparation01.json` pins old/new methods and the exact
scope of preparation. Products independently reviewed the agreed schema against
its admission collector. Only Python3.9 AST parsing and data-shape review have
occurred; no fabricated release, target invocation, CLI pass or archive-restoration
pass is claimed. Actual completed admission, selected CLI controls and capsule
verification remain necessary before a new default can be published.

## Scalar screen and exact candidate composition

The subsequently completed `scalar-full-screen01` verifies48 full C outputs and
48 complete diagnostics with unchanged inputs. Equal-case geometric ratios are
**0.837655 request** and **0.956548 process** against the original native B1.
The complete medians, ranges and per-round ratios are preserved in
[`scalar-screen-summary01.json`](../../selfhost/tools/performance/phase98/comparison/scalar-screen-summary01.json).
The request result is modestly below the separate held-simple screen's0.856190,
but the extra11 source lines do not have a paired causal benefit established yet.
Tag-v4's separate0.813832 screen remains the stronger measured source candidate.

A generic exact-composition tool prepares tag plus scalar at
`tag-scalar-source01/compiler.bend`, SHA256
`76d00fc2b74c120f5b6815130b80dabcce16fe678755614f6850684cf5340fad`.
It shares the held wrapper once and adds34 physical lines versus D04. The fresh
`compare-candidates.py` derives the existing screen method to compare two
independently checked/built source candidates using the same complete C and
diagnostic oracles. Its offline preflight against actual tag/scalar acquisitions
passes; this is input validation, not a target or performance result. It supports
a direct tag-versus-tag-plus-scalar test before selecting that optional expansion.

The main qualification candidate instead composes the independently developed
observer-permission02 change with held-simple and tag-v4, without scalar:
`permission-tag-source02/compiler.bend`, SHA256
`59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714`,
1,754,058 bytes, **78 extra physical lines** versus D04. Its recipe applies the
seven exact permission definition edits first, then the held public wrapper and
finish, then1,366 left-operand tag comparisons and the tag helper definitions.
All1,375 edits replay sequentially and invert to the exact original source;
the private equality walker remains byte-identical. New permission helpers'
`String.eq` calls are preserved rather than silently normalized. These source
transport checks do not establish backend correctness or lifetime safety.
Actual-source proof extraction and whole-stage qualification remain separate
root-run gates. This source is an explicit native profile derivative; canonical
Bend modules and the installed JavaScript compiler are unchanged.

## Combined actual B1 code and reproducible profile

The actual combined upstream-built B1 acquires/builds successfully in
`combined-checked01` / `combined-b1.json`. Its17,724,799-byte C, SHA256
`5782601ed24d0215669e0fe27a62ff240c452219b510b9ab70c312645dc60767`, retains
byte-identical tag-v4 bodies for public tag equality,borrowed tag read,private
equality walker and tag finish. The walker has three peek sites and no take,
keep,sink,free or allocation sites; tag read borrows all variants and drops only
the key once after the generic comparison. Public equality finish drops the two
retained original strings once. Exact bodies,pins and static counts are saved in
[`combined-code-shape-b1-01.json`](../../selfhost/tools/performance/phase98/comparison/combined-code-shape-b1-01.json).
This confirms the B1 mechanism survives permission integration; it does not
establish B2 code shape,correctness or speed.

A compact public source replay now verifies the same final59b36 source from the
committed D04 capsule using15,554 compressed delta bytes and a1,851-byte manifest.
`selfhost/tools/native/profile.py` validates source/capsule/delta identities,
replays and inverses all1,375 edits and validates the final full source hash.
The data-only completed receipt is `selfhost/build/phase98/profile-replay01.json`.
The stable public CLI control method and final admission/archive command recipe
are prepared in the native host directory and `comparison/promotion-plan.md`.
No new default,public CLI pass or B2 admission is inferred from this preparation.

## Full-source resource stop and profile fallback

The first combined B1 self request reaches the declared 2GiB process-tree limit
at82.998s; the retained guard records SIGKILL and no completed C product. Root
also reports a separate 4GiB retry stopped at about101s. These are resource
failures, not accepted compilation or proof failures. The earlier B1 C mechanism
and six-source results do not establish that full-self observer emission scales.
The observer-permission lane is investigating repeated layout/planning work.

For attribution if needed, the unchanged ownership-table generator already
binds55 exact unwind rows to the current combined B1 ELF. The original sampler
flushes in its destructor, so it cannot recover data after an RSS SIGKILL. The
prepared fallback therefore reuses the already controlled Phase90 watchdog:
ordinary-thread exit77 at75s flushes the unchanged sampler, while the existing
4GiB/16GiB-headroom outer guard remains active. No new mapped format or
signal-handler I/O is introduced. Exact commands and current input pins are in
`comparison/ownership-prefix-preparation01.{json,md}`. Only root may build/run
this diagnostic. The unchanged strict stopped analyzer and ownership-window
reader retain the incomplete-compilation label and require zero sampling loss;
missing C is never counted as a pass. Preparation has run only ELF/table reads,
not a sampler build or compiler request.
