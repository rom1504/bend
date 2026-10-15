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
the obsolete carrier's observation law disappears with the helper itself. Its
full compiler acquisition/build/screen is pending at this revision.

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
