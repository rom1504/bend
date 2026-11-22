# Tier-2 Adversarial & Conformance Audit: Wave 2B Track A

**Audit Target:**
- Combined patcher: [apply_all_track_a.py](file:///home/ai/bend2_agy/research/agy/wave2_ray_b/apply_all_track_a.py) (`apply_wave2_ray.py` + [apply_wave2b.py](file:///home/ai/bend2_agy/research/agy/wave2_ray_b/apply_wave2b.py))
- Prebuilt candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray_b/api_w2b.mjs`
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_ray_b/test_tier2_adversarial.py)

## Overall Verdict: **PASS — CLEARED FOR TIER-3 INTEGRATION (POST-FIX)**

1. **Initial audit (`FAIL`)**: Caught a real silent miscompilation bug in the Wave 2B carried-F32 XMM pass (`w2_xl_plan` / `w2b_find_carried_idx` in [apply_wave2b.py](file:///home/ai/bend2_agy/research/agy/wave2_ray_b/apply_wave2b.py#L292-L308)) when `>= 6` invariant `F32` params / float constants exhausted `xmm10..xmm15`.
2. **Fix applied & verified (`PASS`)**: Updated `w2_xl_plan` (`w2b_finish_plan` + `w2b_plan_after_carried`) to allocate the carried `F32` parameter **first** at `reg = 10` before `w2_xl_assign_inv` and `w2_xl_assign_consts`, making `cidx_pre != 999999 <=> cxmm == 10 > 0` an exact invariant by construction. Rebuilt `/home/ai/bend2_agy/selfhost/build/agy/wave2_ray_b/api_w2b.mjs` (`Checked 5304 API exports`) and re-ran `test_tier2_adversarial.py`: **5 / 5 PASS** (`w2b_carried_xmm_reg_exhaust`: `1095514379 == 1095514379 == 1095514379`).

---

## 1. Miscompilation Found: Carried-F32 XMM Register Exhaustion (`w2_xl_plan`)

### Root Cause
In [apply_wave2b.py](file:///home/ai/bend2_agy/research/agy/wave2_ray_b/apply_wave2b.py#L292-L308):
```bend
def w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +tparams = w2_xl_tail_params(params)
  +cidx_pre = w2b_find_carried_idx(tparams,0,nodes)
  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),
    u => w2_xl_pick_carried(tparams,0,nodes,ids,frame,
           w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
             w2_xl_assign_inv(tparams,0,nodes,ids,frame,
               W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidx_pre),X188Empty{},10}))),
```

1. `cidx_pre = w2b_find_carried_idx(tparams, 0, nodes)` selects the carried `F32` parameter index `cidx_pre` **before** checking whether any of `xmm10..xmm15` will remain available after `w2_xl_assign_inv` and `w2_xl_assign_consts`.
2. `x186_x_homes_capped(params, setup, nodes, cidx_pre)` runs `w2b_x_scan`, which treats `vals[cidx_pre]` at `P113DAgain` as an XMM read instead of forbidding it from XMM. Consequently, the local temporary holding `vals[cidx_pre]` (e.g. `y_next`) is allocated **only** an XMM home and is **never written to its GPR/stack home**.
3. When the loop body contains `>= 6` invariant `F32` parameters and/or float constants, `w2_xl_assign_inv` + `w2_xl_assign_consts` exhaust `xmm10..xmm15` (`reg == 16`).
4. `w2_xl_pick_carried` then sees `U32.is_lt(16, 16) == False` and returns `cxmm = 0` (`has_c = False`).
5. At `P113DAgain` emission, because `has_c == False`, `x181_stmt(P113DAgain{vals})` runs and **`x181_again` reads `y_next` from its unwritten GPR/stack home**, silently corrupting the loop-carried `F32` state on every iteration.

### Exact Reproducer (`w2b_carried_xmm_reg_exhaust`)
Run `python3 -B research/agy/wave2_ray_b/test_tier2_adversarial.py /home/ai/bend2_agy/selfhost/build/agy/wave2_ray_b/api_w2b.mjs`:
```text
[w2b_carried_xmm_reg_exhaust] FAIL
  upstream : 1095514379
  phase205 : 1095514379
  w2b_a    : 1082130432
```

### Required Fix
Allocate the carried `F32` parameter **before** `w2_xl_assign_inv` and `w2_xl_assign_consts` (starting at `reg = 10`, where `U32.is_lt(10, 16)` is **guaranteed** true whenever `cidx_pre != 999999`), then run `w2_xl_assign_inv` and `w2_xl_assign_consts` on the remaining registers (`11..15`, or `10..15` if no carried param). This makes `cidx_pre != 999999 <=> cxmm > 0` an exact invariant by construction (and also prioritizes the loop-carried recurrence over the 6th constant). Re-run `test_tier2_adversarial.py` after fixing.

---

## 2. Other Soundness Checks (Verified Clean)
- **Carried `F32` with `F32.bits` / swapped carried `F32`s**: `w2b_carried_bits_and_swap` **PASS** (`1071967378 2869376`).
- **Float copy coalescing (`w2b_coalesce`) + commutative `addss`/`mulss`**: `w2b_coalesce_and_comm_edges` **PASS** (`63742976 0`, including operand aliasing `x+x`/`y*y`, live reuse, and `-0.0 + 0.0`).
- **Unboxed/boxed `Bool` branch fast-path (`w2b_bool_match`, `w2b_emit_bool_fast`)**: `w2b_bool_boxed_and_unboxed` **PASS** (`50 50 45 57`, covering unboxed `0`/`1` and boxed `True{}`/`False{}` in both match arm orders).
- **Sound post-DCE `sarl` (`w2_asr_body` + `w2_asr_strip_self` + second `x185_dead_body`)**: `w2b_asr_boundaries_and_live` **PASS** (`0 0 0 0`, covering `0, 1, 2147483647, 2147483648, 4294967295`, shifts `1, 8, 31`, and live intermediate `s1`/`m`).

---

## 3. Hosted-B1 Conformance Results (`api_w2b.mjs`)
- **`native64`**: **64 / 64 PASS** (125.12s)
- **`runtime10`**: **10 / 10 PASS** (12.15s)
- **`boundary13`**: **13 / 13 PASS** (12.33s)
- **Tier-2 Adversarial (`test_tier2_adversarial.py`, post-fix)**: **5 / 5 PASS** (`w2b_carried_xmm_reg_exhaust` fixed: `1095514379 == 1095514379 == 1095514379`)
