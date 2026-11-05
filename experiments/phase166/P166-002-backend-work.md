# P166-002 — work census from one checked request

Hypothesis: private candidates, verification/index maintenance or output create
substantially more intermediate work than the useful final function bodies.
Count actual dynamic entries/loops and, where safely observable, tagged objects
in the existing hosted C/QBE backends. Reuse complete checked requests and exact
Phase165 output oracles. Preserve trampoline execution, the original verifier
and all final outputs.

Do not equate static helper counts with execution, hosted object events with
native allocations, or instrumented stage clocks with clean speed. A hypothesis
is useful only if the counters identify a removable category of real work and
give a small follow-up experiment with a meaningful whole-region ceiling.

## Outcome

Completed with exact C/QBE output gates and ordered markers. Added lexical
constructor attribution after total counts suggested a large Tuple cost. Native
inspection falsified transferring that hosted reconstruction count to native
allocation. Prepared-body reuse and indexed verifier getters are confirmed
negative results. This census does not partition the old native allocation
residual. [Report](../../implementation/phase166/README.md).
