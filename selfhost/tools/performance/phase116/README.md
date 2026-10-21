# Phase116 matched backend and hotspot survey

[Design](../../../../design/phase116/profile-and-backend-comparison.md) ·
[Report](../../../../implementation/phase116/README.md).

This is diagnostic tooling, with no compiler algorithm or runtime change.
The authoritative files are under `selfhost/build/phase116/`:

- `manifest01.json`: exact sources/oracles, C and QBE products, checked producer
  receipts, pinned upstream/Base, installed JS API and runtime engine.
- `js01/`: freshly checked upstream/selfhost JavaScript and acquisition record.
- `clean01/`: 120 matched observations, original clean method `survey.py`.
- `native01/`: 48 unchanged-ELF captures and decoded leaves, `survey-v2.py`.
- `js-profile01/`: 16 V8 CPU profiles, kept separate from clean timings.
- `compiler01/`: six exact qualified N1 lexer requests, four sampled.
- `independent-output-check01.json`: unchanged Phase112 output gate replay.

`survey-v2.py` differs only by accepting QBE's unsized text symbols and explicitly
using the next text-symbol start as the inferred end. Its shared timing/protocol
code is unchanged from `survey.py`. The older script was not used for native
symbol attribution. Every capture records samples, overruns, drops and process
CPU coverage. Native leaf categories and V8 ticks are different measurements.

Original serial guard, CPU3, 2GiB RSS/16GiB available memory and 64MiB file limit:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/phase116/NEW-clean-guard --seconds 240 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase116/survey-v2.py clean \
    --out selfhost/build/phase116/NEW-clean \
    --names variation-local-fold-128-0 editdist
```

Use `native` for unchanged-binary profiles, or `js` for Node CPU profiles. Those
modes use retained `clean01` medians only to choose enough iterations for sampling;
profiled time is never reported as clean speed. A fresh output path is mandatory.
Counts change explicitly; sources/arguments/oracles do not. The frozen selected
set is historical diagnostic coverage, not blind evaluation or the whole 45.

`acquire-js.mjs` is the exact initial acquisition method; its output destination
is intentionally fresh/fixed. A new acquisition requires a new destination and
manifest, never replacing products behind old identities. `freeze.py` documents
where all five roles come from. `compiler-profile.py` replays an existing ordinary
request and requires byte-identical whole QBE against its independent receipt.

`verify.py` reuses the unmodified Phase112 complete-output/count/interval function.
`summarize.py` reads receipts and regenerates `implementation/phase116/results.json`;
`numeric-audit.py` captures disassembly of actual numeric hotspot symbols without
executing targets. `plot.py` produces static SVGs from results. No frozen benchmark
or compiler source is changed by these operations.

For a future optimization loop, start with two native cases and original 50ms
counts, reuse authenticated checked input artifacts where the transformation
boundary allows it, and include frontend/acquisition cost separately. Reprofile
only when the executed graph changes enough to invalidate attribution. Reserve
full 45 and self-reproduction for a useful candidate with demonstrated transfer.

The evidence archive contains bounded receipts, raw profiles, generated diagnostic
JS and outputs. Its inventory hashes every archived byte. Large native images,
original compiler APIs and external build assets remain pinned local dependencies;
the capsule alone cannot recreate them. Preserve the original build receipts.
