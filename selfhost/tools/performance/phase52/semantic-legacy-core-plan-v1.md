# Selected06 legacy backend rejection screen

Pending root's release of the final full45 timing slot. This is a fresh legacy
backend acquisition and bounded eight-point screen, separate from direct06's
29-fixture/96-scenario semantic gate and the full45 direct timing evidence.
No target has run from this plan. The unchanged programs/prepare.py producer
is deliberately independent of Phase52 direct acquisition tooling. Do not nest another execution guard around
these tools: each owns its process-tree guard.

The unchanged Phase37 `core` selection is exactly local-pair, local-fold,
scalar-region-0, scalar-region-8192, complete-generic-row32, mandelbrot, editdist,
and test-rle-roundtrip. The baseline bundle retains the preserved RNFA04 comparison baseline and
pinned TypeScript modules; it is not a fresh Phase51 emission. The runner selects only these eight and measures
fresh samples. It never uses historical timings as a denominator.

From the repository root, after target-slot authorization:

```bash
python3 selfhost/tools/performance/programs/prepare.py \
  --attempt selfhost/build/phase52/checked-direct06 \
  --role candidate --set core \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --heap-mib 1024 --rss-mib 2048 --available-mib 4096 --timeout 180 \
  --out selfhost/build/phase52/prepared-legacy06-core

python3 selfhost/tools/performance/programs/run.py \
  --baseline selfhost/tools/performance/phase51/bundles/baseline/manifest.json \
  --candidate selfhost/build/phase52/prepared-legacy06-core/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --set core --budget 20 \
  --node /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --cpu 3 --rss-mib 2048 --available-mib 4096 \
  --out selfhost/build/phase52/screen-legacy06-core
```

Acquire first and require its complete checked receipt before the screen.
The second command uses the unchanged timing worker, exact per-invocation
oracles, three balanced rounds, and the 20-second total execution ceiling.
If it runs out of budget or fails, preserve the entire partial report and all
logs; no silent denominator change or budget extension. This is rejection
screen evidence, not full legacy conformance, installation, or promotion.

After complete legacy acquisition, compare each of its eight case modules to
Phase51 current by exact byte hashes. This is data-only evidence, no module
execution or normalization; unequal bytes stay unequal and do not skip the
unchanged screen above.

```bash
python3 selfhost/tools/performance/phase52/semantic-legacy-byte-compare-v1.py \
  --candidate selfhost/build/phase52/prepared-legacy06-core/manifest.json \
  --previous selfhost/tools/performance/phase51/bundles/current/manifest.json \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase52/legacy06-core-byte-comparison.json
```
