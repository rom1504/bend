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
