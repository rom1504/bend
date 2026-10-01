# Phase37 held-out application results

The six held-out points complete **90 samples in 110.727 seconds**, with every
program output passing its frozen oracle. Their first performance measurement
used the already frozen checked03 compiler. No optimizer change followed these
holdout observations. This closes the planned holdout measurement; it does not
establish broad performance parity or remove the penalties described below.

The principal new finding is the size of the remaining application gap:
checked03 is **151.69× and 209.31× slower than TypeScript** on the two BST points,
41.64–42.70× on expression evaluation, and 59.87–71.69× on record aggregation.
These per-point ratios are not a typical-program estimate or an average.

## Frozen workload and protocol

The selection was fixed in the [coverage design](../../design/phase37/coverage.md)
before optimization. BST insertion uses a fueled zipper and rebuilds tree paths;
the 32-element, seed-zero point inserts increasing keys and the 64-element,
seed-seventeen point uses an irregular order. Expression evaluation builds an
unbalanced tree with a recursive child and varying shallow branches. Record
aggregation produces textual numbers, parses them, updates sixteen Unicode-named
map entries and renders the complete ordered result. It is an in-memory workload,
not filesystem or full CSV-parser throughput.

BST and expression outputs are wrapping U32 digests with independently calculated
expectations. Record aggregation compares the complete returned string. Untimed
semantic checks occurred before optimization, but these families supplied no
timings or profiles for choosing the changes. Each family varies both size and
seed, so the two rows do not isolate size-only scaling.

`holdout-final01` uses five fresh serial paired rounds of Phase36, checked03 and
pinned TypeScript. The protocol requests three warmup calls and at least 600 ms
warmup, 50 ms calibration and a 250 ms target timing block. Resource bounds are
CPU 3, Node 24.18.0, a 1024 MiB heap, 2048 MiB process-tree RSS and a 2048 MiB
available-memory floor. Timings include exact-result/checksum work and exclude
compilation, import, first call and warmup. A target block is not a guaranteed
duration; calibration and changing execution cost can produce shorter or longer
blocks.

## Per-point execution results

All times are milliseconds per complete exported call. A gain below one means
the candidate has a slower ratio of medians.

| Point `(size, seed)` | Phase36 | Checked03 | TypeScript | Phase36 / checked03 | Checked03 / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| BST `(32,0)` | 3.32582 | 3.29368 | 0.0217125 | 1.010× | 151.69× |
| BST `(64,17)` | 9.93314 | 10.32466 | 0.0493282 | 0.962× | 209.31× |
| Expression `(32,17)` | 0.0945855 | 0.0879064 | 0.00205852 | 1.076× | 42.70× |
| Expression `(128,123)` | 0.346876 | 0.361951 | 0.00869139 | 0.958× | 41.64× |
| Record aggregation `(64,17)` | 20.96302 | 21.03421 | 0.293397 | 0.997× | 71.69× |
| Record aggregation `(256,123)` | 78.30743 | 77.47148 | 1.29392 | 1.011× | 59.87× |

All six baseline/candidate sample ranges overlap. Overlap alone does not erase
a repeated paired direction: comparison within each round is useful because
slow rounds can affect both roles. The table below retains both views. Paired
change is `100 * (candidate_ms / baseline_ms - 1)`; positive means slower.
These descriptive ranges are not confidence intervals or a formal significance
test.

| Point | Phase36 min–max ms | Checked03 min–max ms | Paired changes min–max | Median paired change | Direction across rounds |
| --- | ---: | ---: | ---: | ---: | --- |
| BST 32 | 3.31639–3.69961 | 3.27656–3.65860 | −2.30% to −0.20% | −1.11% | Five faster |
| BST 64 | 9.91016–11.01070 | 10.26646–11.13959 | +1.17% to +4.18% | +3.85% | Five slower |
| Expression 32 | 0.0937960–0.104569 | 0.0875631–0.100259 | −7.19% to −4.12% | −6.61% | Five faster |
| Expression 128 | 0.342152–0.360928 | 0.348944–0.382178 | +1.57% to +5.89% | +3.00% | Five slower |
| Record aggregation 64 | 19.49450–22.41976 | 20.90453–24.84886 | +0.035% to +10.83% | +3.44% | Five slower |
| Record aggregation 256 | 77.50517–93.08689 | 77.12872–132.97891 | −1.95% to +42.85% | −0.49% | Three faster, two slower |

The small expression point improves consistently, but its larger companion
slows consistently. BST 64 also has a modest repeated penalty. Record 64's
nearly unchanged ratio of medians conceals five slower paired observations;
its paired median is +3.44%. These measured costs belong in the performance
admission decision, rather than being dismissed because the full ranges overlap.
The experiment does not isolate whether additional conditional branches, guards,
output shape or runtime behavior cause them.

Record 256 demonstrates a different risk in summarizing by median alone. Its
five candidate/baseline ratios are **0.9951, 1.1703, 0.9866, 1.4285 and 0.9805**.
Thus the approximately one-percent faster ratio of medians coexists with two
substantial slower rounds. No outlier is discarded, and no reliable speedup is
claimed for this point. The candidate's 132.979 ms maximum remains in the record.

## Within-block drift and short samples

The worker divides the measured calls into two consecutive halves and records
their per-call change. The following ranges cover all five samples for each
role; positive drift means the second half is slower.

| Point | Phase36 half drift | Checked03 half drift | TypeScript half drift |
| --- | ---: | ---: | ---: |
| BST 32 | −4.69% to +2.86% | −0.51% to +4.57% | −1.04% to +2.77% |
| BST 64 | +6.14% to +15.46% | +0.08% to +16.13% | −1.69% to +3.65% |
| Expression 32 | −0.53% to +3.22% | +1.62% to +3.32% | −10.62% to +0.30% |
| Expression 128 | +9.36% to +24.69% | +13.15% to +21.71% | −8.31% to +2.37% |
| Record aggregation 64 | −13.23% to +8.59% | −12.01% to +9.67% | −0.86% to +0.62% |
| Record aggregation 256 | −9.70% to −3.03% | −15.18% to −3.60% | −4.17% to +15.09% |

The larger expression point is still slowing substantially during measurement
in both Bend roles. Record 256 has only **three completed Bend calls per timing
sample**, so its halves contain one and two calls. Record 64 has eight to
thirteen baseline calls and eight to ten candidate calls. Their drift values
are observations from short blocks, not evidence of stabilized steady-state
throughput. Five fresh rounds describe this bounded experiment; they do not
justify generalizing away the large remaining TypeScript gaps or the paired
penalties.

## Complete phase execution accounting

All four final execution groups now pass their frozen output checks on the
same selected compiler identities. Each point appears in exactly one group.

| Closed run | Points | Samples | Wall seconds |
| --- | ---: | ---: | ---: |
| `historical-final01` | 15 | 219 | 385.773709 |
| `variation-final01` | 14 | 210 | 375.126624 |
| `development-final01` | 10 | 150 | 184.692946 |
| `holdout-final01` | 6 | 90 | 110.726806 |
| Separate-run sums | **45** | **669** | **1,056.320084** |

The sum is about **17.61 minutes** of final execution workflow, including worker
startup, warmup and calibration. It excludes source acquisition, prototype
experiments, profiles and integration gates. It is neither a program-runtime
denominator nor a promise that all 45 points fit one 600-second preset. The
[aggregate execution report](execution/report.md) is prepared separately from
these closed raw reports.

The raw [holdout report](../../selfhost/build/phase37/holdout-final01/report.json)
has SHA256
`3d98adc6c2dd628892adaa2feb098dea2667e0a5e568d3194dc5452af0d8fe91`.
Its candidate API is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`;
the baseline API is
`93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75`.
The TypeScript pin remains `018751270e800bc222a93dad7f257083ee53a5f7`.
Raw build paths resolve after restoring the phase evidence capsule. This report
is a read-only analysis of root-executed evidence; it runs no target or test and
does not declare final installation or release admission.
