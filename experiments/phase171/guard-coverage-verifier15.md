# Phase171 borrowed-descendant guard coverage

Offline snapshot: 2026-11-06T17:52:04.115995+00:00.

The exact diagnostic wrapper **$direct.index_find** makes 165120 calls: 165120 pass the root guard, 768 readers decline, and **164352 promotions are derived** under the authenticated result-or-rfc policy.

768 calls use the owned fallback. Old result-guard passes: 65280; additional RFC-permitted promotions: 99072. Promotions are derived from counters and the exact validated CFG, not directly instrumented.

The root-owned diagnostic reused the exact program/runtime objects and interposed only the guard call. The shim forwards unchanged arguments and result; counters are separate from the Bend heap. Exact stdout, empty stderr, zero lost sites and zero unexpected guard values passed. No target was executed by this analyzer.

| Site | Return address | Calls | Old guard passed | Failed + RFC | QBE line |
| --- | --- | ---: | ---: | ---: | ---: |
| helper: `$direct.index_hash` | `0x4056c9` | 296448 | 296448 | 0 | 512 |
| helper: `$direct.p88_string_eq_go` | `0x405d28` | 0 | 0 | 0 | 968 |
| helper: `$direct.p98_eq_finish` | `0x405dfb` | 0 | 0 | 0 | 1005 |
| helper: `$direct.String.is_empty` | `0x405ff0` | 395520 | 395008 | 256 | 1127 |
| helper: `$direct.p111v_at` | `0x406cf9` | 0 | 0 | 0 | 2109 |
| helper: `$direct.dx` | `0x407770` | 49664 | 49664 | 0 | 2879 |
| helper: `$direct.da` | `0x407b40` | 262144 | 262144 | 0 | 3126 |
| helper: `$direct.String.order` | `0x4083ba` | 0 | 0 | 0 | 3581 |
| helper: `$direct.String.eq` | `0x4084fa` | 738304 | 738304 | 0 | 3656 |
| helper: `$direct.p88_string_eq` | `0x408947` | 17920 | 17920 | 0 | 3896 |
| helper: `$p171desc.$direct.p88_string_eq_go.100` | `0x40b114` | 0 | 0 | 0 | 6553 |
| helper: `$p171desc.$direct.p98_eq_finish.208` | `0x40b247` | 0 | 0 | 0 | 6633 |
| helper: `$p171desc.$direct.p88_string_eq.32` | `0x40b3ef` | 768 | 768 | 0 | 6741 |
| helper: `$p171desc.$direct.p88_string_eq_go.505` | `0x40c474` | 0 | 0 | 0 | 7971 |
| helper: `$p171desc.$direct.p98_eq_finish.730` | `0x40c5a7` | 0 | 0 | 0 | 8051 |
| helper: `$p171desc.$direct.p88_string_eq.391` | `0x40c74f` | 0 | 0 | 0 | 8159 |
| helper: `$p171desc.$direct.p88_string_eq_go.1193` | `0x40de34` | 81664 | 0 | 81664 | 9898 |
| helper: `$p171desc.$direct.p98_eq_finish.1418` | `0x40df67` | 81664 | 0 | 81664 | 9978 |
| helper: `$p171desc.$direct.p88_string_eq.1079` | `0x40e10f` | 99072 | 17408 | 81664 | 10086 |
| root: `$direct.index_find` | `0x40ec81` | 165120 | 165120 | 0 | 11129 |
| result: `$direct.index_find` | `0x40ed1a` | 164352 | 65280 | 99072 | 11141 |

The result site is authenticated from the diagnostic ELF even when absent from the counter table; with zero losses, absence means zero calls. Reader declines = passed roots − result-guard calls. For legacy policy, promotions = passed result guards. For result-or-rfc, promotions = passed + failedFirstRfc (disjoint sets). Owned fallbacks = wrapper calls − promotions. Missing RFC fields in legacy observations remain unknown, not measured zero.

QBE and machine mapping: the wrapper first tests `p171desc_roots`, invokes the two-result reader, tests `p171desc_accepted`, and only then reaches `p171desc_escape`. The selected policy then determines success; the RFC variant additionally masks bit63, canonicalizes both predicates and ORs them. Promotion calls `p111_rt_keep` before dropping both held roots. Each refusal branches to the original owned implementation. The JSON retains this exact QBE body and the frozen Bend producer; the disassembly contains every guard caller from this ELF.

Exact binary SHA256: `9024abaeef8dbe5488346b4d967a0063f351486d158da878b618a115ccedc675`. Full receipt/source/object/QBE/method/tool pins and mapped instructions: [JSON](guard-coverage-verifier15.json). Disassembly: [guard callers](guard-coverage-verifier15-disassembly.txt).

This establishes observed refusal/acceptance coverage, not a compiler-wide speed prediction, promotion decision or universal ownership proof. The counters do not reveal why helper guards reject their arguments. Reuse the analyzer with an explicit policy and fresh output prefix, remapping its own executable; never reuse these addresses. Wrong-policy QBE/source is rejected.

```sh
python3 -B experiments/phase171/tools/analyze-descendant-guards-v2.py \
  --report /home/ai/bend2/build/publish/bend/selfhost/build/phase171/descendant-verifier-guard-plan15/execution/report.json \
  --policy result-or-rfc --out FRESH_OUTPUT_PREFIX
```
