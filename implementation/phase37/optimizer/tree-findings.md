# Private tree selection findings

The useful small mechanism is eliminating both finite tree selection and leaf
selection under one proved scalar root. Eliminating zip alone has weak gains.
A larger direct recursive component is substantially faster, but needs a
separate recursion/continuation proof. The actual compiler candidate remains
subject to checked source controls, expanded-catalog timings and compilation
costs; the numbers below are saved-generated-JavaScript experiments.

## Controlled mechanism experiment

All variants derive from the same frozen Phase36 tree module with SHA-256
`6ba1adf3a5ba6aeae722f63dd16adef0a32ff846027d563fcd322c428cdff696`.
The original remains byte-identical. Guard-only, zip-only, finite selection,
recursive warp and complete-component variants retain the original generic
fallback. Diagnostic counters are absent from clean timing modules. Root alone
executes acquisition, controls and timing under the shared serial resource guard.

The first derivation (`tree-derive-outer01`) fails an assertion before output:
there are three `callOwned` warp sites and one equivalent tail `jump`, rather
than four `callOwned` sites. Its tool remains unchanged. The explicit v2 tool
handles and verifies both shapes. `tree-derived02` succeeds;
`tree-controls02` passes 313 structural/numeric oracle observations, 112 public
boundary observations and 25 admission observations. Controls include complete
trees, surviving aliases, nonzero actual private entry, dependency mutation,
deferred-field order/errors and unchanged public stages. This does not itself
establish a general compiler admission rule.

The five-round confirmation (`tree-confirm02`) measures seven roles at three
input sizes: 105 samples in 176.383 seconds. Medians are milliseconds.

| Depth / seed | Original Bend | Finite selection | Complete component | TypeScript | Finite gain | Component gain |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 6 / 17 | 2.8883 | 2.1771 | 1.1090 | 0.03683 | 1.327× | 2.604× |
| 8 / 0 | 20.1188 | 15.0908 | 6.2219 | 0.27340 | 1.333× | 3.234× |
| 9 / 123 | 58.8363 | 44.4350 | 16.5314 | 0.73284 | 1.324× | 3.559× |

Finite/component ranges are disjoint from original at all three sizes. Zip-only
gains are 1.030×, 1.098× and 1.057×, with overlapping ranges at the smaller and
larger sizes. Guard-only medians are 3.0142, 20.9855 and 65.8934 ms: the boundary
itself costs time. Even the component remains 22.6–30.1× slower than TypeScript
on these points. The experiment supports a mechanism, not a parity claim.

## Small actual-source candidate

[`finite.bend`](../../../selfhost/src/back/js/finite.bend) adds 163 physical Bend
lines and 19 helper definitions, plus approximately 17 Bend integration/proof
lines. It adds no type representation, optimizer IR, worker registry or
recursive worker. Existing `JPure`, scalar guards, original Lam/Mat prefixes,
constructor layout and generic fallbacks are reused.

The candidate handles saturated acyclic finite selectors with at most eight
arguments, 256 executable source nodes and prefix depth below 32. Leaves allow
variables, literals, existing scalar primitives and inert nonnative constructors
(Bool is the native exception). Helper calls, recursion, lets, native
constructors such as Nat successor and higher-order shapes refuse the selector
route. A complete typed prefix proof checks the remaining obligations.

Direct field reads require a wholly guarded scalar-input graph whose internal
constructor fields are fully materialized. Purity alone does not justify eager
matching. Public trees and raw/staged entries stay generic. The root opens a
scope only with no existing proof, and the outer force loop owns nested generic
tail cycles. Native Bool.xor remains generic but is explicitly typed and captured.
The separate cast experiment's DataView guard correction is required before
promotion because float literals can otherwise invoke mutable host hooks.

Before the first build, review caught nested root forcing and eager analysis
scheduling. The preserved `finite-v1` and `finite-v2` patches are **unexecuted
proposals**. The successor requires `regionProof===null`, gates name lookup and
saturated arity, uses `kc` for cheap-to-expensive checks because Bend `&&` is
eager, and strips annotations in the bounded match probe.

`checked01` then fails bootstrap parsing in 2.56 seconds: a parameter match
follows local bindings. Moving that match to the start of its definition and
the bindings inside its branch produces `checked02`, which passes in 40.366
seconds including Focus36. Neither event is a program-speed measurement.

The checked API visibly preserves the intended lazy screening. Nevertheless,
readiness/type checks repeat per known call, complete pure-graph analysis repeats
per fallback scalar root, and each direct branch duplicates generic output.
Normal compiler time, emitted bytes and expanded-catalog regressions therefore
remain mandatory gates. The active ray workload is especially important because
guard descriptor checks were already a major cost before adding DataView checks.

Actual-source fixtures include complete aliased trees, multiple sum inputs,
declined shapes, nonzero branch counters, 30,000-step self/mutual tail cycles,
actual argument overflow with Error mutation/reentry, dependency mutation and
raw/public/staged calls. The later sections record the actual controls and
runtime acquisitions separately from the preceding saved-output experiment.
Detailed version history is in
[`attempts.md`](attempts.md), and independent proof review is in
[`finite-review.md`](finite-review.md).

The first actual checked02 runtime screen gives 1.215× on depth 8 and 1.122×
on depth 6, smaller than the saved-output finite mechanism. It also exposes an
active-ray regression: tiny scalar-only selectors induce 1,968 extra complete
guard scopes per call. That root policy is rejected. The
[`ray attribution report`](ray-regression.md) preserves the complete failing
screen and counter/ablation evidence. A three-line profitability successor
requires a sum-touching finite selector before creating a new scope; scalar
selectors remain usable in existing proofs. The finite module becomes 166 lines.
Root's checked03 build passes in 42.175 seconds; its fresh runtime/fixture results
are recorded below. The earlier tree timing is neither erased nor treated as
the final successor's result.

The final checked-source control now passes: `finite-cohort05` binds the v5
source to Phase36, checked03 and TypeScript receipts; `finite-controls02` passes
154 independent/differential oracle observations, 9 admission observations and
76 boundary observations in 1.307 seconds (reported peak 101 MB). All five actual
selector families enter, complete tree aliases survive, and each 30,000-step
self/mutual tail cycle opens only one outer scope and executes its terminal
selector. Argument overflow and Error mutation/reentry preserve fallback
behavior and leave no active proof. Module, receipt and diagnostic-parent hashes
match; the full identities and fixture/tool failures are retained in
[`attempts.md`](attempts.md). This establishes the focused finite controls, not
the still-pending expanded performance and final integration gates.

## Checked03 preliminary execution screen

Root's `candidate-screen02` completes all six selected cases in 45.63 seconds,
with three paired rounds against fresh same-run Phase36 and TypeScript roles.
This is a short screen, preceding the five-round expanded acceptance groups.

| Point | Phase36 ms | Checked03 ms | Gain | Checked03 / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Tree depth 8 / seed 0 | 22.6625 | 18.2723 | 1.240× | 64.19× |
| Tree depth 6 / seed 17 | 3.2901 | 3.0258 | 1.087× | 78.41× |
| Numeric recurrence 256 | 0.04725 | 0.01442 | 3.277× | 7.27× |
| Numeric recurrence 1024 | 0.13092 | 0.02590 | 5.054× | 3.19× |
| Active ray 256 / start 2240 | 90.0331 | 89.6643 | 1.004× | 71.70× |
| Zero-work scalar region | 0.004022 | 0.004073 | 0.988× | 60.92× |

Tree and recurrence ranges are disjoint. Active-ray and zero-work scalar ranges
overlap; these are parity screens, not claimed improvements. The ray regression
from checked02 is removed. The recurrence gain comes from the independent native
cast patch, not the finite selector mechanism. Tree samples show substantial
within-process drift (candidate later halves about 38–45% slower), so do not
treat this short screen as steady-state evidence. The full five-round results,
normal compilation costs and integration gates remain the final decision basis.

## Final historical comparison

`historical-final01` completes all 15 unchanged historical cases in 385.774
seconds, with 219 samples. Ordinary points have five paired rounds; the existing
expensive-ray policy retains three. This supersedes the preliminary screen for
these points; variation/application acceptance groups are separate.

| Point | Phase36 ms | Checked03 ms | Gain | Checked03 / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Tree depth 8 / seed 0 | 19.5728 | 16.0265 | **1.221×** | 57.12× |
| Historical raytrace | 717.9430 | 693.1939 | 1.036× | 20.20× |
| Scalar region 8192 | 0.154784 | 0.139629 | 1.109× | 1.40× |
| Complete generic row32 | 0.402784 | 0.430625 | 0.935× | 58.11× |

Tree ranges are disjoint: 19.4391–20.5505 ms baseline and 15.8929–16.1282 ms
candidate. Every paired round improves by 17.4–22.0% in execution time. Later
sample halves drift about 4.0–7.0% for the candidate and 5.3–7.4% for baseline,
substantially less than the preliminary screen's 38–45%. This confirms the
finite mechanism's runtime gain at the historical tree point, while retaining
a large TypeScript gap. The handwritten complete recursive component remains
unimplemented and its larger gains must not be attributed to this compiler.

Historical ray has a small range overlap (candidate maximum 713.742 ms versus
baseline minimum 712.564 ms), though all three paired rounds improve. Its Bend
samples contain only one timed invocation per round, so half-drift is unavailable.
Scalar-region ranges overlap substantially and its baseline includes a slow
0.26077 ms round; treat that median gain cautiously. Most other historical
points are within about 2%, rather than broad speed breakthroughs.

The generic-row ratio of medians is 6.91% slower, but its paired evidence does
not establish a material regression. Baseline range 0.39142–0.43801 ms overlaps
candidate range 0.38635–0.44126 ms. Candidate/baseline ratios by round are
0.9592, 1.0028, 1.1074, 0.9833 and 0.9925: the median paired ratio is 0.9925 and
the geometric mean is 1.0078. Report the original ratio-of-medians result without
turning it into a confirmed seven-percent slowdown.

Read-only generated-code comparison finds exactly two changed function bodies
in that row module: `umin` and `cell.f1` gain finite selector conditions for
`umin.go` and `b2u`. Both modules have the same 31 generated definitions and the
same complete-array serialization adapter. The candidate has no finite root,
no generated host-guard call and no generated proof opening. Consequently its
two finite paths stay behind false `regionProof!==null` tests during this entry;
the DataView guard extension is initialization-only here and cannot explain a
repeated execution cost. Extra null checks or changed JIT code shape are plausible
small costs, but attribution would require a later isolated ablation. No source
change or extra execution was performed for this review. Compared module hashes
are baseline `6cb4de7df70e07d226f644ee1d131b5de16b2dbe0ae6da37d487f1d520f65485`
and candidate `669560365d516bfdd9a936471a5348ec0d4a54406c0703af0156883b83be6e4b`.

## Final varied-input comparison

`variation-final01` completes all 14 varied-input cases, 210 samples and five
paired rounds per point, in 375.127 seconds. Combining its two tree points with
the separately matched historical tree point gives the following final picture;
each ratio uses the baseline measured in that point's own acquisition.

| Tree depth / seed | Phase36 ms | Checked03 ms | Gain | Checked03 / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| 6 / 17 | 2.7728 | 2.3797 | **1.165×** | 62.71× |
| 8 / 0 | 19.5728 | 16.0265 | **1.221×** | 57.12× |
| 9 / 123 | 58.3332 | 45.9310 | **1.270×** | 64.79× |

All three baseline/candidate ranges are disjoint and all 15 paired rounds
improve. At depth 6 they are 2.7493–2.7983 ms baseline versus 2.3497–2.4648 ms
candidate; both roles' half-drift stays within approximately 1%. At depth 9 they
are 55.5983–59.1833 versus 45.3354–48.4907 ms. That larger point has substantial
drift: baseline halves vary about −17.5% to +17.2%; four candidate rounds improve
by 3.7–6.2% within the sample, while one slows by 26.0%. The disjoint overall
ranges still support the gain, but the larger input is not perfectly steady.

The final active-ray points qualify the earlier parity screen:

| Point | Phase36 ms | Checked03 ms | Candidate time change | Checked03 / TypeScript |
| --- | ---: | ---: | ---: | ---: |
| 64 pixels / start 2440 | 25.9419 | 26.3763 | **+1.67%** | 87.72× |
| 256 pixels / start 2240 | 85.8160 | 88.8849 | **+3.58%** | 71.59× |

The 64-pixel ranges overlap widely (20.4046–27.2601 versus 20.5320–28.4591 ms).
Many baseline/candidate samples speed up by 35–44% between halves; its small
median difference is weak evidence. The 256-pixel ranges are **disjoint**:
85.4208–87.4211 ms baseline versus 88.3489–98.9662 ms candidate. Every paired
round is slower, by 2.95–13.21%. Candidate half-drift is +1.35% to +17.13%
(mostly about +8%), versus baseline +3.32% to +5.06%. The final evidence therefore
does show a smaller residual active-ray slowdown; do not report zero regression
from the preliminary screen.

The eight new finite roots are absent from the final ray module, so the large
1,968-extra-scope regression is fixed. The retained DataView correctness guard
adds work to existing unscoped checks and is a plausible contributor to the
remaining cost. Four finite selector sites remain behind the active-proof check;
changed generated-code shape may also matter. The final minimal guard version
has not been isolated by another ablation, so this report does not assign the
remaining 3.58% precisely to either cause. The correctness fix is retained; this
measured performance tradeoff and the still-large TypeScript gap are explicit
limitations of the selected phase result.
