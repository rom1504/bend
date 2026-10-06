# Compiler-image latency method

The Phase58 method tests a small hypothesis before committing to a full compiler
reproduction or a wide performance campaign. The first two-process pilot completed;
its limited observations appear below. [Replay commands and binding schema](../../selfhost/tools/performance/phase58/latency/README.md)
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
(`b7c5752d…`); its final two-case, three-round comparison with TypeScript has not
yet been measured here. The
existing genuine-image method04 can compare those final B1 and B2 roles without
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

These are prepared commands, not completed results. Final allocation numbers,
TypeScript ratios and own-source costs will be taken from their saved receipts.
