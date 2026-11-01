# Phase150 profiler admission audit

Read-only workflow/source/receipt review, 2026-11-01. No profiler capture,
instrumented build or target execution was performed for this audit.

**Use direct complete-region standalone parser measurements next; defer a new
profile until a quiet reporting entry exists.** The current standalone image
cannot honestly satisfy the maintained profiler's output admission contract.

## Admission obstacle

The current source's `p144pn_report` prints three variable lines (`prepare_ms`,
`parse_ms`, `observe_ms`) followed by a deterministic hash. The maintained
[`freeze.py`](../../selfhost/tools/profiler/freeze.py) and
[`run.py`](../../selfhost/tools/profiler/run.py) accept exact stdout, or a fixed
prefix followed by **one final unsigned integer line**. Neither contract covers
this output. Do not filter away output, introduce a custom capture bypass or
weaken the gate for this phase.

The smallest future source change is a separately checked quiet reporting entry
that prints only the existing deterministic hash while retaining the parse and
result-observation computation. Bind that output to an independent reference;
a target-generated expected hash alone is not an independent oracle. A quiet
driver produces a new image and requires its own source/object/FID bindings.

## Current recorded identities

These are the pins recorded in
[`parser-reference-native01/report.json`](../../selfhost/build/phase150/parser-reference-native01/report.json)
and [`assets-runtime.json`](../../selfhost/manifests/assets-runtime.json).
They are not a new rehash or runtime-equivalence qualification.

| Asset | Exact path | SHA-256 |
| --- | --- | --- |
| Standalone source | `selfhost/build/phase150/parser-source01/reference.bend` | `9174372bee83a1b566fc86339182f004cde6a7aa258097636135693c051af826` |
| Executable | `selfhost/build/phase150/parser-reference-native01/program` | `4b19c9ac9abdc1521f1fc9130850b2d6a1ab27861ce9af998a5f16a57b43c7ff` |
| Program object | `selfhost/build/phase150/parser-reference-native01/program.o` | `87005a7b3820dcbd897799b17098bb91804729598110a0e85d5e295ed2e76293` |
| Retained QBE | `selfhost/build/phase150/parser-reference-native01/program.ssa` | `75b26e47d35d203a7887e50f1fedaa25892860083019b691f42df2b5c2ba52f3` |
| Linked runtime object | `selfhost/.assets/native/qbe-runtime.o` | `2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3` |
| Runtime source | `selfhost/src/runtime/qbe/runtime.c` | `aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333` |
| Runtime header | `selfhost/src/runtime/qbe/runtime.h` | `9b19b8d6ae1c8f07759041201c2692c20d9612393819e2bbc597deba44679d12` |
| Primitive header | `selfhost/src/runtime/qbe/primitives.h` | `ecbdfe62b875fc20e5805840b83c3779ed8fb8fb1de83c543ba1ce1217165d20` |

The actual retained QBE descriptor declares ABI `11101`, size192, **11,824
segments**, main FID **11,818**, register/result widths **21/1** and capabilities
**5**. These are this image's identities, not reusable stage-marker IDs.
The build receipt names Phase147 N2 producer
`selfhost/build/phase147/integrated-sequel02/n2/program`, SHA
`ab5662a17690f6814834074442905fec2f061a67203e66c3008d51d48727ca32`.

## Economical future route and gates

After admitting a quiet image, start with physical sampling. Add active dispatch
only if leaf attribution leaves the decision unresolved. The maintained
[`runtime.py`](../../selfhost/tools/profiler/runtime.py) can create reversible
diagnostic hooks and relink the exact retained program object; instrumentation
alone does not require recompiling the Bend parser. Preserve the runtime recipe's
`-O2 -std=gnu11 -ffp-contract=off -DP144_SINGLE_MUTATOR_RFC=1`, one thread and GPU-off
policy. Run its small independent-output gate before a full input capture.

Extract a fresh owner/FID map from that image's QBE with
[`owners.py`](../../selfhost/tools/profiler/owners.py), pin its actual producing
source/receipt and emitter-contract sources, then bind the segment table against
the linked ELF using [`attribute.py`](../../selfhost/tools/profiler/attribute.py).
Old Phase147 addresses, FIDs and stage boundaries cannot be copied. An owner is
a lowered definition, not a reconstructed logical stack.

The retained ordinary sampler at
`selfhost/build/phase147/profile-final-build01/sampler-base/sampler.so` has recorded
SHA `fa2897d38b6c2060f744a8493e07d60c13a900fecc3f3794873929b629d0c630` in its adjacent
`report.json`. It is a possible authenticated reusable asset, subject to checking
that receipt and its dependencies; it is not necessary to reuse the stage sampler
or introduce new stage instrumentation.

Keep the established quality gates: exact status/output, unchanged pins, zero
loss/overruns, intact signal handler and main-thread shutdown, at least500 accepted
samples, at least95% sampled-thread/process CPU coverage, and plausible timer
delivery (0.8–1.2 of expected after startup). Absolute whole-child estimates also
need95% capture-window coverage and independent clean CPU timing. Use two periods
to check aliasing; do not lower sample thresholds. The tools report diagnostic
overhead separately; there is no automatic numerical overhead ceiling that proves
neutrality. No event counters or expanded stage campaign is justified yet.
See the [maintained profiler guide](../../docs/self_hosted/PROFILING.md) and
[stage contract](../../selfhost/tools/profiler/STAGES.md).

## Comparison boundary

The [Phase147 profile](../phase147/final-profile.md) measured32.025s of diagnostic
parse/load on a3,010,912-byte request using its full compiler and exact stage
boundaries. The new lexer experiment uses a different standalone image and
approximately3.07MB input; its4.42→0.787s observation isolates lexer work.
**32.025 minus the lexer saving is not a measured residual parser cost.** Runtime
layout, input, entry/exit boundaries and surrounding ownership work differ.

Measure reference/candidate complete standalone parser regions directly on the
same frozen input and preparation, preserving exact token evidence and independent
result checks. That establishes transfer and the remaining interval before any
new profiling expense. The current driver's explicit parse clock excludes file
reads and initial String creation, Base preparation and result hashing; whole-child
wall/CPU remain a separate measurement.
