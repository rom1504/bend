# Crosscutting capability: root-tied descendant results

Source/machine-shape audit only; no target executions. The strongest still-open
capability is a read-only selector returning a descendant of a held input root,
with one explicit ownership promotion at the public boundary. This is materially
different from the existing scalar observers, shallow field projection, source
fusion and owning index zipper. **A 30% whole-compiler gain is not established or
currently justified by attributable samples.** The capability merits one small
complete lifetime experiment; its crosscutting potential is larger than another
single-stage scan cleanup.

## What is still missing in the actual installed code

The exact Phase170 N2 QBE, SHA256 `661b6266…`, has no borrowed worker for
`lookup`, `index_find`, `index_bucket` or `p111v_get`. A streamed inspection found:

| Actual private worker | QBE line | Static runtime boundaries |
| --- | ---: | --- |
| `index_bucket` |187161|6 sink,2 keep,1 take2|
| `index_find` |187253|32 sink,1 keep, take9/take2/take4,2 ctor2|
| `lookup` |212405|10 sink,3 keep,1 take2|
| `p111v_get` |215603|1 keep, owning hash, owning index_find|
| `p111v_capacity` |240932|owning get followed by dx;2 sinks and1 take1|

These are static sites across different branches, not executed call counts.
The equality/hash borrowed readers already exist, at QBE9205/8448. Equality has
250 QBE lines and hash101; their2KiB scratch reservations are stack space, not
heap allocation. Removing their scalar guards alone is a small opportunity.

Current source `core/index.bend:116` consumes each index node and walks selected
children. `index_bucket` selects a complete KDef. Source
`back/qbe/verify-segments.bend:3` returns that owned record before scalar consumers
such as capacity/kind/width checks inspect it. Similar book/AST selectors occur
outside final verification, so the opportunity is not bounded to its12.04s
combined verifier intervals. Its actual whole-process coverage remains unknown.

## Why earlier negatives do not falsify this

- [Phase131 selector boundary](../../research/phase131/verifier-boundary.md)
  explicitly identified the missing returned-descendant lifetime contract.
  Its scalar-consumer placement experiment retained owning selector traversal;
  6.26%/0.52% gains did not test a borrowed selector.
- [Phase166 machine comparison](../phase166/code-shapes.md) found the complete
  lookup fixture 3.46× slower than bendc, with QBE constructor/take boundaries and
  explicit ownership. However its full-record digest consumer dominated much of
  the experiment. That ratio is neither a lookup-only ceiling nor a whole-build
  forecast. Do not reuse that large consumer as the primary new timing boundary.
- Phase169's owning field-projection replay did not eliminate deep traversal
  ownership. Phase164's explicit insertion zipper changed rebuilding strategy,
  not read-only lookup lifetime. Neither demonstrates this capability.
- Phase160's GC experiment traded substantial RSS for performance and changed
  memory policy. The proposed borrowed path keeps the existing runtime, heap
  representation and owned ABI. It is not another arena/GC switch.

## The crucial ownership rule

The simple recipe “raw descendant → keep(result) → drop(root)” is **not always
safe**. `runtime.c:926` implements `term_keep`: a non-RFC, nontrivial value gets a
new RFC wrapper. The parent still stores its original raw child, so dropping the
parent can free the payload underneath the newly returned wrapper. A raw result
being reachable from a root is not sufficient permission to promote it that way.

For the first prototype, permit promotion only when the returned value is
**trivial or already RFC**, otherwise decline to the unchanged owned function.
Retain all owned arguments unchanged until this decision. For an RFC descendant,
increment its count before dropping roots; for a trivial value no keep is needed.
Same-root and parent/child aliases must be accounted for, and any identity result
must not accidentally consume a root twice. Cold-constructor capability 8 can
leave non-RFC fields; current capability 5 is not a reason to omit that fallback
from a general implementation. Do not rewrite a shared parent field in place.

The reader must allocate nothing and perform no mutation/effect/ownership
operation, so a refusal can safely execute the original owned path. Fresh
results and missing records can initially decline too, or use an authenticated
existing static constant. Do not invent a fake static missing value. A tagged
status/output pair or an unambiguous private refusal sentinel is required.

## General compiler contract, not a function-name optimization

A private summary needs `BorrowedResult(rootParameter, descendantOrigin)` in
addition to current scalar results. Admission must establish actual source
permission, read-only recursive traversal, exact constructor/field identities,
root retention and every return's origin. A branch may instead refuse. Recursive
trees and helper calls require a checked closed local region or equivalent
stack-safe worker, not unbounded native recursion. One public adapter promotes
the successful result; later scalar consumers could compose inside the same held
region and avoid that final promotion entirely.

Existing useful interfaces are `p118b_project_borrow` and
`p118b_verify_functions` in `back/qbe/ownership.bend:209,256`, actual constructor
widths2–16, and `p128br_arguments`/held-origin analysis. But the old structural
projection checker maps read-only imports to ordinary take operations; it does
**not** prove the lifetime of a newly escaping borrowed result. Keep that checker
unchanged and add a separate result-origin/adapter obligation. Likewise,
`borrowed-regions.bend:217` currently requires `nol_scalar(result)`;
`p128br_reference:232` rejects unknown helper cycles. Simply relaxing either test
would be unsound. A general result summary is a new capability, not an existing
flag to turn on.

## Small decisive experiment

Use the current runtime and a small checked Bend source closure. Compare the
original complete lookup/get-and-scalar-consumer path with the read-only
descendant worker and owned adapter. Keep names, hashing, trie shape, construction
and final consumption identical; build products once rather than rebuilding the
full compiler. Include both an actual scalar consumer (`p111v_capacity` or the
kind/width part of `p111v_value`) and a result that remains owned after its source
root is dropped. Include all teardown in elapsed time.

Before timing, compare complete records and retained-root values against an
independent literal oracle: hits, misses, duplicate order, Unicode, empty names,
collisions, current and legacy nodes, split-zero fallback, unique/shared roots,
same-root and parent/child aliases, already-RFC count-one descendants, static
descendants, and non-RFC descendants that must decline. Preserve unreachable
sibling payloads in these controls. Runtime checksum consumption is acceptable
only after the full-value gate; avoid Phase166's allocation-heavy generic scanner
as the dominant timed consumer.

First machine gate: the admitted traversal must contain no take/sink/keep or
constructor operations internally; only the boundary may promote/drop. Confirm
the original fallback remains and the reader/adapter passes explicit origin and
ordinary final structural checks. Then require a clear repeatable improvement
on complete map+query+consumer lifetime before extending admission to arbitrary
book/AST selectors. A speedup obtained only by omitting root destruction fails.

## Honest gain envelope

Current physical samples put 25.50% in lifetime/reclamation,20.27% in product
access/construction, and1.59% in allocator bodies. Those categories total 47.37%,
but include necessary construction and destruction far outside selectors; 53.58%
of active lexical ownership is unknown. They cannot be assigned to lookup.
With the current compiler/whole-build share, a 30% whole-build reduction would
require eliminating roughly 73% of that entire physical category envelope. The
present data does not support that assumption.

This is therefore the best **large, untested capability**, not a credible 30%
prediction yet. If complete borrowed lookup is strongly faster, use its original
and new general worker on one real parse/check/lowering request and exact output
before paying for another native self-build. If it is neutral, stop: the current
evidence then supports work elimination and representation changes across
multiple stages, not another claim that one runtime primitive will reach 100s.
