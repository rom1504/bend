# Root-only paired fixture acquisition

Run from `/home/ai/bend2/build/publish/bend`. These commands perform nine checked
emissions across three exact copied semantic sources and three compiler roles.
Keep root supervision and fresh output directories. All source paths stay inside
the catalog folder; copied SHA/bytes and original source identities are frozen.
The original pinned checkout currently matches018751270e800bc222a93dad7f257083ee53a5f7.

```bash
python3 selfhost/tools/performance/programs/prepare.py --catalog selfhost/tools/performance/phase42/fusion/fixture-catalog-v2/catalog.json --set full --attempt selfhost/build/phase42/checked02 --role candidate --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 --heap-mib 1024 --rss-mib 1600 --available-mib 2048 --timeout 120 --out selfhost/build/phase42/fixtures-candidate02
python3 selfhost/tools/performance/programs/prepare.py --catalog selfhost/tools/performance/phase42/fusion/fixture-catalog-v2/catalog.json --set full --attempt selfhost/build/phase41/checked01 --role baseline --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 --heap-mib 1024 --rss-mib 1600 --available-mib 2048 --timeout 120 --out selfhost/build/phase42/fixtures-baseline41
python3 selfhost/tools/performance/programs/prepare.py --catalog selfhost/tools/performance/phase42/fusion/fixture-catalog-v2/catalog.json --set full --upstream selfhost/.bootstrap/upstream-phase23 --role typescript --node /home/ai/.nvm/versions/node/v24.18.0/bin/node --cpu 3 --heap-mib 1024 --rss-mib 1600 --available-mib 2048 --timeout 120 --out selfhost/build/phase42/fixtures-typescript
```

For a corrected candidate use a fresh output name and that checked attempt.
After actual markers are established, independent fusion comparison is:

```bash
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node --max-old-space-size=1024 selfhost/tools/performance/phase42/fusion/fixture-controls-v4.mjs selfhost/build/phase42/fixtures-typescript/modules/fusion-fixture-v4.mjs selfhost/build/phase42/fixtures-baseline41/modules/fusion-fixture-v4.mjs selfhost/build/phase42/fixtures-candidate02/modules/fusion-fixture-v4.mjs selfhost/build/phase42/fusion-fixture-controls02
```

V4 expects compiler-selected fusion on pipeline, ordered_pipeline and
modzero_pipeline; each retains its complete existing guard/proof/finally owner.
No fusion may appear on retained, alias_single, shared or refused_division.
