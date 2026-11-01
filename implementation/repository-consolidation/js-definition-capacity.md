# JS self-emission resource capacity

The consolidated JS/C API retains its existing preparation caches and exports.
Its complete emitted dependency closure exceeds the direct JS backend's 4,096
definition limit. Removing useful exports solely to fit this limit would remove
accepted capabilities from the maintained compiler.

The only compiler change here raises `jd_definition_budget` to 4,352 in
`selfhost/src/back/js/direct/calls.bend`. This is a bounded resource-capacity
increase, not removal of a semantic verifier. Both call-graph construction and
exact emitted reachability use this bound. All body, ownership, layout,
reference, metadata and effect checks remain. Separate limits remain unchanged:
8,192 body/tail nodes per definition, 4,194,304 call-graph edge occurrences,
65,536 emitted-reach visits and 2,097,152 metadata scan characters. The unrelated
4,096 readback-type-node bound in `program.bend` also remains unchanged.

The capacity grows by 6.25%; this is not a prediction of memory or runtime cost.
On already admitted inputs the consumed counters do not become generated code.
That supports, but does not replace, exact-product regression checks.

`selfhost/tests/consolidation/js-capacity.mjs` calls two independently checked B1
APIs with 4,096, 4,100, 4,352 and 4,353 selected definitions. It checks one tiny
zero-arity U32 literal declaration per producer, then changes only the names of
independent copies of that closed definition. This exercises the actual compiled
Bend planner without four repeated checks of the complete compiler source.
It requires planner admission at each respective bound, refusal above it, exact
emitted library bytes at 8 and 4,096 definitions, and an unchanged missing-root
refusal. The 4,100/4,352/4,353 cases test planner admission only; they do not claim
full library export rendering or execution at the enlarged bound. This does not
establish a compiler-correctness theorem.

Run with explicit checked acquisition receipts and a fresh output directory:

```sh
node --stack-size=8192 --max-old-space-size=2048 \
  selfhost/tests/consolidation/js-capacity.mjs \
  --baseline selfhost/build/consolidation/hosted-current03/report.json \
  --candidate NEW_CHECKED_B1/report.json \
  --out selfhost/build/consolidation/js-capacity01
```

The new assembled source is 3,010,912 bytes, SHA256
`00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e`.
The original extraction identity in `src/compiler.json.frozenSource` remains
unchanged provenance. The explicit source-change receipt records the one changed
declaration. Normal assembly accepts edited bodies; frozen verification is
intentionally a separate historical identity check.

A conservative source-reference census does not reach this JS limit from the
QBE `main`. That is diagnostic evidence only. Reusing the prior qualified native
image requires a full source-to-QBE comparison against the qualified Q3 product;
structural non-reachability alone is insufficient. Genuine JS B2/B3 self-emission
and independent behavioral controls remain separate integration requirements.

At creation of this note, the capacity controls and full QBE comparison are
pending in the coordinator's controlled execution lane. Report their results
explicitly before promotion; this note makes no new qualification claim.

## Preserved first control failure

`selfhost/build/consolidation/js-capacity01/report.json` records an 87.24-second
failed run under Bun. Both producers completed the 4,096-definition library
with identical SHA256
`166732dbbb63713653b076bb068ea30e860ac47edb2364632121619b2d587af5`.
The candidate also emitted 4,100 definitions. Its 4,352-definition planner
returned success and exactly 4,352 selected definitions, then a downstream
operation overflowed the host stack in `index_remove`.

The original method did not mark the boundary between layout checking and
library rendering, so the receipt cannot alone identify which call failed.
Library export rendering has a source-backed path through `j_io_type`,
`j_io_shadow`, `book_put` and recursive `index_remove`; that is a mechanism to
investigate, not a demonstrated resolution. This remains an observed host-stack
limitation, not a successful full-library test at 4,352.

Control method version 2 measures planner boundaries separately from the
under-old-limit product comparison and records each stage explicitly. It keeps
the same 4,096-byte-equality check and invalid-root rejection. It changes no
compiler admission, layout or ownership gate. Genuine compiler B2/B3 emission
and behavior remain separate required checks.
