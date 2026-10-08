# P65-008: Boolean lookup without missing-definition construction

- Owner: cache-contract lane; reviewer: correctness lane.
- Status: isolated source candidate; no target execution or gain yet.
- Goal: remove unnecessary definition construction from generic constructor
  membership without adding artifact fields, versions or admission rules.
- Candidate: [manifest](../../selfhost/tools/performance/phase65/cache-contract/boolean-lookup-v1.json).
- Report: [Boolean lookup](../../implementation/phase65/boolean-lookup.md).

## Hypothesis

`constructor_exists` asks only whether `dk(lookup(children, name))` is not Absent.
An ordinary miss nevertheless constructs a complete missing KDef and two missing
terms. The selected B2 emits eight object constructions along that path. Replace
this discarded value with a Boolean list lookup, retaining the original cached
index fallback. This affects every constructor membership call, unlike the
rejected H5 prepared-world index, and adds no cache schema.

## Exact contract

Preserve lookup's first matching name, even when that row is Absent. A BookCache
sentinel encountered at any list position delegates to its index and ignores
subsequent list rows. Keep existing `dn`/`dk` projections for index variants and
empty names. Retain `index_lookup` verbatim for the uncommon cached child-list
case, so full-hash collisions and legacy index forms have the old semantics.
Only replace the Boolean projection consumed by `constructor_exists`; leave
its strict outer `&&`/`||` recursion unchanged in this ablation.

## Falsifier and gates

1. Differentially compare the Boolean helper with `dk(lookup(...)) != Absent`
   on empty/missing/hit lists, duplicate/Absent masking, BookCache positions,
   exact hash collisions, index variants and empty names. Keep input immutability.
2. Compare constructor predicates, real complete emitted modules and a short
   balanced fresh-process checked-B1 screen with the selected baseline.
3. Reject advancement if the complete request improvement remains within noise
   or regresses meaningfully; do not qualify a larger bundle merely because an
   allocation counter falls. A surviving candidate needs the normal broader
   correctness and genuine-B2 gates before promotion.

The leaf census is data-only over closed raw profiles. No attribution assigns
all inlined constructor samples to missing values, and no speed gain is inferred
from sampled bytes alone. Root alone executes compiler/Node targets.
