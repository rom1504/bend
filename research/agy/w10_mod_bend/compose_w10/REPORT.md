# Phase 2 (P2-A): Wave 10 Pure-Bend Modular Unified Compiler (`wave10_unified`)

## Summary
Composed **`selfhost/build/agy/wave10_unified/{compiler.bend,api.mjs}`** (`3,435,783 B` Bend source, `15 MiB` JS API) on top of `selfhost/build/agy/wave8_unified/compiler.bend` (untouched) combining all 5 verified Phase 1 / Wave 9 deliverables plus `--trace`:
1. **`w9_str_hot`** (`apply_w9_str_hot.py`): restores `agy_sh_try` in `-O0` (`x181_program_private_fast`), protects `agy_sh` intrinsics from `p113i_eligible` inlining, and eliminates mutual recursion in `index_find`/`index_bucket`/`index_remove`/`index_tip` for direct `p113d_` lowering.
2. **`w9_elf_fast`** (`apply_w9_elf_fast.py`): compact pre-encoded `x202k_template`, single-pass `x187_elf_symbol_add`, fused `w7c_relocs_fused`, direct reverse-push `x188_build_instruction` (preserving `128 MiB` ELF guard `134217728`), and fast `x181_program_public_fast`, while keeping `p111_cid_hot` in writable `.data`.
3. **M1 `merge_obj.bend`**: pure-Bend `x86-merge-obj` link-time segment table merge `.o` emitter (**0 C**).
4. **M2 `mod_elf_vis.bend`** (reconciled with `w9_elf_fast`): pure-Bend `STB_LOCAL` (`$p111.k.*`, `def main`) + `STB_WEAK` (`P86Seed.book`) ELF64 symbol visibility (**0 `objcopy`**). Reconciled `w10_elf_symbol_add`, `w10_build_symbol_checked`, and `w10_x202p_build_symbol_checked` to reuse `w9_elf_fast`'s single-pass `w7c_elf_ascii_valid`, `w7c_elf_sym_nums_valid`, and `w7c_elf_sym_push`, and wired M2 into both `x86-module` (`w8_module_entry`) and `--trace x86-module` (`w8_tr_*`).
5. **M3 `iface_emit.bend`**: pure-Bend `x86-iface` `.p130` interface carrier emitter (**0 JS `build_iface_carrier.mjs`**).

Reproducible composition script: [`compose_w10.py`](compose_w10.py).

---

## Verification Gates (`selfhost/build/agy/wave10_unified/api.mjs`)

| Gate | Command / Scope | Result |
| :--- | :--- | :--- |
| **`--check-only`** | `locked_bun.sh selfhost/build/agy/wave10_unified/compiler.bend --check-only` | **PASS** (0 type/linearity errors across `8,617` defs; `@unsafe` audit only) |
| **`api.mjs` build** | `locked_bun.sh selfhost/build/agy/wave10_unified/compiler.bend -o .../api.mjs` | **PASS** (`15 MiB`, rc=0) |
| **`64/64 native64`** | `run_gates.py --api selfhost/build/agy/wave10_unified/api.mjs` | **64/64 PASS** (`45.0 s`) |
| **`15/15` Observer Gate** | `44+2` ABI probes + 5 probes x 3 modes (`normal`, `cap-no8`, `all-hot`) | **15/15 PASS** (0 violations) |
| **`readelf` `.data`/`.rodata` Audit** | `modB_v1.o` & `modA_v1.o` emitted by `wave10_unified` | **PASS** (`p111_cid_hot` in `.data` Ndx=`3` `WA`; `p111_cid_arity` in `.rodata` Ndx=`2` `A`) |

---

## 100% Pure-Bend End-to-End A -> B Proof (0 C, 0 `objcopy`, 0 JS `build_iface_carrier.mjs`)

Executed via [`verify_w10_ab.py`](verify_w10_ab.py) using ONLY `selfhost/build/agy/wave10_unified/api.mjs` (`x86-merge-obj`, `x86-iface`, `x86-module`, `--trace x86-module`) + `gcc-10`:

| Case | Steps | Interface Stamp | Link Warnings | Output | Result |
| :--- | :--- | :--- | ---: | ---: | :--- |
| **`x86-merge-obj`** | `x86-merge-obj modA modB modA` -> `merge.o` (`724,128 B`, `799.1 ms`, `sh_info=6` valid) | — | — | — | **PASS** |
| **Case 1: Clean A -> B** | `x86-iface modB_v1` (`10.3s`, `4,651,837 B`) + `x86-module modB_v1` (`370,944 B`, `55` local `$p111.k.*`, `18` weak, `sh_info=1633`) + `x86-module modA_v1` (`148,072 B`, `5` local `$p111.k.*`, `3` weak, `sh_info=1565`) + `gcc-10` (both `modB modA` and reverse `modA modB`) | `p130-word-pair-v1:w10-iface-v1:71eb49620ebd4c52` | `0` | **`34`** (fwd & rev) | **PASS** |
| **Case 2: Body-only B edit (`+10`)** | `x86-iface modB_v2` -> **IDENTICAL stamp**; rebuild ONLY `modB_v2.o`; `modA_v1.o` reused untouched (SHA-256 & mtime verified) + `gcc-10` | `p130-word-pair-v1:w10-iface-v1:71eb49620ebd4c52` (**IDENTICAL**) | `0` | **`44`** | **PASS** |
| **Case 3: Incompatible sig change (`+bonus: U32`)** | `x86-iface modB_v3` -> **CHANGED stamp**; stale `stamp_v1` rejected (`rc=1`, `base_cache: cache stamp`); stale `modA_v1` rejected (`rc=1`, `check: main: type mismatch`); rebuilt `modB_v3.o` + `modA_v3.o` + `gcc-10` | `p130-word-pair-v1:w10-iface-v1:f6da53fd6a54942c` (**CHANGED**) | `0` | **`54`** | **PASS** |
| **`--trace x86-module`** | `--trace x86-module modA_v1` (`1,864.1 ms`, 8 `[bend-trace]` stage lines, `sh_info=1565` valid) | — | — | — | **PASS** |

---

## Stage Timings on `research/agy/w9_ladder/rung1_parse.bend` (`3,440` live segments)

Measured via [`bench_rung1.mjs`](bench_rung1.mjs) (`locked_node.sh`, `-O0` `x187_prepared_fast`):

| Compiler | `p86_plan` | `x198pw_plan` | `x187_prepared_fast` | Total (`-O0`) | `.o` Size |
| :--- | ---: | ---: | ---: | ---: | ---: |
| `wave8_unified` (recorded baseline) | `6,874.0 ms` | `10,365.0 ms` | `16,918.0 ms` | `34,157.0 ms` | `9,087,456 B` |
| `wave8_unified` (live paired on host) | `6,724.8 ms` | `12,770.4 ms` | `20,686.9 ms` | `40,182.1 ms` | `9,087,456 B` |
| **`wave10_unified` (live paired on host)** | **`6,721.2 ms`** | **`13,154.2 ms`** | **`21,216.0 ms`** | **`41,091.4 ms`** | **`8,902,632 B` (`-184.8 KB` / `-2.03%`)** |
| `wave10_unified` (earlier quiet run) | `6,991.5 ms` | `12,441.3 ms` | `18,660.1 ms` | `38,092.9 ms` | `8,902,632 B` (`-2.03%`) |

*Note*: In JS (`api.mjs`), `wave10_unified` is within `~2.3%` of `wave8_unified` on the live paired run while emitting a **`2.03%` smaller `.o`** (`-184,824 B`). The `w9_str_hot` changes (`agy_sh_try` in `-O0` + `nt_choose` hash-trie) trade minor JS overhead for large native x86-64 speedups once compiled to native `n1` in Phase 2B.

---

## Hygiene & Cleanup
- `/tmp/agy_w10_compose/` cleaned (verified absent).
- `selfhost/build/agy/wave8_unified/*` untouched.
- `/dev/md2` free space verified `>= 5.0 GiB`.
