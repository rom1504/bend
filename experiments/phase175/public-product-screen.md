# Phase175: bounded JS/C emitted-product screen

Result: both selected six-case screens passed with complete byte identity.
JS emission took 62.861s; C emission took 68.351s. These are gate costs, not
comparative compiler timings. Source selection was fixed before execution. `selfhost/tests/phase175/reemit-public.py` remains a thin caller
of maintained `request.plan` / `request.execute`, with explicit checked B1/live
API selection. It does not build or execute the generated programs.

Given the separate Phase175 exact-QBE and full frontend-value gates, start with
six representative JS products and the same six C products: **12 emissions**,
not 90. This tests whether the frontend change preserves emitted public-backend
products for distinct computation families. It does not replace the complete
45-case suite or constitute fresh conformance/performance qualification.

| Exact frozen ID | Main reason to include it |
|---|---|
| `broad/editdist` | Numeric loops and array state |
| `broad/tree-bitonic` | Recursive trees and ownership |
| `broad/lexer` | Text processing and constructor control flow |
| `broad/test-rle-roundtrip` | Lists and producer/consumer composition |
| `broad/coverage-map-churn-128` | Persistent Map updates and reconstruction |
| `broad/coverage-closures-256` | Closures and captured values |

These IDs occur in both completed Phase174 `js45` and `c45` reports, with
matching source identities and independent expected execution outputs. Selection
retains the frozen report's order. Duplicate, empty or unknown IDs are refused;
there is no pattern matching, implicit skipping or substitution.

Use the following argument sets inside the root's normal outer execution guard:

```sh
python3 -B selfhost/tests/phase175/reemit-public.py \
  --target js --out selfhost/build/phase175/js6-reemit01 \
  --case broad/editdist \
  --case broad/tree-bitonic \
  --case broad/lexer \
  --case broad/test-rle-roundtrip \
  --case broad/coverage-map-churn-128 \
  --case broad/coverage-closures-256

python3 -B selfhost/tests/phase175/reemit-public.py \
  --target c --out selfhost/build/phase175/c6-reemit01 \
  --case broad/editdist \
  --case broad/tree-bitonic \
  --case broad/lexer \
  --case broad/test-rle-roundtrip \
  --case broad/coverage-map-churn-128 \
  --case broad/coverage-closures-256
```

`--plan` authenticates these inputs and prints jobs without compiler execution.
The checked API must first exist at the explicit default Phase175 `public-api01`
paths, or be supplied through `--api` and `--api-receipt`.

Both emitted plan and execution receipt record `selected`, all 45 `available`
IDs, `availableCount: 45`, `expectedCount: 6`, `fullSuite: false`, and a partial
`completionScope`. `complete: true` means all selected comparisons succeeded;
it never means the remaining 39 products were tested. With no `--case`, the
original default remains all 45 and `fullSuite: true`.

Stop at the first byte mismatch and inspect it before expanding coverage. If
these screens pass, preserve their restricted scope alongside the separate
QBE/frontend gates. Re-run the full default when a backend-affecting change or
unresolved mismatch justifies the additional work. Historical JS45 qualification
was approximately 411 seconds; a six-case emission screen removes most requests
but no proportional time saving is promised. Historical C45 used native/cache,
so its duration is not an estimate for this checked B1/live screen. Neither
screen measures compiled-program speed.

Actual receipts: `selfhost/build/phase175/js6-reemit01/report.json` and
`selfhost/build/phase175/c6-reemit01/report.json`; the checked complete-source
API is `selfhost/build/phase175/public-api01/report.json`. All six expected
products per target match; the remaining 39 per target were not rerun.
