# P113-002: preserve mature field and Nat ownership facts

Receipt snapshot: 2026-10-20, 18:56 UTC. Optional `facts14` prototype; native
qualification is incomplete. This records the next hypothesis under the
[Phase113 design](../../design/phase113/qbe-program-parity.md), after initial
source checks. It is not a retrospective claim of prior registration.

## Hypothesis and source evidence

Preserving checked ownership facts through direct functions and products will
remove redundant keep/sink calls without changing value representation,
evaluation order, overflow behavior, or owned-field transfers.

The mature `nc_erase_mat` computes `Mat.qty` from the instantiated constructor
telescope. Its scalar-field mask reaches `nc_field_env` in the mature path, but
the first direct/product match consumers used `p111_field_env` and discarded it.
The [field adapter](../../selfhost/tools/performance/phase113/direct-fields/README.md)
restores this existing fact, including virtual product fields, while preserving
IDs, names and full U64 words. Malformed masks, wrong arity and unknown fields
remain conservative. The source audit predicts removal of four keep and four
sink sites on scalar `Hit` fields in ray09's `trace`; this still needs a current
structural witness.

The [Nat extension](../../selfhost/tools/performance/phase113/nat-facts/README.md)
adds `N_Imm64`, a nonowning full-Term kind. Its premise is the pinned CPU runtime's
valid Nat range, `0..2^48-1`, with existing checked arithmetic and fail-stop
overflow. This is not U32 narrowing or classification of arbitrary bits.
Canonical types, authenticated primitives and conservative checked result/field
rules provide the facts. Generic Nat fields and virtual product Nat fields stay
outside the new field rule. The
[consumer audit](../../selfhost/tools/performance/phase113/nat-facts/type-consumers.md)
records width, capture, C type and ownership consumers; scalar-array
classification remains unchanged.

## Observed gates

- [facts14 API](../../selfhost/build/phase111/p113-facts-api14/report.json):
  source checked, complete, status 0; binds the exact assembled compiler.
- [Finite controls](../../selfhost/build/phase113/fact-controls14/report.json):
  148 passing rows: 58 result facts, 20 products, 24 field facts and 46 Nat
  controls. These finite reflected checks do not prove provenance or runtime
  ownership correctness.
- [Native batch](../../selfhost/build/phase113/facts-all14/report.json):
  high values and four strict overflow fixtures passed their complete
  output/status expectations. The mixed Nat/String `owned-record` fixture
  [failed frontend parsing](../../selfhost/build/phase111/p113-nat14-owned-record-emit/report.json)
  before execution: a computed value was directly destructured. This is a
  fixture syntax failure, not an observed runtime ownership failure. Mixed-owner
  alias survival and the remaining native campaign are still unqualified.

## Independent gates and falsification

Repair the fixture in a fresh version and retain the failed receipt. Require
native high values at `2^32`, `2^40` and `2^48-1`, exact overflow failures,
mixed owned/nonowned fields, retained String aliases, and both release orders.
Add independent rejection challenges for forged/out-of-range masks, dependent
or generic fields, Nat lookalikes, wrong call arity and unknown results.
Authenticate the actual checked producer-to-consumer path; raw KTerms are not
ownership certificates.

Reject the correctness hypothesis on truncation, lost overflow, changed
evaluation order, removed owning-field operations or alias corruption. Reject
the proposed performance mechanism if current hot bodies retain the targeted
ownership sites. Only after structural and semantic gates should matched timing
test whether fewer calls improve runtime without unacceptable compiler-time,
code-size or memory costs.

Scope is sequential CPU execution with the pinned runtime and generic fallback.
Any combination with inlining needs its own checks. Full45, native compiler
acquisition, successive-generation qualification and promotion remain separate;
the installed selection is unchanged. This documentation audit ran no targets.
