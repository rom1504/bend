# Phase45 compiler request costs

All **36 checked requests passed**, but **compilation became slower on all four sampled sources**. Worker23 request medians increase 8.62% for local-pair, 28.55% for lexer, 1.32% for Map and 1.20% for closures against fresh Phase44 checked04. The roughly 2× improvement in [generated-program execution](results.md) is a separate result and does not imply faster compiler throughput.

Four fixed sources each run in three fresh processes per compiler, serially with rotated roles: TypeScript/baseline/candidate, baseline/candidate/TypeScript, candidate/TypeScript/baseline. Every result matches its independently acquired role-specific JavaScript hash. CPU 3, Node 24.18.0, a 1024MiB heap, 2048MiB process-tree RSS limit and 2048MiB available-memory floor match the bound config. Catalog sizes 128/256 identify points; they are not runtime repetitions during compilation.

| Source | TypeScript request ms | Phase44 request ms | Worker23 request ms | Worker23 time change | Phase44 / worker23 | Worker23 / TS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `local-pair` | 370.49 | 2,100.96 | 2,282.08 | +8.62% | 0.921× | 6.160× |
| `lexer` | 378.43 | 3,439.48 | 4,421.60 | +28.55% | 0.778× | 11.684× |
| `coverage-map-churn-128` | 467.54 | 7,363.73 | 7,460.68 | +1.32% | 0.987× | 15.957× |
| `coverage-closures-256` | 333.29 | 1,497.45 | 1,515.45 | +1.20% | 0.988× | 4.547× |

Entries are medians and ratios of medians. Local-pair and lexer have disjoint request ranges in this small sample; the Map ranges overlap substantially. Three rounds cannot establish statistical significance or general performance across unmeasured programs. All regressions remain part of the reported tradeoff.

| Source | Phase44 request range ms | Worker23 request range ms |
| --- | ---: | ---: |
| `local-pair` | 2,090.95–2,145.73 | 2,277.32–2,296.96 |
| `lexer` | 3,438.34–3,514.32 | 4,403.19–4,446.57 |
| `coverage-map-churn-128` | 7,360.94–7,365.17 | 7,122.05–7,957.23 |
| `coverage-closures-256` | 1,489.76–1,503.87 | 1,512.89–1,604.03 |

The request boundary is the normal checked-library operation: Bend `inspect` includes lazy API loading and normal Base-cache handling; TypeScript performs `book_load`, `book_valid` and `js_lib`. Host import is timed separately. These are end-to-end requests, not emission-only timing or a self-compilation measurement.

## Import and process costs

| Source | TS process wall ms | Phase44 process wall ms | Worker23 process wall ms | Host import ms: TS / Phase44 / worker23 |
| --- | ---: | ---: | ---: | ---: |
| `local-pair` | 5,121.25 | 6,806.95 | 7,081.29 | 210.812 / 3.903 / 3.849 |
| `lexer` | 5,141.83 | 8,126.86 | 9,248.15 | 212.485 / 3.912 / 3.799 |
| `coverage-map-churn-128` | 5,222.79 | 12,044.84 | 12,331.65 | 210.806 / 3.933 / 3.814 |
| `coverage-closures-256` | 5,123.12 | 6,177.21 | 6,245.05 | 213.365 / 3.846 / 3.825 |

These are also medians. Process wall includes startup, integrity/attempt/cache verification, import, request and output checking. Across 36 requests, measured request time totals **95.30s**, child-process wall time **267.38s**, and cost-runner wall time **309.60s**. The remaining **42.22s** is outside child execution. The enclosing preparation-plus-cost job took 348.730s; it contains this runner and must not be added to it. These validation costs matter to iteration speed but are not compiler request time.

## Bound identities and scope

The actual config binds **Phase44 checked04** and **Phase45 worker23** against TypeScript pinned to `018751270e800bc222a93dad7f257083ee53a5f7`. Its explicit API/runtime/source identities override stale “Phase37 checked03” prose inherited from the reused planner. The runtime differs between baseline and candidate; Base remains identical.

| Bound artifact | SHA-256 |
| --- | --- |
| Phase44 api | `0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea` |
| Phase44 runtime | `e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb` |
| Worker23 api | `e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c` |
| Worker23 runtime | `4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26` |
| Shared Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |

Source/output entries below show 12-character hash prefixes; the raw config and each leaf result preserve complete hashes.

| Source | Source SHA | TypeScript output | Phase44 output | Worker23 output |
| --- | --- | --- | --- | --- |
| `local-pair` | `3987479425f7` | `e303d7add56b` | `70d29a37ecb0` | `3c6d89a2e9df` |
| `lexer` | `6014af6bf7e9` | `2d9378dfdcac` | `c744ee7e1259` | `a288fb4c6a8d` |
| `coverage-map-churn-128` | `180fc1c2c966` | `4925966fd240` | `251404faa932` | `652574426a7a` |
| `coverage-closures-256` | `bc5fb44cba79` | `595d9752cd6e` | `84de565a3b55` | `3d158f9cf532` |

The data-only check independently verified the complete source/round/role Cartesian product, serial rotation, leaf result equality, source/output hashes, config identities and request/import/process statistics. It did not execute compiler or generated programs.

The combined backend adds useful generated-code optimization and more compiler work. These four requests do not isolate which planning/lowering pass accounts for the regressions. Sharing completed call-graph/type facts or bounded memoization are plausible compiler-cost experiments, but neither is established as the measured cause here. A compiler-cost optimization should measure stage-level time or repeated analysis before changing the backend; the generated-program CPU profiles do not answer that question. No compilation-speed improvement or global compiler-throughput claim is made.

Raw report: `selfhost/build/phase45/qualification23/compiler-cost/report.json`, SHA-256 `6280466e426bf1853c2dd430118cab71a5921f12993a2a3371fb9c1afadbab5d`. Config: `selfhost/build/phase45/qualification23/cost-plan/config.json`, SHA-256 `384d993a237499e0afb78d47fac17085995f930854c31a89c4abb4ff6792cc92`. Consumed data-only helper: `selfhost/build/phase45/compiler-cost-facts23-v1.py`, SHA-256 `5ec05142ff3b48073610cfd03fd017ee7b08d230ee0c7b727fbe48e2a5a2dc9f`. These raw paths will be bound by the portable evidence archive; they are not GitHub links to ignored files. See [the phase report](README.md) for final qualification and installation status.
