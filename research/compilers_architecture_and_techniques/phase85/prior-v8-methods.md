# Phase85: reuse the V8 investigations without repeating their mistakes

This is a source/document/tool review, dated 2026-10-13. This lane ran no
compiler, generated program, benchmark or profiler, and changed no production
source. Historical measurements below retain their original scope. Root owns
new Phase85 measurements and any selection decision.

The useful inheritance is a method: connect **actual request cost**, **engine
decisions**, **surviving optimized operations**, and **a falsifiable intervention**.
The old guard and descriptor-runtime fixes are largely the wrong objects for
today's compiler. Current B2 uses the later direct backend. Its remaining gap
requires evidence about the current generated compiler executing actual source
loading/checking/reporting/native emission.

## Current question and historical scope

[Phase84](../../../implementation/phase84/README.md) restored installed Phase82:
the qualified fresh Bend-to-C request ratios remain 1.673× B1 and 1.328× B2
upstream. These are JS-hosted compiler execution times, excluding module import,
explicit Bend Base preparation, Clang and generated-C execution. The inherited
upstream comparator loads/checks Base but does not run its CLI proof-report
helper; Bend's ordinary report is included. Preserve this asymmetry explicitly
and add an alternate report-inclusive comparator only as a separate result.

Three different comparisons must remain distinct:

| Comparison | What it can establish |
| --- | --- |
| B1 versus B2, same Bend compiler source | Effect of the generated implementation, including its real adapter/runtime |
| B1 or B2 versus upstream compiler written in TypeScript | End-to-end implementation gap under the stated request boundary |
| Bend user program compiled through different backends | Generated-program execution behavior; not compiler throughput by itself |

The Phase30 parent/H experiment is the first row. Phase49/51 concern the third.
The desired Phase85 result primarily concerns the second, with the first helping
explain generated control flow. A historical ratio is not a multiplier for a
new ratio, nor can an old profile be treated as the current image's profile.

## What the earlier experiments actually taught us

### Phase49: finding the dominant cost beat counting removed objects

[Design](../../../design/phase49/v8-aware-diagnostics.md),
[report](../../../implementation/phase49/README.md),
[IR analysis](../../../implementation/phase49/v8-ir.md).

On one six-element RLE source, the unchanged baseline took 39.343 µs/public call
versus upstream 0.589 µs. An explicitly unsafe saved-JS guard bypass took
0.804 µs. Five guard routines accounted for 79.44% of baseline CPU self samples;
reflection dominated sampled allocation. This was a specific causal intervention,
not permission to remove the public contract, a legal optimization ceiling, or
a representative whole-program speed claim.

The originally suspected tuple transformation did remove real allocation sites:
16 baseline versus eight candidate `Allocate` nodes survived escape analysis.
Nevertheless, the bypassed candidate was about 3.9% slower and retained six
context loads plus six stores, initialization checks and pointer-barrier paths.
Its optimized loop grew 2,448→2,516 instruction bytes and 16→17 safepoint stack
slots. The investigation found an actual tradeoff instead of assuming that fewer
source constructors implied faster machine code.

Both loop versions reached TurboFan before measurement, with their step helper
inlined and no measured bailouts. Tier success and absence of deoptimization did
not imply good code or explain performance. Conversely, a final graph's zero
`Allocate` nodes meant lowering to memory/slow-path operations, not that all
allocations vanished. Cold throw/barrier paths in assembly did not prove those
paths executed.

The entire investigation used 136.81 seconds of target occupancy, across 63
bounded jobs; the recorded target campaign spanned about 14 minutes. Source
inspection, report and publication added time. This is evidence that a focused
saved-output discriminator can be much cheaper than another compiler campaign.

### Phase51: inlining is a budget tradeoff, not an optimization score

[Design](../../../design/phase51/v8-guided-runtime.md),
[dispatch](../../../implementation/phase51/dispatch.md),
[guards](../../../implementation/phase51/guards.md),
[final report](../../../implementation/phase51/README.md).

V8's original `apply` was optimized, but refused as an inline candidate because
of its bytecode size. Splitting four cold branches changed its inlining events
from zero to 37, while useful `force` inlining fell from 17 to zero. The existing
inlined-bytecode size recorded for `force` grew 319→807. The transformation
achieved the requested local mechanism without reliably improving execution.
Those counts describe compiler events, not dynamic invocation frequencies.

The smallest IO-only extraction was retained, with ordinary property-read order,
partial/overapplication, getters, exceptions, reentry and trampoline behavior
covered by 27 differential controls. However, Evening's apparent 1.555× gain
under a time-based warmup became 1.0477× after 32,768 fixed warmup calls. The
fixed-work driver did not record sample halves; missing drift data was not zero
drift. Allocation stayed effectively flat: 177,349→177,524 sampled bytes/call.
Attribution shifted from `apply` toward `force` with changed inlining; it did not
prove allocations disappeared or captured contexts were eliminated.

Batched String descriptor acquisition preserved boundary behavior but made
guard-heavy examples slower, so it was rejected. Reusing a String proof within
one already-validated callback-free interval succeeded; caching that permission
across public calls remained invalid. The qualified combination improved the
45-point corpus by only 2.66% elapsed time. It was useful, but not the predicted
large architectural solution.

### Phase52/54: keep the architectural change, not obsolete targets

[Phase52](../../../implementation/phase52/README.md) replaced mutable descriptor
tables and `code/env/bound` transport with native callable JS, native data layouts,
ordinary known calls and self/mutual tail loops. This involved an explicit
interface/contract change, rather than silently bypassing old guards. Its full
same-window comparison improved generated execution from 2.631× to 1.124× TS.
Those are historical generated-program numbers, not present compiler timings.

This establishes why examining upstream's emitted representation was more
powerful than repeatedly tuning the legacy dispatcher. It does **not** imply
that the current remaining gap has another dispatcher to delete. Phase83's
current audit finds only eight `run_tail` sites inside selected B2 function
bodies, versus 4,234 in B1. The old `apply`, `localGuard` and String guard paths
are not justified Phase85 B2 targets without current profile evidence.

[Phase54](../../../implementation/phase54/README.md) also demonstrates a useful
negative lesson: offline processing of an enormous profiler log exhausted its
512 MiB tool heap. Bounded deterministic tick subsampling retained mappings and
enabled diagnosis, but was explicitly not unbiased attribution. Avoid giant
logs and heap snapshots in the first place.

### Phase30: measure actual compiler stages and preserve warming evidence

[Design](../../../design/phase30/warmed-generated-compiler-cost.md),
[measurement](../../../implementation/phase30/warmed-generated-compiler-cost.md),
[independent review](../../../implementation/phase30/warmed-generated-compiler-independent-review.md),
[H17 repeat](../../../implementation/phase30/warmed-generated-compiler17.md).

One warm request followed by two timed checked-library requests compared a
genuine TypeScript-produced parent with its actual self-emitted H compiler.
Each role obtained its own validated Base cache under its actual API hash.
Ordinary discovery, checking, emission, cache processing and H's real ABI adapter
remained inside `D.inspect`; import, explicit Base preparation and output hashing
were outside. All 18 warm/timed outputs retained the independent exact hash.

Original H measured 5.2089× its genuine parent. The parent continued speeding up
11.1–11.5% between timed calls while H slowed 4.4–5.9%. H17's separate run measured
5.0016×, with both roles still speeding up. Neither was steady-state throughput,
an upstream-compiler ratio, a fixed point, or an isolated flag speedup. Lazy ABI
views were already present; whole-graph copying could not simply be assumed.

The method remains directly applicable. The old 8 GiB heap allowance and CPU0
assignment do not: Phase85 should use the current root-owned CPU3/1 GiB heap/
2 GiB tree-RSS guard and memory-headroom constraints.

## Reusable exact tools and required adaptations

| Existing method | Reuse | Change for compiler requests |
| --- | --- | --- |
| [phase49/v8-probe.mjs](../../../selfhost/tools/performance/phase49/v8-probe.mjs) | Pinned binary/module/config, import/first-call/warmup/measurement markers; separate clean, CPU, allocation and trace modes; every result checked | Its numeric-export loop is not an appropriate compiler benchmark. Use actual `D.inspect` and full output/report validation. |
| [phase49/v8-probe-graphs.mjs](../../../selfhost/tools/performance/phase49/v8-probe-graphs.mjs) | Exact single-function graph/code filters and flag validation; dump directories created before Node starts | Bind selected current compiler function/source offsets; preserve original first-request trace separately from a longer graph-completion diagnostic. |
| [phase49/run-probes.py](../../../selfhost/tools/performance/phase49/run-probes.py) | One serial guarded process, deadlines, 64 MiB per-file ceiling, isolated logs/dumps and explicit argument arrays | Root should use current plan/guard machinery; add a total job output budget, because a per-file limit alone permits many files. |
| [programs/profile.mjs](../../../selfhost/tools/performance/programs/profile.mjs) | Existing CPU/allocation aggregation and validation | Compiler frames span driver, runtime and API modules. Retain URLs and categories; avoid counting the new driver as generated work. |
| [phase30 compiler worker](../../../selfhost/tools/performance/phase30/inspect-generated-compiler-cost-worker.mjs) | Authentic role hashes, actual validated cache receipts, per-call warming data, exact output and complete observations | Preserve today's owned `D.inspect` route. Old explicit `api` calls deliberately have different admission behavior now. |
| [phase83/worker.mjs](../../../selfhost/tools/performance/phase83/worker.mjs) | Current frozen role/inputs, ordinary native request, exact C, prepared-state checks and public stage clocks | Add trace-mode phase markers without silently turning its single cold request into warmed throughput. |
| [phase51/dispatch-prepare-io.py](../../../selfhost/tools/performance/phase51/dispatch-prepare-io.py) | Exact old/new span, one-match precondition, inverse reconstruction, pinned producer and separate diagnostic export copy | Apply this discipline to a new current-image experiment; the historical old-body/runtime hash should fail closed on current code. |

CPU sampling used a 1,000 µs interval, weighted each sample by its preceding
time delta, and deduplicated recursive inclusive frame attribution per sample.
Keep self and inclusive numbers separate; inclusive frames overlap and cannot be
summed into a savings budget. Public-stage wrappers do not intercept recursive
calls through the generated module's private bindings.

Allocation sampling used 32,768-byte intervals with
`includeObjectsCollectedByMajorGC:true` and
`includeObjectsCollectedByMinorGC:true`. The summarizer uses `samples[].size`
as its single denominator, preserves sample IDs absent from the call tree as
unattributed, and retains differing tree totals separately. Do not add sample
and tree totals, infer zero allocation from missing samples, or confuse cumulative
allocation with live heap/RSS. Changed inlining can move attribution between
frames without changing total bytes.

The historical filtered diagnostic argument array was:

```json
[
  "--trace-opt", "--trace-deopt", "--trace-turbo-inlining",
  "--trace-turbo", "--trace-turbo-graph",
  "--trace-turbo-filter=EXACT_CURRENT_FUNCTION",
  "--trace-turbo-path=ABSOLUTE_FRESH_DUMP_DIRECTORY",
  "--trace-turbo-cfg-file=ABSOLUTE_FRESH_DUMP_DIRECTORY/graph.cfg",
  "--print-opt-code", "--print-opt-code-filter=EXACT_CURRENT_FUNCTION"
]
```

This is a recipe to validate against the actual pinned Node, not permission to
assume flags or reason numbers are stable. Phase49 used Node 24.18.0/V8
13.6.233.17-node.50. In that release inlining traces were global despite the
graph filter; `trace-turbo-escape` was debug-only, and `trace-turbo` allowed
concurrent tracing. Literal `$` in generated function names must remain inside
structured arguments, not unquoted shell expansion. The historical reason-5
mapping was tied to that bundled V8 source.

Require valid complete graph JSON, the expected `function.sourceName`, offsets
and function/version identity. Resolve inlined source IDs through the graph's
`inlinings` and `sources` tables. Compare allocation nodes before lowering,
context fields after load/escape analysis, then final calls/barrier operations
and disassembly. Final-phase operation disappearance alone is insufficient.
Phase49 retained an incomplete TS graph even though its program oracle passed,
then obtained a separate complete graph with a longer natural run. Never repair
truncated JSON or substitute a warmed graph for proof of the cold execution tier.

## Recommended Phase85 sequence

These are investigation choices and estimated effort, not promised speed gains.
Use existing prepared Phase82 products; avoid a new compiler build until a saved
diagnostic has discriminated a mechanism.

1. **Current cold versus later-request execution, 20–40 minutes analysis/tooling.**
   Begin with Numeric and Functions65; add Map only when useful to the decision.
   Use actual B1/B2/upstream identities and a fixed finite request sequence in
   each fresh process. Record the first request independently and every later
   request rather than aggregating them. Run clean repetitions separately from
   trace/CPU/GC. Mark import, each request and relevant public stages. Determine
   which hot functions optimize before, during or after the cold request, and
   whether later latency reduction coincides with changed tiers. Warming is a
   diagnostic variable, not free production speed or a replacement parity metric.

2. **Inspect the two highest-value current hot functions, 20–40 minutes.**
   Choose by measured cost, not source length. A hot large SCC is a candidate for
   bytecode-budget and inlining investigation; a frequently called small lookup
   or text helper supplies a contrasting case. Join profile source locations,
   optimized-function versions and Bend definitions. B1's closure/trampoline
   overhead is a different hypothesis from B2's SCC code quality. Measure whether
   large bodies stay below peak tier, refuse inlining, have expensive surviving
   loads/checks, or merely execute necessary work many times. Do not inspect all
   generated functions or emit all optimizer graphs.

3. **One intervention tied to that observation, 30–60 minutes including controls.**
   Possible examples are one exact cold-path extraction, one direct branch
   equivalent to a selected closure, or one no-observer temporary data transport
   expressed as caller locals. These are conditional examples, not established
   opportunities. Require exact output/report/diagnostic behavior on ordinary
   sources, plus targeted getter/alias/reentry controls wherever the affected
   interface makes those observable. Keep altered-image diagnostics clearly
   unchecked and non-installable. If the API bytes change, create and validate
   its own genuine Base cache; never relabel a baseline cache to avoid setup.
   Preparation remains separate and its cost is reported.

4. **Integrate only a demonstrated mechanism.** A changed trace is insufficient;
   the clean whole request must improve enough to justify production complexity.
   Compare baseline and derivative in the same rotated window. For a source-level
   implementation, require both stage identities, exact generated programs or
   explicit execution comparisons where bytes change, correctness and source
   accounting. Stop a neutral experiment rather than expanding qualification.

Useful falsifiers are concrete: no tier difference weakens a tiering explanation;
fully inlined helpers weaken a missing-inlining explanation; unchanged allocation
totals weaken an allocation-removal claim; a local improvement that vanishes in
whole requests rejects its proposed parity budget. A current trace may show a
limitation, but only a controlled intervention estimates how much can be recovered.

## Why this is preferable to another unbudgeted rewrite

[Phase83](../../../implementation/phase83/README.md) already showed Numeric B2
allocating 100.80 MB versus upstream 145.45 MB, while remaining slower. Functions65
check/report dropped 351→136 ms between its first and third B2 requests. Neither
observation identifies V8 as the sole cause, but together they justify this
focused investigation better than assuming excess allocation or quadratic work.

Phase84's paired annotation/erasure representation removed 33.5 ms from one
instrumented preparation stage but added 14.9 ms to its producer, leaving only
18.6 ms net and neutral clean B2 performance. The full old region was only about
18.5% of that profiled request. Local pass simplification could not deliver a
general 25% improvement without a larger measured mechanism. Phase85 should
explain time per operation and cold generated execution before adding another
representation whose downstream consumers remain unchanged.

The past large success was an evidence-backed representation change with a clear
contract; the past cheap successes came from very small changes with exact
controls. Neither history warrants promising parity before the current evidence.
