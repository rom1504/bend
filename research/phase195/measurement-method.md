# Phase195 runtime measurement and summaries

`selfhost/tests/phase195/summarize.py` adapts the Phase194 summary wrapper to the frozen Phase195 ten-development / 35-heldout partition and the Phase195 reference manifest. It imports the same Phase193 family/excess diagnostics and strict Phase192/186 receipt analysis. It executes no benchmark, compiler, archive or cleanup command. Existing references, manifests and historical methods remain unchanged.

The baseline is the qualified Phase194 N2 executable set frozen by `selfhost/tests/phase195/references.py`, alongside retained C and QBE products. A supplied runtime report must pin that exact reference manifest. C, baseline and QBE executable identities are checked against it for every observed case. A role label alone does not establish compiler generation, native qualification or promotion.

## Usage

For the existing six-case screen, choose fresh JSON and adjacent Markdown output paths:

```sh
python3 -B selfhost/tests/phase195/summarize.py \
  --report selfhost/build/phase195/screen-runtime01/report.json \
  --references selfhost/build/phase195/references01/manifest.json \
  --out implementation/phase195/screen-summary01.json
```

Use the same command with the completed full45 runtime receipt and a fresh output name for the final comparison. Screens need not contain all ten development cases: observed coverage and missing case IDs are reported separately for all 45, development 10 and heldout 35. Unobserved heldout cases never become inferred results. A merged receipt must satisfy the same authenticated runtime schema and input/oracle checks.

Defaults are `--c-role c --baseline-role baseline --qbe-role qbe --spread-limit 1.10`. The three reference role names must differ; candidate roles are taken from the runtime receipt. Optional repeated `--emission LABEL RECEIPT` arguments attach separately authenticated hosted API preparation/selection/render/object costs. These single-acquisition observations do not measure native compiler throughput or generated-program runtime. Labels must be unique.

## Admission and interpretation

The inherited analyzer requires a complete unchanged adaptive native-runtime receipt without a reached deadline. It verifies every input pin, frozen catalog identity, case point/family/source group, executable identity, admitted sample summary and aggregate. Every retained pilot and sample stdout/stderr is reopened and independently checked against its oracle, exit status and timing observation. Recorded elapsed time and per-repetition metric must agree with those authenticated bytes.

Ratio-eligible samples must meet the report's minimum accepted duration, which must be at least 100 ms. Catalog warmups remain exact. The frozen partition must cover the 45 catalog IDs exactly once and match the catalog hash. Reports, references and partition are checked again for changes during analysis.

All comparisons use ratios of per-role medians measured in the supplied report. Let `m_i(r)` be a role's median milliseconds per repetition, `q_i = m_i(candidate) / m_i(reference)`, and `n_i` the original catalog repetition count. For each observed eligible subset and each role, comparisons against C and the frozen baseline include:

- Case-weighted geometric mean of `q_i` and mean positive log slowdown `mean(max(0, log(q_i)))`.
- Counts above 1.1× and 2×, per-case ratios, and worst regressions.
- Fixed-catalog time `sum(m_i(r) * n_i)` and its reference ratio.
- Equal-family geometric mean: compute the geometric mean within each observed eligible family, then give those family means equal weight.
- Positive fixed-catalog excess milliseconds `sum(max(0, m_i(candidate) - m_i(reference)) * n_i)`.

Adaptive calibration repetition counts do not weight these aggregates. Zero-work/correctness-only cases are excluded from ratio aggregates. A subset with no eligible cases has no fabricated aggregate. Dispersion uses sample maximum/minimum and defaults to a 1.10 threshold; flagged cases remain included and are reported for review. Unbalanced role positions also produce a warning. Neither warning is a significance test, an automatic exclusion or a promotion decision.

## Metadata-only verification

The adaptation passed syntax compilation and CLI help. An offline self-check authenticated the existing Phase195 six-case screen: 85 pilot observations, 150 timed observations and 288 input pins; all 35 heldout cases remained explicitly unmeasured. Supplying the old Phase194 reference manifest was refused because its baseline executable differed (`baseline/local-pair`).

A separate in-memory numerical check covered geometric mean, mean positive log slowdown, equal-family weighting, fixed-catalog sums, positive excess, family/case counts and exclusion of a zero-work row. No target process or archive job ran. The transient self-check receipt is `/tmp/phase195-summary-selfcheck-4pun2x4s/result.json`; the runtime and frozen-reference receipts remain the authoritative measurement evidence.
