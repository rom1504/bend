# Phase39 performance admission

Decision: **retain the four narrow mechanisms in checked05 for release**. All 45 primary points, the separate four-point confirmation, exact-byte aggregate and final semantic gates pass. This admits the measured tradeoff below; the [release record](release-05.md) separately confirms installation and all 42 CLI checks, and the [final audit](final-conformance/gates.md) closes all 15 groups and 227 canonical source pairs.
The [campaign](../../design/phase39/campaign.md) remains the prospective contract.
Initial screens and preserved failures are in the [phase index](README.md),
[component report](components.md), [countdown report](countdown.md), and
[scope report](guard-scope.md). The [complete execution table](execution/report.md)
and [machine-readable aggregate](execution/report.json) preserve all primary
and confirmation observations, including hashes, ranges, pairings and drift.

## Exact comparison

The candidate is **Phase39 checked05**, API SHA256
`04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`.
Its complete checked preparation is
`selfhost/build/phase39/final-candidate01/manifest.json`: all 45 frozen points
from the unchanged Phase37 catalog, spanning 23 source files. A successful
acquisition establishes checked output availability, not measured execution or
all interface obligations.

Every final comparison executes three roles afresh: installed **Phase37
checked03**, the selected checked05 output, and the pinned upstream TypeScript
output. The current baseline API is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`;
upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.
Historical Phase36/37 medians are not denominators for this phase. Prototype
modules and earlier checked candidates are not final compiler measurements.

The final image is frozen before the broad measurements. Phase37's former
holdout families are now exposed, and expression was used during this phase's
development. Their catalog partition names remain historical labels; they are
not described as fresh unseen holdouts. Independent source shapes and refusal
controls supply separate transfer evidence. Broad final results are not followed
by tuning this candidate on an inconvenient point.

## Required evidence and interpretation

1. **Correct execution and interfaces.** All 45 frozen outputs must pass.
   Checked B1, focused frontend checks, applicable inherited owners, the four
   new actual-output owners and release integration retain separate reports.
   Public mutation, partial/raw/overapplied calls, aliases, field demand,
   first-error order, reentry and deep tail behavior cannot be discharged by
   scalar checksums or agreement with TypeScript alone.
2. **Controlled paired execution.** Final ordinary points use five complete
   rotated rounds per role in fresh serial Node 24.18.0 processes on CPU3.
   Preserve the maintained expensive original-ray exception of at most three
   rounds and one warmup call; label it explicitly. Runs record their actual
   warmup, calibration and timed-target settings. Use bounded chunks rather
   than truncate inputs or imply the full catalog fits one 600-second request.
3. **Within-run arithmetic only.** For each point, report baseline, candidate
   and TypeScript median milliseconds and their observed minimum–maximum
   ranges. Incremental gain is `baseline median / candidate median`; the TS
   deficit is `candidate median / TypeScript median`. Candidate change is
   `(candidate median / baseline median - 1) × 100%`. Keep paired round ratios
   and candidate win/tie/loss counts. Do not pool samples from different runs.
4. **Drift and uncertainty remain visible.** Retain every role's first-call,
   import and half-run drift observations. Disjoint full ranges and a common
   paired direction strengthen a local observation; ranges are not confidence
   intervals and five wins are not a significance test. Overlap is not evidence
   of no cost. Material drift requires an explicitly separate confirmation or
   a qualified protocol-specific claim, never removal of earlier samples.
5. **Costs receive the same scrutiny.** Name every disjoint slower point and
   every consistent paired slowdown, including small costs. Show median/range,
   paired counts, drift and generated module bytes before attributing a cause.
   A gain elsewhere does not erase these costs. Normal checked-request latency,
   source/module/definition counts and generated API bytes remain separate
   outcomes; build duration is not compiler throughput.
6. **One selected image and traceable bytes.** Reports must share exact
   candidate and baseline compiler identities. Each sampled role/case binds
   to the corresponding checked bundle's source, point, module hash and bytes.
   Node identity must match the selected attempt. Repeated primary IDs reject;
   explicit confirmations retain their own rows and cannot silently replace
   a primary observation.

The [final report generator](../../selfhost/tools/performance/phase39/summarize-execution.py)
enforces these identity, completeness and arithmetic constraints, with
`--require-full` for the 45-point aggregate. It reports point-specific results,
not an average application speed. Profiles and diagnostic counters are separate
from clean timing and cannot be substituted for observed execution gains.

## Completed primary execution

The four unchanged-image runs pass **45 points / 23 source files**, with
**669 fresh samples** in **1,076.213 seconds** of workflow time. Historical and
variation groups use the 600-second preset (1,000 ms warmup, 300 ms timed block);
development and exposed groups use the 300-second preset (600 ms warmup,
250 ms timed block). All ordinary points retain five rounds per role; original
raytrace retains three. These are the actual measured protocols, not a universal
steady-state distribution. Workflow wall time is not a speed denominator.

| Primary group | Points | Samples | Wall seconds |
| --- | ---: | ---: | ---: |
| `final-historical01` | 15 | 219 | 391.506 |
| `final-variation01` | 14 | 210 | 386.839 |
| `final-development01` | 10 | 150 | 183.761 |
| `final-exposed01` | 6 | 90 | 114.107 |

The separately reported four-point confirmation contributes another **60 samples
in 98.328 seconds**; all five runs total **729 samples / 1,174.541 seconds**.
Confirmation samples are not pooled with or substituted for the primary runs.

The substantial measured gains are below. Every listed candidate wins all five
pairings and has an observed range wholly below the baseline range. Times are
milliseconds per complete benchmark call; gain and TS deficit use the ratio of
medians. TypeScript medians/ranges, all first-call/import observations and every
paired sample remain in the complete execution records.

| Point | Phase37 ms [range] | Phase39 ms [range] | Gain | Phase39 / TS |
| --- | ---: | ---: | ---: | ---: |
| Expression 32 | 0.105447 [0.104402–0.11769] | 0.0236367 [0.0213332–0.0240108] | 4.461× | 10.465× |
| Expression 128 | 0.391518 [0.385809–0.430375] | 0.0486259 [0.0477648–0.0531515] | 8.052× | 5.239× |
| Active ray 64 | 29.2307 [28.9893–34.7567] | 10.1942 [9.91436–12.5145] | 2.867× | 33.653× |
| Active ray 256 | 101.304 [99.3423–110.755] | 38.7067 [37.7498–51.3659] | 2.617× | 31.027× |
| Tree 6 / seed 17 | 2.86865 [2.8651–2.90995] | 1.62926 [1.61719–1.64598] | 1.761× | 44.003× |
| Tree 8 / seed 0 | 18.3023 [18.2662–18.3919] | 10.2073 [10.0934–10.4466] | 1.793× | 36.801× |
| Tree 9 / seed 123 | 50.0104 [49.7905–51.0186] | 22.2058 [22.0266–22.3375] | 2.252× | 31.846× |
| Symbolic regression 4 / 17 | 2.07008 [2.06124–2.1223] | 1.18151 [1.17723–1.18912] | 1.752× | 2.140× |
| Symbolic regression historical | 4.29985 [4.24374–4.77831] | 2.42968 [2.40753–2.67668] | 1.770× | 2.201× |
| Symbolic regression 7 / 123 | 7.36992 [7.2909–8.0969] | 4.0298 [3.99548–4.0576] | 1.829× | 2.148× |
| Numeric recurrence 256 | 0.0167844 [0.0164211–0.0170959] | 0.0157162 [0.015091–0.0161509] | 1.068× | 7.517× |
| Numeric recurrence 1024 | 0.027083 [0.0270537–0.0305937] | 0.0221811 [0.022065–0.0247367] | 1.221× | 2.794× |
| Scalar countdown 8192 | 0.141353 [0.140659–0.156815] | 0.117468 [0.116119–0.128806] | 1.203× | 1.174× |

Expression gains concern a still-materialized tagged producer and its selection
path, not fusion. Structural tree output includes both `warp` and `scan` workers.
The full candidate contains four changes, so combined actual-output gains are
not individually attributed by subtracting unrelated prototype medians.

Substantial gaps remain: the two BST points are **182.9× and 223.0× TypeScript**,
map churn **102.7× and 96.1×**, and the lexer points **84.4–89.3×**. Original raytrace
is **22.8×** with only a 0.74% median reduction and overlapping ranges, unlike the
active-ray points. Some unmodified or weakly affected workloads move little.
There is no average application-speed, overall parity or across-language claim.

## Module identity limits attribution

**23 of 45 points execute byte-identical baseline and candidate modules**, not
merely equal-size files. They include all lexer points, original raytrace,
local-fold and its variants, morning/evening programs, RLE, map/set, closures,
lists, BST, Unicode, map churn and record aggregation. Changed module hashes are
present at all 13 substantial-gain points in the preceding table. The full
aggregate records the hashes individually; distinct catalog points need not
represent distinct programs or modules.

Timing differences on identical modules are retained as observations but cannot
be attributed to compiler-emitted code changes. This applies equally to the
historical lexer's apparent 1.013× gain, BST32's 1.038× gain, evening's variable
1.501× gain, and the slower lexer/list/closure observations below. Their differing
process measurements expose this protocol's variability or role context; this
phase has not isolated its cause. Equal byte counts alone would be insufficient
for that conclusion, hence the SHA comparisons.

## Costs and unresolved variability

This table lists **every primary point whose candidate median is higher**.
Pairing is by recorded round; a median paired percentage is a different quantity
from a ratio of medians. The table does not hide a slower median because its
range overlaps or its paired median points in the other direction.

| Point | Median time change | Median paired time change | Slower pairs / 5 | Full ranges |
| --- | ---: | ---: | ---: | --- |
| `scalar-region-0` | +2.322% | +2.501% | 4/5 | Overlap |
| `complete-generic-row32` | +0.966% | +1.346% | 5/5 | Disjoint slower |
| `test-rle-roundtrip` | +2.055% | +0.997% | 3/5 | Overlap |
| `test-map-set-ops` | +10.298% | +1.731% | 3/5 | Overlap |
| `variation-editdist-0-17` | +0.006% | -0.374% | 2/5 | Overlap |
| `variation-lexer-6-17` | +1.172% | +1.369% | 5/5 | Disjoint slower |
| `variation-lexer-10-123` | +0.362% | -0.087% | 2/5 | Overlap |
| `variation-local-fold-128-0` | +0.796% | -0.193% | 2/5 | Overlap |
| `variation-local-fold-8192-123` | +6.823% | -0.244% | 2/5 | Overlap |
| `coverage-closures-64` | +0.451% | +0.075% | 3/5 | Overlap |
| `coverage-closures-256` | +0.779% | +0.779% | 5/5 | Overlap |
| `coverage-list-pipeline-128` | +0.936% | +0.985% | 5/5 | Disjoint slower |
| `coverage-map-churn-32` | +0.038% | +0.083% | 4/5 | Overlap |
| `coverage-record-aggregation-64` | +6.648% | -0.964% | 2/5 | Overlap |
| `coverage-record-aggregation-256` | +0.065% | +0.253% | 3/5 | Overlap |

The consistent small slower observations are generic-row32, lexer6/17, list128 and closures256.
The first three have disjoint slower ranges; closures256 loses all five pairings
with overlapping full ranges. List128 has +10.6–12.7% baseline and +11.0–12.4%
candidate half-drift, so even its small consistent difference retains a protocol
qualification. Of these four, only generic-row32 has changed generated bytes;
the three unchanged-module results are not claimed as optimizer regressions.

Map/set's +10.30%, fold8192's +6.82% and record64's +6.65% primary median changes
need a different interpretation from the consistent costs. Map/set loses three
pairings; fold and record lose two. Record64 paired changes are −8.63%, −0.964%,
−1.549%, +1.200% and +16.399%; its median paired change is −0.964%, despite the
higher candidate median. Both record roles span approximately 23–30.6 ms and
have downward half-drift reaching about 20%. This is uncertain, variable
behavior; neither an established 6.65% fixed penalty nor evidence of no cost.

The separately recorded `final-canary-confirm01` repeats the exact module hashes
for generic-row32, map/set, fold8192 and lexer6/17. It uses five rotated rounds,
1,000 ms warmup and a 300 ms timed block per role. Each has overlapping baseline
and candidate ranges in this second run. Medians and ranges below are milliseconds.

| Point | Phase37 ms [range] | Phase39 ms [range] | Median change | Slower pairs | Candidate / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| `complete-generic-row32` | 0.45153 [0.449423–0.490977] | 0.459007 [0.452032–0.498387] | +1.656% | 5/5 | 54.320× |
| `test-map-set-ops` | 1.66715 [1.60914–2.1301] | 1.68887 [1.59773–2.14517] | +1.303% | 4/5 | 74.583× |
| `variation-local-fold-8192-123` | 0.294097 [0.275002–0.334075] | 0.274615 [0.274037–0.290154] | -6.624% | 2/5 | 2.215× |
| `variation-lexer-6-17` | 41.3885 [41.2634–43.4453] | 42.2802 [41.7248–42.6131] | +2.154% | 3/5 | 89.931× |

The changed generic-row module is slower in **all five pairings in each run**:
+0.966% primary and +1.656% confirmation by ratios of medians, with median paired
penalties +1.346% and +1.509%. Confirmation Bend half-drift stays within about
−0.37% to +1.71%. We admit this small observed cost rather than explaining it away;
its source-level cause was not isolated.

For unchanged modules, map/set's primary +10.30% becomes +1.30%; large-fold's
+6.82% becomes −6.62%; lexer6/17's +1.17% becomes +2.15% with only three slower
pairings. Map/set still has large negative drift, and all confirmation ranges
overlap. These are useful variability checks, not recovered optimization gains
or proof that a penalty is zero. Neither the primary observations nor the
separate confirmation is discarded.

Other prominent drift limits are:

- Tree8 candidate half-drift is **−15.63% to −12.27%**; its baseline is near zero.
  Tree9 baseline is **+20.54% to +22.47%**, while its candidate is near zero.
- Active64 varies from **−39.63% to +50.76%** in the baseline and **−20.01% to
  +45.52%** in the candidate. Active256 candidate is **−27.49% to −2.79%**.
- Expression32 candidate is **−0.60% to +2.02%** and expression128 **−1.53% to
  +9.65%**. These are final observations, not the earlier, more variable screen.
- Morning/evening source programs have major internal drift in both roles;
  their small/variable aggregate changes do not support stable-gain claims.
  Single-repetition large lexer and original raytrace Bend samples have no
  two-half drift estimate; a missing value is not zero drift.

These limits qualify the reported gains even where ranges are disjoint.
Repeating an identical protocol solely to find a more convenient drift result
would not establish steady state.

## Compiler request and complexity costs

The [checked-request study](compiler-cost.md) passes all 27 expected-output byte
checks. Tree compilation rises **3.50%** by ratio of medians, from 1,696.055 to
1,755.497 ms, with disjoint ranges and all three pairings slower. Its median
paired increase is **8.79%**. Local and numeric request medians fall 1.60% and
1.68%, but overlap and include slower pairings. These three small sources do
not establish faster general compilation; request time remains **5.05–5.98× TS**.

[Source accounting](source-size-checked05.json) records **18,722 physical Bend
lines in 70 modules**, up **364 lines (1.98%)**, and **2,087 definitions**, up 42.
Nonblank lines rise 322 to 16,031. Types remain 71 and laws 640; the assembled
runtime remains byte-identical. The generated compiler API grows **35,303 bytes**
to 1,217,056. There are two additional bounded recursive admission forms and a
new case in an existing producer flag, not a new intermediate representation.
This is an explicit complexity increase, not a simplification result.

Tree generated code grows **7,010 bytes (7.68%)**, from 91,332 to 98,342; the
local source grows 188 bytes and numeric 74 bytes. Existing public fallbacks and
representation are retained, so source/module growth is a real price of the
private workers. Module size alone does not identify the reason for a timing
change.

## Admission status

| Gate or outcome | Current status |
| --- | --- |
| Checked05 module acquisition | Complete: 45 points, 23 source files |
| All-point primary output validation and execution | Pass: 45 points / 669 samples |
| Four new owner groups bound to checked05 | Pass; [closure](new-owner-gates.md) |
| Inherited owners and pre-install conformance | Pass; [integration](integration.md) |
| Same-byte adverse-point confirmation | Pass: four points / 60 samples, reported separately |
| Exact full execution aggregate | Pass: 45 primary points; 729 total samples with confirmations |
| Normal checked-request costs | Pass, with explicit tree cost above |
| Bend source and emitted-size accounting | Complete, with explicit growth above |
| Portable checked candidate archive | Pass: 45 points, 176 members, 1,326,874-byte archive; five-point / 45-sample smoke passes in 17.444 s |
| Installation and ordinary/relocated CLI verification | Pass: installed; all 42 CLI checks; [final audit](final-conformance/gates.md) accepts 15 groups and 227 source pairs |

The [portable candidate](../../selfhost/tools/performance/phase39/current/manifest.json)
contains actual checked compiler output and verified receipts. Its five-point
smoke is an auxiliary portability check, not another primary timing group.

Retain the exact private scalar counter, full-root proof sharing, two-child
structural worker and unary producer. Their substantial improvements on changed
modules, independent source-shape controls and full semantic closure justify the
measured generic-row and tree-compilation costs and 364-line growth. Do not retain
callback specialization: its separate prototype did not beat the original path.

This decision makes no conformance-increase or simplification claim. Shared
frontend/backend failures remain explicit in [integration](integration.md).
All final source bytes were frozen before primary measurement; there is no tuning
after these exposed broad results. Remaining list/map/lexer/BST gaps are future
work, and identical-module noise argues for an unchanged-byte control in future
experiments. Profiles remain diagnostic and do not enter any clean execution ratio.
