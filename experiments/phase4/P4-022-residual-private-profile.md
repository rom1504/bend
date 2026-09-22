# P4-022 — residual costs after private specialization

Status: complete. The plan below preceded both profiles.

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

## Result — 18:41 UTC

Both bounded runs completed with checked success, unchanged inputs and identical
actual emitted bytes. Private exclusive samples retain 28.16% generic `apply`,
9.65% `force`, 3.64% `project`, 3.01% `call` and 5.22% GC. B1 retains 21.38%
`run_loop` and substantial string comparison work. Checking/annotation dominate
both API span inventories. These single diagnostics establish no speed estimate.

Next decision: count concrete typed-worker/matcher staging sites, then apply the
[lowering design's](../../design/phase4/next_compiler_lowering.md) correctness and
material-benefit gates. Do not reopen rejected generic memoization or conclude
that all sampled application work is removable. See the
[residual report](../../implementation/phase4/residual-profile.md).
