# Compiler-image latency method

The final clean comparison shows a large improvement in the new direct B2 image
on Evening and lexer. B1 first-request windows remain essentially unchanged; its
later requests improve on Evening and regress on lexer. These are two separate
changed-source comparisons, not an overall compiler speedup. Earlier diagnostic
pilots are retained below. [Replay commands and binding schema](../../selfhost/tools/performance/phase58/latency/README.md)
describe the concrete tool.

The first comparison holds the Bend compiler source and runtime/driver inputs
fixed: the genuine Phase56 B2 image (`3f652f7d…`) versus the recorded object-key
syntax derivative (`83224c06…`). The derivative changes 7,297 computed constant
string object keys to ordinary quoted keys, according to its separate AST and
inverse-transformation receipt. It is a diagnostic image, not a checked source
build or an installed compiler.

The pilot prepares only lexer and these two roles, then measures two fresh
processes. Each records ordinary API loading, the first checked direct-library
request, and one further ordinary request. A three-round, three-later-request
follow-up is available if the pilot gives useful evidence. CPU and allocation
profiles are separate processes; allocation includes objects collected by GC.
Twenty to sixty seconds is an execution ceiling for a small prepared comparison,
not a guaranteed completion time or a required sampling duration.

Each compiler must first emit a checked module that passes the complete catalog
oracle. Every measured request must reproduce its own prepared bytes. Different
compiler images may legitimately emit different JavaScript, so the method records
cross-role text equality without requiring it. A genuine new B1/B2 comparison can
use explicit `changed-source` bindings; that result would combine source and
code-generation changes. Fixed-subject emission remains available when the new
generator's split-emission receipt identifies the old subject independently.

The tool preserves Phase57 timing and resource boundaries, corrected signed CPU
sample accounting and collected-object allocation sampling. It changes only
candidate binding, workload size and output confinement. The method receipt records
every replacement and parent/output hash. Historical evidence remains untouched.

Scope limits remain important: excluded provenance work can affect pre-timing GC
state; saving the first output occurs before later requests; warmed requests may
still improve; a one-round pilot cannot establish uncertainty or a general compiler
throughput gain. A syntax-only result motivates a checked source implementation
and independent semantic qualification rather than qualifying that implementation
by itself.

## First fixed-source syntax pilot

`selfhost/build/phase58/fields-latency-pilot01/report.json` completed successfully
in 36.904 s, including 20.314 s of separate preparation. Report SHA-256:
`37c03f59e6ffbff7c7d9247cb80df425f74b08737f7893f255635a6aa2c32819`.
Both images passed the full lexer oracle and emitted identical 28,452-byte modules
(`7391f503…`). Each measured process completed its first and one later ordinary
request. This pilot did not include TypeScript.

| Observation, ms | Original B2 | Literal-key derivative | Original / derivative |
|---|---:|---:|---:|
| Ordinary API load | 98.923 | 99.360 | 0.996× |
| First library request | 3,090.103 | 2,259.198 | 1.368× |
| Host import + API load + first request | 3,193.228 | 2,362.773 | 1.351× |
| Single later library request | 2,073.656 | 1,576.144 | 1.316× |
| Complete measured worker process | 7,821.621 | 6,575.550 | 1.190× |

The first request used 26.89% less time and the later request 23.99% less. This is
one process per image in baseline-first order: it supports a rotated repeat, not
an uncertainty estimate, stationary rate, or a measured production-backend gain.
API-load time did not explain the observed difference. Peak process-tree RSS was
535,515,136 versus 533,209,088 bytes; this pilot does not establish an allocation
reduction. A separate collected-object allocation profile is prepared.

## Repeated fixed-source syntax screen

`selfhost/build/phase58/fields-latency-confirm01/report.json` completed in
66.987 s. It reused the pilot's independently checked preparation and ran six
fresh processes: three per image, each with a first request and three later
requests, for 24 requests. Order was baseline/candidate, candidate/baseline,
baseline/candidate. Every request retained the same 28,452-byte lexer output.
Report SHA-256:
`a0cd762fd2c53264f5abdabd0318f06357d3988231c0ca56f7525f1174bb7fd5`.

| Metric, ms | Original B2 median [min–max] | Literal-key derivative median [min–max] | Original / derivative |
|---|---:|---:|---:|
| API load | 99.222 [98.679–100.457] | 99.175 [98.877–99.482] | 1.000× |
| First request | 3,044.115 [3,036.196–3,047.581] | 2,270.266 [2,265.399–2,272.795] | 1.341× |
| Import + API load + first request | 3,147.511 [3,139.059–3,152.264] | 2,373.325 [2,368.765–2,376.439] | 1.326× |
| Median of each process's three later requests | 1,778.884 [1,749.953–1,787.294] | 1,377.905 [1,361.719–1,510.834] | 1.291× |
| Complete worker process | 11,232.571 [11,110.041–11,452.895] | 9,190.408 [9,170.564–9,622.610] | 1.222× |

The repeated first-request median used 25.42% less time; the median of later
request medians used 22.54% less. These are descriptive repeated-window results,
not confidence intervals or steady-state estimates. Both images still improved
within every process. The later-request sequences, in milliseconds, were:

| Round | Original B2 | Literal-key derivative |
|---|---|---|
| 0 | 2,072.73 → 1,749.95 → 1,572.21 | 1,570.87 → 1,377.90 → 1,232.61 |
| 1 | 2,085.11 → 1,778.88 → 1,598.96 | 1,577.53 → 1,361.72 → 1,231.84 |
| 2 | 2,075.53 → 1,787.29 → 1,719.14 | 1,659.06 → 1,510.83 → 1,331.88 |

Median peak tree RSS was 555,581,440 bytes for the original and 556,929,024 bytes
for the derivative. It does not show a peak-memory reduction. This fixed-source
syntax experiment supports the corresponding checked backend change; it does not
itself measure a new production B2 or attribute the mechanism to allocation, V8
inlining, or a specific optimized-code instruction.

## Checked-source follow-up binding

The next pilot compared the genuine `checked-fields01` and
`checked-lookup01` B1 images with a separate changed-source binding. Their actual
`checked: true, strictExact: false` state is retained, so the successor method
permits measurement before full driver qualification while still requiring the
complete lexer oracle. It neither relabels them as fully qualified nor predicts
the effect on their eventual B2 images. Own-source library emission is outside
this small two-process workload; existing separately bounded self-check and
emission tools retain that responsibility.

`selfhost/build/phase58/lookup-latency-pilot01/report.json` passed in 29.360 s,
including 16.292 s preparation. Its two fresh processes completed four requests;
both images passed the lexer oracle and emitted identical 28,388-byte modules
(`39800331…`). Report SHA-256:
`fcdb4d9ddf91d39193741dfc4009c22d9008c2bcc9df403ed1cf423f266c01d8`.

| Observation, ms | Fields-only B1 | Fields + lookup B1 | Before / after |
|---|---:|---:|---:|
| First request | 1,808.397 | 1,786.534 | 1.012× |
| Import + API load + first request | 1,860.437 | 1,839.627 | 1.011× |
| Single later request | 1,174.785 | 1,181.704 | 0.994× |

This one-round pilot does not establish a lexer improvement from the lookup
change: the first request used 1.21% less time while the later request used 0.59%
more. It also does not test the large own-source emission request where Phase57
observed constructor-search and missing-record construction costs. That request
needs its own complete emission and profile evidence; the lexer result should not
be substituted for it or pooled with the B2 syntax experiment.

The reviewed [saved-data reader](../../selfhost/tools/performance/phase58/latency/summarize.py)
independently re-read both completed screens, joined every worker to its
preparation, source and output oracle, recomputed the statistics, and rehashed
its inputs. The result is
`selfhost/build/phase58/latency-analysis01/report.json`, SHA-256
`8e182a6d413f831cb4b89e0cfc63eeb8a2ab44c03547352721971ddeb5b0b396`.
This was data-only analysis, with no compiler or generated-program execution.

## New genuine B2: first changed-source pilot

`selfhost/build/phase58/reach-b2-latency-pilot01/report.json` passed two fresh
lexer processes and four ordinary requests in 35.375 s, including 20.237 s of
preparation. The comparison is the prior genuine B2 (`3f652f7d…`) against the
new genuine B2 (`e7a6117e…`) compiled from changed Bend source. Report SHA-256:
`706184a3500a3b0d302d2aafb9a476ddb84626d9cc620c0ba89c28c94a306533`.

| Observation, ms | Prior B2 | New B2 | Before / after |
|---|---:|---:|---:|
| API load | 101.833 | 173.719 | 0.586× |
| First request | 3,184.922 | 1,353.164 | 2.354× |
| Import + API load + first request | 3,291.029 | 1,531.084 | 2.149× |
| Single later request | 2,221.236 | 755.333 | 2.941× |
| Complete worker process | 8,108.163 | 4,976.585 | 1.629× |

Both full lexer oracles passed. Their outputs differ: 28,452 bytes before and
28,388 after, each exactly reproduced within its own role. First-request time
fell 57.51%, or 53.48% including import and API load; the single later request
used 65.99% less time. These one-round observations motivate the final comparison
but do not isolate lookup, fields, scalar lowering or choice lowering.

The compiler image grew from 3,896,951 to 8,671,962 bytes. API-load time increased
70.59% in this observation even though compilation was faster. Peak tree RSS was
537,018,368 versus 491,679,744 bytes; one sample cannot establish a general memory
change. The separate SCC-sharing diagnostic below holds this new source fixed;
its result does not qualify the corresponding checked source implementation.

## Fixed-source SCC-sharing pilot

`selfhost/build/phase58/scc-latency-pilot01/report.json` passed in 27.725 s,
including 16.040 s preparation. It compared reach01 B2 (`e7a6117e…`) with the
exact-loop-body-sharing diagnostic (`cea4b818…`), using the same compiler source,
driver, runtime and Base. Two fresh measured processes completed four requests,
one first and one later request per image. Both passed the full lexer oracle and
emitted identical 28,388-byte modules (`39800331…`). Report SHA-256:
`0c6bd4e03b76a14fecd180f9472e49ec1c021dc60610ea92c6201abc17916a08`.

| Observation, ms | Unshared reach01 B2 | Shared-body diagnostic | Before / after |
|---|---:|---:|---:|
| API load | 174.890 | 95.616 | 1.829× |
| First request | 1,355.766 | 1,377.641 | 0.984× |
| Import + API load + first request | 1,534.840 | 1,477.522 | 1.039× |
| Single later request | 749.915 | 750.518 | 0.999× |
| Complete worker process | 4,896.723 | 4,838.109 | 1.012× |

The diagnostic image shrank from 8,671,962 to 3,812,483 bytes, **56.04% less**.
API-load time fell **45.33%**, close to half. The first request used 1.61% more
time; the single later request used 0.08% more, effectively flat in this pilot.
Including import and API load, the first-request window used 3.73% less time.
These observations support image-size and startup benefits; they do not show a
later-request throughput gain. One process per role cannot establish precision,
stationarity or a general memory benefit. Peak tree RSS was 493,449,216 versus
486,248,448 bytes in these processes.

The exact runtime prefix, retained loop bodies and inverse source transformation
are recorded in the diagnostic receipt. They do not substitute for checking the
Bend implementation, generating its genuine B2, or running its broader controls.
`checked-shared01` has now produced its genuine 3,815,480-byte B2
(`b7c5752d…`). Its final two-case, three-round comparison with TypeScript is
reported below. The genuine-image method04 measures those B1 and B2 roles without
a diagnostic-role adapter.

The frozen saved-data reader independently checked the new-B2 and SCC pilots in
`selfhost/build/phase58/latency-analysis02/report.json`, SHA-256
`f515de8804f460da02409bc1e9ca9d5e380097fd2bf909a282ec8b759092fe68`.
This analysis re-read the worker, preparation, source and oracle bindings and
recomputed all reported statistics without executing a compiler.

## Final measurement plan

The reviewed, data-only recipe is
`selfhost/build/phase58/comparison-shared01/final-matrix.json`, SHA-256
`81ac58460ddc4665cca1e729842a7443d47d069a15320897ecc1e305e3121306`.
Its sibling `final-matrix.txt` contains exact commands. It binds the prior
string01 images to the actual checked-shared01 B1 (`eddce750…`) and genuine B2
(`b7c5752d…`), with separate changed-source B1 and B2 comparisons.

Each clean matrix covers Evening and lexer, old/new/TypeScript, and three rotated
rounds: 18 fresh processes with a first and three later ordinary requests, or 72
requests. Each matrix prepares its three private images once, outside those
measurements. Separate lexer allocation and CPU campaigns use all three roles,
three ordinary warm requests and a roughly five-second profile window. Allocation
includes objects collected by minor and major GC; estimated bytes per profiled
request are reported separately from peak RSS and latency.

The plan also requires fresh prior-B2 and candidate-B2 own-source emissions under
the same method02, once per image, with matching clocks and resource ceilings.
Both require their own complete B2/B3 byte equality. Different source remains an
explicit limitation; a change in these requests is not a measurement of lookup
in isolation. No high-rate full-source CPU capture is part of this clean pair.

Both clean matrices now pass. Allocation, CPU and paired own-source observations
remain separate and are reported only when their saved receipts complete.

## Final clean results

[Clean latency chart](figures/compiler-latency.svg) · [PNG](figures/compiler-latency.png)

Both matrices passed all 18 fresh processes and 72 requests: **36 processes /
144 requests** across B1 and B2. Each role and case has three processes, each
with a first request and three further ordinary requests. The source is loaded
and checked through the ordinary driver each time; no persistent inspector is
used. Every request reproduced its role’s prepared output bytes, and preparation
passed the complete catalog oracle for each image. JavaScript text may differ
between roles because the compiler source and generated syntax changed.

The two clean campaign walls sum to **292.675 s** (B1 137.659 s; B2 155.016 s).
Separate preparation campaigns took 22.001 s and 25.141 s. Those preparation
costs are excluded from the request statistics. B1 and B2 each use the
TypeScript processes measured in their own campaign; denominators are not
borrowed from another run.

| Image | Old API | New API | Old source → new source |
| --- | --- | --- | --- |
| B1, checked upstream-derived image | `12861977…` | `eddce750…` | `5356ec99…` → `a4ad6717…` |
| B2, direct self-emitted image | `3f652f7d…` | `b7c5752d…` | `5356ec99…` → `a4ad6717…` |

### Import, API load and first request

This combined window includes TypeScript’s eager compiler import and Bend’s
explicit ordinary API load. Values are medians [observed min–max] in milliseconds;
ranges are not confidence intervals.

| Image / case | Old | New | TypeScript | Old / new | New / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| B1 / Evening | 2,578.04 [2,571.94–2,592.83] | 2,575.52 [2,567.63–2,577.85] | 845.31 [841.14–850.82] | 1.001× | 3.047× |
| B1 / lexer | 1,654.78 [1,650.75–1,655.87] | 1,664.17 [1,641.63–1,666.80] | 574.05 [572.48–575.42] | 0.994× | 2.899× |
| B2 / Evening | 4,609.19 [4,590.04–4,923.04] | 1,796.74 [1,785.10–1,847.01] | 840.62 [831.47–842.66] | 2.565× | 2.137× |
| B2 / lexer | 2,938.60 [2,904.09–2,939.73] | 1,335.06 [1,324.64–1,347.08] | 575.55 [573.05–591.43] | 2.201× | 2.320× |

### Later ordinary requests

The statistic is the median of three process medians, each formed from three
later requests. It is not a stationary throughput estimate.

| Image / case | Old | New | TypeScript | Old / new | New / TS |
| --- | ---: | ---: | ---: | ---: | ---: |
| B1 / Evening | 1,735.50 [1,663.50–1,738.64] | 1,610.83 [1,604.32–1,629.37] | 393.45 [390.50–403.33] | 1.077× | 4.094× |
| B1 / lexer | 889.96 [878.05–894.62] | 930.00 [865.57–931.29] | 236.97 [234.01–243.19] | 0.957× | 3.924× |
| B2 / Evening | 3,053.76 [3,051.79–3,060.83] | 864.15 [842.81–874.34] | 410.28 [400.69–415.19] | 3.534× | 2.106× |
| B2 / lexer | 1,616.58 [1,615.26–1,632.13] | 557.62 [556.58–587.16] | 240.29 [236.21–243.40] | 2.899× | 2.321× |

New B2 reduces the combined first-request window by **61.02% on Evening** and
**54.57% on lexer**. Its later-request statistic falls **71.70%** and **65.51%**,
respectively. The remaining B2/TypeScript ratios are about **2.14–2.32×** for
combined first windows and **2.11–2.32×** for these later windows. Neither
TypeScript parity nor a universal compiler-speed claim follows from two inputs.

B1 shows **−0.10% / +0.57%** changes in the combined first window
(Evening / lexer), and **−7.18% / +4.50%** in the later-request statistic.
The lexer regression is retained explicitly. These observations do not establish
an overall B1 improvement, and are not evidence that the large B2 gain transfers
automatically to the default checked image.

First-request-only medians also improve for B2: Evening 4,519.24→1,706.02 ms
and lexer 2,848.54→1,248.63 ms. API-load medians are 85.89→86.73 ms and
86.25→82.55 ms, so startup alone does not explain the request improvement.
B1 first-request-only medians are nearly unchanged: 2,523.69→2,520.89 ms and
1,610.37→1,608.56 ms.

All B2 processes continue warming across their three later requests. For the
new B2, the median at each ordinal falls from 1,202.97 to 647.84 ms on Evening
and from 682.34 to 493.40 ms on lexer. These ordinal endpoints differ from the
process-median statistic above. The full sequences remain in the saved summary;
the short window does not locate an asymptotic rate. Excluded provenance work,
private preprimed Base caches and first-output saving can influence pre-timing
and later GC/tiering state. Three rotated processes do not provide a significance
test or isolate the contribution of each source change.

Peak tree RSS medians do not establish a general memory decrease: B2 Evening
is 588,128,256→584,577,024 bytes, while lexer is
552,886,272→575,758,336 bytes. Allocation samples are acquired separately and
must not be inferred from these RSS values or generated code size.

The frozen saved-data reader rehashed the inputs, joined every worker to its
prepared image, source and oracle, and recomputed every statistic. Evidence:

| Artifact | SHA-256 |
| --- | --- |
| `comparison-shared01/b1-clean/report.json` | `6b54417a7b03d14d7ea31d728231a1c2a64438c69e6d36279eb1b0bbb6b91f9e` |
| `comparison-shared01/b2-clean/report.json` | `8904e8dd5bed1df80523e6af3734727f9aea1c1d0457bc39e04307af09a75445` |
| `latency-final-clean01/report.json` | `abeca828f5a2242c52ed2d9cbc10d8cbaa5c711116b153ff773bd8f2f380cefe` |

All paths in this table are under `selfhost/build/phase58`. These clean results
do not claim release promotion, wider program performance or completed profiling.

## Final lexer allocation and CPU profiles

[Allocation chart](figures/compiler-allocation.svg) · [PNG](figures/compiler-allocation.png)

All six allocation and six CPU processes completed their output checks. These
are separate diagnostic processes after the first and three later ordinary
requests; their times do not enter the clean tables. Allocation sampling uses a
128 KiB interval and includes objects collected by minor and major GC. Each
profile performs as many complete requests as its roughly five-second window
requires, capped at 32. TypeScript reached the 32-request cap before five seconds
in all four profiles; this limit and the actual call counts remain explicit.

Decimal MB below means 1,000,000 bytes. Values are **sampled cumulative allocation
per profiled request**, not peak RSS, retained heap, exact allocation counts or
three-round statistical estimates. Each role has one allocation profile.

| Comparison | Old MB/request | New MB/request | TS MB/request | Old / new | New / TS | New allocation change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| B1 / lexer | 924.128 | 905.075 | 59.883 | 1.021× | 15.114× | −2.06% |
| B2 / lexer | 2,158.688 | 232.319 | 58.647 | 9.292× | 3.961× | −89.24% |

B1 old/new/TS captured 6/6/32 requests and 5,544.769/5,430.452/1,916.260 MB
in total; B2 captured 3/12/32 requests and 6,476.065/2,787.827/1,876.694 MB.
Division by actual completed requests gives the table. The B2 reduction is much
larger than the B1 change, consistent with the clean latency distinction. This
combined-source comparison does not assign the reduction to one pass.

All six allocation profiles warn that sample and tree estimates differ. The
absolute difference is 0.00077–0.05048% of the sample denominator. Five profiles
also have one or two samples referring to absent tree nodes: 0.137–0.693 MB per
whole capture, at most 0.02402% of its sample total. Their weights remain included
and explicitly unattributed. Per-node discrepancies and complete warnings are
preserved; their cause is not inferred. These accounting quantities describe the
recorded discrepancy, not a bound on profiler sampling error.

The new B2's largest exclusive allocation frames are:

| Actual generated frame | Sampled MB/request | Share of sampled allocation |
| --- | ---: | ---: |
| `$jd$subst$scc` | 25.403 | 10.93% |
| `$jd$index_95_remove` | 15.155 | 6.52% |
| `$jd$String_46_contains_46_if$scc` | 11.171 | 4.81% |
| `$jd$index_95_insert` | 9.833 | 4.23% |
| `$jd$index_95_node` | 9.800 | 4.22% |
| `$jd$lookup$scc` | 9.078 | 3.91% |
| `$jd$jd_95_reach_95_refs_95_unique$scc` | 7.946 | 3.42% |

A shared `$scc` frame identifies its dispatcher, not one uniquely attributed
source member. Percentages use exclusive self weights; inclusive frames are not
added. B1 still attributes about 201.493 MB/request, or 22.26%, to `$sk_char$`
(old: 205.121 MB/request, 22.20%). These observations motivate targeted source
and representation inspection, not an assumption that a frame's allocations
are all unnecessary.

CPU uses separate 1 ms sampling, with old/new/TS request counts of 6/7/32 for B1
and 4/13/32 for B2. All six timestamp-weighted views were admitted with no negative
deltas or correction. Sample counts span 2,298–5,099; the recorded profile-duration
residuals span 255–1,111 µs. These are diagnostic weights, not clean request times.

B1's `run_loop` retains 18.52%→17.83% exclusive CPU self weight. Old B2 attributes
15.19% to `run_loop` and 9.54% to `kt`; neither is among new B2's top ten frames.
The new B2's three visible driver functions `validateSpanCache`, `readBaseCache`
and `validateSpanBook` account for 10.23%, 8.16% and 6.59%, respectively, about
24.97% combined exclusive self weight. The ordinary request includes this driver
work; it must not be mislabeled as direct-emitter work or dropped from the cost.
The leading named generated frames are the substitution dispatcher (2.32%),
index-find dispatcher (2.24%) and lookup dispatcher (1.92%).

New B2's GC share is 10.75%, compared with 4.45% for old B2. That larger share
does not establish more GC time per request: the denominator and number of
requests differ substantially. The same warning applies to increased driver
shares after other costs shrink. TypeScript work spans `bend.ts` and `comp.ts`;
the profiler's one-module category is not the whole TypeScript compiler.

Substitution and persistent index transport are supported next investigation
sites. Any substitution bypass needs the existing structural/provenance proof:
absence of a substituted variable alone does not prove a no-op, because
`core_rebuild` can canonicalize an App and `core_apply_span` can beta-reduce it.
A new host-status key-reuse micro-optimization has not been measured here and is
deferred. These profile results authorize neither a new source change nor a
claim that a proposed optimization will remove all attributed work.

The frozen saved-data summaries and profile presentations are:

| Artifact under `selfhost/build/phase58` | SHA-256 |
| --- | --- |
| `latency-final-allocation01/report.json` | `d5aa950419c17d8cf24182b294abd3c7a9de9ff04d0f50f4502112c5ae37937c` |
| `allocation-presentation01/report.json` | `aa9fa63f484fe1e43da3340f955f1cd79c15ade73ec7cda534867d3f9dace219` |
| `latency-final-cpu01/report.json` | `c08832dc58ccbe9f9d26e77ed0b16659d07d19c0312224d11c56a44f445cbee7` |
| `cpu-presentation01/report.json` | `796d2e7f3d80f142a2bf3b5decd7fe78752dadcc51b01d9215a361b06ad385e9` |

Each presentation has a sibling Markdown report with exact API/upstream identities,
source positions, per-process totals, top ten frames and complete warnings. The
reader checks actual raw sample arrays and rehashes all consumed identities.
Own-source emission allocation is a separate planned workload; these lexer
profiles cannot stand in for that large constructor-search workload.

## Matched-method own-source clean emission

Both fresh runs used the same frozen emission-method02, resource limits and
clock boundaries. Each genuine B2 compiled its own compiler source to B3, with
complete per-image output-byte equality. The result is one observation per image
with changed source, not an isolated lookup experiment or repeated throughput
estimate. It uses the inherited checked-source pipeline; it does not perform a
new full compiler source typecheck inside the measured emission.

| Observation | Prior B2 | New B2 | Before / after |
| --- | ---: | ---: | ---: |
| Complete worker time, seconds | 223.475 | 36.018 | 6.204× |
| Emitted reachability, seconds | 83.376 | 8.438 | 9.881× |
| Unsplit library emission, seconds | 100.522 | 8.418 | 11.942× |
| Selected definitions / entries | 3,054 / 3,167 | 3,093 / 3,207 | — |
| Emitted B2/B3 image bytes | 3,896,951 | 3,815,480 | — |

The measured complete worker time falls **83.88%**. This is the matched-method
pair, rather than a ratio against the older 250-second reproduction record.
Emitted reachability renders definitions to collect dependency metadata; unsplit
library emission includes call facts, definition printing and export wrappers.
Their names do not isolate constructor lookup or SCC rendering costs. Source
loading, specialization and other stages also change. No individual-pass share
of this gain is inferred from the combined result.

Both external supervisors completed with exit code zero under the original
420-second / 2 GiB tree-RSS limits. Their process walls were 223.996 and 36.575 s;
peak tree RSS was 1,108,570,112 and 1,145,380,864 bytes. Faster emission therefore
does not imply a lower measured peak memory footprint. The old source is
`5356ec99…`, the new source `a4ad6717…`; exact output identities remain
`3f652f7d…` and `b7c5752d…`, respectively.

| Artifact under `selfhost/build/phase58` | SHA-256 |
| --- | --- |
| `comparison-shared01/own-source-baseline/report.json` | `8ce25e2387cb61a0d727ce54c35a7a515c8ef865c2856d435920c639c55f6f5c` |
| `comparison-shared01/own-source-candidate/report.json` | `c097f31ba35fecbc6c2ef7dbd6c41382eb33a2c4a621cc5029c1ef227214daf2` |
| `latency-final-emission-clean01/report.json` | `152b9339e607a3b577d365387e844936143d6fdd533b007b6ecad5648eb2a5c6` |

The reviewed data-only extension separately schedules old/new own-source
allocation at 1 MiB sampling and new-image CPU at 25 ms, with one capture per
emitted-reachability and unsplit-library stage. It preserves both GC inclusion
flags, resource limits and complete output equality. Those diagnostic results
remain separate from these clean clocks; the preserved baseline failure is
recorded below.

### Baseline own-source allocation capture: resource-limit failure

The optional baseline allocation process was stopped by the external tree-RSS
guard after **124.707 s**. Its emitted-reachability call had returned after
87.763 s under instrumentation, but the process was stopped while exporting the
profile. The raw `profile.heapprofile` is zero bytes; both worker and profiler
receipts remain incomplete/failed. There is **no usable baseline own-source
allocation total, no completed emission from this process, and no allocation
ratio against the candidate**. The successful clean emission above is a separate
run and remains valid.

The supervisor recorded a 2,376,015,872-byte tree peak against its
2,147,483,648-byte limit; polling can observe a peak beyond the configured limit.
Minimum available system memory was 25,734,656,000 bytes. The recorded stop is
`tree-rss-limit`, exit −9, rather than a system out-of-memory event. No higher-memory
or higher-rate retry is planned. The candidate allocation and 25 ms CPU captures
subsequently passed under the original bounds. They provide absolute attribution
only, as reported next.

Preserved receipts under `comparison-shared01`:

| Failed artifact | SHA-256 |
| --- | --- |
| `own-source-baseline-allocation/report.json` | `b87e529505a6dc5a91ff0f3d1acb2457aeb48c199a531c329e06aa59f38ad93e` |
| `own-source-baseline-allocation-supervisor/run.json` | `59784ef6f2d03d8e0b711828f6008981c358aa01d3257fcf8a7a8c371d1919e1` |

The progress log records the returned call, while the partial profiler receipt
records no completed capture. Neither is converted into a successful profile.

### Candidate own-source allocation and CPU attribution

Both candidate diagnostic processes passed complete B2/B3 byte equality with
`b7c5752d…`. Their worker durations were 53.893 s for allocation and 38.685 s for
CPU. These include instrumentation and profile export; they are not clean speed
measurements. Each captured emitted reachability and unsplit library exactly
once. Other stages were not allocation-profiled.

| Candidate stage | Allocation samples | Estimated cumulative GB | Sampling interval |
| --- | ---: | ---: | ---: |
| Emitted reachability | 19,435 | 20.453 | 1 MiB |
| Unsplit library | 15,123 | 15.869 | 1 MiB |

GB is decimal, and these estimates include collected objects. They do not mean
that this much memory was simultaneously live. There is no valid old/new
own-source allocation ratio because the baseline capture failed. Both completed
profiles retain sample/tree estimate disagreements: 455,968 and 184,168 bytes,
respectively (0.00223% and 0.00116% of sample totals). Neither has samples pointing
to absent nodes. These small recorded discrepancies are not profiler error bounds.

The largest exclusive allocation frames are shared dispatchers. Their exact
emitter-owned member metadata in this B2 is:

| Generated dispatcher | Ordered cases / actual source members | B2 line |
| --- | --- | ---: |
| `String.contains.if$scc` | 0: `String.contains.if`; 1: `String.contains` | 594 |
| `jd_reach_refs_unique$scc` | 0: `jd_reach_refs_unique`; 1: `jd_reach_marker`; 2: `jd_reach_marker_done` | 58,670 |

The table abbreviates only the injective `$jd$` name encoding; the recorded
receipt retains complete generated names and exact header bytes. The first
component has no unrelated selector. Its false case resumes substring search;
the search case destructures a character and tail, tests `starts_with` on their
reconstruction, and advances the tail. The second component scans physical
line-start `JD_REF` markers, accumulates marker text, resolves the name and updates
the persistent seen index before continuing. These are static source facts,
not proof that every case contributes equally to allocation.

| Exclusive generated component/frame | Reach GB / share | Unsplit GB / share |
| --- | ---: | ---: |
| `String.contains.if$scc` | 10.660 / 52.12% | 10.706 / 67.46% |
| `jd_reach_refs_unique$scc` | 7.134 / 34.88% | 0 sampled |
| `index_remove` | 0.574 / 2.80% | 1.126 / 7.10% |
| `subst$scc` | 0.396 / 1.94% | 0.900 / 5.67% |

The raw allocation tree adds useful caller evidence: the largest recorded
`String.contains.if$scc` paths pass through `jd_body_bound`, then body/choice
emission. The frozen source's `jd_body_bound` explicitly checks
`String.contains(body, jd_use(id))` before adding a local declaration. This ties
substantial recorded allocation to use-marker text checks during emission.
The reach-scanner paths pass through `jd_reach_visit`, context and selected-reach
entry. This supports investigation of emitted-text scanning and suffix transport;
it does not identify a unique component member, object type or individual string
operation as the allocator.

The data-only caller mapper groups exclusive samples by the nearest eight
recorded callers. It also computes an ancestor union for each selected component,
counting each raw sample at most once within that union. Different component
unions can overlap and are not added. The published allocation percentages above
remain exclusive self weights. Exact URLs and one-based positions are retained.

The 25 ms CPU capture has an important split outcome. Emitted reachability's
weighted view was admitted: 379 samples, no negative timestamp increments and
no correction. Its largest named generated self frames are the
`String.starts_with.if` dispatcher (19.70%) and `j_find_ctor` dispatcher (13.14%);
GC is 6.63%, `String.contains.if` 5.65% and `index_remove` 3.67%. These are
coarse diagnostic sample weights, not clean stage-time decompositions.

**Unsplit library's timestamp-weighted CPU view was refused.** The raw deltas
contain −10, −1 and −1 µs. Although total correction would be only about 1.31 ppm,
the −10 µs increment exceeds the fixed per-sample 2 µs policy. The unchanged
profiler therefore preserves a count-only view: 3,453 samples, of which 89.69%
name `jd_calls_rows`. That is not an 89.69% time share, and the count concentration
is not accepted as a CPU bottleneck diagnosis. No threshold was relaxed and no
retry was requested. Exact raw timestamps and the refusal remain in the report.

| Artifact under `selfhost/build/phase58` | SHA-256 |
| --- | --- |
| `comparison-shared01/own-source-candidate-allocation/report.json` | `088b307d7a6b1859d05a284343a84ef3b46f1f0dd5448c26d9c7f62319912d84` |
| `comparison-shared01/own-source-candidate-cpu/report.json` | `413d4452f1d9adc46fdc250359c00595f3d1c3455f704f8f6973e02dc87cd695` |
| `latency-final-emission-profiles01/report.json` | `c75c7f1f72cd47ef2631d67e183217a3c1bc4a6603a3a014cb45349584acd3b6` |
| `emission-callers01/report.json` | `2b1991db7ee4481b4225d419bc870cb799c7427fce5ef54692dabdd6589ced70` |

## Next tests suggested by the measured paths

The two workloads now point to different tests. For ordinary small requests,
fresh driver validation, substitution and persistent index transport remain
visible. First test a narrowly proved reuse or representation change on the
same lexer/Evening requests. A cached validation result must bind all source and
cache facts it covers; a substitution bypass must preserve `core_rebuild`
canonicalization and beta reduction, not merely prove that a variable is absent.
The profile is a place to start inspection, not proof that these checks are
redundant.

For complete compiler emission, use-marker searches and reach-marker scans are
concrete callers of string traversal. The cheapest diagnostic would compare an
exact, bounded string-operation specialization or reconstruction elimination
inside those paths, keeping the ordinary source behavior as its oracle. A
production native `contains`/`starts_with` rule must prove the canonical native
owner and preserve empty strings, Unicode, lone surrogates, evaluation order,
partial application and refusal behavior. Plain JavaScript `includes` is not
established equivalent: it searches UTF-16 offsets, while the current source
traversal advances whole characters. A low-surrogate needle within an astral
character is a concrete boundary to test; a high-surrogate-only prefix also
checks the match's ending boundary. The pinned Base source (`c742fae9…`,
`String.starts_with` at line 1,899 and `String.contains` at line 1,925) explicitly
makes an empty needle true for either operation, including an empty haystack.
An empty haystack with a nonempty needle is false. Those results are source
facts, not assumptions borrowed from JavaScript. A boundary-respecting search
or a proved ASCII-needle fast path could be tested generally. The ASCII
use-marker workload supplies a narrow diagnostic, not permission for a
benchmark-specific rule.

An alternative is scalar String-origin tracking that forwards a proved original
string through its immediate head/tail reconstruction, or a structured emission
result carrying use/reference facts instead of repeatedly scanning generated
text. The origin rule would extend the already proved U32 reconstruction pattern:
only unchanged components of one exact nonempty native String view may reconstruct
the original primitive. In the observed direct output the reconstruction is
`head + tail`; the proposed replacement retains required view/evaluation prefixes
and effect order. It needs checked layout and source-origin facts, plus negative
altered-head, altered-tail, mixed-origin, capture and throw controls. It would
preserve Unicode by identity rather than change substring semantics. This rule
has not been implemented or measured.

Each proposal needs a small causal test and exact demand/dependency controls
before implementation. Neither sampled allocation share nor a shared frame's
weight is a predicted speedup. The host-status key-reuse proposal is still
unmeasured and deferred; the refused unsplit CPU weights provide no reason to
change that.
