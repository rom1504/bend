`rle.c` implements `p93.value` / `main.out` from
`selfhost/tools/bench/catalogs/native45/fixtures/test-rle-roundtrip.bend`.
The two API words are unused because the Bend entry also ignores them. Each call
constructs the six-element input list, encodes runs using a reversed pair list,
reverses that list, counts the runs, separately expands `repeat`/`concat` lists,
and consumes the expanded list through the wrapping U32 decimal digest. The
comparisons against three runs and digest 777299 are the original program's
internal checks, not an inserted benchmark result. Every list node is freed.

`unicode-text.c` implements `bench(size,seed)` from the native45
`coverage-unicode-text-16.bend` and `coverage-unicode-text-64.bend` fixtures.
Their executable bodies are the same; runtime size and seed select the point.
It constructs the comma-separated input block, repeats the full code-point
string, forms the intermediate list of split strings, then joins with `|`.
The split is the fixture's right fold, including the trailing empty part and
the single empty part for empty input. No byte-oriented character replacement
or precomputed output is used. U32 decimal formatting follows current
`bend2/base.bend` `U32.show` (division/remainder by ten, zero as one digit), and
append follows its `String.append` left-list traversal.

Both use malloc-allocated native C structs with null list terminators and
uint32_t scalar fields. Uniquely owned lists are reversed, concatenated, split,
and joined by reusing their nodes, without runtime tags or reference counting.
The kept repeated Unicode block is copied on each append. These explicit C
layout/ownership choices differ from Bend's generic runtime representation;
the comparison therefore includes representation and allocation management,
not solely instruction selection. Unicode strings remain linked code points
internally. A final pass allocates and encodes a malloc-owned UTF-8 result for
the C driver, then frees all internal nodes; the driver must free that result.
No live allocation is retained across calls. Allocation failure aborts rather
than returning a fabricated result. Recursion depth for split/join follows the
finite fixture size, so this is not a new unbounded-input stack guarantee.

Suggested root-lane corner checks (not executed here): Unicode sizes 0, 1, 2,
16 and 64 with seeds 0, 9, 10 and UINT32_MAX; verify empty input, the final bar,
and correct two-/three-/four-byte UTF-8 for alpha/beta, CJK and apple. For RLE,
verify the normal result under multiple ignored API arguments and use a small
test harness around the internal functions for empty/singleton/all-equal and
alternating lists. Run repeated calls under a leak/UB checker separately from
timing. Neither source includes a main function or benchmark timing logic.
