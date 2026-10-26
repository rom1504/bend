# P143-003 — select the large-request checker without taxing small requests

The independent checked prototypes pass 20 complete checker-state controls,
47 occurrence/range controls,12 complete erasure-closure controls and10
prepared-Base controls. The latter assert both actual admission/fallback routes
and expected success/error results. They include templates, law filling, TODOs,
and a real collision with the Base name `Unit`.

Two fixture source-check errors, one row-format observer mismatch and an invalid
law-filling fixture are retained in receipts. The invalid typed law fill follows
the original full-check fallback and retains a TODO; its inferred replacement
exercises the new route and succeeds. This was not a demonstrated compiler bug.

The private checker shares a right-to-left first-later-definition schedule and
defers removal of replaced childless definitions from the ordered book. Every
lookup-index update remains in its original order. The complete world is
canonicalized on success and failure; original admission, collision replay,
memo/fresh/checked state, diagnostics and final verification stay independent.

## Measured discriminator and negative result

Shared-API hosted synthetic checking, three balanced orders:

| Definitions | Original seconds | Schedule + deferred publication | Ratio |
| --- | ---: | ---: | ---: |
|100|0.035711|0.029027|0.813|
|500|0.401754|0.161081|0.401|
|1000|1.676547|0.279219|0.167|

Real prepared Lexer/Map/closure requests have exact complete results but the
always-enabled route is slower: medians0.0782→0.0917s,0.0178→0.0244s and
0.0221→0.0340s. Finalization unnecessarily pays for the unchanged Base tail.
These hosted small-request results reject unconditional enabling.

An independently checked prepared-Base scaling fixture gives combined/original
ratios1.371,0.966,0.624,0.259 at16/64/256/1024 added definitions. Select a
conservative **256 childless-definition threshold**, not the noisy64-row
crossover. Count only the actual new suffix and stop at the threshold. Parse
errors short-circuit first. Below it, preserve the original checker call; do not
use the schedule-only route as the supposed unchanged fallback.

This is a profitability choice, not an admission rule. Both routes retain all
semantic gates. The fixtures are small arithmetic definitions and hosted timing;
they do not establish a native/compiler-self-build gain or universal crossover.

## Integrated candidate

Source03 SHA`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`
combines the gated checker, collision-safe ordinary erasure visited set and
modular one-traversal freshness query. It overrides only `p86_plan_loaded`,
`nr_walk`, and `nd_comb_fresh`. Proof declarations and final verifiers remain
byte-exact. NU_Set occurrence summaries are rejected in favor of the simpler
range predicate; they add setup cost without a demonstrated advantage.

Independent source checking and complete frozen Lexer/Map/closure QBE pass.
A257-definition fixture also matches a fresh qualified Phase137 QBE oracle,
exercising the profitable branch. These are the admission conditions for one
native acquisition, not a native speed/qualification claim. Measure unchanged
Phase142 source with the resulting compiler against the frozen complete QBE,
then measure machine construction separately. Keep all attempted native outcomes.
