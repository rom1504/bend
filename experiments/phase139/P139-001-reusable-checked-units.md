# P139-001 — Find a real reusable compilation unit

Status: source investigation complete,2026-10-25, at `df803e9`.
[Options](../../design/phase139/compilation-speed-options.md) ·
[Dedicated investigation](../../research/phase139/reusable-checked-units.md) ·
[Offline inventory](../../research/phase139/inventory.json).

Validation plan added at the user's request after `b392fb5`:
[intermediate gates](../../design/phase139/validation-gates.md). Start with
20–60s contract controls and a 60–180s complete small-request screen; escalate to
real 2× and then 5× warm-build milestones on substantive edits. Compare incumbent
ordinary, candidate cold and candidate warm builds of the same edited revision.
Default program-runtime regression limits are 2% overall, 2% per family and 5%
per case, with focused confirmation of flagged results. Charge acquisition and
qualification explicitly; reuse runtime evidence only through established exact
artifact identities. These are prospective gates, not newly executed results.

Hypothesis: early semantic reuse plus stable named owner output offers the most
credible5× local-edit rebuild path. Existing source modules and object groups
may not have the semantics required for independent compilation.

Investigate exact checker prefix dependencies, source organization, native
erasure/lowering boundaries, global identities and machine-unit linking. Reuse
Phase132–138 frozen evidence. Run only bounded offline source/artifact analysis;
no compiler edits, target benchmarks or new self-host qualification.

Falsifiers: a hidden suffix/body dependency invalidates the proposed prefix;
changed global IDs force near-total output regeneration; most weighted work
belongs to one inseparable unit; or fixed checks exceed the budget. Negative
findings should narrow the first experiment rather than weaken correctness.

Findings: textual header equality plus an unchanged maximum binder ID is
insufficient: global freshening can renumber intermediate types. Ordered actual
post-freshening declaration projections, complete checker state and revision-B
completion form the conservative candidate contract. It is not yet proved or
implemented. Existing Base-prefix machinery is not a substitute.

The QBE image has63,377 functions,49,013 dispatch entries and46,071 static words.
Static values are heap-relative tagged integers; ordinary linker relocations do
not resolve them. Separate reusable named semantic products from bound machine
artifacts. Stable per-epoch slots need capacity/compaction rules and current
cross-unit verification. Source provenance paths do not form contiguous semantic
modules. All counts are static inventory, not runtime or dirty-work estimates.

Next: bounded exact checker checkpoint and one actual prepared/lowered owner;
decode historical literal shifts before a stable-binding implementation. No
compiler/target run, new proof, promotion, speed result or production change.
