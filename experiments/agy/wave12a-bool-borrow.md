# Experiment: Wave 12-A — Unboxed `Bool` Match Fast-Path & Borrow-Loop Direct Field Load

- **Date:** 2026-11-23
- **Hypothesis:** Eliminating the 37-insn×2 tagged-`Bool` decode, `-0x840(%rbp)` stack-buffer bounce, duplicate `CCons` tag sub, and unhoisted `state->heap` reload in `$p118borrow.read.has` / `$p118borrow.read.len` (via pure-Bend x86-64 codegen in `x190_step` and `x185_late_stmts_h`) will accelerate `hashmap` (`2.0–2.8×`) and `bst`/`expression` (`1.2–1.5×`).
- **Baseline:** `selfhost/build/agy/wave8-native-self/n1` (`selfhost/build/agy/wave8_unified/compiler.bend`), isolated on CPU `5` (`taskset -c 5`).
- **Outcome:** **Correct & Promotable Codegen Cleanup, Partial Wall-Clock Gain (`1.086×` `hashmap`, `1.018×` `expression`, `1.000×` `bst`)**.
  - **Assembly target exceeded:** `$p118borrow.read.has` hot loop shrunk from `~92` → **`27` insns/node (`3.4×` fewer)**, function size `790 → 503 B` (`-36.3%`); `$p118borrow.read.len` shrunk from `~45` → **`17` insns/node (`2.6×` fewer)**; `.o` sizes shrunk on all 3 benchmarks (`-1.4 KB` `hashmap`, `-5.0 KB` `bst`, `-0.9 KB` `expression`).
  - **Root cause of wall-clock ceiling:** Out-of-order x86-64 execution previously hid most of the 65 eliminated ALU instructions behind L2/L3 serial pointer-chase latency (`mov 0x8(%rbx,%rdi,8),%r15` across freelist-scattered `CCons` nodes). Further `hashmap` speedups require reducing runtime/memory traffic (inline boxed `Array.get`/`Array.set` fast-path + allocation/drop reduction).
  - **Compile-time safety lesson:** Local liveness `w12_i_dead_in` must halve fuel (`U32.div(fuel, 2)`) on `P113DIf` branches to guarantee $O(\text{fuel})$ linear compile time on deeply nested `match`es (`native64` batch 16..31 exposed exponential blowup before halving, and dropped to `26.6 s` after).
- **Verification:**
  - `compiler.bend` typecheck / JS build: **0 type errors**.
  - `native64` qualification gate: **`64/64 PASS`** (`92.56 s`, CPU `5`).
  - Observer Gate (`normal`, `cap-no8`, `all-hot`): **`15/15 PASS`** (`0` violations, CPU `5`).
- **Evidence:**
  - [REPORT.md](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/REPORT.md)
  - [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/results.json)
  - [w12a_bool_borrow.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/w12a_bool_borrow.patch)
  - [apply_w12a_bool_borrow.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/apply_w12a_bool_borrow.py)
