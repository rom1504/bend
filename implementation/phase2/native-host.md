# Native compiler host: implementation and measured findings

The native host now runs the Bend compiler's existing graph loader, checker and
JavaScript emitter over explicit module and foreign-asset manifests. It compiled
the final v2 compiler source in **311.544 seconds**. For the measured small
programs, however, the normal JavaScript host with its validated Base cache was
faster than this native host. Native execution is therefore useful for the large
compiler-source experiment; it is not yet the preferred repeated-small-edit loop.

The design is [the phase 2 fast-loop plan](../../design/phase2/fast_conformance_loop.md).
The executable protocol and reproduction commands are documented in
[the native graph guide](../../selfhost/tools/performance/rapid/native-graph.md).
All results below are bounded experiments, not whole-language conformance claims.

## What changed

The checked native program contains the same 59 compiler modules as the final
checked JavaScript B1 API, plus two experimental Bend IO driver modules. The
shared pipeline retains graph loading, checking, ownership checks, unresolved-law
rejection, specialization, emission ownership, entry validation, reachability,
foreign validation, annotation and layout. The host does not move these algorithms
into JavaScript and does not fall back to a JavaScript or TypeScript compiler.

The JavaScript launcher performs filesystem orchestration. It resolves an explicit
manifest, snapshots source and runtime bytes, and passes raw `FSource` records to
the native Bend graph loader. Consequently an unused malformed module remains
unparsed. Canonical source identity and lexical aliases are retained; ambiguous
logical-name/physical-path module collisions are rejected at the boundary.

Foreign JavaScript contents are read only after the checked Bend pipeline selects
reachable assets. Logical asset names take precedence over physical-path fallback
across the entire manifest. Missing unused assets are permitted; a required asset
absent from the explicit manifest is rejected. This last case is an intentional
scope difference from the ordinary host's filesystem discovery.

Output publication uses a private temporary file and atomic rename. The launcher
protects source, runtime, manifest, binary and asset aliases, including symlinks
and hardlinks. It checks content and identity drift before publication. A
post-process drift or publication failure retains a structured failed result and
an unpublished-output hash when available; it does not report a published result.

## Validation and source identity

The final [graph matrix](evidence/native-graph-v2-validation.json) passed **23/23**:
14 positive cases checked exact emitted bytes and execution, and nine negative
cases checked rejection behavior. Coverage includes nested and parent imports,
diamonds, repeated aliases, symlinked main files, cycles, unused malformed modules,
namespace conflicts, missing modules, imported parse/type/TODO failures, imported
ADTs and templates, library exports, shared foreign assets, missing required and
unused assets, logical asset precedence, and Unicode paths.

The omitted-required-asset case records its explicit manifest scope difference:
the ordinary host discovers the existing file while the native manifest refuses
the undeclared dependency. This is preserved as an expected difference rather
than counted as matching acceptance. The final missing-module case agrees on
`load`, unchecked; an earlier v1 native driver had classified that error as parse.

A separate [non-BMP source supplement](evidence/native-graph-v2-unicode.json)
passed **1/1**, including exact emitted bytes and execution of `😀🦋猫`.
The [boundary evidence](evidence/native-graph-boundary-tests.json) records **25/25**
launcher checks, **17/17** emitted-JavaScript transport checks, and **9/9** actual
native malformed-transport checks. These short checks are correctness evidence,
not benchmark samples. They cover malformed frames and limits as well as output
preservation, input drift, identity collisions and asset precedence.

The [build evidence](evidence/native-graph-v2-build.json) connects module hashes,
the assembled native-driver source, checked upstream JS/C emissions, the C-only
build, executable and exposed same-source JavaScript workers. The exposure tool
changes only the process entry and uses the emitted program's existing `run_lib`
ABI; compiler worker code is preserved. Matrix and timing reports retain the
consumed host/tool hashes and verify them unchanged during their respective runs.
The later Unicode supplement has its own hashes because the fixture generator
and bootstrap-only host provenance code subsequently changed.

## Controlled small-workload comparison

Three alternating fresh-process repetitions compared native, same-source uncached
JavaScript, and the ordinary checked B1 with its validated Base cache. Six
subsequent live pinned-TypeScript samples used the same physical inputs, CPU3,
Node executable and `--stack-size=4096`. They are explicitly subsequent samples,
not an interleaved four-way experiment. The machine was shared; CPU affinity
isolated these samples from the other agents' assigned compiler processes, but
this is not a dedicated-host performance claim.

The primary metric is process wall time, including startup, host preparation,
checking, emission and writing the output. Execution is a separate oracle. Each
port sample matched output bytes and execution; TypeScript output bytes may
differ, so its execution is compared. TypeScript fully loads and checks Base in
each fresh process and has no persistent Base prefix cache.

| Workload | Native | Same-source uncached JS | Cached B1 | Pinned TypeScript |
| --- | ---: | ---: | ---: | ---: |
| Tree | 1.927 s | 6.718 s | 1.851 s | 0.737 s |
| Import plus foreign asset | 1.892 s | 6.604 s | 1.591 s | 0.713 s |

All **18/18** port samples and **6/6** TypeScript samples passed. See the
[port latency evidence](evidence/native-graph-v2-latency.json) and
[live TypeScript extension](evidence/native-graph-v2-upstream-latency.json).
Cached B1 is about **2.51× / 2.23×** the TypeScript process time on these workloads;
native is **2.61× / 2.66×**. Native is about 3.5× faster than uncached same-source
JS, but that comparison alone would misrepresent the normal cached loop.

The cache was already present. Its recorded 120 ms preparation is an existing
cache read/validation, **not a cold Base-cache build**. These measurements do not
include an observed cold edit-to-bootstrap-to-cache-to-test sequence. Nor do two
small workloads establish the crossover point for larger module graphs.

A separate [cold development-loop observation](evidence/edit-loop-cold.json)
did measure checked final-source bootstrap followed by 21 live frontend cases:
**40.467 s** total, including **22.071 s** bootstrap and **18.363 s** for the
matrix with an initially absent validated Base cache. The resulting B1 API was
byte-identical to the final checked API. This ran on CPU1 with a private,
byte-identical Base path to force the cold cache; it compared acceptance and
phase with the canonical pinned reference, rather than output bytes. It is a
separate observed workflow, not an added sample in the native latency table.

The successful native build phases took **208.844 s**: 44.903 s for load, full
checking and JS/C emission, then 163.942 s for Clang 16 at `-O1`. This sum excludes
orchestration gaps and earlier failed attempts; it is not an end-to-end build
measurement. There is **no native build-cost amortization advantage over cached
B1 for these two workloads**, because native requests themselves were slower.
The design's earlier uncached batch estimate is superseded by this observation.
Keep cached B1 for these small edit/test loops; native prefix caching or a batch
host would require a new measured experiment before changing that recommendation.

## Proven self-emitted H on the small workloads

After the final proof completed, the [interleaved B1/H/TypeScript comparison](evidence/selfhost-cached-latency.json)
ran all three variants with the same current host, canonical pinned Base, CPU3,
Node executable and stack limit. Each sample used a fresh process; the variant
order rotated across three repetitions. All **18/18** compilations and execution
oracles passed, and B1/H output bytes matched the earlier port outputs.

| Workload | Cached B1 process median | Cached self-emitted H | Pinned TypeScript |
| --- | ---: | ---: | ---: |
| Tree | 1.808 s | 3.448 s | 0.689 s |
| Import plus foreign asset | 1.601 s | 3.162 s | 0.688 s |

These process timings include startup, host preparation and output writing;
execution checks run afterward. Inner compilation medians were respectively
1.701 / 3.263 / 0.382 s for tree and 1.494 / 2.960 / 0.388 s for import plus foreign
asset. B1 and H use their validated Base caches, while TypeScript fully checks
Base in each fresh process. This compares the available edit-loop policies,
not identical cache policies.

The proven self-emitted H is **1.91–1.97× slower than B1** and **4.60–5.00× slower
than TypeScript** by process wall on these small workloads. The earlier native
observations around 1.9 s remain separate historical samples. The native host
may beat H on these tasks, but it still has no demonstrated latency or build-cost
advantage over cached B1.

Cache setup was measured separately: B1's cache already existed (0.099 s internal,
0.228 s process wall); H's cache was absent and required **14.494 s internal /
14.909 s process wall** to build. Those setup costs are excluded from the medians.
The H artifact was accepted through the completed, input-verified two-stage
self-emission chain and equal output hashes; no synthetic bootstrap provenance
was used. Input, worker and upstream hashes remained unchanged. The current host
contains later bootstrap-only provenance changes relative to the original native
benchmark, which is why B1 and H were rerun together. Child `NODE_OPTIONS` and
`BEND_TYPED_TRACE` were cleared explicitly.

A separate [backend/runtime validation through proven H](evidence/backend-runtime-selfhost-v2.json)
passed **12/12 suites**, including all six interpreter/JS/native boundary probes
for borrow/fork lifetime and stack-fault handling. It used the same current runtime,
4 MiB Node stack and 4 GiB heap as the earlier B1 backend run. All consumed inputs
remained unchanged. The 81.258-second suite wall is a correctness-run observation,
not an isolated benchmark; cache warmth was not controlled.

## Full compiler-source run

The final frozen compiler source SHA is
`266933eb2ee6aa0d406a48b19f5bbe0250c6685e9f5f2d9fe276bc38bac31784`.
The run used the immutable
`selfhost/build/phase2/grammar-v2/frozen-base/base.bend` path, which must also be
used by the corresponding JavaScript self-compilation for byte comparison.

The [full-source evidence](evidence/native-graph-v2-fullsource.json) records a
successful checked library emission under a 600-second limit:

- Native IO plus compile and complete output consumption: **311.544 s**.
- Native process wall: **311.679 s**; launcher wall: **311.770 s**.
- JavaScript output: **1,117,775 bytes**; syntax check passed.
- Output SHA: `0b2b86aba15cda5ff7536b870f5ad3f372c7b159b8c77225e03715e5a969b7c3`.

The [independent JavaScript stage2 comparison](evidence/native-js-fullsource-equality.json)
now confirms **identical bytes** for the same source and canonical Base path.
Checked B1 emitted stage2 in 784.367 s; stage2 then reproduced the identical
stage3 bytes in **2,921.261 s (48.69 minutes)**. Both stages completed with verified
inputs. This native program is an execution host for the compiler
that emits JavaScript; it does not demonstrate a native compiler fixed point or
arbitrary native-output conformance.

A subsequent [pinned TypeScript full-source sample](evidence/native-fullsource-upstream.json)
compiled the same source with exactly the same canonical immutable Base path in
**49.242 s**, or **49.738 s** process wall. Loading took 2.038 s, full checking and
ownership took 5.368 s, and library emission took 41.830 s. The unchanged pinned
`bend.ts` and `comp.ts` files ran from a private snapshot whose `base.bend` symlink
resolved to the proof's frozen Base. Their bytes, Base and effect files, tool,
Node and output hashes were retained and verified unchanged.

This sample used the structural counterpart of `j_library_roots`, including
**1,466 roots**, of which **40 were Base foreign definitions**. Using the ordinary
bootstrap's narrower export list would have measured different work. All roots
were present in the native-produced API; the TypeScript library's export list,
syntax and ASCII helper execution passed. Its 1,180,983 output bytes have a
different emitter/runtime representation, so byte equality with the port is not
required.

The [export-contract supplement](evidence/native-fullsource-root-supplement.json)
clarifies that this historical check established root inclusion, not equality of
the two default API export sets. Native exports **1,748** entries: its 1,466
selected library roots plus **282** runtime globals and reachable Base helpers.
TypeScript exports only the explicitly selected 1,466 roots. No TypeScript root
was missing. The supplement preserves the complete extra set and an exact copy
of the original consumed tool matching its recorded hash. The revised runner
separately checks exact root selection by applying the actual Bend
`j_library_roots` to the checked upstream metadata fields it reads, outside the
compile timer; it records broader native API exports as a distinct contract.

Native compile time is **6.33×** this TypeScript observation, and process wall is
**6.27×**. This is one later CPU1 sample compared with the native CPU3 run, not a
same-core interleaved benchmark or a median. The canonical source/Base identities
and library workload match, but timing variation across cores and shared-host
conditions remains a limitation. The faster 40.467-second edit loop above uses
checked B1 bootstrap and targeted tests; it does not make the complete
self-emitted-JavaScript fixed-point proof a 40-second operation.

The final [same-CPU3 TypeScript sample](evidence/native-fullsource-upstream-cpu3.json)
completed in **47.784 s internal / 48.261 s process wall**. Loading took 1.883 s,
checking and ownership 5.319 s, and emission 40.576 s. The independent actual Bend
`j_library_roots` classifier selected exactly the same **1,466** roots from all
1,936 checked declarations: no missing or extra roots. Syntax, exported-root and
helper execution checks passed, with unchanged consumed hashes and a clean pin.

| Same frozen full source | Observed process/stage wall | Ratio to final TypeScript sample |
| --- | ---: | ---: |
| Pinned TypeScript | 48.261 s | 1.00× |
| Native graph compiler, emitting JS | 311.679 s | 6.46× |
| Checked B1, emitting stage2 | 784.367 s | 16.25× |
| Self-emitted H, reproducing stage3 | 2,921.261 s | 60.53× |

All four used the same canonical immutable Base and final compiler source on
CPU3. These are separate single observations across the session, not interleaved
medians; Node startup, host work and output publication are included in the
process/stage walls. Native output and both self-emitted stages are byte-identical.
The full self-emitted compiler remains very slow despite the much shorter cached
small-test loop. No claim of a fast complete bootstrap follows from the targeted
validation timings.

## Retained failures and provenance limits

The earlier v1 full-source run did **not** publish output. A concurrent bootstrap
rewrote the shared `dist/base.bend` file with identical bytes but changed its
metadata; the launcher's drift guard rejected publication. At that time the
failure path threw before serializing native timing or hashing temporary output.
The [failure record](evidence/native-graph-v1-fullsource-failure.json) therefore
has null timing and no output hash. Those missing observations are not inferred.
The final v2 run uses the immutable Base copy, and the wrapper now retains
structured post-run failure evidence. The ordinary bootstrap also avoids
rewriting identical Base bytes.

Earlier graph driver attempts failed normal pinned parser or ownership checks;
they were corrected rather than bypassed. Their report hashes, phases and
diagnostics are retained in the build evidence. Successful build-phase totals
exclude that development history. A source revision change requires a fresh
checked build before reusing its performance results.

The historical C-build report recorded compiler path/version/flags, C source hash
and resulting binary hash, but did not capture pre/post hashes of the Clang
executable, linked libraries, or every build helper. Supplemental archive-time
tool/compiler hashes are labeled accordingly; they cannot establish retrospective
immutability. Full-source launcher identity is bracketed by matching hashes from
the adjacent completed latency and Unicode runs rather than by a separate field
inside its original report. The archives retain original report SHA values,
content hashes and recorded tool provenance; repeated native OS fingerprints
were omitted from compact matrix copies and remain in the original report whose
digest is recorded.
