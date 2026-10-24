# The verifier lookup boundary after Phase131

The next capability worth testing is **a scalar consumer specialized through a
borrowed selector**, rather than another record-width increase by itself. The
current native compiler performs an owning map lookup, returns a complete KDef,
then immediately destroys that result to extract one scalar. This is visible in
the actual native-image code, not merely inferred from source.

This audit performs no target execution or compiler edits. The separate wider
record experiment owns width 9–16 admission; it is not duplicated here.

## Exact scope and profile interpretation

The image is Phase131 final N2,
`selfhost/build/phase111/p131-final-native01-n2/program`, SHA256
`2fae36020081ccc5cbfb847caf0b285b762387327e4bb44e1d62d96d1affd5dc`.
It comes from combined source
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`
and QBE `selfhost/build/phase130/p131-final-self01/program.ssa`.

The fresh profile-analysis receipt attributes 9.72% of lexer active-context time
to `p111v_get` (65 of 670 context samples, period-weighted); Map is 2.80% and the
closure workload 0.40%. Within the lexer context, `span_fade` accounts for 2.02%
of all request time, `term_drop` 1.48%, and borrowed `index_hash` 1.63%. These
fractions are overlapping context/physical views; do not add them to the
reported 6.38% overall physical borrowed-hash fraction. Nor is all 9.72% removable
lookup overhead: it includes required hashing, comparisons and traversal.
Private synchronous calls retain the outer dispatch context; this is not an
exclusive source-function timing or a complete caller stack.

## Source-to-machine chain

In the exact combined source:

- `p111v_get` at 40131 computes `index_find(tree,name,index_hash(name,...),32)`.
- `p111v_capacity` at 40234 immediately asks `dx` of that result.
- `p111v_value` at 40209 consumes `dk`/`da` to compute a Boolean.
- `p111v_assign` at 40224 consumes `dk`/`da`/`dx` to construct a new entry.
  It is a more complex transfer case because the String kind escapes into the
  new owned result. It is not the first scalar-query target.

The source declarations are protected verifier code and remain unchanged.
General code generation can optimize their checked semantics without weakening
any verification predicate or changing its answers.

[Retained evidence](verifier-boundary-evidence.json) records streamed QBE
extractions and actual disassembly in
`selfhost/build/phase131/verifier-boundary-inspection01/`:

| Actual function | QBE lines | Machine instructions | Relevant current behavior |
| --- | ---: | ---: | --- |
| Borrowed `index_hash` |101| — | Already emitted; still scans the String. |
| Owning `p111v_get` |22|31| Keeps the key, calls hash, then owning lookup. |
| Owning `index_find` |681|595| 43 sink and 14 generic-constructor sites across all branches. |
| Owning `index_bucket` |205|273| 21 sink sites, owning record extraction, owning equality and two constructors. |
| Owning `p111v_capacity` |132|148| Calls hash/lookup, then takes 9 KDef fields, returns field 3 and sinks the other 8. |
| Owning `p111v_value` |380|352| Calls get, then ordinary `dk`, String.eq and `da` helpers. |

The capacity path additionally reserves a 72-byte inlined scratch buffer for the
nine-field take. The corresponding field extraction is physically present in
machine code. Static counts cover mutually exclusive cases and fallback
branches; they are not per-call instruction or allocation counts.

At the lookup return boundary, the compiler loses two useful facts:

1. A successful selection is a descendant of the still-available input map,
   so the immediate scalar consumer could observe it under a held root.
2. Failure returns a known `missing()` constructor. For capacity, its field 3 is
   zero, so constructing a complete missing KDef and nested Absent terms is
   unnecessary if the consumer stays visible.

The selected leaf does not need to become a public owned value at all when its
only consumer returns a scalar. Eliminating that materialization is distinct
from merely making its field copy wider or faster.

## Implemented, admitted and proposed

**Implemented and emitted:** borrowed scalar hashing, shallow record views up to
width 8, finite virtual-constructor evaluation, scalar/product-wrapper helper
composition, and the owning `index_find`/`index_bucket` functions above. There is
no borrowed `p111v_get`, `p111v_capacity`, `index_find` or `index_bucket` reader in
the final N2 function inventory examined here.

**Being tested separately:** the four bounded width changes that permit 9–16
fields. The original final compiler still rejects the nine-field KDef layout.
A successful width experiment would establish record access, not automatically
prove or emit a complete borrowed map query.

**Still missing for this chain:** a returned *selected descendant* with a
root-lifetime witness, or equivalently a compile-time scalar continuation fused
into the selection. `p128br_call` currently admits a verified scalar observation
and reconstructs a fixed wrapper from original parameters plus that observation.
It cannot express an arbitrary selected KDef descendant as the observed result.
Its result must pass `nol_scalar`. Simply declaring KDef scalar would be wrong.

Furthermore, helper body expansion uses bounded acyclic evaluation. A recursive
helper other than the current analyzed owner hits the stack/cycle rejection in
`p128br_reference`. The existing spine layout requires exactly one recursive
child, and `nol_root_ctors` recognizes a two-constructor nil/cons shape. KDef
has three constructors and KIndexNode has two child alternatives. Shallow views
therefore leave those unsupported child fields opaque. Widening field count does not authorize following
those opaque children or traversing recursive helpers.

The new product-projection machinery is useful precedent, but its fixed
root/product wrapper is not already a borrowed map-selector contract.

## Smallest semantic contract

Avoid exposing a new borrowed-result ABI initially. Specialize a pure selector
with its statically known scalar consumer, so only a scalar leaves the private
region. A conceptual checked plan is:

```text
HeldRoots(map, key)
Selector: exact source lookup; each selected record is rooted in map
Failure: virtual constructor equal to original missing()
Consumer: closed pure scalar computation on selected/virtual record
Output: scalar; original adapter consumes its owned inputs after observation
Fallback: unchanged owning lookup followed by unchanged consumer
```

For the first experiment the consumer is exactly `dx`, including its behavior
for all three KDef constructors. General legality must prove:

- Input expressions retain their evaluation order and exact hash/comparison
  behavior; no foreign or effectful call is skipped or reordered.
- Selected children stay beneath a held root throughout the consumer. No
  selected pointer is published, stored or returned as an owned object.
- The virtual missing path reproduces the actual consumer result. No source
  error or required effect disappears.
- Existing alias/ownership adapter gates and owning fallback remain; a source
  type alone is not a lifetime certificate.
- Recursive branches become verified local loops or a closed stack-safe region,
  not unbounded native recursion. Preserve both legacy and current map forms.
- The final independent verifier remains unchanged and checks emitted code.

A scalar continuation can be an existing residual-expression/continuation
object captured at compile time, not a runtime closure. The optimization must
match semantic producer/consumer properties, not verifier or benchmark names.
Only after this proves useful should a reusable borrowed-selector summary be
added. Returning borrowed descendants between independently compiled helpers
would introduce a more difficult lifetime interface and is unnecessary for the
first ceiling.

## Cheap falsifier and limits

Extract the original lookup algorithm plus the unchanged capacity consumer into
an ordinary isolated fixture. Compare the existing owning composition with an
explicit source-level fused scalar ceiling. This does not modify protected
verifier declarations in the real compiler. Reuse native runtime, independent
oracle and held/shared root controls. No full compiler rebuild is required.

Include hits, misses, Unicode/common-prefix keys, collisions, legacy KDef maps,
KIndexLeaf/KIndexNode maps, mask-zero branches and empty keys. Do not assume every
selected value is the main KDef constructor: `dn(KIndexNode)` is empty and
`dx(KIndexNode)` is its mask, so an empty-key bucket can select such a value under
the generic source semantics. Duplicate-key order and virtual missing results
must also match. These cases make the ceiling an actual algorithm comparison
rather than a representation-specific guess. Also include accepted/rejected
verifier queries: absent names, mismatched widths and insufficient capacities
must preserve their original scalar answers. Successful compilation alone
would not detect a weakened verifier predicate.

First ask whether the ceiling removes the nine-field take and internal
ownership work and improves runtime. Then determine whether the existing NO
analysis can residualize the same two-loop selector/consumer region economically.
Do not start by bypassing recursion or origin checks.

Even perfect removal of the observed `p111v_get` context would cap its directly
attributed lexer benefit near 9.7%; that is an optimistic diagnostic ceiling,
not a prediction. The capability might also benefit inlined callers with other
active owners, but those require separate evidence. It does not eliminate
content hashing or repeated equal-key lookup work automatically. Hash reuse and
lookup/consumer fusion are separate hypotheses, with potentially overlapping
benefits. Measure the cheap scalar ceiling before estimating implementation
payoff or extending the optimizer's contracts.
