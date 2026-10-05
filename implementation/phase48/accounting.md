# Phase48 static source and output accounting

The frozen RNFA04 candidate adds **406 physical Bend lines (+1.75%)**, **314
nonblank/non-comment lines (+1.64%)** and **51 definitions** against array06.
Its generated libraries change on 16 of 45 points, representing seven of 23
source programs. The runtime image is byte-identical. These are static counts;
generated-program performance, semantic qualification and installation are
separately completed in the [final phase report](README.md). RNFA04 is installed;
these static counts alone do not establish that qualification.

The preserved [RNFA03 checkpoint](rnfa03-checkpoint.md) records the eight-point primary
screen and supplementary literal-array scaling results. It shows the generic-row
gain and zero/one-trip regressions without treating RNFA03 as the final selected
candidate. Those screens do not change this source-count denominator. All 45
RNFA04 corpus modules are byte-identical to RNFA03, as detailed below; RNFA03
receipts remain preserved rather than relabeled as RNFA04 results.

The fresh [RNFA04 literal checkpoint](rnfa04-checkpoint.md) reduces the earlier
zero/one-trip penalty but still measures 30.63% / 18.64% overhead at those sizes.
The [compiler-request report](compiler-cost-final.md) independently records
3.27% / 4.41% median request-time regressions on Evening/lexer. Neither focused
screen supplies the independently completed [primary-corpus aggregate](results.md).

## Scope and method

The data-only [measure-size.py](../../selfhost/tools/performance/phase48/measure-size.py)
reuses hash-pinned Phase47 snapshot/count functions and the maintained bundle
reader. It counts only modules listed by each frozen `src/compiler.json`.
Physical lines use `splitlines`; code lines exclude blank lines and lines whose
first nonspace character is `#`. Definitions, laws and types count their source
declaration lines. They do not measure semantic concepts or prove lower complexity.

The invocation compared `checked-array06` with `checked-combined-rnfa04`, the
retained Phase48 baseline bundle and `combined-rnfa04-full/manifest.json`. It ran
on CPU 0, imported no compiler or generated program, performed no extraction or
compression, and rehashed all 224 recorded inputs. Historical files remained
read-only. Independent static review passed before this measurement.

| Method/artifact | SHA-256 |
| --- | --- |
| Phase48 counting tool | `43fe3e0b568a118bd47ad6d82688aa62b7bc4305bb56b7bdab589955b3726432` |
| Reused Phase47 counting helper | `8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681` |
| [Complete RNFA04 count receipt](evidence/accounting-rnfa04.json) | `b48a575ebae7333c0bb6e1e9a76c1958dd75100ef3428d34546a37a31abd23c6` |
| RNFA04 checked API | `6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100` |
| Shared runtime | `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b` |

## Maintained compiler source

| Metric | Array06 | RNFA04 | Change |
| --- | ---: | ---: | ---: |
| Physical Bend lines | 23,254 | 23,660 | +406 |
| Nonblank/non-comment lines | 19,175 | 19,489 | +314 |
| Definitions | 2,622 | 2,673 | +51 |
| Laws | 629 | 629 | 0 |
| Type declarations | 87 | 87 | 0 |
| Manifest-listed Bend modules | 86 | 92 | +6 |
| Source bytes | 1,024,879 | 1,047,729 | +22,850 |

The baseline totals are explicit assertions in the tool. The six new modules
contain 443 physical lines; edits to existing files remove 37 net lines, yielding
the 406-line increase. No unchanged type-declaration count is interpreted as
zero conceptual growth: literal planning, typed native operations and array
ownership/result boundaries add behavior and obligations even without new ADTs.

| Changed module | Physical-line change | Definition change |
| --- | ---: | ---: |
| `array-effect-guards.bend` | +11 | +2 |
| `array-effects.bend` | +135 | +18 |
| `array-literals.bend` | +183 | +20 |
| `array-result.bend` | +62 | +6 |
| `array-view.bend` | +15 | +3 |
| `emit.bend` | −7 | 0 |
| `fold.bend` | 0 | 0 |
| `ir/native-values.bend` | +17 | +2 |
| `ir/worker-emit.bend` | 0 | 0 |
| `local.bend` | −45 | −5 |
| `private-float.bend` | +35 | +5 |
| `region.bend` | 0 | 0 |
| `tree.bend` | 0 | 0 |

All paths above are relative to `selfhost/src/back/js/`. Zero line changes can
still contain meaningful edits; the receipt records exact file hashes and byte
deltas. Unselected experimental modules absent from RNFA04's manifest are not
counted as part of this compiler, though their experiment evidence remains.

## Images and generated output

| Image | Array06 bytes | RNFA04 bytes | Change |
| --- | ---: | ---: | ---: |
| Derived API | 1,598,192 | 1,628,716 | +30,524 (+1.91%) |
| Checked API | 1,578,559 | 1,608,557 | +29,998 |
| Assembled runtime | 57,196 | 57,196 | 0, byte-identical |
| Runtime core source | 22,619 | 22,619 | 0, byte-identical |

These image sizes are separate views, not additions to the maintained source
total. The output comparison verifies each catalog point and compiler tuple;
runtime prefixes are included in library sizes.

Across the full acquisition, **29 point modules are unchanged and 16 change**.
Those changes cover seven source programs; 16 of 23 source programs remain
unchanged. Both bundles have **24 distinct `(source hash, output hash)` pairs**,
because a source can have an additional observation adapter. The sum of those
24 output sizes grows from **4,156,968 to 4,186,885 bytes**, +29,917 (+0.72%).
The geometric byte ratio is **1.004001× by point** and **1.003903× by source**.
These are code-size statistics, not execution ratios.

| Output/source group | Points changed | Baseline bytes | Candidate bytes | Per-output change |
| --- | ---: | ---: | ---: | ---: |
| Edit distance, three sizes | 3 | 166,580 | 166,624 | +44 |
| Local pair | 1 | 167,491 | 182,250 | +14,759 (+8.81%) |
| Generic row observation adapter | 1 | 167,644 | 182,403 | +14,759 (+8.80%) |
| Local fold, three sizes | 3 | 91,521 | 91,543 | +22 |
| Unicode, two sizes | 2 | 155,511 | 155,455 | −56 |
| Map churn, two sizes | 2 | 247,548 | 247,540 | −8 |
| Numeric recurrence, two sizes | 2 | 83,393 | 83,830 | +437 |
| Record aggregation, two sizes | 2 | 240,898 | 240,858 | −40 |

Local pair and generic row share a source and therefore count once among the
seven changed source programs, but their distinct emitted outputs both belong
in the byte inventory. Their growth dominates the output-size increase and
must be weighed against the separately measured execution benefit. Static
output changes alone establish neither executed activation nor a speedup.

## RNFA03 to RNFA04

The fresh [comparison receipt](evidence/rnfa03-to-rnfa04.json) compares all 45
module byte strings after verifying both manifests, exact source/point bindings,
compiler tuples and recorded hashes. **All 45 point outputs, across 23 sources,
are byte-identical.** The runtime, Base and driver identities are also unchanged.
This explains why the generated-size table is unchanged from RNFA03; it does
not relabel earlier timing or qualify a different compiler API.

The only changed manifest-listed source file is `array-literals.bend`: +4,808
bytes, +90 physical lines, +73 code lines and +9 definitions. That is RNFA04's
general literal-path profitability change. Its supplementary zero/one-trip
fixture is outside the primary 45-point source set, so a changed result there
can coexist with byte-identical primary modules. Fresh semantic qualification
and the selected compiler's full acquisition were independently completed.

The original [RNFA03 count receipt](evidence/accounting-rnfa03.json), SHA-256
`9f4e1309f4481c26d0fcf83ff1f7b86178a4400c5424e869850dfb38961bab30`, is unchanged.
Its 23,570 physical lines and 19,416 code lines remain the correct historical
counts for that provisional compiler.

## Completed final joins

The [final report](README.md) and [selected qualification](../../selfhost/tools/performance/phase48/evidence/selected-qualification.json)
join the fresh 45-point / 669-sample comparison, independent all-row verification,
semantic controls, installed release, 42 CLI checks and portable replay. This
static receipt remains separate from those results and does not by itself justify
introduced lines. Compiler latency and campaign elapsed time are reported
separately from generated-program speed and source size.
