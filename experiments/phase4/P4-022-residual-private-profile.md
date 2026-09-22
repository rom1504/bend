# P4-022 — residual costs after private specialization

Status: planned, before collecting the new profiles.

Question: which costs remain in the final private compiler, and how do they
compare with checked B1 on the same real compiler-core source? The initial public
H profiles strongly implicated generic calls. Those old percentages cannot be
assigned to the now-specialized image or used to predict the next speedup.

Use the already checked 60,909-byte, 312-declaration core fixture from the
corrected four-way matrix. Both selected compilers must emit exact SHA
`016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186`.
Select final B1 `0653f21e…` and private profile `4318bbcd…`, with the same frozen
host, canonical Base and runtime. Record exact consumed identities.

Run the existing bounded profiler separately on each compiler after a CPU becomes
available. Limit each diagnostic to 90 seconds, 3 GiB heap, 4 MiB stack, 128 KiB
root input and a 10,000-microsecond sampling interval. Prime Base and discover
dependencies before sampling, as the tool already does. Keep all other compiler
measurements off the selected physical core. Preserve timeouts and partial
reports; do not raise limits or retry a full-source inspector profile.

Require checked success, exact emitted bytes, unchanged consumed files and a
complete profile before interpreting the samples. Attribute exclusive samples,
garbage collection and top-level API spans separately. Profiler overhead,
discovery/JIT warmup and sampling uncertainty prevent treating profile durations
as a controlled speed comparison. The existing uninstrumented matrices supply
performance evidence.

Decision: use the resulting residual distribution to rank the next experiment.
Only a concrete mechanism with a cheap falsifying gate earns implementation.
Do not multiply old percentages, equate allocation counts with time, or infer a
whole-compiler gain from one sampled helper. This diagnostic does not modify a
compiler image, runtime, ordinary emitted program or any of the 59 Bend modules.
