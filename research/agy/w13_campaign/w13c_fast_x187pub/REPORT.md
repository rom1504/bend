# W13-C Report: Fast `x187_pub` — Fused Direct-to-`X187Build` Public Segment Emission

**Status:** **COMPLETE — `2.56×` Speedup on `m11` (`x86-module-fast`) & `2.93×` Speedup on `rung2_frontend.bend` (`x86-object-fast`), 100% SHA-256 Bit-for-Bit Identical `.o` Output, `0` Type Errors, `64/64` (`x86-object-fast`) + `64/64` (`-O2`) + `15/15` Observer Gate PASS.**

- **Date:** 2026-11-23
- **Isolation:** Dedicated CPUs `0, 1` (`taskset -c 0`, `taskset -c 1`), read-only on `selfhost/build/agy/wave11_unified/`.
- **Deliverables:** [w13c_fast_x187pub.patch](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.patch), [w13c_fast_x187pub.bend](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/w13c_fast_x187pub.bend), [build_and_test.py](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/build_and_test.py), [results.json](file:///home/ai/bend2_agy/research/agy/w13_campaign/w13c_fast_x187pub/results.json), [wave13c-fast-x187pub.md](file:///home/ai/bend2_agy/experiments/agy/wave13c-fast-x187pub.md).

---

## 1. Root-Cause Profile of `x187_pub` (`m11`, `3,549` segments)

V8 CPU profiling (`node --cpu-prof`, CPU `0`) of `wave11_unified/api.mjs --trace x86-module-fast` on `m11` (`x187_pub = 11,212 ms`, `31.0%` of compile; `9,304 ms` / `29.2%` on native `n4_o2`) identified 4 exact hotspots:

| Hotspot inside `x187_pub` | Baseline Share | Root Cause |
|---|---:|---|
| `w10f_output_fn` (`w10f_fn_seq_go` + `w10f_fn_inst` + `x187_encode`) | **40.7%** | Built a full `X188Seq` AST of `X187Instruction{String, List<X187Operand>}` + `PLabel`, walked it via 6-function CPS dispatch, string-matched opcodes, and fell back to `x187_encode` (`9.6%`) for `testl`/`movl`/`cmpq`/`addq`/`shrq`/`set*`/`movzbl` + `5,169` `p111_rt_sink`/`p111_rt_keep` templates. |
| `x181_stmts` + `x181_prologue` | **33.3%** | Allocated `X188Seq` trees, called `x185_physical_home`/`x190_value_home` hash lookups (always `None` in `-O0` except `"state"`), and formatted 65-char `.L<symbol>_b<U32.show(n)>` local label strings twice per label only for `w10f_fn_resolve` to discard them (`sym = ""`). |
| `x185_late_stmts` | **13.9%** | Ran all 10 late call expanders + `p128bf_match` (twice!) on **every** `N111Stmt` (including `Set`/`Bin`/`Load`/`Store`/`Return`/`Alloca` and non-expandable `N111Call`s like `p111_rt_sink`/`p111_rt_keep`/`p113d_*`). |
| `x181_frame` + `x186_saves_frame` | **6.4%** | Double-hashed every local name in `x181_frame_home` (`p111v_get` + `p111v_put`) and walked the entire `slots` tree in `x186_saves_tree` even though `"state"` is the only possible register in `-O0`. |

---

## 2. Pure-Bend Optimization Design (W13-C)

1. **Fused Direct-to-`X187Build` Public Segment Emitter (`w13c_pub_emit_fast`):**
   - Wired into all 5 fast public emission entrypoints (`x187_cursor_fast_good`, `w10_module_cursor_fast_good`, `w10_module_cursor_fast_io_good`, `w8_tr_emit_pub`, `ts_emit_pub`).
   - Emits x86-64 machine bytes **directly onto `t_rev`** for `x202k_template`, prologue/epilogue, `N111Set`, `N111Load`, `N111Store`, `N111Bin` (`add`/`sub`/`and`/`or`/`xor`/`shl`/`shr`/`sar`/all 10 comparisons), `N111Offset`, `N111Return`, `P113DIf`/`N111If`, `N111Call` (direct args + `xorl %eax,%eax` + `call`), and 0-arity `p111_rt_ctor` — completely eliminating `X188Seq`/`X187Instruction`/`X187Operand` allocation and `w10f_fn_seq_go` traversal on the hot path.
   - Replaces 65-char `".L" ++ symbol ++ "_b" ++ U32.show(n)` local labels with compact 4-char base-32 tags `".L#<tag>"` (`w13c_lbl`, zero `U32.show`, zero `String.append`).
   - Direct `saved_mask` (`1` if `uses_state` else `0`), skipping `x186_saves_tree` and `agy_mark_bounded_frame`.
2. **Pre-Assembled Constant Byte Templates for `p111_rt_sink` (`150 B`) & `p111_rt_keep` (`152 B`):**
   - `m11` alone emits `3,531` `p111_rt_sink` + `1,638` `p111_rt_keep` (`5,169` calls). Pre-resolving their 5 constant internal branch offsets eliminates `5,169 × 32` `X188Seq` nodes, `20,676` `U32.show` label hashes, and `>100,000` `x187_encode` calls while emitting the exact same `.text` bytes and `.rela.text` relocations (`p111_program+0x3c`, `p111_rt_sink`/`p111_rt_keep`).
3. **Symbol-Dispatched `x185_late_stmts` (shared across `-O0` and `-O2`):**
   - Skips all late expanders for non-`N111Call` statements (`Set`/`Bin`/`Load`/`Store`/`Return`/`Offset`/`Alloca`).
   - Dispatches `N111Call` directly on `symbol` to the single matching expander (`p111_rt_reg_get`/`p111_rt_tag`, `p111_rt_jump`/`p111_rt_return`, `p111_rt_frame`/`p111_rt_stack_pop`/`p111_rt_stack_get`, `p111_rt_ctor`, `p111_rt_take`/`p118_rt_extend`, `p118_rt_borrow_fields` with single `p128bf_match`, `p111_rt_special_*`), and immediately short-circuits all other calls.
4. **Single-Hash `x181_frame_home` (shared across `-O0` and `-O2`):**
   - Computes `index_hash(name, 2166136261)` once and passes it to `w5c3_find` + `p111v_put_h`.

---

## 3. Benchmarks & Bit-for-Bit Verification (CPU `0`)

| Workload | Mode | Baseline `x187_pub` | W13-C `x187_pub` | `x187_pub` Speedup | Total Wall (Base → W13-C) | `.o` Size & SHA-256 |
|---|---|---:|---:|---:|---:|---|
| **`m11.bend`** (`3,549` segs) | `x86-module-fast` | `11,212.0 ms` | **`4,372.0 ms`** | **`2.56×` (`-61.0%`)** | `34.11 s → 30.99 s` (`-3.12 s`) | `6,165,176 B` — **`100%` BIT-IDENTICAL** (`a1bcd3b85096ad50`) |
| **`rung2_frontend.bend`** (`10,373` segs) | `x86-object-fast` | `30,046.0 ms` | **`10,253.0 ms`** | **`2.93×` (`-65.9%`)** | `153.46 s → 128.89 s` (`-24.57 s`) | `25,942,432 B` — **`100%` BIT-IDENTICAL** (`656a394cbbdd1210`) |

**Projected Native `n4_o2` Impact (from W13-A profile):**
- `m11` `x187_pub`: `9,304 ms → ~3,630 ms` (**`-5.67 s`** off `31.94 s` leaf edit!)
- `m05` `x187_pub`: `14,972 ms → ~5,850 ms` (**`-9.12 s`** off `108.70 s` longest pole!)

---

## 4. Mandatory Correctness & Soundness Gates

| Gate | CPU | Result |
|---|---|---|
| `bend --check-only` (`w13c_compiler.bend`) | CPU `0` | **PASS (`0` type errors, `48.5 s`)** |
| `m11` (`6.17 MB`) + `rung2_frontend` (`25.94 MB`) SHA-256 | CPU `0` | **`100%` BIT-FOR-BIT IDENTICAL** |
| **`64/64 native64` (`x86-object-fast`)** | CPU `0` | **`64/64 PASS` (`38.7 s`)** |
| **`64/64 native64` (`x86-object` `-O2`)** | CPU `1` | **`64/64 PASS` (`66.4 s`)** |
| **`15/15` Live-Metadata Observer Gate (`44+2` ABI + `5×3` probes)** | CPU `1` | **`15/15 PASS` (`0` violations)** |
