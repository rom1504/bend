# Phase49: V8 explains why tuple removal was the wrong priority

**The dominant cost in this RLE benchmark is fresh public-entry validation.**
The generated computation itself approaches TypeScript speed when those checks
are experimentally bypassed. The bypass is unsafe under the current public
contract and is not installed. This phase changes diagnostic tooling and
understanding, not the compiler's production performance or conformance status.

The [design](../../design/phase49/v8-aware-diagnostics.md) was committed/pushed as
`21f4a78` before target execution. Installed Phase48 RNFA04's RLE module is
byte-identical to this experiment's historical array06 baseline, so the finding
applies to the current RLE output. The rejected values03 tuple-transport candidate
is a separate comparison role; it is not relabeled as RNFA04.

## Controlled result

Five fresh processes per role, rotating role order, ordinary public calls,
unchanged expected result `11`, every result checked and included in a digest.
The table uses the longer final run, not earlier short TypeScript windows.
The three changed-guard modules each edit one exact condition; all private
computation, declarations and original fallback bytes are preserved.

| Generated program / diagnostic | Median µs/call | Observed range | Relative to TS |
| --- | ---: | ---: | ---: |
| Pinned upstream TypeScript | 0.5894 | 0.5741–0.6374 | 1.00× |
| Current RLE output / array06 baseline | 39.3434 | 38.6752–42.8951 | 66.75× |
| Rejected tuple-removal candidate | 39.3651 | 39.0906–42.8507 | 66.79× |
| Baseline, only String-host check omitted **(unsafe)** | 22.3696 | 21.8056–24.2677 | 37.95× |
| Baseline, host/dependency entry checks bypassed **(unsafe)** | 0.8043 | 0.7964–0.8904 | 1.36× |
| Tuple candidate, same checks bypassed **(unsafe)** | 0.8355 | 0.8249–0.9240 | 1.42× |

Bypassing the checks produces a **48.92×** diagnostic speedup; omitting only the
String check produces **1.759×**. These interventions support guard cost as the
dominant cause of this tiny program's gap. They also change V8's optimization
context, so their differences are not exact timers around the removed functions
or rigorous upper bounds on a legal future optimization. They validate only
ordinary clean-host results, not behavior under host/dependency mutations.

The ordinary candidate is effectively flat in this fresh run: **0.055% slower**.
The earlier Phase48 screen's 4.4% regression is preserved, not reproduced or
explained precisely here. With both boundaries bypassed, the tuple candidate is
**3.88% slower** despite allocating less. There are no confidence intervals, and
some per-role ranges span roughly 10%; small effects are not treated as decisive.

This is **one fixed six-element RLE source**, not the 45-point corpus, a typical
program estimate or a new parity result. Installed overall speed remains the
Phase48 result of 2.6789× TypeScript on that corpus. New harness/window choices
also mean this 66.75× RLE number does not replace historical corpus medians.

## What the profiles reveal

The five named guard routines account for **79.44% baseline / 76.55% candidate**
of time-weighted CPU self samples. These are exclusive self weights, so nested
guards are not double-counted. They include `stringHostGuard`,
`stringHostDescriptor`, `regionHostGuard`, `scalarGuard` and `localGuard`.
Anonymous entry code, GC, harness and other work remain visible separately.

Allocation sampling includes objects collected by major and minor GC. It shows:

| Role | First estimate, bytes/call | Independent later estimate, bytes/call |
| --- | ---: | ---: |
| TypeScript | 2,245 | Not repeated |
| Baseline | 33,700 | 33,262 |
| Tuple candidate | 32,688 | 32,600 |
| Baseline with full diagnostic bypass | — | 2,549 |
| Candidate with full diagnostic bypass | — | 1,770 |
| Baseline with String-only omission | — | 24,847 |

`getOwnPropertyDescriptor` alone accounts for approximately **20.9 KB per baseline
call** in the first profile. Removing tuples reduces the loop's attributed
allocation from about **1,211 to 514 bytes/call**, but this is small beside the
reflection and descriptor-check machinery. The later bypass pair reduces
estimated allocation by another 30.5% through tuple removal while becoming
slightly slower. Less allocated memory is not sufficient to predict execution
speed.

These are sampled estimates, not exact object counts or retained heap. Tree and
sample totals differ; absent-node samples remain explicitly unattributed. Calls
include public wrappers, output checks and digest work. CPU profile counts are
1,210 baseline, 1,213 candidate and 543 TypeScript; allocation profiles have
tens of thousands of samples. Profile durations never enter the timing table.

## What V8 does with the worker

The fresh opt/deopt/inlining traces show both Bend RLE loops reaching
**TurboFan before warmup ends**, with their step helper inlined. None of the
three roles records a bailout during the trace's measurement window. Failure
to inline that helper or persistent lower-tier execution is therefore not
supported as the explanation for this comparison.

The [optimized-IR and machine-code report](v8-ir.md) goes further:

- Baseline and candidate retain **16 versus eight allocation nodes** through
  V8's escape-analysis phase. Four transient array sites, each with a shell and
  backing store, disappear in the candidate. V8 did not already erase the
  particular baseline tuple difference we targeted.
- The candidate instead retains **six shared-context loads and six stores**.
  Its extra scalar results do not become entirely register-local transport.
  Lexical initialization checks and pointer write-barrier paths survive.
- The optimized loop grows **2,448 → 2,516 instruction bytes**, with **16 → 17
  safepoint stack slots**, despite fewer IR nodes. Some additional calls are
  cold initialization-error paths, not calls necessarily executed by this input.

This supplies concrete possible offsets to allocation savings. It does not
prove which instruction accounts for a timing difference, or that the listed
write-barrier slow path executed. The graph is one compiled function/version;
callers can have different inlining decisions. Source sites, static graph
nodes, sampled heap bytes and elapsed time are kept separate.

The first TypeScript graph was incomplete JSON even though its public-call job
passed. We retained it as invalid and obtained a complete graph with a fresh,
longer warmup/call run. We did not repair the dump, force optimization or use
its partial nodes as evidence. All three final graphs and assembly are preserved.

## Why these checks are expensive—and what is not proved

The [contextual-worker emitter](../../selfhost/src/back/js/jpure.bend) currently
emits both `regionHostGuard()` and `stringHostGuard()` at the boundary. This
choice is not specialized to this RLE source's effects. Its 17 dependency names
contain no String operation, yet the guard scans the String constructor and
prototype, their key lists and every property descriptor. The numeric-region
guard also takes its full mode, including floating-point host checks.

The scalar guard validates source function identities and descriptors, while
the other guards preserve original runtime/prototype observations. Those
contracts cannot be dismissed as redundant merely because the clean benchmark
uses no String operation. Full original-source and runtime behavior—including
errors, forcing and reentry—must support any narrowing. Caching a successful
guard across calls is not justified when the host or dependencies can change.

The useful next direction is **prove smaller boundary checks, or amortize them
across a region whose validity is established**, before another broad tuple pass.
V8-aware inspection also suggests avoiding shared lexical result channels when
testing future scalar transport. The [next experiments](next-experiments.md)
state cheap falsifiers and required semantic evidence. None of these production
changes was attempted or qualified in this phase.

## Method, scope and reproducibility

The [diagnostic guide](../../selfhost/tools/performance/phase49/README.md) explains
the new driver, exact filters and replay commands. CPU/allocation summaries reuse
the existing maintained profiler. The [data-only summary](evidence/measurements.json)
rehashes 131 consumed inputs and recomputes all table medians and profile totals;
it also verifies nonoverlapping target intervals.

Node **24.18.0**, V8 **13.6.233.17-node.50**, CPU3, 1,024 MiB heap,
2,048 MiB process-tree RSS and 4,096 MiB available-memory floor were fixed.
All **63 target jobs** return their expected results; the incomplete first TS
graph remains a separate artifact failure. Peak observed process-tree RSS was
**205.9 MiB**. No compiler build or full-corpus validation was needed.

Measured target-process occupancy totals **136.81 seconds**. The raw experiment
clock begins at 05:32:05 UTC and the last target ends at 05:46:00 UTC, about
14 minutes later; preliminary reading/design began before that clock and report,
review and publication follow it. Unrecorded intervals include coding, reasoning,
coordination and documentation, not an inferred waiting-time total. Agents
prepared the driver, inspected outputs/IR and independently checked conclusions;
root ran targets serially. This is a substantially smaller investigation than
the previous compiler-implementation campaign.

The installed compiler and its source are unchanged. The three unsafe derivatives
remain explicitly non-installable. All 103 unrelated starting files and closed
historical raw trees are preserved. No PR comment was posted.

The [published evidence capsule](../../selfhost/tools/performance/phase49/evidence/README.md)
retains all 327 raw files, including invalid and unsafe experiments;
every archived member was reopened and hashed. Raw writes closed at 05:52:23 UTC,
about 20 minutes after the campaign clock began. Subsequent work is documentation,
review and Git publication outside the closed raw tree.
