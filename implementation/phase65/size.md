# Phase65 State10 source size and complexity

The selected Phase65 source adds **117 physical Bend lines (+0.414%)**, 85 code
lines, 15 definitions and one data type. All 114 pre-existing Bend modules are
byte-identical to Phase64 State09; the sole addition is `check/base-products.bend`.
This is a small increase in implementation size and retained contracts, not a
simplification claim. The [compact data-only receipt](evidence/state10-size.json)
checks 260 input identities and rehashes every input after counting.

| Manifest-listed Bend source | Phase64 State09 | Phase65 State10 | Change |
| --- | ---: | ---: | ---: |
| Modules | 114 | 115 | +1 |
| Physical lines | 28,279 | 28,396 | +117 |
| Code lines | 23,199 | 23,284 | +85 |
| `def` declarations | 3,254 | 3,269 | +15 |
| `law` declarations | 642 | 642 | 0 |
| `type` declarations | 118 | 119 | +1 |
| UTF-8 bytes | 1,289,580 | 1,295,705 | +6,125 |

The boundary and rules match the [Phase64 audit](../phase64/size.md): exactly the
modules named by each frozen `src/compiler.json`, with no generated assembly,
host/runtime code, pinned upstream Base, fixtures, documents, experiment tools or
nonmanifest `.bend.orig` backups in the Bend denominator. Physical lines use
UTF-8 Python `splitlines`. Code lines exclude blank lines and lines whose first
nonspace character is `#`. Declarations count line-start `def`, `law` and `type`
followed by whitespace. These textual measures are reproducible proxies, not a
count of semantic concepts or a universal complexity score.

Both checked attempts require `checked` and `strictExact`. The audit verifies
every manifest/module against its frozen source identity, checks image hashes
against checked/emission receipts, and confirms the B2 receipt points to the
same checked attempt and assembled source. Original module order is preserved;
the new module follows annotation. The 48KB receipt stores a shared table for
the 114 unchanged modules rather than duplicating their measurements.

## What complexity was added

The new [Bend module](../../selfhost/src/check/base-products.bend) introduces
`KBaseAnnotationState{keys,book}` and four private API roles: prepare annotations
from the exact checked Base world, detect whether selected definitions need a
product, validate the existing request/world relationship, and choose cached or
ordinary annotation while giving current stops precedence. A generic bounded
body-size threshold selects which Base products are worth preparing; it does
not name benchmark programs. Public `annotate_selected` stays unchanged.

This adds an optional artifact lifecycle and its ownership/invalidation contract:
the product belongs to the exact compiler, Base, source/span ABI and frame graph;
its header can be inspected before its body is read; unavailable or inadmissible
products retain ordinary annotation. Compiler semantics remain implemented in
Bend. The host handles file transport, validation and admission of Bend-produced
facts.

The other selected change reorganizes the existing indexed decoder into fixed
constructor readers. It adds host functions to isolate constructor dispatch
behavior, while retaining the existing schema, frame4 format, typed reference
checks and compatibility paths. It does not add a new term representation or
another compiler IR. The existing prepared world and mandatory frame shapes
remain unchanged.

Rejected shallow/leaf substitution guards, constructor-index experiments and
normalized annotation proposals are absent from this final Bend source. The
byte equality of all old modules includes `core/term.bend`, the checker, parser,
normalizer and backend modules. Preserved experiments and reports remain outside
the maintained compiler-source count.

## Host support and generated images

Host support is counted separately from Bend:

| Frozen host file | Phase64 lines | Phase65 lines | Line change | Byte change |
| --- | ---: | ---: | ---: | ---: |
| `tools/typed-driver.mjs` | 996 | 1,079 | +83 | +7,219 |
| `tools/base-cache-graph.mjs` | 285 | 348 | +63 | +2,979 |
| `tools/development/workflow.mjs` | 200 | 200 | 0 | 0 |
| `tools/development/release.mjs` | 170 | 170 | 0 | 0 |

The Bend module and the two changed host files together add 263 physical lines.
That sum is an implementation inventory, not a substitute for the consistent
manifest-only Bend series. Ordinary and direct runtime hashes are unchanged.

The [earlier State09 receipt](evidence/state09-size.json) remains unchanged.
State10 has identical Bend source and generated images. Its driver adds five
lines and 396 bytes for the pinned Base guard; its graph helper removes eight
spaces from one blank line, reducing bytes by eight without changing line count.
The final driver and helper sizes are 81,423 and 21,085 bytes respectively.

| Actual generated JavaScript artifact | Phase64 bytes | Phase65 bytes | Change |
| --- | ---: | ---: | ---: |
| Raw checked B1 | 1,943,217 | 1,949,868 | +6,651 |
| Equality-derived checked B1 API | 1,970,019 | 1,976,779 | +6,760 |
| Genuine B2 | 4,040,799 | 4,054,089 | +13,290 |

B2 grows 0.329%. The selected API root set grows from 95 to 99, adding
`base_annotation_prepare`, `base_annotation_wanted`, `base_annotation_allowed`
and `annotate_selected_base`; no old root is removed. Image sizes therefore
describe actual selected scopes, not an equal-export microcomparison. B1 and B2
remain distinct artifacts: Phase65 equality B1 is `3a7fedb7…`, genuine B2 is
`239f7970…`, and assembled Bend source is `310c9d07…`. Image size is not source
size, and this audit makes no independent speed, conformance or release claim.

Reproduce the audit without compiler execution using a fresh output pathname:

```sh
taskset -c 0 python3 selfhost/tools/performance/phase65/size-state10.py /tmp/phase65-state10-size-recheck.json
```

The [audit script](../../selfhost/tools/performance/phase65/size-state10.py) reads only
the frozen attempts and reports and writes the requested evidence file. It never
runs Node, a compiler, a benchmark or Git.
