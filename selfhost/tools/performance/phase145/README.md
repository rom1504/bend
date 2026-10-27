# Comparative work observations

These are bounded research observers, not a production compiler implementation.
Start with the [Phase145 report](../../../../implementation/phase145/README.md)
and [design](../../../../design/phase145/README.md). The qualified final04 source,
checked generated-JS API, native N2, runtime, Base carrier and all fixture inputs
are pinned by the plans. Do not substitute another ordinary/batch policy.

## Evidence layers

| Directory | Question | Gates |
| --- | --- | --- |
| `execution/` | How does the same Bend compiler run as JS and QBE native? | Exact full ordinary QBE; alternating fresh processes; frozen methods/inputs |
| `execution/` verified input observer | Does a repeated check inspect the same input? | Exact inverse instrumentation; data fingerprints/root IDs; complete QBE |
| `execution/` warm observer | How much does engine warmup matter? | Fresh complete request per iteration, same API engine, four exact products |
| `native/` | What runtime work and stages occur? | Existing sixteen-channel control, exact products, source/ELF/FID binding |
| `upstream/` | How does the pinned upstream implementation organize work? | Pristine/derived complete C equality and loaded/checked summaries |

Internal generated declarations and loop bodies are instrumented in copies.
The protected upstream TypeScript, checked original API, compiler source and
selected runtime are never edited. Diagnostic clocks are not production timings.
Counters are observations at explicit hooks, not all machine instructions or
all allocations in every execution engine.

## Actual completed paths

- `selfhost/build/phase145/execution-plan01/plan.json`: three original requests.
- `execution-clean01`: four alternating pairs each, all 24 QBE products exact.
- `execution-counts01`: selected internal declaration/loop counters.
- `execution-verified-plan01` and `execution-verified01`: strict Lexer witness.
- `execution-warm02`: four real fresh requests in one JS engine; warm01 failed.
- `execution-plan02` and `execution-index01`: actual compiler-index slice,
  three pairs. Oracle is `phase130/p145-index-oracle01/report.json`.
- `native-accounting02` and `native-observe02`: control and counter observations.
- `native-stages01` and `native-stages-observe01`: exact native stage clocks.
- `upstream03`: original, clean-transpiled and counted small requests.
- `upstream-full-parse01`: two bounded full-input parse-only observations.

All paths except the explicit oracle are relative to `selfhost/build/phase145`.
Plans preserve exact absolute fixture paths because paths can affect compiler
products. Metadata-only alternatives such as `execution-index-plan01` were not
executed; their presence is not another timing result. Methods with earlier
version suffixes preserve failed/preliminary plans and are not default choices.

Example reproduction after restoring the pinned dependencies, using a fresh
output directory and one controlled measurement lane:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase145/recheck01-guard \
  --seconds 180 --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase145/execution/run-v01.py \
  --plan selfhost/build/phase145/execution-plan01/plan.json \
  --out selfhost/build/phase145/recheck01 --case lexer --rounds 4
```

Use `--mode counts` for the reversible counter copy. The stricter witness uses
`run-verified-v01.py` with the verified plan. Engine-warm reproduction must use
`warm-v02.py`: Bun reused query-suffixed observer imports in v01, which the
output gate correctly rejected. The native and upstream subdirectory READMEs
describe their own immutable plans and bounded root-owned commands. Never nest
guards or run competing target lanes.

`summarize-v01.py --out FRESH_JSON` only reads completed observations, verifies
the expected output counts and nonoverlapping guard windows, and records costs.
It performs no compilation or benchmark. The native archive method preserves
readable receipts, methods, diagnostic derivatives and direct dependencies;
see its explicit omissions before assuming portable reproduction.

## Interpretation limits

Same-source native/JS timings address execution of our compiler. Upstream's
TypeScript implementation is a separate experiment, with source Base preparation
and C output. Neither ratio is a fresh full compiler parity result. Parse-only
upstream observations do not typecheck Base or source; old generic observer
scope wording is corrected in the full-parse summary and research addendum.

The evidence capsule omits compiler images, generated SSA/assembly and tool
binaries, retaining their exact pins and parent recovery references. Fresh sample
symbolization needs the exact omitted diagnostic ELF. Restoring another checkout
or toolchain requires renewed identity/output gates; this archive is measured
evidence, not a hermetic compiler SDK.
