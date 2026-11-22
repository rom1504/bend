# Wave 2B Track B Report — Certified In-Place BST Zipper (`AGY-W2B-3`) & Native Bitonic `flow` (`AGY-W2B-4`)

- **Base**: Composed cleanly on top of Tier-2-cleared Wave 2 Track B (`AGY-W2B-1` + `AGY-W2B-2`); runtime `runtime-agy.o` unchanged (`44/44 abi-contract.c` + `2/2 observer.c` preserved).
- **Standalone Composable Patchers** (zero merge conflict with Track C's `apply_rorec.py` — both hook after `x198pw_annotate` at the single caller site, and `AGY-W2B-4` chains into the `else` arm of `x198pw_worker`):
  1. **`AGY-W2B-3`**: `/home/ai/bend2_agy/research/agy/wave2_bst_b/apply_bst_zipper.py`
  2. **`AGY-W2B-4`**: `/home/ai/bend2_agy/research/agy/wave2_bst_b/apply_flow_native.py`
- **Verification Harness**: `/home/ai/bend2_agy/research/agy/wave2_bst_b/verify_w2b.py` (**25 / 25 PASS**: `6/6` adversarial upstream differential tests + `19/19` `focused19`)

---

## 1. Design & Soundness Proofs

### `AGY-W2B-3`: Certified In-Place Binary-Tree Zipper-Insert Fast Path
- **Problem**: Even with `AGY-005b` (absorbing-state early-exit) and `AGY-W2B-1` (Perceus reuse), `coverage-bst-32` (`486 ms`) and `coverage-bst-64` (`306 ms`) still allocated and tore down a `List<BFrame>` zipper on every insert (`17.7M` steps each of `bst.down` and `bst.up` for skewed depth-32 `bst-32`).
- **General Name-Independent KTerm Certification** (`agy_zip_owners` → `agy_zip_checked_plan`):
  - Matches any `Def` `f(fuel: Nat, x: U32, t: T) -> T` over a 0-param, non-indexed, non-erased 2-ctor ADT `T = { Leaf{}, Node{l: T, v: U32, r: T} }` whose body is `fin(x, down(fuel, x, (t, Nil{})))`, where:
    - `fin` inserts `Node{Leaf{}, x, Leaf{}}` at `Leaf{}` and rebuilds unchanged at `Node{l, v, r}` via `up`;
    - `up` pops `List<Frame>` and rebuilds the exact same `Node` path;
    - `down` is a fueled `Nat` loop descending `Node` via `U32.is_lt(x, v)` (`u32_is_lt` intrinsic) pushing frames onto `List<Frame>`, absorbing at `Leaf{}` (matches both `Let`-bound `+v = {v0 : U32}` and direct `v` forms);
    - `pick` branches on `True{}`/`False{}` to descend left/right and push the matching `Frame`.
- **Guarded Leaf x86 Fast Path** (`agy_zip_machine` wrapping `p113d_<f>`, fallback `agy_zip_slow_<sym>`):
  - Checks live `capabilities & 9 == 9` and live `!cid_hot[node_cid]` before saving `%rbx` (`HEAP_OFF`).
  - Walks down the tree in a 15-instruction register loop (0 allocations, 0 stack frame, 0 calls):
    - Checks `Leaf{}` first (`fuel == 0` at `Leaf{}` still inserts!).
    - If `rem_fuel == 0` at `Node`, returns original `tree` unchanged.
    - Checks `(cur >> 40) == (0x20000 | node_cid)` (simultaneously verifying `TAG_CTR == 2`, `RFC_BIT == 0`, and `cid == node_cid`) and `loc >= HEAP_OFF`. Any failure jumps to `agy_zip_slow_<sym>` with **zero heap mutations**!
    - At `Leaf{}`, allocates **1** `Node` from class-2 freelist (bailing cleanly with zero mutations if empty), writes `Node{Leaf{}, x, Leaf{}}`, patches `*slot_ptr` (or returns new root if root was `Leaf{}`), and returns.

### `AGY-W2B-4`: Certified Native In-Place Bitonic `flow` Merger Fast Path
- **Problem**: After `AGY-W2B-2` promoted `warp_node`, `flow`, and `bsort` to `p114r_`, `SIGPROF` showed `p114r_direct.flow` (`29.7%`, using `p111_rt_frame` + `sub $0x2bd0, %rsp` + out-of-line `take2`/`ctor2`) and `p114r_direct.warp_node` (`17.2%`) still dominated `tree-bitonic` (`674 ms`).
- **General Name-Independent KTerm Certification** (`agy_fl_owners` → `agy_fl_checked_plan`):
  - Matches any `Def` `flow(d: Nat, s: Bool, w: T) -> T` over a 0-param 2-ctor ADT `T = { Leaf{v: U32}, Node{l: T, r: T} }` where `d == 0n` is identity on `Leaf`/`Node`, `d == 1n+p` is identity on `Leaf` and recursively computes `fa fb = flow(p, s, wn(wa, s)) flow(p, s, wn(wb, s)); Node{fa, fb}`, where `wn` dispatches `Leaf -> Leaf` and `Node{a, b} -> warp(a, b, s)`, and `warp` passes `x198pw_checked_plan` with identical `Leaf`/`Node` constructor identities.
- **Depth-Bounded Native-Stack x86 Fast Path** (`agy_fl_machine` wrapping `p114r_<flow>`, fallback `agy_flow_slow_<sym>`):
  - Entry guards: `mode == 0`, `depth == 0`, `val == 0`, `d <= 64`, live `capabilities & 9 == 9`, live `!cid_hot[node_cid]`.
  - Native recursive `.Lrec` (24 bytes/level on x86 stack, max `1.5 KiB` for `d <= 64`):
    - Returns `w` immediately on `d == 0` or `Leaf`.
    - For uniquely-owned heap `Node` (`loc >= HEAP_OFF`), inlines `wn` (unpacking child `Node`, freeing its class-1 slot, calling `p114r_<warp>` directly), recurses on both halves, and **reuses `w`'s `Node` slot in-place** (`mem[loc+0] = fa; mem[loc+1] = fb; return w`).
    - For any RFC-shared, static, or freelist-full node, cleanly delegates to `agy_flow_slow_<sym>` / `p114r_<wn>` without any partial mutation.

---

## 2. Benchmark Results (CPU 2, 3 Alternating Rounds vs Unified Baseline)

| Case | Unified Fixed-Work (ms) | Isolated Wave 2B Ratio (`task-258`/`269`) | Full 7-Case Run (`task-275`, noisy sibling load) | Projected Fixed-Work (ms) | Total Track B Delta vs Unified | Projected vs C |
|---|---:|---:|---:|---:|---:|---:|
| `coverage-bst-32` | `532` | **`0.1378×`** (`624 → 86 ms`) | **`0.1178×`** (`866 → 102 ms`) | **`~68 ms`** | **−464 ms** | **`~0.32× C`** |
| `coverage-bst-64` | `336` | **`0.1601×`** (`381 → 61 ms`) | **`0.2119×`** (`703 → 149 ms`) | **`~58 ms`** | **−278 ms** | **`~0.29× C`** |
| `variation-tree-bitonic-6-17` | `397` | **`0.3410×`** (`566 → 193 ms`) | **`0.4395×`** (`603 → 265 ms`) | **`~145 ms`** | **−252 ms** | **`~0.53× C`** |
| `tree-bitonic` | `327` | **`0.2982×`** (`493 → 147 ms`) | **`0.3829×`** (`457 → 175 ms`) | **`~105 ms`** | **−222 ms** | **`~0.39× C`** |
| `variation-tree-bitonic-9-123` | `294` | **`0.3110×`** (`492 → 153 ms`) | **`0.4895×`** (`478 → 234 ms`) | **`~102 ms`** | **−192 ms** | **`~0.39× C`** |
| `coverage-map-churn-32` | `351` | — | `1.0575×` (neutral) | `~351 ms` | `0 ms` | `2.69× C` |
| `coverage-map-churn-128` | `336` | — | `1.0260×` (neutral) | `~336 ms` | `0 ms` | `2.67× C` |
| **Track B Bucket Total** | **`2,572`** | — | **`0.5055×`** (`4309 → 2178 ms`) | **`~1,165 ms`** | **~−1,408 ms (−54.7%)** | — |

*(Additional savings of Wave 2B on top of Wave 2 Track B's −420 ms: **~−988 ms**!)*

---

## 3. Verification (`verify_w2b.py` — 25 / 25 PASS)

- **Adversarial Upstream Differential Tests (`bun bend2/main.ts` vs x86 binary)**: **6 / 6 PASS**
  - `bst_zipper_rfc_shared` (`15048202`): RFC-shared `+base` BST bails cleanly with zero mutation
  - `bst_zipper_static_root` (`639981283`): top-level static BST (`loc < HEAP_OFF`) bails cleanly across 10 calls
  - `bst_zipper_fuel_boundary` (`1922515649`): `fuel=0` on `Empty` (inserts), `fuel=0` on `Branch` (unchanged), `fuel=1` on depth-2 (unchanged), `fuel=2` (inserts), duplicate key `x == v` (goes right), `0` and `4294967295` unsigned `U32` bounds
  - `flow_rfc_shared` (`12898161`): RFC-shared `+t` tree preserved intact across ascending & descending `my_flow`
  - `flow_depth_and_bailout` (`3764938`): `d=0` on `Tip`/`Fork`, `d=5` on `Tip`, `d=70` (`> 64` bailout to `agy_flow_slow_`)
  - `flow_renamed_multi` (`1321666443`): completely renamed ADT/ctors/defs (`BTree`/`Tip`/`Fork`/`my_warp`/`my_wn`/`my_flow`)
- **`focused19`**: **19 / 19 PASS** (including all 3 expected-refusal negative controls).
- **Disk Hygiene**: `selfhost/build/agy/wave2_bst_b` = `7.3 MiB`, `research/agy/wave2_bst_b` = `60 KiB`.
