# Existing controls under the wider policy

Source-only audit of qualified Phase134 `a0001924…fa19fb57`; no target was run.
The frozen four-bound module and `wide-source01` remain unchanged.

One existing assertion explicitly encodes the old width limit:
`p131rg_controls` expects `p131rg_width(9)` to be false. That is deliberately
false under the new width16 policy. The separate `controls-policy-v01.bend`
replaces only that predicate with refusal at17, and changes its label to
`region-width-seventeen-refused`. It retains all13 rows and every other safety
predicate. Compose it only when integrating the wider policy; it is not needed
to reinterpret old frozen receipts. The new17-control suite already tests
positive admission at9/16 and refusal at17.

A conservative call-closure inventory and source inspection found eight existing
control entry points that reach at least one changed bound:

| Entry | Width-sensitive expectation |
|---|---|
| `p118ns_controls` | No nine-field refusal; nested scalar projection and stack permissions. |
| `p128br_call_controls` | Root provenance, helper arguments and two-field String; unchanged. |
| `p128bl_controls` | Instantiation identity and graph budget; its literal8 is fuel, not record width. |
| `p128raw_controls` | Error paths, dependency admission and final verifier; unchanged. |
| `p128raw_br_controls` | Composition error paths; unchanged. |
| `p131rg_controls` | One explicit old policy assertion, isolated above. |
| `p131rv_controls` | Virtual String, provenance and fuel; its literal16 is evaluation fuel. |
| `p134ec_controls` | Stream/render bridges and refusals; unchanged. |

The late `p128bf_*` field-template controls remain unchanged: the four-bound
candidate does **not** expand that separate inline emitter. Packed width1,
constructor-count limits, helper arity, aliases, unknown layouts, scratch
capacity and final verifier refusals are not relaxed. This is a static inventory,
not a claim that all old predicates have been executed on the candidate.

`control-policy-audit.json` pins source and proposed module. Root should include
the existing region13 and new wider17 controls in the integration gate.
