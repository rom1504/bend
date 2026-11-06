# Phase171 borrowed-descendant guard coverage

Offline snapshot: 2026-11-06T17:52:43.591368+00:00.

The exact diagnostic wrapper **$direct.index_find** makes 60000 calls: 40000 pass the root guard, 20000 readers decline, and **0 promotions are derived** under the authenticated legacy policy.

60000 calls use the owned fallback. Old result-guard passes: 0; additional RFC-permitted promotions: 0. Promotions are derived from counters and the exact validated CFG, not directly instrumented.

The root-owned diagnostic reused the exact program/runtime objects and interposed only the guard call. The shim forwards unchanged arguments and result; counters are separate from the Bend heap. Exact stdout, empty stderr, zero lost sites and zero unexpected guard values passed. No target was executed by this analyzer.

| Site | Return address | Calls | Old guard passed | Failed + RFC | QBE line |
| --- | --- | ---: | ---: | ---: | ---: |
| helper: `$direct.p88_string_eq_go` | `0x405888` | 10000 | 10000 | 0 | 547 |
| helper: `$direct.p98_eq_finish` | `0x40595b` | 10000 | 0 | 10000 | 584 |
| helper: `$direct.index_hash` | `0x405bb9` | 80000 | 80000 | 0 | 785 |
| helper: `$direct.p88_string_eq` | `0x406187` | 530000 | 520000 | 10000 | 1088 |
| helper: `$direct.p137q_name_eq` | `0x406f1a` | 380000 | 380000 | 0 | 1955 |
| helper: `$p171desc.$direct.p88_string_eq_go.100` | `0x408014` | 20000 | 0 | 20000 | 3168 |
| helper: `$p171desc.$direct.p98_eq_finish.208` | `0x408147` | 0 | 0 | 0 | 3244 |
| helper: `$p171desc.$direct.p88_string_eq.32` | `0x4082ef` | 20000 | 0 | 20000 | 3350 |
| helper: `$p171desc.$direct.p88_string_eq_go.505` | `0x409374` | 0 | 0 | 0 | 4560 |
| helper: `$p171desc.$direct.p98_eq_finish.730` | `0x4094a7` | 0 | 0 | 0 | 4636 |
| helper: `$p171desc.$direct.p88_string_eq.391` | `0x40964f` | 0 | 0 | 0 | 4742 |
| helper: `$p171desc.$direct.p88_string_eq_go.1193` | `0x40ad34` | 30000 | 0 | 30000 | 6451 |
| helper: `$p171desc.$direct.p98_eq_finish.1418` | `0x40ae67` | 30000 | 0 | 30000 | 6527 |
| helper: `$p171desc.$direct.p88_string_eq.1079` | `0x40b00f` | 30000 | 0 | 30000 | 6633 |
| root: `$direct.index_find` | `0x40bb81` | 60000 | 40000 | 20000 | 7636 |
| result: `$direct.index_find` | `0x40bc17` | 20000 | 0 | 20000 | 7648 |

The result site is authenticated from the diagnostic ELF even when absent from the counter table; with zero losses, absence means zero calls. Reader declines = passed roots − result-guard calls. For legacy policy, promotions = passed result guards. For result-or-rfc, promotions = passed + failedFirstRfc (disjoint sets). Owned fallbacks = wrapper calls − promotions. Missing RFC fields in legacy observations remain unknown, not measured zero.

QBE and machine mapping: the wrapper first tests `p171desc_roots`, invokes the two-result reader, tests `p171desc_accepted`, and only then reaches `p171desc_escape`. The selected policy then determines success; the RFC variant additionally masks bit63, canonicalizes both predicates and ORs them. Promotion calls `p111_rt_keep` before dropping both held roots. Each refusal branches to the original owned implementation. The JSON retains this exact QBE body and the frozen Bend producer; the disassembly contains every guard caller from this ELF.

Exact binary SHA256: `a5919c6f4311166d23e59b4089d4ca4fa4b85f8e29bbaceaa072b604169fc8e4`. Full receipt/source/object/QBE/method/tool pins and mapped instructions: [JSON](guard-coverage-find13-rfc-diagnostic.json). Disassembly: [guard callers](guard-coverage-find13-rfc-diagnostic-disassembly.txt).

This establishes observed refusal/acceptance coverage, not a compiler-wide speed prediction, promotion decision or universal ownership proof. The counters do not reveal why helper guards reject their arguments. Reuse the analyzer with an explicit policy and fresh output prefix, remapping its own executable; never reuse these addresses. Wrong-policy QBE/source is rejected.

```sh
python3 -B experiments/phase171/tools/analyze-descendant-guards-v2.py \
  --report /home/ai/bend2/build/publish/bend/selfhost/build/phase171/descendant-find-guard-plan14/execution/report.json \
  --policy legacy --out FRESH_OUTPUT_PREFIX
```
