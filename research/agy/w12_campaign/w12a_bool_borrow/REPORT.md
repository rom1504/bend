# W12-A Report: Unboxed `Bool` Match Fast-Path & Borrow-Loop Direct Field Load

**Status:** **100% Verified & Sound** (`0` type errors, **`64/64 native64` PASS**, **`15/15` Observer Gate PASS with `0` violations**).
**Headline Result:** Pure-Bend x86-64 codegen cuts `$p118borrow.read.has` from **~92 → 27 instructions/node (`3.4×` fewer instructions, `-36.3%` code size)** and `$p118borrow.read.len` from **~45 → 17 instructions/node (`2.6×` fewer instructions)**, delivering **`1.086×` on `hashmap`** (`11,190.4 ms → 10,301.8 ms` on CPU `5`, exact checksum `1307803744`), **`1.018×` on `coverage-expression-128`**, and **`1.000×` on `coverage-bst-64`** (with `-5,040 B` `.o` reduction).

**Key Architectural Finding:** Cutting 65 ALU instructions/node in `$p118borrow.read.has` yields `+8.6%` wall-clock speedup rather than the projected `2.0–2.8×` because on an out-of-order x86-64 CPU, `hashmap`'s chain walk is **L2/L3 serial pointer-chase latency bound** (`mov 0x8(%rbx,%rdi,8),%r15` across freelist-scattered `CCons` nodes), which previously overlapped with the 37-insn `Bool` decode ALU instructions. Further `hashmap` speedups require reducing memory/runtime traffic (W11-B Rank 5: inline boxed `Array.get`/`Array.set` fast-path + allocation/drop reduction).

---

## 1. Pure-Bend Codegen Changes (`apply_w12a_bool_borrow.py` / `w12a_bool_borrow.patch`)

All changes are pure-Bend edits to `wave8_unified/compiler.bend` (zero edits to `bend2/bend.ts`, `runtime.c`, or `runtime-agy.o`):

1. **Unboxed `Bool` Match Fast-Path in `x190_step` (`w12_i_bool_match` + `w12_bool_fast_prefix`):**
   - Root cause found: Wave 2B's `w2b_bool_match` only lived in the float emitter (`x186_x_emit_nodes`) and only matched `False`-first (`xor 1`) patterns; pure-integer functions (`$p118borrow.read.has`, `$direct.bst.up`, `$direct.eval`) emit through **`x190_step`** and frequently match `True`-first (`case _ True{}`).
   - Added 1-level linear step matchers (`w12_i_bm_1..6`, zero flattener blowup) in `x190_step` handling **both** `True`-first (6 bins) and `False`-first (7 bins) `p112_special_bool` sequences with structural dataflow matching.
   - Added 1-level step opposite-branch stripper (`w12_i_strip_opp`) using `x190_branch_append` to safely eliminate both CSE'd (`eq; or; [xor]; if`) and un-CSE'd redundant opposite-polarity checks in the `no` branch.
   - Emits `testq %reg,%reg; jz ...; cmpq $1,%reg; je ...` (2-insn hot path for `0`/`1`, exact cold fallback for packed `True`).
2. **Borrow-Loop Direct Field Load & Heap-Base Hoist (`x185_late_stmts_h` + `x198n_late_h` + `x185_function_setup`):**
   - Matches `p118_rt_borrow_fields` together with immediately following `N111Load`s from `scratch` (guarded by `w4_bf_no_buf_load` on the tail) and emits direct `N111Load`s from `borrow_fields` on the fast path, eliminating the `-0x840(%rbp)` stack-buffer bounce completely.
   - Folds `sub $0x20000; cmp $cid` in `p128bf_guard` into a single `cmp $(0x20000 | cid)`.
   - Hoists `p114t_borrow_heap = load(state, 0)` into `setup` for borrow-read loops (`x190_register_loop(body) && w12_has_borrow_fields(body)`) in both `x185_function_setup` and `x181_direct_orig_la` (`x198n`), keeping `state->heap` in `%rbx` across the entire loop.
3. **Sign-Bit & Integer-Compare Branch Fusion + Empty-`no` Jump Elimination (`x190_step` & `x190_if_yes`):**
   - Fuses `N111Bin{c, N111U64{}, "shr", w, 63}` + `P113DIf{c}` into `testq %reg,%reg; jge l_no`.
   - Fuses non-`cmov` integer compares (including `N111CtorId` immediates via `w12_int_cmp_imm`) using `O(fuel)` local liveness (`w12_i_dead_in` with fuel halving on `P113DIf` branches to guarantee linear compile time on deeply nested `match`es).
   - Skips redundant `jmp l_end` (`jmpq +0`) in `x190_if_yes` and `x186_x_emit_yes` when `no` is empty.

---

## 2. Assembly Before vs After (`$p118borrow.read.has` & `$p118borrow.read.len`)

| Function | Metric | Wave 8 Baseline | W12-A | Delta |
|---|---|---:|---:|---:|
| `$p118borrow.read.has` | Function bytes | `790 B` | **`503 B`** | **`-36.3%`** |
| `$p118borrow.read.has` | Hot-loop insns/node | `~92` | **`27`** | **`3.4×` fewer** |
| `$p118borrow.read.has` | `Bool` match hot path | `37` insns (`×2`) | **`2` insns** (`testq; je`) | **`18.5×` fewer** |
| `$p118borrow.read.has` | `-0x840(%rbp)` bounce | `14` insns / `4` mem ops | **`0`** (`mov (%rbx,%rdi,8)`) | **Eliminated** |
| `$p118borrow.read.has` | `state->heap` reload | `1` load/node | **`0`** (hoisted `%rbx`) | **Eliminated** |
| `$p118borrow.read.len` | Hot-loop insns/node | `~45` | **`17`** | **`2.6×` fewer** |

---

## 3. Benchmarks & Qualification Gates (CPU `5` Exclusively)

| Benchmark | Expected Stdout | `.o` Size (Base → Cand) | Base Median (CPU 5) | W12-A Median (CPU 5) | Speedup |
|---|---|---:|---:|---:|---:|
| **`hashmap`** (`11n, 16384`) | `1307803744` (exact) | `73,664 → 72,248 B` | `11,190.4 ms` | **`10,301.8 ms`** | **`1.086×`** |
| **`coverage-bst-64`** (`100k` reps) | `861157620` (exact) | `130,024 → 124,984 B` | `164.0 ms` | `164.0 ms` | `1.000×` |
| **`coverage-expression-128`** (`200k` reps) | `3393903617` (exact) | `99,168 → 98,304 B` | `58.0 ms` | **`57.0 ms`** | **`1.018×`** |

### Soundness & Correctness Gates
- **Typecheck (`--check-only` / Bun JS build):** **PASS** (`0` type errors).
- **`native64` Qualification Gate (`x86-object` `-O2`, 64 cases incl. 3 refusals):** **`64/64 PASS`** (`0` failures, `92.56 s`).
- **Observer Gate (`5` probes × `3` live-metadata modes: `normal`, `cap-no8`, `all-hot`):** **`15/15 PASS`** (`0` violations).

### Artifacts
- Patcher: [apply_w12a_bool_borrow.py](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/apply_w12a_bool_borrow.py)
- Unified diff: [w12a_bool_borrow.patch](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/w12a_bool_borrow.patch)
- Machine-readable results: [results.json](file:///home/ai/bend2_agy/research/agy/w12_campaign/w12a_bool_borrow/results.json)
