# Tier-2 Adversarial & Conformance Audit: Wave 2 Track B

**Audit Target:**
- `AGY-W2B-1`: [apply_reuse.py](file:///home/ai/bend2_agy/research/agy/wave2_bst/apply_reuse.py) (`--reuse --take`)
- `AGY-W2B-2`: [apply_p114h_mp.py](file:///home/ai/bend2_agy/research/agy/wave2_bst/apply_p114h_mp.py)
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_bst/test_tier2_adversarial.py)

## Overall Verdict: **PASS (CLEARED FOR TIER-3 INTEGRATION)**

Both `AGY-W2B-1` (`apply_reuse.py --reuse --take`) and `AGY-W2B-2` (`apply_p114h_mp.py`) passed ruthless static soundness inspection, all 4 fresh Tier-2 adversarial differential tests against upstream Bend and Phase 205, and all 87 Hosted-B1 conformance tests (`64/64 native64` + `10/10 runtime10` + `13/13 boundary13`).

---

## 1. Static Soundness Audit

### `AGY-W2B-1` (`apply_reuse.py --reuse --take`)
- **Perceus in-place reuse (`agy_rt_take_reuseN` → `agy_rt_ctor_reuseM`)**:
  - Live runtime guards verified: `p111_program.capabilities & 9 == 9` (fast take + unsealed ctor), `!p111_cid_hot[target_cid]`, uniquely owned `TAG_CTR` (`(term >> 56) == 2`, `RFC_BIT == 0`), `source_cid < constructor_count`, `p111_cid_arity[source_cid] == N`, and `loc >= HEAP_OFF` (identical formula to `agy_rt_take_text` in `unified/compiler.bend`).
  - Aliasing & lifetime verified: `agy_rt_take_reuseN` copies all `N` source fields into stack buffer `buf` before any subsequent reads; `agy_reuse_find` forbids any intervening `N111Call`/`N111If`/`N111Return`, requires every non-abort path (`p111_rt_sink` + `p111_rt_fail` exempted) to reach a same-class (`p185cc_class(N) == p185cc_class(M)`) and same-`target_ctor` `p125_rt_ctorM`, and checks `tname` is dead in `rest`.
  - Fallback safety verified: `%rdi`, `%rsi`, `%rdx` are preserved across all guard checks before `call p125_rt_takeN`; slow path returns `0` in `tname`, causing `agy_rt_ctor_reuseM` to branch to normal inlined allocation (`testq %rcx, %rcx; jz normal`).
- **0-arg `p111_rt_ctor` constant folding**:
  - Verified against [runtime.c](file:///home/ai/bend2_agy/selfhost/src/runtime/qbe/runtime.c#L4091-L4094): `if (!count) return term_pak(cid, 0);` executes unconditionally before `cid_hot` or `capabilities`. Folding `p111_rt_ctor(state, ctor, buf, 0)` (when `p185cb_known` & `p185cc_known(ctor, 0)`) to `movabsq $(0x0100000000000000 | (cid << 40)), %rax` is bit-exact and preserves all observer invariants.

### `AGY-W2B-2` (`apply_p114h_mp.py`)
- **Acyclicity & mutual recursion**:
  - `agy_p114h_fixpoint` runs up to 6 passes, admitting segment `f` into `hready` only when `p114h_plan(f, index, view)` succeeds against the current `view` (requiring every non-self call in `f` to already be in `ready`/`direct`/`hready`) and `agy_p114h_plan_hygiene` passes.
  - Because a function can only enter `hready` if all its non-self callees are already in `hready` from strictly earlier passes, mutually recursive cycles (`ping <-> pong`) can never enter `hready` (confirmed via `objdump -dr` on `p114h_mutual_rec_deep`), preventing unbounded C-stack recursion and preventing post-fixpoint hygiene drift.
- **Calling convention & arity boundary**:
  - Verified `count <= 8` (`1 + 8 + 3 = 12` machine args, 6 register + 6 stack args), closures/partial applications (`p111_rt_apply`), and erased arguments (`-tag: U32`).

---

## 2. Verification Results

### Tier-2 Adversarial Differential Tests (`test_tier2_adversarial.py`, upstream == Phase 205 == Track B)
- `p114h_mutual_rec_deep`: **PASS** (`135001`) — 60,000-hop mutually recursive `ping <-> pong` (verified not promoted to cyclic direct C calls; no stack overflow)
- `p114h_8_args_stack_spill`: **PASS** (`13013`) — exact 8-user-arg / 12-machine-arg `p114r_` boundary
- `p114h_closures_and_erased`: **PASS** (`85`) — closures + erased `-tag: U32` argument mixed with promoted `p114r_` workers
- `reuse_branch_alias_and_mixed`: **PASS** (`177209345 31134`) — asymmetric reuse branches, field permutation, class-1/class-2 cross-arity, cross-class non-fusion, and unique parent containing RFC-shared `0x82` child

### Hosted-B1 Full Conformance (Freshly Built Track B Combined API)
- **`native64`**: **64 / 64 PASS** (103.05s)
- **`runtime10`**: **10 / 10 PASS** (7.54s)
- **`boundary13`**: **13 / 13 PASS** (7.61s)
