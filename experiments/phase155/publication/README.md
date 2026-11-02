# Phase155 publication tournament: IDs 05–07

Private Bend witnesses in `selfhost/tests/phase155/publication.bend`; production
source and its verifier are unchanged. The root owns checking and native runs.
This directory records hypotheses and finite controls, not successful results.

All six old/new entries take `+n: U32` and return a String. The observer emits
every KDef, index and KTerm field, with constructor tags, numeric delimiters and
length-prefixed strings. No ignored result, sampled lookup or checksum can hide
a changed final publication world. Input construction, publication, observation
and cleanup are part of each entry. Start with the spec's small finite controls;
the synthetic streams are not the actual full compiler publication trace.

## 05: canonical-state provenance

`selfhost/src/check/compact-schedule.bend:59` calls `p143cp_canon(book)` before
every non-childless fallback, even if the immediately preceding fallback left
the book canonical. A private bit distinguishes that state from the existing
childless-Def publication log. The candidate skips only redundant intermediate
canonicalization; it still calls original `p143cp_canon` on every exit.

The generated stream has a run of bodies followed by a run of ADTs. The first
ADT must flush the body log; later ADTs enter with clean provenance. Alternating
Def/ADT streams would flush each time and may show little benefit. The finite
prefix control finalizes after every event, modeling an outward failure boundary
without pretending to execute a full dependent checker.

Integration is not established: a real checker-state version must preserve the
bit through template insertion/restoration, specialization and failure worlds.
The replay creates the bit only after original `check_declarations`, never from
an arbitrary caller-supplied book. It retains the current cache/index exactly.

## 06: initial declarations, not deferred checking

`selfhost/src/check/kernel.bend:1127` maps each event through Foreign/declared
and calls `book_put`. The candidate does that same map, then existing
`book_put_many`, whose admission and sequential fallback already preserve cache
records, malformed-name demand behavior and exact publication/index ordering.
This is a precise reuse of an existing capability at a new call site.

The baseline's `index_put_rest` already avoids filtering on cached fresh-name
misses, so the realistic disjoint seed may make batching slower. Retain that
negative if observed; do not select an artificial all-overwrite workload merely
to manufacture a win.

Broader batching across successful checks is rejected. `check_declarations`
installs absent bodies; completed bodies become available only through the
sequential publication. `p155p_deferred_type(n)` compares Alias with Type0
before/after installing its completed body and must return `0:1`. Thus distinct
names alone do not establish publication independence. The full dependent
checker and its original final verifier remain untouched.

## 07: constructor-history metadata

`kernel.bend:1156` scans every non-cache event and its constructor children for
each membership query; `constructor_names` repeats this for each new constructor.
The private candidate maintains a collision-correct existing KDef index of
successful constructor names. It retains original local duplicate checks,
successful event-book updates, first error text and failure-prefix book.
All cache construction and insertion costs are paid, beginning from empty.

Only append-only, unique-owner ADT history is admitted. This component is not
an optimization of arbitrary checker-world lookup or type checking. Existing
`event_error` also enforces law/definition and duplicate-owner constraints; those
are outside this isolated membership workload and must remain on integration.

Blindly extending ADT logging or retaining membership after owner replacement
is rejected by `p155p_stale_adt(n)`, expected `0:1`: replacing A{Old} with A{New}
removes Old under ordinary `book_put`, but retaining the obsolete ADT row makes
`constructor_exists` find Old. `dg_family` also scans raw constructor families.
This is the source reason Phase143 allowed stale childless Def rows only.

## Evidence and ceiling

The prior audit is `research/phase143/checker-independent-audit.md`, especially
its canonical projection contract and raw ADT observer table. Existing batching
is `selfhost/src/core/index.bend:480–548`; no new global index policy is proposed.
Phase153 measured 33.568s for all checking/publication, with 243 named
book-finalization samples. That is a stage ceiling, not canonicalization CPU
time and not independent evidence for a 20% full cold-build gain. The earlier
Phase143 log optimization is already present and is the reference here.

Run metadata, hashes, exact comparisons and timing decisions belong to the root
campaign artifacts. No targets were executed during preparation.
