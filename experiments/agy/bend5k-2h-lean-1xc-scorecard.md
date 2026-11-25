# `bend5k` 2-Hour Lean & Fast `1× C` Campaign — Final Scorecard

**Date:** `2026-11-24 / 2026-11-25` (`23:19 → 01:11 UTC`)  
**Branch:** `selfhost/agy` (verified head before scorecard commit: `fb3b6e51`)  
**Promoted Binary:** `selfhost/build/agy/bend5k/bend5k_o2` (bit-identical stage-2 self-hosted `-O2` compiler)  
**Raw JSON Evidence:** `research/agy/bend5k/final_2h_lean_results.json`

---

## 1. Headline Result (All User Guardrails Exceeded)

| Metric | User Target | Start of 2h Campaign (`2f85782c`) | Final (`fb3b6e51`) | Delta |
|---|---|---:|---:|---:|
| **7-Family Geomean vs `gcc-10 -O2`** | Toward `1.0× C` | `1.9949×` | **`1.8212×`** (`7/7 OK`) | **`-8.7%`** *(2/7 beat C, 4/7 `< 2×`)* |
| **`terrain` Holdout (5-run CPU 7)** | Faster | `50.4105 s` (`6.40×`) | **`40.7938 s`** (`5.18×`) | **`-19.1%`** *(`-70.3%` vs `137.5 s`)* |
| **1-Core `-O2` Self-Host (`s2 == s3`)** | Hard `<= 20 s`, **ideal `<= 10 s`** | `11.807 s` | **`8.547 s`** *(bit-identical)* | **`-27.6%`** *(well under `10 s`!)* |
| **1-Core `-O0` Self-Compile** | Fast | `7.160 s` | **`3.688 s`** | **`-48.5%`** *(nearly `2×` faster)* |
| **Total LOC (`selfhost/bend5k/*.bend`)** | Hard `<= 15k`, **ideal `~10k`** | `10,322` | **`10,595`** | **`+273` net LOC** |
| **`bend5k.o` (`-O2` object size)** | Compact | `12,095,968 B` | **`11,591,264 B`** | **`-505 KB` (`-4.2%`)** |
| **Correctness & Safety** | `158/158`, `0 @unsafe` | `158/158 PASS` | **`158/158 PASS`, `0 @unsafe`, `ALL PROOFS CHECK`** | `0` regressions |

---

## 2. Official 5-Run Uncontended Benchmark Table (CPU 7 vs `gcc-10 -O2`)

Command:
```bash
python3 selfhost/bend5k/bench_b5k.py \
  --bend5k selfhost/build/agy/bend5k/bend5k_o2 \
  --opt-flag=-O2 --runs 5 --cpu 7 --holdout-timeout 120 \
  --label bend5k-2h-lean-final --json-out research/agy/bend5k/final_2h_lean_results.json
```

| Benchmark | Start (`2f85782c`) | Final `bend5k -O2` | `gcc-10 -O2` | Final Ratio (`b5k / gcc10`) | Compile Time | Obj Size | Status |
|---|---:|---:|---:|---:|---:|---:|:---:|
| **`list`** | `0.8695×` | **`0.2254 ms`** | `0.2637 ms` | **`0.8548×`** *(beats C by 15%)* | `443.7 ms` | `155,088 B` | OK |
| **`nbody`** | `0.9851×` | **`88.3071 ms`** | `88.7451 ms` | **`0.9951×`** *(beats C)* | `641.0 ms` | `127,760 B` | OK |
| **`gameoflife`** | `1.8256×` | **`1593.4419 ms`** | `921.7667 ms` | **`1.7287×`** | `749.0 ms` | `132,448 B` | OK |
| **`expression`** | `2.1698×` | **`11.9386 ms`** | `6.2494 ms` | **`1.9104×`** *(sub-2×!)* | `437.3 ms` | `155,232 B` | OK |
| **`histogram`** | `2.9728×` | **`58.8582 ms`** | `23.6832 ms` | **`2.4852×`** *(`-16.4%`)* | `809.0 ms` | `192,736 B` | OK |
| **`editdist`** | `3.0000×` | **`25.3125 ms`** | `9.8438 ms` | **`2.5714×`** *(`-14.3%`)* | `519.4 ms` | `170,688 B` | OK |
| **`bst`** | `4.1558×` | **`48.4215 ms`** | `13.0823 ms` | **`3.7013×`** *(`-10.9%`)* | `455.1 ms` | `158,112 B` | OK |
| **7-Family Geomean** | `1.9949×` | — | — | **`1.8212×`** | — | — | **7 / 7 OK** |
| **`terrain` (holdout)** | `50.4105 s` (`6.40×`) | **`40.7938 s`** | `7.8733 s` | **`5.1813×`** *(`-19.1%`)* | `739.1 ms` | `148,192 B` | **OK** |

---

## 3. Qualification, Proof & Self-Hosting Verification

- **Proof & Safety Check (`research/agy/locked_bun.sh --check-only`):** **`ALL PROOFS CHECK`** (`7.30 s`, `0` errors, **`0` `@unsafe` annotations**, `10,595 / 15,000` LOC).
- **Bit-Identical Self-Hosting (1-core CPU 7, `bend5k.bend` = `10,595` LOC):**
  - `s1` (`-O2`): `8.412 s`, `12,207,824 B`
  - `s2` (`-O2`): `8.658 s`, `11,591,264 B`, `sha256 = 356758a8a2ba17812861e494a83f2809e8a4b3725a771cdb3930d889ba1e0241`
  - `s3` (`-O2`): **`8.547 s`**, **`11,591,264 B`**, **`sha256 = 356758a8a2ba17812861e494a83f2809e8a4b3725a771cdb3930d889ba1e0241`** (**bit-identical `s2 == s3`**)
  - `s2_o0` (`-O0`): **`3.688 s`**, `3,517,104 B`
- **Native Qualification (`158 / 158 PASS`, `0` violations):**
  - `run_qual_b5k.py --opt O0`: **`64 / 64 PASS`** (`61` exec, `3` reject)
  - `run_qual_b5k.py --opt O2`: **`64 / 64 PASS`** (`61` exec, `3` reject, `32.28 s`)
  - Observer Gate `-O0` (`5` probes × `{normal, cap-no8, all-hot}`): **`15 / 15 PASS` (`0` violations)**
  - Observer Gate `-O2` (`5` probes × `{normal, cap-no8, all-hot}`): **`15 / 15 PASS` (`0` violations)**

---

## 4. Tracks Landed (`selfhost/agy`, `3e0f1913`..`fb3b6e51`)

- **Wave 1 (`3e0f1913`, `96e5593c`, `1ac03c6a`, `91d12fe2`):**
  - `E1-D` (`-2` LOC): `U32` bit-trie `ChkTrie` in `check.bend`, lazy lexer/parser steps, O(1) `sym_intr`/`sym_kind` tables in `lower.bend` (`--check-only` `2.09 s → 1.02 s`).
  - `E1-C` (`+52` LOC): Structural SIB `[base + idx*8]` load/lea fusion, generalized `cmp+jcc` fusion, `elf_append_buf`.
  - `E1-A` (`+72` LOC): Sound numeric-scalar array fast paths (`sc == 2`, `x64_run_nu`, `IArrOp 79`), non-self-tail-call array hoisting (`terrain` `-369` insns), callee-saved `ha0_dp`/`ha0_mk` pinning.
  - `E1-B` (`+15` LOC): Fast scalar rewriter on large programs, algebraic identities (`0-b`, `a^~0`), dead-code removal.
- **Wave 2 (`a237ced6`, `1833d987`, `f46b3f4d`, `8780d544`):**
  - `E2-B` (`+58` LOC): `lea (%dp, %rdi, 8), %rdi` hoisted SIB-8 fusion, dual-array `%r10`/`%r11` pinning (`histogram:count.go`), frameless self-tail-call loops (`bst:repeat_key`, `expression:unwind`), direct-GPR magic `mod` & `U32.not`/`neg`.
  - `E2-D` (`+43` LOC): Wired `IArrOp 79` for statically-scalar `Array.set`, Nat-literal peeling fix, `IKeep`-safe global SSA copy propagation, empty-block terminator forwarding.
  - `E2-A` (`-52` LOC!): Crushed the `3.48 s` `elf_compute_cid_hot` self-compile bottleneck with 32-bit-packed bitset `RaVec<U32>` + single-word `kept_param` bitmask + direct `e_b1..4`/`e_u32` emission + `XStore` SIB fusion (`-O0` `-40%`, `-O2` `-23%`).
  - `E2-C` (`+49` LOC): Hoisted `IArrOp` handle de-weighting, sound spill-slot coalescing, used-callee hint coalescing (`gameoflife:step` `-60` insns, `expression:unwind` `0` spills).
- **Wave 3 (`193b846f`, `fb3b6e51`):**
  - `E3-B` (`+38` LOC): Structural reg-mem load+ALU/CMP/RMW fusion in `elf.bend` (`-616 KB` on `bend5k.o`, `-3.8` to `-6.2 KB` per benchmark `.o`).
  - `E3-A` (`+0` LOC!): 100%-sound cold-path outlining for `IArrOp`/`ICtor`/`ITake`/`IKeep`/`ISink` (contiguously packing hot loop blocks and removing taken `jmp l_done` from every fast path; `histogram` `-4.4%`).
