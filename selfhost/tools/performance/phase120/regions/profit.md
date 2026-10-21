# Region04: fixed arithmetic-prefix selection

This is one optional selection experiment on region03 with the corrected
constructor-ID controls. It does not change semantic eligibility, the original
private-graph verifier, rendering, ABI, four-site limit, 1024 added-node budget,
or stack limits. The only existing declaration replaced is `p120nr_table`.

Root's checked-source inspection found copy costs of 295 for the arithmetic
leaf and 224, 324, 191 and 211 for four branch-oriented selectors. Region03 copies
the arithmetic leaf once, then two selectors, leaving insufficient budget for
the second identical 295-cost call. Two arithmetic copies cost 590 and fit the
existing budget. These are actual Bend planner costs in
`selfhost/build/phase120/region-inspect04.json`, not estimates from rendered C.

The new table requires both the unchanged safety predicate and four exact F32
add/sub/mul/div operations in the unconditional scalar prefix before the first
structured branch or transfer. IDs 26–29 count; conversions, comparisons and
sqrt do not. Numeric instructions below branches do not count. This selects
work guaranteed to be exposed at each copied call rather than crediting the
sum of mutually exclusive arms. It also gives the lane renderer a straight
arithmetic prefix in which conversion reuse is possible.

Four is a fixed experimental work floor, not a proven profitability threshold
or a calibrated runtime cost model. No threshold search or function-name rule
is performed. The existing exact copy cost still caps total growth. The smallest
falsifier is that the intended two arithmetic calls remain, or that their removal
does not improve complete-output paired runtime enough to justify the code.
There will be no automatic follow-on threshold variants in this experiment.

`profit-controls.mjs CHECKED_API FRESH_REPORT` separates safety from selection:
small safe leaves and branch-only work remain semantically eligible but absent
from the candidate table; a profitable unsafe leaf remains refused. It checks
the 3/4 boundary, arithmetic catalogue, branches and joins, CtorId, unchanged
argument order and growth/site fallback. The original `controls.mjs` expansion
tests remain attached to region03 because they intentionally assume every safe
leaf enters the table. The corrected nine CtorId controls are still included.

Only authenticated compiler APIs and ordinary source programs may qualify this
profile. Reflected finite controls do not constitute a source/ownership proof.
All compiler and native execution remains owned by root.
