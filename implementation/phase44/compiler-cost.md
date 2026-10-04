# Phase44 compiler request costs

The four-source comparison completed all **36 checked requests** in **311.43 seconds**.
Map compilation fell from 8.934 to 7.539 seconds: **15.61% less request time, or
1.185× speedup**. The other three request medians increased by 2.81–3.57%. This is
mixed compiler-cost evidence for the combined Phase44 changes, separate from
the execution speed of generated programs.

Each source has three fresh processes per compiler, run serially with roles rotated
each round: TypeScript/baseline/candidate, baseline/candidate/TypeScript, then
candidate/TypeScript/baseline. Node 24.18.0 used CPU 3, a 1,024 MiB heap limit,
2,048 MiB process-tree RSS limit and 2,048 MiB available-memory floor. Every output
matched its independently acquired role-specific JavaScript hash. Sources were
fixed across roles and rounds; `128` and `256` identify catalog points, not repeated
runtime calls during compilation.

| Source | TypeScript request ms | Phase43 request ms | Phase44 request ms | Phase44 time change | Phase43/44 speedup | Phase44/TS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `local-pair` | 362.11 | 2,104.90 | 2,175.49 | +3.35% | 0.968× | 6.008× |
| `lexer` | 349.95 | 3,396.08 | 3,517.26 | +3.57% | 0.966× | 10.051× |
| `coverage-map-churn-128` | 443.53 | 8,933.89 | 7,538.97 | −15.61% | 1.185× | 16.998× |
| `coverage-closures-256` | 310.78 | 1,446.04 | 1,486.65 | +2.81% | 0.973× | 4.784× |

All table entries are medians; ratios divide those medians. Map's three baseline
requests ranged from 8.926–9.935 seconds and candidate requests from 7.319–7.784
seconds. Local-pair and lexer ranges overlap between compilers; the closure ranges
do not overlap in this small sample. Three rounds do not establish statistical
significance or performance across unmeasured programs.

The request boundary is the normal checked-library operation: Bend `inspect`
includes lazy API loading and normal Base-cache handling; TypeScript performs
`book_load`, `book_valid`, and `js_lib`. Host module import is measured separately.
These are end-to-end request measurements, with no attribution to emission alone.

| Source | TS process wall ms | Phase43 process wall ms | Phase44 process wall ms | Host import ms: TS / Phase43 / Phase44 |
| --- | ---: | ---: | ---: | ---: |
| `local-pair` | 5,159.57 | 6,986.53 | 7,010.19 | 210.897 / 3.791 / 3.848 |
| `lexer` | 5,037.68 | 8,016.66 | 8,180.99 | 209.978 / 3.818 / 3.892 |
| `coverage-map-churn-128` | 5,140.49 | 13,568.36 | 12,444.64 | 209.987 / 3.831 / 3.955 |
| `coverage-closures-256` | 5,017.54 | 6,058.52 | 6,121.73 | 214.066 / 3.863 / 3.968 |

These columns also report medians. Process wall time includes integrity checks,
attempt/cache verification, startup, import, request and output validation. Across
all 36 requests, measured request time totaled 97.71 seconds, child process wall
time 269.33 seconds, and total runner wall time 311.43 seconds. The remaining
42.10 seconds were outside child execution. These validation costs matter to the
iteration loop, but must not be reported as compiler request time.

The baseline is **Phase43 checked14**, and the candidate is **Phase44 checked04**.
Both use the same runtime and Base. Upstream TypeScript is pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`. Actual config/input identities below
override the reused Phase39 planner's stale canned “Phase37 checked03” scope text;
that text does not identify the compiler that ran.

| Bound artifact | SHA-256 |
| --- | --- |
| Phase43 checked14 API | `222902e565253ae20c628301a9191c6d71e47b211f1dc463da4e8eb1b51c86eb` |
| Phase44 checked04 API | `0d3325425139c59ac81c4f1bca19fa09e9f977062aa3b202c0ef1c8c7b56b0ea` |
| Shared runtime | `e62cf92d8b600fdc2eb44029b1945f288c81bf878931f883a1b6f4fb5774aaeb` |
| Shared Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Pinned TypeScript `bend.ts` | `de2b39db2fcbd2f9115053e85e34d791693e1297bfeb6874da1013ff7b44b7dd` |
| Pinned TypeScript `comp.ts` | `3bd7ed49d33f1c61334d75a905e38c0345fb15a10b45d85884b77f49833dc5ee` |

Source and emitted-artifact identities below show 12-character SHA-256 prefixes;
the bound config and each raw result preserve full hashes.

| Catalog point / source file | Source | TypeScript output | Phase43 output | Phase44 output |
| --- | --- | --- | --- | --- |
| `local-pair` / `local-row.bend` | `3987479425f7` | `e303d7add56b` | `1eb85cf86992` | `70d29a37ecb0` |
| `lexer` / `lexer.bend` | `6014af6bf7e9` | `2d9378dfdcac` | `3452eada0d78` | `c744ee7e1259` |
| `coverage-map-churn-128` / `map-churn.bend` | `180fc1c2c966` | `4925966fd240` | `08ed55601509` | `251404faa932` |
| `coverage-closures-256` / `closures.bend` | `bc5fb44cba79` | `595d9752cd6e` | `0ee7b774c204` | `84de565a3b55` |

This experiment combines the new IR, simplifications and removal of repeated
planner work. It does not isolate which change caused Map's reduction, establish
general compiler throughput, or measure a self-compilation speedup. The three
regressions remain part of the result; the next cost investigation should separate
request stages before selecting another optimization.

Raw report: `selfhost/build/phase44/compiler-cost04/report.json`, SHA-256
`2229ec802b9e55b5804f63d3e191ec18576d31ec8d767e85adc81e9e082294dc`.
Bound config: `selfhost/build/phase44/cost-plan04/config.json`, SHA-256
`9f70dc7731f4babc95ea240e4ebcda6f895b48c30294b06e6f43a621444e236a`.
The [closed raw archive index](../../selfhost/tools/performance/phase44/evidence/raw/archive.json)
binds all raw inputs and samples.
See the [phase report](README.md) and [benchmark guide](../../selfhost/tools/performance/phase44/README.md).
