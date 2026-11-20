# Direct x86 runtime and native qualification

The combined optimization reduced direct x86 execution time **5.70% across the 44 timed native45 cases**. Fresh timings put Phase194 at 1.97723× mature self-hosted Bend C, the candidate at **1.86457×**, and QBE at 1.35379×. All 45 ordinary output oracles passed. One zero-work input contributes only to correctness. [Per-case results and dispersion](broad-runtime-summary02.md)

| Runtime measure | Phase194 | Combined candidate |
| --- | ---: | ---: |
| Geometric runtime relative to C | 1.97723× | 1.86457× |
| Geometric runtime with equal family weights, relative to C | 2.05127× | 1.95332× |
| Mean positive log slowdown against C | 0.81049 | 0.75016 |
| Cases above 1.1× / 2× C | 36 / 32 | 36 / 27 |
| Total runtime at the original catalog repetition counts | 24.546 s | 22.420 s |
| Sum of positive fixed-work excess over C | 14.540 s | 12.403 s |

## What transferred

The compiler preserves scalar facts across branch joins and eligible calls, replaces eligible constant-return helpers with table loads, and lowers a checked square-root case directly. The branch and call rules invalidate facts on writes and retain conservative fallbacks. These transformations had previously reduced runtime 17.38% across six development cases. The new result covers ten development cases and 35 frozen held-out cases, including the zero-work input. [Integration details](../../research/phase195/maintained-integration-result.md) · [Original six-case screen](resume-2026-11-20.md)

- The ten development cases used 10.31% less runtime geometrically. The 34 timed held-out cases used 4.30% less. Excluding the two held-out cases whose baseline code had been inspected leaves 32 cases and a 4.53% reduction.
- Both active-ray cases used about 35% less time. All three edit-distance cases saved about 28%, and local-pair saved 22%. The largest regressions were list-pipeline-128 (+5.43%), list-pipeline-512 (+4.54%) and unicode-text-64 (+3.23%).
- Five cases triggered the existing dispersion warning. All observations enter the published results. Changes in object bytes do not by themselves attribute runtime differences to an optimization. [Transfer and family results](broad-transfer02.json)

The first run stopped when C local-fold-128 consumed eight pilot attempts without settling inside the original calibration window. It produced no broad score. The successful run started again with the same binaries, CPU, catalog, oracle, role rotation, four rounds, 250 ms pilot target and 100 ms minimum accepted sample. The sole harness change allowed up to 20 pilot attempts. Its 625 pilots and 720 timed observations were independently rechecked. [Calibration change](../../selfhost/tests/phase195/qualification/calibration.patch)

## What the hardware model earned

LLVM-MCA on the Ivy Bridge model correctly ranked the pressure-few optimization first among four retrospective pairs. Its 0.774× modeled cycle ratio matched the 0.774× historical runtime ratio. It tied the other three, including byte-identical hot loops whose whole-program runtimes moved in opposite directions. That limits its use for layout and for choosing between candidates with unchanged kernel instructions. [Four-pair retrospective](../../research/phase195/hardware-models/results-2026-11-20.md)

A prospective fifth test froze the arithmetic prediction before candidate timing. For U32 remainder by 26, block throughput fell from 10 to 2 cycles in the model even though the proposed sequence used more instructions. The experimental compiler eliminated four of five literal remainder calls in the lexer. Six rounds measured **3.17% less lexer time** against the combined compiler. The unrelated active-ray program took **0.48% longer** with substantial dispersion. Both routes passed 2,640 independent C observations each, and 17 structural controls passed. Seven guarded jobs took 83.9 s including two source-check failures. This candidate stays experimental. Modeling a short arithmetic sequence helps choose what to test cheaply, while whole-program measurements determine adoption. [Frozen prediction](../../research/phase195/hardware-models/prospective-remainder26.md) · [Measured results](../../research/phase195/prospective/README.md)

## Native qualification

Upstream accepted the assembled Bend source with zero unresolved holes. A qualified QBE-built seed acquired N1 in 173.1 s. N1 acquired the direct-x86 N2 in 284.7 s, and N2 reproduced the same 30,679,808-byte compiler object in 336.1 s. These are individual guarded run times. The two linked images differ in their build identifiers and symbol tables. Their executable code and data sections match. [Qualification receipts](../../research/phase195/native-qualification-summary.json) · [Linked section comparison](compiler-link-comparison.json)

Six N1 development objects match the frozen hosted experiment. Across the full corpus, N1 and N2 passed the 45 independent output checks and produced 45 identical objects and 135 identical linked sections. N2 also passed 64/64 conformance cases and 10/10 runtime controls. These checks establish reproducibility and tested behavior within the published scopes.

The selected x86 Bend source grew by 342 physical lines and 14,336 bytes (+0.78%). The N2 executable grew from 24,963,272 to 25,004,832 bytes (+0.17%). Five other assembled source profiles and their maps matched their pre-change bytes. [Source audit](../../research/phase195/maintained-integration-result.md)

On four paired development requests, source-to-object latency was **1.01285×** Phase194 for N1 and **1.00360×** for N2. Each stage used two reversed rounds per case and validated every output. The near-neutral N2 result is a guardrail with limited precision. [Compiler cost and scope](compiler-cost.md)

Eight maintained source files now contain the qualified composition. Reassembling the live x86 profile reproduced the checked 1,849,936-byte source exactly. Phase195 is available from source and as the explicitly qualified N2 at `selfhost/build/phase195/native-self01/program`. The installed selector still points to Phase189. The compressed evidence archive includes timing observations and failed calibration and source-check receipts. [Promotion receipt](maintained-promotion01.json) · [Evidence verification](qualification-evidence/verification.json)

## Next experiment

The remaining families have different causes. A 56.3 s controlled capture profiled tree-bitonic and BST64 through all three backends on the exact benchmark binaries. BST64 took 27.88 µs per x86 invocation and 18.58 µs on QBE in the clean profiling batches. Physical time in the named lookup/descent worker was already comparable (8.66 and 8.99 µs). Named ownership helpers accumulated 13.65 and 5.51 µs respectively. QBE inlines free-list constructor fast paths into the worker and calls a helper on fallback. That difference in where the work runs prevents treating the 8.14 µs difference as removable overhead.

The existing Bend predicate `x185_ctor_enabled` disables a shared constructor expansion in the x86 backend. An earlier experiment gave mixed tree and Map outcomes. The next test can reuse that implementation: count fast-path hits and fallback calls at the hot private sites, then time a bounded change on BST, tree sort and Map. Preserve ownership, publication and the existing runtime fallback. Matching QBE on *all five* tree and BST inputs would improve the suite geomean only 3.75%. That counterfactual gives scale for the hypothesis. [Exact-machine comparison](../../research/phase195/hardware-models/tree-bst-followup.md) · [Profiling plan](../../research/phase195/hardware-models/tree-bst-profile-plan/README.md)
