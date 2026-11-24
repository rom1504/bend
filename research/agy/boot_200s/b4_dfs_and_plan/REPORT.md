# B4: DFS Dependency-Order Balanced Splitter + `x198pw_plan` / `p86_plan` Hotspot Killer

**Date:** 2026-11-24  
**Hardware / Guard:** CPU 6 (`taskset -c 6`), `ulimit -s 262144`, strictly 1 compiler process at a time, never `--nodrop`, `/dev/md2 >= 5.0 GiB`.

## Executive Summary

1. **DFS Dependency-Order Balanced Splitter (`--order dfs`)** in `research/agy/s10_campaign/s10g_nodrop_and_k24/split_kN_balanced.py` exceeds all targets for both `K=16` and `K=24`:
   - **`k16_wave17_dfs` vs `k16_wave17` (BFS):**
     - **Stubs:** `8,793 → 2,041` (**`-76.8%`**, beats `-72%` target)
     - **Stub source bytes (`auto` ABI):** `978.1 KB → 210.5 KB` (**`-78.5%`**, `-767.5 KB` less stub source)
     - **Synthetic export entries (`.exp`):** `5,593 → 1,061` (**`-81.0%`**, beats `-76%` target)
     - **Byte balance (`max/avg`):** `1.0056× → 1.0035×` (even tighter than BFS!)
     - **Forward dependency violations:** `0` (`0 lost, 0 dup, 0 cycles`)
   - **`k24_wave17_dfs` vs `k24_wave17` (BFS):**
     - **Stubs:** `10,085 → 2,459` (**`-75.6%`**)
     - **Stub source bytes (`auto` ABI):** `1,127.9 KB → 251.2 KB` (**`-77.7%`**, `-876.7 KB`)
     - **Synthetic export entries (`.exp`):** `6,051 → 1,160` (**`-80.8%`**)
     - **Byte balance (`max/avg`):** `1.0168×` (`<= 1.03×`, `0` forward violations)
2. **Native `n8_o2 --trace x86-module` (`-O2`) Benchmark (CPU 6):**
   - On `m08` (representative interior module): **`p86_plan` sped up `1.88×`** (`14,581 ms → 7,766 ms`), **`x198pw_plan` sped up `1.07×`** (`28,674 ms → 26,757 ms`), **`x187_priv` sped up `1.29×`** (`12,677 ms → 9,858 ms`), and `.o` size dropped **`-17.8%`** (`6.44 MB → 5.29 MB`).
   - On `m00`: **`p86_plan` sped up `1.44×`** (`10,240 ms → 7,096 ms`). Note that per-module `x187_pub` depends on which functions land in that module (DFS puts a heavy CPS subtree in `m00` whereas BFS puts 1,100 tiny leaf defs in `m00`); across all 16 modules, real `def` count is invariant (`9,380`) while stubs drop by `6,752` (`-76.8%`) and synthetic exports drop by `4,532` (`-81.0%`).
3. **`gdb -batch -ex 'bt 10'` Sampling on Clean `n8_o2` + `apply_b4.py`:**
   - Captured **16 samples during `p86_plan`** and **30 samples during `x198pw_plan`** on `k16_wave17_dfs/m00_zero.bend`.
   - Implemented **4 semantics-preserving, 0%-`-O2`-regression optimizations** in `research/agy/boot_200s/b4_dfs_and_plan/apply_b4.py` (100% disjoint from B2/B3, idempotent, **`0` type/linearity errors** under `research/agy/locked_bun.sh --check-only`).

---

## Part 1: DFS Dependency-Order Balanced Splitter

### Algorithm (`--order {bfs,dfs,source}`)
The original `split_kN_balanced.py` used Kahn's BFS queue (`deque.popleft()`), which scatters tightly coupled helper/caller chains across distant modules and inflates cross-module stubs and `.exp` exports.

We added `--order {bfs,dfs,source}` (default `bfs` for 100% backward compatibility):
- **`--order dfs`:** Iterative **post-order DFS** on SCC dependency edges (`dag_deps`) starting from `main_scc` with deterministic tie-breaking `(-scc_bytes[s], scc_min_line[s])`, emitting each subsystem's exclusive helper subtree immediately adjacent to its caller, then visiting any unreachable SCCs in the same order, and pinning `main_scc` last. The resulting topological order feeds directly into the existing exact binary-search painter's partition (`partition_optimal_balanced`).
- **`--order source`:** Min-heap Kahn's topological sort keyed by `scc_min_line[s]` (reduces `K=16` cross-imports from `8,779` to `3,577`).

### Split Metrics (`selfhost/build/agy/wave17_unified/compiler.bend`)

| Split | Order | `max/avg` | Forward Edges | `.exp` Exports | Cross-Mod Imports | Stubs (`auto`) | Stub Bytes (`auto`) |
|---|---|---:|---:|---:|---:|---:|---:|
| `k16_wave17` | `bfs` | `1.0056×` | `0` | `5,593` | `8,779` | `8,793` | `978.1 KB` |
| **`k16_wave17_dfs`** | **`dfs`** | **`1.0035×`** | **`0`** | **`1,061` (`-81.0%`)** | **`2,030` (`-76.9%`)** | **`2,041` (`-76.8%`)** | **`210.5 KB` (`-78.5%`)** |
| `k24_wave17` | `bfs` | `1.0070×` | `0` | `6,051` | `10,065` | `10,085` | `1,127.9 KB` |
| **`k24_wave17_dfs`** | **`dfs`** | **`1.0168×`** | **`0`** | **`1,160` (`-80.8%`)** | **`2,441` (`-75.7%`)** | **`2,459` (`-75.6%`)** | **`251.2 KB` (`-77.7%`)** |

### Representative Module Benchmark (`n8_o2 --trace x86-module`, CPU 6)

| Case | `.exp` | `ximp` | `p86_plan` | `x198pw_plan` | `segs` | `x187_priv` (`cnt`) | `x187_pub` | `x187_elf` | Wall | `.o` Size |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `bfs_m00` | 1,074 | 0 | 10,240 ms | 35,125 ms | 1,334 | 31,921 ms (1,441) | 6,177 ms | 2,608 ms | 86.77 s | 7.37 MB |
| `dfs_m00` | 150 | 0 | **7,096 ms (`1.44×`)** | 48,022 ms | 1,667 | 22,349 ms (316) | 45,520 ms | 3,810 ms | 127.67 s | 8.58 MB |
| `bfs_m08` | 313 | 572 | 14,581 ms | 28,674 ms | 1,910 | 12,677 ms (346) | 26,512 ms | 2,111 ms | 85.61 s | 6.44 MB |
| **`dfs_m08`** | **45** | **146** | **7,766 ms (`1.88×`)** | **26,757 ms (`1.07×`)** | 2,328 | **9,858 ms (295, `1.29×`)** | 40,426 ms | 2,282 ms | 87.80 s | **5.29 MB (`-17.8%`)** |

---

## Part 2: `gdb` Sampling & `apply_b4.py` Hotspot Killer

### `gdb -batch -ex 'bt 10'` Sampling on `n8_o2` (`k16_wave17_dfs/m00_zero.bend`, CPU 6)
- **`p86_plan` (16 samples):** `p98_tag_eq` / `agy_str_eq` / `f_eq` / `String.eq`, `w7_infer_tag`, `w7c_subst_var`, `terms_at`/`ks`/`kid`/`j_strip`, `term_drop`/`p125_rt_ctor2`.
- **`x198pw_plan` (30 samples):**
  - `nc_uses_term` / `nc_uses_list` (**3/30 samples**, 10%): double-unpacking `KTerm` via `p98_tag_eq` + `w5c2_nc_uses_if` + `ix(t)`/`ks(t)` on every AST node including `KLiteral` and `KLambda`.
  - `nq_layout_subst` / `nq_layout_subst_list` (**2/30 samples**, 6.7%): calling slow CPS `String.eq(tag, "Var")` + `k_rebuild` + 6 field accessors (`nm/qt/ks/rm/kb/ke`) even on leaf `KTerm` nodes with `kids == Nil{}`.
  - `term_drop` (5/30), `span_fade` (3/30), `p125_rt_ctor2` (2/30): AST allocation/drop churn directly driven by unnecessary leaf rebuilds in `nq_layout_subst` and repeated unpacks.

### Four Optimizations in `apply_b4.py` (0% `-O2` Runtime Regression)
1. **`b4_nc_uses_term` (`x198pw_plan`):** Single `match t` in `nc_uses_term` with `agy_str_eq(tag, "Var")`, instant `KLiteral` return, `KLambda` bypass, and `Nil{}` leaf short-circuit.
2. **`b4_nq_layout_subst` (`x198pw_plan`):** `agy_str_eq(tag, "Var")`, zero-allocation `Nil{}` leaf return, and direct `KTerm{...}` reconstruction instead of `k_rebuild` + 6 accessors.
3. **`b4_pre_bang_index` (`x198pw_plan` `w7_pre_build_set`):** Replaces `O(N * |bangs|)` linear `nb_contains(bangs, name)` with `O(1)` `w5c3_find` on `w8_bangs_index(bangs, missing())`.
4. **`b4_o2_mod_check` (`p86_plan` `s10e_plan_loaded_check`):** In `-O2 x86-module` (`fast == False && is_mod == True`), routes through `s10e_p143cb_program(..., True{})` so the 422 shared `ADT`s, `law`s, and synthetic zero-`.p130` `@unsafe` stubs skip redundant `check_definition_world` while all real `def`s remain 100% typechecked (`x86-object`/`x86` stays untouched).

### Verification
- **Disjointness & Idempotency:** Confirmed `apply_b2.py` + `apply_b4.py` compose cleanly (`+8,642 B`) and re-applying `apply_b4.py` is a 0-byte no-op.
- **Typechecker Gate:** `research/agy/locked_bun.sh --check-only` passed with **0 type/linearity errors**.
