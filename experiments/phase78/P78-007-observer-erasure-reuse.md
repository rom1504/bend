# P78-007: retain pre-compaction bodies for observer analysis

Fresh attribution identifies observer routing as a large remaining cost.
Inspection found a concrete repeated pass: symbolic helper expansion calls
`nc_definition_plain`, re-erasing an annotated definition on each expansion.
The request already produced exactly that erased body, but static preparation
replaces its fact with the compacted body. Observers intentionally need the
pre-compaction form for typed literal/origin analysis.

Keep the original erased fact as a child of the private static fact. Add a
separate source-body query used only by observer expansion and its root. It must
fall back to ordinary erasure when no matching original fact exists. Foreign
bodies retain their fresh-counter-dependent construction. Raw compiler requests
still clear caller-supplied payloads. This is request-local retained work, with
no additional preparation or benchmark-contract change.

Require exact C, fresh paired timing and raw/observer controls. Profile repeated
erasure only for attribution; cold JIT placement may limit the expected gain.
