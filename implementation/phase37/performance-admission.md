# Phase37 performance admission

**Decision: retain and install frozen checked03. The inherited release gates
and installation checks are now complete.** The phase delivers large
targeted numeric gains and repeatable tree gains, while expanding the evidence
from 15 to 45 program points. It also has real execution regressions, higher
compilation cost on two measured sources, and a small source increase. This is
an explicit tradeoff, not an overall-speed, TypeScript-parity or simplification
claim. No optimizer change followed the held-out performance measurements.

The selected API SHA256 is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`,
from `selfhost/build/phase37/checked03/attempt.json`. It is a checked B1
derivative, not a self-emitted fixed point. Phase36 checked03 is the immediately
previous compiler; the TypeScript reference remains upstream
`018751270e800bc222a93dad7f257083ee53a5f7`.

## Evidence and comparison boundary

The [complete execution table](execution/report.md) and its
[machine-readable observations](execution/report.json) contain all **45 frozen
points from 23 compiled sources**, with **669 samples** across four separate
paired runs. Every output passes its fixed expectation. The summed run wall time
is **1,056.320 seconds**, about 17.61 minutes, including process startup, warmup
and calibration. This is workflow cost, not a program-runtime denominator or a
promise that all 45 points fit a 600-second preset.

Execution times include the output/checksum work and exclude compilation,
import, first call, warmup and profiling. Each ratio compares roles within the
same run. Historical and variation runs request five rounds, 1,000 ms warmup
and 300 ms timing blocks; the historical whole-image ray point retains its
three-round policy. New application runs use five rounds, 600 ms warmup and
250 ms timing blocks. All use serial fresh processes under the same bounded
Node/CPU protocol. Different protocols are not pooled into an average ratio.

Observed ranges are descriptive, not confidence intervals. There are six
points with disjoint faster candidate ranges, four with disjoint slower ranges,
and 35 with overlapping ranges. These counts are not weights for estimating
typical application speed. Paired direction and within-block drift remain
relevant even when ranges overlap. The suite covers selected CPU/in-memory
programs; it does not cover all language behavior, IO/FFI throughput, native/GPU
execution or a population-weighted mix of applications.

## Gains that justify retention

Times below are median milliseconds per completed exported call. Gain is
`Phase36 / checked03`; the last column is `checked03 / TypeScript`.

| Point | Phase36 ms | Checked03 ms | Gain | Remaining TS ratio |
| --- | ---: | ---: | ---: | ---: |
| Numeric recurrence 256 | 0.0397300 | 0.0148559 | **2.674×** | 7.382× |
| Numeric recurrence 1024 | 0.131576 | 0.0254735 | **5.165×** | 3.338× |
| Tree depth 6, seed 17 | 2.77280 | 2.37967 | **1.165×** | 62.708× |
| Tree depth 8, seed 0 | 19.5728 | 16.0265 | **1.221×** | 57.117× |
| Tree depth 9, seed 123 | 58.3332 | 45.9310 | **1.270×** | 64.794× |

All five points improve in every paired round and have disjoint sample ranges.
The native-cast change removes repeated generic dispatch from an already proved
numeric loop, sharing the exact effective public conversion semantics through
the existing `JNative` path. The finite-selector change reuses existing typed
matching, purity and materialization proofs; it retains ordinary tagged values
and generic fallback. The [cast findings](optimizer/native-cast-prototype.md)
and [tree findings](optimizer/tree-findings.md) separate saved-output mechanism
experiments from these final checked-compiler results.

The larger tree point still has substantial within-block drift: Phase36 ranges
from −17.50% to +17.25%, checked03 from −6.15% to +25.99%. Its five paired gains
remain 14.68–22.77%, but the bounded result is not a claim of stabilized
steady-state throughput. Numeric 1024 has much smaller candidate drift,
−1.88% to −1.21%.

Unicode 64 also has disjoint faster ranges: 2.01044 to 1.97376 ms, a **1.0186×**
gain (1.82% lower time). Every pair improves, but no isolated mechanism
attribution was established. It is recorded as an observation, not credited
to a particular optimization.

## Execution costs accepted in this version

All four disjoint slower points must remain visible. Positive changes below
mean slower; ratio-of-medians and median paired changes answer different
descriptive questions.

| Point | Phase36 ms | Checked03 ms | Median time change | Median paired change |
| --- | ---: | ---: | ---: | ---: |
| Historical symbolic regression | 3.87947 | 3.94271 | **+1.63%** | +2.82% |
| Lexer size 6, seed 17 | 36.0373 | 36.6788 | **+1.78%** | +1.53% |
| Active ray 256, seed 2240 | 85.8160 | 88.8849 | **+3.58%** | +4.06% |
| List pipeline 512 | 1.22934 | 1.28651 | **+4.65%** | +5.13% |

Each of these four points is slower in all five paired rounds. Candidate
symbolic-regression and active-ray maxima reach 4.54226 and 98.96620 ms;
their largest paired penalties are 17.08% and 13.21%. Candidate half drift
reaches +21.43% and +17.13%, respectively. The medians do not remove those
observations. The final active-ray result supersedes the short earlier screen
whose ranges overlapped; eliminating the rejected candidate's many tiny proof
scopes did not establish a zero-cost final change.

List 512 is particularly clear: all candidate samples, 1.28183–1.29237 ms,
exceed all baseline samples, 1.21837–1.24247 ms. Its paired penalties are
3.48–5.68%, with little within-block drift. The
[static source comparison](optimizer/development-final-observations.md) finds
all six benchmark-reachable emitted definition bodies unchanged, no calls to
the new region guard/proof entries, and eight new finite branches only in
unreachable definitions. The module grew 2.91% in bytes. Direct hot-loop
DataView checks or finite branches therefore do not explain this workload's
penalty. Module layout, JIT context, collection behavior or other variation are
possible causes; none was isolated. Required correctness work does not excuse
an unrelated inactive-code cost.

Closures 256 has overlapping ranges, a +3.15% ratio-of-medians penalty and four
of five slower pairs; its median paired change is +2.28%. It remains a possible
small regression. Conversely, generic row32's +6.91% ratio-of-medians penalty
coexists with overlapping ranges and a slightly faster median paired ratio.
Neither should be simplified to an established uniform percentage change.

The [six held-out results](holdout-findings.md) add costs that overlapping
ranges do not erase:

| Held-out point | Median paired change | Paired direction |
| --- | ---: | --- |
| BST 64 | **+3.85%** | Five slower |
| Expression 128 | **+3.00%** | Five slower |
| Record aggregation 64 | **+3.44%** | Five slower |
| Record aggregation 256 | −0.49% | Three faster, two slower |

Record 256's two slower rounds are +17.03% and +42.85%; its candidate maximum
is 132.979 ms. No reliable gain is claimed for its slightly faster median.
Both Bend roles at expression 128 slow substantially during their timing
blocks; record 256 has only three calls per sample. These are short-block
observations, not stabilized throughput. BST 32 and expression 32 improve
in all five pairs, but do not cancel their larger companions' regressions.

The remaining TypeScript gaps are large: 151.69–209.31× for BST,
41.64–42.70× for expression evaluation, 59.87–71.69× for record aggregation,
and 91.19–105.54× for map churn. A large gain in one numeric kernel does not
establish application parity.

## Compilation and code-size cost

The [normal checked-request measurements](../../selfhost/build/phase37/compiler-cost02/report.json)
pass all 27 observations: three sources, three compiler roles, three fresh
rotated rounds. The worker uses normal Bend inspect/Base handling and normal
TypeScript load/check/library emission, requiring exact independently acquired
output. Host import is measured separately; this is not an emission-only
benchmark or a self-bootstrap timing.

| Source | Phase36 request ms | Checked03 request ms | Change | Checked03 / TS request |
| --- | ---: | ---: | ---: | ---: |
| Local pair | 1,700.878 | 1,742.898 | **+2.47%** | 5.609× |
| Tree bitonic | 1,515.185 | 1,612.191 | **+6.40%** | 5.536× |
| Numeric recurrence | 1,306.120 | 1,319.924 | +1.06% | 5.060× |

Pair and tree request ranges are disjoint slower. Including host import, their
median costs rise 1.89% and 5.74%; numeric rises 0.31% with overlapping ranges.
The numeric request range is 1,303.622–1,396.666 ms, so its small median change
is not evidence of an isolated compiler-speed improvement or regression.
Median process peak RSS stays close: pair 525,080 to 526,620 KiB, tree 523,860
to 523,600 KiB, numeric 521,660 to 520,860 KiB. These small-sample observations
do not establish a memory improvement.

Generated output grows by 1,192 bytes for pair (+0.96%), 5,220 for tree
(+6.06%) and 620 for numeric (+0.79%). The compilation overhead is accepted
with this version's targeted execution gains, but is a real iteration-loop
cost. No claim is made that executing the gains amortizes compilation for every
use case.

The [frozen source-size count](source-size-final.json) records **18,174 to
18,358 physical Bend lines: +184, or +1.01%**. Nonblank lines rise 164;
modules rise 69 to 70; definitions rise 2,024 to 2,045. Types and laws remain
71 and 640. The assembled runtime grows 652 bytes/eight lines; the generated
API grows 16,972 bytes. Reusing existing IR and proofs limits the conceptual
addition, but the finite admission/selection code and host-mutation obligations
are additional complexity. This phase does not reduce source or prove a lower
concept count.

## Correctness conditions and release boundary

The shared DataView guard is required correctness work. An earlier cast
prototype lost observable callbacks despite matching scalar checksums:
18 of 22 mutation observations failed. The corrected guard validates the
existing view's exact prototype, absence of four own method overrides and the
four captured prototype methods. A previously leaked view remains covered.
The guard deliberately avoids checking a subsequently unused global
constructor; creating additional views inside a future proved region would
require revisiting that obligation.

Fresh checked03 controls pass **44 cast oracle rows, 57 cast boundaries,
seven cast admission records, 22 DataView observations, 154 finite oracle
rows, 76 finite boundaries and nine finite admission records**. The expanded
application check passes 154 executions: 45 catalog points plus 32 small
controls, each on checked03 and TypeScript. These heterogeneous counts must
not be summed into a language-conformance denominator. The
[final owner closure](optimizer/final-scope-owner-report.md) binds the three
new owner groups to the selected API through 710 file identities and 15
pinned Git blobs.

Retention accepts the measured penalties above to preserve the large narrow
gains, the required guard correction and a bounded implementation using
existing compiler machinery. This is a qualitative engineering decision over
the complete observations, not a post-hoc claim that a predeclared percentage
threshold was met. It does not authorize dropping generic fallback, weakening
mutation checks or treating held-out regressions as tuning inputs for this
same candidate.

The [release record](release-03.md) closes the inherited frontend/backend gates,
all fifteen Phase35 owner groups and seven Phase36 groups bound to this API,
canonical-source audit, installation and 42 CLI checks, as specified in the
[integration protocol](../../selfhost/tools/performance/phase37/final-integration-README.md).
The measured-cost decision above remains separate from those semantic gates. Any compiler
change after this frozen candidate requires a new identity and new applicable
evidence. Further cost-model work, investigation of list/module-layout costs,
or broader recursive components belongs to a subsequent phase with a new
experimental design and fresh holdouts.
