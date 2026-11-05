# Phase163 — direct-first compilation, with measured limits

We implemented a different compilation route in Bend: construct and verify
ordinary native workers **without first constructing their generic continuation
program**. It produces working QBE executables. We also built a native compiler
that exposes this route, using the qualified N2 compiler to build it. The new
route cannot yet compile its own IO entry. This is a restricted research route,
not a replacement for the qualified compiler.

The revised native prototype reduces complete compilation requests by **22.6%
and 34.7%** on two real compiler computations. Their generated runtimes are
respectively **0.993× and 1.070×** the qualified reference. A matched-policy
experiment also produces byte-identical final QBE while avoiding real generic
IR construction and verification. However, only **2 of 8 unrelated transfer
computations** are admitted by the closed direct route. The compact-App
representation experiment did not establish a useful speedup.

**We have not demonstrated a 5× full-build gain or a 50-second self-build.**
The qualified Phase152 source, native image, installed selection and its
249.222-second cold observation remain unchanged.

[Design](../../design/phase163/README.md) · [Exact metrics](metrics.json) ·
[Reproduction](reproduce.md) · [Research cost](cost.json) ·
[Retention](retention.json) · [Evidence](evidence/README.md).

## Native measurements

Starting HEAD `a8b598980ef7016133484eb28563b63bd5e30f09`, branch
`selfhost/bootstrap`. Same qualified producer/runtime/toolchain, one CPU3 lane,
one worker, GPU off, fresh processes, unchanged source/Base/carrier per pair.
The baseline is our qualified compiler, **not upstream**. Filesystem caches were
not evicted.

| Real compiler workload | Qualified source→QBE | Direct-first, optimized | Time reduction | Generated runtime/reference |
|---|---:|---:|---:|---:|
| `book_final_reverse` plus complete-result traversal |0.9909s|0.7672s|22.6%|0.993×|
| `lookup` plus complete-result traversal |1.5630s|1.0200s|34.7%|1.070×|

Compilation values are medians of two observations in reversed order. They
include process startup, file reads, authenticated cached Base preparation,
source checking, lowering, verification and QBE output. They exclude subsequent
QBE machine construction, assembly and linking. Generated-runtime values are
medians from four reversed-order pairs per policy. Raw samples remain available;
these are bounded controls, not confidence intervals or broad benchmark scores.

The workloads use the actual maintained helpers. They include cached/plain
lookup, duplicates, empty/Unicode/missing names and a hash collision. Independent
complete-record builders pass eight small controls. Larger workloads construct
40,000/100,000 logical returned definition records (not measured allocations)
and visit every field through a stack-safe
worklist; two checksums and record counts match an independently implemented
oracle. Small complete-output comparisons remain the stronger observation gate.
The repeated kernels remain in generated code; source answers are not embedded.

The first direct version omitted too much optimization: reversal ran 1.57× and
lookup 1.16× the reference. We recovered most of that loss by composing existing
bounded inlining/scalar simplification and source-derived cold-constructor facts.
No new ownership assumption or weakened verifier was introduced.

| Direct policy | Reversal runtime/reference | Lookup runtime/reference |
|---|---:|---:|
| Initial direct workers |1.570×|1.157×|
| Existing inliner/scalar simplification |1.436×|1.107×|
| Existing cold-constructor analysis |1.104×|1.121×|
| Both |0.993×|1.070×|

The cold analysis establishes 31/163 constructors cold in reversal and 23/163 in
lookup. The original direct prototype marked all 163 hot. The existing table
renderer then enables the existing runtime capability for skipping unnecessary
sealing. These are static proof/admission facts, not dynamic call counts. The
per-policy ablations support the mechanism; they do not assign every saved cycle
to sealing. Current range processing is a no-op, so we did not add a redundant
range pass.

## What the architecture actually removes

`direct-first.bend` separates semantic planning from rendering. It reuses checked
preparation, static construction, direct-candidate admission, tail-SCC handling,
ownership operations and the existing final direct verifier. Its scheduler-ID
map is truthfully empty. Unknown calls, escaping function identities, unsupported
effects and ordinary recursive cycles are refused. Tail recursion retains the
existing loop semantics.

`direct-executable.bend` adds exactly one real, independently checked entry
adapter using the existing runtime ABI. Constructor/static/readback metadata
comes from the actual source. It does not invent empty generic bodies or claim
that they were verified. The actual adapter body and fixed ABI contract are
explicit. There are 22 finite direct/adapter/optimization controls.

The initial hosted screen showed 2.8×/4.0× lower backend time and 62%/77% less QBE
for the small reversal/lookup inputs. Those comparisons also change optimizer
policy, so they are not a clean estimate of generic-IR cost alone.

We therefore built `direct-generic-control.bend`: run the genuine current raw
generic+direct lowering once, independently verify its real original program,
then select the same direct workers and mode3 policy. Both routes must emit the
**exact same QBE bytes** before timings are admitted.

| Matched-policy hosted control | Generic segments built and discarded | Direct workers | Generic route median | Direct-first median |
|---|---:|---:|---:|---:|
| Reversal workload |149|13|2.447s|1.718s|
| Lookup workload |310|34|3.116s|2.606s|

This screen measures 29.8%/16.4% less work in the timed route with identical final
code. There are only two samples per role and visible hosted-runtime variance.
The result establishes a real removable category of work; it does not establish
that percentage for the native whole compiler. Raw construction timings include
shared/static/direct preparation and must not be labelled generic-only time.

## Transfer and the missing interface

Eight families were selected before execution. Only the final IO benchmarking
wrapper was replaced with pure readback at the exact frozen input. All other
declaration bytes and complete output oracles are pinned. String results use an
explicitly audited quoted readback adapter; original oracles remain unchanged.
These are single-result transfer controls, not altered frozen timing benchmarks.

`local-fold` and `coverage-closures-64` compile, execute and match their independent
outputs. Edit distance, lexer, tree-bitonic, mandelbrot, Unicode text and record
aggregation conservatively refuse because the main computation lacks a complete
admitted direct entry. Refusals are not conformance passes. Existing native
correctness/runtime qualification remains unchanged.

The strongest next step is a **hybrid direct-first boundary**. Preserve real
closure factories and scheduled continuations where necessary; construct an
admitted worker's direct adapter before generating its redundant generic body.
The concrete [hybrid design](../../experiments/phase163/hybrid-direct-first.md)
identifies two obligations that cannot be skipped:

1. Independently verify mixed generic segments and actual direct adapters.
2. Preserve verified direct-import registry entries, so generic callers retain
   fast native calls instead of falling back to scheduler transitions.

Numeric function IDs are assigned after symbolic references, so consistent new
IDs are feasible. Exact old QBE bytes are not a valid requirement for that larger
change. The offline qualified-image census finds 1,448 direct workers with
scheduler entries; it does **not** prove every one of 48,096 continuation segments
can disappear. Start with one mixed computation before changing the full compiler.

## Compact terms: useful negative evidence

The separate App overlay replaces 3 logical objects/15 requested words with
2/8, given existing operands. A direct fixed-two-child node would break existing
arbitrary-child structural laws, so the experiment uses canonical zero/one/two/
many child variants. Direct projections/substitution avoid compatibility lists
where practical. Legacy decoding, quantities, spans, malformed child counts,
literal and Lambda metadata remain supported.

Sixteen finite structural controls pass. Three source inputs have identical
complete hosted parser and checker observations. An independent review checked
the observer and documented its limits: candidate accessors could self-mask a
coupled bug, and parse observations omit prefix-eligibility/trace internals.
This is not a universal proof or public host/cache ABI qualification.

Two native binaries then checked the identical 182,039-byte/645-declaration
compiler workload, with two reversed pairs and complete result equality:

| Native stage median | Original | Compact App |
|---|---:|---:|
| Cold Base preparation |1.3995s|1.3890s|
| Parse/load |2.1120s|2.2195s|
| Checking/publication |1.5805s|1.6455s|

Parse+check is 4.7% slower in this small screen. Initial observations were near
neutral; there is no persuasive speedup. Complete observation/write costs about
11s separately and are excluded from these stage figures. We stopped before a
full-source campaign. The local allocation model was insufficient: App frequency,
consumer reconstruction and additional dispatch must be measured before a broader
typed-term migration. The overlay remains experimental and is not promoted.

## Reliability, acquisition cost and limits

Protected maintained declarations, production source and selectors are unchanged.
Pinned upstream independently accepts the optimized prototype through source
checking, then reports 2723 unsafe/foreign-dependent definitions at the proof
verdict boundary. Its exit 1 is retained; this is **not BendTT proof acceptance**.
See [the boundary interpretation](source-check.json).

The optimized native prototype itself took 146.02s to build through qualified N2,
emitting 84.73MB QBE from 1.128MB experimental source. That smaller, restricted
compiler is a different input/functionality set; 146s is not a new full self-build
score. The first acquisition hit its 144MiB disk budget during assembly. We
retained the failure and rebuilt its captured complete QBE in 11.08s instead of
repeating source compilation. One oversized hosted acquisition also stopped at
its 2GiB RSS cap; splitting it and reusing the existing baseline API solved that.

Even ignoring research/qualification cost, 146s acquisition needs roughly 270–650
matching small requests to amortize the measured per-request savings. We have
not demonstrated recursive research acceleration or a generally worthwhile
replacement research compiler.

The 37 guarded jobs total 771s (12.9 minutes): 437s for native acquisition and
recovery, 78s for hosted acquisition/source controls, 224s for compilation and
semantic measurements, and 32s for independent checking, small machine builds,
transfer and runtime measurements. This is target-job wall time, not total
research time or agent compute. Twenty-eight commands succeeded; nine exited
nonzero or were stopped, including the separately interpreted unsafe verdict.
The phase adds 1,950 experimental Bend lines and zero production lines. All runs
are closed; useful failures and exact source/method identities are retained.

The practical result is a working, measured architectural capability and a clear
next integration boundary. Preserve cold/ownership information when removing
generic representation; do not simply discard optimization passes. Pursue the
mixed direct/generic experiment, keep the qualified compiler for general use,
and defer the compact-App migration and full self-host campaign until their
specific gates are justified.
