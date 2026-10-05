# Diagnostic aggregate transport scaling

These six points use the exact reviewed `aggregate-transport-v4.bend`, SHA-256
`51febd83c9f780dfd99252b73621a8c032a022c445f579fbd2000ce41789ec66`.
They change only arguments and expected outputs. They are **additional diagnostic
points**, not new weights or replacements in the primary 45-point / 23-source
catalog. A favorable result cannot improve that catalog's reported aggregate.

| Export | Size | Seed / x | Independent U32 result |
|---|---:|---:|---:|
| bench | 32 | 3 | 32355 |
| bench | 256 | 3 | 258817 |
| bench | 1024 | 3 | 1035264 |
| deep | 32 | 9 | 1960 |
| deep | 256 | 9 | 72856 |
| deep | 1024 | 9 | 1077784 |

`aggregate-scale-catalog-v1.py` models run count and weighted values directly,
with a second periodic-sum check for each `bench` point. For `deep`, it sums the
independent scalar leaf formula for all `n+1` values using wrapping U32
arithmetic. No compiler or generated module supplies these results. The retained
production receipt is `selfhost/build/phase48/aggregate-scale-plan01/oracles.json`.

The two exports cover a tail state machine with a persistent encoded list used
twice, and non-tail recursion with a live caller while a pair-returning helper
executes. These points neither cover every aggregate shape nor establish
physical heap allocation after JIT optimization. The existing untimed source
controls qualify constructor execution; timing uses untouched generated modules.
The fixed historical RLE point remains part of the unchanged primary corpus.

## Root-only serial commands

Run from the repository root, after the current target job finishes. Output
paths must be fresh. `--attempt` takes the checked-attempt directory, not its
`attempt.json` file. The earlier example supplied the file and was corrected
after an `ENOTDIR` orchestration failure; the failed acquisition is preserved. There is one unique source, so each preparation compiles it
once for all six points. Each role uses the same source and public exports.
The pinned TypeScript preparation performs its normal clean-checkout and source
identity checks. The reference packer verifies Base agreement and all point,
source and module identities. No new timing runner or target adapter is used.

```bash
set -euo pipefail
P48_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P48_SCALE=selfhost/tools/performance/phase48/controls/aggregate-scale-catalog-v1.json
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_SCALE" --set full --role baseline --attempt selfhost/build/phase47/checked-array06 --node "$P48_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase48/aggregate-scale-baseline01
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_SCALE" --set full --role candidate --attempt selfhost/build/phase48/checked-values03 --node "$P48_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase48/aggregate-scale-candidate01
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_SCALE" --set full --role typescript --upstream selfhost/.bootstrap/upstream-phase23 --node "$P48_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase48/aggregate-scale-typescript01
python3 selfhost/tools/performance/programs/freeze-reference.py --catalog "$P48_SCALE" --baseline selfhost/build/phase48/aggregate-scale-baseline01 --typescript selfhost/build/phase48/aggregate-scale-typescript01 --out selfhost/build/phase48/aggregate-scale-reference01
python3 selfhost/tools/performance/programs/run.py --catalog "$P48_SCALE" --set full --budget 60 --baseline selfhost/build/phase48/aggregate-scale-reference01/manifest.json --candidate selfhost/build/phase48/aggregate-scale-candidate01/manifest.json --node "$P48_NODE" --cpu 3 --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase48/aggregate-scale-screen01
```

The 60-second preset requests three fresh balanced rounds, 350ms warmup and
150ms target samples. It is a nominal budget, not a completion guarantee or a
steady-state result. Inspect completion, exact values, individual ratios and
within-sample drift before deciding whether the pass earns a longer check.
Retain any TypeScript stack or semantic failure; do not silently reduce sizes.
If evidence warrants confirmation, rerun the same modules/catalog with budget
300 and a fresh output directory: five rounds, 600ms warmup, 250ms target.
Compilation cost, emitted size and full-corpus regressions remain separate gates.
