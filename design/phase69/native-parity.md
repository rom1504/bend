# Phase69: remove excess native work, targeting upstream parity

The user authorizes implementing the findings of the compiler23 native survey,
with compiled C program parity as the primary target. Preserve correctness,
B1/B2 compilation cost, generated JS behavior and simplicity. The compiler
remains implemented in Bend. Starting source is `c84246e` / compiler23; pinned
upstream is `059266225b77c8ca256ac6b25ee5c21449bab151`. Installed Phase67 and all
earlier raw evidence remain separate and unchanged until release qualification.

[Evidence motivating this design](../../implementation/phase68/c23-parity-survey.md).
The previous six-family C result is 1.724× upstream. Numeric/arrays are near
parity; tree, lexer, Map and closures contain the measured excess work. This is
a finite mechanism corpus, not the broader 45-point JS set or whole-language
coverage. A fresh combined campaign must establish any new runtime ratio.

## Implementation order and falsifiable hypotheses

1. **Reachable parallelism.** Compute bang facts from runtime-reachable bodies
   and use the same domain for scheduler and worker admission. Dead definitions
   must not change sequential mode; live bangs and indirect/foreign/device roots
   must retain their behavior. The saved-C mode-only effect is already measured:
   14.9% less tree time and 11.9% less lexer time. Integration may admit more
   workers, so do not assume generated C changes only one flag.
2. **Static immutable constructors.** Intern closed constructor graphs using
   the existing static image ABI, once per native compilation. Ordinary and
   scheduler paths must see the same prepared representation. Preserve exact
   constructor/layout identities, static-safe ownership, demand/error order,
   and ordinary allocation for unknown or effectful values. The existing lexer
   experiment removes 473,088 allocations and 10.1% time independently of mode.
3. **Known partial applications.** Construct the remaining known closure with
   already evaluated captures, avoiding intermediate curried factories. Preserve
   partial-call demand, argument/capture order, ownership, overapplication and
   indirect fallback. Start with actual leading lambdas and existing direct
   adapters, not a speculative whole-program points-to analysis.
4. **Product transport.** Prove a constructor-known internal loop/result can
   transport its fields without heap reconstruction while retaining the generic
   raw entry and its demand/drop/error behavior. Start with a saved-C lexer
   loop discriminator; extend representation through actual caller/continuation
   edges if it pays. Map's nested helper products motivate a later multiword
   scheduler ABI slice, not a benchmark-specific Map rewrite.
5. **Owned reconstruction and reuse.** Separate cold/unique field transport,
   direct taking, compatible storage reuse and unchanged-field preservation.
   Prior seal-only and spare-only experiments had small gains; a new experiment
   must demonstrate a stronger mechanism. Keep shared/static fallbacks and
   bounded retained memory. Generalize only after clean output/time evidence.

Each item has a separate hypothesis under `experiments/phase69`. Preserve
failed variants and negative results. Prefer adding a fact once and reusing it
across lowering paths over separate analyses or another general IR. No
benchmark-name rules, unchecked annotation trust or weakened raw API contract.

## Parallel execution and ownership

Root owns all production integration and one guarded CPU3 target tree. Five
agents own independent static-image, closure-factory, product-transport,
node-reuse and method-preparation lanes. They inspect source and prepare patches,
controls and derivations; they do not run competing compiler/native jobs.
Root integrates disjoint patches sequentially and commissions independent
reviews of ownership, demand, ABI and measurements before selecting a candidate.

Use exact input/snapshot identities and fresh outputs only under
`selfhost/build/phase69`. Guard process-tree RSS at 2 GiB with a 4 GiB available
memory floor; Node heap 1 GiB and stack 4 MiB. Keep source/data work on CPU0.
Reuse saved compiler23/upstream native acquisitions, not obsolete slow installed
benchmark binaries. Check disk and process state before larger qualification.
Do not clean up unrelated files or modify old raw to make space.

## Fast loops and selection gates

- Inspect and compare known source/assembly before building. A saved-C edit is
  a diagnostic only; all selected production behavior must come from Bend.
- Build an isolated checked B1 via the maintained equality development workflow.
  Run focused frontend checks, then the smallest native oracle and mechanism
  controls. Record rejection phases and failures instead of updating goldens.
- Acquire C/Clang binaries once per changed output. Reuse verified binaries for
  balanced fixed-work timing with independent digest checks and intervals above
  100 ms. Keep counted/profiled runs separate from clean timing.
- Test generalization on unrelated source witnesses: dead/live bang roots,
  shared/consumed static graphs, varied closure captures, escaping/partial calls,
  nested/shared products, wrong tags and competing errors. Thread controls must
  retain scheduling semantics. Physical GPU execution remains an explicit limit
  if no GPU is available.
- On a combined selected compiler, compare all six families against both
  unchanged compiler23 and pinned upstream in the same campaign. Report every
  family and the equal-family geometric mean; do not multiply overlapping gains.
- Run the existing 37 selected native cases, raw controls and JS-route protection,
  then genuine B2 generation and selected B1/B2 native emission/latency checks.
  Full self-check/reproduction and installed release promotion are separate gates
  on the final stable selection, not repeated per small experiment.
- Record physical/code Bend lines, modules, C size/Clang cost, peak memory and
  target/process time. A speed win that regresses semantics is rejected; material
  compiler-size or compilation-cost regressions need explicit tradeoff analysis.

## Decision and delivery

Aim for 1× or better on the finite C set, while identifying individual residual
families rather than hiding them in an average. If a prototype fails, use its
counterexample or profile to choose the next general mechanism. A 0.5× result
requires doing less work than upstream too; known nonescaping closures and
producer/consumer elimination are later candidates, not assumed gains.

Commit/push the design, coherent implementation checkpoints and a comprehensive
[report](../../implementation/phase69/README.md). Preserve compact reproductions,
raw receipts, method versions and failed attempts in a verified capsule. Update
the native backend documentation and current frontier. Do not post PR comments.
