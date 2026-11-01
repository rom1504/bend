# Phase148 — compact compiler units: useful boundary, no speed promotion

**The tested compact adapter does not improve complete compiler-unit throughput
enough to adopt.** Corrected native ownership and exact-output controls pass,
but compiler-family time is essentially unchanged and Map is 2.8% slower. We
retain the qualified Phase147 compiler and its matched cold-build result of
246.17s. There is no new whole-cold, upstream-parity or generated-program speed
claim in this phase.

[Design](../../design/phase148/README.md) ·
[Hypothesis](../../experiments/phase148/P148-001-compact-unit.md) ·
[Metrics and cost](metrics.json) ·
[Reproduction](../../experiments/phase148/tools/README.md) ·
[Evidence inventory](evidence/inventory.json) ·
[Next architectural boundary](../../research/phase148/conclusions.md).

## What we implemented

The experiment encodes actual private native functions into contiguous scalar
instruction/value arrays with exact interned name IDs. Two real consumers—the
existing scalar optimizer's behavior and private direct admission—operate on
that same representation. They do not decode between passes. One final decode
feeds the unchanged independent verifier and QBE renderer. Packing, interning,
branch copies, decoding, rendering and destruction all count in the timings.

The three additive Bend modules live under `selfhost/tests/phase148/`: codec
833 lines, scalar consumer 542, admission consumer 543. The 1,918 experimental
lines are not included in the canonical compiler manifest. Host scripts only
extract declarations, transport fixtures, execute and measure; the compiler
algorithms remain Bend. The original final verifier remains an independent
check. There is no new cache, backend, runtime primitive or production policy.

This follows the compact indexed-IR principle in our earlier Zig research, but
tests its actual Bend execution cost rather than assuming contiguous storage
means direct machine loads. The ordinary mixed-array native program uses
**eight-byte scalar cells**, with runtime calls for reads and writes. A scalar
fact table has 16 cells per name, or 128 bytes before power-of-two rounding.

## Measurements

All rows below use ordinary native execution on CPU3, one thread, GPU off.
Old and new modes live in the same executable. Each observation includes
fixed context construction, repeated complete function pipelines and process
cleanup. Four alternating pairs use a common calibrated repetition count;
complete output oracles run before and afterward. Startup is not subtracted.

| Experiment | Old median | New median | New / old |
| --- | ---: | ---: | ---: |
| Six compiler functions, four repetitions | 149.922 ms | 148.967 ms | 0.9936 |
| Six Map functions, sixteen repetitions | 212.518 ms | 218.448 ms | 1.0279 |
| Compiler ablation, full pipeline | 149.085 ms | 147.698 ms | 0.9907 |
| Compiler ablation, rendering omitted from both | 126.514 ms | 125.314 ms | 0.9905 |
| Original pipeline versus pack/unpack then original pipeline | 147.957 ms | 171.970 ms | 1.1623 |

The first two rows are the frozen native03/Map comparisons. The last three use
a separately checked native04 harness with diagnostic modes, four repetitions
and four balanced pairs per comparison. These are complete selected-function
computations, not the full compiler. No confidence interval is claimed; the
roughly 1% compiler differences do not establish a useful win.

The ablation rejects the explanation that common rendering hides a large
analysis improvement. The additional representation transfer is material.
Compact consumers recover approximately that added work, but this is a
qualitative interpretation: transport also changes the ownership of the input
tree, so its 16.2% difference is **not an additive conversion stopwatch** or a
guaranteed gain available to a producer-integrated implementation.

The compiler/Map/Lexer captures contain respectively 856/291/922 statements and
33/13/35 branches across six functions each. Hosted controls cover all three;
only compiler and Map have fresh native timing. The prepared Lexer native plan
was not executed after the first two families failed the performance gate.
The captured functions are authenticated earlier inputs, not a new full capture
of every function in the current compiler.

Exact run paths within the evidence inventory:

- `selfhost/build/phase148/compiler-native03/timing/report.json`
- `selfhost/build/phase148/map-native01/timing/report.json`
- `selfhost/build/phase148/compiler-ablation01/report.json`

## Ownership finding and validation

The first version passed source checking and 81 hosted controls, but failed
ordinary native execution before its first compact output. A tiny pack-only
program reproduced the failure; storage and dictionary-seeding controls passed.
The defect was our prototype's unsafe sharing of a Type wrapper containing
unsealed array handles. Taking the shared wrapper reached the runtime's
`span_fade` refusal. Hosted persistent arrays did not expose that distinction.

We corrected the interface: consume array-bearing wrappers once, pass raw
arrays and scalar metadata internally, explicitly clone independent branch
facts, and decode only the unit returned by admission. Runtime checks remain
unchanged. This is an invalid `@unsafe` assumption repaired in experimental
code, not an established production compiler conformance bug. See the
[ownership analysis](../../design/phase148/ownership-successor.md).

The corrected version passes:

- Independent source acquisition of 17 API entries and 737 reachable declarations.
- All 81 fixed controls: 37 admission diagnostics, eight literal optimized
  bodies, 18 actual admissions and 18 actual full-body/render comparisons.
- Twelve supplementary controls: ten optimizer-result comparisons and two
  explicit conservative refusals for metadata-name collisions.
- Ordinary native storage, dictionary-seeding, packing, roundtrip and admission
  smoke checks; five array-layout controls also pass.
- Complete old/new native output equality for both timed families and all
  old/new/transport full outputs in the ablation.

These are finite differential tests and source checks, not BendTT proofs or
end-to-end compiler qualification. Malformed optimization/admission fixtures
were not executed as native programs. Original arithmetic helpers remain
shared, so the oracle independence is at the representation and transformation
boundary, not a separately implemented mathematical semantics.

## What the profiler and machine code show

We reused the maintained native profiler. Its first 4ms capture failed strict
loss/delivery requirements due timer overruns and is retained as rejected
evidence. A new 16ms capture passes unchanged gates: 719 old and 722 new samples,
zero loss/overruns, complete lifecycle, sufficient CPU coverage and fresh mapping
from the actual experimental executable. Diagnostic repetition counts differ
slightly to obtain similar duration; these samples are not speed measurements.

The profile describes physical leaves. Old/new samples include `term_drop`
64/57, constructor creation 50/39, `p111_rt_sink` 32/34 and the borrowed
`index_hash` worker 23/6.
The new path still spends time in array helpers, constructor operations and
ownership machinery. Counts this small support a direction, not precise causal
allocation of savings to compiler stages. There is no inclusive call-stack
attribution or addition of overlapping owner groups.

Machine inspection is more specific: `p148v_w` and `p148c_at` carry six uniform
arguments although they need one array and an index. Each emits two sink calls
for unused arrays, an array-read pair call, and another sink of the returned
handle. Scalar leaf readers already have narrower signatures. Therefore this
implementation has not achieved cheap raw memory access merely by selecting an
array representation. Static evidence is in native03 `program.s` around lines
6377 and 21343; the exact ELF and profile maps are in the compact capsule, while
full assembly/QBE are in the verified local closure archives.

## Ambition, outcome and next step

The **1× experiment** is complete and misses its proposed 2× complete-region
discriminator. Keeping its 1,918 lines out of production avoids adding a second
optimization implementation for no useful performance gain.

We implemented pieces of the **10× architectural plan**: one numeric identity
space across consumers, physical buffers and explicit affine unit lifetimes.
The remaining high-value question is whether the producer can create those
units directly and retain them through lowering, analyses and rendering. That
would remove a representation transition instead of merely amortizing it.
It must first demonstrate cheap native access and a substantial complete-region
win; this phase does not justify a wholesale IR rewrite.

The **100× plan** concerns reusable checked owner units, dependency-aware reuse
and bounded parallel work. It remains conditional. No cache or worker framework
was built to compensate for a failed cold-path experiment. Ambition levels label
scope; neither is a measured or promised speed multiplier.

Next, a small access experiment can cheaply falsify the current physical-storage
choice. Then test one producer-to-rendering family, or investigate semantic IDs
across parsing/checking if native access remains expensive. Phase147's lowering,
initial optimization and rendering/output consume 37.6, 24.3 and 38.9 seconds of
diagnostic thread CPU; parsing and checking/publication consume 32.0 and 31.3.
Those larger boundaries matter more than another isolated admission helper.
They are not interchangeable with the 246.17s clean whole-build wall metric.

## Cost, retention and production status

There were 56 finished guarded target jobs, totaling **427.42s (7.12 minutes)**:
297.98s native harness construction, 36.24s profiler capture/analysis and 93.20s
other checking/controls/timing. Eighteen jobs returned failure, mostly rejected
experimental source forms plus the diagnosed native ownership failure. Exact
attempts and costs are preserved. Peak observed process-tree RSS was 987.59MiB;
no OOM or resource-limit stop occurred. One attempted overlapping guard refused
before launching its target and is not counted as executed work.

The first-to-last guarded-job span was 54.69 minutes. That is not total billed
compute or the whole conversation duration: implementation, diagnosis, parallel
agent work, review and documentation occupied the remaining time and continued
outside that span. We do not have a reliable token/quota bill. Bounded agents
implemented independent consumers, built controls and falsified conclusions;
only the root ran the serial measurement lane.

All 56 guards are closed. Cold outputs were archived and verified with the
maintained retention tool; no raw files were pruned. The compact committed
capsule includes failed sources, historical methods, exact controls/results,
experimental executables and both profiler captures. Large QBE/assembly/object
files remain locally hot and in verified restorable archives. Exact historical
method bytes may be stored under a history path; a current file with the same
name is not asserted to match an earlier receipt.

Phase147's qualified N2 and the installed consolidated JS/C/QBE selection remain
available. Canonical compiler modules, runtime, protected laws and selectors were
not modified. No expensive N1/N2 or 45-program campaign was run for this rejected
performance candidate. Existing program-speed evidence is unaffected by the
absence of a production change; exact outputs of the experimental samples do
not constitute a fresh broad runtime qualification.
