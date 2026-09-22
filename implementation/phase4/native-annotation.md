# Native annotation fork experiment

**Rejected for performance.** The isolated [P4-018](../../experiments/phase4/P4-018-native-annotation-parallelism.md) wrapper passes the checked build and exact structural controls, but two-worker annotation is **about 11.5% slower in both execution orders**. No production change, four-core escalation or full-source run followed.

## Scope and frozen inputs

The wrapper uses all 59 unchanged final compiler modules, checked B1 `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`, and final combined compiler source `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`. It loads/checks/specializes the source sequentially, constructs one immutable context, splits only selected annotation declarations into contiguous chunks, and rejoins in the original order. It does not change declaration checking, ordinary compiler APIs, emitted programs or the frozen self-hosting proof.

Current disposable bundle source is `2e914b7fb83c2ab74292eff7b8a3dc985f41e8b4fbefee49ea93ec3a9c94f7c7`; C is `8ab07ba124eb065eaa08e136c1d46de2361aa4c4f69ffebad2a2ed38819c15db`; O2 binary is `68c583425d45523c86b9f39cad2cd6e9b6d064f7df1527f21c3737e111477f08`. Checked emission took 33.527 seconds of report wall and native build 81.465 seconds. The latter overlapped a roughly 12-second same-core archive/audit task; it is observed setup expense, not a controlled build-performance sample.

The real workload is the existing four-module `private/component/core.bend` used by earlier controlled pilots. A fresh four-module assembly from the combined source was rejected because the newer index depends on `book_final_legacy` from the kernel. That failure is retained; no unresolved declaration was ignored. Both native variants and the independent B1 tree oracle consume the same existing closed core fixture.

## Correctness and demand gates

- Thirty complete KDef/KTerm tree comparisons pass between frozen B1 `annotate_selected` and the checked wrapper's serial/two-way/four-way JavaScript workers. Cases include libraries, non-BMP source, dependent function arguments, erased arguments, templates, the real core, and empty/duplicate/reordered/stopped selections.
- Fifteen native positive cases pass exact tree-file comparison and the full structural digest. Two/four worker paths were exercised while confined to CPU3; these are correctness controls, not multicore performance evidence.
- Eight native negative controls reject parse, type, unresolved-law and ownership inputs before the annotation timer, with identical wrapper diagnostics between serial and two-worker modes and no output publication. These are the component wrapper's preparation errors, not a claim of complete public frontend diagnostic equivalence.
- The generated C contains an actual two-child fork calling the unchanged annotation workers. Context and stops are retained at the fork. Existing workers still retain the context and perform owned projections; shared inputs are not assumed free.
- The full structural hash returns a scalar through the generated continuation before the second `IO.now`. Canonical exact serialization happens afterward. The timed component includes annotation, split/join and structural consumption; complete process wall includes preparation and expensive serialization/file output.

The [independent review](native-annotation-review.md) found the value ordering and demand boundary sound for these checked finite inputs. Its provenance findings were corrected: preparation now captures exact consumed buffers before use and checks destinations against the checked manifest; measurement binds fixture/Base/build bytes and paths to the oracle and rejects empty trials or unsafe output IDs. Six refusal tests and a positive native smoke pass. A retrospective companion verifies all 59 original copied modules and shows that the hardened preparation produces identical source apart from assembly path comments. Original reports and consumed tool versions remain separate.

## One-worker prerequisite

Two opposite-order rounds use the same binary and CPU3, with one worker. All six outputs are exact, including the roughly 13 MiB core structural serialization.

| Round/order | Serial | Two-way wrapper | Four-way wrapper |
| --- | ---: | ---: | ---: |
| Serial, two-way, four-way | 2,393 ms | 2,363 ms | 2,427 ms |
| Four-way, two-way, serial | 2,297 ms | 2,313 ms | 2,427 ms |

The two-way wrapper is 1.25% faster in the first order and 0.70% slower in reverse, passing the proposed 5% overhead limit. Four-way overhead is 1.42% and 5.66%; the latter exceeds the proposed threshold, so four-way escalation is withheld. Peak process RSS ranges from 394,244 to 397,920 KiB. The serial baseline shifts by about 4%, so both orders are retained. These are prerequisite measurements, not parallel speedup evidence.

## Two-core falsifier and decision

After the independent scheduling sweep released CPU0, two opposite-order pairs ran with serial mode on CPU3 and two-worker mode on CPUs0+3. Both use the same checked binary, source, Base, exact-tree oracle and hardened measurement tool. All four full tree files and structural digests match; all consumed inputs remain unchanged.

| Order | Component serial | Component two-worker | Slowdown | Process serial | Process two-worker |
| --- | ---: | ---: | ---: | ---: | ---: |
| Serial, two-worker | 2,324 ms | 2,591 ms | 11.49% | 31.693 s | 59.384 s |
| Two-worker, serial | 2,326 ms | 2,594 ms | 11.52% | 31.451 s | 59.148 s |

Peak RSS is 394,816/396,724 KiB for serial and 410,192/410,016 KiB for two workers, about 3–4% higher. Preparation also rises from 5.34–5.39 s to 6.51–6.52 s, and complete user CPU time nearly doubles (31.1–31.3 s versus 59.1–59.3 s). The process includes the intentionally expensive exact serializer; these wall times describe this experiment, not the normal developer loop or complete compiler throughput.

The proposed gate required at least a 20% component improvement. Instead both orders regress, so the current two-way approach is rejected without further core counts or full-source runs. The one-worker four-way borderline regression is retained separately. This rejects the implemented wrapper on this runtime and workload; it does not disprove the source-level independence of annotation.

A concrete static obstruction deserves separate future investigation. Pinned `comp.ts:2894–2905` propagates the may-fork bit through a closure apply as though it can reach **every closure**. Introducing the wrapper fork therefore marks `KA_DEFS_EXCEPT`, `AP_HASH_DEFS` and `AP_PREPARE` as potentially forking, even though their ordinary compiler work does not invoke the new wrapper. The emitted `FID_FLAG_T` confirms this; `AP_DEFS` itself remains marked fork-free. Runtime selection between serial frames and task execution uses that metadata, providing a plausible source of broader overhead. Shared reference counting and chunk imbalance remain other possible contributors. No counterfactual metadata ablation was performed, so the report does **not** attribute the full measured slowdown to any one mechanism. A future experiment needs a precise closed-world or closure-flow proof before changing those flags; simply forcing global serial execution would defeat the intended parallel work.

## Retained failures and resource qualification

The first build command omitted the explicit pinned-upstream environment, then the first wrapper used the wrong `IO<U32>` result-type syntax. Both attempts failed before successful checked emission and are retained. A measurement attempt found `/usr/bin/time` unavailable; the corrected harness uses a small `wait4` helper that preserves exit/signal behavior and records the native child's resource usage. The incomplete fresh core fixture also remains a rejected preparation.

A read-only emitted-C inspector accidentally ran without explicit affinity during the conservative interval **18:13:40–18:14:05 UTC**. Its initial quadratic line-number scan took roughly 10–15 seconds; it was replaced with a linear scan and subsequent executions were pinned. It did not execute a compiler, but may add shared-resource noise to concurrent root runs. No annotation timing was running then. The exact command, purpose, original tool hash and interval are retained in the contention record. CPU reservations describe intentional work allocation, not operating-system or memory isolation.

Raw checked builds, controls, original failures and timing reports are under `selfhost/build/phase4/annotation-parallel-attempt{1,2,3}/`, with a separate hardened preparation. The [compact evidence archive](native-annotation-evidence/manifest.json) retains 146 hash-verified files in 1,208,594 packed bytes, including all three assembled wrapper sources, consumed historical tools, failed attempts, complete timing records and one final exact tree per scenario. Its manifest records external prerequisites and omissions. Generated C and binaries can be regenerated from the retained assembled Bend source, pinned compiler and recorded native build environment; they are not new distributed compiler artifacts.

## Replay

From `selfhost`, use the recorded Node 24.18.0 executable and an explicit canonical `BEND_UPSTREAM`. `tools/performance/phase4/native-annotation-prepare.mjs build/phase4/combined-launch.json NEW_DIRECTORY` snapshots the checked 59-module source plus the disposable wrapper. The archived consumed `native-component.mjs` builds a fully checked C/JavaScript component; the archived native cache/build helpers compile its C with Clang16 and `--opt=O2`. Their environment, command arguments, headers and tool identities are in the retained build reports. No distributed API is overwritten.

The retained oracle and measurement configuration files specify the exact fixture paths, Base identity, modes, thread counts, CPU masks and reversed round order. Run `native-annotation-oracle.mjs CONFIG NEW_DIRECTORY` first, then `native-annotation-measure.mjs CONFIG NEW_DIRECTORY`. Regenerate the oracle when relocating physical source or Base paths; compare every variant against that same input identity. The structural timer includes annotation, split/join and full digest consumption; serialization remains outside it. The archive includes compressed exact expected trees for independent checking, rather than treating a timing report as a correctness oracle.
