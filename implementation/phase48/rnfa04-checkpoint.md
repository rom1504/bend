# RNFA04 literal-array checkpoint

RNFA04 substantially reduces the earlier zero/one-iteration penalty, but **does
not eliminate it**: zero iterations remain **30.63% slower** than the fresh
array06 baseline, and one iteration remains **18.64% slower**. At 128 and 8,192
iterations, the measured gains remain **16.372×** and **71.831×**. This is a
supplementary four-point screen, separate from the primary 45-point corpus and
its still-pending final runtime qualification.

## Fresh scaling measurement

`literal-scale-screen-rnfa04/report.json` passes all **36 samples** in **29.336 s**.
The three compiler roles run three rotated fresh rounds, with three warmup calls,
350 ms warmup, 40 ms calibration and a 150 ms measurement target. Each point calls
the independent fixture `loop_bench(n,3)` and retains its full scalar oracle.

| Iterations | Array06 µs | RNFA04 µs | TypeScript µs | Array06 / RNFA04 | RNFA04 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| 0 | 1.346691 | 1.759165 | 0.249081 | 0.766× | 7.063× |
| 1 | 4.993282 | 5.923964 | 0.275103 | 0.843× | 21.534× |
| 128 | 296.506466 | 18.110820 | 1.944981 | 16.372× | 9.312× |
| 8192 | 19382.153500 | 269.829415 | 116.544293 | 71.831× | 2.315× |

The remaining zero/one-trip overhead is approximately **0.412 / 0.931 µs** per
call. The preserved [RNFA03 screen](rnfa03-checkpoint.md) measured 10.393× and
2.731× baseline time at those sizes; RNFA04 measures 1.306× and 1.186×. These are
separate fresh-baseline episodes, not a direct RNFA03/RNFA04 timing comparison.
No historical samples are pooled or relabeled.

Maximum absolute candidate half-window drift is **11.859%, 11.436%, 13.858% and
6.321%** at the four sizes. Across the screen the baseline maximum is 12.418%
and TypeScript's is 12.176%. Three warmed rounds with these drifts do not prove
stationarity or statistical significance. The tiny-input regressions remain an
explicit tradeoff; neither the count gate nor this screen establishes universal
profitability.

## Independent count-mapping controls

`array-counts-controls04/report.json` passes **43 value oracles**, **13 host/error
boundary observations** and **56 separate activation/refusal observations**.
The renamed fixture covers direct U32 and Nat countdown arguments, a count in a
different argument slot, computed counts and constant counts. It also compares
ordinary object-count coercion order, exact thrown sentinel identity and source
helper replacement against untouched baseline/candidate modules.

The counter-only derivative establishes that directly mapped zero/one counts
decline the new literal path, while mapped counts 2, 37 and 128 enter it. Computed
and constant cases retain the unknown-count policy. All 13 hostile boundary
observations refuse entry. This is finite evidence about the general argument
mapping and fallback behavior, not a benchmark-name selector or a proof for every
possible call. Instrumented modules supply no timing result.

## Source/output identity and evidence

The candidate API is
`6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100`; array06 remains
`28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`. Both use runtime
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` and pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`.

[Static accounting](accounting.md) verifies that all 45 primary-corpus outputs
are byte-identical between RNFA03 and RNFA04. Only `array-literals.bend` changes
in the manifest-listed compiler source: +90 physical lines, +73 code lines and
nine definitions. The supplementary fixture is outside that 45-point source set,
so its changed path is compatible with unchanged primary outputs. RNFA04 still
requires its own complete runtime and semantic qualification before selection.

[Checked evidence](evidence/literal-rnfa04-checkpoint.json) independently
recomputes all 12 medians, retains all round samples and drift arrays, verifies
all 36 raw sample/process pairs and their globally nonoverlapping intervals,
and rehashes 153 consumed inputs. Its SHA-256 is
`e6c875e594040a852e1d9e6d55d9bdef03eb32e45fcada1a5874871712303986`.
Raw report hashes are:

- Scaling: `af2df2f6ad3c8a3fcdaebf4f35cba78dc147af7450bd18b186a51120901f8af2`.
- Count controls: `4501411cb7066ccda3d374f1d3b170be4107f6b2dbcc90cc53990a6fc5bca163`.

The first data-only derivation assumed that case grouping in the report was
chronological; the runner interleaves cases. That checker stopped before writing
the literal receipt. The preserved successor checks globally sorted intervals
and passes. This was a reporting-checker correction, not a failed target or a
change to the completed benchmark. No raw report was modified.
