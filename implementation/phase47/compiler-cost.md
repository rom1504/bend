# Phase47 checked-library compiler cost

The selected `checked-array04` candidate increases median normal checked-library request time by **2.966% for local fold, 2.742% for local pair, and 1.677% for lexer** relative to Worker23. All 27 requests passed. This is a separate compiler-cost study; it does not measure execution of the generated programs.

The completed campaign took **214.174 seconds wall time**, including the fresh-process protocol and its verification work. The raw [report](../../selfhost/build/phase47/compiler-cost-array04/report.json) is summarized in [hash-bound evidence](evidence/compiler-cost.json); that summary retains the report, plan, producer, worker, compiler API/runtime/Base, source, expected-output and acquisition-receipt identities.

## Request results

Each row below has three samples per compiler variant. Times are milliseconds. Candidate change is `(candidate median / Worker23 median - 1) × 100`; smaller request time is better.

| Input | Worker23 median | Candidate median | Change | Pinned TypeScript median |
| --- | ---: | ---: | ---: | ---: |
| local-fold | 1602.971810 | 1650.516512 | +2.966% | 303.624994 |
| local-pair | 2279.510148 | 2342.012754 | +2.742% | 341.665748 |
| lexer | 4370.259753 | 4443.548535 | +1.677% | 339.427687 |

| Input | Worker23 request range (ms) | Candidate request range (ms) | TypeScript request range (ms) |
| --- | ---: | ---: | ---: |
| local-fold | 1598.141–1610.281 | 1620.960–1652.549 | 303.553–307.040 |
| local-pair | 2275.790–2317.196 | 2337.135–2373.998 | 339.712–341.728 |
| lexer | 4368.300–4377.247 | 4430.935–4466.408 | 336.562–340.813 |

Three samples describe this campaign’s observed variation; they do not establish a general regression rate or a confidence interval. The fold and pair candidate ranges are above their Worker23 ranges, as is lexer in this campaign.

## Timing and cache boundary

The unchanged [Phase30 worker](../../selfhost/tools/performance/phase30/library-cost-worker.mjs) runs one fresh process for each request under the [Phase35 runner](../../selfhost/tools/performance/phase35/compiler-cost-run.py). For each input, sample orders rotate TypeScript/Worker23/candidate, Worker23/candidate/TypeScript, then candidate/TypeScript/Worker23. Node is v24.18.0, affinity is CPU 3, the V8 heap limit is 1,024 MiB, the process-tree RSS limit is 2,048 MiB, and the available-memory floor is 4,096 MiB. The campaign’s resource envelope gives 60 seconds per request and 240 seconds total; all requests completed within it.

For Bend, the measured request is `inspect(source, {mode: "library"})`, including normal checking and library emission. Lazy generated-API loading and ordinary disk Base-cache handling remain inside this boundary. Disk Base-cache priming occurs beforehand and is excluded. Each API uses its own validated cache, checked before and after the request. This is a fresh-process request with a primed disk cache, rather than a persistent warm compiler session or a fully uncached bootstrap.

TypeScript measures `book_load`, `book_valid` with zero holes, and `js_lib(book, true)`. Host imports are timed separately for both variants: median TypeScript imports are about 215–217 ms, and Bend driver imports about 3.8–4.0 ms. Bend’s lazy API load remains inside its request. The request medians therefore compare the stated public protocol boundaries; they do not isolate an emission pass or equalize module-loading work between implementations. The evidence also retains `importAndRequestMs`.

Input identity checks, attempt verification, cache verification, output-file writing, expected-output hashing, and final verification sit outside `requestMs`. They remain part of process/campaign wall time and can affect whole-process peak RSS. The 214.174-second campaign wall time must not be substituted for the sum of compiler request medians.

## Memory and output checks

RSS below is Node’s whole-process maximum RSS, in KiB. Each cell gives median and observed minimum–maximum; it includes verification and import work as well as compilation. Process-tree RSS is retained separately in the evidence.

| Input | Worker23 RSS (KiB) | Candidate RSS (KiB) | TypeScript RSS (KiB) |
| --- | ---: | ---: | ---: |
| local-fold | 538,180 (537,540–540,040) | 538,460 (536,860–538,976) | 541,996 (541,788–542,388) |
| local-pair | 539,648 (539,428–541,840) | 541,104 (540,488–541,676) | 540,088 (539,792–541,960) |
| lexer | 547,376 (545,928–547,904) | 547,756 (547,668–550,784) | 541,836 (541,664–545,544) |

| Input | Worker23 emitted bytes | Candidate emitted bytes | TypeScript emitted bytes |
| --- | ---: | ---: | ---: |
| local-fold | 86,853 | 91,281 | 5,191 |
| local-pair | 130,147 | 148,609 | 12,457 |
| lexer | 208,893 | 209,713 | 14,110 |

Every generated output matched the SHA-256 of its own compiler variant’s independently acquired expected module, and all three samples within each input/variant produced the same bytes. Outputs from different compiler variants have different byte sizes and digests; cross-variant byte equality is not claimed. The source import closure for each Bend request was exactly the source plus pinned Base. Inputs, checked-attempt identity, API identity, and validated Base cache were verified before and after each request.

## Interpretation and limits

This study binds Worker23 API `e77c504a…` against selected `checked-array04` API `1accfefd…`, their respective frozen runtimes, and the same pinned Base `c742fae9…`; complete hashes are in the evidence. It establishes a small measured compiler-request cost on three retained regression inputs. It does not qualify every compiler input, compiler bootstrap time, incremental invalidation, generated-program correctness, or generated-program execution speed. Those require their own evidence.

The earlier [compiler memo diagnostic](compiler-memo-outcome.md) measured a separate raw-identity WeakMap counterfactual on one lexer input. Its 6.64% request reduction and its roughly 51% repeated predicate queries are not combined with this candidate’s measurements. That diagnostic cache was not shipped as a production compiler change. These normal checked-library results contain neither that memo overlay nor its instrumentation.
