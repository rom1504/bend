# Bounded composed-session source review

Read-only review; no target executions or implementation changes. Inspected:

| Module | SHA-256 |
| --- | --- |
| `session/frontend-v01.bend` | a2bc3e3e1b1ee9b2cdcc7cf1fe354955e174d0274d5ec98bee10b961839af5e8 |
| `session/backend-v01.bend` | 6c47e34f4bea11d1a73090821ccf5d2393f227e6792a6fd62cdee16649ff2691 |
| `owner/bridge-v01.bend` | ae2246336f8829d2f707251bbf4444f66d063d677ff039c624efe18bfba9e4ad |
| `owner/core-v03.bend` | 8b75b93579aa398396eeb9941599c3c7dd4743ec0a19e9dfa9f0b9d047c98eaa |
| `verify/core-v02.bend` | b87be65c76070da9502cedd12f82fb6bf4f1239e96b2ab28117b7fdbcfa41064 |

These are experimental source contracts, not native qualification. The parent
owns composition, full request comparisons and eventual publication.

## Findings affecting correctness and admission

No additional correctness blocker was identified within the fixed-producer,
fixed-prepared-Base, internally-produced-cache contract.

1. `p140s_finished` now discards proposed frontend/raw/backend caches on any
   semantic `P111Emission` error and returns the prior session. Earlier parser,
   checker, annotation and runtime-admission failures likewise preserve previous
   state. Successful internal helpers may propose caches before later failure;
   those proposals do not escape the outer transaction.
2. `P134Planned` is success of the semantic plan, before rendered output and IO.
   A native adapter still must publish its retained session and rendering state
   only after the writer succeeds if it promises full-request transactions.
   This pure layer cannot establish successful file output or machine building.
3. The fixed Base/producer premise is essential. The checker bridge receives a
   literal producer epoch; `P140SCache` does not authenticate an arbitrary new
   `P86Seed` supplied by an external caller. An immutable seed held by the native
   session satisfies the premise. A general exported long-lived service needs
   an actual seed/producer identity check before admitting these capabilities.
4. Raw and private lowering retain exact static nodes, names, bangs and complete
   product signatures. Generic owners additionally check the incoming fresh
   counter. Frontend dependency analysis preserves ordered headers, complete
   types/children/flags/Foreign bodies, and propagates body changes transitively.
   The raw bridge separately compares erased/static facts. Do not remove these
   constraints to increase hit counts.
5. `p140v_open` and `p140v_array` reuse successful judgments with exact actual
   contexts, not claimed unchanged source. Static/effect-image and namespace
   checks run again. An independent source audit by the parser agent found no
   blocker under the private-success-cache premise. Its recommended additional
   controls concern constructor reorder/arity, changed effect blocking, parameter
   kind/name changes and an invalid earlier callee; these extend coverage rather
   than fix a known defect.

The owner agent separately confirmed fresh/cold/warm/no-op complete raw products
and QBE equality for real Lexer/Map numeric edits. This review does not replace
those receipts or establish a general invalidation theorem.

## Costs still paid

The raw bridge continues full static preparation, global bangs/signature
construction, dependency/context comparison, ordinary SCC/admission closure,
annotation validation, program assembly and final projection verification.
The frontend still constructs the current checker declaration/context views and
checks the dirty suffix. Preserved output text does not avoid these costs.

An exact whole static-image comparison deliberately disables all raw owner reuse
when a pooled literal changes. The historical `%result`→`%answer` source edit
therefore is a poor success case for this first gate. Actual numeric/policy edits
can preserve the pool, as the small Lexer/Map experiments did. A later symbolic
literal-ID scheme could widen the supported edit class; it is not implemented.

The backend currently chooses the prior post-optimization cache for
`p140v_array`. The same request's successful open cache is also a valid source
of raw judgments and may save the second raw-body verification on cold requests.
That is a separate small profitability choice; don't change it speculatively
without timing the complete pipeline and checking which private bodies change.

## Smallest next reuse below `p128raw_verified`

The new backend already replaces the earlier whole `p113a_verify` through
`p140v_array`. The old40.665s combined final interval therefore is **not** the
remaining cost of `p128raw_verified`. Separate timings for these two calls are
the cheapest next discriminator; do not count the same verification saving twice.

A small, tightly specified candidate is projection-result reuse:

```
ProjectionSlot = (exact P113DFunction,
                  exact ordered original-segment headers/constructors,
                  actual p118b_project_function result)
```

`p118b_project_function(function,ids)` consumes only the function and immutable
original/constructor IDs. On a hit, reuse its projected function/error. On a
miss, call the original producer. Rebuild current ordered projected output,
then always run **the original `p113e_functions` on every final function**, plus
original array/transport checks. This removes repeated projection and temporary
IR construction while preserving the final independent verifier. It does not
remove that verifier's body walks and table lookups. Expected gain is bounded
by measured projection time, currently unseparated; no numerical gain is claimed.

The larger next unit is one observer owner: retain `NO_Plan`, constructed reader
and adapter functions, helper seeds and retry disposition before their producers
run. Its key needs complete actual source/type/layout/erased-body dependencies,
synthetic-name absence, global admission facts, and the exact current original
worker used as the owning fallback. A helper-ready retry additionally depends on
ordered helper descriptions and the exact matched closed fallback function.
Conservatively compare the complete helper context once per request initially.
Do not reuse a reader with an old owning fallback just because signatures match.

This observer unit can skip more work than projection reuse, but integrating it
without a readset audit would be more invasive. First measure the residual late
path after the already implemented verifier cache; then choose one of these
boundaries. Neither higher cache hit counts nor the historical40s interval alone
establishes enough avoided work to justify another implementation campaign.
