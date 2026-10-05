# Loop-qualified literal-array diagnostic points

These points use the reviewed `array-literals-v2.bend`, SHA-256
`00832788f6f71126bb84b5959cd69a2cd5f2c73566a5ee226f239fb7ef3e10d4`.
They are additional amortization diagnostics. The primary 45-point/23-source
catalog and its weights remain unchanged. The fresh loop-qualified arrays03
control run passes 96 oracles, 41 boundaries and 47 entry/refusal observations;
that proves correctness and entry scope, not speed.

| Export | Iterations | Seed | Independent U32 result |
| --- | ---: | ---: | ---: |
| loop_bench | 0 | 3 | 0 |
| loop_bench | 1 | 3 | 1 |
| loop_bench | 128 | 3 | 206 |
| loop_bench | 8192 | 3 | 13310 |

The oracle starts with cells `[3,0.5]` and score zero. Each iteration reads cell
`i%2`, replaces it with `fround((i%7)+0.25)`, and updates score with
`fround(score+fround(old*0.5))`. Final checked conversion truncates this score.
The v3 control independently evaluates this recurrence, including nonfinite
inputs and a 50,000-iteration stack check. The 0/1 points deliberately expose
fixed entry cost; the longest point asks whether ordinary repeated work can
amortize it. Passing every value does not make a regression acceptable.

## Root-only serial commands

Run from the repository root only after the current target job finishes. All
outputs must be fresh. Each preparation compiles the single unique source once
for all four points. The maintained packer verifies the complete catalog,
Base agreement and exact checked role identities; the normal runner measures
the unchanged public export in each compiler's output. No target adapter or
special timing framework is added. `--attempt` takes the checked attempt
directory: `emit-worker.mjs` appends `attempt.json` itself. The earlier draft
incorrectly supplied that filename; these corrected commands do not. Root will
acquire the combined RNFA02 candidate once rather than duplicate arrays03 work.

```bash
set -euo pipefail
P48_LITERAL_NODE=/home/ai/.nvm/versions/node/v24.18.0/bin/node
P48_LITERAL_CATALOG=selfhost/tools/performance/phase48/controls/array-literals-scaled-catalog-v2.json
P48_LITERAL_ATTEMPT=selfhost/build/phase48/checked-combined-rnfa02
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_LITERAL_CATALOG" --set full --role baseline --attempt selfhost/build/phase47/checked-array06 --node "$P48_LITERAL_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 --out selfhost/build/phase48/literal-scale-baseline03
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_LITERAL_CATALOG" --set full --role typescript --upstream selfhost/.bootstrap/upstream-phase23 --node "$P48_LITERAL_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 --out selfhost/build/phase48/literal-scale-typescript03
python3 selfhost/tools/performance/programs/prepare.py --catalog "$P48_LITERAL_CATALOG" --set full --role candidate --attempt "$P48_LITERAL_ATTEMPT" --node "$P48_LITERAL_NODE" --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 --out selfhost/build/phase48/literal-scale-candidate-rnfa02
python3 selfhost/tools/performance/programs/freeze-reference.py --catalog "$P48_LITERAL_CATALOG" --baseline selfhost/build/phase48/literal-scale-baseline03 --typescript selfhost/build/phase48/literal-scale-typescript03 --out selfhost/build/phase48/literal-scale-reference03
python3 selfhost/tools/performance/programs/run.py --catalog "$P48_LITERAL_CATALOG" --set full --budget 60 --baseline selfhost/build/phase48/literal-scale-reference03/manifest.json --candidate selfhost/build/phase48/literal-scale-candidate-rnfa02/manifest.json --node "$P48_LITERAL_NODE" --cpu 3 --rss-mib 2048 --available-mib 4096 --out selfhost/build/phase48/literal-scale-screen-rnfa02
```

The 60-second preset requests three fresh rotated rounds, 350ms warmup and
150ms target samples. This is a nominal screen budget, not steady-state proof.
Keep values, ratios, sample ranges/drift, code size and compiler acquisition cost
separate. Three acquisitions have a 180-second per-source ceiling; they occur
outside the execution budget. Do not reduce sizes or bypass guards on a failure.

The actual combined Evening module is acquired separately under the maintained
Phase37 catalog. Its intended profitability refusal is checked by the optional
fourth module argument to `array-literals-controls-v3.mjs`. Compare each emitted
definition against Phase47 `array06-full`, identifying allowed typed F32 literal
changes explicitly; the combined image contains that independent pass, so
whole-module byte equality is not assumed. No comparison is credited until the
actual module exists and its checked receipt is bound.
