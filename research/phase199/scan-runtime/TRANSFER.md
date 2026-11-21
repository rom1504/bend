# Actual generated-program transfer and scan-only contribution

The unchanged Bend fold programs now contain a real call to the shared SSE2
leaf. Independent decoding confirms the five SysV arguments, owner preservation
in RBX, and original owner/carry output order. Initialized-runtime controls
passed 649 trials and checked 39,699 cells. The 275 observed calls equal exactly
315 raw-array trials minus 40 empty entries; shared, static and uniform-array
fallback tests added no helper calls. See `candidate-abi-review.json` and
`candidate-count-review.json` in `evidence/` for exact object/receipt pins.

## Measured complete-program performance

The focused acquisition used five cyclic role positions over five rounds,
three fold inputs, and three runtime/link-order configurations: 225 validated
observations, each at least 130 ms. Ratios below are medians of within-round
pairs from the live runtime with program/helper/runtime link order:

| Ordinary source case | SIMD / matched old worker | SIMD / same-object scalar delegate | SIMD / mature C |
| --- | ---: | ---: | ---: |
| 4096 steps, seed 17 | 0.27427 | 0.43981 | 0.54505 |
| 128 steps, seed 0 | 0.54545 | 0.73864 | 1.43382 |
| 8192 steps, seed 123 | 0.26136 | 0.42990 | 0.52271 |

The scalar delegate uses the identical new program object and call ABI, with
ordinary scalar C in the helper. Its separate improvement over the old worker
means the full gain cannot all be attributed to SIMD. The SIMD/delegate column
isolates the vector contribution at that seam. The two longer inputs beat
mature C; the short input remains **43.4% slower than C**, despite improving on
the old Bend worker. Swapping helper/runtime link order yields SIMD/baseline
0.26834, 0.54658 and 0.25989, with C ratios 0.54546, 1.47233 and 0.52340. The
original runtime cross-check agrees in direction. This is one short focused
acquisition, not an independently repeated full-catalog timing campaign.

The independent read-only analysis in `contribution.py` revalidates all 225
printed result/count observations and recomputes the published paired ratios.
Its input is `selfhost/build/phase199/focused-runtime01/report.json` and its
output is `evidence/contribution.json`.

## Transparent broad projection

Use the authenticated Phase198 live fixed-work summary: 45 programs executed,
44 ratio-eligible cases, 19.31277 seconds of fixed-catalog-equivalent work and
case geomean 1.27813 relative to C. Prior object/allocated-layout equivalence
receipts authenticate transfer of those measurements to the corrected Phase198
baseline. Apply the three measured SIMD/matched-baseline ratios above to those
three historical case times, leaving the other 41 eligible cases unchanged:

* Geometric factor: `exp((log(r1)+log(r2)+log(r3))/44) = 0.92898`, a **7.10%**
  reduction; projected C-relative geomean **1.18735**.
* Fixed-work time: **19.31277 → 18.57114 seconds**, saving **0.74163 seconds
  (3.84%)**. The other live link order projects 0.74353 seconds (3.85%) saved.
* The fold family's contribution falls from **1.21811 → 0.47648 seconds**,
  or **2.57%** of the projected remaining time.

These are mechanical projections from focused measurements and historical
weights, **not measured new broad results**. Fixed-equivalent work is the
catalog's frozen repetition count, not the elapsed time of the whole benchmark
acquisition. The non-ratio-eligible zero-work case is excluded from these
denominators, matching the existing summary. Historical dispersion warnings
remain applicable.

## Largest remaining diagnostic opportunities

After the same projection, family positive fixed-work excess over mature C is:

| Family | Remaining work | Positive excess over C |
| --- | ---: | ---: |
| Raytrace | 2.897 s | 1.175 s |
| Lexer | 1.646 s | 1.026 s |
| BST | 1.238 s | 0.824 s |
| Mandelbrot | 1.525 s | 0.821 s |
| Tree-bitonic | 1.389 s | 0.562 s |

Individual large gaps include evening-program (0.740 s), RLE roundtrip
(0.616 s), and BST-32 (0.534 s). These are prioritization diagnostics, not
promises that a compiler optimization can attain C's time. The largest
remaining work is outside the now-improved fold family.
