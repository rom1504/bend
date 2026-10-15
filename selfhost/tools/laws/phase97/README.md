# Phase97: test the usefulness and boundaries of laws

[Results](../../../../implementation/phase97/README.md) ·
[Design](../../../../design/phase97/law-usefulness-experiments.md) ·
[Evidence restoration](EVIDENCE.md).

The unchanged Phase96 fast/audit commands remain the routine production suite.
Phase97 adds independently selected challenges, two supplemental production
witnesses, a compositional ownership model, and an isolated native lookup
experiment. Formal proof, finite execution, semantic rejection, native lifetime
failure and timing remain separate result categories.

With the authenticated workspace dependencies described in the
[law guide](../../../../docs/self_hosted/COMPILER_LAWS.md), a fresh ownership
proof check is:

```sh
python3 -B selfhost/tools/laws/phase97/check.py \
  --source selfhost/proofs/phase97/ownership/composition.bend \
  --out selfhost/build/phase97/my-ownership-check
```

It snapshots the complete relative source closure, checks/elaborates every body,
requires nonopaque theorem definitions and invokes unchanged BendTT/Lean. A
separate false equality must be rejected by the independent kernel. This checks
the explicit model; it does not prove the concrete runtime.

Replay the frozen targeted contracts with a new aggregate output directory:

```sh
python3 -B selfhost/tools/laws/phase97/campaign-v2.py \
  --section followups --out selfhost/build/phase97/my-followups
```

This uses the retained `challenge-targeted01` inputs: 228 baseline JS cases,
three semantic mutants and 34 baseline native cases. It does **not** re-extract
an edited production tree. Use Phase96 `run.py` for that purpose, and prepare a
new Phase97 candidate/corpus when the supplemental helpers change. Existing
attempt directories are immutable; restore missing frozen inputs from evidence,
never silently substitute a different compiler image or edit an old receipt.

| Method | Purpose |
| --- | --- |
| `challenge-run.py` | Apply eight bad and two equivalent independently frozen recipes to the original 226-case extraction; report uncovered helpers/admission failures separately. |
| `targeted-challenges.py` | Keep the 226 cases and add two frozen gap witnesses; retain the original affinity-invalid recipe and separately prepare its typing repair. |
| `formal-challenge.py` | Apply the independent literal fault to exact Phase96 representation extraction and unchanged laws. |
| `proof-negatives.py` | Require standalone admission before semantic law rejection; exclude syntax, affine usage and resource errors. |
| `ownership-boundary.py` | Mutate one generated-C child retain, preserving the known baseline and raw failure. Does not edit production C/runtime sources. |
| `campaign.py`, `campaign-v2.py` | Preserve failed first projection attempt and run corrected frozen02 respectively; follow-up section is identical. |
| `production.py` | Guard JS B2 full-value comparison or exact generated-C execution; explicit semantic mutant expectations. |
| `collect.py` | Authenticate accepted results, retain failures, calculate serial target cost and verify the complete archive. No target executions. |

`derivations.json` records the exact Phase96 checker/worker and Phase95 acquisition
copies. Changed output roots do not change acceptance. The new proof checker
reuses the existing audited Bun/Lean/kernel installation; native contracts reuse
the pinned JS B2 and Clang22. This is a reproducible workspace workflow with
external dependencies, not an automatic fresh-clone CI installer.

The [projection package](../../performance/phase97/projection/README.md) contains
the independent full-value oracle, frozen-source preparer, micro acquisition/
build and timing methods. `measure-v2.py` only raises the repetition cap from
two to four million to accommodate the faster candidate's doubled-count check;
timing windows, oracle, alternating rounds and sampling budget remain unchanged.
Failed `projection-timing01` is retained. The compiler request comparison uses
the same baseline source/cache/runtime assets and Clang O2 flags; helper micros
use O3. Do not combine their ratios or describe either as generated-program
speed against upstream.
