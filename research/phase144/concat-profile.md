# Typed concat diagnosis: legal append was often unprofitable

The added counters confirm a strong difference between the two workloads.
**Row32 rejects 90.50% of speculative concat attempts; Unicode64 rejects 54.53%.**
Row32 also inspects substantially more spine positions per attempt. This is
consistent with the independently measured row32 regression: unsuccessful checks
add work before the original append worker executes. It does not convert these
counts into a number of milliseconds lost.

The root executed all three prepared jobs successfully: diagnostic runtime
build/relinks, original ABI counter control, and both ordinary programs with
counters disabled/enabled. All complete semantic outputs and success counts
matched the frozen independent oracle. [Pinned observations and offline summary](concat-profile.json)
retain actual binaries, original program objects, runtime source, event files,
build/control receipts and the reproducible summarizer.

| Observed complete invocation | Row32 | Unicode64 |
|---|---:|---:|
| Concat attempts |2,064|1,412|
| Successful empty-left returns |0|0|
| Successful nonempty splices |196|642|
| Static-term refusals |830|642|
| Shared-RFC refusals |0|126|
| Heap wrapper targeting static constructor refusals |1,038|2|
| Total refusals |1,868|770|
| Refusal fraction |90.50%|54.53%|
| Spine positions inspected |13,816|1,694|
| Positions per attempt |6.69|1.20|

A position is counted before the original loop's ownership/static check, including
a position that causes refusal. The node total is **not partitioned by eventual
success/refusal**; we cannot call all 13,816 visits wasted work or claim that the
average failed scan visits 6.69 nodes. Each invocation uses the frozen source
arguments with diagnostic repetitions 1 / warmups 0. Counts include the initial
semantic result, wrapper and output, not just an isolated benchmark kernel.

## What the extension establishes

The existing generic profiler supplies dispatch attribution, counter storage,
overflow checks and JSON output. Seven appended channels preserve the first 16
names/order. Source transformation is reversible: removing these hooks and the
original profiler hooks restores the entire original runtime, while removing
the appended enum/names restores the original support include. The hooks do not
repeat a heap read or ownership condition, nor modify an operand or its ownership.

The unchanged independently frozen ABI fixture passed with its exact original
16-channel per-FID counts and seven expected-zero columns. Counters-off produced
no event rows. Both ordinary programs passed counters-off/on output checks and
per-context attempt/success/refusal conservation. Positive branch meanings are
source-audited; this fixture does **not** independently exercise every new positive
refusal branch. A general qualification of those channels would require such a
fixture. Active dispatch IDs are not logical call stacks or allocation origins.

This diagnostic uses **atomic Phase128 runtime** source
`6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`,
compiled with `-O2 -std=gnu11 -ffp-contract=off`, without a serial-RFC macro.
That matches the `codegen` products in the clean row32 baseline→candidate
comparison. Retained final03 program objects are relinked; no program is
re-emitted by the later reverted compiler. This is neither a serial-runtime
profile nor a performance measurement of the selected compiler. Instrumented
elapsed times are not used for speed claims.

## Decision and lesson

Eight separate clean row32 pairs had already shown median 512 ms → 557 ms,
1.08789×, with all eight candidate runs slower. The ownership checks are necessary
for the helper's mutation to be legal; weakening them would be incorrect.
The source04 admission reversal therefore stands, while the distinct live-bank
whitelist recovery can be retained. Unicode's smaller gains demonstrate that the
operation can help; they do not justify enabling it broadly.

The useful compiler distinction is a known profitable complete computation,
versus a legal speculative helper with a high refusal rate. An owned root does
not by itself establish that every tail in a whole spine is dynamic and uniquely
owned. Future profitability work can use validated producer/ownership information,
but this phase adds no new recognizer or policy search. The counters explain a
negative result and make the same question cheaper to investigate later.

## Reuse contract

The [versioned opt-in extension](../../selfhost/tools/performance/phase144/emission/string-append/profile/README.md)
contains preparation, guarded root commands, observation and summarization. It
leaves the generic profiler source and production runtime unchanged. A future
reuse must authenticate the exact helper/runtime/header and program-object
identities, prepare fresh outputs, pass the independent control and ordinary
outputs, and keep diagnostic counts separate from clean timing. The frozen
recipe deliberately refuses a changed source rather than silently applying the
old hook locations to a new runtime. It has not been promoted as a universally
qualified profiler feature.

The separate small-register-copy full-source experiment remains **unrun** at
this checkpoint. These concat results provide no evidence for adopting that
runtime change.
