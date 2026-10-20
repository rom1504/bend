# Index the product signature catalogue once

This candidate restores a mature optimization omitted by the Phase113 product
port. It changes the catalogue representation only. No source book, signature,
candidate order, shape decision, fresh identifier, or emitted operation changes.

Exact selected source31 evidence:

- `compiler.bend:33587`, mature `nf_plan_scoped`, already uses
  `book_cached(nq_signatures(book,names),0)`.
- `compiler.bend:46093`, `p113pl_plan`, passes the uncached signature list.
- `compiler.bend:46081`, every candidate queries that list; `:45930` queries it
  again at each ordinary call. `nq_info` at `:33953` queries it for constructor
  and call-result shape decisions. Its only consumers in the selected direct
  path use `lookup`, or forward the catalogue to those consumers.
- `lookup` at `:5954` scans list records until a name matches, unless its first
  record is a `BookCache`; then it uses the existing exact-name index.

The failed source31 full-emission receipt reports 2,707 requested names. The
catalogue has at least one signature record per name, plus flat routes and
constructor shape records. Uncached candidate lookup alone can accumulate
quadratic list visits, and every further call/shape query repeats a search.
The actual contribution to elapsed time is unmeasured. An index adds one build
and replaces these list walks with the existing bounded hash-trie traversal
and exact-name collision checks.

## Duplicate names retain the same definition

`nq_signatures` returns only `NQSignature` and `NQConstructor` records. Repeated
constructor-shape keys are normal. `index_build` first builds the tail, then
inserts the head. `index_leaf` replaces any existing entry of that exact name.
Therefore the earliest list record wins, exactly as ordinary `lookup` does.
Hash collisions retain distinct names in a bucket, and lookup compares the
full name. The appended `BookCache` marker redirects queries to this index;
it does not alter any original signature record. The bound field is zero,
matching the mature product planner, and no direct consumer reads that field.

The two overrides in `catalogue.bend` wrap the catalogue once at production
planning and once at diagnostic candidate discovery. They do not globally
change `nq_signatures`, `lookup`, or index helpers. They compose independently
with the verification-session candidate. `catalogue-modules01.json` pins the
two replaced source31 declarations and the unchanged index implementation.

## Qualification

Root should first compose this optional override with the already checked
verification session, then repeat the two existing staged kernels. Require
byte-identical QBE and complete ordinary outputs against the existing session
products. Compare `product-lowering` time separately; optimizer/final-verifier
times should be interpreted independently. The array certificate and final
whole-program verification remain unchanged. Only proceed to a full compiler
input once these small gates establish output identity and useful cost change.

No target run or timing claim is included in this source preparation. A
`baseline` split-driver run on the indexed source still uses the new indexed
product planner; it isolates verification-session reuse, not catalogue reuse.
Catalogue comparison needs the preserved pre-catalogue API/products.

## Other source findings, not implemented

Known flat lets still reconstruct/substitute the remaining body and rebuild
liveness. Passing the already available suffix-use set into `p113pl_bind_flat`
could remove two scans, but does not remove the quadratic suffix substitution
pattern. Prepared `NativeStaticBody` records already bypass repeated compaction,
so compaction should not be blamed without evidence. Dependency-ready sets and
the inliner table are already indexed; no second obvious catalogue omission was
found in the bounded inspection.
