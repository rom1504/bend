# Phase179 — compare complete checked compiler builds

User question: does bendc's roughly ten-second self-compilation remain much
faster when measured through a complete executable, like our roughly180s build?

Use the exact historical bendc9c54842e source/seed/Base already authenticated in
Phase158. Its8.81s result was checked C emission. Measure its actual checked `-o`
CLI, including Clang-O2 and linking, on this same CPU3. Give both systems cached
runtime objects, fresh compiler processes, fresh program outputs, one worker and
GPU off. Filesystem caches are not flushed; no program IR/object is reused.

Copy the historical seed executable to a fresh isolated asset directory because
its CLI writes `bendrt.o` beside the real executable. Build that runtime once,
outside timed program builds, and record the cost. Preserve original sources and
seed. Set `BENDC_RT`, `TMPDIR`, and `CC` explicitly. A small CC transport wrapper
records the actual Clang interval and preserves emitted C before the CLI removes
it. Its small copy/launch overhead is included in total time and reported.

For ours, execute the explicitly bound Phase177 N1 on its own exact Phase177
source, through maintained streaming QBE construction, assembly and linking.
Compare all emitted QBE with the independent Phase175-produced N1 oracle. This
is a real same-source-generation self-build, slightly different input from the
historical176.9s fixed-Phase170 benchmark. Current Phase178 cleanup has no new
native executable and is not silently substituted.

Run two observations each in bendc/ours/ours/bendc order if the first pair passes.
Separate compiler work from machine construction where measurable. Our streaming
compiler/QBE intervals overlap; report them honestly instead of subtracting an
invented pure compiler duration. A serial diagnostic is optional only if needed.

Check each bendc C product against the complete historical seed and each QBE
product against its existing oracle. After timing, execute one rebuilt compiler
per system: bendc re-emits its checked exact seed; ours compiles a frozen ordinary
program with an independently retained QBE/output oracle. This is bounded product
validation, not a new full qualification or installed promotion.

This comparison matches the complete operation, hardware and resource policy.
The compilers, own source programs, Base revisions, intermediate languages,
optimizations and runtime policies remain different. Our existing prepared Base
is reused; bendc reads/checks its Base live. Do not present this as equal-work
throughput or the bendc AArch64 native-backend result, which cannot run here.

One root execution lane, normal2GiB RSS/5GiB disk reserve, explicit disk/time
budgets and fresh paths. Reuse existing artifacts and guards. Preserve failures,
exact inputs, outputs and receipts; commit/push the report. No production edits,
large qualification campaign or PR comment.
