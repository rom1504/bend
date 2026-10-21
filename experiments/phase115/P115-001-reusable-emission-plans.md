# P115-001: retain legal alternatives across policy evaluations

See the pre-execution [design](../../design/phase115/reusable-plans-and-policy-search.md).
Hypothesis: request-local immutable emission alternatives remove repeated pure
region planning and make fixed-work policy evaluation materially cheaper.
Falsifiers: unequal QBE for the same policy, output disagreement, retained-plan
cost/memory exceeding savings, or useful gains confined to a contrived workload.
Legality remains in the existing Bend planners and verifier. Policy data chooses
among legal alternatives; no host-side lowering or external trust certificate.
The untouched Phase114 source02 and API are the policy0 reference. Qualification,
speed, research capacity and promotion remain separate outcomes.
