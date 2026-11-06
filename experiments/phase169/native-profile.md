# Native N1 canonical-source physical profile

Prepared only; no target was executed. `native-profile.recipe.json` pins the
exact successful `canonical-candidate01` compiler command, Phase169 native N1,
canonical 3,085,157-byte Phase152 source, prepared Base carrier/stamp, linked
runtime, and retained expected QBE. The preparation receipt is
`native-profile-metadata.json`.

Reuse `selfhost/build/phase159/sampler01/sampler.so`: its retained C snapshot is
byte-identical to current maintained `selfhost/tools/profiler/sample.c`
(`261de8f0…`). Its build receipt, snapshot, historical build method and binary are
pinned. No compiler relink or collector rebuild is needed. Use the main-thread
collector at **32ms**, as requested, for one initial capture. At roughly 200 CPU
seconds this gives about 6,250 samples, below its 100,000-slot bound. Actual CPU
coverage and losses must pass; single-CPU affinity alone does not prove that the
main thread did the work.

From the repository root, freeze and check metadata without executing a target:

```sh
python3 -B selfhost/tools/profiler/freeze.py --recipe experiments/phase169/native-profile.recipe.json --out selfhost/build/phase169/native-profile-manifest01.json
python3 -B selfhost/tools/profiler/run.py --manifest selfhost/build/phase169/native-profile-manifest01.json --out selfhost/build/phase169/native-profile01 --modes sample --rounds 1 --periods-us 32000 --check-only
```

Root's guarded target payload, after the checker and successor gates:

```sh
python3 -B selfhost/tools/build-retention/guard.py --out selfhost/build/phase169/native-profile01-guard --run-root selfhost/build/phase169/native-profile01 --seconds 330 --disk-mib 128 --rss-mib 2048 --available-mib 16384 --file-mib 128 --cpu 3 -- python3 -B selfhost/tools/profiler/run.py --manifest selfhost/build/phase169/native-profile-manifest01.json --out selfhost/build/phase169/native-profile01 --modes sample --rounds 1 --periods-us 32000
```

`--periods-us` determines sample capture count; this command launches **one**
compiler child, with a 300s per-child deadline. The 128MiB disk/file allowance
includes its 94,447,397-byte stdout plus small sample/analysis receipts. The guard
retains its normal 5GiB reserve. `LD_PRELOAD` is applied by the maintained runner
only to the actual native executable, never to `taskset`, a shell or the guard.
The retained native pipeline used about 800MiB peak process-tree RSS; 2GiB gives
headroom for this compiler-only capture and offline symbol analysis.

Offline summary after a completed capture:

```sh
python3 -B selfhost/tools/profiler/compare.py --report selfhost/build/phase169/native-profile01/report.json --out selfhost/build/phase169/native-profile-comparison01.json
python3 -B selfhost/tools/profiler/render.py --comparison selfhost/build/phase169/native-profile-comparison01.json --out selfhost/build/phase169/native-profile-summary01.md --top 30
```

Require exit 0, exactly empty stderr, byte/hash-equal full stdout
(`5f9db26a22fbe223323b795a514c4342a917cc7192f792a9be8d596566a6fb06`),
unchanged inputs, at least 500 delivered samples, at least 95% sampled-thread
process-CPU coverage, zero drops/overruns, intact handler/shutdown, and plausible
timer delivery. The stdout is retained from the **unprofiled same-image** build:
it verifies that profiling preserved the measured compilation, not an independent
proof that this compiler is correct. Semantic and self-host controls stay separate.
Failed quality gates remain evidence and prohibit quantitative attribution.

This captures the **complete native compiler child**, including read/parse/check,
lowering, verification, rendering, stdout writes and exit reclamation. It excludes
QBE, assembler and linker. The existing 197.355s clean number covers that whole
source-to-executable pipeline, whose QBE stage overlaps emission; do not multiply
leaf fractions by that number or present sampled wall time as a clean speedup.
This capture writes to a regular file rather than the pipeline's bounded QBE
relay, so its wall time also lacks that consumer's backpressure.
Without a separate clean compiler-only CPU observation, report physical sample
fractions and observed diagnostic CPU time, not estimated clean seconds saved.

The generic runner does **not** record first output. The first write would delimit
pre-output preparation from subsequent streamed work; it would not by itself be
an independently validated compiler phase boundary. No first-output interval is
required for this initial aggregate investigation. Main-thread sample order can
support later coarse CPU windows if coverage passes, but cannot reconstruct the
wall time of first output. If main-thread coverage fails, prepare a new manifest
with the retained Phase159 thread sampler and a fresh capture; its concatenated
per-thread samples are not a chronological timeline. Do not silently pool failed
main-thread coverage or infer complete logical call stacks from physical leaves.
