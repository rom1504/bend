# bend5k/x64.bend — Direct x86-64 Codegen (-O0 Stack-Slot & -O2 RegAlloc, SysV AMD64 + P111 v11102)
# Regs: %rdi=state, %rsi/%rdx/%rcx/%r8/%r9=args0..4, %rax=ret; frame=[saved_callee|state|spills|128B scratch]
def x64_if1(-A: Data, -B: Data, c: Bool, x: A, t: A -> B, f: A -> B) -> B:
  match c:
    case True{}: t(x)
    case False{}: f(x)
def x64_when(c: Bool, x: List<&2, X64Inst>, f: List<&2, X64Inst> -> List<&2, X64Inst>) -> List<&2, X64Inst>:
  match c:
    case True{}: f(x)
    case False{}: x
type X64Ha is Data:
  X64Ha{ha: U32, dp: U32, mk: U32, sc: Bool}
def x64_no_ha() -> X64Ha: X64Ha{0, 0, 0, False{}}
type X64Bor is Data:
  X64Bor{bpm: U32, bm: RaVec<U32>}
type X64HMag is Data:
  X64HMag{m0: U32, r0: U32, m1: U32, r1: U32, t0c: U32, t0t: U32, t0e: U32, t0d: Bool}
type X64R2 is Data:
  X64R2{csm: U32, map: RaVec<U32>, cur_fid: U32, cur_r2: U32, u2p: U32, u2o0: U32, u2o1: U32}
type X64R2Scan is Data:
  X64R2Scan{ret2: RaVec<U32>, u2p: RaVec<U32>}
type X64Meta is Data:
  X64Meta{is_leaf: Bool, hi_used: RaVec<Bool>, is_sc: RaVec<U32>, num_use: RaVec<Bool>, arr_org: RaVec<U32>, ha0: X64Ha, ha1: X64Ha, ha2: X64Ha, hax: List<&2, X64Ha>, no_chk: Bool, lbase: U32, cval: RaVec<U32>, cmat: RaVec<Bool>, r2: X64R2, hmag: X64HMag, bor: X64Bor}
def x64_empty_meta() -> X64Meta: X64Meta{False{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, x64_no_ha(), x64_no_ha(), x64_no_ha(), Nil{}, False{}, 0, RVEmpty{}, RVEmpty{}, X64R2{0, RVEmpty{}, 0, 0, 0, 0, 0}, X64HMag{0, 0, 0, 0, 0, 0, 0, False{}}, X64Bor{0, RVEmpty{}}}
type X64Ctx is Data:
  X64Ctx{is_o2: Bool, reg_map: RaVec<U32>, vd: Nat, spill_base: U32, state_disp: U32, mem_reg: U32, mem_disp: U32, frame: U32, used_callee: List<&2, U32>, heap_off: U32, meta: X64Meta}
def x64_ctx_vd(ctx: X64Ctx) -> Nat:
  X64Ctx{_, _, vd, _, _, _, _, _, _, _, _} = ctx
  vd
def x64_need_mask32(ctx: X64Ctx, dst: U32) -> Bool:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: True{}
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, hu, _, _, _, _, _, _, _, _, _, _, _, _, _, _}}: ra_vec_get(Bool, vd, False{}, dst, hu)
def x64_sc_tag(ctx: X64Ctx, v: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, sc, _, _, _, _, _, _, _, _, _, _, _, _, _}}: ra_vec_get(U32, vd, 0, v, sc)
    case _: 0
def x64_is_scalar(ctx: X64Ctx, v: U32) -> Bool: (+s = x64_sc_tag(ctx, v); Bool.and(U32.is_ge(s, 1), U32.is_le(s, 2)))
def x64_is_num_scalar(ctx: X64Ctx, v: U32) -> Bool: U32.is_eq(x64_sc_tag(ctx, v), 2)
def x64_is_num_use(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, nu, _, _, _, _, _, _, _, _, _, _, _, _}}: ra_vec_get(Bool, vd, False{}, v, nu)
    case _: False{}
def x64_all_scalar(+ctx: X64Ctx, vs: List<&2, U32>) -> Bool: opt_alll(~U32, ~X64Ctx, ~(c => v => x64_is_scalar(c, v)), ctx, vs)
def x64_hoist_find_ext(+org: U32, hs: List<&2, X64Ha>) -> X64Ha:
  match hs:
    case Nil{}: x64_no_ha()
    case Con{X64Ha{+h, dp, mk, sc}, t}: Bool.pick(X64Ha, Bool.and(U32.is_ne(h, 0), U32.is_eq(org, h)), X64Ha{h, dp, mk, sc}, x64_hoist_find_ext(org, t))
def x64_hoist_of(ctx: X64Ctx, a: U32) -> X64Ha:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, ao, X64Ha{+h0, dp0, mk0, sc0}, X64Ha{+h1, dp1, mk1, sc1}, X64Ha{+h2, dp2, mk2, sc2}, hax, _, _, _, _, _, _, _}}: (+org = ra_vec_get(U32, vd, 0, a, ao); r2 = Bool.pick(X64Ha, Bool.and(U32.is_ne(h2, 0), U32.is_eq(org, h2)), X64Ha{h2, dp2, mk2, sc2}, x64_hoist_find_ext(org, hax)); Bool.pick(X64Ha, Bool.and(U32.is_ne(h0, 0), U32.is_eq(org, h0)), X64Ha{h0, dp0, mk0, sc0}, Bool.pick(X64Ha, Bool.and(U32.is_ne(h1, 0), U32.is_eq(org, h1)), X64Ha{h1, dp1, mk1, sc1}, r2)))
    case _: x64_no_ha()
def x64_un_ha(-R: Type, h: X64Ha, k: U32 -> U32 -> Bool -> R) -> R:
  X64Ha{_, dp, mk, sc} = h
  k(dp, mk, sc)
def x64_hoist_slot(is_dp: Bool, ctx: X64Ctx, a: U32) -> U32: x64_un_ha(U32, x64_hoist_of(ctx, a), dp => mk => _ => Bool.pick(U32, is_dp, dp, mk))
def x64_hoist_is_sc(ctx: X64Ctx, a: U32) -> Bool: x64_un_ha(Bool, x64_hoist_of(ctx, a), _ => _ => sc => sc)
def x64_no_dp_chk(ctx: X64Ctx) -> Bool:
  X64Ctx{o2, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, nc, _, _, _, _, _, _}} = ctx
  Bool.and(o2, nc)
def x64_is_cval(+e: U32) -> Bool: Bool.and(U32.is_gt(e, 0), U32.is_lt(e, 4294967295))
def x64_const_val(ctx: X64Ctx, consts: RaVec<U32>, +v: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, +vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, cv, _, _, _, _}}: (+lc = ra_vec_get(U32, vd, 0, v, consts); +gc = ra_vec_get(U32, vd, 0, v, cv); Bool.pick(U32, U32.is_ne(lc, 0), lc, Bool.pick(U32, x64_is_cval(gc), gc, 0)))
    case _: 0
def x64_skip_const(ctx: X64Ctx, +v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, +vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, cv, cm, _, _, _}}: Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, v, cv)), Bool.not(ra_vec_get(Bool, vd, False{}, v, cm)))
    case _: False{}
def x64_ctx_csm(ctx: X64Ctx) -> U32:
  X64Ctx{o2, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, _, _, _, _, _}, _, _}} = ctx
  Bool.pick(U32, o2, U32.and(csm, 15), 0)
def x64_is_inline_rt(ctx: X64Ctx) -> Bool:
  X64Ctx{o2, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, _, _, _, _, _}, _, _}} = ctx
  Bool.and(o2, U32.is_zero(U32.and(csm, 16)))
def x64_is_inline_take(ctx: X64Ctx, +cnt: U32) -> Bool:
  X64Ctx{o2, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, fid, _, _, _, _}, _, _}} = ctx
  Bool.and(o2, Bool.or(Bool.and(U32.is_zero(U32.and(csm, 16)), U32.is_le(cnt, 8)), Bool.and(U32.is_ne(fid, 0), U32.is_le(cnt, 4))))
def x64_r2_of(ctx: X64Ctx, +fid: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, mp, _, _, _, _, _}, _, _}}: Bool.pick(U32, U32.is_lt(fid, 65536), ra_vec_get(U32, 8n, 0, fid, mp), 0)
    case _: 0
def x64_magic_hreg(ctx: X64Ctx, +m: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, X64HMag{m0, +r0, m1, +r1, _, _, _, _}, _}}: Bool.pick(U32, Bool.and(U32.is_ne(r0, 0), U32.is_eq(m, m0)), r0, Bool.pick(U32, Bool.and(U32.is_ne(r1, 0), U32.is_eq(m, m1)), r1, 0))
    case _: 0
def x64_is_bor(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64Bor{+bpm, bm}}}: Bool.and(U32.is_ne(bpm, 0), U32.is_ne(U32.and(ra_vec_get(U32, vd, 0, v, bm), bpm), 0))
    case _: False{}
def x64_u32_nth(xs: List<&2, U32>, n: Nat) -> U32: low_nth(U32, n, 4294967295, xs)
def x64_heap_off(statics: List<&2, U32>) -> U32: U32.add(51413504, U32.and(U32.add(b5k_u32_list_len(statics), 127), U32.sub(0, 128)))
def x64_arg_reg(+i: U32) -> U32: Bool.pick(U32, U32.is_eq(i, 0), 6, Bool.pick(U32, U32.is_eq(i, 1), 2, Bool.pick(U32, U32.is_eq(i, 2), 1, Bool.pick(U32, U32.is_eq(i, 3), 8, 9))))
def x64_o2_arg_reg(+i: U32) -> U32: Bool.pick(U32, U32.is_eq(i, 0), 6, Bool.pick(U32, U32.is_eq(i, 1), 2, Bool.pick(U32, U32.is_eq(i, 2), 1, Bool.pick(U32, U32.is_eq(i, 3), 0, 7))))
def x64_cmp_cc(+op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 0), 4, Bool.pick(U32, U32.is_eq(op, 1), 5, Bool.pick(U32, U32.is_eq(op, 2), 2, Bool.pick(U32, U32.is_eq(op, 3), 6, Bool.pick(U32, U32.is_eq(op, 4), 7, 3)))))
def x64_align16(n: U32) -> U32: U32.and(U32.add(n, 15), U32.sub(0, 16))
def x64_fn_sym(name: String) -> String: String.append("$direct.", name)
def x64_seg_sym(fid: U32) -> String: String.append("p111_seg_", b5k_u32_to_str(fid))
def x64_build_fn_map_go(fns: List<&2, IrFn>, m: RaVec<String>) -> RaVec<String>: opt_foldl0(~IrFn, ~RaVec<String>, ~(f => acc => opt_un_fn(RaVec<String>, f, fid => name => _ => _ => _ => _ => _ => _ => ra_vec_set(String, 9n, fid, x64_fn_sym(name), acc))), fns, m)
def x64_lookup_fn_sym(fn_map: RaVec<String>, +fid: U32) -> String: ra_vec_get(String, 9n, x64_fn_sym(b5k_u32_to_str(fid)), fid, fn_map)
def x64_emit(inst: X64Inst, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: Con{inst, acc}
def x64_emit_if(cond: Bool, inst: X64Inst, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>: Bool.pick(List<&2, X64Inst>, cond, Con{inst, acc}, acc)
def x64_vreg_loc(ctx: X64Ctx, v: U32) -> U32:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: U32.add(100, v)
    case X64Ctx{True{}, rm, vd, _, _, _, _, _, _, _, _}: ra_vec_get(U32, vd, 0, v, rm)
def x64_spill_disp(ctx: X64Ctx, loc: U32) -> U32:
  X64Ctx{_, _, _, sb, _, _, _, _, _, _, _} = ctx
  U32.sub(0, U32.add(sb, U32.mul(U32.sub(loc, 100), 8)))
def x64_is_o2(ctx: X64Ctx) -> Bool:
  X64Ctx{o2, _, _, _, _, _, _, _, _, _, _} = ctx
  o2
def x64_is_gpr(loc: U32) -> Bool: U32.is_lt(loc, 20)
def x64_is_xmm(+loc: U32) -> Bool: Bool.and(U32.is_ge(loc, 20), U32.is_lt(loc, 100))
def x64_gpr_or(+loc: U32, def_r: U32) -> U32: Bool.pick(U32, x64_is_gpr(loc), loc, def_r)
def x64_vreg_gpr(ctx: X64Ctx, v: U32) -> U32: x64_gpr_or(x64_vreg_loc(ctx, v), 0)
def x64_vreg_io(is_ld: Bool, is_sp: Bool, is_xm: Bool, same: Bool, ctx: X64Ctx, reg: U32, loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp is_xm same:
    case True{} True{} _ _: Con{XLoad{reg, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{} _ _: Con{XStore{5, x64_spill_disp(ctx, loc), reg}, acc}
    case True{} False{} True{} _: Con{XCvt{3, reg, U32.sub(loc, 20)}, acc}
    case False{} False{} True{} _: Con{XCvt{2, U32.sub(loc, 20), reg}, acc}
    case _ False{} False{} True{}: acc
    case True{} False{} False{} False{}: Con{XMovRR{reg, loc}, acc}
    case False{} False{} False{} False{}: Con{XMovRR{loc, reg}, acc}
def x64_load_vreg(+ctx: X64Ctx, +reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, v); x64_vreg_io(True{}, U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, reg, loc, acc))
def x64_store_vreg(+ctx: X64Ctx, v: U32, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, v); x64_vreg_io(False{}, U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, reg, loc, acc))
def x64_xmm_io(+is_ld: Bool, is_sp: Bool, is_xm: Bool, ctx: X64Ctx, +xmm: U32, +loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp is_xm:
    case True{} True{} _: Con{XXmmLoad{xmm, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{} _: Con{XXmmStore{5, x64_spill_disp(ctx, loc), xmm}, acc}
    case _ False{} True{}: (+xr = U32.sub(loc, 20); x64_emit_if(U32.is_ne(xr, xmm), XXmmRR{7, Bool.pick(U32, is_ld, xmm, xr), Bool.pick(U32, is_ld, xr, xmm)}, acc))
    case True{} False{} False{}: Con{XCvt{2, xmm, loc}, acc}
    case False{} False{} False{}: Con{XCvt{3, loc, xmm}, acc}
def x64_load_xmm(+ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, v); x64_xmm_io(True{}, U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, xmm, loc, acc))
def x64_store_xmm(+ctx: X64Ctx, v: U32, xmm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, v); x64_xmm_io(False{}, U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, xmm, loc, acc))
def x64_emit_const(+ctx: X64Ctx, dst: U32, +val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, dst); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(loc, 100), acc, a => Con{XStore{5, x64_spill_disp(ctx, loc), 0}, Con{XMovRI32{0, val}, a}}, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(loc), a, a1 => +xr = U32.sub(loc, 20); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_zero(val), a1, a2 => Con{XXmmRR{6, xr, xr}, a2}, a2 => Con{XCvt{2, xr, 0}, Con{XMovRI32{0, val}, a2}}), a1 => Con{XMovRI32{loc, val}, a1})))
def x64_emit_copy(+ctx: X64Ctx, +dst: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+cv = x64_const_val(ctx, RVEmpty{}, src); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(cv, 1), acc, a => x64_emit_const(ctx, dst, 0, a), a => +dloc = x64_vreg_loc(ctx, dst); +sloc = x64_vreg_loc(ctx, src); x64_when(U32.is_ne(dloc, sloc), a, a0 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(dloc, 100), a0, a1 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(sloc, 100), a1, a2 => Con{XStore{5, x64_spill_disp(ctx, dloc), 0}, Con{XLoad{0, 5, x64_spill_disp(ctx, sloc)}, a2}}, a2 => Con{Bool.pick(X64Inst, x64_is_xmm(sloc), XXmmStore{5, x64_spill_disp(ctx, dloc), U32.sub(sloc, 20)}, XStore{5, x64_spill_disp(ctx, dloc), sloc}), a2}), a1 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(dloc), a1, a2 => x64_load_xmm(ctx, U32.sub(dloc, 20), src, a2), a2 => x64_load_vreg(ctx, dloc, src, a2))))))
def x64_load_state(ctx: X64Ctx, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ctx{_, _, _, _, sd, _, _, _, _, _, _} = ctx
  Con{XLoad{reg, 5, sd}, acc}
def x64_load_mem(ctx: X64Ctx, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ctx{_, _, _, _, sd, +mr, +md, _, _, _, _} = ctx
  x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(mr, 0), acc, a => Con{XMovRR{reg, mr}, a}, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(md, 0), a, a1 => Con{XLoad{reg, 5, md}, a1}, a1 => Con{XLoad{reg, reg, 0}, Con{XLoad{reg, 5, sd}, a1}}))
def x64_scratch_io(+is_st: Bool, +ctx: X64Ctx, vs: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match vs:
    case Nil{}: acc
    case Con{+v, t}: (+off = U32.mul(idx, 8); +vloc = x64_vreg_loc(ctx, v); +is_xm = x64_is_xmm(vloc); x64_scratch_io(is_st, ctx, t, U32.add(idx, 1), x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_st, acc, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_xm, a, a0 => x64_emit(XXmmStore{4, off, U32.sub(vloc, 20)}, a0), a0 => x64_emit(XStore{4, off, 0}, x64_load_vreg(ctx, 0, v, a0))), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_xm, a, a0 => x64_emit(XXmmLoad{U32.sub(vloc, 20), 4, off}, a0), a0 => x64_store_vreg(ctx, v, 0, x64_emit(XLoad{0, 4, off}, a0))))))
def x64_save_params_go(+ctx: X64Ctx, n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: (+loc = x64_vreg_loc(ctx, idx); +soff = U32.add(16, U32.mul(U32.sub(idx, 5), 8)); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_lt(idx, 5), acc, a => x64_store_vreg(ctx, idx, Bool.pick(U32, x64_is_o2(ctx), x64_o2_arg_reg(idx), x64_arg_reg(idx)), a), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(loc), a, a0 => Con{XXmmLoad{U32.sub(loc, 20), 5, soff}, a0}, a0 => x64_store_vreg(ctx, idx, 0, Con{XLoad{0, 5, soff}, a0}))); x64_save_params_go(ctx, p, U32.add(idx, 1), a1))
def x64_push_extra_args(+ctx: X64Ctx, rev_extra: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl(~U32, ~X64Ctx, ~List<&2, X64Inst>, ~(c => v => a => Con{XPush{0}, x64_load_vreg(c, 0, v, a)}), ctx, rev_extra, acc)
def x64_load_reg_args(+ctx: X64Ctx, args: List<&2, U32>, +idx: U32, in_reg: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args in_reg:
    case Nil{} _: acc
    case _ False{}: acc
    case Con{v, t} True{}: (+nxt = U32.add(idx, 1); x64_load_reg_args(ctx, t, nxt, U32.is_lt(nxt, 5), x64_load_vreg(ctx, Bool.pick(U32, x64_is_o2(ctx), x64_o2_arg_reg(idx), x64_arg_reg(idx)), v, acc)))
def x64_finish_o2_call_args(is_o2: Bool, +nargs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(is_o2, acc, a => x64_emit_if(U32.is_ge(nargs, 5), XMovRR{9, 7}, x64_emit_if(U32.is_ge(nargs, 4), XMovRR{8, 0}, a)))
def x64_emit_call(+ctx: X64Ctx, +sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+nargs = b5k_u32_list_len(args); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_gt(nargs, 5), acc, a => +extra_cnt = U32.sub(nargs, 5); +odd = U32.is_eq(U32.and(extra_cnt, 1), 1); a1 = x64_push_extra_args(ctx, b5k_list_rev(U32, low_drop(U32, 5n, args)), x64_emit_if(odd, XSubRsp{8}, a)); a2 = x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, a1)); Con{XAddRsp{U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, x64_load_state(ctx, 7, a2))}, a => Con{XCallSym{sym}, x64_load_state(ctx, 7, x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, a)))}))
def x64_mask32(+reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: Con{XShift{9, reg, 32, False{}}, Con{XShift{8, reg, 32, False{}}, acc}}
def x64_mask40(+reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: Con{XShift{9, reg, 24, False{}}, Con{XShift{8, reg, 24, False{}}, acc}}
def x64_opt_mask32(need: Bool, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(need, acc, a => x64_mask32(reg, a))
def x64_opt_load_vreg(skip: Bool, ctx: X64Ctx, reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(Bool.not(skip), acc, a => x64_load_vreg(ctx, reg, v, a))
def x64_opt_load_xmm(skip: Bool, ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(Bool.not(skip), acc, a => x64_load_xmm(ctx, xmm, v, a))
def x64_bin_alu(m32: Bool, +op: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case 2: x64_opt_mask32(m32, 0, Con{XMul{0, 1}, acc})
    case 3: (a2 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, x64_emit(XMovRI32{0, 0}, x64_emit(XMovRR{2, 0}, acc)))); x64_emit(XLabel{lbl}, x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, x64_emit(XMovRR{0, 2}, a2)))))
    case 4: (a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, acc)); x64_mask32(0, x64_emit(XLabel{lbl}, x64_emit(XMovRR{0, 2}, x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, a1))))))
    case 8: x64_opt_mask32(m32, 0, Con{XShift{8, 0, 0, True{}}, acc})
    case 9: Con{XShift{9, 0, 0, True{}}, acc}
    case _: x64_opt_mask32(Bool.and(m32, U32.is_le(op, 1)), 0, Con{XAluRR{op, 0, 1}, acc})
def x64_is_simple_alu(+op: U32) -> Bool: Bool.or(U32.is_le(op, 1), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))
def x64_is_comm_alu(+op: U32) -> Bool: Bool.or(U32.is_zero(op), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))
def x64_load_xmm_c(ctx: X64Ctx, +xmm: U32, +v: U32, xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(xm0, U32.add(v, 1)), acc, a => x64_emit_if(U32.is_ne(xmm, 0), XXmmRR{7, xmm, 0}, a), a => x64_load_xmm(ctx, xmm, v, a))
def x64_emit_fbin_go(dxm: Bool, skip_st: Bool, +ctx: X64Ctx, dst: U32, +op: U32, +lhs: U32, +rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, +xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dxm:
    case True{}: (+fop = U32.sub(op, 10); +rxm = x64_is_xmm(rloc); +dx = U32.sub(dloc, 20); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(lloc, rloc), acc, a => x64_emit(XXmmRR{fop, dx, dx}, x64_load_xmm_c(ctx, dx, lhs, xm0, a)), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(dloc, rloc), a, a1 => +r0 = U32.is_eq(xm0, U32.add(rhs, 1)); x64_emit(XXmmRR{fop, dx, Bool.pick(U32, rxm, U32.sub(rloc, 20), Bool.pick(U32, r0, 0, 1))}, x64_opt_load_xmm(Bool.or(rxm, r0), ctx, 1, rhs, x64_load_xmm_c(ctx, dx, lhs, xm0, a1))), a1 => +lxm = x64_is_xmm(lloc); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.or(U32.is_eq(op, 10), U32.is_eq(op, 12)), a1, a0 => x64_emit(XXmmRR{fop, dx, Bool.pick(U32, lxm, U32.sub(lloc, 20), 1)}, x64_when(Bool.not(lxm), a0, a2 => x64_load_xmm_c(ctx, 1, lhs, xm0, a2))), a0 => x64_emit(XXmmRR{7, dx, 0}, x64_emit(XXmmRR{fop, 0, dx}, x64_load_xmm_c(ctx, 0, lhs, xm0, a0)))))))
    case False{}: (+fop = U32.sub(op, 10); +rxm = x64_is_xmm(rloc); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(lloc, rloc), acc, a0 => x64_emit(XXmmRR{fop, 0, 0}, x64_load_xmm_c(ctx, 0, lhs, xm0, a0)), a0 => x64_emit(XXmmRR{fop, 0, Bool.pick(U32, rxm, U32.sub(rloc, 20), 1)}, x64_load_xmm_c(ctx, 0, lhs, xm0, x64_when(Bool.not(rxm), a0, a_ => x64_load_xmm_c(ctx, 1, rhs, xm0, a_))))); x64_when(Bool.not(skip_st), a1, a0 => x64_store_xmm(ctx, dst, 0, a0)))
def x64_ibin_reg_go(is_dir: Bool, is_comm_eq: Bool, +ctx: X64Ctx, +dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, lloc: U32, +rloc: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_dir is_comm_eq:
    case True{} _: (+rg = x64_is_gpr(rloc); +sr = Bool.pick(U32, rg, rloc, 1); a1 = x64_opt_load_vreg(rg, ctx, 1, rhs, x64_load_vreg(ctx, dloc, lhs, acc)); x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_le(op, 2)), dloc, x64_emit(Bool.pick(X64Inst, U32.is_eq(op, 2), XMul{dloc, sr}, XAluRR{op, dloc, sr}), a1)))
    case False{} True{}: x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_zero(op)), dloc, x64_emit(XAluRR{op, dloc, lloc}, acc))
    case False{} False{}: (+dir_r = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(rloc), Bool.or(x64_is_simple_alu(op), U32.is_eq(op, 2)))); a1 = x64_opt_load_vreg(dir_r, ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc)); a2 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, dir_r, a1, a => x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_le(op, 2)), 0, x64_emit(Bool.pick(X64Inst, U32.is_eq(op, 2), XMul{0, rloc}, XAluRR{op, 0, rloc}), a)), a => x64_bin_alu(x64_need_mask32(ctx, dst), op, lbl, a)); x64_store_vreg(ctx, dst, 0, a2))
type X64Mag is Data:
  X64Mag{m: U32, s: U32, add1: Bool}
def x64_magic_loop(n: Nat, +d: U32, +rem: U32, +q: U32) -> X64Mag:
  match n:
    case 0n: X64Mag{q, rem, False{}}
    case 1n+p: (+r2 = U32.shln(rem, 1n); +ge = U32.is_ge(r2, d); x64_magic_loop(p, d, Bool.pick(U32, ge, U32.sub(r2, d), r2), Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n))))
def x64_magic_fin(st: X64Mag, +d: U32, +k: U32) -> X64Mag:
  X64Mag{+q, +rem, _} = st
  +ok = U32.is_le(U32.sub(d, rem), U32.shln(1, U32.to_nat(k)))
  +ge = U32.is_ge(U32.shln(rem, 1n), d)
  ql = Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n))
  Bool.pick(X64Mag, ok, X64Mag{U32.add(q, 1), U32.add(32, k), False{}}, X64Mag{U32.add(ql, 1), U32.add(k, 1), True{}})
def x64_magic(+d: U32) -> X64Mag: (+k = U32.from_nat(U32.log2(d)); x64_magic_fin(x64_magic_loop(32n, d, U32.shln(1, U32.to_nat(k)), 0), d, k))
def x64_is_pow2(+c: U32) -> Bool: Bool.and(U32.is_gt(c, 0), U32.is_zero(U32.and(c, U32.sub(c, 1))))
def x64_is_mul_sr(+c: U32) -> Bool: Bool.or(U32.is_le(c, 1), Bool.or(x64_is_pow2(c), Bool.or(U32.is_eq(c, 3), Bool.or(U32.is_eq(c, 5), Bool.or(U32.is_eq(c, 9), U32.is_eq(c, 10))))))
def x64_lea_scale(+c: U32) -> U32: Bool.pick(U32, U32.is_eq(c, 3), 17, Bool.pick(U32, U32.is_eq(c, 5), 18, Bool.pick(U32, U32.is_eq(c, 9), 19, 0)))
def x64_emit_mul_c(+reg: U32, +tmp: U32, +c: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+cm1 = U32.sub(c, 1); +ls = x64_lea_scale(c); Bool.pick(List<&2, X64Inst>, Bool.and(U32.is_ne(reg, 4), U32.is_ne(ls, 0)), x64_emit(XMul{reg, ls}, acc), Bool.pick(List<&2, X64Inst>, Bool.and(U32.is_ge(c, 3), x64_is_pow2(cm1)), x64_emit(XAluRR{0, reg, tmp}, x64_emit(XShift{8, reg, U32.from_nat(U32.log2(cm1)), False{}}, x64_emit(XMovRR{tmp, reg}, acc))), x64_emit(XMul{reg, tmp}, x64_emit(XMovRI32{tmp, c}, acc)))))
def x64_emit_mul_sr(+ctx: X64Ctx, +dst: U32, +lhs: U32, +dloc: U32, +c: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match c:
    case 0: x64_emit_const(ctx, dst, 0, acc)
    case 1: (+dreg = x64_gpr_or(dloc, 0); x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_load_vreg(ctx, dreg, lhs, acc))))
    case 10: (+dreg = x64_gpr_or(dloc, 0); x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(XShift{8, dreg, 1, False{}}, x64_emit(XMul{dreg, 18}, x64_load_vreg(ctx, dreg, lhs, acc))))))
    case _: (+dreg = x64_gpr_or(dloc, 0); +ls = x64_lea_scale(c); x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(Bool.pick(X64Inst, U32.is_ne(ls, 0), XMul{dreg, ls}, XShift{8, dreg, U32.from_nat(U32.log2(c)), False{}}), x64_load_vreg(ctx, dreg, lhs, acc)))))
def x64_emit_divmod_magic(is_mod: Bool, +ctx: X64Ctx, +dst: U32, +lhs: U32, +c: U32, mg: X64Mag, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Mag{+m, s, +add1} = mg
  +mr = x64_magic_hreg(ctx, m)
  mm = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(mr, 0), x64_emit_if(add1, XMovRR{2, 0}, x64_load_vreg(ctx, 0, lhs, acc)), a => x64_emit(XMul{0, mr}, a), a => x64_emit(XMul{0, 1}, x64_emit(XMovRI32{1, m}, a)))
  a1 = x64_emit(XShift{9, 0, s, False{}}, x64_when(add1, mm, a => x64_emit(XAluRR{0, 0, 2}, x64_emit(XShift{9, 0, 32, False{}}, a))))
  x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_mod, a1, a => +dreg = x64_gpr_or(x64_vreg_loc(ctx, dst), 2); x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRR{1, dreg, 0}, x64_load_vreg(ctx, dreg, lhs, x64_emit_mul_c(0, 1, c, a)))), a => x64_store_vreg(ctx, dst, 0, a))
def x64_emit_ibin_imm(+ctx: X64Ctx, +dst: U32, +op: U32, +lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, +has_rc: Bool, +c: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+imm_alu = Bool.and(has_rc, x64_is_simple_alu(op)); +imm_sh = Bool.and(has_rc, Bool.and(U32.is_ge(op, 8), U32.is_lt(c, 64))); +is_dm = Bool.and(has_rc, Bool.or(U32.is_eq(op, 3), U32.is_eq(op, 4))); +dreg = x64_gpr_or(dloc, 0); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.or(imm_alu, imm_sh), acc, a => x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), Bool.or(U32.is_le(op, 1), U32.is_eq(op, 8))), dreg, x64_emit(Bool.pick(X64Inst, imm_alu, XAluRI{op, dreg, c}, XShift{op, dreg, c, False{}}), x64_load_vreg(ctx, dreg, lhs, a)))), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(has_rc, Bool.and(U32.is_eq(op, 2), x64_is_mul_sr(c))), a, a1 => x64_emit_mul_sr(ctx, dst, lhs, dloc, c, a1), a1 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(is_dm, x64_is_pow2(c)), a1, a2 => x64_store_vreg(ctx, dst, dreg, x64_emit(Bool.pick(X64Inst, U32.is_eq(op, 3), XShift{9, dreg, U32.from_nat(U32.log2(c)), False{}}, XAluRI{5, dreg, U32.sub(c, 1)}), x64_load_vreg(ctx, dreg, lhs, a2))), a2 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(is_dm, U32.is_ge(c, 3)), a2, a3 => x64_emit_divmod_magic(U32.is_eq(op, 4), ctx, dst, lhs, c, x64_magic(c), a3), a3 => +dg_ok = Bool.and(x64_is_o2(ctx), x64_is_gpr(dloc)); +ne_dr = U32.is_ne(dloc, rloc); x64_ibin_reg_go(Bool.and(Bool.and(dg_ok, ne_dr), Bool.or(x64_is_simple_alu(op), U32.is_eq(op, 2))), Bool.and(Bool.and(dg_ok, Bool.and(x64_is_gpr(rloc), Bool.not(ne_dr))), Bool.and(x64_is_comm_alu(op), x64_is_gpr(lloc))), ctx, dst, op, lhs, rhs, dloc, lloc, rloc, lbl, a3))))))
def x64_emit_bin_go(+ctx: X64Ctx, is_flt: Bool, skip_st: Bool, consts: RaVec<U32>, +fconsts: RaVec<U32>, xm0: U32, +dst: U32, +op: U32, +lhs: U32, +rhs: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+dloc = x64_vreg_loc(ctx, dst); +lloc = x64_vreg_loc(ctx, lhs); +rloc = x64_vreg_loc(ctx, rhs); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_flt, acc, a => +la = Bool.pick(U32, Bool.and(x64_is_o2(ctx), U32.is_eq(op, 13)), ra_vec_get(U32, x64_ctx_vd(ctx), 0, lhs, fconsts), 0); +rb = Bool.pick(U32, U32.is_ne(la, 0), ra_vec_get(U32, x64_ctx_vd(ctx), 0, rhs, fconsts), 0); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(rb, 0), a, a2 => x64_emit_const(ctx, dst, opt_fdiv_bits(U32.sub(la, 1), U32.sub(rb, 1)), a2), a2 => x64_emit_fbin_go(x64_is_xmm(dloc), skip_st, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, xm0, a2)), a => +rc = x64_const_val(ctx, consts, rhs); x64_emit_ibin_imm(ctx, dst, op, lhs, rhs, dloc, lloc, rloc, U32.is_ne(rc, 0), U32.sub(rc, 1), lbl, a)))
def x64_f2u_clamp(acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(XCmov{5, 0, 2}, x64_emit(XShift{9, 1, 32, False{}}, x64_emit(XMovRR{1, 0}, x64_emit(XMovRI32{2, 0}, acc))))
def x64_emit_un(+ctx: X64Ctx, consts: RaVec<U32>, +dst: U32, uop: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match uop:
    case 0: (+dreg = x64_vreg_gpr(ctx, dst); x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(XMovRR{dreg, 1}, x64_emit(XAluRR{1, 1, dreg}, x64_emit(XMovRI32{1, 0}, x64_load_vreg(ctx, dreg, src, acc)))))))
    case 1: (+dreg = x64_vreg_gpr(ctx, dst); x64_store_vreg(ctx, dst, dreg, x64_mask32(dreg, x64_emit(XAluRI{7, dreg, 4294967295}, x64_load_vreg(ctx, dreg, src, acc)))))
    case 2: x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{7, 0, 1}, x64_emit(XMovRI32{1, 2147483648}, x64_load_vreg(ctx, 0, src, acc))))
    case 3: (+dloc = x64_vreg_loc(ctx, dst); +sloc = x64_vreg_loc(ctx, src); +dir = Bool.and(x64_is_xmm(dloc), x64_is_xmm(sloc)); x64_when(Bool.not(dir), x64_emit(XXmmRR{4, Bool.pick(U32, dir, U32.sub(dloc, 20), 0), Bool.pick(U32, dir, U32.sub(sloc, 20), 0)}, x64_opt_load_xmm(dir, ctx, 0, src, acc)), a => x64_store_xmm(ctx, dst, 0, a)))
    case 4: (+rc = x64_const_val(ctx, consts, src); +c = U32.sub(rc, 1); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(U32.is_ne(rc, 0), U32.is_le(c, 65535)), acc, a => x64_emit_const(ctx, dst, Bool.pick(U32, U32.is_zero(c), 0, opt_fdiv_bits(c, 1)), a), a => +dloc = x64_vreg_loc(ctx, dst); +sloc = x64_vreg_loc(ctx, src); +dxm = x64_is_xmm(dloc); +sgpr = x64_is_gpr(sloc); x64_when(Bool.not(dxm), x64_emit(XCvt{0, Bool.pick(U32, dxm, U32.sub(dloc, 20), 0), Bool.pick(U32, sgpr, sloc, 0)}, x64_opt_load_vreg(sgpr, ctx, 0, src, a)), a1 => x64_store_xmm(ctx, dst, 0, a1))))
    case _: (+sloc = x64_vreg_loc(ctx, src); +sxm = x64_is_xmm(sloc); x64_store_vreg(ctx, dst, 0, x64_f2u_clamp(x64_emit(XCvt{1, 0, Bool.pick(U32, sxm, U32.sub(sloc, 20), 0)}, x64_opt_load_xmm(sxm, ctx, 0, src, acc)))))
def x64_emit_fcmp(+fop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fop:
    case 0: x64_emit(XAluRR{5, 0, 1}, x64_emit(XSetcc{11, 1}, x64_emit(XSetcc{4, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc)))))
    case 1: x64_emit(XAluRR{6, 0, 1}, x64_emit(XSetcc{10, 1}, x64_emit(XSetcc{5, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc)))))
    case _: x64_emit(XSetcc{Bool.pick(U32, Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 4)), 7, 3), 0}, x64_emit(XMovRI32{0, 0}, acc))
def x64_emit_cmp_flags_go(has_c: Bool, dir: Bool, +ctx: X64Ctx, +cop: U32, lhs: U32, rhs: U32, +lloc: U32, rloc: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_c dir:
    case True{} _: (+lreg = x64_gpr_or(lloc, 0); x64_emit(Bool.pick(X64Inst, Bool.and(U32.is_zero(c), U32.is_le(cop, 1)), XTestRR{lreg, lreg}, XCmpRI{lreg, c}), x64_load_vreg(ctx, lreg, lhs, acc)))
    case False{} True{}: x64_emit(XCmpRR{lloc, rloc}, acc)
    case False{} False{}: x64_emit(XCmpRR{0, 1}, x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc)))
def x64_emit_cmp_flags(+ctx: X64Ctx, consts: RaVec<U32>, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+lloc = x64_vreg_loc(ctx, lhs); +rloc = x64_vreg_loc(ctx, rhs); +rc = x64_const_val(ctx, consts, rhs); x64_emit_cmp_flags_go(U32.is_ne(rc, 0), Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc)), ctx, cop, lhs, rhs, lloc, rloc, U32.sub(rc, 1), acc))
def x64_emit_fcmp_ucomiss(+ctx: X64Ctx, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+lloc = x64_vreg_loc(ctx, lhs); +rloc = x64_vreg_loc(ctx, rhs); +fop = U32.sub(cop, 6); +swap = Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 3)); +lxm = x64_is_xmm(lloc); +rxm = x64_is_xmm(rloc); +lx = Bool.pick(U32, lxm, U32.sub(lloc, 20), 0); +rx = Bool.pick(U32, rxm, U32.sub(rloc, 20), 1); x64_emit(XXmmRR{5, Bool.pick(U32, swap, rx, lx), Bool.pick(U32, swap, lx, rx)}, x64_opt_load_xmm(rxm, ctx, 1, rhs, x64_opt_load_xmm(lxm, ctx, 0, lhs, acc))))
def x64_emit_cmp_go(+ctx: X64Ctx, consts: RaVec<U32>, is_flt: Bool, +dst: U32, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_flt, acc, a => x64_store_vreg(ctx, dst, 0, x64_emit_fcmp(U32.sub(cop, 6), x64_emit_fcmp_ucomiss(ctx, cop, lhs, rhs, a))), a => +lloc = x64_vreg_loc(ctx, lhs); +rloc = x64_vreg_loc(ctx, rhs); +rc = x64_const_val(ctx, consts, rhs); +has_c = U32.is_ne(rc, 0); +dir = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc))); +dreg = Bool.pick(U32, Bool.or(has_c, dir), x64_vreg_gpr(ctx, dst), 0); x64_store_vreg(ctx, dst, dreg, x64_emit(XSetcc{x64_cmp_cc(cop), dreg}, x64_emit(XMovRI32{dreg, 0}, x64_emit_cmp_flags_go(has_c, dir, ctx, cop, lhs, rhs, lloc, rloc, U32.sub(rc, 1), a)))))
def x64_cls_fit(+cnt: U32) -> U32: Bool.pick(U32, U32.is_le(cnt, 1), 0, Bool.pick(U32, U32.is_eq(cnt, 2), 1, Bool.pick(U32, U32.is_le(cnt, 4), 2, 3)))
def x64_cls_step(+cls: U32) -> U32: Bool.pick(U32, U32.is_zero(cls), 1, Bool.pick(U32, U32.is_eq(cls, 1), 2, Bool.pick(U32, U32.is_eq(cls, 2), 4, 8)))
def x64_is_cs_reg(+r: U32) -> Bool: Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11))
def x64_inval_ha(h: X64Ha, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ha{ha, +dp, mk, _} = h
  x64_emit_if(Bool.and(U32.is_ne(ha, 0), Bool.or(x64_is_cs_reg(dp), x64_is_cs_reg(mk))), XAluRR{7, dp, dp}, acc)
def x64_inval_cs_hoist(ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, h0, h1, h2, _, False{}, _, _, _, _, _, _}}: x64_inval_ha(h2, x64_inval_ha(h1, x64_inval_ha(h0, acc)))
    case _: acc
def x64_push_pop_list(+is_push: Bool, regs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl(~U32, ~Bool, ~List<&2, X64Inst>, ~(ip => r0 => a => (+r = r0; Con{Bool.pick(X64Inst, ip, XPush{r}, XPop{r}), a})), is_push, regs, acc)
def x64_xmm_save_loop(+is_push: Bool, n: Nat, +xr: U32, +off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: x64_xmm_save_loop(is_push, p, U32.add(xr, 1), U32.add(off, 4), Con{Bool.pick(X64Inst, is_push, XXmmStore{4, off, U32.add(32, xr)}, XXmmLoad{xr, 4, off}), acc})
def x64_cs4_gpr(+is_push: Bool, gm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match gm:
    case 0: acc
    case 1: x64_push_pop_list(is_push, Bool.pick(List<&2, U32>, is_push, [8, 9], [9, 8]), acc)
    case 2: x64_push_pop_list(is_push, Bool.pick(List<&2, U32>, is_push, [10, 11], [11, 10]), acc)
    case _: x64_push_pop_list(is_push, Bool.pick(List<&2, U32>, is_push, [8, 9, 10, 11], [11, 10, 9, 8]), acc)
def x64_cs4_io(+is_push: Bool, +csm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+gm = U32.and(csm, 3); +hx = U32.is_ne(U32.and(csm, 4), 0); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_push, acc, a => x64_when(hx, x64_cs4_gpr(True{}, gm, a), a0 => x64_xmm_save_loop(True{}, 14n, 2, 0, x64_emit(XSubRsp{64}, a0))), a => x64_cs4_gpr(False{}, gm, x64_when(hx, a, a0 => x64_emit(XAddRsp{64}, x64_xmm_save_loop(False{}, 14n, 2, 0, a0))))))
def x64_mem_idx_ptr(+ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ctx{_, _, _, _, _, +mr, _, _, _, _, _} = ctx
  x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(mr, 0), acc, a => x64_emit(XAluRR{0, 7, mr}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, a))), a => x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, x64_load_mem(ctx, 1, a)))))
def x64_chk_cid_hot(+reg: U32, +cid: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_emit(XJcc{4, lbl}, x64_emit(XAluRI{5, reg, 8}, x64_emit(XLoad{reg, reg, 88}, x64_emit(XLeaRip{reg, "p111_program"}, acc)))); x64_emit(XJcc{5, lbl}, x64_emit(XAluRI{5, reg, 255}, x64_emit(XLoad{reg, reg, cid}, x64_emit(XLeaRip{reg, "p111_cid_hot"}, a1)))))
def x64_fl_pop(+ctx: X64Ctx, +coff: U32, +loff: U32, step: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_emit(XLoad{2, 6, coff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, acc))))); a4 = x64_emit(XStore{6, coff, 1}, x64_emit(XLoad{1, 7, 0}, x64_mem_idx_ptr(ctx, a1))); x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{1, 1, step}, x64_emit(XLoad{1, 6, loff}, a4))))
def x64_seal_pack_val(+vreg: U32, mv0: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_emit(XStore{6, 256, 1}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XLoad{1, 6, 256}, x64_emit(XStore{6, 0, 1}, x64_emit(XLoad{1, 7, 0}, acc))))); a2 = x64_emit_if(mv0, XMovRR{0, vreg}, x64_emit(XStore{7, 0, 1}, x64_emit(XAluRI{6, 1, 1}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, vreg}, a1))))); x64_emit(XAluRR{6, 0, 1}, x64_emit(XMovRI64{1, 0, 2147483648}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XShift{8, 0, 40, False{}}, x64_emit(XShift{9, 0, 40, False{}}, a2))))))
def x64_rt_scratch_call(+ctx: X64Ctx, is_pair: Bool, sym: String, code: U32, +args: List<&2, U32>, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+csm = x64_ctx_csm(ctx); a1 = x64_load_state(ctx, 7, x64_scratch_io(True{}, ctx, args, 0, acc)); a2 = x64_cs4_io(True{}, csm, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, code}, a1)))); a3 = x64_when(is_pair, a2, a => x64_emit(XMovRI32{9, 2}, x64_emit(XMovRR{8, 2}, a))); x64_cs4_io(False{}, csm, x64_emit(XCallSym{sym}, a3)))
def x64_cold_rt_call(+ctx: X64Ctx, sym: String, +l_call: U32, +l_done: U32, pre: List<&2, X64Inst> -> List<&2, X64Inst>, post: List<&2, X64Inst> -> List<&2, X64Inst>, cold: List<&2, X64Inst>) -> List<&2, X64Inst>: (+csm = x64_ctx_csm(ctx); x64_emit(XJmp{l_done}, post(x64_cs4_io(False{}, csm, x64_emit(XCallSym{sym}, x64_cs4_io(True{}, csm, x64_load_state(ctx, 7, pre(x64_emit(XLabel{l_call}, cold)))))))))
def x64_ctor_slow(+ctx: X64Ctx, cid: U32, fields: List<&2, U32>, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_inval_cs_hoist(ctx, x64_rt_scratch_call(ctx, False{}, "p111_rt_ctor", cid, fields, cnt, acc))
type X64Acc is Data:
  X64Acc{insts: List<&2, X64Inst>, next_lbl: U32, cold: List<&2, X64Inst>}
def x64_ctor_store_raw(+ctx: X64Ctx, fields: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fields:
    case Nil{}: acc
    case Con{+f, t}: (+floc = x64_vreg_loc(ctx, f); +off = U32.mul(idx, 8); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_gpr(floc), acc, a => x64_emit(XStore{7, off, floc}, a), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(floc), a, a0 => x64_emit(XXmmStore{7, off, U32.sub(floc, 20)}, a0), a0 => x64_emit(XStore{7, off, 0}, x64_load_vreg(ctx, 0, f, a0)))); x64_ctor_store_raw(ctx, t, U32.add(idx, 1), a1))
def x64_ctor_store_fields(+ctx: X64Ctx, fields: List<&2, U32>, +idx: U32, st: X64Acc) -> X64Acc:
  match fields st:
    case Nil{} _: st
    case Con{+f, t} X64Acc{acc, +lbl, +cold}: (+floc = x64_vreg_loc(ctx, f); +off = U32.mul(idx, 8); x64_ctor_store_fields(ctx, t, U32.add(idx, 1), x64_if1(List<&2, X64Inst>, X64Acc, x64_is_xmm(floc), acc, a => X64Acc{x64_emit(XXmmStore{7, off, U32.sub(floc, 20)}, a), lbl, cold}, a => a1 = x64_emit(XJcc{5, lbl}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, x64_load_vreg(ctx, 0, f, a))))); a2 = x64_emit(XLoad{2, 6, 0}, x64_emit(XStore{4, 8, 7}, x64_emit(XStore{4, 0, 2}, a1))); a3 = x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, x64_load_mem(ctx, 1, a2)))); X64Acc{x64_emit(XStore{7, off, 0}, x64_emit(XLabel{lbl}, x64_emit(XLoad{2, 4, 0}, x64_emit(XLoad{7, 4, 8}, x64_seal_pack_val(0, False{}, a3))))), U32.add(lbl, 1), cold})))
def x64_un_acc(-R: Type, st: X64Acc, k: List<&2, X64Inst> -> U32 -> List<&2, X64Inst> -> R) -> R:
  X64Acc{a, l, c} = st
  k(a, l, c)
def x64_ctor_body_fin(+ctx: X64Ctx, dst: U32, cid: U32, fields: List<&2, U32>, cnt: U32, lbl: U32, lbl_done: U32, lbl_pack: U32, a5d: List<&2, X64Inst>, sub: X64Acc) -> X64Acc:
  X64Acc{c6, nl, _} = sub
  X64Acc{x64_store_vreg(ctx, dst, 0, a5d), nl, x64_emit(XJmp{lbl_done}, x64_ctor_slow(ctx, cid, fields, cnt, x64_emit(XLabel{lbl}, x64_emit(XJmp{lbl_pack}, c6))))}
def x64_ctor_body(+is_r: Bool, all_sc: Bool, +ctx: X64Ctx, dst: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +coff: U32, +loff: U32, step: U32, +hi: U32, +lbl: U32, a5: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match all_sc:
    case True{}:
      +lbl_done = U32.add(lbl, 1)
      a6 = x64_store_vreg(ctx, dst, 0, x64_emit(XLabel{lbl_done}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, hi}, x64_ctor_store_raw(ctx, fields, 0, a5)))))
      X64Acc{a6, U32.add(lbl, 2), x64_emit(XJmp{lbl_done}, x64_ctor_slow(ctx, cid, fields, cnt, x64_emit(XLabel{lbl}, cold)))}
    case False{}: (+lbl_done = U32.add(lbl, 1); +lbl_seal = U32.add(lbl, 2); +lbl_pack = U32.add(lbl, 3); +lbl_sok = U32.add(lbl, 4); a5d = x64_emit(XLabel{lbl_done}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, hi}, x64_emit(XLabel{lbl_pack}, x64_ctor_store_raw(ctx, fields, 0, x64_chk_cid_hot(1, cid, lbl_seal, a5)))))); cs0 = x64_emit(XJcc{7, lbl_sok}, x64_emit(XCmpRI{0, cnt}, x64_emit(XLoad{0, 6, 256}, x64_when(is_r, x64_emit(XLabel{lbl_seal}, cold), a => x64_emit(XLoad{6, 0, 8}, x64_load_state(ctx, 0, a)))))); cs1 = x64_emit(XLabel{lbl_sok}, x64_emit(XJmp{lbl}, x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{0, 1, step}, x64_emit(XLoad{1, 6, loff}, x64_emit(XStore{6, coff, 2}, x64_when(is_r, cs0, a => x64_emit(XStore{7, 0, 1}, x64_emit(XLoad{1, 6, coff}, a))))))))); x64_ctor_body_fin(ctx, dst, cid, fields, cnt, lbl, lbl_done, lbl_pack, a5d, x64_ctor_store_fields(ctx, fields, 0, X64Acc{cs1, U32.add(lbl, 5), Nil{}})))
def x64_emit_ctor_o2(is_o2: Bool, is_z: Bool, is_sm: Bool, +ctx: X64Ctx, +dst: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_z is_sm:
    case True{} True{} _: (+dreg = x64_vreg_gpr(ctx, dst); X64Acc{x64_store_vreg(ctx, dst, dreg, x64_emit(XMovRI64{dreg, 0, U32.or(16777216, U32.shln(cid, 8n))}, acc)), lbl, cold})
    case True{} False{} True{}: (+cls = x64_cls_fit(cnt); +coff = U32.mul(cls, 8); +loff = U32.add(256, coff); +step = x64_cls_step(cls); x64_ctor_body(False{}, x64_all_scalar(ctx, fields), ctx, dst, cid, fields, cnt, coff, loff, step, U32.or(33554432, U32.shln(cid, 8n)), lbl, x64_fl_pop(ctx, coff, loff, step, lbl, acc), cold))
    case _ _ _: X64Acc{x64_store_vreg(ctx, dst, 0, x64_ctor_slow(ctx, cid, fields, cnt, acc)), lbl, cold}
def x64_emit_pak1(+ctx: X64Ctx, +dst: U32, +cid: U32, f0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+dreg = x64_vreg_gpr(ctx, dst); x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRR{6, dreg, 1}, x64_emit(XMovRI64{1, 0, U32.or(16777216, U32.shln(cid, 8n))}, x64_mask32(dreg, x64_load_vreg(ctx, dreg, f0, acc))))))
def x64_cold_join(hot: List<&2, X64Inst>, l_done: U32, sub: X64Acc) -> X64Acc:
  X64Acc{ch, nl, cc} = sub
  X64Acc{hot, nl, b5k_list_app(X64Inst, cc, x64_emit(XJmp{l_done}, ch))}
def x64_emit_pak1_dyn(+ctx: X64Ctx, +dst: U32, +cid: U32, +f0: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc: (+dreg = x64_vreg_gpr(ctx, dst); +l_done = U32.add(lbl, 1); a1 = x64_emit(XJcc{5, lbl}, x64_emit(XShift{9, 1, 32, False{}}, x64_emit(XMovRR{1, dreg}, x64_load_vreg(ctx, dreg, f0, acc)))); a2 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRR{6, dreg, 1}, x64_emit(XMovRI64{1, 0, U32.or(16777216, U32.shln(cid, 8n))}, a1)))); x64_cold_join(a2, l_done, x64_emit_ctor_o2(True{}, False{}, True{}, ctx, dst, cid, Con{f0, Nil{}}, 1, U32.add(lbl, 2), x64_emit(XLabel{lbl}, cold), Nil{})))
def x64_emit_ctor(+ctx: X64Ctx, +dst: U32, +cid: U32, +fields: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match fields:
    case Con{+f0, Nil{}}: x64_if1(List<&2, X64Inst>, X64Acc, Bool.and(x64_is_o2(ctx), U32.is_ge(cid, 39)), acc, a => x64_if1(List<&2, X64Inst>, X64Acc, x64_is_num_scalar(ctx, f0), a, a1 => X64Acc{x64_emit_pak1(ctx, dst, cid, f0, a1), lbl, cold}, a1 => x64_if1(List<&2, X64Inst>, X64Acc, x64_is_inline_rt(ctx), a1, a2 => x64_emit_pak1_dyn(ctx, dst, cid, f0, lbl, a2, cold), a2 => X64Acc{x64_store_vreg(ctx, dst, 0, x64_ctor_slow(ctx, cid, Con{f0, Nil{}}, 1, a2)), lbl, cold})), a => x64_emit_ctor_o2(x64_is_inline_rt(ctx), False{}, True{}, ctx, dst, cid, Con{f0, Nil{}}, 1, lbl, a, cold))
    case Nil{}: x64_emit_ctor_o2(x64_is_o2(ctx), True{}, True{}, ctx, dst, cid, Nil{}, 0, lbl, acc, cold)
    case fs: (+cnt = b5k_u32_list_len(fs); x64_emit_ctor_o2(x64_is_inline_rt(ctx), False{}, U32.is_le(cnt, 8), ctx, dst, cid, fs, cnt, lbl, acc, cold))
def x64_reuse_body(+all_sc: Bool, +ctx: X64Ctx, dst: U32, +cid: U32, +fs: List<&2, U32>, +cnt: U32, +lbl: U32, a: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc: (+cls = x64_cls_fit(cnt); +coff = U32.mul(cls, 8); x64_ctor_body(True{}, all_sc, ctx, dst, cid, fs, cnt, coff, U32.add(256, coff), x64_cls_step(cls), U32.or(33554432, U32.shln(cid, 8n)), lbl, x64_mem_idx_ptr(ctx, a), cold))
def x64_emit_reuse_go(use_r: Bool, +ctx: X64Ctx, +dst: U32, +slot: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match use_r fields:
    case False{} fs: x64_emit_ctor(ctx, dst, cid, fs, lbl, acc, cold)
    case True{} Con{+f0, Nil{}}: x64_if1(List<&2, X64Inst>, X64Acc, U32.is_ge(cid, 39), x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc)), a => +l_done = U32.add(lbl, 1); +a1 = x64_emit(XJcc{5, lbl}, a); +pak = x64_is_num_scalar(ctx, f0); x64_un_acc(X64Acc, x64_if1(List<&2, X64Inst>, X64Acc, pak, a1, a_ => X64Acc{x64_emit_pak1(ctx, dst, cid, f0, a_), U32.add(lbl, 2), cold}, a_ => x64_emit_pak1_dyn(ctx, dst, cid, f0, U32.add(lbl, 2), a_, cold)), ah => nl => ch => x64_cold_join(x64_emit(XLabel{l_done}, ah), l_done, x64_reuse_body(Bool.or(pak, x64_all_scalar(ctx, Con{f0, Nil{}})), ctx, dst, cid, Con{f0, Nil{}}, 1, nl, x64_emit(XLabel{lbl}, ch), Nil{}))), a => x64_reuse_body(x64_all_scalar(ctx, Con{f0, Nil{}}), ctx, dst, cid, Con{f0, Nil{}}, 1, lbl, x64_emit(XJcc{4, lbl}, a), cold))
    case True{} +fs: x64_reuse_body(x64_all_scalar(ctx, fs), ctx, dst, cid, fs, cnt, lbl, x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc))), cold)
def x64_emit_reuse(+ctx: X64Ctx, reuse: RaVec<Bool>, +dst: U32, +slot: U32, +cid: U32, +fields: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc: (+cnt = b5k_u32_list_len(fields); x64_emit_reuse_go(Bool.and(Bool.and(x64_is_inline_rt(ctx), Bool.and(U32.is_gt(cnt, 0), U32.is_le(cnt, 8))), ra_vec_get(Bool, x64_ctx_vd(ctx), False{}, slot, reuse)), ctx, dst, slot, cid, fields, cnt, lbl, acc, cold))
def x64_take_load_fields(+ctx: X64Ctx, dsts: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Nil{}: acc
    case Con{+d, t}: (+dloc = x64_vreg_loc(ctx, d); +off = U32.mul(idx, 8); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_gpr(dloc), acc, a => x64_emit(XLoad{dloc, 7, off}, a), a => x64_store_vreg(ctx, d, 0, x64_emit(XLoad{0, 7, off}, a))); x64_take_load_fields(ctx, t, U32.add(idx, 1), a1))
def x64_take_slow(+ctx: X64Ctx, dsts: List<&2, U32>, src: U32, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+csm = x64_ctx_csm(ctx); a2 = x64_cs4_io(True{}, csm, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))))); x64_scratch_io(False{}, ctx, dsts, 0, x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_take"}, a2))))
def x64_take_sh_loop(+is_chk: Bool, n: Nat, +idx: U32, +lbl_slow: U32, +lbase: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: (+lok = U32.add(lbase, idx); a0 = x64_emit(XLoad{0, 7, U32.mul(idx, 8)}, acc); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_chk, a0, a => x64_emit(XJcc{9, lbl_slow}, x64_emit(XTestRR{0, 0}, x64_emit(XJcc{4, lok}, x64_emit(XShift{9, 2, 57, False{}}, x64_emit(XMovRR{2, 0}, a))))), a => x64_emit(XJcc{9, lok}, x64_emit(XTestRR{0, 0}, a))); a2 = x64_emit(XLoad{2, 0, 0}, x64_emit(XAluRR{0, 0, 6}, x64_emit(XShift{9, 0, 21, False{}}, x64_emit(XShift{8, 0, 24, False{}}, a1)))); a3 = x64_emit(XLabel{lok}, x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_chk, a2, a => x64_emit(XJcc{3, lbl_slow}, x64_emit(XCmpRI{2, 16777200}, x64_emit(XAluRI{5, 2, 16777215}, a))), a => x64_emit(XStore{0, 0, 2}, x64_emit(XAluRI{0, 2, 1}, a)))); x64_take_sh_loop(is_chk, p, U32.add(idx, 1), lbl_slow, lbase, a3))
def x64_take_clr_tok(is_r: Bool, ctx: X64Ctx, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(is_r, acc, a => x64_store_vreg(ctx, src, 0, x64_emit(XAluRR{7, 0, 0}, a)))
def x64_emit_take_heap(+is_r: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _} = ctx
  +cls = x64_cls_fit(cnt)
  +coff = U32.mul(cls, 8)
  +loff = U32.add(256, coff)
  +lbl_done = U32.add(lbl, 1)
  +lbl_sh = U32.add(lbl, 2)
  +lbl_sh1 = U32.add(lbl, 3)
  +lbl_free = U32.add(lbl, 4)
  +lbl_st = U32.add(lbl, 5)
  a2 = x64_emit(XJcc{5, lbl_sh}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, x64_load_vreg(ctx, 2, src, acc)))))
  a3 = x64_emit(XJcc{2, lbl_st}, x64_emit(XCmpRR{2, 0}, x64_emit(XMovRI32{0, ho}, x64_mask40(2, a2))))
  a4 = x64_when(Bool.not(is_r), a3, a => x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{1, 32760}, x64_emit(XLoad{1, 6, loff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, a))))))
  a6 = x64_take_load_fields(ctx, dsts, 0, x64_mem_idx_ptr(ctx, x64_emit(XLabel{lbl_free}, a4)))
  a8 = x64_emit(XLabel{lbl_done}, x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_r, a6, a => x64_store_vreg(ctx, src, 2, a), a => x64_emit(XStore{6, coff, 2}, x64_emit(XStore{7, 0, 1}, x64_emit(XLoad{1, 6, coff}, x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{0, 1, x64_cls_step(cls)}, x64_emit(XLoad{1, 6, loff}, a))))))))
  b0 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_load_fields(ctx, dsts, 0, x64_mem_idx_ptr(ctx, x64_emit(XLabel{lbl_st}, cold)))))
  b1 = x64_emit(XJcc{5, lbl}, x64_emit(XCmpRI{1, 130}, x64_emit(XLabel{lbl_sh}, b0)))
  b2 = x64_emit(XAluRR{0, 1, 7}, x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XMovRR{1, 2}, x64_load_mem(ctx, 7, x64_mask40(2, b1)))))
  b3 = x64_emit(XJcc{2, lbl}, x64_emit(XJcc{4, lbl_sh1}, x64_emit(XCmpRI{6, 1}, x64_emit(XAluRI{5, 6, 16777215}, x64_emit(XMovRR{6, 0}, x64_emit(XLoad{0, 1, 0}, b2))))))
  b4 = x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XMovRR{6, 7}, b3))))
  b5 = x64_take_sh_loop(True{}, U32.to_nat(cnt), 0, lbl, U32.add(lbl, 6), b4)
  b6 = x64_take_sh_loop(False{}, U32.to_nat(cnt), 0, 0, U32.add(U32.add(lbl, 6), cnt), x64_emit(XStore{1, 0, 0}, x64_emit(XAluRI{1, 0, 1}, x64_emit(XLoad{0, 1, 0}, b5))))
  b7 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_load_fields(ctx, dsts, 0, b6)))
  c1 = x64_emit(XJcc{2, lbl}, x64_emit(XCmpRR{0, 2}, x64_emit(XMovRI32{2, ho}, x64_emit(XStore{4, 0, 2}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLabel{lbl_sh1}, b7))))))
  c2 = x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{2, 32760}, x64_emit(XLoad{2, 6, loff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, c1)))))
  c3 = x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{2, 32760}, x64_emit(XLoad{2, 6, 256}, c2)))
  c4 = x64_emit(XStore{6, 0, 2}, x64_emit(XLoad{2, 4, 0}, x64_emit(XStore{1, 0, 2}, x64_emit(XLoad{2, 6, 0}, c3))))
  c5 = x64_emit(XJmp{lbl_free}, x64_emit(XMovRR{2, 0}, x64_emit(XStore{6, 256, 2}, x64_emit(XAluRI{0, 2, 1}, x64_emit(XLoad{2, 6, 256}, c4)))))
  c6 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_slow(ctx, dsts, src, cnt, x64_emit(XLabel{lbl}, c5))))
  X64Acc{a8, U32.add(U32.add(lbl, 6), U32.mul(cnt, 2)), c6}
def x64_bor_deref(+ctx: X64Ctx, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_emit(XJcc{9, lbl}, x64_emit(XTestRR{2, 2}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_load_mem(ctx, 1, x64_mask40(7, x64_emit(XMovRR{7, 2}, acc))))))); x64_emit(XLabel{lbl}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XShift{9, 7, 24, False{}}, x64_emit(XLoad{7, 7, 0}, a1))))))
def x64_emit_take_go(+is_o2: Bool, +is_r: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +lbl: U32, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match dsts:
    case Nil{}: low_if(X64Acc, is_o2, _ => X64Acc{acc, lbl, cold}, _ => X64Acc{x64_take_slow(ctx, Nil{}, src, 0, acc), lbl, cold})
    case Con{+d0, Nil{}}: (+is_bor = x64_is_bor(ctx, src); low_if(X64Acc, Bool.or(is_bor, x64_is_inline_take(ctx, 1)), _ => +l_done = U32.add(lbl, 1); a1 = x64_emit(XJcc{5, lbl}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, x64_load_vreg(ctx, 2, src, acc))))); +a2 = x64_emit(XLabel{l_done}, x64_take_clr_tok(Bool.and(Bool.not(is_bor), is_r), ctx, src, x64_store_vreg(ctx, d0, 2, x64_mask40(2, a1)))); x64_if1(List<&2, X64Inst>, X64Acc, is_bor, x64_emit(XLabel{lbl}, cold), c => X64Acc{a2, U32.add(lbl, 3), x64_emit(XJmp{l_done}, x64_take_load_fields(ctx, Con{d0, Nil{}}, 0, x64_bor_deref(ctx, U32.add(lbl, 2), c)))}, c => x64_cold_join(a2, l_done, x64_emit_take_heap(is_r, ctx, Con{d0, Nil{}}, src, 1, U32.add(lbl, 2), c, Nil{}))), _ => X64Acc{x64_take_slow(ctx, Con{d0, Nil{}}, src, 1, acc), lbl, cold}))
    case ds: (+cnt = b5k_u32_list_len(ds); +is_bor = Bool.and(x64_is_bor(ctx, src), Bool.and(U32.is_gt(cnt, 0), U32.is_le(cnt, 8))); low_if(X64Acc, Bool.or(is_bor, x64_is_inline_take(ctx, cnt)), _ => low_if(X64Acc, is_bor, _ => X64Acc{x64_take_load_fields(ctx, ds, 0, x64_bor_deref(ctx, lbl, x64_load_vreg(ctx, 2, src, acc))), U32.add(lbl, 1), cold}, _ => x64_emit_take_heap(is_r, ctx, ds, src, cnt, lbl, acc, cold)), _ => X64Acc{x64_take_slow(ctx, ds, src, cnt, acc), lbl, cold}))
def x64_emit_tag(is_o2: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_o2, acc, a => +dreg = x64_vreg_gpr(ctx, dst); x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRI{5, dreg, 65535}, x64_emit(XShift{9, dreg, 40, False{}}, x64_load_vreg(ctx, dreg, src, a)))), a => x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_tag"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, a)))))
def x64_rc_shared_go(+is_keep: Bool, +is_arr: Bool, +ctx: X64Ctx, +reg: U32, +l_done: U32, +l_call: U32, +l_uniq: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_emit(XJcc{9, l_uniq}, x64_emit(XTestRR{reg, reg}, x64_emit(XJcc{4, l_done}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, reg}, acc))))); a2 = x64_emit(XAluRR{0, 1, 7}, x64_load_mem(ctx, 7, x64_emit(XShift{9, 1, 21, False{}}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, reg}, a1))))); a3 = x64_emit(XJcc{Bool.pick(U32, is_keep, 3, 6), l_call}, x64_emit(XCmpRI{7, Bool.pick(U32, is_keep, 16777214, 1)}, x64_emit(XAluRI{5, 7, 16777215}, x64_emit(XMovRR{7, 2}, x64_emit(XLoad{2, 1, 0}, a2))))); x64_emit(Bool.pick(X64Inst, is_arr, XJmp{l_done}, XLabel{l_done}), x64_emit(XStore{1, 0, 2}, x64_emit(XAluRI{Bool.pick(U32, is_keep, 0, 1), 2, 1}, a3))))
def x64_rc_shared(is_keep: Bool, ctx: X64Ctx, reg: U32, l_done: U32, +l_call: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_rc_shared_go(is_keep, False{}, ctx, reg, l_done, l_call, l_call, acc)
def x64_rc_stat_chk(ctx: X64Ctx, reg: U32, l_done: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _} = ctx
  x64_emit(XJcc{2, l_done}, x64_emit(XCmpRR{1, 2}, x64_emit(XMovRI32{2, ho}, x64_mask40(1, x64_emit(XMovRR{1, reg}, acc)))))
def x64_emit_keep_rt(in_rt: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match in_rt:
    case False{}:
      +csm = x64_ctx_csm(ctx)
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_keep"}, x64_cs4_io(True{}, csm, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc)))))), lbl, cold}
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      +both_g = Bool.and(x64_is_gpr(dloc), x64_is_gpr(sloc))
      +l_call = U32.add(lbl, 1)
      +reg = Bool.pick(U32, both_g, dloc, 0)
      a0 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, both_g, acc, a => x64_emit_if(U32.is_ne(dloc, sloc), XMovRR{dloc, sloc}, a), a => x64_load_vreg(ctx, 0, src, a))
      a2 = x64_when(Bool.not(both_g), x64_rc_shared(True{}, ctx, reg, lbl, l_call, a0), a => x64_store_vreg(ctx, dst, 0, a))
      X64Acc{a2, U32.add(lbl, 2), x64_cold_rt_call(ctx, "p111_rt_keep", l_call, lbl, a => x64_emit(XMovRR{6, reg}, x64_rc_stat_chk(ctx, reg, lbl, a)), a => x64_emit_if(both_g, XMovRR{dloc, 0}, a), cold)}
def x64_emit_keep_sc(is_o2: Bool, is_sc: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_sc:
    case False{} _: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc)))), lbl, cold}
    case True{} True{}: X64Acc{x64_emit_copy(ctx, dst, src, acc), lbl, cold}
    case True{} False{}: x64_emit_keep_rt(x64_is_inline_rt(ctx), ctx, dst, src, lbl, acc, cold)
def x64_sink_arr_fast(+ctx: X64Ctx, +sloc: U32, +l_done: U32, +l_call: U32, +l_uniq: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _} = ctx
  a4 = x64_rc_shared_go(False{}, True{}, ctx, sloc, l_done, l_call, l_uniq, acc)
  u1 = x64_emit(XJcc{5, l_call}, x64_emit(XCmpRI{1, 6}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, sloc}, x64_emit(XLabel{l_uniq}, a4)))))
  u2 = x64_emit(XJcc{7, l_call}, x64_emit(XCmpRI{1, 11}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, sloc}, u1)))))
  u3 = x64_emit(XJcc{2, l_done}, x64_emit(XCmpRR{2, 0}, x64_emit(XMovRI32{0, ho}, x64_mask40(2, x64_emit(XMovRR{2, sloc}, u2)))))
  u4 = x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XMovRR{0, 1}, x64_emit(XLoad{7, 7, 8}, x64_load_state(ctx, 7, u3)))))
  u5 = x64_emit(XJcc{5, l_call}, x64_emit(XTestRR{6, 6}, x64_emit(XLoad{6, 0, 256}, u4)))
  u6 = x64_emit(XStore{0, 0, 2}, x64_emit(XLoad{6, 0, 0}, u5))
  u7 = x64_emit(XStore{7, 0, 6}, x64_emit(XAluRR{0, 7, 2}, x64_emit(XShift{8, 2, 3, False{}}, x64_load_mem(ctx, 7, u6))))
  x64_emit(XLabel{l_done}, x64_emit(XStore{0, 256, 7}, x64_emit(XShift{8, 7, 0, True{}}, x64_emit(XMovRI32{7, 1}, u7))))
def x64_emit_sink_rt(in_rt: Bool, +ctx: X64Ctx, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match in_rt:
    case False{}:
      +csm = x64_ctx_csm(ctx)
      X64Acc{x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_sink"}, x64_cs4_io(True{}, csm, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))))), lbl, cold}
    case True{}: (+sloc = x64_vreg_loc(ctx, src); +is_g = x64_is_gpr(sloc); +l_call = U32.add(lbl, 1); x64_if1(List<&2, X64Inst>, X64Acc, Bool.and(is_g, x64_hoist_is_sc(ctx, src)), acc, a => X64Acc{x64_sink_arr_fast(ctx, sloc, lbl, l_call, U32.add(lbl, 2), a), U32.add(lbl, 3), x64_cold_rt_call(ctx, "p111_rt_sink", l_call, lbl, c => x64_emit(XMovRR{6, sloc}, c), c => c, cold)}, a => +reg = Bool.pick(U32, is_g, sloc, 6); X64Acc{x64_rc_shared(False{}, ctx, reg, lbl, l_call, x64_opt_load_vreg(is_g, ctx, 6, src, a)), U32.add(lbl, 2), x64_cold_rt_call(ctx, "p111_rt_sink", l_call, lbl, c => x64_emit_if(is_g, XMovRR{6, sloc}, x64_rc_stat_chk(ctx, reg, lbl, c)), c => c, cold)}))
def x64_emit_sink_sc(is_o2: Bool, is_sc: Bool, +ctx: X64Ctx, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_sc:
    case False{} _: X64Acc{x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))), lbl, cold}
    case True{} True{}: X64Acc{acc, lbl, cold}
    case True{} False{}: x64_emit_sink_rt(x64_is_inline_rt(ctx), ctx, src, lbl, acc, cold)
def x64_store_head(ctx: X64Ctx, dsts: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Con{d, _}: x64_store_vreg(ctx, d, 0, acc)
    case Nil{}: acc
def x64_arr_slow_pair(+ctx: X64Ctx, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_scratch_io(False{}, ctx, dsts, 0, x64_rt_scratch_call(ctx, True{}, "p113_rt_array_pair", aop, args, b5k_u32_list_len(args), acc))
def x64_arr_slow_one(+ctx: X64Ctx, sym: String, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_store_head(ctx, dsts, x64_rt_scratch_call(ctx, False{}, sym, aop, args, b5k_u32_list_len(args), acc))
def x64_arr_slow_get_val(+ctx: X64Ctx, +dv: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+dloc = x64_vreg_loc(ctx, dv); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(dloc), x64_rt_scratch_call(ctx, True{}, "p113_rt_array_pair", 72, args, 2, acc), a => x64_emit(XXmmLoad{U32.sub(dloc, 20), 4, 8}, a), a => x64_store_vreg(ctx, dv, 0, x64_emit(XLoad{0, 4, 8}, a))))
def x64_arr_spec(is_take: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +kind: U32, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{v, _}: (+csm = x64_ctx_csm(ctx); a1 = x64_emit(XMovRI32{6, kind}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, v, acc))); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_take, a1, a => x64_scratch_io(False{}, ctx, dsts, 0, x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_special_take"}, x64_emit(XMovRI32{8, Bool.pick(U32, U32.is_eq(kind, 8), 1, 2)}, x64_cs4_io(True{}, csm, x64_emit(XMovRR{1, 4}, a)))))), a => x64_store_head(ctx, dsts, x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_special_test"}, x64_cs4_io(True{}, csm, a))))))
def x64_arr_slow(+ctx: X64Ctx, +aop: U32, +dsts: List<&2, U32>, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match aop dsts:
    case 78 Con{dv, _}: x64_arr_slow_get_val(ctx, dv, args, acc)
    case 78 Nil{}: acc
    case _ _: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(U32.is_ge(aop, 7), U32.is_le(aop, 9)), acc, a => x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, aop, args, a), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.or(U32.is_eq(aop, 71), Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 79))), a, a1 => x64_arr_slow_one(ctx, "p111_rt_op", dsts, Bool.pick(U32, U32.is_eq(aop, 79), 73, aop), args, a1), a1 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.or(Bool.and(U32.is_ge(aop, 208), U32.is_le(aop, 209)), Bool.and(U32.is_ge(aop, 218), U32.is_le(aop, 219))), a1, a2 => x64_arr_spec(U32.is_ge(aop, 210), ctx, dsts, U32.mod(aop, 10), args, a2), a2 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(U32.is_ge(aop, 100), U32.is_lt(aop, 200)), a2, a3 => x64_arr_slow_one(ctx, "p111_rt_op", dsts, U32.sub(aop, 100), args, a3), a3 => x64_arr_slow_pair(ctx, dsts, aop, args, a3)))))
def x64_arr_chk_tag(tag: U32, lbl_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(XJcc{5, lbl_slow}, x64_emit(XCmpRI{0, tag}, x64_emit(XAluRI{5, 0, 127}, x64_emit(XShift{9, 0, 56, False{}}, x64_emit(XMovRR{0, 6}, acc)))))
def x64_arr_sz_r0(acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, acc)))))
def x64_arr_unsh_ptr(ctx: X64Ctx, +l_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a3 = x64_emit(XJcc{9, l_unsh}, x64_emit(XTestRR{6, 6}, x64_mask40(0, x64_emit(XMovRR{0, 6}, x64_load_mem(ctx, 7, acc))))); x64_emit(XLabel{l_unsh}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 0, 0}, x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, a3))))))
def x64_arr_elem_ptr(+ctx: X64Ctx, a: U32, i: U32, +lbl_slow: U32, +lbl_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a2m = x64_emit(XAluRR{5, 2, 0}, x64_emit(XAluRI{1, 0, 1}, x64_arr_sz_r0(x64_arr_chk_tag(6, lbl_slow, x64_load_vreg(ctx, 2, i, x64_load_vreg(ctx, 6, a, acc)))))); x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XAluRR{0, 0, 2}, x64_arr_unsh_ptr(ctx, lbl_unsh, a2m)))))
def x64_opt_store_arr(+ctx: X64Ctx, +da: U32, a: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_when(U32.is_ne(x64_vreg_loc(ctx, da), x64_vreg_loc(ctx, a)), acc, a1 => x64_store_vreg(ctx, da, 6, a1))
def x64_arr_set_val(+is_sc: Bool, +ctx: X64Ctx, +v: U32, +l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+vloc = x64_vreg_loc(ctx, v); +is_g = x64_is_gpr(vloc); +vr = Bool.pick(U32, is_g, vloc, 0); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(is_sc, x64_is_xmm(vloc)), acc, a => x64_emit(XXmmStore{7, 0, U32.sub(vloc, 20)}, a), a => x64_emit(XStore{7, 0, vr}, x64_when(Bool.not(is_sc), x64_opt_load_vreg(is_g, ctx, 0, v, a), a0 => x64_emit(XJcc{4, l_slow}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, vr}, a0))))))))
def x64_hoist_store(+loc: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(Bool.pick(X64Inst, U32.is_lt(loc, 16), XMovRR{loc, src}, XStore{5, loc, src}), acc)
def x64_arr_elem_ptr_hoist(+ctx: X64Ctx, +dp: U32, +mk: U32, i: U32, +l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+dp_r = U32.is_lt(dp, 16); +dr = Bool.pick(U32, dp_r, dp, 2); a1 = x64_when(Bool.not(x64_no_dp_chk(ctx)), x64_emit_if(Bool.not(dp_r), XLoad{2, 5, dp}, x64_load_vreg(ctx, 7, i, acc)), a0 => x64_emit(XJcc{4, l_slow}, x64_emit(XTestRR{dr, dr}, a0))); a2 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_lt(mk, 16), a1, a => x64_emit(XAluRR{5, 7, mk}, a), a => x64_when(U32.is_ne(mk, 65535), a, a0 => x64_emit(XAluRR{5, 7, 0}, x64_emit(XLoad{0, 5, mk}, a0)))); x64_emit(XAluRR{0, 7, dr}, x64_emit(XShift{8, 7, 3, False{}}, a2)))
def x64_arr_elem_ptr_sel(hoist: Bool, +ctx: X64Ctx, dp: U32, mk: U32, a: U32, +i: U32, +l_slow: U32, l_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, hoist, acc, a0 => x64_arr_elem_ptr_hoist(ctx, dp, mk, i, l_slow, a0), a0 => x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, a0))
def x64_opt_store_arr_sel(hoist: Bool, +ctx: X64Ctx, +da: U32, +a: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, hoist, acc, a0 => x64_emit_copy(ctx, da, a, a0), a0 => x64_opt_store_arr(ctx, da, a, a0))
def x64_arr_cold_fin(fast: Bool, inval_ho: Bool, +ctx: X64Ctx, dp: U32, +lbl: U32, done_off: U32, lbl_inc: U32, hot: List<&2, X64Inst>, cold: List<&2, X64Inst>, slow_fn: List<&2, X64Inst> -> List<&2, X64Inst>) -> X64Acc:
  match fast:
    case True{}: X64Acc{hot, lbl, cold}
    case False{}:
      +l_done = U32.add(lbl, done_off)
      c0 = x64_inval_cs_hoist(ctx, x64_when(inval_ho, slow_fn(x64_emit(XLabel{lbl}, cold)), a => x64_hoist_store(dp, 0, x64_emit(XAluRR{7, 0, 0}, a))))
      X64Acc{x64_emit(XLabel{l_done}, hot), U32.add(lbl, lbl_inc), x64_emit(XJmp{l_done}, c0)}
def x64_arr_get_dreg(+ctx: X64Ctx, dv: U32, a: U32, i: U32, da: U32, has_da: Bool, ho: Bool) -> U32: (+dl = x64_vreg_loc(ctx, dv); ok1 = Bool.and(x64_is_gpr(dl), Bool.and(U32.is_ne(dl, 7), Bool.and(U32.is_ne(dl, 1), Bool.and(U32.is_ne(dl, 2), Bool.or(ho, U32.is_ne(dl, 6)))))); ok2 = Bool.and(U32.is_ne(dl, x64_vreg_loc(ctx, a)), Bool.and(U32.is_ne(dl, x64_vreg_loc(ctx, i)), Bool.or(Bool.not(has_da), U32.is_ne(dl, x64_vreg_loc(ctx, da))))); Bool.pick(U32, Bool.and(ok1, ok2), dl, 0))
def x64_arr_set_go(+skip_old: Bool, +ctx: X64Ctx, dst: U32, dsts: List<&2, U32>, args: List<&2, U32>, +a: U32, i: U32, +v: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc: (+dp = x64_hoist_slot(True{}, ctx, a); +ho = U32.is_ne(dp, 0); a1 = x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), acc); a2 = x64_when(Bool.not(skip_old), a1, a0 => x64_emit(XJcc{5, lbl}, x64_emit(XShift{9, 0, 57, False{}}, x64_emit(XLoad{0, 7, 0}, a0)))); a3 = x64_opt_store_arr_sel(ho, ctx, dst, a, x64_arr_set_val(Bool.or(skip_old, x64_is_scalar(ctx, v)), ctx, v, lbl, a2)); x64_arr_cold_fin(Bool.and(ho, Bool.and(skip_old, x64_no_dp_chk(ctx))), ho, ctx, dp, lbl, 2, 3, a3, cold, c => x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, c)))
def x64_fill_stores(+is_xmm: Bool, n: Nat, +off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: x64_fill_stores(is_xmm, p, U32.add(off, Bool.pick(U32, is_xmm, 16, 8)), Con{Bool.pick(X64Inst, is_xmm, XXmmStore{7, off, 16}, XStore{7, off, 0}), acc})
def x64_arr_new_fill(is_z: Bool, c: U32, nw: U32, +l_loop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_z c:
    case _ 0: x64_fill_stores(False{}, 1n, 0, acc)
    case _ 1: x64_fill_stores(False{}, 2n, 0, acc)
    case _ 2: x64_fill_stores(False{}, 4n, 0, acc)
    case True{} 3: x64_fill_stores(True{}, 4n, 0, x64_emit(XXmmRR{6, 0, 0}, acc))
    case True{} _: x64_emit(XJcc{5, l_loop}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XAluRI{0, 7, 128}, x64_fill_stores(True{}, 8n, 0, x64_emit(XLabel{l_loop}, x64_emit(XMovRI32{1, U32.shrn(nw, 4n)}, x64_emit(XXmmRR{6, 0, 0}, acc)))))))
    case False{} _: x64_emit(XJcc{5, l_loop}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XAluRI{0, 7, 64}, x64_fill_stores(False{}, 8n, 0, x64_emit(XLabel{l_loop}, x64_emit(XMovRI32{1, U32.shrn(nw, 3n)}, acc))))))
def x64_arr_get_go(+has_da: Bool, +ctx: X64Ctx, +da: U32, +dv: U32, +a: U32, +i: U32, +dsts: List<&2, U32>, +args: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc: (+dp = x64_hoist_slot(True{}, ctx, a); +ho = U32.is_ne(dp, 0); +dl = x64_vreg_loc(ctx, dv); +skip_ld = Bool.or(x64_is_num_use(ctx, dv), x64_hoist_is_sc(ctx, a)); +is_xm = Bool.and(x64_is_xmm(dl), skip_ld); +dr = x64_arr_get_dreg(ctx, dv, a, i, da, has_da, ho); +mk = x64_hoist_slot(False{}, ctx, a); +fast_base = Bool.and(ho, Bool.and(U32.is_lt(dp, 16), Bool.and(skip_ld, Bool.and(x64_no_dp_chk(ctx), U32.is_eq(mk, 65535))))); +fast_ld = Bool.and(fast_base, Bool.and(U32.is_ne(dr, 0), U32.is_ne(dr, dp))); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_xm, acc, a0 => +xr = U32.sub(dl, 20); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, fast_base, a0, a_ => x64_emit(XXmmLoad{xr, 7, 0}, x64_emit(XAluRR{0, 7, dp}, x64_emit(XShift{8, 7, 3, False{}}, x64_load_vreg(ctx, 7, i, a_)))), a_ => x64_emit(XXmmLoad{xr, 7, 0}, x64_arr_elem_ptr_sel(ho, ctx, dp, mk, a, i, lbl, U32.add(lbl, 1), a_))), a0 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, fast_ld, a0, a_ => x64_emit(XLoad{dr, dr, 0}, x64_emit(XAluRR{0, dr, dp}, x64_emit(XShift{8, dr, 3, False{}}, x64_load_vreg(ctx, dr, i, a_)))), a_ => x64_emit(XLoad{dr, 7, 0}, x64_arr_elem_ptr_sel(ho, ctx, dp, mk, a, i, lbl, U32.add(lbl, 1), a_)))); a2 = x64_when(Bool.not(skip_ld), a1, a0 => x64_rc_shared(True{}, ctx, dr, U32.add(lbl, 3), lbl, a0)); a2b = x64_when(has_da, a2, a0 => x64_opt_store_arr_sel(ho, ctx, da, a, a0)); a3 = x64_when(Bool.not(is_xm), a2b, a0 => x64_store_vreg(ctx, dv, dr, a0)); x64_arr_cold_fin(Bool.and(ho, Bool.and(skip_ld, x64_no_dp_chk(ctx))), False{}, ctx, 0, lbl, 2, 4, a3, cold, c => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, has_da, c, c0 => x64_arr_slow_pair(ctx, dsts, 72, args, c0), c0 => x64_arr_slow_get_val(ctx, dv, args, c0))))
def x64_arr_swap_go(+dead_old: Bool, +ctx: X64Ctx, da: U32, dold: U32, dsts: List<&2, U32>, args: List<&2, U32>, +a: U32, i: U32, +v: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc: (+dp = x64_hoist_slot(True{}, ctx, a); +ho = U32.is_ne(dp, 0); +vsc = Bool.or(x64_is_scalar(ctx, v), Bool.or(x64_is_num_use(ctx, v), x64_hoist_is_sc(ctx, a))); a1 = x64_emit_if(Bool.not(dead_old), XLoad{2, 7, 0}, x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), acc)); a2 = x64_opt_store_arr_sel(ho, ctx, da, a, x64_arr_set_val(vsc, ctx, v, lbl, a1)); a2c = x64_when(Bool.not(dead_old), a2, a0 => x64_store_vreg(ctx, dold, 2, a0)); x64_arr_cold_fin(Bool.and(ho, Bool.and(vsc, x64_no_dp_chk(ctx))), ho, ctx, dp, lbl, 2, 3, a2c, cold, c => x64_arr_slow_pair(ctx, dsts, 74, args, c)))
def x64_arr_rmw_ir_slow(+ctx: X64Ctx, da: U32, a: U32, +i: U32, cv: U32, +bop: U32, +rc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+csm = x64_ctx_csm(ctx); s1 = x64_emit(XLoad{0, 4, 8}, x64_arr_slow_pair(ctx, Nil{}, 72, [a, i], acc)); s1b = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(rc, 0), s1, s => x64_emit(XAluRI{bop, 0, U32.sub(rc, 1)}, s), s => x64_emit(XAluRR{bop, 0, 1}, x64_load_vreg(ctx, 1, cv, s))); s3 = x64_load_state(ctx, 7, x64_emit(XStore{4, 8, 1}, x64_load_vreg(ctx, 1, i, x64_emit(XStore{4, 16, 0}, x64_mask32(0, s1b))))); s4 = x64_cs4_io(True{}, csm, x64_emit(XMovRI32{1, 3}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, 73}, s3)))); x64_store_vreg(ctx, da, 0, x64_cs4_io(False{}, csm, x64_emit(XCallSym{"p111_rt_op"}, s4))))
def x64_arr_rmw_ir(+ctx: X64Ctx, +da: U32, +a: U32, +i: U32, +cv: U32, +bop: U32, +rc: U32, +dp: U32, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc: (+ho = U32.is_ne(dp, 0); x64_if1(List<&2, X64Inst>, X64Acc, U32.is_ne(rc, 0), acc, a0 => f1 = x64_emit(XLoad{0, 7, 0}, x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), a0)); f2 = x64_when(Bool.not(ho), f1, a1 => x64_emit(XJcc{5, lbl}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, 0}, a1)))); f3 = x64_opt_store_arr_sel(ho, ctx, da, a, x64_emit(XStore{7, 0, 0}, x64_mask32(0, x64_emit(XAluRI{bop, 0, U32.sub(rc, 1)}, f2)))); x64_arr_cold_fin(Bool.and(ho, x64_no_dp_chk(ctx)), ho, ctx, dp, lbl, 2, 3, f3, cold, c => x64_arr_rmw_ir_slow(ctx, da, a, i, cv, bop, rc, c)), a0 => X64Acc{x64_arr_rmw_ir_slow(ctx, da, a, i, cv, bop, rc, a0), lbl, cold}))
def x64_sa_idx_ptr(+ctx: X64Ctx, +buf: U32, +i: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+bl = x64_vreg_loc(ctx, buf); +mask = U32.sub(U32.shln(1, U32.to_nat(c)), 1); +a2 = x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XAluRI{5, 7, mask}, x64_load_vreg(ctx, 7, i, acc))); Bool.pick(List<&2, X64Inst>, x64_is_gpr(bl), x64_emit(XAluRR{0, 7, bl}, a2), x64_emit(XAluRR{0, 7, 2}, x64_load_vreg(ctx, 2, buf, a2))))
def x64_sa_new(+ctx: X64Ctx, consts: RaVec<U32>, aop: U32, buf: U32, +vv: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +c = U32.sub(aop, 1000)
  +nw = U32.shln(1, U32.to_nat(c))
  +is_z = U32.is_eq(x64_const_val(ctx, consts, vv), 1)
  +a1 = x64_load_vreg(ctx, 7, buf, x64_load_vreg(ctx, 0, vv, acc))
  +use_rtz = Bool.and(Bool.not(is_z), U32.is_ge(c, 3))
  a_rtz = x64_emit(XLabel{U32.add(lbl, 3)}, x64_arr_new_fill(False{}, c, nw, U32.add(lbl, 2), x64_emit(XLabel{U32.add(lbl, 1)}, x64_emit(XJmp{U32.add(lbl, 3)}, x64_arr_new_fill(True{}, c, nw, lbl, x64_emit(XJcc{5, U32.add(lbl, 1)}, x64_emit(XTestRR{0, 0}, a1)))))))
  X64Acc{Bool.pick(List<&2, X64Inst>, use_rtz, a_rtz, x64_arr_new_fill(is_z, c, nw, lbl, a1)), U32.add(lbl, 4), cold}
def x64_emit_sa_arrop(+ctx: X64Ctx, +consts: RaVec<U32>, +aop: U32, dsts: List<&2, U32>, args: List<&2, U32>, +lbl: U32, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match dsts args:
    case _ Con{buf, Con{+i, Con{+v, _}}}: low_if(X64Acc, U32.is_ge(aop, 1200), _ => +vl = x64_vreg_loc(ctx, v); +a1 = x64_sa_idx_ptr(ctx, buf, i, U32.sub(aop, 1200), acc); X64Acc{Bool.pick(List<&2, X64Inst>, x64_is_gpr(vl), x64_emit(XStore{7, 0, vl}, a1), x64_emit(XStore{7, 0, 0}, x64_load_vreg(ctx, 0, v, a1))), lbl, cold}, _ => X64Acc{acc, lbl, cold})
    case Con{+dv, _} Con{+buf, Con{+i, Nil{}}}: low_if(X64Acc, U32.is_ge(aop, 1100), _ => +dl = x64_vreg_loc(ctx, dv); +dr = Bool.pick(U32, Bool.and(x64_is_gpr(dl), U32.is_ne(dl, 7)), dl, 0); X64Acc{x64_store_vreg(ctx, dv, dr, x64_emit(XLoad{dr, 7, 0}, x64_sa_idx_ptr(ctx, buf, i, U32.sub(aop, 1100), acc))), lbl, cold}, _ => x64_sa_new(ctx, consts, aop, buf, i, lbl, acc, cold))
    case Nil{} Con{buf, Con{vv, Nil{}}}: low_if(X64Acc, U32.is_lt(aop, 1100), _ => x64_sa_new(ctx, consts, aop, buf, vv, lbl, acc, cold), _ => X64Acc{acc, lbl, cold})
    case _ _: X64Acc{acc, lbl, cold}
def x64_emit_arrop(is_o2: Bool, +ctx: X64Ctx, +consts: RaVec<U32>, uc: RaVec<U32>, +aop: U32, +dsts: List<&2, U32>, +args: List<&2, U32>, +lbl: U32, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 aop dsts args:
    case False{} _ _ _: X64Acc{x64_arr_slow(ctx, aop, dsts, args, acc), lbl, cold}
    case True{} 71 Con{+dst, _} Con{vd, Con{+vv, _}}: (+dc = x64_const_val(ctx, consts, vd); +c = U32.sub(dc, 1); low_if(X64Acc, Bool.and(U32.is_ne(dc, 0), U32.is_le(c, 12)), _ => +is_z = U32.is_eq(x64_const_val(ctx, consts, vv), 1); +coff = U32.mul(c, 8); +nw = U32.shln(1, U32.to_nat(c)); a1 = x64_when(Bool.not(Bool.or(is_z, x64_is_scalar(ctx, vv))), x64_load_vreg(ctx, 0, vv, acc), a => x64_emit(XJcc{5, lbl}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, 0}, a)))); a7 = x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, U32.or(100663296, U32.shln(c, 8n))}, x64_arr_new_fill(is_z, c, nw, U32.add(lbl, 2), x64_fl_pop(ctx, coff, U32.add(256, coff), nw, lbl, a1))))); x64_arr_cold_fin(False{}, False{}, ctx, 0, lbl, 1, 3, a7, cold, cl => x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, cl)), _ => X64Acc{x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, acc), lbl, cold}))
    case True{} 72 Con{da, Con{dv, _}} Con{a, Con{i, _}}: x64_arr_get_go(True{}, ctx, da, dv, a, i, dsts, args, lbl, acc, cold)
    case True{} 73 Con{dst, _} Con{+a, Con{i, Con{+v, _}}}: x64_arr_set_go(Bool.or(x64_hoist_is_sc(ctx, a), Bool.or(x64_is_num_scalar(ctx, v), x64_is_num_use(ctx, v))), ctx, dst, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 79 Con{dst, _} Con{+a, Con{i, Con{+v, _}}}: x64_arr_set_go(True{}, ctx, dst, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 74 Con{da, Con{+dold, _}} Con{+a, Con{i, Con{+v, _}}}: x64_arr_swap_go(U32.is_zero(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dold, uc)), ctx, da, dold, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 75 Con{da, Con{dsz, _}} Con{+a, _}: X64Acc{x64_store_vreg(ctx, dsz, 0, x64_opt_store_arr(ctx, da, a, x64_arr_sz_r0(x64_load_vreg(ctx, 6, a, acc)))), lbl, cold}
    case True{} 78 Con{dv, _} Con{a, Con{i, _}}: x64_arr_get_go(False{}, ctx, 0, dv, a, i, dsts, args, lbl, acc, cold)
    case True{} 80 Con{da, _} Con{+a, Con{i, Con{+cv, _}}}: x64_arr_rmw_ir(ctx, da, a, i, cv, 0, x64_const_val(ctx, consts, cv), x64_hoist_slot(True{}, ctx, a), lbl, acc, cold)
    case True{} 81 Con{da, _} Con{+a, Con{i, Con{+cv, _}}}: x64_arr_rmw_ir(ctx, da, a, i, cv, 1, x64_const_val(ctx, consts, cv), x64_hoist_slot(True{}, ctx, a), lbl, acc, cold)
    case _ _ _ _: Bool.pick(X64Acc, U32.is_ge(aop, 1000), x64_emit_sa_arrop(ctx, consts, aop, dsts, args, lbl, acc, cold), X64Acc{x64_arr_slow(ctx, aop, dsts, args, acc), lbl, cold})
def x64_clr_const(vd: Nat, v: U32, cs: RaVec<U32>) -> RaVec<U32>:
  match cs:
    case RVEmpty{}: RVEmpty{}
    case _: ra_vec_set(U32, vd, v, 0, cs)
def x64_clr_op(vd: Nat, op: IrOp, cs: RaVec<U32>) -> RaVec<U32>:
  match cs:
    case RVEmpty{}: RVEmpty{}
    case _: ra_vec_set_all(U32, vd, 0, opt_op_dsts(op), cs)
def x64_set_const(ok: Bool, vd: Nat, dst: U32, val: U32, cs: RaVec<U32>) -> RaVec<U32>:
  match ok:
    case True{}: ra_vec_set(U32, vd, dst, U32.add(val, 1), cs)
    case False{}: x64_clr_const(vd, dst, cs)
def x64_upd_consts(is_o2: Bool, vd: Nat, op: IrOp, cs: RaVec<U32>) -> RaVec<U32>:
  match is_o2 op:
    case False{} _: cs
    case True{} IConst{dst, +val}: x64_set_const(U32.is_lt(val, 2147483647), vd, dst, val, cs)
    case True{} _: x64_clr_op(vd, op, cs)
def x64_upd_fconsts(is_o2: Bool, +ctx: X64Ctx, +vd: Nat, consts: RaVec<U32>, op: IrOp, fcs: RaVec<U32>) -> RaVec<U32>:
  match is_o2 op:
    case False{} _: fcs
    case True{} IUn{dst, 4, src}: (+rc = x64_const_val(ctx, consts, src); +c = U32.sub(rc, 1); x64_set_const(Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535)), vd, dst, c, fcs))
    case True{} _: x64_clr_op(vd, op, fcs)
def x64_upd_xm0(+ctx: X64Ctx, +fconsts: RaVec<U32>, op: IrOp) -> U32:
  match op:
    case IBin{+dst, +bop, lhs, rhs}: (+la = Bool.pick(U32, Bool.and(x64_is_o2(ctx), U32.is_eq(bop, 13)), ra_vec_get(U32, x64_ctx_vd(ctx), 0, lhs, fconsts), 0); +rb = Bool.pick(U32, U32.is_ne(la, 0), ra_vec_get(U32, x64_ctx_vd(ctx), 0, rhs, fconsts), 0); ok = Bool.and(Bool.and(Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), Bool.not(x64_is_xmm(x64_vreg_loc(ctx, dst)))), U32.is_zero(rb)); Bool.pick(U32, ok, U32.add(dst, 1), 0))
    case _: 0
def x64_u2f_only_fdiv(n: Nat, +ctx: X64Ctx, +consts: RaVec<U32>, +fcs: RaVec<U32>, +dst: U32, rest: List<&2, IrOp>) -> Bool:
  match n rest:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{IConst{_, _}, t}: x64_u2f_only_fdiv(p, ctx, consts, fcs, dst, t)
    case 1n+p Con{IUn{d2, 4, s2}, t}: (+rc = x64_const_val(ctx, consts, s2); +c = U32.sub(rc, 1); ok = Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535)); x64_u2f_only_fdiv(p, ctx, consts, x64_set_const(ok, x64_ctx_vd(ctx), d2, c, fcs), dst, t))
    case _ Con{IBin{_, 13, +l, +r}, _}: (+vd = x64_ctx_vd(ctx); Bool.and(Bool.or(U32.is_eq(l, dst), U32.is_eq(r, dst)), Bool.and(U32.is_ne(ra_vec_get(U32, vd, 0, l, fcs), 0), U32.is_ne(ra_vec_get(U32, vd, 0, r, fcs), 0))))
    case _ _: False{}
def x64_skip_fbin_st(+ctx: X64Ctx, +consts: RaVec<U32>, +fconsts: RaVec<U32>, +uc: RaVec<U32>, op: IrOp, rest: List<&2, IrOp>) -> Bool:
  match op rest:
    case IFlt{dst, _} _: Bool.and(x64_is_o2(ctx), U32.is_zero(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc)))
    case IUn{+dst, 4, src} _: (+vd = x64_ctx_vd(ctx); +u = ra_vec_get(U32, vd, 0, dst, uc); +rc = x64_const_val(ctx, consts, src); +c = U32.sub(rc, 1); f1 = Bool.and(U32.is_eq(u, 1), Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535))); Bool.and(x64_is_o2(ctx), Bool.or(U32.is_zero(u), Bool.and(f1, x64_u2f_only_fdiv(4n, ctx, consts, ra_vec_set(U32, vd, dst, U32.add(c, 1), fconsts), dst, rest)))))
    case IBin{+dst, +bop, _, _} Con{IBin{_, +bop2, l, r}, _}: Bool.and(Bool.and(x64_is_o2(ctx), Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13))), Bool.and(U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1), Bool.and(Bool.and(U32.is_ge(bop2, 10), U32.is_le(bop2, 13)), Bool.or(U32.is_eq(l, dst), U32.is_eq(r, dst)))))
    case _ _: False{}
def x64_unpack_r2(acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(XCvt{3, 2, 0}, acc)
def x64_par2_go(is_ld: Bool, c1: Bool, c2: Bool, +ctx: X64Ctx, a: U32, b: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld c1 c2:
    case _ True{} True{}: x64_emit(XMovRR{0, 1}, x64_emit(XMovRR{2, 0}, x64_emit(XMovRR{1, 2}, acc)))
    case True{} True{} False{}: x64_load_vreg(ctx, 0, a, x64_load_vreg(ctx, 2, b, acc))
    case True{} False{} _: x64_load_vreg(ctx, 2, b, x64_load_vreg(ctx, 0, a, acc))
    case False{} True{} False{}: x64_store_vreg(ctx, a, 0, x64_store_vreg(ctx, b, 2, acc))
    case False{} False{} _: x64_store_vreg(ctx, b, 2, x64_store_vreg(ctx, a, 0, acc))
def x64_u2_load(+ctx: X64Ctx, +d: U32, +off: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+loc = x64_vreg_loc(ctx, d); Bool.pick(List<&2, X64Inst>, x64_is_gpr(loc), x64_emit(XLoad{loc, 5, off}, acc), x64_store_vreg(ctx, d, 0, x64_emit(XLoad{0, 5, off}, acc))))
def x64_emit_take_u2(+ctx: X64Ctx, +is_r: Bool, +dsts: List<&2, U32>, +src: U32, +lbl: U32, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  match ctx dsts:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, +u2p, u2o0, u2o1}, _, _}} Con{d0, Con{d1, Nil{}}}: low_if(X64Acc, Bool.and(U32.is_ne(u2p, 0), U32.is_eq(U32.sub(u2p, 1), src)), u => X64Acc{x64_u2_load(ctx, d1, u2o1, x64_u2_load(ctx, d0, u2o0, acc)), lbl, cold}, u => x64_emit_take_go(True{}, is_r, ctx, dsts, src, lbl, acc, cold))
    case _ _: x64_emit_take_go(x64_is_o2(ctx), is_r, ctx, dsts, src, lbl, acc, cold)
def x64_is_u2_src(ctx: X64Ctx, src: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, +u2p, _, _}, _, _}}: Bool.and(U32.is_ne(u2p, 0), U32.is_eq(U32.sub(u2p, 1), src))
    case _: False{}
def x64_emit_mutfield(+ctx: X64Ctx, +obj: U32, +cidx: U32, +val: U32, +lbl: U32, acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc: (+vloc = x64_vreg_loc(ctx, val); +vg = Bool.and(x64_is_gpr(vloc), Bool.and(U32.is_ne(vloc, 6), U32.is_ne(vloc, 7))); +vreg = Bool.pick(U32, vg, vloc, 0); +cid = U32.shrn(cidx, 4n); +off = U32.mul(U32.and(cidx, 15), 8); a0 = x64_opt_load_vreg(vg, ctx, 0, val, x64_load_vreg(ctx, 2, obj, acc)); x64_if1(List<&2, X64Inst>, X64Acc, x64_is_scalar(ctx, val), a0, a => X64Acc{x64_emit(XStore{7, off, vreg}, x64_mem_idx_ptr(ctx, x64_mask40(2, a))), lbl, cold}, a => +l_raw = U32.add(lbl, 1); +l_done = U32.add(lbl, 2); +l_call = U32.add(lbl, 3); a4 = x64_emit(XLabel{l_done}, x64_emit(XStore{7, off, vreg}, x64_mem_idx_ptr(ctx, x64_mask40(2, x64_emit(XLabel{l_raw}, x64_chk_cid_hot(6, cid, lbl, a)))))); s1 = x64_emit(XJcc{4, l_call}, x64_emit(XTestRR{1, 1}, x64_emit(XLoad{1, 6, 0}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, x64_emit(XJcc{5, l_raw}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, vreg}, x64_emit(XLabel{lbl}, cold)))))))))); s5 = x64_seal_pack_val(vreg, vg, x64_mem_idx_ptr(ctx, x64_emit(XMovRR{2, 1}, x64_emit(XStore{4, 0, 2}, s1)))); s6 = x64_emit(XJmp{l_done}, x64_emit(XStore{7, off, 0}, x64_mem_idx_ptr(ctx, x64_mask40(2, x64_emit(XLoad{2, 4, 0}, s5))))); X64Acc{a4, U32.add(lbl, 4), x64_cold_rt_call(ctx, "p118_rt_finish", l_call, l_done, c => x64_emit(XMovRR{2, 6}, x64_emit(XMovRR{1, vreg}, x64_emit(XStore{7, off, 1}, x64_emit(XMovRI64{1, 4294967295, 4294967295}, x64_mem_idx_ptr(ctx, x64_mask40(2, x64_emit(XMovRR{6, 2}, c))))))), c => x64_inval_cs_hoist(ctx, c), s6)}))
def x64_emit_nat_sub(+ctx: X64Ctx, consts: RaVec<U32>, +dst: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+dloc = x64_vreg_loc(ctx, dst); +rloc = x64_vreg_loc(ctx, rhs); +dreg = x64_gpr_or(dloc, 0); +rc = x64_const_val(ctx, consts, rhs); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(rc, 0), acc, a => x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRI{1, dreg, U32.sub(rc, 1)}, x64_load_vreg(ctx, dreg, lhs, a))), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(dloc), U32.is_ne(dloc, rloc))), a, a1 => +rg = x64_is_gpr(rloc); x64_emit(XAluRR{1, dloc, Bool.pick(U32, rg, rloc, 1)}, x64_opt_load_vreg(rg, ctx, 1, rhs, x64_load_vreg(ctx, dloc, lhs, a1))), a1 => x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{1, 0, 1}, x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, a1)))))))
def x64_emit_rol32(+ctx: X64Ctx, consts: RaVec<U32>, +dst: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +dloc = x64_vreg_loc(ctx, dst)
  +dreg = x64_gpr_or(dloc, 0)
  +rc = x64_const_val(ctx, consts, rhs)
  +amt = Bool.pick(U32, U32.is_ne(rc, 0), U32.sub(rc, 1), 0)
  x64_store_vreg(ctx, dst, dreg, x64_emit(XShift{11, dreg, amt, False{}}, x64_load_vreg(ctx, dreg, lhs, acc)))
def x64_emit_op(+ctx: X64Ctx, fn_map: RaVec<String>, reuse: RaVec<Bool>, skip_st: Bool, consts: RaVec<U32>, fconsts: RaVec<U32>, xm0: U32, uc: RaVec<U32>, op: IrOp, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, +lbl: U32) -> X64Acc:
  match op:
    case IConst{+dst, val}: X64Acc{x64_when(Bool.not(x64_skip_const(ctx, dst)), acc, a => x64_emit_const(ctx, dst, val, a)), lbl, cold}
    case IFlt{dst, bits}: X64Acc{x64_when(Bool.not(skip_st), acc, a => x64_emit_const(ctx, dst, bits, a)), lbl, cold}
    case ICopy{dst, src}: X64Acc{x64_emit_copy(ctx, dst, src, acc), lbl, cold}
    case IBin{dst, 14, lhs, rhs}: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc)))), lbl, cold}
    case IBin{dst, 15, lhs, rhs}: X64Acc{x64_emit_nat_sub(ctx, consts, dst, lhs, rhs, acc), lbl, cold}
    case IBin{dst, 16, lhs, rhs}: X64Acc{x64_emit_rol32(ctx, consts, dst, lhs, rhs, acc), lbl, cold}
    case IBin{dst, +bop, lhs, rhs}: X64Acc{x64_emit_bin_go(ctx, U32.is_ge(bop, 10), skip_st, consts, fconsts, xm0, dst, bop, lhs, rhs, lbl, acc), U32.add(lbl, 1), cold}
    case IUn{dst, uop, src}: X64Acc{x64_when(Bool.not(skip_st), acc, a => x64_emit_un(ctx, consts, dst, uop, src, a)), lbl, cold}
    case ICmp{dst, +cop, lhs, rhs}: X64Acc{x64_emit_cmp_go(ctx, consts, U32.is_ge(cop, 6), dst, cop, lhs, rhs, acc), lbl, cold}
    case ICallDirect{dst, +fid, args}:
      +r2 = x64_r2_of(ctx, fid)
      a0 = x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, fid), args, acc)
      a1 = x64_when(U32.is_ne(r2, 0), a0, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(r2, 65536), a, a3 => x64_emit(XCallSym{"p111_rt_ctor"}, x64_emit(XMovRI32{1, 3}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, U32.sub(U32.and(r2, 65535), 1)}, x64_load_state(ctx, 7, x64_emit(XStore{4, 16, 1}, x64_emit(XStore{4, 8, 2}, x64_emit(XStore{4, 0, 0}, a3)))))))), a2 => x64_emit(XCallSym{"p111_rt_ctor"}, x64_emit(XMovRI32{1, 2}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, U32.sub(r2, 1)}, x64_load_state(ctx, 7, x64_emit(XStore{4, 8, 2}, x64_emit(XStore{4, 0, 0}, x64_unpack_r2(a2))))))))))
      X64Acc{x64_store_vreg(ctx, dst, 0, a1), lbl, cold}
    case ICallClosure{dst, fid, +caps}: (a2 = x64_emit(XMovRI32{1, b5k_u32_list_len(caps)}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, fid}, x64_load_state(ctx, 7, x64_scratch_io(True{}, ctx, caps, 0, acc))))); X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_closure"}, a2)), lbl, cold})
    case IApply{dst, clo, arg}: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"$b5k_apply"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, arg, x64_load_vreg(ctx, 6, clo, acc))))), lbl, cold}
    case ICtor{dst, cid, fields}: x64_emit_ctor(ctx, dst, cid, fields, lbl, acc, cold)
    case ITake{dsts, +src}: x64_emit_take_u2(ctx, Bool.and(x64_is_o2(ctx), ra_vec_get(Bool, x64_ctx_vd(ctx), False{}, src, reuse)), dsts, src, lbl, acc, cold)
    case ITag{dst, src}: X64Acc{x64_emit_tag(x64_is_o2(ctx), ctx, dst, src, acc), lbl, cold}
    case IKeep{dst, +src}: x64_emit_keep_sc(x64_is_o2(ctx), Bool.or(x64_is_scalar(ctx, src), x64_is_bor(ctx, src)), ctx, dst, src, lbl, acc, cold)
    case ISink{+src}: x64_emit_sink_sc(x64_is_o2(ctx), Bool.or(Bool.or(x64_is_scalar(ctx, src), x64_is_u2_src(ctx, src)), x64_is_bor(ctx, src)), ctx, src, lbl, acc, cold)
    case IReuse{dst, slot, cid, fields}: x64_emit_reuse(ctx, reuse, dst, slot, cid, fields, lbl, acc, cold)
    case IStatic{dst, idx}: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XLoad{0, 0, U32.mul(idx, 8)}, x64_emit(XLeaRip{0, "p111_static_image"}, acc))), lbl, cold}
    case IArrOp{dsts, aop, args}: x64_emit_arrop(x64_is_o2(ctx), ctx, consts, uc, aop, dsts, args, lbl, acc, cold)
    case IAlloca{+dst, +words}: X64Acc{x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_zero(words), acc, a => x64_store_vreg(ctx, dst, 4, a), a => x64_store_vreg(ctx, dst, 0, x64_emit(XAluRI{0, 0, 256}, x64_emit(XMovRR{0, 4}, a)))), lbl, cold}
    case ILoad{+dst, base, +off}: X64Acc{x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(off, 65536), x64_load_vreg(ctx, 0, base, acc), a => x64_store_xmm(ctx, dst, 0, x64_emit(XXmmLoad{0, 0, U32.mul(U32.sub(off, 65536), 4)}, a)), a => x64_store_vreg(ctx, dst, 0, x64_emit(XLoad{0, 0, U32.mul(off, 8)}, a))), lbl, cold}
    case IStore{+base, +off, +val}: X64Acc{x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(off, 65536), acc, a => x64_emit(XXmmStore{0, U32.mul(U32.sub(off, 65536), 4), 32}, x64_load_vreg(ctx, 0, base, x64_load_xmm(ctx, 0, val, a))), a => x64_emit(XStore{0, U32.mul(off, 8), 1}, x64_load_vreg(ctx, 1, val, x64_load_vreg(ctx, 0, base, a)))), lbl, cold}
    case IMutField{obj, idx, val}: x64_emit_mutfield(ctx, obj, idx, val, lbl, acc, cold)
    case ILut{+dst, +iv, +dv, +vals}:
      +n = b5k_u32_list_len(vals)
      a0 = x64_emit(XCmov{3, 1, 2}, x64_emit(XCmpRI{1, n}, x64_emit(XMovRI32{2, n}, x64_load_vreg(ctx, 1, iv, acc))))
      a1 = x64_emit(XExtReloc{3, "", 256}, x64_emit(XExtReloc{1, "", dv}, opt_foldl0(~U32, ~List<&2, X64Inst>, ~(v => a => x64_emit(XExtReloc{1, "", v}, a)), vals, x64_emit(XExtReloc{2, "", 0}, a0))))
      X64Acc{x64_store_vreg(ctx, dst, 0, a1), lbl, cold}
    case IFail{code}: X64Acc{x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))), lbl, cold}
def x64_emit_switch_arms(+reg: U32, arms: List<&2, IrSwitchArm>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl(~IrSwitchArm, ~U32, ~List<&2, X64Inst>, ~(r => a => ac => opt_un_arm(List<&2, X64Inst>, a, tag => target => x64_emit(XJcc{4, target}, x64_emit(XCmpRI{r, tag}, ac)))), reg, arms, acc)
def x64_ins_arm(+t1: U32, +tgt1: U32, sorted: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>:
  match sorted:
    case Nil{}: Con{IrArm{t1, tgt1}, Nil{}}
    case Con{IrArm{+t2, +tgt2}, +rest}: Bool.pick(List<&2, IrSwitchArm>, U32.is_le(t1, t2), Con{IrArm{t1, tgt1}, Con{IrArm{t2, tgt2}, rest}}, Con{IrArm{t2, tgt2}, x64_ins_arm(t1, tgt1, rest)})
def x64_sort_arms(arms: List<&2, IrSwitchArm>, acc: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>: opt_foldl0(~IrSwitchArm, ~List<&2, IrSwitchArm>, ~(a => ac => opt_un_arm(List<&2, IrSwitchArm>, a, t1 => tgt1 => x64_ins_arm(t1, tgt1, ac))), arms, acc)
type X64SwSplit is Data:
  X64SwSplit{lo: List<&2, IrSwitchArm>, mtag: U32, mtgt: U32, hi: List<&2, IrSwitchArm>}
def x64_split_arms(n: Nat, arms: List<&2, IrSwitchArm>, rev_lo: List<&2, IrSwitchArm>) -> X64SwSplit:
  match n arms:
    case 0n Con{IrArm{mt, mg}, hi}: X64SwSplit{b5k_list_rev(IrSwitchArm, rev_lo), mt, mg, hi}
    case 1n+p Con{a, t}: x64_split_arms(p, t, Con{a, rev_lo})
    case _ _: X64SwSplit{b5k_list_rev(IrSwitchArm, rev_lo), 0, 0, Nil{}}
type X64SwTask is Data:
  X64SwTask{has_lbl: Bool, lbl: U32, arms: List<&2, IrSwitchArm>, n: U32}
type X64SwStep is Data:
  X64SwStep{todo: List<&2, X64SwTask>, st: X64Acc}
def x64_sw_bs_drain(+reg: U32, +db: U32, todo: List<&2, X64SwTask>, st: X64Acc) -> X64Acc:
  match todo st:
    case Nil{} _: st
    case Con{X64SwTask{hl, tl, arms, _}, rest} X64Acc{acc, lbl, cold}: x64_sw_bs_drain(reg, db, rest, X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, x64_emit_if(hl, XLabel{tl}, acc))), lbl, cold})
def x64_sw_bs_step(sp: X64SwSplit, reg: U32, +mid: U32, n: U32, rest: List<&2, X64SwTask>, a0: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64SwStep:
  X64SwSplit{lo, mtag, mtgt, hi} = sp
  X64SwStep{Con{X64SwTask{False{}, 0, lo, mid}, Con{X64SwTask{True{}, lbl, hi, U32.sub(U32.sub(n, mid), 1)}, rest}}, X64Acc{x64_emit(XJcc{7, lbl}, x64_emit(XJcc{4, mtgt}, x64_emit(XCmpRI{reg, mtag}, a0))), U32.add(lbl, 1), cold}}
def x64_sw_bs_work(fuel: Nat, +reg: U32, +db: U32, step: X64SwStep) -> X64Acc:
  match fuel step:
    case _ X64SwStep{Nil{}, st}: st
    case 0n X64SwStep{todo, st}: x64_sw_bs_drain(reg, db, todo, st)
    case 1n+p X64SwStep{Con{X64SwTask{hl, tl, +arms, +n}, +rest}, X64Acc{acc, +lbl, +cold}}: (+p1 = p; +a0 = x64_emit_if(hl, XLabel{tl}, acc); low_if(X64Acc, U32.is_le(n, 3), _ => x64_sw_bs_work(p1, reg, db, X64SwStep{rest, X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, a0)), lbl, cold}}), _ => +mid = U32.shrn(n, 1n); x64_sw_bs_work(p1, reg, db, x64_sw_bs_step(x64_split_arms(U32.to_nat(mid), arms, Nil{}), reg, mid, n, rest, a0, lbl, cold))))
def x64_emit_switch_bs(use_bs: Bool, +reg: U32, arms: List<&2, IrSwitchArm>, +n: U32, db: U32, st: X64Acc) -> X64Acc:
  match use_bs st:
    case False{} X64Acc{acc, lbl, cold}: X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, acc)), lbl, cold}
    case True{} _: x64_sw_bs_work(U32.to_nat(U32.mul(n, 2)), reg, db, X64SwStep{Con{X64SwTask{False{}, 0, x64_sort_arms(arms, Nil{}), n}, Nil{}}, st})
def x64_emit_epilogue(acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, acc)))
def x64_emit_epilogue_end(+is_ret: Bool, ctx: X64Ctx, end: X64Inst, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, ce, _, X64Meta{True{}, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, _, _, _, _, _}, _, _}}: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.and(is_ret, U32.is_ne(U32.and(csm, 8), 0)), acc, a => x64_emit(XJmp{2147614717}, a), a => x64_emit(end, x64_push_pop_list(False{}, b5k_list_rev(U32, ce), a)))
    case X64Ctx{_, _, _, _, _, _, _, _, Nil{}, _, _}: x64_emit(end, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, acc)))
    case X64Ctx{_, _, _, _, _, _, _, frame, ce, _, _}: x64_emit(end, x64_emit(XPop{5}, x64_push_pop_list(False{}, b5k_list_rev(U32, ce), x64_emit(XAddRsp{frame}, acc))))
def x64_emit_epilogue_ctx(ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit_epilogue_end(True{}, ctx, XRet{}, acc)
def x64_emit_epilogue_jmp(ctx: X64Ctx, sym: String, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit_epilogue_end(False{}, ctx, XJmpSym{sym}, acc)
def x64_u32_in(x: U32, xs: List<&2, U32>) -> Bool: b5k_chk_u32_mem(xs, x)
def x64_cons_if(add: Bool, x: U32, +xs: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, add, Con{x, xs}, xs)
def x64_tail_src_locs(+p2: Bool, +ctx: X64Ctx, +srcs1: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match args:
    case Nil{}: acc
    case Con{r, t}: (+rloc = x64_vreg_loc(ctx, r); +iloc = x64_vreg_loc(ctx, idx); x64_tail_src_locs(p2, ctx, srcs1, t, U32.add(idx, 1), x64_cons_if(Bool.and(U32.is_ne(rloc, iloc), Bool.or(Bool.not(p2), x64_u32_in(iloc, srcs1))), rloc, acc)))
def x64_tail_direct(+ctx: X64Ctx, +p2: Bool, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}: (+rloc = x64_vreg_loc(ctx, r); +iloc = x64_vreg_loc(ctx, idx); ok = Bool.pick(Bool, p2, Bool.and(x64_u32_in(iloc, srcs1), Bool.not(x64_u32_in(iloc, srcs2))), Bool.not(x64_u32_in(iloc, srcs1))); x64_tail_direct(ctx, p2, srcs1, srcs2, t, U32.add(idx, 1), x64_when(Bool.and(U32.is_ne(rloc, iloc), ok), acc, a => x64_emit_copy(ctx, idx, r, a))))
def x64_tail_scratch(+ctx: X64Ctx, +to_scr: Bool, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}: (+rloc = x64_vreg_loc(ctx, r); +iloc = x64_vreg_loc(ctx, idx); +loc = Bool.pick(U32, to_scr, rloc, iloc); +off = U32.mul(idx, 8); a1 = x64_when(Bool.and(U32.is_ne(rloc, iloc), Bool.and(x64_u32_in(iloc, srcs1), x64_u32_in(iloc, srcs2))), acc, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, to_scr, a, a0 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(loc), a0, a_ => x64_emit(XXmmStore{4, off, U32.sub(loc, 20)}, a_), a_ => x64_emit(XStore{4, off, 0}, x64_load_vreg(ctx, 0, r, a_))), a0 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, x64_is_xmm(loc), a0, a_ => x64_emit(XXmmLoad{U32.sub(loc, 20), 4, off}, a_), a_ => x64_store_vreg(ctx, idx, 0, x64_emit(XLoad{0, 4, off}, a_))))); x64_tail_scratch(ctx, to_scr, srcs1, srcs2, t, U32.add(idx, 1), a1))
def x64_emit_jcc_pair(+cc: U32, +tb: U32, +eb: U32, +nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(tb, nxt), acc, a => x64_emit(XJcc{U32.xor(cc, 1), eb}, a), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(eb, nxt), a, a1 => x64_emit(XJcc{cc, tb}, a1), a1 => x64_emit(XJmp{eb}, x64_emit(XJcc{cc, tb}, a1))))
def x64_emit_br_go(is_dec: Bool, +ctx: X64Ctx, +loc: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_dec, acc, a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(loc, 100), a, a0 => +d = x64_spill_disp(ctx, loc); Con{XStore{5, d, 0}, Con{XAluRI{1, 0, 1}, Con{XLoad{0, 5, d}, a0}}}, a0 => x64_emit(XAluRI{1, loc, 1}, a0)), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(loc, 100), a, a0 => x64_emit(XTestRR{0, 0}, Con{XLoad{0, 5, x64_spill_disp(ctx, loc)}, a0}), a0 => x64_emit(XTestRR{loc, loc}, a0))); x64_emit_jcc_pair(5, tb, eb, nxt, a1))
def x64_emit_tail_jmp(+ctx: X64Ctx, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, lbase, _, _, _, X64HMag{_, _, _, _, +t0c, t0t, t0e, t0d}, _}}: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(t0c, 0), acc, a => x64_emit_br_go(t0d, ctx, x64_vreg_loc(ctx, U32.sub(t0c, 1)), t0t, t0e, nxt, a), a => x64_emit(XJmp{lbase}, a))
    case _: x64_emit(XJmp{0}, acc)
type X64Swap2 is Data:
  X64Swap2{cnt: U32, d0: U32, s0: U32, d1: U32, s1: U32}
def x64_tail_scan_swap2(+ctx: X64Ctx, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, st: X64Swap2) -> X64Swap2:
  match args st:
    case Nil{} _: st
    case Con{+r, t} X64Swap2{+cnt, +d0, +s0, +d1, +s1}: (+rloc = x64_vreg_loc(ctx, r); +iloc = x64_vreg_loc(ctx, idx); +act = Bool.and(U32.is_ne(rloc, iloc), Bool.and(x64_u32_in(iloc, srcs1), x64_u32_in(iloc, srcs2))); +c0 = Bool.and(act, U32.is_zero(cnt)); +c1 = Bool.and(act, U32.is_eq(cnt, 1)); x64_tail_scan_swap2(ctx, srcs1, srcs2, t, U32.add(idx, 1), X64Swap2{Bool.pick(U32, act, U32.add(cnt, 1), cnt), Bool.pick(U32, c0, iloc, d0), Bool.pick(U32, c0, rloc, s0), Bool.pick(U32, c1, iloc, d1), Bool.pick(U32, c1, rloc, s1)}))
def x64_tail_fin(+ctx: X64Ctx, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, +args: List<&2, U32>, nxt: U32, +a1: List<&2, X64Inst>, sw: X64Swap2) -> List<&2, X64Inst>:
  X64Swap2{cnt, +d0, +s0, +d1, +s1} = sw
  ok = Bool.and(U32.is_eq(cnt, 2), Bool.and(Bool.and(U32.is_eq(d0, s1), U32.is_eq(d1, s0)), Bool.and(Bool.and(x64_is_gpr(d0), x64_is_gpr(d1)), Bool.and(U32.is_ne(d0, 0), U32.is_ne(d1, 0)))))
  x64_emit_tail_jmp(ctx, nxt, Bool.pick(List<&2, X64Inst>, ok, x64_emit(XMovRR{d1, 0}, x64_emit(XMovRR{d0, d1}, x64_emit(XMovRR{0, d0}, a1))), x64_tail_scratch(ctx, False{}, srcs1, srcs2, args, 0, x64_tail_scratch(ctx, True{}, srcs1, srcs2, args, 0, a1))))
def x64_emit_term(+ctx: X64Ctx, +fn_map: RaVec<String>, term: IrTerm, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match term:
    case TJmp{target}: x64_emit(XJmp{target}, acc)
    case TBr{cond, then_blk, else_blk}: x64_emit_br_go(False{}, ctx, x64_vreg_loc(ctx, cond), then_blk, else_blk, nxt, acc)
    case TSwitch{_, _, db}: x64_emit(XJmp{db}, acc)
    case TRet{val}: x64_emit_epilogue_ctx(ctx, x64_load_vreg(ctx, 0, val, acc))
    case TTailCall{+fid, +args}: x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_le(b5k_u32_list_len(args), 64), acc, a => +srcs1 = x64_tail_src_locs(False{}, ctx, Nil{}, args, 0, Nil{}); +srcs2 = x64_tail_src_locs(True{}, ctx, srcs1, args, 0, Nil{}); x64_tail_fin(ctx, srcs1, srcs2, args, nxt, x64_tail_direct(ctx, True{}, srcs1, srcs2, args, 0, x64_tail_direct(ctx, False{}, srcs1, Nil{}, args, 0, a)), x64_tail_scan_swap2(ctx, srcs1, srcs2, args, 0, X64Swap2{0, 0, 0, 0, 0})), a => x64_emit_epilogue_ctx(ctx, x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, fid), args, a)))
    case TFail{code}: x64_emit_epilogue_ctx(ctx, x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))))
def x64_emit_term_acc(+ctx: X64Ctx, +fn_map: RaVec<String>, term: IrTerm, +nxt: U32, st: X64Acc) -> X64Acc:
  match term st:
    case TSwitch{scrut, +arms, def_blk} X64Acc{a1, lbl1, cold}: (+loc = x64_vreg_loc(ctx, scrut); +is_sp = U32.is_ge(loc, 100); +n = b5k_list_len(IrSwitchArm, arms); x64_emit_switch_bs(Bool.and(x64_is_o2(ctx), U32.is_ge(n, 5)), Bool.pick(U32, is_sp, 0, loc), arms, n, def_blk, X64Acc{x64_when(is_sp, a1, a => Con{XLoad{0, 5, x64_spill_disp(ctx, loc)}, a}), lbl1, cold}))
    case TRet{+val} X64Acc{a1, +lbl1, +cold}: (+cv = x64_const_val(ctx, RVEmpty{}, val); a_ld = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(cv, 1), a1, a => x64_emit(XAluRR{7, 0, 0}, a), a => x64_load_vreg(ctx, 0, val, a)); x64_if1(List<&2, X64Inst>, X64Acc, Bool.and(x64_is_bor(ctx, val), Bool.not(x64_is_scalar(ctx, val))), a_ld, a => X64Acc{x64_emit_epilogue_ctx(ctx, x64_rc_shared(True{}, ctx, 0, lbl1, U32.add(lbl1, 1), a)), U32.add(lbl1, 2), x64_emit(XJmp{lbl1}, x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_emit(XMovRR{6, 0}, x64_emit(XLabel{U32.add(lbl1, 1)}, cold)))))}, a => X64Acc{x64_emit_epilogue_ctx(ctx, a), lbl1, cold}))
    case _ X64Acc{a1, lbl1, cold}: X64Acc{x64_emit_term(ctx, fn_map, term, nxt, a1), lbl1, cold}
type X64Step is Data:
  X64Step{skip: Nat, cs: RaVec<U32>, fcs: RaVec<U32>, xm0: U32, st: X64Acc}
def x64_step_def(+ctx: X64Ctx, fn_map: RaVec<String>, reuse: RaVec<Bool>, +op1: IrOp, t1: List<&2, IrOp>, +consts: RaVec<U32>, +fconsts: RaVec<U32>, xm0: U32, +uc: RaVec<U32>, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, lbl: U32) -> X64Step:
  +vd = x64_ctx_vd(ctx)
  X64Step{0n, x64_upd_consts(x64_is_o2(ctx), vd, op1, consts), x64_upd_fconsts(x64_is_o2(ctx), ctx, vd, consts, op1, fconsts), x64_upd_xm0(ctx, fconsts, op1), x64_emit_op(ctx, fn_map, reuse, x64_skip_fbin_st(ctx, consts, fconsts, uc, op1, t1), consts, fconsts, xm0, uc, op1, acc, cold, lbl)}
def x64_emit_ops_step(+ctx: X64Ctx, +fn_map: RaVec<String>, +reuse: RaVec<Bool>, +op1: IrOp, +t1: List<&2, IrOp>, +consts: RaVec<U32>, +fconsts: RaVec<U32>, +xm0: U32, +uc: RaVec<U32>, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>, +lbl: U32) -> X64Step:
  match op1 t1:
    case IConst{+d, +val} Con{ICopy{+cd, +cs}, _}: (+vd = x64_ctx_vd(ctx); opt_if(X64Step, Bool.and(x64_is_o2(ctx), Bool.and(U32.is_eq(d, cs), U32.is_eq(ra_vec_get(U32, vd, 0, d, uc), 1))), _ => X64Step{1n, x64_upd_consts(True{}, vd, IConst{cd, val}, consts), x64_clr_const(vd, cd, fconsts), 0, X64Acc{x64_emit_const(ctx, cd, val, acc), lbl, cold}}, _ => x64_step_def(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)))
    case ICallDirect{+dst, +cfid, +args} Con{ITake{Con{+d0, Con{+d1, Nil{}}}, tsrc}, _}: (+vd = x64_ctx_vd(ctx); +r2 = x64_r2_of(ctx, cfid); low_if(X64Step, Bool.and(Bool.and(Bool.and(U32.is_ne(r2, 0), U32.is_lt(r2, 65536)), U32.is_eq(dst, tsrc)), Bool.and(Bool.and(U32.is_ne(d0, d1), U32.is_eq(ra_vec_get(U32, vd, 0, dst, uc), 1)), Bool.not(ra_vec_get(Bool, vd, False{}, dst, reuse)))), _ => X64Step{1n, x64_clr_const(vd, d1, x64_clr_const(vd, d0, consts)), x64_clr_const(vd, d1, x64_clr_const(vd, d0, fconsts)), 0, X64Acc{x64_par2_go(False{}, U32.is_eq(x64_vreg_loc(ctx, d0), 2), U32.is_zero(x64_vreg_loc(ctx, d1)), ctx, d0, d1, x64_unpack_r2(x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, cfid), args, acc))), lbl, cold}}, _ => x64_step_def(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)))
    case ICallDirect{+dst, +cfid, +args} Con{ITake{Con{+d0, Con{+d1, Con{+d2, Nil{}}}}, tsrc}, _}: (+vd = x64_ctx_vd(ctx); low_if(X64Step, Bool.and(Bool.and(U32.is_ge(x64_r2_of(ctx, cfid), 65536), U32.is_eq(dst, tsrc)), Bool.and(Bool.and(Bool.and(U32.is_ne(d0, d1), Bool.and(U32.is_ne(d0, d2), U32.is_ne(d1, d2))), U32.is_eq(ra_vec_get(U32, vd, 0, dst, uc), 1)), Bool.not(ra_vec_get(Bool, vd, False{}, dst, reuse)))), _ => X64Step{1n, x64_clr_const(vd, d2, x64_clr_const(vd, d1, x64_clr_const(vd, d0, consts))), x64_clr_const(vd, d2, x64_clr_const(vd, d1, x64_clr_const(vd, d0, fconsts))), 0, X64Acc{x64_store_vreg(ctx, d2, 1, x64_store_vreg(ctx, d1, 2, x64_store_vreg(ctx, d0, 0, x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, cfid), args, acc)))), lbl, cold}}, _ => x64_step_def(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)))
    case _ _: x64_step_def(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)
def x64_fused_def(+ctx: X64Ctx, +fn_map: RaVec<String>, +term: IrTerm, +nxt: U32, cs: RaVec<U32>, fcs: RaVec<U32>, xm0: U32, op: IrOp, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, lbl: U32) -> X64Acc: x64_emit_term_acc(ctx, fn_map, term, nxt, x64_emit_op(ctx, fn_map, RVEmpty{}, False{}, cs, fcs, xm0, RVEmpty{}, op, acc, cold, lbl))
def x64_emit_ops_fused(+ctx: X64Ctx, +fn_map: RaVec<String>, +reuse: RaVec<Bool>, ops: List<&2, IrOp>, step: X64Step, +uc: RaVec<U32>, +term: IrTerm, +nxt: U32) -> X64Acc:
  match ctx ops step term:
    case _ Nil{} X64Step{_, _, _, _, st} _: x64_emit_term_acc(ctx, fn_map, term, nxt, st)
    case _ Con{_, t} X64Step{1n+p, cs, fcs, xm0, st} _: x64_emit_ops_fused(ctx, fn_map, reuse, t, X64Step{p, cs, fcs, xm0, st}, uc, term, nxt)
    case _ Con{IConst{+d, +val}, Nil{}} X64Step{0n, _, _, _, X64Acc{+acc, +lbl, +cold}} TRet{+rv}: opt_if(X64Acc, Bool.and(x64_is_o2(ctx), U32.is_eq(d, rv)), _ => X64Acc{x64_emit_epilogue_ctx(ctx, x64_emit(Bool.pick(X64Inst, U32.is_zero(val), XAluRR{7, 0, 0}, XMovRI32{0, val}), acc)), lbl, cold}, _ => x64_emit_term_acc(ctx, fn_map, TRet{rv}, nxt, x64_emit_op(ctx, fn_map, reuse, False{}, RVEmpty{}, RVEmpty{}, 0, uc, IConst{d, val}, acc, cold, lbl)))
    case _ Con{ICmp{+dst, +cop, +lhs, +rhs}, Nil{}} X64Step{0n, +consts, _, _, X64Acc{+acc, +lbl, +cold}} TBr{+cond, +tb, +eb}: low_if(X64Acc, Bool.and(Bool.and(x64_is_o2(ctx), Bool.or(U32.is_lt(cop, 6), U32.is_ge(cop, 8))), Bool.and(U32.is_eq(dst, cond), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1))), _ => (+is_flt = U32.is_ge(cop, 8); +fop = U32.sub(cop, 6); X64Acc{x64_emit_jcc_pair(Bool.pick(U32, is_flt, Bool.pick(U32, Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 4)), 7, 3), x64_cmp_cc(cop)), tb, eb, nxt, x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, is_flt, acc, a => x64_emit_fcmp_ucomiss(ctx, cop, lhs, rhs, a), a => x64_emit_cmp_flags(ctx, consts, cop, lhs, rhs, a))), lbl, cold}), _ => x64_emit_term_acc(ctx, fn_map, TBr{cond, tb, eb}, nxt, X64Acc{x64_emit_cmp_go(ctx, consts, U32.is_ge(cop, 6), dst, cop, lhs, rhs, acc), lbl, cold}))
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, cur_r2, _, _, _}, _, _}} Con{ICtor{+dst, +cid, Con{+a, Con{+b, Nil{}}}}, Nil{}} X64Step{0n, +cs, +fcs, +xm0, X64Acc{+acc, +lbl, +cold}} TRet{+val}: low_if(X64Acc, Bool.and(U32.is_eq(cur_r2, U32.add(cid, 1)), U32.is_eq(dst, val)), _ => X64Acc{x64_emit_epilogue_ctx(ctx, x64_emit(XCvt{2, 0, 2}, x64_par2_go(True{}, U32.is_zero(x64_vreg_loc(ctx, b)), U32.is_eq(x64_vreg_loc(ctx, a), 2), ctx, a, b, acc))), lbl, cold}, _ => x64_fused_def(ctx, fn_map, TRet{val}, nxt, cs, fcs, xm0, ICtor{dst, cid, Con{a, Con{b, Nil{}}}}, acc, cold, lbl))
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, cur_r2, _, _, _}, _, _}} Con{ICtor{+dst, +cid, Con{+a, Con{+b, Con{+c, Nil{}}}}}, Nil{}} X64Step{0n, +cs, +fcs, +xm0, X64Acc{+acc, +lbl, +cold}} TRet{+val}: low_if(X64Acc, Bool.and(U32.is_eq(cur_r2, U32.or(65536, U32.add(cid, 1))), U32.is_eq(dst, val)), _ => X64Acc{x64_emit_epilogue_ctx(ctx, x64_load_vreg(ctx, 1, c, x64_load_vreg(ctx, 2, b, x64_load_vreg(ctx, 0, a, acc)))), lbl, cold}, _ => x64_fused_def(ctx, fn_map, TRet{val}, nxt, cs, fcs, xm0, ICtor{dst, cid, Con{a, Con{b, Con{c, Nil{}}}}}, acc, cold, lbl))
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, +cur_fid, +cur_r2, +u2p, +u2o0, +u2o1}, _, _}} Con{ICallDirect{+dst, +cfid, +args}, Nil{}} X64Step{0n, +cs, +fcs, +xm0, X64Acc{+acc, +lbl, +cold}} TTailCall{+tfid, +targs}: low_if(X64Acc, Bool.and(Bool.and(U32.is_ne(u2p, 0), U32.is_eq(cfid, cur_fid)), Bool.and(U32.is_eq(tfid, cur_fid), Bool.and(U32.is_eq(x64_u32_nth(targs, U32.to_nat(U32.sub(u2p, 1))), dst), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1)))), _ => (a1 = x64_emit(XStore{5, u2o1, 2}, x64_emit(XStore{5, u2o0, 0}, x64_unpack_r2(x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, cfid), args, acc)))); X64Acc{x64_emit_term(ctx, fn_map, TTailCall{tfid, targs}, nxt, x64_store_vreg(ctx, dst, 0, x64_emit(XMovRI64{0, 0, U32.or(33554432, U32.shln(U32.sub(cur_r2, 1), 8n))}, a1))), lbl, cold}), _ => x64_fused_def(ctx, fn_map, TTailCall{tfid, targs}, nxt, cs, fcs, xm0, ICallDirect{dst, cfid, args}, acc, cold, lbl))
    case X64Ctx{_, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, cur_r2, _, _, _}, _, _}} Con{ICallDirect{+dst, +cfid, +args}, Nil{}} X64Step{0n, +cs, +fcs, +xm0, X64Acc{+acc, +lbl, +cold}} TRet{+val}: (+nargs = b5k_u32_list_len(args); low_if(X64Acc, Bool.and(Bool.and(U32.is_eq(dst, val), U32.is_le(nargs, 5)), Bool.and(Bool.and(U32.is_zero(cur_r2), U32.is_zero(x64_r2_of(ctx, cfid))), Bool.not(x64_is_bor(ctx, val)))), _ => X64Acc{x64_emit_epilogue_jmp(ctx, x64_lookup_fn_sym(fn_map, cfid), x64_load_state(ctx, 7, x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, acc)))), lbl, cold}, _ => x64_fused_def(ctx, fn_map, TRet{val}, nxt, cs, fcs, xm0, ICallDirect{dst, cfid, args}, acc, cold, lbl)))
    case _ Con{op1, +t1} X64Step{0n, consts, fconsts, xm0, X64Acc{acc, lbl, cold}} _: x64_emit_ops_fused(ctx, fn_map, reuse, t1, x64_emit_ops_step(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl), uc, term, nxt)
def x64_acc_insts(st: X64Acc) -> List<&2, X64Inst>:
  X64Acc{insts, _, cold} = st
  b5k_list_app(X64Inst, cold, insts)
def x64_inc_use(+vd: Nat, +v: U32, +uc: RaVec<U32>) -> RaVec<U32>: ra_vec_set(U32, vd, v, U32.add(ra_vec_get(U32, vd, 0, v, uc), 1), uc)
def x64_inc_uses(+vd: Nat, vs: List<&2, U32>, uc: RaVec<U32>) -> RaVec<U32>: opt_foldl(~U32, ~Nat, ~RaVec<U32>, ~(e => v => u => x64_inc_use(e, v, u)), vd, vs, uc)
def x64_uc_op(vd: Nat, op: IrOp, uc: RaVec<U32>) -> RaVec<U32>: x64_inc_uses(vd, opt_op_uses_list(op), uc)
def x64_uc_term(vd: Nat, term: IrTerm, uc: RaVec<U32>) -> RaVec<U32>: x64_inc_uses(vd, opt_term_uses_list(term), uc)
def x64_uc_blks(+vd: Nat, blks: List<&2, IrBlock>, uc: RaVec<U32>) -> RaVec<U32>: opt_foldl(~IrBlock, ~Nat, ~RaVec<U32>, ~(v => b => u => (+v0 = v; opt_un_blk(RaVec<U32>, b, _ => ops1 => term => opt_foldl(~IrOp, ~Nat, ~RaVec<U32>, ~(v1 => op => u1 => x64_inc_uses(v1, opt_op_uses_list(op), u1)), v0, ops1, x64_inc_uses(v0, opt_term_uses_list(term), u))))), vd, blks, uc)
def x64_op_pred(+k: U32, +fid: U32, op: IrOp) -> Bool:
  match k op:
    case 0 ICtor{_, _, Con{_, _}}: True{}
    case 0 IReuse{_, _, _, Con{_, _}}: True{}
    case 0 ITake{Con{_, _}, _}: True{}
    case 0 IKeep{_, _}: True{}
    case 0 ISink{_}: True{}
    case 0 IMutField{_, _, _}: True{}
    case 0 IArrOp{_, +aop, _}: Bool.or(Bool.and(U32.is_ge(aop, 71), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 79)))
    case 1 IReuse{_, _, _, _}: True{}
    case 2 ICallDirect{_, _, _}: True{}
    case 2 ICallClosure{_, _, _}: True{}
    case 2 IApply{_, _, _}: True{}
    case 3 ICallDirect{_, cfid, _}: U32.is_eq(cfid, fid)
    case 4 IArrOp{_, _, _}: True{}
    case _ _: False{}
def x64_blks_any_walk(+k: U32, +fid: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>) -> Bool:
  match blks ops:
    case Nil{} Nil{}: False{}
    case Con{IrBlock{_, ops1, TTailCall{+tfid, _}}, t} Nil{}: Bool.or(Bool.pick(Bool, U32.is_eq(k, 2), U32.is_ne(tfid, fid), Bool.and(U32.is_eq(k, 3), U32.is_eq(tfid, fid))), x64_blks_any_walk(k, fid, t, ops1))
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_blks_any_walk(k, fid, t, ops1)
    case _ Con{op, ot}: Bool.or(x64_op_pred(k, fid, op), x64_blks_any_walk(k, fid, blks, ot))
def x64_blks_any(k: U32, fid: U32, blks: List<&2, IrBlock>) -> Bool: x64_blks_any_walk(k, fid, blks, Nil{})
def x64_op_redefs(s: U32, op: IrOp) -> Bool: x64_u32_in(s, opt_op_dsts(op))
def x64_ru_is_pak1(+ctx: X64Ctx, +cid: U32, fs: List<&2, U32>) -> Bool:
  match fs:
    case Con{f0, Nil{}}: Bool.and(U32.is_ge(cid, 39), x64_is_num_scalar(ctx, f0))
    case _: False{}
def x64_find_reuse_ops(+ctx: X64Ctx, +vd: Nat, +s: U32, +cls: U32, ops: List<&2, IrOp>, +st: U32) -> U32:
  match ops:
    case Nil{}: st
    case Con{IReuse{+d, +sl, +cid, +fs}, t}: (+nf = b5k_u32_list_len(fs); +st1 = Bool.pick(U32, U32.is_eq(sl, s), Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(st, 2), Bool.not(x64_ru_is_pak1(ctx, cid, fs))), Bool.and(Bool.and(U32.is_ne(d, s), Bool.not(x64_u32_in(s, fs))), Bool.and(Bool.and(U32.is_gt(nf, 0), U32.is_le(nf, 8)), U32.is_eq(x64_cls_fit(nf), cls)))), 1, 0), Bool.pick(U32, Bool.and(U32.is_ne(d, s), Bool.not(x64_u32_in(s, fs))), st, 0)); Bool.pick(U32, U32.is_zero(st1), 0, x64_find_reuse_ops(ctx, vd, s, cls, t, st1)))
    case Con{+op, t}: Bool.pick(U32, Bool.or(x64_op_redefs(s, op), U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_op(vd, op, RVEmpty{})), 0)), 0, x64_find_reuse_ops(ctx, vd, s, cls, t, st))
def x64_ru_inc(+id: U32, +ps: RaVec<U32>) -> RaVec<U32>: Bool.pick(RaVec<U32>, U32.is_lt(id, 1024), ra_vec_set(U32, 5n, id, U32.add(ra_vec_get(U32, 5n, 0, id, ps), 1), ps), ps)
def x64_ru_arms(arms: List<&2, IrSwitchArm>, ps: RaVec<U32>) -> RaVec<U32>: opt_foldl0(~IrSwitchArm, ~RaVec<U32>, ~(a => p => opt_un_arm(RaVec<U32>, a, _ => tgt => x64_ru_inc(tgt, p))), arms, ps)
def x64_ru_jmp(+ctx: X64Ctx, mb: Maybe<&2, IrBlock>, vd: Nat, s: U32) -> U32:
  match mb:
    case Some{IrBlock{_, ops, TJmp{tgt}}}: Bool.pick(U32, U32.is_eq(x64_find_reuse_ops(ctx, vd, s, 99, ops, 2), 2), U32.add(tgt, 1), 0)
    case _: 0
def x64_ru_both(a: List<&2, U32>, b: List<&2, U32>) -> List<&2, U32>:
  match a b:
    case Con{x, xt} Con{y, yt}: b5k_list_app(U32, Con{x, xt}, Con{y, yt})
    case _ _: Nil{}
def x64_ru_walk(fuel: Nat, is_t: Bool, tu: Bool, +ctx: X64Ctx, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: RaVec<U32>, +vd: Nat, +s: U32, +cls: U32, +bid: U32, term: IrTerm, mb: Maybe<&2, IrBlock>) -> List<&2, U32>:
  match fuel is_t tu term mb:
    case 0n _ _ _ _: Nil{}
    case _ True{} True{} _ _: Nil{}
    case 1n+p True{} False{} TJmp{+tgt} _: Bool.pick(List<&2, U32>, Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, bid), U32.is_eq(ra_vec_get(U32, 5n, 0, tgt, preds), 1))), x64_ru_walk(p, False{}, False{}, ctx, bmap, preds, vd, s, cls, tgt, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap)), Nil{})
    case 1n+p0 True{} False{} TBr{_, +tb, +fb} _: (+p = p0; +ok = Bool.and(Bool.and(U32.is_lt(tb, 1024), U32.is_lt(fb, 1024)), Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_eq(ra_vec_get(U32, 5n, 0, tb, preds), 1), U32.is_eq(ra_vec_get(U32, 5n, 0, fb, preds), 1)))); +jt = Bool.pick(U32, ok, x64_ru_jmp(ctx, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), vd, s), 0); +m = U32.sub(jt, 1); Bool.pick(List<&2, U32>, ok, Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, Bool.pick(U32, ok, x64_ru_jmp(ctx, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), vd, s), 0)), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, bid), U32.is_eq(ra_vec_get(U32, 5n, 0, m, preds), 2))))), x64_ru_walk(p, False{}, False{}, ctx, bmap, preds, vd, s, cls, m, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, m, bmap)), x64_ru_both(x64_ru_walk(p, False{}, False{}, ctx, bmap, preds, vd, s, cls, tb, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), x64_ru_walk(p, False{}, False{}, ctx, bmap, preds, vd, s, cls, fb, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)))), Nil{}))
    case 1n+p False{} _ _ Some{IrBlock{_, ops, +t2}}: (+st = x64_find_reuse_ops(ctx, vd, s, cls, ops, 2); +tu2 = U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_term(vd, t2, RVEmpty{})), 0); Bool.pick(List<&2, U32>, U32.is_eq(st, 1), Bool.pick(List<&2, U32>, tu2, Nil{}, Con{bid, Nil{}}), Bool.pick(List<&2, U32>, U32.is_eq(st, 2), x64_ru_walk(p, True{}, tu2, ctx, bmap, preds, vd, s, cls, bid, t2, None{}), Nil{})))
    case _ _ _ _ _: Nil{}
def x64_ru_mark(+vd: Nat, +s: U32, bids: List<&2, U32>, +brm: RaVec<RaVec<Bool>>) -> RaVec<RaVec<Bool>>: opt_foldl2(~U32, ~Nat, ~U32, ~RaVec<RaVec<Bool>>, ~(v0 => s0 => b => m => (+vv = v0; +bid = b; +m0 = m; ra_vec_set(RaVec<Bool>, 5n, bid, ra_vec_set(Bool, vv, s0, True{}, ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, bid, m0)), m0))), vd, s, bids, brm)
def x64_scan_reuse_walk(+ctx: X64Ctx, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: RaVec<U32>, +vd: Nat, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, +bid: U32, +term: IrTerm, +seen: RaVec<Bool>, +brm: RaVec<RaVec<Bool>>) -> RaVec<RaVec<Bool>>:
  match blks ops:
    case Nil{} Nil{}: brm
    case Con{IrBlock{+id, ops1, term1}, t} Nil{}: x64_scan_reuse_walk(ctx, bmap, preds, vd, t, Bool.pick(List<&2, IrOp>, U32.is_lt(id, 1024), ops1, Nil{}), id, term1, RVEmpty{}, brm)
    case _ Con{ITake{+ds, +s}, +t}: (+nt = b5k_u32_list_len(ds); +cls = x64_cls_fit(nt); +st = Bool.pick(U32, Bool.and(Bool.and(U32.is_gt(nt, 0), U32.is_le(nt, 8)), Bool.and(Bool.not(x64_u32_in(s, ds)), Bool.and(Bool.not(x64_is_u2_src(ctx, s)), Bool.and(Bool.not(x64_is_bor(ctx, s)), Bool.and(Bool.not(ra_vec_get(Bool, vd, False{}, s, seen)), Bool.not(ra_vec_get(Bool, vd, False{}, s, ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, bid, brm)))))))), x64_find_reuse_ops(ctx, vd, s, cls, t, 2), 0); +tu = U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_term(vd, term, RVEmpty{})), 0); hits = Bool.pick(List<&2, U32>, U32.is_eq(st, 1), Bool.pick(List<&2, U32>, tu, Nil{}, Con{bid, Nil{}}), Bool.pick(List<&2, U32>, U32.is_eq(st, 2), x64_ru_walk(24n, True{}, tu, ctx, bmap, preds, vd, s, cls, bid, term, None{}), Nil{})); x64_scan_reuse_walk(ctx, bmap, preds, vd, blks, t, bid, term, ra_vec_set(Bool, vd, s, True{}, seen), x64_ru_mark(vd, s, x64_ru_both(Con{bid, Nil{}}, hits), brm)))
    case _ Con{IReuse{_, s, _, _}, t}: x64_scan_reuse_walk(ctx, bmap, preds, vd, blks, t, bid, term, ra_vec_set(Bool, vd, s, True{}, seen), brm)
    case _ Con{_, t}: x64_scan_reuse_walk(ctx, bmap, preds, vd, blks, t, bid, term, seen, brm)
def x64_blk_preds_go(blks: List<&2, IrBlock>, ps: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: ps
    case Con{IrBlock{_, _, TJmp{tgt}}, t}: x64_blk_preds_go(t, x64_ru_inc(tgt, ps))
    case Con{IrBlock{_, _, TBr{_, tb, fb}}, t}: x64_blk_preds_go(t, x64_ru_inc(fb, x64_ru_inc(tb, ps)))
    case Con{IrBlock{_, _, TSwitch{_, arms, db}}, t}: x64_blk_preds_go(t, x64_ru_inc(db, x64_ru_arms(arms, ps)))
    case Con{_, t}: x64_blk_preds_go(t, ps)
def x64_ru_go(has: Bool, ctx: X64Ctx, vd: Nat, +blks: List<&2, IrBlock>) -> RaVec<RaVec<Bool>>:
  match has:
    case False{}: RVEmpty{}
    case True{}: x64_scan_reuse_walk(ctx, opt_index_blks(blks, RVEmpty{}), x64_blk_preds_go(blks, ra_vec_set(U32, 5n, 0, 2, RVEmpty{})), vd, blks, Nil{}, 0, TJmp{0}, RVEmpty{}, RVEmpty{})
def x64_blk_preds(blks: List<&2, IrBlock>) -> RaVec<U32>:
  match blks:
    case Con{b0, Con{b1, Con{b2, t}}}: x64_blk_preds_go(Con{b0, Con{b1, Con{b2, t}}}, ra_vec_set(U32, 5n, 0, 2, RVEmpty{}))
    case _: RVEmpty{}
def x64_blk_head_id(blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 4294967295
    case Con{IrBlock{id, _, _}, _}: id
def x64_emit_cmov_cc(reuse_lr: Bool, +ctx: X64Ctx, cc: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match reuse_lr:
    case True{}: x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, 0, x64_emit(XCmov{cc, 0, 1}, acc)))
    case False{}: (+vtloc = x64_vreg_loc(ctx, vt); +dloc = x64_vreg_loc(ctx, dst); +vtg = x64_is_gpr(vtloc); +vtreg = Bool.pick(U32, vtg, vtloc, 1); +dreg = Bool.pick(U32, Bool.and(x64_is_gpr(dloc), U32.is_ne(dloc, vtreg)), dloc, 0); x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, dreg, x64_emit(XCmov{cc, dreg, vtreg}, x64_opt_load_vreg(vtg, ctx, 1, vt, x64_load_vreg(ctx, dreg, ve, acc))))))
def x64_emit_cmov_sel(+ctx: X64Ctx, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{acc, lbl, cold}:
      +cloc = x64_vreg_loc(ctx, cond)
      +cg = x64_is_gpr(cloc)
      +creg = Bool.pick(U32, cg, cloc, 2)
      X64Acc{x64_emit_cmov_cc(False{}, ctx, 5, dst, vt, ve, j1, nxt, x64_emit(XTestRR{creg, creg}, x64_opt_load_vreg(cg, ctx, 2, cond, acc))), lbl, cold}
def x64_cmov_cc_go(+ctx: X64Ctx, +consts: RaVec<U32>, +cop: U32, cc: U32, +l: U32, +r: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  rlr = Bool.and(Bool.and(U32.is_zero(x64_const_val(ctx, consts, r)), Bool.and(Bool.not(x64_is_gpr(x64_vreg_loc(ctx, l))), Bool.not(x64_is_gpr(x64_vreg_loc(ctx, r))))), Bool.and(U32.is_eq(ve, l), U32.is_eq(vt, r)))
  X64Acc{x64_emit_cmov_cc(rlr, ctx, cc, dst, vt, ve, j1, nxt, x64_emit_cmp_flags(ctx, consts, cop, l, r, acc)), lbl, cold}
def x64_emit_ops_cmov(+ctx: X64Ctx, +fn_map: RaVec<String>, +reuse: RaVec<Bool>, ops: List<&2, IrOp>, step: X64Step, +uc: RaVec<U32>, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32) -> X64Acc:
  match ops step:
    case Nil{} X64Step{_, _, _, _, st}: x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, st)
    case Con{_, t} X64Step{1n+p, cs, fcs, xm0, st}: x64_emit_ops_cmov(ctx, fn_map, reuse, t, X64Step{p, cs, fcs, xm0, st}, uc, cond, dst, vt, ve, j1, nxt)
    case Con{ICmp{+cd, +cop, +l, +r}, Nil{}} X64Step{0n, +cs, _, _, X64Acc{+acc, +lbl, +cold}}: low_if(X64Acc, Bool.and(Bool.and(U32.is_lt(cop, 6), U32.is_eq(cd, cond)), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, cd, uc), 1)), _ => x64_cmov_cc_go(ctx, cs, cop, x64_cmp_cc(cop), l, r, dst, vt, ve, j1, nxt, acc, lbl, cold), _ => x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, cs, U32.is_ge(cop, 6), cond, cop, l, r, acc), lbl, cold}))
    case Con{ICmp{+t1, +cop1, +l1, +r1}, Con{ICmp{+cd, 0, +l2, +r2}, Nil{}}} X64Step{0n, +cs, _, _, X64Acc{+acc, +lbl, +cold}}: (+vd = x64_ctx_vd(ctx); low_if(X64Acc, Bool.and(Bool.and(U32.is_lt(cop1, 6), Bool.and(U32.is_eq(l2, t1), U32.is_eq(cd, cond))), Bool.and(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, t1, uc), 1), U32.is_eq(ra_vec_get(U32, vd, 0, cd, uc), 1)), U32.is_eq(x64_const_val(ctx, cs, r2), 1))), _ => x64_cmov_cc_go(ctx, cs, cop1, U32.xor(x64_cmp_cc(cop1), 1), l1, r1, dst, vt, ve, j1, nxt, acc, lbl, cold), _ => x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, x64_clr_const(vd, t1, cs), False{}, cond, 0, l2, r2, x64_emit_cmp_go(ctx, cs, U32.is_ge(cop1, 6), t1, cop1, l1, r1, acc)), lbl, cold})))
    case Con{ICmp{+t1, 2, +lx, +rc}, Con{IBin{+d1, 1, +l1, +r1}, Con{IBin{+d2, 1, +l2, +r2}, Con{ICmp{+cd, 0, +lc, +rz}, Nil{}}}}} X64Step{0n, +cs, _, _, X64Acc{+acc, +lbl, +cold}}: (+vd = x64_ctx_vd(ctx); +ok1 = Bool.and(Bool.and(Bool.and(U32.is_eq(l1, lx), U32.is_eq(r1, rc)), Bool.and(U32.is_eq(l2, rc), U32.is_eq(r2, lx))), Bool.and(Bool.and(U32.is_eq(lc, t1), U32.is_eq(cd, cond)), Bool.and(U32.is_eq(vt, d1), U32.is_eq(ve, d2)))); low_if(X64Acc, Bool.and(Bool.not(x64_no_dp_chk(ctx)), Bool.and(ok1, Bool.and(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, t1, uc), 1), U32.is_eq(ra_vec_get(U32, vd, 0, cd, uc), 1)), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, d1, uc), 1), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, d2, uc), 1), U32.is_eq(x64_const_val(ctx, cs, rz), 1)))))), _ => X64Acc{x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, 0, x64_emit(XCmov{2, 0, 2}, x64_emit(XAluRR{1, 0, 1}, x64_emit(XAluRR{1, 2, 0}, x64_emit(XMovRR{2, 1}, x64_load_vreg(ctx, 1, rc, x64_load_vreg(ctx, 0, lx, acc)))))))), lbl, cold}, _ => +c1 = x64_clr_const(vd, t1, cs); +c2 = x64_clr_const(vd, d1, c1); a1 = x64_emit_bin_go(ctx, False{}, False{}, c1, RVEmpty{}, 0, d1, 1, l1, r1, lbl, x64_emit_cmp_go(ctx, cs, False{}, t1, 2, lx, rc, acc)); x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, x64_clr_const(vd, d2, c2), False{}, cd, 0, lc, rz, x64_emit_bin_go(ctx, False{}, False{}, c2, RVEmpty{}, 0, d2, 1, l2, r2, U32.add(lbl, 1), a1)), U32.add(lbl, 2), cold})))
    case Con{op1, +t1} X64Step{0n, consts, fconsts, xm0, X64Acc{acc, lbl, cold}}: x64_emit_ops_cmov(ctx, fn_map, reuse, t1, x64_emit_ops_step(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl), uc, cond, dst, vt, ve, j1, nxt)
def x64_emit_one_blk(+ctx: X64Ctx, +fn_map: RaVec<String>, +uc: RaVec<U32>, +brm: RaVec<RaVec<Bool>>, +id: U32, ops: List<&2, IrOp>, term: IrTerm, nxt: U32, st: X64Acc) -> X64Acc:
  X64Acc{acc, lbl, cold} = st
  x64_emit_ops_fused(ctx, fn_map, Bool.pick(RaVec<Bool>, U32.is_lt(id, 1024), ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, id, brm), RVEmpty{}), ops, X64Step{0n, RVEmpty{}, RVEmpty{}, 0, X64Acc{x64_emit(XLabel{id}, acc), lbl, cold}}, uc, term, nxt)
def x64_emit_blocks(+ctx: X64Ctx, +fn_map: RaVec<String>, +uc: RaVec<U32>, +brm: RaVec<RaVec<Bool>>, +preds: RaVec<U32>, blks: List<&2, IrBlock>, skip: Nat, st: X64Acc) -> X64Acc:
  match blks skip:
    case Nil{} _: st
    case Con{_, t} 1n+p: x64_emit_blocks(ctx, fn_map, uc, brm, preds, t, p, st)
    case Con{IrBlock{id, ops, term}, Nil{}} 0n: x64_emit_one_blk(ctx, fn_map, uc, brm, id, ops, term, 4294967295, st)
    case Con{IrBlock{+id0, +ops0, TBr{+cond, +tb, +eb}}, Con{IrBlock{+id1, Con{ICopy{+d1, +v1}, Nil{}}, TJmp{+j1}}, Con{IrBlock{+id2, Con{ICopy{+d2, +v2}, Nil{}}, TJmp{+j2}}, +t3}}} 0n:
      X64Acc{+acc, +lbl, +cold} = st
      +o1 = Bool.and(U32.is_eq(id1, tb), U32.is_eq(id2, eb))
      +o2 = Bool.and(U32.is_eq(id1, eb), U32.is_eq(id2, tb))
      +ok = Bool.and(Bool.and(x64_is_o2(ctx), Bool.and(U32.is_eq(d1, d2), Bool.and(U32.is_eq(j1, j2), U32.is_ne(tb, eb)))), Bool.and(Bool.or(o1, o2), Bool.and(Bool.and(U32.is_lt(id1, 1024), U32.is_lt(id2, 1024)), Bool.and(U32.is_eq(ra_vec_get(U32, 5n, 0, id1, preds), 1), U32.is_eq(ra_vec_get(U32, 5n, 0, id2, preds), 1)))))
      st1 = low_if(X64Acc, ok, _ => x64_emit_ops_cmov(ctx, fn_map, Bool.pick(RaVec<Bool>, U32.is_lt(id0, 1024), ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, id0, brm), RVEmpty{}), ops0, X64Step{0n, RVEmpty{}, RVEmpty{}, 0, X64Acc{x64_emit(XLabel{id0}, acc), lbl, cold}}, uc, cond, d1, Bool.pick(U32, o1, v1, v2), Bool.pick(U32, o1, v2, v1), j1, x64_blk_head_id(t3)), _ => x64_emit_one_blk(ctx, fn_map, uc, brm, id0, ops0, TBr{cond, tb, eb}, id1, X64Acc{acc, lbl, cold}))
      x64_emit_blocks(ctx, fn_map, uc, brm, preds, Con{IrBlock{id1, Con{ICopy{d1, v1}, Nil{}}, TJmp{j1}}, Con{IrBlock{id2, Con{ICopy{d2, v2}, Nil{}}, TJmp{j2}}, t3}}, Bool.pick(Nat, ok, 2n, 0n), st1)
    case Con{IrBlock{id, ops, term}, Con{IrBlock{+nid, nops, nterm}, t2}} 0n: x64_emit_blocks(ctx, fn_map, uc, brm, preds, Con{IrBlock{nid, nops, nterm}, t2}, 0n, x64_emit_one_blk(ctx, fn_map, uc, brm, id, ops, term, nid, st))
def x64_lower_fn(fn_map: RaVec<String>, heap_off: U32, f: IrFn) -> X64Fn:
  match f:
    case IrFn{_, name, +arity, +nregs, _, _, _, blocks}:
      scr = U32.add(16, U32.mul(U32.max(16, arity), 8))
      +frame = x64_align16(U32.add(scr, U32.mul(U32.max(nregs, arity), 8)))
      +ctx : X64Ctx = X64Ctx{False{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, frame, Nil{}, heap_off, x64_empty_meta()}
      a0 = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_save_params_go(ctx, U32.to_nat(arity), 0, a0)
      X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_blocks(ctx, fn_map, RVEmpty{}, RVEmpty{}, RVEmpty{}, blocks, 0n, X64Acc{a1, 2147483648, Nil{}})))}
def x64_pick_free_callee(+ce: List<&2, U32>) -> U32: Bool.pick(U32, x64_u32_in(15, ce), Bool.pick(U32, x64_u32_in(14, ce), Bool.pick(U32, x64_u32_in(13, ce), Bool.pick(U32, x64_u32_in(12, ce), Bool.pick(U32, x64_u32_in(3, ce), 0, 3), 12), 13), 14), 15)
def x64_init_mem(has_r: Bool, has_d: Bool, mr: U32, md: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r has_d:
    case True{} _: x64_emit(XLoad{mr, 7, 0}, acc)
    case False{} True{}: x64_emit(XStore{5, md, 0}, x64_emit(XLoad{0, 7, 0}, acc))
    case False{} False{}: acc
type X64DefSt is Data:
  X64DefSt{c31: RaVec<U32>, sc: RaVec<U32>, nf: Bool, stc: Bool, harr: Bool, hc: Bool}
def x64_msc(+tag: U32, +vd: Nat, arity: U32, +v: U32, +m: RaVec<U32>) -> RaVec<U32>: (+cur = ra_vec_get(U32, vd, 0, v, m); ra_vec_set_if(U32, vd, Bool.and(U32.is_ge(v, arity), Bool.or(U32.is_zero(cur), Bool.and(U32.is_eq(tag, 1), U32.is_eq(cur, 2)))), v, tag, m))
def x64_mc(+vd: Nat, arity: U32, +v: U32, val: U32, +m: RaVec<U32>) -> RaVec<U32>: (ok = Bool.and(U32.is_ge(v, arity), U32.is_zero(ra_vec_get(U32, vd, 0, v, m))); Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, vd, v, U32.add(val, 1), m), ra_vec_set(U32, vd, v, 4294967295, m)))
def x64_m2(vd: Nat, v: U32, m: RaVec<U32>) -> RaVec<U32>: ra_vec_set(U32, vd, v, 4294967295, m)
def x64_def_pak(+vd: Nat, arity: U32, +d: U32, cid: U32, f0: U32, +sc: RaVec<U32>) -> RaVec<U32> & Bool: (+is_pak = Bool.and(U32.is_ge(cid, 39), U32.is_eq(ra_vec_get(U32, vd, 0, f0, sc), 2)); (Bool.pick(RaVec<U32>, is_pak, x64_msc(1, vd, arity, d, sc), x64_m2(vd, d, sc)), is_pak))
def x64_def_op(+vd: Nat, +arity: U32, op: IrOp, st: X64DefSt) -> X64DefSt:
  match op st:
    case IConst{+d, +val} X64DefSt{+c31, sc, nf, stc, ha, hc}: (c1 = Bool.pick(RaVec<U32>, U32.is_lt(val, 2147483647), x64_mc(vd, arity, d, val, c31), x64_m2(vd, d, c31)); X64DefSt{c1, x64_msc(2, vd, arity, d, sc), nf, stc, ha, hc})
    case IFlt{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(2, vd, arity, d, sc), nf, stc, ha, hc}
    case IBin{+d, _, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(2, vd, arity, d, sc), nf, stc, ha, hc}
    case IUn{+d, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(2, vd, arity, d, sc), nf, stc, ha, hc}
    case ICmp{+d, _, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(1, vd, arity, d, sc), nf, stc, ha, hc}
    case ITag{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(1, vd, arity, d, sc), nf, stc, ha, hc}
    case ICtor{+d, _, Nil{}} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(1, vd, arity, d, sc), nf, stc, ha, hc}
    case ICtor{+d, cid, Con{f0, Nil{}}} X64DefSt{c31, sc, nf, stc, ha, hc}: ra_un_pair(RaVec<U32>, Bool, X64DefSt, x64_def_pak(vd, arity, d, cid, f0, sc), sc1 => is_pak => X64DefSt{x64_m2(vd, d, c31), sc1, Bool.or(nf, Bool.not(is_pak)), stc, ha, hc})
    case ICtor{+d, _, Con{_, _}} X64DefSt{c31, sc, _, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, hc}
    case ICopy{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case IStatic{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case ILut{+d, _, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_msc(2, vd, arity, d, sc), nf, stc, ha, hc}
    case ILoad{+d, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case IStore{_, _, _} _: st
    case ITake{Nil{}, _} _: st
    case IArrOp{+ds, +aop, _} X64DefSt{c31, sc, _, stc, ha, hc}:
      +is_ha = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81)))
      +is_sa = U32.is_ge(aop, 1000)
      X64DefSt{ra_vec_set_all(U32, vd, 4294967295, ds, c31), ra_vec_set_all(U32, vd, 4294967295, ds, sc), True{}, stc, Bool.or(ha, is_ha), Bool.or(hc, Bool.not(Bool.or(is_ha, Bool.or(is_sa, U32.is_eq(aop, 75)))))}
    case IReuse{+d, _, cid, Con{f0, Nil{}}} X64DefSt{c31, sc, _, stc, ha, _}: ra_un_pair(RaVec<U32>, Bool, X64DefSt, x64_def_pak(vd, arity, d, cid, f0, sc), sc1 => _ => X64DefSt{x64_m2(vd, d, c31), sc1, True{}, stc, ha, True{}})
    case IAlloca{+d, _} X64DefSt{c31, sc, _, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, hc}
    case o X64DefSt{c31, sc, _, stc, ha, _}: (+ds = opt_op_dsts(o); X64DefSt{ra_vec_set_all(U32, vd, 4294967295, ds, c31), ra_vec_set_all(U32, vd, 4294967295, ds, sc), True{}, stc, ha, True{}})
def x64_def_term(+fn_fid: U32, term: IrTerm, st: X64DefSt) -> X64DefSt:
  match term st:
    case TTailCall{fid, args} X64DefSt{c31, sc, nf, stc, ha, hc}: (+is_st = Bool.and(U32.is_eq(fid, fn_fid), U32.is_le(b5k_u32_list_len(args), 64)); X64DefSt{c31, sc, Bool.or(nf, Bool.not(is_st)), Bool.or(stc, is_st), ha, Bool.or(hc, Bool.not(is_st))})
    case TFail{_} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{c31, sc, True{}, stc, ha, True{}}
    case _ _: st
def x64_def_blks(+vd: Nat, +arity: U32, +fn_fid: U32, blks: List<&2, IrBlock>, st: X64DefSt) -> X64DefSt: opt_foldl3(~IrBlock, ~Nat, ~U32, ~U32, ~X64DefSt, ~(v => ar => ff => b => s => opt_un_blk(X64DefSt, b, _ => ops1 => term => opt_foldl2(~IrOp, ~Nat, ~U32, ~X64DefSt, ~(v1 => a1 => op => s1 => x64_def_op(v1, a1, op, s1)), v, ar, ops1, x64_def_term(ff, term, s)))), vd, arity, fn_fid, blks, st)
type X64HiSt is Data:
  X64HiSt{hu: RaVec<Bool>, cm: RaVec<Bool>}
def x64_hi_set(vd: Nat, v: U32, hu: RaVec<Bool>) -> RaVec<Bool>: ra_vec_set(Bool, vd, v, True{}, hu)
def x64_hi_set_if(cond: Bool, vd: Nat, v: U32, hu: RaVec<Bool>) -> RaVec<Bool>: ra_vec_set_if(Bool, vd, cond, v, True{}, hu)
def x64_hi_both(+vd: Nat, +v: U32, st: X64HiSt) -> X64HiSt:
  X64HiSt{hu, cm} = st
  X64HiSt{x64_hi_set(vd, v, hu), x64_hi_set(vd, v, cm)}
def x64_hi_boths(+vd: Nat, +vs: List<&2, U32>, st: X64HiSt) -> X64HiSt:
  X64HiSt{hu, cm} = st
  X64HiSt{ra_vec_set_all(Bool, vd, True{}, vs, hu), ra_vec_set_all(Bool, vd, True{}, vs, cm)}
def x64_hi_op(+vd: Nat, +cval: RaVec<U32>, op: IrOp, st: X64HiSt) -> X64HiSt:
  match op st:
    case IBin{_, +bop, +l, +r} X64HiSt{+hu, cm}:
      +rv = ra_vec_get(U32, vd, 0, r, cval)
      +c = U32.sub(rv, 1)
      r_fold = Bool.or(Bool.or(x64_is_simple_alu(bop), U32.is_eq(bop, 15)), Bool.and(x64_is_cval(rv), Bool.or(Bool.and(Bool.or(U32.is_eq(bop, 8), Bool.or(U32.is_eq(bop, 9), U32.is_eq(bop, 16))), U32.is_lt(c, 64)), Bool.or(Bool.and(U32.is_eq(bop, 2), x64_is_mul_sr(c)), Bool.and(Bool.or(U32.is_eq(bop, 3), U32.is_eq(bop, 4)), U32.is_ge(c, 2))))))
      hu1 = Bool.pick(RaVec<Bool>, Bool.or(U32.is_le(bop, 2), U32.is_eq(bop, 16)), hu, Bool.pick(RaVec<Bool>, U32.is_eq(bop, 8), x64_hi_set(vd, r, hu), Bool.pick(RaVec<Bool>, U32.is_eq(bop, 5), x64_hi_set_if(Bool.not(x64_is_cval(ra_vec_get(U32, vd, 0, l, cval))), vd, r, x64_hi_set_if(Bool.not(x64_is_cval(rv)), vd, l, hu)), x64_hi_set(vd, r, x64_hi_set(vd, l, hu)))))
      X64HiSt{hu1, x64_hi_set_if(Bool.not(r_fold), vd, r, x64_hi_set(vd, l, cm))}
    case IUn{_, +uop, +s} X64HiSt{hu, cm}:
      +sv = ra_vec_get(U32, vd, 0, s, cval)
      s_fold = Bool.and(U32.is_eq(uop, 4), Bool.and(x64_is_cval(sv), U32.is_le(U32.sub(sv, 1), 65535)))
      X64HiSt{x64_hi_set_if(U32.is_ne(uop, 0), vd, s, hu), x64_hi_set_if(Bool.not(s_fold), vd, s, cm)}
    case ICmp{_, +cop, +l, +r} X64HiSt{hu, cm}: X64HiSt{x64_hi_set(vd, r, x64_hi_set(vd, l, hu)), x64_hi_set_if(U32.is_ge(cop, 6), vd, r, x64_hi_set(vd, l, cm))}
    case IArrOp{_, +aop, Con{a, Con{i, Con{+cv, Nil{}}}}} X64HiSt{hu, cm}: (is_rmw = Bool.and(Bool.or(U32.is_eq(aop, 80), U32.is_eq(aop, 81)), x64_is_cval(ra_vec_get(U32, vd, 0, cv, cval))); x64_hi_both(vd, i, x64_hi_both(vd, a, X64HiSt{x64_hi_set(vd, cv, hu), x64_hi_set_if(Bool.not(is_rmw), vd, cv, cm)})))
    case o _: x64_hi_boths(vd, opt_op_uses_list(o), st)
def x64_hi_blks(+vd: Nat, +cval: RaVec<U32>, blks: List<&2, IrBlock>, st: X64HiSt) -> X64HiSt: opt_foldl2(~IrBlock, ~Nat, ~RaVec<U32>, ~X64HiSt, ~(v => cv => b => s => (+v0 = v; opt_un_blk(X64HiSt, b, _ => ops1 => term => opt_foldl2(~IrOp, ~Nat, ~RaVec<U32>, ~X64HiSt, ~(v1 => c1 => op => s1 => x64_hi_op(v1, c1, op, s1)), v0, cv, ops1, x64_hi_boths(v0, opt_term_uses_list(term), s))))), vd, cval, blks, st)
def x64_nu_set(+vd: Nat, +arity: U32, ao: RaVec<U32>, +v: U32, nu: RaVec<Bool>) -> RaVec<Bool>: (+nu1 = x64_hi_set(vd, v, nu); +o = ra_vec_get(U32, vd, 0, v, ao); x64_hi_set_if(Bool.and(U32.is_gt(o, 0), U32.is_le(o, arity)), vd, U32.sub(o, 1), nu1))
def x64_nu_tc(+vd: Nat, args: List<&2, U32>, +idx: U32, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match args:
    case Nil{}: nu
    case Con{a, t}: x64_nu_tc(vd, t, U32.add(idx, 1), x64_hi_set_if(ra_vec_get(Bool, vd, False{}, idx, nu), vd, a, nu))
def x64_nu_bad_walk(+vd: Nat, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, bad: RaVec<Bool>) -> RaVec<Bool>:
  match blks ops:
    case Nil{} Nil{}: bad
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_nu_bad_walk(vd, t, ops1, bad)
    case _ Con{ITag{_, s}, ot}: x64_nu_bad_walk(vd, blks, ot, x64_hi_set(vd, s, bad))
    case _ Con{ITake{_, s}, ot}: x64_nu_bad_walk(vd, blks, ot, x64_hi_set(vd, s, bad))
    case _ Con{ICallDirect{_, _, args}, ot}: x64_nu_bad_walk(vd, blks, ot, ra_vec_set_all(Bool, vd, True{}, args, bad))
    case _ Con{ICallClosure{_, _, caps}, ot}: x64_nu_bad_walk(vd, blks, ot, ra_vec_set_all(Bool, vd, True{}, caps, bad))
    case _ Con{IApply{_, c, a}, ot}: x64_nu_bad_walk(vd, blks, ot, x64_hi_set(vd, a, x64_hi_set(vd, c, bad)))
    case _ Con{_, ot}: x64_nu_bad_walk(vd, blks, ot, bad)
def x64_nu_term(vd: Nat, arity: U32, fn_fid: U32, ao: RaVec<U32>, term: IrTerm, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match term:
    case TBr{c, _, _}: x64_nu_set(vd, arity, ao, c, nu)
    case TTailCall{fid, args}: Bool.pick(RaVec<Bool>, U32.is_eq(fid, fn_fid), x64_nu_tc(vd, args, 0, nu), nu)
    case _: nu
def x64_nu_walk(+vd: Nat, +arity: U32, +fn_fid: U32, +ao: RaVec<U32>, +bad: RaVec<Bool>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, term: IrTerm, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match blks ops:
    case Nil{} Nil{}: x64_nu_term(vd, arity, fn_fid, ao, term, nu)
    case Con{IrBlock{_, ops1, term1}, t} Nil{}: x64_nu_walk(vd, arity, fn_fid, ao, bad, t, ops1, term1, x64_nu_term(vd, arity, fn_fid, ao, term, nu))
    case _ Con{IBin{_, bop, +l, +r}, ot}: (ok = Bool.or(U32.is_ne(bop, 0), Bool.not(Bool.or(ra_vec_get(Bool, vd, False{}, l, bad), ra_vec_get(Bool, vd, False{}, r, bad)))); x64_nu_walk(vd, arity, fn_fid, ao, bad, blks, ot, term, Bool.pick(RaVec<Bool>, ok, x64_nu_set(vd, arity, ao, r, x64_nu_set(vd, arity, ao, l, nu)), nu)))
    case _ Con{IUn{_, _, s}, ot}: x64_nu_walk(vd, arity, fn_fid, ao, bad, blks, ot, term, x64_nu_set(vd, arity, ao, s, nu))
    case _ Con{ICmp{_, cop, l, r}, ot}: x64_nu_walk(vd, arity, fn_fid, ao, bad, blks, ot, term, Bool.pick(RaVec<Bool>, U32.is_ge(cop, 1), x64_nu_set(vd, arity, ao, r, x64_nu_set(vd, arity, ao, l, nu)), nu))
    case _ Con{_, ot}: x64_nu_walk(vd, arity, fn_fid, ao, bad, blks, ot, term, nu)
def x64_run_nu(do_n: Bool, +vd: Nat, arity: U32, fn_fid: U32, ao: RaVec<U32>, +blks: List<&2, IrBlock>) -> RaVec<Bool>:
  match do_n:
    case False{}: RVEmpty{}
    case True{}: x64_nu_walk(vd, arity, fn_fid, ao, x64_nu_bad_walk(vd, blks, Nil{}, RVEmpty{}), blks, Nil{}, TJmp{0}, RVEmpty{})
type X64HoistSt is Data:
  X64HoistSt{org: RaVec<U32>, used: RaVec<U32>, bad: RaVec<Bool>, sc_arr: RaVec<Bool>, wrap: RaVec<U32>}
def x64_hoist_init_org(+vd: Nat, n: Nat, +idx: U32, org: RaVec<U32>) -> RaVec<U32>:
  match n:
    case 0n: org
    case 1n+p: x64_hoist_init_org(vd, p, U32.add(idx, 1), ra_vec_set(U32, vd, idx, U32.add(idx, 1), org))
def x64_hoist_org(vd: Nat, v: U32, st: X64HoistSt) -> U32:
  match st:
    case X64HoistSt{org, _, _, _, _}: ra_vec_get(U32, vd, 0, v, org)
def x64_hoist_kill(+vd: Nat, +arity: U32, +d: U32, st: X64HoistSt) -> X64HoistSt:
  match st:
    case X64HoistSt{+org, used, +bad, sca, wr}:
      +is_p = U32.is_lt(d, arity)
      org1 = Bool.pick(RaVec<U32>, is_p, org, ra_vec_set(U32, vd, d, 4294967295, org))
      bad1 = Bool.pick(RaVec<Bool>, is_p, ra_vec_set(Bool, vd, d, True{}, bad), bad)
      X64HoistSt{org1, used, bad1, sca, wr}
def x64_hoist_kills(+vd: Nat, +arity: U32, ds: List<&2, U32>, st: X64HoistSt) -> X64HoistSt: opt_foldl2(~U32, ~Nat, ~U32, ~X64HoistSt, ~(v0 => ar0 => d => s => x64_hoist_kill(v0, ar0, d, s)), vd, arity, ds, st)
def x64_hoist_join(+cur: U32, +so: U32) -> U32:
  Bool.pick(U32, U32.is_zero(so), cur, Bool.pick(U32, Bool.or(U32.is_zero(cur), U32.is_eq(cur, so)), so, 4294967295))
def x64_hoist_prop_v(+vd: Nat, +arity: U32, +d: U32, +so: U32, st: X64HoistSt) -> X64HoistSt:
  match st:
    case X64HoistSt{+org, used, +bad, sca, wr}:
      +cur = ra_vec_get(U32, vd, 0, d, org)
      +is_p = U32.is_lt(d, arity)
      p_bad = Bool.and(is_p, U32.is_ne(so, U32.add(d, 1)))
      bad1 = Bool.pick(RaVec<Bool>, p_bad, ra_vec_set(Bool, vd, d, True{}, bad), bad)
      nv = x64_hoist_join(cur, so)
      org1 = Bool.pick(RaVec<U32>, is_p, org, ra_vec_set(U32, vd, d, nv, org))
      X64HoistSt{org1, used, bad1, sca, wr}
def x64_hoist_prop(+vd: Nat, +arity: U32, +d: U32, s: U32, +st: X64HoistSt) -> X64HoistSt: x64_hoist_prop_v(vd, arity, d, x64_hoist_org(vd, s, st), st)
def x64_hoist_wrap(+vd: Nat, +arity: U32, +d: U32, f0: U32, +st: X64HoistSt) -> X64HoistSt: (+fo = x64_hoist_org(vd, f0, st); ok = Bool.and(U32.is_gt(fo, 65536), U32.is_le(fo, U32.add(65536, arity))); Bool.pick(X64HoistSt, ok, x64_hoist_prop_v(vd, arity, d, U32.sub(fo, 65536), st), x64_hoist_kill(vd, arity, d, st)))
def x64_hoist_mark_use(+vd: Nat, +arity: U32, a: U32, is_nsc: Bool, st: X64HoistSt) -> X64HoistSt:
  match st:
    case X64HoistSt{+org, +used, +bad, +sca, +wr}:
      +ao = ra_vec_get(U32, vd, 0, a, org)
      +is_f0 = U32.is_ge(ao, 65536)
      +base = Bool.pick(U32, is_f0, U32.sub(ao, 65536), ao)
      +ok = Bool.and(U32.is_gt(base, 0), U32.is_le(base, arity))
      +pi = U32.sub(base, 1)
      +ww = Bool.pick(U32, is_f0, 2, 1)
      +cw = ra_vec_get(U32, vd, 0, pi, wr)
      bad1 = Bool.pick(RaVec<Bool>, Bool.and(ok, Bool.and(U32.is_ne(cw, 0), U32.is_ne(cw, ww))), ra_vec_set(Bool, vd, pi, True{}, bad), bad)
      wr1 = Bool.pick(RaVec<U32>, Bool.and(ok, U32.is_zero(cw)), ra_vec_set(U32, vd, pi, ww, wr), wr)
      used1 = Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, vd, pi, U32.add(ra_vec_get(U32, vd, 0, pi, used), 1), used), used)
      sca1 = Bool.pick(RaVec<Bool>, Bool.and(ok, is_nsc), ra_vec_set(Bool, vd, pi, True{}, sca), sca)
      X64HoistSt{org, used1, bad1, sca1, wr1}
def x64_hoist_arr_nsc(+vd: Nat, sc: RaVec<U32>, +aop: U32, args: List<&2, U32>) -> Bool:
  match args:
    case Con{_, Con{_, Con{v, _}}}: Bool.or(Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81)), Bool.and(Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 74)), U32.is_eq(ra_vec_get(U32, vd, 0, v, sc), 2)))
    case _: False{}
def x64_hoist_op(+vd: Nat, +arity: U32, sc: RaVec<U32>, op: IrOp, +st: X64HoistSt) -> X64HoistSt:
  match op:
    case ICopy{d, s}: x64_hoist_prop(vd, arity, d, s, st)
    case IArrOp{+dsts, +aop, +args}:
      match dsts args:
        case Con{+da, t} Con{+a, _}: (is_u = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81))); is_p = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 75)), Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81))); +st1 = Bool.pick(X64HoistSt, is_u, x64_hoist_mark_use(vd, arity, a, x64_hoist_arr_nsc(vd, sc, aop, args), st), st); st2 = Bool.pick(X64HoistSt, is_p, x64_hoist_prop(vd, arity, da, a, st1), x64_hoist_kill(vd, arity, da, st1)); x64_hoist_kills(vd, arity, t, st2))
        case _ _: x64_hoist_kills(vd, arity, dsts, st)
    case ITake{Con{+d0, t}, s}: (+so = x64_hoist_org(vd, s, st); ok = Bool.and(U32.is_gt(so, 0), U32.is_le(so, arity)); st1 = Bool.pick(X64HoistSt, ok, x64_hoist_prop_v(vd, arity, d0, U32.or(so, 65536), st), x64_hoist_kill(vd, arity, d0, st)); x64_hoist_kills(vd, arity, t, st1))
    case ITake{Nil{}, _}: st
    case ICtor{d, _, Con{f0, _}}: x64_hoist_wrap(vd, arity, d, f0, st)
    case IReuse{d, _, _, Con{f0, _}}: x64_hoist_wrap(vd, arity, d, f0, st)
    case _: (+d1 = opt_op_dst1(op); Bool.pick(X64HoistSt, U32.is_zero(d1), st, x64_hoist_kill(vd, arity, U32.sub(d1, 1), st)))
def x64_hoist_tc_args(+vd: Nat, args: List<&2, U32>, +idx: U32, +org: RaVec<U32>, +bad: RaVec<Bool>) -> RaVec<Bool>:
  match args:
    case Nil{}: bad
    case Con{a, t}: x64_hoist_tc_args(vd, t, U32.add(idx, 1), org, ra_vec_set_if(Bool, vd, U32.is_ne(ra_vec_get(U32, vd, 0, a, org), U32.add(idx, 1)), idx, True{}, bad))
def x64_hoist_term(vd: Nat, fn_fid: U32, term: IrTerm, st: X64HoistSt) -> X64HoistSt:
  match term st:
    case TTailCall{fid, args} X64HoistSt{+org, used, +bad, sca, wr}: X64HoistSt{org, used, Bool.pick(RaVec<Bool>, U32.is_eq(fid, fn_fid), x64_hoist_tc_args(vd, args, 0, org, bad), bad), sca, wr}
    case _ _: st
def x64_hoist_walk(+vd: Nat, +arity: U32, +fn_fid: U32, +sc: RaVec<U32>, blks: List<&2, IrBlock>, st: X64HoistSt) -> X64HoistSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops1, term1}, t}: x64_hoist_walk(vd, arity, fn_fid, sc, t, x64_hoist_term(vd, fn_fid, term1, opt_foldl3(~IrOp, ~Nat, ~U32, ~RaVec<U32>, ~X64HoistSt, ~(v1 => a1 => sc1 => op => s1 => x64_hoist_op(v1, a1, sc1, op, s1)), vd, arity, sc, ops1, st)))
type X64HPick is Data:
  X64HPick{h0: U32, h0_sc: Bool, h1: U32, h1_sc: Bool, h2: U32, h2_sc: Bool, hx: List<&2, X64Ha>}
def x64_hoist_pick_ext(+vd: Nat, n: Nat, +idx: U32, +min_u: U32, +used: RaVec<U32>, +bad: RaVec<Bool>, +sca: RaVec<Bool>, +wr: RaVec<U32>, +h0: U32, +h1: U32, +h2: U32, rem: Nat, +acc: List<&2, X64Ha>) -> List<&2, X64Ha>:
  match n rem:
    case 0n _: acc
    case _ 0n: acc
    case 1n+p 1n+r:
      +p1 = p; +r1 = r
      +u = ra_vec_get(U32, vd, 0, idx, used)
      +hid = Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, idx, wr), 2), U32.or(U32.add(idx, 1), 65536), U32.add(idx, 1))
      +ok = Bool.and(U32.is_ge(u, min_u), Bool.and(Bool.not(ra_vec_get(Bool, vd, False{}, idx, bad)), Bool.and(U32.is_ne(hid, h0), Bool.and(U32.is_ne(hid, h1), U32.is_ne(hid, h2)))))
      low_if(List<&2, X64Ha>, ok, _ => x64_hoist_pick_ext(vd, p1, U32.add(idx, 1), min_u, used, bad, sca, wr, h0, h1, h2, r1, Con{X64Ha{hid, 0, 0, ra_vec_get(Bool, vd, False{}, idx, sca)}, acc}), _ => x64_hoist_pick_ext(vd, p1, U32.add(idx, 1), min_u, used, bad, sca, wr, h0, h1, h2, 1n+r1, acc))
def x64_hoist_pick(+vd: Nat, n: Nat, +idx: U32, +min_u: U32, +used: RaVec<U32>, +bad: RaVec<Bool>, +sca: RaVec<Bool>, +wr: RaVec<U32>, +h0: U32, +u0: U32, +h0_sc: Bool, +h1: U32, +u1: U32, +h1_sc: Bool, +h2: U32, +u2: U32, +h2_sc: Bool) -> X64HPick:
  match n:
    case 0n: X64HPick{h0, h0_sc, h1, h1_sc, h2, h2_sc, Nil{}}
    case 1n+p: (+u = ra_vec_get(U32, vd, 0, idx, used); +ok = Bool.and(U32.is_ge(u, min_u), Bool.not(ra_vec_get(Bool, vd, False{}, idx, bad))); +is_sc = ra_vec_get(Bool, vd, False{}, idx, sca); +hid = Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, idx, wr), 2), U32.or(U32.add(idx, 1), 65536), U32.add(idx, 1)); +b0 = Bool.and(ok, U32.is_gt(u, u0)); +b1 = Bool.and(ok, Bool.and(Bool.not(b0), U32.is_gt(u, u1))); +b2 = Bool.and(ok, Bool.and(Bool.not(b0), Bool.and(Bool.not(b1), U32.is_gt(u, u2)))); x64_hoist_pick(vd, p, U32.add(idx, 1), min_u, used, bad, sca, wr, Bool.pick(U32, b0, hid, h0), Bool.pick(U32, b0, u, u0), Bool.pick(Bool, b0, is_sc, h0_sc), Bool.pick(U32, b0, h0, Bool.pick(U32, b1, hid, h1)), Bool.pick(U32, b0, u0, Bool.pick(U32, b1, u, u1)), Bool.pick(Bool, b0, h0_sc, Bool.pick(Bool, b1, is_sc, h1_sc)), Bool.pick(U32, Bool.or(b0, b1), h1, Bool.pick(U32, b2, hid, h2)), Bool.pick(U32, Bool.or(b0, b1), u1, Bool.pick(U32, b2, u, u2)), Bool.pick(Bool, Bool.or(b0, b1), h1_sc, Bool.pick(Bool, b2, is_sc, h2_sc))))
def x64_hoist_pick_fin(+vd: Nat, +arity: U32, +min_u: U32, +used: RaVec<U32>, +bad: RaVec<Bool>, +sca: RaVec<Bool>, +wr: RaVec<U32>, hp: X64HPick) -> X64HPick:
  X64HPick{+h0, h0_sc, +h1, h1_sc, +h2, h2_sc, _} = hp
  X64HPick{h0, h0_sc, h1, h1_sc, h2, h2_sc, Bool.pick(List<&2, X64Ha>, U32.is_ne(h2, 0), x64_hoist_pick_ext(vd, U32.to_nat(arity), 0, min_u, used, bad, sca, wr, h0, h1, h2, 5n, Nil{}), Nil{})}
def x64_hoist_pick_all(+vd: Nat, +arity: U32, +min_u: U32, +used: RaVec<U32>, +bad: RaVec<Bool>, +sca: RaVec<Bool>, +wr: RaVec<U32>) -> X64HPick:
  x64_hoist_pick_fin(vd, arity, min_u, used, bad, sca, wr, x64_hoist_pick(vd, U32.to_nat(arity), 0, min_u, used, bad, sca, wr, 0, 0, False{}, 0, 0, False{}, 0, 0, False{}))
def x64_hoist_org_set(+vd: Nat, +arity: U32, +d: U32, +so: U32, +org: RaVec<U32>) -> RaVec<U32>:
  nv = x64_hoist_join(ra_vec_get(U32, vd, 0, d, org), so)
  Bool.pick(RaVec<U32>, U32.is_lt(d, arity), org, ra_vec_set(U32, vd, d, nv, org))
def x64_hoist_org_kill(+vd: Nat, +arity: U32, +d: U32, +org: RaVec<U32>) -> RaVec<U32>:
  Bool.pick(RaVec<U32>, U32.is_lt(d, arity), org, ra_vec_set(U32, vd, d, 4294967295, org))
def x64_hoist_org_kills(+vd: Nat, +arity: U32, ds: List<&2, U32>, org: RaVec<U32>) -> RaVec<U32>:
  opt_foldl2(~U32, ~Nat, ~U32, ~RaVec<U32>, ~(v0 => ar0 => d => o => x64_hoist_org_kill(v0, ar0, d, o)), vd, arity, ds, org)
def x64_hoist_org_wrap(+vd: Nat, +arity: U32, +d: U32, f0: U32, +org: RaVec<U32>) -> RaVec<U32>:
  +fo = ra_vec_get(U32, vd, 0, f0, org)
  ok = Bool.and(U32.is_gt(fo, 65536), U32.is_le(fo, U32.add(65536, arity)))
  Bool.pick(
    RaVec<U32>,
    ok,
    x64_hoist_org_set(vd, arity, d, U32.sub(fo, 65536), org),
    x64_hoist_org_kill(vd, arity, d, org),
  )
def x64_hoist_org_op(+vd: Nat, +arity: U32, op: IrOp, +org: RaVec<U32>) -> RaVec<U32>:
  match op:
    case ICopy{d, s}: x64_hoist_org_set(vd, arity, d, ra_vec_get(U32, vd, 0, s, org), org)
    case IArrOp{+dsts, +aop, +args}:
      match dsts args:
        case Con{+da, t} Con{+a, _}:
          is_p = opt_stc_is_pass(aop)
          o1 = Bool.pick(
            RaVec<U32>,
            is_p,
            x64_hoist_org_set(vd, arity, da, ra_vec_get(U32, vd, 0, a, org), org),
            x64_hoist_org_kill(vd, arity, da, org),
          )
          x64_hoist_org_kills(vd, arity, t, o1)
        case _ _: x64_hoist_org_kills(vd, arity, dsts, org)
    case ITake{Con{+d0, t}, s}:
      +so = ra_vec_get(U32, vd, 0, s, org)
      ok = Bool.and(U32.is_gt(so, 0), U32.is_le(so, arity))
      o1 = Bool.pick(
        RaVec<U32>,
        ok,
        x64_hoist_org_set(vd, arity, d0, U32.or(so, 65536), org),
        x64_hoist_org_kill(vd, arity, d0, org),
      )
      x64_hoist_org_kills(vd, arity, t, o1)
    case ITake{Nil{}, _}: org
    case ICtor{+d, _, Con{f0, _}}: x64_hoist_org_wrap(vd, arity, d, f0, org)
    case IReuse{+d, _, _, Con{f0, _}}: x64_hoist_org_wrap(vd, arity, d, f0, org)
    case _:
      +d1 = opt_op_dst1(op)
      Bool.pick(RaVec<U32>, U32.is_zero(d1), org, x64_hoist_org_kill(vd, arity, U32.sub(d1, 1), org))
def x64_hoist_org_blks(+vd: Nat, +arity: U32, blks: List<&2, IrBlock>, org: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: org
    case Con{IrBlock{_, ops1, _}, t}:
      o1 = opt_foldl2(~IrOp, ~Nat, ~U32, ~RaVec<U32>, ~(v => a => op => o => x64_hoist_org_op(v, a, op, o)), vd, arity, ops1, org)
      x64_hoist_org_blks(vd, arity, t, o1)
def x64_hoist_org_pass(n: Nat, +vd: Nat, +arity: U32, +blks: List<&2, IrBlock>, org: RaVec<U32>) -> RaVec<U32>:
  match n:
    case 0n: org
    case 1n+p: x64_hoist_org_pass(p, vd, arity, blks, x64_hoist_org_blks(vd, arity, blks, org))
def x64_run_hoist(do_h: Bool, +vd: Nat, +arity: U32, fn_fid: U32, sc: RaVec<U32>, +blocks: List<&2, IrBlock>) -> X64HoistSt:
  match do_h:
    case False{}: X64HoistSt{RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}}
    case True{}:
      org = x64_hoist_org_pass(3n, vd, arity, blocks, x64_hoist_init_org(vd, U32.to_nat(arity), 0, RVEmpty{}))
      x64_hoist_walk(vd, arity, fn_fid, sc, blocks, X64HoistSt{org, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}})
def x64_init_hoist_one(+ctx: X64Ctx, +ha: U32, +dp: U32, mk: U32, st: X64Acc) -> X64Acc:
  X64Acc{acc, +lbl, +cold} = st
  x64_if1(List<&2, X64Inst>, X64Acc, U32.is_zero(ha), acc, a => X64Acc{a, lbl, cold}, a => a0 = x64_hoist_store(dp, 0, x64_emit(XAluRR{7, 0, 0}, x64_load_vreg(ctx, 6, U32.sub(U32.and(ha, 65535), 1), a))); a1 = x64_when(U32.is_ge(ha, 65536), a0, a_ => x64_emit(XLoad{6, 7, 0}, x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_arr_unsh_ptr(ctx, U32.add(lbl, 2), x64_arr_chk_tag(2, lbl, a_)))))); a3 = x64_hoist_store(mk, 0, x64_emit(XAluRI{1, 0, 1}, x64_arr_sz_r0(x64_arr_chk_tag(6, lbl, a1)))); a7 = x64_emit(XLabel{lbl}, x64_hoist_store(dp, 7, x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_arr_unsh_ptr(ctx, U32.add(lbl, 1), a3))))); X64Acc{a7, U32.add(lbl, 3), cold})
def x64_sw_pure_ops(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{IConst{_, _}, t}: x64_sw_pure_ops(t)
    case Con{ICmp{_, _, _, _}, t}: x64_sw_pure_ops(t)
    case Con{ITag{_, _}, t}: x64_sw_pure_ops(t)
    case Con{ICopy{_, _}, t}: x64_sw_pure_ops(t)
    case _: False{}
def x64_sw_is_dead_z(mb: Maybe<&2, IrBlock>, +p: U32, +nzb: U32, +fid: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, _, TFail{_}}}: True{}
    case Some{IrBlock{_, ops, TBr{c, _, _}}}: Bool.or(U32.is_eq(fid, nzb), Bool.and(U32.is_eq(c, p), x64_sw_pure_ops(ops)))
    case _: U32.is_eq(fid, nzb)
def x64_sw_chk_z(d2: Nat, mb: Maybe<&2, IrBlock>, +ar: U32, +p: U32, +nzb: U32, +rp0: U32, +bm: RaVec<Maybe<&2, IrBlock>>) -> U32:
  match d2 mb:
    case 1n+q Some{IrBlock{_, Nil{}, TRet{+rv}}}: Bool.pick(U32, U32.is_lt(rv, ar), U32.add(rv, 1), 0)
    case 1n+q Some{IrBlock{_, ops, TBr{_, +tb, +fb}}}: (+rp1 = Bool.pick(U32, x64_sw_pure_ops(ops), opt_esc_ret_param(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bm), ar), 0); +fb_b = ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bm); Bool.pick(U32, Bool.and(U32.is_ne(rp1, 0), Bool.or(U32.is_eq(opt_esc_ret_param(fb_b, ar), rp1), U32.is_ne(x64_sw_chk_z(q, fb_b, ar, p, nzb, rp1, bm), 0))), rp1, 0))
    case 0n Some{IrBlock{_, ops, TBr{_, +tb, +fb}}}: Bool.to_u32(Bool.and(x64_sw_pure_ops(ops), Bool.and(U32.is_eq(opt_esc_ret_param(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bm), ar), rp0), x64_sw_is_dead_z(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bm), p, nzb, fb))))
    case _ _: 0
def x64_sw_find(+ar: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Con{IrBlock{0, +ops0, TBr{+c0, +tb, +fb}}, rest}: (+zp = opt_esc_b0_pn(c0, ar, ops0, UM0{}); +p = Bool.pick(U32, U32.is_lt(c0, ar), c0, U32.sub(zp, 1)); +eb = Bool.pick(U32, U32.is_lt(c0, ar), fb, tb); +nzb = Bool.pick(U32, U32.is_lt(c0, ar), tb, fb); +ok = Bool.and(U32.is_le(ar, 5), Bool.and(Bool.or(U32.is_lt(c0, ar), U32.is_ne(zp, 0)), Bool.and(U32.is_lt(eb, 1024), x64_sw_pure_ops(ops0)))); +bm = opt_index_blks(rest, RVEmpty{}); +rp1 = Bool.pick(U32, ok, x64_sw_chk_z(1n, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, eb, bm), ar, p, nzb, 0, bm), 0); Bool.pick(U32, U32.is_ne(rp1, 0), U32.or(U32.shln(rp1, 4n), U32.add(p, 1)), 0))
    case _: 0
def x64_sw_is_pak_ret(mb: Maybe<&2, IrBlock>, +p: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, Con{ITake{Con{+d0, Nil{}}, +s}, Nil{}}, TRet{+rv}}}: Bool.and(U32.is_eq(s, p), U32.is_eq(rv, d0))
    case Some{IrBlock{_, Con{ITake{Con{+d0, Nil{}}, +s}, Con{IKeep{+d1, +s1}, Nil{}}}, TRet{+rv}}}: Bool.and(U32.is_eq(s, p), Bool.and(U32.is_eq(s1, d0), U32.is_eq(rv, d1)))
    case Some{IrBlock{_, Con{ITake{Con{+d0, Nil{}}, +s}, Con{ICopy{+d1, +s1}, Nil{}}}, TRet{+rv}}}: Bool.and(U32.is_eq(s, p), Bool.and(U32.is_eq(s1, d0), U32.is_eq(rv, d1)))
    case _: False{}
def x64_sw_tag_p(+ar: U32, +tr: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{ITag{d, +p}, t}: Bool.pick(U32, Bool.and(U32.is_eq(d, tr), U32.is_lt(p, ar)), U32.add(p, 1), x64_sw_tag_p(ar, tr, t))
    case Con{_, t}: x64_sw_tag_p(ar, tr, t)
def x64_sw_arms_pak(+p: U32, +bm: RaVec<Maybe<&2, IrBlock>>, arms: List<&2, IrSwitchArm>) -> U32:
  match arms:
    case Nil{}: 0
    case Con{IrArm{+cid, +tgt}, t}: (+ok = Bool.and(U32.is_ge(cid, 39), Bool.and(U32.is_lt(cid, 65536), Bool.and(U32.is_lt(tgt, 1024), x64_sw_is_pak_ret(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm), p)))); Bool.pick(U32, ok, cid, x64_sw_arms_pak(p, bm, t)))
def x64_sw_br_pak(+ar: U32, +c0: U32, +tb: U32, +fb: U32, +bm: RaVec<Maybe<&2, IrBlock>>, ops: List<&2, IrOp>, +cm: U32Map, +tm: U32Map) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IConst{d, v}, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, um_set(cm, d, U32.add(v, 1)), tm)
    case Con{ITag{d, +p}, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, Bool.pick(U32Map, U32.is_lt(p, ar), um_set(tm, d, U32.add(p, 1)), tm))
    case Con{ICmp{d, +cop, +l, +r}, t}: (+p1 = um_get(tm, l); +k1 = um_get(cm, r); +cid = U32.sub(k1, 1); +tgt = Bool.pick(U32, U32.is_zero(cop), tb, fb); +ok = Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_ne(p1, 0), Bool.and(U32.is_ne(k1, 0), Bool.and(U32.is_ge(cid, 39), Bool.and(U32.is_lt(cid, 65536), Bool.and(U32.is_lt(tgt, 1024), x64_sw_is_pak_ret(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm), U32.sub(p1, 1))))))))); Bool.pick(U32, ok, U32.or(16777216, U32.or(U32.shln(cid, 4n), p1)), x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, tm)))
    case Con{_, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, tm)
def x64_sw_find_pak(+ar: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Con{IrBlock{0, +ops0, TSwitch{s, arms, _}}, rest}: (+p1 = Bool.pick(U32, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_tag_p(ar, s, ops0), 0); +cid = Bool.pick(U32, U32.is_ne(p1, 0), x64_sw_arms_pak(U32.sub(p1, 1), opt_index_blks(rest, RVEmpty{}), arms), 0); Bool.pick(U32, U32.is_ne(cid, 0), U32.or(16777216, U32.or(U32.shln(cid, 4n), p1)), 0))
    case Con{IrBlock{0, +ops0, TBr{c0, tb, fb}}, rest}: Bool.pick(U32, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_br_pak(ar, c0, tb, fb, opt_index_blks(rest, RVEmpty{}), ops0, UM0{}, UM0{}), 0)
    case _: 0
type X64SwLeaf is Data:
  SwLeafNo{}
  SwLeaf{p: U32, cid: U32, ops: List<&2, IrOp>, rv: U32}
def x64_sw_leaf_is_sc(+vd: Nat, +is_sc: RaVec<U32>, v: U32) -> Bool: (+s = ra_vec_get(U32, vd, 0, v, is_sc); Bool.and(U32.is_ge(s, 1), U32.is_le(s, 2)))
def x64_sw_leaf_reg(+ar: U32, +dm: U32Map, +v: U32) -> Bool: Bool.or(U32.is_lt(v, ar), U32.is_eq(um_get(dm, v), 1))
def x64_sw_leaf_val(+ar: U32, +dm: U32Map, +v: U32) -> Bool: Bool.or(U32.is_lt(v, ar), U32.is_ne(um_get(dm, v), 0))
def x64_sw_leaf_chk(+vd: Nat, +ar: U32, +p: U32, +cid: U32, +is_sc: RaVec<U32>, ops: List<&2, IrOp>, +rv: U32, +dm: U32Map, +cm: U32Map, +nd: U32, +nops: U32) -> Bool:
  match ops:
    case Nil{}: Bool.and(U32.is_le(nops, 12), Bool.and(U32.is_le(nd, U32.sub(8, ar)), x64_sw_leaf_val(ar, dm, rv)))
    case Con{ITake{Con{+d0, Nil{}}, +s}, t}: Bool.and(U32.is_eq(s, p), Bool.and(U32.is_ge(cid, 39), Bool.and(U32.is_ge(d0, ar), Bool.and(U32.is_zero(um_get(dm, d0)), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d0, 1), cm, U32.add(nd, 1), U32.add(nops, 1))))))
    case Con{IConst{+d, +v}, t}: Bool.and(U32.is_lt(v, 2147483647), Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_zero(um_get(dm, d)), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d, 2), um_set(cm, d, U32.add(v, 1)), nd, U32.add(nops, 1)))))
    case Con{ICopy{+d, +s}, t}: Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_zero(um_get(dm, d)), Bool.and(x64_sw_leaf_val(ar, dm, s), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d, Bool.pick(U32, x64_sw_leaf_reg(ar, dm, s), 1, 2)), cm, nd, U32.add(nops, 1)))))
    case Con{IKeep{+d, +s}, t}: Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_zero(um_get(dm, d)), Bool.and(x64_sw_leaf_val(ar, dm, s), Bool.and(x64_sw_leaf_is_sc(vd, is_sc, s), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d, Bool.pick(U32, x64_sw_leaf_reg(ar, dm, s), 1, 2)), cm, nd, U32.add(nops, 1))))))
    case Con{ISink{+s}, t}: Bool.and(x64_sw_leaf_is_sc(vd, is_sc, s), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, dm, cm, nd, U32.add(nops, 1)))
    case Con{IUn{+d, +uop, +s}, t}: Bool.and(U32.is_le(uop, 1), Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_zero(um_get(dm, d)), Bool.and(x64_sw_leaf_reg(ar, dm, s), x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d, 1), cm, U32.add(nd, 1), U32.add(nops, 1))))))
    case Con{IBin{+d, +bop, +l, +r}, t}: (+is_sh = Bool.or(U32.is_eq(bop, 8), U32.is_eq(bop, 9)); +op_ok = Bool.or(U32.is_le(bop, 2), Bool.or(Bool.and(U32.is_ge(bop, 5), U32.is_le(bop, 9)), U32.is_eq(bop, 15))); +rc = um_get(cm, r); +r_ok = Bool.pick(Bool, is_sh, Bool.and(U32.is_ne(rc, 0), U32.is_lt(U32.sub(rc, 1), 64)), x64_sw_leaf_val(ar, dm, r)); Bool.and(op_ok, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_zero(um_get(dm, d)), Bool.and(x64_sw_leaf_reg(ar, dm, l), Bool.and(r_ok, x64_sw_leaf_chk(vd, ar, p, cid, is_sc, t, rv, um_set(dm, d, 1), cm, U32.add(nd, 1), U32.add(nops, 1))))))))
    case _: False{}
def x64_sw_try_blk(+vd: Nat, +ar: U32, +p: U32, +cid: U32, +is_sc: RaVec<U32>, mb: Maybe<&2, IrBlock>) -> X64SwLeaf:
  match mb:
    case Some{IrBlock{_, +lops, TRet{+rv}}}: Bool.pick(X64SwLeaf, x64_sw_leaf_chk(vd, ar, p, cid, is_sc, lops, rv, UM0{}, UM0{}, 0, 0), SwLeaf{p, cid, lops, rv}, SwLeafNo{})
    case _: SwLeafNo{}
def x64_sw_arms_leaf(+vd: Nat, +ar: U32, +p: U32, +is_sc: RaVec<U32>, +bm: RaVec<Maybe<&2, IrBlock>>, arms: List<&2, IrSwitchArm>, cur: X64SwLeaf) -> X64SwLeaf:
  match arms cur:
    case _ SwLeaf{p1, c1, o1, rv1}: SwLeaf{p1, c1, o1, rv1}
    case Nil{} SwLeafNo{}: SwLeafNo{}
    case Con{IrArm{+cid, +tgt}, t} SwLeafNo{}: x64_sw_arms_leaf(vd, ar, p, is_sc, bm, t, Bool.pick(X64SwLeaf, Bool.and(U32.is_lt(cid, 65536), U32.is_lt(tgt, 1024)), x64_sw_try_blk(vd, ar, p, cid, is_sc, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm)), SwLeafNo{}))
def x64_sw_br_leaf(+vd: Nat, +ar: U32, +c0: U32, +tb: U32, +fb: U32, +is_sc: RaVec<U32>, +bm: RaVec<Maybe<&2, IrBlock>>, ops: List<&2, IrOp>, +cm: U32Map, +tm: U32Map) -> X64SwLeaf:
  match ops:
    case Nil{}: SwLeafNo{}
    case Con{IConst{d, v}, t}: x64_sw_br_leaf(vd, ar, c0, tb, fb, is_sc, bm, t, um_set(cm, d, U32.add(v, 1)), tm)
    case Con{ITag{d, +p}, t}: x64_sw_br_leaf(vd, ar, c0, tb, fb, is_sc, bm, t, cm, Bool.pick(U32Map, U32.is_lt(p, ar), um_set(tm, d, U32.add(p, 1)), tm))
    case Con{ICmp{d, +cop, +l, +r}, t}: (+p1 = um_get(tm, l); +k1 = um_get(cm, r); +cid = U32.sub(k1, 1); +tgt = Bool.pick(U32, U32.is_zero(cop), tb, fb); +ok = Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_ne(p1, 0), Bool.and(U32.is_ne(k1, 0), Bool.and(U32.is_lt(cid, 65536), U32.is_lt(tgt, 1024)))))); Bool.pick(X64SwLeaf, ok, x64_sw_try_blk(vd, ar, U32.sub(p1, 1), cid, is_sc, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm)), x64_sw_br_leaf(vd, ar, c0, tb, fb, is_sc, bm, t, cm, tm)))
    case Con{_, t}: x64_sw_br_leaf(vd, ar, c0, tb, fb, is_sc, bm, t, cm, tm)
def x64_sw_find_leaf(+vd: Nat, +ar: U32, +is_sc: RaVec<U32>, blks: List<&2, IrBlock>) -> X64SwLeaf:
  match blks:
    case Con{IrBlock{0, +ops0, TSwitch{s, arms, _}}, rest}: (+p1 = Bool.pick(U32, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_tag_p(ar, s, ops0), 0); Bool.pick(X64SwLeaf, U32.is_ne(p1, 0), x64_sw_arms_leaf(vd, ar, U32.sub(p1, 1), is_sc, opt_index_blks(rest, RVEmpty{}), arms, SwLeafNo{}), SwLeafNo{}))
    case Con{IrBlock{0, +ops0, TBr{c0, tb, fb}}, rest}: Bool.pick(X64SwLeaf, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_br_leaf(vd, ar, c0, tb, fb, is_sc, opt_index_blks(rest, RVEmpty{}), ops0, UM0{}, UM0{}), SwLeafNo{})
    case _: SwLeafNo{}
def x64_sw_init_v2r(n: Nat, +i: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: x64_sw_init_v2r(p, U32.add(i, 1), um_set(m, i, U32.add(x64_arg_reg(i), 1)))
def x64_sw_free_regs(+ar: U32) -> List<&2, U32>: b5k_list_app(U32, [10, 11, 7], low_drop(U32, U32.to_nat(ar), [6, 2, 1, 8, 9]))
def x64_sw_emit_bin(+bop: U32, +rd: U32, +rl: U32, +rr: U32, +rc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a0 = x64_emit_if(U32.is_ne(rd, rl), XMovRR{rd, rl}, acc)
  x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(rc, 0), a0, a => (+c = U32.sub(rc, 1); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(bop, 2), a, a1 => x64_emit(XMul{rd, 0}, x64_emit(XMovRI32{0, c}, a1)), a1 => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, Bool.or(U32.is_eq(bop, 8), U32.is_eq(bop, 9)), a1, a2 => x64_opt_mask32(U32.is_eq(bop, 8), rd, x64_emit(XShift{bop, rd, c, False{}}, a2)), a2 => x64_opt_mask32(U32.is_le(bop, 1), rd, x64_emit(XAluRI{Bool.pick(U32, U32.is_eq(bop, 15), 1, bop), rd, c}, a2))))), a => x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_eq(bop, 2), a, a1 => x64_emit(XMul{rd, rr}, a1), a1 => x64_opt_mask32(U32.is_le(bop, 1), rd, x64_emit(XAluRR{Bool.pick(U32, U32.is_eq(bop, 15), 1, bop), rd, rr}, a1))))
def x64_sw_emit_ops(+preg: U32, ops: List<&2, IrOp>, +rv: U32, +v2r: U32Map, +cm: U32Map, free: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ops free:
    case Nil{} _: (+rc = um_get(cm, rv); x64_emit(XLabel{2147614719}, x64_emit(XRet{}, x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(rc, 0), acc, a => x64_emit(XMovRI32{0, U32.sub(rc, 1)}, a), a => x64_emit(XMovRR{0, U32.sub(um_get(v2r, rv), 1)}, a)))))
    case Con{IConst{d, v}, t} fs: x64_sw_emit_ops(preg, t, rv, v2r, um_set(cm, d, U32.add(v, 1)), fs, acc)
    case Con{ICopy{+d, +s}, t} fs: x64_sw_emit_ops(preg, t, rv, um_set(v2r, d, um_get(v2r, s)), um_set(cm, d, um_get(cm, s)), fs, acc)
    case Con{IKeep{+d, +s}, t} fs: x64_sw_emit_ops(preg, t, rv, um_set(v2r, d, um_get(v2r, s)), um_set(cm, d, um_get(cm, s)), fs, acc)
    case Con{ISink{_}, t} fs: x64_sw_emit_ops(preg, t, rv, v2r, cm, fs, acc)
    case Con{ITake{Con{d0, Nil{}}, _}, t} Con{+rd, ft}: x64_sw_emit_ops(preg, t, rv, um_set(v2r, d0, U32.add(rd, 1)), cm, ft, x64_mask40(rd, x64_emit(XMovRR{rd, preg}, acc)))
    case Con{IUn{d, +uop, s}, t} Con{+rd, ft}: (+rl = U32.sub(um_get(v2r, s), 1); a1 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_zero(uop), acc, a => x64_mask32(rd, x64_emit(XAluRR{1, rd, rl}, x64_emit(XMovRI32{rd, 0}, a))), a => x64_mask32(rd, x64_emit(XAluRI{7, rd, 4294967295}, x64_emit(XMovRR{rd, rl}, a)))); x64_sw_emit_ops(preg, t, rv, um_set(v2r, d, U32.add(rd, 1)), cm, ft, a1))
    case Con{IBin{d, bop, l, +r}, t} Con{+rd, ft}: x64_sw_emit_ops(preg, t, rv, um_set(v2r, d, U32.add(rd, 1)), cm, ft, x64_sw_emit_bin(bop, rd, U32.sub(um_get(v2r, l), 1), U32.sub(um_get(v2r, r), 1), um_get(cm, r), acc))
    case _ _: acc
def x64_sw_emit_leaf(+ar: U32, lf: X64SwLeaf, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match lf:
    case SwLeafNo{}: acc
    case SwLeaf{+p, +cid, ops, rv}: (+preg = x64_arg_reg(p); a1 = x64_emit(XJcc{5, 2147614719}, x64_emit(XCmpRI{0, U32.or(65536, cid)}, x64_emit(XShift{9, 0, 40, False{}}, x64_emit(XMovRR{0, preg}, acc)))); x64_sw_emit_ops(preg, ops, rv, x64_sw_init_v2r(U32.to_nat(ar), 0, UM0{}), UM0{}, x64_sw_free_regs(ar), a1))
def x64_sw_pre(+ar: U32, +sw: U32, lf: X64SwLeaf, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match sw:
    case 0: x64_sw_emit_leaf(ar, lf, acc)
    case +code: (+preg = x64_arg_reg(U32.sub(U32.and(code, 15), 1)); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ne(U32.and(code, 16777216), 0), acc, a => a1 = x64_emit(XJcc{5, 2147614719}, x64_emit(XCmpRI{0, U32.or(65536, U32.and(U32.shrn(code, 4n), 65535))}, x64_emit(XShift{9, 0, 40, False{}}, x64_emit(XMovRR{0, preg}, a)))); x64_emit(XLabel{2147614719}, x64_emit(XRet{}, x64_mask40(0, x64_emit(XMovRR{0, preg}, a1)))), a => x64_emit(XLabel{2147614719}, x64_emit(XRet{}, x64_emit(XMovRR{0, x64_arg_reg(U32.sub(U32.shrn(code, 4n), 1))}, x64_emit(XJcc{5, 2147614719}, x64_emit(XTestRR{preg, preg}, a)))))))
def x64_bor_sh_chk(n: Nat, +idx: U32, +bpm: U32, +l_bor: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: (+r = x64_arg_reg(idx); x64_bor_sh_chk(p, U32.add(idx, 1), bpm, l_bor, x64_when(U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0), acc, a => x64_emit(XJcc{8, l_bor}, x64_emit(XTestRR{r, r}, a)))))
def x64_o2_prologue_pre(is_leaf: Bool, +sw: U32, lf: X64SwLeaf, +bpre: U32, +ar: U32, ce: List<&2, U32>, frame: U32, sd: U32, has_mr: Bool, has_md: Bool, mr: U32, md: U32) -> List<&2, X64Inst>:
  match is_leaf:
    case True{}: x64_push_pop_list(True{}, ce, Nil{})
    case False{}: (a_pre = x64_bor_sh_chk(U32.to_nat(ar), 0, bpre, 2147614718, x64_sw_pre(ar, sw, lf, Nil{})); a0 = x64_push_pop_list(True{}, ce, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, a_pre))); x64_init_mem(has_mr, has_md, mr, md, x64_emit(XStore{5, sd, 7}, x64_emit(XSubRsp{frame}, a0))))
def x64_rm_cs_mask(+vd: Nat, n: Nat, +idx: U32, +rm: RaVec<U32>, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: (+r = ra_vec_get(U32, vd, 0, idx, rm); x64_rm_cs_mask(vd, p, U32.add(idx, 1), rm, U32.or(acc, U32.or(Bool.pick(U32, x64_is_xmm(r), 4, 0), U32.or(Bool.pick(U32, Bool.or(U32.is_eq(r, 8), U32.is_eq(r, 9)), 1, 0), Bool.pick(U32, Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11)), 2, 0))))))
def x64_count_rets(blks: List<&2, IrBlock>, +acc: U32) -> U32:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{_, _, TRet{_}}, t}: x64_count_rets(t, U32.add(acc, 1))
    case Con{_, t}: x64_count_rets(t, acc)
def x64_pick_hreg(+want: Bool, allow_cs: Bool, +ce: List<&2, U32>, +cs: List<&2, U32>) -> U32: (+r = Bool.pick(U32, want, x64_pick_free_callee(ce), 0); Bool.pick(U32, U32.is_ne(r, 0), r, Bool.pick(U32, Bool.and(want, allow_cs), Bool.pick(U32, x64_u32_in(10, cs), Bool.pick(U32, x64_u32_in(11, cs), 0, 11), 10), 0)))
def x64_blks_tail_scr(+ctx: X64Ctx, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, _, TTailCall{_, +args}}, t}: (+s1 = x64_tail_src_locs(False{}, ctx, Nil{}, args, 0, Nil{}); Bool.or(ra_is_nonempty(x64_tail_src_locs(True{}, ctx, s1, args, 0, Nil{})), x64_blks_tail_scr(ctx, t)))
    case Con{_, t}: x64_blks_tail_scr(ctx, t)
def x64_nu_sc_walk(+vd: Nat, +nu: RaVec<Bool>, +ao: RaVec<U32>, +ha: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>) -> Bool:
  match blks ops:
    case Nil{} Nil{}: False{}
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_nu_sc_walk(vd, nu, ao, ha, t, ops1)
    case _ Con{IArrOp{Con{_, Con{dv, _}}, 72, Con{a, _}}, ot}: Bool.or(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), ra_vec_get(Bool, vd, False{}, dv, nu)), x64_nu_sc_walk(vd, nu, ao, ha, blks, ot))
    case _ Con{IArrOp{Con{dv, _}, 78, Con{a, _}}, ot}: Bool.or(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), ra_vec_get(Bool, vd, False{}, dv, nu)), x64_nu_sc_walk(vd, nu, ao, ha, blks, ot))
    case _ Con{_, ot}: x64_nu_sc_walk(vd, nu, ao, ha, blks, ot)
def x64_nu_sc_ha_go(cur: Bool, z: Bool, ha: U32, vd: Nat, nu: RaVec<Bool>, ao: RaVec<U32>, blks: List<&2, IrBlock>) -> Bool: Bool.or(cur, low_if(Bool, z, _ => False{}, _ => x64_nu_sc_walk(vd, nu, ao, ha, blks, Nil{})))
def x64_hmag_add(mg: X64Mag, s: X64HMag) -> X64HMag:
  X64Mag{+m, _, _} = mg
  X64HMag{+m0, r0, +m1, r1, t0c, t0t, t0e, t0d} = s
  X64HMag{Bool.pick(U32, U32.is_zero(m0), m, m0), r0, Bool.pick(U32, Bool.and(U32.is_ne(m0, 0), Bool.and(U32.is_ne(m0, m), U32.is_zero(m1))), m, m1), r1, t0c, t0t, t0e, t0d}
def x64_hmag_walk(+vd: Nat, +c31: RaVec<U32>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, st: X64HMag) -> X64HMag:
  match blks ops:
    case Nil{} Nil{}: st
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_hmag_walk(vd, c31, t, ops1, st)
    case _ Con{IBin{_, +bop, _, r}, ot}: (+rv = ra_vec_get(U32, vd, 0, r, c31); +c = U32.sub(rv, 1); ok = Bool.and(Bool.or(U32.is_eq(bop, 3), U32.is_eq(bop, 4)), Bool.and(x64_is_cval(rv), Bool.and(U32.is_ge(c, 3), Bool.not(x64_is_pow2(c))))); x64_hmag_walk(vd, c31, blks, ot, x64_if1(X64HMag, X64HMag, ok, st, s => x64_hmag_add(x64_magic(c), s), s => s)))
    case _ Con{_, ot}: x64_hmag_walk(vd, c31, blks, ot, st)
def x64_b0_skip_c(+vd: Nat, +c31: RaVec<U32>, +cm: RaVec<Bool>, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Con{IConst{+d, v}, +t}: Bool.pick(List<&2, IrOp>, Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, d, c31)), Bool.not(ra_vec_get(Bool, vd, False{}, d, cm))), x64_b0_skip_c(vd, c31, cm, t), Con{IConst{d, v}, t})
    case xs: xs
type X64T0 is Data:
  X64T0{c: U32, tb: U32, eb: U32}
def x64_b0_t0_cmp(ok: Bool, +cop: U32, p: U32, +tb: U32, +eb: U32) -> X64T0:
  +is_z = U32.is_zero(cop)
  X64T0{Bool.pick(U32, ok, U32.add(p, 1), 0), Bool.pick(U32, is_z, eb, tb), Bool.pick(U32, is_z, tb, eb)}
def x64_b0_t0_ops(+vd: Nat, +arity: U32, +c31: RaVec<U32>, +uc: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +tb: U32, +eb: U32) -> X64T0:
  match ops:
    case Nil{}: X64T0{Bool.pick(U32, U32.is_lt(c, arity), U32.add(c, 1), 0), tb, eb}
    case Con{ICmp{+d, +cop, +p, +k}, Nil{}}: x64_b0_t0_cmp(Bool.and(Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_eq(d, c), U32.is_eq(ra_vec_get(U32, vd, 0, d, uc), 1))), Bool.and(U32.is_lt(p, arity), U32.is_eq(ra_vec_get(U32, vd, 0, k, c31), 1))), cop, p, tb, eb)
    case Con{IConst{+k, 0}, Con{ICmp{+d, +cop, +p, k2}, Nil{}}}: x64_b0_t0_cmp(Bool.and(Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_eq(k, k2), U32.is_eq(ra_vec_get(U32, vd, 0, k, uc), 1))), Bool.and(Bool.and(U32.is_eq(d, c), U32.is_eq(ra_vec_get(U32, vd, 0, d, uc), 1)), U32.is_lt(p, arity))), cop, p, tb, eb)
    case _: X64T0{0, 0, 0}
def x64_b0_t0(+vd: Nat, arity: U32, +c31: RaVec<U32>, cm: RaVec<Bool>, uc: RaVec<U32>, blks: List<&2, IrBlock>) -> X64T0:
  match blks:
    case Con{IrBlock{0, ops, TBr{c, tb, eb}}, _}: x64_b0_t0_ops(vd, arity, c31, uc, x64_b0_skip_c(vd, c31, cm, ops), c, tb, eb)
    case _: X64T0{0, 0, 0}
def x64_un_t0(-R: Type, t: X64T0, k: U32 -> U32 -> U32 -> R) -> R:
  X64T0{c, tb, eb} = t
  k(c, tb, eb)
def x64_run_hmag(stc: Bool, t0d: Bool, +vd: Nat, +arity: U32, +c31: RaVec<U32>, cm: RaVec<Bool>, +uc: RaVec<U32>, +blks: List<&2, IrBlock>) -> X64HMag:
  match stc:
    case False{}: X64HMag{0, 0, 0, 0, 0, 0, 0, False{}}
    case True{}: x64_un_t0(X64HMag, x64_b0_t0(vd, arity, c31, cm, uc, blks), c => tb => eb => (+c1 = c; x64_hmag_walk(vd, c31, blks, Nil{}, X64HMag{0, 0, 0, 0, c1, tb, eb, Bool.and(t0d, U32.is_ne(c1, 0))})))
type X64BorP is Data:
  X64BorP{bm: RaVec<U32>, own: RaVec<Bool>}
def x64_bor_init(+vd: Nat, n: Nat, +idx: U32, bm: RaVec<U32>) -> RaVec<U32>:
  match n:
    case 0n: bm
    case 1n+p: x64_bor_init(vd, p, U32.add(idx, 1), ra_vec_set(U32, vd, idx, U32.shln(1, U32.to_nat(idx)), bm))
def x64_bor_prop_ds(+vd: Nat, +ar: U32, +m: U32, +o: Bool, ds: List<&2, U32>, st: X64BorP) -> X64BorP:
  match ds st:
    case Nil{} _: st
    case Con{+d, t} X64BorP{+bm, +own}: x64_bor_prop_ds(vd, ar, m, o, t, X64BorP{Bool.pick(RaVec<U32>, U32.is_zero(m), bm, ra_vec_set(U32, vd, d, U32.or(ra_vec_get(U32, vd, 0, d, bm), m), bm)), Bool.pick(RaVec<Bool>, Bool.or(o, U32.is_lt(d, ar)), ra_vec_set(Bool, vd, d, True{}, own), own)})
def x64_bor_prop_walk(+vd: Nat, +ar: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, st: X64BorP) -> X64BorP:
  match blks ops st:
    case Nil{} Nil{} _: st
    case Con{IrBlock{_, ops1, _}, t} Nil{} _: x64_bor_prop_walk(vd, ar, t, ops1, st)
    case _ Con{ICopy{d, +s}, ot} X64BorP{+bm, +own}: x64_bor_prop_walk(vd, ar, blks, ot, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), Con{d, Nil{}}, X64BorP{bm, own}))
    case _ Con{IKeep{d, +s}, ot} X64BorP{+bm, +own}: x64_bor_prop_walk(vd, ar, blks, ot, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), Con{d, Nil{}}, X64BorP{bm, own}))
    case _ Con{ITake{ds, +s}, ot} X64BorP{+bm, +own}: x64_bor_prop_walk(vd, ar, blks, ot, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), ds, X64BorP{bm, own}))
    case _ Con{IArrOp{ds, _, _}, ot} X64BorP{bm, own}: x64_bor_prop_walk(vd, ar, blks, ot, x64_bor_prop_ds(vd, ar, 0, True{}, ds, X64BorP{bm, own}))
    case _ Con{op, ot} X64BorP{bm, +own}: (+d1 = opt_op_dst1(op); x64_bor_prop_walk(vd, ar, blks, ot, X64BorP{bm, ra_vec_set_if(Bool, vd, U32.is_ne(d1, 0), U32.sub(d1, 1), True{}, own)}))
type X64BorC is Data:
  X64BorC{bad: U32, htk: U32, hr: U32, hk: U32}
def x64_bor_mlist(+vd: Nat, +bm: RaVec<U32>, vs: List<&2, U32>) -> U32: opt_foldl2(~U32, ~Nat, ~RaVec<U32>, ~U32, ~(v0 => b0 => v => acc => U32.or(ra_vec_get(U32, v0, 0, v, b0), acc)), vd, bm, vs, 0)
def x64_bor_sargs(+vd: Nat, +bm: RaVec<U32>, args: List<&2, U32>, +idx: U32) -> U32:
  match args:
    case Nil{}: 0
    case Con{a, t}: (+bit = U32.shln(1, U32.to_nat(idx)); +m = ra_vec_get(U32, vd, 0, a, bm); U32.or(Bool.pick(U32, U32.is_eq(m, bit), 0, U32.or(bit, m)), x64_bor_sargs(vd, bm, t, U32.add(idx, 1))))
def x64_bor_mix(+vd: Nat, n: Nat, +idx: U32, +bm: RaVec<U32>, +own: RaVec<Bool>, +bad: U32) -> U32:
  match n:
    case 0n: bad
    case 1n+p: (+m = ra_vec_get(U32, vd, 0, idx, bm); x64_bor_mix(vd, p, U32.add(idx, 1), bm, own, U32.or(bad, Bool.pick(U32, Bool.and(U32.is_ne(m, 0), Bool.or(ra_vec_get(Bool, vd, False{}, idx, own), U32.is_ne(U32.and(m, U32.sub(m, 1)), 0))), m, 0))))
def x64_bor_chk_walk(+vd: Nat, +fid: U32, +bm: RaVec<U32>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, st: X64BorC) -> X64BorC:
  match blks ops st:
    case Nil{} Nil{} _: st
    case Con{IrBlock{_, ops1, TTailCall{tfid, +args}}, t} Nil{} X64BorC{bad, htk, hr, hk}: x64_bor_chk_walk(vd, fid, bm, t, ops1, X64BorC{U32.or(bad, Bool.pick(U32, U32.is_eq(tfid, fid), x64_bor_sargs(vd, bm, args, 0), x64_bor_mlist(vd, bm, args))), htk, hr, hk})
    case Con{IrBlock{_, ops1, _}, t} Nil{} _: x64_bor_chk_walk(vd, fid, bm, t, ops1, st)
    case _ Con{ITake{ds, s}, ot} X64BorC{bad, htk, hr, hk}: (+n = b5k_u32_list_len(ds); +m = ra_vec_get(U32, vd, 0, s, bm); x64_bor_chk_walk(vd, fid, bm, blks, ot, X64BorC{U32.or(bad, Bool.pick(U32, U32.is_gt(n, 8), m, 0)), U32.or(htk, Bool.pick(U32, Bool.and(U32.is_gt(n, 0), U32.is_le(n, 8)), m, 0)), hr, hk}))
    case _ Con{IKeep{_, s}, ot} X64BorC{bad, htk, hr, hk}: x64_bor_chk_walk(vd, fid, bm, blks, ot, X64BorC{bad, htk, hr, U32.or(hk, ra_vec_get(U32, vd, 0, s, bm))})
    case _ Con{ICallDirect{_, cfid, +args}, ot} X64BorC{bad, htk, hr, hk}: x64_bor_chk_walk(vd, fid, bm, blks, ot, X64BorC{U32.or(bad, Bool.pick(U32, U32.is_eq(cfid, fid), x64_bor_sargs(vd, bm, args, 0), x64_bor_mlist(vd, bm, args))), htk, hr, hk})
    case _ Con{IReuse{_, sl, _, fs}, ot} X64BorC{bad, htk, hr, hk}: x64_bor_chk_walk(vd, fid, bm, blks, ot, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, fs)), htk, U32.or(hr, ra_vec_get(U32, vd, 0, sl, bm)), hk})
    case _ Con{ICopy{_, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{IBin{_, _, _, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{IUn{_, _, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{ICmp{_, _, _, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{ITag{_, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{ISink{_}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{ILut{_, _, _, _}, ot} _: x64_bor_chk_walk(vd, fid, bm, blks, ot, st)
    case _ Con{op, ot} X64BorC{bad, htk, hr, hk}: x64_bor_chk_walk(vd, fid, bm, blks, ot, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, opt_op_uses_list(op))), htk, hr, hk})
def x64_scan_bor_fin2(bm: RaVec<U32>, bc: X64BorC) -> X64Bor:
  X64BorC{bad, htk, hr, +hk} = bc
  +bpm0 = U32.and(htk, U32.xor(U32.or(bad, U32.and(hr, U32.xor(hk, 4294967295))), 4294967295))
  X64Bor{U32.or(bpm0, Bool.pick(U32, Bool.and(U32.is_ne(bpm0, 0), U32.is_zero(U32.and(bpm0, hk))), 65536, 0)), bm}
def x64_scan_bor_fin1(+vd: Nat, nregs: U32, fid: U32, blks: List<&2, IrBlock>, bp: X64BorP) -> X64Bor:
  X64BorP{+bm, own} = bp
  x64_scan_bor_fin2(bm, x64_bor_chk_walk(vd, fid, bm, blks, Nil{}, X64BorC{x64_bor_mix(vd, U32.to_nat(nregs), 0, bm, own, 0), 0, 0, 0}))
def x64_scan_bor_go(ok: Bool, +vd: Nat, +ar: U32, nregs: U32, fid: U32, +blks: List<&2, IrBlock>) -> X64Bor:
  match ok:
    case False{}: X64Bor{0, RVEmpty{}}
    case True{}: x64_scan_bor_fin1(vd, nregs, fid, blks, x64_bor_prop_walk(vd, ar, blks, Nil{}, x64_bor_prop_walk(vd, ar, blks, Nil{}, X64BorP{x64_bor_init(vd, U32.to_nat(ar), 0, RVEmpty{}), RVEmpty{}})))
def x64_push_mem_extra(n: Nat, +base: U32, +idx: U32, +off_base: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: x64_push_mem_extra(p, base, U32.sub(idx, 1), off_base, x64_emit(XPush{0}, x64_emit(XLoad{0, base, U32.add(off_base, U32.mul(idx, 8))}, acc)))
def x64_bor_wrap_go(+wctx: X64Ctx, is_sv: Bool, n: Nat, +idx: U32, +bpm: U32, st: X64Acc) -> X64Acc:
  match is_sv n st:
    case True{} 0n _: st
    case False{} 0n X64Acc{a2, lbl, cold}: X64Acc{x64_emit_epilogue(x64_emit(XLoad{0, 5, U32.sub(0, 16)}, a2)), lbl, cold}
    case True{} 1n+p X64Acc{+acc, lbl, cold}: (a1 = x64_when(U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0), acc, a => +off = U32.sub(0, U32.add(24, U32.mul(idx, 8))); x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_lt(idx, 5), a, a_ => x64_emit(XStore{5, off, x64_arg_reg(idx)}, a_), a_ => x64_emit(XStore{5, off, 0}, x64_emit(XLoad{0, 5, U32.add(16, U32.mul(U32.sub(idx, 5), 8))}, a_)))); x64_bor_wrap_go(wctx, True{}, p, U32.add(idx, 1), bpm, X64Acc{a1, lbl, cold}))
    case False{} 1n+p X64Acc{+acc, +lbl, +cold}: x64_bor_wrap_go(wctx, False{}, p, U32.add(idx, 1), bpm, Bool.pick(X64Acc, U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0), X64Acc{x64_rc_shared(False{}, wctx, 6, lbl, U32.add(lbl, 1), x64_emit(XLoad{6, 5, U32.sub(0, U32.add(24, U32.mul(idx, 8)))}, acc)), U32.add(lbl, 2), x64_emit(XJmp{lbl}, x64_emit(XCallSym{"p111_rt_sink"}, x64_emit(XLoad{7, 5, U32.sub(0, 8)}, x64_emit(XLabel{U32.add(lbl, 1)}, cold))))}, X64Acc{acc, lbl, cold}))
def x64_bor_wrap_body(+name: String, +ar: U32, +bpm: U32, +lbl0: U32, pre: List<&2, X64Inst>) -> List<&2, X64Inst>: (+wctx : X64Ctx = X64Ctx{True{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, 96, Nil{}, 0, x64_empty_meta()}; a0 = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{96}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, pre)))); +sym = String.append("$bor.", name); a_c = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_gt(ar, 5), x64_acc_insts(x64_bor_wrap_go(wctx, True{}, U32.to_nat(ar), 0, bpm, X64Acc{a0, lbl0, Nil{}})), a => +ex = U32.sub(ar, 5); +odd = U32.is_eq(U32.and(ex, 1), 1); x64_emit(XAddRsp{U32.mul(U32.add(ex, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, x64_push_mem_extra(U32.to_nat(ex), 5, U32.sub(ex, 1), 16, x64_emit_if(odd, XSubRsp{8}, a)))), a => x64_emit(XCallSym{sym}, a)); x64_acc_insts(x64_bor_wrap_go(wctx, False{}, U32.to_nat(ar), 0, bpm, X64Acc{x64_emit(XStore{5, U32.sub(0, 16), 0}, a_c), lbl0, Nil{}})))
def x64_init_hoist_list(+ctx: X64Ctx, hs: List<&2, X64Ha>, st: X64Acc) -> X64Acc:
  match hs:
    case Nil{}: st
    case Con{X64Ha{ha, dp, mk, _}, t}: x64_init_hoist_list(ctx, t, x64_init_hoist_one(ctx, ha, dp, mk, st))
def x64_ver_chk_dp(h: X64Ha, +l_slow: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  X64Ha{ha, +dp, _, _} = h
  Bool.pick(List<&2, X64Inst>, U32.is_zero(ha), acc, x64_emit(XJcc{4, l_slow}, Bool.pick(List<&2, X64Inst>, U32.is_lt(dp, 16), x64_emit(XTestRR{dp, dp}, acc), x64_emit(XTestRR{0, 0}, x64_emit(XLoad{0, 5, dp}, acc)))))
def x64_ver_chk_dp_list(hs: List<&2, X64Ha>, +l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hs:
    case Nil{}: acc
    case Con{h, t}: x64_ver_chk_dp_list(t, l_slow, x64_ver_chk_dp(h, l_slow, acc))
def x64_shift_term(+off: U32, term: IrTerm) -> IrTerm:
  match term:
    case TJmp{tgt}: TJmp{U32.add(tgt, off)}
    case TBr{c, tb, eb}: TBr{c, U32.add(tb, off), U32.add(eb, off)}
    case TSwitch{s, arms, db}: TSwitch{s, opt_shift_arms(off, arms), U32.add(db, off)}
    case _: term
def x64_shift_blks(+off: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>: opt_mapl(~IrBlock, ~U32, ~IrBlock, ~(e => b => (+o = e; opt_un_blk(IrBlock, b, id => ops => term => IrBlock{U32.add(id, o), ops, x64_shift_term(o, term)}))), off, blks)
def x64_rm_other_has_reg(+vd: Nat, n: Nat, +idx: U32, +r: U32, +skip_v: U32, +rm: RaVec<U32>, +c31: RaVec<U32>, +cm: RaVec<Bool>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p: (skip = Bool.or(U32.is_eq(idx, skip_v), Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, idx, c31)), Bool.not(ra_vec_get(Bool, vd, False{}, idx, cm)))); hit = Bool.and(Bool.not(skip), U32.is_eq(ra_vec_get(U32, vd, 0, idx, rm), r)); Bool.or(hit, x64_rm_other_has_reg(vd, p, U32.add(idx, 1), r, skip_v, rm, c31, cm)))
def x64_rdx_safe_op(op: IrOp) -> Bool:
  match op:
    case IConst{_, _}: True{}
    case IFlt{_, _}: True{}
    case ICopy{_, _}: True{}
    case IUn{_, _, _}: True{}
    case ICmp{_, _, _, _}: True{}
    case IBin{_, +bop, _, _}: Bool.and(U32.is_ne(bop, 3), U32.is_ne(bop, 4))
    case IArrOp{_, +aop, _}: Bool.or(U32.is_eq(aop, 72), Bool.or(U32.is_eq(aop, 73), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81))))
    case _: False{}
def x64_rdx_safe_walk(+fn_fid: U32, +rm: RaVec<U32>, +vd: Nat, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, +mode: U32) -> Bool:
  match blks ops:
    case Nil{} Nil{}: True{}
    case Con{IrBlock{_, ops1, TRet{_}}, t} Nil{}: x64_rdx_safe_walk(fn_fid, rm, vd, t, ops1, 1)
    case Con{IrBlock{_, ops1, TTailCall{fid, _}}, t} Nil{}: Bool.and(U32.is_eq(fid, fn_fid), x64_rdx_safe_walk(fn_fid, rm, vd, t, ops1, 0))
    case Con{IrBlock{_, ops1, TBr{c, _, _}}, t} Nil{}: Bool.and(x64_is_gpr(ra_vec_get(U32, vd, 0, c, rm)), x64_rdx_safe_walk(fn_fid, rm, vd, t, ops1, 0))
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_rdx_safe_walk(fn_fid, rm, vd, t, ops1, 0)
    case _ Con{+op, ot}: (+ok = Bool.pick(Bool, U32.is_eq(mode, 2), Bool.not(x64_op_pred(4, 0, op)), Bool.or(x64_rdx_safe_op(op), U32.is_eq(mode, 1))); +nm = Bool.pick(U32, Bool.and(U32.is_eq(mode, 1), Bool.not(x64_rdx_safe_op(op))), 2, mode); Bool.and(ok, x64_rdx_safe_walk(fn_fid, rm, vd, blks, ot, nm)))
type X64Nw is Data:
  X64Nw{kind: U32, a: U32, b: U32, off: U32}
def x64_nw_is_ha(+vd: Nat, +ao: RaVec<U32>, +ha: U32, +aop: U32, a: U32) -> Bool: Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81))))
def x64_nw_find_walk(+mode: U32, +vd: Nat, +c31: RaVec<U32>, +v: U32, +p: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>) -> U32:
  match blks ops:
    case Nil{} Nil{}: 0
    case Con{IrBlock{_, ops1, _}, t} Nil{}: x64_nw_find_walk(mode, vd, c31, v, p, t, ops1)
    case _ Con{IBin{+d, +bop, +l, +r}, ot}: (+cr = ra_vec_get(U32, vd, 0, r, c31); +cl = ra_vec_get(U32, vd, 0, l, c31); +is_d = U32.is_eq(d, v); h1 = Bool.and(U32.is_zero(mode), Bool.and(U32.is_zero(bop), Bool.and(is_d, Bool.and(U32.is_eq(l, p), Bool.and(U32.is_ge(cr, 1), U32.is_le(cr, 17)))))); h2 = Bool.and(U32.is_zero(mode), Bool.and(U32.is_zero(bop), Bool.and(is_d, Bool.and(U32.is_eq(r, p), Bool.and(U32.is_ge(cl, 1), U32.is_le(cl, 17)))))); h3 = Bool.and(U32.is_ge(mode, 1), Bool.and(U32.is_eq(bop, 5), Bool.and(is_d, Bool.and(U32.is_ge(cr, 1), U32.is_le(cr, Bool.pick(U32, U32.is_eq(mode, 2), 4096, 65536)))))); h4 = Bool.and(U32.is_ge(mode, 1), Bool.and(U32.is_eq(bop, 4), Bool.and(is_d, Bool.and(U32.is_ge(cr, 2), U32.is_le(cr, Bool.pick(U32, U32.is_eq(mode, 2), 1025, 65536)))))); Bool.pick(U32, Bool.or(h1, h3), cr, Bool.pick(U32, h4, U32.sub(cr, 1), Bool.pick(U32, h2, cl, x64_nw_find_walk(mode, vd, c31, v, p, blks, ot)))))
    case _ Con{_, ot}: x64_nw_find_walk(mode, vd, c31, v, p, blks, ot)
def x64_nw_param_kind(+vd: Nat, +c31: RaVec<U32>, +fid: U32, +p: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, +k: U32) -> U32:
  match blks:
    case Nil{}: k
    case Con{IrBlock{_, _, TTailCall{tfid, args}}, t}: (+a = x64_u32_nth(args, U32.to_nat(p)); +ac = x64_nw_find_walk(1, vd, c31, a, p, all_blks, Nil{}); nk = Bool.pick(U32, U32.is_ne(tfid, fid), 99, Bool.pick(U32, U32.is_eq(a, p), Bool.pick(U32, U32.is_zero(k), 1, k), Bool.pick(U32, U32.is_eq(x64_nw_find_walk(0, vd, c31, a, p, all_blks, Nil{}), 2), Bool.pick(U32, U32.is_le(k, 2), 2, 99), Bool.pick(U32, U32.is_ne(ac, 0), Bool.pick(U32, Bool.or(U32.is_le(k, 1), U32.is_eq(k, U32.add(100, ac))), U32.add(100, ac), 99), 99)))); x64_nw_param_kind(vd, c31, fid, p, all_blks, t, nk))
    case Con{_, t}: x64_nw_param_kind(vd, c31, fid, p, all_blks, t, k)
def x64_nw_min_cmp(ops: List<&2, IrOp>, +c: U32, +vt: U32, +ve: U32, +ar: U32) -> U32:
  match ops:
    case Nil{}: 0
    case Con{ICmp{+cd, +cop, +l, +r}, Nil{}}: (ok1 = Bool.and(U32.is_eq(cd, c), Bool.and(Bool.or(U32.is_eq(cop, 2), U32.is_eq(cop, 3)), Bool.and(U32.is_eq(vt, l), Bool.and(U32.is_eq(ve, r), U32.is_lt(r, ar))))); ok2 = Bool.and(U32.is_eq(cd, c), Bool.and(Bool.or(U32.is_eq(cop, 4), U32.is_eq(cop, 5)), Bool.and(U32.is_eq(ve, l), Bool.and(U32.is_eq(vt, r), U32.is_lt(r, ar))))); Bool.pick(U32, Bool.or(ok1, ok2), U32.add(r, 1), 0))
    case Con{_, t}: x64_nw_min_cmp(t, c, vt, ve, ar)
def x64_nw_find_min_k1(blks: List<&2, IrBlock>, +m: U32, +ar: U32) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{_, ops0, TBr{c, +tb, +eb}}, Con{IrBlock{+i1, Con{ICopy{+d1, +v1}, Nil{}}, TJmp{+j1}}, Con{IrBlock{+i2, Con{ICopy{+d2, +v2}, Nil{}}, TJmp{+j2}}, t}}}: (+o1 = Bool.and(U32.is_eq(i1, tb), U32.is_eq(i2, eb)); +hit = Bool.and(Bool.and(U32.is_eq(d1, m), U32.is_eq(d2, m)), Bool.and(U32.is_eq(j1, j2), Bool.or(o1, Bool.and(U32.is_eq(i1, eb), U32.is_eq(i2, tb))))); +k1 = Bool.pick(U32, hit, x64_nw_min_cmp(ops0, c, Bool.pick(U32, o1, v1, v2), Bool.pick(U32, o1, v2, v1), ar), 0); Bool.pick(U32, U32.is_ne(k1, 0), k1, x64_nw_find_min_k1(Con{IrBlock{i1, Con{ICopy{d1, v1}, Nil{}}, TJmp{j1}}, Con{IrBlock{i2, Con{ICopy{d2, v2}, Nil{}}, TJmp{j2}}, t}}, m, ar)))
    case Con{_, t}: x64_nw_find_min_k1(t, m, ar)
def x64_nw_chk_mono_walk(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +t0e: U32, +pj: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, +is_e: Bool, +mo: U32) -> U32:
  match blks ops:
    case Nil{} Nil{}: mo
    case Con{IrBlock{id, ops1, _}, t} Nil{}: x64_nw_chk_mono_walk(vd, c31, ao, ha, t0e, pj, all_blks, t, ops1, U32.is_eq(id, t0e), mo)
    case _ Con{IArrOp{_, aop, Con{a, Con{+i, _}}}, ot}: (+hit = x64_nw_is_ha(vd, ao, ha, aop, a); +lo = U32.and(mo, 65535); +r = Bool.pick(U32, hit, Bool.pick(U32, U32.is_eq(i, pj), 1, x64_nw_find_walk(0, vd, c31, i, pj, all_blks, Nil{})), 1); +m1 = Bool.pick(U32, Bool.or(U32.is_zero(lo), U32.is_zero(r)), 0, U32.max(lo, r)); x64_nw_chk_mono_walk(vd, c31, ao, ha, t0e, pj, all_blks, blks, ot, is_e, Bool.pick(U32, U32.is_zero(m1), 0, U32.or(m1, Bool.pick(U32, Bool.or(U32.is_ge(mo, 65536), Bool.and(is_e, hit)), 65536, 0)))))
    case _ Con{_, ot}: x64_nw_chk_mono_walk(vd, c31, ao, ha, t0e, pj, all_blks, blks, ot, is_e, mo)
def x64_nw_find_add_min(+vd: Nat, +ar: U32, +all_blks: List<&2, IrBlock>, +idx: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{+d, 0, +l, +r}, t}: (+k1 = Bool.pick(U32, Bool.and(U32.is_eq(d, idx), U32.is_lt(l, ar)), x64_nw_find_min_k1(all_blks, r, ar), 0); +k2 = Bool.pick(U32, Bool.and(U32.is_eq(d, idx), U32.is_lt(r, ar)), x64_nw_find_min_k1(all_blks, l, ar), 0); Bool.pick(U32, U32.is_ne(k1, 0), U32.or(U32.shln(U32.add(l, 1), 16n), k1), Bool.pick(U32, U32.is_ne(k2, 0), U32.or(U32.shln(U32.add(r, 1), 16n), k2), x64_nw_find_add_min(vd, ar, all_blks, idx, t))))
    case Con{_, t}: x64_nw_find_add_min(vd, ar, all_blks, idx, t)
def x64_nw_ha_step(+mode: U32, +vd: Nat, +c31: RaVec<U32>, +p1: U32, +p2: U32, +all_blks: List<&2, IrBlock>, +all_ops: List<&2, IrOp>, +i: U32, +acc: U32) -> U32:
  match mode:
    case 0: (+ac = x64_nw_find_walk(1, vd, c31, i, 0, Nil{}, all_ops); Bool.to_u32(Bool.and(U32.is_ne(acc, 0), Bool.or(U32.is_eq(i, p1), Bool.and(U32.is_ne(ac, 0), U32.is_le(U32.sub(ac, 1), p2))))))
    case 1: (+r = x64_nw_find_add_min(vd, p1, all_blks, i, all_ops); Bool.pick(U32, U32.is_zero(r), 4294967294, Bool.pick(U32, U32.is_zero(acc), r, Bool.pick(U32, U32.is_eq(acc, r), acc, 4294967294))))
    case _: (+ac = x64_nw_find_walk(2, vd, c31, i, 0, Nil{}, all_ops); Bool.pick(U32, Bool.or(U32.is_zero(ac), U32.is_eq(acc, 4294967294)), 4294967294, U32.max(acc, ac)))
def x64_nw_ha_walk(+mode: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +p1: U32, +p2: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, +all_ops: List<&2, IrOp>, +acc: U32) -> U32:
  match blks ops:
    case Nil{} Nil{}: acc
    case Con{IrBlock{_, +ops1, _}, t} Nil{}: x64_nw_ha_walk(mode, vd, c31, ao, ha, p1, p2, all_blks, t, ops1, ops1, acc)
    case _ Con{IArrOp{_, aop, Con{a, Con{i, _}}}, ot}: x64_nw_ha_walk(mode, vd, c31, ao, ha, p1, p2, all_blks, blks, ot, all_ops, Bool.pick(U32, x64_nw_is_ha(vd, ao, ha, aop, a), x64_nw_ha_step(mode, vd, c31, p1, p2, all_blks, all_ops, i, acc), acc))
    case _ Con{_, ot}: x64_nw_ha_walk(mode, vd, c31, ao, ha, p1, p2, all_blks, blks, ot, all_ops, acc)
def x64_nw_scan_params(n: Nat, +p: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +fid: U32, +t0d: Bool, +t0e: U32, +pn: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  match n:
    case 0n: X64Nw{0, 0, 0, 0}
    case 1n+r: (+pk = x64_nw_param_kind(vd, c31, fid, p, blks, blks, 0); +mo = Bool.pick(U32, Bool.and(t0d, U32.is_eq(pk, 2)), x64_nw_chk_mono_walk(vd, c31, ao, ha, t0e, p, blks, blks, Nil{}, False{}, 1), 0); +cm = Bool.pick(U32, U32.is_gt(pk, 100), U32.sub(pk, 101), 0); +k1 = Bool.pick(U32, U32.is_ge(mo, 65536), 1, 4); Bool.pick(X64Nw, U32.is_ne(mo, 0), X64Nw{k1, p, pn, U32.sub(U32.and(mo, 65535), 1)}, Bool.pick(X64Nw, Bool.and(U32.is_gt(pk, 100), U32.is_ne(x64_nw_ha_walk(0, vd, c31, ao, ha, p, cm, blks, blks, Nil{}, Nil{}, 1), 0)), X64Nw{2, p, cm, 0}, x64_nw_scan_params(r, U32.add(p, 1), vd, c31, ao, ha, fid, t0d, t0e, pn, blks))))
def x64_nw_blk_uses_ha(+vd: Nat, +ao: RaVec<U32>, +ha: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IArrOp{_, aop, Con{a, _}}, t}: Bool.or(x64_nw_is_ha(vd, ao, ha, aop, a), x64_nw_blk_uses_ha(vd, ao, ha, t))
    case Con{_, t}: x64_nw_blk_uses_ha(vd, ao, ha, t)
def x64_nw_find_op(+is_cmp: Bool, +v: U32, +op: U32, ops: List<&2, IrOp>) -> U32:
  match is_cmp ops:
    case _ Nil{}: 0
    case False{} Con{IBin{d, ob, l, r}, t}: Bool.pick(U32, Bool.and(U32.is_eq(d, v), U32.is_eq(ob, op)), U32.or(U32.shln(U32.add(l, 1), 16n), U32.add(r, 1)), x64_nw_find_op(False{}, v, op, t))
    case True{} Con{ICmp{d, oc, l, r}, t}: Bool.pick(U32, Bool.and(U32.is_eq(d, v), U32.is_eq(oc, op)), U32.or(U32.shln(U32.add(l, 1), 16n), U32.add(r, 1)), x64_nw_find_op(True{}, v, op, t))
    case _ Con{_, t}: x64_nw_find_op(is_cmp, v, op, t)
def x64_nw_cd_base_step(+vd: Nat, +c31: RaVec<U32>, +pn: U32, +all_ops: List<&2, IrOp>, +sh: U32) -> U32: (+s_e = x64_nw_find_op(False{}, sh, 8, all_ops); +q1 = Bool.pick(U32, U32.is_ne(s_e, 0), U32.sub(U32.shrn(s_e, 16n), 1), sh); +shc = Bool.pick(U32, U32.is_ne(s_e, 0), ra_vec_get(U32, vd, 0, U32.sub(U32.and(s_e, 65535), 1), c31), 1); +s = U32.sub(shc, 1); +a_e = x64_nw_find_op(False{}, q1, 0, all_ops); +q = Bool.pick(U32, U32.is_ne(a_e, 0), U32.sub(U32.shrn(a_e, 16n), 1), q1); +a_c = Bool.pick(U32, U32.is_ne(a_e, 0), ra_vec_get(U32, vd, 0, U32.sub(U32.and(a_e, 65535), 1), c31), 0); +d_e = x64_nw_find_op(False{}, q, 1, all_ops); +p0 = U32.sub(U32.shrn(d_e, 16n), 1); +d_c = ra_vec_get(U32, vd, 0, U32.sub(U32.and(d_e, 65535), 1), c31); +ok_q = Bool.or(U32.is_eq(q1, pn), Bool.and(U32.is_eq(a_c, 2), Bool.and(U32.is_ne(d_e, 0), Bool.and(U32.is_eq(p0, pn), U32.is_eq(d_c, 2))))); Bool.pick(U32, Bool.and(ok_q, Bool.and(U32.is_ne(shc, 0), U32.is_le(s, 3))), U32.add(s, 1), 0))
def x64_nw_cd_find_i0(+vd: Nat, +c31: RaVec<U32>, +pn: U32, +all_ops: List<&2, IrOp>, ops: List<&2, IrOp>) -> X64Nw:
  match ops:
    case Nil{}: X64Nw{0, 0, 0, 0}
    case Con{IBin{+d, 1, +l, +r}, t}: (+cl = ra_vec_get(U32, vd, 0, l, c31); +c = U32.sub(cl, 1); +s1 = Bool.pick(U32, Bool.and(U32.is_ne(cl, 0), Bool.and(U32.is_ge(c, 64), U32.is_le(c, 65536))), x64_nw_cd_base_step(vd, c31, pn, all_ops, r), 0); Bool.pick(X64Nw, U32.is_ne(s1, 0), X64Nw{6, d, c, U32.sub(s1, 1)}, x64_nw_cd_find_i0(vd, c31, pn, all_ops, t)))
    case Con{_, t}: x64_nw_cd_find_i0(vd, c31, pn, all_ops, t)
def x64_nw_cd_chain(fuel: Nat, +vd: Nat, +c31: RaVec<U32>, +i0: U32, +all_ops: List<&2, IrOp>, +v: U32, +off: U32) -> U32:
  match fuel:
    case 0n: 0
    case 1n+p: (+e = x64_nw_find_op(False{}, v, 0, all_ops); Bool.pick(U32, U32.is_eq(v, i0), U32.add(off, 1), low_if(U32, U32.is_ne(e, 0), _ => Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, U32.sub(U32.and(e, 65535), 1), c31), 2), x64_nw_cd_chain(p, vd, c31, i0, all_ops, U32.sub(U32.shrn(e, 16n), 1), U32.add(off, 1)), 0), _ => 0)))
def x64_nw_cd_clamp_ok(+is_add: Bool, +vd: Nat, +c31: RaVec<U32>, +c: U32, +all_ops: List<&2, IrOp>, +base: U32, +d: U32) -> Bool: (+se = x64_nw_find_op(False{}, d, 8, all_ops); +cv = Bool.pick(U32, U32.is_ne(se, 0), U32.sub(U32.shrn(se, 16n), 1), d); +lc = Bool.pick(U32, U32.is_ne(se, 0), ra_vec_get(U32, vd, 0, U32.sub(U32.and(se, 65535), 1), c31), 1); +shl = U32.sub(lc, 1); +ce = x64_nw_find_op(True{}, cv, Bool.pick(U32, is_add, 2, 4), all_ops); +src = U32.sub(U32.shrn(ce, 16n), 1); +limc = ra_vec_get(U32, vd, 0, U32.sub(U32.and(ce, 65535), 1), c31); +lim = U32.sub(limc, 1); +is_z = U32.is_ne(se, 0); +xe = x64_nw_find_op(False{}, src, Bool.pick(U32, is_z, 9, 5), all_ops); +xb = U32.sub(U32.shrn(xe, 16n), 1); +xrc = ra_vec_get(U32, vd, 0, U32.sub(U32.and(xe, 65535), 1), c31); +xr = U32.sub(xrc, 1); +ok_lim = Bool.pick(Bool, is_add, Bool.pick(Bool, is_z, U32.is_eq(lim, U32.sub(U32.shrn(c, U32.to_nat(shl)), 1)), U32.is_eq(lim, xr)), U32.is_zero(lim)); +ok_x = Bool.pick(Bool, is_z, U32.is_eq(xr, shl), Bool.and(U32.is_gt(xr, 0), U32.is_zero(U32.and(c, xr)))); Bool.and(Bool.and(U32.is_ne(lc, 0), Bool.and(U32.is_ne(ce, 0), Bool.and(U32.is_ne(limc, 0), Bool.and(U32.is_ne(xe, 0), U32.is_ne(xrc, 0))))), Bool.and(U32.is_eq(xb, base), Bool.and(ok_lim, ok_x))))
def x64_nw_cd_idx_ok(+vd: Nat, +c31: RaVec<U32>, +i0: U32, +c: U32, +step: U32, +all_ops: List<&2, IrOp>, +idx: U32) -> Bool: (+ch = x64_nw_cd_chain(8n, vd, c31, i0, all_ops, idx, 0); +is_ch = Bool.and(U32.is_ne(ch, 0), U32.is_lt(U32.sub(ch, 1), step)); +ae = x64_nw_find_op(False{}, idx, 0, all_ops); +se = x64_nw_find_op(False{}, idx, 1, all_ops); +ab = U32.sub(U32.shrn(ae, 16n), 1); +ad = U32.sub(U32.and(ae, 65535), 1); +sb = U32.sub(U32.shrn(se, 16n), 1); +sd = U32.sub(U32.and(se, 65535), 1); +ach = Bool.pick(U32, U32.is_ne(ae, 0), x64_nw_cd_chain(8n, vd, c31, i0, all_ops, ab, 0), 0); +sch = Bool.pick(U32, U32.is_ne(se, 0), x64_nw_cd_chain(8n, vd, c31, i0, all_ops, sb, 0), 0); +ok_a = Bool.and(Bool.and(U32.is_ne(ach, 0), U32.is_lt(U32.sub(ach, 1), step)), x64_nw_cd_clamp_ok(True{}, vd, c31, c, all_ops, ab, ad)); +ok_s = Bool.and(Bool.and(U32.is_ne(sch, 0), U32.is_lt(U32.sub(sch, 1), step)), x64_nw_cd_clamp_ok(False{}, vd, c31, c, all_ops, sb, sd)); Bool.or(is_ch, Bool.or(ok_a, ok_s)))
def x64_nw_cd_ops(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +i0: U32, +c: U32, +step: U32, +all_ops: List<&2, IrOp>, ops: List<&2, IrOp>, +ok: Bool) -> Bool:
  match ops:
    case Nil{}: ok
    case Con{IArrOp{_, aop, Con{a, Con{+i, _}}}, t}: x64_nw_cd_ops(vd, c31, ao, ha, i0, c, step, all_ops, t, Bool.and(ok, Bool.or(Bool.not(x64_nw_is_ha(vd, ao, ha, aop, a)), x64_nw_cd_idx_ok(vd, c31, i0, c, step, all_ops, i))))
    case Con{_, t}: x64_nw_cd_ops(vd, c31, ao, ha, i0, c, step, all_ops, t, ok)
def x64_nw_cd_step(cand: X64Nw, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +pn: U32, +ops: List<&2, IrOp>, has_h: Bool, cur: X64Nw) -> X64Nw:
  match cand cur:
    case _ X64Nw{99, _, _, _}: X64Nw{99, 0, 0, 0}
    case X64Nw{6, +i0, +c, +s} _: (+ok = x64_nw_cd_ops(vd, c31, ao, ha, i0, c, U32.shln(1, U32.to_nat(s)), ops, ops, True{}); Bool.pick(X64Nw, ok, X64Nw{6, pn, c, s}, X64Nw{99, 0, 0, 0}))
    case _ _: Bool.pick(X64Nw, has_h, X64Nw{99, 0, 0, 0}, cur)
def x64_nw_cd_chk_blks(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +pn: U32, blks: List<&2, IrBlock>, cur: X64Nw) -> X64Nw:
  match blks:
    case Nil{}: cur
    case Con{IrBlock{_, +ops, _}, t}: (+has_h = x64_nw_blk_uses_ha(vd, ao, ha, ops); cand = Bool.pick(X64Nw, has_h, x64_nw_cd_find_i0(vd, c31, pn, ops, ops), X64Nw{0, 0, 0, 0}); x64_nw_cd_chk_blks(vd, c31, ao, ha, pn, t, x64_nw_cd_step(cand, vd, c31, ao, ha, pn, ops, has_h, cur)))
def x64_nw_cd_fin(r: X64Nw) -> X64Nw:
  match r:
    case X64Nw{6, p, c, s}: X64Nw{6, p, c, s}
    case _: X64Nw{0, 0, 0, 0}
def x64_nw_cd_dec_ok(+vd: Nat, +c31: RaVec<U32>, +fid: U32, +pn: U32, blks: List<&2, IrBlock>, seen: Bool) -> Bool:
  match blks:
    case Nil{}: seen
    case Con{IrBlock{_, +ops, TTailCall{tfid, args}}, t}: (+is_s = U32.is_eq(tfid, fid); +q = x64_u32_nth(args, U32.to_nat(pn)); +de = x64_nw_find_op(False{}, q, 1, ops); +ok = Bool.and(U32.is_ne(de, 0), Bool.and(U32.is_eq(U32.sub(U32.shrn(de, 16n), 1), pn), U32.is_eq(ra_vec_get(U32, vd, 0, U32.sub(U32.and(de, 65535), 1), c31), 2))); Bool.and(Bool.or(Bool.not(is_s), ok), x64_nw_cd_dec_ok(vd, c31, fid, pn, t, Bool.or(seen, is_s))))
    case Con{_, t}: x64_nw_cd_dec_ok(vd, c31, fid, pn, t, seen)
def x64_nw_cd_try(+fid: U32, +ha: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +blks: List<&2, IrBlock>) -> X64Nw: Bool.pick(X64Nw, x64_nw_cd_dec_ok(vd, c31, fid, 0, blks, False{}), x64_nw_cd_fin(x64_nw_cd_chk_blks(vd, c31, ao, ha, 0, blks, X64Nw{0, 0, 0, 0})), X64Nw{0, 0, 0, 0})
def x64_nw_fb(nw: X64Nw, +ha: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  X64Nw{+k0, a0, b0, o0} = nw
  low_if(X64Nw, U32.is_ne(k0, 0), _ => X64Nw{k0, a0, b0, o0}, _ => +pr = x64_nw_ha_walk(1, vd, c31, ao, ha, ar, 0, blks, blks, Nil{}, Nil{}, 0); +row = U32.sub(U32.shrn(pr, 16n), 1); +k1 = U32.sub(U32.and(pr, 65535), 1); +ok = Bool.and(Bool.and(U32.is_ne(pr, 0), U32.is_lt(pr, 4294967294)), Bool.and(U32.is_eq(x64_nw_param_kind(vd, c31, fid, row, blks, blks, 0), 1), U32.is_eq(x64_nw_param_kind(vd, c31, fid, k1, blks, blks, 0), 1))); +bm = Bool.pick(U32, ok, 0, x64_nw_ha_walk(2, vd, c31, ao, ha, 0, 0, blks, blks, Nil{}, Nil{}, 0)); +bok = Bool.and(U32.is_ne(bm, 0), U32.is_lt(bm, 4294967294)); Bool.pick(X64Nw, ok, X64Nw{3, row, k1, 0}, Bool.pick(X64Nw, bok, X64Nw{5, U32.sub(bm, 1), 0, 0}, x64_nw_cd_try(fid, ha, vd, c31, ao, blks))))
def x64_nw_analyze_one(+ha: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +fid: U32, +ar: U32, +t0d: Bool, +t0e: U32, +pn: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  match ha:
    case 0: X64Nw{0, 0, 0, 0}
    case _: x64_nw_fb(x64_nw_scan_params(U32.to_nat(ar), 0, vd, c31, ao, ha, fid, t0d, t0e, pn, blks), ha, vd, c31, ao, fid, ar, blks)
def x64_nw_cmp_mk(+mk: U32, +l_slow: U32, +add1: Bool, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>: (+a1 = Bool.pick(List<&2, X64Inst>, U32.is_lt(mk, 16), Bool.pick(List<&2, X64Inst>, add1, x64_emit(XCmpRR{0, 1}, x64_emit(XAluRI{0, 1, 1}, x64_emit(XMovRR{1, mk}, acc))), x64_emit(XCmpRR{0, mk}, acc)), x64_emit(XCmpRR{0, 1}, x64_emit_if(add1, XAluRI{0, 1, 1}, x64_emit(XLoad{1, 5, mk}, acc)))); x64_emit(XJcc{7, l_slow}, a1))
def x64_nw_emit_chk(+ctx: X64Ctx, +mk: U32, nw: X64Nw, +l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match nw:
    case X64Nw{+k, pj, +pn, +off}:
      match k:
        case 2: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XMovRI32{0, pn}, x64_nw_cmp_mk(mk, l_slow, False{}, x64_load_vreg(ctx, 0, pj, acc))))
        case 3: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, pn, x64_load_vreg(ctx, 0, pj, acc))))
        case 5: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XMovRI32{0, pj}, acc))
        case 6: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XMovRI32{0, U32.sub(pn, 1)}, x64_emit(XJcc{7, l_slow}, x64_emit(XCmpRI{0, pn}, x64_emit_if(U32.is_ne(off, 0), XShift{8, 0, off, False{}}, x64_load_vreg(ctx, 0, pj, acc))))))
        case 0: acc
        case _: x64_nw_cmp_mk(mk, l_slow, U32.is_eq(k, 4), x64_emit_if(U32.is_ne(off, 0), XAluRI{0, 0, off}, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, pn, x64_load_vreg(ctx, 0, pj, acc)))))
def x64_ctx_ver(nc: Bool, +off: U32, +mk1_ov: U32, nw0: Bool, nw1: Bool, nw2: Bool, ctx: X64Ctx) -> X64Ctx:
  X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, X64Ha{h0, d0, m0, s0}, X64Ha{h1, d1, m1, s1}, X64Ha{h2, d2, m2, s2}, hax, _, _, cv, cm, r2, X64HMag{hm0, hr0, hm1, hr1, +t0c, t0t, t0e, t0d}, bor}} = ctx
  +sh = Bool.pick(U32, U32.is_ne(t0c, 0), off, 0)
  nm1 = Bool.pick(U32, nw1, 65535, Bool.pick(U32, U32.is_ne(mk1_ov, 0), mk1_ov, m1))
  X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, X64Ha{h0, d0, Bool.pick(U32, nw0, 65535, m0), s0}, X64Ha{h1, d1, nm1, s1}, X64Ha{h2, d2, Bool.pick(U32, nw2, 65535, m2), s2}, hax, nc, off, cv, cm, r2, X64HMag{hm0, hr0, hm1, hr1, t0c, U32.add(t0t, sh), U32.add(t0e, sh), t0d}, bor}}
def x64_nw_is_ok(nw: X64Nw) -> Bool:
  X64Nw{k, _, _, _} = nw
  U32.is_ne(k, 0)
def x64_fin_shared_ret(ctx: X64Ctx, st: X64Acc) -> X64Acc:
  match ctx st:
    case X64Ctx{_, _, _, _, _, _, _, _, ce, _, X64Meta{True{}, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, _, _, _, _, _}, _, _}} X64Acc{insts, lbl, cold}:
      X64Acc{x64_when(U32.is_ne(U32.and(csm, 8), 0), insts, a => x64_emit(XRet{}, x64_push_pop_list(False{}, b5k_list_rev(U32, ce), x64_emit(XLabel{2147614717}, a)))), lbl, cold}
    case _ _: st
# General Counted Array<F32> Map Auto-Vectorizer (8-wide AVX1)
type V8Arr is Data:
  V8Arr{ok: Bool, fid: U32, name: String, ar: U32, nregs: U32, idx_p: U32, in_p: U32, in_val: U32, out_p: U32, out_val: U32, invs: List<&2, U32>, fops: List<&2, IrOp>}
type V8AScan is Data:
  V8AScan{ok: Bool, idx_p: U32, idx_n: U32, in_p: U32, in_n: U32, in_v: U32, out_p: U32, out_n: U32, out_v: U32, nf: U32, fops: List<&2, IrOp>}
def v8a_no() -> V8Arr: V8Arr{False{}, 0, "", 0, 0, 0, 0, 0, 0, 0, Nil{}, Nil{}}
def v8a_is_ctl(+pdec: U32, +ip: U32, +in0: U32, +ap: U32, +an: U32, +op: U32, +on: U32, +v: U32) -> Bool: Bool.or(U32.is_zero(v), Bool.or(U32.is_eq(v, pdec), Bool.or(U32.is_eq(v, ip), Bool.or(Bool.and(U32.is_ne(in0, 0), U32.is_eq(v, in0)), Bool.or(Bool.and(U32.is_ne(ap, 0), U32.is_eq(v, ap)), Bool.or(Bool.and(U32.is_ne(an, 0), U32.is_eq(v, an)), Bool.or(Bool.and(U32.is_ne(op, 0), U32.is_eq(v, op)), Bool.and(U32.is_ne(on, 0), U32.is_eq(v, on)))))))))
def v8a_scan_ops(+vd: Nat, +c31: RaVec<U32>, +ar: U32, +pdec: U32, ops: List<&2, IrOp>, st: V8AScan) -> V8AScan:
  match ops st:
    case Nil{} _: st
    case _ V8AScan{False{}, _, _, _, _, _, _, _, _, _, _}: V8AScan{False{}, 0, 0, 0, 0, 0, 0, 0, 0, 0, Nil{}}
    case Con{IConst{_, 1}, t} _: v8a_scan_ops(vd, c31, ar, pdec, t, st)
    case Con{IBin{+d, +bop, 0, r}, t} _: Bool.pick(V8AScan, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), Bool.and(U32.is_eq(d, pdec), U32.is_eq(ra_vec_get(U32, vd, 0, r, c31), 2))), v8a_scan_ops(vd, c31, ar, pdec, t, st), V8AScan{False{}, 0, 0, 0, 0, 0, 0, 0, 0, 0, Nil{}})
    case Con{IBin{+d, 0, +l, +r}, t} V8AScan{_, +ip, +in0, ap, an, av, op, on, ov, nf, fops}: (+lr = Bool.and(U32.is_gt(l, 0), Bool.and(U32.is_lt(l, ar), U32.is_eq(ra_vec_get(U32, vd, 0, r, c31), 2))); +rl = Bool.and(U32.is_gt(r, 0), Bool.and(U32.is_lt(r, ar), U32.is_eq(ra_vec_get(U32, vd, 0, l, c31), 2))); +nip = Bool.pick(U32, lr, l, r); +ok = Bool.and(U32.is_zero(in0), Bool.and(Bool.or(lr, rl), Bool.or(U32.is_zero(ip), U32.is_eq(nip, ip)))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, nip, d, ap, an, av, op, on, ov, nf, fops}))
    case Con{IArrOp{Con{+a1, Con{+x0, Nil{}}}, 72, Con{+ap, Con{+iv, Nil{}}}}, t} V8AScan{_, +ip, in0, +ap0, an, av, op, on, ov, nf, fops}: (+iok = Bool.pick(Bool, U32.is_zero(ip), Bool.and(U32.is_gt(iv, 0), U32.is_lt(iv, ar)), U32.is_eq(iv, ip)); +ok = Bool.and(U32.is_zero(ap0), Bool.and(U32.is_gt(ap, 0), Bool.and(U32.is_lt(ap, ar), iok))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, Bool.pick(U32, U32.is_zero(ip), iv, ip), in0, ap, a1, x0, op, on, ov, nf, fops}))
    case Con{IArrOp{Con{+x0, Nil{}}, 78, Con{+ap, Con{+iv, Nil{}}}}, t} V8AScan{_, +ip, in0, +ap0, an, av, op, on, ov, nf, fops}: (+iok = Bool.pick(Bool, U32.is_zero(ip), Bool.and(U32.is_gt(iv, 0), U32.is_lt(iv, ar)), U32.is_eq(iv, ip)); +ok = Bool.and(U32.is_zero(ap0), Bool.and(U32.is_gt(ap, 0), Bool.and(U32.is_lt(ap, ar), iok))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, Bool.pick(U32, U32.is_zero(ip), iv, ip), in0, ap, ap, x0, op, on, ov, nf, fops}))
    case Con{IArrOp{Con{+o1, Nil{}}, +aop, Con{+op, Con{+iv, Con{+nv, Nil{}}}}}, t} V8AScan{_, +ip, in0, ap, an, av, +op0, on, ov, nf, fops}: (+iok = Bool.pick(Bool, U32.is_zero(ip), Bool.and(U32.is_gt(iv, 0), U32.is_lt(iv, ar)), U32.is_eq(iv, ip)); +ok = Bool.and(Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 79)), Bool.and(U32.is_zero(op0), Bool.and(U32.is_gt(op, 0), Bool.and(U32.is_lt(op, ar), iok)))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, Bool.pick(U32, U32.is_zero(ip), iv, ip), in0, ap, an, av, op, o1, nv, nf, fops}))
    case Con{IFlt{d, b}, t} V8AScan{_, ip, in0, ap, an, av, op, on, ov, nf, fops}: v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{True{}, ip, in0, ap, an, av, op, on, ov, U32.add(nf, 1), Con{IFlt{d, b}, fops}})
    case Con{ICopy{d, +s}, t} V8AScan{_, +ip, +in0, +ap, +an, av, +op, +on, ov, nf, fops}: v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{Bool.not(v8a_is_ctl(pdec, ip, in0, ap, an, op, on, s)), ip, in0, ap, an, av, op, on, ov, nf, Con{ICopy{d, s}, fops}})
    case Con{IBin{d, +bop, +l, +r}, t} V8AScan{_, +ip, +in0, +ap, +an, av, +op, +on, ov, nf, fops}: (+ok = Bool.and(Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), Bool.and(Bool.not(v8a_is_ctl(pdec, ip, in0, ap, an, op, on, l)), Bool.not(v8a_is_ctl(pdec, ip, in0, ap, an, op, on, r)))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, ip, in0, ap, an, av, op, on, ov, U32.add(nf, 1), Con{IBin{d, bop, l, r}, fops}}))
    case Con{IUn{d, +uop, +s}, t} V8AScan{_, +ip, +in0, +ap, +an, av, +op, +on, ov, nf, fops}: (+ok = Bool.and(Bool.or(U32.is_eq(uop, 2), U32.is_eq(uop, 3)), Bool.not(v8a_is_ctl(pdec, ip, in0, ap, an, op, on, s))); v8a_scan_ops(vd, c31, ar, pdec, t, V8AScan{ok, ip, in0, ap, an, av, op, on, ov, U32.add(nf, 1), Con{IUn{d, uop, s}, fops}}))
    case _ _: V8AScan{False{}, 0, 0, 0, 0, 0, 0, 0, 0, 0, Nil{}}
def v8a_chk_tf(tf: List<&2, U32>, +ip: U32, +in0: U32, +ap: U32, +an: U32, +op: U32, +on: U32, +idx: U32, +invs: List<&2, U32>) -> Bool & List<&2, U32>:
  match tf:
    case Nil{}: (True{}, b5k_list_rev(U32, invs))
    case Con{+a, t}: (+is_i = U32.is_eq(idx, ip); +is_a = U32.is_eq(idx, ap); +is_o = U32.is_eq(idx, op); +ok = Bool.pick(Bool, is_i, U32.is_eq(a, in0), Bool.pick(Bool, is_a, U32.is_eq(a, an), Bool.pick(Bool, is_o, U32.is_eq(a, on), U32.is_eq(a, idx)))); +invs1 = Bool.pick(List<&2, U32>, Bool.or(is_i, Bool.or(is_a, is_o)), invs, Con{idx, invs}); Bool.pick(Bool & List<&2, U32>, ok, v8a_chk_tf(t, ip, in0, ap, an, op, on, U32.add(idx, 1), invs1), (False{}, Nil{})))
def v8a_find_blk(blks: List<&2, IrBlock>, +bid: U32) -> Maybe<&2, IrBlock>:
  match blks:
    case Nil{}: None{}
    case Con{IrBlock{+id, ops, term}, t}: Bool.pick(Maybe<&2, IrBlock>, U32.is_eq(id, bid), Some{IrBlock{id, ops, term}}, v8a_find_blk(t, bid))
def v8a_match_scan(+fid: U32, +name: String, +ar: U32, +nregs: U32, +tf: List<&2, U32>, sc: V8AScan) -> V8Arr:
  V8AScan{+sok, +ip, +in0, +ap, +an, +av, +op, +on, +ov, +nf, fops_r} = sc
  +ok1 = Bool.and(sok, Bool.and(U32.is_ge(nf, 4), Bool.and(U32.is_ne(ip, 0), Bool.and(U32.is_ne(in0, 0), Bool.and(U32.is_ne(ap, 0), U32.is_ne(op, 0))))))
  low_if(V8Arr, ok1, _ => ra_un_pair(Bool, List<&2, U32>, V8Arr, v8a_chk_tf(tf, ip, in0, ap, an, op, on, 1, Nil{}), tok => +invs => V8Arr{Bool.and(tok, U32.is_le(b5k_u32_list_len(invs), 8)), fid, name, ar, nregs, ip, ap, av, op, ov, invs, b5k_list_rev(IrOp, fops_r)}), _ => v8a_no())
def v8a_match_step(+fid: U32, +name: String, +ar: U32, +nregs: U32, +vd: Nat, +c31: RaVec<U32>, mb: Maybe<&2, IrBlock>) -> V8Arr:
  match mb:
    case Some{IrBlock{_, sops, TTailCall{+tfid, Con{+pdec, +tf}}}}: (+ok0 = Bool.and(U32.is_eq(tfid, fid), U32.is_eq(b5k_u32_list_len(tf), U32.sub(ar, 1))); low_if(V8Arr, ok0, _ => v8a_match_scan(fid, name, ar, nregs, tf, v8a_scan_ops(vd, c31, ar, pdec, sops, V8AScan{True{}, 0, 0, 0, 0, 0, 0, 0, 0, 0, Nil{}})), _ => v8a_no()))
    case _: v8a_no()
def v8a_match_b0(+fid: U32, +name: String, +ar: U32, +nregs: U32, +vd: Nat, +c31: RaVec<U32>, +blks: List<&2, IrBlock>) -> V8Arr:
  match blks:
    case Con{IrBlock{0, Nil{}, TBr{0, +tb, _}}, _}: v8a_match_step(fid, name, ar, nregs, vd, c31, v8a_find_blk(blks, tb))
    case Con{IrBlock{0, Con{IConst{+zr, 0}, Con{ICmp{+cr, 0, 0, +zr2}, Nil{}}}, TBr{+c, _, +fb}}, _}: Bool.pick(V8Arr, Bool.and(U32.is_eq(zr, zr2), U32.is_eq(cr, c)), v8a_match_step(fid, name, ar, nregs, vd, c31, v8a_find_blk(blks, fb)), v8a_no())
    case Con{IrBlock{0, Con{ICmp{+cr, 0, 0, +zr}, Nil{}}, TBr{+c, _, +fb}}, _}: Bool.pick(V8Arr, Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, zr, c31), 1), U32.is_eq(cr, c)), v8a_match_step(fid, name, ar, nregs, vd, c31, v8a_find_blk(blks, fb)), v8a_no())
    case _: v8a_no()
def v8a_dp_of(+p: U32, +h0: U32, +d0: U32, +ok0: Bool, +h1: U32, +d1: U32, +ok1: Bool, +h2: U32, +d2: U32, +ok2: Bool) -> U32: (+t = U32.add(p, 1); Bool.pick(U32, Bool.and(ok0, U32.is_eq(h0, t)), d0, Bool.pick(U32, Bool.and(ok1, U32.is_eq(h1, t)), d1, Bool.pick(U32, Bool.and(ok2, U32.is_eq(h2, t)), d2, 0))))
def v8a_load_dp(+reg: U32, +dp: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit(Bool.pick(X64Inst, U32.is_lt(dp, 16), XMovRR{reg, dp}, XLoad{reg, 5, dp}), acc)
def v8a_inv_io(+is_ld: Bool, +ctx: X64Ctx, invs: List<&2, U32>, +m: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match invs:
    case Nil{}: acc
    case Con{+p, t}: (+off = U32.mul(m, 4); a1 = Bool.pick(List<&2, X64Inst>, is_ld, x64_store_xmm(ctx, p, 0, x64_emit(XXmmLoad{0, 4, off}, acc)), x64_emit(XXmmStore{4, off, 32}, x64_load_xmm(ctx, 0, p, acc))); v8a_inv_io(is_ld, ctx, t, U32.add(m, 1), a1))
def v8a_emit_caller(va: V8Arr, +ctx: X64Ctx, +sym: String, +h0: U32, +d0: U32, +ok0: Bool, +h1: U32, +d1: U32, +ok1: Bool, +h2: U32, +d2: U32, +ok2: Bool, +lbl: U32, +acc: List<&2, X64Inst>) -> X64Acc:
  match va:
    case V8Arr{True{}, _, _, _, _, +ip, +ap, _, +op, _, +invs, _}: (+dp_in = v8a_dp_of(ap, h0, d0, ok0, h1, d1, ok1, h2, d2, ok2); +dp_out = v8a_dp_of(op, h0, d0, ok0, h1, d1, ok1, h2, d2, ok2); +can = Bool.and(U32.is_ne(dp_in, 0), U32.is_ne(dp_out, 0)); low_if(X64Acc, can, _ => a0 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{7, 7}, x64_emit(XShift{9, 7, 3, False{}}, x64_load_vreg(ctx, 7, 0, acc)))); a1 = v8a_inv_io(False{}, ctx, invs, 0, a0); a2 = x64_emit(XMovRR{1, 4}, x64_emit(XAluRR{0, 2, 0}, v8a_load_dp(2, dp_out, x64_emit(XAluRR{0, 6, 0}, v8a_load_dp(6, dp_in, x64_emit(XShift{8, 0, 3, False{}}, x64_load_vreg(ctx, 0, ip, a1))))))); a3 = v8a_inv_io(True{}, ctx, invs, 0, x64_emit(XCallSym{sym}, a2)); a4 = x64_store_vreg(ctx, ip, 1, x64_emit(XAluRR{0, 1, 0}, x64_load_vreg(ctx, 1, ip, x64_emit(XAluRI{5, 0, 4294967288}, x64_load_vreg(ctx, 0, 0, a3))))); a5 = x64_emit(XLabel{lbl}, x64_store_vreg(ctx, 0, 0, x64_emit(XAluRI{5, 0, 7}, x64_load_vreg(ctx, 0, 0, a4)))); X64Acc{a5, U32.add(lbl, 1), Nil{}}, _ => X64Acc{acc, lbl, Nil{}}))
    case _: X64Acc{acc, lbl, Nil{}}
def x64_emit_fn_blks(ver_ok: Bool, +ctx: X64Ctx, +fn_map: RaVec<String>, +uc: RaVec<U32>, +vd: Nat, +fn_fid: U32, +arity: U32, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc) -> X64Acc:
  match ver_ok:
    case False{}: x64_fin_shared_ret(ctx, x64_emit_blocks(ctx, fn_map, uc, x64_ru_go(x64_blks_any(1, 0, blocks), ctx, vd, blocks), x64_blk_preds(blocks), blocks, 0n, st0))
    case True{}:
      X64Ctx{_, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, +ao, X64Ha{+h0, +d0, +m0, s0}, X64Ha{+h1, +d1, +m1, s1}, X64Ha{+h2, +d2, +m2, s2}, hax, _, _, +c31, _, _, X64HMag{_, _, _, _, +t0c, _, +t0e, +t0d}, _}} = ctx
      X64Acc{a0, l0, c0} = st0
      +pn = Bool.pick(U32, U32.is_ne(t0c, 0), U32.sub(t0c, 1), 0)
      +nw0 = x64_nw_analyze_one(h0, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +nw1 = x64_nw_analyze_one(h1, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +nw2 = x64_nw_analyze_one(h2, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +ok0 = x64_nw_is_ok(nw0)
      +ok1 = x64_nw_is_ok(nw1)
      +ok2 = x64_nw_is_ok(nw2)
      +m1sp = Bool.pick(U32, Bool.and(Bool.not(ok1), Bool.and(Bool.and(U32.is_ne(h1, 0), U32.is_zero(h2)), Bool.and(U32.is_lt(d0, 16), Bool.and(U32.is_lt(d1, 16), U32.is_ge(m1, 16))))), m1, 0)
      +use_rdx = Bool.and(U32.is_ne(m1sp, 0), x64_rdx_safe_walk(fn_fid, rm, vd, blocks, Nil{}, 0))
      a_pre = x64_ver_chk_dp_list(hax, 65536, x64_ver_chk_dp(X64Ha{h2, d2, m2, s2}, 65536, x64_ver_chk_dp(X64Ha{h1, d1, m1, s1}, 65536, x64_ver_chk_dp(X64Ha{h0, d0, m0, s0}, 65536, a0))))
      a_nw = x64_nw_emit_chk(ctx, m2, nw2, 65536, x64_nw_emit_chk(ctx, m1, nw1, 65536, x64_nw_emit_chk(ctx, m0, nw0, 65536, a_pre)))
      x64_un_acc(X64Acc, v8a_emit_caller(v8a_match_b0(fn_fid, "", arity, 0, vd, c31, blocks), ctx, String.append("$v8a.", x64_lookup_fn_sym(fn_map, fn_fid)), h0, d0, ok0, h1, d1, ok1, h2, d2, ok2, l0, a_nw), a_v8 => l_v8 => _ => ( a_chk = x64_emit_if(use_rdx, XLoad{2, 5, m1sp}, a_v8); x64_un_acc(X64Acc, x64_emit_blocks(x64_ctx_ver(True{}, 0, Bool.pick(U32, use_rdx, 2, 0), ok0, ok1, ok2, ctx), fn_map, uc, x64_ru_go(x64_blks_any(1, 0, blocks), ctx, vd, blocks), x64_blk_preds(blocks), blocks, 0n, X64Acc{a_chk, l_v8, c0}), insts1 => lbl1 => cold1 => (+lbl1a = lbl1; X64Acc{insts1, lbl1a, x64_acc_insts(x64_emit_blocks(x64_ctx_ver(False{}, 65536, 0, False{}, False{}, False{}, ctx), fn_map, uc, RVEmpty{}, RVEmpty{}, x64_shift_blks(65536, blocks), 0n, X64Acc{cold1, lbl1a, Nil{}}))}))))
def x64_ctx_clr_bor(ctx: X64Ctx) -> X64Ctx:
  X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, h1, h2, hax, nc, lb, cv, cm, r2, hm, _}} = ctx
  X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, h1, h2, hax, nc, lb, cv, cm, r2, hm, X64Bor{0, RVEmpty{}}}}
def x64_lower_fn_o2_own(+ver_ok: Bool, +ctx: X64Ctx, +fn_map: RaVec<String>, +fn_fid: U32, +name: String, +arity: U32, +bpm: U32, +uc: RaVec<U32>, +vd: Nat, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc, +bn: String, +on: String, oa: X64Acc, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  X64Acc{oinsts, +onl, ocold} = oa
  own_fn: X64Fn = X64Fn{on, False{}, b5k_list_rev(X64Inst, x64_acc_insts(X64Acc{oinsts, onl, x64_bor_wrap_body(name, arity, bpm, onl, x64_emit(XLabel{2147614718}, ocold))}))}
  a_own = x64_emit(XLabel{2147614718}, x64_emit(XRet{}, x64_emit(XAddRsp{8}, x64_emit(XCallSym{on}, x64_emit(XSubRsp{8}, x64_bor_sh_chk(U32.to_nat(arity), 0, bpm, 2147614718, Nil{}))))))
  Con{X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_bor_wrap_body(name, arity, bpm, 1, a_own))}, Con{own_fn, Con{X64Fn{bn, False{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, ra_vec_set(String, 9n, fn_fid, bn, fn_map), uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}}}
def x64_lower_fn_o2_w(is_b: Bool, bor_own: Bool, +ver_ok: Bool, +ctx: X64Ctx, +fn_map: RaVec<String>, +fn_fid: U32, +name: String, +arity: U32, +bpm: U32, +uc: RaVec<U32>, +vd: Nat, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc, st0_own: X64Acc, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_b bor_own:
    case False{} _: Con{X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, fn_map, uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}
    case True{} False{}: (+bn = String.append("$bor.", name); Con{X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_bor_wrap_body(name, arity, bpm, 1, Nil{}))}, Con{X64Fn{bn, False{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, ra_vec_set(String, 9n, fn_fid, bn, fn_map), uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}})
    case True{} True{}: (+bn = String.append("$bor.", name); +on = String.append("$own.", name); x64_lower_fn_o2_own(ver_ok, ctx, fn_map, fn_fid, name, arity, bpm, uc, vd, rm, blocks, st0, bn, on, x64_emit_fn_blks(ver_ok, x64_ctx_clr_bor(ctx), ra_vec_set(String, 9n, fn_fid, on, fn_map), uc, vd, fn_fid, arity, rm, blocks, st0_own), acc))
def x64_alloca_w(op: IrOp, m: U32) -> U32:
  match op:
    case IAlloca{_, w}: U32.max(m, w)
    case _: m
def x64_max_alloca(blks: List<&2, IrBlock>) -> U32: opt_foldl0(~IrBlock, ~U32, ~(b => m => opt_un_blk(U32, b, _ => ops1 => _ => opt_foldl0(~IrOp, ~U32, ~x64_alloca_w, ops1, m))), blks, 0)
def x64_max_alloca_if(go: Bool, blks: List<&2, IrBlock>) -> U32:
  match go:
    case True{}: x64_max_alloca(blks)
    case False{}: 0
def x64_filter_ce(+vd: Nat, +nregs: U32, ce: List<&2, U32>, +rm: RaVec<U32>, +c31: RaVec<U32>, +cm: RaVec<Bool>) -> List<&2, U32>:
  match ce:
    case Nil{}: Nil{}
    case Con{+r, t}: x64_cons_if(x64_rm_other_has_reg(vd, U32.to_nat(nregs), 0, r, 4294967295, rm, c31, cm), r, x64_filter_ce(vd, nregs, t, rm, c31, cm))
def x64_o2_pro(cond: Bool, +ctx: X64Ctx, is_leaf: Bool, sw: U32, lf: X64SwLeaf, bpre: U32, +arity: U32, ce: List<&2, U32>, frame: U32, sd: U32, has_mr: Bool, has_md: Bool, mr: U32, md: U32, +hr0: U32, hm0: U32, +hr1: U32, hm1: U32, h0: U32, d0: U32, m0: U32, h1: U32, d1: U32, m1: U32, h2: U32, d2: U32, m2: U32, hax: List<&2, X64Ha>) -> X64Acc:
  match cond:
    case False{}: X64Acc{Nil{}, 2147483648, Nil{}}
    case True{}: (a3 = x64_emit_if(U32.is_ne(hr1, 0), XMovRI32{hr1, hm1}, x64_emit_if(U32.is_ne(hr0, 0), XMovRI32{hr0, hm0}, x64_save_params_go(ctx, U32.to_nat(arity), 0, x64_emit_if(U32.is_ge(arity, 5), XMovRR{7, 9}, x64_emit_if(U32.is_ge(arity, 4), XMovRR{0, 8}, x64_o2_prologue_pre(is_leaf, sw, lf, bpre, arity, ce, frame, sd, has_mr, has_md, mr, md)))))); x64_init_hoist_list(ctx, hax, x64_init_hoist_one(ctx, h2, d2, m2, x64_init_hoist_one(ctx, h1, d1, m1, x64_init_hoist_one(ctx, h0, d0, m0, X64Acc{a3, 2147483648, Nil{}})))))
type X64RegPick is Data:
  X64RegPick{r: U32, ce: List<&2, U32>, cs: List<&2, U32>}
def x64_alloc_hr(want: Bool, acs: Bool, +ce: List<&2, U32>, +cs: List<&2, U32>) -> X64RegPick:
  +r = x64_pick_hreg(want, acs, ce, cs)
  X64RegPick{r, x64_cons_if(Bool.and(U32.is_ne(r, 0), Bool.not(x64_is_cs_reg(r))), r, ce), x64_cons_if(x64_is_cs_reg(r), r, cs)}
type X64HaAlloc is Data:
  X64HaAlloc{dp: U32, mk: U32, b: U32}
def x64_alloc_ha(+ha: U32, +dp_r: U32, +mk_r: U32, +b: U32) -> X64HaAlloc:
  +b1 = Bool.pick(U32, Bool.and(U32.is_ne(ha, 0), U32.is_zero(dp_r)), U32.add(b, 8), b)
  +b2 = Bool.pick(U32, Bool.and(U32.is_ne(ha, 0), U32.is_zero(mk_r)), U32.add(b1, 8), b1)
  X64HaAlloc{Bool.pick(U32, U32.is_ne(dp_r, 0), dp_r, Bool.pick(U32, U32.is_ne(ha, 0), U32.sub(0, b1), 0)), Bool.pick(U32, U32.is_ne(mk_r, 0), mk_r, Bool.pick(U32, U32.is_ne(ha, 0), U32.sub(0, b2), 0)), b2}
def x64_un_rp(-R: Type, p: X64RegPick, k: U32 -> List<&2, U32> -> List<&2, U32> -> R) -> R:
  X64RegPick{r, ce, cs} = p
  k(r, ce, cs)
def x64_un_haa(-R: Type, h: X64HaAlloc, k: U32 -> U32 -> U32 -> R) -> R:
  X64HaAlloc{dp, mk, b} = h
  k(dp, mk, b)
type X64O2R1 is Data:
  X64O2R1{dp0: U32, dp1: U32, dp2: U32, mk0: U32, mk1: U32, mk2: U32, hr0: U32, hr1: U32, mr: U32, ce: List<&2, U32>, rm1: RaVec<U32>, sc1: U32}
def x64_o2_r1_b(+dp0: U32, +dp1: U32, +dp2: U32, +mk0: U32, +um: Bool, +h_first: Bool, +mr0: U32, +hm0: U32, +hm1: U32, +t0c: U32, +acs: Bool, +vd: Nat, +pn: U32, +rm1a: RaVec<U32>, sc1: U32, p1: X64RegPick, p2: X64RegPick) -> X64O2R1:
  X64RegPick{mk1, _, _} = p1
  X64RegPick{mk2, +ce5a, cs4b} = p2
  +mr = Bool.pick(U32, Bool.and(um, h_first), x64_pick_free_callee(ce5a), mr0)
  +ce5 = x64_cons_if(Bool.and(h_first, U32.is_ne(mr, 0)), mr, ce5a)
  x64_un_rp(X64O2R1, x64_alloc_hr(U32.is_ne(hm0, 0), acs, ce5, cs4b), hr0 => ce6 => cs5 => x64_un_rp(X64O2R1, x64_alloc_hr(U32.is_ne(hm1, 0), acs, ce6, cs5), hr1 => ce7 => cs6 => x64_un_rp(X64O2R1, x64_alloc_hr(Bool.and(acs, Bool.and(U32.is_ne(t0c, 0), U32.is_ge(ra_vec_get(U32, vd, 0, pn, rm1a), 100))), acs, ce7, cs6), cr0 => ce => _ => (+cnt_r = cr0; X64O2R1{dp0, dp1, dp2, mk0, mk1, mk2, hr0, hr1, mr, ce, Bool.pick(RaVec<U32>, U32.is_ne(cnt_r, 0), ra_vec_set(U32, vd, pn, cnt_r, rm1a), rm1a), sc1}))))
def x64_o2_r1_a(+ha0: U32, +ha1: U32, +ha2: U32, +hm0: U32, +hm1: U32, +t0c: U32, +t0e: U32, +t0d: Bool, +um: Bool, +h_first: Bool, +mr0: U32, +acs: Bool, +stc: Bool, +vd: Nat, +nregs: U32, +arity: U32, +fn_fid: U32, +rm: RaVec<U32>, +sc: U32, +c31: RaVec<U32>, +cm: RaVec<Bool>, +ao: RaVec<U32>, +blocks: List<&2, IrBlock>, p0: X64RegPick, p1: X64RegPick, p2: X64RegPick) -> X64O2R1:
  X64RegPick{+dp0, _, _} = p0
  X64RegPick{+dp1, _, _} = p1
  X64RegPick{+dp2, +ce3b, +cs2b} = p2
  +pn = Bool.pick(U32, U32.is_ne(t0c, 0), U32.sub(t0c, 1), 0)
  +nw0_sp = Bool.and(Bool.and(stc, U32.is_ne(ha0, 0)), Bool.and(U32.is_le(b5k_list_len(IrBlock, blocks), 64), x64_nw_is_ok(x64_nw_analyze_one(ha0, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks))))
  +mk0_r0 = x64_pick_hreg(Bool.and(U32.is_ne(ha0, 0), Bool.not(nw0_sp)), Bool.and(acs, U32.is_ne(dp0, 0)), ce3b, cs2b)
  +p0_v = U32.sub(ha0, 1)
  +p0_r = Bool.pick(U32, Bool.and(stc, Bool.and(Bool.not(nw0_sp), Bool.and(U32.is_ne(ha0, 0), Bool.and(U32.is_lt(ha0, 65536), U32.is_zero(mk0_r0))))), ra_vec_get(U32, vd, 0, p0_v, rm), 100)
  +dem0 = Bool.and(x64_is_gpr(p0_r), Bool.not(x64_rm_other_has_reg(vd, U32.to_nat(nregs), 0, p0_r, p0_v, rm, c31, cm)))
  +rm1a = Bool.pick(RaVec<U32>, dem0, ra_vec_set(U32, vd, p0_v, U32.add(100, sc), rm), rm)
  +sc1 = Bool.pick(U32, dem0, U32.add(sc, 1), sc)
  +mk0 = Bool.pick(U32, dem0, p0_r, mk0_r0)
  +ce4 = x64_cons_if(Bool.and(U32.is_ne(mk0, 0), Bool.and(Bool.not(dem0), Bool.not(x64_is_cs_reg(mk0)))), mk0, ce3b)
  +cs3 = x64_cons_if(x64_is_cs_reg(mk0), mk0, cs2b)
  x64_un_rp(X64O2R1, x64_alloc_hr(U32.is_ne(ha1, 0), Bool.and(acs, U32.is_ne(dp1, 0)), ce4, cs3), mk1 => ce4b => cs4 => x64_o2_r1_b(dp0, dp1, dp2, mk0, um, h_first, mr0, hm0, hm1, t0c, acs, vd, pn, rm1a, sc1, X64RegPick{mk1, Nil{}, Nil{}}, x64_alloc_hr(U32.is_ne(ha2, 0), Bool.and(acs, U32.is_ne(dp2, 0)), ce4b, cs4)))
type X64HaxAlloc is Data:
  X64HaxAlloc{hax: List<&2, X64Ha>, b: U32}
def x64_alloc_hax(hx: List<&2, X64Ha>, +b: U32, acc: List<&2, X64Ha>) -> X64HaxAlloc:
  match hx:
    case Nil{}: X64HaxAlloc{acc, b}
    case Con{X64Ha{ha, _, _, sc}, t}: (+b1 = U32.add(b, 8); +b2 = U32.add(b1, 8); x64_alloc_hax(t, b2, Con{X64Ha{ha, U32.sub(0, b1), U32.sub(0, b2), sc}, acc}))
def x64_nu_sc_hax(hs: List<&2, X64Ha>, +vd: Nat, +nu: RaVec<Bool>, +ao: RaVec<U32>, +blocks: List<&2, IrBlock>) -> List<&2, X64Ha>:
  match hs:
    case Nil{}: Nil{}
    case Con{X64Ha{+ha, dp, mk, sc}, t}: Con{X64Ha{ha, dp, mk, x64_nu_sc_ha_go(sc, False{}, ha, vd, nu, ao, blocks)}, x64_nu_sc_hax(t, vd, nu, ao, blocks)}
def x64_hax_all_sc(hs: List<&2, X64Ha>) -> Bool:
  match hs:
    case Nil{}: True{}
    case Con{X64Ha{_, _, _, sc}, t}: Bool.and(sc, x64_hax_all_sc(t))
def x64_o2_emit_fin(+small: Bool, +fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, +fn_fid: U32, +name: String, +arity: U32, +nregs: U32, +blocks: List<&2, IrBlock>, +vd: Nat, +c31: RaVec<U32>, +is_sc: RaVec<U32>, nf: Bool, +stc: Bool, +harr: Bool, +ao: RaVec<U32>, hp: X64HPick, hm: X64HMag, bor: X64Bor, uc: RaVec<U32>, hist: X64HiSt, +um: Bool, r1: X64O2R1, a0: X64HaAlloc, a1: X64HaAlloc, a2: X64HaAlloc, ax: X64HaxAlloc, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  X64R2Scan{+r2m, u2m} = r2s
  X64HPick{+ha0, ha0_sc, +ha1, ha1_sc, +ha2, ha2_sc, _} = hp
  X64HMag{+hm0, _, +hm1, _, +t0c, t0t, +t0e, +t0d} = hm
  X64Bor{+bpm_raw, bbm} = bor
  X64HiSt{hu, +cm} = hist
  X64O2R1{_, _, _, _, _, _, +hr0, +hr1, +mr, +ce, +rm1, +sc1} = r1
  X64HaAlloc{+ha0_dp, +ha0_mk, _} = a0
  X64HaAlloc{+ha1_dp, +ha1_mk, _} = a1
  X64HaAlloc{+ha2_dp, +ha2_mk, _} = a2
  X64HaxAlloc{hax0, +b2d} = ax
  +bpm = U32.and(bpm_raw, 255)
  +bor_own = Bool.and(U32.is_ne(U32.and(bpm_raw, 65536), 0), Bool.and(U32.is_le(arity, 5), U32.is_le(b5k_list_len(IrBlock, blocks), 32)))
  +cur_r2 = ra_vec_get(U32, 8n, 0, fn_fid, r2m)
  +u2p = ra_vec_get(U32, 8n, 0, fn_fid, u2m)
  +has_mr = U32.is_ne(mr, 0)
  +has_md = Bool.and(um, Bool.not(has_mr))
  +k = b5k_u32_list_len(ce)
  +state_off = U32.mul(U32.add(k, 1), 8)
  +sd = U32.sub(0, state_off)
  +b0 = Bool.pick(U32, has_md, U32.add(state_off, 8), state_off)
  +md = Bool.pick(U32, has_md, U32.sub(0, b0), 0)
  +has_u2 = U32.is_ne(u2p, 0)
  +b3 = Bool.pick(U32, has_u2, U32.add(b2d, 16), b2d)
  u2o0 = Bool.pick(U32, has_u2, U32.sub(0, U32.add(b2d, 8)), 0)
  u2o1 = Bool.pick(U32, has_u2, U32.sub(0, b3), 0)
  +sb = U32.add(b3, 8)
  +aw = x64_max_alloca_if(Bool.or(small, harr), blocks)
  +ab = Bool.pick(U32, U32.is_zero(aw), 0, U32.add(256, x64_align16(U32.mul(aw, 8))))
  +frame = U32.sub(x64_align16(U32.add(U32.add(b3, U32.add(U32.mul(U32.max(16, arity), 8), ab)), U32.mul(sc1, 8))), U32.mul(k, 8))
  +is_leaf = Bool.and(Bool.and(Bool.and(U32.is_le(arity, 5), U32.is_zero(sc1)), Bool.and(Bool.not(um), Bool.and(U32.is_zero(ha0), Bool.not(nf)))), Bool.not(x64_blks_tail_scr(X64Ctx{True{}, rm1, vd, 0, 0, 0, 0, 0, Nil{}, 0, x64_empty_meta()}, blocks)))
  +nu = x64_run_nu(Bool.and(small, Bool.or(harr, um)), vd, arity, fn_fid, ao, blocks)
  +ha0_sc1 = x64_nu_sc_ha_go(ha0_sc, U32.is_zero(ha0), ha0, vd, nu, ao, blocks)
  +ha1_sc1 = x64_nu_sc_ha_go(ha1_sc, U32.is_zero(ha1), ha1, vd, nu, ao, blocks)
  +ha2_sc1 = x64_nu_sc_ha_go(ha2_sc, U32.is_zero(ha2), ha2, vd, nu, ao, blocks)
  +hax1 = x64_nu_sc_hax(hax0, vd, nu, ao, blocks)
  +ver_ok = Bool.and(Bool.and(stc, U32.is_ne(ha0, 0)), Bool.and(Bool.and(ha0_sc1, Bool.and(Bool.or(U32.is_zero(ha1), ha1_sc1), Bool.and(Bool.or(U32.is_zero(ha2), ha2_sc1), x64_hax_all_sc(hax1)))), U32.is_le(b5k_list_len(IrBlock, blocks), 64)))
  h_cs = Bool.or(Bool.or(x64_is_cs_reg(hr0), x64_is_cs_reg(hr1)), Bool.or(Bool.and(U32.is_ne(ha0, 0), Bool.or(x64_is_cs_reg(ha0_dp), x64_is_cs_reg(ha0_mk))), Bool.or(Bool.and(U32.is_ne(ha1, 0), Bool.or(x64_is_cs_reg(ha1_dp), x64_is_cs_reg(ha1_mk))), Bool.and(U32.is_ne(ha2, 0), Bool.or(x64_is_cs_reg(ha2_dp), x64_is_cs_reg(ha2_mk))))))
  +sh_ret = Bool.and(is_leaf, Bool.and(U32.is_ge(x64_count_rets(blocks, 0), 5), Bool.and(U32.is_zero(cur_r2), U32.is_zero(bpm))))
  +csm0 = U32.or(U32.or(Bool.pick(U32, is_leaf, 0, x64_rm_cs_mask(vd, U32.to_nat(nregs), 0, rm1, 0)), Bool.pick(U32, h_cs, 2, 0)), Bool.pick(U32, sh_ret, 8, 0))
  csm = U32.or(csm0, Bool.pick(U32, small, 0, 16))
  +ctx: X64Ctx = X64Ctx{True{}, rm1, vd, sb, sd, mr, md, frame, ce, heap_off, X64Meta{is_leaf, hu, is_sc, nu, ao, X64Ha{ha0, ha0_dp, ha0_mk, ha0_sc1}, X64Ha{ha1, ha1_dp, ha1_mk, ha1_sc1}, X64Ha{ha2, ha2_dp, ha2_mk, ha2_sc1}, hax1, False{}, 0, c31, cm, X64R2{csm, r2m, fn_fid, cur_r2, u2p, u2o0, u2o1}, X64HMag{hm0, hr0, hm1, hr1, t0c, t0t, t0e, t0d}, X64Bor{bpm, bbm}}}
  +sw_pak = Bool.pick(U32, Bool.or(is_leaf, Bool.not(small)), 0, x64_sw_find_pak(arity, blocks))
  +sw_z = Bool.pick(U32, Bool.or(is_leaf, Bool.or(Bool.not(small), U32.is_ne(bpm, 0))), 0, x64_sw_find(arity, blocks))
  +sw = Bool.pick(U32, U32.is_ne(sw_z, 0), sw_z, sw_pak)
  +sw_own = Bool.pick(U32, Bool.or(is_leaf, Bool.not(bor_own)), 0, Bool.pick(U32, U32.is_ne(sw_pak, 0), sw_pak, x64_sw_find(arity, blocks)))
  +sw_lf = Bool.pick(X64SwLeaf, Bool.and(Bool.not(is_leaf), Bool.and(small, Bool.and(U32.is_zero(cur_r2), U32.is_zero(sw)))), x64_sw_find_leaf(vd, arity, is_sc, blocks), SwLeafNo{})
  +sw_lf_own = Bool.pick(X64SwLeaf, Bool.and(bor_own, Bool.and(Bool.not(is_leaf), Bool.and(U32.is_zero(cur_r2), U32.is_zero(sw_own)))), sw_lf, SwLeafNo{})
  st0 = x64_o2_pro(True{}, ctx, is_leaf, sw, sw_lf, 0, arity, ce, frame, sd, has_mr, has_md, mr, md, hr0, hm0, hr1, hm1, ha0, ha0_dp, ha0_mk, ha1, ha1_dp, ha1_mk, ha2, ha2_dp, ha2_mk, hax1)
  st0_own = x64_o2_pro(bor_own, ctx, is_leaf, sw_own, sw_lf_own, bpm, arity, ce, frame, sd, has_mr, has_md, mr, md, hr0, hm0, hr1, hm1, ha0, ha0_dp, ha0_mk, ha1, ha1_dp, ha1_mk, ha2, ha2_dp, ha2_mk, hax1)
  x64_lower_fn_o2_w(U32.is_ne(bpm, 0), bor_own, ver_ok, ctx, fn_map, fn_fid, name, arity, bpm, uc, vd, rm1, blocks, st0, st0_own, acc)
def x64_o2_emit_s2(small: Bool, fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, fn_fid: U32, name: String, arity: U32, nregs: U32, blocks: List<&2, IrBlock>, vd: Nat, c31: RaVec<U32>, is_sc: RaVec<U32>, nf: Bool, stc: Bool, harr: Bool, ao: RaVec<U32>, +hp: X64HPick, hm: X64HMag, bor: X64Bor, uc: RaVec<U32>, hist: X64HiSt, +um: Bool, +r1: X64O2R1, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  X64HPick{+ha0, _, +ha1, _, +ha2, _, +hx} = hp
  X64O2R1{dp0, dp1, dp2, mk0, mk1, mk2, _, _, mr, ce, _, _} = r1
  +state_off = U32.mul(U32.add(b5k_u32_list_len(ce), 1), 8)
  +a0 = x64_alloc_ha(ha0, dp0, mk0, Bool.pick(U32, Bool.and(um, U32.is_zero(mr)), U32.add(state_off, 8), state_off))
  +a1 = x64_un_haa(X64HaAlloc, a0, _ => _ => b1 => x64_alloc_ha(ha1, dp1, mk1, b1))
  +a2 = x64_un_haa(X64HaAlloc, a1, _ => _ => b2 => x64_alloc_ha(ha2, dp2, mk2, b2))
  ax = x64_un_haa(X64HaxAlloc, a2, _ => _ => b2d => x64_alloc_hax(hx, b2d, Nil{}))
  x64_o2_emit_fin(small, fn_map, heap_off, r2s, fn_fid, name, arity, nregs, blocks, vd, c31, is_sc, nf, stc, harr, ao, hp, hm, bor, uc, hist, um, r1, a0, a1, a2, ax, acc)
def x64_lower_fn_o2_emit(small: Bool, +fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, +fn_fid: U32, +name: String, +arity: U32, +nregs: U32, +blocks: List<&2, IrBlock>, +rm: RaVec<U32>, +vd: Nat, +ce0: List<&2, U32>, +sc: U32, +c31: RaVec<U32>, is_sc: RaVec<U32>, nf: Bool, +stc: Bool, harr: Bool, +ao: RaVec<U32>, +hp: X64HPick, +hm: X64HMag, bor: X64Bor, uc: RaVec<U32>, +hist: X64HiSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  X64HPick{+ha0, _, +ha1, _, +ha2, _, _} = hp
  X64HMag{+hm0, _, +hm1, _, +t0c, _, +t0e, +t0d} = hm
  X64HiSt{_, +cm} = hist
  +um = x64_blks_any(0, 0, blocks)
  +ce0f = x64_filter_ce(vd, nregs, ce0, rm, c31, cm)
  +h_first = Bool.and(stc, U32.is_ne(ha0, 0))
  +mr0 = Bool.pick(U32, Bool.and(um, Bool.not(h_first)), x64_pick_free_callee(ce0f), 0)
  +ce1 = x64_cons_if(U32.is_ne(mr0, 0), mr0, ce0f)
  +acs = Bool.and(Bool.not(x64_blks_any(2, fn_fid, blocks)), U32.is_ne(ha0, 0))
  +cs0 = x64_cons_if(Bool.and(acs, x64_rm_other_has_reg(vd, U32.to_nat(nregs), 0, 11, 4294967295, rm, c31, cm)), 11, x64_cons_if(Bool.and(acs, x64_rm_other_has_reg(vd, U32.to_nat(nregs), 0, 10, 4294967295, rm, c31, cm)), 10, Nil{}))
  +p0 = x64_alloc_hr(U32.is_ne(ha0, 0), acs, ce1, cs0)
  +p1 = x64_un_rp(X64RegPick, p0, _ => ce2 => cs1 => x64_alloc_hr(U32.is_ne(ha1, 0), acs, ce2, cs1))
  p2 = x64_un_rp(X64RegPick, p1, _ => ce3 => cs2 => x64_alloc_hr(U32.is_ne(ha2, 0), acs, ce3, cs2))
  x64_o2_emit_s2(small, fn_map, heap_off, r2s, fn_fid, name, arity, nregs, blocks, vd, c31, is_sc, nf, stc, harr, ao, hp, hm, bor, uc, hist, um, x64_o2_r1_a(ha0, ha1, ha2, hm0, hm1, t0c, t0e, t0d, um, h_first, mr0, acs, stc, vd, nregs, arity, fn_fid, rm, sc, c31, cm, ao, blocks, p0, p1, p2), acc)
def x64_def_sc(d: X64DefSt) -> RaVec<U32>:
  X64DefSt{_, sc, _, _, _, _} = d
  sc
def x64_un_hi(-R: Type, h: X64HiSt, k: RaVec<Bool> -> RaVec<Bool> -> R) -> R:
  X64HiSt{hu, cm} = h
  k(hu, cm)
def x64_lower_fn_o2_d(small: Bool, fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, ra: RegAllocRes, +fid: U32, name: String, +arity: U32, +nregs: U32, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, ds: X64DefSt, hs: X64HoistSt, +hist: X64HiSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match small r2s ra ds hs hist:
    case False{} X64R2Scan{r2m, u2m} RegAllocRes{rm, +vd, ce0, sc} X64DefSt{c31, is_sc, nf, stc, +harr, _} X64HoistSt{ao, _, _, _, _} _: x64_lower_fn_o2_emit(False{}, fn_map, heap_off, X64R2Scan{r2m, u2m}, fid, name, arity, nregs, blks, rm, vd, ce0, sc, c31, is_sc, nf, stc, harr, ao, X64HPick{0, False{}, 0, False{}, 0, False{}, Nil{}}, X64HMag{0, 0, 0, 0, 0, 0, 0, False{}}, X64Bor{0, RVEmpty{}}, Bool.pick(RaVec<U32>, harr, x64_uc_blks(vd, blks, RVEmpty{}), RVEmpty{}), hist, acc)
    case True{} X64R2Scan{+r2m, u2m} RegAllocRes{rm, +vd, ce0, sc} X64DefSt{+c31, is_sc, nf, +stc, +harr, hc} X64HoistSt{ao, hused, hbad, hsca, hwr} X64HiSt{_, cm}: (+uc = x64_uc_blks(vd, blks, RVEmpty{}); hp = x64_hoist_pick_all(vd, arity, Bool.pick(U32, stc, 1, 2), hused, hbad, hsca, hwr); hm = x64_run_hmag(stc, t0d, vd, arity, c31, cm, uc, blks); bor = x64_scan_bor_go(Bool.and(Bool.and(hc, Bool.and(Bool.and(Bool.not(eff), Bool.not(is_m)), Bool.and(U32.is_gt(arity, 0), Bool.and(U32.is_le(arity, 8), U32.is_zero(ra_vec_get(U32, 8n, 0, fid, r2m)))))), x64_blks_any(3, fid, blks)), vd, arity, nregs, fid, blks); x64_lower_fn_o2_emit(True{}, fn_map, heap_off, X64R2Scan{r2m, u2m}, fid, name, arity, nregs, blks, rm, vd, ce0, sc, c31, is_sc, nf, stc, harr, ao, hp, hm, bor, uc, hist, acc))
def x64_lower_fn_o2_s1(+small: Bool, fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, +ra: RegAllocRes, +fid: U32, name: String, +arity: U32, nregs: U32, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +ds: X64DefSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  RegAllocRes{_, +vd, _, _} = ra
  X64DefSt{c31, is_sc, _, _, harr, _} = ds
  x64_lower_fn_o2_d(small, fn_map, heap_off, r2s, t0d, ra, fid, name, arity, nregs, eff, is_m, blks, ds, x64_run_hoist(Bool.and(small, harr), vd, arity, fid, is_sc, blks), x64_hi_blks(vd, c31, blks, X64HiSt{RVEmpty{}, RVEmpty{}}), acc)
def x64_lower_fn_o2_go(small: Bool, fn_map: RaVec<String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, +ra: RegAllocRes, f: IrFn, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  RegAllocRes{_, +vd, _, _} = ra
  IrFn{+fid, name, +arity, nregs, _, eff, is_m, +blocks} = f
  +blks = Bool.pick(List<&2, IrBlock>, U32.is_le(arity, 64), opt_self_tc_blks(fid, arity, blocks), blocks)
  x64_lower_fn_o2_s1(small, fn_map, heap_off, r2s, t0d, ra, fid, name, arity, nregs, eff, is_m, blks, x64_def_blks(vd, arity, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}}), acc)
def x64_seg_load_regs(n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: x64_seg_load_regs(p, U32.add(idx, 1), x64_emit(XLoad{x64_arg_reg(idx), 7, U32.add(40, U32.mul(idx, 8))}, acc))
def x64_seg_call(has_extra: Bool, +arity: U32, sym: String, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_extra:
    case False{}: x64_emit(XCallSym{sym}, x64_seg_load_regs(U32.to_nat(arity), 0, acc))
    case True{}: (+extra_cnt = U32.sub(arity, 5); +odd = U32.is_eq(U32.and(extra_cnt, 1), 1); e1 = x64_push_mem_extra(U32.to_nat(extra_cnt), 7, U32.sub(arity, 1), 40, x64_emit_if(odd, XSubRsp{8}, acc)); x64_emit(XAddRsp{U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, x64_seg_load_regs(5n, 0, e1))))
def x64_make_seg_wrapper(f: IrFn) -> X64Fn:
  match f:
    case IrFn{fid, name, +arity, _, _, _, _, _}:
      a0 = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{32}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_seg_call(U32.is_gt(arity, 5), arity, x64_fn_sym(name), a0)
      a2 = x64_emit(XMovRI32{2, 1}, x64_emit(XMovRR{6, 4}, x64_emit(XLoad{7, 5, U32.sub(0, 8)}, x64_emit(XStore{4, 0, 0}, a1))))
      a3 = x64_emit_epilogue(x64_emit(XCallSym{"p111_rt_return"}, a2))
      X64Fn{x64_seg_sym(fid), True{}, b5k_list_rev(X64Inst, a3)}
def x64_make_apply_stub() -> X64Fn:
  a0 = x64_emit(XStore{5, U32.sub(0, 24), 2}, x64_emit(XStore{5, U32.sub(0, 16), 6}, x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{48}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))))
  a1 = x64_emit(XStore{5, U32.sub(0, 32), 0}, x64_emit(XAluRI{5, 0, 65535}, x64_emit(XShift{9, 0, 40, False{}}, x64_emit(XMovRR{0, 6}, a0))))
  a2 = x64_emit(XAluRI{1, 9, 1}, x64_emit(XAluRI{5, 9, 255}, x64_emit(XLoad{9, 8, 0}, x64_emit(XAluRR{0, 8, 0}, x64_emit(XLeaRip{8, "p111_fid_arity"}, a1)))))
  a3 = x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XShift{9, 1, 24, False{}}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XLoad{1, 5, U32.sub(0, 16)}, a2))))
  a4 = x64_emit(XMovRI32{1, 0}, x64_emit(XAluRI{0, 2, 40}, x64_emit(XMovRR{2, 7}, x64_emit(XAluRR{0, 8, 1}, x64_emit(XLoad{8, 7, 0}, a3)))))
  a5 = x64_emit(XJcc{3, 2}, x64_emit(XCmpRR{1, 9}, x64_emit(XLabel{1}, a4)))
  a6 = x64_emit(XLabel{2}, x64_emit(XJmp{1}, x64_emit(XAluRI{0, 1, 1}, x64_emit(XAluRI{0, 2, 8}, x64_emit(XAluRI{0, 8, 8}, x64_emit(XStore{2, 0, 0}, x64_emit(XLoad{0, 8, 0}, a5)))))))
  a7 = x64_emit(XStore{7, 16, 0}, x64_emit(XAluRI{0, 0, 8}, x64_emit(XLoad{0, 7, 16}, x64_emit(XStore{2, 0, 0}, x64_emit(XLoad{0, 5, U32.sub(0, 24)}, a6)))))
  a8 = x64_emit(XCallReg{0}, x64_emit(XLoad{7, 5, U32.sub(0, 8)}, x64_emit(XLoad{0, 8, 0}, x64_emit(XAluRR{0, 8, 0}, x64_emit(XLeaRip{8, "p111_segments"}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XLoad{0, 5, U32.sub(0, 32)}, a7)))))))
  a9 = x64_emit_epilogue(x64_emit(XLoad{0, 7, 40}, x64_emit(XLoad{7, 5, U32.sub(0, 8)}, a8)))
  X64Fn{"$b5k_apply", False{}, b5k_list_rev(X64Inst, a9)}
def x64_make_main_stub() -> X64Fn:
  a0 = x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XCallSym{"p111_rt_main"}, x64_emit(XLeaRip{2, "p111_program"}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))))
  X64Fn{"main", True{}, b5k_list_rev(X64Inst, a0)}
def x64_u32_idx(+x: U32, xs: List<&2, U32>, +idx: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: Bool.pick(U32, U32.is_eq(x, h), U32.add(idx, 1), x64_u32_idx(x, t, U32.add(idx, 1)))
type X64R2Fn is Data:
  X64R2Fn{c1: U32, pm: U32}
def x64_r2_pmask(+ar: U32, +sc: RaVec<U32>, +v: U32) -> U32: Bool.pick(U32, U32.is_eq(ra_vec_get(U32, 8n, 0, v, sc), 2), 0, Bool.pick(U32, Bool.and(U32.is_lt(v, ar), U32.is_lt(v, 31)), U32.shln(1, U32.to_nat(v)), 2147483648))
def x64_r2_ret_ops(+ar: U32, +sc: RaVec<U32>, +v: U32, ops: List<&2, IrOp>, st: X64R2Fn) -> X64R2Fn:
  match ops st:
    case Con{ICtor{d, +cid, Con{a, Con{b, Nil{}}}}, Nil{}} X64R2Fn{+cur, pm}: (+m = U32.or(pm, U32.or(x64_r2_pmask(ar, sc, a), x64_r2_pmask(ar, sc, b))); X64R2Fn{Bool.pick(U32, Bool.and(U32.is_lt(m, 2147483648), Bool.and(U32.is_eq(d, v), Bool.or(U32.is_zero(cur), U32.is_eq(cur, U32.add(cid, 1))))), U32.add(cid, 1), 4294967295), m})
    case Con{ICtor{d, +cid, Con{_, Con{_, Con{_, Nil{}}}}}, Nil{}} X64R2Fn{+cur, _}: (+enc = U32.or(65536, U32.add(cid, 1)); X64R2Fn{Bool.pick(U32, Bool.and(U32.is_eq(d, v), Bool.or(U32.is_zero(cur), U32.is_eq(cur, enc))), enc, 4294967295), 0})
    case Con{_, Nil{}} _: X64R2Fn{4294967295, 0}
    case Con{_, t} _: x64_r2_ret_ops(ar, sc, v, t, st)
    case Nil{} _: X64R2Fn{4294967295, 0}
def x64_r2_fn_scan(+ar: U32, +sc: RaVec<U32>, +fid: U32, blks: List<&2, IrBlock>, st: X64R2Fn) -> X64R2Fn:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{_, ops, TRet{v}}, t} _: x64_r2_fn_scan(ar, sc, fid, t, x64_r2_ret_ops(ar, sc, v, ops, st))
    case Con{IrBlock{_, _, TTailCall{tfid, _}}, t} X64R2Fn{cur, pm}: x64_r2_fn_scan(ar, sc, fid, t, X64R2Fn{Bool.pick(U32, U32.is_eq(tfid, fid), cur, 4294967295), pm})
    case Con{_, t} _: x64_r2_fn_scan(ar, sc, fid, t, st)
def x64_r2_args_u32(+pm: U32, +is_self: Bool, +sc: RaVec<U32>, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+a, t}: Bool.and(Bool.or(U32.is_zero(U32.and(pm, U32.shln(1, U32.to_nat(idx)))), Bool.or(U32.is_eq(ra_vec_get(U32, 8n, 0, a, sc), 2), Bool.and(is_self, U32.is_eq(a, idx)))), x64_r2_args_u32(pm, is_self, sc, t, U32.add(idx, 1)))
def x64_z0_op(+ar: U32, op: IrOp, +z0: RaVec<U32>) -> RaVec<U32>:
  match op:
    case ICtor{d, cid, Nil{}}: x64_mc(8n, ar, d, cid, z0)
    case o: ra_vec_set_all(U32, 8n, 4294967295, opt_op_dsts(o), z0)
def x64_z0_blks(+ar: U32, blks: List<&2, IrBlock>, z0: RaVec<U32>) -> RaVec<U32>: opt_foldl(~IrBlock, ~U32, ~RaVec<U32>, ~(a => b => z => opt_un_blk(RaVec<U32>, b, _ => ops1 => _ => opt_foldl(~IrOp, ~U32, ~RaVec<U32>, ~(a1 => op => z1 => x64_z0_op(a1, op, z1)), a, ops1, z))), ar, blks, z0)
def x64_u2p_last_call(+fid: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Con{ICallDirect{dst, cfid, _}, Nil{}}: Bool.pick(U32, U32.is_eq(cfid, fid), U32.add(dst, 1), 0)
    case Con{_, t}: x64_u2p_last_call(fid, t)
    case Nil{}: 0
def x64_u2p_find(+fid: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{_, ops, TTailCall{tfid, targs}}, t}: (+d1 = Bool.pick(U32, U32.is_eq(tfid, fid), x64_u2p_last_call(fid, ops), 0); +p1 = Bool.pick(U32, U32.is_ne(d1, 0), x64_u32_idx(U32.sub(d1, 1), targs, 0), 0); Bool.pick(U32, U32.is_ne(p1, 0), p1, x64_u2p_find(fid, t)))
    case Con{_, t}: x64_u2p_find(fid, t)
def x64_u2p_walk(+fid: U32, +cid: U32, +p: U32, +uc: RaVec<U32>, +z0: RaVec<U32>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>) -> Bool:
  match blks ops:
    case Nil{} Nil{}: True{}
    case Con{IrBlock{_, +ops1, TTailCall{_, +targs}}, t} Nil{}: (+v = x64_u32_nth(targs, U32.to_nat(p)); +e = ra_vec_get(U32, 8n, 0, v, z0); tok = Bool.and(Bool.not(x64_u32_in(p, targs)), Bool.or(Bool.and(x64_is_cval(e), U32.is_ne(U32.sub(e, 1), cid)), Bool.and(U32.is_eq(x64_u2p_last_call(fid, ops1), U32.add(v, 1)), U32.is_eq(ra_vec_get(U32, 8n, 0, v, uc), 1)))); Bool.and(tok, x64_u2p_walk(fid, cid, p, uc, z0, t, ops1)))
    case Con{IrBlock{_, ops1, term}, t} Nil{}: Bool.and(U32.is_zero(ra_vec_get(U32, 8n, 0, p, x64_uc_term(8n, term, RVEmpty{}))), x64_u2p_walk(fid, cid, p, uc, z0, t, ops1))
    case _ Con{ITag{d, _}, ot}: Bool.and(U32.is_ne(d, p), x64_u2p_walk(fid, cid, p, uc, z0, blks, ot))
    case _ Con{ITake{Con{d0, Con{d1, Nil{}}}, _}, ot}: Bool.and(Bool.and(U32.is_ne(d0, p), U32.is_ne(d1, p)), x64_u2p_walk(fid, cid, p, uc, z0, blks, ot))
    case _ Con{ISink{_}, ot}: x64_u2p_walk(fid, cid, p, uc, z0, blks, ot)
    case _ Con{ITake{+ds, s}, ot}: Bool.and(Bool.and(Bool.not(x64_u32_in(p, ds)), U32.is_ne(s, p)), x64_u2p_walk(fid, cid, p, uc, z0, blks, ot))
    case _ Con{IArrOp{+ds, _, +args}, ot}: Bool.and(Bool.and(Bool.not(x64_u32_in(p, ds)), Bool.not(x64_u32_in(p, args))), x64_u2p_walk(fid, cid, p, uc, z0, blks, ot))
    case _ Con{+op, ot}: Bool.and(Bool.and(U32.is_ne(opt_op_dst1(op), U32.add(p, 1)), U32.is_zero(ra_vec_get(U32, 8n, 0, p, x64_uc_op(8n, op, RVEmpty{})))), x64_u2p_walk(fid, cid, p, uc, z0, blks, ot))
type X64R2P1 is Data:
  X64R2P1{cand: RaVec<U32>, u2p: RaVec<U32>, pms: RaVec<U32>}
def x64_r2_p1_fin(+fid: U32, +ar: U32, +blks: List<&2, IrBlock>, +cand: RaVec<U32>, +u2p: RaVec<U32>, +pms: RaVec<U32>, r2f: X64R2Fn) -> X64R2P1:
  X64R2Fn{+c1, pm} = r2f
  +good = x64_is_cval(c1)
  +p1 = Bool.pick(U32, Bool.and(good, Bool.and(U32.is_lt(c1, 65536), U32.is_le(ar, 32))), x64_u2p_find(fid, blks), 0)
  +u2v = low_if(U32, U32.is_ne(p1, 0), _ => Bool.pick(U32, x64_u2p_walk(fid, U32.sub(c1, 1), U32.sub(p1, 1), x64_uc_blks(8n, blks, RVEmpty{}), x64_z0_blks(ar, blks, RVEmpty{}), blks, Nil{}), p1, 0), _ => 0)
  X64R2P1{ra_vec_set_if(U32, 8n, good, fid, c1, cand), ra_vec_set_if(U32, 8n, U32.is_ne(u2v, 0), fid, u2v, u2p), ra_vec_set_if(U32, 8n, good, fid, pm, pms)}
def x64_r2_p1(fns: List<&2, IrFn>, st: X64R2P1) -> X64R2P1:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, +ar, _, esc, eff, is_m, +blks}, t} X64R2P1{+cand, +u2p, +pms}: (sc = x64_def_sc(x64_def_blks(8n, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})); x64_r2_p1(t, x64_r2_p1_fin(fid, ar, blks, cand, u2p, pms, low_if(X64R2Fn, Bool.and(Bool.and(Bool.not(esc), Bool.not(eff)), Bool.not(is_m)), _ => x64_r2_fn_scan(ar, sc, fid, blks, X64R2Fn{0, 0}), _ => X64R2Fn{0, 0}))))
type X64R2P2 is Data:
  X64R2P2{u2p: RaVec<U32>, ben: RaVec<Bool>, clo: RaVec<Bool>}
def x64_r2_is_tk(+c1: U32, +dst: U32, uc: RaVec<U32>, t: List<&2, IrOp>) -> Bool:
  match t:
    case Con{ITake{Con{d0, Con{d1, Nil{}}}, tsrc}, _}: Bool.and(Bool.and(Bool.and(U32.is_ne(c1, 0), U32.is_lt(c1, 65536)), U32.is_eq(dst, tsrc)), Bool.and(U32.is_ne(d0, d1), U32.is_eq(ra_vec_get(U32, 8n, 0, dst, uc), 1)))
    case Con{ITake{Con{+d0, Con{+d1, Con{+d2, Nil{}}}}, tsrc}, _}: Bool.and(Bool.and(U32.is_ge(c1, 65536), U32.is_eq(dst, tsrc)), Bool.and(Bool.and(U32.is_ne(d0, d1), Bool.and(U32.is_ne(d0, d2), U32.is_ne(d1, d2))), U32.is_eq(ra_vec_get(U32, 8n, 0, dst, uc), 1)))
    case _: False{}
def x64_r2_p2_walk(+cur_fid: U32, +cand: RaVec<U32>, +pms: RaVec<U32>, +sc: RaVec<U32>, +uc: RaVec<U32>, +z0: RaVec<U32>, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, st: X64R2P2) -> X64R2P2:
  match blks ops st:
    case Nil{} Nil{} _: st
    case Con{IrBlock{_, ops1, TTailCall{+tfid, args}}, t} Nil{} X64R2P2{u2p, ben, +clo}: (+pm = ra_vec_get(U32, 8n, 0, tfid, pms); +bad = Bool.or(U32.is_ne(tfid, cur_fid), Bool.and(U32.is_ne(pm, 0), Bool.not(x64_r2_args_u32(pm, True{}, sc, args, 0)))); x64_r2_p2_walk(cur_fid, cand, pms, sc, uc, z0, t, ops1, X64R2P2{u2p, ben, ra_vec_set_if(Bool, 8n, bad, tfid, True{}, clo)}))
    case Con{IrBlock{_, ops1, _}, t} Nil{} _: x64_r2_p2_walk(cur_fid, cand, pms, sc, uc, z0, t, ops1, st)
    case _ Con{ICallClosure{_, cfid, _}, ot} X64R2P2{u2p, ben, clo}: x64_r2_p2_walk(cur_fid, cand, pms, sc, uc, z0, blks, ot, X64R2P2{u2p, ben, ra_vec_set(Bool, 8n, cfid, True{}, clo)})
    case _ Con{ICallDirect{+dst, +cfid, +args}, +ot} X64R2P2{+u2p, +ben, +clo}: (+c1 = ra_vec_get(U32, 8n, 0, cfid, cand); +p1 = ra_vec_get(U32, 8n, 0, cfid, u2p); +pm = ra_vec_get(U32, 8n, 0, cfid, pms); +e = ra_vec_get(U32, 8n, 0, x64_u32_nth(args, U32.to_nat(U32.sub(p1, 1))), z0); x64_r2_p2_walk(cur_fid, cand, pms, sc, uc, z0, blks, ot, X64R2P2{ra_vec_set_if(U32, 8n, Bool.and(U32.is_ne(p1, 0), Bool.not(Bool.and(x64_is_cval(e), U32.is_ne(U32.sub(e, 1), U32.sub(c1, 1))))), cfid, 0, u2p), ra_vec_set_if(Bool, 8n, x64_r2_is_tk(c1, dst, uc, ot), cfid, True{}, ben), ra_vec_set_if(Bool, 8n, Bool.and(U32.is_ne(pm, 0), Bool.not(x64_r2_args_u32(pm, U32.is_eq(cfid, cur_fid), sc, args, 0))), cfid, True{}, clo)}))
    case _ Con{_, ot} _: x64_r2_p2_walk(cur_fid, cand, pms, sc, uc, z0, blks, ot, st)
def x64_r2_p2(+cand: RaVec<U32>, +pms: RaVec<U32>, fns: List<&2, IrFn>, st: X64R2P2) -> X64R2P2: opt_foldl2(~IrFn, ~RaVec<U32>, ~RaVec<U32>, ~X64R2P2, ~(ca => pm => f => s => opt_un_fn(X64R2P2, f, fid => _ => ar => _ => _ => _ => _ => blks => (+fi = fid; +a = ar; +bl = blks; x64_r2_p2_walk(fi, ca, pm, x64_def_sc(x64_def_blks(8n, a, fi, bl, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})), x64_uc_blks(8n, bl, RVEmpty{}), x64_z0_blks(a, bl, RVEmpty{}), bl, Nil{}, s)))), cand, pms, fns, st)
def x64_r2_fin(+cand: RaVec<U32>, +u2p: RaVec<U32>, +ben: RaVec<Bool>, +clo: RaVec<Bool>, fns: List<&2, IrFn>, st: X64R2Scan) -> X64R2Scan:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, _, _, _, _, _, _}, t} X64R2Scan{+out, +u2o}: (+c1 = ra_vec_get(U32, 8n, 0, fid, cand); +p1 = ra_vec_get(U32, 8n, 0, fid, u2p); +ok = Bool.and(Bool.and(U32.is_ne(c1, 0), Bool.not(ra_vec_get(Bool, 8n, False{}, fid, clo))), Bool.or(ra_vec_get(Bool, 8n, False{}, fid, ben), U32.is_ne(p1, 0))); x64_r2_fin(cand, u2p, ben, clo, t, X64R2Scan{Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, 8n, fid, c1, out), out), Bool.pick(RaVec<U32>, Bool.and(ok, U32.is_ne(p1, 0)), ra_vec_set(U32, 8n, fid, p1, u2o), u2o)}))
def x64_scan_ret2_p2(cand: RaVec<U32>, fns: List<&2, IrFn>, p2: X64R2P2) -> X64R2Scan:
  X64R2P2{u2p1, ben, clo} = p2
  x64_r2_fin(cand, u2p1, ben, clo, fns, X64R2Scan{RVEmpty{}, RVEmpty{}})
def x64_scan_ret2_p1(+fns: List<&2, IrFn>, p1: X64R2P1) -> X64R2Scan:
  X64R2P1{+cand, u2p0, pms} = p1
  x64_scan_ret2_p2(cand, fns, x64_r2_p2(cand, pms, fns, X64R2P2{u2p0, RVEmpty{}, RVEmpty{}}))
def x64_scan_ret2(is_o2: Bool, +fns: List<&2, IrFn>) -> X64R2Scan:
  match is_o2:
    case False{}: X64R2Scan{RVEmpty{}, RVEmpty{}}
    case True{}: x64_scan_ret2_p1(fns, x64_r2_p1(fns, X64R2P1{RVEmpty{}, RVEmpty{}, RVEmpty{}}))
def x64_rot_find_sub_ops(+vd: Nat, +c31: RaVec<U32>, +p: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{+p2, +bop, a, k1}, ot}: Bool.pick(U32, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), Bool.and(Bool.and(U32.is_eq(a, p), U32.is_ne(p2, p)), U32.is_eq(ra_vec_get(U32, vd, 0, k1, c31), 2))), U32.add(p2, 1), x64_rot_find_sub_ops(vd, c31, p, ot))
    case Con{_, ot}: x64_rot_find_sub_ops(vd, c31, p, ot)
def x64_rot_find_sub(+vd: Nat, +c31: RaVec<U32>, +p: U32, +bid: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{id, ops1, _}, t}: Bool.pick(U32, U32.is_eq(id, bid), x64_rot_find_sub_ops(vd, c31, p, ops1), x64_rot_find_sub(vd, c31, p, bid, t))
type X64RotChk is Data:
  X64RotChk{ok: Bool, dp2: U32, ntc: U32}
def x64_rot_chk_walk(+fid: U32, +ar: U32, +p: U32, +p2: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, st: X64RotChk) -> X64RotChk:
  match blks ops st:
    case Nil{} Nil{} _: st
    case Con{IrBlock{_, ops1, TTailCall{tfid, +args}}, t} Nil{} X64RotChk{ok, dp2, ntc}: (+is_s = Bool.and(U32.is_eq(tfid, fid), U32.is_eq(b5k_u32_list_len(args), ar)); ok2 = Bool.and(ok, Bool.or(Bool.not(is_s), U32.is_eq(x64_u32_nth(args, U32.to_nat(p)), p2))); x64_rot_chk_walk(fid, ar, p, p2, t, ops1, X64RotChk{ok2, dp2, U32.add(ntc, Bool.to_u32(is_s))}))
    case Con{IrBlock{_, ops1, _}, t} Nil{} _: x64_rot_chk_walk(fid, ar, p, p2, t, ops1, st)
    case _ Con{+op, ot} X64RotChk{ok, dp2, ntc}: x64_rot_chk_walk(fid, ar, p, p2, blks, ot, X64RotChk{Bool.and(ok, Bool.not(x64_op_redefs(p, op))), U32.add(dp2, Bool.to_u32(x64_op_redefs(p2, op))), ntc})
def x64_rot_rw_args(+p: U32, args: List<&2, U32>, +idx: U32) -> List<&2, U32>:
  match args:
    case Nil{}: Nil{}
    case Con{a, t}: Con{Bool.pick(U32, U32.is_eq(idx, p), p, a), x64_rot_rw_args(p, t, U32.add(idx, 1))}
def x64_rot_strip_ops(+p2: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{IBin{+d, +bop, a, k1}, +t}: Bool.pick(List<&2, IrOp>, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), U32.is_eq(d, p2)), t, Con{IBin{d, bop, a, k1}, x64_rot_strip_ops(p2, t)})
    case Con{op, t}: Con{op, x64_rot_strip_ops(p2, t)}
def x64_rot_rw_blks(+fid: U32, +bid: U32, +p: U32, +p2: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, TTailCall{+tfid, +args}}, t}: Con{IrBlock{id, Bool.pick(List<&2, IrOp>, U32.is_eq(id, bid), x64_rot_strip_ops(p2, ops), ops), TTailCall{tfid, Bool.pick(List<&2, U32>, U32.is_eq(tfid, fid), x64_rot_rw_args(p, args, 0), args)}}, x64_rot_rw_blks(fid, bid, p, p2, t)}
    case Con{IrBlock{+id, +ops, term}, t}: Con{IrBlock{id, Bool.pick(List<&2, IrOp>, U32.is_eq(id, bid), x64_rot_strip_ops(p2, ops), ops), term}, x64_rot_rw_blks(fid, bid, p, p2, t)}
type X64RotFn is Data:
  X64RotFn{fn: IrFn, t0d: Bool}
def x64_rot_fin(+fid: U32, name: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, vd: Nat, uc: RaVec<U32>, tb: U32, p: U32, +p2: U32, rc: X64RotChk) -> X64RotFn:
  X64RotChk{cok, dp2, +ntc} = rc
  +good = Bool.and(Bool.and(cok, U32.is_eq(dp2, 1)), Bool.and(U32.is_gt(ntc, 0), U32.is_eq(ra_vec_get(U32, vd, 0, p2, uc), ntc)))
  X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, Bool.pick(List<&2, IrBlock>, good, x64_rot_rw_blks(fid, tb, p, p2, blks), blks)}, good}
def x64_rot_t0(+fid: U32, +name: String, +ar: U32, +nregs: U32, +esc: Bool, +eff: Bool, +is_m: Bool, +blks: List<&2, IrBlock>, +vd: Nat, +c31: RaVec<U32>, +uc: RaVec<U32>, t0: X64T0) -> X64RotFn:
  X64T0{+c, +tb, _} = t0
  +p = U32.sub(c, 1)
  +ok = Bool.and(Bool.and(U32.is_ne(c, 0), U32.is_lt(tb, 1024)), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, p, uc), 2), U32.is_eq(ra_vec_get(U32, 5n, 0, tb, x64_blk_preds(blks)), 1)))
  +p2_1 = Bool.pick(U32, ok, x64_rot_find_sub(vd, c31, p, tb, blks), 0)
  low_if(X64RotFn, U32.is_zero(p2_1), _ => X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{}}, _ => (+p2 = U32.sub(p2_1, 1); x64_rot_fin(fid, name, ar, nregs, esc, eff, is_m, blks, vd, uc, tb, p, p2, x64_rot_chk_walk(fid, ar, p, p2, blks, Nil{}, X64RotChk{True{}, 0, 0}))))
def x64_rot_def(+fid: U32, +name: String, +ar: U32, +nregs: U32, +esc: Bool, +eff: Bool, +is_m: Bool, +blks: List<&2, IrBlock>, +vd: Nat, ds: X64DefSt) -> X64RotFn:
  X64DefSt{+c31, _, _, stc, _, _} = ds
  low_if(X64RotFn, Bool.and(stc, U32.is_le(ar, 64)), _ => (+uc = x64_uc_blks(vd, blks, RVEmpty{}); x64_rot_t0(fid, name, ar, nregs, esc, eff, is_m, blks, vd, c31, uc, x64_un_hi(X64T0, x64_hi_blks(vd, c31, blks, X64HiSt{RVEmpty{}, RVEmpty{}}), _ => cm => x64_b0_t0(vd, ar, c31, cm, uc, blks)))), _ => X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{}})
def x64_rot_countdown(f: IrFn) -> X64RotFn:
  IrFn{+fid, name, +ar, +nregs, esc, eff, is_m, +blocks0} = f
  +blks = Bool.pick(List<&2, IrBlock>, U32.is_le(ar, 64), opt_self_tc_blks(fid, ar, blocks0), blocks0)
  +vd = ra_vd_of(U32.max(nregs, ar))
  x64_rot_def(fid, name, ar, nregs, esc, eff, is_m, blks, vd, x64_def_blks(vd, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}}))
# L13-SIMD + L14-SIMD-2: Unified 8-Wide AVX1 Loop & Reduction Vectorizer
type V4Hdr is Data:
  V4Hdr{ok: Bool, vd: Nat, c31: RaVec<U32>, blks: List<&2, IrBlock>, sid: U32, sops: List<&2, IrOp>, pdec: U32, tf: List<&2, U32>}
type V4Cal is Data:
  V4Cal{ok: Bool, fid: U32, name: String, arity: U32, nregs: U32, ops: List<&2, IrOp>, targs: List<&2, U32>}
type V8Blk is Data:
  V8Blk{ok: Bool, ops: List<&2, IrOp>, term: IrTerm}
def v8r_get_blk(+bid: U32, blks: List<&2, IrBlock>) -> V8Blk: opt_fold_blks(~U32, ~V8Blk, ~(b0 => id => ops => tm => acc => Bool.pick(V8Blk, U32.is_eq(id, b0), V8Blk{True{}, ops, tm}, acc)), bid, blks, V8Blk{False{}, Nil{}, TFail{0}})
def v4_hdr_blk(b: V8Blk, vd: Nat, c31: RaVec<U32>, blks: List<&2, IrBlock>, sid: U32, fid: U32, ar: U32) -> V4Hdr:
  match b:
    case V8Blk{True{}, sops, TTailCall{tfid, Con{pdec, +tf}}}: V4Hdr{Bool.and(U32.is_eq(tfid, fid), U32.is_eq(b5k_u32_list_len(tf), U32.sub(ar, 1))), vd, c31, blks, sid, sops, pdec, tf}
    case _: V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}}
def v4_un_hdr(-R: Type, h: V4Hdr, k: Bool -> Nat -> RaVec<U32> -> List<&2, IrBlock> -> U32 -> List<&2, IrOp> -> U32 -> List<&2, U32> -> R) -> R:
  V4Hdr{ok, vd, c31, blks, sid, sops, pdec, tf} = h
  k(ok, vd, c31, blks, sid, sops, pdec, tf)
def v4_un_ra(-R: Type, ra: RegAllocRes, k: RaVec<U32> -> Nat -> U32 -> R) -> R:
  RegAllocRes{rm, vd, _, sc} = ra
  k(rm, vd, sc)
def v4_loop_hdr_d(+fid: U32, +ar: U32, +blks: List<&2, IrBlock>, +vd: Nat, ds: X64DefSt) -> V4Hdr:
  X64DefSt{+c31, _, _, stc, _, _} = ds
  low_if(V4Hdr, stc, _ => x64_un_hi(V4Hdr, x64_hi_blks(vd, c31, blks, X64HiSt{RVEmpty{}, RVEmpty{}}), _ => cm => x64_un_t0(V4Hdr, x64_b0_t0(vd, ar, c31, cm, x64_uc_blks(vd, blks, RVEmpty{}), blks), c => tb_ => _ => ( +tb = tb_; low_if(V4Hdr, U32.is_eq(c, 1), _ => v4_hdr_blk(v8r_get_blk(tb, blks), vd, c31, blks, tb, fid, ar), _ => V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}})))), _ => V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}})
def v4_loop_hdr(f: IrFn) -> V4Hdr:
  match f:
    case IrFn{+fid, _, +ar, +nregs, _, False{}, False{}, +blks0}: low_if(V4Hdr, Bool.and(U32.is_ge(ar, 2), U32.is_le(ar, 32)), _ => +blks = Bool.pick(List<&2, IrBlock>, U32.is_le(ar, 64), opt_self_tc_blks(fid, ar, blks0), blks0); +vd = ra_vd_of(U32.max(nregs, ar)); v4_loop_hdr_d(fid, ar, blks, vd, x64_def_blks(vd, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})), _ => V4Hdr{False{}, 0n, RVEmpty{}, blks0, 0, Nil{}, 0, Nil{}})
    case IrFn{_, _, _, _, _, _, _, blks0}: V4Hdr{False{}, 0n, RVEmpty{}, blks0, 0, Nil{}, 0, Nil{}}
def v4_chk_step(+vd: Nat, +c31: RaVec<U32>, +pdec: U32, ops: List<&2, IrOp>, +nf: U32, +acc: List<&2, IrOp>) -> Bool & List<&2, IrOp>:
  match ops:
    case Nil{}: (U32.is_ge(nf, 4), b5k_list_rev(IrOp, acc))
    case Con{IConst{_, 1}, t}: v4_chk_step(vd, c31, pdec, t, nf, acc)
    case Con{IFlt{d, bits}, t}: v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IFlt{d, bits}, acc})
    case Con{ICopy{d, +s}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.or(U32.is_zero(s), U32.is_eq(s, pdec)), (False{}, Nil{}), v4_chk_step(vd, c31, pdec, t, nf, Con{ICopy{d, s}, acc}))
    case Con{IBin{+d, +bop, 0, r}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), Bool.and(U32.is_eq(d, pdec), U32.is_eq(ra_vec_get(U32, vd, 0, r, c31), 2))), v4_chk_step(vd, c31, pdec, t, nf, acc), (False{}, Nil{}))
    case Con{IBin{d, +bop, +l, +r}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), Bool.and(Bool.and(U32.is_ne(l, 0), U32.is_ne(r, 0)), Bool.and(U32.is_ne(l, pdec), U32.is_ne(r, pdec)))), v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IBin{d, bop, l, r}, acc}), (False{}, Nil{}))
    case Con{IUn{d, +uop, +s}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(Bool.or(U32.is_eq(uop, 2), U32.is_eq(uop, 3)), Bool.and(U32.is_ne(s, 0), U32.is_ne(s, pdec))), v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IUn{d, uop, s}, acc}), (False{}, Nil{}))
    case _: (False{}, Nil{})
def v4_match_fn(f: IrFn) -> V4Cal:
  IrFn{+fid, +name, +ar, +nregs, esc, eff, is_m, blks} = f
  v4_un_hdr(V4Cal, v4_loop_hdr(IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}), ok => vd => c31 => _ => _ => sops => pdec_ => tf_ => ( +pdec = pdec_; +tf = tf_; low_if(V4Cal, ok, _ => ra_un_pair(Bool, List<&2, IrOp>, V4Cal, v4_chk_step(vd, c31, pdec, sops, 0, Nil{}), ok1 => cops => V4Cal{Bool.and(Bool.and(Bool.not(x64_u32_in(0, tf)), Bool.not(x64_u32_in(pdec, tf))), ok1), fid, name, ar, nregs, cops, tf}), _ => V4Cal{False{}, 0, "", 0, 0, Nil{}, Nil{}})))
def v4_disp(loc: U32) -> U32: U32.add(32, U32.mul(U32.sub(loc, 100), 32))
def v4_vex_op(vv: U32, bo: U32) -> U32: U32.add(256, U32.or(U32.shln(U32.and(vv, 15), 4n), bo))
def v4_reg(+loc: U32, +sp_r: U32) -> U32: Bool.pick(U32, U32.is_ge(loc, 100), sp_r, U32.sub(loc, 20))
def v4_ld_sp(+loc: U32, xmm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit_if(U32.is_ge(loc, 100), XXmmLoad{U32.add(32, xmm), 4, v4_disp(loc)}, acc)
def v4_st_dst(+dl: U32, +dx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: x64_emit_if(U32.is_ge(dl, 100), XXmmStore{4, v4_disp(dl), U32.add(48, dx)}, acc)
def v4_xmm_io(is_ld: Bool, is_sp: Bool, +xmm: U32, +loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp:
    case True{} True{}: x64_emit(XXmmLoad{U32.add(32, xmm), 4, v4_disp(loc)}, acc)
    case False{} True{}: x64_emit(XXmmStore{4, v4_disp(loc), U32.add(48, xmm)}, acc)
    case True{} False{}: x64_emit_if(U32.is_ne(U32.sub(loc, 20), xmm), XXmmRR{263, xmm, U32.sub(loc, 20)}, acc)
    case False{} False{}: x64_emit_if(U32.is_ne(U32.sub(loc, 20), xmm), XXmmRR{263, U32.sub(loc, 20), xmm}, acc)
def v4_mem_io(is_ld: Bool, is_sp: Bool, +lb: U32, +base: U32, +loc: U32, +off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp:
    case True{} True{}: x64_emit(XXmmStore{4, v4_disp(loc), 48}, x64_emit(XXmmLoad{lb, base, off}, acc))
    case True{} False{}: x64_emit(XXmmLoad{U32.add(lb, U32.sub(loc, 20)), base, off}, acc)
    case False{} True{}: x64_emit(XXmmStore{base, off, 48}, x64_emit(XXmmLoad{32, 4, v4_disp(loc)}, acc))
    case False{} False{}: x64_emit(XXmmStore{base, off, U32.add(48, U32.sub(loc, 20))}, acc)
def v4_io_params(+is_ld: Bool, +rm: RaVec<U32>, +vd: Nat, n: Nat, +k: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: (+loc = ra_vec_get(U32, vd, 0, k, rm); v4_io_params(is_ld, rm, vd, p, U32.add(k, 1), Bool.pick(List<&2, X64Inst>, U32.is_zero(loc), acc, v4_mem_io(is_ld, U32.is_ge(loc, 100), 32, 2, loc, U32.mul(U32.sub(k, 1), 32), acc))))
def v4_dst(rm: RaVec<U32>, vd: Nat, d: U32, f: U32 -> List<&2, X64Inst>) -> List<&2, X64Inst>: (+dl = ra_vec_get(U32, vd, 0, d, rm); +dx = v4_reg(dl, 0); v4_st_dst(dl, dx, f(dx)))
def v4_emit_op(+rm: RaVec<U32>, +vd: Nat, op: IrOp, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case IFlt{d, +bits}: v4_dst(rm, vd, d, dx => +x = dx; x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_zero(bits), acc, a => x64_emit(XXmmRR{v4_vex_op(x, 6), x, x}, a), a => x64_emit(XXmmLoad{U32.add(48, x), 0, 0}, x64_emit(XExtReloc{1, "", bits}, x64_emit(XExtReloc{2, "", 0}, a)))))
    case ICopy{d, s}: (+sl = ra_vec_get(U32, vd, 0, s, rm); v4_dst(rm, vd, d, dx => v4_xmm_io(True{}, U32.is_ge(sl, 100), dx, sl, acc)))
    case IBin{d, +bop, l, r}: (+ll = ra_vec_get(U32, vd, 0, l, rm); +rl = ra_vec_get(U32, vd, 0, r, rm); v4_dst(rm, vd, d, dx => x64_emit(XXmmRR{v4_vex_op(v4_reg(ll, 0), U32.sub(bop, 10)), dx, v4_reg(rl, 1)}, v4_ld_sp(rl, 1, v4_ld_sp(ll, 0, acc)))))
    case IUn{d, 3, s}: (+sl = ra_vec_get(U32, vd, 0, s, rm); v4_dst(rm, vd, d, dx => +x = dx; x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, U32.is_ge(sl, 100), acc, a => x64_emit(XXmmRR{260, x, x}, x64_emit(XXmmLoad{U32.add(32, x), 4, v4_disp(sl)}, a)), a => x64_emit(XXmmRR{260, x, U32.sub(sl, 20)}, a))))
    case IUn{d, 40, s}: (+sl = ra_vec_get(U32, vd, 0, s, rm); v4_dst(rm, vd, d, dx => +x = dx; x64_emit(XXmmRR{260, x, x}, x64_emit(XXmmRR{v4_vex_op(v4_reg(sl, 0), 5), x, 1}, x64_emit(XXmmRR{v4_vex_op(1, 6), 1, 1}, v4_ld_sp(sl, 0, acc))))))
    case IUn{d, 2, s}: (+sl = ra_vec_get(U32, vd, 0, s, rm); v4_dst(rm, vd, d, dx => x64_emit(XXmmRR{v4_vex_op(v4_reg(sl, 0), 6), dx, 1}, x64_emit(XXmmLoad{49, 0, 0}, x64_emit(XExtReloc{1, "", 2147483648}, x64_emit(XExtReloc{2, "", 0}, v4_ld_sp(sl, 0, acc)))))))
    case _: acc
def v4_emit_ops(+rm: RaVec<U32>, +vd: Nat, ops: List<&2, IrOp>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl2(~IrOp, ~RaVec<U32>, ~Nat, ~List<&2, X64Inst>, ~(r => v => op => a => v4_emit_op(r, v, op, a)), rm, vd, ops, acc)
def v4_loc_src(+rm: RaVec<U32>, +vd: Nat, +loc: U32, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{r, t}: (+rl = ra_vec_get(U32, vd, 0, r, rm); Bool.or(Bool.and(U32.is_ne(rl, ra_vec_get(U32, vd, 0, idx, rm)), U32.is_eq(rl, loc)), v4_loc_src(rm, vd, loc, t, U32.add(idx, 1))))
def v4_no_cycle(+rm: RaVec<U32>, +vd: Nat, +all: List<&2, U32>, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{r, t}: (+il = ra_vec_get(U32, vd, 0, idx, rm); Bool.and(Bool.or(U32.is_eq(ra_vec_get(U32, vd, 0, r, rm), il), Bool.not(v4_loc_src(rm, vd, il, all, 1))), v4_no_cycle(rm, vd, all, t, U32.add(idx, 1))))
def v4_tail_dir(+rm: RaVec<U32>, +vd: Nat, args: List<&2, U32>, +idx: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{r, t}: (+rl = ra_vec_get(U32, vd, 0, r, rm); +il = ra_vec_get(U32, vd, 0, idx, rm); +dx = v4_reg(il, 0); v4_tail_dir(rm, vd, t, U32.add(idx, 1), Bool.pick(List<&2, X64Inst>, U32.is_eq(rl, il), acc, v4_st_dst(il, dx, v4_xmm_io(True{}, U32.is_ge(rl, 100), dx, rl, acc)))))
def v4_tail_mv(+rm: RaVec<U32>, +vd: Nat, +sbase: U32, +is_ld: Bool, args: List<&2, U32>, +idx: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{r, t}: (+rl = ra_vec_get(U32, vd, 0, r, rm); +il = ra_vec_get(U32, vd, 0, idx, rm); +loc = Bool.pick(U32, is_ld, il, rl); v4_tail_mv(rm, vd, sbase, is_ld, t, U32.add(idx, 1), Bool.pick(List<&2, X64Inst>, U32.is_eq(rl, il), acc, v4_mem_io(is_ld, U32.is_ge(loc, 100), 32, 4, loc, U32.add(sbase, U32.mul(idx, 32)), acc))))
def v4_avx_fn(sym: String, frame: U32, body: List<&2, X64Inst> -> List<&2, X64Inst>) -> X64Fn:
  a0 = x64_emit(XAluRI{5, 4, 4294967264}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
  X64Fn{sym, False{}, b5k_list_rev(X64Inst, x64_emit_epilogue(body(a0)))}
def x64_emit_v4_fn(cal: V4Cal) -> X64Fn:
  V4Cal{_, +fid, +name, +ar, nregs, +ops, +tf} = cal
  v4_un_ra(X64Fn, b5k_regalloc_v4(IrFn{fid, name, ar, nregs, False{}, False{}, False{}, Con{IrBlock{0, ops, TTailCall{fid, Con{0, tf}}}, Nil{}}}), rm_ => vd_ => sc_ => ( +rm = rm_; +vd = vd_; +sc = sc_; +nc = v4_no_cycle(rm, vd, tf, tf, 1); +sbase = U32.add(32, U32.mul(sc, 32)); +frame = x64_align16(U32.add(U32.add(sbase, 32), Bool.pick(U32, nc, 0, U32.mul(ar, 32)))); +np = U32.to_nat(U32.sub(ar, 1)); v4_avx_fn(String.append("$v8.", name), frame, a0 => a2 = v4_emit_ops(rm, vd, ops, x64_emit(XLabel{1}, v4_io_params(True{}, rm, vd, np, 1, x64_emit(XJcc{4, 2}, x64_emit(XTestRR{6, 6}, a0))))); a4 = x64_if1(List<&2, X64Inst>, List<&2, X64Inst>, nc, a2, a => v4_tail_dir(rm, vd, tf, 1, a), a => v4_tail_mv(rm, vd, sbase, True{}, tf, 1, v4_tail_mv(rm, vd, sbase, False{}, tf, 1, a))); x64_emit(XXmmRR{14, 0, 0}, x64_emit(XLabel{2}, v4_io_params(False{}, rm, vd, np, 1, x64_emit(XJcc{5, 1}, x64_emit(XAluRI{1, 6, 1}, a4))))))))
type V4Scan is Data:
  V4Scan{vmap: RaVec<U32>, fn_map: RaVec<String>, acc: List<&2, X64Fn>}
def v4_scan_one(cal: V4Cal, st: V4Scan) -> V4Scan:
  match cal st:
    case V4Cal{True{}, +fid, +name, +ar, nregs, ops, tf} V4Scan{vm, fm, acc}: V4Scan{ra_vec_set(U32, 8n, fid, ar, vm), ra_vec_set(String, 9n, U32.add(65536, fid), String.append("$v8.", name), fm), Con{x64_emit_v4_fn(V4Cal{True{}, fid, name, ar, nregs, ops, tf}), acc}}
    case _ _: st
def v4_inv_mask(targs: List<&2, U32>, +idx: U32, +m: U32) -> U32:
  match targs:
    case Nil{}: m
    case Con{a, t}: v4_inv_mask(t, U32.add(idx, 1), Bool.pick(U32, U32.is_eq(a, idx), U32.or(m, U32.shln(1, U32.to_nat(idx))), m))
def v4_v_ok(+ar: U32, +im: U32, +vd: Nat, +dm: RaVec<Bool>, +v: U32) -> Bool: Bool.pick(Bool, U32.is_lt(v, ar), Bool.or(U32.is_zero(v), U32.is_ne(U32.and(im, U32.shln(1, U32.to_nat(v))), 0)), ra_vec_get(Bool, vd, False{}, v, dm))
type V4Split is Data:
  V4Split{ok: Bool, setup: List<&2, IrOp>, w: U32, cfid: U32, cnt: U32, fargs: List<&2, U32>, post: List<&2, IrOp>, defs: List<&2, U32>}
def v4_split_ops(+vmap: RaVec<U32>, +ar: U32, +im: U32, +vd: Nat, ops: List<&2, IrOp>, +dm: RaVec<Bool>, +srev: List<&2, IrOp>, +drev: List<&2, U32>) -> V4Split:
  match ops:
    case Nil{}: V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}}
    case Con{ICallDirect{w, +cfid, Con{+cnt, +fargs}}, rest}: (+car = ra_vec_get(U32, 8n, 0, cfid, vmap); V4Split{Bool.and(Bool.and(U32.is_ne(car, 0), U32.is_eq(b5k_u32_list_len(fargs), U32.sub(car, 1))), Bool.and(U32.is_lt(cnt, ar), U32.is_ne(U32.and(im, U32.shln(1, U32.to_nat(cnt))), 0))), b5k_list_rev(IrOp, srev), w, cfid, cnt, fargs, rest, b5k_list_rev(U32, drev)})
    case Con{IConst{+d, v}, t}: v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IConst{d, v}, srev}, Con{d, drev})
    case Con{IFlt{+d, b}, t}: v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IFlt{d, b}, srev}, Con{d, drev})
    case Con{ICopy{+d, +s}, t}: Bool.pick(V4Split, v4_v_ok(ar, im, vd, dm, s), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{ICopy{d, s}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{IBin{+d, bop, +l, +r}, t}: Bool.pick(V4Split, Bool.and(v4_v_ok(ar, im, vd, dm, l), v4_v_ok(ar, im, vd, dm, r)), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IBin{d, bop, l, r}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{IUn{+d, uop, +s}, t}: Bool.pick(V4Split, v4_v_ok(ar, im, vd, dm, s), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IUn{d, uop, s}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{ICmp{+d, cop, +l, +r}, t}: Bool.pick(V4Split, Bool.and(v4_v_ok(ar, im, vd, dm, l), v4_v_ok(ar, im, vd, dm, r)), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{ICmp{d, cop, l, r}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case _: V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}}
def v4_s0_ops(+jl: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>: opt_map_ops_rm(False{}, RMZero{jl}, ops)
def v4_live_outs(+vd: Nat, +pu: RaVec<U32>, ds: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>: b5k_list_rev(U32, opt_foldl2(~U32, ~Nat, ~RaVec<U32>, ~List<&2, U32>, ~(v => p => +d => +a => Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(ra_vec_get(U32, v, 0, d, p), 0), Bool.not(x64_u32_in(d, a))), Con{d, a}, a)), vd, pu, ds, acc))
def v4_io_ir(+is_st: Bool, +boff: U32, +ptr: U32, xs: List<&2, U32>, +k: U32) -> List<&2, IrOp>:
  match xs:
    case Nil{}: Nil{}
    case Con{+v, t}: Con{Bool.pick(IrOp, is_st, IStore{ptr, U32.add(boff, U32.mul(k, 8)), v}, ILoad{v, ptr, U32.add(boff, U32.mul(k, 8))}), v4_io_ir(is_st, boff, ptr, t, U32.add(k, 1))}
def v4_acc_cp(+ph2: Bool, targs: List<&2, U32>, +idx: U32, +nv: U32) -> List<&2, IrOp>:
  match targs:
    case Nil{}: Nil{}
    case Con{+a, +t}: Bool.pick(List<&2, IrOp>, U32.is_eq(a, idx), v4_acc_cp(ph2, t, U32.add(idx, 1), nv), Con{Bool.pick(IrOp, ph2, ICopy{idx, nv}, ICopy{nv, a}), v4_acc_cp(ph2, t, U32.add(idx, 1), U32.add(nv, 1))})
def v4_rw_b0(+sid: U32, +cid: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Con{IrBlock{0, ops, TBr{c, +tb, +eb}}, t}: Con{IrBlock{0, ops, TBr{c, Bool.pick(U32, U32.is_eq(tb, sid), cid, tb), Bool.pick(U32, U32.is_eq(eb, sid), cid, eb)}}, t}
    case bs: bs
def v4_build_caller(sp: V4Split, +fid: U32, name: String, +ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +sid: U32, +targs: List<&2, U32>) -> IrFn & Bool:
  match sp:
    case V4Split{False{}, _, _, _, _, _, _, _}: (IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{})
    case V4Split{True{}, setup, w, +cfid, cnt, +fargs, +post, defs}: (+vd = ra_vd_of(U32.max(nregs, ar)); +los = v4_live_outs(vd, x64_inc_uses(vd, targs, opt_foldl(~IrOp, ~Nat, ~RaVec<U32>, ~(v1 => op => u1 => x64_inc_uses(v1, opt_op_uses_list(op), u1)), vd, post, RVEmpty{})), defs, Nil{}); +kf = b5k_u32_list_len(fargs); +ml = b5k_u32_list_len(los); +nb = U32.add(opt_blks_max_id(blks, 0), 1); +v = nregs; +a_vs = opt_ww_seq(U32.to_nat(kf), U32.add(v, 18)); +v_ac = U32.add(U32.add(v, 18), kf); +b8_ops: List<&2, IrOp> = [IConst{U32.add(v, 8), U32.mul(kf, 32)}, IBin{U32.add(v, 9), 14, U32.add(v, 2), U32.add(v, 8)}, IConst{U32.add(v, 10), 3}, IBin{U32.add(v, 11), 8, U32.add(v, 3), U32.add(v, 10)}, IBin{U32.add(v, 12), 14, U32.add(v, 9), U32.add(v, 11)}]; +p4_ops: List<&2, IrOp> = [IConst{U32.add(v, 5), 2}, IBin{U32.add(v, 6), 8, U32.add(v, 3), U32.add(v, 5)}, IBin{U32.add(v, 7), 14, U32.add(v, 2), U32.add(v, 6)}]; +inc_ops: List<&2, IrOp> = [IConst{U32.add(v, 13), 1}, IBin{U32.add(v, 3), 0, U32.add(v, 3), U32.add(v, 13)}, ICmp{U32.add(v, 14), 2, U32.add(v, 3), v}]; b_chk: IrBlock = IrBlock{nb, [IConst{v, 8}, ICmp{U32.add(v, 1), 5, 0, v}], TBr{U32.add(v, 1), U32.add(nb, 1), sid}}; b_ini: IrBlock = IrBlock{U32.add(nb, 1), [IAlloca{U32.add(v, 2), U32.add(U32.mul(kf, 4), U32.mul(ml, 8))}, IConst{U32.add(v, 3), 0}], TJmp{U32.add(nb, 2)}}; s_lo = Bool.pick(List<&2, IrOp>, U32.is_zero(ml), Nil{}, b5k_list_app(IrOp, b8_ops, v4_io_ir(True{}, 0, U32.add(v, 12), los, 0))); b_set: IrBlock = IrBlock{U32.add(nb, 2), b5k_list_app(IrOp, Con{IBin{U32.add(v, 4), 1, 0, U32.add(v, 3)}, v4_s0_ops(U32.add(v, 4), setup)}, b5k_list_app(IrOp, p4_ops, b5k_list_app(IrOp, v4_io_ir(True{}, 65536, U32.add(v, 7), fargs, 0), b5k_list_app(IrOp, s_lo, inc_ops)))), TBr{U32.add(v, 14), U32.add(nb, 2), U32.add(nb, 3)}}; b_cal: IrBlock = IrBlock{U32.add(nb, 3), [ICallDirect{U32.add(v, 15), U32.add(65536, cfid), [cnt, U32.add(v, 2)]}, IConst{U32.add(v, 3), 0}], TJmp{U32.add(nb, 4)}}; e_lo = Bool.pick(List<&2, IrOp>, U32.is_zero(ml), Nil{}, b5k_list_app(IrOp, b8_ops, v4_io_ir(False{}, 0, U32.add(v, 12), los, 0))); b_epi: IrBlock = IrBlock{U32.add(nb, 4), b5k_list_app(IrOp, Con{IBin{U32.add(v, 4), 1, 0, U32.add(v, 3)}, p4_ops}, b5k_list_app(IrOp, v4_io_ir(False{}, 65536, U32.add(v, 7), a_vs, 0), b5k_list_app(IrOp, e_lo, b5k_list_app(IrOp, [IConst{U32.add(v, 16), 0}, ICallDirect{w, cfid, Con{U32.add(v, 16), a_vs}}], b5k_list_app(IrOp, v4_s0_ops(U32.add(v, 4), post), b5k_list_app(IrOp, v4_acc_cp(False{}, targs, 1, v_ac), b5k_list_app(IrOp, v4_acc_cp(True{}, targs, 1, v_ac), inc_ops))))))), TBr{U32.add(v, 14), U32.add(nb, 4), U32.add(nb, 5)}}; b_don: IrBlock = IrBlock{U32.add(nb, 5), [IBin{U32.add(v, 17), 1, 0, v}], TTailCall{fid, Con{U32.add(v, 17), opt_ww_seq(U32.to_nat(U32.sub(ar, 1)), 1)}}}; (IrFn{fid, name, ar, U32.add(v_ac, ar), esc, eff, is_m, b5k_list_app(IrBlock, v4_rw_b0(sid, nb, blks), [b_chk, b_ini, b_set, b_cal, b_epi, b_don])}, True{}))
type V8Op is Data:
  V8Ir{op: IrOp}
  V8Lut{dst: U32, vs: List<&2, U32>}
  V8Sel{dst: U32, cop: U32, lhs: U32, rhs: U32, tval: U32, eval: U32}
type V8Cmp is Data:
  V8Cmp{v: U32, a: U32, b: U32}
type V8Arm is Data:
  V8Arm{ok: Bool, d: U32, j: U32, b: U32}
type V8Cls is Data:
  V8Cls{ok: Bool, pt: U32, pk: U32, bi: U32, invs: List<&2, U32>}
type V8LutHit is Data:
  V8LutHit{ok: Bool, dst: U32, join: U32, vs: List<&2, U32>}
type V8Lin is Data:
  V8Lin{ok: Bool, ops_rev: List<&2, V8Op>, targs: List<&2, U32>, cmp_d: U32, cmp_t: U32, cmp_bt: U32, nv: U32}
type V8Red is Data:
  V8Red{ok: Bool, fid: U32, name: String, ar: U32, nregs: U32, sid: U32, lt_p: U32, pt_p: U32, pk_p: U32, bt_p: U32, bi_p: U32, invs: List<&2, U32>, ops: List<&2, V8Op>, res_v: U32}
type V8Pure is Data:
  V8Pure{ok: Bool, ops: List<&2, V8Op>}
def v8r_no_red() -> V8Red: V8Red{False{}, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, Nil{}, Nil{}, 0}
def v8r_cm_walk(+vd: Nat, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, cm: RaVec<U32>) -> RaVec<U32>:
  match blks ops:
    case Nil{} Nil{}: cm
    case Con{IrBlock{_, ops1, _}, t} Nil{}: v8r_cm_walk(vd, t, ops1, cm)
    case _ Con{IConst{d, val}, ot}: v8r_cm_walk(vd, blks, ot, ra_vec_set(U32, vd, d, U32.add(val, 1), cm))
    case _ Con{_, ot}: v8r_cm_walk(vd, blks, ot, cm)
def v8r_cmp_ops(+is_z: Bool, +vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +k: U32, +tb: U32, +eb: U32) -> V8Cmp:
  match ops:
    case Nil{}: V8Cmp{0, 0, 0}
    case Con{ICmp{d, +cop, +a, +b}, t}: (+v1 = Bool.pick(U32, is_z, Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, b, cm), 1), U32.add(a, 1), Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, a, cm), 1), U32.add(b, 1), 0)), Bool.pick(U32, U32.is_eq(a, k), ra_vec_get(U32, vd, 0, b, cm), Bool.pick(U32, U32.is_eq(b, k), ra_vec_get(U32, vd, 0, a, cm), 0))); +is0 = U32.is_zero(cop); Bool.pick(V8Cmp, Bool.and(Bool.and(U32.is_eq(d, c), U32.is_le(cop, 1)), U32.is_ne(v1, 0)), V8Cmp{v1, Bool.pick(U32, is0, tb, eb), Bool.pick(U32, is0, eb, tb)}, v8r_cmp_ops(is_z, vd, cm, t, c, k, tb, eb)))
    case Con{_, t}: v8r_cmp_ops(is_z, vd, cm, t, c, k, tb, eb)
def v8r_cmp_eq(vd: Nat, cm: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +k: U32, +tb: U32, +eb: U32) -> V8Cmp: Bool.pick(V8Cmp, U32.is_eq(c, k), V8Cmp{1, eb, tb}, v8r_cmp_ops(False{}, vd, cm, ops, c, k, tb, eb))
def v8r_cmp_z(vd: Nat, cm: RaVec<U32>, ar: U32, ops: List<&2, IrOp>, +c: U32, +tb: U32, +eb: U32) -> V8Cmp: Bool.pick(V8Cmp, U32.is_lt(c, ar), V8Cmp{U32.add(c, 1), eb, tb}, v8r_cmp_ops(True{}, vd, cm, ops, c, 0, tb, eb))
def v8r_find_dec(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{d, +bop, 0, r}, t}: Bool.pick(U32, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), U32.is_eq(ra_vec_get(U32, vd, 0, r, cm), 2)), U32.add(d, 1), v8r_find_dec(vd, cm, t))
    case Con{_, t}: v8r_find_dec(vd, cm, t)
def v8r_fcmp(ops: List<&2, IrOp>, +c: U32) -> V8Cmp:
  match ops:
    case Nil{}: V8Cmp{0, 0, 0}
    case Con{ICmp{d, +cop, l, r}, t}: Bool.pick(V8Cmp, Bool.and(U32.is_eq(d, c), Bool.and(U32.is_ge(cop, 8), U32.is_le(cop, 11))), V8Cmp{cop, l, r}, v8r_fcmp(t, c))
    case Con{_, t}: v8r_fcmp(t, c)
def v8r_last_flt_lt(ops: List<&2, IrOp>, cur: V8Cmp) -> V8Cmp:
  match ops:
    case Nil{}: cur
    case Con{ICmp{d, 8, l, r}, t}: v8r_last_flt_lt(t, V8Cmp{U32.add(d, 1), l, r})
    case Con{_, t}: v8r_last_flt_lt(t, cur)
def v8r_arm_flt(ops: List<&2, IrOp>, +fv: U32, +fb: U32, +dst: U32) -> V8Arm:
  match ops:
    case Nil{}: V8Arm{U32.is_ne(dst, 0), U32.sub(dst, 1), 0, fb}
    case Con{IFlt{+d, b}, t}: v8r_arm_flt(t, U32.add(d, 1), b, U32.add(d, 1))
    case Con{ICopy{d, s}, t}: Bool.pick(V8Arm, U32.is_eq(U32.add(s, 1), fv), v8r_arm_flt(t, fv, fb, U32.add(d, 1)), V8Arm{False{}, 0, 0, 0})
    case _: V8Arm{False{}, 0, 0, 0}
def v8r_un_arm(-R: Type, a: V8Arm, k: Bool -> U32 -> U32 -> U32 -> R) -> R:
  V8Arm{ok, d, j, b} = a
  k(ok, d, j, b)
def v8r_un_cmp(-R: Type, c: V8Cmp, k: U32 -> U32 -> U32 -> R) -> R:
  V8Cmp{v, a, b} = c
  k(v, a, b)
def v8r_un_pure(-R: Type, p: V8Pure, k: Bool -> List<&2, V8Op> -> R) -> R:
  V8Pure{ok, ops} = p
  k(ok, ops)
def v8r_un_lin(-R: Type, l: V8Lin, k: Bool -> List<&2, V8Op> -> List<&2, U32> -> U32 -> U32 -> U32 -> U32 -> R) -> R:
  V8Lin{ok, ops, ta, cd, ct, cbt, nv} = l
  k(ok, ops, ta, cd, ct, cbt, nv)
def v8r_last_dst(ops: List<&2, IrOp>, cur: U32) -> U32:
  match ops:
    case Nil{}: cur
    case Con{IFlt{d, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{ICopy{d, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{IBin{d, _, _, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{IUn{d, _, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{_, t}: v8r_last_dst(t, cur)
def v8r_blk_arm(is_flt: Bool, blk: V8Blk) -> V8Arm:
  match is_flt blk:
    case True{} V8Blk{True{}, ops, TJmp{j}}: v8r_un_arm(V8Arm, v8r_arm_flt(ops, 0, 0, 0), ok => d => _ => b => V8Arm{ok, d, j, b})
    case False{} V8Blk{True{}, ops, TJmp{j}}: (+ld = v8r_last_dst(ops, 0); V8Arm{U32.is_ne(ld, 0), ld, j, 0})
    case _ _: V8Arm{False{}, 0, 0, 0}
def v8r_try_lut_go(n: Nat, ok: Bool, blk: V8Blk, +vd: Nat, +cm: RaVec<U32>, +blks: List<&2, IrBlock>, +k: U32, +idx: U32, +res: U32, +join: U32, acc: List<&2, U32>) -> V8LutHit:
  match n ok blk:
    case _ False{} _: V8LutHit{False{}, 0, 0, Nil{}}
    case 0n True{} b: v8r_un_arm(V8LutHit, v8r_blk_arm(True{}, b), aok => ad => aj => _ => V8LutHit{Bool.and(aok, Bool.and(U32.is_eq(ad, res), U32.is_eq(aj, join))), res, join, b5k_list_rev(U32, acc)})
    case 1n+p True{} V8Blk{True{}, ops, TBr{c, tb, eb}}: v8r_un_cmp(V8LutHit, v8r_cmp_eq(vd, cm, ops, c, k, tb, eb), ev => ea => neb => v8r_un_arm(V8LutHit, v8r_blk_arm(True{}, v8r_get_blk(ea, blks)), aok => ad_ => aj_ => ab => ( +ad = ad_; +aj = aj_; sok = Bool.and(Bool.and(U32.is_eq(ev, U32.add(idx, 1)), aok), Bool.or(U32.is_zero(idx), Bool.and(U32.is_eq(ad, res), U32.is_eq(aj, join)))); v8r_try_lut_go(p, sok, v8r_get_blk(neb, blks), vd, cm, blks, k, U32.add(idx, 1), ad, aj, Con{ab, acc}))))
    case _ _ _: V8LutHit{False{}, 0, 0, Nil{}}
def v8r_rw_dst(+dst_h: U32, +new_d: U32, +d: U32) -> U32: Bool.pick(U32, Bool.and(U32.is_ne(dst_h, 0), U32.is_eq(d, U32.sub(dst_h, 1))), new_d, d)
def v8r_emit_pure(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>, +in_br: Bool, +dst_h: U32, +new_d: U32, acc: List<&2, V8Op>) -> V8Pure:
  match ops:
    case Nil{}: V8Pure{True{}, acc}
    case Con{IConst{_, _}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc)
    case Con{ICmp{_, _, _, _}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc)
    case Con{IFlt{d, b}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Ir{IFlt{v8r_rw_dst(dst_h, new_d, d), b}}, acc})
    case Con{ICopy{d, s}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Ir{ICopy{v8r_rw_dst(dst_h, new_d, d), s}}, acc})
    case Con{IBin{_, 1, 0, r}, t}: Bool.pick(V8Pure, U32.is_eq(ra_vec_get(U32, vd, 0, r, cm), 2), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc), V8Pure{False{}, Nil{}})
    case Con{IBin{_, 15, 0, r}, t}: Bool.pick(V8Pure, U32.is_eq(ra_vec_get(U32, vd, 0, r, cm), 2), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc), V8Pure{False{}, Nil{}})
    case Con{IBin{d, +bop, l, r}, t}: Bool.pick(V8Pure, Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Ir{IBin{v8r_rw_dst(dst_h, new_d, d), bop, l, r}}, acc}), V8Pure{False{}, Nil{}})
    case Con{IUn{d, +uop, s}, t}: Bool.pick(V8Pure, Bool.or(U32.is_eq(uop, 2), U32.is_eq(uop, 3)), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Ir{IUn{v8r_rw_dst(dst_h, new_d, d), Bool.pick(U32, Bool.and(in_br, U32.is_eq(uop, 3)), 40, uop), s}}, acc}), V8Pure{False{}, Nil{}})
    case _: V8Pure{False{}, Nil{}}
def v8r_un_lut(-R: Type, h: V8LutHit, k: Bool -> U32 -> U32 -> List<&2, U32> -> R) -> R:
  V8LutHit{ok, d, j, vs} = h
  k(ok, d, j, vs)
type V8BrPrep is Data:
  V8BrPrep{lok: Bool, lhd: U32, lhj: U32, lhvs: List<&2, U32>, acc1: List<&2, V8Op>, sok: Bool, fcv: U32, fca: U32, fcb: U32, dh: U32, jn: U32}
def v8r_br_prep(pr: V8Pure, eq: V8Cmp, fc: V8Cmp, +ja1: V8Arm, ja2: V8Arm, vd: Nat, cm: RaVec<U32>, +blks: List<&2, IrBlock>, k: U32, bid: U32) -> V8BrPrep:
  V8Pure{+pok, acc1} = pr
  V8Cmp{eq_v, _, _} = eq
  V8Cmp{+fcv, fca, fcb} = fc
  V8Arm{ja1_ok, _, _, _} = ja1
  +is_lut = U32.is_eq(eq_v, 1)
  v8r_un_arm(V8BrPrep, Bool.pick(V8Arm, ja1_ok, ja1, ja2), ja_ok => dh => jn => _ => v8r_un_lut(V8BrPrep, v8r_try_lut_go(8n, Bool.and(pok, is_lut), v8r_get_blk(bid, blks), vd, cm, blks, k, 0, 0, 0, Nil{}), lok => lhd => lhj => lhvs => V8BrPrep{lok, lhd, lhj, lhvs, acc1, Bool.and(Bool.and(pok, Bool.not(is_lut)), Bool.and(U32.is_ne(fcv, 0), ja_ok)), fcv, fca, fcb, dh, jn}))
def v8r_br_fin(bp: V8BrPrep, r2: V8Lin, +stop: U32, +dst_h: U32, +new_d: U32, +nv: U32) -> V8Lin:
  V8BrPrep{+lok, lhd, lhj, lhvs, acc1, _, fcv, fca, fcb, dh, +jn} = bp
  V8Lin{r2_ok, r2_ops, _, _, _, _, r2_nv} = r2
  +sd = v8r_rw_dst(Bool.pick(U32, U32.is_eq(jn, stop), dst_h, 0), new_d, U32.sub(dh, 1))
  V8Lin{Bool.or(lok, r2_ok), Bool.pick(List<&2, V8Op>, lok, Con{V8Lut{lhd, lhvs}, acc1}, Con{V8Sel{sd, fcv, fca, fcb, nv, U32.add(nv, 1)}, r2_ops}), Nil{}, Bool.pick(U32, lok, lhj, jn), 0, 0, Bool.pick(U32, lok, nv, r2_nv)}
def v8r_un_brp(-R: Type, bp: V8BrPrep, k: List<&2, V8Op> -> Bool -> U32 -> U32 -> R) -> R:
  V8BrPrep{_, _, _, _, acc1, sok, _, _, _, dh, jn} = bp
  k(acc1, sok, dh, jn)
def v8r_lin(fuel: Nat, go: Bool, blk: V8Blk, +vd: Nat, +cm: RaVec<U32>, +fid: U32, +blks: List<&2, IrBlock>, +k: U32, +stop: U32, +dst_h: U32, +new_d: U32, +in_br: Bool, +bid: U32, +acc: List<&2, V8Op>, +nv: U32) -> V8Lin:
  match fuel go blk:
    case _ False{} _: V8Lin{False{}, Nil{}, Nil{}, 0, 0, 0, nv}
    case 0n _ _: V8Lin{False{}, Nil{}, Nil{}, 0, 0, 0, nv}
    case 1n+p True{} V8Blk{True{}, ops, TJmp{+tgt}}: v8r_un_pure(V8Lin, v8r_emit_pure(vd, cm, ops, in_br, Bool.pick(U32, U32.is_eq(tgt, stop), dst_h, 0), new_d, acc), pok => pops => Bool.pick(V8Lin, U32.is_eq(bid, stop), V8Lin{True{}, acc, Nil{}, 0, 0, 0, nv}, v8r_lin(p, pok, v8r_get_blk(tgt, blks), vd, cm, fid, blks, k, stop, dst_h, new_d, in_br, tgt, pops, nv)))
    case 1n+p0 True{} V8Blk{True{}, +ops, TBr{+a0, +tb, +eb}}: (+p = p0; +bp = v8r_br_prep(v8r_emit_pure(vd, cm, ops, in_br, 0, 0, acc), v8r_cmp_eq(vd, cm, ops, a0, k, tb, eb), v8r_fcmp(ops, a0), v8r_blk_arm(False{}, v8r_get_blk(tb, blks)), v8r_blk_arm(False{}, v8r_get_blk(eb, blks)), vd, cm, blks, k, bid); r2 = v8r_un_brp(V8Lin, bp, acc1 => sok => dh_ => jn_ => ( +dh = dh_; +jn = jn_; v8r_un_lin(V8Lin, v8r_lin(p, sok, v8r_get_blk(tb, blks), vd, cm, fid, blks, k, jn, dh, nv, True{}, tb, acc1, U32.add(nv, 2)), r1_ok => r1_ops => _ => _ => _ => _ => r1_nv => v8r_lin(p, r1_ok, v8r_get_blk(eb, blks), vd, cm, fid, blks, k, jn, dh, U32.add(nv, 1), True{}, eb, r1_ops, r1_nv)))); v8r_un_lin(V8Lin, v8r_br_fin(bp, r2, stop, dst_h, new_d, nv), ok => n_acc => _ => n_bid_ => _ => _ => n_nv => ( +n_bid = n_bid_; Bool.pick(V8Lin, U32.is_eq(bid, stop), V8Lin{True{}, acc, Nil{}, 0, 0, 0, nv}, v8r_lin(p, ok, v8r_get_blk(n_bid, blks), vd, cm, fid, blks, k, stop, dst_h, new_d, in_br, n_bid, n_acc, n_nv)))))
    case 1n+p True{} V8Blk{True{}, +ops, TTailCall{tfid, args}}: v8r_un_pure(V8Lin, v8r_emit_pure(vd, cm, ops, in_br, 0, 0, acc), pok => pops => v8r_un_cmp(V8Lin, v8r_last_flt_lt(ops, V8Cmp{0, 0, 0}), cd1_ => lta => ltb => ( +cd1 = cd1_; Bool.pick(V8Lin, U32.is_eq(bid, stop), V8Lin{True{}, acc, Nil{}, 0, 0, 0, nv}, V8Lin{Bool.and(Bool.and(U32.is_eq(stop, 4294967295), U32.is_eq(tfid, fid)), Bool.and(pok, U32.is_ne(cd1, 0))), pops, args, U32.sub(cd1, 1), lta, ltb, nv}))))
    case 1n+p True{} _: Bool.pick(V8Lin, U32.is_eq(bid, stop), V8Lin{True{}, acc, Nil{}, 0, 0, 0, nv}, V8Lin{False{}, Nil{}, Nil{}, 0, 0, 0, nv})
def v8r_classify(tf: List<&2, U32>, tt: List<&2, U32>, go: Bool, +lt_p: U32, +cmp_d: U32, +cmp_t: U32, +cmp_bt: U32, +k_reg: U32, +idx: U32, +pt: U32, +pk: U32, +bi: U32, +invs: List<&2, U32>) -> V8Cls:
  match tf tt go:
    case _ _ False{}: V8Cls{False{}, 0, 0, 0, Nil{}}
    case Nil{} Nil{} True{}: V8Cls{Bool.and(U32.is_ne(pt, 0), Bool.or(U32.is_zero(pk), U32.is_ne(bi, 0))), pt, pk, bi, b5k_list_rev(U32, invs)}
    case Con{+af, rf} Con{+at, rt} True{}: (+is_lt = U32.is_eq(idx, lt_p); +is_pt = Bool.and(Bool.not(is_lt), U32.is_eq(af, cmp_t)); +is_pk = Bool.and(Bool.not(Bool.or(is_lt, is_pt)), U32.is_eq(af, k_reg)); +is_id = Bool.and(Bool.not(Bool.or(is_lt, Bool.or(is_pt, is_pk))), U32.is_eq(af, idx)); +ok = Bool.or(Bool.and(is_lt, U32.is_eq(af, cmp_d)), Bool.or(is_pt, Bool.or(is_pk, is_id))); +is_inv = Bool.and(is_id, Bool.and(U32.is_ne(idx, cmp_bt), U32.is_eq(at, idx))); +is_bi = Bool.and(is_id, Bool.and(U32.is_ne(idx, cmp_bt), U32.is_ne(at, idx))); v8r_classify(rf, rt, ok, lt_p, cmp_d, cmp_t, cmp_bt, k_reg, U32.add(idx, 1), Bool.pick(U32, is_pt, idx, pt), Bool.pick(U32, is_pk, idx, pk), Bool.pick(U32, is_bi, idx, bi), Bool.pick(List<&2, U32>, is_inv, Con{idx, invs}, invs)))
    case _ _ _: V8Cls{False{}, 0, 0, 0, Nil{}}
def v8r_blk_k(blk: V8Blk, vd: Nat, cm: RaVec<U32>, defk: U32) -> U32:
  match blk:
    case V8Blk{True{}, bops, _}: (+k2 = v8r_find_dec(vd, cm, bops); Bool.pick(U32, U32.is_ne(k2, 0), U32.sub(k2, 1), defk))
    case _: defk
def v8r_match_cls(cls: V8Cls, fid: U32, name: String, +ar: U32, nv1: U32, sid: U32, lt_p: U32, +cbt: U32, cbt2: U32, k_reg: U32, ftargs: List<&2, U32>, fops: List<&2, V8Op>, ct: U32) -> V8Red:
  V8Cls{cok, +pt, pk, bi, invs} = cls
  V8Red{Bool.and(Bool.and(U32.is_eq(x64_u32_nth(ftargs, 0n), k_reg), U32.is_eq(cbt2, pt)), Bool.and(cok, Bool.and(U32.is_ge(cbt, 1), U32.is_lt(cbt, ar)))), fid, name, ar, nv1, sid, lt_p, pt, pk, cbt, bi, invs, b5k_list_rev(V8Op, fops), ct}
def v8r_mlin2(fid: U32, name: String, +ar: U32, nv1: U32, sid: U32, +lt_p: U32, cd: U32, +ct: U32, +cbt: U32, +k_reg: U32, +ftargs: List<&2, U32>, fops: List<&2, V8Op>, l2: V8Lin) -> V8Red:
  V8Lin{ok2, _, +ttargs, _, _, cbt2, _} = l2
  low_if(V8Red, Bool.and(ok2, U32.is_ne(b5k_u32_list_len(ttargs), 0)), _ => v8r_match_cls(v8r_classify(low_drop(U32, 1n, ftargs), low_drop(U32, 1n, ttargs), True{}, lt_p, cd, ct, cbt, k_reg, 1, 0, 0, 0, Nil{}), fid, name, ar, nv1, sid, lt_p, cbt, cbt2, k_reg, ftargs, fops, ct), _ => v8r_no_red())
def v8r_mlin1(+vd: Nat, +cm: RaVec<U32>, +fid: U32, name: String, +ar: U32, +blks: List<&2, IrBlock>, sid: U32, +lt_p: U32, +cb: U32, +k_reg: U32, l1: V8Lin) -> V8Red:
  V8Lin{ok1, fops, +ftargs, cd, ct, cbt, +nv1} = l1
  low_if(V8Red, Bool.and(ok1, U32.is_ne(b5k_u32_list_len(ftargs), 0)), _ => v8r_mlin2(fid, name, ar, nv1, sid, lt_p, cd, ct, cbt, k_reg, ftargs, fops, v8r_lin(64n, True{}, v8r_get_blk(cb, blks), vd, cm, fid, blks, v8r_blk_k(v8r_get_blk(cb, blks), vd, cm, k_reg), 4294967295, 0, 0, False{}, cb, Nil{}, nv1)), _ => v8r_no_red())
def v8r_match_lin(+vd: Nat, +cm: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, +blks: List<&2, IrBlock>, sid: U32, blk: V8Blk) -> V8Red:
  match blk:
    case V8Blk{True{}, +ops, TBr{c, tb, eb}}: (+k1 = v8r_find_dec(vd, cm, ops); +k_reg = U32.sub(k1, 1); v8r_un_cmp(V8Red, v8r_cmp_z(vd, cm, ar, ops, c, tb, eb), l1 => ca0 => cb => (+lt1 = l1; +ca = ca0; v8r_mlin1(vd, cm, fid, name, ar, blks, sid, U32.sub(lt1, 1), cb, k_reg, v8r_lin(64n, Bool.and(U32.is_ne(k1, 0), Bool.and(U32.is_gt(lt1, 1), U32.is_lt(U32.sub(lt1, 1), ar))), v8r_get_blk(ca, blks), vd, cm, fid, blks, k_reg, 4294967295, 0, 0, False{}, ca, Nil{}, nregs)))))
    case _: v8r_no_red()
def v8r_skip_z(blk: V8Blk, vd: Nat, cm: RaVec<U32>, ar: U32, bid: U32) -> U32:
  match blk:
    case V8Blk{True{}, ops, TBr{c, tb, eb}}: v8r_un_cmp(U32, v8r_cmp_z(vd, cm, ar, ops, c, tb, eb), zv => _ => zb => Bool.pick(U32, U32.is_eq(zv, 1), zb, bid))
    case _: bid
def v8r_match_b0(blk: V8Blk, +vd: Nat, +cm: RaVec<U32>, fid: U32, name: String, +ar: U32, nregs: U32, +blks: List<&2, IrBlock>) -> V8Red:
  match blk:
    case V8Blk{True{}, ops, TBr{c, tb, eb}}: v8r_un_cmp(V8Red, v8r_cmp_z(vd, cm, ar, ops, c, tb, eb), zv => _ => nzb_ => (+nzb = nzb_; low_if(V8Red, Bool.and(Bool.and(U32.is_ge(ar, 4), U32.is_le(ar, 20)), U32.is_eq(zv, 1)), _ => v8r_match_lin(vd, cm, fid, name, ar, nregs, blks, nzb, v8r_get_blk(v8r_skip_z(v8r_get_blk(nzb, blks), vd, cm, ar, nzb), blks)), _ => v8r_no_red())))
    case _: v8r_no_red()
def v8r_match_fn(f: IrFn) -> V8Red:
  match f:
    case IrFn{fid, name, +ar, +nregs, _, False{}, False{}, +blks}: (+vd = ra_vd_of(U32.max(nregs, ar)); v8r_match_b0(v8r_get_blk(0, blks), vd, v8r_cm_walk(vd, blks, Nil{}, RVEmpty{}), fid, name, ar, nregs, blks))
    case _: v8r_no_red()
def v8r_dummy_ops(ops: List<&2, V8Op>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{V8Ir{IUn{d, 40, s}}, t}: Con{IUn{d, 3, s}, v8r_dummy_ops(t)}
    case Con{V8Ir{op}, t}: Con{op, v8r_dummy_ops(t)}
    case Con{V8Lut{d, _}, t}: Con{IFlt{d, 0}, v8r_dummy_ops(t)}
    case Con{V8Sel{+d, _, l, r, tv, ev}, t}: Con{IBin{d, 10, l, r}, Con{IBin{d, 10, tv, ev}, v8r_dummy_ops(t)}}
def v8r_emit_lut_vals(vs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl0(~U32, ~List<&2, X64Inst>, ~(v => a => x64_emit(XExtReloc{1, "", v}, a)), vs, acc)
def v8_emit_invs(+base: U32, +off0: U32, +rm: RaVec<U32>, +vd: Nat, invs: List<&2, U32>, +m: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match invs:
    case Nil{}: acc
    case Con{p, t}: (+loc = ra_vec_get(U32, vd, 0, p, rm); v8_emit_invs(base, off0, rm, vd, t, U32.add(m, 1), Bool.pick(List<&2, X64Inst>, U32.is_zero(loc), acc, v4_mem_io(True{}, U32.is_ge(loc, 100), 48, base, loc, U32.add(off0, U32.mul(m, 4)), acc))))
def v8r_emit_op(+rm: RaVec<U32>, +vd: Nat, op: V8Op, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case V8Ir{ir}: v4_emit_op(rm, vd, ir, acc)
    case V8Lut{d, vs}: v4_dst(rm, vd, d, dx => x64_emit(XXmmLoad{U32.add(32, dx), 0, 0}, v8r_emit_lut_vals(vs, x64_emit(XExtReloc{2, "", 0}, acc))))
    case V8Sel{d, +cop, l, r, tv, ev}: (+ll = ra_vec_get(U32, vd, 0, l, rm); +rl = ra_vec_get(U32, vd, 0, r, rm); +tl = ra_vec_get(U32, vd, 0, tv, rm); +el = ra_vec_get(U32, vd, 0, ev, rm); +lx = v4_reg(ll, 0); +rx = v4_reg(rl, 1); +sw = U32.is_ge(cop, 10); a_c = x64_emit(XXmmRR{v4_vex_op(Bool.pick(U32, sw, rx, lx), Bool.pick(U32, Bool.or(U32.is_eq(cop, 8), U32.is_eq(cop, 10)), 8, 9)), 1, Bool.pick(U32, sw, lx, rx)}, v4_ld_sp(rl, 1, v4_ld_sp(ll, 0, acc))); v4_dst(rm, vd, d, dx => +x = dx; +ex = v4_reg(el, Bool.pick(U32, U32.is_ge(tl, 100), x, 0)); x64_emit(XXmmRR{v4_vex_op(ex, 12), x, v4_reg(tl, 0)}, v4_ld_sp(tl, 0, v4_ld_sp(el, ex, a_c)))))
def v8r_emit_ops(+rm: RaVec<U32>, +vd: Nat, ops: List<&2, V8Op>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>: opt_foldl2(~V8Op, ~RaVec<U32>, ~Nat, ~List<&2, X64Inst>, ~(r => v => op => a => v8r_emit_op(r, v, op, a)), rm, vd, ops, acc)
def v8r_emit_lane(n: Nat, +has_idx: Bool, +k: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: (+lbl = U32.add(k, 10); a1 = x64_emit(XJcc{6, lbl}, x64_emit(XXmmRR{5, 0, 1}, x64_emit(XXmmLoad{1, 4, U32.mul(k, 4)}, acc))); a2 = x64_emit(XLabel{lbl}, x64_emit_if(has_idx, XMovRI32{0, k}, x64_emit(XXmmRR{7, 0, 1}, a1))); v8r_emit_lane(p, has_idx, U32.sub(k, 1), a2))
def x64_emit_v8r_fn(red: V8Red) -> X64Fn:
  V8Red{_, fid, +name, ar, nregs, _, _, _, pk_p, _, _, +invs, +ops, +res_v} = red
  +has_idx = U32.is_ne(pk_p, 0)
  v4_un_ra(X64Fn, b5k_regalloc_v4(IrFn{fid, name, ar, nregs, False{}, False{}, False{}, Con{IrBlock{0, v8r_dummy_ops(ops), TRet{res_v}}, Nil{}}}), rm_ => vd_ => sc => ( +rm = rm_; +vd = vd_; v4_avx_fn(String.append("$v8r.", name), x64_align16(U32.add(64, U32.mul(sc, 32))), a0 => a1 = v8r_emit_ops(rm, vd, ops, v8_emit_invs(6, 16, rm, vd, invs, 0, a0)); +rl = ra_vec_get(U32, vd, 0, res_v, rm); a2 = x64_emit(XXmmRR{14, 0, 0}, x64_emit(XXmmStore{4, 0, U32.add(48, v4_reg(rl, 0))}, v4_ld_sp(rl, 0, a1))); a3 = x64_emit_if(has_idx, XLoad{0, 6, 8}, x64_emit(XXmmLoad{0, 6, 0}, a2)); x64_emit_if(has_idx, XStore{6, 8, 0}, x64_emit(XXmmStore{6, 0, 32}, v8r_emit_lane(8n, has_idx, 7, a3))))))
def v8r_store_invs(+buf: U32, invs: List<&2, U32>, +m: U32) -> List<&2, IrOp>:
  match invs:
    case Nil{}: Nil{}
    case Con{p, t}: Con{IStore{buf, U32.add(65540, m), p}, v8r_store_invs(buf, t, U32.add(m, 1))}
def v8r_tc_args(n: Nat, +idx: U32, +lt_p: U32, +pt_p: U32, +pk_p: U32, +bt_p: U32, +bi_p: U32, +nbt: U32, +nbi: U32, +zv: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: (a = Bool.pick(U32, U32.is_eq(idx, lt_p), zv, Bool.pick(U32, Bool.or(U32.is_eq(idx, bt_p), U32.is_eq(idx, pt_p)), nbt, Bool.pick(U32, Bool.and(U32.is_ne(pk_p, 0), Bool.or(U32.is_eq(idx, bi_p), U32.is_eq(idx, pk_p))), nbi, idx))); Con{a, v8r_tc_args(p, U32.add(idx, 1), lt_p, pt_p, pk_p, bt_p, bi_p, nbt, nbi, zv)})
def v8r_splice(red: V8Red, f: IrFn) -> IrFn & Bool:
  match red f:
    case V8Red{False{}, _, _, _, _, _, _, _, _, _, _, _, _, _} _: (f, False{})
    case V8Red{True{}, +fid, _, +ar, _, +sid, +lt_p, +pt_p, +pk_p, +bt_p, +bi_p, +invs, _, _} IrFn{_, name, _, +nregs, esc, eff, is_m, +blks}: (+hi = U32.is_ne(pk_p, 0); +nb = U32.add(opt_blks_max_id(blks, 0), 1); +v = nregs; +buf = U32.add(v, 2); +words = U32.add(2, U32.shrn(U32.add(b5k_u32_list_len(invs), 1), 1n)); b_chk: IrBlock = IrBlock{nb, [IConst{v, 8}, ICmp{U32.add(v, 1), 0, 0, v}], TBr{U32.add(v, 1), U32.add(nb, 1), sid}}; b_ini: IrBlock = IrBlock{U32.add(nb, 1), [IAlloca{buf, words}, IConst{U32.add(v, 3), 0}, ICmp{U32.add(v, 4), 0, lt_p, U32.add(v, 3)}], TBr{U32.add(v, 4), U32.add(nb, 2), U32.add(nb, 3)}}; s0 = Bool.pick(List<&2, IrOp>, hi, [IStore{buf, 65536, bt_p}, IStore{buf, 1, bi_p}], [IStore{buf, 65536, bt_p}]); s1 = Bool.pick(List<&2, IrOp>, hi, [IStore{buf, 65536, pt_p}, IStore{buf, 1, pk_p}], [IStore{buf, 65536, pt_p}]); +nbt = U32.add(v, 6); +nbi = U32.add(v, 7); +zv = U32.add(v, 8); lds = Bool.pick(List<&2, IrOp>, hi, [ILoad{nbt, buf, 65536}, ILoad{nbi, buf, 1}, IConst{zv, 0}], [ILoad{nbt, buf, 65536}, IConst{zv, 0}]); b_cal: IrBlock = IrBlock{U32.add(nb, 4), b5k_list_app(IrOp, v8r_store_invs(buf, invs, 0), Con{ICallDirect{U32.add(v, 5), U32.add(131072, fid), [buf]}, lds}), TTailCall{fid, Con{zv, v8r_tc_args(U32.to_nat(U32.sub(ar, 1)), 1, lt_p, pt_p, pk_p, bt_p, bi_p, nbt, nbi, zv)}}}; (IrFn{fid, name, ar, U32.add(v, 9), esc, eff, is_m, b5k_list_app(IrBlock, v4_rw_b0(sid, nb, blks), [b_chk, b_ini, IrBlock{U32.add(nb, 2), s0, TJmp{U32.add(nb, 4)}}, IrBlock{U32.add(nb, 3), s1, TJmp{U32.add(nb, 4)}}, b_cal])}, True{}))
def v8r_scan_one(red: V8Red, st: V4Scan) -> V4Scan:
  match red st:
    case V8Red{True{}, +fid, +name, ar, nregs, sid, lt_p, pt_p, pk_p, bt_p, bi_p, invs, ops, res_v} V4Scan{vm, fm, acc}: V4Scan{vm, ra_vec_set(String, 9n, U32.add(131072, fid), String.append("$v8r.", name), fm), Con{x64_emit_v8r_fn(V8Red{True{}, fid, name, ar, nregs, sid, lt_p, pt_p, pk_p, bt_p, bi_p, invs, ops, res_v}), acc}}
    case _ _: st
def v4_try_batch_hdr(vmap: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, h: V4Hdr) -> IrFn & Bool:
  match h:
    case V4Hdr{True{}, vd, _, blks1, sid, sops, _, +tr}: v4_build_caller(v4_split_ops(vmap, ar, v4_inv_mask(tr, 1, 0), vd, sops, RVEmpty{}, Nil{}, Nil{}), fid, name, ar, nregs, esc, eff, is_m, blks1, sid, tr)
    case V4Hdr{False{}, _, _, blks1, _, _, _, _}: (IrFn{fid, name, ar, nregs, esc, eff, is_m, blks1}, False{})
type V8SpRes is Data:
  V8SpRes{fns: List<&2, IrFn>, bank: InlBank, any: Bool}
def v8r_sp_add(hit: Bool, f: IrFn, bank: InlBank, acc: List<&2, IrFn>, any: Bool) -> V8SpRes:
  match hit f bank:
    case True{} IrFn{+fid, nm, +ar, +nregs, esc, eff, is_m, +blks} InlBank{has, tr}: V8SpRes{Con{IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}, acc}, opt_collect_put(U32.is_lt(fid, 2048), fid, ar, nregs, blks, has, tr), True{}}
    case False{} f1 b1: V8SpRes{Con{f1, acc}, b1, any}
def v8r_splice_all(fns: List<&2, IrFn>, st: V8SpRes) -> V8SpRes:
  match fns st:
    case Nil{} V8SpRes{acc, bank, any}: V8SpRes{b5k_list_rev(IrFn, acc), bank, any}
    case Con{+f, t} V8SpRes{acc, bank, any}: v8r_splice_all(t, ra_un_pair(IrFn, Bool, V8SpRes, v8r_splice(v8r_match_fn(f), f), f1 => hit => v8r_sp_add(hit, f1, bank, acc, any)))
def v8r_inl_round(+bank: InlBank, fns: List<&2, IrFn>) -> List<&2, IrFn>: opt_map_fns(FMMid{}, opt_map_fns(FMMsroa{}, opt_map_fns(FMMid{}, opt_map_fns(FMInl{True{}, False{}, 6, bank}, fns))))
def v8r_inl_pass(sp: V8SpRes) -> List<&2, IrFn>:
  match sp:
    case V8SpRes{fns, _, False{}}: fns
    case V8SpRes{fns, +bank, True{}}: v8r_inl_round(bank, v8r_inl_round(bank, fns))
def v4_try_batch(vmap: RaVec<U32>, +f: IrFn) -> IrFn & Bool:
  match f:
    case IrFn{+fid, +name, +ar, +nregs, +esc, +eff, +is_m, blks}: v4_try_batch_hdr(vmap, fid, name, ar, nregs, esc, eff, is_m, v4_loop_hdr(IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}))
def x64_lower_one_o2(small: Bool, +fn_map: RaVec<String>, +heap_off: U32, +r2s: X64R2Scan, rf: X64RotFn, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  X64RotFn{+f2, t0d} = rf
  Con{x64_make_seg_wrapper(f2), x64_lower_fn_o2_go(small, fn_map, heap_off, r2s, t0d, b5k_regalloc(f2), f2, acc)}
def x64_lower_all(+is_o2: Bool, +small: Bool, +vmap: RaVec<U32>, +fn_map: RaVec<String>, +heap_off: U32, +r2s: X64R2Scan, fns: List<&2, IrFn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_o2 small fns:
    case _ _ Nil{}: acc
    case False{} _ Con{+f, t}: x64_lower_all(False{}, small, vmap, fn_map, heap_off, r2s, t, Con{x64_make_seg_wrapper(f), Con{x64_lower_fn(fn_map, heap_off, f), acc}})
    case True{} False{} Con{f, t}: x64_lower_all(True{}, False{}, vmap, fn_map, heap_off, r2s, t, x64_lower_one_o2(False{}, fn_map, heap_off, r2s, X64RotFn{f, False{}}, acc))
    case True{} True{} Con{f, t}: x64_lower_all(True{}, True{}, vmap, fn_map, heap_off, r2s, t, ra_un_pair(IrFn, Bool, List<&2, X64Fn>, v4_try_batch(vmap, f), f1_ => batched => (+f1 = f1_; x64_lower_one_o2(True{}, fn_map, heap_off, r2s, low_if(X64RotFn, batched, _ => X64RotFn{f1, False{}}, _ => x64_rot_countdown(f1)), acc))))
def x64_codegen_o2_fin(+fns: List<&2, IrFn>, heap_off: U32, sc: V4Scan) -> List<&2, X64Fn>:
  V4Scan{vm, fm1, acc1} = sc
  +fns1 = v8r_inl_pass(v8r_splice_all(fns, V8SpRes{Nil{}, InlBank{UM0{}, RVEmpty{}}, False{}}))
  b5k_list_rev(X64Fn, x64_lower_all(True{}, True{}, vm, fm1, heap_off, x64_scan_ret2(True{}, fns1), fns1, acc1))
def v8a_lane_io(+is_st: Bool, n: Nat, +k: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: v8a_lane_io(is_st, p, U32.add(k, 1), x64_emit(Bool.pick(X64Inst, is_st, XXmmStore{2, U32.mul(k, 8), 0}, XXmmStore{4, U32.mul(k, 4), 32}), x64_emit(Bool.pick(X64Inst, is_st, XXmmLoad{0, 4, U32.mul(k, 4)}, XXmmLoad{0, 6, U32.mul(k, 8)}), acc)))
def x64_emit_v8a_fn(va: V8Arr) -> X64Fn:
  V8Arr{_, +fid, +name, +ar, nregs, _, _, +in_v, _, +out_v, +invs, +fops} = va
  v4_un_ra(X64Fn, b5k_regalloc_v4(IrFn{fid, name, ar, nregs, False{}, False{}, False{}, Con{IrBlock{0, Con{IFlt{in_v, 0}, fops}, TTailCall{fid, Con{0, Con{out_v, invs}}}}, Nil{}}}), rm_ => vd_ => sc_ => ( +rm = rm_; +vd = vd_; +sc = sc_; +frame = x64_align16(U32.add(64, U32.mul(sc, 32))); +in_loc = ra_vec_get(U32, vd, 0, in_v, rm); +out_loc = ra_vec_get(U32, vd, 0, out_v, rm); v4_avx_fn(String.append("$v8a.", x64_fn_sym(name)), frame, a0 => a1 = v8_emit_invs(1, 0, rm, vd, invs, 0, a0); a2 = v4_mem_io(True{}, U32.is_ge(in_loc, 100), 32, 4, in_loc, 0, v8a_lane_io(False{}, 8n, 0, x64_emit(XLabel{1}, a1))); a3 = v8a_lane_io(True{}, 8n, 0, v4_mem_io(False{}, U32.is_ge(out_loc, 100), 32, 4, out_loc, 0, v4_emit_ops(rm, vd, fops, a2))); x64_emit(XXmmRR{14, 0, 0}, x64_emit(XJcc{5, 1}, x64_emit(XAluRI{1, 7, 1}, x64_emit(XAluRI{0, 2, 64}, x64_emit(XAluRI{0, 6, 64}, a3))))))))
def v8a_match_fn_d(+fid: U32, +name: String, +ar: U32, +nregs: U32, +vd: Nat, +blks: List<&2, IrBlock>, ds: X64DefSt) -> V8Arr:
  X64DefSt{c31, _, _, stc, harr, _} = ds
  low_if(V8Arr, Bool.and(stc, harr), _ => v8a_match_b0(fid, name, ar, nregs, vd, c31, blks), _ => v8a_no())
def v8a_match_fn(f: IrFn) -> V8Arr:
  match f:
    case IrFn{+fid, +name, +ar, +nregs, _, False{}, False{}, +blks0}: low_if(V8Arr, Bool.and(U32.is_ge(ar, 4), U32.is_le(ar, 16)), _ => +blks = Bool.pick(List<&2, IrBlock>, U32.is_le(ar, 64), opt_self_tc_blks(fid, ar, blks0), blks0); +vd = ra_vd_of(U32.max(nregs, ar)); v8a_match_fn_d(fid, name, ar, nregs, vd, blks, x64_def_blks(vd, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})), _ => v8a_no())
    case _: v8a_no()
def v8a_scan_one(va: V8Arr, st: V4Scan) -> V4Scan:
  match va st:
    case V8Arr{True{}, fid, name, ar, nregs, ip, ap, av, op, ov, invs, fops} V4Scan{vm, fm, acc}: V4Scan{vm, fm, Con{x64_emit_v8a_fn(V8Arr{True{}, fid, name, ar, nregs, ip, ap, av, op, ov, invs, fops}), acc}}
    case _ _: st
def v8_scan_fns(fns: List<&2, IrFn>, st: V4Scan) -> V4Scan: opt_foldl0(~IrFn, ~V4Scan, ~(+f => s => v8a_scan_one(v8a_match_fn(f), v8r_scan_one(v8r_match_fn(f), v4_scan_one(v4_match_fn(f), s)))), fns, st)
def x64_codegen_o2_sel(small: Bool, +fns: List<&2, IrFn>, fm0: RaVec<String>, heap_off: U32) -> List<&2, X64Fn>:
  match small:
    case True{}: x64_codegen_o2_fin(fns, heap_off, v8_scan_fns(fns, V4Scan{RVEmpty{}, fm0, Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}}}))
    case False{}: b5k_list_rev(X64Fn, x64_lower_all(True{}, False{}, RVEmpty{}, fm0, heap_off, X64R2Scan{RVEmpty{}, RVEmpty{}}, fns, Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}}))
def x64_codegen(is_o2: Bool, prog: IrProg) -> List<&2, X64Fn>:
  match is_o2 prog:
    case True{} IrProg{+fns, _, statics, _, _, _, _, _}: x64_codegen_o2_sel(U32.is_le(b5k_list_len(IrFn, fns), 384), fns, x64_build_fn_map_go(fns, RVEmpty{}), x64_heap_off(statics))
    case False{} IrProg{+fns, _, statics, _, _, _, _, _}: (+fm0 = x64_build_fn_map_go(fns, RVEmpty{}); b5k_list_rev(X64Fn, x64_lower_all(False{}, False{}, RVEmpty{}, fm0, x64_heap_off(statics), X64R2Scan{RVEmpty{}, RVEmpty{}}, fns, Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}})))
def b5k_codegen(prog: IrProg) -> List<&2, X64Fn>: x64_codegen(False{}, prog)
def b5k_codegen_o2(prog: IrProg) -> List<&2, X64Fn>: x64_codegen(True{}, prog)
