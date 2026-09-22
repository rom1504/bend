# Native compiler optimization experiments

This experiment changes Clang flags for the **already checked Phase 3 C compiler artifact**. It does not change Bend algorithms, upstream code, the production runtime, cache policy, or generated-program semantics. It is separate from the Phase 4 source optimizations under development.

The C SHA-256 is `74da4cbe2a3fbcfd52bdf2faf69501783c3522e45a14e60d1b8cf9870ab506b6`. Full-source runs retain the original Phase 3 source/Base/runtime manifest and must reproduce the 1,131,553-byte H library, SHA-256 `360bb62bec910e8148a8c24ee63c1a350a8fda06c206bdd5f04c153a006804de`. The completed checking/emission provenance comes from the [Phase 3 native gate](../phase3/native-final.md). Clang builds do not stand in for those checks.

The current evidence supports keeping **O2** for ordinary builds. PGO is a reproducible optional experiment for a frozen compiler binary; ThinLTO and O3 do not justify default changes. The full-source PGO gain survived a reversed-order repeat.

## Build and training method

All new measured compiler processes inherit CPU 3. Node wrappers use a 4 MiB stack and 4 GiB heap; those limits do not constrain the native executable's heap. Other agents use other CPUs on the shared host. Compilation timers and complete process wall time are recorded separately; emitted JavaScript execution or syntax checking occurs afterward.

Local Clang is Debian 16.0.6. Its existing LLVMgold plugin supports the LTO investigation, but llvm-profdata and the profile runtime were initially absent. Matching Debian packages `llvm-16` and `libclang-rt-16-dev`, version `1:16.0.6-15~deb11u2`, were downloaded, checked against the local apt metadata SHA-256 values and extracted into the experiment directory. No system installation occurred. The initial sandbox DNS failure and successful approved network retry are recorded.

The PGO experiment uses Clang front-end instrumentation: `-O2 -fprofile-instr-generate`. Compilation and linking are separate so the locally extracted profile runtime can be linked explicitly without changing the compiler's resource directory. The instrumented binary compiled tree, list-sort and the complete frozen compiler source once each. Every output passed the original byte/output oracle. Instrumented full-source compilation took **426.405 s**, versus the historical unpaired O2 observation of 249.953 s; training is an expense, not a benchmark speedup.

Three raw profiles merged with `llvm-profdata merge --failure-mode=any --num-threads=1`. The merged profile is 1,380,096 bytes, SHA-256 `4ccc136f801507bd3a02f6742ce31fb861cd822cfd312b374fc694b8995f1047`. Profile-use builds require that exact profile, its raw inputs, the completed training report and the exact original checked C identity. Both stale-profile and unprofiled-function warnings are errors. No compatibility of the profile with changed native compiler C is assumed. Different programs can still be compiled by the same frozen optimized executable; the held-out string case tests that distinction.

Observed C compile phases were 70.417 s for O3, 72.677 s for instrumented O2 plus 0.281 s linking, and 53.839 s for O2+PGO. These are individual builds, not repeated build benchmarks. Profile preparation costs roughly nine minutes starting with the existing O2 executable; any amortization estimate must charge instrumented build, training, merge and profile-use build.

## Small workload observations

Three alternating fresh-process repetitions per variant retained every sample. All emitted bytes and program outputs matched.

| Initial flag comparison | O2 median | O3 median |
| --- | ---: | ---: |
| Tree | 1.636 s | 1.658 s |
| List-sort | 1.937 s | 1.956 s |

O3 was slightly slower on both small workloads.

| Separate PGO comparison | O2 median | O2+PGO median |
| --- | ---: | ---: |
| Tree, included in training | 1.851 s | 1.797 s |
| List-sort, included in training | 2.112 s | 2.099 s |
| String operations, held out of training | 2.702 s | 2.610 s |

These small gains are modest and the samples were noisier than the initial flag comparison. Baseline time also changed between the two experiments, so their separate O2 baselines must not be mixed. No result here measures the runtime speed of emitted user programs.


| Separate ThinLTO comparison | O2 median | O2 + ThinLTO median |
| --- | ---: | ---: |
| Tree | 1.755 s | 1.744 s |
| List-sort | 2.062 s | 2.069 s |
| String operations | 2.640 s | 2.620 s |

ThinLTO used `-flto=thin -Wl,-plugin-opt,jobs=1`, retaining one CPU and one linker job. Its single C compile/link phase took 87.478 s. The small-workload differences are below 1% and do not justify a default change or further full-source LTO runs. All 18 LTO/O2 samples passed exact emitted-byte and execution oracles.

## Semantic gate

The PGO executable passed all **11** selected native graph cases against the original checked JavaScript pipeline: nested imports, diamonds, non-BMP source, libraries, shared foreign assets, asset alias precedence, absent unused assets, required missing assets, imported parse/type errors and imported TODOs. Accepted outputs were byte-identical and executed correctly; rejection phases and checked flags matched. All consumed input and tool hashes remained unchanged. This is focused compiler validation, not full language conformance.

## Provenance and limitations

The standalone `native-opt-{build,measure,profile}.mjs` tools retain commands, deadlines, input/profile/tool/header hashes, stdout/stderr and output identities. Builds verify the checked C and all observed headers before publication. PGO additionally records the profile tool, runtime archive and shared toolchain libraries. The production native cache is untouched.

The first O3 preprocessing record used `-P`, which removes line markers; its preprocessing hash therefore cannot be compared directly with the old O2 cache hash. The original consumed build-tool source is retained. Later instrumented/PGO builds keep line markers and their preprocessing hash matches O2 exactly. This reporting-format difference does not change the C passed to compilation.

The merged training profile counts 6,817 functions, including approximately 56.4 billion `term_tag` and 7.32 billion `heap_alloc` invocations. These include inlined semantic functions; they are **not CPU-time fractions or host malloc counts**. They are retained as possible evidence for a future native representation/ownership investigation.

## Full compiler-source observations

The sequential CPU 3 samples used exactly the same frozen compiler source, canonical Base path, runtime and explicit manifest. Every result passed JavaScript syntax checking and reproduced the independently proven H output SHA-256 above.

| Variant | Native compile timer | Complete compilation process |
| --- | ---: | ---: |
| O2 | 275.611 s | 275.848 s |
| O2 + PGO | 253.800 s | 253.975 s |
| O3 | 269.323 s | 269.495 s |
| PGO, reversed repeat | 255.750 s | 255.951 s |
| O2, reversed repeat | 284.843 s | 285.017 s |

PGO reduced full-source time by **7.9%** in the first O2→PGO pair and **10.2%** in the reversed PGO→O2 pair. The two-sample means are 280.227 s for O2 and 254.775 s for PGO: approximately **9.1% less time**, or 1.10× throughput. O3 reduced its single comparison by 2.3%. This is still limited evidence on a shared host: O2 drifted from 275.6 to 284.8 seconds, and the full compiler source was included in training. The earlier Phase 3 O2 result used CPU 0 at a different time; it is not the comparison baseline.

The roughly nine-minute PGO setup would need about **23** full-source compilations to repay at the observed mean 25.5-second saving, before charging profile maintenance. This is a projection from two pairs, not measured amortization. Rebuilding the native compiler after edits changes its C identity and requires a fresh compatibility decision or retraining. Compiling a different input with the existing frozen PGO binary does not invalidate its profile. The experiment supports a possible amortized frozen-tool lane, but does not demonstrate a faster ordinary native-compiler edit/build loop.

## Native `missing()` is already static

The pinned emitter already folds the absent-definition constructor into static data. In the checked C, the empty-book lookup branch invokes `spin_82`, whose result is `term_ctr(CID_KDEF, STAT_OFF + 2718)` with no heap allocation. `term_keep` returns static terms through its trivial-value path; `ctr_take` reads their static fields without reference-counted ownership transfer. The pinned emitter's `term_const`, `ctr_build` and `emit_fold` paths account for this representation. Source excerpts and exact hashes are retained in the missing-static evidence.

Caching `missing()` again in the native compiler would duplicate an existing optimization. This finding does not imply that all other constructor projections are allocation-free, and it does not transfer automatically to the JavaScript runtime.

## Reproduction

The archived configurations record every absolute input path, flag and deadline. From the repository root, use Node 24.18.0 and a fresh output directory for every command:

```sh
taskset -c 3 node selfhost/tools/performance/phase4/native-opt-build.mjs CONFIG.json NEW_BUILD_DIR
taskset -c 3 node selfhost/tools/performance/phase4/native-opt-measure.mjs CONFIG.json NEW_MEASUREMENT_DIR
taskset -c 3 node selfhost/tools/performance/phase4/native-opt-profile.mjs CONFIG.json NEW_PROFILE_DIR
```

Rebuild the frozen Phase 3 native component first using its documented checked-emission procedure if its ignored artifacts are absent. The native build tool refuses a C hash that differs from the completed checking/emission record. For profiling, run instrumented compilation, the three workload training commands, profile merging, and only then the profile-use build. Local compiler/profile tools and packages are prerequisites recorded in the evidence; the experiment tools do not install them or silently substitute system versions.

The original configurations are historical records. Replaying at different filesystem paths requires a new configuration and new reports; canonical Base paths participate in emitted output. Compressed evidence stores the raw profiles and merged profile as well as their hashes. Uncompressing those files does not waive the original C and profile provenance checks.

## Evidence

The [compact summary](native-opt-evidence/summary.json) records all five full-source samples and the final verdict. All **56** benchmark/training compilations passed the byte/output oracle, alongside the 11-case semantic gate.

The [archive manifest](native-opt-evidence/archive-manifest.json) records original and compressed SHA-256 values. It includes build reports and historical consumed-tool versions, the original checking references, training and merged profile provenance, all measured samples, ThinLTO results, the semantic matrix, toolchain/package identities and the static `missing()` audit. Large C files, executables and downloaded packages remain in the ignored experiment directory; exact hashes identify them. The retained raw and merged profiles allow investigation without pretending their generation cost was free.
