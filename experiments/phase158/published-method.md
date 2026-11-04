# Phase158 — published bendc benchmark method audit

Read-only source/artifact audit, 2026-11-04. No compiler, generated program or
benchmark was executed by this audit. Root owns the single CPU3 target lane.

## Which historical result to reproduce

The preferred source pin is
`9c54842eb5756803af599583ca49870d1e09186a`, the
[September29 README commit](https://github.com/Lulzx/bendc/commit/9c54842eb5756803af599583ca49870d1e09186a)
that introduces the2.13s/2.55s self-emission rows. This identifies the publication
revision; the README has no raw timing receipt binding the measured executables
to exact hashes. A same-revision local reproduction is the strongest available
reconstruction, not proof of the historical binary's identity.

| Published figure | Actual operation and available method |
|---|---|
|2.13s|Clang-built bendc executes on `bendc.bend` and emits C. This is compiler execution, not Clang compiling the emitted C.|
|2.55s|The compiler built with bendc's own AArch64 backend performs the same C-emission task. It is not native machine-code emission time.|
|1.95s/2.54s|Separate source-checking rows for the C-built/native-built compiler.|
|3.5s vs20s|README says complete checked source-to-executable via bendc native backend versus C backend, including assembly/link and mostly Clang work in the latter. Runtime/native-support objects are reusable prerequisites; the actual measured cache state is not recorded.|

The updated table reports interleaved runs, best of9, checking best of5, on an
Apple M4 Pro under load average8–21. Its author cautions that ratios vary by
about0.1. Exact thread flags, Clang version, output destination, warmups, timing
wrapper, emitted-C hashes and per-sample records are not published for these
rows. The compiler rows are not labelled “1 thread.” The runtime defaults to the
host CPU count, and checking contains explicit parallel work, so CPU3 with
`--threads 1` is a deliberately narrower local condition.

The same README elsewhere describes an M4 Pro with12 cores,24GB and macOS27 for
runtime benchmarks. That nearby hardware description is not an independent
receipt for the native-compiler table. Do not transfer the other benchmark's
best-of3 policy to these rows.

The3.5s/20s paragraph originated earlier, in
[`e8fb2785534ba1c6ffcf77f1fa317c3c7a317293`](https://github.com/Lulzx/bendc/commit/e8fb2785534ba1c6ffcf77f1fa317c3c7a317293),
September28. It survived subsequent table updates unchanged. Its stated59,000
C lines are not the72,545-line seed at the preferred September29 pin. Treat the
build claim as a separate earlier observation, not a measured duration attached
to every later revision.

The October6 pin `56edcc65b3527a75838011682c231072d5b46097` used in Phase157 still
quotes these numbers but has a1,187,548-byte `bendc.bend` and4,628,175-byte,
113,077-line seed. At the historical pin those files are734,869 and2,802,777bytes.
Using the current pin would answer a different workload question.

## Verified source and Base identity

The downloaded `selfhost/build/phase158/historical-bendc.tar.gz` is925,847bytes,
SHA256 `23e7260923b9e1bd82362308d2d557d645e70685a57e8c307cfbeb991976a00f`.
A read-only extraction of the eight entries below independently recomputed their
Git blob hashes; all match the complete Git tree at9c54842e.

| Path | Bytes | Git blob SHA1 |
|---|---:|---|
|`bendc.bend`|734869|`9277b4d5c86d7be1c23675384c72f0d5504d16c9`|
|`check.bend`|311769|`3213aa1e6a4ddf2491825fc8e3562db85783973a`|
|`core.bend`|54514|`da8197f70e81229b9e9997db0376a82f23c81c91`|
|`asm.bend`|44830|`d660a7a49c69fe75dd180721656387a45130e0be`|
|`rt/rtjs.bend`|24570|`e53ce0a690b46b0da301ae0397f75f46e54e4170`|
|`rt/rtchan.bend`|3144|`15092ca006bba99ac6eb6db194103ad092e222f0`|
|`seed/bendc.c`|2802777|`342cc889c5aba3bd8dc0c35d66353924256c2880`|
|`rt/bendrt.h`|84837|`e6740e385903ce2379f0f091a2ea480f98c6bbdd`|

The seed SHA256 is
`039673e7cd0a3f8534b30b44af6256b1e957e473814a6337b43e4ba687e90db2`;
the header SHA256 is
`60fe68f74102565f96947c0117bd60a4c613daf03b8ad901cbd0734509d7bb09`.
The six Bend source modules total1,173,696bytes before Base. Preserve relative
imports and the repository root as working directory: `bendc.bend` directly
imports Base and the other five modules. Its foreign imports include `rt/cc.c`
and `rt/hub.c` (with JS counterparts). Base's adjacent `effs/` sources are
additional inputs; copying only `base.bend` is insufficient.

Historical [tools/install-bend.sh](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/tools/install-bend.sh)
pins official Bend2.0.32. The Linux x64 archive is
[bend-2.0.32-linux-x64.tar.gz](https://github.com/bendlang/bend/releases/download/v2.0.32/bend-2.0.32-linux-x64.tar.gz),
SHA256 `5c365ddb12954d0933cef751802e0f7d9875f842edcb80f9661f89cd1a9ff7b6`.
The Darwin arm64 archive hash in that same script is
`d7debc002f59264f648dc94e45c2a9fab23e4b1ee0a390bf2acd8b1673e0cf55`.
The [v2.0.32 tag](https://github.com/bendlang/bend/tree/v2.0.32) resolves to
`573002f01ec6c52416d44489543f69a9625facf8`; its `bend2/base.bend` Git blob is
`b77869e5bfbd08d4b2d388032241c595b5a98244`. Root's downloaded
`selfhost/build/phase158/upstream-2.0.32.tar.gz` independently matches the
36,178,942-byte archive and expected SHA256. Its71,783-byte Base independently
matches that Git blob, SHA256
`485705690d8927389bd156f18e42653176a5e139afe363a7e9bc217eb6f5e716`.
Retain the adjacent effect files from that same verified archive. The install pin is positive contemporaneous
compatibility evidence, not a missing historical run manifest.

For the optional October6 point, CI instead pins2.0.34, tag commit
`7d8a3eb036042c6549461054d25a10f26d361c5c`, Base blob
`0edba8267dd17b178dd1d726a0ebeef8d1b317a0`. Keep that pair separate. The Phase157
Base at05926622 is neither historical pair. Do not import its compatibility
normalization or generated-C ABI adapter into this reproduction preemptively.

## Exact documented operations and checking distinction

Historical [Makefile](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/Makefile)
builds the committed seed with Clang `-O2 -w`, the monolithic runtime header,
`-lm -lpthread`. Its `selfcheck` target is exactly this emission plus byte check:

```sh
BEND_NO_FREE=1 ./build/bendc --no-check "$BEND_BASE" bendc.bend > build/self.c
cmp build/self.c seed/bendc.c
```

[bootstrap.sh](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/bootstrap.sh)
also uses `BEND_NO_FREE=1` and `--no-check` for stage1 and stage2 emissions,
compiles each with Clang `-O2 -w`, and compares the two C files. Its stage0 is
official Bend compiling `boot.bend`, which reaches the C generator without the
checker/JS backend. Bootstrap acquisition is not the2.13s timed operation.

At this historical source revision, `Main.emit.c` (19383) reads only
`BEND_NO_FREE`, `BEND_AUTO_PAR`, and `BEND_OPT`; absent OPT means `i..spf`.
Nonempty NO_FREE disables early match freeing, and absent AUTO_PAR follows that
choice. Unset OPT and AUTO_PAR for the literal documented selfcheck policy.
Do not reuse Phase157's later RC/UNBOX policy descriptions as if this compiler
implemented them. The compiler image's runtime policy was set when that image
was generated; emission-time environment settings select policy in its output.

The README does not explicitly label the2.13s row `--no-check`. Separate checking
rows and the selfcheck scripts make unchecked emission a plausible reconstruction,
but not an authenticated fact about the timing command. Measure and label both:

- `--no-check BASE bendc.bend` loads/parses/lowers/emits without source checking.
- `BASE bendc.bend` calls `Main.check` first, then reloads through `Main.build`
  for its IO entry (`Main.run2`,19467).
- `--check-only BASE bendc.bend` runs the source checker and prints its report.
  Foreign/unsafe dependencies cause report exit1 (`Main.check_only.go`,9239),
  distinct from parse/type failure. Retain and validate the actual report.
- `-o OUT BASE bendc.bend` and `--native -o OUT BASE bendc.bend` include checking.
  Their CLI does not combine `--no-check` with these build forms.

Checking here is bendc's source checker, not our independent final-IR verifier
or an independent BendTT kernel proof. A byte-identical self-emission is also a
separate gate from those claims.

## Bounded local command plan

Root's guard/affinity wrapper supplies resource limits and CPU3. Run from the
unchanged historical checkout, with absolute `$BEND_BASE` pointing to the
verified2.0.32 release and `$OUT` a fresh guarded artifact directory. The commands
below describe preparation and three distinct requests, not a script executed
by this audit:

```sh
"$PINNED_CLANG" -O2 -w -I rt seed/bendc.c -o "$OUT/bendc" -lm -lpthread
env -u BEND_OPT -u BEND_AUTO_PAR BEND_NO_FREE=1 "$OUT/bendc" --threads 1 --gpu off -- --no-check "$BEND_BASE" bendc.bend > "$OUT/unchecked.c"
cmp "$OUT/unchecked.c" seed/bendc.c
env -u BEND_OPT -u BEND_AUTO_PAR BEND_NO_FREE=1 "$OUT/bendc" --threads 1 --gpu off -- "$BEND_BASE" bendc.bend > "$OUT/checked.c"
cmp "$OUT/checked.c" seed/bendc.c
env -u BEND_OPT -u BEND_AUTO_PAR BEND_NO_FREE=1 "$OUT/bendc" --threads 1 --gpu off -- --check-only "$BEND_BASE" bendc.bend
```

Clear inherited runtime diagnostics/experimental knobs and retain exact env,
argv, stdout, stderr, status and source/image hashes in root's receipts. Keep
emission timers around the child process including output write and teardown;
do full-byte comparisons afterwards. Timing with output discarded is not the
same boundary as timing a retained file. Any mismatch or refused checking report
is evidence to diagnose, not a successful fast sample. A few clean local samples
can reproduce the operation; they cannot establish the historical M4 number.

The native backend is AArch64-only and selects its object format from the host;
there is no x86 native lane or cross-compiling here. Therefore2.55s and3.5s are
unsupported on this x86 host. A historical `-o` C build can be measured separately
if authorized, with the same Base and source, but is not an AArch64 comparison.

Historical [rt/cc.c](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/rt/cc.c)
compiles generated C at `-O2 -w -DBEND_RT_SPLIT`, using `$CC` or `cc`, and adds
`-ldl` on Linux. `bendrt.o` lives beside the executable and is rebuilt if absent
or older than runtime sources/headers; `BENDC_RT` selects the runtime source
directory. Native construction similarly reuses `natives.o`. Record whether
these prerequisites are warm, and keep acquisition separate. The later October6
driver uses `-O3`, extra loop/vectorization flags, and Mac outliner changes, so
its build command is not the historical20s method.

## Published benchmark scripts do not fill the missing receipt

Complete Git-tree inspection at both pins finds no `bench/compiler` directory or
compiler-specific timing script. `bench/run.sh` builds and times forks, leaves
and sort, then times checking `bendc.bend`; it does not time self C emission or
native compiler acquisition. `bench/official.sh` covers official runtime
programs. Neither implements the native table's best-of9 interleaved procedure.

The historical [bench/run.sh](https://github.com/Lulzx/bendc/blob/9c54842eb5756803af599583ca49870d1e09186a/bench/run.sh)
(unchanged at the current pin; blob `ee0fa2639c445953942145488c7f786b9523dabd`)
uses best-of3 wall time, suppresses stderr/stdout during timed runs, and reports
RSS from the last sample rather than necessarily the best sample. It accepts
checking status0 or1 and does not bind the timed diagnostic to an expected
report. These details should not be copied into a stronger local qualification
gate. Root's retained receipts and full-byte oracle are the appropriate local
evidence; do not present them as recovered original measurements.

## Historical worker-policy audit

The seed has exactly one executable `par_fork` call, at44789 inside
`F_Chk_dVJob_dall_dgo`; its other textual occurrence at62090 is a string used
when emitting C. The source is `Chk.VJob.all.go` (`check.bend`,7818): a list of
declaration-validation jobs is split in half until each group has at most16
jobs; one half is forked, the other evaluated locally, then results are joined.
The reached chain is `Main.check` → `Chk.check_book` → `book_valid` →
`book_valid.par` → `VJob.all`. The preparatory pass gives each job its persistent
book snapshot. Failed parallel validation falls back to sequential checking;
jobs requiring template changes are replayed in order (`check.bend`,7713–7926).
The source does not establish how much of this particular workload falls back
or how balanced the declaration costs are.

`--no-check` enters `Main.run3` mode4 and directly calls `Main.build`, bypassing
that checker chain (`bendc.bend`,19484; seed71886). Therefore this fixed seed's
unchecked self-emission starts no Bend worker pool. File effects may still use
host IO helper threads; those are a separate mechanism from `--threads`.

Historical `rt/bendrt.h` starts the worker pool lazily from the first actual
`par_fork` (`par_start`,1649; `par_fork`,1671). With one worker, fork instead
returns a tagged closure and join applies it locally. With more workers,
`par_start` creates `N-1` helpers and enables multithreaded allocation state.
Those helpers remain alive after checking, so checked-emission timing also
includes any resulting allocation/GC/scheduling effects in its subsequent
emission. Do not derive an exclusive checker cost by subtracting separate
unchecked medians from checked medians.

This historical collector does **not** perform parallel marking. The collecting
thread stops the other registered Bend threads, scans roots, drains one explicit
mark stack in `gc_drain` (735), then sweeps (`gc_collect_locked`,854–921).
Increasing `--threads` does not create marking workers, and unchecked mode cannot
gain checker parallelism simply by selecting the runtime default. This differs
from later bendc runtime versions inspected in Phase157.

A small four-worker **check-only** probe is useful after the serial series,
provided its affinity permits four distinct physical cores. Keep the same image,
source, Base, report oracle and environment; change only `--threads 1` to4 and
the declared CPU set. Pinning four workers to CPU3 alone tests oversubscription,
not parallel checking. On the stated Xeon E3-1245v2 with4 physical/8 logical CPUs,
literal runtime default calls `sysconf(_SC_NPROCESSORS_ONLN)` and normally chooses8
(`cpu_count`,1714; `bend_start`,2451); it does not consult affinity. Four workers
is a bounded local parallelism probe rather than the exact default. The published
M4's worker count and different cores remain nonmatching conditions.

First compare complete check reports and one clean four-worker check-only
sample with the retained serial distribution. If it shows a material difference,
a small checked-emission follow-up can measure transfer to the whole request.
No additional no-check timing series is motivated by the source: its actual Bend
computation and collector remain serial. The audit predicts opportunities and
boundaries, not a speedup; root alone decides and runs any follow-up.
