# Selected execution evidence

The prospective rules are in
`implementation/phase40/design40/identity-reuse.md`. No target runs are performed
by this selector. It accepts two independently passed maintained summaries,
verifies their consumed identities and the fresh full checked06 preparation,
and indexes 42 unchanged checked05 rotations plus three fresh checked06 rotations.
Raw reports and rejected checked05 ray rows remain intact. Per-case ratios retain
their original complete same-run baseline/candidate/TypeScript measurements.

After the root's bounded fresh three-ray execution, with its directory substituted
for `FRESH_RAYS`:

```sh
python3 selfhost/tools/performance/phase40/summarize-execution.py \
  --attempt selfhost/build/phase40/checked06 \
  --baseline-api 04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f \
  --report FRESH_RAYS \
  --out selfhost/build/phase40/fresh06-ray-summary01

python3 selfhost/tools/performance/phase40/select-execution.py \
  --old-summary selfhost/build/phase40/rejected05-execution-summary01/report.json \
  --fresh-summary selfhost/build/phase40/fresh06-ray-summary01/report.json \
  --candidate selfhost/build/phase40/final-candidate02/manifest.json \
  --baseline selfhost/tools/performance/phase40/baseline/manifest.json \
  --attempt selfhost/build/phase40/checked06 \
  --catalog selfhost/tools/performance/phase37/catalog.json \
  --out selfhost/build/phase40/selected06-execution01
```

The fresh summary deliberately omits `--require-full`; the selector separately
requires exactly those three ray points and exactly 45 selected points. The old
full summary already passed with full coverage. This selection is a data report,
not a replacement for any fresh compiler, semantic, ownership, or install gate.
