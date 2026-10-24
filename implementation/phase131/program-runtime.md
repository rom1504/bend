# Generated-program runtime: full historical45 screen

The combined compiler's generated-program performance is **approximately
unchanged overall**. In the fresh paired block it takes 1.66268× upstream time,
versus 1.66679× for the same Phase128 baseline binaries. Candidate/baseline is
0.99754, only 0.246% lower time. This is not a broad runtime optimization win.
All 405 observations pass their complete output/count oracle.

These products come from the actual checked hosted API for combined-literals
source `1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
Native N2 subsequently reproduced every measured wrapper's whole QBE output
byte for byte, using the same runtime and retained build products. The native
output bridge below therefore binds this performance evidence to N2 without
rerunning identical programs. Whole-source self-reproduction and the remaining
native qualification gates are separate.

| Metric | Phase128 binaries, fresh block | Combined candidate |
|---|---:|---:|
| Historical 44-point geometric time/upstream | 1.66679× | 1.66268× |
| Mean positive log slowdown | 0.769020 | 0.767276 |
| Equal-weighted family geometric time/upstream | 1.73593× | 1.73501× |
| Sum of median fixed-batch time | 21,302ms | 21,209ms |
| Sum of positive excess over upstream | 13,023ms | 12,931ms |
| Cases above 1.1× upstream | 40/44 | 40/44 |
| Cases above 2× upstream | 21/44 | 21/44 |
| Cases above 5× upstream | 3/44 | 3/44 |

Fixed-batch time falls 0.44%; positive excess falls 0.71%. Seventeen cases have
lower medians, nine are equal and eighteen higher. Candidate/baseline geometric
ratios in the three paired rounds are 0.99827,0.99751 and0.99940. The family
weighted relative ratio is 0.99947. These descriptive measurements do not justify
a statistically significant improvement claim.

## Individual changes and uncertainty

| Case | Candidate/baseline median | Paired round ratios |
|---|---:|---|
| Mandelbrot grid5/31 | 1.06250 | 0.975,1.096,0.997 |
| BST32 | 1.04161 | 1.082,1.016,1.034 |
| Map/set operations | 1.02236 | 0.999,1.022,1.035 |
| RLE roundtrip | 1.02165 | 1.009,1.014,1.037 |
| Tree bitonic9/123 | 0.90994 | 0.959,0.878,0.987 |

The largest median regression, grid5, has mixed paired directions; it must not
be presented as an established 6.25% slowdown. BST32 and RLE are slower in all
three pairs, although magnitudes vary. Likewise the tree improvement varies
substantially. A separate five-round recheck of BST32, RLE, grid5 and tree9 has
been prepared with exactly the same binaries and frozen counts. It must not be
pooled into or silently replace this complete405-observation block.

The remaining deficit is broad. RLE is 5.70× upstream, evening 5.39×, tree6/17
5.00×, main tree 4.61×, tree9/123 4.31× and BST32 4.05×. Compiler-hot query
optimizations need not improve these unrelated timed computations. This result
supports approximate preservation of average generated-program speed, not
strict per-program non-regression or parity.

## Historical reference drift

Phase128 previously measured 1.65258× upstream. The **unchanged Phase128
binaries** now measure 1.66679× in the fresh block. Their absolute median times
rise 3.23% geometrically, while the unchanged upstream binaries rise 2.35%.
Consequently comparing current 1.66268 directly with historical 1.65258 would
confound reference drift with compiler effects. The controlled effect for this
campaign is current candidate/current baseline 0.99754. The evidence does not
identify a specific hardware or environmental cause for cross-block drift.

## Method and cost

The corpus contains 45 frozen historical repetition wrappers: 44 timed points
and the existing zero-work correctness control. Source bytes, runtime arguments,
count profile×4, warmups, role rotation and complete-output oracle are unchanged.
All three roles run on CPU3 for three rounds. Aligned candidate products reuse
the same Phase128 runtime object and toolchain policy. All 45 QBE products and
all45 machine texts differ, so selective timing exemptions were not used.

The runtime tool took 177.58s,178.38s under its outer guard; target child wall
times sum 158.34s. Builds were reused, adding zero machine-build time inside
this timing campaign. The earlier parallel CPU6 emission/check campaign cost
493.03 guarded seconds plus 14.58s for aligned builds and 45 count/output smokes.
That emission included 194.90s of independent parent work and 250.64s of integrated
candidate work. It was a correctness campaign, not a controlled compiler-speed
measurement. Source checking, native acquisition, failed earlier experiments,
agent effort and quota are not included in these numbers.

Evidence:

- [program-results.json](program-results.json): complete summary, per-case
  samples, round ratios, families, metrics and exact raw report identities.
- `selfhost/build/phase131/combined-programs01/runtime/report.json`:405 raw
  observations and preserved outputs, unchanged products and commands.
- Sibling`classification.json`: QBE/runtime/allocated-machine comparison.
- Sibling`recheck-jobs.json`: separate60-observation follow-up, not executed by
  the analysis agent.
- [Screen method](../../selfhost/tools/performance/phase131/programs/README.md):
  exact inverse derivation of the historical runner and separate correctness
  versus performance gates.

## Separate five-round recheck

The four selected cases subsequently passed all 60 fresh observations. The
exact binaries, argument vectors, frozen repetition counts, warmups and runtime
were verified against the original 405 block; no products were rebuilt. This
post-hoc subset does not replace any original observation or change the
1.66268× full-corpus score above.

| Case | Original three-round candidate/baseline | Fresh five-round candidate/baseline | Paired directions in recheck |
|---|---:|---:|---|
| BST32 | 1.04161 | 1.01563 | Slower in all five |
| RLE roundtrip | 1.02165 | 1.00428 | Four faster, one slower |
| Mandelbrot grid5/31 | 1.06250 | 1.00000 | Mixed; equal medians |
| Tree bitonic9/123 | 0.90994 | 0.98751 | Faster in all five |

The large grid regression and tree improvement did not reproduce at their
original magnitudes. BST32 retains a smaller consistent slowdown, about1.56%
by the fresh medians. The recheck does not establish a robust RLE slowdown:
its0.43% median difference coexists with four faster paired observations.
Tree improves consistently, but by about1.25% in this block. These remain
descriptive small-sample results, not confidence intervals or guarantees.

The recheck took38.79s in the runner, with36.06s of target child wall time and
zero new build time. [program-recheck-results.json](program-recheck-results.json)
preserves the separate samples, ratios and authenticated raw report. This
supports approximate average preservation with a small BST concern, rather
than either a broad performance gain or strict per-program non-regression.

## Actual native N2 output bridge

N2 image`2fae36020081ccc5cbfb847caf0b285b762387327e4bb44e1d62d96d1affd5dc`
recompiled all 45 exact frozen wrappers. Each native output matches its measured
hosted QBE completely, including LF bytes. The image build is authenticated
against Q2`f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e`,
the checked source/admission, compact carrier lineage and selected runtime.
The measured binaries are also bound to those same QBE products and runtime.

All 45 comparisons pass. Reusing the existing 405 observations therefore
measures programs that the actual native compiler produces; a second timing
campaign of identical code is unnecessary. This establishes output identity on
the frozen corpus, not a general correctness proof or completion of native
self-reproduction qualification.

The coordinator authorized CPU6 correctness execution while N3 reproduction
occupied CPU3. Native request child time sums94.24s; per-job guards sum117.05s;
the complete serial equality/binding campaign took130.27s. Peak guarded RSS was
89.2MB and minimum available memory25.73GB. These are overlapping research-cost
observations, not controlled compilation-speed measurements. No generated
program was rebuilt or retimed.

[native-program-equality.json](native-program-equality.json) preserves the
exact source, image, runtime, input/output identities and all 45 native receipts.
Execution commands and CPU6 guard lineage are under
`selfhost/build/phase131/final-native-wrapper-equality01/`; the original CPU3
plan remains unchanged. The full-corpus score and separate recheck above are
unchanged by this bridge.
