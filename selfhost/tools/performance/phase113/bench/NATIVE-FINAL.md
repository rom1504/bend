# Final array-pipeline native qualification

This additive plan replaces no frozen method. Prepare it only after the final
composed source and its checked API are selected. It requires the actual array
native entry hook and an exported `p113a_admitted_chunks`; the hosted transport
verifies the same lowered program once before calling that renderer. Compiler
passes may perform their own checks. No host code transforms compiler programs.

From the repository root, set the selected paths and a fresh descriptive tag:

```sh
python3 -B selfhost/tools/performance/phase113/bench/prepare-native-plan.py prepare \
  --source selfhost/build/phase113/SELECTED_SOURCE/compiler.bend \
  --api selfhost/build/phase111/SELECTED_API/api.mjs \
  --tag p113-finalNN --out selfhost/build/phase113/native-finalNN-plan.json
```

The generator runs no targets. It authenticates the exact API/source/composition,
all module snapshots, product runtime build, immutable methods, and frozen
coverage manifests. Default runtime is `runtime-products-build01/runtime.o`;
`--runtime` accepts an explicit object with its matching build receipt. The
plan's `rootGuardCommand` is the exact executable argument vector for root's
serial CPU3 lane. To execute that vector, after reviewing the generated plan:

```sh
python3 -B - <<'PY'
import json, subprocess
with open('selfhost/build/phase113/native-finalNN-plan.json') as f:
    plan = json.load(f)
raise SystemExit(subprocess.run(plan['rootGuardCommand']).returncode)
PY
```

The guard has 4 GiB process-tree RSS, 16 GiB available-memory floor and 128 MiB
file limit. The existing guard also requires more than 416 MiB free disk before
starting. Eight serial jobs stop at the first failure:

1. Authenticate every frozen plan input.
2. Staged-v2 array full compiler emission, at most 600 seconds.
3. N1 QBE build, at most 150 seconds (120-second builder commands).
4. Unchanged focused19 through N1, at most 180 seconds.
5. Actual N1 native self-emission and N2 build, at most 1050 seconds
   (650-second native request, 120-second builder commands).
6. Authenticate actual source/assets/runtime/product lineage and compare raw
   hosted/native full-source QBE bytes, at most 30 seconds.
7. Unchanged focused19 through N2, at most 180 seconds.
8. Original one-shot full45 through N2, at most 300 seconds.

The 2565-second outer ceiling includes slack; it is not a runtime prediction.
The earlier Phase112 facts chain took about twelve minutes for these stages.
Per-fixture focused limits are 30 seconds for native emission and builder
commands; full45 keeps the original 120/10-second limits. Original focused19
means 16 positive executions plus two source and one backend refusal, not 19
compiled programs. Full45 is conformance, separate from the runtime benchmark.

The native command remains `IMAGE --threads 1 --gpu off -- phase111 SOURCE BASE
cache CARRIER STAMP`. Its stdout is untouched. The `phase111` token is the
program-name placeholder. A successful comparison proves hosted/N1 output
reproduction and the actual N1-to-N2 build chain; N2-to-N3 output reproduction
is a separate optional request. Failed attempts retain their original receipts.

Collect small evidence after execution, optionally including selected benchmark
or admission reports and their small JSON trees:

```sh
python3 -B selfhost/tools/performance/phase113/bench/collect-native-evidence.py \
  --plan selfhost/build/phase113/native-finalNN-plan.json \
  --extra-json selfhost/build/phase113/SELECTED_ADMISSION/manifest.json \
  --out selfhost/build/phase113/native-finalNN-evidence
```

The collector archives exact JSON bytes only (2 MiB per file, 32 MiB total by
default). Every product, source, API, tool and output remains an external hash
reference. Its manifest distinguishes receipt completeness, qualification gates
and missing/changed historical dependencies; it can preserve an incomplete or
failed run without labeling it qualified. `--extra-tree` adds an explicitly
selected receipt directory. It is an evidence index, not a self-contained replay
archive or a replacement for source/runtime/module preservation.
