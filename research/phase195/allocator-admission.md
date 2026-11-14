# Exact allocator admission and the 1024-row experiment

Read-only audit of root-owned `allocation-capture01`, `budget-dev-emit01`
and `budget-dev-build01`. No target ran during this audit. The capture invokes
the unchanged allocator at final ordinary/float placement and records its
post-validation route; it does not execute or time the resulting programs.
Its manifest binds the Phase194 selected-source02 snapshot and the four
diagnostic overrides. All five requested cases completed.

| Case | Joint / total | Legacy functions: final placement rows |
| --- | ---: | --- |
| ray64 | 181 / 184 | product.trace 592; direct.pixel 426; direct.trace 613 |
| editdist | 216 / 216 | none |
| tree-bitonic | 248 / 248 | none |
| lexer | 233 / 233 | none |
| Map churn32 | 633 / 637 | direct.Map.ins.go 2695; put.go 1210; seek.go 1299; pop.go 1180 |

All seven legacy bodies pass the safety predicate. The ray functions have
239/238/245 eligible names respectively, but the unchanged graph admits at
most32 candidates. The source-only gate change to1024 therefore reaches these
three ray functions and none of the Map fallbacks. A512 bound would reach
pixel alone. Map borrowing is already selected: `$p118borrow.read.Map.bit.go`
is joint,74 rows,32 eligible names. The giant generic Map fallbacks are not
evidence that the hot bit traversal is unallocated.

The final float pruning materially changes the earlier hypothesis: ray
`$product.nearest`, `$direct.nearest.t`, `$direct.nearest` and `$direct.isect5`
are already joint at189/175/207/60 rows, with119/113/125/53 eligible names.
The two editdist `$product.row` owners are already joint at167/99 selected
rows, with102/75 eligible names. These facts supersede the older preselection
row counts as evidence of actual admission.

## Actual emitted change, not a presumed benefit

Comparing function assembly bodies from Phase194 `final-dev-emit01` to
Phase195 `budget-dev-emit01` finds exactly three changed functions across the
six development cases. Numeric, local-pair, tree, editdist and lexer function
bodies are unchanged. Ray changes are:

| Function | Instructions before → after | Explicit RBP/RSP references before → after |
| --- | ---: | ---: |
| product.trace | 1978 → 2056 | 690 → 853 |
| direct.pixel | 1594 → 1600 | 456 → 424 |
| direct.trace | 2060 → 2138 | 730 → 890 |

Counts use indented assembly instruction lines and explicit `(%rbp)`/`(%rsp)`
operands. They exclude implicit stack accesses and are neither executed
instruction counts nor memory-stall measurements. The root's build/oracle
checks pass; no runtime speed claim follows from that.

The fallback already gives product.trace146, pixel145 and direct.trace144
region-local transient homes, plus four saved-register homes each. Joint
allocation selects at most32 names across the function. Thus broadening its
gate can trade extensive short-lived register coverage for fewer globally
coordinated homes. The increased trace stack references are a concrete warning
against assuming that joint admission monotonically improves allocation.
Float XMM placement can supersede these GPR homes; home counts alone cannot
measure executed bank transfers or spills.

The separately qualified pooled physical profile in
`profiles/priority-findings.md` assigns product.trace10.55% and pixel4.47%
of ray64 CPU time; direct.trace has no reported samples. The nearest owners
already admitted together account for51.62%. About15% observed physical leaf
share is a prioritization estimate for the budget experiment, not a hard
removable-time ceiling: caller/child behavior and layout can change. Even
removing all that share would only suggest roughly1.18× on this case, not
suite parity. The table helpers'22.78% share is a stronger independent target.

## Decision

Keep the1024 joint-only prototype bounded and measure it before adoption;
retain the original legacy allocator and32-bit masks. At fixed32 candidates,
the main graph scans are proportional to body rows times a bounded candidate
or fixed-point count, not intrinsically quadratic in body length. This does
not establish acceptable compiler cost on every1024-row function. Changing
32 to64 alone is incorrect: masks, graph operations, coloring and affinities
require a new representation. Even a correct wider graph needs a profitability
policy because unchosen names currently lose the fallback's regional homes.

The highest-value allocator follow-up is preserving regional allocation for
unselected names while respecting the joint graph's live ranges, or improving
candidate pressure in the already-joint hot owners. Neither is authorized by
these finite observations as a source change; both require a clobber witness
and comparison against the existing checked fallback.
