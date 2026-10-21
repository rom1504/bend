# Phase114 native qualification and compiler requests

Source02 completes hosted→N1→native self-emission→N2 through the unchanged
qualification gates. The raw QBE files are byte-identical: **74,220,801 bytes**,
SHA256 `f1abc6d75d176e30d4528f796bd9c866b20964cc74248c929e6b51deb7c4024b`. N1 and N2 each pass 16 positive focused
programs plus 3 expected refusals (2 source, 1 backend); N2 also passes all 45 original
one-shot conformance programs. Refusals are not counted as compiled programs.
The installed selection is unchanged.

The full guard takes **1323.984 s** (22.07 min),
with peak process-tree RSS **4,101,935,104 bytes**
(3.820 GiB) under its 4 GiB guard limit. Hosted acquisition takes
560.524 s; the actual N1 self-request takes
466.724 s. These nested clocks must not be added
to the guard wall. The guard includes semantic suites and the timing screen.

[Exact pins, gates and clocks](native-results.json) · [Separate evidence selections](selection.json) ·
[Raw comparison](../../selfhost/build/phase113/p114-native-final02-qbe-comparison/report.json) ·
[Guard receipt](../../selfhost/build/phase113/p114-native-final02-qualification-guard/process.json).

## Three-source request screen

All 27 observations pass complete outputs: three unchanged sources × three roles
× three rotated rounds, cache mode, CPU 3, one worker, GPU off. Values are medians
in seconds. Ready time is each sample's request plus machine-build child times;
it excludes harness bookkeeping and the correctness execution.

| Source | N1 request | N2 request | Upstream request | N1 ready | N2 ready | Upstream ready |
|---|---:|---:|---:|---:|---:|---:|
| lexer | 2.883 | 2.886 | 0.748 | 2.962 | 2.967 | 1.411 |
| coverage-closures-256 | 0.761 | 0.769 | 0.525 | 0.800 | 0.809 | 1.090 |
| coverage-map-churn-128 | 4.465 | 4.425 | 1.107 | 4.624 | 4.584 | 2.864 |

The geometric mean request ratios are **2.82490×**
for N1/upstream and **2.82713×** for N2/upstream.
Ready-executable ratios are **1.35522×**
and **1.35687×**, respectively.
Ratios below 1 are faster. N2/N1 ratios are
1.00079 for requests and
1.00122 for ready time.
[Raw measurements](../../selfhost/build/phase112/p114-native-final02-transport/report.json)
retain every sample; the JSON summary independently recomputes their medians
and geometric means.

Native requests emit QBE with authenticated prepared Base. Upstream requests
emit C and load/check source Base. Native builds use QBE/as/link with the cached
runtime; upstream uses Clang-O2 and recompiles runtime C. These are practical
request/build comparisons with disclosed format and preparation differences,
not same-format throughput or generated-program runtime measurements.

Phase112's separate [transport04 campaign](../../selfhost/build/phase112/transport04/report.json)
reported N2 requests at 2.071× upstream
and ready time at 1.014×.
It used a different full compiler source/runtime and was not rerun as a role in
this campaign. The historical/current difference does not isolate a regression
or identify which transformation caused it. Three repeated sources and three
rounds do not establish broad compiler throughput or confidence intervals.

## Source and qualification scope

Qualified native source02: `500211d484785778e75d5d4388b0d5ebc7282effd233c6b8f3d0e0269ac777f8`.
The earlier broad runtime result remains bound to hosted source01:
`4fb0572f0a011f6c1921594372d816bb49f26289ecc0e079328edd7491598587`. Its 44 timed points,
one zero-work control and 405 output/count observations remain the source01
[runtime result](results.json); the score is not relabeled as a source02 native
measurement. Source02 repairs namespace traversal; three ordinary requests have
[exact old/new QBE witnesses](namespace-products01.json), a deliberately limited
bridge between the sources.

Exact reproduction concerns raw QBE. The N1 and N2 executable hashes differ;
there is no ELF fixed-point or N2-to-N3 self-emission claim. Full45 here is
one-shot correctness, not native-produced batch45 timing. Parallel execution,
GPU, live-mode timing, installed promotion and auxiliary experiments are outside
this result. The report pins the original gates, source/API/runtime, images and
receipts without changing production pointers.
