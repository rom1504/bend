# P87-001: attribute native compiler cost and request growth

Status: profiles collected; append mechanism confirmed, repetition locality unresolved. [Design](../../design/phase87/native-compiler-investigation.md).

Question: why does native Lexer compilation cost5.31s initially and10.79s by call
five, while its JS sibling improves1.06s→0.476s? Native peak RSS is only40.5MiB.
Do not infer a memory leak, quadratic strings or a profiler limitation without
evidence. CPU samples and the existing runtime/source are the first discriminator.

Use exact Phase86 binary `1d45119d…`, one runtime thread and GPU off. Reuse the
Phase68 sampling method rather than rebuild for instrumentation. Check coverage,
sample loss and exact C. Compare clean versus sampled behavior; any generated-C
derivative must be saved separately and explicitly labeled diagnostic.

Three exact-image profiles produced seven exact C outputs. Primary4000us
profiles have zero overruns/drops and nearly100% CPU coverage. Five Lexer calls:
67.39% String.append leaf samples. Startup-dominated Small:62.55% term_drop +
span_fade. These are whole-process symbols, not allocation caller attribution.

Results: [Phase87 report](../../implementation/phase87/README.md).
