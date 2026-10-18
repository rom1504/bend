# Generic owned Build→Take elimination: bounded feasibility review

**Recommendation: do not implement an isolated local pass in this phase.**
The rewrite would remove real constructor allocation and ownership work, and is
not already provided by Phase107 promotion. However, the current admitted source
lowerer does not expose a demonstrated local opportunity. An owned-call inliner
or broader computed-value/match lowering would be needed first. This review
inspected source and saved JSON only; it ran no compiler, proof or target.

## Existing transformations and observed opportunities

[Phase110 general runtime lowering](../../selfhost/tools/performance/phase110/runtime-ir/general.bend)
recognizes adjacent **Take→Build**, now with an arbitrary checked suffix. It
reuses a consumed shell while reconstructing a result. It has no reverse
Build→Take rule and does not eliminate a newly created constructor altogether.

[Phase107 scalar promotion](../../selfhost/tools/performance/phase107/inline/promotion.bend)
replaces eligible scalar field loads/stores with locals, but explicitly retains
allocation/free statements and pointer stores. It requires closed known fresh
allocations, scalar parameters/results, and rejects calls, unknown pointers and
allocation/free inside loops. It therefore neither subsumes the proposed owned
rewrite nor reaches the current runtime-call representation of constructors.
Its [qualification report](../phase107/promotion.md) makes those limits explicit.

The actual [owned-call lowerer](../../selfhost/tools/performance/phase110/calls/lower.bend)
has a more immediate limitation: `nxc_apply_live` accepts leading lambda/match
binders, while `nxc_value` accepts variables, constructors and closed calls.
`nxc_terminal` evaluates values/call arguments and finishes with Return or Tail.
There is no general Let continuation or match on a newly computed value. Thus
construction belongs to terminal value evaluation, whereas Take is emitted
while matching incoming parameters/fields. The IR agent independently confirmed
this reading; an earlier informal suggestion that general Let was supported was
corrected.

A read-only scan of 113 saved `.owned.json` files at the first two artifact
directory depths found 19 distinct byte-level graphs and **zero Build operations
immediately followed by Take or Branch**, recursively including branch bodies.
Six existing native-fact captures contained 77 definition entries, including
repeated definitions, and no direct `App(Mat/Lam, argument)` node. These are
bounded corpus observations, not proof that every mature compiler input lacks
an opportunity. The inspected captures include
[call shapes](../../selfhost/build/phase110/capture-call-shapes01/native-facts.json),
[ordinary calls](../../selfhost/build/phase110/capture-calls01/native-facts.json)
and [closed dependencies](../../selfhost/build/phase110/capture-closure01/native-facts.json).

Checked erasure itself is largely structural:
[`nc_definition_plain`](../../selfhost/src/back/native/book.bend) calls
[`nc_erase`](../../selfhost/src/back/native/erase.bend), which removes annotations
and erased arguments while preserving live applications. The absence above
does **not** establish that normalization already eliminates every constructed
match. No captured representative constructor-then-match witness was available
to distinguish upstream simplification from unsupported lowering. Ordinary
Build→Call producer/consumer opportunities would require interprocedural work.

## A useful rewrite and its proof obligations

The intended rule is:

```text
Build d, C(a,b); Take d -> (x,y); K
    ⇒ simultaneous ownership transfer a→x, b→y; K
```

For a source match it may instead require known-tag branch selection:
`Build d,C(...); Branch d,C { Take d; K } { ... }`. No intervening Keep,
escape, call or other effect may be silently crossed. Check the original graph
first, use the same constructor catalogue/field order, require the built parent
to have its sole fresh ownership credit, and independently verify the result.
The existing verifier supplies useful credit/freshness checks, not rewrite
correctness by itself.

There is no owning Move operation in Nxo today. Substituting names throughout
the suffix must be simultaneous and capture-safe: the generic verifier allows
reuse of zero-credit names, and repeated input fields can be legal when they
carry enough credits. A minimal implementation could require globally fresh,
distinct generated names and otherwise refuse; an unrestricted textual rename
would be unsound. Suffix handling must cover branches, calls and tail moves.

Existing selector and `unique_take_transfers` laws support exact field order and
logical ownership transfer, but do not yet prove this cancellation. Original
Build seals each child; immediate Take returns the sealed words. Cancellation
may return raw words instead, including raw static constructors, and remove
their count-1 wrappers as well as the parent shell. Therefore the new theorem
must compare decoded values, ownership credits and external aliases under an
explicit representation relation, not raw words or allocator state. Stored-field
idempotence proves that already-sealed words need no reseal; it does not prove
raw and sealed words interchangeable under every continuation. Allocation
failure behavior and physical allocator correspondence remain separate scope
decisions.

The next gate should be one authenticated checked-source witness that survives
into an admitted owned graph, with the relevant shell allocation/RC category
present before rewriting. If none survives, first choose bounded owned-call
inlining or computed-value match support and assess its independent cost.
Only after that evidence would a source-connected cancellation helper, complete
local relation, wrong-field/missing-credit/escaping-parent mutants and native
allocation accounting justify an implementation campaign.
