# RNFA03 provisional execution checkpoint

RNFA03 passes an eight-point primary-corpus screen and a separate four-point
literal-array scaling screen. The generic-row point improves **13.431×**, from
**383.461 to 28.550 µs/call**, while remaining **4.074× TypeScript time**.
The literal-array experiment exposes substantial zero/one-iteration regressions
despite strong gains at larger sizes. RNFA03 is a provisional candidate, not a
final selected release; a successor may change only literal-path profitability.

The primary performance measure remains the unchanged **45-point corpus**, with
its established equal-point/source/family weightings. The following screens
neither replace that measurement nor establish a new aggregate result. The
supplementary scaling points do not become extra weights in the primary corpus.

## Eight primary-corpus points

`combined-rnfa03-core8/report.json` passes all **72 fresh samples** in **58.244 s**.
Each point has three rotated fresh rounds per compiler, 350 ms warmup, 40 ms
calibration target and 150 ms measurement target under the maintained serial
Node/resource policy. Times below are medians in milliseconds per call.

| Point | Array06 | RNFA03 | TypeScript | Array06 / RNFA03 | RNFA03 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| Local pair | 1.429070 | 1.439849 | 1.258059 | 0.993× | 1.145× |
| Local fold, 4096 | 0.060789 | 0.060854 | 0.063288 | 0.999× | 0.962× |
| Scalar region, 0 | 0.004364 | 0.004233 | 0.000067 | 1.031× | 63.137× |
| Scalar region, 8192 | 0.112245 | 0.113543 | 0.099755 | 0.989× | 1.138× |
| Complete generic row, 32 | 0.383461 | 0.028550 | 0.007009 | 13.431× | 4.074× |
| Mandelbrot | 0.121582 | 0.121995 | 0.047634 | 0.997× | 2.561× |
| Edit distance | 5.633923 | 5.659440 | 5.035221 | 0.995× | 1.124× |
| RLE round trip | 0.031752 | 0.031564 | 0.000547 | 1.006× | 57.727× |

The generic-row observation checks the complete JSON output of all four returned
backings. This is the existing full-output catalog oracle, not a new partial
checksum designed to avoid the result boundary. Its measured time falls 92.55%.
The other seven median changes range from 2.99% less time to 1.16% more time;
these small differences do not establish isolated optimization effects.

Generic-row maximum absolute half-window drift is 1.465% for array06, 6.190%
for RNFA03 and 11.945% for TypeScript. Across all eight points the maxima are
10.691%, 11.077% and 12.331% respectively. These are short warmed windows, not
proof of stationarity or statistical significance. Scalar zero-trip and RLE
remain large gaps; this checkpoint does not imply broad TypeScript parity.

## Separate literal-array scaling experiment

`literal-scale-screen-rnfa03/report.json` passes **36 fresh samples** in
**29.453 s**, with the same three-round screen protocol. All points call the
independent `loop_bench(n,3)` fixture and retain its full scalar output oracle.

| Iterations | Array06 µs | RNFA03 µs | TypeScript µs | Array06 / RNFA03 | RNFA03 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| 0 | 1.251638 | 13.008179 | 0.232643 | 0.096× | 55.915× |
| 1 | 5.016309 | 13.700651 | 0.268020 | 0.366× | 51.118× |
| 128 | 295.045777 | 18.107739 | 1.806502 | 16.294× | 10.024× |
| 8192 | 19145.372750 | 269.081996 | 116.007170 | 71.151× | 2.320× |

At zero iterations RNFA03 takes **10.393×** the baseline time; at one iteration
it takes **2.731×**. The absolute extra costs are about 11.757 and 8.684 µs.
These regressions remain visible alongside the 16.294× and 71.151× gains at 128
and 8192 iterations. Maximum absolute candidate half-window drift is 2.020%,
1.910%, 11.760% and 0.135% for those four points respectively; baseline and
TypeScript drift arrays are retained in the evidence.

This size dependence supports testing a general zero/one-trip decline before
the expensive literal path's full guard. It does not prove that such a gate is
already correct or implemented, nor that a particular guard causes all the
difference. The proposed successor must preserve the old path's argument
evaluation, host mutations and demand behavior, receive independent controls,
and retain the large-input benefit. It must not select benchmark names. No
successor performance is inferred from RNFA03's samples.

## Identities and scope

Both screens bind candidate API
`a64c4dceb00f60c7cdb9994afb864564f4ff9a9c8b1c143b066db793b9ba738b`,
array06 API `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`,
and the unchanged runtime
`880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
The pinned TypeScript compiler remains upstream
`018751270e800bc222a93dad7f257083ee53a5f7`.

[Checkpoint evidence](evidence/rnfa03-checkpoint.json) independently recomputes
the medians and ratios, agrees with all 108 raw sample/process leaves, and
rehashes 385 consumed files. It keeps both protocols, role identities, exact
points and drift arrays separately. Raw report SHA-256 values are:

- `selfhost/build/phase48/combined-rnfa03-core8/report.json`:
  `e0cf7ecd9a53410510b0e6d5614520dd3184806726f2179f9cc6b897dc044600`.
- `selfhost/build/phase48/literal-scale-screen-rnfa03/report.json`:
  `3d10c2d1758ca8e163f8ae44ba41ff52b6ed35fd8f5c9b2aefd405c13dfa260a`.

The [RNFA03 count receipt](evidence/accounting-rnfa03.json) is bound to this same candidate.
Independent mechanism controls, compiler-request cost, the complete corpus,
installation and portable publication remain separate qualification scopes.
No target execution, source change, compression or raw mutation was performed
to produce this data-only checkpoint report.
