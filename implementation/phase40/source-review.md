# Independent grounded List source review

2026-10-03; inspection only, no compiler/program execution. Reviewed proposal04
patch and current admission helpers in fold/jpure/local/region/producer/finite.
The separate tree reviewer owns the new linear continuation implementation.

The grounded List predicate checks ADT identity, two parameters, empty record
members, explicit Qua quantity2 and canonical primitive U32 via the existing
native-book guard. Owner admission additionally checks a nonbuiltin arity2 ADT
with exactly Nil/Con, specializes the owner and both constructor telescopes,
and requires quantity2 U32 head and List2U32 tail/result. The specialized result
kind is quantity2. Both sides of List type comparisons must satisfy the canonical
grounded head predicate, preventing name-only equality across instantiations.
No obvious parameter/type-owner escape found by inspection.

Constructor purity and finite-emission checks now specialize the constructor
field telescope using the ADT arguments. Existing zero-parameter types preserve
the previous telescope. Guarded root capture, complete pure-graph dependency
proof and constructor-field checks still determine admission; this is not a
public untyped-list fast path. The producer constructor change is broader than
its old @producer restriction specifically for the canonical grounded List;
actual-emission controls must demonstrate full field demand and generic fallback.

Before promotion require independent noncanonical List element/quantity or
modified-constructor refusals, alias/import identity, complete tagged stages,
constructor head/tail demand and first-error order, public deferred/getter values,
raw/forged/reentrant entry and live dependency/host mutation controls. Checked
fixture rejection alone is not successful emission admission/refusal evidence.

The new j_region_has_loop recomputes a component plan for residual candidates.
Correctness can pass while checked request latency rises: measure normal request
cost separately. Existing Phase39 cost planner accepts a supplied baseline API;
its baseline preparation must expose the baseline role. Fresh preparation of
three startingPhase39 cost sources avoids feeding candidate-only metadata or
changing the cost auditor.

## Correction after Base List admission probe

The proposal04 nonbuiltin/quantity2 constructor assumptions above were too
restrictive for canonical Base List: the probe identifies builtin owner/ctors
and quantity1 constructor fields. The current narrow revision explicitly
requires builtin List/Nil/Con and quantity1 fields while keeping ADT parameter
Qua2, canonical U32, specialized result Kind2 and recursive List2U32 identity.
This correction supersedes the admission description above; the original review
is retained as negative evidence. No claim that proposal04 admitted canonical
Base List survives. Actual checked emission and controls remain required.
