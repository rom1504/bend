# Phase47 final checked-library compiler cost

The final `checked-array06` candidate increases median normal checked-library request time by **1.213% for local fold, 3.752% for editdist, and 0.866% for lexer** relative to Worker23. All 27 requests completed and passed; campaign wall time was **216.740 seconds**. This measures compilation, separately from execution of the generated programs.

The [raw report](../../selfhost/build/phase47/compiler-cost-array06/report.json) uses the successful [plan02](../../selfhost/build/phase47/compiler-cost-array06-plan02/config.json). Its [compact evidence summary](evidence/compiler-cost-final.json) binds the raw report and plan hashes, producer/worker/Node identities, checked-attempt manifests, APIs/runtimes/Base/caches, source hashes, independently acquired expected outputs, and acquisition receipts. All nine statistic groups were recomputed from the 27 rows, including ranges, medians, samples, RSS, process wall time, and output sizes.

## Request results

Times are milliseconds; each input/variant has three samples. Change is `(candidate median / Worker23 median - 1) × 100`. The third input is editdist, replacing array04’s local pair to cover the added tree-entry path.

| Input | Worker23 median | Final candidate median | Change | Pinned TypeScript median |
| --- | ---: | ---: | ---: | ---: |
| local-fold | 1625.546780 | 1645.271509 | +1.213% | 305.644067 |
| editdist | 2257.175603 | 2341.864870 | +3.752% | 336.857784 |
| lexer | 4395.071616 | 4433.122523 | +0.866% | 336.339859 |

| Input | Worker23 request range (ms) | Final candidate request range (ms) | TypeScript request range (ms) |
| --- | ---: | ---: | ---: |
| local-fold | 1612.718–1668.588 | 1639.211–1769.893 | 302.481–331.831 |
| editdist | 2254.563–2279.963 | 2335.277–2349.871 | 336.756–374.671 |
| lexer | 4368.685–4441.250 | 4423.882–4440.819 | 335.871–340.169 |

Editdist’s candidate range lies above Worker23’s range in this campaign. Fold and lexer ranges overlap. These are three-sample observations, not confidence intervals or a general compiler regression estimate.

## Memory and emitted output

RSS cells give whole-process maximum RSS median and minimum–maximum, in KiB. They include imports and verification, rather than attributing allocation solely to the compiler request. Process-tree RSS is recorded separately in the evidence.

| Input | Worker23 RSS (KiB) | Final candidate RSS (KiB) | TypeScript RSS (KiB) |
| --- | ---: | ---: | ---: |
| local-fold | 537,624 (537,464–538,372) | 538,832 (537,536–540,076) | 543,156 (542,628–545,496) |
| editdist | 542,928 (541,584–543,888) | 541,660 (541,260–543,712) | 541,588 (540,468–542,436) |
| lexer | 549,724 (545,400–551,988) | 545,756 (545,244–547,204) | 541,204 (540,444–544,608) |

| Input | Worker23 emitted bytes | Final candidate emitted bytes | TypeScript emitted bytes |
| --- | ---: | ---: | ---: |
| local-fold | 86,853 | 91,521 | 5,191 |
| editdist | 129,236 | 166,580 | 11,907 |
| lexer | 208,893 | 209,949 | 14,110 |

Every output digest matches that compiler variant’s independently acquired expected module; all three samples within an input/variant produced identical bytes. Different compiler variants emit different bytes and sizes. This digest check protects the measured compilation output; it does not substitute for generated-program semantic qualification. Worker23’s expected modules and their original checked-emission receipts were retained without recompiling the baseline.

## Protocol and exact final image

The unchanged Phase30 worker and existing Phase47 runner use rotated TypeScript/Worker23/candidate order in three fresh processes per input/variant. Node is v24.18.0, CPU affinity is 3, V8 heap is limited to 1,024 MiB, process-tree RSS to 2,048 MiB, with a 4,096-MiB available-memory floor. The runner retains a 60-second request deadline and 240-second campaign envelope.

For Bend, `requestMs` covers normal `inspect(source, {mode: "library"})`, including checking, library emission, lazy API loading, and ordinary Base-cache handling. Disk Base-cache priming is excluded and each API’s validated cache is verified before/after. Each process is fresh; this is neither a persistent incremental compiler session nor an uncached bootstrap. TypeScript measures `book_load`, `book_valid` with zero holes, and `js_lib(book, true)`. Host imports are measured separately: medians are about 213–217 ms for TypeScript and 3.8–4.0 ms for Bend’s driver; Bend lazy API loading remains in its request.

Input/attempt/cache verification, output writing, expected-output digest comparison, and postflight verification lie outside `requestMs` but contribute to process/campaign wall time and RSS. The 216.740-second campaign wall time is not a compiler-request median or an emission-only measurement. Inputs, checked attempts, and validated caches are verified before and after; the returned Bend source closure must contain precisely the source plus pinned Base.

The recorded final attempt manifest and plan agree on these whole identities:

- Candidate API: `28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f`.
- Candidate runtime: `880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b`.
- Worker23 API: `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c`.
- Worker23 runtime: `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26`.
- Shared Base: `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661`.

## Comparison with array04

Only fold and lexer are common inputs. The [array04 outcome](compiler-cost.md) and [its evidence](evidence/compiler-cost.json) remain unchanged. This is a later campaign with a different candidate API/runtime; the baseline and TypeScript medians also shifted.

| Common input | Array04 Worker23 / candidate medians (ms) | Final Worker23 / candidate medians (ms) | Array04 candidate change | Final candidate change |
| --- | ---: | ---: | ---: | ---: |
| local-fold | 1602.972 / 1650.517 | 1625.547 / 1645.272 | +2.966% | +1.213% |
| lexer | 4370.260 / 4443.549 | 4395.072 / 4433.123 | +1.677% | +0.866% |

Between campaigns, Worker23 medians increased about 1.408% on fold and 0.568% on lexer, while candidate medians decreased about 0.318% and 0.235%. The smaller final within-campaign ratios therefore do not establish that the additional tree-entry work reduced compiler cost. No pair-to-editdist timing comparison or aggregate across different input sets is claimed. The final editdist row establishes its own cost against Worker23; it has no corresponding array04 compiler-cost row.

The initial [array06 plan refusal](../../selfhost/build/phase47/compiler-cost-array06-plan/preparation.json) is retained: the execution lock was held, the preparation remained incomplete, and its binding list is empty. It started no measured request. The fresh plan02 and its 27-request campaign passed; the refusal is not included in their statistics.

The separate [memo diagnostic](compiler-memo-outcome.md) remains a one-input counterfactual, with no production memo cache shipped. Its 6.64% reduction and repeated-query fraction are not combined with this final candidate cost. These three retained regression inputs do not establish universal compiler latency, bootstrap cost, incremental invalidation behavior, or generated execution speed.
