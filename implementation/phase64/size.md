# Phase64 State09 source size and complexity

The final Phase64 source adds **164 physical Bend lines (+0.58%)**, 124 code
lines, 19 definitions and one data type versus Phase63 State09. It is a modest
increase in implementation size and retained contracts, not a simplification
claim. The [data-only receipt](evidence/state09-size.json) verifies 256 inputs.

| Manifest-listed Bend source | Phase63 State09 | Phase64 State09 | Change |
| --- | ---: | ---: | ---: |
| Modules | 114 | 114 | 0 |
| Physical lines | 28,115 | 28,279 | +164 |
| Code lines | 23,075 | 23,199 | +124 |
| `def` declarations | 3,235 | 3,254 | +19 |
| `law` declarations | 642 | 642 | 0 |
| `type` declarations | 117 | 118 | +1 |
| UTF-8 bytes | 1,280,814 | 1,289,580 | +8,766 |

The unchanged, hash-verified `src/compiler.json` supplies exactly those 114
modules. Physical lines use Python `splitlines`; code excludes blank and
comment-only lines beginning with `#` after whitespace. Declarations count
line-start `def`, `law` and `type`. Every module is rehashed against its frozen
checked-attempt identity. Generated assemblies, runtime/host code, fixtures,
documents, tools and a nonmanifest `validate.bend.orig` backup are excluded.
This reproduces the Phase63 report's 28,115-line baseline exactly.

Six Bend modules change:

| Module | Added physical lines | Purpose |
| --- | ---: | --- |
| `check/prefix-state.bend` | 65 | Carry Base TODO count and checked maximum ID; private context construction retains the known prefix bound |
| `driver/api.bend` | 21 | Count suffix TODOs after checking; filter native definitions once for owned-name validation |
| `back/js/direct/host.bend` | 49 | Retain one host-instantiated signature telescope for result/input/copyback consumers |
| `back/js/direct/core.bend` | 13 | Classify tail-transfer arguments without rendering strings that the selector discards |
| `back/js/direct/constructors.bend` | 8 | Exact native-name classifier with historical substring fallback |
| `back/js/validate.bend` | 8 | Exact array-intrinsic classifier with historical substring fallback |

`JDHostSignature` is the one new data type. The existing `KBasePreparedWorld`
gains two scalar fields, `todos` and `checkedBound`; their private admission and
producer/context coupling are additional contracts. The lowering plan, term
representation and backend organization stay the same. The rejected
child-type guards and compact-annotation proposal are absent from this final
source. The two name classifiers and argument-shape traversal introduce small
helpers, not new intermediate representations.

Host support is counted separately:

| Frozen host file | Phase63 lines | Phase64 lines | Byte change |
| --- | ---: | ---: | ---: |
| `tools/typed-driver.mjs` | 983 | 996 | +1,492 |
| `tools/base-cache-graph.mjs` | 156 | 285 | +9,483 |
| `tools/development/workflow.mjs` | 200 | 200 | +56 |
| `tools/development/release.mjs` | 156 | 170 | +1,071 |

The cache helper adds a validated indexed binary transport alongside the older
JSON readers. That introduces a format/schema and compatibility obligation; it
is a real increase in host complexity. The release helper's 14-line snapshot
delta incorporates the graph-helper packaging adapter already selected during
Phase63 release, rather than a new Phase64 compiler feature. Ordinary and direct
runtime hashes are unchanged.

| Generated JavaScript artifact | Phase63 bytes | Phase64 bytes | Change |
| --- | ---: | ---: | ---: |
| Raw checked B1 | 1,936,235 | 1,943,217 | +6,982 |
| Equality-derived checked B1 API | 1,962,981 | 1,970,019 | +7,038 |
| Genuine B2 | 4,029,799 | 4,040,799 | +11,000 |

B2 is 0.27% larger. Its export set grows from 94 to 95 with the private
`book_context_world` API, so these sizes describe the actual selected image
scopes, not an equal-export microcomparison. Each image is verified against its
checked or emission receipt. Image size is not Bend source size, and none of
these counts establishes speed, correctness or a semantic complexity score.

Reproduce the audit without compiler execution using
[`size.py`](../../selfhost/tools/performance/phase64/typed-plan/size.py), with a
fresh output pathname:

```
taskset -c 0 python3 selfhost/tools/performance/phase64/typed-plan/size.py /tmp/phase64-size-recheck.json
```
