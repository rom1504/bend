# W14-D Report: Pure-Bend `bend_build_real` Driving Real `n5_o2` Self-Compilation (`k14_wave13`)

**Date:** 2026-11-23  
**Status:** **PASSED** (`ALL PROOFS CHECK`, `0` `@unsafe`, `0` Python / `0` JS / `0` C / `0` `objcopy` at runtime, `14/14` `.o` + `merge.o` **100% SHA-256 bit-identical** to W13-INT Stage 2A, all 4 real self-compilation scenarios PASS on CPUs `4, 5, 6`).

---

## 1. Hardening Upgrades (`bend_build_pipe.bend` → `bend_build_real.bend`)

Built [`bend_build_real.bend`](bend_build_real.bend) (`ALL PROOFS CHECK`, **`0` `@unsafe`**) and compiled to standalone native x86-64 ELF binary [`bend_build_real`](bend_build_real) (`845,408 B`):

1. **6-Column Real-Project Manifest (Backward-Compatible with 4-Column):**
   - `<name> <src> <fid_base> <out_o> [<prefix_or_-> <footer_or_->]`
   - Handles `k14_wave13`'s `m00a` (`types.bend` prefix + `m00a.exp` export footer), `m00b..m10` (`import Base` prefix + `mXX.exp` footer), and `m11` (`import Base` prefix, entry module) natively with **0 Python at build time**.
   - On cache HIT: zero temp files written. On cache MISS: atomically assembles `<tmp_src>` via `cat` and cleans it up after `n5_o2` exits.
2. **Parallel Streaming Dual-FNV-1a File Hashing (`IO.fork` + 64 KiB Chunks):**
   - Replaces `O(N²)` `acc ++ chunk` whole-file string accumulation with single-pass streaming dual 32-bit FNV-1a (`HashPair{h1, h2}`) forked across all modules via `IO.fork`/`IO.join`.
   - Cut 14-module (`3.65 MB`) no-op content verification from `206 ms` → **`155–156 ms`** (pure-Bend `File.read` floor; `base.bend` has no `mtime` stat primitive, so every no-op build performs 100% full-content verification).
3. **Pure-Bend `.p130` Header Stamp Adoption (`--adopt-p130`):**
   - Reads the first 512 bytes of pre-seeded `.p130` files, decodes the UTF-8 word-pair length (`lo = u0 - 65536`, `hi = u1 - 65536`) and extracts the exact ASCII interface stamp directly in pure Bend (`1–26 ms` per module), writing `.ikey` and `.stamp` sidecars so subsequent runs perform strict FNV-1a verification without `--adopt-p130`.
4. **Hardened `n5_o2` Execution:**
   - Enforces `ulimit -s 262144`, passes `--trace x86-module-fast` to `--jobs N` parallel `IO.fork` workers, runs native `n5_o2 x86-merge-obj` (`m11` first!), and links with `gcc-10 -O2 -no-pie ... runtime-agy.o -lm -lpthread`.

---

## 2. Real `n5_o2` Self-Compilation Verification (`k14_wave13`, CPUs `4, 5, 6`, `--jobs 3`)

All 4 scenarios ran strictly pinned to dedicated CPUs `4, 5, 6` (`taskset -c 4-6`), driving `selfhost/build/agy/wave13-native-mod/n5_o2` over all 14 modules (`65,180 / 65,532` FIDs) with zero Python/JS/C/`objcopy`:

| Scenario | Flags | `iface_ms` | `compile_ms` | `merge_ms` | `link_ms` | `total_ms` | Rebuilt | `.o` SHA-256 Check | `n6_bend_build` Smoke |
|---|---|---:|---:|---:|---:|---:|:---:|:---:|:---:|
| **1. Warm-`.p130` 3-Core Build** | `--jobs 3 --adopt-p130` | `377` | `140,545` | `64` | `751` | **`141,360`** (`141.36 s`) | **`14/14`** | **`14/14` + `merge.o` bit-identical to W13-INT** | **`out=34`** |
| **2. No-Op Rebuild** | `--jobs 3` | `156` | `156` | `0` | `0` | **`156`** (runs: `162, 155, 156`) | **`0/14`** | **`14/14` unchanged** | skipped (up to date) |
| **3. Leaf Edit (`m11`)** | `--jobs 3` | `229` | `28,289` | `55` | `483` | **`28,828`** (`28.83 s`) | **`1/14`** (`m11.o`) | **`13/14` unchanged**, `m11.o` changed | **`out=34`** + `stage=read_w14d` |
| **4. Mid-Stack Body Edit (`m06`)** | `--jobs 3` | `14,900` | `35,155` | `56` | `499` | **`35,711`** (`35.71 s`) | **`1/14`** (`m06.o`) | **`13/14` unchanged**, `m06.o` changed | **`out=34`** |

### Key Verified Highlights
- **2.89× Parallel Scaling on 3 Cores (Test 1):** Sum of 14 module compiles was `405,792 ms`; wall `compile_ms` on 3 cores was `140,545 ms` (**`2.89×` / 96.2% efficiency**). All `14/14` `.o` files and `merge.o` were **100% SHA-256 bit-identical** to W13-INT Stage 2A (`/tmp/agy_k14_w13_cache/obj_o0/`).
- **100% Hidden `x86-iface` Pipelining on Mid-Stack Edit (Test 4):** Editing `m06.bend`'s `w10_if_suffix_set` body triggered `m06.p130` (`14,591 ms`) concurrently with `m06.o` (`35,052 ms`). `m06.p130` produced the **exact same stamp** (`p130-word-pair-v1:w10-iface-v1:a49725d60e163c94`), so downstream `m07..m11` all hit cache in `0–1 ms`, **100% of `m06.p130` (`14.59 s`) was hidden behind `m06.o`**, and only `1/14` modules rebuilt!
- **Full Cleanliness:** `/tmp/agy_w14d/` removed; `/dev/md2` reserve preserved (`>= 5.0 GiB`).

---

## 3. Artifacts
- [`research/agy/w14_campaign/w14d_bend_build_real/bend_build_real.bend`](bend_build_real.bend) — Pure-Bend hardened driver (`ALL PROOFS CHECK`, `0` `@unsafe`)
- [`research/agy/w14_campaign/w14d_bend_build_real/bend_build_real`](bend_build_real) — Standalone native x86-64 ELF binary (`845 KB`)
- [`research/agy/w14_campaign/w14d_bend_build_real/results.json`](results.json) — Structured timing, SHA-256 & verification receipts
- [`experiments/agy/wave14d-bend-build-real.md`](../../../experiments/agy/wave14d-bend-build-real.md) — Experiment summary
