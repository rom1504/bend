# Phase43 compiler-cost report renderer

Reuse the maintained Phase35 runner/report schema and the Phase42 findings fields.
This helper reads completed reports; it does not compile, execute, profile, or
change the measurement protocol. Run after both final reports are complete:

```sh
python3 selfhost/tools/performance/phase43/strings/compiler-cost-report-v1.py \
 --core selfhost/build/phase43/integration01/compiler-cost/report.json \
 --families selfhost/build/phase43/integration01/compiler-cost-families/report.json \
 --candidate-api-sha256 "$SELECTED_API_SHA256" \
 --out implementation/phase43/compiler-cost.md
```

Both Markdown and adjacent `compiler-cost.json` must be fresh. Core source IDs are
local-pair, tree-bitonic, coverage-numeric-recurrence-1024 and
coverage-list-pipeline-512. Changed families are lexer, coverage-map-churn-128,
coverage-closures-256 and coverage-bst-64. Each has three fresh-process samples for
baseline, candidate and TypeScript: 72 rows total. The helper binds the two report
configurations, exact selected candidate API, checked16 baseline API and shared
role/Node/worker identities; it rejects incomplete or incompatible matrices.

Every metric is independently recomputed from raw observations and compared with
the saved summary and sample values. Four separate tables per source group show
requestMs, importAndRequestMs, processWallMs and outputBytes, with min / median /
max for all roles and candidate/previous median ratios. No incompatible-source
millisecond average, generated-program runtime inference, emitter-only
attribution or statistical significance claim is introduced.

The JSON preserves exact raw/config/controller hashes and sample arrays. API and
other large source inventories are taken from the frozen plan's provenance; this
renderer does not replace release verification or perform a new broad hash sweep.
Static Python syntax passed before final reports were available. Root owns final
rendering and verifies the selected source/report binding.
