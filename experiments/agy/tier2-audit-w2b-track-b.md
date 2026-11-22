# Tier-2 Adversarial & Conformance Audit: Wave 2B Track B

**Audit Target (4-Pass Composed Stack on `unified/compiler.bend`):**
- `AGY-W2B-1`: [apply_reuse.py](file:///home/ai/bend2_agy/research/agy/wave2_bst/apply_reuse.py) (`--reuse --take`)
- `AGY-W2B-2`: [apply_p114h_mp.py](file:///home/ai/bend2_agy/research/agy/wave2_bst/apply_p114h_mp.py)
- `AGY-W2B-3`: [apply_bst_zipper.py](file:///home/ai/bend2_agy/research/agy/wave2_bst_b/apply_bst_zipper.py)
- `AGY-W2B-4`: [apply_flow_native.py](file:///home/ai/bend2_agy/research/agy/wave2_bst_b/apply_flow_native.py)
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_bst_b/test_tier2_adversarial.py)

## Overall Verdict: **PASS (CLEARED FOR TIER-3 INTEGRATION)**

Both `AGY-W2B-3` (`apply_bst_zipper.py`) and `AGY-W2B-4` (`apply_flow_native.py`) passed ruthless static soundness inspection, all 3 fresh Tier-2 adversarial differential suites against upstream Bend and Phase 205, and all 87 Hosted-B1 conformance tests (`64/64 native64` + `10/10 runtime10` + `13/13 boundary13`).

---

## 1. Static Soundness Audit

### `AGY-W2B-3` (`apply_bst_zipper.py`)
- **Zero-mutation partial-descent bailout**:
  - Live descriptor checks (`capabilities & 9 == 9` and `!cid_hot[node_cid]`) execute before saving `%rbx`.
  - Descent loop reads only (`cur`, `e.mem[loc+1]`, `e.mem[loc+0/2]`), checking `(cur >> 40) == (0x20000 | node_cid)` (`TAG_CTR == 2`, `RFC_BIT == 0`, exact `node_cid`) and `loc >= HEAP_OFF` at every node.
  - On encountering a shared `0x82` internal child (even partway down a unique `0x02` root), a static node, or an empty class-2 freelist at `l_ins`, `l_bail` pops `%rbx` and jumps to `agy_zip_slow_<sym>` with `%rdi, %rsi, %rdx, %rcx` completely intact and **zero heap mutations**.
- **Fuel & `U32`/`Nat` boundary soundness**:
  - `Leaf{}` is checked before `rem_fuel == 0` (`fuel == 0` on `Leaf{}` still inserts, matching `fin(x, down(0n, x, (Leaf{}, Nil{})))`).
  - `rem_fuel` uses 64-bit `testq`/`subq`, handling `fuel > U32.max` (`Succ{U32.to_nat(4294967295)}`) identically to upstream Bend.
  - At `rem_fuel == 0` on a `Node`, returns `tree` unchanged (preserves refcount conservation `in=1, out=1` for unique, RFC-shared, and static roots alike).
  - Unsigned `cmpl` + `jb` matches `U32.is_lt(x, v)` across `0`, `4294967295`, and duplicate keys (`x == v` goes right).
- **Name-independent certification**:
  - Strictly enforces `u32_is_lt` intrinsic, matching `Frame` constructor identity between `pick` and `up`, exact `l`/`r` child placement, and unmodified `v` on rebuild. Near-miss variants (`U32.is_le`, swapped `l`/`r`, `v+1` in `up`) cleanly decline certification.

### `AGY-W2B-4` (`apply_flow_native.py`)
- **Entry guards & depth bounds**:
  - Guards `mode == 0`, `depth == 0`, `val == 0` (`8(%rsp)`), `d <= 64` (unsigned `ja slow`, so `d == 65` and `d > U32.max` cleanly bail to `agy_flow_slow_<sym>`), `capabilities & 9 == 9`, and `!cid_hot[node_cid]`.
- **Shared children & in-place parent reuse**:
  - When a uniquely-owned `0x02` parent `Node` contains shared `0x82` children (including `Node{sub, sub}` where both children alias the same `0x82` subtree), `.Lwn` detects `(child >> 40) != (0x20000 | node_cid)` and delegates to `p114r_<wn>` (`l_wn_slow`), consuming each child ref cleanly and writing the newly warped subtrees back into the uniquely-owned parent's slots without mutating `sub`.
  - Stack alignment verified `0 mod 16` before every `call` (`l_rec`, `l_wn`, `warp_sym`, `wn_sym`, `slow`).
  - `p114r_<warp>` and `p114r_<wn>` symbol existence is guaranteed whenever `flow` is emitted as a `p114r_` worker by `AGY-W2B-2`'s topological `p114h` admission invariant.

---

## 2. Verification Results

### Tier-2 Adversarial Differential Tests (`test_tier2_adversarial.py`, upstream == Phase 205 == Wave 2B Track B)
- `bst_partial_descent_and_fuel_u32max`: **PASS** (`2938408 232404701 714325878 7625`) — unique root with shared `0x82` internal child 2 levels down (zero mutation to `sh`), `fuel = Succ{U32.to_nat(4294967295)}`, `fuel = 0n`/`1n`, duplicate keys, `0`/`4294967295`
- `bst_nearmiss_variants`: **PASS** (`2453435638 2838634 2821236`) — `U32.is_le`, swapped `l`/`r`, and `v+1` in `up` all cleanly decline and match upstream
- `flow_shared_children_and_depth_edges`: **PASS** (`11295449 208513 962138 192316 68908 68908 192316 45`) — unique root with `Node{sub, sub}` shared `0x82` children (zero mutation to `sub`), static tree, exact `d = 0, 64, 65`, `d = Succ{U32.to_nat(4294967295)}`, and `Leaf` at `d = 64`

### Hosted-B1 Full Conformance (Freshly Built 4-Pass Track B API)
- **`native64`**: **64 / 64 PASS** (118.17s)
- **`runtime10`**: **10 / 10 PASS** (11.58s)
- **`boundary13`**: **13 / 13 PASS** (11.10s)
