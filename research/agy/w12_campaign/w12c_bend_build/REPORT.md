# Wave 12-C: Pure-Bend Pipelined `bend_build_pipe` Driver

## Summary

Built and verified **[`bend_build_pipe.bend`](bend_build_pipe.bend)** — a **100% pure-Bend** pipelined, incremental, parallel module build driver (`0` Python, `0` JS/Bun at runtime, `0` `@unsafe` declarations, **`ALL PROOFS CHECK`**).

It replaces Python build orchestration (`run_p4_native_repro.py`) with a standalone **655 KB native x86-64 ELF binary** (`bend_build_pipe`) that:
1. Parses topological module manifests (`<name> <src_path> <fid_base> <out_o_path>`, compatible with `k12_wave10/manifest.txt` and `k13_wave11/manifest.txt`).
2. Computes **dual 32-bit FNV-1a** content + `.p130` interface-stamp cache keys for both `x86-iface` and `x86-module-fast`.
3. **Pipelines** `x86-iface` (1 producer stage) with `N` (`--jobs N`) parallel `x86-module-fast` worker threads via native **`IO.fork` / `IO.join` / `Chan.*` + `Process.run`** — as soon as `m_{i-1}.p130` lands, `m_i.o` is dispatched immediately while the iface stage advances to `m_i.p130`.
4. Runs native **`x86-merge-obj`** (entry module first!) + **`gcc-10 -O2 -no-pie`** link, printing a live millisecond timing summary (`iface_ms`, `compile_ms`, `merge_ms`, `link_ms`, `total_ms`, `rebuilt=R/T`).

---

## CLI Usage

```sh
bend_build_pipe [--jobs N] <manifest> <compiler> <base_bend> \
  <base_carrier_p130> <base_stamp> <iface_dir> <runtime_o> <entry_mod> <out_exe>
```

---

## Type-Checking & Native Binary Compilation

1. **`--check-only`:**
   ```text
   selfhost/.assets/bin/bun bend2/main.ts research/agy/w12_campaign/w12c_bend_build/bend_build_pipe.bend --check-only
   -> ALL PROOFS CHECK (rc=0, 0 @unsafe declarations)
   ```
2. **`n3_w10 x86-object` ABI11102 admission probe:**
   - `n3_w10` parsed and type-checked `bend_build_pipe.bend` cleanly, stopping only at the ABI11102 fixed runtime admission gate:
     ```text
     compile: foreign provider unavailable in fixed runtime: Chan.close
     ```
   - This is expected because `runtime-agy.o` (ABI11102, read-only) does not expose `Process.run` or `IO.fork`/`IO.join`/`Chan.*`.
3. **Standalone Native ELF Compilation (0 Python / 0 JS / 0 Bun at runtime):**
   - Emitted C via `selfhost/.assets/bin/bun bend2/main.ts bend_build_pipe.bend -o bend_build_pipe.c` and compiled with `gcc-10 -O2` (stripping Clang-only `__attribute__((musttail))` and stubbing glibc 2.34+ `posix_spawn_file_actions_addclosefrom_np` on glibc 2.31) → standalone **655 KB** native x86-64 ELF binary (`bend_build_pipe`).

---

## End-to-End Verification on CPU 7 (3-Module DAG `modA -> modB -> modC`)

Tested with `selfhost/build/agy/wave10-native-mod/n3_w10`, `--jobs 2`, pinned to CPU `7` (`taskset -c 7`):

| Scenario | `iface_ms` | `compile_ms` | `merge_ms` | `link_ms` | `total_ms` | Rebuilt | `modA.o` SHA | `modB.o` SHA | `modC.o` SHA | Output |
|---|---:|---:|---:|---:|---:|:---:|:---:|:---:|:---:|:---:|
| **1. Cold pipelined** | 19,935 | 20,626 | 66 | 38 | **20,730** | **3/3** | created | created | created | **`42`** |
| **2. No-op rebuild** | 1 | 1 | 0 | 0 | **1** | **0/3** | unchanged | unchanged | unchanged | **`42`** |
| **3. Mid-stack body-only edit (`modB`: `20→30`)** | 9,857 | 9,857 | 65 | 40 | **9,962** | **1/3** | **unchanged** | rebuilt | **unchanged** | **`52`** |
| **4. Interface-changing edit (`modB`: `+extra_b`)** | 9,938 | 10,649 | 63 | 37 | **10,750** | **2/3** | **unchanged** | rebuilt | **rebuilt** | **`52`** |

### Key Verified Properties
- **True Pipelining Overlap (Test 1):** Sequential `iface + compile` sum was `23,447 ms`; pipelined `compile_ms` was `20,626 ms` — 100% of `modA.o` (`1,273 ms`) and `modB.o` (`1,548 ms`) compiled in parallel behind `x86-iface` (`2,821 ms` completely hidden).
- **Sub-2ms No-Op Rebuild (Test 2):** `total_ms = 1 ms` (`< 100 ms` target), `0/3` modules rebuilt, `0/2` ifaces rebuilt, link skipped.
- **1/K Mid-Stack Body-Only Rebuild (Test 3):** Editing `modB`'s body re-ran `modB.p130` (`9,856 ms`, overlapped with `modB.o` `1,304 ms`), produced the **exact same interface stamp** (`p130-word-pair-v1:w10-iface-v1:f5c7e17ef48e3b09`), and caused downstream `modC.o` to **`[cache HIT]` in `0 ms`** with identical SHA-256!
- **Automatic Downstream Invalidation on Interface Change (Test 4):** Adding exported `def extra_b` to `modB` changed `modB.p130`'s stamp (`f5c7e17ef48e3b09` → `f47801cbb3a1ee37`), automatically rebuilding `modB.o` and `modC.o` (`2/3`) while keeping `modA.o` untouched.

---

## Artifacts

- [`research/agy/w12_campaign/w12c_bend_build/bend_build_pipe.bend`](bend_build_pipe.bend) — 100% pure-Bend pipelined build driver
- [`research/agy/w12_campaign/w12c_bend_build/bend_build_pipe`](bend_build_pipe) — Standalone native x86-64 ELF binary (655 KB)
- [`research/agy/w12_campaign/w12c_bend_build/results.json`](results.json) — Structured benchmark & verification receipts
- [`experiments/agy/wave12c-bend-build.md`](../../../experiments/agy/wave12c-bend-build.md) — Experiment summary
