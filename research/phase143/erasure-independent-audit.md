# Independent indexed-erasure audit

Source-only review of [core-v01.bend](../../selfhost/tools/performance/phase143/erasure/core-v01.bend)
and [override-v01.bend](../../selfhost/tools/performance/phase143/erasure/override-v01.bend)
against Phase142 `indexed-source02/compiler.bend`, SHA-256
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`.
No target execution, runtime change or production integration was performed.

**No source-semantic blocker found for finite runtime-valid inputs.** The change
replaces only the Boolean membership test on the accumulated `done` names. It
does not replace the observable ordered names list with an index.

## Preserved invariant

The indexed walk carries `seen` satisfying, for every String `name`,
`p142j_member(seen,name,index_hash(name,2166136261)) = nb_contains(done,name)`.
`p143nr_begin` establishes it from every supplied initial `done` entry. Duplicate
initial entries can collapse in the private index while the original `done`
list, including its duplicates and order, remains unchanged.

On a hit, both walks advance to the original queue tail without looking up or
erasing the definition. On a miss, both compute `lookup(book,name)`, the same
`nc_definition_plain(book,d,0)`, the same optional `NativeErasedBody` fact and
the same reference list. Both prepend that reference list to the pending queue,
prepend the name to `done`, and prepend an admitted fact to `facts`. The new
walk additionally inserts the name into `seen`, restoring the invariant. In
particular, it marks before revisiting any recursive reference, as the original
does through the updated `done` list. Self and mutual cycles terminate under
the same finite-book assumptions.

The mark is built before the visit in the candidate instead of only updating
the list after body erasure. This changes allocation/evaluation timing but does
not expose new state to the unchanged lookup or body-erasure operations.
The index contains only privately constructed `P142JSeen` rows; no externally
supplied index is trusted.

## Important boundary checks

| Pinned source lines | Finding |
|---|---|
| 35766–35781 | Original queue, name and fact order is reproduced exactly; `nr_visit` itself is not overridden. |
| 63607–63623 | Existing set uses `index_find`/`index_set` with exact name comparison in collision buckets. Hash equality alone cannot create a hit. |
| 5772–5780 | Ordinary first-match and terminal `BookCache` lookup behavior remains the original `lookup`. |
| 35042–35051 | `nc_refs` visitation order is reused, including repeated references. |
| 35070–35096 | Native, Foreign and Absent bodies retain the original body-selection behavior. They are not simply skipped. |
| 32146–32161, 32402–32405 | Native classification and fact arity remain the original operations. |
| 15314–15322 | Complete term observer retains variant, source spans and quantity-presence metadata. |

A missing lookup still adds the requested name and traverses the body computed
by the original missing/foreign path; it does not add an ordinary erased-body
fact. A definition with `Absent` value is classified as foreign by the original
code. Native and foreign definitions still pass through `nc_definition_plain`
and `nc_refs`; only the fact predicate excludes them. The candidate copies that
predicate, including the `kind == Def` condition, unchanged.

## Independent finite controls prepared

[controls-v01.bend](../../selfhost/tools/performance/phase143/erasure/controls-v01.bend)
contains twelve rows, exported by `p143nr_controls`. It requires
[equality-v02.bend](../../selfhost/tools/performance/phase140/checker/equality-v02.bend).
The complete `NR_Closure` comparison uses ordered String-list equality and
variant-aware `p140ce_defs`, including complete terms and initial fact payloads.
It does not use names, lengths or hashes as a substitute for fact equality.

The legacy reference consists of the exact two original declarations with only
`nr_walk`/`nr_visit` renamed. A source-only script checked byte equality after
that renaming. This remains an independent traversal even when `override-v01`
replaces `nr_walk` in the experimental source.

Cases cover empty requests with nontrivial initial facts; already-done duplicate
names; reference-versus-queue ordering; self and mutual cycles; the real
`costarring`/`liquid` hash collision; a collision against initial done; empty,
Unicode and missing names; first-definition shadowing; terminal BookCache
lookup; native/foreign/Absent exclusion from facts; and negative mutations of
the full result observer. These are finite raw-IR controls, not a claim that
every artificial fixture is a valid source program. They have **not been run
by this audit**.

Reviewed SHA-256 pins:

- core: `f58d3571c64f9fd2efa404b9ea06f0638ca292e970f2e2e5ae985984e44ea848`
- override: `3b92b00e090ab1cc7a8ffead567fa5e8492783d330cc76b4f98c9c8f83fdd859`
- controls: `f5355bff5f05bb7efd508d96132cd35796045115c11f65387c46acb23ed24e83`

The likely tradeoff is fewer repeated growing-list comparisons versus new
hashing/index allocation. Constructing the index from nonempty initial `done`
also adds work when `todo` is empty. No performance claim follows from the
invariant; check actual ordinary erasure workloads and complete products before
native acquisition or promotion. This optimization adds no cross-request reuse
or new authority to omit verification.
