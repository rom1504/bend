# Reproduce Phase178

Run from the repository root. Use fresh paths and the ordinary outer disk/RSS
guard for every compiler or benchmark job. The exact commands and artifacts are
in [evidence.tar.gz](evidence.tar.gz), authenticated by
[evidence-index.json](evidence-index.json). Restore into a separate empty
directory; never overwrite qualified artifacts.

## Selected cleanup

The baseline is commit `296f288`. Metadata-only audits:

```sh
python3 -B selfhost/tests/phase178/parser/audit-deletion.py
python3 -B selfhost/tests/phase178/parser/audit-profiles.py
```

Assemble current source using `selfhost/tools/build/source.py`, then run the
shared `check-source.mjs` with pinned Bun, as documented in the
[workflow](../../docs/self_hosted/workflow.md). Final recorded source and check:
`cleanup-source03/compiler.bend` and `cleanup-check03/result/report.json` under
`selfhost/build/phase178`. Source inventory/protection is checked by maintained
assembly. Independent acceptance must still be run after future changes.

The unchanged Phase177 `parser/decl-reuse-controls.bend` and `.mjs` supply565
observations. The recorded extraction/acquisition recipes and full sources are
`parser-deletion-{base,candidate}-source01`, `parser-deletion-plan01`,
`parser-deletion-api01` and `parser-deletion-values01`. Both APIs were independently
checked. Their snapshot precedes the last three orphaned-helper deletions;
the final profile audit establishes unchanged executable declarations afterward.

## Neutral producer/consumer experiment

The checked Bend implementation, exports and ten replacements are in
[`layout/spec.json`](../../selfhost/tests/phase178/layout/spec.json).
Use `tests/phase178/prepare.py --parent-source SNAPSHOT` to reuse the existing
lexical source extractor. The baseline is the exact frozen baseline source;
the candidate adds the product/prelude and specified replacements. Semantic
checking and erasure remain in Bend; this host adapter only assembles text.

`erasure-api01` records independent API acquisitions; `erasure-values01` records
1,474 full-value comparisons. `front-product-source01` is the complete extracted
native frontend. Its executable was built using:

```sh
python3 -B selfhost/tools/build/native.py \
  --assets selfhost/manifests/assets-native.json \
  --image selfhost/build/phase175/full-native-n2/program \
  --image-receipt selfhost/build/phase175/full-native-n2/report.json \
  --host native --stage N2 --target qbe --mode cache \
  --source selfhost/build/phase178/front-product-source01/compiler.bend \
  --retain-ir --out FRESH_NATIVE_OUTPUT --seconds 85
```

For isolated medium timing, reuse `tests/phase175/native-frontend.py` with
`--baseline selfhost/build/phase177/front-combined-native01/report.json`,
the new candidate report, the exact `front-base-source02/base-binding.json`,
`--source selfhost/build/phase175/baseline-source03/compiler.bend`,
`--mode request --rounds 2 --seconds 25 --out FRESH_OUTPUT`.
Keep CPU3 isolated, the same producer/runtime/Base and one worker/GPU off.
The output digest is supplementary to the independent complete-value controls.

The retained native timing report is
`selfhost/build/phase178/front-product-medium01/result/report.json`. No full-image
qualification follows this neutral result. Machine binaries are excluded from
the committed compact archive; their exact identities and build recipes are
retained, and local products remain available under normal retention policy.
