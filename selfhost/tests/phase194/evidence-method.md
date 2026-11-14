# Phase194 compact evidence and campaign costs

These offline helpers adapt the Phase193 pack and campaign-cost tools. They do
not execute compiler products, change installed selections, prune artifacts,
or make qualification claims. Run final capture only after the root target lane
has finished; use a fresh destination for every snapshot.

```sh
python3 -B selfhost/tests/phase194/campaign-cost.py --plan-only
python3 -B selfhost/tests/phase194/pack-evidence.py --plan-only --out implementation/phase194/evidence01
python3 -B selfhost/tests/phase194/campaign-cost.py --out implementation/phase194/campaign-cost01.json
python3 -B selfhost/tests/phase194/pack-evidence.py --out implementation/phase194/evidence01
python3 -B selfhost/tests/phase194/pack-evidence.py --verify --out implementation/phase194/evidence01
```

The package preserves selected files verbatim, with SHA-256 and byte length for
each archive member and the archive itself. Its scope includes all attempt
directories under `selfhost/build/phase194`, retention receipts, and top-level
Phase194 implementation JSON/Markdown/log files. Failed and superseded attempts
are selected by the same rules as successful attempts. Top-level build JSON
preserves execution plans and argv; nested recognized receipts, source bindings,
exports, recipe/argv/plan files, and diagnostic stdout/stderr preserve the raw
observations behind reports. Bounded oracle stdout/stderr are copied exactly,
without normalization. Both helper identities and their Phase193 predecessors
are pinned in resulting reports.

Member limits are 128 KiB per diagnostic stream and 8 MiB per JSON/report, with
a 128 MiB total raw selection limit. Oversized selected files are explicitly
listed as exclusions. ELF content transported as stdout is excluded. Generated
source, source maps, preselection/IR dumps, assembly, objects, executables,
profiles and retention recovery archives remain at their original pinned paths.
Thus the compact package preserves observations and provenance, but is not a
complete rebuild capsule or an independent backup. Inspect `excludedLarge` in
the plan before closing the campaign; important omitted output needs a separate
reviewed bounded capture, not an unrecorded truncation.

Packing refuses unfinished outer guards, an existing output directory,
symlinked selected files, changing selected contents or a changed selection.
It preserves the 5 GiB free-space reserve plus worst-case archive scratch.
Verification checks every member, archive SHA-256 and gzip integrity without
extracting files. This is evidence capture, not the archive/prune lifecycle in
`selfhost/tools/build-retention/close.py`; root retains responsibility for that
separate campaign classification.

Campaign cost sums each top-level `*-guard/process.json` exactly once. A terminal
nonzero exit counts as a failed job even when its receipt says `complete=false`.
Nested target process records are excluded to avoid double counting. The report
retains each guard identity, failure status, wall time and resource observations;
category totals are descriptive. Peak RSS/storage and minimum free disk are
extrema, not sums. The total excludes unguarded work, agent compute and billed
quota. Do not interpret it as compiler request throughput, generated-program
runtime, or total human/research time.
