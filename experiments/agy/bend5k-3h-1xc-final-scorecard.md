# `bend5k` 3-Hour `1× C` Optimization Campaign — Final Scorecard

**Date:** `2026-11-24` (`19:02 → 21:45 UTC`)  
**Branch:** `selfhost/agy` (verified head before scorecard commit: `f4982d09`)  
**Promoted Binary:** `selfhost/build/agy/bend5k/bend5k_o2` (bit-identical stage-2 self-hosted `-O2` compiler)  
**Raw JSON Evidence:** `research/agy/bend5k/final_3h_results.json`

---

## 1. Headline Result

Across the 3-hour campaign, our clean-sheet self-hosted Bend-to-x86-64 ELF compiler (`selfhost/bend5k/`, **`10,322 / 10,500` LOC**, **`0` `@unsafe` annotations**, **`ALL PROOFS CHECK`**) broke **sub-`2.0×` `gcc-10 -O2`** across the 7-family proxy suite on uncontended 5-run medians (CPU 7), with **2 families beating `gcc-10 -O2` outright** (`list` **`0.8695×`**, `nbody` **`0.9851×`**):

| Milestone | 7-Family Geomean vs `gcc-10 -O2` | `terrain` Holdout (1-core `b5k`) | 1-Core `-O2` Self-Host (`s2==s3`) | Qualification |
|---|---:|---:|---:|---|
| Initial `bend5k` (tree arrays) | `79.75×` | — | — | `64/64` |
| Start of 3h Campaign (`fad53b3a`) | `7.746×` | `137.5 s` | `6.466 s` | `158/158 PASS` |
| Wave A (`9f034ec4`..`394e1e3e`) | `5.355×` | `80.5 s` | `6.818 s` | `64/64 + 15/15 PASS` |
| Wave B (`2ce46ed2`..`f3d74e75`) | `3.585×` | `67.0 s` | — | `64/64 + 15/15 PASS` |
| Wave C (`a8d3a250`..`9c8ffcc8`) | `2.258×` | `52.15 s` | `12.853 s` | `64/64 + 15/15 PASS` |
| **Wave D Final (`f4982d09`, 5-run CPU 7)** | **`1.9949×` (`-74.2%` vs start, `-97.5%` vs initial)** | **`50.4105 s` (`-63.3%`)** | **`11.807 s` (`s2 == s3` bit-identical)** | **`158/158 PASS` (`0` violations)** |

---

## 2. Official 5-Run Uncontended Benchmark Table (CPU 7 vs `gcc-10 -O2`)

Command:
```bash
python3 selfhost/bend5k/bench_b5k.py \
  --bend5k selfhost/build/agy/bend5k/bend5k_o2 \
  --opt-flag=-O2 --runs 5 --cpu 7 --holdout-timeout 120 \
  --label bend5k-3h-final --json-out research/agy/bend5k/final_3h_results.json
```

| Benchmark | `bend5k -O2` (median) | `gcc-10 -O2` (median) | Ratio (`b5k / gcc10`) | `b5k` Compile Time | Object Size | Status |
|---|---:|---:|---:|---:|---:|:---:|
| **`list`** | **`0.2293 ms`** | `0.2637 ms` | **`0.8695×`** *(15% faster than C)* | `477.55 ms` | `162,928 B` | OK |
| **`nbody`** | **`88.1060 ms`** | `89.4402 ms` | **`0.9851×`** *(beats C)* | `709.09 ms` | `133,520 B` | OK |
| **`gameoflife`** | `1683.7997 ms` | `922.3494 ms` | **`1.8256×`** | `802.46 ms` | `138,640 B` | OK |
| **`expression`** | `13.5599 ms` | `6.2494 ms` | **`2.1698×`** | `478.71 ms` | `163,088 B` | OK |
| **`histogram`** | `71.4282 ms` | `24.0273 ms` | **`2.9728×`** | `905.05 ms` | `206,240 B` | OK |
| **`editdist`** | `29.0625 ms` | `9.6875 ms` | **`3.0000×`** | `574.59 ms` | `179,424 B` | OK |
| **`bst`** | `54.3680 ms` | `13.0823 ms` | **`4.1558×`** | `487.22 ms` | `166,016 B` | OK |
| **7-Family Geomean** | — | — | **`1.9949×`** | — | — | **7 / 7 OK** |
| **`terrain` (holdout)** | `50.4105 s` | `7.8740 s` | `6.4021×` | `801.17 ms` | `155,520 B` | **OK** |

---

## 3. Qualification, Proof & Self-Hosting Verification

- **Proof & Safety Check (`research/agy/locked_bun.sh --check-only`):** **`ALL PROOFS CHECK`** (`6.11 s`, `0` errors, **`0` `@unsafe` annotations** across all `10,322 / 10,500` LOC).
- **Bit-Identical Self-Hosting (1-core CPU 7, `bend5k.bend` = `10,322` LOC):**
  - `s1` (`prev -> final -O2`): `13.195 s`, `12,100,864 B`
  - `s2` (`final -> final -O2`): `12.143 s`, `12,095,968 B`, `sha256 = aab72a53effa2dc59ab33f9cfcfdbd31e55e732f45a0302459f986d58f54aea4`
  - `s3` (`final -> final -O2`): **`11.807 s`**, **`12,095,968 B`**, **`sha256 = aab72a53effa2dc59ab33f9cfcfdbd31e55e732f45a0302459f986d58f54aea4`** (**bit-identical `s2 == s3`**)
  - `s2` (`final -> final -O0`): **`7.160 s`**, `3,401,248 B`
- **Native Qualification (`158 / 158 PASS`, `0` violations):**
  - `run_qual_b5k.py --opt O0`: **`64 / 64 PASS`** (`61` exec, `3` reject, `9.44 s`)
  - `run_qual_b5k.py --opt O2`: **`64 / 64 PASS`** (`61` exec, `3` reject, `34.67 s`)
  - Observer Gate `-O0` (`5` probes × `{normal, cap-no8, all-hot}`): **`15 / 15 PASS` (`0` violations)**
  - Observer Gate `-O2` (`5` probes × `{normal, cap-no8, all-hot}`): **`15 / 15 PASS` (`0` violations)**

---

## 4. Key Optimization Tracks Landed (`selfhost/agy`)

- **Wave A (`9f034ec4`, `ff32f64d`, `cd197ffc`, `394e1e3e`):** Pair-param worker-wrapper unboxing, whole-program per-ctor `cid_hot` + `capabilities = 9` (Observer-safe), direct reg-reg XMM ALU, pinned `state->e.mem`, fused `cmp+jcc`, 11-GPR leaf-loop allocation.
- **Wave B (`2ce46ed2`, `dffc3dab`, `b8749a36`, `f3d74e75`):** Compact x86-64 encodings (`disp8`/`imm8`/`mod=00`, `-24.1%` `.text`), killed bogus `+` `String.append` checks, inlined `U32/Nat.min/max/sub`, constant `U2F`/`FDIV` folding + `xmm0` cache (`nbody` `0.985×`), magic-reciprocal `div`/`mod`, inline shared `0x82` `ITake`/`IKeep`/`ISink`, N-field (`arity 2..4`) worker-wrapper unboxing (`Masks4`).
- **Wave C (`a8d3a250`, `8bbe0fb5`, `49067797`, `f405807a`, `9c8ffcc8`):** Direct `U32.cmp`/`Nat.cmp` lowering, branchless `Bool`, `Nat` Peano flattening, single-ctor hoisting; branch-dominated fact propagation, 4-level leaf inlining (`step_cell` → `step`), post-WW self-tail-call peeling; loop-hoisted `arr_data_ptr`/`arr_mask` (25 → 8 insns per `IArrOp`), dead upper-32-bit `mask32` elimination, zero-frame leaf functions, all-scalar `ICtor`/`IKeep`/`ISink`/`Array.set` fast paths; self-`TTailCall` back-edge interval & param coalescing, structural 32-bit U32 mask fusion in `elf.bend` (`0` remaining `shl 32; shr 32` pairs).
- **Wave D (`6130fb41`, `f4982d09`):** Multi-def join scalar back-propagation (eliminated all 4 per-iteration `rt_keep` calls in `editdist:columns`), global single-def SSA constant propagation (`-187 lines / -39 spills` in `gameoflife:step`), dynamic trie depths & large-program pass gating (self-compile `12.88 s → 11.81 s`), function-wide constant table + dead `IConst` elimination, immediate `IBin`/`ICmp`, fused hoisted array RMW, and 2-pass direct tail-call moves.

---

## 5. Next Bottlenecks Toward `~1.0× C` on Remaining Families

- **`bst` (`4.16×`), `histogram` (`2.97×`), `editdist` (`3.00×`):** Hoisting `arr_data_ptr` into a dedicated callee-saved register across tight array loops and proving scalar-only array element types (eliminating per-write `old_val >> 56 == 2` checks) are the clearest remaining levers.
- **`expression` (`2.17×`), `gameoflife` (`1.83×`):** Register-resident accumulator/bitboard loops with zero spill reloads inside `step` and tighter switch/tag dispatch in `unwind`.
