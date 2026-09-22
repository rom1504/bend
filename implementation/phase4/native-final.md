# Integrated Phase 4 native compiler

The combined source passes checked native emission, a real O2 cache miss/hit, all 11 selected native semantic cases, and full-source JavaScript emission. That library and all six timed comparison outputs are **byte-identical to both stages of the completed JavaScript self-hosting fixed point**. The integrated native compiler lowers median compilation time by **13.85%** on the same final compiler source; individual paired improvements range from 6.05% to 14.28%. This does not claim native-code self-hosting.

The required full-source gate took **254.370 s** in the native compile timer and **254.541 s** for the complete compilation process. The output contains 1,143,517 bytes, SHA-256 `b33b38e32a263bf78e1d43cf459b7abf9a41d78d112d71a25f87ddba7bd09bf8`. This initial correctness gate is separate from the controlled old/new timing series below.

## Frozen inputs and build

The input compiler source is the combined guarded-book/telescope candidate, SHA-256 `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`; checked B1 API is `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`. All 59 source modules were verified against the checked report and copied before building. Native graph and IO driver declarations are added in a separate frozen bundle; its source hash is intentionally different from the compiler-library input.

The checked native C is 6,090,174 bytes, SHA-256 `d2168657332620674302a7c0e6c2a430b83145fa81514acbf801ab1b203d683a`. The unchanged pinned TypeScript compiler performed loading, checking, ownership validation and the unresolved-hole guard before emitting C and the JavaScript control image. This is a checked build, not an unchecked transpilation.

All steps use CPU 3. Node build/measurement hosts use a 4 MiB stack and 4 GiB heap, Clang is the same local Debian 16.0.6, and native flags remain O2. The canonical pinned Base and baseline runtime paths exactly match the combined self-hosting proof.

| Build phase | Complete child-process wall |
| --- | ---: |
| Source preparation | 1.706 s |
| Checked JS and C emission | 48.576 s |
| Fresh O2 cache miss | 85.383 s |
| Cache hit, including preprocessing | 1.920 s |

Both cache outputs have identical binary SHA-256 `37c2f32b75969452638548418ccda598c9b74e058ee38b34ec9315c6f276e4a5`. These build expenses are excluded from runtime compilation samples and are not free in an edit/build loop.

## Correctness gates

The native executable and JavaScript workers exposed from the same checked native-driver bundle agree on all 11 selected cases: nested imports, diamond imports, non-BMP source, libraries, shared foreign assets, logical asset alias precedence, unused missing assets, required missing assets, imported parse/type errors and imported TODOs. Accepted emitted bytes and executed values match; rejection phases and checked flags match. Consumed input/tool identities remained unchanged.

The full-source gate uses the same physical compiler-source and Base paths, the same runtime bytes and library mode as checked stage2. Its output passes JavaScript syntax checking and exact SHA-256 comparison. The JavaScript proof completed at 17:01:13 UTC: checked B1 emitted stage2 in 670.766 s, and stage2 emitted identical stage3 bytes in 1,591.343 s. A separate [completed-proof equality record](native-final-evidence/completed-proof-equality.json) verifies the source, canonical Base, runtime, both actual stage files and all seven native output files. The original partial proof snapshot remains unchanged, alongside the completed snapshot. These single JavaScript proof times used CPU 2 and a 12 GiB heap; the native series used CPU 3, so they are milestones rather than a controlled JavaScript/native timing comparison. This is cross-backend output agreement for the compiler's JavaScript output, not a native-code fixed point or full language conformance.

## Retained harness failure and supervision

An attempt-local orchestration script omitted `version:1` from its full-source manifest. The manifest boundary correctly rejected it before native compilation. The original orchestration report remains `complete:false`, with the failure and all preceding successful build/semantic phases intact. A separate valid manifest and completed full-source report provide the successful gate; no checking/build reports were rewritten and no compiler fallback occurred.

The native launcher and validator use the already tested attempt-local asynchronous file-capture adapter. The checked-emission tool has the same narrow adaptation for git/affinity queries, retaining explicit spawn-error, signal, exit-status, pin and clean-check requirements. Original/consumed sources and hashes are archived. These harness adaptations do not change Bend algorithms or checking gates.

## Controlled comparison

Three alternating fresh-process pairs compare the original Phase 3 O2 binary with this combined Phase 4 O2 binary on **the same new compiler source**, canonical Base, runtime and manifest. Every sample reproduces both completed self-hosting stages exactly and passes syntax checking. Input, binary and consumed tool hashes stayed unchanged throughout.

| Pair and execution order | Old compile | New compile | Reduction | Old process wall | New process wall |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1: old, new | 284.807 s | 245.364 s | 13.85% | 285.021 s | 245.531 s |
| 2: new, old | 288.696 s | 247.477 s | 14.28% | 288.879 s | 247.639 s |
| 3: old, new | 257.663 s | 242.075 s | 6.05% | 257.834 s | 242.237 s |

Median compile time falls from **284.807 to 245.364 s**, a 13.85% reduction (1.16× throughput). Means fall from 277.055 to 244.972 s, an 11.58% reduction. The third old-control sample is noticeably faster, so the full range matters: CPU affinity does not isolate shared-host memory, thermal or other resource effects. No samples were removed.

The native compile timer includes source/selected-asset reads and full output consumption. Complete process wall also includes launcher preparation/provenance and publication; syntax checks happen afterward. Build and cache costs remain separate. This establishes compiler throughput on the full frozen source, not faster execution of generated user programs; all generated bytes are unchanged. [Compact summary](native-final-evidence/paired-summary.json) and [complete sample report](native-final-evidence/paired/report.json.gz) retain the observations and hashes.

[Evidence manifest](native-final-evidence/archive-manifest.json) records the completed build, cache, semantic and full-source gates, six paired samples, original failure, consumed tools, and both partial and completed proof snapshots. Raw executables/C/output artifacts remain in `selfhost/build/phase4/native-final/`.
