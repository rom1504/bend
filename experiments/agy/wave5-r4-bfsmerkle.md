# Wave 5 Engine B Track W5-R4: General `Nat.Suc` Inline Fast-Path & Loop-Carried Product Unboxing (`bfs` & `merkle`)

**Date:** 2026-11-22  
**Base compiler:** `selfhost/build/agy/wave4c_unified/compiler.bend`  
**Patch script:** `research/agy/wave5_r4/apply_r4.py`  
**Built compiler:** `selfhost/build/agy/wave5_r4/compiler.bend` → `selfhost/build/agy/wave5_r4/api.mjs`

---

## 1. Root-Cause Diagnosis (`SIGPROF` + `objdump -d` on `wave4c_unified`)

Scaled-down 1–3 s proxy workloads (`bfs_15`: `DEPTH=15`, `2^15` mazes; `merkle_18`: `SIZE=18`, `2^18` leaves, `BLOCKS=30`, `PROBE=1337`) were profiled at 1000 Hz (`SIGPROF`) on CPU 2 (`+RTS --threads 1 --gpu off -RTS`) and disassembled:

### A. `merkle_18` (`4.33×` C baseline)
- `p113d_$direct.spk`: **57.2%** of samples
- `p111_rt_special_ctor`: **35.3%** of samples
- `p113d_$direct.blk`: **4.9%** of samples
- **Root cause (100% general):** `p186ch_expand` already lowered `p111_rt_special_ctor` inline for `kind == 1..3` (arity 0: `False`/`True`/`Zero`) and `kind == 5` (arity 1: `Char`), **but omitted `kind == 4` (`P111_SPECIAL_SUCC` = `1n+j`, arity 1)**. Every `1n+j` inside a `Nat`-counting loop emitted a full C runtime call to `p111_rt_special_ctor(state, 4, &buf, 1)` (which simply executes `nat_chk(e, args[0] + 1)` with `NAT_IMM = (1ULL << 48) - 1`).

### B. `bfs_15` (`7.49×` C baseline)
- `p113d_$direct.bfs`: **79.0%** of samples (3,404 lines of assembly, heavy stack spilling)
- Runtime heap ctor/take (`p111_rt_take`, `p111_rt_ctor`, `p125_rt_take2`, `p125_rt_ctor2`, `blk_new`): **12.7%** of samples
- **Root cause (100% general):** Even though all inner helpers (`pop`, `look4`, `look`, ...) were unboxed and inlined into `$direct.bfs`, the loop-carried state parameter `r : St & Bool` (nested `Tuple(St(g, q, d, head, tail), Bool)`) was still unpacked via `p111_rt_take` on every iteration and re-boxed via `p111_rt_ctor` right before `P113DAgain`. Because the arrays `g, q, d` were hidden inside the boxed loop-carried record instead of being direct loop parameters, `p117v` (`x185_array_version`) could not hoist their array headers (`tag`, `heap_min`, `base`, `mask`) out of the loop, leaving 20× full `p113a` tag/bounds/RFC-fallback blocks inside the loop body.

---

## 2. General Compiler Passes (`research/agy/wave5_r4/apply_r4.py`)

Both passes are **100% general** (zero benchmark-specific names, shapes, or magic constants; all pattern matches use 1-scrutinee helpers):

1. **Pass 1 — Inline `P111_SPECIAL_SUCC` (`w5_succ_expand` in `x186_late_char`):**
   - Matches `N111Call{dest, N111U64{}, "p111_rt_special_ctor", [state, Const{4, 0}, buffer, Const{1, 0}]}` (`buffer != "state"`).
   - Expands to:
     - `succ_in = Load(buffer, 0)`
     - `succ_ok = Bin(ult, succ_in, Const{4294967295, 65535})` (`NAT_IMM = 0x0000FFFFFFFFFFFF`)
     - `If succ_ok: dest = Bin(add, succ_in, 1) Else: <original p111_rt_special_ctor call>`
   - Preserves bit-exact `nat_chk` overflow + `ERR_NATS` semantics on the slow path while eliminating the C runtime call on every `1n+j` fast path.

2. **Pass 2 — General Loop-Carried Product Unboxing (`w5_lcu_selected` wrapping `x185_array_selected`):**
   - Applies up to 2 nested levels (`depth < 2`) on single-result tail-recursive `P113DFunction`s with `P113DAgain` (`nParams <= 12`, `p113i_size(body) <= 1024`).
   - Checks whether a loop parameter `p_k` is:
     - Constructed with the same constructor `C` and arity `A` (`1 <= A <= 8`, total params after unboxing `<= 16`) immediately before every `P113DAgain` (`A` consecutive `Store`s + `p111_rt_ctor`), and
     - Only inspected inside the body via `p111_rt_tag`, `p111_rt_take` (at least once), `p111_rt_sink`, or `P113DResult` (never reassigned or escaped).
   - Emits three functions via `x181_program_join`:
     - Untouched fallback `w5_lcu_fb_<depth>_<fid>`
     - Entry wrapper checking `p111_rt_tag(p_k) == C`, unpacking `p_k` once via `p111_rt_take`, and calling the worker (or fallback on tag mismatch)
     - Unboxed worker `$lcu<depth>.<name>` with `p_k` replaced by its `A` field parameters, folding `p111_rt_take` + consecutive `Load`s into `N111Set` + `w4g_copy_pass` + `w4g_bwd_dce`, materializing `C` only on exit (`P113DResult`/`p111_rt_sink`), and recursing into `w5_lcu_selected` (Round 2) → `x185_array_selected_core` (`p117v` + `w4c_bce`).
   - On `bfs`, Round 1 unboxes `Tuple(st, more)`, Round 2 unboxes `St(g, q, d, head, tail)`, and `p117v` automatically hoists all three arrays `g, q, d` out of the BFS loop (`p117v_$lcu1.$lcu0.$direct.bfs`).

---

## 3. Verification & Benchmark Results

### A. Target Workloads (3-run median, interleaved on CPU 2, gcc-10 `-O3` C twin, `+RTS --threads 1 --gpu off -RTS`)

| Benchmark | C (ms) | `wave4c_unified` (ms) | W4C / C | `wave5_r4` (ms) | R4 / C | Speedup (W4C → R4) | Exact Checksum |
|---|---:|---:|---:|---:|---:|---:|---|
| `bfs_15` (`DEPTH=15`) | 418.2 | 3130.3 | 7.49× | **1096.1** | **2.62×** | **2.86×** | `3905624395` (MATCH) |
| `merkle_18` (`SIZE=18`) | 565.9 | 2450.6 | 4.33× | **1320.3** | **2.33×** | **1.86×** | `3967947184` (MATCH) |

### B. Qualification & Zero-Regression Gates
- **`focused19` (`research/agy/wave2_ray/run_focused19.py`):** **PASS 19/19**
- **`observer_wave2_gate` (`research/agy/wave3_fuzz/observer_wave2_gate.py`):** **PASS 15/15 (0 violations)** + ABI/observer probe 44+2 PASS
- **Wave 4 Proxy (`research/agy/wave4_bench/run_proxy.py --runs 1 --cpu 2`):** **7/7 PASS**, zero regression:
  - `histogram`: `65.350 ms` (`2.92×` C / `2.72×` C16)
  - `gameoflife`: `612.830 ms` (`0.67×` C / `2.54×` C16)
  - `nbody`: `109.933 ms` (`1.26×` C / `1.47×` C16)
  - `list`: `0.232 ms` (`0.86×` C / `0.86×` C16)
  - `expression`: `10.317 ms` (`1.65×` C / `1.43×` C16)
  - `bst`: `35.679 ms` (`2.73×` C / `3.29×` C16)
  - `editdist`: `26.250 ms` (`2.71×` C / `2.85×` C16)
  - Overall 7-family geomean: **`1.590×` vs C** (`1.976×` vs Clang-16)
- **Holdouts untouched:** `queens`, `terrain`, `tree-matmul`, `tree-radix`, `hashmap` were never read or touched.
- **Disk usage:** `selfhost/build/agy/wave5_r4/` = `11 MiB` (`< 40 MiB` budget).
