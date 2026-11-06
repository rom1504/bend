# Phase171 checkpoint: 4.21% faster full-source compilation

The experimental native compiler builds the fixed full maintained source in
**180.677s versus a fresh 188.620s baseline**, including QBE, assembly and linking:
**7.942s / 4.21% less time**. Both produce identical QBE, assembly and object
bytes. This is one observation per role, candidate first, not a repeated median.
The 100s objective remains open. The candidate is **not integrated or promoted**;
installed Phase170 and its rollback remain unchanged.

[Design](../../design/phase171/README.md) · [Metrics and receipt pins](metrics.json) ·
[Reproduce](reproduce.md) ·
[Original profile](../../experiments/phase171/current-profile.md) ·
[Candidate profile](../../experiments/phase171/candidate-profile.md) ·
[Follow-up experiments](followup.md).

## Controlled result

| Boundary | Baseline | Candidate | Less time |
| --- | ---: | ---: | ---: |
| Native full source → executable |188.619676s|180.677191s|4.21%|
| Same build, compiler + QBE relay |182.771009s|174.828495s|4.35%|
| Hosted B1 Map request |17.201471s|16.217614s|5.72%|
| Hosted B1 real-verifier request |30.168110s|29.031967s|3.77%|

The native input is the unchanged 3,150,535-byte Phase170 source,
SHA256 `434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71`.
Prepared Base, one CPU3 lane, runtime and machine toolchain match. Cold means a
fresh compiler process/request, not filesystem-cache eviction. QBE and compiler
pipeline elapsed times overlap; do not add them.

The candidate image is a genuine experimental **native N1**, acquired using the
installed native N2 from the larger 3,161,409-byte candidate source `74cd7de3…`.
Comparing its execution against installed N2 on the same original input does not
establish candidate N1→N2 self-reproduction. Nor should its acquisition input be
substituted for the fixed benchmark workload.

Full output identity is97,488,970 QBE bytes, SHA256 `661b6266…`; assembly
`5309933d…` and object `40f7fec1…` are also equal. Whole linked ELF hashes differ
(`dfdb9416…` versus `9be2c1cd…`). This checkpoint has not independently audited
their loaded segments and makes no stronger ELF-identity claim. Full hashes and
receipt paths are in `metrics.json`.

## Four combined changes

All changes remain explicit experimental Bend overlays:

1. **Stop rejected direct lowering early.** Nine call sites stop lowering later
   let/branch work after the first definite failure. Successful complete records,
   first diagnostics, candidate slots/names and SCC duplicate handling remain.
   Failed partial bodies/fresh counters may intentionally differ.
2. **Delay frame/fusion planning until eligible.** Four planner entries retain
   their original complete results while avoiding work rejected by the outer
   ABI, size or existing-callable conditions.
3. **Reuse one scalar catalogue during nested retries.** A request-local cache
   reuses the exact catalogue for the same immutable prepared book. Failed
   schemas do not initialize it; existing errors and final verification remain.
4. **Narrow private publication-event history.** The real checking world remains
   unchanged. A separate history view retains the authoritative lookup index and
   bound, with raw rows only where constructor observations require them.

The native source assembler retains all 8,414 canonical declarations, replaces 16
definitions, adds 28 declarations and 10,874 bytes, and prunes none. It verifies
original replacement signatures, native main, protected declarations and exact
inverse recovery of the parent source. This is modest experimental complexity
growth, not a simplification result. Catalogue helper copies/private history
representation need consolidation if accepted into maintained code.

Details: [fail-fast](../../experiments/phase171/fail-fast.md),
[catalogue](../../experiments/phase171/scalar-catalogue.md),
[publication history](../../experiments/phase171/publication-history.md),
and `selfhost/tests/phase171/lazy-admission.bend`.

## Correctness and coverage

The combined checked API passes **77 finite controls**: 22 complete-success/first-
error lowering cases, 6 SCC cases, 32 complete planner cases, 12 catalogue cases and
5 history-observation streams. These are finite source/compiler-data checks,
not an independent BendTT theorem or all-language conformance.

Hosted Map and real-verifier requests have exact complete baseline QBE. The
actual native candidate also emits those exact products (1.607s and 3.991s,
respectively; no paired native-small speed claim). Both native full-source runs
match the retained independent Q3 oracle, including complete stream digest.
This checkpoint does not execute a new broad generated-program runtime suite;
the request reports explicitly mark their recorded runtime oracles unexecuted.
No new JS/C qualification, upstream speed ratio or installed capability is claimed.

A separate checked-frame-import prototype passed 9 finite recursive-tree
compiler-data controls. **Its real-verifier inspection found zero imports,
zero added workers and zero direct/transitive added callers** from 93 old private
functions. That is a coverage-negative result, not evidence for an optimization
speedup. No generated execution or broad compiler claim follows from those
compiler-data controls. See
[the import prototype](../../experiments/phase171/checked-import-prototype.md)
and `import-inspect-verifier01/report.json`.

## What the new profile tells us

Both original and candidate diagnostic captures pass exact output, marker,
coverage and zero-loss gates. Their disjoint stage totals change 179.961→172.609s.
The largest reductions occur in scalar finish/retry 8.635→3.807s,
check/publication 21.239→19.027s and render/output 32.451→30.454s. Raw candidate
production changes only 25.514→24.985s; registry preparation remains about 12.2s.
Parse/load rises 28.742→29.545s.

These are combined candidate observations; they do not causally isolate the
four patches. Instrumentation, run variation, moved work and ownership effects
remain. In particular the source-motivated catalogue/publication explanation is
consistent with the intervals, not independently measured per-patch savings.
The comparison supports retaining this bounded candidate for further work, not
spending immediately on broad qualification of a purported 100s breakthrough.

The root-tied borrowed descendant experiment is now closed without integration.
It passes complete values and47 finite controls, but lookup is neutral and the
real verifier improves only1.25% despite99.535% promotion coverage. Three other
small exact-output cleanup experiments are also neutral. See the
[follow-up report](followup.md) for retained failures, measurements and the
runtime-caller profiler improvement. The original four-overlay result above
remains the best measured full-source build; no follow-up speedup is added to it.

## Cost and remaining gates

At this checkpoint, 40 terminal guarded jobs total **1,254.77s (20.91min)**,
including 10 nonzero attempts. Principal evidence jobs account for 861.85s. These
are summed guarded elapsed times, not total session time, agent reasoning time,
exclusive CPU or quota usage. Every included guard receipt is hashed in metrics;
failed source/control attempts remain visible. Guards use CPU3, explicit
RSS/disk limits and the 5GiB reserve. No crash/OOM cause is inferred from a kill
code without its receipt.

Before promotion: complete the architectural experiment or reject it, decide
which supporting patches justify their complexity, repeat promising clean
measurements, qualify actual candidate self-reproduction and representative
behavior, then integrate with the existing protected verification/release gates.
This checkpoint installs nothing and posts no PR comment.
