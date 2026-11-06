# Bounded String representation follow-up

Read-only source/profile audit, 2026-11-06. No target ran. A cheaper String
representation is a real architectural option, but the current evidence does
not support claiming it alone can remove the roughly 80 seconds needed for a
100-second cold build.

## What the implementations actually use

Our QBE runtime represents `SCon` as an ordinary two-field constructor:
code-point word and tail Term, with a separate RFC cell when sharing requires
one. A Char is already a scalar; there is no extra boxed Char to eliminate.
`runtime.c:2543` converts a String to UTF-8 by `ctr_take` plus `spare_free` for
every character. Names and term tags are Strings in `core/term.bend:6–12`;
`index_hash` traverses characters once per query, and the index stores its
32-bit hash/masks. `p88_string_eq_go` and `p98_tag_eq` already have borrowed
generated readers. Literal strings are already represented in static data.

The pinned bendc implementation **also uses linked code-point Strings**.
`rt/bendrt.h:3240` defines `SCONS(h,t)` as `C2(1,h,t)`, and `C2` allocates three
words: header, code point and tail. `mk_str` builds these nodes; `str_to_c`
traverses them. `BEND_NATIVE_STR` selects borrowed `str_cmp`/`String.eq`, not
packed byte strings. Its comparison loop directly reads the code-point and
tail fields. Literal `STRC` caches are shared/immortal. This is an execution
and ownership difference, not evidence that bendc's speed comes from a flat
String representation.

The retained [Phase166 machine comparison](../phase166/code-shapes.md) finds
our equality reader at 220 instructions versus bendc's 52, and hashing at 71
versus 20. Our readers have representation/RFC checks and explicit scratch
frames; both are already loops. The [Phase165 reciprocal experiment](../phase165/transfer-note.md)
copied our exact non-reconstructing equality into bendc and found only a small
whole-checker change. Repeating a native-equality proposal is therefore weak.

## Actual observed cost and the missing bound

The valid Phase171 full profile has 631/5584 samples (11.30%) in the explicitly
named string/hash readers. Of those, 355 land in `p88_string_eq_go`. These
counts exclude String construction/destruction hidden in generic runtime
helpers; they do not establish an inclusive String cost.

The separate valid caller capture attributes 273/5429 samples (5.03%) to
`String.append` or its immediate observed runtime callees. In rendering,
183/960 samples (19.06%) belong to that subset. The entire rendering/output
window is 31.94 seconds; parse/load is 30.52 seconds. These are diagnostic
clocks, not clean predicted savings. Do not add percentages from different
captures or attribute all generic take/drop work to Strings.

Even eliminating all named reader work is far short of 80 seconds. A broader
representation could also remove allocation, destruction and conversion, but
those additional costs remain unattributed. There is currently no defensible
whole-build ceiling for changing all Strings, and no evidence that most of the
25.5% lifetime or 20.3% product sample groups are String-specific.

## A concrete architectural option

Separate three semantic domains that currently share the same linked type:

1. **Source text:** one immutable code-point/byte backing store plus offsets,
   retaining exact Unicode and UTF-16 diagnostic positions. Lexing moves an
   offset rather than maintaining a shared tail for every cursor.
2. **Identifiers:** canonical IDs assigned once, with a retained spelling table
   for diagnostics/output. Equality and keys use IDs throughout their lifetime,
   not String-to-ID conversion at every lookup. This must span a complete
   producer/consumer boundary to beat the already hashed index.
3. **Generated text:** immutable fragments or a bounded builder passed to output
   without repeatedly constructing and consuming per-character linked nodes.

This is more feasible incrementally than replacing public String everywhere.
Existing arbitrary `SCon` matching, persistent tails, shared aliases, static
images, effects, generic runtime walkers and foreign ABI all constrain a global
flat-String change. A slice descriptor allocated on every tail operation would
merely replace one allocation with another. An ordinary `Array<U32>` is not
automatically compact here: the current compiler descriptor has capability 5,
with scalar-array specialization disabled. Physical representation must be
demonstrated, not inferred from the source type.

## Earliest useful 20-minute falsifier

Start with the already extracted real-verifier QBE renderer, not the tiny-book
lookup fixture whose names are constants. Preserve the current final verified
IR and the exact full output oracle. Add a bounded fragment-preserving emitter
for one complete output operation (argument/line groups through the existing
function writer), charge fragment construction and final destruction, and
batch writes. Compare complete rendering plus output, code bytes, peak memory
and actual output identity. Do not emit one syscall per tiny fragment.

The falsifiable question is whether avoiding intermediate linked text across
that whole boundary wins substantially after conversion/output costs. This is
distinct from already implemented whole-program streaming and tail-recursive
append, and from the neutral `render-clean` predicate-sharing experiment.
If building even that complete boundary exceeds the short budget, use existing
profile/caller data to specify it; a partial `append` microbenchmark must not be
promoted as whole-render evidence.

A large render win would justify extending the same private text abstraction,
then a source-reader span experiment with complete parser-result comparison.
It still cannot by itself reach 100 seconds: rendering is only about 18% of the
current diagnostic request. To justify a global String rewrite, first attribute
SCon-specific allocation/take/reclamation across frontend and backend with
scoped counters or supported caller recovery; generic helper totals are not
enough. Keep instrumentation timing separate from clean paired measurements.

Recommendation: retain this as a cross-stage structural candidate. Prefer the
small complete fragment boundary first, and do not repeat equality, naive
chunk reversal, already present streaming, or name-cache experiments under a
new String label.

## More economical new hypothesis: avoid wrapping static children

The coordinating agent subsequently identified a narrower representation
boundary worth testing before a String rewrite. `rfc_seal` wraps a raw
constructor even when its location is in immutable static storage; `term_keep`
already treats that static value as trivial. Thus repeatedly storing literal
tags/names into hot compiler records can allocate wrappers for immortal data.

This pattern is inherited: pinned upstream `comp.ts:3891` and the mature C
`runtime/native/runtime.c:739` contain the same seal condition. By contrast,
bendc's cached literals are marked immortal under RC (`RC_STICKY`,
`rc_immortal`) or shared under tracing; publishing them does not create a
separate wrapper per parent.

The current runtime's `span_fade` already accepts raw static children through
`term_triv`. Raw static `ctr_take` returns a static payload location, and
`spare_free` declines to reclaim it. These source facts support an independent
audit of omitting redundant static sealing; they are not complete qualification
of all runtime and optimization consumers.

A bounded offline sum of the Phase171 caller matrix finds 51 physical samples
in `rfc_wrap`, plus 73 in `heap_alloc` with `rfc_wrap` as the immediate caller:
124/5429 = 2.284% disjoint sampled CPU. Static versus dynamic wrapper creation
was not recorded. Wrapper-induced later take/drop/bump work is additional and
unattributed. Do not advertise 2.284% as a predicted gain or a complete ceiling.

The inspected Phase163 cold-constructor result is a different experiment: it
derived unshared constructor facts and skipped publication sealing for those
constructors. No retained static-only seal omission was found in the bounded
Phase163/169/171 search. This narrow allocation-removal hypothesis is cheaper
and more directly falsifiable than introducing a new String representation.
