# Phase155 independent screen audit

2026-11-02. Read-only review before native timing results. Reviewed the design,
all seven family specifications/readmes and their Bend kernels, preparation and
control/timing harnesses, and Phase153/154 evidence. No targets, compiler builds,
benchmarks, or production edits were performed for this audit. This document is
the only audit output. Concurrent additions were rechecked before writing it.

## Findings by transfer risk

**High — ID16 can reward work the canonical consumer does not perform.**
`selfhost/tests/phase155/pipeline.bend:p155b_16_before` always calculates clean,
size and stack on the same original body. Calibration increases body size;
at n=1024 the synthetic size has saturated at4096. However,
`selfhost/src/back/qbe/inline.bend:p113i_eligible` rejects size above512 before
stack, while `p113i_function` rejects size above2048 and checks stack only on
the subsequently rewritten body in `p113i_function_done`. A fused tuple win is
valid kernel evidence but cannot justify replacing these separated analyses.
An admitted-size consumer and preservation of the post-rewrite stack check are
necessary transfer conditions. Shared summaries must also be invalidated when
bodies change.

**High — publication05–07 depend on narrower histories than a full checker.**
`publication.bend:p155p_put_book` correctly flushes a dirty book before the
general fallback and `p155p_finish` retains final canonicalization. Its timed
sequence favors long consecutive ADT runs: ordinary definitions dirty the book,
the first ADT flushes it, and later ADTs benefit. Alternating definitions and
ADTs offers much less removable work. The replay does not execute checker-world
mutations, specialization, rollback, or full failure paths. In production,
`check/compact-schedule.bend:p143cp_publish` takes the checked result's world;
clean-bit provenance must account for that world, not just the submitted
definition. ID06 is limited to initial declaration installation with existing
`book_put_many` guards and ordering; it does not authorize batching completed
bodies. ID07 is a successful append-only ADT history, not arbitrary owner
replacement. Existing `p155p_stale_adt` and `p155p_deferred_type` counterexamples
appropriately demonstrate stale-constructor and publication-order hazards.
Full book serialization and prefix controls are good gates, but do not establish
full checker/error-world equivalence. No defect was found inside the stated
admitted replay cases.

A subsequent source-only census used the existing `maintained_assemble` and
`blocks` helpers, retaining manifest declaration order and checking the assembled
SHA against Phase152 qualification. The 3,085,157-byte source (SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`) has
369 types in 75 contiguous type runs: **294 type-to-type adjacencies**. Run-length
counts are 1:30, 2:15, 3:8, 4:8, 5:4, 6:3, 7:3, 9:2, 17:1, 159:1.
The largest run is `KTerm` through `P86Result`; the 17-type run is `N111Type`
through `P111ShowWords`. Grouped ADT exposure is therefore real. These 294
adjacencies are neither measured canonicalization calls nor proven removable
calls: checking between publications may alter the world, and materialization
cost varies. The census does not justify claiming all 369 calls can disappear.

**High — storage19–20 test specialization plus representation, not a general
persistent-map replacement.** `storage/README.md` accurately limits both to64
possible numeric keys, exact present scalar facts, no relations/predicates,
snapshots, joins, or ID-assignment cost. ID19 omits invariant metadata and mutates
after a scalar observation boundary. ID20 pays the same batch creation in both
roles and allocates/copies a fresh candidate buffer per merge; no omitted setup
or teardown was apparent. It also assumes already-sorted batches. After eight
batches all possible keys are populated, so larger calibration sizes chiefly
measure replacement workloads, not an indefinitely growing sparse map.
Snapshot cloning, arbitrary sorting and large-map/small-batch behavior remain
unmeasured. The combined image's actual array cell width, read transport and
copy-on-write behavior matter; `Array<U32>` and source affinity alone prove no
cheap-load path. A scalar-only standalone image would not be fair transfer
evidence. These restrictions are particularly important after Phase148's late
conversion failure.

**Medium — some query/render/frontend kernels deliberately amplify a narrow
operation.** ID10 supplies three layout consumers but has not identified a real
caller making that exact triple query. ID18 validates every lexer token, whereas
the parser invokes name validation only at relevant grammar positions. ID11
uses real constructor-name corpora but returns one complete string, unlike the
current bounded streaming emitter; it cannot represent all output work or the
40.99% allocation-call observation. ID13 caches only small selected owner-local
name sets and pays cache construction/search. ID09 may already compile into the
same borrowed query. Wins in these screens require actual call-count and native
code evidence before stage extrapolation.

**Resolved during review — native extras and facts equality gates.** Current
`experiments/phase155/bench.py` executes family extra checks natively before
selected cases and includes their results in the family gate. New
`facts.bend:p155f_controls` compares complete trie/cell structures, full names,
epochs and metadata, and checks absent queries. The earlier missing-native-extra
and checksum-only concerns therefore do not remain open. Timed facts checksums
are still lossy observations, not a proof of arbitrary equivalence. Finite exact
controls reduce that risk without proving all histories.

## Overlap and source-gain ceilings

IDs01–04 and19–20 use Phase154's private fact model, which was not selected for
the canonical backend. Phase154 measured13.02% on its selected compiler helpers,
2.36% on Map, and admitted only nine of twenty helpers. Those ratios cannot be
applied to an entire compiler stage. IDs01 and08 share the scalar-return
mechanism;02–04 eliminate overlapping reads, hashes and reconstructions;19–20
change the same fact-storage costs. Their gains cannot be summed. Publication
05–07 overlap checking/publication, and15/16 overlap lowering/initialopt.

Phase153's one diagnostic capture attributes39.27s to raw lowering,38.63s to
output/cleanup,33.57s to checking/publication and23.55s to initialopt. None is
entirely removable by these kernels. Named `book_final_*` contexts account for
243 sampling periods, approximately7.78s, within checking/publication; this is
an attribution clue, not a complete publication bill. The whole33.57s stage is
only an impossible upper bound of about13.5% against the separate249.222s cold
build. Conditional final verification9.22s is already included in the19.42s
composition/final-admission stage. Physical ownership/reclamation categories
overlap these stage totals and must not be added. Allocation-call percentages
are not elapsed-time percentages. The profile capture and clean cold build are
different observations, not a confidence interval.

## Best transfer candidates before timings

1. **ID15, shared `nc_uses`:** the duplicate is present in canonical
   `back/qbe/flat-products.bend:p113pl_bind_flat`; `back/native/bridge.bend:nc_live_env`
   recomputes uses for a nonempty environment. Reuse through `nc_live_uses` is
   localized and preserves the existing algorithms. The boxed path already
   shares uses and must not be counted again. The kernel still excludes most
   lowering work.
2. **ID08, scalar existing-index query:** compares against the actual indexed
   `p111v_get`, preserves collision/legacy/missing cases, and avoids an invented
   linear baseline. Native scalar transport remains the decisive uncertainty.
3. **ID05, redundant canonicalization:** credible only after real publication
   event order and clean-state provenance establish meaningful clean runs.
   IDs01/04 are useful subsequent discriminators inside the unselected Phase154
   branch, not immediate production improvements.

The same-executable, complete-child timing design is appropriate for a screen.
Setup, rendering and destruction remain charged. Default three alternating pairs
do not perfectly balance order; the5% classification threshold is descriptive,
not statistical significance. Calibration changes different workload dimensions
across ideas, so compare each pair at its recorded n rather than ranking raw
seconds across IDs. Keep source rejections12/14/17 as negative evidence, not
timed wins or universal impossibility results. No result here alone justifies a
full self-build; a favorable screen supports a bounded actual-consumer transfer.

Sources: `design/phase155/README.md`; `experiments/phase155/*/{README.md,spec.json}`;
`selfhost/tests/phase155/*.bend`; `experiments/phase155/{prepare.py,controls.mjs,bench.py}`;
`implementation/phase153/README.md`; `implementation/phase154/README.md`.
