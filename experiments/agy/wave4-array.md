# Wave 4 Phase 1 Track W4-2: Runtime-Guarded `p113a` Array Fast-Path + `p117v` Array LICM + Cold Scratch-Store Sinking

**Date:** 2026-11-22  
**Patcher:** [`research/agy/wave4_array/apply_array_fast.py`](file:///home/ai/bend2_agy/research/agy/wave4_array/apply_array_fast.py) (`--src selfhost/build/agy/wave3b_unified/compiler.bend` → `--dst selfhost/build/agy/wave4_array/compiler.bend`)  
**Built API:** [`selfhost/build/agy/wave4_array/api.mjs`](file:///home/ai/bend2_agy/selfhost/build/agy/wave4_array/api.mjs)  
**Runtime:** `selfhost/build/agy/unified/runtime-agy.o` (unmodified)  
**Scratch / Build Footprint:** `9.1 MiB` (`selfhost/build/agy/wave4_array`) + `40 KiB` (`research/agy/wave4_array`)

---

## 1. Root Cause & General Compiler Changes

All changes are **100% general** (zero benchmark-specific matchers or AST templates) and purely in `compiler.bend`:

1. **Lift `p113a_enabled` from whole-program `scalar && unshared` to `scalar`**:
   - In `wave3b_unified/compiler.bend:29291`, `p113a_enabled` required both `scalar = ns_definitions(book, names)` AND `unshared = nr_unshared(book, names)`. Whenever `Array.fork`/`Array.join` (`histogram`) or a parallel fork (`editdist`) appeared anywhere in the program, `unshared` failed globally — disabling `mode = 2`, `NATIVE_SCALAR_ARRAYS` (`capabilities & 2`), `p113a` inline array ops, `p117h`/`p117v` array-header LICM, and `p169o_certified` mode-2 inlining across the entire program.
   - As verified in `selfhost/src/runtime/qbe/runtime.c:1292`, `NATIVE_SCALAR_ARRAYS` (`TAG_BUF`, 4-byte packed `u32` elements) depends **only** on `scalar` (`ns_definitions`), independent of handle sharing (`term_rfc(a)` / `term_peek(e, a)`).
2. **Runtime-guarded RFC-wrapped `TAG_BUF` support in `p113a_template` and `p117h_metadata` (zero hot-path overhead on unshared arrays)**:
   - In `Term` encoding (`runtime.c:215, 221, 827-862`), `tag = array >> 56` encodes `(term_rfc << 7) | term_tag`:
     - `tag == 4`: unshared raw `TAG_BUF` (`loc = array & 0xffffffffff`).
     - `tag == 132` (`0x84`): RFC-wrapped `TAG_BUF` (e.g., from `Array.fork`), whose backing heap location is `*(uint64_t *)(heap_base + (r << 3)) >> 24` (immutable for the lifetime of the RFC cell; ordinary loads on x86-64 already provide acquire semantics).
     - Any other tag (`TAG_ARR == 6`, static `loc < heap_min`, invalid handles) transparently falls back to `p113_rt_array_pair` / `p111_rt_op`.
   - In **`p113a_template_core`**, the fast path tests `tag == 4 && loc >= heap_min` (**0 extra instructions** on unshared arrays like `bst` and `editdist`), and checks `tag == 132` (`p113a_rfc_fallback`) only in the `else` branch — keeping unshared array ops identical in length while still eliminating 100% of C runtime calls on forked arrays (`histogram`'s `bump` / `bump.at`).
   - In **`p117h_metadata`** (executed once at function entry outside `p117h`/`p117v` loops), both `tag == 4` and `tag == 132` are resolved once into loop-invariant `base` and `mask` — hoisting RFC indirection completely out of inner loops (`fill.go`, `zero.go`, `count.go` in `histogram`).
3. **Sink cold `scratch` argument stores into the slow fallback branch**:
   - In `p113a_scan`, `p117h_rewrite`, and `p117v_rewrite`, `p113a_match_sunk` detects the compiler-emitted `Store(U64, scratch, 0/8/16, v*)` + `[Alloca(out, 16, 8)]` + `p111_rt_op(73)` / `p113_rt_array_pair(72|74|75)` sequence.
   - On the hot path, `p113a_sunk_sets` binds `p113a_N_{array,index,new}` directly to `v0, v1, v2` (eliminating 2–3 dead stack stores + 2–3 stack loads per array op).
   - In `p113a`/`p117h`, `p113a_sunk_stores` emits the `scratch` stores **only** inside the cold runtime fallback branch; in `p117v` (no fallback branch), the `scratch` stores are eliminated completely.

---

## 2. Benchmark Results (CPU 2, `runs=3`, back-to-back A/B)

Command:
```bash
python3 -B research/agy/wave4_bench/run_proxy.py --api <api.mjs> --only histogram,editdist,bst --runs 3
```

| Benchmark | Group | `C_ms` (GCC-10 `-O3`) | Baseline `wave3b_unified` | Candidate `wave4_array` | Speedup | `Bend/C` (Before → After) | `Bend/C16` (Before → After) | Checksum |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **`histogram`** | upstream-medium | `22.414` | `445.243 ms` | **`191.313 ms`** | **`2.33×`** (`2.00×` vs Phase 0 `383.2 ms`) | `19.86× → 8.54×` | `18.55× → 7.97×` | PASS (`3307081914`) |
| **`editdist`** | tuned | `9.688` | `131.250 ms` | **`103.125 ms`** | **`1.27×`** | `13.55× → 10.65×` | `14.24× → 11.19×` | PASS (`2065873279`) |
| **`bst`** | tuned | `13.082` | `66.261 ms` | **`65.412 ms`** | **`1.013×`** | `5.06× → 5.00×` | `6.12× → 6.04×` | PASS (`861157620`) |
| **3-bench geomean** | — | — | — | — | **`1.44×`** | **`11.088× → 7.687×`** | **`11.733× → 8.135×`** | **3/3 PASS** |

Full 7-family Wave 4 proxy (`--runs 3`) also passed **7/7** exact checksums (`histogram`, `gameoflife`, `nbody`, `list`, `expression`, `bst`, `editdist`).

---

## 3. `SIGPROF` Runtime Drain Verification

| Benchmark | Before (`wave3b_unified`, Phase 0) | After (`wave4_array`, W4-2) | Delta |
|---|---|---|---|
| **`histogram`** | `runtime-agy.o` = **`34.04%`** (`p111_rt_op` `18.09%`, `p113_rt_array_pair` `14.89%`) | `runtime-agy.o` = **`0.00%`** (`100.00%` in `p113d_direct`) | **-34.04 pp (100% drained!)** |
| **`editdist`** | `runtime-agy.o` = **`16.92%`** (`p113_rt_array_pair` `8.96%`, `p111_rt_op` `6.22%`) | `runtime-agy.o` = **`2.03%`** (`p113_rt_array_pair` `0.00%`, `p111_rt_op` `0.00%`; only `p125_rt_ctor4` `1.35%` + `p111_rt_sink` `0.68%`) | **-14.89 pp (100% array ops drained!)** |
| **`bst`** | `bump` `13.04%`, `blk_new` `13.59%` | `bump` `10.48%`, `blk_new` `12.90%` (0 dead `scratch` stores on hot path in `collect` & `bump`) | `-2.56 pp` in `bump` |

---

## 4. Safety & Conformance Gates

| Gate | Command / Script | Result |
|---|---|---|
| **`focused19`** | `python3 -B research/agy/wave2_lexrec/run_focused19.py selfhost/build/agy/wave4_array/api.mjs selfhost/build/agy/unified/runtime-agy.o` | **19/19 PASS** |
| **`observer_wave2_gate`** | `research/agy/wave3_fuzz/observer_wave2_gate.py` (`W2_API = wave4_array/api.mjs`) | **15/15 PASS (`0 violations`)** + 44+2 ABI/live-metadata probes PASS |
| **Array Adversarial + Observer Gate** | [`research/agy/wave4_array/test_array_adversarial.py`](file:///home/ai/bend2_agy/research/agy/wave4_array/test_array_adversarial.py) (`shared_fork_loop`, `nested_fork_oob`, `clone_isolation`, `nonscalar_array`, `mixed_ctor_array` × `normal`/`cap-no8`/`all-hot`, diffed against upstream `bun bend2/main.ts`) | **15/15 PASS (`0 violations`)** |
| **Full 7-family Wave 4 proxy** | `python3 -B research/agy/wave4_bench/run_proxy.py --api selfhost/build/agy/wave4_array/api.mjs --runs 3` | **7/7 PASS** |
