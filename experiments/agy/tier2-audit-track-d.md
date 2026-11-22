# Tier-2 Adversarial & Conformance Audit: Wave 2 Track D

**Audit Target:**
- Patcher: [apply_lex_deforest.py](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/apply_lex_deforest.py) + [wave2_lex_deforest.bend](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend)
- Prebuilt candidate API: `/home/ai/bend2_agy/selfhost/build/agy/wave2_lexrec/api_lex.mjs`
- Adversarial test suite: [test_tier2_adversarial.py](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/test_tier2_adversarial.py)

## Overall Verdict: **PASS — CLEARED FOR TIER-3 INTEGRATION (POST-FIX)**

1. **Initial audit (`FAIL`)**: Caught a real silent miscompilation bug in W2D's top-level `Mat` lifting (`w2d_lift_mat2_go` / `$w2d$m2$<ctor>` and `w2d_lift_closed_mat` / `$w2d$ch$<code>` in [wave2_lex_deforest.bend](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend#L1262-L1350)).
2. **Fix applied & verified (`PASS`)**: Updated `w2d_scon_mat_ch_raw` and `w2d_scon_direct_res` to give every lifted `Mat` a globally unique fresh name (`$w2d$m2$<ctor>$<n3>$<ctx_len>` and `$w2d$ch$<code>$<n1>$<ctx_len>`), and updated `w2d_lift_mat2_go` and `w2d_lift_closed_mat` to never silently reuse an existing def on name collision (falling back to the unlifted expression instead). Rebuilt `/home/ai/bend2_agy/selfhost/build/agy/wave2_lexrec/api_lex.mjs`, re-ran `test_tier2_adversarial.py`: **3 / 3 PASS** (`w2d_m2_name_collision`: `1806378708 == 1806378708 == 1806378708`), and verified `bench/runtime/lexer/main.bend` (`size=23n` → `2401049475`).

---

## 1. Miscompilation Found: Lifted-`Mat` Name Collision (`$w2d$m2$<ctor>` & `$w2d$ch$<code>`)

### Root Cause
In [wave2_lex_deforest.bend](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend#L1290-L1294) and [line 1321](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend#L1321):
```bend
def w2d_lift_mat2_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  kc(W2State,Bool.not(String.eq(dk(lookup(ctx,hname)),"Absent")),
    u => W2State{ctx,added,0,app(app(app(ref(hname),a0),a1),acc_arg),False{}},
    u => w2d_lift_mat2_build(ctx,added,hname,mat,a0,a1,acc_id,acc_ty,acc_arg))
```
1. `w2d_scon_mat_ch_raw` names the lifted 2-arg `Mat` helper solely by the hoisted constructor name: `"$w2d$m2$" ++ nm(j_strip(kid(se, 0)))` (e.g. `"$w2d$m2$Gap"`).
2. When a program has two distinct 2-arg `Char`-producing helpers (e.g. `op1` choosing `+ - * /` and `op2` choosing `= ; : ,`) whose fused `step` expressions both hoist `Gap{}`:
   - The first lifts its `Mat` into `$w2d$m2$Gap` and inserts it into `ctx`.
   - The second sees `lookup(ctx, "$w2d$m2$Gap") != Absent` and **silently reuses `op1`'s `$w2d$m2$Gap`**, discarding `op2`'s `Mat` body!
   - Because both have the exact same type (`Bool -> Bool -> U32 -> U32`), Bend's kernel type-checker accepts the miscompiled definition without error.
3. The **exact same bug** exists in `w2d_lift_closed_mat` ([lines 1262–1266](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend#L1262-L1266) and [line 1348](file:///home/ai/bend2_agy/research/agy/wave2_lexrec/wave2_lex_deforest.bend#L1348)), where `"$w2d$ch$" ++ U32.show(code)` collides across two distinct folds over the same state type `st_ty` and character code.

### Exact Reproducer (`w2d_m2_name_collision`)
Run `python3 -B research/agy/wave2_lexrec/test_tier2_adversarial.py /home/ai/bend2_agy/selfhost/build/agy/wave2_lexrec/api_lex.mjs`:
```text
[w2d_m2_name_collision] FAIL
  upstream : 1806378708
  phase205 : 1806378708
  track_d  : 2998236967
```

### Required Fix
Give every lifted `Mat` helper a **unique fresh name** using the monotonic `next` counter (and return `U32.inc(next)`), e.g.:
- In `w2d_scon_mat_ch_raw` (line 1321): `"$w2d$m2$" ++ nm(j_strip(kid(se,0))) ++ "$" ++ U32.show(n3)` (passing `U32.inc(n3)` to `w2d_scon_mat_ch_lifted`).
- In `w2d_scon_direct_res` (line 1348): `"$w2d$ch$" ++ U32.show(code) ++ "$" ++ U32.show(n1)` (passing `U32.inc(n1)` to `w2d_scon_direct_lifted`).
- In both `w2d_lift_mat2_go` and `w2d_lift_closed_mat`: never silently reuse an existing definition on name collision without verifying structural body equality (`k_eq`); if a name is already taken, bail out to the unlifted expression instead of calling a different function!

---

## 2. Other Soundness Checks (Verified Clean)
- **`p205v` sound U32 interval folding**:
  - `p205v_range_add` checks `U32.is_ge(s_hi, ha) && U32.is_ge(s_lo, la)` (sound no-wrap guard); `p205v_range_mod` rejects `k == 0`; `p205v_range_and` bounds `[0, k]`; all 6 comparison ops (`le/lt/ge/gt/eq/ne`) verified sound at endpoints `0` and `4294967295`.
  - `w2d_u32_interval_edges`: **PASS** (`320086885` across upstream, Phase 205, and Track D).
- **W2D String `foldl` deforestation**:
  - `w2d_unicode_empty_and_order`: **PASS** (`307500765` across upstream, Phase 205, and Track D — empty `""`, `0n` builder, Unicode `Chr{128512}`, non-linear observed string, order-sensitive fold).

---

## 3. Hosted-B1 Conformance Results (`api_lex.mjs`)
- **`native64`**: **64 / 64 PASS** (147.08s)
- **`runtime10`**: **10 / 10 PASS** (7.88s)
- **`boundary13`**: **13 / 13 PASS** (9.00s)
- **Tier-2 Adversarial (`test_tier2_adversarial.py`, post-fix)**: **3 / 3 PASS** (`w2d_m2_name_collision` fixed: `1806378708 == 1806378708 == 1806378708`)
- **`lexer` oracle (`bench/runtime/lexer/main.bend`, `size=23n`)**: **PASS** (`2401049475`)
