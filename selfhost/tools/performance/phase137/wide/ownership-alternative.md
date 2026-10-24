# Earlier constructor ownership facts: bounded alternative

This is a source-only investigation of qualified Phase134
`a0001924…fa19fb57`. No compiler change or target run is proposed as qualified.
The active borrowed-query/inliner experiment remains the first choice until
its measured result is known.

## The existing index is not the answer to this query

`nc_ctor_owned` (`native/identity.bend`) returns the `db` flag of the **first
top-level ADT** whose lookup-visible direct child has the requested name and
kind `Ctr`. A false flag terminates the search too. A nonconstructor child can
shadow a later constructor in that ADT without hiding a constructor in a later
ADT. Child `BookCache` changes the lookup operation itself.

`NativeCtorIndex`, built by `nc_ctor_index`, instead chooses the first constructor
in a depth-first walk over all definitions and children. It stores the child,
not its parent's ownership flag. It does not preserve the other query's
nonconstructor-shadowing rule. Reusing it directly is wrong for nested or
non-ADT constructors, duplicate child names and parent flags. Similarly,
`nc_default_ctors` is a runtime catalogue, not an ownership certificate.

Typed erasure sometimes already has the parent ADT. Its existing true-flag
fast path is present in `nc_erase_mat` and `nc_erase_annotated`. Replacing their
remaining global query with that parent's flag is not generally equivalent:
the legacy query's first qualifying owner may be another same-name constructor.
That shortcut needs an independently established uniqueness fact or fallback.

## Smallest useful alternative: an early immutable prepared view

Phase135 already has the exact ordered ownership summary and29 finite controls.
It conservatively refuses child `BookCache`, preserves first false, resets the
per-ADT child-name set, and keeps full names for hash collisions. Its late
attachment after `p112s_prepare` missed erasure and initial constructor-table
construction; its hosted results were mixed and it was not selected.

The next falsifier should reuse that semantic work, but attach the fact once at
`nr_prepare_annotated`, **after** source and annotation checking and **before**
`nr_walk` calls `nc_definition_plain`. Keep the original source book, bound,
paths, scope and compile-admission inputs unchanged. Pass a distinct prepared
view only to erasure and native preparation. A dedicated `nr_prepared` variant
can retain `NR_Request.source` exactly while constructing `NR_Request.book`
from that view and the same closure facts. This is an adapter experiment, not a
global `book_cached` change or a frontend cache.

The existing attachment needs care: `ns_attach_book` carries
`nc_ctor_prepare(view)` into its new native context, so a sidecar under the
existing constructor context can survive. In contrast `ns_source` deliberately
strips extra context. Insert **after** that stripping, and test every subsequent
context reconstruction. Preserve the original source index as the first cache
child and all unrelated context fields. Do not attach synthetic source rows or
change source checking, binder bounds, static IDs or final verification.

There is one further gap to cover explicitly: `p128raw_lower_request` builds
`nc_constructors(source,source)`, not from `request.book`. The early erasure view
alone cannot accelerate this call. A local request adapter can compute that
table with the prepared view while retaining original `source` for
`nc_compile_error_known`; its exact ordered constructor table must match the
original before proceeding. Do not claim complete caller coverage until this
bridge is checked.

## Keep the first implementation smaller than Phase135

Start with one-request build/use, not across-edit shape equality or a general
cache framework. Check metadata once at query entry, then use the unchanged
legacy loop on refusal; avoid recursively probing metadata at each visited row.
The Phase135 wrapper's repeated nested context extraction on ordinary books is
part of its measured overhead and must be charged.

An optional second discriminator is a **positive ownership-name set**. After
the exact ordered summary is constructed, false and missing both answer false,
so query-time representation need only retain names whose first qualified owner
is true. This can avoid returning a nine-field `KDef` merely to read one bit.
False rows must remain in the construction-time first-match certificate; they
cannot be discarded while resolving precedence. Count the actual positive set
before choosing a list or tree. A small set may be cheaper than the current
payload index, but its size and runtime benefit are unmeasured. This is a later
representation choice, not a hardcoded builtin-name list.

## Cheap decisive test and stopping rule

1. On the three existing checked requests, compare legacy and prepared ownership
   answers for every real constructor plus missing, duplicate, nonconstructor,
   child-cache, empty-name, collision and Unicode controls. Reuse the29 old
   controls rather than inventing weaker admission.
2. Compare exact closure names/erased bodies, original `NR_Request.source`,
   source admission result, ordered `N_Constructor` table and final QBE bytes.
   Prepared metadata intentionally differs; whole request-record equality is
   not the oracle. Preserve a refused-input fallback case.
3. Measure construction plus erasure and initial preparation on the same
   executable. Measure the actual complete request in both orders; do not quote
   summary lookup time or cache hit rate as the gain. A native extracted
   constructor-identity workload is useful before another full compiler image.
4. Stop if early callers still receive the raw book, if context reconstruction
   discards the fact, or if build/lookup/cleanup cost offsets removed scans.

Phase136's erasure interval is30.326s and raw lowering59.411s, but neither is
exclusively constructor ownership. The approximately7.9% active ownership
context overlaps physical reclamation and other caller costs. It is evidence
of a target, not a promised7.9% saving, and cannot be added to the lookup share.
The higher-value aim is to remove repeated whole-book traversal and repeated
ownership transfers, while the current borrowed-query work lowers the cost of
each remaining visit. Those benefits may compose; they must be measured together.

Source references: qualified Phase134 declarations `nc_ctor_owned`,
`nc_ctor_identity`, `nc_ctor_index`, `nc_ctor_prepare`, `ns_source`,
`ns_attach_book`, `nr_walk`, `nr_visit`, `nr_prepared`, `nr_prepare_annotated`,
`p128raw_lower_request`; prior implementation
`selfhost/tools/performance/phase135/preparation/ownership-v01.bend` and
`ownership-request-v01.bend`; measured frontier
`implementation/phase136/README.md` and `baseline/query-results.md`.
