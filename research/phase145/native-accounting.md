# Native operation accounting: evidence before more instrumentation

The current qualified compiler is **final04 N2**, source `865cff6a…`, program
object `c29c4749…`, serial runtime object `2d078323…`. We can profile its runtime
operations by relinking this object. A new compiler emission is unnecessary.
The [prepared small experiment](../../selfhost/tools/performance/phase145/native/README.md)
uses existing general-profiler hooks and already-qualified complete QBE oracles.
The root executed the build, independent control and all six counters-off/on
requests successfully in 16.13 s of supervised work. No compiler was rebuilt.
The [pinned event summary](native-counts.json) retains the observations and
source-owner joins.

## What the three full captures already establish

The [authenticated compact inventory](native-history.json) reuses the existing
Phase144 summaries and pinned stage/capture/spec receipts. All three captures
have zero reported loss and more than 99.4% main-thread CPU coverage. They compile
the same frozen Phase142 source, but their compiler source, native generation,
runtime and output differ. They are not three repetitions of one treatment.

| Engine | Samples at 32 ms | Diagnostic wall |
|---|---:|---:|
| Phase143 N2, atomic runtime | 10,283 | 330.82 s |
| Phase144 integrated source01 N1, atomic runtime | 9,158 | 294.87 s |
| Phase144 final03 N2, serial runtime | 8,681 | 279.52 s |

Final03's exact stage intervals still put 88.45 s in frontend including erasure,
43.44 s in admission/static preparation/raw lowering, 56.25 s in initial
optimization plus first verification, 23.35 s in observer/final admission, and
67.61 s in registry plus rendering/output. These are instrumented intervals,
not clean predicted savings or current final04 phase budgets.

Final03 physical leaves include drop 10.44%, shared-field fade 6.60%, take helpers
11.40% and constructor helpers 5.38%. Register transport accounts for 7.17% when
disjoint direct-helper PCs and authenticated libc-caller PCs are combined. These
views overlap the stage and active-owner views. They cannot be added to those
budgets. Nor can destruction samples identify the original allocation site.

The source01→final03 change reduced drop/fade substantially, while constructor
and take activity remained. That motivates counting requested operations and
words, rather than assuming the remaining cost is solely atomic instructions.
There is no causal isolation of runtime, source and machine layout in these
three whole-engine captures.

Final03 also spent 147 samples in typed concat. This is historical evidence:
final04 deliberately withdrew broad String.append admission after repeated
serialization regression. Do not carry that final03 opportunity forward as a
current final04 hotspot. The current exact-profile inventory is not refreshed
merely by relinking a newer binary.

## The inexpensive new falsifier

The same final04 N2 object will compile the existing Lexer, Map-churn and closures
sources using the same prepared Base and paths as the parallel JS/native pilot.
Counters-off and counters-on output must equal the frozen final04 ordinary QBE.
The independent ABI fixture must pass first. The original sixteen channels are
sufficient for the first decision: allocation/word pressure, take versus drop,
keep/sink, frames, and register traffic by authenticated dispatch context.

Interpretation is deliberately narrower than an allocation profiler with object
lifetimes. A take does not establish reconstruction; a keep may be trivial;
drop entry counts omit the number of recursively visited children. Requested
allocation words are class-rounded allocator traffic, not RSS or unique bytes.
Source owner grouping is the enclosing active dispatcher, not logical ancestry.
A query helper name therefore does not turn runtime counts into query counts.

There is no complete String-character or search-probe counter in the unchanged
runtime interface. Borrowed/private readers may directly read heap fields or
compare scalar characters. Instrumenting only public String/query helpers would
silently undercount them. Keep this gap explicit until a measured question
justifies instrumentation at an audited shared operation boundary.

If all three requests show similar ownership/transport ratios, inspect a shared
runtime/representation boundary next. If one family dominates, use its exact
caller and machine code to identify the full computation that creates that
traffic. Do not start another full capture or build a larger profiler before
these small, independently checked observations answer that distinction.

## Actual small-request counts

| Runtime event | Lexer | Map churn | Closures |
|---|---:|---:|---:|
| Allocation calls | 16,772,154 | 23,676,442 | 7,781,479 |
| Requested allocator words | 32,523,800 | 43,963,324 | 16,089,059 |
| Constructor takes | 16,477,743 | 21,806,059 | 5,860,665 |
| Keep calls | 7,264,928 | 11,378,366 | 2,682,494 |
| Sink calls | 19,774,582 | 33,328,011 | 3,849,358 |
| Drop entries | 14,191,557 | 20,776,269 | 2,400,080 |
| Dispatches | 12,415,863 | 18,042,681 | 5,319,330 |
| Frames pushed | 77,338 | 215,131 | 30,743 |
| Register words copied | 22,361,417 | 33,212,426 | 9,539,193 |
| Register words cleared | 0 | 0 | 0 |

Whole-invocation allocation/free calls and requested/free words balance exactly
in each observation. That does not prove all lifetime or alias properties; it is
an accounting fact for these completed requests. The zero clear count confirms
that these executions retain the existing live-register-bank capability. The
remaining register traffic is copying, rather than clearing a historical
214-word bank.

A useful fixed-work signal appears in 36 named `p88_`/`p130m_` contexts belonging
to the prepared-Base carrier decoder. Their fifteen non-refill channels are
identical across all three workloads: **4,501,818 allocations, 10,798,893 requested
words, 3,707,655 takes and 7,307,598 copied register words**. Allocator refill calls
vary 201/224/246, as freelist state can differ. The selected family contributes
26.84%, 19.01% and 57.85% of allocation calls respectively. It is a posthoc
observed invariant subset, not a complete or exclusive Base phase, and these are
operation shares rather than CPU shares. Parent/child values created elsewhere
can be freed in these contexts, explaining why that subset's free count exceeds
its allocations. No small-request percentage is extrapolated to the full build.

The actual source connections are `p88_number` (line 37458), `p88_field` (37498),
`p88_fields_finish` (37615) and `p130m_word` (56374) in the pinned final04 source.
They repeatedly decode/update `P88State`/`P88Step` and compact word pairs.
`String.append` accounts for 4,306,000 / 5,955,313 / 491,847 allocation calls under
its active context. Those are allocations, not necessarily the number of String
characters: runtime wrappers, ownership metadata and inline callees share that
context. Base-defined String helpers receive a separate pinned Base declaration
link instead of an invented compiler source line.

The exact stage-clock observation also passed using the existing generic stage
observer and retained sampler, with unchanged complete QBE in all three cases.
All 24 historical marker names map to current exact FIDs. Required entries and
order pass; the optional nested final-verifier marker appears only in Map
(31.83 ms, already included in observer/final admission). Its Lexer/closures
interval remains unavailable. The 156/243/51 samples support descriptive views
only, below the 500-sample threshold. [Pinned stage clocks](native-stages.json)
are diagnostic single observations, not repeated clean timings.

| Nonoverlapping diagnostic stage | Lexer | Map churn | Closures |
|---|---:|---:|---:|
| Base/carrier preparation | 231.02 ms | 232.98 ms | 232.89 ms |
| Frontend including erasure | 137.57 ms | 182.57 ms | 61.30 ms |
| Admission/static/raw lowering | 103.54 ms | 504.24 ms | 24.27 ms |
| Initial optimizer | 327.88 ms | 183.15 ms | 15.66 ms |
| First independent verifier | 159.53 ms | 162.43 ms | 12.37 ms |
| Observer/final admission | 15.96 ms | 93.05 ms | 7.37 ms |
| Registry | 82.06 ms | 153.13 ms | 10.85 ms |
| Render/output/teardown | 195.23 ms | 449.22 ms | 46.91 ms |

The fixed carrier work is real but costs about 0.23 s here. It is 18.44%, 11.88%
and 56.57% of these marker spans, respectively, not the large full-build
bottleneck: the retained final03 full-source Base interval is only 0.256 s.
Therefore reducing small-request fixed preparation is a separate development-loop
improvement, and cannot plausibly turn a 231-second full build into 50 seconds.
The variable work differs sharply: initial optimization/verification dominates
Lexer; raw lowering and rendered output dominate Map. The parallel JS pilot must
use corresponding boundaries before attributing any difference to QBE quality.
