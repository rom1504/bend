# Phase157 — bendc tested on actual compiler work

The same captured compiler workload does **not** show an automatic advantage
from replacing our QBE runtime with bendc's direct-call/GC architecture. The
ranking changes with the amount of work per process. The workload executable
compiled by our qualified QBE compiler executes repeated owner computations
slightly faster than its upstream C counterpart, but pays
more to load and prepare this captured input. bendc GC produces compact code but
is slower than upstream on both measured boundaries. Its RC image fails the
ordinary full-output control and receives no performance score.

[Design](../../design/phase157/README.md) · [Metrics](metrics.json) ·
[Cost](cost.json) · [Independent review](../../experiments/phase157/independent-review.md) ·
[Reproduction](../../experiments/phase157/README.md).

## Controlled result

One identical 387,345-byte checked Bend source, one 75,064-byte Base, one captured
2,979,167-byte compiler book. Each batch runs five actual compiler owners through
original lowering, scalar optimization, the original independent verifier,
complete QBE rendering and checked file writing. All successful roles match the
existing independent 173,582-byte output oracle exactly, before and after timing.
This is **one extracted compiler workload, not a full compiler request, self-build
or the 45-program benchmark**. It exercises a legacy direct-helper pipeline;
it does not replay every selected modern compiler analysis.

Six balanced permutations per measurement, serial CPU3, one runtime worker, GPU
off, same pinned Clang-O3 for C products. Every observation is a fresh process;
input decoding, metadata preparation, writing and normal runtime teardown are
included. Teardown does not force a final tracing collection. Timing stdout is
empty because every freshly generated result is written to`/dev/null`; separate
full-output controls write the real result. No startup subtraction.

| Backend/runtime | One batch, median | Ratio to upstream |16 batches, median | Ratio to upstream | Peak RSS,16 batches |
|---|---:|---:|---:|---:|---:|
| Pinned upstream C/Clang |0.692s|1.000×|6.491s|1.000×|111.6MiB|
| Qualified Phase152 QBE |1.405s|2.029×|5.935s|0.914×|81.4MiB|
| Adapted bendc C, tracing GC/no early free |1.072s|1.549×|13.824s|2.130×|1185.6MiB|
| Adapted bendc C, explicit RC |failed output gate|—|not measured|—|—|

CPU medians closely track elapsed medians:16 batches consume 6.490s upstream,
5.934s QBE and 13.822s GC. Raw times and source/product identities are retained.
These small samples establish neither confidence intervals nor broad parity.
The control/calibration ladder uses 0, 1, 4 and 16 batches. Zero-repeat controls
still load/decode the complete book and prepare the owner contexts; the first
ladder measured about 0.253s upstream, 1.019s QBE and 0.476s GC. That is a specific
capture/setup cost, not the full compiler's frontend time. The fresh single-batch
follow-up independently confirms the different ordering.

## What disappeared—and what did not

No production optimization was implemented. We established a comparable
experiment and tested architectural assumptions against actual compiler work.

[Machine/source inspection](../../experiments/phase157/code-shape.md) finds
real differences: bendc uses direct functions and output-pointer helpers;
upstream and our path retain continuation segments around some candidate
computations. Our lookup already has a direct worker, but substantial ownership
transport and boxed/raw admission remain. Upstream's borrowed String equality
keeps a raw scalar result and places cleanup outside the character loop. These
are useful concrete designs to study, but smaller functions and fewer static
calls did not predict the overall winner here.

The separate`BEND_GC_STATS=1` run executes the same 16-batch work in 13.818s.
It reports 135 collections (7 major), summed rounded collection intervals 1.078s
and marking intervals 0.761s. The exit heap is reported as 1035MiB. Collection
intervals are instrumented elapsed intervals, not exclusive CPU; heap figures
are rounded and the exit handed-out counter is not total allocation traffic.
Still, the measured collection intervals alone do not explain the roughly 7.3s
clean gap to upstream. Allocation, generated computation and representation
work remain unpartitioned. We did not collect physical-PC samples in this
cycle. Hardware instruction counters are unavailable in this environment;
static disassembly counts are not substituted for them.

GC is both slower and much more memory hungry on this particular repeated
pipeline. RC exits 1 with`bend: runtime fail-stop` before producing the expected
output. The failing source is an ordinary finite compiler workload, not a fault
probe. Its cause is **unlocalized**; do not call it an RC-runtime bug, stack
overflow, memory exhaustion or an effect-adapter bug without further evidence.
Do not treat its short failed runtime as a speed result. No unsafe failure
campaign, sanitizers or repeated fault reproduction was launched.

## Compatibility work and negative evidence

bendc is pinned to[Lulzx/bendc at 56edcc65](https://github.com/Lulzx/bendc/tree/56edcc65b3527a75838011682c231072d5b46097).
We verified the public seed C and runtime header against their Git blob hashes.
Its direct native emitter targets AArch64; this x86_64 experiment uses C/Clang.
The seed is a third-party bootstrap input, not independently rebuilt through
bendc self-reproduction. Its acquisition took 88.38s and is separate from workload
execution and subsequent emission/build times.

1. Original source is accepted by upstream and QBE; bendc's emission parser
   rejects a comma after a multiline expression lambda. We normalize 368 audited
   whitespace boundaries, preserving tokens and all compiler algorithm bodies.
   The normalized source independently checks and produces byte-identical
   upstream C and byte-identical QBE/assembly/object. This is checked emission
   equality, not an AST theorem. All final roles use the normalized source.
2. Our pinned Base has older two-argument IO registration. bendc's header needs
   an explicit pre-wait policy. The experiment adds zero at exactly nine
   generated-C registration sites. All 30 related callbacks/helpers then match
   bendc's own seed definitions exactly. Zero preserves their callback-managed
   IO scheduling; it is not a root/ownership bypass. Raw and adapted C are both
   retained. Production Base and runtime stay untouched.
3. Upstream and bendc include`argv[0]` in`IO.args`; our qualified QBE entry omits
   it. A common`exec -a` launcher presents identical logical Bend arguments to
   all three. The first unadapted argument control failed and is retained.
4. GC explicitly uses`BEND_RC=0 BEND_NO_FREE=1 BEND_AUTO_PAR=0`. RC uses
   `BEND_RC=1 BEND_AUTO_PAR=0` with`BEND_NO_FREE`absent. Other compiler knobs are
   cleared/default. No automatic hybrid selection, implicit parallelism or
   changed optimization pass settings are hidden in these labels. GC-versus-RC
   was intended as an ablation, but RC's failure prevents a valid timing ablation.

See the complete[backend/ABI audit](../../experiments/phase157/bendc-method.md).
The smaller publication-replay fallback was prepared but not checked or run;
it contributes no measurement or conformance result.

## Acquisition and research cost

| Workload executable route | Checking/emission | Machine construction | Observed total |
|---|---:|---:|---:|
| Upstream C/Clang, original source |28.90s|56.72s|85.62s|
| QBE, normalized source |overlapped with QBE|assembly/link included|51.99s|
| bendc GC, normalized source |19.19s|56.41s|75.59s|
| bendc RC, normalized source |21.02s|128.78s|149.79s|

These are workload-image acquisition observations, not throughput measurements
of the complete compiler. QBE uses the qualified image's prepared Base; C
emission performs its own source checking/preparation. Upstream's normalized
source re-emits the exact same C in 30.08s, allowing the already-built machine
product to be reused. GC reuses its exact successful emission after the ABI
build refusal. No failed cost is silently discarded: 16 guards total 800.37s
(13.34 min), including seed acquisition, duplicate compatibility qualification,
failed controls and runtime measurement. Research, agent preparation, report and
retention time are additional. Three bounded agents handled preparation/audits;
root ran every target in one serial lane. All 16 guards are sealed. Peak limits
remained 2GiB RSS with 16GiB host headroom and 5GiB disk reserve; no OOM or full
compiler rebuild occurred. Exact evidence is in the[capsule](evidence/capsule.json).
Extracted compiler source fixtures and rejected method revisions live in that
capsule rather than adding parallel compiler implementations to HEAD.

## Decision and next experiment

Keep QBE and the qualified Phase152 compiler. This result does not justify a GC
runtime migration or replacing the backend, and does not overturn the measured
Phase156 publication-provenance gain awaiting integration.

The best next architectural test is a **measured immutable-reader boundary**:
profile actual lookup/String/owner consumers inside the native compiler, then
carry borrowing and raw scalar results through one hot caller-to-callee boundary
without a boxing or generic ownership round trip. Use upstream's existing
borrowed String loop as the concrete reference, retain direct-worker fallback
and independent output checks, and require transfer to another consumer. First
measure time in that boundary; the static 902-byte/601-byte workers and lookup
call counts are not a gain estimate. Existing scalar borrowed readers should be
composed or extended, not rediscovered as a new optimization.

Separately, profile the capture's unusually slow QBE input preparation before
using this transport as a research benchmark again. That can improve experiment
latency, but must not be promoted as a production compiler speedup unless the
same work is hot there. The strongest ecosystem lesson is to borrow specific
representations and calling conventions, then measure them end to end. Direct
calls, compact code and deferred reclamation are not sufficient evidence of a
faster compiler.
