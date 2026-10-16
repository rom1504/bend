# Candidate03 serial native queue

Prepared for root execution only. The new
[native-queue03.py](../../selfhost/tools/performance/phase102/native-queue03.py)
uses the actual sequence from `native-chain02/chain-queue.json` and `qualify02.py`,
with fresh paths and explicit recipe/control/application arguments. It does not
choose the final source, edit any source or policy, or execute an admission or
selection change. It invokes the existing recipe-to-policy preparer using root's
description.

Root supplies a complete reversible **Phase98-to-final** recipe. A recipe from
an intermediate source or the compact D04 public profile is refused. Source is
read from that recipe's pinned `candidate`; there is no candidate hash in the
queue. `--controls` accepts one or more final `check-emitted.py` output receipts;
`--apps` accepts one or more final Phase102 application `run.py` receipts. The
existing native inheritance method authenticates their full products and outputs.

Run from the repository root, after assigning these values to actual final
paths and the intended changed-backend description:

```sh
P102_RECIPE=/absolute/path/to/final/changes.json
P102_CONTROLS=/absolute/path/to/final-controls/report.json
P102_APPS=/absolute/path/to/final-apps/report.json
P102_REASON='Root-supplied description of the final changed backend'
P102_QUEUE=selfhost/tools/performance/phase102/native-queue03.py

python3 -B "$P102_QUEUE" chain --recipe "$P102_RECIPE" --reason "$P102_REASON" --dry-run
python3 -B "$P102_QUEUE" chain --recipe "$P102_RECIPE" --reason "$P102_REASON"
```

The chain stops on the first nonzero child result or exception. Its seven jobs
are acquisition of the checked upstream B1, source/policy preparation,
independent frozen-Phase98 B2 reference on the final source, B1 self emission,
matched O2 B2 build (420 seconds, 6 GiB RSS), B2 binding, and B2 self emission
requiring exact B1 C. Existing guards and request resource limits are unchanged.
Acquisition itself retains its separate checked-upstream/build/bind receipts.

Default outputs are:

| Purpose | Path under `selfhost/build/` |
| --- | --- |
| B1 acquisition and binding | `phase102/native-b1-03/` |
| Chain, B2 and subsequent gates | `phase102/native-chain03/` |
| Normalized recipe and policy | `phase99/phase102-final-plan03/` |
| Six-source B1/B2 screens | `phase99/phase102-b1-screen03/`, `phase99/phase102-b2-screen03/` |
| Changed runtime product acquisition | `phase99/phase102-runtime-products03/` |

After root reviews the completed `native-chain03/chain-queue.json`, continue
explicitly; the chain never starts this phase automatically:

```sh
python3 -B "$P102_QUEUE" qualification --recipe "$P102_RECIPE" \
  --controls "$P102_CONTROLS" --apps "$P102_APPS" --dry-run
python3 -B "$P102_QUEUE" qualification --recipe "$P102_RECIPE" \
  --controls "$P102_CONTROLS" --apps "$P102_APPS"
```

Append more receipt paths after `--controls` or `--apps` when needed. This phase
requires the completed same-recipe chain and unchanged queue method. It runs
ordinary controls, broad45, conformance prepare/B1/B2/diagnostics/collect, native
inheritance, runtime batch continuity, six-source B1/B2 comparisons, then changed
runtime product acquisition. The last acquisition is retained from `qualify02`;
it builds changed products but does not time them. The earlier `apps50` command
is omitted because root supplies the already completed final application receipts.

Each phase keeps a distinct queue JSON plus complete `.stdout`/`.stderr` files
for every child command. Rows retain argv, return code, start/finish time,
monotonic elapsed seconds and output hashes. An interrupted command records its
exception rather than inventing a return code. The queue rechecks its recipe,
source and supplied receipt bytes between jobs. It refuses existing outputs;
`--run-id 04` can select a completely fresh campaign without changing the method.
There is no automatic failed-job retry or overwriting of earlier observations.

Runtime timing, backend-specific evidence, original final-image controls,
admission and publication remain separate decisions in the
[qualification](native-qualification-plan.md) and
[release](native-release-plan.md) plans. In particular, after inspecting changed
products, root can run the existing runtime `measure` command on the generated
`phase98-products.json` and `upstream-products.json` into fresh output paths;
an empty changed subset does not justify an empty measurement campaign.
Queue completion alone makes no release or no-regression claim.

## Versioned runtime-reuse continuation

Use the separate
[native-queue03-reuse.py](../../selfhost/tools/performance/phase102/native-queue03-reuse.py)
for candidate03 qualification when reusing authenticated candidate02 runtime
products. It accepts only the qualification phase and checks the completed
chain's exact source, recipe and frozen original queue method. The original
`native-queue03.py` stays unchanged.

```sh
python3 -B selfhost/tools/performance/phase102/native-queue03-reuse.py qualification \
  --recipe "$P102_RECIPE" --run-id 03 \
  --controls selfhost/build/phase102/final-controls03/report.json \
  --apps selfhost/build/phase102/final-broad03/report.json \
         selfhost/build/phase102/final-screen03/report.json
```

Add `--dry-run` for command review. All eleven preceding gate commands and all
output paths are unchanged. The final `runtime-acquire` uses
`phase102/runtime-reuse.py acquire` with
`--reuse selfhost/build/phase99/phase102-runtime-products02/report.json`.
That existing method permits old binary reuse only after fresh native B1/B2
whole-C equality and authentication of the historical build. It still builds
different C. Run either qualification queue once, not both; they deliberately
share fresh candidate03 output paths and refuse existing receipts.
