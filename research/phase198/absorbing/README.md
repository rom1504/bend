# Absorbing countdowns at shared backedges

This isolated x86 compiler experiment lets a positive countdown finish when one branch has already reached a fixed point. It preserves the original zero-fuel result, complete parallel argument vector and calling convention. The proof and timing threshold are in [plan.md](plan.md). The earlier [Phase197 experiment](../../phase197/discovery-b/absorbing/README.md) measured direct assembly edits. Phase198 uses a different implementation.

## Focused whole-program results

| Complete program | Direct encoder, session 1 | GNU assembler, session 1 | Direct encoder, session 2 | GNU assembler, session 2 |
| --- | ---: | ---: | ---: | ---: |
| BST64 | 0.7543 | 0.7575 | 0.7553 | 0.7527 |
| Draining queue | 0.1542 | 0.1496 | 0.1698 | 0.1512 |

Each entry is the median candidate/baseline elapsed-time ratio over four balanced pairs. Every pair favored the candidate. Each sample validated 8,451 complete BST64 results or 690,313 queue results, with four additional warmups. These standalone comparisons support selection for combined qualification. The queue is an authored transfer case.

The checked selector changed one function out of 207 in BST64 and one out of 178 in the queue. In both, it preserved the shared latch and set the fuel predecessor to zero. BST64 needed an immediate move and a stack store. The queue needed one register move. The regenerated BST64 direct object exactly matched the qualified Phase195 baseline. [Machine witnesses](evidence/paired-machine-differences.json).

On the 64-node input, both versions executed 64 descent calls. The positive countdown body ran 4,160 times in the baseline and 429 times in the candidate. Leaf-arm visits dropped from 3,795 to 64. All 3,731 skipped trips were repeated leaf visits. The direct and independently assembled baseline and candidate matched the mature C result at all six tested input points and passed 72 raw-worker observations each. Both queue implementations matched the independent formula at seven input points. The first runtime driver stopped before timing on a relative-path formatting error. Its corrected version reused the identical emitted objects. [Emission and initial stop](evidence/paired-emission01.tar.gz). [Complete successful samples, oracles and sealed receipts](evidence/paired-runtime02.tar.gz).

## Implementation and transfer

[absorbing.bend](absorbing.bend) recognizes the zero test, predecessor, pure predicate, conditional and shared backedge after private-function copy elimination. On each arm it checks local copies in order, the backedge arguments by position, and the exact predicate on the next state. A certified branch assigns zero to the predecessor immediately before the existing backedge. A constant written on the first visit therefore retains its canonical bit representation. Zero fuel returns the original word untouched. Constructor IDs come from the program being compiled. The other arm can contain heap and reference-count operations because every execution of that arm is retained.

The one-function [hook](hook.bend) is the whole interface to instruction selection. The standalone patch stages in an isolated tree with [stage.py](stage.py). Its staging checks compare normalized declarations with the checked-API projection and run `git apply --check`. The module does not inspect program, worker, source or constructor names. The tested ABI frame conventions do include backend-owned names for the state word and result pointer.

The standalone API was acquired from checked source `2bc6aba1…`. All 40 controls passed, including six positive cases and 34 deliberate refusals. Seven independently observed worker pairs exercised both the accepted and refused paths. Each assembly route returned `checks=2272 errors=0`. After normalizing only function names, each of the four positive assembly pairs differs by one instruction, and all three refusal pairs are identical. [Finite assembly witnesses](evidence/finite-machines.json). The qualified-source parent is `ee95d489…`. The [patch](compiler.patch) has SHA-256 `7eea124d88433cf3d5a6bf93cedf9cea0bab7fd6296e230e08ac6cc840e5e6ae`. It independently [stages on Phase195](evidence/standalone-stage.json) and [stages on the selected Phase197 pair](evidence/combination-stage.json). The checked API and finite machine controls used the standalone projection. [Raw successful receipts and emitted worker assembly](evidence/checked-api-controls.tar.gz).

The [qualified-machine census](evidence/machine-census.json) found eight countdown headers with a nearby conditional before any call across 45 existing executables. Two had a copy-only route to the same header, both the product descent worker in BST32 and BST64. Four edit-distance/local-pair headers and two Mandelbrot harness headers had additional work on both routes. The scan deliberately requires one particular machine layout. The independent [draining queue](drain.bend) exercised source-level transfer. An additional scalar epoch, BST32, and bitonic screen remains pending.

The [control driver](controls.mjs) submits source-independent compiler data directly to the checked export. Its separate [C observer](observer.c) calls the real emitted functions. The [whole-program driver](emit.mjs) shares only immutable prepared data, runs both checked selectors, and requires the baseline direct objects to match the qualified ordinary objects on every catalog row. The [runtime driver](measure.py) builds direct and independently GNU-assembled siblings, compares complete outputs with the mature C references or independent fixed-width formulas, and records paired timings and separate iteration-counter runs.

Four initial upstream checker refusals were retained with their original source snapshots, stderr, and sealed guard receipts. They rejected a computed scrutinee, a multi-element bracket-list pattern, a match whose scrutinees were out of binder order, and a constructed local requiring an explicit type. [Refusals](evidence/upstream-refusals.json) and [raw receipts](evidence/checker-refusals01.tar.gz).

## Reproduction

From the repository root, prepare a fresh standalone overlay with `python3 -B research/phase198/absorbing/prepare.py --out selfhost/build/phase198/absorb-api-src-FRESH`. The tested overlay used the qualified Phase195 parent from `selfhost/build/phase197/baseline-source01/compiler.bend`. Under the shared guard, acquire that overlay with the checked hosted driver and run the controls against the resulting authority.

```bash
python3 -B research/phase198/qualification/job.py --rss-mib 3072 absorb-api-FRESH 90 96 \
  selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/phase198/absorb-api-src-FRESH/compiler.bend \
  --exports selfhost/build/phase198/absorb-api-src-FRESH/exports.json \
  --out selfhost/build/phase198/absorb-api-FRESH --engine selfhost/.assets/bin/bun \
  --upstream selfhost/.bootstrap/upstream-phase182
python3 -B research/phase198/qualification/job.py absorb-controls-FRESH 40 24 \
  selfhost/.assets/bin/bun research/phase198/absorbing/controls.mjs \
  --api selfhost/build/phase198/absorb-api-FRESH/report.json \
  --out selfhost/build/phase198/absorb-controls-FRESH
```

For a standalone maintained-source candidate, run `stage.py --api <tested-overlay>/compiler.bend --out <fresh-directory>` with Python 3. The generated patch changes only `selfhost/src/back/x86/function.bend`. Use `--tree <prior-stage>/maintained` to reproduce the composition staging against an already selected parent. When combining with the separate Phase198 permutation rule, both hooks customize `x185_function_copied`. Evaluate `x198a_body` once and pass its body result to both permutation selection and the ordinary fallback. That combined hook requires its own machine controls and qualification.
