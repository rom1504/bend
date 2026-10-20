# Direct hosted acquisition for the unchanged broad45

`hosted45.py` prepares commands and authenticates receipts without importing an
API or launching a compiler, builder or product. It uses the original
`phase112/benchmark45/manifest01.json`, `run.py` and
`upstream-50ms-profile01.json`, verified against their original freeze. All45
source wrappers, workload arguments, full outputs, repetition counts and four
warmups remain unchanged. The named `scalar-region-0` point receives output
checks but has no runtime ratio; the aggregate still covers 44 fixed points.
The old Phase112 held-out fields retain their historical meaning. This is not
a fresh Phase113 held-out set.

Prepare after the checked direct API exists:

```sh
python3 -B selfhost/tools/performance/phase113/bench/hosted45.py prepare \
  --api CHECKED_DIRECT_API_DIRECTORY --runtime RUNTIME_OBJECT \
  --tag p113-direct-broad01 \
  --out selfhost/tools/performance/phase113/bench/direct-broad-plan01.json
```

Omit `--runtime` to use the exact frozen facts runtime. An optional
`--reuse-reports COMPLETED_SIX_MAP.json` reuses completed products only after
checking their exact source, API, direct transport, runtime and build receipts.
It cannot reuse the old facts products as direct candidate products. Reused
products need no new emission or build; the output map still contains all45.

Root executes the commands serially inside its process-tree guard:

```sh
python3 -B selfhost/tools/performance/phase112/run-jobs.py \
  --plan selfhost/tools/performance/phase113/bench/direct-broad-plan01.json \
  --out selfhost/build/phase112/p113-direct-broad-jobs01
```

Every emission calls the exact Phase113 staged transport with
`API SOURCE OUT cache direct`, then the unchanged Phase111 QBE builder. The
plan contains 90 commands, or 78 when the six matching products are reused.
Each command has a 45-second ceiling; the outer root guard bounds the whole
batch. Acquisition and runtime measurement are separate. A 480-second initial
acquisition guard is a planning budget, not a measured guarantee.

Authenticate the actual products and create a normal broad45 binding:

```sh
python3 -B selfhost/tools/performance/phase113/bench/hosted45.py audit \
  --plan selfhost/tools/performance/phase113/bench/direct-broad-plan01.json \
  --label direct01 \
  --out selfhost/build/phase112/p113-direct-broad-producer01.json
```

This writes `p113-direct-broad-producer01-binding.json` only after all45
emissions pass the direct-path audit and the unchanged binder. Measure it
with the existing method, under the root guard:

```sh
python3 -B selfhost/tools/performance/phase112/benchmark45/run.py measure \
  --bindings selfhost/build/phase112/p113-direct-broad-producer01-binding.json \
  --profile selfhost/tools/performance/phase112/benchmark45/upstream-50ms-profile01.json \
  --out selfhost/build/phase112/p113-direct-broad-runtime01 \
  --budget-seconds 300
```

This measures candidate/upstream in three rotated rounds. For a current
facts-N2/candidate/upstream comparison, also pass
`selfhost/build/phase112/facts-broad-binding01.json` and use a larger explicit
guard. The old facts run spent 200.413 seconds inside facts products and
6.728 seconds inside upstream across three rounds; its total wall time was
255.455 seconds. A repeated facts role therefore adds substantial time even
when the candidate improves. Use 600 seconds as a provisional three-role
budget, with the same unchanged counts. Historical timing estimates do not
change qualification or justify multiplying ratios across campaigns.

The legacy binder accepts staged receipts structurally when the checked API
also exports `p111_compile_source`. That compatibility export is never called
by the direct plan. The binder authenticates source/Base/carrier, QBE and
binary pins, exact toolchain/flags and producer source/API, but it does not
enforce `pipeline=direct`, runtime admission, IR verification or one candidate
API/runtime across all products. The producer audit supplies those checks:
all seven direct exports, all expected completed stages, the planned emitter,
and identical API/runtime pins. The receipt does not establish native compiler
qualification or prove that every source function used the new direct path;
fallback usage and direct-function counts require separate compiler evidence.

Preparation was source-only. The compatibility conclusion is based on the
receipt schema and binder source; completed direct products still require the
real audit and full-output execution gates.
