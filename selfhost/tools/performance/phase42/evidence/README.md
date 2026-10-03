# Root-run final accounting and ratio figure

Run after timings finish and final inputs freeze. No target program is executed.
Both tools require fresh outputs. The accounting tool only reads Git/canonical
source and recorded evidence; it writes its own report artifacts.

```bash
python3 selfhost/tools/performance/phase42/evidence/summarize.py --repo . --ledger selfhost/build/phase42/campaign.jsonl --baseline 5ec82b3 --manifest FINAL_FULL_MANIFEST --end CLOSURE_UTC_EPOCH --out selfhost/build/phase42/accounting-final01
python3 selfhost/tools/performance/phase42/evidence/plot-ratios.py FINAL_RUNTIME_REPORT --catalog selfhost/tools/performance/phase37/catalog.json --max-ratio 64 --out implementation/phase42/runtime-ratios.svg
```

Omit --end for a retrospective through the last ledger record; that is explicitly
not called campaign closure. Chronological enclosing jobs, categories, failed and
incomplete status, summed durations, union coverage, overlaps and unclassified
wall time are retained. --category-map accepts a JSON label-to-category mapping
for ambiguous jobs. Nested supervision intervals are not separately counted.
Unclassified time is never labeled idle time, model latency or agent latency.

Bend counts follow maintained Phase32/40 definitions: compiler.json module list,
physical/nonblank lines, bytes, and top-level def/law/type declarations. Baseline
5ec82b3 must match Phase41's18898lines/2108defs/70modules/71types/640laws.
Canonical runtime JavaScript counts are separate. Generated program module
bytes come from exact complete final manifests; multiple --manifest arguments
are supported and role/path/content counts remain separate.

The SVG shows every complete paired point, grouped by family without a family
average. Blue is before and orange after; the dashed1x line is pinned TypeScript.
The axis is logarithmic. Values beyond display bounds have clipping triangles
and exact numerical ratios at right; omitted incomplete points require an
explicit --allow-partial flag and are labeled. Source JSON retains ranges/drift;
the plot makes no confidence interval or general application-parity claim.

Prepared only; root owns syntax validation and final execution after timing.
