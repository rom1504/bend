# P65-005: retain exact Base constructor membership

- Owner: cache-contract lane; independent reviewer: correctness lane.
- Started October 8, 2026; first source-only candidate prepared before any target.
- Objective: reduce fresh-request checking/context admission allocation without
  changing compiled programs, diagnostics, public checking or compiler ownership.
- Correctness: source proof reviewed; fifteen focused membership and eight maximum
  controls passed on checked State03; all eight screen output oracles passed.
- Measurement: balanced checked-B1 first-request geometric mean 0.99803× baseline
  (−0.20%), Numeric +0.74%, Map −1.13%, below A/A noise.
- Decision: reject standalone advancement; baseline unchanged, world version4
  not promoted. Full matrix, 92 host controls and B2 qualification not run.
- Report: [constructor index](../../implementation/phase65/constructor-index.md).

## Claim and invariant

The prepared Base world can retain the exact set queried by
`constructor_exists(finalBase, name)` instead of scanning all Base declarations
for each suffix name during checking and again during context admission.
`base_prefix_names` in the admitted producer excludes `Absent` and `BookCache`
children, so non-absent lookup in each immediate child list is equivalent to
membership in the union of those immediate names. The existing exact-name trie
preserves full 32-bit hash collisions. Do not index outer names, recursively add
grandchildren, or substitute the parser's recursive Ctr-only index.

Persist one `constructorIndex: KDef` as the last prepared-world field. The Bend
producer builds it from final Base declarations. All three private admission
sites consume it; the original raw predicate and `constructor_exists` remain.
World version4, exact API/Base/path/root coupling and ordinary optional-state
fallback guard the new capability. The host only transports the Bend fact.

## Cost budget and disproof

The fresh allocation ancestry report attributes 6.036/6.958/5.510 MB to
`base_prefix_ctor_disjoint` on Lexer/Map/Ray. The inclusive constructor total is
larger (26.117/25.733/18.631 MB), but its remaining ancestry is unresolved; it
must not be counted as removable by this patch. Exact constructor CPU totals
are only 13/14/14 samples out of 493/800/673. Allocation reduction is a mechanism,
not a whole-request speed prediction.

Reject on membership mismatch, changed refusal/diagnostic/result/context,
incorrect old-cache capability, changed full module output, or request-level
regression. Do not add a general mutable lookup cache. A saved field is preferred
to rebuilding the same set on both admissions; transport and preparation cost
still count in the appropriate clocks.

## Gates

1. Compare exact membership against the original function for admitted-shaped
   immediate Def/ADT/Ctr children, empty and duplicate names, full hash collisions,
   outer-only names and grandchild-only names. Compare recursive suffix admission.
2. Compare whole DChecking/DResult and context against existing paths, including
   constructor collisions, malformed/reserved suffixes, unsafe/unready states,
   prefix-hash replay, bounds and source changes.
3. Exercise version4 encoding/admission, old6/7/8-field decoding without granting
   the new capability, malformed index references and optional-state fallback.
4. Root builds checked B1 and runs short alternating Numeric/Map screens, then
   Lexer/Ray if the candidate survives. Larger decisions require genuine B2 and
   complete request clocks with prepared caches, not instrumented counters.

All compiler/Node targets remain root-only and serial on CPU3 under the existing
memory guard. This lane uses CPU0 source/data work. Preserve the isolated patch,
exact before/after hashes, all unsuccessful results and closed Phase64 evidence.

## Result

Root executed gates one and the short screen in gate four; both preserved their
scoped correctness conditions. The screen did not establish a useful speed gain,
so later gates were skipped rather than spending more time qualifying a field
and version with no demonstrated payoff. The
[measured report](../../implementation/phase65/constructor-index.md#latency-screen-and-decision)
links exact receipts and distinguishes executed tests from the prepared but
unrun controls.
