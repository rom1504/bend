# Phase57 bounded compiler-request profiles

The [profiling helper](../../selfhost/tools/performance/phase57/profile-v2.mjs)
wraps a supplied async compiler request. The latency worker owns compiler
selection, source/output identity checks, Base preparation, the first request,
and three warm requests. Profiling starts afterward and uses the same request
and output oracle. The ordinary checked B1, emitted direct B2 and pinned
TypeScript roles must request the same source and library operation; profiling
does not silently substitute a lower-level emitter.

```js
import {profile} from '../profile-v2.mjs';
const diagnostic = await profile({
  mode: 'cpu',             // allocation uses its own fresh process
  run: async () => { await checkedRequestAndOutputOracle(); },
  out: freshPhase57Directory,
  targetMs: 5000,
  maxRequests: 32,
  samplingIntervalUs: 1000,
  samplingIntervalBytes: 131072,
  moduleUrl: actualCompilerModuleUrl,
});
```

The output directory must be fresh and inside `selfhost/build/phase57`.
The helper exports functions only. Its summary functions are imported from
the hash-pinned [existing program profiler](../../selfhost/tools/performance/programs/profile.mjs),
whose explicit main-module guard prevents its CLI from running on import.
No compiler or generated program is imported by the profiler helper itself.

CPU and allocation runs are separate fresh processes, supervised serially by
the parent with CPU3, a 1 GiB Node heap, a 2 GiB process-tree RSS cap and a
4 GiB free-memory floor. The helper executes whole requests sequentially until
five seconds or 32 successful requests. A request is never interrupted at
five seconds; the external supervisor enforces the actual wall deadline.
The receipt retains actual request count, diagnostic per-request durations,
target/cap flags and errors. Import/first-request/warmup handling is the
caller's responsibility and must appear in its receipt.

## Accounting and interpretation

CPU sampling uses a 1 ms interval. The current helper preserves two views:
weighted timestamp attribution and independent sample-count attribution. Every
original signed `timeDeltas` value remains unchanged in the raw profile. A
weighted view may replace a negative increment with zero only if each negative
magnitude is at most 2 µs and the total correction is at most 10 parts per
million of the raw profile duration. There is no absolute correction allowance.
The receipt records every corrected index/value, signed sum, correction,
fraction, duration and residual; it does not establish the anomaly's cause.

If either bound fails, `weightedStatus` is `refused`, the primary summary has
`summaryView: sample-count` and units `samples`, and no weighted attribution is
published. The count view always gives every original sample one unit. Refusal
of the weighted view does not waive a compiler/output failure, nor discard an
otherwise completed capture. The independent count summary is also saved when
the weighted view is admitted. It must never be relabeled microseconds.

Both views keep self/inclusive rankings, full frame URLs and positions, and
all categories. Residual duration is not assigned to a guessed frame. A frame
is counted once per sample's stack for inclusive estimates, including recursion;
inclusive totals overlap and must never be added together. Native, idle,
garbage-collector and unidentified frames remain in the denominator.

The first CPU attempt, `cpu-lexer01`, is retained as failed: compilation and
output checks succeeded, but the frozen v1 summarizer rejected two negative
increments, −1 and −2 µs. The preserved raw profile has 2,569 samples, a signed
delta sum of 4,536,829 µs and a duration of 4,537,186 µs. A data-only check of the
v2 method admits a 3 µs correction (0.661 ppm), giving 4,536,832 µs of weighted
samples and leaving a 354 µs residual. This does not turn the old failed receipt
into a successful capture. Raw SHA-256:
`1be942e447c55e20703174f223532423a25ee8a28d654bfdc9834974e81ca89c`.
The [frozen predecessor](../../selfhost/tools/performance/phase57/profile.mjs)
and its failure are preserved; v2 is a separately hashed producer.

The inherited `generated` category matches **one exact module URL**, not all
compiler work. A Bend API can occupy one module, whereas TypeScript checking
and emission span `bend.ts` and `comp.ts`; frames outside the supplied primary
URL remain `other`. This helper and its caller also remain `other` rather than
the inherited profiler's `harness` category. Compare actual frame URLs and
weights, not cross-role `generated` percentages. All original URLs remain in
the raw profile and full frame table.

Allocation sampling uses 128 KiB and explicitly includes objects collected by
both minor and major GC. Frame weights come only from `samples[].size`.
The separate call-tree `selfSize` sum and discrepancies remain visible rather
than being added to sampled bytes. Samples referencing absent tree nodes are
retained as unattributed bytes with no fabricated ancestry. These are sampled
allocation estimates, not exact event counts, retained heap or peak memory.

Each run saves a raw `.cpuprofile` or `.heapprofile`, `summary.json` with self
and inclusive rankings, `summary-counts.json` for CPU captures, and `report.json` binding producer, parent summary
method, Node, raw output and summary hashes. Stop/validation failures preserve
available raw data and a failed receipt. No V8 `--prof` processing, whole-log
symbol expansion, or heavyweight postprocessor is used.

The supplied request may include parsing, I/O, checking, completion,
specialization and emission. A frame's source identity does not by itself
prove which higher-level stage caused its work. In particular, ABI2
`check_program_diagnostic` includes completion/specialization; the current
ABI3 source-discovery path includes host I/O, `f_source_header`,
`f_complete_source`/`f_complete_seed`, and final `f_graph_trace`;
`jd_reach_selected` emits definitions
while resolving references. Use those exact function labels when interpreting
frames. Trace messages establish ordering, but cannot establish exact stage
durations unless their timestamps and boundaries are recorded. The ordinary
driver's library-emission interval also includes foreign
collection and runtime concatenation.

Profiled durations include inspector, allocation sampler, validation and async
loop overhead. They are diagnostic evidence only and must remain separate from
unprofiled latency medians or speedup ratios. The requested target is a useful
sampling window, not a claim that all roles perform an equal number of requests;
report both weights and request counts before comparing per-request estimates.
