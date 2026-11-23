# Phase 2 (P2-B): K=12 Strictly Acyclic Modular Split of `wave8_unified/compiler.bend`

## Summary

Split `selfhost/build/agy/wave8_unified/compiler.bend` (**3,279.6 KB**, **391 `type`**, **8,754 `def`**, **863 `law`** declarations) into **`K = 12` strictly acyclic, size-balanced `.bend` modules (`m00.bend`..`m11.bend`)** plus a frozen shared type header **`types.bend`** (53.3 KB) and a pure-Bend build manifest **`manifest.txt`** compatible with `research/agy/w9_bend_build/bend_build.bend`.

### Key Properties
- **100% Acyclic Module DAG**: Computed via exact Tarjan SCC condensation over all 9,617 `def`/`law` declarations (6,422 SCCs, 33,241 call-graph edges). Every `law X` / `def X` pair is bidirectionally coupled into the same SCC so forward declarations stay co-located with their definitions, and intra-module declarations preserve original source line order.
- **Strict Topological Order**: Module `m_i` only calls functions in `Base` or `m_0 .. m_{i-1}` (**0 forward cross-module calls**). `main` is deterministically placed in `m11.bend`.
- **Balanced Module Sizes**: Body size spans **245.7–282.2 KB** (avg **269.0 KB**; **298.9–335.5 KB** including `types.bend`).
- **Clean `fid_base` Budget**: Uniform stride `5,120` within `0..65531` (`m00..m10` get 5,120 FID slots each; `m11` gets 9,212 slots: `56320..65531`).
- **100% Lossless Round-Trip**: **0 lost**, **0 duplicated**, **0 forward cycles**, and **0 parse/type errors** under `bend2/main.ts --check-only`.

---

## Module Table (`manifest.json` / `manifest.txt`)

| Module | Body (KB) | +`types.bend` (KB) | SCCs | `def`s | `law`s | Cross-Mod Imports | Reserved `fid_base` Range | Dependencies | Notes |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | :---: | :--- | :--- |
| `types.bend` | 53.3 | 53.3 | — | 0 | 0 | 0 | — | `Base` | All 391 `type` decls in canonical `cid` order |
| `m00.bend` | 282.2 | 335.5 | 1,267 | 1,344 | 97 | 0 | `0..5119` (5,120) | `Base` | Leaf module (checks standalone with `types.bend`) |
| `m01.bend` | 281.0 | 334.3 | 810 | 930 | 65 | 436 | `5120..10239` (5,120) | `m00` | |
| `m02.bend` | 279.2 | 332.4 | 671 | 811 | 73 | 707 | `10240..15359` (5,120) | `m00..m01` | |
| `m03.bend` | 278.1 | 331.3 | 505 | 676 | 81 | 655 | `15360..20479` (5,120) | `m00..m02` | |
| `m04.bend` | 276.4 | 329.7 | 374 | 577 | 71 | 614 | `20480..25599` (5,120) | `m00..m03` | |
| `m05.bend` | 273.5 | 326.8 | 539 | 720 | 66 | 623 | `25600..30719` (5,120) | `m00..m04` | |
| `m06.bend` | 270.0 | 323.3 | 510 | 686 | 67 | 623 | `30720..35839` (5,120) | `m00..m05` | |
| `m07.bend` | 269.3 | 322.5 | 506 | 690 | 61 | 544 | `35840..40959` (5,120) | `m00..m06` | |
| `m08.bend` | 267.3 | 320.5 | 441 | 635 | 70 | 853 | `40960..46079` (5,120) | `m00..m07` | |
| `m09.bend` | 259.8 | 313.0 | 290 | 604 | 77 | 751 | `46080..51199` (5,120) | `m00..m08` | |
| `m10.bend` | 246.0 | 299.2 | 185 | 607 | 81 | 667 | `51200..56319` (5,120) | `m00..m09` | |
| `m11.bend` | 245.7 | 298.9 | 264 | 474 | 54 | 638 | `56320..65531` (9,212) | `m00..m10` | Entry module (`main`) |
| **Total** | **3,281.8** | — | **6,422** | **8,754** | **863** | — | **`0..65531`** | Acyclic | **391 types + 9,617 def/law** |

---

## Verification Receipts

### 1. Lossless Declaration Audit (`split_k12.py`)
- Source (`selfhost/build/agy/wave8_unified/compiler.bend`): `391` types, `8,754` defs, `863` laws (`9,617` def/law total).
- Emitted (`types.bend` + `m00.bend`..`m11.bend`): `391` types, `8,754` defs, `863` laws.
- Lost declarations: **0** | Duplicated declarations: **0** | Forward cross-module edges (`m_i -> m_j, j > i`): **0**.

### 2. Full Round-Trip & Standalone Type-Checking (`bash research/agy/locked_bun.sh --check-only`)
All checks ran via `bash research/agy/locked_bun.sh --check-only` on temporary concatenations in `/tmp/agy_k12_split/` (cleaned up afterwards):

| Target | Parse Errors | Type Errors | `@unsafe`/Foreign Proof Count | Result |
| :--- | ---: | ---: | ---: | :---: |
| `types.bend + m00.bend` (standalone leaf) | **0** | **0** | 1,124 (expected `@unsafe`) | **PASS** |
| `types.bend + m00..m11.bend` (`reassembled.bend`) | **0** | **0** | **8,480** (exact match to original) | **PASS** |
| `selfhost/build/agy/wave8_unified/compiler.bend` (baseline) | **0** | **0** | **8,480** | Reference |

### 3. Hygiene & Disk Budget
- `selfhost/build/agy/wave8_unified/*`: untouched.
- `/tmp/agy_k12_split/`: removed.
- `/dev/md2` free space: **7.6 GiB** (`>= 5.0 GiB` budget satisfied).

---

## Artifacts (`research/agy/w10_mod_bend/k12_modules/`)
- `split_k12.py` — Reproducible Tarjan SCC splitter and lossless verifier
- `types.bend` — Frozen shared type header (`import Base` + 391 `type` declarations)
- `m00.bend` .. `m11.bend` — `K = 12` strictly acyclic topological modules (`main` in `m11.bend`)
- `manifest.txt` — Pure-Bend `bend_build.bend`-compatible manifest (`<name> <src_path> <fid_base> <out_o_path>`)
- `manifest.json` — Machine-readable module statistics and FID budget
- `REPORT.md` — This report
