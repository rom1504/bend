# Fixed-name classification experiment

`candidate.patch` is an isolated, unapplied Bend source patch. `proposal.json`
binds the inspected before/after source. Integration belongs to root; narrow
hunks compose with the independent child-type change in `validate.bend`.

`attribution.py` reads existing State09 heap profiles; it runs no target.
`attribution.json` is its recorded output. `corpus.json` contains deterministic
name-boundary cases; `static-controls.json` covers only the membership formula.

After root applies the patch and obtains a checked strict-exact B1, run the
following through the standard serial CPU3 resource supervisor, with a fresh
output path:

```sh
node --max-old-space-size=1024 selfhost/tools/performance/phase64/name-classification/compare.mjs CHECKED_ATTEMPT selfhost/build/phase64/name-classification-control01
```

Optional trailing case IDs are `numeric-recurrence` and `test-map-set-ops`.
The diagnostic executes actual compiled helper comparisons for all 2,235 names,
per-call checks during checked source compilation, and complete-module equality
with the original membership implementation restored. It does not measure speed.
Each real source also reports full-predicate calls and rejected-tag counts, so
root can reject the separate lazy-guard idea before building it when the dynamic
opportunity is absent.

`guard-only.patch` and `guard-after-classifier.patch` are mutually exclusive
ways to test the optional outer-tag guard. They are separate from membership-only
`candidate.patch`; do not combine both guard variants. Their behavior domain and
additional required controls are recorded in `guard-proposal.json` and the report.

Read the [report](../../../../../implementation/phase64/name-classification.md)
for the behavior-preservation argument, allocation scope and falsifiers.
