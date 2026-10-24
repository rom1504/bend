# Closed factory reduction before static preparation: discriminator

This is an isolated checked Bend experiment. It does **not** override a compiler
entry or optimizer, change the qualified compiler, emit target code, or establish
a performance improvement. Its purpose is to test whether generic preparation
can recover the value hidden by small constructor factories, allowing readable
compiler source instead of419 expanded constructor expressions.

## Source finding

The existing `p112s_defs` has the checked request book and an effect-filtered
constructor index. It already runs `nc_compact` and then `p112s_term`.
`p112s_term` traverses children and pools eligible constructors, but leaves
references/applications opaque. Compaction has no book argument and does not
inline factories. The later selector rule requires a matcher and excludes
non-nullary constructor fields; it cannot recover these constants before pooling.

The known ceiling is real: exposing the original `missing()` constructor tree
removed its three runtime allocations; the independent mixed hit/miss proxy
improved9.81%. This experiment does not rerun or broaden that timing claim.

## Actual experiment

`probe-v02.bend` adds a bounded closed-value evaluator, using the existing
`nc_source_body`, literal compaction, capture-free substitution of closed values,
canonical word admission, and effect-filtered constructor admission. It accepts
ordinary saturated factory calls with up to8 arguments, up to64 source-body
nodes, at most64 characters per source String literal, and4 nested factory
expansions. It admits no open values, primitive computations, effects, foreign
calls, matches, arbitrary lets or stale static markers. Unsupported cases return
a refusal value; there is no native execution of malformed inputs.

Arguments are validated closed values before substitution, including unused
arguments. Dropping or duplicating such values introduces no argument effects or
errors. Dynamic arguments are deliberately excluded: preserving their order and
ownership would require ordered lets/fresh IDs and would not make them static
constants anyway. Existing static-data ownership and final verifier contracts
remain the intended authority when/if integrated.

`controls-v03.bend` supplies17 finite checks: exact saturated/two-hop/duplicated
values, open and unused-open refusal, unknown actual, partial/overapplication,
recursive/exhausted fuel, primitive/foreign/effect/unknown constructor refusal,
wrong arity, stale marker and noncanonical word.

`workload-v01.bend` contains the exact selected `KTerm`, `KDef`, `kt`, `atom` and
`missing` declarations plus literal twins. Its unrelated `Packet` factory has a
String field and a duplicated scalar argument. The actual checked frontend
constructs the request; the probe reduces both source forms. `check-v01.mjs`
compares every resulting field/tag with the literal twin, not a checksum.

Evidence:

- `selfhost/build/phase131/factory-probe-source03/manifest.json`
- `selfhost/build/phase111/p131-factory-probe-api03/report.json`
- `selfhost/build/phase131/factory-probe-check01/report.json`

All17 controls pass. Original `missing → atom → kt` and the unrelated Packet
factory produce byte-identical whole result JSON to their respective literal
twins (including every reconstructed term field). The four-export API acquisition
cost10.37 guarded seconds/1.24GB peak; finite controls plus the actual checked
fixture cost3.04s/218MB. Earlier affine-annotation and missing-list-annotation
refusals are preserved in source01/API01 and source02/API02. There was no full
compiler image acquisition.

## Smallest next implementation

Add a private context-aware arm to the **existing** static walk, before its
children have been replaced by image-relative `NStatic` values. Only attempt
factory admission when actual arguments pass a cheap closed-syntax filter;
reject dynamic actuals before looking up/inspecting the callee. On success, feed
the resulting constructor tree to the unchanged static walk. On refusal, follow
the exact old walk and diagnostics. Preserve the original erased-source facts
for observers; only the generated `NativeStaticBody` changes. Do not rewrite
source files or introduce a global search/cache.

The existing walk needs access to its request book; a small private context
parameter or context-aware worker is preferable to duplicating the whole static
pipeline. No new source-level recognizer for `atom`, `kt`, `missing`, or a benchmark
name is justified. Start with exactly these two factory/literal comparisons,
then require identical complete static products and meaningful generated-code
improvement on the unchanged source. Measure whole-request overhead before a
full self-hosting build.

**Remaining bounds obligation:** per-callee limits and call depth are not a
complete aggregate expansion-work budget. Repeated parameters and branching
nested factories can amplify a large closed argument. The current data-only
probe establishes semantic/representation feasibility on bounded fixtures.
Production integration needs an explicit aggregate work/result bound (and a
cheap prefilter) before arbitrary-program use. Do not label this prototype a
production optimizer or infer that broader inlining is profitable.
