# Phase5 source-size recount

Recounted at 2026-09-23T02:20:43.169702+00:00 against campaign baseline `7d69850b9943ab5c66e573ebd69a2ce289626b12`, including the final validation tools. The original pre-promotion and 00:37 host-promotion counts are retained. Experimental tools are a point-in-time count; later source changes require another explicitly dated recount.

The same `compiler.json` boundary reproduces the prior 59-module baseline exactly. Current production is **16,509 physical / 13,803 nonblank lines**, with **1,526 definitions and 1,280 laws**: net +454 physical lines (+2.83%), +403 nonblank, +44 definitions, +44 laws and one type. Eighteen production files changed; the module count remains 59. These are size and declaration counts, not cyclomatic or semantic complexity.

| Category | Files, baseline → current | Physical lines, baseline → current | Nonblank lines, baseline → current |
| --- | ---: | ---: | ---: |
| Production Bend modules | 59 → 59 | 16,055 → 16,509 | 13,400 → 13,803 |
| Top-level host/tool scripts | 18 → 18 | 1,271 → 1,327 | 1,235 → 1,289 |
| Conformance tooling | 24 → 24 | 1,641 → 1,641 | 1,584 → 1,584 |
| Development workflow | 0 → 4 | 0 → 517 | 0 → 503 |
| Private compiler tooling | 33 → 33 | 1,190 → 1,190 | 1,186 → 1,186 |
| Runtime JS components/tests | 8 → 8 | 484 → 484 | 481 → 481 |
| Native runtime/source headers | 41 → 41 | 5,101 → 5,101 | 4,537 → 4,537 |
| Other source support/tests | 18 → 18 | 2,552 → 2,552 | 2,296 → 2,296 |
| Performance tools/prototypes/tests | 208 → 256 | 12,209 → 14,644 | 11,790 → 14,184 |

The experimental baseline also reproduces the earlier **12,209** physical lines. The explicit support categories above total **12,239 → 12,812** physical lines. They do **not** reproduce the previous report’s 12,462 support total: its original file-selection script was unavailable, leaving a 223-line boundary difference. This recount does not silently reinterpret that old total. Both revisions here use the same published rules; the current +573 support lines comprise the 517-line maintained development workflow and 56 net host lines. Tests stored inside selected source/tool directories count in those categories, while `selfhost/tests` fixtures and tests are outside this size inventory.

The principal additions support explicit parser error transport/presentation and import freshness. Size growth does not establish an increase or decrease in implementation difficulty. Bounded simplifications also removed the duplicate checker filter and unreachable Nat helpers; their deletions remain visible rather than being hidden by the larger diagnostic additions.

## Changed production modules

| Module | Physical delta | Nonblank delta | Definitions delta | Laws delta |
| --- | ---: | ---: | ---: | ---: |
| `check/kernel.bend` | -13 | -11 | -1 | -1 |
| `check/specialize.bend` | +0 | +0 | +0 | +0 |
| `core/index.bend` | +0 | +0 | +0 | +0 |
| `diagnostic/frontend.bend` | +0 | +0 | +0 | +0 |
| `diagnostic/produce.bend` | +10 | +8 | +1 | +1 |
| `diagnostic/trace.bend` | +0 | +0 | +0 | +0 |
| `front/declarations.bend` | +26 | +21 | +2 | +2 |
| `front/elaborate.bend` | +1 | +1 | +0 | +0 |
| `front/families.bend` | +15 | +12 | +1 | +1 |
| `front/lexer.bend` | +9 | +7 | +1 | +1 |
| `front/literals_arrays.bend` | -17 | -13 | -2 | -2 |
| `front/parallel.bend` | +14 | +12 | +1 | +1 |
| `front/parser.bend` | +147 | +129 | +14 | +14 |
| `front/sugar.bend` | +48 | +40 | +5 | +5 |
| `front/validate.bend` | +36 | +30 | +3 | +3 |
| `load/graph.bend` | +178 | +167 | +19 | +19 |
| `load/imports.bend` | +0 | +0 | +0 | +0 |
| `load/seed.bend` | +0 | +0 | +0 | +0 |

Zero line-count deltas can still contain semantic edits; the JSON retains the exact old/new SHA-256 values and byte counts for every changed module.

## Largest production modules

| Module | Physical | Nonblank | Definitions | Laws |
| --- | ---: | ---: | ---: | ---: |
| `check/kernel.bend` | 1,261 | 1,050 | 104 | 104 |
| `back/js/emit.bend` | 981 | 815 | 85 | 85 |
| `check/specialize.bend` | 972 | 800 | 83 | 83 |
| `front/declarations.bend` | 737 | 613 | 61 | 61 |
| `core/normalize.bend` | 724 | 618 | 58 | 58 |
| `front/parser.bend` | 637 | 530 | 58 | 58 |
| `core/pretty.bend` | 584 | 477 | 53 | 53 |
| `load/graph.bend` | 574 | 499 | 52 | 52 |
| `front/elaborate.bend` | 520 | 427 | 46 | 46 |
| `core/graph.bend` | 503 | 425 | 36 | 36 |

## Exact method and reproduction

[The final campaign recount](code-size-evidence/final-campaign-report.json) lists every selected file at both revisions, its category, SHA-256, bytes, physical/nonblank lines and declaration counts. The earlier [post-promotion report](code-size-evidence/host-promoted-report.json) remains unchanged. [The script](code-size-evidence/recount.py) selects compiler modules from each revision’s `compiler.json`; support code comes from the explicitly named `src`/`tools` categories. Performance code is reported separately. Included suffixes are `.mjs`, `.js`, `.ts`, `.py`, `.sh`, `.bend`, `.c` and `.h`. Generated build outputs, result archives, documentation and external fixtures are excluded. The checked-in runtime bundle and its source components both occur within the support boundary; totals do not represent unique deduplicated implementation.

Physical lines use Python `str.splitlines()`; a terminal newline adds no empty line. Nonblank lines contain non-whitespace. Bend definitions/laws/types are line-start declarations (`def` also permits same-line `@unsafe`). Declaration counts are interpreted only for production Bend; matching text inside tool fixtures is not a JavaScript complexity metric. Git reads use a bounded path list and a single file-backed `cat-file --batch`, with checked exit codes. Current buffers are read again after counting to reject mid-count changes. No compiler, test, build, checkout or artifact-tree scan runs.

The original [pre-promotion report](code-size-evidence/report.json) is preserved. Reproduce a later count into a **new** result file:

```sh
python3 implementation/phase5/code-size-evidence/recount.py \
  7d69850 selfhost/build/phase5/code-size/final-report.json
```

The command is a source recount, not a benchmark. Experimental-tool totals are a point-in-time inventory and can increase as further measurement tools are added.
