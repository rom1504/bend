# Phase195 checkpoint — paused at user request

No maintained compiler changes, native qualification, installed-image promotion or parity claim. The qualified Phase194 full-suite result remains **1.971034× mature Bend C**. User requested stopping on 2026-11-14 because quota was exhausted. All execution jobs are terminal.

## Results worth keeping

The final [balanced six-program screen](prepared-candidates-screen01.md) has seven rounds, authenticated unchanged C/QBE/Phase194 products and independent output oracles. Branch-plus-call fact propagation takes **0.886927× baseline runtime** geometrically (11.31% less). Adaptive register allocation takes0.968662×, RCX-only1.009410×, and table-plus-float-selection composition0.949728×. Edit-distance dispersion is retained. These are development-only results, not a new native45 score.

Earlier isolated table lowering improves ray runtime27.05%; branch facts improve edit distance about27%; sqrt specialization improves ray about6.85%. Their gains cannot be added. A combined table/call/sqrt compiler passes source checking, component machine controls and six ordinary-program oracles, but its runtime has not yet been measured.

Physical selection removed instructions without improving runtime; unconditional extra registers regressed state-heavy programs. Keep these negative results. The adaptive policy adds9,233 bytes over RCX-only, so do not integrate it without evaluating its maintenance/compilation cost. See [research/results draft](results-draft.md) and [partial experiment checkpoint](checkpoint01.md).

Shared immutable preparation passed twelve exact assembly/object comparisons and six independent machine oracles. The subsequent four-emitter/six-input batch took163.615s, with33.726s shared preparation,0.199s freezing and126.345s emission; peak RSS1.396GB. Saved-work estimates are projections, not a controlled end-to-end speedup.

## Resume in this order

1. Acquire and test the residual-cycle parallel-copy prototype: `cycle-api02-argv.json` and `combined-cycle-api02-argv.json` under `selfhost/build/phase195/`. Their exact sources are prepared, but neither acquisition has run. Use selection/parallel-cycle-driver-v2.mjs and its fixed C observer. Existing ray code snapshots all12 parameters on one cycle; proposed residual-only handling may reduce72 copy instructions to about16. This is a prediction, not a measured improvement.
2. Time combined table/call/sqrt products (`combined-dev-build01`) and, if valid, combined-cycle products. Keep the frozen six-case partition. Reject complexity without real runtime benefit.
3. Run the independent store-to-next-iteration-load diagnostic: `loop-carry-diagnostic-plan01/plan.json`; command/proof in research/phase195/branch-facts/remaining-machine/loop-carry.md. This is a causal machine experiment, not a compiler pass.
4. Only then integrate selected mechanisms using research/phase195/maintained-integration-plan.md and qualification templates. Complete broader native45/runtime/ABI and N1/N2/N3 gates before qualifying a new compiler. Original Phase194 and installed189 stay available.

Optional bounded pending work: owned-observer diagnostic source05 (experimental-v6) has not been checked; stop if its final source retry fails. Earlier versions failed parsing, absent symbols or type inference, so no actual Map optimization is established. The independent ownership fixture showed a large ceiling, not application speedup. Adaptive source02 adds actual policy-path controls and remains unacquired.

Hardware-model research is saved under research/phase195/hardware-models/. CPU is Intel Ivy Bridge XeonE3-1245V2. No llvm-mca/tool package was downloaded, no model was run and no predictive accuracy is established. Exact Debian tool URL/hash and next experiment are in that research directory. Keep this research bounded alongside compiler work.

## Boundaries and resources

The frozen35-case held-out list remains unchanged, but baseline machine code for Map128 and record256 was inspected during ownership research. Report that leakage and an additionally uninspected subset; do not call all35 untouched. No held-out timing in this checkpoint.

One CPU3 target lane, existing5GiB disk reserve and pinned assets remain mandatory. User is handling disk cleanup; do not resume archival work automatically. Earlier reviewed exact-member retention receipts remain preserved. No target/security settings were changed.

Reproduction methods are in selfhost/tests/phase195; source/API/job plans and raw products remain under selfhost/build/phase195. The receipt archive preserves completed reports, commands, source-preparation manifests and failures. `tally-guard-cost.py` regenerates cost accounting; draft totals are explicitly snapshots. No recursive acceleration or formal compiler-correctness claim.
