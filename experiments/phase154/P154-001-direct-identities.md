# P154-001 — directly produced numeric identities and semantic facts

Status: completed; retain private prototype, no production promotion.
Result: [Phase154 report](../../implementation/phase154/README.md).
Design: [Phase154](../../design/phase154/README.md).
Baseline: `bde17c0` source; explicit qualified Phase152 N2.

Prediction: repeated local spelling, hashing and generic fact boxing can be
removed before they occur, across a genuine producer and multiple consumers.
Unlike Phase148, this must not require building the old local-name IR first.

Primary discriminator: complete producer→analyses→independent verifier→output
native cost, including conversion and destruction, compiler and Map families.
Near 2× over a representative region is needed to support the suggested large
whole-build opportunity. A cheap lookup-only gain is insufficient.

Keep all admission/ABI/fallback obligations, exact original text where practical,
and a fixed independent oracle. No production integration or release selection
until separately justified. Source checking, finite differential controls and
native timing are distinct from mathematical proof and self-host qualification.

After the initial sixteen producers matched exactly, actual final-header contexts
exposed missing direct dependencies and self-identity duplicates in the harness.
The verifier context is corrected to the authentic ordered prefix, not all
headers minus the owner. Keep all original sixteen outcomes. Before measuring
candidate speed, add four source-audited actual final-admitted names to test
coverage: compiler `p111v_value`, `p111v_counted_call`; Map `Map.ins.splice.bit`,
`Map.pop.lo`. These names are chosen from existing baseline headers, not from
candidate performance. New failures remain reported; no invented callee headers.

Final result: 13.02% less complete child time on five compiler helpers and 2.36%
on four Map helpers, four alternating pairs each. Nine exact independent output
oracles pass; all refusals remain. This is legacy direct production, not the
current prepared pipeline or the whole 101.45s region. The near-2× discriminator
was not met. Preserve the experiment; no full self-hosting campaign or production
migration. Hashing falls, but owned fact objects and scheduler transport remain.
