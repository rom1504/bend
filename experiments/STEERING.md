# Current frontier: Phase63 State09 installed

The authorized implementation phase is complete. State09 is installed and
verified as equality-derived checked B1; its separate genuine B2/B3 images pass
their gates. The compiler algorithms remain Bend. No upstream update or PR
comment was made.

[Final results](../implementation/phase63/state09-results.md) ·
[Qualification](../implementation/phase63/evidence/state09-qualification.json) ·
[Design](../design/phase63/ready-world-and-lowering-plan.md) ·
[Architecture](../docs/self_hosted/compiler-request-pipeline.md).

## Measured result

The balanced 23-source, three-role, three-round campaign passes207/207 workers.
Equal-source geometric means of median times:

| Clock | Previous B2 / TS | State09 B2 / TS | Time reduction |
| --- | ---: | ---: | ---: |
| Compilation alone | 2.05505× | 1.63275× | 20.55% |
| Host/API import plus first compilation | 1.40665× | 1.15092× | 18.18% |

Every source improves over the previous compiler on both clocks. Compilation
remains slower than TS on every source. These are fresh processes with prepared
persistent Base caches, not OS-cold runs, installed-B1 CLI timings or generated
program timings. Raw modules match the qualified historical artifacts exactly.
The old Phase61 headline and intermediate State06 campaign stay separate.

## Selected mechanisms and boundaries

- Retain an authenticated Base checker world and parser indexes; extend only
  with the actual source suffix. Public/fallback checking remains.
- Transport shared immutable state through a validated frame3 DAG using fixed
  constructor decode paths. Mandatory corruption fails; invalid optional state
  falls back. Smaller bytes or warm-only throughput are insufficient evidence.
- Keep one annotated library lowering context and save each retained definition's
  lowered output once, preserving demand, references, SCC/source order and bounds.
- Compute host field conversions once and carry arity already computed by call
  analysis. No new general mutable query cache or eager fact prepass.
- Carry completed source fragments directly and remove four unused host helpers.

State09 has28,115 physical Bend lines across114 modules: +362 versus Phase61,
−11 versus State06. The stronger reuse contracts add five data types; do not
claim this is a reduction in overall conceptual complexity.

Strict36/export94, full checked semantic suites, B2 construction/driver checks,
fresh own-source type acceptance, exact B2/B3 equality, B2 source96/numeric34/
composition18/overapplication2, raw23/point45 equality, legacy42/default24 and
five helper-integrity controls pass. The expected unsafe proof-trust refusal
remains. These finite, overlapping suites are not full-language soundness proofs.
Metadata and permission failures remain failed; explicit successful successors
close the selected gates.

## Next investigation, not selected implementation

1. Profile the selected image on Numeric, Lexer and Map, then confirm attribution
   across all23. Earlier profiles no longer assign the current residual gap.
2. Retain more typed signature/layout facts at their original demand point in
   the immutable owning plan. Require exact local oracles and request-level gain.
3. Count remaining header/completion/provenance scans and test a carried source
   view. Lexer has the worst current ratio; that alone is not causal evidence.
4. Separate fixed validated admission from source-proportional work. Persistent
   sessions may change a distinct metric and must not replace the fresh-request
   parity target.

Parity requires another38.75% reduction in measured compilation time. General
WNF memoization had less diagnostic benefit than arity reuse; checked call-spine
reuse was reverted for no useful request gain; owned positional-ABI work was
inapplicable because the actual images use named layout. Do not relaunch these
without a new discriminating hypothesis and measured cost budget.

## Identity and evidence

Source `0ebe491e727721857ce981ff5a2167a52d1e040f5674915a3349fea33bed8ed5`.
Checked B1 `4a208bffcf47b5d19f8ff18be1fc01b2faf988b37d38e7f5db9e6bd42d79905f`.
B2/B3 `e838cbab6e6543d1785da0474c50c1c33ab91e6806d2e6796cfcbeabf5b98003`.
Upstream `018751270e800bc222a93dad7f257083ee53a5f7`; Node24.18.0.

[Evidence restoration](../selfhost/tools/performance/phase63/artifacts/README.md)
retains failures and rejected attempts. The previous seven installed files are
preserved under release-history/97f412af…; all110 inherited unrelated files are
unchanged. Historical Phase58–62 inputs retain their existing capsules.

Root alone executed serial CPU3 targets under one process-tree guard: 1GiB Node
heap, 2GiB RSS ceiling and 4GiB available-memory floor. Independent agents handled
source, tooling, analysis and review on CPU0. Future target work should keep
that memory discipline and use short checked-B1 controls/screens before broad
B2/reproduction/release qualification. Stage only explicitly owned paths.
