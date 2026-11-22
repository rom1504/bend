# Wave 2 Track B Report — BST, Map Churn & Tree-Bitonic (`AGY-W2B-1` + `AGY-W2B-2`)

- **Target Bucket**: `2,572 ms` (`23.4%` of the `10,997 ms` Wave 2 fixed-work batch)
  - `coverage-bst-32` (`532 ms`, `2.496× C`), `coverage-bst-64` (`336 ms`, `1.686× C`)
  - `coverage-map-churn-32` (`351 ms`, `2.688× C`), `coverage-map-churn-128` (`336 ms`, `2.670× C`)
  - `variation-tree-bitonic-6-17` (`397 ms`, `1.444× C`), `tree-bitonic` (`327 ms`, `1.206× C`), `variation-tree-bitonic-9-123` (`294 ms`, `1.129× C`)
- **Standalone Patchers** (cleanly composable on top of `selfhost/build/agy/unified/compiler.bend`, runtime `runtime-agy.o` unchanged):
  1. **`AGY-W2B-1`**: `/home/ai/bend2_agy/research/agy/wave2_bst/apply_reuse.py` (`--reuse --take`)
  2. **`AGY-W2B-2`**: `/home/ai/bend2_agy/research/agy/wave2_bst/apply_p114h_mp.py`
- **Verification Harness**: `/home/ai/bend2_agy/research/agy/wave2_bst/verify_all.py` (**26 / 26 PASS**: `7/7` adversarial upstream differential tests + `19/19` `focused19`)
- **Benchmark Harness**: `/home/ai/bend2_agy/research/agy/wave2_bst/bench7.py`

---

## 1. Root-Cause Diagnosis (`SIGPROF` + `objdump -dr`)

1. **`tree-bitonic` family (`1,018 ms` — `65%+` spent in `p111_` continuation trampoline!)**:
   - `warp` was promoted to `p114r_direct.warp` (with `p198w` fast path), **but** `p114h_plan` only ran a single pass and never registered `p114r_` workers into `p124r_view`, and `p114h_finish` refused non-recursive wrappers (`frames == []`).
   - Consequently, `warp_node` (a 5-line non-recursive wrapper calling `warp`), `flow` (calling `warp_node` and recursing), and `bsort` (calling `warp` and `flow`) all remained `p111_` continuation-passing segments.
   - `SIGPROF` on baseline `variation-tree-bitonic-6-17` showed: `p111_p111.k.*` (`21.2%`), `p111_direct.flow` (`10.1%`), `work_loop` (`7.3%`), `p111_direct.bsort` (`6.4%`), `p111_rt_return` (`5.5%`), `p111_direct.warp` adapter (`4.6%`), `p111_direct.warp_node` (`2.8%`), plus out-of-line `p125_rt_ctor2`/`take2` (`13.8%`).
2. **`coverage-bst-32` vs `coverage-bst-64` (`868 ms`)**:
   - `AGY-005b` (absorbing-state early-exit) fired on both `bst.down` variants. `bst-64` (`seed=17`, `x = (35i + 17) % 257`) builds a balanced tree of depth `~8` (saving `~57` steps of `fuel=65`), whereas `bst-32` (`seed=0`, `x = i`) builds a **completely skewed tree of depth 32** (`496` steps down + `496` steps up per repetition, `35,620` reps = `17.7M` iterations each of `bst.down` and `bst.up`).
   - `SIGPROF` on `coverage-bst-32` showed `93.6%` of runtime in `bst.down` (`30.6%`), `bst.up` (`27.1%`), out-of-line `p125_rt_take3` (`25.3%`), and out-of-line `p125_rt_take2` (`10.6%`). Every step freed a class-2 node (`BNode`/`BF`) to the freelist and immediately re-allocated the exact same class-2 slot for `BF`/`BNode`.
3. **`coverage-map-churn-32/128` (`687 ms`)**:
   - Multi-scrutinee `match node kb t:` in `base.bend` (`Map.ins.go`, `Map.seek.go`, `Map.put.go`, `Map.pop.go`) expands into a 36-way cartesian match (`41 KiB` + `20 KiB` + `19 KiB` + `18 KiB` = `98 KiB` of hot `p111_` code). `SIGPROF` showed `p113d_p118borrow.read.Map.bit.go` (`13.5%`), `p113d_p118borrow.read.String.cmp` (`7.3%`), `Map.*.go` + `p111.k.*` (`22.9%`), `p125_rt_ctor/take` (`11.5%`), `p126_rt_nat_divmod` (`4.2%`), `term_drop` (`4.2%`).

---

## 2. Implemented General Optimizations

### `AGY-W2B-1`: Perceus Static In-Place Reuse + Bounded `take{1..4}` Inlining + 0-Arg `ctor` Fold
- **Script**: `/home/ai/bend2_agy/research/agy/wave2_bst/apply_reuse.py` (`--reuse --take`)
- **Mechanism**:
  1. **Perceus Static Reuse** (`agy_reuse_body` on `P113DFunction` after `x185_dead_body`, bounded to `p113d_`/`p114r_` workers `<= 256` stmts):
     - Matches `p125_rt_takeN(state, term, buf)` (with dead return temp `tname`) where **every normal path** (allowing `p111_rt_sink` + `p111_rt_fail` abort paths) reaches a `p125_rt_ctorM(state, N111CtorId{target_ctor}, buf2)` of the **same size class** (`p185cc_class(N) == p185cc_class(M)`) and same `target_ctor`, with no intervening calls or exits.
     - Emits `agy_rt_take_reuseN`: checks live `capabilities & 9 == 9`, live `!cid_hot[target_cid]`, uniquely owned `TAG_CTR` (`(term >> 56) == 2`, `RFC_BIT == 0`), valid `cid_arity == N`, and `loc >= HEAP_OFF`. On fast path, copies `N` words and returns `loc` in `tname` **without touching `ALC_AT`/`ALC_LEN`/`KEEP_WORDS`**. On slow path (RFC-shared, static, `TAG_PAK`, hot, or cap disabled), calls `p125_rt_takeN` and returns `0`.
     - Emits `agy_rt_ctor_reuseM`: if `reuse_loc != 0`, copies `M` words directly into `e.mem[reuse_loc]` and returns `term_ctr(target_cid, reuse_loc)` in 8+2M instructions (zero freelist pop, zero `p111_program` loads); if `0`, falls back to normal inlined `ctorM`.
  2. **Bounded `p125_rt_take{1..4}` Inlining**: Enables `agy_take_inline_enabled()` for bounded `p113d_`/`p114r_` workers (`<= 256` stmts).
  3. **0-Arg `p111_rt_ctor` Constant Folding**: Folds `p111_rt_ctor(state, N111CtorId{ctor}, buf, 0)` (when `p185cc_known(ctor, 0, ids)`) directly into `movabsq $(0x0100000000000000 | (cid << 40)), %rax` (`term_pak(cid, 0)`).

### `AGY-W2B-2`: Multi-Pass Topological `p114r` Direct-Worker Promotion
- **Script**: `/home/ai/bend2_agy/research/agy/wave2_bst/apply_p114h_mp.py`
- **Mechanism**:
  - Runs a bounded topological fixpoint (`agy_p114h_fixpoint`, up to 6 passes) over `P134Public` segments before emission, skipping dead `p111.k.` continuations and verifying `x192h` hygiene before admitting each promoted worker into `hready`.
  - Extends `P124Callables` (`[ready, direct, hready]`) so `p114h_plan` resolves calls to lower-rank `p114r_` workers directly to `p114r_symbol(target)(state, args..., 0, 0, 0)` without `p111_rt_keep`/`p111_rt_jump`/`p111_rt_return`.
  - Extends `p114h_finish` to also admit non-recursive wrappers (`frames == []`) that call at least one `p114r_` worker (e.g., `warp_node`, `bench`, `Map.to_list`), enabling multi-level recursive DAGs (`warp` → `warp_node` → `flow` → `bsort` → `bench` → `p93.loop`) to compile to 100% direct x86 calls.
  - Strictly acyclic by topological rank (`owner != target` + pass-ordered discovery).

---

## 3. Benchmark Results (CPU 2, 3 Alternating Rounds vs Unified Baseline)

| Case | Baseline (ms) | Cand (`W2B-1 + W2B-2`, ms) | Delta | Ratio | Notes |
|---|---:|---:|---:|---:|---|
| `coverage-bst-32` | `553.0` | **`505.0`** | **−48.0** | **`0.9132×`** | `0.9162×` in quiet run (`537 → 492 ms`) |
| `coverage-bst-64` | `350.0` | **`319.0`** | **−31.0** | **`0.9114×`** | `0.9226×` in quiet run (`336 → 310 ms`) |
| `coverage-map-churn-32` | `350.0` | `396.0` | +46.0* | `1.1314×`* | `1.0086×` (`350 → 353 ms`) in quiet run (`task-121`) |
| `coverage-map-churn-128` | `442.0`* | `340.0` | −102.0* | `0.7692×`* | `1.0030×` (`338 → 339 ms`) in quiet run (`task-121`) |
| `variation-tree-bitonic-6-17` | `429.0` | **`279.0`** | **−150.0** | **`0.6503×`** | `0.6460×` (`387 → 250 ms`, **~0.93× C**) |
| `tree-bitonic` | `335.0` | **`223.0`** | **−112.0** | **`0.6657×`** | `0.6677×` (`322 → 215 ms`, **~0.80× C**) |
| `variation-tree-bitonic-9-123` | `312.0` | **`210.0`** | **−102.0** | **`0.6731×`** | `0.6759×` (`290 → 196 ms`, **~0.76× C**) |
| **7-Case Total** | `2,771.0` | **`2,272.0`** | **−499.0** | **`0.8199×`** | Quiet-baseline normalized: **−415 ms (`~0.838×`)** |

*(`*` Note: Parallel Wave 2 worker tracks on sibling cores introduced transient L3/boost variance on `map-churn` in `task-186`; on the quieter `task-121` run `map-churn-32/128` were neutral at `1.0086×`/`1.0030×` while `bst` and `tree-bitonic` ratios were identical across both runs.)*

---

## 4. Falsified / Rejected Experiments (Preserved)

1. **Lifting `agy_mark_bounded_frame` cap from `256` → `512` stmts**:
   - Improved `coverage-bst-64` (`0.8848×`) and `tree-bitonic-6-17` (`0.6364×`), **but regressed `coverage-bst-32` (`0.916× → 0.982×`) and `coverage-map-churn-128` (`1.003× → 1.080×`)** due to L1i code bloat. Rejected; cap kept at `256`.
2. **Omitting `P113DIf{p114h_mode, x192h_unwind(...)}` when `cases == Nil{}`**:
   - **Falsified (infinite loop on `coverage-bst-32`)**: Tail-recursive `p114h` workers (like `p93.loop`) have `cases == Nil{}` but still exit via `P114RResult → P113DAgain(..., mode=1)` into `x192h_unwind`! Immediately reverted.
3. **Ablating `--reuse` without `--take`**:
   - `--reuse` alone gave `0.9199×` on `bst-32` and `0.9565×` on `bst-64` (`0.8613×` total) vs `--reuse --take` giving `0.9132×`/`0.9114×` (`0.844×` total). Keeping `--reuse --take` at cap `256` wins on both `bst-32` and `bst-64` without hurting `map-churn`.

---

## 5. Verification Summary (`verify_all.py`)

- **Adversarial Upstream Differential Tests (`bun bend2/main.ts` vs compiled x86 binary)**: **7 / 7 PASS**
  - `reuse_rfc_shared` (`13320123`): verifies RFC-shared `+shared` tree is NOT mutated in-place
  - `reuse_static_term` (`9120`): verifies top-level static constructor (`loc < HEAP_OFF`) is NOT mutated in-place
  - `reuse_cross_arity` (`31829065`): verifies `take4 → ctor3` and `take3 → ctor4` same-class reuse
  - `p114h_deep_dag` (`13680`): verifies 5-level multi-pass topological `p114r` DAG with binary recursion + wrappers
  - `p114h_many_args` (`394`): verifies 6 user args (`state + 6 + 3 = 10` machine args, crossing into stack args)
  - `zero_arg_ctor_variants` (`3754511808`): verifies 5-variant 0-arg `p111_rt_ctor` constant folding
  - `reuse_with_drop_and_0arg` (`198`): verifies mixed recursive reuse + 0-arg ctors
- **`focused19` (`selfhost/tests/phase182/qualification-catalog.json`)**: **19 / 19 PASS** (including all 3 negative refusal controls).
- **Runtime ABI**: `runtime-agy.o` untouched (`44/44 abi-contract.c` + `2/2 observer.c` preserved).
- **Disk Hygiene**: `selfhost/build/agy/wave2_bst` = `7.2 MiB` (temp binaries removed), `research/agy/wave2_bst` = `60 KiB`.
