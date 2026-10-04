# Remaining execution gap and next opportunities

Worker23 is the current development candidate, with full performance qualification pending. The historical worker21 screen retains Map and record execution at 1.721× and 1.551× pinned TypeScript time, while improving RLE and Map/Set to 53.40× and 66.71×. The earlier worker19 screen put lexer and active ray at roughly 1.5–1.7× and Unicode at 2.8×; those three points have not been freshly measured for 21. Other paths still spend most of their work in generic public invocation and data handling. No completed fresh 45-point aggregate exists for worker23, so these selected results cannot replace the earlier full-corpus figure.

All timings below measure warmed, repeated program execution. Even the tiny cases use warmed repeated-execution windows; they simply perform less useful work per public invocation. Substantial half-window drift means these are not proven stationary asymptotic measurements. Compiler request time, module import and first-call latency are separate metrics.

## Earlier worker19 screen

Fresh predecessor and candidate samples from `selfhost/build/phase45/runtime-worker19-vs18-six/report.json`:

| Point | Worker19 / TypeScript | Worker18 / worker19 speed ratio |
| --- | ---: | ---: |
| Map churn 128 | 1.727× | 0.909× |
| Record aggregation 256 | 1.571× | 1.074× |
| Lexer | 1.505× | 1.056× |
| Active ray 256 | 1.681× | 1.018× |
| Unicode 64 | 2.795× | 1.056× |
| Complete generic row 32 | 57.394× | 0.953× |

This is a short screen with mixed movement, especially Map. The generic-row output is byte-identical between 18 and 19. It would be incorrect to attribute its timing variation to the new collector, combine the best samples from different runs, or claim a universal primitive-fence speedup.

The earlier architecture changes explain the substantial progress on whole private graphs: explicit calls/matches replace generic descriptor dispatch; SCC partitioning keeps generated functions manageable; bounded native recursion and tail loops avoid repeated continuation vectors; Number-Nat removes much internal BigInt work; and direct constructor emission removes extra helper calls and arrays. Public guards still establish entry permission, but substantial work then reuses that permission inside the graph.

## Small public boundaries remain expensive

The last complete four-library screen before23 is worker21, `runtime-worker21-nullary/report.json`, freshly sampled against Phase44 and pinned TypeScript. Its guarded nullary workers improve two cases; unsupported parts of their graphs still retain generic execution.

| Program | Worker21 median µs | TypeScript median µs | Worker21 / TypeScript | Phase44 / worker21 |
| --- | ---: | ---: | ---: | ---: |
| RLE roundtrip | 31.907 | 0.598 | 53.40× | 1.5315× |
| Map/Set operations | 1,431.397 | 21.458 | 66.71× | 1.4317× |
| Morning program | 243.357 | 3.483 | 69.87× | 0.9911× |
| Evening program | 172.790 | 2.956 | 58.46× | 0.9900× |

These are selected fixed fixtures, not a distribution of all Bend programs. Three fresh rounds per role all pass; short samples and substantial drift remain, particularly morning. Their ratios cannot be pooled with the earlier 19 table into a current aggregate. Function-valued arguments, Array operations, Map payload layouts and public object results still require additional proofs or adapters before complete workers cover them. The Unit/Map22 extension independently activates new private graphs and passes its boundary controls, but all ten acquired corpus modules match21 byte for byte, so it earns no corpus speedup claim. Worker23 retains that coverage and repairs six supported post-import entry-hook observations reproduced on22. Fresh23 nullary/Unit/hook controls pass; full timing remains pending.

A small public helper can also become slower when optimized internally but wrapped in a large entry protocol. The generic-row falsifier isolated one acyclic scalar helper called twice per cell. Worker17b turned it into a guarded public worker and regressed substantially. Worker18 restored the previous output by requiring recursive work for new alias-only public entries; private acyclic helpers inside admitted graphs remain optimized.

Worker20 explicitly retested that policy with worker19's reduced primitive fences. The row still took 1.980 ms against worker19's 0.384 ms: **5.1548× slower**, while lexer was effectively flat. Pruning primitive dependencies was insufficient to justify repeated entry. Full host/String validation and exact public-call machinery remain plausible major fixed costs; this probe did not separately profile their exclusive contributions. The experiment was rejected, preserving the worker18 profitability gate.

## What should improve next

The useful general direction is to move a larger supported computation behind one guarded boundary. Bounded proofs for canonical Unit/Map shapes, complete local-function applications, Array operations and owned result reconstruction can expand coverage without creating another public wrapper at every helper call. Each needs independent refusal, mutation and aliasing controls. Public object reconstruction must preserve identity/sharing and externally mutable layouts; it is not simply copying private fields out.

Within already admitted graphs, remaining allocation, live-register/frame size and ordinary acyclic call overhead are better targets than repeatedly changing public entry. Profiles identify opportunities, but new claims need fresh controlled measurements. Fusion and compact producer/fold implementations already retained by typed root ranking should eventually become reusable worker-IR passes, so a general backend inherits those optimizations without displacing proven faster plans.

The corrected nullary-entry experiment 21 now passes six exact oracles, 39 boundary observations, six activation observations and nine metadata comparisons, including the previously missing `.code.length` boundary. All eleven screened points pass. The five maintained fast canaries show no large regression; generic row takes 0.398447 ms, 56.71× TypeScript and 3.65% slower than same-run Phase44. Map and records retain 16.31× and 52.68× gains against same-run Phase44. These combined-candidate figures do not isolate the nullary change, and focused passes do not establish full-corpus coverage or a selected release.

Run the maintained fast-five canaries before feature-focused and full screens. The complete generic-row case caught a major selection regression that the Map/record examples could not reveal. Promotion still requires a fresh representative comparison and full qualification of one exact compiler/runtime image.

Evidence: [typed root selection](../../experiments/phase45/P45-016-root-plan-ranking.md), [acyclic profitability repair](../../experiments/phase45/P45-018-acyclic-root-profitability.md), [used primitive fences](../../experiments/phase45/P45-019-used-primitive-fences.md), [rejected acyclic ablation](../../experiments/phase45/P45-020-acyclic-reentry-ablation.md), and [resource/time accounting](accounting.md).

Current correctness status: [P45-023 exact-entry repair](../../experiments/phase45/P45-023-exact-entry-preflight.md). The [full execution report](results.md) will use only complete23 batches, not historical screen values.
