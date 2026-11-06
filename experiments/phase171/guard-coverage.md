# Phase171 borrowed-descendant guard coverage

Offline snapshot: 2026-11-06T17:30:49.930147+00:00.

The exact diagnostic wrapper **$direct.index_bucket** makes 40000 calls: 40000 pass the root guard, 40000 readers decline, and **0 borrowed results are promoted**.

All 40000 calls use the owned fallback. The neutral clean runtime result therefore does not measure a successful borrowed-result path or disprove the capability.

The root-owned diagnostic reused the exact program/runtime objects and interposed only the guard call. The shim forwards unchanged arguments and result; counters are separate from the Bend heap. Exact stdout, empty stderr, zero lost sites and zero unexpected guard values passed. No target was executed by this analyzer.

| Site | Return address | Calls | Passed | QBE line |
| --- | --- | ---: | ---: | ---: |
| helper: `$direct.p88_string_eq_go` | `0x405888` | 10000 | 10000 | 512 |
| helper: `$direct.p98_eq_finish` | `0x40595b` | 10000 | 0 | 549 |
| helper: `$direct.index_hash` | `0x405bb9` | 80000 | 80000 | 750 |
| helper: `$direct.p88_string_eq` | `0x406187` | 530000 | 520000 | 1053 |
| helper: `$direct.p137q_name_eq` | `0x406f1a` | 380000 | 380000 | 1920 |
| helper: `$p171desc.$direct.p88_string_eq_go.190` | `0x4080d4` | 40000 | 0 | 3213 |
| helper: `$p171desc.$direct.p98_eq_finish.378` | `0x408207` | 0 | 0 | 3289 |
| helper: `$p171desc.$direct.p88_string_eq.82` | `0x4083af` | 40000 | 0 | 3395 |
| root: `$direct.index_bucket` | `0x4086da` | 40000 | 40000 | 3627 |
| result: `$direct.index_bucket` | `0x40873e` | 0 | 0 | 3639 |

The result site is authenticated from the diagnostic ELF even when absent from the counter table; with zero losses, absence means zero calls. Reader declines = passed roots − result-guard calls. Promotions = passed result guards. Owned fallbacks = wrapper calls − promotions.

QBE and machine mapping: the wrapper first tests `p171desc_roots`, invokes the two-result reader, tests `p171desc_accepted`, and only then reaches `p171desc_escape`. Promotion calls `p111_rt_keep` before dropping both held roots. Each refusal branches to the original owned implementation. The JSON retains this exact QBE body and the frozen Bend producer; the disassembly contains every guard caller from this ELF.

Exact binary SHA256: `77cfa5229da6604abf227da6eb0e2cb16e8aabecdf022b1dc1f067ff2fe5c610`. Full receipt/source/object/QBE/method/tool pins and mapped instructions: [JSON](guard-coverage.json). Disassembly: [guard callers](guard-coverage-disassembly.txt).

This establishes observed refusal/acceptance coverage, not a compiler-wide speed prediction, promotion decision or universal ownership proof. The counters do not reveal why helper guards reject their arguments. Reuse the analyzer with a fresh output prefix for source13 and remap its own executable; never reuse these addresses.

```sh
python3 -B experiments/phase171/tools/analyze-descendant-guards.py \
  --report /home/ai/bend2/build/publish/bend/selfhost/build/phase171/descendant-bucket-guard-plan01/execution/report.json \
  --out FRESH_OUTPUT_PREFIX
```
