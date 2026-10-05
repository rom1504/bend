# Phase51: optimize mechanisms demonstrated by V8 profiles

## Objective and starting point

Improve generated-program speed while preserving the current public semantics.
Start from installed Phase48 RNFA04 and the unchanged Phase49/50 diagnostics.
The last whole-corpus result is 2.678937× pinned TypeScript across 45 points;
it is a historical reference, not a denominator for new instrumented timings.

Phase50 finds two distinct opportunities: guard ancestry exceeds half the CPU
samples in 11/45 points, while Morning/Evening/MapSet allocate about 28–30× TS
bytes and spend much of execution in generic application/matching. V8 refuses
to inline `apply` because of its bytecode size. Expression producer/consumer
transport is a later independent opportunity, not part of this first change.

## A. Cheaper fresh checks

Start with equivalent checks before changing their scope. A first candidate
batches String/String.prototype descriptor acquisition using captured native
reflection, retaining every key, descriptor, prototype and global-identity
comparison on every entry. Those captured objects are ordinary objects rather
than caller-supplied proxies. Native descriptor retrieval must not invoke their
property getters. Compare exact mutation/refusal and reentry behavior with the
original guard and ordinary public execution.

The experiment can lose: descriptor-map allocation and general native machinery
may cost more than the existing repeated calls. Reject it if clean timings do
not improve. A second small equivalent-check shape may be tested if profiles
explain the failure. Do not erase checks because dependency names lack String
operations. Narrowing scope requires a complete source/runtime observation
argument; caching permission across calls remains unsupported.

## B. An inlineable generic application path

Keep `apply`'s branch tests and property reads in their original order. Extract
the IO action, type application, nonfunction/error and overapplication bodies
into cold helpers. Keep the common bound-argument preparation, exact-saturation
and partial-application behavior intact. Do not cache mutable properties, assume
all calls are saturated, or reuse argument vectors without an ownership proof.

First ask V8 whether `apply` becomes eligible and actually gets inlined. Then
measure clean execution and allocation: successful inlining is a mechanism,
not sufficient evidence of speed. Boundary controls cover getters/proxies,
partial and overapplication, null/IO/type values, owned/shared vectors, throws,
reentry and exact-entry permission. A counterexample rejects the prototype.

## Efficient sequence

1. Freeze this design, the RNFA04 input identities and a file per hypothesis.
   Agents work on independent prototypes, controls and review; root alone runs
   generated code or compilers. Initial feedback should take minutes.
2. Make exact saved-JavaScript derivatives of retained current output, recording
   matched old/new spans and hashes. These are prototypes, not checked compiler
   outputs or releases. Run boundary controls before expensive measurement.
3. Use a few fresh rotated clean processes on affected cases and canaries. Run
   separate targeted CPU/allocation or V8 traces to test the proposed mechanism.
   Stop weak ideas early. Avoid a full corpus after each edit.
4. Integrate surviving changes into authoritative runtime modules or the Bend
   emitter. Rebuild generated runtime with `src/runtime/js/build.mjs`; build one
   checked B1 for the combined candidate, then acquire outputs once for reuse.
5. Run focused semantic controls, maintained runtime/backend-relevant gates,
   core canaries and affected-family comparisons. Broaden once for a final
   candidate when the change warrants it. Report per-point regressions and all
   failed attempts; no isolated-program result becomes a whole-corpus claim.
6. Install only a qualified useful version, verify the installed package and
   relevant CLI behavior, and publish design, code, report and exact evidence.
   If neither experiment qualifies, retain the previous release and document
   the negative results rather than selecting an unsafe or slower change.

## Control and measurement boundaries

Use pinned Node24.18.0 / V8 13.6.233.17-node.50, CPU3, 1024 MiB Node heap,
2048 MiB process-tree RSS ceiling, 4096 MiB memory headroom and bounded output.
No concurrent target, build, compression or timing work. Preserve exact whole
result oracles, cold/import costs separately from warmed execution, all repeats,
and profiled durations separately from clean timings. For small changes require
repeatable evidence across multiple relevant inputs, not one favorable median.

Source edits do not touch human-written `bend2/bend.ts`. All 103 pre-existing
files and closed Phase45–50 evidence remain unchanged. Commit/push checkpoints
are authorized; no PR comment is authorized. A checked derivative does not imply
a new self-hosted fixed point or broader frontend/native conformance.

Record target process occupancy separately from total phase elapsed time. At
each checkpoint ask whether the next operation will change a selection decision;
skip redundant builds/profiles and stop expanding a failed hypothesis.
