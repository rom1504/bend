# Phase184 handwritten C text/map counterparts

These seven C translation units cover the ten entries in `mapping.json`.
Each is compiled separately with the root-owned driver in another translation
unit, C11, `-O3 -ffp-contract=off`, without LTO. There is no main or timing loop
here. `bench_u32(a,b)` returns U32; `bench_text(a,b)` returns malloc-owned UTF-8
without a trailing newline. The driver must free every returned text. Include
`base.h` in the frozen source closure of the five translation units that use it.
The Unicode and RLE units are self-contained. Nothing is cached across calls.

Sources are the identically named fixtures in
`selfhost/tools/bench/catalogs/native45/fixtures/`, interpreted at `p93.value`
before the shared benchmark validation/timing wrapper. Current library semantics
were read from `bend2/base.bend` at repository HEAD `cdf90a7` (upstream language
`9a4223d577ba56a0cb53d1fd952d2b481c38930f`), especially `String.append/split/join`,
`Nat.read`, `U32.show/read`, `Array.swap`, and `Map`/`Set`. The catalog's fixed
runtime arguments are not hardcoded in the size/seed families; their two points
share the same C file. The four original programs ignore both words because
their Bend `p93.value` does too.

## Operations and invariants

* `morning.c`: two map insertions and default lookup; actual split and join;
  codepoint length; U32 arithmetic and conditional; construction and length of
  the word list; decimal conversion, small Nat multiplication, concatenation
  and final seven-part join. It does not return the complete expected sentence.
* `evening.c`: sets and decimal keys, default map lookup, decimal U32/Nat reads,
  retained pair projections and a binary F32 array. Each `swap` computes array
  size, masks the index, descends and returns the previous value. Arithmetic
  uses `float` operands and the caller's disabled contraction policy; no double
  arithmetic substitutes for F32. The source's checks form the returned number.
* `map-set-ops.c`: constructs the actual pair lists; tests found/missing/default
  lookups, prefix-key deletion, successful and repeated pop, right-biased union,
  sorted keys and values, duplicate set insertion and deletion. It preserves
  the fixture's internal predicates, including ordered-key strings and digit
  checks. These predicates are part of the program, not a copied final oracle.
* `map-churn.c`: fills all keys, replaces every third entry, removes every
  fourth, materializes the complete ordered entry list, and hashes every
  codepoint/value. Addition/multiplication/XOR are uint32_t and wrap modulo
  2^32. Loop-count expressions wrap before division, just as U32 expressions do.
* `record-aggregation.c`: first materializes every `(Unicode key, decimal
  amount)` record, then separately parses and aggregates it through get/set.
  It converts the final map to an ordered entry list and renders every entry.
  It does not replace the map with a sixteen-element array or bypass parsing.
* `unicode-text.c`: constructs the Unicode/decimal input block, repeats the
  full codepoint string, performs the fixture's right-fold split including the
  trailing empty part, and joins with a separator. UTF-8 encoding is a final
  boundary pass; alpha/beta, CJK and the supplementary apple remain codepoints
  during the algorithm. See `NOTES-text.md` for the detailed correspondence.
* `rle.c`: constructs the input list, accumulates reversed run pairs, reverses
  them, separately counts runs and expands repeat/concat lists, then digests
  the expansion. The original internal three-run/digest predicates remain.
  No final expected benchmark result is substituted.

`base.h` uses the same crit-bit tree algorithm as Base, not a hash map or search
tree alternative. Each codepoint contributes a presence bit followed by its 32
bits from most to least significant; absent suffixes have zero bits. This makes
prefix keys precede their extensions, and traversal orders by Unicode codepoint.
`set` performs the separate seek and put/insert descents; new branches splice at
the first differing bit. Pop collapses an emptied branch. Traversal visits high
before low while prepending, producing ascending order. Union inserts the
right map's ordered entries into the left map. No sorting pass is substituted.
Keys remain linked codepoints, so bit lookup walks the key prefix as in Base.
U32 parsing retains Base's exact wrapping digit arithmetic and quotient guard.
The Nat parser enforces the current 48-bit limit; only small Nat values are
needed by the fixed programs.

## Representation boundaries

The implementation retains the source algorithms and intermediate collections,
but uses native C structs, null list/tree terminators, uint32_t words, native
bounded integers for Nat and manual ownership. Unique list cells and tree paths
are mutated/reused in place; lookups borrow their input key and map instead of
transporting ownership through returned tuples. Kept strings are explicitly
copied where construction needs a second owner. There are no tagged generic
values, reference-count traffic or runtime dispatch frames. Therefore ratios
include representation, ownership, allocation and compiler differences; they
must not be presented as isolated instruction-selection headroom. The crit-bit
algorithm and codepoint representation remain matched. Set Unit values occupy
an ignored U32 field in this C representation.

All intermediate lists, strings, records, map nodes and F32 array nodes are
reclaimed each call. Returned UTF-8 is the only remaining allocation. Allocation
failure aborts; it never returns an oracle or a partial successful result. Fixed
valid UTF-8 source literals are decoded by the shared helper; no general invalid
UTF-8 input contract is claimed. Recursive splitting/joining/rendering retains
finite fixture stack bounds rather than introducing an unbounded-input promise.
C optimization may fold source-constant arithmetic; no artificial volatility
or hidden cross-call cache is added to prevent ordinary optimization.

## Root-lane checks to run

No C compilation or target execution was performed by this implementation task.
Only file/mapping integrity and source review were performed. Root must run the
ten frozen full-output oracles before timing. Suggested additional cases:

* Shared map helper: empty key, prefix pairs (`app`/`apple`), duplicate overwrite,
  absent deletion/pop, right-biased duplicate union, Unicode keys across BMP and
  supplementary ranges; verify exact ordered keys/values and tree collapse.
* Churn: sizes 0, 1, 2, 3, 4, 5 plus both catalog sizes; seeds 0 and UINT32_MAX.
  Record aggregation: sizes 0, 1, 15, 16, 17 plus both catalog sizes, including
  a seed near UINT32_MAX to exercise wrapped key/amount arithmetic.
* Unicode: sizes 0, 1, 2, 16, 64 and seeds 0, 9, 10, UINT32_MAX; check empty
  result, trailing separator, codepoint handling and decimal width.
* Original fixed programs: repeat with different ignored arguments. For RLE
  helpers, empty, singleton, all-equal and alternating input lists; for the
  array helper, masked indices and returned pre-swap values.
* Repeated calls with leak/undefined-behavior instrumentation in a separate
  correctness job. Keep these diagnostics outside measured runtime batches.
