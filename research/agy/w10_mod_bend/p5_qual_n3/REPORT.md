# Phase 5-C Report: Full `64/64 native64` + `15/15 Live-Metadata Observer` Qualification on Native `n3_w10`

**Status:** **ALL GATES PASSED (100% Native `n3_w10`, 0 JS, 0 Failures, 0 Observer Violations)**

- **Compiler under test:** `selfhost/build/agy/wave10-native-mod/n3_w10` (`86,269,736 B`, 100% pure-Bend modular self-reproduced native compiler)
- **Runtime:** `selfhost/build/agy/unified/runtime-agy.o` linked with `/usr/bin/x86_64-linux-gnu-gcc-10`
- **Catalog:** `selfhost/tests/phase182/qualification-catalog.json` (`64` cases: `61` execute + `3` refusal)
- **CPU isolation:** Strictly 2-way parallel on dedicated CPUs `4, 5` (`taskset -c 4`, `taskset -c 5`, `ulimit -s 262144`)
- **Total wall time:** `281.81 s`
- **Runner:** [run_p5_qual_n3.py](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_qual_n3/run_p5_qual_n3.py)
- **Machine-readable results:** [results.json](file:///home/ai/bend2_agy/research/agy/w10_mod_bend/p5_qual_n3/results.json)

---

## Executive Summary

| Gate | Mode | Result | Wall Time (2-core CPUs 4,5) | Notes |
|---|---|---|---:|---|
| **`64/64 native64`** | `x86-object-fast` (`-O0`) | **64 / 64 PASS** | **51.82 s** (`100.57 s` compile sum) | 61/61 exact stdout/stderr/rc + 3/3 exact refusal diagnostics |
| **`64/64 native64`** | `x86-object` (`-O2`) | **64 / 64 PASS** | **129.43 s** (`245.92 s` compile sum) | 61/61 exact stdout/stderr/rc + 3/3 exact refusal diagnostics |
| **`15/15` Live-Metadata Observer** | `x86-object` (`-O2`) | **15 / 15 PASS** | **42.98 s** | 5 probes × `{normal, cap-no8, all-hot}`, **0 violations** |
| **`15/15` Live-Metadata Observer** | `x86-object-fast` (`-O0`) | **15 / 15 PASS** | **12.20 s** | 5 probes × `{normal, cap-no8, all-hot}`, **0 violations** |
| **ELF Section Audit** | `x86-object` & `x86-object-fast` | **PASS (both)** | — | `p111_cid_hot` in `.data` (`WA`), `p111_cid_arity` & `p111_cid_names_0` in `.rodata` (`A`, `LOCAL`) |

---

## 1. `64/64 native64` Conformance (Native `n3_w10`)

Every test in `selfhost/tests/phase182/qualification-catalog.json` was compiled directly by native `n3_w10` (`ulimit -s 262144`) using `selfhost/dist/base.bend` + `selfhost/build/agy/bootstrap/base.p130`, linked with `gcc-10 -O2 -no-pie ... runtime-agy.o -lm -pthread`, and executed with `+RTS --threads 1 --gpu off -RTS`.

- **`x86-object-fast` (`-O0`):** **64/64 PASS**, `0` failures, `51.82 s` wall (`100.57 s` compile sum; `2.45x` faster than `-O2` compile sum).
  - Slowest cases: `broad/variation-lexer-6-17` (`8,971.1 ms`, `133,592 B`), `broad/variation-lexer-10-123` (`7,890.0 ms`, `133,592 B`), `broad/lexer` (`7,824.3 ms`, `133,592 B`).
- **`x86-object` (`-O2`):** **64/64 PASS**, `0` failures, `129.43 s` wall (`245.92 s` compile sum).
  - Slowest cases: `broad/coverage-record-aggregation-256` (`33,925.3 ms`, `384,344 B`), `broad/coverage-record-aggregation-64` (`29,336.2 ms`, `384,344 B`), `broad/coverage-map-churn-32` (`27,439.3 ms`, `402,824 B`).
- **Refusal Diagnostics (3/3 verified in both modes, `rc=1`, `0 B` stdout):**
  - `focused/negative-type`: `check: main: constructor does not belong to goal or field count differs`
  - `focused/negative-affine`: `check: twice: affine variable consumed more than allowed`
  - `focused/negative-foreign`: `compile: foreign provider unavailable in fixed runtime: p108_missing`

---

## 2. `15/15` Live-Metadata Observer Gate (Both `-O2` and `-O0`)

All 5 observer probes (`map_set_del_get`, `bst_zipper`, `flow_native`, `perceus_reuse`, `listapp_arrlist`) were compiled natively by `n3_w10`, linked with `observer_gate_hook.c` (`-Wl,--wrap=p111_rt_main`, `-Wl,--wrap=p125_rt_take1..4`) and `runtime-agy.o`, and executed under `OBS_MODE=normal`, `cap-no8`, and `all-hot`. Every run matched upstream `locked_bun.sh` stdout identically with empty stderr and **0 `OBSERVER_VIOLATION`s**.

| Probe | Upstream Ref | `x86-object` Compile (ms) | `x86-object` `.o` (B) | `x86-object-fast` Compile (ms) | `x86-object-fast` `.o` (B) | Modes (`normal`/`cap-no8`/`all-hot`) |
|---|---:|---:|---:|---:|---:|:---:|
| `map_set_del_get` | `4008146603` | 42,918.6 | 478,888 | 8,629.5 | 533,280 | **PASS / PASS / PASS** |
| `bst_zipper` | `382401606` | 4,509.9 | 55,952 | 3,223.5 | 72,512 | **PASS / PASS / PASS** |
| `flow_native` | `49913905` | 4,246.6 | 55,056 | 3,509.7 | 63,728 | **PASS / PASS / PASS** |
| `perceus_reuse` | `3114` | 3,060.7 | 33,184 | 3,325.3 | 38,528 | **PASS / PASS / PASS** |
| `listapp_arrlist` | `3905793128` | 3,769.5 | 43,384 | 3,440.1 | 53,400 | **PASS / PASS / PASS** |

---

## 3. ELF Section Audit (`readelf -SW` / `readelf -sW`)

Audited on `research/agy/w7_bench/compiler_slice.bend` emitted directly by native `n3_w10`:

| Mode | `.o` Bytes | `.text` (`AX`, Ndx 1) | `.rodata` (`A`, Ndx 2) | `.data` (`WA`, Ndx 3) | `p111_cid_hot` | `p111_cid_arity` | `p111_cid_names_0` |
|---|---:|---:|---:|---:|---|---|---|
| `x86-object` (`-O2`) | `349,064` | `0x0231b2` | `0x008ca1` | `0x0036d9` | `.data` (`WA`, Ndx 3, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 5 B, `LOCAL`) |
| `x86-object-fast` (`-O0`) | `410,064` | `0x032f2d` | `0x008ca1` | `0x0036d9` | `.data` (`WA`, Ndx 3, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 775 B, `LOCAL`) | `.rodata` (`A`, Ndx 2, 5 B, `LOCAL`) |

---

## 4. Hygiene & Disk Verification
- `/tmp/agy_p5_qual/` removed (`TMP_CLEAN=YES`).
- `/dev/md2` free space after completion: **`7.1 GiB`** (`>= 5.0 GiB` requirement met).
- Read-only paths (`selfhost/build/agy/wave10_unified/`, `n2_w10`, `n3_w10`, `selfhost/tools/`, `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, `experiments/*`) untouched.
