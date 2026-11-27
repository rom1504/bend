# bend5k/x64.bend — Direct x86-64 Codegen (-O0 Stack-Slot & -O2 RegAlloc)
# =======================================================================
# Lowers IrProg into typed X64Inst sequences (X64Fn) targeting System V
# AMD64 ABI + P111 ABI v11102 runtime.
#
# Calling convention for `$direct.<name>`:
#   %rdi = P111State *state
#   %rsi, %rdx, %rcx, %r8, %r9 = first 5 Bend args (extra args on stack)
#   %rax = return value
# Stack frame layout (-O0: k=0; -O2: k=len(used_callee)):
#   [rbp - 8 .. rbp - 8*k]             = saved callee-saved regs (rbx, r12..r15)
#   [rbp - 8*(k+1)]                    = saved P111State *state
#   [rbp - 8*(k+2) - 8*slot]           = spill slot (or vreg in -O0)
#   [rsp + 0 .. rsp + 127]             = 16-word scratch array for p111_rt_*

type X64Ha2 is Data:
  X64Ha2{ha: U32, dp: U32, mk: U32, sc: Bool, no_chk: Bool, lbase: U32}
def x64_no_ha2() -> X64Ha2:
  X64Ha2{0, 0, 0, False{}, False{}, 0}
type X64Bor is Data:
  X64Bor{bpm: U32, bm: RaVec<U32>, ha2: X64Ha2}
type X64HMag is Data:
  X64HMag{m0: U32, r0: U32, m1: U32, r1: U32, t0c: U32, t0t: U32, t0e: U32, t0d: Bool, bor: X64Bor}
type X64R2 is Data:
  X64R2{csm: U32, map: RaVec<U32>, cur_fid: U32, cur_r2: U32, u2p: U32, u2o0: U32, u2o1: U32, hmag: X64HMag}
type X64R2Scan is Data:
  X64R2Scan{ret2: RaVec<U32>, u2p: RaVec<U32>}
type X64Meta is Data:
  X64Meta{is_leaf: Bool, hi_used: RaVec<Bool>, is_sc: RaVec<U32>, num_use: RaVec<Bool>, arr_org: RaVec<U32>, ha0: U32, ha0_dp: U32, ha0_mk: U32, ha0_sc: Bool, ha1: U32, ha1_dp: U32, ha1_mk: U32, ha1_sc: Bool, cval: RaVec<U32>, cmat: RaVec<Bool>, r2: X64R2}
def x64_empty_meta() -> X64Meta:
  X64Meta{False{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, 0, 0, 0, False{}, 0, 0, 0, False{}, RVEmpty{}, RVEmpty{}, X64R2{0, RVEmpty{}, 0, 0, 0, 0, 0, X64HMag{0, 0, 0, 0, 0, 0, 0, False{}, X64Bor{0, RVEmpty{}, x64_no_ha2()}}}}
type X64Ctx is Data:
  X64Ctx{is_o2: Bool, reg_map: RaVec<U32>, vd: Nat, spill_base: U32, state_disp: U32, mem_reg: U32, mem_disp: U32, frame: U32, used_callee: List<&2, U32>, heap_off: U32, meta: X64Meta}
def x64_mk_ctx(is_o2: Bool, rm: RaVec<U32>, vd: Nat, sb: U32, sd: U32, mr: U32, md: U32, frame: U32, ce: List<&2, U32>, ho: U32, meta: X64Meta) -> X64Ctx:
  X64Ctx{is_o2, rm, vd, sb, sd, mr, md, frame, ce, ho, meta}
def x64_ctx_vd(ctx: X64Ctx) -> Nat:
  match ctx:
    case X64Ctx{_, _, vd, _, _, _, _, _, _, _, _}: vd
def x64_need_mask32(ctx: X64Ctx, dst: U32) -> Bool:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: True{}
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, hu, _, _, _, _, _, _, _, _, _, _, _, _, _, _}}:
      ra_vec_get(Bool, vd, False{}, dst, hu)
def x64_is_scalar(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, sc, _, _, _, _, _, _, _, _, _, _, _, _, _}}:
      +s = ra_vec_get(U32, vd, 0, v, sc)
      Bool.and(U32.is_ge(s, 1), U32.is_le(s, 2))
    case _: False{}
def x64_is_num_scalar(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, sc, _, _, _, _, _, _, _, _, _, _, _, _, _}}:
      U32.is_eq(ra_vec_get(U32, vd, 0, v, sc), 2)
    case _: False{}
def x64_is_num_use(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, nu, _, _, _, _, _, _, _, _, _, _, _, _}}:
      ra_vec_get(Bool, vd, False{}, v, nu)
    case _: False{}
def x64_all_scalar(+ctx: X64Ctx, vs: List<&2, U32>) -> Bool:
  match vs:
    case Nil{}: True{}
    case Con{v, t}: Bool.and(x64_is_scalar(ctx, v), x64_all_scalar(ctx, t))
def x64_hoist_slot(+is_dp: Bool, ctx: X64Ctx, a: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, ao, +h0, dp0, mk0, _, +h1, dp1, mk1, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{+h2, dp2, mk2, _, _, _}}}}}}:
      +org = ra_vec_get(U32, vd, 0, a, ao)
      v0 = Bool.pick(U32, is_dp, dp0, mk0)
      v1 = Bool.pick(U32, is_dp, dp1, mk1)
      v2 = Bool.pick(U32, is_dp, dp2, mk2)
      r2 = Bool.pick(U32, Bool.and(U32.is_ne(h2, 0), U32.is_eq(org, h2)), v2, 0)
      Bool.pick(U32, Bool.and(U32.is_ne(h0, 0), U32.is_eq(org, h0)), v0, Bool.pick(U32, Bool.and(U32.is_ne(h1, 0), U32.is_eq(org, h1)), v1, r2))
    case _: 0
def x64_hoist_is_sc(ctx: X64Ctx, a: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, ao, +h0, _, _, sc0, +h1, _, _, sc1, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{+h2, _, _, sc2, _, _}}}}}}:
      +org = ra_vec_get(U32, vd, 0, a, ao)
      s2 = Bool.and(Bool.and(U32.is_ne(h2, 0), U32.is_eq(org, h2)), sc2)
      s1 = Bool.or(Bool.and(Bool.and(U32.is_ne(h1, 0), U32.is_eq(org, h1)), sc1), s2)
      Bool.or(Bool.and(Bool.and(U32.is_ne(h0, 0), U32.is_eq(org, h0)), sc0), s1)
    case _: False{}
def x64_no_dp_chk(ctx: X64Ctx) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{_, _, _, _, nc, _}}}}}}: nc
    case _: False{}
def x64_is_cval(+e: U32) -> Bool:
  Bool.and(U32.is_gt(e, 0), U32.is_lt(e, 4294967295))
def x64_const_val(ctx: X64Ctx, consts: RaVec<U32>, +v: U32) -> U32:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: 0
    case X64Ctx{True{}, _, +vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, cv, _, _}}:
      +lc = ra_vec_get(U32, vd, 0, v, consts)
      +gc = ra_vec_get(U32, vd, 0, v, cv)
      Bool.pick(U32, U32.is_ne(lc, 0), lc, Bool.pick(U32, x64_is_cval(gc), gc, 0))
def x64_skip_const(ctx: X64Ctx, +v: U32) -> Bool:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: False{}
    case X64Ctx{True{}, _, +vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, cv, cm, _}}:
      Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, v, cv)), Bool.not(ra_vec_get(Bool, vd, False{}, v, cm)))
def x64_ctx_csm(ctx: X64Ctx) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{csm, _, _, _, _, _, _, _}}}: csm
    case _: 0
def x64_r2_of(ctx: X64Ctx, fid: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, mp, _, _, _, _, _, _}}}: ra_vec_get(U32, 8n, 0, fid, mp)
    case _: 0
def x64_magic_hreg(ctx: X64Ctx, +m: U32) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{m0, +r0, m1, +r1, _, _, _, _, _}}}}:
      Bool.pick(U32, Bool.and(U32.is_ne(r0, 0), U32.is_eq(m, m0)), r0, Bool.pick(U32, Bool.and(U32.is_ne(r1, 0), U32.is_eq(m, m1)), r1, 0))
    case _: 0
def x64_is_bor(ctx: X64Ctx, v: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, vd, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{+bpm, bm, _}}}}}: Bool.and(U32.is_ne(bpm, 0), U32.is_ne(U32.and(ra_vec_get(U32, vd, 0, v, bm), bpm), 0))
    case _: False{}
def x64_u32_nth(xs: List<&2, U32>, n: Nat) -> U32:
  match xs n:
    case Nil{} _: 4294967295
    case Con{h, _} 0n: h
    case Con{_, t} 1n+p: x64_u32_nth(t, p)
def x64_heap_off(statics: List<&2, U32>) -> U32:
  n = b5k_u32_list_len(statics)
  U32.add(51413504, U32.and(U32.add(n, 127), U32.sub(0, 128)))
def x64_arg_reg(+i: U32) -> U32:
  Bool.pick(U32, U32.is_eq(i, 0), 6, Bool.pick(U32, U32.is_eq(i, 1), 2, Bool.pick(U32, U32.is_eq(i, 2), 1, Bool.pick(U32, U32.is_eq(i, 3), 8, 9))))
def x64_o2_arg_reg(+i: U32) -> U32:
  Bool.pick(U32, U32.is_eq(i, 0), 6, Bool.pick(U32, U32.is_eq(i, 1), 2, Bool.pick(U32, U32.is_eq(i, 2), 1, Bool.pick(U32, U32.is_eq(i, 3), 0, 7))))
def x64_cmp_cc(+op: U32) -> U32:
  Bool.pick(U32, U32.is_eq(op, 0), 4, Bool.pick(U32, U32.is_eq(op, 1), 5, Bool.pick(U32, U32.is_eq(op, 2), 2, Bool.pick(U32, U32.is_eq(op, 3), 6, Bool.pick(U32, U32.is_eq(op, 4), 7, 3)))))
def x64_align16(n: U32) -> U32:
  U32.and(U32.add(n, 15), U32.sub(0, 16))
def x64_fn_sym(name: String) -> String:
  String.append("$direct.", name)
def x64_seg_sym(fid: U32) -> String:
  String.append("p111_seg_", b5k_u32_to_str(fid))
def x64_build_fn_map_go(fns: List<&2, IrFn>, m: Map<&2, String>) -> Map<&2, String>:
  match fns:
    case Nil{}: m
    case Con{IrFn{fid, name, _, _, _, _, _, _}, t}:
      x64_build_fn_map_go(t, Map.set(&2, String, m, b5k_u32_to_str(fid), x64_fn_sym(name)))
def x64_snd_str(p: Map<&2, String> & String) -> String:
  (_, sym) = p
  sym
def x64_lookup_fn_sym(fn_map: Map<&2, String>, +fid: U32) -> String:
  x64_snd_str(Map.get(String, x64_fn_sym(b5k_u32_to_str(fid)), fn_map, b5k_u32_to_str(fid)))
def x64_emit(inst: X64Inst, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{inst, acc}
def x64_emit_if(cond: Bool, inst: X64Inst, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match cond:
    case True{}: Con{inst, acc}
    case False{}: acc
def x64_vreg_loc(ctx: X64Ctx, v: U32) -> U32:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _, _}: U32.add(100, v)
    case X64Ctx{True{}, rm, vd, _, _, _, _, _, _, _, _}: ra_vec_get(U32, vd, 0, v, rm)
def x64_spill_disp(ctx: X64Ctx, loc: U32) -> U32:
  match ctx:
    case X64Ctx{_, _, _, sb, _, _, _, _, _, _, _}: U32.sub(0, U32.add(sb, U32.mul(U32.sub(loc, 100), 8)))
def x64_is_o2(ctx: X64Ctx) -> Bool:
  match ctx:
    case X64Ctx{o2, _, _, _, _, _, _, _, _, _, _}: o2
def x64_is_gpr(loc: U32) -> Bool:
  U32.is_lt(loc, 20)
def x64_is_xmm(+loc: U32) -> Bool:
  Bool.and(U32.is_ge(loc, 20), U32.is_lt(loc, 100))
def x64_vreg_io(is_ld: Bool, is_sp: Bool, is_xm: Bool, same: Bool, ctx: X64Ctx, reg: U32, loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp is_xm same:
    case True{} True{} _ _: Con{XLoad{reg, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{} _ _: Con{XStore{5, x64_spill_disp(ctx, loc), reg}, acc}
    case True{} False{} True{} _: Con{XCvt{3, reg, U32.sub(loc, 20)}, acc}
    case False{} False{} True{} _: Con{XCvt{2, U32.sub(loc, 20), reg}, acc}
    case _ False{} False{} True{}: acc
    case True{} False{} False{} False{}: Con{XMovRR{reg, loc}, acc}
    case False{} False{} False{} False{}: Con{XMovRR{loc, reg}, acc}
def x64_load_vreg(+ctx: X64Ctx, +reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_vreg_io(True{}, U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, reg, loc, acc)
def x64_store_vreg(+ctx: X64Ctx, v: U32, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_vreg_io(False{}, U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, reg, loc, acc)
def x64_xmm_io(is_ld: Bool, is_sp: Bool, is_xm: Bool, ctx: X64Ctx, +xmm: U32, +loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp is_xm:
    case True{} True{} _: Con{XXmmLoad{xmm, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{} _: Con{XXmmStore{5, x64_spill_disp(ctx, loc), xmm}, acc}
    case True{} False{} True{}:
      +xr = U32.sub(loc, 20)
      x64_emit_if(U32.is_ne(xr, xmm), XXmmRR{7, xmm, xr}, acc)
    case False{} False{} True{}:
      +xr = U32.sub(loc, 20)
      x64_emit_if(U32.is_ne(xr, xmm), XXmmRR{7, xr, xmm}, acc)
    case True{} False{} False{}: Con{XCvt{2, xmm, loc}, acc}
    case False{} False{} False{}: Con{XCvt{3, loc, xmm}, acc}
def x64_load_xmm(+ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_xmm_io(True{}, U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, xmm, loc, acc)
def x64_store_xmm(+ctx: X64Ctx, v: U32, xmm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_xmm_io(False{}, U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, xmm, loc, acc)
def x64_emit_const_xm(is_z: Bool, +xr: U32, val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_z:
    case True{}: Con{XXmmRR{6, xr, xr}, acc}
    case False{}: Con{XCvt{2, xr, 0}, Con{XMovRI32{0, val}, acc}}
def x64_emit_const_go(is_sp: Bool, is_xm: Bool, ctx: X64Ctx, loc: U32, +val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm:
    case True{} _: Con{XStore{5, x64_spill_disp(ctx, loc), 0}, Con{XMovRI32{0, val}, acc}}
    case False{} True{}: x64_emit_const_xm(U32.is_zero(val), U32.sub(loc, 20), val, acc)
    case False{} False{}: Con{XMovRI32{loc, val}, acc}
def x64_emit_const(+ctx: X64Ctx, dst: U32, val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, dst)
  x64_emit_const_go(U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, loc, val, acc)
def x64_emit_copy_sp(src_sp: Bool, src_xm: Bool, +ctx: X64Ctx, dloc: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match src_sp src_xm:
    case True{} _: Con{XStore{5, x64_spill_disp(ctx, dloc), 0}, Con{XLoad{0, 5, x64_spill_disp(ctx, sloc)}, acc}}
    case False{} True{}: Con{XXmmStore{5, x64_spill_disp(ctx, dloc), U32.sub(sloc, 20)}, acc}
    case False{} False{}: Con{XStore{5, x64_spill_disp(ctx, dloc), sloc}, acc}
def x64_emit_copy_go(same: Bool, dst_sp: Bool, dst_xm: Bool, +ctx: X64Ctx, dloc: U32, +sloc: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match same dst_sp dst_xm:
    case True{} _ _: acc
    case False{} True{} _: x64_emit_copy_sp(U32.is_ge(sloc, 100), x64_is_xmm(sloc), ctx, dloc, sloc, acc)
    case False{} False{} True{}: x64_load_xmm(ctx, U32.sub(dloc, 20), src, acc)
    case False{} False{} False{}: x64_load_vreg(ctx, dloc, src, acc)
def x64_emit_copy(+ctx: X64Ctx, dst: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +dloc = x64_vreg_loc(ctx, dst)
  +sloc = x64_vreg_loc(ctx, src)
  x64_emit_copy_go(U32.is_eq(dloc, sloc), U32.is_ge(dloc, 100), x64_is_xmm(dloc), ctx, dloc, sloc, src, acc)
def x64_load_state(ctx: X64Ctx, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, sd, _, _, _, _, _, _}: Con{XLoad{reg, 5, sd}, acc}
def x64_load_mem_go(has_r: Bool, has_d: Bool, mr: U32, md: U32, sd: U32, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r has_d:
    case True{} _: Con{XMovRR{reg, mr}, acc}
    case False{} True{}: Con{XLoad{reg, 5, md}, acc}
    case False{} False{}: Con{XLoad{reg, reg, 0}, Con{XLoad{reg, 5, sd}, acc}}
def x64_load_mem(ctx: X64Ctx, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, sd, +mr, +md, _, _, _, _}:
      x64_load_mem_go(U32.is_ne(mr, 0), U32.is_ne(md, 0), mr, md, sd, reg, acc)
def x64_store_scratch_go(+ctx: X64Ctx, vs: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match vs:
    case Nil{}: acc
    case Con{v, t}:
      a1 = x64_load_vreg(ctx, 0, v, acc)
      x64_store_scratch_go(ctx, t, U32.add(idx, 1), x64_emit(XStore{4, U32.mul(idx, 8), 0}, a1))
def x64_load_scratch_go(+ctx: X64Ctx, dsts: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Nil{}: acc
    case Con{d, t}:
      a1 = x64_emit(XLoad{0, 4, U32.mul(idx, 8)}, acc)
      x64_load_scratch_go(ctx, t, U32.add(idx, 1), x64_store_vreg(ctx, d, 0, a1))
def x64_save_param_one(+ctx: X64Ctx, in_reg: Bool, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match in_reg:
    case True{}:
      src_r = Bool.pick(U32, x64_is_o2(ctx), x64_o2_arg_reg(idx), x64_arg_reg(idx))
      x64_store_vreg(ctx, idx, src_r, acc)
    case False{}:
      off = U32.add(16, U32.mul(U32.sub(idx, 5), 8))
      x64_store_vreg(ctx, idx, 0, Con{XLoad{0, 5, off}, acc})
def x64_save_params_go(+ctx: X64Ctx, n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      a1 = x64_save_param_one(ctx, U32.is_lt(idx, 5), idx, acc)
      x64_save_params_go(ctx, p, U32.add(idx, 1), a1)
def x64_drop_u32(n: Nat, xs: List<&2, U32>) -> List<&2, U32>:
  match n xs:
    case 0n ys: ys
    case 1n+p Nil{}: Nil{}
    case 1n+p Con{_, t}: x64_drop_u32(p, t)
def x64_push_extra_args(+ctx: X64Ctx, rev_extra: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match rev_extra:
    case Nil{}: acc
    case Con{v, t}:
      a1 = x64_load_vreg(ctx, 0, v, acc)
      x64_push_extra_args(ctx, t, Con{XPush{0}, a1})
def x64_load_reg_args(+ctx: X64Ctx, args: List<&2, U32>, +idx: U32, in_reg: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args in_reg:
    case Nil{} _: acc
    case _ False{}: acc
    case Con{v, t} True{}:
      +nxt = U32.add(idx, 1)
      dst_r = Bool.pick(U32, x64_is_o2(ctx), x64_o2_arg_reg(idx), x64_arg_reg(idx))
      x64_load_reg_args(ctx, t, nxt, U32.is_lt(nxt, 5), x64_load_vreg(ctx, dst_r, v, acc))
def x64_finish_o2_call_args(is_o2: Bool, +nargs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_o2:
    case False{}: acc
    case True{}: x64_emit_if(U32.is_ge(nargs, 5), XMovRR{9, 7}, x64_emit_if(U32.is_ge(nargs, 4), XMovRR{8, 0}, acc))
def x64_emit_call_go(+ctx: X64Ctx, has_extra: Bool, +nargs: U32, sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_extra:
    case False{}:
      a1 = x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, acc))
      Con{XCallSym{sym}, x64_load_state(ctx, 7, a1)}
    case True{}:
      +extra_cnt = U32.sub(nargs, 5)
      +odd = U32.is_eq(U32.and(extra_cnt, 1), 1)
      a1 = x64_push_extra_args(ctx, b5k_list_rev(U32, x64_drop_u32(5n, args)), x64_emit_if(odd, XSubRsp{8}, acc))
      a2 = x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, a1))
      Con{XAddRsp{U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, x64_load_state(ctx, 7, a2))}
def x64_emit_call(ctx: X64Ctx, sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +nargs = b5k_u32_list_len(args)
  x64_emit_call_go(ctx, U32.is_gt(nargs, 5), nargs, sym, args, acc)
def x64_mask32(+reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XShift{9, reg, 32, False{}}, Con{XShift{8, reg, 32, False{}}, acc}}
def x64_opt_mask32(need: Bool, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match need:
    case True{}: x64_mask32(reg, acc)
    case False{}: acc
def x64_bin_alu(m32: Bool, +op: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case 2: x64_opt_mask32(m32, 0, Con{XMul{0, 1}, acc})
    case 3:
      a2 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, x64_emit(XMovRI32{0, 0}, x64_emit(XMovRR{2, 0}, acc))))
      x64_emit(XLabel{lbl}, x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, x64_emit(XMovRR{0, 2}, a2))))
    case 4:
      a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, acc))
      x64_mask32(0, x64_emit(XLabel{lbl}, x64_emit(XMovRR{0, 2}, x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, a1)))))
    case 8: x64_opt_mask32(m32, 0, Con{XShift{8, 0, 0, True{}}, acc})
    case 9: Con{XShift{9, 0, 0, True{}}, acc}
    case _: x64_opt_mask32(Bool.and(m32, U32.is_le(op, 1)), 0, Con{XAluRR{op, 0, 1}, acc})
def x64_is_simple_alu(+op: U32) -> Bool:
  Bool.or(U32.is_le(op, 1), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))
def x64_is_comm_alu(+op: U32) -> Bool:
  Bool.or(U32.is_zero(op), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))
def x64_load_xmm_c_go(hit: Bool, ctx: X64Ctx, +xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hit:
    case True{}: x64_emit_if(U32.is_ne(xmm, 0), XXmmRR{7, xmm, 0}, acc)
    case False{}: x64_load_xmm(ctx, xmm, v, acc)
def x64_load_xmm_c(ctx: X64Ctx, xmm: U32, +v: U32, xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_load_xmm_c_go(U32.is_eq(xm0, U32.add(v, 1)), ctx, xmm, v, acc)
def x64_fbin_rhs_xmm(rxm: Bool, r_in0: Bool, ctx: X64Ctx, fop: U32, dx: U32, rhs: U32, rloc: U32, a1: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match rxm r_in0:
    case True{} _: x64_emit(XXmmRR{fop, dx, U32.sub(rloc, 20)}, a1)
    case False{} True{}: x64_emit(XXmmRR{fop, dx, 0}, a1)
    case False{} False{}: x64_emit(XXmmRR{fop, dx, 1}, x64_load_xmm(ctx, 1, rhs, a1))
def x64_fbin_dst_eq_rhs(comm: Bool, lxm: Bool, ctx: X64Ctx, fop: U32, +dx: U32, lhs: U32, lloc: U32, xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match comm lxm:
    case True{} True{}: x64_emit(XXmmRR{fop, dx, U32.sub(lloc, 20)}, acc)
    case True{} False{}: x64_emit(XXmmRR{fop, dx, 1}, x64_load_xmm_c(ctx, 1, lhs, xm0, acc))
    case False{} _:
      a1 = x64_emit(XXmmRR{fop, 0, dx}, x64_load_xmm_c(ctx, 0, lhs, xm0, acc))
      x64_emit(XXmmRR{7, dx, 0}, a1)
def x64_fbin_dxmm(eq_lr: Bool, ne_dr: Bool, comm: Bool, +ctx: X64Ctx, +fop: U32, +dx: U32, lhs: U32, +rhs: U32, +lloc: U32, +rloc: U32, +xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq_lr ne_dr:
    case True{} _: x64_emit(XXmmRR{fop, dx, dx}, x64_load_xmm_c(ctx, dx, lhs, xm0, acc))
    case False{} True{}:
      a1 = x64_load_xmm_c(ctx, dx, lhs, xm0, acc)
      x64_fbin_rhs_xmm(x64_is_xmm(rloc), U32.is_eq(xm0, U32.add(rhs, 1)), ctx, fop, dx, rhs, rloc, a1)
    case False{} False{}: x64_fbin_dst_eq_rhs(comm, x64_is_xmm(lloc), ctx, fop, dx, lhs, lloc, xm0, acc)
def x64_fbin_spill_fin(skip_st: Bool, ctx: X64Ctx, dst: U32, a2: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip_st:
    case True{}: a2
    case False{}: x64_store_xmm(ctx, dst, 0, a2)
def x64_fbin_spill(skip_st: Bool, eq_lr: Bool, rxm: Bool, +ctx: X64Ctx, dst: U32, fop: U32, lhs: U32, rhs: U32, rloc: U32, +xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq_lr rxm:
    case True{} _: x64_fbin_spill_fin(skip_st, ctx, dst, x64_emit(XXmmRR{fop, 0, 0}, x64_load_xmm_c(ctx, 0, lhs, xm0, acc)))
    case False{} True{}: x64_fbin_spill_fin(skip_st, ctx, dst, x64_emit(XXmmRR{fop, 0, U32.sub(rloc, 20)}, x64_load_xmm_c(ctx, 0, lhs, xm0, acc)))
    case False{} False{}:
      a1 = x64_load_xmm_c(ctx, 0, lhs, xm0, x64_load_xmm_c(ctx, 1, rhs, xm0, acc))
      x64_fbin_spill_fin(skip_st, ctx, dst, x64_emit(XXmmRR{fop, 0, 1}, a1))
def x64_emit_fbin_go(dxm: Bool, skip_st: Bool, +ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dxm:
    case True{}:
      fop = U32.sub(op, 10)
      comm = Bool.or(U32.is_eq(op, 10), U32.is_eq(op, 12))
      x64_fbin_dxmm(U32.is_eq(lloc, rloc), U32.is_ne(dloc, rloc), comm, ctx, fop, U32.sub(dloc, 20), lhs, rhs, lloc, rloc, xm0, acc)
    case False{}: x64_fbin_spill(skip_st, U32.is_eq(lloc, rloc), x64_is_xmm(rloc), ctx, dst, U32.sub(op, 10), lhs, rhs, rloc, xm0, acc)
def x64_opt_load_vreg(skip: Bool, ctx: X64Ctx, reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_load_vreg(ctx, reg, v, acc)
def x64_ibin_sp_fin(dir_r: Bool, +ctx: X64Ctx, +dst: U32, +op: U32, +rloc: U32, lbl: U32, a1: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dir_r:
    case True{}: x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_le(op, 2)), 0, x64_emit(Bool.pick(X64Inst, U32.is_eq(op, 2), XMul{0, rloc}, XAluRR{op, 0, rloc}), a1))
    case False{}: x64_bin_alu(x64_need_mask32(ctx, dst), op, lbl, a1)
def x64_ibin_reg_go(is_alu: Bool, is_mul: Bool, is_comm_eq: Bool, +ctx: X64Ctx, +dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, lloc: U32, +rloc: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_alu is_mul is_comm_eq:
    case True{} _ _:
      +rg = x64_is_gpr(rloc)
      +rreg = Bool.pick(U32, rg, rloc, 1)
      a1 = x64_opt_load_vreg(rg, ctx, 1, rhs, x64_load_vreg(ctx, dloc, lhs, acc))
      x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_le(op, 1)), dloc, x64_emit(XAluRR{op, dloc, rreg}, a1))
    case False{} True{} _:
      +rg = x64_is_gpr(rloc)
      +rreg = Bool.pick(U32, rg, rloc, 1)
      a1 = x64_opt_load_vreg(rg, ctx, 1, rhs, x64_load_vreg(ctx, dloc, lhs, acc))
      x64_opt_mask32(x64_need_mask32(ctx, dst), dloc, x64_emit(XMul{dloc, rreg}, a1))
    case False{} False{} True{}:
      x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_zero(op)), dloc, x64_emit(XAluRR{op, dloc, lloc}, acc))
    case False{} False{} False{}:
      +dir_r = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(rloc), Bool.or(x64_is_simple_alu(op), U32.is_eq(op, 2))))
      a1 = x64_opt_load_vreg(dir_r, ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
      x64_store_vreg(ctx, dst, 0, x64_ibin_sp_fin(dir_r, ctx, dst, op, rloc, lbl, a1))

def x64_fdiv_bits(+a0: U32, +b0: U32) -> U32:
  opt_fdiv_bits(a0, b0)
type X64Mag is Data:
  X64Mag{m: U32, s: U32, add1: Bool}
def x64_magic_loop(n: Nat, +d: U32, +rem: U32, +q: U32) -> X64Mag:
  match n:
    case 0n: X64Mag{q, rem, False{}}
    case 1n+p:
      +r2 = U32.shln(rem, 1n)
      +ge = U32.is_ge(r2, d)
      x64_magic_loop(p, d, Bool.pick(U32, ge, U32.sub(r2, d), r2), Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n)))
def x64_magic_fin(st: X64Mag, +d: U32, +k: U32) -> X64Mag:
  match st:
    case X64Mag{+q, +rem, _}:
      +ok = U32.is_le(U32.sub(d, rem), U32.shln(1, U32.to_nat(k)))
      +ge = U32.is_ge(U32.shln(rem, 1n), d)
      ql = Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n))
      Bool.pick(X64Mag, ok, X64Mag{U32.add(q, 1), U32.add(32, k), False{}}, X64Mag{U32.add(ql, 1), U32.add(k, 1), True{}})
def x64_magic(+d: U32) -> X64Mag:
  +k = U32.from_nat(U32.log2(d))
  x64_magic_fin(x64_magic_loop(32n, d, U32.shln(1, U32.to_nat(k)), 0), d, k)
def x64_is_pow2(+c: U32) -> Bool:
  Bool.and(U32.is_gt(c, 0), U32.is_zero(U32.and(c, U32.sub(c, 1))))
def x64_is_mul_sr(+c: U32) -> Bool:
  Bool.or(U32.is_le(c, 1), Bool.or(x64_is_pow2(c), Bool.or(U32.is_eq(c, 3), Bool.or(U32.is_eq(c, 5), Bool.or(U32.is_eq(c, 9), U32.is_eq(c, 10))))))
def x64_emit_mul_c(+reg: U32, +tmp: U32, +c: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +cm1 = U32.sub(c, 1)
  Bool.pick(List<&2, X64Inst>, Bool.and(U32.is_ge(c, 3), x64_is_pow2(cm1)),
    x64_emit(XAluRR{0, reg, tmp}, x64_emit(XShift{8, reg, U32.from_nat(U32.log2(cm1)), False{}}, x64_emit(XMovRR{tmp, reg}, acc))),
    x64_emit(XMul{reg, tmp}, x64_emit(XMovRI32{tmp, c}, acc)))
def x64_emit_mul_sr_sh(dir: Bool, +ctx: X64Ctx, +dst: U32, lhs: U32, +dreg: U32, +lloc: U32, k: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dir:
    case True{}: x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(XAluRR{0, dreg, lloc}, x64_emit(XShift{8, dreg, k, False{}}, x64_emit(XMovRR{dreg, lloc}, acc)))))
    case False{}:
      +tmp = Bool.pick(U32, U32.is_zero(dreg), 1, 0)
      x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(XAluRR{0, dreg, tmp}, x64_emit(XShift{8, dreg, k, False{}}, x64_emit(XMovRR{tmp, dreg}, x64_load_vreg(ctx, dreg, lhs, acc))))))
def x64_emit_mul_sr_go(+ctx: X64Ctx, +dst: U32, +lhs: U32, +dreg: U32, +lloc: U32, +c: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match c:
    case 0: x64_emit_const(ctx, dst, 0, acc)
    case 1: x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_load_vreg(ctx, dreg, lhs, acc)))
    case 3: x64_emit_mul_sr_sh(Bool.and(x64_is_gpr(lloc), U32.is_ne(dreg, lloc)), ctx, dst, lhs, dreg, lloc, 1, acc)
    case 5: x64_emit_mul_sr_sh(Bool.and(x64_is_gpr(lloc), U32.is_ne(dreg, lloc)), ctx, dst, lhs, dreg, lloc, 2, acc)
    case 9: x64_emit_mul_sr_sh(Bool.and(x64_is_gpr(lloc), U32.is_ne(dreg, lloc)), ctx, dst, lhs, dreg, lloc, 3, acc)
    case 10:
      +tmp = Bool.pick(U32, U32.is_zero(dreg), 1, 0)
      +dir = Bool.and(x64_is_gpr(lloc), U32.is_ne(dreg, lloc))
      a1 = Bool.pick(List<&2, X64Inst>, dir,
        x64_emit(XShift{8, dreg, 1, False{}}, x64_emit(XAluRR{0, dreg, lloc}, x64_emit(XShift{8, dreg, 2, False{}}, x64_emit(XMovRR{dreg, lloc}, acc)))),
        x64_emit(XShift{8, dreg, 1, False{}}, x64_emit(XAluRR{0, dreg, tmp}, x64_emit(XShift{8, dreg, 2, False{}}, x64_emit(XMovRR{tmp, dreg}, x64_load_vreg(ctx, dreg, lhs, acc))))))
      x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, a1))
    case _: x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, x64_emit(XShift{8, dreg, U32.from_nat(U32.log2(c)), False{}}, x64_load_vreg(ctx, dreg, lhs, acc))))
def x64_emit_mul_sr(+ctx: X64Ctx, dst: U32, lhs: U32, +dloc: U32, lloc: U32, c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit_mul_sr_go(ctx, dst, lhs, Bool.pick(U32, x64_is_gpr(dloc), dloc, 0), lloc, c, acc)
def x64_emit_divmod_pow2(is_div: Bool, +ctx: X64Ctx, dst: U32, lhs: U32, +dloc: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
  x64_store_vreg(ctx, dst, dreg, x64_emit(Bool.pick(X64Inst, is_div, XShift{9, dreg, U32.from_nat(U32.log2(c)), False{}}, XAluRI{5, dreg, U32.sub(c, 1)}), x64_load_vreg(ctx, dreg, lhs, acc)))
def x64_emit_magic_mul(has_r: Bool, mr: U32, m: U32, a0: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r:
    case True{}: x64_emit(XMul{0, mr}, a0)
    case False{}: x64_emit(XMul{0, 1}, x64_emit(XMovRI32{1, m}, a0))
def x64_emit_divmod_magic_q(add1: Bool, +mr: U32, m: U32, s: U32, a0: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match add1:
    case False{}: x64_emit(XShift{9, 0, s, False{}}, x64_emit_magic_mul(U32.is_ne(mr, 0), mr, m, a0))
    case True{}: x64_emit(XShift{9, 0, s, False{}}, x64_emit(XAluRR{0, 0, 2}, x64_emit(XShift{9, 0, 32, False{}}, x64_emit_magic_mul(U32.is_ne(mr, 0), mr, m, x64_emit(XMovRR{2, 0}, a0)))))
def x64_emit_divmod_magic(is_mod: Bool, +ctx: X64Ctx, +dst: U32, +lhs: U32, +c: U32, mg: X64Mag, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_mod mg:
    case False{} X64Mag{+m, s, add1}: x64_store_vreg(ctx, dst, 0, x64_emit_divmod_magic_q(add1, x64_magic_hreg(ctx, m), m, s, x64_load_vreg(ctx, 0, lhs, acc)))
    case True{} X64Mag{+m, s, add1}:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 2)
      a2 = x64_emit_mul_c(0, 1, c, x64_emit_divmod_magic_q(add1, x64_magic_hreg(ctx, m), m, s, x64_load_vreg(ctx, 0, lhs, acc)))
      x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRR{1, dreg, 0}, x64_load_vreg(ctx, dreg, lhs, a2)))
def x64_emit_ibin_dm(is_sr: Bool, is_p2: Bool, is_mag: Bool, +ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, +c: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sr is_p2 is_mag:
    case True{} _ _: x64_emit_mul_sr(ctx, dst, lhs, dloc, lloc, c, acc)
    case False{} True{} _: x64_emit_divmod_pow2(U32.is_eq(op, 3), ctx, dst, lhs, dloc, c, acc)
    case False{} False{} True{}: x64_emit_divmod_magic(U32.is_eq(op, 4), ctx, dst, lhs, c, x64_magic(c), acc)
    case False{} False{} False{}:
      +dg_ok = Bool.and(x64_is_o2(ctx), x64_is_gpr(dloc))
      +ne_dr = U32.is_ne(dloc, rloc)
      is_alu = Bool.and(Bool.and(dg_ok, ne_dr), x64_is_simple_alu(op))
      is_mul = Bool.and(Bool.and(dg_ok, ne_dr), U32.is_eq(op, 2))
      is_ceq = Bool.and(Bool.and(dg_ok, Bool.and(x64_is_gpr(rloc), Bool.not(ne_dr))), Bool.and(x64_is_comm_alu(op), x64_is_gpr(lloc)))
      x64_ibin_reg_go(is_alu, is_mul, is_ceq, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, lbl, acc)
def x64_emit_ibin_imm(imm_alu: Bool, imm_sh: Bool, +ctx: X64Ctx, +dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, +has_rc: Bool, +c: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match imm_alu imm_sh:
    case True{} _:
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_load_vreg(ctx, dreg, lhs, acc)
      x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_le(op, 1)), dreg, x64_emit(XAluRI{op, dreg, c}, a1)))
    case False{} True{}:
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_load_vreg(ctx, dreg, lhs, acc)
      x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(Bool.and(x64_need_mask32(ctx, dst), U32.is_eq(op, 8)), dreg, x64_emit(XShift{op, dreg, c, False{}}, a1)))
    case False{} False{}:
      is_sr = Bool.and(has_rc, Bool.and(U32.is_eq(op, 2), x64_is_mul_sr(c)))
      +is_dm = Bool.and(has_rc, Bool.or(U32.is_eq(op, 3), U32.is_eq(op, 4)))
      +is_p2 = Bool.and(is_dm, x64_is_pow2(c))
      is_mag = Bool.and(is_dm, Bool.and(U32.is_ge(c, 3), Bool.not(is_p2)))
      x64_emit_ibin_dm(is_sr, is_p2, is_mag, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, c, lbl, acc)
def x64_emit_fdiv_fold(fold: Bool, skip_st: Bool, +ctx: X64Ctx, dst: U32, op: U32, lhs: U32, rhs: U32, +dloc: U32, lloc: U32, rloc: U32, la: U32, rb: U32, xm0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fold:
    case True{}: x64_emit_const(ctx, dst, x64_fdiv_bits(U32.sub(la, 1), U32.sub(rb, 1)), acc)
    case False{}: x64_emit_fbin_go(x64_is_xmm(dloc), skip_st, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, xm0, acc)
def x64_emit_bin_go(+ctx: X64Ctx, is_flt: Bool, skip_st: Bool, consts: RaVec<U32>, +fconsts: RaVec<U32>, xm0: U32, +dst: U32, +op: U32, +lhs: U32, +rhs: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_flt:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +la = Bool.pick(U32, Bool.and(x64_is_o2(ctx), U32.is_eq(op, 13)), ra_vec_get(U32, x64_ctx_vd(ctx), 0, lhs, fconsts), 0)
      +rb = Bool.pick(U32, U32.is_ne(la, 0), ra_vec_get(U32, x64_ctx_vd(ctx), 0, rhs, fconsts), 0)
      x64_emit_fdiv_fold(U32.is_ne(rb, 0), skip_st, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, la, rb, xm0, acc)
    case False{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +rc = x64_const_val(ctx, consts, rhs)
      +has_rc = U32.is_ne(rc, 0)
      +c = U32.sub(rc, 1)
      imm_alu = Bool.and(has_rc, x64_is_simple_alu(op))
      imm_sh = Bool.and(has_rc, Bool.and(U32.is_ge(op, 8), U32.is_lt(c, 64)))
      x64_emit_ibin_imm(imm_alu, imm_sh, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, has_rc, c, lbl, acc)
def x64_u2f_go(dxm: Bool, sgpr: Bool, +ctx: X64Ctx, dst: U32, src: U32, dloc: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dxm sgpr:
    case True{} True{}: x64_emit(XCvt{0, U32.sub(dloc, 20), sloc}, acc)
    case True{} False{}: x64_emit(XCvt{0, U32.sub(dloc, 20), 0}, x64_load_vreg(ctx, 0, src, acc))
    case False{} True{}: x64_store_xmm(ctx, dst, 0, x64_emit(XCvt{0, 0, sloc}, acc))
    case False{} False{}: x64_store_xmm(ctx, dst, 0, x64_emit(XCvt{0, 0, 0}, x64_load_vreg(ctx, 0, src, acc)))
def x64_u2f_const(fold: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fold:
    case True{}: x64_emit_const(ctx, dst, Bool.pick(U32, U32.is_zero(c), 0, x64_fdiv_bits(c, 1)), acc)
    case False{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_u2f_go(x64_is_xmm(dloc), x64_is_gpr(sloc), ctx, dst, src, dloc, sloc, acc)
def x64_emit_f2u_sqrt(is_sq: Bool, direct: Bool, +ctx: X64Ctx, dst: U32, src: U32, dloc: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sq direct:
    case True{} True{}: x64_emit(XXmmRR{4, U32.sub(dloc, 20), U32.sub(sloc, 20)}, acc)
    case True{} False{}: x64_store_xmm(ctx, dst, 0, x64_emit(XXmmRR{4, 0, 0}, x64_load_xmm(ctx, 0, src, acc)))
    case False{} True{}: x64_store_vreg(ctx, dst, 0, x64_mask32(0, x64_emit(XCvt{1, 0, U32.sub(sloc, 20)}, acc)))
    case False{} False{}: x64_store_vreg(ctx, dst, 0, x64_mask32(0, x64_emit(XCvt{1, 0, 0}, x64_load_xmm(ctx, 0, src, acc))))
def x64_emit_un(+ctx: X64Ctx, consts: RaVec<U32>, +dst: U32, uop: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match uop:
    case 0:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_emit(XMovRR{dreg, 1}, x64_emit(XAluRR{1, 1, dreg}, x64_emit(XMovRI32{1, 0}, x64_load_vreg(ctx, dreg, src, acc))))
      x64_store_vreg(ctx, dst, dreg, x64_opt_mask32(x64_need_mask32(ctx, dst), dreg, a1))
    case 1:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      x64_store_vreg(ctx, dst, dreg, x64_mask32(dreg, x64_emit(XAluRI{7, dreg, 4294967295}, x64_load_vreg(ctx, dreg, src, acc))))
    case 2:
      x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{7, 0, 1}, x64_emit(XMovRI32{1, 2147483648}, x64_load_vreg(ctx, 0, src, acc))))
    case 3:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_emit_f2u_sqrt(True{}, Bool.and(x64_is_xmm(dloc), x64_is_xmm(sloc)), ctx, dst, src, dloc, sloc, acc)
    case 4:
      +rc = x64_const_val(ctx, consts, src)
      +c = U32.sub(rc, 1)
      x64_u2f_const(Bool.and(U32.is_ne(rc, 0), U32.is_le(c, 65535)), ctx, dst, src, c, acc)
    case _:
      +sloc = x64_vreg_loc(ctx, src)
      x64_emit_f2u_sqrt(False{}, x64_is_xmm(sloc), ctx, dst, src, 0, sloc, acc)
def x64_emit_fcmp(+fop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fop:
    case 0: x64_emit(XAluRR{5, 0, 1}, x64_emit(XSetcc{11, 1}, x64_emit(XSetcc{4, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc)))))
    case 1: x64_emit(XAluRR{6, 0, 1}, x64_emit(XSetcc{10, 1}, x64_emit(XSetcc{5, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc)))))
    case _: x64_emit(XSetcc{Bool.pick(U32, Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 4)), 7, 3), 0}, x64_emit(XMovRI32{0, 0}, acc))
def x64_emit_icmp_go(has_c: Bool, direct: Bool, +ctx: X64Ctx, +dst: U32, +cop: U32, lhs: U32, rhs: U32, +lloc: U32, rloc: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_c direct:
    case True{} _:
      +lreg = Bool.pick(U32, x64_is_gpr(lloc), lloc, 0)
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_emit(Bool.pick(X64Inst, Bool.and(U32.is_zero(c), U32.is_le(cop, 1)), XTestRR{lreg, lreg}, XCmpRI{lreg, c}), x64_load_vreg(ctx, lreg, lhs, acc))
      x64_store_vreg(ctx, dst, dreg, x64_emit(XSetcc{x64_cmp_cc(cop), dreg}, x64_emit(XMovRI32{dreg, 0}, a1)))
    case False{} True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      x64_store_vreg(ctx, dst, dreg, x64_emit(XSetcc{x64_cmp_cc(cop), dreg}, x64_emit(XMovRI32{dreg, 0}, x64_emit(XCmpRR{lloc, rloc}, acc))))
    case False{} False{}:
      a1 = x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
      x64_store_vreg(ctx, dst, 0, x64_emit(XSetcc{x64_cmp_cc(cop), 0}, x64_emit(XMovRI32{0, 0}, x64_emit(XCmpRR{0, 1}, a1))))
def x64_opt_load_xmm(skip: Bool, ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_load_xmm(ctx, xmm, v, acc)
def x64_emit_cmp_go(+ctx: X64Ctx, consts: RaVec<U32>, is_flt: Bool, dst: U32, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_flt:
    case True{}:
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +fop = U32.sub(cop, 6)
      +swap = Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 3))
      +lxm = x64_is_xmm(lloc)
      +rxm = x64_is_xmm(rloc)
      +lx = Bool.pick(U32, lxm, U32.sub(lloc, 20), 0)
      +rx = Bool.pick(U32, rxm, U32.sub(rloc, 20), 1)
      a1 = x64_opt_load_xmm(rxm, ctx, 1, rhs, x64_opt_load_xmm(lxm, ctx, 0, lhs, acc))
      a2 = x64_emit(XXmmRR{5, Bool.pick(U32, swap, rx, lx), Bool.pick(U32, swap, lx, rx)}, a1)
      x64_store_vreg(ctx, dst, 0, x64_emit_fcmp(fop, a2))
    case False{}:
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +rc = x64_const_val(ctx, consts, rhs)
      dir = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc)))
      x64_emit_icmp_go(U32.is_ne(rc, 0), dir, ctx, dst, cop, lhs, rhs, lloc, rloc, U32.sub(rc, 1), acc)
def x64_cls_fit(+cnt: U32) -> U32:
  Bool.pick(U32, U32.is_le(cnt, 1), 0, Bool.pick(U32, U32.is_eq(cnt, 2), 1, Bool.pick(U32, U32.is_le(cnt, 4), 2, 3)))
def x64_cls_step(+cls: U32) -> U32:
  Bool.pick(U32, U32.is_zero(cls), 1, Bool.pick(U32, U32.is_eq(cls, 1), 2, Bool.pick(U32, U32.is_eq(cls, 2), 4, 8)))
def x64_is_cs_reg(+r: U32) -> Bool:
  Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11))
def x64_inval_cs_hoist(ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, +h0, +dp0, +mk0, _, +h1, +dp1, +mk1, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{+h2, +dp2, +mk2, _, False{}, _}}}}}}:
      +inv0 = Bool.and(U32.is_ne(h0, 0), Bool.or(x64_is_cs_reg(dp0), x64_is_cs_reg(mk0)))
      +inv1 = Bool.and(U32.is_ne(h1, 0), Bool.or(x64_is_cs_reg(dp1), x64_is_cs_reg(mk1)))
      +inv2 = Bool.and(U32.is_ne(h2, 0), Bool.or(x64_is_cs_reg(dp2), x64_is_cs_reg(mk2)))
      x64_emit_if(inv2, XAluRR{7, dp2, dp2}, x64_emit_if(inv1, XAluRR{7, dp1, dp1}, x64_emit_if(inv0, XAluRR{7, dp0, dp0}, acc)))
    case _: acc
def x64_push_cs4(csm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match csm:
    case 0: acc
    case 1: x64_emit(XPush{9}, x64_emit(XPush{8}, acc))
    case 2: x64_emit(XPush{11}, x64_emit(XPush{10}, acc))
    case _: x64_emit(XPush{11}, x64_emit(XPush{10}, x64_emit(XPush{9}, x64_emit(XPush{8}, acc))))
def x64_pop_cs4(csm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match csm:
    case 0: acc
    case 1: x64_emit(XPop{8}, x64_emit(XPop{9}, acc))
    case 2: x64_emit(XPop{10}, x64_emit(XPop{11}, acc))
    case _: x64_emit(XPop{8}, x64_emit(XPop{9}, x64_emit(XPop{10}, x64_emit(XPop{11}, acc))))
def x64_mem_idx_ptr_go(has_r: Bool, ctx: X64Ctx, mr: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r:
    case True{}: x64_emit(XAluRR{0, 7, mr}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, acc)))
    case False{}: x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, x64_load_mem(ctx, 1, acc))))
def x64_mem_idx_ptr(+ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, +mr, _, _, _, _, _}:
      x64_mem_idx_ptr_go(U32.is_ne(mr, 0), ctx, mr, acc)
def x64_ctor_slow(+ctx: X64Ctx, cid: U32, fields: List<&2, U32>, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, fields, 0, acc))
  a2 = x64_push_cs4(csm, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, cid}, a1))))
  x64_inval_cs_hoist(ctx, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_ctor"}, a2)))

type X64Acc is Data:
  X64Acc{insts: List<&2, X64Inst>, next_lbl: U32, cold: List<&2, X64Inst>}
def x64_ctor_store_raw_one(is_g: Bool, ctx: X64Ctx, f: U32, floc: U32, off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_g:
    case True{}: x64_emit(XStore{7, off, floc}, acc)
    case False{}: x64_emit(XStore{7, off, 0}, x64_load_vreg(ctx, 0, f, acc))
def x64_ctor_store_raw(+ctx: X64Ctx, fields: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match fields:
    case Nil{}: acc
    case Con{+f, t}:
      +floc = x64_vreg_loc(ctx, f)
      x64_ctor_store_raw(ctx, t, U32.add(idx, 1), x64_ctor_store_raw_one(x64_is_gpr(floc), ctx, f, floc, U32.mul(idx, 8), acc))
def x64_ctor_store_fields(+ctx: X64Ctx, fields: List<&2, U32>, +idx: U32, st: X64Acc) -> X64Acc:
  match fields st:
    case Nil{} _: st
    case Con{f, t} X64Acc{acc, +lbl, cold}:
      a0 = x64_load_vreg(ctx, 0, f, acc)
      a1 = x64_emit(XJcc{5, lbl}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, a0))))
      a2 = x64_emit(XLoad{2, 6, 0}, x64_emit(XStore{4, 8, 7}, x64_emit(XStore{4, 0, 2}, a1)))
      a3 = x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XMovRR{7, 2}, x64_load_mem(ctx, 1, a2))))
      a4 = x64_emit(XStore{6, 0, 1}, x64_emit(XLoad{1, 7, 0}, a3))
      a5 = x64_emit(XStore{6, 256, 1}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XLoad{1, 6, 256}, a4)))
      a6 = x64_emit(XStore{7, 0, 1}, x64_emit(XAluRI{6, 1, 1}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, 0}, a5))))
      a7 = x64_emit(XAluRR{6, 0, 1}, x64_emit(XMovRI64{1, 0, 2147483648}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XShift{8, 0, 40, False{}}, x64_emit(XShift{9, 0, 40, False{}}, a6)))))
      a8 = x64_emit(XLoad{2, 4, 0}, x64_emit(XLoad{7, 4, 8}, a7))
      a9 = x64_emit(XStore{7, U32.mul(idx, 8), 0}, x64_emit(XLabel{lbl}, a8))
      x64_ctor_store_fields(ctx, t, U32.add(idx, 1), X64Acc{a9, U32.add(lbl, 1), cold})
def x64_ctor_fin(+ctx: X64Ctx, dst: U32, +cid: U32, fields: List<&2, U32>, cnt: U32, lbl_slow: U32, +lbl_done: U32, lbl_pack: U32, ah: List<&2, X64Inst>, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{c6, nl, _}:
      c7 = x64_emit(XJmp{lbl_done}, x64_ctor_slow(ctx, cid, fields, cnt, x64_emit(XLabel{lbl_slow}, x64_emit(XJmp{lbl_pack}, c6))))
      X64Acc{x64_store_vreg(ctx, dst, 0, ah), nl, c7}
def x64_ctor_seal_pre(is_r: Bool, ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case False{}: acc
    case True{}: x64_emit(XLoad{6, 0, 8}, x64_load_state(ctx, 0, acc))
def x64_ctor_seal_link(is_r: Bool, coff: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case False{}: acc
    case True{}: x64_emit(XStore{7, 0, 1}, x64_emit(XLoad{1, 6, coff}, acc))
def x64_ctor_body(+is_r: Bool, all_sc: Bool, +ctx: X64Ctx, dst: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +coff: U32, +loff: U32, step: U32, +hi: U32, +lbl: U32, a5: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match all_sc:
    case True{}:
      +lbl_slow = lbl
      +lbl_done = U32.add(lbl, 1)
      a6 = x64_store_vreg(ctx, dst, 0, x64_emit(XLabel{lbl_done}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, hi}, x64_ctor_store_raw(ctx, fields, 0, a5)))))
      c1 = x64_emit(XJmp{lbl_done}, x64_ctor_slow(ctx, cid, fields, cnt, x64_emit(XLabel{lbl_slow}, cold)))
      X64Acc{a6, U32.add(lbl, 2), c1}
    case False{}:
      +lbl_slow = lbl
      +lbl_done = U32.add(lbl, 1)
      +lbl_seal = U32.add(lbl, 2)
      +lbl_pack = U32.add(lbl, 3)
      +lbl_sok = U32.add(lbl, 4)
      a5b = x64_emit(XJcc{4, lbl_seal}, x64_emit(XAluRI{5, 1, 8}, x64_emit(XLoad{1, 1, 88}, x64_emit(XLeaRip{1, "p111_program"}, a5))))
      a5c = x64_emit(XJcc{5, lbl_seal}, x64_emit(XAluRI{5, 1, 255}, x64_emit(XLoad{1, 1, cid}, x64_emit(XLeaRip{1, "p111_cid_hot"}, a5b))))
      a5d = x64_emit(XLabel{lbl_done}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, hi}, x64_emit(XLabel{lbl_pack}, x64_ctor_store_raw(ctx, fields, 0, a5c)))))
      cs0 = x64_emit(XJcc{7, lbl_sok}, x64_emit(XCmpRI{0, cnt}, x64_emit(XLoad{0, 6, 256}, x64_ctor_seal_pre(is_r, ctx, x64_emit(XLabel{lbl_seal}, cold)))))
      cs1 = x64_emit(XLabel{lbl_sok}, x64_emit(XJmp{lbl_slow}, x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{0, 1, step}, x64_emit(XLoad{1, 6, loff}, x64_emit(XStore{6, coff, 2}, x64_ctor_seal_link(is_r, coff, cs0)))))))
      st6 = x64_ctor_store_fields(ctx, fields, 0, X64Acc{cs1, U32.add(lbl, 5), Nil{}})
      x64_ctor_fin(ctx, dst, cid, fields, cnt, lbl_slow, lbl_done, lbl_pack, a5d, st6)
def x64_emit_ctor_o2(is_o2: Bool, is_z: Bool, is_sm: Bool, +ctx: X64Ctx, +dst: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_z is_sm:
    case True{} True{} _:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      X64Acc{x64_store_vreg(ctx, dst, dreg, x64_emit(XMovRI64{dreg, 0, U32.or(16777216, U32.shln(cid, 8n))}, acc)), lbl, cold}
    case True{} False{} True{}:
      +cls = x64_cls_fit(cnt)
      +coff = U32.mul(cls, 8)
      +loff = U32.add(256, coff)
      +step = x64_cls_step(cls)
      a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_emit(XLoad{2, 6, coff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, acc)))))
      a4 = x64_emit(XStore{6, coff, 1}, x64_emit(XLoad{1, 7, 0}, x64_mem_idx_ptr(ctx, a1)))
      a5 = x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{1, 1, step}, x64_emit(XLoad{1, 6, loff}, a4)))
      x64_ctor_body(False{}, x64_all_scalar(ctx, fields), ctx, dst, cid, fields, cnt, coff, loff, step, U32.or(33554432, U32.shln(cid, 8n)), lbl, a5, cold)
    case _ _ _:
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_ctor_slow(ctx, cid, fields, cnt, acc)), lbl, cold}
def x64_is_u32_field(+ctx: X64Ctx, +v: U32) -> Bool:
  Bool.or(x64_is_num_scalar(ctx, v), x64_is_num_use(ctx, v))
def x64_emit_pak1(+ctx: X64Ctx, +dst: U32, +cid: U32, f0: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +dloc = x64_vreg_loc(ctx, dst)
  +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
  a1 = x64_emit(XShift{9, dreg, 32, False{}}, x64_emit(XShift{8, dreg, 32, False{}}, x64_load_vreg(ctx, dreg, f0, acc)))
  a2 = x64_emit(XAluRR{6, dreg, 1}, x64_emit(XMovRI64{1, 0, U32.or(16777216, U32.shln(cid, 8n))}, a1))
  x64_store_vreg(ctx, dst, dreg, a2)
def x64_cold_join(hot: List<&2, X64Inst>, l_done: U32, sub: X64Acc) -> X64Acc:
  match sub:
    case X64Acc{ch, nl, cc}: X64Acc{hot, nl, b5k_list_app(X64Inst, cc, x64_emit(XJmp{l_done}, ch))}
def x64_emit_pak1_dyn(+ctx: X64Ctx, +dst: U32, +cid: U32, +f0: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +dloc = x64_vreg_loc(ctx, dst)
  +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
  +l_heap = lbl
  +l_done = U32.add(lbl, 1)
  a1 = x64_emit(XJcc{5, l_heap}, x64_emit(XShift{9, 1, 32, False{}}, x64_emit(XMovRR{1, dreg}, x64_load_vreg(ctx, dreg, f0, acc))))
  a2 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRR{6, dreg, 1}, x64_emit(XMovRI64{1, 0, U32.or(16777216, U32.shln(cid, 8n))}, a1))))
  sub = x64_emit_ctor_o2(True{}, False{}, True{}, ctx, dst, cid, Con{f0, Nil{}}, 1, U32.add(lbl, 2), x64_emit(XLabel{l_heap}, cold), Nil{})
  x64_cold_join(a2, l_done, sub)
def x64_ctor_pak1(pak: Bool, dyn: Bool, +ctx: X64Ctx, +dst: U32, +cid: U32, +f0: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match pak dyn:
    case True{} _: X64Acc{x64_emit_pak1(ctx, dst, cid, f0, acc), lbl, cold}
    case False{} True{}: x64_emit_pak1_dyn(ctx, dst, cid, f0, lbl, acc, cold)
    case False{} False{}: x64_emit_ctor_o2(x64_is_o2(ctx), False{}, True{}, ctx, dst, cid, Con{f0, Nil{}}, 1, lbl, acc, cold)
def x64_emit_ctor(+ctx: X64Ctx, +dst: U32, +cid: U32, +fields: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match fields:
    case Con{+f0, Nil{}}:
      +c39 = Bool.and(x64_is_o2(ctx), U32.is_ge(cid, 39))
      x64_ctor_pak1(Bool.and(c39, x64_is_u32_field(ctx, f0)), c39, ctx, dst, cid, f0, lbl, acc, cold)
    case fs:
      +cnt = b5k_u32_list_len(fs)
      x64_emit_ctor_o2(x64_is_o2(ctx), U32.is_zero(cnt), U32.is_le(cnt, 8), ctx, dst, cid, fs, cnt, lbl, acc, cold)
def x64_reuse_pak1_dyn_fin(+ctx: X64Ctx, +dst: U32, +cid: U32, +f0: U32, +l_cold: U32, +l_done: U32, st_h: X64Acc) -> X64Acc:
  match st_h:
    case X64Acc{ah, nl, ch}:
      sub = x64_ctor_body(True{}, x64_all_scalar(ctx, Con{f0, Nil{}}), ctx, dst, cid, Con{f0, Nil{}}, 1, 0, 256, 1, U32.or(33554432, U32.shln(cid, 8n)), nl, x64_mem_idx_ptr(ctx, x64_emit(XLabel{l_cold}, ch)), Nil{})
      x64_cold_join(x64_emit(XLabel{l_done}, ah), l_done, sub)
def x64_reuse_pak1(pak: Bool, dyn: Bool, +ctx: X64Ctx, +dst: U32, +slot: U32, +cid: U32, +f0: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match pak dyn:
    case True{} _:
      +l_cold = lbl
      +l_done = U32.add(lbl, 1)
      a1 = x64_emit(XJcc{5, l_cold}, x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc)))
      a2 = x64_emit(XLabel{l_done}, x64_emit_pak1(ctx, dst, cid, f0, a1))
      sub = x64_ctor_body(True{}, True{}, ctx, dst, cid, Con{f0, Nil{}}, 1, 0, 256, 1, U32.or(33554432, U32.shln(cid, 8n)), U32.add(lbl, 2), x64_mem_idx_ptr(ctx, x64_emit(XLabel{l_cold}, cold)), Nil{})
      x64_cold_join(a2, l_done, sub)
    case False{} True{}:
      +l_cold = lbl
      +l_done = U32.add(lbl, 1)
      a1 = x64_emit(XJcc{5, l_cold}, x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc)))
      x64_reuse_pak1_dyn_fin(ctx, dst, cid, f0, l_cold, l_done, x64_emit_pak1_dyn(ctx, dst, cid, f0, U32.add(lbl, 2), a1, cold))
    case False{} False{}:
      a1b = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc)))
      x64_ctor_body(True{}, x64_all_scalar(ctx, Con{f0, Nil{}}), ctx, dst, cid, Con{f0, Nil{}}, 1, 0, 256, 1, U32.or(33554432, U32.shln(cid, 8n)), lbl, x64_mem_idx_ptr(ctx, a1b), cold)
def x64_emit_reuse_o2(use_r: Bool, +ctx: X64Ctx, +dst: U32, +slot: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match use_r fields:
    case True{} Con{+f0, Nil{}}:
      +c39 = U32.is_ge(cid, 39)
      x64_reuse_pak1(Bool.and(c39, x64_is_u32_field(ctx, f0)), c39, ctx, dst, slot, cid, f0, lbl, acc, cold)
    case True{} fs:
      +cls = x64_cls_fit(cnt)
      +coff = U32.mul(cls, 8)
      +loff = U32.add(256, coff)
      a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_load_vreg(ctx, 2, slot, acc)))
      x64_ctor_body(True{}, x64_all_scalar(ctx, fs), ctx, dst, cid, fs, cnt, coff, loff, x64_cls_step(cls), U32.or(33554432, U32.shln(cid, 8n)), lbl, x64_mem_idx_ptr(ctx, a1), cold)
    case False{} fs: x64_emit_ctor(ctx, dst, cid, fs, lbl, acc, cold)
def x64_emit_reuse(+ctx: X64Ctx, reuse: RaVec<Bool>, dst: U32, +slot: U32, cid: U32, +fields: List<&2, U32>, lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +cnt = b5k_u32_list_len(fields)
  ok = Bool.and(Bool.and(x64_is_o2(ctx), Bool.and(U32.is_gt(cnt, 0), U32.is_le(cnt, 8))), ra_vec_get(Bool, x64_ctx_vd(ctx), False{}, slot, reuse))
  x64_emit_reuse_o2(ok, ctx, dst, slot, cid, fields, cnt, lbl, acc, cold)
def x64_take_load_one(is_g: Bool, ctx: X64Ctx, d: U32, dloc: U32, off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_g:
    case True{}: x64_emit(XLoad{dloc, 7, off}, acc)
    case False{}: x64_store_vreg(ctx, d, 0, x64_emit(XLoad{0, 7, off}, acc))
def x64_take_load_fields(+ctx: X64Ctx, dsts: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Nil{}: acc
    case Con{+d, t}:
      +dloc = x64_vreg_loc(ctx, d)
      x64_take_load_fields(ctx, t, U32.add(idx, 1), x64_take_load_one(x64_is_gpr(dloc), ctx, d, dloc, U32.mul(idx, 8), acc))
def x64_take_slow(+ctx: X64Ctx, dsts: List<&2, U32>, src: U32, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))
  a2 = x64_push_cs4(csm, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, a1)))
  x64_load_scratch_go(ctx, dsts, 0, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_take"}, a2)))
def x64_take_sh_chk(n: Nat, +idx: U32, +lbl_slow: U32, +lbase: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      +lok = U32.add(lbase, idx)
      a0 = x64_emit(XJcc{4, lok}, x64_emit(XShift{9, 2, 57, False{}}, x64_emit(XMovRR{2, 0}, x64_emit(XLoad{0, 7, U32.mul(idx, 8)}, acc))))
      a1 = x64_emit(XAluRR{0, 0, 6}, x64_emit(XShift{9, 0, 21, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XJcc{9, lbl_slow}, x64_emit(XTestRR{0, 0}, a0)))))
      a2 = x64_emit(XLabel{lok}, x64_emit(XJcc{3, lbl_slow}, x64_emit(XCmpRI{2, 16777200}, x64_emit(XAluRI{5, 2, 16777215}, x64_emit(XLoad{2, 0, 0}, a1)))))
      x64_take_sh_chk(p, U32.add(idx, 1), lbl_slow, lbase, a2)
def x64_take_sh_bump(n: Nat, +idx: U32, +lbase: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      +lsk = U32.add(lbase, idx)
      a0 = x64_emit(XJcc{9, lsk}, x64_emit(XTestRR{0, 0}, x64_emit(XLoad{0, 7, U32.mul(idx, 8)}, acc)))
      a1 = x64_emit(XAluRR{0, 0, 6}, x64_emit(XShift{9, 0, 21, False{}}, x64_emit(XShift{8, 0, 24, False{}}, a0)))
      a2 = x64_emit(XLabel{lsk}, x64_emit(XStore{0, 0, 2}, x64_emit(XAluRI{0, 2, 1}, x64_emit(XLoad{2, 0, 0}, a1))))
      x64_take_sh_bump(p, U32.add(idx, 1), lbase, a2)
def x64_take_clr_tok(is_r: Bool, ctx: X64Ctx, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case False{}: acc
    case True{}: x64_store_vreg(ctx, src, 0, x64_emit(XAluRR{7, 0, 0}, acc))
def x64_take_uniq_pre(is_r: Bool, ctx: X64Ctx, loff: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case True{}: acc
    case False{}: x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{1, 32760}, x64_emit(XLoad{1, 6, loff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, acc)))))
def x64_take_uniq_post(is_r: Bool, ctx: X64Ctx, src: U32, +coff: U32, +loff: U32, step: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case True{}: x64_store_vreg(ctx, src, 2, acc)
    case False{}:
      a7 = x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{0, 1, step}, x64_emit(XLoad{1, 6, loff}, acc)))
      x64_emit(XStore{6, coff, 2}, x64_emit(XStore{7, 0, 1}, x64_emit(XLoad{1, 6, coff}, a7)))
def x64_emit_take_heap(+is_r: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _}:
      +cls = x64_cls_fit(cnt)
      +coff = U32.mul(cls, 8)
      +loff = U32.add(256, coff)
      +lbl_done = U32.add(lbl, 1)
      +lbl_sh = U32.add(lbl, 2)
      +lbl_sh1 = U32.add(lbl, 3)
      +lbl_free = U32.add(lbl, 4)
      +lbl_st = U32.add(lbl, 5)
      a1 = x64_load_vreg(ctx, 2, src, acc)
      a2 = x64_emit(XJcc{5, lbl_sh}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, a1))))
      a3 = x64_emit(XJcc{2, lbl_st}, x64_emit(XCmpRR{2, 0}, x64_emit(XMovRI32{0, ho}, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, a2)))))
      a4 = x64_take_uniq_pre(is_r, ctx, loff, lbl, a3)
      a6 = x64_take_load_fields(ctx, dsts, 0, x64_mem_idx_ptr(ctx, x64_emit(XLabel{lbl_free}, a4)))
      a8 = x64_emit(XLabel{lbl_done}, x64_take_uniq_post(is_r, ctx, src, coff, loff, x64_cls_step(cls), a6))
      b0 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_load_fields(ctx, dsts, 0, x64_mem_idx_ptr(ctx, x64_emit(XLabel{lbl_st}, cold)))))
      b1 = x64_emit(XJcc{5, lbl}, x64_emit(XCmpRI{1, 130}, x64_emit(XLabel{lbl_sh}, b0)))
      b2 = x64_emit(XAluRR{0, 1, 7}, x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XMovRR{1, 2}, x64_load_mem(ctx, 7, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, b1))))))
      b3 = x64_emit(XJcc{2, lbl}, x64_emit(XJcc{4, lbl_sh1}, x64_emit(XCmpRI{6, 1}, x64_emit(XAluRI{5, 6, 16777215}, x64_emit(XMovRR{6, 0}, x64_emit(XLoad{0, 1, 0}, b2))))))
      b4 = x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XMovRR{6, 7}, b3))))
      b5 = x64_take_sh_chk(U32.to_nat(cnt), 0, lbl, U32.add(lbl, 6), b4)
      b6 = x64_take_sh_bump(U32.to_nat(cnt), 0, U32.add(U32.add(lbl, 6), cnt), x64_emit(XStore{1, 0, 0}, x64_emit(XAluRI{1, 0, 1}, x64_emit(XLoad{0, 1, 0}, b5))))
      b7 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_load_fields(ctx, dsts, 0, b6)))
      c1 = x64_emit(XJcc{2, lbl}, x64_emit(XCmpRR{0, 2}, x64_emit(XMovRI32{2, ho}, x64_emit(XStore{4, 0, 2}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLabel{lbl_sh1}, b7))))))
      c2 = x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{2, 32760}, x64_emit(XLoad{2, 6, loff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, c1)))))
      c3 = x64_emit(XJcc{3, lbl}, x64_emit(XCmpRI{2, 32760}, x64_emit(XLoad{2, 6, 256}, c2)))
      c4 = x64_emit(XStore{6, 0, 2}, x64_emit(XLoad{2, 4, 0}, x64_emit(XStore{1, 0, 2}, x64_emit(XLoad{2, 6, 0}, c3))))
      c5 = x64_emit(XJmp{lbl_free}, x64_emit(XMovRR{2, 0}, x64_emit(XStore{6, 256, 2}, x64_emit(XAluRI{0, 2, 1}, x64_emit(XLoad{2, 6, 256}, c4)))))
      c6 = x64_emit(XJmp{lbl_done}, x64_take_clr_tok(is_r, ctx, src, x64_take_slow(ctx, dsts, src, cnt, x64_emit(XLabel{lbl}, c5))))
      X64Acc{a8, U32.add(U32.add(lbl, 6), U32.mul(cnt, 2)), c6}
def x64_emit_take_o2(is_o2: Bool, is_z: Bool, is_sm: Bool, +is_r: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_z is_sm:
    case True{} True{} _: X64Acc{acc, lbl, cold}
    case True{} False{} True{}:
      match dsts:
        case Con{+d0, Nil{}}:
          +l_heap = lbl
          +l_done = U32.add(lbl, 1)
          a1 = x64_emit(XJcc{5, l_heap}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, x64_load_vreg(ctx, 2, src, acc)))))
          a2 = x64_emit(XLabel{l_done}, x64_take_clr_tok(is_r, ctx, src, x64_store_vreg(ctx, d0, 2, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, a1)))))
          x64_cold_join(a2, l_done, x64_emit_take_heap(is_r, ctx, Con{d0, Nil{}}, src, 1, U32.add(lbl, 2), x64_emit(XLabel{l_heap}, cold), Nil{}))
        case ds: x64_emit_take_heap(is_r, ctx, ds, src, cnt, lbl, acc, cold)
    case _ _ _: X64Acc{x64_take_slow(ctx, dsts, src, cnt, acc), lbl, cold}
def x64_emit_take_bor(+ctx: X64Ctx, +dsts: List<&2, U32>, src: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match dsts:
    case Con{+d0, Nil{}}:
      +l_heap = lbl
      +l_done = U32.add(lbl, 1)
      +l_bor = U32.add(lbl, 2)
      a1 = x64_emit(XJcc{5, l_heap}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, x64_load_vreg(ctx, 2, src, acc)))))
      a2 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, d0, 2, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, a1))))
      c1 = x64_emit(XJcc{9, l_bor}, x64_emit(XTestRR{2, 2}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_load_mem(ctx, 1, x64_emit(XShift{9, 7, 24, False{}}, x64_emit(XShift{8, 7, 24, False{}}, x64_emit(XMovRR{7, 2}, x64_emit(XLabel{l_heap}, cold)))))))))
      c2 = x64_emit(XJmp{l_done}, x64_take_load_fields(ctx, Con{d0, Nil{}}, 0, x64_emit(XLabel{l_bor}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XShift{9, 7, 24, False{}}, x64_emit(XLoad{7, 7, 0}, c1)))))))
      X64Acc{a2, U32.add(lbl, 3), c2}
    case ds:
      a1 = x64_emit(XJcc{9, lbl}, x64_emit(XTestRR{2, 2}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_load_mem(ctx, 1, x64_emit(XShift{9, 7, 24, False{}}, x64_emit(XShift{8, 7, 24, False{}}, x64_emit(XMovRR{7, 2}, x64_load_vreg(ctx, 2, src, acc)))))))))
      X64Acc{x64_take_load_fields(ctx, ds, 0, x64_emit(XLabel{lbl}, x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 7, 3, False{}}, x64_emit(XShift{9, 7, 24, False{}}, x64_emit(XLoad{7, 7, 0}, a1)))))), U32.add(lbl, 1), cold}
def x64_emit_take_go(is_o2: Bool, is_r: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +lbl: U32, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>) -> X64Acc:
  +cnt = b5k_u32_list_len(dsts)
  Bool.pick(X64Acc, Bool.and(x64_is_bor(ctx, src), Bool.and(U32.is_gt(cnt, 0), U32.is_le(cnt, 8))), x64_emit_take_bor(ctx, dsts, src, lbl, acc, cold), x64_emit_take_o2(is_o2, U32.is_zero(cnt), U32.is_le(cnt, 8), is_r, ctx, dsts, src, cnt, lbl, acc, cold))
def x64_emit_tag(is_o2: Bool, +ctx: X64Ctx, +dst: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_o2:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      x64_store_vreg(ctx, dst, dreg, x64_emit(XAluRI{5, dreg, 65535}, x64_emit(XShift{9, dreg, 40, False{}}, x64_load_vreg(ctx, dreg, src, acc))))
    case False{}:
      x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_tag"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))))
def x64_rc_shared(+is_keep: Bool, +ctx: X64Ctx, +reg: U32, +l_done: U32, +l_call: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_emit(XJcc{9, l_call}, x64_emit(XTestRR{reg, reg}, x64_emit(XJcc{4, l_done}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, reg}, acc)))))
  a2 = x64_emit(XAluRR{0, 1, 7}, x64_load_mem(ctx, 7, x64_emit(XShift{9, 1, 21, False{}}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, reg}, a1)))))
  a3 = x64_emit(XJcc{Bool.pick(U32, is_keep, 3, 6), l_call}, x64_emit(XCmpRI{7, Bool.pick(U32, is_keep, 16777214, 1)}, x64_emit(XAluRI{5, 7, 16777215}, x64_emit(XMovRR{7, 2}, x64_emit(XLoad{2, 1, 0}, a2)))))
  x64_emit(XLabel{l_done}, x64_emit(XStore{1, 0, 2}, x64_emit(XAluRI{Bool.pick(U32, is_keep, 0, 1), 2, 1}, a3)))
def x64_rc_stat_chk(ctx: X64Ctx, reg: U32, l_done: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _}:
      x64_emit(XJcc{2, l_done}, x64_emit(XCmpRR{1, 2}, x64_emit(XMovRI32{2, ho}, x64_emit(XShift{9, 1, 24, False{}}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, reg}, acc))))))
def x64_keep_o2_go(both_g: Bool, +ctx: X64Ctx, dst: U32, src: U32, +dloc: U32, +sloc: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match both_g:
    case True{}:
      +csm = x64_ctx_csm(ctx)
      +l_call = U32.add(lbl, 1)
      a1 = x64_rc_shared(True{}, ctx, dloc, lbl, l_call, x64_emit_if(U32.is_ne(dloc, sloc), XMovRR{dloc, sloc}, acc))
      c1 = x64_emit(XJmp{lbl}, x64_emit(XMovRR{dloc, 0}, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_keep"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_emit(XMovRR{6, dloc}, x64_rc_stat_chk(ctx, dloc, lbl, x64_emit(XLabel{l_call}, cold)))))))))
      X64Acc{a1, U32.add(lbl, 2), c1}
    case False{}:
      +csm = x64_ctx_csm(ctx)
      +l_call = U32.add(lbl, 1)
      a1 = x64_store_vreg(ctx, dst, 0, x64_rc_shared(True{}, ctx, 0, lbl, l_call, x64_load_vreg(ctx, 0, src, acc)))
      c1 = x64_emit(XJmp{lbl}, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_keep"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_emit(XMovRR{6, 0}, x64_rc_stat_chk(ctx, 0, lbl, x64_emit(XLabel{l_call}, cold))))))))
      X64Acc{a1, U32.add(lbl, 2), c1}
def x64_emit_keep_sc(is_o2: Bool, is_sc: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_sc:
    case False{} _: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc)))), lbl, cold}
    case True{} True{}: X64Acc{x64_emit_copy(ctx, dst, src, acc), lbl, cold}
    case True{} False{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_keep_o2_go(Bool.and(x64_is_gpr(dloc), x64_is_gpr(sloc)), ctx, dst, src, dloc, sloc, lbl, acc, cold)
def x64_sink_arr_fast(+ctx: X64Ctx, +sloc: U32, +l_done: U32, +l_call: U32, +l_uniq: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, _, +ho, _}:
      a1 = x64_emit(XJcc{9, l_uniq}, x64_emit(XTestRR{sloc, sloc}, x64_emit(XJcc{4, l_done}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, sloc}, acc)))))
      a2 = x64_emit(XAluRR{0, 1, 7}, x64_load_mem(ctx, 7, x64_emit(XShift{9, 1, 21, False{}}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, sloc}, a1)))))
      a3 = x64_emit(XJcc{6, l_call}, x64_emit(XCmpRI{7, 1}, x64_emit(XAluRI{5, 7, 16777215}, x64_emit(XMovRR{7, 2}, x64_emit(XLoad{2, 1, 0}, a2)))))
      a4 = x64_emit(XJmp{l_done}, x64_emit(XStore{1, 0, 2}, x64_emit(XAluRI{1, 2, 1}, a3)))
      u1 = x64_emit(XJcc{5, l_call}, x64_emit(XCmpRI{1, 6}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, sloc}, x64_emit(XLabel{l_uniq}, a4)))))
      u2 = x64_emit(XJcc{7, l_call}, x64_emit(XCmpRI{1, 11}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, sloc}, u1)))))
      u3 = x64_emit(XJcc{2, l_done}, x64_emit(XCmpRR{2, 0}, x64_emit(XMovRI32{0, ho}, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_emit(XMovRR{2, sloc}, u2))))))
      u4 = x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XMovRR{0, 1}, x64_emit(XLoad{7, 7, 8}, x64_load_state(ctx, 7, u3)))))
      u5 = x64_emit(XJcc{5, l_call}, x64_emit(XTestRR{6, 6}, x64_emit(XLoad{6, 0, 256}, u4)))
      u6 = x64_emit(XStore{0, 0, 2}, x64_emit(XLoad{6, 0, 0}, u5))
      u7 = x64_emit(XStore{7, 0, 6}, x64_emit(XAluRR{0, 7, 2}, x64_emit(XShift{8, 2, 3, False{}}, x64_load_mem(ctx, 7, u6))))
      x64_emit(XLabel{l_done}, x64_emit(XStore{0, 256, 7}, x64_emit(XShift{8, 7, 0, True{}}, x64_emit(XMovRI32{7, 1}, u7))))
def x64_sink_o2_go(is_g: Bool, is_sca: Bool, +ctx: X64Ctx, src: U32, +sloc: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_g is_sca:
    case True{} True{}:
      +csm = x64_ctx_csm(ctx)
      +l_call = U32.add(lbl, 1)
      a1 = x64_sink_arr_fast(ctx, sloc, lbl, l_call, U32.add(lbl, 2), acc)
      c1 = x64_emit(XJmp{lbl}, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_sink"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_emit(XMovRR{6, sloc}, x64_emit(XLabel{l_call}, cold)))))))
      X64Acc{a1, U32.add(lbl, 3), c1}
    case True{} False{}:
      +csm = x64_ctx_csm(ctx)
      +l_call = U32.add(lbl, 1)
      a1 = x64_rc_shared(False{}, ctx, sloc, lbl, l_call, acc)
      c1 = x64_emit(XJmp{lbl}, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_sink"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_emit(XMovRR{6, sloc}, x64_rc_stat_chk(ctx, sloc, lbl, x64_emit(XLabel{l_call}, cold))))))))
      X64Acc{a1, U32.add(lbl, 2), c1}
    case False{} _:
      +csm = x64_ctx_csm(ctx)
      +l_call = U32.add(lbl, 1)
      a1 = x64_rc_shared(False{}, ctx, 6, lbl, l_call, x64_load_vreg(ctx, 6, src, acc))
      c1 = x64_emit(XJmp{lbl}, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_sink"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_rc_stat_chk(ctx, 6, lbl, x64_emit(XLabel{l_call}, cold)))))))
      X64Acc{a1, U32.add(lbl, 2), c1}
def x64_emit_sink_sc(is_o2: Bool, is_sc: Bool, +ctx: X64Ctx, +src: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 is_sc:
    case False{} _: X64Acc{x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))), lbl, cold}
    case True{} True{}: X64Acc{acc, lbl, cold}
    case True{} False{}:
      +sloc = x64_vreg_loc(ctx, src)
      x64_sink_o2_go(x64_is_gpr(sloc), x64_hoist_is_sc(ctx, src), ctx, src, sloc, lbl, acc, cold)
def x64_arr_slow_pair(+ctx: X64Ctx, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_push_cs4(csm, x64_emit(XMovRI32{1, b5k_u32_list_len(args)}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, aop}, a1))))
  a3 = x64_emit(XMovRI32{9, 2}, x64_emit(XMovRR{8, 2}, a2))
  x64_load_scratch_go(ctx, dsts, 0, x64_pop_cs4(csm, x64_emit(XCallSym{"p113_rt_array_pair"}, a3)))
def x64_store_head(ctx: X64Ctx, dsts: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Con{d, _}: x64_store_vreg(ctx, d, 0, acc)
    case Nil{}: acc
def x64_arr_slow_one(+ctx: X64Ctx, sym: String, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_push_cs4(csm, x64_emit(XMovRI32{1, b5k_u32_list_len(args)}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, aop}, a1))))
  x64_store_head(ctx, dsts, x64_pop_cs4(csm, x64_emit(XCallSym{sym}, a2)))
def x64_arr_slow_get_val(+ctx: X64Ctx, dv: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_push_cs4(csm, x64_emit(XMovRI32{1, 2}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, 72}, a1))))
  a3 = x64_emit(XMovRI32{9, 2}, x64_emit(XMovRR{8, 2}, a2))
  x64_store_vreg(ctx, dv, 0, x64_emit(XLoad{0, 4, 8}, x64_pop_cs4(csm, x64_emit(XCallSym{"p113_rt_array_pair"}, a3))))
def x64_arr_spec_test(+ctx: X64Ctx, dsts: List<&2, U32>, kind: U32, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Con{v, _}:
      +csm = x64_ctx_csm(ctx)
      a1 = x64_push_cs4(csm, x64_emit(XMovRI32{6, kind}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, v, acc))))
      x64_store_head(ctx, dsts, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_special_test"}, a1)))
    case Nil{}: acc
def x64_arr_spec_take(+ctx: X64Ctx, dsts: List<&2, U32>, +kind: U32, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Con{v, _}:
      +csm = x64_ctx_csm(ctx)
      a1 = x64_emit(XMovRR{1, 4}, x64_emit(XMovRI32{6, kind}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, v, acc))))
      a2 = x64_emit(XMovRI32{8, Bool.pick(U32, U32.is_eq(kind, 8), 1, 2)}, x64_push_cs4(csm, a1))
      x64_load_scratch_go(ctx, dsts, 0, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_special_take"}, a2)))
    case Nil{}: acc
def x64_arr_slow_78(ctx: X64Ctx, dsts: List<&2, U32>, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Con{dv, _}: x64_arr_slow_get_val(ctx, dv, args, acc)
    case Nil{}: acc
def x64_arr_slow_rt(is_rt: Bool, ctx: X64Ctx, aop: U32, dsts: List<&2, U32>, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_rt:
    case True{}: x64_arr_slow_one(ctx, "p111_rt_op", dsts, U32.sub(aop, 100), args, acc)
    case False{}: x64_arr_slow_pair(ctx, dsts, aop, args, acc)
def x64_arr_slow(+ctx: X64Ctx, +aop: U32, dsts: List<&2, U32>, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match aop:
    case 7: x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, 7, args, acc)
    case 8: x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, 8, args, acc)
    case 9: x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, 9, args, acc)
    case 71: x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, acc)
    case 73: x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, acc)
    case 79: x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, acc)
    case 78: x64_arr_slow_78(ctx, dsts, args, acc)
    case 208: x64_arr_spec_test(ctx, dsts, 8, args, acc)
    case 209: x64_arr_spec_test(ctx, dsts, 9, args, acc)
    case 218: x64_arr_spec_take(ctx, dsts, 8, args, acc)
    case 219: x64_arr_spec_take(ctx, dsts, 9, args, acc)
    case _: x64_arr_slow_rt(Bool.and(U32.is_ge(aop, 100), U32.is_lt(aop, 200)), ctx, aop, dsts, args, acc)
def x64_arr_elem_ptr(+ctx: X64Ctx, a: U32, i: U32, +lbl_slow: U32, +lbl_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_vreg(ctx, 2, i, x64_load_vreg(ctx, 6, a, acc))
  a2 = x64_emit(XJcc{5, lbl_slow}, x64_emit(XCmpRI{0, 6}, x64_emit(XAluRI{5, 0, 127}, x64_emit(XShift{9, 0, 56, False{}}, x64_emit(XMovRR{0, 6}, a1)))))
  a2m = x64_emit(XAluRR{5, 2, 0}, x64_emit(XAluRI{1, 0, 1}, x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, a2)))))))
  a3 = x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XMovRR{0, 6}, x64_load_mem(ctx, 7, a2m))))
  a4 = x64_emit(XJcc{9, lbl_unsh}, x64_emit(XTestRR{6, 6}, a3))
  a5 = x64_emit(XLabel{lbl_unsh}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 0, 0}, x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, a4)))))
  x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XAluRR{0, 0, 2}, a5)))
def x64_opt_store_arr_go(same: Bool, ctx: X64Ctx, da: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match same:
    case True{}: acc
    case False{}: x64_store_vreg(ctx, da, 6, acc)
def x64_opt_store_arr(+ctx: X64Ctx, +da: U32, a: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_opt_store_arr_go(U32.is_eq(x64_vreg_loc(ctx, da), x64_vreg_loc(ctx, a)), ctx, da, acc)
def x64_arr_chk_v(is_sc: Bool, reg: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sc:
    case True{}: acc
    case False{}: x64_emit(XJcc{4, l_slow}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, reg}, acc))))
def x64_arr_set_val(is_g: Bool, is_sc: Bool, +ctx: X64Ctx, +v: U32, +vloc: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_g:
    case True{}: x64_emit(XStore{7, 0, vloc}, x64_arr_chk_v(is_sc, vloc, l_slow, acc))
    case False{}: x64_emit(XStore{7, 0, 0}, x64_arr_chk_v(is_sc, 0, l_slow, x64_load_vreg(ctx, 0, v, acc)))
def x64_hoist_store(+loc: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit(Bool.pick(X64Inst, U32.is_lt(loc, 16), XMovRR{loc, src}, XStore{5, loc, src}), acc)
def x64_hoist_load_dp(no_chk: Bool, is_r: Bool, +dp: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match no_chk is_r:
    case True{} True{}: acc
    case True{} False{}: x64_emit(XLoad{2, 5, dp}, acc)
    case False{} True{}: x64_emit(XJcc{4, l_slow}, x64_emit(XTestRR{dp, dp}, acc))
    case False{} False{}: x64_emit(XJcc{4, l_slow}, x64_emit(XTestRR{2, 2}, x64_emit(XLoad{2, 5, dp}, acc)))
def x64_hoist_mask_idx(is_r: Bool, +mk: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r:
    case True{}: x64_emit(XAluRR{5, 7, mk}, acc)
    case False{}: Bool.pick(List<&2, X64Inst>, U32.is_eq(mk, 65535), acc, x64_emit(XAluRR{5, 7, 0}, x64_emit(XLoad{0, 5, mk}, acc)))
def x64_arr_elem_ptr_hoist(+ctx: X64Ctx, +dp: U32, +mk: U32, i: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +dp_r = U32.is_lt(dp, 16)
  a1 = x64_hoist_load_dp(x64_no_dp_chk(ctx), dp_r, dp, l_slow, x64_load_vreg(ctx, 7, i, acc))
  x64_emit(XAluRR{0, 7, Bool.pick(U32, dp_r, dp, 2)}, x64_emit(XShift{8, 7, 3, False{}}, x64_hoist_mask_idx(U32.is_lt(mk, 16), mk, a1)))
def x64_arr_elem_ptr_sel(hoist: Bool, ctx: X64Ctx, dp: U32, mk: U32, a: U32, i: U32, l_slow: U32, l_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hoist:
    case True{}: x64_arr_elem_ptr_hoist(ctx, dp, mk, i, l_slow, acc)
    case False{}: x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, acc)
def x64_opt_inval_hoist(hoist: Bool, ctx: X64Ctx, dp: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hoist:
    case True{}: x64_inval_cs_hoist(ctx, x64_hoist_store(dp, 0, x64_emit(XAluRR{7, 0, 0}, acc)))
    case False{}: x64_inval_cs_hoist(ctx, acc)
def x64_opt_store_arr_sel(hoist: Bool, ctx: X64Ctx, da: U32, a: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hoist:
    case True{}: x64_emit_copy(ctx, da, a, acc)
    case False{}: x64_opt_store_arr(ctx, da, a, acc)
def x64_arr_chk_sc(skip: Bool, dr: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_emit(XJcc{5, l_slow}, x64_emit(XShift{9, 1, 57, False{}}, x64_emit(XMovRR{1, dr}, acc)))
def x64_arr_chk_loaded(skip: Bool, ctx: X64Ctx, dr: U32, l_ok: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_rc_shared(True{}, ctx, dr, l_ok, l_slow, acc)
def x64_arr_chk_old(skip: Bool, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_emit(XJcc{5, l_slow}, x64_emit(XShift{9, 0, 57, False{}}, x64_emit(XLoad{0, 7, 0}, acc)))
def x64_arr_get_dreg(+ctx: X64Ctx, dv: U32, a: U32, i: U32, da: U32, has_da: Bool, ho: Bool) -> U32:
  +dl = x64_vreg_loc(ctx, dv)
  ok1 = Bool.and(x64_is_gpr(dl), Bool.and(U32.is_ne(dl, 7), Bool.and(U32.is_ne(dl, 1), Bool.and(U32.is_ne(dl, 2), Bool.or(ho, U32.is_ne(dl, 6))))))
  ok2 = Bool.and(U32.is_ne(dl, x64_vreg_loc(ctx, a)), Bool.and(U32.is_ne(dl, x64_vreg_loc(ctx, i)), Bool.or(Bool.not(has_da), U32.is_ne(dl, x64_vreg_loc(ctx, da)))))
  Bool.pick(U32, Bool.and(ok1, ok2), dl, 0)
def x64_arr_set_fin(fast: Bool, ho: Bool, +ctx: X64Ctx, dp: U32, dsts: List<&2, U32>, args: List<&2, U32>, a3b: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match fast:
    case True{}: X64Acc{a3b, lbl, cold}
    case False{}:
      +l_done = U32.add(lbl, 2)
      c1 = x64_emit(XJmp{l_done}, x64_opt_inval_hoist(ho, ctx, dp, x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, x64_emit(XLabel{lbl}, cold))))
      X64Acc{x64_emit(XLabel{l_done}, a3b), U32.add(lbl, 3), c1}
def x64_arr_set_go(+skip_old: Bool, +ctx: X64Ctx, dst: U32, dsts: List<&2, U32>, args: List<&2, U32>, +a: U32, i: U32, +v: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +vloc = x64_vreg_loc(ctx, v)
  +dp = x64_hoist_slot(True{}, ctx, a)
  +ho = U32.is_ne(dp, 0)
  a2 = x64_arr_chk_old(skip_old, lbl, x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), acc))
  a3 = x64_arr_set_val(x64_is_gpr(vloc), Bool.or(skip_old, x64_is_scalar(ctx, v)), ctx, v, vloc, lbl, a2)
  x64_arr_set_fin(Bool.and(ho, Bool.and(skip_old, x64_no_dp_chk(ctx))), ho, ctx, dp, dsts, args, x64_opt_store_arr_sel(ho, ctx, dst, a, a3), lbl, cold)
def x64_arr_new_fill_z(c: U32, nw: U32, +l_loop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match c:
    case 3:
      z0 = x64_emit(XXmmRR{6, 0, 0}, acc)
      x64_emit(XXmmStore{7, 48, 16}, x64_emit(XXmmStore{7, 32, 16}, x64_emit(XXmmStore{7, 16, 16}, x64_emit(XXmmStore{7, 0, 16}, z0))))
    case _:
      f0 = x64_emit(XLabel{l_loop}, x64_emit(XMovRI32{1, U32.shrn(nw, 4n)}, x64_emit(XXmmRR{6, 0, 0}, acc)))
      f1 = x64_emit(XXmmStore{7, 48, 16}, x64_emit(XXmmStore{7, 32, 16}, x64_emit(XXmmStore{7, 16, 16}, x64_emit(XXmmStore{7, 0, 16}, f0))))
      f2 = x64_emit(XXmmStore{7, 112, 16}, x64_emit(XXmmStore{7, 96, 16}, x64_emit(XXmmStore{7, 80, 16}, x64_emit(XXmmStore{7, 64, 16}, f1))))
      x64_emit(XJcc{5, l_loop}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XAluRI{0, 7, 128}, f2)))
def x64_arr_new_fill_go(use_z: Bool, c: U32, nw: U32, +l_loop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match use_z:
    case True{}: x64_arr_new_fill_z(c, nw, l_loop, acc)
    case False{}:
      match c:
        case 0: x64_emit(XStore{7, 0, 0}, acc)
        case 1: x64_emit(XStore{7, 8, 0}, x64_emit(XStore{7, 0, 0}, acc))
        case 2: x64_emit(XStore{7, 24, 0}, x64_emit(XStore{7, 16, 0}, x64_emit(XStore{7, 8, 0}, x64_emit(XStore{7, 0, 0}, acc))))
        case _:
          f0 = x64_emit(XLabel{l_loop}, x64_emit(XMovRI32{1, U32.shrn(nw, 3n)}, acc))
          f1 = x64_emit(XStore{7, 24, 0}, x64_emit(XStore{7, 16, 0}, x64_emit(XStore{7, 8, 0}, x64_emit(XStore{7, 0, 0}, f0))))
          f2 = x64_emit(XStore{7, 56, 0}, x64_emit(XStore{7, 48, 0}, x64_emit(XStore{7, 40, 0}, x64_emit(XStore{7, 32, 0}, f1))))
          x64_emit(XJcc{5, l_loop}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XAluRI{0, 7, 64}, f2)))
def x64_arr_new_fill(is_z: Bool, +c: U32, nw: U32, +l_loop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_arr_new_fill_go(Bool.and(is_z, U32.is_ge(c, 3)), c, nw, l_loop, acc)
def x64_arr_new_o2(ok: Bool, +is_z: Bool, +ctx: X64Ctx, dst: U32, dsts: List<&2, U32>, args: List<&2, U32>, +c: U32, +vv: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case False{}: X64Acc{x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, acc), lbl, cold}
    case True{}:
      +coff = U32.mul(c, 8)
      +loff = U32.add(256, coff)
      +nw = U32.shln(1, U32.to_nat(c))
      +l_done = U32.add(lbl, 1)
      a1 = x64_arr_chk_sc(Bool.or(is_z, x64_is_scalar(ctx, vv)), 0, lbl, x64_load_vreg(ctx, 0, vv, acc))
      a2 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{2, 2}, x64_emit(XLoad{2, 6, coff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, a1)))))
      a4 = x64_emit(XStore{6, coff, 1}, x64_emit(XLoad{1, 7, 0}, x64_mem_idx_ptr(ctx, a2)))
      a5 = x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{1, 1, nw}, x64_emit(XLoad{1, 6, loff}, a4)))
      a6 = x64_arr_new_fill(is_z, c, nw, U32.add(lbl, 2), a5)
      a7 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, U32.or(100663296, U32.shln(c, 8n))}, a6))))
      c1 = x64_emit(XJmp{l_done}, x64_inval_cs_hoist(ctx, x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, x64_emit(XLabel{lbl}, cold))))
      X64Acc{a7, U32.add(lbl, 3), c1}
def x64_arr_get_fin(fast: Bool, has_da: Bool, +ho: Bool, +ctx: X64Ctx, da: U32, +dv: U32, a: U32, dr: U32, dsts: List<&2, U32>, args: List<&2, U32>, +lbl: U32, a2: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match fast has_da:
    case True{} True{}: X64Acc{x64_store_vreg(ctx, dv, dr, x64_opt_store_arr_sel(ho, ctx, da, a, a2)), lbl, cold}
    case True{} False{}: X64Acc{x64_store_vreg(ctx, dv, dr, a2), lbl, cold}
    case False{} True{}:
      +l_done = U32.add(lbl, 2)
      a3 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, dv, dr, x64_opt_store_arr_sel(ho, ctx, da, a, a2)))
      c1 = x64_emit(XJmp{l_done}, x64_inval_cs_hoist(ctx, x64_arr_slow_pair(ctx, dsts, 72, args, x64_emit(XLabel{lbl}, cold))))
      X64Acc{a3, U32.add(lbl, 4), c1}
    case False{} False{}:
      +l_done = U32.add(lbl, 2)
      a3 = x64_emit(XLabel{l_done}, x64_store_vreg(ctx, dv, dr, a2))
      c1 = x64_emit(XJmp{l_done}, x64_inval_cs_hoist(ctx, x64_arr_slow_get_val(ctx, dv, args, x64_emit(XLabel{lbl}, cold))))
      X64Acc{a3, U32.add(lbl, 4), c1}
def x64_arr_get_go(+has_da: Bool, +ctx: X64Ctx, +da: U32, +dv: U32, +a: U32, +i: U32, dsts: List<&2, U32>, args: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +dp = x64_hoist_slot(True{}, ctx, a)
  +ho = U32.is_ne(dp, 0)
  +dr = x64_arr_get_dreg(ctx, dv, a, i, da, has_da, ho)
  +skip_ld = Bool.or(x64_is_num_use(ctx, dv), x64_hoist_is_sc(ctx, a))
  a1 = x64_emit(XLoad{dr, 7, 0}, x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), acc))
  a2 = x64_arr_chk_loaded(skip_ld, ctx, dr, U32.add(lbl, 3), lbl, a1)
  x64_arr_get_fin(Bool.and(ho, Bool.and(skip_ld, x64_no_dp_chk(ctx))), has_da, ho, ctx, da, dv, a, dr, dsts, args, lbl, a2, cold)
def x64_arr_swap_fin(fast: Bool, ho: Bool, +ctx: X64Ctx, dp: U32, dsts: List<&2, U32>, args: List<&2, U32>, a2c: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match fast:
    case True{}: X64Acc{a2c, lbl, cold}
    case False{}:
      +l_done = U32.add(lbl, 2)
      c1 = x64_emit(XJmp{l_done}, x64_opt_inval_hoist(ho, ctx, dp, x64_arr_slow_pair(ctx, dsts, 74, args, x64_emit(XLabel{lbl}, cold))))
      X64Acc{x64_emit(XLabel{l_done}, a2c), U32.add(lbl, 3), c1}
def x64_arr_swap_go(+dead_old: Bool, +ctx: X64Ctx, da: U32, dold: U32, dsts: List<&2, U32>, args: List<&2, U32>, +a: U32, i: U32, +v: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +vloc = x64_vreg_loc(ctx, v)
  +dp = x64_hoist_slot(True{}, ctx, a)
  +ho = U32.is_ne(dp, 0)
  +vsc = Bool.or(x64_is_scalar(ctx, v), Bool.or(x64_is_num_use(ctx, v), x64_hoist_is_sc(ctx, a)))
  a0 = x64_arr_elem_ptr_sel(ho, ctx, dp, x64_hoist_slot(False{}, ctx, a), a, i, lbl, U32.add(lbl, 1), acc)
  a1 = x64_emit_if(Bool.not(dead_old), XLoad{2, 7, 0}, a0)
  a2 = x64_arr_set_val(x64_is_gpr(vloc), vsc, ctx, v, vloc, lbl, a1)
  +a2b = x64_opt_store_arr_sel(ho, ctx, da, a, a2)
  a2c = Bool.pick(List<&2, X64Inst>, dead_old, a2b, x64_store_vreg(ctx, dold, 2, a2b))
  x64_arr_swap_fin(Bool.and(ho, Bool.and(vsc, x64_no_dp_chk(ctx))), ho, ctx, dp, dsts, args, a2c, lbl, cold)
def x64_arr_rmw_ir_slow(+ctx: X64Ctx, da: U32, a: U32, +i: U32, cv: U32, +bop: U32, +rc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +csm = x64_ctx_csm(ctx)
  +s1 = x64_arr_slow_pair(ctx, Nil{}, 72, [a, i], acc)
  s1b = Bool.pick(List<&2, X64Inst>, U32.is_ne(rc, 0),
    x64_emit(XAluRI{bop, 0, U32.sub(rc, 1)}, x64_emit(XLoad{0, 4, 8}, s1)),
    x64_emit(XAluRR{bop, 0, 1}, x64_load_vreg(ctx, 1, cv, x64_emit(XLoad{0, 4, 8}, s1))))
  s2 = x64_emit(XStore{4, 16, 0}, x64_mask32(0, s1b))
  s3 = x64_load_state(ctx, 7, x64_emit(XStore{4, 8, 1}, x64_load_vreg(ctx, 1, i, s2)))
  s4 = x64_push_cs4(csm, x64_emit(XMovRI32{1, 3}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, 73}, s3))))
  x64_store_vreg(ctx, da, 0, x64_pop_cs4(csm, x64_emit(XCallSym{"p111_rt_op"}, s4)))
def x64_arr_rmw_ir_fin(nc: Bool, +ctx: X64Ctx, da: U32, a: U32, i: U32, cv: U32, +bop: U32, +rc: U32, +dp: U32, f3: List<&2, X64Inst>, cold: List<&2, X64Inst>, +lbl: U32) -> X64Acc:
  match nc:
    case True{}: X64Acc{f3, lbl, cold}
    case False{}:
      +l_done = U32.add(lbl, 1)
      c1 = x64_emit(XJmp{l_done}, x64_opt_inval_hoist(True{}, ctx, dp, x64_arr_rmw_ir_slow(ctx, da, a, i, cv, bop, rc, x64_emit(XLabel{lbl}, cold))))
      X64Acc{x64_emit(XLabel{l_done}, f3), U32.add(lbl, 2), c1}
def x64_arr_rmw_ir_go(fast: Bool, +ctx: X64Ctx, +da: U32, +a: U32, +i: U32, cv: U32, +bop: U32, +rc: U32, +dp: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match fast:
    case False{}: X64Acc{x64_arr_rmw_ir_slow(ctx, da, a, i, cv, bop, rc, acc), lbl, cold}
    case True{}:
      f1 = x64_emit(XLoad{0, 7, 0}, x64_arr_elem_ptr_hoist(ctx, dp, x64_hoist_slot(False{}, ctx, a), i, lbl, acc))
      f3 = x64_emit_copy(ctx, da, a, x64_emit(XStore{7, 0, 0}, x64_mask32(0, x64_emit(XAluRI{bop, 0, U32.sub(rc, 1)}, f1))))
      x64_arr_rmw_ir_fin(x64_no_dp_chk(ctx), ctx, da, a, i, cv, bop, rc, dp, f3, cold, lbl)
def x64_emit_arrop(is_o2: Bool, +ctx: X64Ctx, +consts: RaVec<U32>, uc: RaVec<U32>, +aop: U32, +dsts: List<&2, U32>, +args: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_o2 aop dsts args:
    case False{} _ _ _: X64Acc{x64_arr_slow(ctx, aop, dsts, args, acc), lbl, cold}
    case True{} 71 Con{dst, _} Con{vd, Con{+vv, _}}:
      +dc = x64_const_val(ctx, consts, vd)
      +c = U32.sub(dc, 1)
      x64_arr_new_o2(Bool.and(U32.is_ne(dc, 0), U32.is_le(c, 12)), U32.is_eq(x64_const_val(ctx, consts, vv), 1), ctx, dst, dsts, args, c, vv, lbl, acc, cold)
    case True{} 72 Con{da, Con{dv, _}} Con{a, Con{i, _}}:
      x64_arr_get_go(True{}, ctx, da, dv, a, i, dsts, args, lbl, acc, cold)
    case True{} 73 Con{dst, _} Con{+a, Con{i, Con{+v, _}}}:
      x64_arr_set_go(Bool.or(x64_hoist_is_sc(ctx, a), Bool.or(x64_is_num_scalar(ctx, v), x64_is_num_use(ctx, v))), ctx, dst, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 79 Con{dst, _} Con{+a, Con{i, Con{+v, _}}}:
      x64_arr_set_go(True{}, ctx, dst, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 74 Con{da, Con{+dold, _}} Con{+a, Con{i, Con{+v, _}}}:
      x64_arr_swap_go(U32.is_zero(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dold, uc)), ctx, da, dold, dsts, args, a, i, v, lbl, acc, cold)
    case True{} 75 Con{da, Con{dsz, _}} Con{+a, _}:
      a1 = x64_load_vreg(ctx, 6, a, acc)
      a2 = x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, a1)))))
      X64Acc{x64_store_vreg(ctx, dsz, 0, x64_opt_store_arr(ctx, da, a, a2)), lbl, cold}
    case True{} 78 Con{dv, _} Con{a, Con{i, _}}:
      x64_arr_get_go(False{}, ctx, 0, dv, a, i, dsts, args, lbl, acc, cold)
    case True{} 80 Con{da, _} Con{+a, Con{i, Con{+cv, _}}}:
      +dp = x64_hoist_slot(True{}, ctx, a)
      +rc = x64_const_val(ctx, consts, cv)
      x64_arr_rmw_ir_go(Bool.and(U32.is_ne(dp, 0), U32.is_ne(rc, 0)), ctx, da, a, i, cv, 0, rc, dp, lbl, acc, cold)
    case True{} 81 Con{da, _} Con{+a, Con{i, Con{+cv, _}}}:
      +dp = x64_hoist_slot(True{}, ctx, a)
      +rc = x64_const_val(ctx, consts, cv)
      x64_arr_rmw_ir_go(Bool.and(U32.is_ne(dp, 0), U32.is_ne(rc, 0)), ctx, da, a, i, cv, 1, rc, dp, lbl, acc, cold)
    case _ _ _ _: X64Acc{x64_arr_slow(ctx, aop, dsts, args, acc), lbl, cold}
def x64_op_dst1(op: IrOp) -> U32:
  match op:
    case IConst{d, _}: U32.add(d, 1)
    case IFlt{d, _}: U32.add(d, 1)
    case ICopy{d, _}: U32.add(d, 1)
    case IBin{d, _, _, _}: U32.add(d, 1)
    case IUn{d, _, _}: U32.add(d, 1)
    case ICmp{d, _, _, _}: U32.add(d, 1)
    case ICallDirect{d, _, _}: U32.add(d, 1)
    case ICallClosure{d, _, _}: U32.add(d, 1)
    case IApply{d, _, _}: U32.add(d, 1)
    case ICtor{d, _, _}: U32.add(d, 1)
    case ITag{d, _}: U32.add(d, 1)
    case IKeep{d, _}: U32.add(d, 1)
    case IReuse{d, _, _, _}: U32.add(d, 1)
    case IStatic{d, _}: U32.add(d, 1)
    case IAlloca{d, _}: U32.add(d, 1)
    case ILoad{d, _, _}: U32.add(d, 1)
    case _: 0
def x64_clr_const(vd: Nat, v: U32, cs: RaVec<U32>) -> RaVec<U32>:
  match cs:
    case RVEmpty{}: RVEmpty{}
    case _: ra_vec_set(U32, vd, v, 0, cs)
def x64_clr_consts(+vd: Nat, vs: List<&2, U32>, cs: RaVec<U32>) -> RaVec<U32>:
  match vs cs:
    case Nil{} _: cs
    case _ RVEmpty{}: RVEmpty{}
    case Con{v, t} _: x64_clr_consts(vd, t, ra_vec_set(U32, vd, v, 0, cs))
def x64_clr_op(vd: Nat, op: IrOp, +cs: RaVec<U32>) -> RaVec<U32>:
  match op:
    case ITake{ds, _}: x64_clr_consts(vd, ds, cs)
    case IArrOp{ds, _, _}: x64_clr_consts(vd, ds, cs)
    case _:
      +d1 = x64_op_dst1(op)
      Bool.pick(RaVec<U32>, U32.is_zero(d1), cs, x64_clr_const(vd, U32.sub(d1, 1), cs))
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
    case True{} IUn{dst, 4, src}:
      +rc = x64_const_val(ctx, consts, src)
      +c = U32.sub(rc, 1)
      x64_set_const(Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535)), vd, dst, c, fcs)
    case True{} _: x64_clr_op(vd, op, fcs)
def x64_upd_xm0(+ctx: X64Ctx, +fconsts: RaVec<U32>, op: IrOp) -> U32:
  match op:
    case IBin{+dst, +bop, lhs, rhs}:
      +la = Bool.pick(U32, Bool.and(x64_is_o2(ctx), U32.is_eq(bop, 13)), ra_vec_get(U32, x64_ctx_vd(ctx), 0, lhs, fconsts), 0)
      +rb = Bool.pick(U32, U32.is_ne(la, 0), ra_vec_get(U32, x64_ctx_vd(ctx), 0, rhs, fconsts), 0)
      ok = Bool.and(Bool.and(Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), Bool.not(x64_is_xmm(x64_vreg_loc(ctx, dst)))), U32.is_zero(rb))
      Bool.pick(U32, ok, U32.add(dst, 1), 0)
    case _: 0
def x64_u2f_only_fdiv(n: Nat, +ctx: X64Ctx, +consts: RaVec<U32>, +fcs: RaVec<U32>, +dst: U32, rest: List<&2, IrOp>) -> Bool:
  match n rest:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{IConst{_, _}, t}: x64_u2f_only_fdiv(p, ctx, consts, fcs, dst, t)
    case 1n+p Con{IUn{d2, 4, s2}, t}:
      +rc = x64_const_val(ctx, consts, s2)
      +c = U32.sub(rc, 1)
      ok = Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535))
      x64_u2f_only_fdiv(p, ctx, consts, x64_set_const(ok, x64_ctx_vd(ctx), d2, c, fcs), dst, t)
    case _ Con{IBin{_, 13, +l, +r}, _}:
      +vd = x64_ctx_vd(ctx)
      Bool.and(Bool.or(U32.is_eq(l, dst), U32.is_eq(r, dst)), Bool.and(U32.is_ne(ra_vec_get(U32, vd, 0, l, fcs), 0), U32.is_ne(ra_vec_get(U32, vd, 0, r, fcs), 0)))
    case _ _: False{}
def x64_skip_fbin_st(+ctx: X64Ctx, +consts: RaVec<U32>, +fconsts: RaVec<U32>, +uc: RaVec<U32>, op: IrOp, rest: List<&2, IrOp>) -> Bool:
  match op rest:
    case IFlt{dst, _} _: Bool.and(x64_is_o2(ctx), U32.is_zero(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc)))
    case IUn{+dst, 4, src} _:
      +vd = x64_ctx_vd(ctx)
      +u = ra_vec_get(U32, vd, 0, dst, uc)
      +rc = x64_const_val(ctx, consts, src)
      +c = U32.sub(rc, 1)
      f1 = Bool.and(U32.is_eq(u, 1), Bool.and(U32.is_gt(rc, 1), U32.is_le(c, 65535)))
      Bool.and(x64_is_o2(ctx), Bool.or(U32.is_zero(u), Bool.and(f1, x64_u2f_only_fdiv(4n, ctx, consts, ra_vec_set(U32, vd, dst, U32.add(c, 1), fconsts), dst, rest))))
    case IBin{+dst, +bop, _, _} Con{IBin{_, +bop2, l, r}, _}:
      Bool.and(Bool.and(x64_is_o2(ctx), Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13))),
        Bool.and(U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1),
          Bool.and(Bool.and(U32.is_ge(bop2, 10), U32.is_le(bop2, 13)), Bool.or(U32.is_eq(l, dst), U32.is_eq(r, dst)))))
    case _ _: False{}
def x64_emit_const_opt(skip: Bool, ctx: X64Ctx, dst: U32, val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_emit_const(ctx, dst, val, acc)
def x64_unpack_r2(acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_mask32(0, x64_emit(XShift{9, 2, 32, False{}}, x64_emit(XMovRR{2, 0}, acc)))
def x64_par2_go(is_ld: Bool, c1: Bool, c2: Bool, +ctx: X64Ctx, a: U32, b: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld c1 c2:
    case _ True{} True{}: x64_emit(XMovRR{0, 1}, x64_emit(XMovRR{2, 0}, x64_emit(XMovRR{1, 2}, acc)))
    case True{} True{} False{}: x64_load_vreg(ctx, 0, a, x64_load_vreg(ctx, 2, b, acc))
    case True{} False{} _: x64_load_vreg(ctx, 2, b, x64_load_vreg(ctx, 0, a, acc))
    case False{} True{} False{}: x64_store_vreg(ctx, a, 0, x64_store_vreg(ctx, b, 2, acc))
    case False{} False{} _: x64_store_vreg(ctx, b, 2, x64_store_vreg(ctx, a, 0, acc))
def x64_u2_load(+ctx: X64Ctx, +d: U32, +off: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, d)
  Bool.pick(List<&2, X64Inst>, x64_is_gpr(loc), x64_emit(XLoad{loc, 5, off}, acc), x64_store_vreg(ctx, d, 0, x64_emit(XLoad{0, 5, off}, acc)))
def x64_emit_call_ret2(is_r2: Bool, +ctx: X64Ctx, dst: U32, cid: U32, sym: String, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_r2:
    case False{}: x64_store_vreg(ctx, dst, 0, x64_emit_call(ctx, sym, args, acc))
    case True{}:
      a1 = x64_load_state(ctx, 7, x64_emit(XStore{4, 8, 2}, x64_emit(XStore{4, 0, 0}, x64_unpack_r2(x64_emit_call(ctx, sym, args, acc)))))
      x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_ctor"}, x64_emit(XMovRI32{1, 2}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, cid}, a1)))))
def x64_emit_take_u2_go(ok: Bool, is_r: Bool, +ctx: X64Ctx, dsts: List<&2, U32>, src: U32, d0: U32, d1: U32, o0: U32, o1: U32, lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}: X64Acc{x64_u2_load(ctx, d1, o1, x64_u2_load(ctx, d0, o0, acc)), lbl, cold}
    case False{}: x64_emit_take_go(True{}, is_r, ctx, dsts, src, lbl, acc, cold)
def x64_emit_take_u2(+ctx: X64Ctx, is_r: Bool, +dsts: List<&2, U32>, +src: U32, lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match ctx dsts:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, +u2p, u2o0, u2o1, _}}} Con{d0, Con{d1, Nil{}}}:
      x64_emit_take_u2_go(Bool.and(U32.is_ne(u2p, 0), U32.is_eq(U32.sub(u2p, 1), src)), is_r, ctx, dsts, src, d0, d1, u2o0, u2o1, lbl, acc, cold)
    case _ _: x64_emit_take_go(x64_is_o2(ctx), is_r, ctx, dsts, src, lbl, acc, cold)
def x64_is_u2_src(ctx: X64Ctx, src: U32) -> Bool:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, +u2p, _, _, _}}}: Bool.and(U32.is_ne(u2p, 0), U32.is_eq(U32.sub(u2p, 1), src))
    case _: False{}
def x64_emit_un_opt(skip: Bool, ctx: X64Ctx, consts: RaVec<U32>, dst: U32, uop: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_emit_un(ctx, consts, dst, uop, src, acc)
def x64_emit_mutfield_go(is_sc: Bool, +vg: Bool, +vreg: U32, +ctx: X64Ctx, +obj: U32, +cid: U32, +off: U32, +val: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  match is_sc:
    case True{}: X64Acc{x64_emit(XStore{7, off, vreg}, x64_mem_idx_ptr(ctx, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_opt_load_vreg(vg, ctx, 0, val, x64_load_vreg(ctx, 2, obj, acc)))))), lbl, cold}
    case False{}:
      +csm = x64_ctx_csm(ctx)
      +l_raw = U32.add(lbl, 1)
      +l_done = U32.add(lbl, 2)
      +l_call = U32.add(lbl, 3)
      a1 = x64_emit(XJcc{4, lbl}, x64_emit(XAluRI{5, 6, 8}, x64_emit(XLoad{6, 6, 88}, x64_emit(XLeaRip{6, "p111_program"}, x64_opt_load_vreg(vg, ctx, 0, val, x64_load_vreg(ctx, 2, obj, acc))))))
      a2 = x64_emit(XJcc{5, lbl}, x64_emit(XAluRI{5, 6, 255}, x64_emit(XLoad{6, 6, cid}, x64_emit(XLeaRip{6, "p111_cid_hot"}, a1))))
      a4 = x64_emit(XLabel{l_done}, x64_emit(XStore{7, off, vreg}, x64_mem_idx_ptr(ctx, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_emit(XLabel{l_raw}, a2))))))
      s1 = x64_emit(XJcc{4, l_call}, x64_emit(XTestRR{1, 1}, x64_emit(XLoad{1, 6, 0}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, x64_emit(XJcc{5, l_raw}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, vreg}, x64_emit(XLabel{lbl}, cold))))))))))
      s3 = x64_emit(XStore{6, 256, 1}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XLoad{1, 6, 256}, x64_emit(XStore{6, 0, 1}, x64_emit(XLoad{1, 7, 0}, x64_mem_idx_ptr(ctx, x64_emit(XMovRR{2, 1}, x64_emit(XStore{4, 0, 2}, s1))))))))
      s5 = x64_emit(XAluRR{6, 0, 1}, x64_emit(XMovRI64{1, 0, 2147483648}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XShift{8, 0, 40, False{}}, x64_emit(XShift{9, 0, 40, False{}}, x64_emit_if(vg, XMovRR{0, vreg}, x64_emit(XStore{7, 0, 1}, x64_emit(XAluRI{6, 1, 1}, x64_emit(XShift{8, 1, 24, False{}}, x64_emit(XMovRR{1, vreg}, s3))))))))))
      s6 = x64_emit(XJmp{l_done}, x64_emit(XStore{7, off, 0}, x64_mem_idx_ptr(ctx, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_emit(XLoad{2, 4, 0}, s5))))))
      c2 = x64_emit(XStore{7, off, 1}, x64_emit(XMovRI64{1, 4294967295, 4294967295}, x64_mem_idx_ptr(ctx, x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_emit(XMovRR{6, 2}, x64_emit(XLabel{l_call}, s6)))))))
      c4 = x64_emit(XJmp{l_done}, x64_inval_cs_hoist(ctx, x64_pop_cs4(csm, x64_emit(XCallSym{"p118_rt_finish"}, x64_push_cs4(csm, x64_load_state(ctx, 7, x64_emit(XMovRR{2, 6}, x64_emit(XMovRR{1, vreg}, c2))))))))
      X64Acc{a4, U32.add(lbl, 4), c4}
def x64_emit_mutfield(+ctx: X64Ctx, +obj: U32, +cidx: U32, +val: U32, +lbl: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>) -> X64Acc:
  +vloc = x64_vreg_loc(ctx, val)
  +vg = Bool.and(x64_is_gpr(vloc), Bool.and(U32.is_ne(vloc, 6), U32.is_ne(vloc, 7)))
  x64_emit_mutfield_go(x64_is_scalar(ctx, val), vg, Bool.pick(U32, vg, vloc, 0), ctx, obj, U32.shrn(cidx, 4n), U32.mul(U32.and(cidx, 15), 8), val, lbl, acc, cold)
def x64_emit_alloca(is_z: Bool, ctx: X64Ctx, dst: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_z:
    case True{}: x64_store_vreg(ctx, dst, 4, acc)
    case False{}: x64_store_vreg(ctx, dst, 0, x64_emit(XAluRI{0, 0, 256}, x64_emit(XMovRR{0, 4}, acc)))
def x64_emit_load_op(is_f32: Bool, +ctx: X64Ctx, dst: U32, base: U32, off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_f32:
    case True{}: x64_store_xmm(ctx, dst, 0, x64_emit(XXmmLoad{0, 0, U32.mul(U32.sub(off, 65536), 4)}, x64_load_vreg(ctx, 0, base, acc)))
    case False{}: x64_store_vreg(ctx, dst, 0, x64_emit(XLoad{0, 0, U32.mul(off, 8)}, x64_load_vreg(ctx, 0, base, acc)))
def x64_emit_store_op(is_f32: Bool, +ctx: X64Ctx, base: U32, off: U32, val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_f32:
    case True{}: x64_emit(XXmmStore{0, U32.mul(U32.sub(off, 65536), 4), 32}, x64_load_vreg(ctx, 0, base, x64_load_xmm(ctx, 0, val, acc)))
    case False{}: x64_emit(XStore{0, U32.mul(off, 8), 1}, x64_load_vreg(ctx, 1, val, x64_load_vreg(ctx, 0, base, acc)))
def x64_emit_op(+ctx: X64Ctx, fn_map: Map<&2, String>, reuse: RaVec<Bool>, skip_st: Bool, consts: RaVec<U32>, fconsts: RaVec<U32>, xm0: U32, uc: RaVec<U32>, op: IrOp, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, +lbl: U32) -> X64Acc:
  match op:
    case IConst{+dst, val}: X64Acc{x64_emit_const_opt(x64_skip_const(ctx, dst), ctx, dst, val, acc), lbl, cold}
    case IFlt{dst, bits}: X64Acc{x64_emit_const_opt(skip_st, ctx, dst, bits, acc), lbl, cold}
    case ICopy{dst, src}: X64Acc{x64_emit_copy(ctx, dst, src, acc), lbl, cold}
    case IBin{dst, 14, lhs, rhs}: X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc)))), lbl, cold}
    case IBin{dst, +bop, lhs, rhs}: X64Acc{x64_emit_bin_go(ctx, U32.is_ge(bop, 10), skip_st, consts, fconsts, xm0, dst, bop, lhs, rhs, lbl, acc), U32.add(lbl, 1), cold}
    case IUn{dst, uop, src}: X64Acc{x64_emit_un_opt(skip_st, ctx, consts, dst, uop, src, acc), lbl, cold}
    case ICmp{dst, +cop, lhs, rhs}: X64Acc{x64_emit_cmp_go(ctx, consts, U32.is_ge(cop, 6), dst, cop, lhs, rhs, acc), lbl, cold}
    case ICallDirect{dst, +fid, args}:
      +r2 = x64_r2_of(ctx, fid)
      X64Acc{x64_emit_call_ret2(U32.is_ne(r2, 0), ctx, dst, U32.sub(r2, 1), x64_lookup_fn_sym(fn_map, fid), args, acc), lbl, cold}
    case ICallClosure{dst, fid, +caps}:
      a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, caps, 0, acc))
      a2 = x64_emit(XMovRI32{1, b5k_u32_list_len(caps)}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, fid}, a1)))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_closure"}, a2)), lbl, cold}
    case IApply{dst, clo, arg}:
      a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, arg, x64_load_vreg(ctx, 6, clo, acc)))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"$b5k_apply"}, a1)), lbl, cold}
    case ICtor{dst, cid, fields}: x64_emit_ctor(ctx, dst, cid, fields, lbl, acc, cold)
    case ITake{dsts, +src}: x64_emit_take_u2(ctx, Bool.and(x64_is_o2(ctx), ra_vec_get(Bool, x64_ctx_vd(ctx), False{}, src, reuse)), dsts, src, lbl, acc, cold)
    case ITag{dst, src}: X64Acc{x64_emit_tag(x64_is_o2(ctx), ctx, dst, src, acc), lbl, cold}
    case IKeep{dst, +src}: x64_emit_keep_sc(x64_is_o2(ctx), Bool.or(x64_is_scalar(ctx, src), x64_is_bor(ctx, src)), ctx, dst, src, lbl, acc, cold)
    case ISink{+src}: x64_emit_sink_sc(x64_is_o2(ctx), Bool.or(Bool.or(x64_is_scalar(ctx, src), x64_is_u2_src(ctx, src)), x64_is_bor(ctx, src)), ctx, src, lbl, acc, cold)
    case IReuse{dst, slot, cid, fields}: x64_emit_reuse(ctx, reuse, dst, slot, cid, fields, lbl, acc, cold)
    case IStatic{dst, idx}:
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XLoad{0, 0, U32.mul(idx, 8)}, x64_emit(XLeaRip{0, "p111_static_image"}, acc))), lbl, cold}
    case IArrOp{dsts, aop, args}: x64_emit_arrop(x64_is_o2(ctx), ctx, consts, uc, aop, dsts, args, lbl, acc, cold)
    case IAlloca{dst, +words}: X64Acc{x64_emit_alloca(U32.is_zero(words), ctx, dst, acc), lbl, cold}
    case ILoad{dst, base, +off}: X64Acc{x64_emit_load_op(U32.is_ge(off, 65536), ctx, dst, base, off, acc), lbl, cold}
    case IStore{base, +off, val}: X64Acc{x64_emit_store_op(U32.is_ge(off, 65536), ctx, base, off, val, acc), lbl, cold}
    case IMutField{obj, idx, val}: x64_emit_mutfield(ctx, obj, idx, val, lbl, acc, cold)
    case IFail{code}:
      X64Acc{x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))), lbl, cold}
def x64_emit_switch_arms(+reg: U32, arms: List<&2, IrSwitchArm>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match arms:
    case Nil{}: acc
    case Con{IrArm{tag, target}, t}:
      x64_emit_switch_arms(reg, t, x64_emit(XJcc{4, target}, x64_emit(XCmpRI{reg, tag}, acc)))
def x64_ins_arm(+t1: U32, +tgt1: U32, sorted: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>:
  match sorted:
    case Nil{}: Con{IrArm{t1, tgt1}, Nil{}}
    case Con{IrArm{+t2, +tgt2}, +rest}:
      Bool.pick(List<&2, IrSwitchArm>, U32.is_le(t1, t2), Con{IrArm{t1, tgt1}, Con{IrArm{t2, tgt2}, rest}}, Con{IrArm{t2, tgt2}, x64_ins_arm(t1, tgt1, rest)})
def x64_sort_arms(arms: List<&2, IrSwitchArm>, acc: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>:
  match arms:
    case Nil{}: acc
    case Con{IrArm{t1, tgt1}, t}: x64_sort_arms(t, x64_ins_arm(t1, tgt1, acc))
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
def x64_sw_bs_fin(sp: X64SwSplit, +reg: U32, +mid: U32, n: U32, rest: List<&2, X64SwTask>, a0: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64SwStep:
  match sp:
    case X64SwSplit{lo, mtag, mtgt, hi}:
      a1 = x64_emit(XJcc{7, lbl}, x64_emit(XJcc{4, mtgt}, x64_emit(XCmpRI{reg, mtag}, a0)))
      X64SwStep{Con{X64SwTask{False{}, 0, lo, mid}, Con{X64SwTask{True{}, lbl, hi, U32.sub(U32.sub(n, mid), 1)}, rest}}, X64Acc{a1, U32.add(lbl, 1), cold}}
def x64_sw_bs_one(sm: Bool, +reg: U32, db: U32, arms: List<&2, IrSwitchArm>, +n: U32, rest: List<&2, X64SwTask>, a0: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64SwStep:
  match sm:
    case True{}: X64SwStep{rest, X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, a0)), lbl, cold}}
    case False{}:
      +mid = U32.shrn(n, 1n)
      x64_sw_bs_fin(x64_split_arms(U32.to_nat(mid), arms, Nil{}), reg, mid, n, rest, a0, lbl, cold)
def x64_sw_bs_drain(+reg: U32, +db: U32, todo: List<&2, X64SwTask>, st: X64Acc) -> X64Acc:
  match todo st:
    case Nil{} _: st
    case Con{X64SwTask{hl, tl, arms, _}, rest} X64Acc{acc, lbl, cold}:
      x64_sw_bs_drain(reg, db, rest, X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, x64_emit_if(hl, XLabel{tl}, acc))), lbl, cold})
def x64_sw_bs_work(fuel: Nat, +reg: U32, +db: U32, step: X64SwStep) -> X64Acc:
  match fuel step:
    case _ X64SwStep{Nil{}, st}: st
    case 0n X64SwStep{todo, st}: x64_sw_bs_drain(reg, db, todo, st)
    case 1n+p X64SwStep{Con{X64SwTask{hl, tl, arms, +n}, rest}, X64Acc{acc, lbl, cold}}:
      a0 = x64_emit_if(hl, XLabel{tl}, acc)
      x64_sw_bs_work(p, reg, db, x64_sw_bs_one(U32.is_le(n, 3), reg, db, arms, n, rest, a0, lbl, cold))
def x64_emit_switch_bs(use_bs: Bool, +reg: U32, arms: List<&2, IrSwitchArm>, +n: U32, db: U32, st: X64Acc) -> X64Acc:
  match use_bs st:
    case False{} X64Acc{acc, lbl, cold}: X64Acc{x64_emit(XJmp{db}, x64_emit_switch_arms(reg, arms, acc)), lbl, cold}
    case True{} _: x64_sw_bs_work(U32.to_nat(U32.mul(n, 2)), reg, db, X64SwStep{Con{X64SwTask{False{}, 0, x64_sort_arms(arms, Nil{}), n}, Nil{}}, st})
def x64_push_pop_list(+is_push: Bool, regs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match regs:
    case Nil{}: acc
    case Con{+r, t}: x64_push_pop_list(is_push, t, Con{Bool.pick(X64Inst, is_push, XPush{r}, XPop{r}), acc})
def x64_emit_epilogue(acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, acc)))
def x64_emit_epilogue_ctx(ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, ce, _, X64Meta{True{}, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _}}:
      x64_emit(XRet{}, x64_push_pop_list(False{}, b5k_list_rev(U32, ce), acc))
    case X64Ctx{_, _, _, _, _, _, _, _, Nil{}, _, _}: x64_emit_epilogue(acc)
    case X64Ctx{_, _, _, _, _, _, _, frame, ce, _, _}:
      x64_emit(XRet{}, x64_emit(XPop{5}, x64_push_pop_list(False{}, b5k_list_rev(U32, ce), x64_emit(XAddRsp{frame}, acc))))
def x64_u32_in(+x: U32, xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(U32.is_eq(x, h), x64_u32_in(x, t))
def x64_cons_if(add: Bool, x: U32, xs: List<&2, U32>) -> List<&2, U32>:
  match add:
    case True{}: Con{x, xs}
    case False{}: xs
def x64_tail_src_locs(+ctx: X64Ctx, args: List<&2, U32>, +idx: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match args:
    case Nil{}: acc
    case Con{r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      x64_tail_src_locs(ctx, t, U32.add(idx, 1), x64_cons_if(U32.is_ne(rloc, iloc), rloc, acc))
def x64_tail_src_locs2(+ctx: X64Ctx, +srcs1: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match args:
    case Nil{}: acc
    case Con{r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      x64_tail_src_locs2(ctx, srcs1, t, U32.add(idx, 1), x64_cons_if(Bool.and(U32.is_ne(rloc, iloc), x64_u32_in(iloc, srcs1)), rloc, acc))
def x64_tail_direct_one(do_dir: Bool, ctx: X64Ctx, idx: U32, r: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match do_dir:
    case True{}: x64_emit_copy(ctx, idx, r, acc)
    case False{}: acc
def x64_tail_direct(+ctx: X64Ctx, +p2: Bool, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      ok = Bool.pick(Bool, p2, Bool.and(x64_u32_in(iloc, srcs1), Bool.not(x64_u32_in(iloc, srcs2))), Bool.not(x64_u32_in(iloc, srcs1)))
      x64_tail_direct(ctx, p2, srcs1, srcs2, t, U32.add(idx, 1), x64_tail_direct_one(Bool.and(U32.is_ne(rloc, iloc), ok), ctx, idx, r, acc))
def x64_tail_scr_one(skip: Bool, to_scr: Bool, is_xm: Bool, ctx: X64Ctx, r: U32, +idx: U32, loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip to_scr is_xm:
    case True{} _ _: acc
    case False{} True{} True{}: x64_emit(XXmmStore{4, U32.mul(idx, 8), U32.sub(loc, 20)}, acc)
    case False{} True{} False{}: x64_emit(XStore{4, U32.mul(idx, 8), 0}, x64_load_vreg(ctx, 0, r, acc))
    case False{} False{} True{}: x64_emit(XXmmLoad{U32.sub(loc, 20), 4, U32.mul(idx, 8)}, acc)
    case False{} False{} False{}: x64_store_vreg(ctx, idx, 0, x64_emit(XLoad{0, 4, U32.mul(idx, 8)}, acc))
def x64_tail_scratch(+ctx: X64Ctx, +to_scr: Bool, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      skip = Bool.or(U32.is_eq(rloc, iloc), Bool.or(Bool.not(x64_u32_in(iloc, srcs1)), Bool.not(x64_u32_in(iloc, srcs2))))
      +loc = Bool.pick(U32, to_scr, rloc, iloc)
      x64_tail_scratch(ctx, to_scr, srcs1, srcs2, t, U32.add(idx, 1), x64_tail_scr_one(skip, to_scr, x64_is_xmm(loc), ctx, r, idx, loc, acc))
def x64_emit_jcc_pair_go(eq_t: Bool, eq_e: Bool, cc: U32, tb: U32, eb: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq_t eq_e:
    case True{} _: x64_emit(XJcc{U32.xor(cc, 1), eb}, acc)
    case False{} True{}: x64_emit(XJcc{cc, tb}, acc)
    case False{} False{}: x64_emit(XJmp{eb}, x64_emit(XJcc{cc, tb}, acc))
def x64_emit_jcc_pair(cc: U32, +tb: U32, +eb: U32, +nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit_jcc_pair_go(U32.is_eq(tb, nxt), U32.is_eq(eb, nxt), cc, tb, eb, acc)
def x64_emit_br_go(is_sp: Bool, ctx: X64Ctx, +loc: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp:
    case True{}:
      a1 = x64_emit(XTestRR{0, 0}, Con{XLoad{0, 5, x64_spill_disp(ctx, loc)}, acc})
      x64_emit_jcc_pair(5, tb, eb, nxt, a1)
    case False{}:
      x64_emit_jcc_pair(5, tb, eb, nxt, x64_emit(XTestRR{loc, loc}, acc))
def x64_emit_dec_br_go(is_sp: Bool, ctx: X64Ctx, +loc: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp:
    case True{}:
      +d = x64_spill_disp(ctx, loc)
      x64_emit_jcc_pair(5, tb, eb, nxt, Con{XStore{5, d, 0}, Con{XAluRI{1, 0, 1}, Con{XLoad{0, 5, d}, acc}}})
    case False{}:
      x64_emit_jcc_pair(5, tb, eb, nxt, x64_emit(XAluRI{1, loc, 1}, acc))
def x64_emit_tail_jmp_go(has_t0: Bool, t0d: Bool, +ctx: X64Ctx, cond: U32, tb: U32, eb: U32, lbase: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_t0 t0d:
    case False{} _: x64_emit(XJmp{lbase}, acc)
    case True{} False{}:
      +loc = x64_vreg_loc(ctx, cond)
      x64_emit_br_go(U32.is_ge(loc, 100), ctx, loc, tb, eb, nxt, acc)
    case True{} True{}:
      +loc = x64_vreg_loc(ctx, cond)
      x64_emit_dec_br_go(U32.is_ge(loc, 100), ctx, loc, tb, eb, nxt, acc)
def x64_emit_tail_jmp(+ctx: X64Ctx, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, +t0c, t0t, t0e, t0d, X64Bor{_, _, X64Ha2{_, _, _, _, _, lbase}}}}}}: x64_emit_tail_jmp_go(U32.is_ne(t0c, 0), t0d, ctx, U32.sub(t0c, 1), t0t, t0e, lbase, nxt, acc)
    case _: x64_emit(XJmp{0}, acc)
type X64Swap2 is Data:
  X64Swap2{cnt: U32, d0: U32, s0: U32, d1: U32, s1: U32}
def x64_tail_scan_swap2(+ctx: X64Ctx, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, args: List<&2, U32>, +idx: U32, st: X64Swap2) -> X64Swap2:
  match args st:
    case Nil{} _: st
    case Con{+r, t} X64Swap2{+cnt, +d0, +s0, +d1, +s1}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      +act = Bool.and(U32.is_ne(rloc, iloc), Bool.and(x64_u32_in(iloc, srcs1), x64_u32_in(iloc, srcs2)))
      +c0 = Bool.and(act, U32.is_zero(cnt))
      +c1 = Bool.and(act, U32.is_eq(cnt, 1))
      x64_tail_scan_swap2(ctx, srcs1, srcs2, t, U32.add(idx, 1), X64Swap2{Bool.pick(U32, act, U32.add(cnt, 1), cnt), Bool.pick(U32, c0, iloc, d0), Bool.pick(U32, c0, rloc, s0), Bool.pick(U32, c1, iloc, d1), Bool.pick(U32, c1, rloc, s1)})
def x64_tail_cycles(+ctx: X64Ctx, +srcs1: List<&2, U32>, +srcs2: List<&2, U32>, +args: List<&2, U32>, sw: X64Swap2, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match sw:
    case X64Swap2{2, +d0, +s0, +d1, +s1}:
      ok = Bool.and(Bool.and(U32.is_eq(d0, s1), U32.is_eq(d1, s0)), Bool.and(Bool.and(x64_is_gpr(d0), x64_is_gpr(d1)), Bool.and(U32.is_ne(d0, 0), U32.is_ne(d1, 0))))
      Bool.pick(List<&2, X64Inst>, ok, x64_emit(XMovRR{d1, 0}, x64_emit(XMovRR{d0, d1}, x64_emit(XMovRR{0, d0}, acc))), x64_tail_scratch(ctx, False{}, srcs1, srcs2, args, 0, x64_tail_scratch(ctx, True{}, srcs1, srcs2, args, 0, acc)))
    case _: x64_tail_scratch(ctx, False{}, srcs1, srcs2, args, 0, x64_tail_scratch(ctx, True{}, srcs1, srcs2, args, 0, acc))
def x64_emit_tail(+ctx: X64Ctx, use_jmp: Bool, fn_map: Map<&2, String>, fid: U32, +args: List<&2, U32>, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match use_jmp:
    case False{}: x64_emit_epilogue_ctx(ctx, x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, fid), args, acc))
    case True{}:
      +srcs1 = x64_tail_src_locs(ctx, args, 0, Nil{})
      +srcs2 = x64_tail_src_locs2(ctx, srcs1, args, 0, Nil{})
      a1 = x64_tail_direct(ctx, True{}, srcs1, srcs2, args, 0, x64_tail_direct(ctx, False{}, srcs1, Nil{}, args, 0, acc))
      x64_emit_tail_jmp(ctx, nxt, x64_tail_cycles(ctx, srcs1, srcs2, args, x64_tail_scan_swap2(ctx, srcs1, srcs2, args, 0, X64Swap2{0, 0, 0, 0, 0}), a1))
def x64_emit_switch_go(is_sp: Bool, +ctx: X64Ctx, loc: U32, +arms: List<&2, IrSwitchArm>, db: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match is_sp:
    case True{}:
      +n = b5k_list_len(IrSwitchArm, arms)
      x64_emit_switch_bs(Bool.and(x64_is_o2(ctx), U32.is_ge(n, 5)), 0, arms, n, db, X64Acc{Con{XLoad{0, 5, x64_spill_disp(ctx, loc)}, acc}, lbl, cold})
    case False{}:
      +n = b5k_list_len(IrSwitchArm, arms)
      x64_emit_switch_bs(Bool.and(x64_is_o2(ctx), U32.is_ge(n, 5)), loc, arms, n, db, X64Acc{acc, lbl, cold})
def x64_emit_term(+ctx: X64Ctx, fn_map: Map<&2, String>, term: IrTerm, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match term:
    case TJmp{target}: x64_emit(XJmp{target}, acc)
    case TBr{cond, then_blk, else_blk}:
      +loc = x64_vreg_loc(ctx, cond)
      x64_emit_br_go(U32.is_ge(loc, 100), ctx, loc, then_blk, else_blk, nxt, acc)
    case TSwitch{_, _, db}: x64_emit(XJmp{db}, acc)
    case TRet{val}: x64_emit_epilogue_ctx(ctx, x64_load_vreg(ctx, 0, val, acc))
    case TTailCall{fid, +args}:
      n = b5k_u32_list_len(args)
      x64_emit_tail(ctx, U32.is_le(n, 64), fn_map, fid, args, nxt, acc)
    case TFail{code}:
      x64_emit_epilogue_ctx(ctx, x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))))
def x64_emit_ret_bor(is_b: Bool, +ctx: X64Ctx, val: U32, a1: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match is_b:
    case False{}: X64Acc{x64_emit_epilogue_ctx(ctx, x64_load_vreg(ctx, 0, val, a1)), lbl, cold}
    case True{}: X64Acc{x64_emit_epilogue_ctx(ctx, x64_rc_shared(True{}, ctx, 0, lbl, U32.add(lbl, 1), x64_load_vreg(ctx, 0, val, a1))), U32.add(lbl, 2), x64_emit(XJmp{lbl}, x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_emit(XMovRR{6, 0}, x64_emit(XLabel{U32.add(lbl, 1)}, cold)))))}
def x64_emit_term_acc(+ctx: X64Ctx, fn_map: Map<&2, String>, term: IrTerm, nxt: U32, st: X64Acc) -> X64Acc:
  match term st:
    case TSwitch{scrut, arms, def_blk} X64Acc{a1, lbl1, cold}:
      +loc = x64_vreg_loc(ctx, scrut)
      x64_emit_switch_go(U32.is_ge(loc, 100), ctx, loc, arms, def_blk, a1, lbl1, cold)
    case TRet{+val} X64Acc{a1, lbl1, cold}:
      x64_emit_ret_bor(Bool.and(x64_is_bor(ctx, val), Bool.not(x64_is_scalar(ctx, val))), ctx, val, a1, lbl1, cold)
    case _ X64Acc{a1, lbl1, cold}:
      X64Acc{x64_emit_term(ctx, fn_map, term, nxt, a1), lbl1, cold}
def x64_emit_fused_cmp_go(has_c: Bool, dir: Bool, +ctx: X64Ctx, +cop: U32, lhs: U32, rhs: U32, +lloc: U32, rloc: U32, +c: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_c dir:
    case True{} _:
      +lreg = Bool.pick(U32, x64_is_gpr(lloc), lloc, 0)
      a1 = x64_emit(Bool.pick(X64Inst, Bool.and(U32.is_zero(c), U32.is_le(cop, 1)), XTestRR{lreg, lreg}, XCmpRI{lreg, c}), x64_load_vreg(ctx, lreg, lhs, acc))
      x64_emit_jcc_pair(x64_cmp_cc(cop), tb, eb, nxt, a1)
    case False{} True{}: x64_emit_jcc_pair(x64_cmp_cc(cop), tb, eb, nxt, x64_emit(XCmpRR{lloc, rloc}, acc))
    case False{} False{}:
      a1 = x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
      x64_emit_jcc_pair(x64_cmp_cc(cop), tb, eb, nxt, x64_emit(XCmpRR{0, 1}, a1))
def x64_emit_fused_fcmp(+ctx: X64Ctx, +cop: U32, +lhs: U32, +rhs: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +lloc = x64_vreg_loc(ctx, lhs)
  +rloc = x64_vreg_loc(ctx, rhs)
  +fop = U32.sub(cop, 6)
  +swap = Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 3))
  +lxm = x64_is_xmm(lloc)
  +rxm = x64_is_xmm(rloc)
  +lx = Bool.pick(U32, lxm, U32.sub(lloc, 20), 0)
  +rx = Bool.pick(U32, rxm, U32.sub(rloc, 20), 1)
  a2 = x64_emit(XXmmRR{5, Bool.pick(U32, swap, rx, lx), Bool.pick(U32, swap, lx, rx)}, x64_opt_load_xmm(rxm, ctx, 1, rhs, x64_opt_load_xmm(lxm, ctx, 0, lhs, acc)))
  x64_emit_jcc_pair(Bool.pick(U32, Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 4)), 7, 3), tb, eb, nxt, a2)
def x64_emit_fused_cmp_go2(is_flt: Bool, +ctx: X64Ctx, +consts: RaVec<U32>, +cop: U32, +lhs: U32, +rhs: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_flt:
    case True{}: x64_emit_fused_fcmp(ctx, cop, lhs, rhs, tb, eb, nxt, acc)
    case False{}:
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +rc = x64_const_val(ctx, consts, rhs)
      dir = Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc))
      x64_emit_fused_cmp_go(U32.is_ne(rc, 0), dir, ctx, cop, lhs, rhs, lloc, rloc, U32.sub(rc, 1), tb, eb, nxt, acc)
def x64_emit_fused_cmp_fin(fuse: Bool, +ctx: X64Ctx, fn_map: Map<&2, String>, +consts: RaVec<U32>, dst: U32, +cop: U32, +lhs: U32, +rhs: U32, cond: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, lbl: U32) -> X64Acc:
  match fuse:
    case True{}: X64Acc{x64_emit_fused_cmp_go2(U32.is_ge(cop, 8), ctx, consts, cop, lhs, rhs, tb, eb, nxt, acc), lbl, cold}
    case False{}:
      x64_emit_term_acc(ctx, fn_map, TBr{cond, tb, eb}, nxt, X64Acc{x64_emit_cmp_go(ctx, consts, U32.is_ge(cop, 6), dst, cop, lhs, rhs, acc), lbl, cold})
type X64Step is Data:
  X64Step{skip: Nat, cs: RaVec<U32>, fcs: RaVec<U32>, xm0: U32, st: X64Acc}
def x64_step_one(+ctx: X64Ctx, fn_map: Map<&2, String>, reuse: RaVec<Bool>, +op: IrOp, +t: List<&2, IrOp>, +consts: RaVec<U32>, +fconsts: RaVec<U32>, xm0: U32, +uc: RaVec<U32>, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, lbl: U32) -> X64Step:
  cs1 = x64_upd_consts(x64_is_o2(ctx), x64_ctx_vd(ctx), op, consts)
  fcs1 = x64_upd_fconsts(x64_is_o2(ctx), ctx, x64_ctx_vd(ctx), consts, op, fconsts)
  X64Step{0n, cs1, fcs1, x64_upd_xm0(ctx, fconsts, op), x64_emit_op(ctx, fn_map, reuse, x64_skip_fbin_st(ctx, consts, fconsts, uc, op, t), consts, fconsts, xm0, uc, op, acc, cold, lbl)}
def x64_ret2_take_step(ok: Bool, +ctx: X64Ctx, fn_map: Map<&2, String>, reuse: RaVec<Bool>, op1: IrOp, t1: List<&2, IrOp>, cfid: U32, args: List<&2, U32>, +d0: U32, +d1: U32, +consts: RaVec<U32>, +fconsts: RaVec<U32>, xm0: U32, uc: RaVec<U32>, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, lbl: U32) -> X64Step:
  match ok:
    case True{}:
      +vd = x64_ctx_vd(ctx)
      a1 = x64_par2_go(False{}, U32.is_eq(x64_vreg_loc(ctx, d0), 2), U32.is_zero(x64_vreg_loc(ctx, d1)), ctx, d0, d1, x64_unpack_r2(x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, cfid), args, acc)))
      X64Step{1n, x64_clr_const(vd, d1, x64_clr_const(vd, d0, consts)), x64_clr_const(vd, d1, x64_clr_const(vd, d0, fconsts)), 0, X64Acc{a1, lbl, cold}}
    case False{}: x64_step_one(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)
def x64_emit_ops_step(+ctx: X64Ctx, fn_map: Map<&2, String>, +reuse: RaVec<Bool>, +op1: IrOp, +t1: List<&2, IrOp>, +consts: RaVec<U32>, +fconsts: RaVec<U32>, +xm0: U32, +uc: RaVec<U32>, +acc: List<&2, X64Inst>, +cold: List<&2, X64Inst>, +lbl: U32) -> X64Step:
  match op1 t1:
    case ICallDirect{+dst, +cfid, args} Con{ITake{Con{+d0, Con{+d1, Nil{}}}, tsrc}, _}:
      +vd = x64_ctx_vd(ctx)
      ok = Bool.and(Bool.and(U32.is_ne(x64_r2_of(ctx, cfid), 0), U32.is_eq(dst, tsrc)), Bool.and(Bool.and(U32.is_ne(d0, d1), U32.is_eq(ra_vec_get(U32, vd, 0, dst, uc), 1)), Bool.not(ra_vec_get(Bool, vd, False{}, dst, reuse))))
      x64_ret2_take_step(ok, ctx, fn_map, reuse, op1, t1, cfid, args, d0, d1, consts, fconsts, xm0, uc, acc, cold, lbl)
    case _ _: x64_step_one(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl)
def x64_fused_r2_go(ok: Bool, +ctx: X64Ctx, +fn_map: Map<&2, String>, op1: IrOp, +a: U32, +b: U32, cs: RaVec<U32>, fcs: RaVec<U32>, xm0: U32, term: IrTerm, nxt: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}: X64Acc{x64_emit_epilogue_ctx(ctx, x64_emit(XAluRR{6, 0, 2}, x64_emit(XShift{8, 2, 32, False{}}, x64_par2_go(True{}, U32.is_zero(x64_vreg_loc(ctx, b)), U32.is_eq(x64_vreg_loc(ctx, a), 2), ctx, a, b, acc)))), lbl, cold}
    case False{}: x64_emit_term_acc(ctx, fn_map, term, nxt, x64_emit_op(ctx, fn_map, RVEmpty{}, False{}, cs, fcs, xm0, RVEmpty{}, op1, acc, cold, lbl))
def x64_fused_u2_go(ok: Bool, +ctx: X64Ctx, +fn_map: Map<&2, String>, op1: IrOp, dst: U32, cfid: U32, args: List<&2, U32>, o0: U32, o1: U32, cid: U32, cs: RaVec<U32>, fcs: RaVec<U32>, xm0: U32, +term: IrTerm, nxt: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}:
      a1 = x64_emit(XStore{5, o1, 2}, x64_emit(XStore{5, o0, 0}, x64_unpack_r2(x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, cfid), args, acc))))
      X64Acc{x64_emit_term(ctx, fn_map, term, nxt, x64_store_vreg(ctx, dst, 0, x64_emit(XMovRI64{0, 0, U32.or(33554432, U32.shln(cid, 8n))}, a1))), lbl, cold}
    case False{}: x64_emit_term_acc(ctx, fn_map, term, nxt, x64_emit_op(ctx, fn_map, RVEmpty{}, False{}, cs, fcs, xm0, RVEmpty{}, op1, acc, cold, lbl))
def x64_emit_ops_fused(+ctx: X64Ctx, +fn_map: Map<&2, String>, +reuse: RaVec<Bool>, ops: List<&2, IrOp>, step: X64Step, +uc: RaVec<U32>, +term: IrTerm, +nxt: U32) -> X64Acc:
  match ctx ops step term:
    case _ Nil{} X64Step{_, _, _, _, st} _: x64_emit_term_acc(ctx, fn_map, term, nxt, st)
    case _ Con{_, t} X64Step{1n+p, cs, fcs, xm0, st} _:
      x64_emit_ops_fused(ctx, fn_map, reuse, t, X64Step{p, cs, fcs, xm0, st}, uc, term, nxt)
    case _ Con{ICmp{+dst, +cop, lhs, rhs}, Nil{}} X64Step{0n, consts, _, _, X64Acc{acc, lbl, cold}} TBr{+cond, tb, eb}:
      fuse = Bool.and(Bool.and(x64_is_o2(ctx), Bool.or(U32.is_lt(cop, 6), U32.is_ge(cop, 8))), Bool.and(U32.is_eq(dst, cond), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1)))
      x64_emit_fused_cmp_fin(fuse, ctx, fn_map, consts, dst, cop, lhs, rhs, cond, tb, eb, nxt, acc, cold, lbl)
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, _, cur_r2, _, _, _, _}}} Con{ICtor{+dst, +cid, Con{+a, Con{+b, Nil{}}}}, Nil{}} X64Step{0n, cs, fcs, xm0, X64Acc{acc, lbl, cold}} TRet{+val}:
      x64_fused_r2_go(Bool.and(U32.is_eq(cur_r2, U32.add(cid, 1)), U32.is_eq(dst, val)), ctx, fn_map, ICtor{dst, cid, Con{a, Con{b, Nil{}}}}, a, b, cs, fcs, xm0, TRet{val}, nxt, acc, lbl, cold)
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X64R2{_, _, +cur_fid, +cur_r2, +u2p, u2o0, u2o1, _}}} Con{ICallDirect{+dst, +cfid, +args}, Nil{}} X64Step{0n, cs, fcs, xm0, X64Acc{acc, lbl, cold}} TTailCall{+tfid, +targs}:
      ok = Bool.and(Bool.and(U32.is_ne(u2p, 0), U32.is_eq(cfid, cur_fid)), Bool.and(U32.is_eq(tfid, cur_fid), Bool.and(U32.is_eq(x64_u32_nth(targs, U32.to_nat(U32.sub(u2p, 1))), dst), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1))))
      x64_fused_u2_go(ok, ctx, fn_map, ICallDirect{dst, cfid, args}, dst, cfid, args, u2o0, u2o1, U32.sub(cur_r2, 1), cs, fcs, xm0, TTailCall{tfid, targs}, nxt, acc, lbl, cold)
    case _ Con{op1, +t1} X64Step{0n, consts, fconsts, xm0, X64Acc{acc, lbl, cold}} _:
      x64_emit_ops_fused(ctx, fn_map, reuse, t1, x64_emit_ops_step(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl), uc, term, nxt)
def x64_acc_insts(st: X64Acc) -> List<&2, X64Inst>:
  match st:
    case X64Acc{insts, _, cold}: b5k_list_app(X64Inst, cold, insts)
def x64_inc_use(+vd: Nat, +v: U32, +uc: RaVec<U32>) -> RaVec<U32>:
  ra_vec_set(U32, vd, v, U32.add(ra_vec_get(U32, vd, 0, v, uc), 1), uc)
def x64_inc_uses(+vd: Nat, vs: List<&2, U32>, uc: RaVec<U32>) -> RaVec<U32>:
  match vs:
    case Nil{}: uc
    case Con{v, t}: x64_inc_uses(vd, t, x64_inc_use(vd, v, uc))
def x64_uc_op(+vd: Nat, op: IrOp, uc: RaVec<U32>) -> RaVec<U32>:
  match op:
    case ICopy{_, s}: x64_inc_use(vd, s, uc)
    case IBin{_, _, l, r}: x64_inc_use(vd, r, x64_inc_use(vd, l, uc))
    case IUn{_, _, s}: x64_inc_use(vd, s, uc)
    case ICmp{_, _, l, r}: x64_inc_use(vd, r, x64_inc_use(vd, l, uc))
    case ICallDirect{_, _, args}: x64_inc_uses(vd, args, uc)
    case ICallClosure{_, _, caps}: x64_inc_uses(vd, caps, uc)
    case IApply{_, c, a}: x64_inc_use(vd, a, x64_inc_use(vd, c, uc))
    case ICtor{_, _, fs}: x64_inc_uses(vd, fs, uc)
    case ITake{_, s}: x64_inc_use(vd, s, uc)
    case ITag{_, s}: x64_inc_use(vd, s, uc)
    case IKeep{_, s}: x64_inc_use(vd, s, uc)
    case ISink{s}: x64_inc_use(vd, s, uc)
    case IReuse{_, sl, _, fs}: x64_inc_uses(vd, fs, x64_inc_use(vd, sl, uc))
    case IArrOp{_, _, args}: x64_inc_uses(vd, args, uc)
    case ILoad{_, b, _}: x64_inc_use(vd, b, uc)
    case IStore{b, _, v}: x64_inc_use(vd, v, x64_inc_use(vd, b, uc))
    case IMutField{o, _, v}: x64_inc_use(vd, v, x64_inc_use(vd, o, uc))
    case _: uc
def x64_uc_ops(+vd: Nat, ops: List<&2, IrOp>, uc: RaVec<U32>) -> RaVec<U32>:
  match ops:
    case Nil{}: uc
    case Con{op, t}: x64_uc_ops(vd, t, x64_uc_op(vd, op, uc))
def x64_uc_term(vd: Nat, term: IrTerm, uc: RaVec<U32>) -> RaVec<U32>:
  match term:
    case TBr{c, _, _}: x64_inc_use(vd, c, uc)
    case TSwitch{s, _, _}: x64_inc_use(vd, s, uc)
    case TRet{v}: x64_inc_use(vd, v, uc)
    case TTailCall{_, args}: x64_inc_uses(vd, args, uc)
    case _: uc
def x64_uc_blks(+vd: Nat, blks: List<&2, IrBlock>, uc: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: uc
    case Con{IrBlock{_, ops, term}, t}: x64_uc_blks(vd, t, x64_uc_term(vd, term, x64_uc_ops(vd, ops, uc)))
def x64_ops_has_reuse(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IReuse{_, _, _, _}, _}: True{}
    case Con{_, t}: x64_ops_has_reuse(t)
def x64_blks_has_reuse(blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, _}, t}: Bool.or(x64_ops_has_reuse(ops), x64_blks_has_reuse(t))
def x64_op_redefs(+s: U32, op: IrOp) -> Bool:
  match op:
    case ITake{ds, _}: x64_u32_in(s, ds)
    case IArrOp{ds, _, _}: x64_u32_in(s, ds)
    case _: U32.is_eq(x64_op_dst1(op), U32.add(s, 1))
def x64_ru_is_pak1(+ctx: X64Ctx, +cid: U32, fs: List<&2, U32>) -> Bool:
  match fs:
    case Con{f0, Nil{}}: Bool.and(U32.is_ge(cid, 39), x64_is_num_scalar(ctx, f0))
    case _: False{}
def x64_find_reuse_ops(+ctx: X64Ctx, +vd: Nat, +s: U32, +cls: U32, ops: List<&2, IrOp>, +st: U32) -> U32:
  match ops:
    case Nil{}: st
    case Con{IReuse{+d, +sl, +cid, +fs}, t}:
      +nf = b5k_u32_list_len(fs)
      +st1 = Bool.pick(U32, U32.is_eq(sl, s), Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(st, 2), Bool.not(x64_ru_is_pak1(ctx, cid, fs))), Bool.and(Bool.and(U32.is_ne(d, s), Bool.not(x64_u32_in(s, fs))), Bool.and(Bool.and(U32.is_gt(nf, 0), U32.is_le(nf, 8)), U32.is_eq(x64_cls_fit(nf), cls)))), 1, 0), Bool.pick(U32, Bool.and(U32.is_ne(d, s), Bool.not(x64_u32_in(s, fs))), st, 0))
      Bool.pick(U32, U32.is_zero(st1), 0, x64_find_reuse_ops(ctx, vd, s, cls, t, st1))
    case Con{+op, t}: Bool.pick(U32, Bool.or(x64_op_redefs(s, op), U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_op(vd, op, RVEmpty{})), 0)), 0, x64_find_reuse_ops(ctx, vd, s, cls, t, st))
def x64_ru_inc(+id: U32, +ps: RaVec<U32>) -> RaVec<U32>:
  Bool.pick(RaVec<U32>, U32.is_lt(id, 1024), ra_vec_set(U32, 5n, id, U32.add(ra_vec_get(U32, 5n, 0, id, ps), 1), ps), ps)
def x64_ru_arms(arms: List<&2, IrSwitchArm>, ps: RaVec<U32>) -> RaVec<U32>:
  match arms:
    case Nil{}: ps
    case Con{IrArm{_, tgt}, t}: x64_ru_arms(t, x64_ru_inc(tgt, ps))
def x64_ru_jmp(+ctx: X64Ctx, mb: Maybe<&2, IrBlock>, vd: Nat, s: U32) -> U32:
  match mb:
    case Some{IrBlock{_, ops, TJmp{tgt}}}: Bool.pick(U32, U32.is_eq(x64_find_reuse_ops(ctx, vd, s, 99, ops, 2), 2), U32.add(tgt, 1), 0)
    case _: 0
def x64_ru_both(a: List<&2, U32>, b: List<&2, U32>) -> List<&2, U32>:
  match a b:
    case Con{x, xt} Con{y, yt}: b5k_list_app(U32, Con{x, xt}, Con{y, yt})
    case _ _: Nil{}
def x64_ru_walk(fuel: Nat, is_t: Bool, tu: Bool, +ctx: X64Ctx, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: RaVec<U32>, +vd: Nat, +s: U32, +cls: U32, +bid: U32, term: IrTerm, mb: Maybe<&2, IrBlock>) -> List<&2, U32>:
  match fuel:
    case 0n: Nil{}
    case 1n+p:
      match is_t:
        case True{}:
          match tu:
            case True{}: Nil{}
            case False{}:
              match term:
                case TJmp{+tgt}: Bool.pick(List<&2, U32>, Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, bid), U32.is_eq(ra_vec_get(U32, 5n, 0, tgt, preds), 1))), x64_ru_walk(p, False{}, False{}, ctx, bmap, preds, vd, s, cls, tgt, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap)), Nil{})
                case TBr{_, +tb, +fb}:
                  +p1 = p
                  +ok = Bool.and(Bool.and(U32.is_lt(tb, 1024), U32.is_lt(fb, 1024)), Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_eq(ra_vec_get(U32, 5n, 0, tb, preds), 1), U32.is_eq(ra_vec_get(U32, 5n, 0, fb, preds), 1))))
                  +jt = Bool.pick(U32, ok, x64_ru_jmp(ctx, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), vd, s), 0)
                  +m = U32.sub(jt, 1)
                  Bool.pick(List<&2, U32>, ok, Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, Bool.pick(U32, ok, x64_ru_jmp(ctx, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), vd, s), 0)), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, bid), U32.is_eq(ra_vec_get(U32, 5n, 0, m, preds), 2))))), x64_ru_walk(p1, False{}, False{}, ctx, bmap, preds, vd, s, cls, m, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, m, bmap)), x64_ru_both(x64_ru_walk(p1, False{}, False{}, ctx, bmap, preds, vd, s, cls, tb, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), x64_ru_walk(p1, False{}, False{}, ctx, bmap, preds, vd, s, cls, fb, TJmp{0}, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)))), Nil{})
                case _: Nil{}
        case False{}:
          match mb:
            case None{}: Nil{}
            case Some{IrBlock{_, ops, +t2}}:
              +st = x64_find_reuse_ops(ctx, vd, s, cls, ops, 2)
              +tu2 = U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_term(vd, t2, RVEmpty{})), 0)
              Bool.pick(List<&2, U32>, U32.is_eq(st, 1), Bool.pick(List<&2, U32>, tu2, Nil{}, Con{bid, Nil{}}), Bool.pick(List<&2, U32>, U32.is_eq(st, 2), x64_ru_walk(p, True{}, tu2, ctx, bmap, preds, vd, s, cls, bid, t2, None{}), Nil{}))
def x64_ru_mark(+vd: Nat, +s: U32, bids: List<&2, U32>, +brm: RaVec<RaVec<Bool>>) -> RaVec<RaVec<Bool>>:
  match bids:
    case Nil{}: brm
    case Con{+bid, t}: x64_ru_mark(vd, s, t, ra_vec_set(RaVec<Bool>, 5n, bid, ra_vec_set(Bool, vd, s, True{}, ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, bid, brm)), brm))
def x64_scan_reuse_ops(+ctx: X64Ctx, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: RaVec<U32>, +vd: Nat, +bid: U32, +term: IrTerm, ops: List<&2, IrOp>, +seen: RaVec<Bool>, +brm: RaVec<RaVec<Bool>>) -> RaVec<RaVec<Bool>>:
  match ops:
    case Nil{}: brm
    case Con{ITake{+ds, +s}, +t}:
      +nt = b5k_u32_list_len(ds)
      +cls = x64_cls_fit(nt)
      +st = Bool.pick(U32, Bool.and(Bool.and(U32.is_gt(nt, 0), U32.is_le(nt, 8)), Bool.and(Bool.not(x64_u32_in(s, ds)), Bool.and(Bool.not(x64_is_u2_src(ctx, s)), Bool.and(Bool.not(x64_is_bor(ctx, s)), Bool.and(Bool.not(ra_vec_get(Bool, vd, False{}, s, seen)), Bool.not(ra_vec_get(Bool, vd, False{}, s, ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, bid, brm)))))))), x64_find_reuse_ops(ctx, vd, s, cls, t, 2), 0)
      +tu = U32.is_ne(ra_vec_get(U32, vd, 0, s, x64_uc_term(vd, term, RVEmpty{})), 0)
      hits = Bool.pick(List<&2, U32>, U32.is_eq(st, 1), Bool.pick(List<&2, U32>, tu, Nil{}, Con{bid, Nil{}}), Bool.pick(List<&2, U32>, U32.is_eq(st, 2), x64_ru_walk(24n, True{}, tu, ctx, bmap, preds, vd, s, cls, bid, term, None{}), Nil{}))
      x64_scan_reuse_ops(ctx, bmap, preds, vd, bid, term, t, ra_vec_set(Bool, vd, s, True{}, seen), x64_ru_mark(vd, s, x64_ru_both(Con{bid, Nil{}}, hits), brm))
    case Con{IReuse{_, s, _, _}, t}: x64_scan_reuse_ops(ctx, bmap, preds, vd, bid, term, t, ra_vec_set(Bool, vd, s, True{}, seen), brm)
    case Con{_, t}: x64_scan_reuse_ops(ctx, bmap, preds, vd, bid, term, t, seen, brm)
def x64_scan_reuse_blks(+ctx: X64Ctx, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: RaVec<U32>, +vd: Nat, blks: List<&2, IrBlock>, +brm: RaVec<RaVec<Bool>>) -> RaVec<RaVec<Bool>>:
  match blks:
    case Nil{}: brm
    case Con{IrBlock{+id, ops, term}, t}: x64_scan_reuse_blks(ctx, bmap, preds, vd, t, Bool.pick(RaVec<RaVec<Bool>>, U32.is_lt(id, 1024), x64_scan_reuse_ops(ctx, bmap, preds, vd, id, term, ops, RVEmpty{}, brm), brm))
def x64_ru_prep(+ctx: X64Ctx, +vd: Nat, +all_b: List<&2, IrBlock>, blks: List<&2, IrBlock>, +bm: RaVec<Maybe<&2, IrBlock>>, ps: RaVec<U32>) -> RaVec<RaVec<Bool>>:
  match blks:
    case Nil{}: x64_scan_reuse_blks(ctx, bm, ps, vd, all_b, RVEmpty{})
    case Con{IrBlock{+id, ops, TJmp{+tgt}}, t}: x64_ru_prep(ctx, vd, all_b, t, Bool.pick(RaVec<Maybe<&2, IrBlock>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrBlock>, 5n, id, Some{IrBlock{id, ops, TJmp{tgt}}}, bm), bm), x64_ru_inc(tgt, ps))
    case Con{IrBlock{+id, ops, TBr{c, +tb, +fb}}, t}: x64_ru_prep(ctx, vd, all_b, t, Bool.pick(RaVec<Maybe<&2, IrBlock>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrBlock>, 5n, id, Some{IrBlock{id, ops, TBr{c, tb, fb}}}, bm), bm), x64_ru_inc(fb, x64_ru_inc(tb, ps)))
    case Con{IrBlock{+id, ops, TSwitch{sc, +arms, +db}}, t}: x64_ru_prep(ctx, vd, all_b, t, Bool.pick(RaVec<Maybe<&2, IrBlock>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrBlock>, 5n, id, Some{IrBlock{id, ops, TSwitch{sc, arms, db}}}, bm), bm), x64_ru_inc(db, x64_ru_arms(arms, ps)))
    case Con{IrBlock{+id, ops, term}, t}: x64_ru_prep(ctx, vd, all_b, t, Bool.pick(RaVec<Maybe<&2, IrBlock>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrBlock>, 5n, id, Some{IrBlock{id, ops, term}}, bm), bm), ps)
def x64_ru_go(has: Bool, ctx: X64Ctx, vd: Nat, +blks: List<&2, IrBlock>) -> RaVec<RaVec<Bool>>:
  match has:
    case False{}: RVEmpty{}
    case True{}: x64_ru_prep(ctx, vd, blks, blks, RVEmpty{}, ra_vec_set(U32, 5n, 0, 2, RVEmpty{}))
def x64_blk_preds_go(blks: List<&2, IrBlock>, ps: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: ps
    case Con{IrBlock{_, _, TJmp{tgt}}, t}: x64_blk_preds_go(t, x64_ru_inc(tgt, ps))
    case Con{IrBlock{_, _, TBr{_, tb, fb}}, t}: x64_blk_preds_go(t, x64_ru_inc(fb, x64_ru_inc(tb, ps)))
    case Con{IrBlock{_, _, TSwitch{_, arms, db}}, t}: x64_blk_preds_go(t, x64_ru_inc(db, x64_ru_arms(arms, ps)))
    case Con{_, t}: x64_blk_preds_go(t, ps)
def x64_blk_preds(blks: List<&2, IrBlock>) -> RaVec<U32>:
  match blks:
    case Con{b0, Con{b1, Con{b2, t}}}: x64_blk_preds_go(Con{b0, Con{b1, Con{b2, t}}}, ra_vec_set(U32, 5n, 0, 2, RVEmpty{}))
    case _: RVEmpty{}
def x64_blk_head_id(blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 4294967295
    case Con{IrBlock{id, _, _}, _}: id
def x64_emit_cmp_flags_go(has_c: Bool, dir: Bool, +ctx: X64Ctx, +cop: U32, lhs: U32, rhs: U32, +lloc: U32, rloc: U32, +c: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_c dir:
    case True{} _:
      +lreg = Bool.pick(U32, x64_is_gpr(lloc), lloc, 0)
      x64_emit(Bool.pick(X64Inst, Bool.and(U32.is_zero(c), U32.is_le(cop, 1)), XTestRR{lreg, lreg}, XCmpRI{lreg, c}), x64_load_vreg(ctx, lreg, lhs, acc))
    case False{} True{}: x64_emit(XCmpRR{lloc, rloc}, acc)
    case False{} False{}: x64_emit(XCmpRR{0, 1}, x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc)))
def x64_emit_cmp_flags(+ctx: X64Ctx, consts: RaVec<U32>, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +lloc = x64_vreg_loc(ctx, lhs)
  +rloc = x64_vreg_loc(ctx, rhs)
  +rc = x64_const_val(ctx, consts, rhs)
  x64_emit_cmp_flags_go(U32.is_ne(rc, 0), Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc)), ctx, cop, lhs, rhs, lloc, rloc, U32.sub(rc, 1), acc)
def x64_emit_cmov_cc(reuse_lr: Bool, +ctx: X64Ctx, cc: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match reuse_lr:
    case True{}: x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, 0, x64_emit(XCmov{cc, 0, 1}, acc)))
    case False{}:
      +vtloc = x64_vreg_loc(ctx, vt)
      +dloc = x64_vreg_loc(ctx, dst)
      +vtg = x64_is_gpr(vtloc)
      +vtreg = Bool.pick(U32, vtg, vtloc, 1)
      +dreg = Bool.pick(U32, Bool.and(x64_is_gpr(dloc), U32.is_ne(dloc, vtreg)), dloc, 0)
      x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, dreg, x64_emit(XCmov{cc, dreg, vtreg}, x64_opt_load_vreg(vtg, ctx, 1, vt, x64_load_vreg(ctx, dreg, ve, acc)))))
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
def x64_cmov_fuse1(ok: Bool, +ctx: X64Ctx, +consts: RaVec<U32>, +cop: U32, +lhs: U32, +rhs: U32, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}: x64_cmov_cc_go(ctx, consts, cop, x64_cmp_cc(cop), lhs, rhs, dst, vt, ve, j1, nxt, acc, lbl, cold)
    case False{}: x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, consts, U32.is_ge(cop, 6), cond, cop, lhs, rhs, acc), lbl, cold})
def x64_cmov_fuse2(ok: Bool, +ctx: X64Ctx, +consts: RaVec<U32>, +cop1: U32, +l1: U32, +r1: U32, +t1: U32, +l2: U32, +r2: U32, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>, lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}: x64_cmov_cc_go(ctx, consts, cop1, U32.xor(x64_cmp_cc(cop1), 1), l1, r1, dst, vt, ve, j1, nxt, acc, lbl, cold)
    case False{}: x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, x64_clr_const(x64_ctx_vd(ctx), t1, consts), False{}, cond, 0, l2, r2, x64_emit_cmp_go(ctx, consts, U32.is_ge(cop1, 6), t1, cop1, l1, r1, acc)), lbl, cold})
def x64_cmov_abs(ok: Bool, +ctx: X64Ctx, +cs: RaVec<U32>, +t1: U32, +lx: U32, +rc: U32, +d1: U32, +l1: U32, +r1: U32, +d2: U32, +l2: U32, +r2: U32, +cd: U32, +lc: U32, +rz: U32, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32, acc: List<&2, X64Inst>, +lbl: U32, cold: List<&2, X64Inst>) -> X64Acc:
  match ok:
    case True{}:
      a1 = x64_emit(XCmov{2, 0, 2}, x64_emit(XAluRR{1, 0, 1}, x64_emit(XAluRR{1, 2, 0}, x64_emit(XMovRR{2, 1}, x64_load_vreg(ctx, 1, rc, x64_load_vreg(ctx, 0, lx, acc))))))
      X64Acc{x64_emit_if(U32.is_ne(j1, nxt), XJmp{j1}, x64_store_vreg(ctx, dst, 0, a1)), lbl, cold}
    case False{}:
      +vd = x64_ctx_vd(ctx)
      +c1 = x64_clr_const(vd, t1, cs)
      +c2 = x64_clr_const(vd, d1, c1)
      a1 = x64_emit_bin_go(ctx, False{}, False{}, c1, RVEmpty{}, 0, d1, 1, l1, r1, lbl, x64_emit_cmp_go(ctx, cs, False{}, t1, 2, lx, rc, acc))
      x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, X64Acc{x64_emit_cmp_go(ctx, x64_clr_const(vd, d2, c2), False{}, cd, 0, lc, rz, x64_emit_bin_go(ctx, False{}, False{}, c2, RVEmpty{}, 0, d2, 1, l2, r2, U32.add(lbl, 1), a1)), U32.add(lbl, 2), cold})
def x64_emit_ops_cmov(+ctx: X64Ctx, +fn_map: Map<&2, String>, +reuse: RaVec<Bool>, ops: List<&2, IrOp>, step: X64Step, +uc: RaVec<U32>, +cond: U32, +dst: U32, +vt: U32, +ve: U32, +j1: U32, +nxt: U32) -> X64Acc:
  match ops step:
    case Nil{} X64Step{_, _, _, _, st}: x64_emit_cmov_sel(ctx, cond, dst, vt, ve, j1, nxt, st)
    case Con{_, t} X64Step{1n+p, cs, fcs, xm0, st}: x64_emit_ops_cmov(ctx, fn_map, reuse, t, X64Step{p, cs, fcs, xm0, st}, uc, cond, dst, vt, ve, j1, nxt)
    case Con{ICmp{+cd, +cop, +l, +r}, Nil{}} X64Step{0n, cs, _, _, X64Acc{acc, lbl, cold}}:
      x64_cmov_fuse1(Bool.and(Bool.and(U32.is_lt(cop, 6), U32.is_eq(cd, cond)), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, cd, uc), 1)), ctx, cs, cop, l, r, cond, dst, vt, ve, j1, nxt, acc, lbl, cold)
    case Con{ICmp{+t1, +cop1, +l1, +r1}, Con{ICmp{+cd, 0, +l2, +r2}, Nil{}}} X64Step{0n, +cs, _, _, X64Acc{acc, lbl, cold}}:
      +vd = x64_ctx_vd(ctx)
      x64_cmov_fuse2(Bool.and(Bool.and(U32.is_lt(cop1, 6), Bool.and(U32.is_eq(l2, t1), U32.is_eq(cd, cond))), Bool.and(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, t1, uc), 1), U32.is_eq(ra_vec_get(U32, vd, 0, cd, uc), 1)), U32.is_eq(x64_const_val(ctx, cs, r2), 1))), ctx, cs, cop1, l1, r1, t1, l2, r2, cond, dst, vt, ve, j1, nxt, acc, lbl, cold)
    case Con{ICmp{+t1, 2, +lx, +rc}, Con{IBin{+d1, 1, +l1, +r1}, Con{IBin{+d2, 1, +l2, +r2}, Con{ICmp{+cd, 0, +lc, +rz}, Nil{}}}}} X64Step{0n, +cs, _, _, X64Acc{acc, lbl, cold}}:
      +vd = x64_ctx_vd(ctx)
      +ok1 = Bool.and(Bool.and(Bool.and(U32.is_eq(l1, lx), U32.is_eq(r1, rc)), Bool.and(U32.is_eq(l2, rc), U32.is_eq(r2, lx))), Bool.and(Bool.and(U32.is_eq(lc, t1), U32.is_eq(cd, cond)), Bool.and(U32.is_eq(vt, d1), U32.is_eq(ve, d2))))
      x64_cmov_abs(Bool.and(Bool.not(x64_no_dp_chk(ctx)), Bool.and(ok1, Bool.and(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, t1, uc), 1), U32.is_eq(ra_vec_get(U32, vd, 0, cd, uc), 1)), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, d1, uc), 1), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, d2, uc), 1), U32.is_eq(x64_const_val(ctx, cs, rz), 1)))))), ctx, cs, t1, lx, rc, d1, l1, r1, d2, l2, r2, cd, lc, rz, cond, dst, vt, ve, j1, nxt, acc, lbl, cold)
    case Con{op1, +t1} X64Step{0n, consts, fconsts, xm0, X64Acc{acc, lbl, cold}}:
      x64_emit_ops_cmov(ctx, fn_map, reuse, t1, x64_emit_ops_step(ctx, fn_map, reuse, op1, t1, consts, fconsts, xm0, uc, acc, cold, lbl), uc, cond, dst, vt, ve, j1, nxt)
def x64_emit_one_blk(+ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, +brm: RaVec<RaVec<Bool>>, +id: U32, ops: List<&2, IrOp>, term: IrTerm, nxt: U32, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{acc, lbl, cold}:
      x64_emit_ops_fused(ctx, fn_map, Bool.pick(RaVec<Bool>, U32.is_lt(id, 1024), ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, id, brm), RVEmpty{}), ops, X64Step{0n, RVEmpty{}, RVEmpty{}, 0, X64Acc{x64_emit(XLabel{id}, acc), lbl, cold}}, uc, term, nxt)
def x64_emit_blocks_dia(ok: Bool, +ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, +brm: RaVec<RaVec<Bool>>, +id0: U32, ops0: List<&2, IrOp>, term0: IrTerm, cond: U32, dst: U32, vt: U32, ve: U32, j1: U32, nid: U32, nxt_hit: U32, st: X64Acc) -> X64Acc:
  match ok st:
    case True{} X64Acc{acc, lbl, cold}:
      x64_emit_ops_cmov(ctx, fn_map, Bool.pick(RaVec<Bool>, U32.is_lt(id0, 1024), ra_vec_get(RaVec<Bool>, 5n, RVEmpty{}, id0, brm), RVEmpty{}), ops0, X64Step{0n, RVEmpty{}, RVEmpty{}, 0, X64Acc{x64_emit(XLabel{id0}, acc), lbl, cold}}, uc, cond, dst, vt, ve, j1, nxt_hit)
    case False{} _: x64_emit_one_blk(ctx, fn_map, uc, brm, id0, ops0, term0, nid, st)
def x64_emit_blocks(+ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, +brm: RaVec<RaVec<Bool>>, +preds: RaVec<U32>, blks: List<&2, IrBlock>, skip: Nat, st: X64Acc) -> X64Acc:
  match blks skip:
    case Nil{} _: st
    case Con{_, t} 1n+p: x64_emit_blocks(ctx, fn_map, uc, brm, preds, t, p, st)
    case Con{IrBlock{id, ops, term}, Nil{}} 0n: x64_emit_one_blk(ctx, fn_map, uc, brm, id, ops, term, 4294967295, st)
    case Con{IrBlock{+id0, ops0, TBr{+cond, +tb, +eb}}, Con{IrBlock{+id1, Con{ICopy{+d1, +v1}, Nil{}}, TJmp{+j1}}, Con{IrBlock{+id2, Con{ICopy{+d2, +v2}, Nil{}}, TJmp{+j2}}, +t3}}} 0n:
      +o1 = Bool.and(U32.is_eq(id1, tb), U32.is_eq(id2, eb))
      +o2 = Bool.and(U32.is_eq(id1, eb), U32.is_eq(id2, tb))
      +ok = Bool.and(Bool.and(x64_is_o2(ctx), Bool.and(U32.is_eq(d1, d2), Bool.and(U32.is_eq(j1, j2), U32.is_ne(tb, eb)))), Bool.and(Bool.or(o1, o2), Bool.and(Bool.and(U32.is_lt(id1, 1024), U32.is_lt(id2, 1024)), Bool.and(U32.is_eq(ra_vec_get(U32, 5n, 0, id1, preds), 1), U32.is_eq(ra_vec_get(U32, 5n, 0, id2, preds), 1)))))
      st1 = x64_emit_blocks_dia(ok, ctx, fn_map, uc, brm, id0, ops0, TBr{cond, tb, eb}, cond, d1, Bool.pick(U32, o1, v1, v2), Bool.pick(U32, o1, v2, v1), j1, id1, x64_blk_head_id(t3), st)
      x64_emit_blocks(ctx, fn_map, uc, brm, preds, Con{IrBlock{id1, Con{ICopy{d1, v1}, Nil{}}, TJmp{j1}}, Con{IrBlock{id2, Con{ICopy{d2, v2}, Nil{}}, TJmp{j2}}, t3}}, Bool.pick(Nat, ok, 2n, 0n), st1)
    case Con{IrBlock{id, ops, term}, Con{IrBlock{+nid, nops, nterm}, t2}} 0n:
      x64_emit_blocks(ctx, fn_map, uc, brm, preds, Con{IrBlock{nid, nops, nterm}, t2}, 0n, x64_emit_one_blk(ctx, fn_map, uc, brm, id, ops, term, nid, st))
def x64_lower_fn(fn_map: Map<&2, String>, heap_off: U32, f: IrFn) -> X64Fn:
  match f:
    case IrFn{_, name, +arity, +nregs, _, _, _, blocks}:
      scr = U32.add(16, U32.mul(U32.max(16, arity), 8))
      +frame = x64_align16(U32.add(scr, U32.mul(U32.max(nregs, arity), 8)))
      +ctx = x64_mk_ctx(False{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, frame, Nil{}, heap_off, x64_empty_meta())
      a0 = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_save_params_go(ctx, U32.to_nat(arity), 0, a0)
      X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_blocks(ctx, fn_map, RVEmpty{}, RVEmpty{}, RVEmpty{}, blocks, 0n, X64Acc{a1, 2147483648, Nil{}})))}
def x64_op_uses_mem(op: IrOp) -> Bool:
  match op:
    case ICtor{_, _, Con{_, _}}: True{}
    case IReuse{_, _, _, Con{_, _}}: True{}
    case ITake{Con{_, _}, _}: True{}
    case IKeep{_, _}: True{}
    case ISink{_}: True{}
    case IMutField{_, _, _}: True{}
    case IArrOp{_, +aop, _}: Bool.or(Bool.and(U32.is_ge(aop, 71), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 79)))
    case _: False{}
def x64_ops_use_mem(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{op, t}: Bool.or(x64_op_uses_mem(op), x64_ops_use_mem(t))
def x64_blks_use_mem(blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, _}, t}: Bool.or(x64_ops_use_mem(ops), x64_blks_use_mem(t))
def x64_pick_free_callee(+ce: List<&2, U32>) -> U32:
  Bool.pick(U32, x64_u32_in(15, ce), Bool.pick(U32, x64_u32_in(14, ce), Bool.pick(U32, x64_u32_in(13, ce), Bool.pick(U32, x64_u32_in(12, ce), Bool.pick(U32, x64_u32_in(3, ce), 0, 3), 12), 13), 14), 15)
def x64_init_mem(has_r: Bool, has_d: Bool, mr: U32, md: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r has_d:
    case True{} _: x64_emit(XLoad{mr, 7, 0}, acc)
    case False{} True{}: x64_emit(XStore{5, md, 0}, x64_emit(XLoad{0, 7, 0}, acc))
    case False{} False{}: acc

type X64DefSt is Data:
  X64DefSt{c31: RaVec<U32>, sc: RaVec<U32>, nf: Bool, stc: Bool, harr: Bool, hc: Bool}
def x64_m1(+vd: Nat, arity: U32, +v: U32, +m: RaVec<U32>) -> RaVec<U32>:
  +cur = ra_vec_get(U32, vd, 0, v, m)
  ok = Bool.and(U32.is_ge(v, arity), Bool.or(U32.is_zero(cur), U32.is_eq(cur, 2)))
  Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, vd, v, 1, m), m)
def x64_mnum(+vd: Nat, arity: U32, +v: U32, +m: RaVec<U32>) -> RaVec<U32>:
  ok = Bool.and(U32.is_ge(v, arity), U32.is_zero(ra_vec_get(U32, vd, 0, v, m)))
  Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, vd, v, 2, m), m)
def x64_mc(+vd: Nat, arity: U32, +v: U32, val: U32, +m: RaVec<U32>) -> RaVec<U32>:
  ok = Bool.and(U32.is_ge(v, arity), U32.is_zero(ra_vec_get(U32, vd, 0, v, m)))
  Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, vd, v, U32.add(val, 1), m), ra_vec_set(U32, vd, v, 4294967295, m))
def x64_m2(vd: Nat, v: U32, m: RaVec<U32>) -> RaVec<U32>:
  ra_vec_set(U32, vd, v, 4294967295, m)
def x64_m2s(+vd: Nat, vs: List<&2, U32>, m: RaVec<U32>) -> RaVec<U32>:
  match vs:
    case Nil{}: m
    case Con{v, t}: x64_m2s(vd, t, ra_vec_set(U32, vd, v, 4294967295, m))
def x64_def_op(+vd: Nat, +arity: U32, op: IrOp, st: X64DefSt) -> X64DefSt:
  match op st:
    case IConst{+d, +val} X64DefSt{+c31, sc, nf, stc, ha, hc}:
      c1 = Bool.pick(RaVec<U32>, U32.is_lt(val, 2147483647), x64_mc(vd, arity, d, val, c31), x64_m2(vd, d, c31))
      X64DefSt{c1, x64_mnum(vd, arity, d, sc), nf, stc, ha, hc}
    case IFlt{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_mnum(vd, arity, d, sc), nf, stc, ha, hc}
    case IBin{+d, _, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_mnum(vd, arity, d, sc), nf, stc, ha, hc}
    case IUn{+d, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_mnum(vd, arity, d, sc), nf, stc, ha, hc}
    case ICmp{+d, _, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m1(vd, arity, d, sc), nf, stc, ha, hc}
    case ITag{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m1(vd, arity, d, sc), nf, stc, ha, hc}
    case ICtor{+d, _, Nil{}} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m1(vd, arity, d, sc), nf, stc, ha, hc}
    case ICtor{+d, +cid, Con{+f0, Nil{}}} X64DefSt{c31, +sc, nf, stc, ha, hc}:
      +is_pak = Bool.and(U32.is_ge(cid, 39), U32.is_eq(ra_vec_get(U32, vd, 0, f0, sc), 2))
      X64DefSt{x64_m2(vd, d, c31), Bool.pick(RaVec<U32>, is_pak, x64_m1(vd, arity, d, sc), x64_m2(vd, d, sc)), Bool.or(nf, Bool.not(is_pak)), stc, ha, hc}
    case ICtor{+d, _, Con{_, _}} X64DefSt{c31, sc, _, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, hc}
    case ICopy{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case IStatic{+d, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case ILoad{+d, _, _} X64DefSt{c31, sc, nf, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), nf, stc, ha, hc}
    case IStore{_, _, _} _: st
    case IMutField{_, _, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{c31, sc, True{}, stc, ha, True{}}
    case ITake{Nil{}, _} _: st
    case ITake{+ds, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2s(vd, ds, c31), x64_m2s(vd, ds, sc), True{}, stc, ha, True{}}
    case IArrOp{+ds, +aop, _} X64DefSt{c31, sc, _, stc, ha, hc}:
      +is_ha = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81)))
      X64DefSt{x64_m2s(vd, ds, c31), x64_m2s(vd, ds, sc), True{}, stc, Bool.or(ha, is_ha), Bool.or(hc, Bool.not(Bool.or(is_ha, U32.is_eq(aop, 75))))}
    case ICallDirect{+d, _, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, True{}}
    case ICallClosure{+d, _, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, True{}}
    case IApply{+d, _, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, True{}}
    case IKeep{+d, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, True{}}
    case ISink{_} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{c31, sc, True{}, stc, ha, True{}}
    case IReuse{+d, _, +cid, Con{+f0, Nil{}}} X64DefSt{c31, +sc, _, stc, ha, _}:
      +is_pak = Bool.and(U32.is_ge(cid, 39), U32.is_eq(ra_vec_get(U32, vd, 0, f0, sc), 2))
      X64DefSt{x64_m2(vd, d, c31), Bool.pick(RaVec<U32>, is_pak, x64_m1(vd, arity, d, sc), x64_m2(vd, d, sc)), True{}, stc, ha, True{}}
    case IReuse{+d, _, _, _} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, True{}}
    case IAlloca{+d, _} X64DefSt{c31, sc, _, stc, ha, hc}: X64DefSt{x64_m2(vd, d, c31), x64_m2(vd, d, sc), True{}, stc, ha, hc}
    case IFail{_} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{c31, sc, True{}, stc, ha, True{}}
def x64_def_ops(+vd: Nat, +arity: U32, ops: List<&2, IrOp>, st: X64DefSt) -> X64DefSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: x64_def_ops(vd, arity, t, x64_def_op(vd, arity, op, st))
def x64_def_term(fn_fid: U32, term: IrTerm, st: X64DefSt) -> X64DefSt:
  match term st:
    case TTailCall{fid, args} X64DefSt{c31, sc, nf, stc, ha, hc}:
      +is_st = Bool.and(U32.is_eq(fid, fn_fid), U32.is_le(b5k_u32_list_len(args), 64))
      X64DefSt{c31, sc, Bool.or(nf, Bool.not(is_st)), Bool.or(stc, is_st), ha, Bool.or(hc, Bool.not(is_st))}
    case TFail{_} X64DefSt{c31, sc, _, stc, ha, _}: X64DefSt{c31, sc, True{}, stc, ha, True{}}
    case _ _: st
def x64_def_blks(+vd: Nat, +arity: U32, +fn_fid: U32, blks: List<&2, IrBlock>, st: X64DefSt) -> X64DefSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}: x64_def_blks(vd, arity, fn_fid, t, x64_def_term(fn_fid, term, x64_def_ops(vd, arity, ops, st)))
type X64HiSt is Data:
  X64HiSt{hu: RaVec<Bool>, cm: RaVec<Bool>}
def x64_hi_set(vd: Nat, v: U32, hu: RaVec<Bool>) -> RaVec<Bool>:
  ra_vec_set(Bool, vd, v, True{}, hu)
def x64_hi_set_if(cond: Bool, vd: Nat, v: U32, hu: RaVec<Bool>) -> RaVec<Bool>:
  match cond:
    case True{}: ra_vec_set(Bool, vd, v, True{}, hu)
    case False{}: hu
def x64_hi_sets(+vd: Nat, vs: List<&2, U32>, hu: RaVec<Bool>) -> RaVec<Bool>:
  match vs:
    case Nil{}: hu
    case Con{v, t}: x64_hi_sets(vd, t, ra_vec_set(Bool, vd, v, True{}, hu))
def x64_hi_both(+vd: Nat, +v: U32, st: X64HiSt) -> X64HiSt:
  match st:
    case X64HiSt{hu, cm}: X64HiSt{x64_hi_set(vd, v, hu), x64_hi_set(vd, v, cm)}
def x64_hi_boths(+vd: Nat, +vs: List<&2, U32>, st: X64HiSt) -> X64HiSt:
  match st:
    case X64HiSt{hu, cm}: X64HiSt{x64_hi_sets(vd, vs, hu), x64_hi_sets(vd, vs, cm)}
def x64_hi_bin(+vd: Nat, +cval: RaVec<U32>, bop: U32, +l: U32, +r: U32, +rv: U32, hu: RaVec<Bool>) -> RaVec<Bool>:
  match bop:
    case 0: hu
    case 1: hu
    case 2: hu
    case 8: x64_hi_set(vd, r, hu)
    case 5: x64_hi_set_if(Bool.not(x64_is_cval(ra_vec_get(U32, vd, 0, l, cval))), vd, r, x64_hi_set_if(Bool.not(x64_is_cval(rv)), vd, l, hu))
    case _: x64_hi_set(vd, r, x64_hi_set(vd, l, hu))
def x64_hi_op(+vd: Nat, +cval: RaVec<U32>, op: IrOp, st: X64HiSt) -> X64HiSt:
  match op st:
    case IBin{_, +bop, +l, +r} X64HiSt{hu, cm}:
      +rv = ra_vec_get(U32, vd, 0, r, cval)
      +c = U32.sub(rv, 1)
      +cv = x64_is_cval(rv)
      r_fold = Bool.or(x64_is_simple_alu(bop), Bool.and(cv, Bool.or(Bool.and(Bool.or(U32.is_eq(bop, 8), U32.is_eq(bop, 9)), U32.is_lt(c, 64)), Bool.or(Bool.and(U32.is_eq(bop, 2), x64_is_mul_sr(c)), Bool.and(Bool.or(U32.is_eq(bop, 3), U32.is_eq(bop, 4)), U32.is_ge(c, 2))))))
      X64HiSt{x64_hi_bin(vd, cval, bop, l, r, rv, hu), x64_hi_set_if(Bool.not(r_fold), vd, r, x64_hi_set(vd, l, cm))}
    case IUn{_, +uop, +s} X64HiSt{hu, cm}:
      +sv = ra_vec_get(U32, vd, 0, s, cval)
      s_fold = Bool.and(U32.is_eq(uop, 4), Bool.and(x64_is_cval(sv), U32.is_le(U32.sub(sv, 1), 65535)))
      X64HiSt{x64_hi_set_if(U32.is_ne(uop, 0), vd, s, hu), x64_hi_set_if(Bool.not(s_fold), vd, s, cm)}
    case ICmp{_, +cop, +l, +r} X64HiSt{hu, cm}:
      X64HiSt{x64_hi_set(vd, r, x64_hi_set(vd, l, hu)), x64_hi_set_if(U32.is_ge(cop, 6), vd, r, x64_hi_set(vd, l, cm))}
    case ICopy{_, s} _: x64_hi_both(vd, s, st)
    case ICallDirect{_, _, args} _: x64_hi_boths(vd, args, st)
    case ICallClosure{_, _, caps} _: x64_hi_boths(vd, caps, st)
    case IApply{_, c, a} _: x64_hi_both(vd, a, x64_hi_both(vd, c, st))
    case ICtor{_, _, fs} _: x64_hi_boths(vd, fs, st)
    case ITake{_, s} _: x64_hi_both(vd, s, st)
    case ITag{_, s} _: x64_hi_both(vd, s, st)
    case IKeep{_, s} _: x64_hi_both(vd, s, st)
    case ISink{s} _: x64_hi_both(vd, s, st)
    case IReuse{_, sl, _, fs} _: x64_hi_boths(vd, fs, x64_hi_both(vd, sl, st))
    case IArrOp{_, +aop, Con{a, Con{i, Con{+cv, Nil{}}}}} X64HiSt{hu, cm}:
      is_rmw = Bool.and(Bool.or(U32.is_eq(aop, 80), U32.is_eq(aop, 81)), x64_is_cval(ra_vec_get(U32, vd, 0, cv, cval)))
      x64_hi_both(vd, i, x64_hi_both(vd, a, X64HiSt{x64_hi_set(vd, cv, hu), x64_hi_set_if(Bool.not(is_rmw), vd, cv, cm)}))
    case IArrOp{_, _, args} _: x64_hi_boths(vd, args, st)
    case ILoad{_, b, _} _: x64_hi_both(vd, b, st)
    case IStore{b, _, v} _: x64_hi_both(vd, v, x64_hi_both(vd, b, st))
    case IMutField{o, _, v} _: x64_hi_both(vd, v, x64_hi_both(vd, o, st))
    case _ _: st
def x64_hi_ops(+vd: Nat, +cval: RaVec<U32>, ops: List<&2, IrOp>, st: X64HiSt) -> X64HiSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: x64_hi_ops(vd, cval, t, x64_hi_op(vd, cval, op, st))
def x64_hi_term(vd: Nat, term: IrTerm, st: X64HiSt) -> X64HiSt:
  match term:
    case TBr{c, _, _}: x64_hi_both(vd, c, st)
    case TSwitch{s, _, _}: x64_hi_both(vd, s, st)
    case TRet{v}: x64_hi_both(vd, v, st)
    case TTailCall{_, args}: x64_hi_boths(vd, args, st)
    case _: st
def x64_hi_blks(+vd: Nat, +cval: RaVec<U32>, blks: List<&2, IrBlock>, st: X64HiSt) -> X64HiSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}: x64_hi_blks(vd, cval, t, x64_hi_term(vd, term, x64_hi_ops(vd, cval, ops, st)))
def x64_nu_set(+vd: Nat, +arity: U32, ao: RaVec<U32>, +v: U32, nu: RaVec<Bool>) -> RaVec<Bool>:
  +nu1 = x64_hi_set(vd, v, nu)
  +o = ra_vec_get(U32, vd, 0, v, ao)
  x64_hi_set_if(Bool.and(U32.is_gt(o, 0), U32.is_le(o, arity)), vd, U32.sub(o, 1), nu1)
def x64_nu_tc(+vd: Nat, args: List<&2, U32>, +idx: U32, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match args:
    case Nil{}: nu
    case Con{a, t}: x64_nu_tc(vd, t, U32.add(idx, 1), x64_hi_set_if(ra_vec_get(Bool, vd, False{}, idx, nu), vd, a, nu))
def x64_nu_bad_op(+vd: Nat, op: IrOp, bad: RaVec<Bool>) -> RaVec<Bool>:
  match op:
    case ITag{_, s}: x64_hi_set(vd, s, bad)
    case ITake{_, s}: x64_hi_set(vd, s, bad)
    case ICallDirect{_, _, args}: x64_hi_sets(vd, args, bad)
    case ICallClosure{_, _, caps}: x64_hi_sets(vd, caps, bad)
    case IApply{_, c, a}: x64_hi_set(vd, a, x64_hi_set(vd, c, bad))
    case _: bad
def x64_nu_bad_ops(+vd: Nat, ops: List<&2, IrOp>, bad: RaVec<Bool>) -> RaVec<Bool>:
  match ops:
    case Nil{}: bad
    case Con{op, t}: x64_nu_bad_ops(vd, t, x64_nu_bad_op(vd, op, bad))
def x64_nu_bad_blks(+vd: Nat, blks: List<&2, IrBlock>, bad: RaVec<Bool>) -> RaVec<Bool>:
  match blks:
    case Nil{}: bad
    case Con{IrBlock{_, ops, _}, t}: x64_nu_bad_blks(vd, t, x64_nu_bad_ops(vd, ops, bad))
def x64_nu_ops(+vd: Nat, +arity: U32, +ao: RaVec<U32>, +bad: RaVec<Bool>, ops: List<&2, IrOp>, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match ops:
    case Nil{}: nu
    case Con{IBin{_, bop, +l, +r}, t}:
      ok = Bool.or(U32.is_ne(bop, 0), Bool.not(Bool.or(ra_vec_get(Bool, vd, False{}, l, bad), ra_vec_get(Bool, vd, False{}, r, bad))))
      x64_nu_ops(vd, arity, ao, bad, t, Bool.pick(RaVec<Bool>, ok, x64_nu_set(vd, arity, ao, r, x64_nu_set(vd, arity, ao, l, nu)), nu))
    case Con{IUn{_, _, s}, t}: x64_nu_ops(vd, arity, ao, bad, t, x64_nu_set(vd, arity, ao, s, nu))
    case Con{ICmp{_, cop, l, r}, t}: x64_nu_ops(vd, arity, ao, bad, t, Bool.pick(RaVec<Bool>, U32.is_ge(cop, 1), x64_nu_set(vd, arity, ao, r, x64_nu_set(vd, arity, ao, l, nu)), nu))
    case Con{_, t}: x64_nu_ops(vd, arity, ao, bad, t, nu)
def x64_nu_term(+vd: Nat, +arity: U32, fn_fid: U32, ao: RaVec<U32>, term: IrTerm, +nu: RaVec<Bool>) -> RaVec<Bool>:
  match term:
    case TBr{c, _, _}: x64_nu_set(vd, arity, ao, c, nu)
    case TTailCall{fid, args}: Bool.pick(RaVec<Bool>, U32.is_eq(fid, fn_fid), x64_nu_tc(vd, args, 0, nu), nu)
    case _: nu
def x64_nu_blks(+vd: Nat, +arity: U32, +fn_fid: U32, +ao: RaVec<U32>, +bad: RaVec<Bool>, blks: List<&2, IrBlock>, nu: RaVec<Bool>) -> RaVec<Bool>:
  match blks:
    case Nil{}: nu
    case Con{IrBlock{_, ops, term}, t}: x64_nu_blks(vd, arity, fn_fid, ao, bad, t, x64_nu_term(vd, arity, fn_fid, ao, term, x64_nu_ops(vd, arity, ao, bad, ops, nu)))
def x64_run_nu(do_n: Bool, +vd: Nat, arity: U32, fn_fid: U32, ao: RaVec<U32>, +blks: List<&2, IrBlock>) -> RaVec<Bool>:
  match do_n:
    case False{}: RVEmpty{}
    case True{}: x64_nu_blks(vd, arity, fn_fid, ao, x64_nu_bad_blks(vd, blks, RVEmpty{}), blks, RVEmpty{})
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
def x64_hoist_kills(+vd: Nat, +arity: U32, ds: List<&2, U32>, st: X64HoistSt) -> X64HoistSt:
  match ds:
    case Nil{}: st
    case Con{d, t}: x64_hoist_kills(vd, arity, t, x64_hoist_kill(vd, arity, d, st))
def x64_hoist_prop_v(+vd: Nat, +arity: U32, +d: U32, +so: U32, st: X64HoistSt) -> X64HoistSt:
  match st:
    case X64HoistSt{+org, used, +bad, sca, wr}:
      +cur = ra_vec_get(U32, vd, 0, d, org)
      +is_p = U32.is_lt(d, arity)
      p_bad = Bool.and(is_p, U32.is_ne(so, U32.add(d, 1)))
      bad1 = Bool.pick(RaVec<Bool>, p_bad, ra_vec_set(Bool, vd, d, True{}, bad), bad)
      nv = Bool.pick(U32, U32.is_zero(cur), so, Bool.pick(U32, U32.is_eq(cur, so), cur, 4294967295))
      org1 = Bool.pick(RaVec<U32>, is_p, org, ra_vec_set(U32, vd, d, nv, org))
      X64HoistSt{org1, used, bad1, sca, wr}
def x64_hoist_prop(+vd: Nat, +arity: U32, +d: U32, s: U32, +st: X64HoistSt) -> X64HoistSt:
  x64_hoist_prop_v(vd, arity, d, x64_hoist_org(vd, s, st), st)
def x64_hoist_wrap(+vd: Nat, +arity: U32, +d: U32, f0: U32, +st: X64HoistSt) -> X64HoistSt:
  +fo = x64_hoist_org(vd, f0, st)
  ok = Bool.and(U32.is_gt(fo, 65536), U32.is_le(fo, U32.add(65536, arity)))
  Bool.pick(X64HoistSt, ok, x64_hoist_prop_v(vd, arity, d, U32.sub(fo, 65536), st), x64_hoist_kill(vd, arity, d, st))
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
    case Con{_, Con{_, Con{v, _}}}:
      Bool.or(Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81)), Bool.and(Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 74)), U32.is_eq(ra_vec_get(U32, vd, 0, v, sc), 2)))
    case _: False{}
def x64_hoist_op(+vd: Nat, +arity: U32, sc: RaVec<U32>, op: IrOp, +st: X64HoistSt) -> X64HoistSt:
  match op:
    case ICopy{d, s}: x64_hoist_prop(vd, arity, d, s, st)
    case IArrOp{+dsts, +aop, +args}:
      match dsts args:
        case Con{+da, t} Con{+a, _}:
          is_u = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81)))
          is_p = Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 75)), Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81)))
          +st1 = Bool.pick(X64HoistSt, is_u, x64_hoist_mark_use(vd, arity, a, x64_hoist_arr_nsc(vd, sc, aop, args), st), st)
          st2 = Bool.pick(X64HoistSt, is_p, x64_hoist_prop(vd, arity, da, a, st1), x64_hoist_kill(vd, arity, da, st1))
          x64_hoist_kills(vd, arity, t, st2)
        case _ _: x64_hoist_kills(vd, arity, dsts, st)
    case ITake{Con{+d0, t}, s}:
      +so = x64_hoist_org(vd, s, st)
      ok = Bool.and(U32.is_gt(so, 0), U32.is_le(so, arity))
      st1 = Bool.pick(X64HoistSt, ok, x64_hoist_prop_v(vd, arity, d0, U32.or(so, 65536), st), x64_hoist_kill(vd, arity, d0, st))
      x64_hoist_kills(vd, arity, t, st1)
    case ITake{Nil{}, _}: st
    case ICtor{d, _, Con{f0, _}}: x64_hoist_wrap(vd, arity, d, f0, st)
    case IReuse{d, _, _, Con{f0, _}}: x64_hoist_wrap(vd, arity, d, f0, st)
    case _:
      +d1 = x64_op_dst1(op)
      Bool.pick(X64HoistSt, U32.is_zero(d1), st, x64_hoist_kill(vd, arity, U32.sub(d1, 1), st))
def x64_hoist_ops(+vd: Nat, +arity: U32, +sc: RaVec<U32>, ops: List<&2, IrOp>, st: X64HoistSt) -> X64HoistSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: x64_hoist_ops(vd, arity, sc, t, x64_hoist_op(vd, arity, sc, op, st))
def x64_hoist_tc_args(+vd: Nat, args: List<&2, U32>, +idx: U32, +org: RaVec<U32>, +bad: RaVec<Bool>) -> RaVec<Bool>:
  match args:
    case Nil{}: bad
    case Con{a, t}:
      bad1 = Bool.pick(RaVec<Bool>, U32.is_ne(ra_vec_get(U32, vd, 0, a, org), U32.add(idx, 1)), ra_vec_set(Bool, vd, idx, True{}, bad), bad)
      x64_hoist_tc_args(vd, t, U32.add(idx, 1), org, bad1)
def x64_hoist_term(vd: Nat, fn_fid: U32, term: IrTerm, st: X64HoistSt) -> X64HoistSt:
  match term st:
    case TTailCall{fid, args} X64HoistSt{+org, used, +bad, sca, wr}:
      bad1 = Bool.pick(RaVec<Bool>, U32.is_eq(fid, fn_fid), x64_hoist_tc_args(vd, args, 0, org, bad), bad)
      X64HoistSt{org, used, bad1, sca, wr}
    case _ _: st
def x64_hoist_blks(+vd: Nat, +arity: U32, +fn_fid: U32, +sc: RaVec<U32>, blks: List<&2, IrBlock>, st: X64HoistSt) -> X64HoistSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}: x64_hoist_blks(vd, arity, fn_fid, sc, t, x64_hoist_term(vd, fn_fid, term, x64_hoist_ops(vd, arity, sc, ops, st)))
type X64HPick is Data:
  X64HPick{h0: U32, h0_sc: Bool, h1: U32, h1_sc: Bool, h2: U32, h2_sc: Bool}
def x64_hoist_pick(+vd: Nat, n: Nat, +idx: U32, +min_u: U32, +used: RaVec<U32>, +bad: RaVec<Bool>, +sca: RaVec<Bool>, +wr: RaVec<U32>, +h0: U32, +u0: U32, +h0_sc: Bool, +h1: U32, +u1: U32, +h1_sc: Bool, +h2: U32, +u2: U32, +h2_sc: Bool) -> X64HPick:
  match n:
    case 0n: X64HPick{h0, h0_sc, h1, h1_sc, h2, h2_sc}
    case 1n+p:
      +u = ra_vec_get(U32, vd, 0, idx, used)
      +ok = Bool.and(U32.is_ge(u, min_u), Bool.not(ra_vec_get(Bool, vd, False{}, idx, bad)))
      +is_sc = ra_vec_get(Bool, vd, False{}, idx, sca)
      +hid = Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, idx, wr), 2), U32.or(U32.add(idx, 1), 65536), U32.add(idx, 1))
      +b0 = Bool.and(ok, U32.is_gt(u, u0))
      +b1 = Bool.and(ok, Bool.and(Bool.not(b0), U32.is_gt(u, u1)))
      +b2 = Bool.and(ok, Bool.and(Bool.not(b0), Bool.and(Bool.not(b1), U32.is_gt(u, u2))))
      nh0 = Bool.pick(U32, b0, hid, h0)
      nu0 = Bool.pick(U32, b0, u, u0)
      ns0 = Bool.pick(Bool, b0, is_sc, h0_sc)
      nh1 = Bool.pick(U32, b0, h0, Bool.pick(U32, b1, hid, h1))
      nu1 = Bool.pick(U32, b0, u0, Bool.pick(U32, b1, u, u1))
      ns1 = Bool.pick(Bool, b0, h0_sc, Bool.pick(Bool, b1, is_sc, h1_sc))
      nh2 = Bool.pick(U32, Bool.or(b0, b1), h1, Bool.pick(U32, b2, hid, h2))
      nu2 = Bool.pick(U32, Bool.or(b0, b1), u1, Bool.pick(U32, b2, u, u2))
      ns2 = Bool.pick(Bool, Bool.or(b0, b1), h1_sc, Bool.pick(Bool, b2, is_sc, h2_sc))
      x64_hoist_pick(vd, p, U32.add(idx, 1), min_u, used, bad, sca, wr, nh0, nu0, ns0, nh1, nu1, ns1, nh2, nu2, ns2)
def x64_run_hoist(do_h: Bool, +vd: Nat, +arity: U32, fn_fid: U32, sc: RaVec<U32>, blocks: List<&2, IrBlock>) -> X64HoistSt:
  match do_h:
    case False{}: X64HoistSt{RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}}
    case True{}:
      org0 = x64_hoist_init_org(vd, U32.to_nat(arity), 0, RVEmpty{})
      x64_hoist_blks(vd, arity, fn_fid, sc, blocks, X64HoistSt{org0, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}})
def x64_init_hoist_f0(is_f0: Bool, +ctx: X64Ctx, l_skip: U32, +l_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_f0:
    case False{}: acc
    case True{}:
      c1 = x64_emit(XJcc{5, l_skip}, x64_emit(XCmpRI{0, 2}, x64_emit(XAluRI{5, 0, 127}, x64_emit(XShift{9, 0, 56, False{}}, x64_emit(XMovRR{0, 6}, acc)))))
      c2 = x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XMovRR{0, 6}, x64_load_mem(ctx, 7, c1))))
      c3 = x64_emit(XJcc{9, l_unsh}, x64_emit(XTestRR{6, 6}, c2))
      c4 = x64_emit(XLabel{l_unsh}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 0, 0}, x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, c3)))))
      x64_emit(XLoad{6, 7, 0}, x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, c4)))
def x64_init_hoist_go(is_z: Bool, +ctx: X64Ctx, +ha: U32, +dp: U32, mk: U32, acc: List<&2, X64Inst>, cold: List<&2, X64Inst>, +lbl: U32) -> X64Acc:
  match is_z:
    case True{}: X64Acc{acc, lbl, cold}
    case False{}:
      +l_skip = lbl
      +l_unsh = U32.add(lbl, 1)
      a0 = x64_load_vreg(ctx, 6, U32.sub(U32.and(ha, 65535), 1), acc)
      a1 = x64_init_hoist_f0(U32.is_ge(ha, 65536), ctx, l_skip, U32.add(lbl, 2), x64_hoist_store(dp, 0, x64_emit(XAluRR{7, 0, 0}, a0)))
      a2 = x64_emit(XJcc{5, l_skip}, x64_emit(XCmpRI{0, 6}, x64_emit(XAluRI{5, 0, 127}, x64_emit(XShift{9, 0, 56, False{}}, x64_emit(XMovRR{0, 6}, a1)))))
      a3 = x64_hoist_store(mk, 0, x64_emit(XAluRI{1, 0, 1}, x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, a2)))))))
      a4 = x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XMovRR{0, 6}, x64_load_mem(ctx, 7, a3))))
      a5 = x64_emit(XJcc{9, l_unsh}, x64_emit(XTestRR{6, 6}, a4))
      a6 = x64_emit(XLabel{l_unsh}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 0, 0}, x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, a5)))))
      a7 = x64_emit(XLabel{l_skip}, x64_hoist_store(dp, 7, x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, a6))))
      X64Acc{a7, U32.add(lbl, 3), cold}
def x64_init_hoist_one(ctx: X64Ctx, +ha: U32, dp: U32, mk: U32, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{acc, lbl, cold}: x64_init_hoist_go(U32.is_zero(ha), ctx, ha, dp, mk, acc, cold, lbl)
def x64_sw_pure_ops(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{IConst{_, _}, t}: x64_sw_pure_ops(t)
    case Con{ICmp{_, _, _, _}, t}: x64_sw_pure_ops(t)
    case Con{ITag{_, _}, t}: x64_sw_pure_ops(t)
    case Con{ICopy{_, _}, t}: x64_sw_pure_ops(t)
    case _: False{}
def x64_sw_ret_p(mb: Maybe<&2, IrBlock>, +ar: U32) -> U32:
  match mb:
    case Some{IrBlock{_, Nil{}, TRet{+rv}}}: Bool.pick(U32, U32.is_lt(rv, ar), U32.add(rv, 1), 0)
    case _: 0
def x64_sw_is_dead_z(mb: Maybe<&2, IrBlock>, +p: U32, +nzb: U32, +fid: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, _, TFail{_}}}: True{}
    case Some{IrBlock{_, ops, TBr{c, _, _}}}: Bool.or(U32.is_eq(fid, nzb), Bool.and(U32.is_eq(c, p), x64_sw_pure_ops(ops)))
    case _: U32.is_eq(fid, nzb)
def x64_sw_chk_z2(mb: Maybe<&2, IrBlock>, +ar: U32, +p: U32, +nzb: U32, +rp1: U32, +bm: RaVec<Maybe<&2, IrBlock>>) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, TBr{_, +tb, +fb}}}:
      Bool.and(x64_sw_pure_ops(ops), Bool.and(U32.is_eq(x64_sw_ret_p(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bm), ar), rp1), x64_sw_is_dead_z(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bm), p, nzb, fb)))
    case _: False{}
def x64_sw_chk_z(mb: Maybe<&2, IrBlock>, +ar: U32, +p: U32, +nzb: U32, +bm: RaVec<Maybe<&2, IrBlock>>) -> U32:
  match mb:
    case Some{IrBlock{_, Nil{}, TRet{+rv}}}: Bool.pick(U32, U32.is_lt(rv, ar), U32.add(rv, 1), 0)
    case Some{IrBlock{_, ops, TBr{_, +tb, +fb}}}:
      +rp1 = Bool.pick(U32, x64_sw_pure_ops(ops), x64_sw_ret_p(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bm), ar), 0)
      +ok = Bool.and(U32.is_ne(rp1, 0), Bool.or(U32.is_eq(x64_sw_ret_p(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bm), ar), rp1), x64_sw_chk_z2(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bm), ar, p, nzb, rp1, bm)))
      Bool.pick(U32, ok, rp1, 0)
    case _: 0
def x64_sw_find(+ar: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Con{IrBlock{0, +ops0, TBr{+c0, +tb, +fb}}, rest}:
      +zp = opt_esc_b0_pn(c0, ar, ops0, UM0{})
      +p = Bool.pick(U32, U32.is_lt(c0, ar), c0, U32.sub(zp, 1))
      +eb = Bool.pick(U32, U32.is_lt(c0, ar), fb, tb)
      +nzb = Bool.pick(U32, U32.is_lt(c0, ar), tb, fb)
      +ok = Bool.and(U32.is_le(ar, 5), Bool.and(Bool.or(U32.is_lt(c0, ar), U32.is_ne(zp, 0)), Bool.and(U32.is_lt(eb, 1024), x64_sw_pure_ops(ops0))))
      +bm = opt_index_blks(rest, RVEmpty{})
      +rp1 = Bool.pick(U32, ok, x64_sw_chk_z(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, eb, bm), ar, p, nzb, bm), 0)
      Bool.pick(U32, U32.is_ne(rp1, 0), U32.or(U32.shln(rp1, 4n), U32.add(p, 1)), 0)
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
    case Con{IrArm{+cid, +tgt}, t}:
      +ok = Bool.and(U32.is_ge(cid, 39), Bool.and(U32.is_lt(cid, 65536), Bool.and(U32.is_lt(tgt, 1024), x64_sw_is_pak_ret(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm), p))))
      Bool.pick(U32, ok, cid, x64_sw_arms_pak(p, bm, t))
def x64_sw_br_pak(+ar: U32, +c0: U32, +tb: U32, +fb: U32, +bm: RaVec<Maybe<&2, IrBlock>>, ops: List<&2, IrOp>, +cm: U32Map, +tm: U32Map) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IConst{d, v}, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, um_set(cm, d, U32.add(v, 1)), tm)
    case Con{ITag{d, +p}, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, Bool.pick(U32Map, U32.is_lt(p, ar), um_set(tm, d, U32.add(p, 1)), tm))
    case Con{ICmp{d, +cop, +l, +r}, t}:
      +p1 = um_get(tm, l)
      +k1 = um_get(cm, r)
      +cid = U32.sub(k1, 1)
      +tgt = Bool.pick(U32, U32.is_zero(cop), tb, fb)
      +ok = Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_ne(p1, 0), Bool.and(U32.is_ne(k1, 0), Bool.and(U32.is_ge(cid, 39), Bool.and(U32.is_lt(cid, 65536), Bool.and(U32.is_lt(tgt, 1024), x64_sw_is_pak_ret(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bm), U32.sub(p1, 1)))))))))
      Bool.pick(U32, ok, U32.or(16777216, U32.or(U32.shln(cid, 4n), p1)), x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, tm))
    case Con{_, t}: x64_sw_br_pak(ar, c0, tb, fb, bm, t, cm, tm)
def x64_sw_find_pak(+ar: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Con{IrBlock{0, +ops0, TSwitch{s, arms, _}}, rest}:
      +p1 = Bool.pick(U32, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_tag_p(ar, s, ops0), 0)
      +cid = Bool.pick(U32, U32.is_ne(p1, 0), x64_sw_arms_pak(U32.sub(p1, 1), opt_index_blks(rest, RVEmpty{}), arms), 0)
      Bool.pick(U32, U32.is_ne(cid, 0), U32.or(16777216, U32.or(U32.shln(cid, 4n), p1)), 0)
    case Con{IrBlock{0, +ops0, TBr{c0, tb, fb}}, rest}:
      Bool.pick(U32, Bool.and(U32.is_le(ar, 5), x64_sw_pure_ops(ops0)), x64_sw_br_pak(ar, c0, tb, fb, opt_index_blks(rest, RVEmpty{}), ops0, UM0{}, UM0{}), 0)
    case _: 0
def x64_sw_pre_go(is_pak: Bool, +code: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_pak:
    case True{}:
      +preg = x64_arg_reg(U32.sub(U32.and(code, 15), 1))
      +cid = U32.and(U32.shrn(code, 4n), 65535)
      a1 = x64_emit(XJcc{5, 2147614719}, x64_emit(XCmpRI{0, U32.or(65536, cid)}, x64_emit(XShift{9, 0, 40, False{}}, x64_emit(XMovRR{0, preg}, acc))))
      x64_emit(XLabel{2147614719}, x64_emit(XRet{}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XMovRR{0, preg}, a1)))))
    case False{}:
      +preg = x64_arg_reg(U32.sub(U32.and(code, 15), 1))
      +rreg = x64_arg_reg(U32.sub(U32.shrn(code, 4n), 1))
      x64_emit(XLabel{2147614719}, x64_emit(XRet{}, x64_emit(XMovRR{0, rreg}, x64_emit(XJcc{5, 2147614719}, x64_emit(XTestRR{preg, preg}, acc)))))
def x64_sw_pre(+sw: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match sw:
    case 0: acc
    case +code: x64_sw_pre_go(U32.is_ne(U32.and(code, 16777216), 0), code, acc)
def x64_bor_sh_one(hit: Bool, +r: U32, l_bor: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match hit:
    case True{}: x64_emit(XJcc{8, l_bor}, x64_emit(XTestRR{r, r}, acc))
    case False{}: acc
def x64_bor_sh_chk(n: Nat, +idx: U32, +bpm: U32, +l_bor: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      +r = x64_arg_reg(idx)
      +hit = U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0)
      x64_bor_sh_chk(p, U32.add(idx, 1), bpm, l_bor, x64_bor_sh_one(hit, r, l_bor, acc))
def x64_o2_prologue_pre(is_leaf: Bool, +sw: U32, +bpre: U32, +ar: U32, ce: List<&2, U32>, frame: U32, sd: U32, has_mr: Bool, has_md: Bool, mr: U32, md: U32) -> List<&2, X64Inst>:
  match is_leaf:
    case True{}: x64_push_pop_list(True{}, ce, Nil{})
    case False{}:
      a_pre = x64_bor_sh_chk(U32.to_nat(ar), 0, bpre, 2147614718, x64_sw_pre(sw, Nil{}))
      a0 = x64_push_pop_list(True{}, ce, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, a_pre)))
      x64_init_mem(has_mr, has_md, mr, md, x64_emit(XStore{5, sd, 7}, x64_emit(XSubRsp{frame}, a0)))
def x64_rm_cs_mask(+vd: Nat, n: Nat, +idx: U32, +rm: RaVec<U32>, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +r = ra_vec_get(U32, vd, 0, idx, rm)
      x64_rm_cs_mask(vd, p, U32.add(idx, 1), rm, U32.or(acc, U32.or(Bool.pick(U32, Bool.or(U32.is_eq(r, 8), U32.is_eq(r, 9)), 1, 0), Bool.pick(U32, Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11)), 2, 0))))
def x64_rm_has_reg(+vd: Nat, n: Nat, +idx: U32, +r: U32, +rm: RaVec<U32>, +c31: RaVec<U32>, +cm: RaVec<Bool>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p:
      skip = Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, idx, c31)), Bool.not(ra_vec_get(Bool, vd, False{}, idx, cm)))
      hit = Bool.and(Bool.not(skip), U32.is_eq(ra_vec_get(U32, vd, 0, idx, rm), r))
      Bool.or(hit, x64_rm_has_reg(vd, p, U32.add(idx, 1), r, rm, c31, cm))
def x64_pick_hreg(+want: Bool, allow_cs: Bool, +ce: List<&2, U32>, +cs: List<&2, U32>) -> U32:
  +r = Bool.pick(U32, want, x64_pick_free_callee(ce), 0)
  Bool.pick(U32, U32.is_ne(r, 0), r, Bool.pick(U32, Bool.and(want, allow_cs), Bool.pick(U32, x64_u32_in(10, cs), Bool.pick(U32, x64_u32_in(11, cs), 0, 11), 10), 0))
def x64_list_nonempty(xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{_, _}: True{}
def x64_blks_tail_scr(+ctx: X64Ctx, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, _, TTailCall{_, +args}}, t}:
      +s1 = x64_tail_src_locs(ctx, args, 0, Nil{})
      Bool.or(x64_list_nonempty(x64_tail_src_locs2(ctx, s1, args, 0, Nil{})), x64_blks_tail_scr(ctx, t))
    case Con{_, t}: x64_blks_tail_scr(ctx, t)
def x64_nu_sc_ops(+vd: Nat, +nu: RaVec<Bool>, +ao: RaVec<U32>, +ha: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IArrOp{Con{_, Con{dv, _}}, 72, Con{a, _}}, t}:
      Bool.or(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), ra_vec_get(Bool, vd, False{}, dv, nu)), x64_nu_sc_ops(vd, nu, ao, ha, t))
    case Con{IArrOp{Con{dv, _}, 78, Con{a, _}}, t}:
      Bool.or(Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), ra_vec_get(Bool, vd, False{}, dv, nu)), x64_nu_sc_ops(vd, nu, ao, ha, t))
    case Con{_, t}: x64_nu_sc_ops(vd, nu, ao, ha, t)
def x64_nu_sc_blks(+vd: Nat, +nu: RaVec<Bool>, +ao: RaVec<U32>, +ha: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, _}, t}: Bool.or(x64_nu_sc_ops(vd, nu, ao, ha, ops), x64_nu_sc_blks(vd, nu, ao, ha, t))
def x64_nu_sc_ha_go(cur: Bool, z: Bool, ha: U32, vd: Nat, nu: RaVec<Bool>, ao: RaVec<U32>, blks: List<&2, IrBlock>) -> Bool:
  match cur z:
    case True{} _: True{}
    case False{} True{}: False{}
    case False{} False{}: x64_nu_sc_blks(vd, nu, ao, ha, blks)
def x64_hmag_add(mg: X64Mag, st: X64HMag) -> X64HMag:
  match mg st:
    case X64Mag{+m, _, _} X64HMag{+m0, r0, +m1, r1, t0c, t0t, t0e, t0d, bor}:
      X64HMag{Bool.pick(U32, U32.is_zero(m0), m, m0), r0, Bool.pick(U32, Bool.and(U32.is_ne(m0, 0), Bool.and(U32.is_ne(m0, m), U32.is_zero(m1))), m, m1), r1, t0c, t0t, t0e, t0d, bor}
def x64_hmag_add_if(ok: Bool, c: U32, st: X64HMag) -> X64HMag:
  match ok:
    case True{}: x64_hmag_add(x64_magic(c), st)
    case False{}: st
def x64_hmag_ops(+vd: Nat, +c31: RaVec<U32>, ops: List<&2, IrOp>, st: X64HMag) -> X64HMag:
  match ops:
    case Nil{}: st
    case Con{IBin{_, +bop, _, r}, t}:
      +rv = ra_vec_get(U32, vd, 0, r, c31)
      +c = U32.sub(rv, 1)
      ok = Bool.and(Bool.or(U32.is_eq(bop, 3), U32.is_eq(bop, 4)), Bool.and(x64_is_cval(rv), Bool.and(U32.is_ge(c, 3), Bool.not(x64_is_pow2(c)))))
      x64_hmag_ops(vd, c31, t, x64_hmag_add_if(ok, c, st))
    case Con{_, t}: x64_hmag_ops(vd, c31, t, st)
def x64_hmag_blks(+vd: Nat, +c31: RaVec<U32>, blks: List<&2, IrBlock>, st: X64HMag) -> X64HMag:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: x64_hmag_blks(vd, c31, t, x64_hmag_ops(vd, c31, ops, st))
type X64T0 is Data:
  X64T0{c: U32, tb: U32, eb: U32}
def x64_b0_skip_c(+vd: Nat, +c31: RaVec<U32>, +cm: RaVec<Bool>, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Con{IConst{+d, v}, +t}:
      Bool.pick(List<&2, IrOp>, Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, d, c31)), Bool.not(ra_vec_get(Bool, vd, False{}, d, cm))), x64_b0_skip_c(vd, c31, cm, t), Con{IConst{d, v}, t})
    case xs: xs
def x64_b0_t0_ops(+vd: Nat, +arity: U32, +c31: RaVec<U32>, +uc: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +tb: U32, +eb: U32) -> X64T0:
  match ops:
    case Nil{}: X64T0{Bool.pick(U32, U32.is_lt(c, arity), U32.add(c, 1), 0), tb, eb}
    case Con{ICmp{+d, +cop, +p, +k}, Nil{}}:
      ok = Bool.and(Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_eq(d, c), U32.is_eq(ra_vec_get(U32, vd, 0, d, uc), 1))), Bool.and(U32.is_lt(p, arity), U32.is_eq(ra_vec_get(U32, vd, 0, k, c31), 1)))
      +is_z = U32.is_zero(cop)
      X64T0{Bool.pick(U32, ok, U32.add(p, 1), 0), Bool.pick(U32, is_z, eb, tb), Bool.pick(U32, is_z, tb, eb)}
    case Con{IConst{+k, 0}, Con{ICmp{+d, +cop, +p, k2}, Nil{}}}:
      ok = Bool.and(Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_eq(k, k2), U32.is_eq(ra_vec_get(U32, vd, 0, k, uc), 1))), Bool.and(Bool.and(U32.is_eq(d, c), U32.is_eq(ra_vec_get(U32, vd, 0, d, uc), 1)), U32.is_lt(p, arity)))
      +is_z = U32.is_zero(cop)
      X64T0{Bool.pick(U32, ok, U32.add(p, 1), 0), Bool.pick(U32, is_z, eb, tb), Bool.pick(U32, is_z, tb, eb)}
    case _: X64T0{0, 0, 0}
def x64_b0_t0(+vd: Nat, arity: U32, +c31: RaVec<U32>, cm: RaVec<Bool>, uc: RaVec<U32>, blks: List<&2, IrBlock>) -> X64T0:
  match blks:
    case Con{IrBlock{0, ops, TBr{c, tb, eb}}, _}: x64_b0_t0_ops(vd, arity, c31, uc, x64_b0_skip_c(vd, c31, cm, ops), c, tb, eb)
    case _: X64T0{0, 0, 0}
def x64_run_hmag_go(t0: X64T0, t0d: Bool, vd: Nat, c31: RaVec<U32>, blks: List<&2, IrBlock>) -> X64HMag:
  match t0:
    case X64T0{+c, tb, eb}: x64_hmag_blks(vd, c31, blks, X64HMag{0, 0, 0, 0, c, tb, eb, Bool.and(t0d, U32.is_ne(c, 0)), X64Bor{0, RVEmpty{}, x64_no_ha2()}})
def x64_run_hmag(stc: Bool, t0d: Bool, +vd: Nat, +arity: U32, +c31: RaVec<U32>, cm: RaVec<Bool>, +uc: RaVec<U32>, +blks: List<&2, IrBlock>) -> X64HMag:
  match stc:
    case False{}: X64HMag{0, 0, 0, 0, 0, 0, 0, False{}, X64Bor{0, RVEmpty{}, x64_no_ha2()}}
    case True{}: x64_run_hmag_go(x64_b0_t0(vd, arity, c31, cm, uc, blks), t0d, vd, c31, blks)
type X64BorP is Data:
  X64BorP{bm: RaVec<U32>, own: RaVec<Bool>}
def x64_bor_can_ops(+fid: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{ICallDirect{_, cfid, _}, t}: Bool.or(U32.is_eq(cfid, fid), x64_bor_can_ops(fid, t))
    case Con{_, t}: x64_bor_can_ops(fid, t)
def x64_bor_can(+fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, TTailCall{tfid, _}}, t}: Bool.or(Bool.or(U32.is_eq(tfid, fid), x64_bor_can_ops(fid, ops)), x64_bor_can(fid, t))
    case Con{IrBlock{_, ops, _}, t}: Bool.or(x64_bor_can_ops(fid, ops), x64_bor_can(fid, t))
def x64_bor_init(+vd: Nat, n: Nat, +idx: U32, bm: RaVec<U32>) -> RaVec<U32>:
  match n:
    case 0n: bm
    case 1n+p: x64_bor_init(vd, p, U32.add(idx, 1), ra_vec_set(U32, vd, idx, U32.shln(1, U32.to_nat(idx)), bm))
def x64_bor_prop_ds(+vd: Nat, +ar: U32, +m: U32, +o: Bool, ds: List<&2, U32>, st: X64BorP) -> X64BorP:
  match ds st:
    case Nil{} _: st
    case Con{+d, t} X64BorP{+bm, +own}: x64_bor_prop_ds(vd, ar, m, o, t, X64BorP{Bool.pick(RaVec<U32>, U32.is_zero(m), bm, ra_vec_set(U32, vd, d, U32.or(ra_vec_get(U32, vd, 0, d, bm), m), bm)), Bool.pick(RaVec<Bool>, Bool.or(o, U32.is_lt(d, ar)), ra_vec_set(Bool, vd, d, True{}, own), own)})
def x64_bor_prop_ops(+vd: Nat, +ar: U32, ops: List<&2, IrOp>, st: X64BorP) -> X64BorP:
  match ops st:
    case Nil{} _: st
    case Con{ICopy{d, +s}, t} X64BorP{+bm, +own}: x64_bor_prop_ops(vd, ar, t, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), Con{d, Nil{}}, X64BorP{bm, own}))
    case Con{IKeep{d, +s}, t} X64BorP{+bm, +own}: x64_bor_prop_ops(vd, ar, t, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), Con{d, Nil{}}, X64BorP{bm, own}))
    case Con{ITake{ds, +s}, t} X64BorP{+bm, +own}: x64_bor_prop_ops(vd, ar, t, x64_bor_prop_ds(vd, ar, ra_vec_get(U32, vd, 0, s, bm), ra_vec_get(Bool, vd, False{}, s, own), ds, X64BorP{bm, own}))
    case Con{IArrOp{ds, _, _}, t} X64BorP{bm, own}: x64_bor_prop_ops(vd, ar, t, x64_bor_prop_ds(vd, ar, 0, True{}, ds, X64BorP{bm, own}))
    case Con{op, t} X64BorP{bm, +own}:
      +d1 = x64_op_dst1(op)
      x64_bor_prop_ops(vd, ar, t, X64BorP{bm, Bool.pick(RaVec<Bool>, U32.is_zero(d1), own, ra_vec_set(Bool, vd, U32.sub(d1, 1), True{}, own))})
def x64_bor_prop_blks(+vd: Nat, +ar: U32, blks: List<&2, IrBlock>, st: X64BorP) -> X64BorP:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: x64_bor_prop_blks(vd, ar, t, x64_bor_prop_ops(vd, ar, ops, st))
type X64BorC is Data:
  X64BorC{bad: U32, htk: U32, hr: U32, hk: U32}
def x64_bor_mlist(+vd: Nat, +bm: RaVec<U32>, vs: List<&2, U32>) -> U32:
  match vs:
    case Nil{}: 0
    case Con{v, t}: U32.or(ra_vec_get(U32, vd, 0, v, bm), x64_bor_mlist(vd, bm, t))
def x64_bor_sargs(+vd: Nat, +bm: RaVec<U32>, args: List<&2, U32>, +idx: U32) -> U32:
  match args:
    case Nil{}: 0
    case Con{a, t}:
      +bit = U32.shln(1, U32.to_nat(idx))
      +m = ra_vec_get(U32, vd, 0, a, bm)
      U32.or(Bool.pick(U32, U32.is_eq(m, bit), 0, U32.or(bit, m)), x64_bor_sargs(vd, bm, t, U32.add(idx, 1)))
def x64_bor_mix(+vd: Nat, n: Nat, +idx: U32, +bm: RaVec<U32>, +own: RaVec<Bool>, +bad: U32) -> U32:
  match n:
    case 0n: bad
    case 1n+p:
      +m = ra_vec_get(U32, vd, 0, idx, bm)
      x64_bor_mix(vd, p, U32.add(idx, 1), bm, own, U32.or(bad, Bool.pick(U32, Bool.and(U32.is_ne(m, 0), Bool.or(ra_vec_get(Bool, vd, False{}, idx, own), U32.is_ne(U32.and(m, U32.sub(m, 1)), 0))), m, 0)))
def x64_bor_chk_ops(+vd: Nat, +fid: U32, +bm: RaVec<U32>, ops: List<&2, IrOp>, st: X64BorC) -> X64BorC:
  match ops st:
    case Nil{} _: st
    case Con{ITake{ds, s}, t} X64BorC{bad, htk, hr, hk}:
      +n = b5k_u32_list_len(ds)
      +m = ra_vec_get(U32, vd, 0, s, bm)
      x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, Bool.pick(U32, U32.is_gt(n, 8), m, 0)), U32.or(htk, Bool.pick(U32, Bool.and(U32.is_gt(n, 0), U32.is_le(n, 8)), m, 0)), hr, hk})
    case Con{IKeep{_, s}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{bad, htk, hr, U32.or(hk, ra_vec_get(U32, vd, 0, s, bm))})
    case Con{ICallDirect{_, cfid, +args}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, Bool.pick(U32, U32.is_eq(cfid, fid), x64_bor_sargs(vd, bm, args, 0), x64_bor_mlist(vd, bm, args))), htk, hr, hk})
    case Con{ICtor{_, _, fs}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, fs)), htk, hr, hk})
    case Con{IReuse{_, sl, _, fs}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, fs)), htk, U32.or(hr, ra_vec_get(U32, vd, 0, sl, bm)), hk})
    case Con{ICallClosure{_, _, caps}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, caps)), htk, hr, hk})
    case Con{IApply{_, c, a}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, U32.or(ra_vec_get(U32, vd, 0, c, bm), ra_vec_get(U32, vd, 0, a, bm))), htk, hr, hk})
    case Con{IArrOp{_, _, args}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, x64_bor_mlist(vd, bm, args)), htk, hr, hk})
    case Con{ILoad{_, b, _}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, ra_vec_get(U32, vd, 0, b, bm)), htk, hr, hk})
    case Con{IStore{b, _, v}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, U32.or(ra_vec_get(U32, vd, 0, b, bm), ra_vec_get(U32, vd, 0, v, bm))), htk, hr, hk})
    case Con{IMutField{o, _, v}, t} X64BorC{bad, htk, hr, hk}: x64_bor_chk_ops(vd, fid, bm, t, X64BorC{U32.or(bad, U32.or(ra_vec_get(U32, vd, 0, o, bm), ra_vec_get(U32, vd, 0, v, bm))), htk, hr, hk})
    case Con{_, t} _: x64_bor_chk_ops(vd, fid, bm, t, st)
def x64_bor_tc(+vd: Nat, +fid: U32, +bm: RaVec<U32>, term: IrTerm, st: X64BorC) -> X64BorC:
  match term st:
    case TTailCall{tfid, +args} X64BorC{bad, htk, hr, hk}: X64BorC{U32.or(bad, Bool.pick(U32, U32.is_eq(tfid, fid), x64_bor_sargs(vd, bm, args, 0), x64_bor_mlist(vd, bm, args))), htk, hr, hk}
    case _ _: st
def x64_bor_chk_blks(+vd: Nat, +fid: U32, +bm: RaVec<U32>, blks: List<&2, IrBlock>, st: X64BorC) -> X64BorC:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}: x64_bor_chk_blks(vd, fid, bm, t, x64_bor_tc(vd, fid, bm, term, x64_bor_chk_ops(vd, fid, bm, ops, st)))
def x64_scan_bor_fin(bm: RaVec<U32>, c: X64BorC) -> X64Bor:
  match c:
    case X64BorC{bad, htk, hr, +hk}:
      +bpm0 = U32.and(htk, U32.xor(U32.or(bad, U32.and(hr, U32.xor(hk, 4294967295))), 4294967295))
      +no_k = Bool.and(U32.is_ne(bpm0, 0), U32.is_zero(U32.and(bpm0, hk)))
      X64Bor{U32.or(bpm0, Bool.pick(U32, no_k, 65536, 0)), bm, x64_no_ha2()}
def x64_scan_bor_p2(+vd: Nat, nregs: U32, fid: U32, blks: List<&2, IrBlock>, p: X64BorP) -> X64Bor:
  match p:
    case X64BorP{+bm, own}: x64_scan_bor_fin(bm, x64_bor_chk_blks(vd, fid, bm, blks, X64BorC{x64_bor_mix(vd, U32.to_nat(nregs), 0, bm, own, 0), 0, 0, 0}))
def x64_scan_bor_go(ok: Bool, +vd: Nat, +ar: U32, nregs: U32, fid: U32, +blks: List<&2, IrBlock>) -> X64Bor:
  match ok:
    case False{}: X64Bor{0, RVEmpty{}, x64_no_ha2()}
    case True{}: x64_scan_bor_p2(vd, nregs, fid, blks, x64_bor_prop_blks(vd, ar, blks, x64_bor_prop_blks(vd, ar, blks, X64BorP{x64_bor_init(vd, U32.to_nat(ar), 0, RVEmpty{}), RVEmpty{}})))
def x64_bor_sv_one(is_reg: Bool, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_reg:
    case True{}: x64_emit(XStore{5, U32.sub(0, U32.add(24, U32.mul(idx, 8))), x64_arg_reg(idx)}, acc)
    case False{}: x64_emit(XStore{5, U32.sub(0, U32.add(24, U32.mul(idx, 8))), 0}, x64_emit(XLoad{0, 5, U32.add(16, U32.mul(U32.sub(idx, 5), 8))}, acc))
def x64_bor_push_extra(n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p: x64_bor_push_extra(p, U32.sub(idx, 1), x64_emit(XPush{0}, x64_emit(XLoad{0, 5, U32.add(16, U32.mul(U32.sub(idx, 5), 8))}, acc)))
def x64_bor_call(has_ex: Bool, +ar: U32, sym: String, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_ex:
    case False{}: x64_emit(XCallSym{sym}, acc)
    case True{}:
      +ex = U32.sub(ar, 5)
      +odd = U32.is_eq(U32.and(ex, 1), 1)
      e1 = x64_bor_push_extra(U32.to_nat(ex), U32.sub(ar, 1), x64_emit_if(odd, XSubRsp{8}, acc))
      x64_emit(XAddRsp{U32.mul(U32.add(ex, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, e1))
def x64_bor_wrap_go(+wctx: X64Ctx, is_sv: Bool, n: Nat, +idx: U32, +bpm: U32, st: X64Acc) -> X64Acc:
  match is_sv n st:
    case True{} 0n _: st
    case False{} 0n X64Acc{a2, lbl, cold}: X64Acc{x64_emit_epilogue(x64_emit(XLoad{0, 5, U32.sub(0, 16)}, a2)), lbl, cold}
    case True{} 1n+p X64Acc{+acc, lbl, cold}: x64_bor_wrap_go(wctx, True{}, p, U32.add(idx, 1), bpm, X64Acc{Bool.pick(List<&2, X64Inst>, U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0), x64_bor_sv_one(U32.is_lt(idx, 5), idx, acc), acc), lbl, cold})
    case False{} 1n+p X64Acc{+acc, +lbl, +cold}: x64_bor_wrap_go(wctx, False{}, p, U32.add(idx, 1), bpm, Bool.pick(X64Acc, U32.is_ne(U32.and(bpm, U32.shln(1, U32.to_nat(idx))), 0), X64Acc{x64_rc_shared(False{}, wctx, 6, lbl, U32.add(lbl, 1), x64_emit(XLoad{6, 5, U32.sub(0, U32.add(24, U32.mul(idx, 8)))}, acc)), U32.add(lbl, 2), x64_emit(XJmp{lbl}, x64_emit(XCallSym{"p111_rt_sink"}, x64_emit(XLoad{7, 5, U32.sub(0, 8)}, x64_emit(XLabel{U32.add(lbl, 1)}, cold))))}, X64Acc{acc, lbl, cold}))
def x64_make_bor_wrap(+name: String, +ar: U32, +bpm: U32) -> X64Fn:
  +wctx = x64_mk_ctx(True{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, 96, Nil{}, 0, x64_empty_meta())
  X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_bor_wrap_go(wctx, False{}, U32.to_nat(ar), 0, bpm, X64Acc{x64_emit(XStore{5, U32.sub(0, 16), 0}, x64_bor_call(U32.is_gt(ar, 5), ar, String.append("$bor.", name), x64_acc_insts(x64_bor_wrap_go(wctx, True{}, U32.to_nat(ar), 0, bpm, X64Acc{x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{96}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{})))), 1, Nil{}})))), 1, Nil{}})))}
def x64_ver_chk_dp(+ha: U32, +dp: U32, +l_slow: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Bool.pick(List<&2, X64Inst>, U32.is_zero(ha), acc, x64_emit(XJcc{4, l_slow}, Bool.pick(List<&2, X64Inst>, U32.is_lt(dp, 16), x64_emit(XTestRR{dp, dp}, acc), x64_emit(XTestRR{0, 0}, x64_emit(XLoad{0, 5, dp}, acc)))))
def x64_shift_arms(+off: U32, arms: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>:
  match arms:
    case Nil{}: Nil{}
    case Con{IrArm{tg, tgt}, t}: Con{IrArm{tg, U32.add(tgt, off)}, x64_shift_arms(off, t)}
def x64_shift_term(+off: U32, term: IrTerm) -> IrTerm:
  match term:
    case TJmp{tgt}: TJmp{U32.add(tgt, off)}
    case TBr{c, tb, eb}: TBr{c, U32.add(tb, off), U32.add(eb, off)}
    case TSwitch{s, arms, db}: TSwitch{s, x64_shift_arms(off, arms), U32.add(db, off)}
    case _: term
def x64_shift_blks(+off: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{IrBlock{U32.add(id, off), ops, x64_shift_term(off, term)}, x64_shift_blks(off, t)}
def x64_ctx_ver(nc: Bool, +off: U32, ctx: X64Ctx) -> X64Ctx:
  match ctx:
    case X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, m0, s0, h1, d1, m1, s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, +t0c, t0t, t0e, t0d, X64Bor{bpm, bm, X64Ha2{h2, d2, m2, s2, _, _}}}}}}:
      +sh = Bool.pick(U32, U32.is_ne(t0c, 0), off, 0)
      X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, m0, s0, h1, d1, m1, s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, t0c, U32.add(t0t, sh), U32.add(t0e, sh), t0d, X64Bor{bpm, bm, X64Ha2{h2, d2, m2, s2, nc, off}}}}}}
def x64_rm_other_has_reg(+vd: Nat, n: Nat, +idx: U32, +r: U32, +skip_v: U32, +rm: RaVec<U32>, +c31: RaVec<U32>, +cm: RaVec<Bool>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p:
      skip = Bool.or(U32.is_eq(idx, skip_v), Bool.and(x64_is_cval(ra_vec_get(U32, vd, 0, idx, c31)), Bool.not(ra_vec_get(Bool, vd, False{}, idx, cm))))
      hit = Bool.and(Bool.not(skip), U32.is_eq(ra_vec_get(U32, vd, 0, idx, rm), r))
      Bool.or(hit, x64_rm_other_has_reg(vd, p, U32.add(idx, 1), r, skip_v, rm, c31, cm))
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
def x64_rdx_safe_ops(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{op, t}: Bool.and(x64_rdx_safe_op(op), x64_rdx_safe_ops(t))
def x64_rdx_ops_has_arr(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IArrOp{_, _, _}, _}: True{}
    case Con{_, t}: x64_rdx_ops_has_arr(t)
def x64_rdx_safe_ret_ops(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{op, +t}:
      Bool.pick(Bool, x64_rdx_safe_op(op), x64_rdx_safe_ret_ops(t), Bool.not(x64_rdx_ops_has_arr(t)))
def x64_rdx_safe_blks(+fn_fid: U32, +rm: RaVec<U32>, +vd: Nat, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{_, ops, TRet{_}}, t}: Bool.and(x64_rdx_safe_ret_ops(ops), x64_rdx_safe_blks(fn_fid, rm, vd, t))
    case Con{IrBlock{_, ops, TTailCall{fid, _}}, t}: Bool.and(Bool.and(U32.is_eq(fid, fn_fid), x64_rdx_safe_ops(ops)), x64_rdx_safe_blks(fn_fid, rm, vd, t))
    case Con{IrBlock{_, ops, TBr{c, _, _}}, t}: Bool.and(Bool.and(x64_is_gpr(ra_vec_get(U32, vd, 0, c, rm)), x64_rdx_safe_ops(ops)), x64_rdx_safe_blks(fn_fid, rm, vd, t))
    case Con{IrBlock{_, ops, _}, t}: Bool.and(x64_rdx_safe_ops(ops), x64_rdx_safe_blks(fn_fid, rm, vd, t))
type X64Nw is Data:
  X64Nw{kind: U32, a: U32, b: U32, off: U32}
def x64_nw_is_ha(+vd: Nat, +ao: RaVec<U32>, +ha: U32, +aop: U32, a: U32) -> Bool:
  Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, a, ao), ha), Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81))))
def x64_nw_find_op(+is_and: Bool, +vd: Nat, +c31: RaVec<U32>, +v: U32, +p: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{+d, +bop, +l, +r}, t}:
      +cr = ra_vec_get(U32, vd, 0, r, c31)
      +cl = ra_vec_get(U32, vd, 0, l, c31)
      h1 = Bool.and(Bool.not(is_and), Bool.and(U32.is_zero(bop), Bool.and(U32.is_eq(d, v), Bool.and(U32.is_eq(l, p), Bool.and(U32.is_ge(cr, 1), U32.is_le(cr, 17))))))
      h2 = Bool.and(Bool.not(is_and), Bool.and(U32.is_zero(bop), Bool.and(U32.is_eq(d, v), Bool.and(U32.is_eq(r, p), Bool.and(U32.is_ge(cl, 1), U32.is_le(cl, 17))))))
      h3 = Bool.and(is_and, Bool.and(U32.is_eq(bop, 5), Bool.and(U32.is_eq(d, v), Bool.and(U32.is_ge(cr, 1), U32.is_le(cr, 65536)))))
      Bool.pick(U32, Bool.or(h1, h3), cr, Bool.pick(U32, h2, cl, x64_nw_find_op(is_and, vd, c31, v, p, t)))
    case Con{_, t}: x64_nw_find_op(is_and, vd, c31, v, p, t)
def x64_nw_find_blks(+is_and: Bool, +vd: Nat, +c31: RaVec<U32>, +v: U32, +p: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{_, ops, _}, t}:
      +r = x64_nw_find_op(is_and, vd, c31, v, p, ops)
      Bool.pick(U32, U32.is_ne(r, 0), r, x64_nw_find_blks(is_and, vd, c31, v, p, t))
def x64_nw_param_kind(+vd: Nat, +c31: RaVec<U32>, +fid: U32, +p: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, +k: U32) -> U32:
  match blks:
    case Nil{}: k
    case Con{IrBlock{_, _, TTailCall{tfid, args}}, t}:
      +a = x64_u32_nth(args, U32.to_nat(p))
      +ac = x64_nw_find_blks(True{}, vd, c31, a, p, all_blks)
      nk = Bool.pick(U32, U32.is_ne(tfid, fid), 99, Bool.pick(U32, U32.is_eq(a, p), Bool.pick(U32, U32.is_zero(k), 1, k), Bool.pick(U32, U32.is_eq(x64_nw_find_blks(False{}, vd, c31, a, p, all_blks), 2), Bool.pick(U32, U32.is_le(k, 2), 2, 99), Bool.pick(U32, U32.is_ne(ac, 0), Bool.pick(U32, Bool.or(U32.is_le(k, 1), U32.is_eq(k, U32.add(100, ac))), U32.add(100, ac), 99), 99))))
      x64_nw_param_kind(vd, c31, fid, p, all_blks, t, nk)
    case Con{_, t}: x64_nw_param_kind(vd, c31, fid, p, all_blks, t, k)
def x64_nw_min_cmp(ops: List<&2, IrOp>, +c: U32, +vt: U32, +ve: U32, +ar: U32) -> U32:
  match ops:
    case Nil{}: 0
    case Con{ICmp{+cd, +cop, +l, +r}, Nil{}}:
      ok1 = Bool.and(U32.is_eq(cd, c), Bool.and(Bool.or(U32.is_eq(cop, 2), U32.is_eq(cop, 3)), Bool.and(U32.is_eq(vt, l), Bool.and(U32.is_eq(ve, r), U32.is_lt(r, ar)))))
      ok2 = Bool.and(U32.is_eq(cd, c), Bool.and(Bool.or(U32.is_eq(cop, 4), U32.is_eq(cop, 5)), Bool.and(U32.is_eq(ve, l), Bool.and(U32.is_eq(vt, r), U32.is_lt(r, ar)))))
      Bool.pick(U32, Bool.or(ok1, ok2), U32.add(r, 1), 0)
    case Con{_, t}: x64_nw_min_cmp(t, c, vt, ve, ar)
def x64_nw_find_min_k1(blks: List<&2, IrBlock>, +m: U32, +ar: U32) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{_, ops0, TBr{c, +tb, +eb}}, Con{IrBlock{+i1, Con{ICopy{+d1, +v1}, Nil{}}, TJmp{+j1}}, Con{IrBlock{+i2, Con{ICopy{+d2, +v2}, Nil{}}, TJmp{+j2}}, t}}}:
      +o1 = Bool.and(U32.is_eq(i1, tb), U32.is_eq(i2, eb))
      +hit = Bool.and(Bool.and(U32.is_eq(d1, m), U32.is_eq(d2, m)), Bool.and(U32.is_eq(j1, j2), Bool.or(o1, Bool.and(U32.is_eq(i1, eb), U32.is_eq(i2, tb)))))
      +k1 = Bool.pick(U32, hit, x64_nw_min_cmp(ops0, c, Bool.pick(U32, o1, v1, v2), Bool.pick(U32, o1, v2, v1), ar), 0)
      Bool.pick(U32, U32.is_ne(k1, 0), k1, x64_nw_find_min_k1(Con{IrBlock{i1, Con{ICopy{d1, v1}, Nil{}}, TJmp{j1}}, Con{IrBlock{i2, Con{ICopy{d2, v2}, Nil{}}, TJmp{j2}}, t}}, m, ar))
    case Con{_, t}: x64_nw_find_min_k1(t, m, ar)
def x64_nw_chk_mono_ops(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +pj: U32, +all_blks: List<&2, IrBlock>, ops: List<&2, IrOp>, +mo: U32) -> U32:
  match ops:
    case Nil{}: mo
    case Con{IArrOp{_, aop, Con{a, Con{+i, _}}}, t}:
      +r = Bool.pick(U32, x64_nw_is_ha(vd, ao, ha, aop, a), Bool.pick(U32, U32.is_eq(i, pj), 1, x64_nw_find_blks(False{}, vd, c31, i, pj, all_blks)), 1)
      x64_nw_chk_mono_ops(vd, c31, ao, ha, pj, all_blks, t, Bool.pick(U32, Bool.or(U32.is_zero(mo), U32.is_zero(r)), 0, U32.max(mo, r)))
    case Con{_, t}: x64_nw_chk_mono_ops(vd, c31, ao, ha, pj, all_blks, t, mo)
def x64_nw_blk_uses_ha(+vd: Nat, +ao: RaVec<U32>, +ha: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IArrOp{_, aop, Con{a, _}}, t}: Bool.or(x64_nw_is_ha(vd, ao, ha, aop, a), x64_nw_blk_uses_ha(vd, ao, ha, t))
    case Con{_, t}: x64_nw_blk_uses_ha(vd, ao, ha, t)
def x64_nw_chk_mono_blks(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +t0e: U32, +pj: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, +mo: U32) -> U32:
  match blks:
    case Nil{}: mo
    case Con{IrBlock{id, +ops, _}, t}:
      +m1 = x64_nw_chk_mono_ops(vd, c31, ao, ha, pj, all_blks, ops, U32.and(mo, 65535))
      +ex = Bool.or(U32.is_ge(mo, 65536), Bool.and(U32.is_eq(id, t0e), x64_nw_blk_uses_ha(vd, ao, ha, ops)))
      x64_nw_chk_mono_blks(vd, c31, ao, ha, t0e, pj, all_blks, t, Bool.pick(U32, U32.is_zero(m1), 0, U32.or(m1, Bool.pick(U32, ex, 65536, 0))))
def x64_nw_chk_mask_ops(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +pj: U32, +cmax: U32, +all_ops: List<&2, IrOp>, ops: List<&2, IrOp>, +ok: Bool) -> Bool:
  match ops:
    case Nil{}: ok
    case Con{IArrOp{_, aop, Con{a, Con{+i, _}}}, t}:
      +ac = x64_nw_find_op(True{}, vd, c31, i, 0, all_ops)
      x64_nw_chk_mask_ops(vd, c31, ao, ha, pj, cmax, all_ops, t, Bool.and(ok, Bool.or(Bool.not(x64_nw_is_ha(vd, ao, ha, aop, a)), Bool.or(U32.is_eq(i, pj), Bool.and(U32.is_ne(ac, 0), U32.is_le(U32.sub(ac, 1), cmax))))))
    case Con{_, t}: x64_nw_chk_mask_ops(vd, c31, ao, ha, pj, cmax, all_ops, t, ok)
def x64_nw_chk_mask_blks(+vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +pj: U32, +cmax: U32, blks: List<&2, IrBlock>, +ok: Bool) -> Bool:
  match blks:
    case Nil{}: ok
    case Con{IrBlock{_, +ops, _}, t}: x64_nw_chk_mask_blks(vd, c31, ao, ha, pj, cmax, t, x64_nw_chk_mask_ops(vd, c31, ao, ha, pj, cmax, ops, ops, ok))
def x64_nw_find_add_min(+vd: Nat, +ar: U32, +all_blks: List<&2, IrBlock>, +idx: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{+d, 0, +l, +r}, t}:
      +k1 = Bool.pick(U32, Bool.and(U32.is_eq(d, idx), U32.is_lt(l, ar)), x64_nw_find_min_k1(all_blks, r, ar), 0)
      +k2 = Bool.pick(U32, Bool.and(U32.is_eq(d, idx), U32.is_lt(r, ar)), x64_nw_find_min_k1(all_blks, l, ar), 0)
      Bool.pick(U32, U32.is_ne(k1, 0), U32.or(U32.shln(U32.add(l, 1), 16n), k1), Bool.pick(U32, U32.is_ne(k2, 0), U32.or(U32.shln(U32.add(r, 1), 16n), k2), x64_nw_find_add_min(vd, ar, all_blks, idx, t)))
    case Con{_, t}: x64_nw_find_add_min(vd, ar, all_blks, idx, t)
def x64_nw_chk_min_ops(+vd: Nat, +ao: RaVec<U32>, +ha: U32, +ar: U32, +all_blks: List<&2, IrBlock>, +all_ops: List<&2, IrOp>, ops: List<&2, IrOp>, +pair: U32) -> U32:
  match ops:
    case Nil{}: pair
    case Con{IArrOp{_, aop, Con{a, Con{i, _}}}, t}:
      +is_h = x64_nw_is_ha(vd, ao, ha, aop, a)
      +r = Bool.pick(U32, is_h, x64_nw_find_add_min(vd, ar, all_blks, i, all_ops), 4294967295)
      x64_nw_chk_min_ops(vd, ao, ha, ar, all_blks, all_ops, t, Bool.pick(U32, Bool.not(is_h), pair, Bool.pick(U32, U32.is_zero(r), 4294967294, Bool.pick(U32, U32.is_zero(pair), r, Bool.pick(U32, U32.is_eq(pair, r), pair, 4294967294)))))
    case Con{_, t}: x64_nw_chk_min_ops(vd, ao, ha, ar, all_blks, all_ops, t, pair)
def x64_nw_chk_min_blks(+vd: Nat, +ao: RaVec<U32>, +ha: U32, +ar: U32, +all_blks: List<&2, IrBlock>, blks: List<&2, IrBlock>, +pair: U32) -> U32:
  match blks:
    case Nil{}: pair
    case Con{IrBlock{_, +ops, _}, t}: x64_nw_chk_min_blks(vd, ao, ha, ar, all_blks, t, x64_nw_chk_min_ops(vd, ao, ha, ar, all_blks, ops, ops, pair))
def x64_nw_scan_params(n: Nat, +p: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +ha: U32, +fid: U32, +t0d: Bool, +t0e: U32, +pn: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  match n:
    case 0n: X64Nw{0, 0, 0, 0}
    case 1n+r:
      +pk = x64_nw_param_kind(vd, c31, fid, p, blks, blks, 0)
      +mo = Bool.pick(U32, Bool.and(t0d, U32.is_eq(pk, 2)), x64_nw_chk_mono_blks(vd, c31, ao, ha, t0e, p, blks, blks, 1), 0)
      +cm = Bool.pick(U32, U32.is_gt(pk, 100), U32.sub(pk, 101), 0)
      +k1 = Bool.pick(U32, U32.is_ge(mo, 65536), 1, 4)
      Bool.pick(X64Nw, U32.is_ne(mo, 0), X64Nw{k1, p, pn, U32.sub(U32.and(mo, 65535), 1)}, Bool.pick(X64Nw, Bool.and(U32.is_gt(pk, 100), x64_nw_chk_mask_blks(vd, c31, ao, ha, p, cm, blks, True{})), X64Nw{2, p, cm, 0}, x64_nw_scan_params(r, U32.add(p, 1), vd, c31, ao, ha, fid, t0d, t0e, pn, blks)))
def x64_nw_analyze_fin(r1: X64Nw, +ha: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  match r1:
    case X64Nw{0, _, _, _}:
      +pr = x64_nw_chk_min_blks(vd, ao, ha, ar, blks, blks, 0)
      +row = U32.sub(U32.shrn(pr, 16n), 1)
      +k1 = U32.sub(U32.and(pr, 65535), 1)
      ok = Bool.and(Bool.and(U32.is_ne(pr, 0), U32.is_lt(pr, 4294967294)), Bool.and(U32.is_eq(x64_nw_param_kind(vd, c31, fid, row, blks, blks, 0), 1), U32.is_eq(x64_nw_param_kind(vd, c31, fid, k1, blks, blks, 0), 1)))
      Bool.pick(X64Nw, ok, X64Nw{3, row, k1, 0}, X64Nw{0, 0, 0, 0})
    case _: r1
def x64_nw_analyze_one(+ha: U32, +vd: Nat, +c31: RaVec<U32>, +ao: RaVec<U32>, +fid: U32, +ar: U32, +t0d: Bool, +t0e: U32, +pn: U32, +blks: List<&2, IrBlock>) -> X64Nw:
  Bool.pick(X64Nw, U32.is_zero(ha), X64Nw{0, 0, 0, 0}, x64_nw_analyze_fin(x64_nw_scan_params(U32.to_nat(ar), 0, vd, c31, ao, ha, fid, t0d, t0e, pn, blks), ha, vd, c31, ao, fid, ar, blks))
def x64_nw_cmp_mk(+mk: U32, +l_slow: U32, +add1: Bool, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +a1 = Bool.pick(List<&2, X64Inst>, U32.is_lt(mk, 16), Bool.pick(List<&2, X64Inst>, add1, x64_emit(XCmpRR{0, 1}, x64_emit(XAluRI{0, 1, 1}, x64_emit(XMovRR{1, mk}, acc))), x64_emit(XCmpRR{0, mk}, acc)), x64_emit(XCmpRR{0, 1}, x64_emit_if(add1, XAluRI{0, 1, 1}, x64_emit(XLoad{1, 5, mk}, acc))))
  x64_emit(XJcc{7, l_slow}, a1)
def x64_nw_emit_chk(+ctx: X64Ctx, +mk: U32, nw: X64Nw, +l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match nw:
    case X64Nw{1, pj, pn, +off}: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit_if(U32.is_ne(off, 0), XAluRI{0, 0, off}, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, pn, x64_load_vreg(ctx, 0, pj, acc)))))
    case X64Nw{4, pj, pn, +off}: x64_nw_cmp_mk(mk, l_slow, True{}, x64_emit_if(U32.is_ne(off, 0), XAluRI{0, 0, off}, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, pn, x64_load_vreg(ctx, 0, pj, acc)))))
    case X64Nw{2, pj, cmax, _}: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XMovRI32{0, cmax}, x64_nw_cmp_mk(mk, l_slow, False{}, x64_load_vreg(ctx, 0, pj, acc))))
    case X64Nw{3, row, k1, _}: x64_nw_cmp_mk(mk, l_slow, False{}, x64_emit(XAluRR{0, 0, 1}, x64_load_vreg(ctx, 1, k1, x64_load_vreg(ctx, 0, row, acc))))
    case _: acc
def x64_ctx_ver_nw(nc: Bool, +off: U32, +mk1_ov: U32, +nw0: Bool, +nw1: Bool, +nw2: Bool, ctx: X64Ctx) -> X64Ctx:
  match ctx:
    case X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, m0, s0, h1, d1, m1, s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, +t0c, t0t, t0e, t0d, X64Bor{bpm, bm, X64Ha2{h2, d2, m2, s2, _, _}}}}}}:
      +sh = Bool.pick(U32, U32.is_ne(t0c, 0), off, 0)
      X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, Bool.pick(U32, nw0, 65535, m0), s0, h1, d1, Bool.pick(U32, nw1, 65535, Bool.pick(U32, U32.is_ne(mk1_ov, 0), mk1_ov, m1)), s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, t0c, U32.add(t0t, sh), U32.add(t0e, sh), t0d, X64Bor{bpm, bm, X64Ha2{h2, d2, Bool.pick(U32, nw2, 65535, m2), s2, nc, off}}}}}}
def x64_nw_is_ok(nw: X64Nw) -> Bool:
  match nw:
    case X64Nw{0, _, _, _}: False{}
    case _: True{}
def x64_ctx_ha1_mk_sp(ctx: X64Ctx) -> U32:
  match ctx:
    case X64Ctx{True{}, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, _, +d0, _, _, +h1, +d1, +m1, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{+h2, _, _, _, _, _}}}}}}:
      Bool.pick(U32, Bool.and(Bool.and(U32.is_ne(h1, 0), U32.is_zero(h2)), Bool.and(U32.is_lt(d0, 16), Bool.and(U32.is_lt(d1, 16), U32.is_ge(m1, 16)))), m1, 0)
    case _: 0
def x64_ver_pre_chks(ctx: X64Ctx, st: X64Acc) -> X64Acc:
  match ctx st:
    case X64Ctx{_, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, _, h0, d0, _, _, h1, d1, _, _, _, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, _, _, _, _, X64Bor{_, _, X64Ha2{h2, d2, _, _, _, _}}}}}} X64Acc{acc, lbl, cold}:
      X64Acc{x64_ver_chk_dp(h2, d2, 65536, x64_ver_chk_dp(h1, d1, 65536, x64_ver_chk_dp(h0, d0, 65536, acc))), lbl, cold}
def x64_emit_ver_fin(ctx_s: X64Ctx, fn_map: Map<&2, String>, uc: RaVec<U32>, blocks: List<&2, IrBlock>, st1: X64Acc) -> X64Acc:
  match st1:
    case X64Acc{insts1, +lbl1, cold1}:
      st2 = x64_emit_blocks(ctx_s, fn_map, uc, RVEmpty{}, RVEmpty{}, x64_shift_blks(65536, blocks), 0n, X64Acc{cold1, lbl1, Nil{}})
      X64Acc{insts1, lbl1, x64_acc_insts(st2)}
def x64_acc_emit_if(cond: Bool, inst: X64Inst, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{a0, l0, c0}: X64Acc{x64_emit_if(cond, inst, a0), l0, c0}
def x64_nw_emit_chks(+ctx: X64Ctx, m0: U32, nw0: X64Nw, m1: U32, nw1: X64Nw, m2: U32, nw2: X64Nw, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{a0, l0, c0}: X64Acc{x64_nw_emit_chk(ctx, m2, nw2, 65536, x64_nw_emit_chk(ctx, m1, nw1, 65536, x64_nw_emit_chk(ctx, m0, nw0, 65536, a0))), l0, c0}
def x64_emit_ver_nw(+ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, +vd: Nat, +fn_fid: U32, +arity: U32, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc) -> X64Acc:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, _, _, X64Meta{_, _, _, _, +ao, +h0, _, +m0, _, +h1, _, +m1, _, +c31, _, X64R2{_, _, _, _, _, _, _, X64HMag{_, _, _, _, +t0c, _, +t0e, +t0d, X64Bor{_, _, X64Ha2{+h2, _, +m2, _, _, _}}}}}}:
      +pn = Bool.pick(U32, U32.is_ne(t0c, 0), U32.sub(t0c, 1), 0)
      +nw0 = x64_nw_analyze_one(h0, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +nw1 = x64_nw_analyze_one(h1, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +nw2 = x64_nw_analyze_one(h2, vd, c31, ao, fn_fid, arity, t0d, t0e, pn, blocks)
      +ok0 = x64_nw_is_ok(nw0)
      +ok1 = x64_nw_is_ok(nw1)
      +ok2 = x64_nw_is_ok(nw2)
      +m1sp = Bool.pick(U32, ok1, 0, x64_ctx_ha1_mk_sp(ctx))
      +use_rdx = Bool.and(U32.is_ne(m1sp, 0), x64_rdx_safe_blks(fn_fid, rm, vd, blocks))
      st0c = x64_acc_emit_if(use_rdx, XLoad{2, 5, m1sp}, x64_nw_emit_chks(ctx, m0, nw0, m1, nw1, m2, nw2, x64_ver_pre_chks(ctx, st0)))
      st1 = x64_emit_blocks(x64_ctx_ver_nw(True{}, 0, Bool.pick(U32, use_rdx, 2, 0), ok0, ok1, ok2, ctx), fn_map, uc, x64_ru_go(x64_blks_has_reuse(blocks), ctx, vd, blocks), x64_blk_preds(blocks), blocks, 0n, st0c)
      x64_emit_ver_fin(x64_ctx_ver(False{}, 65536, ctx), fn_map, uc, blocks, st1)
def x64_emit_fn_blks(ver_ok: Bool, +ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, +vd: Nat, +fn_fid: U32, +arity: U32, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc) -> X64Acc:
  match ver_ok:
    case False{}: x64_emit_blocks(ctx, fn_map, uc, x64_ru_go(x64_blks_has_reuse(blocks), ctx, vd, blocks), x64_blk_preds(blocks), blocks, 0n, st0)
    case True{}: x64_emit_ver_nw(ctx, fn_map, uc, vd, fn_fid, arity, rm, blocks, st0)
def x64_ctx_clr_bor(ctx: X64Ctx) -> X64Ctx:
  match ctx:
    case X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, m0, s0, h1, d1, m1, s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, t0c, t0t, t0e, t0d, X64Bor{_, _, ha2}}}}}:
      X64Ctx{o2, rm, vd, sb, sd, mr, md, fr, ce, ho, X64Meta{il, hu, sc, nu, ao, h0, d0, m0, s0, h1, d1, m1, s1, cv, cm, X64R2{csm, mp, cf, cr, u2p, u0, u1, X64HMag{hm0, hr0, hm1, hr1, t0c, t0t, t0e, t0d, X64Bor{0, RVEmpty{}, ha2}}}}}
def x64_bor_wrap_cold(+name: String, +ar: U32, +bpm: U32, +l_bor: U32, +lbl0: U32, cold: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +wctx = x64_mk_ctx(True{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, 96, Nil{}, 0, x64_empty_meta())
  a0 = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{96}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, x64_emit(XLabel{l_bor}, cold)))))
  a1 = x64_emit(XStore{5, U32.sub(0, 16), 0}, x64_bor_call(U32.is_gt(ar, 5), ar, String.append("$bor.", name), x64_acc_insts(x64_bor_wrap_go(wctx, True{}, U32.to_nat(ar), 0, bpm, X64Acc{a0, lbl0, Nil{}}))))
  x64_acc_insts(x64_bor_wrap_go(wctx, False{}, U32.to_nat(ar), 0, bpm, X64Acc{a1, lbl0, Nil{}}))
def x64_make_bor_disp(+name: String, +ar: U32, +bpm: U32) -> X64Fn:
  +wctx = x64_mk_ctx(True{}, RVEmpty{}, 0n, 16, U32.sub(0, 8), 0, 0, 96, Nil{}, 0, x64_empty_meta())
  a_pre = x64_bor_sh_chk(U32.to_nat(ar), 0, bpm, 2147614718, Nil{})
  a_own = x64_emit(XRet{}, x64_emit(XAddRsp{8}, x64_emit(XCallSym{String.append("$own.", name)}, x64_emit(XSubRsp{8}, a_pre))))
  a_bor = x64_emit(XStore{5, U32.sub(0, 8), 7}, x64_emit(XSubRsp{96}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, x64_emit(XLabel{2147614718}, a_own)))))
  a_c = x64_emit(XStore{5, U32.sub(0, 16), 0}, x64_bor_call(False{}, ar, String.append("$bor.", name), x64_acc_insts(x64_bor_wrap_go(wctx, True{}, U32.to_nat(ar), 0, bpm, X64Acc{a_bor, 1, Nil{}}))))
  X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_bor_wrap_go(wctx, False{}, U32.to_nat(ar), 0, bpm, X64Acc{a_c, 1, Nil{}})))}
def x64_bor_own_fin(+name: String, +ar: U32, +bpm: U32, st: X64Acc) -> X64Fn:
  match st:
    case X64Acc{insts, +nl, cold}:
      X64Fn{String.append("$own.", name), False{}, b5k_list_rev(X64Inst, x64_acc_insts(X64Acc{insts, nl, x64_bor_wrap_cold(name, ar, bpm, 2147614718, nl, cold)}))}
def x64_lower_fn_o2_w(is_b: Bool, bor_own: Bool, +ver_ok: Bool, +ctx: X64Ctx, +fn_map: Map<&2, String>, +fn_fid: U32, +name: String, +arity: U32, +bpm: U32, +uc: RaVec<U32>, +vd: Nat, +rm: RaVec<U32>, +blocks: List<&2, IrBlock>, st0: X64Acc, st0_own: X64Acc, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_b bor_own:
    case False{} _: Con{X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, fn_map, uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}
    case True{} False{}:
      +bn = String.append("$bor.", name)
      Con{x64_make_bor_wrap(name, arity, bpm), Con{X64Fn{bn, False{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, Map.set(&2, String, fn_map, b5k_u32_to_str(fn_fid), bn), uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}}
    case True{} True{}:
      +bn = String.append("$bor.", name)
      +on = String.append("$own.", name)
      +own_fn = x64_bor_own_fin(name, arity, bpm, x64_emit_fn_blks(ver_ok, x64_ctx_clr_bor(ctx), Map.set(&2, String, fn_map, b5k_u32_to_str(fn_fid), on), uc, vd, fn_fid, arity, rm, blocks, st0_own))
      Con{x64_make_bor_disp(name, arity, bpm), Con{own_fn, Con{X64Fn{bn, False{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_fn_blks(ver_ok, ctx, Map.set(&2, String, fn_map, b5k_u32_to_str(fn_fid), bn), uc, vd, fn_fid, arity, rm, blocks, st0)))}, acc}}}
def x64_max_alloca_ops(ops: List<&2, IrOp>, m: U32) -> U32:
  match ops:
    case Nil{}: m
    case Con{IAlloca{_, w}, t}: x64_max_alloca_ops(t, U32.max(m, w))
    case Con{_, t}: x64_max_alloca_ops(t, m)
def x64_max_alloca_blks(blks: List<&2, IrBlock>, m: U32) -> U32:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: x64_max_alloca_blks(t, x64_max_alloca_ops(ops, m))
def x64_filter_ce(+vd: Nat, +nregs: U32, ce: List<&2, U32>, +rm: RaVec<U32>, +c31: RaVec<U32>, +cm: RaVec<Bool>) -> List<&2, U32>:
  match ce:
    case Nil{}: Nil{}
    case Con{+r, t}: x64_cons_if(x64_rm_has_reg(vd, U32.to_nat(nregs), 0, r, rm, c31, cm), r, x64_filter_ce(vd, nregs, t, rm, c31, cm))
def x64_ops_has_rcall(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{ICallDirect{_, _, _}, _}: True{}
    case Con{ICallClosure{_, _, _}, _}: True{}
    case Con{IApply{_, _, _}, _}: True{}
    case Con{_, t}: x64_ops_has_rcall(t)
def x64_blks_has_rcall(+fn_fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, TTailCall{fid, _}}, t}: Bool.or(Bool.or(U32.is_ne(fid, fn_fid), x64_ops_has_rcall(ops)), x64_blks_has_rcall(fn_fid, t))
    case Con{IrBlock{_, ops, _}, t}: Bool.or(x64_ops_has_rcall(ops), x64_blks_has_rcall(fn_fid, t))
def x64_lower_fn_o2_emit(+fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, +fn_fid: U32, +name: String, +arity: U32, +nregs: U32, +blocks: List<&2, IrBlock>, +rm: RaVec<U32>, +vd: Nat, +ce0: List<&2, U32>, +sc: U32, +c31: RaVec<U32>, is_sc: RaVec<U32>, nf: Bool, +stc: Bool, harr: Bool, hc: Bool, +ao: RaVec<U32>, hp: X64HPick, hm: X64HMag, bor: X64Bor, uc: RaVec<U32>, hist: X64HiSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match r2s hp hm bor hist:
    case X64R2Scan{+r2m, u2m} X64HPick{+ha0, ha0_sc, +ha1, ha1_sc, +ha2, ha2_sc} X64HMag{+hm0, _, +hm1, _, t0c, t0t, t0e, t0d, _} X64Bor{+bpm_raw, bbm, _} X64HiSt{hu, +cm}:
      +bpm = U32.and(bpm_raw, 255)
      +bor_own = Bool.and(U32.is_ne(U32.and(bpm_raw, 65536), 0), Bool.and(U32.is_le(arity, 5), U32.is_le(b5k_list_len(IrBlock, blocks), 32)))
      +cur_r2 = ra_vec_get(U32, 8n, 0, fn_fid, r2m)
      +u2p = ra_vec_get(U32, 8n, 0, fn_fid, u2m)
      +um = x64_blks_use_mem(blocks)
      +ce0f = x64_filter_ce(vd, nregs, ce0, rm, c31, cm)
      +h_first = Bool.and(stc, U32.is_ne(ha0, 0))
      +mr0 = Bool.pick(U32, Bool.and(um, Bool.not(h_first)), x64_pick_free_callee(ce0f), 0)
      +ce1 = x64_cons_if(U32.is_ne(mr0, 0), mr0, ce0f)
      +acs = Bool.and(Bool.not(x64_blks_has_rcall(fn_fid, blocks)), U32.is_ne(ha0, 0))
      +cs0 = x64_cons_if(Bool.and(acs, x64_rm_has_reg(vd, U32.to_nat(nregs), 0, 11, rm, c31, cm)), 11, x64_cons_if(Bool.and(acs, x64_rm_has_reg(vd, U32.to_nat(nregs), 0, 10, rm, c31, cm)), 10, Nil{}))
      +dp0_r = x64_pick_hreg(U32.is_ne(ha0, 0), acs, ce1, cs0)
      +ce2 = x64_cons_if(Bool.and(U32.is_ne(dp0_r, 0), Bool.not(x64_is_cs_reg(dp0_r))), dp0_r, ce1)
      +cs1 = x64_cons_if(x64_is_cs_reg(dp0_r), dp0_r, cs0)
      +dp1_r = x64_pick_hreg(U32.is_ne(ha1, 0), acs, ce2, cs1)
      +ce3 = x64_cons_if(Bool.and(U32.is_ne(dp1_r, 0), Bool.not(x64_is_cs_reg(dp1_r))), dp1_r, ce2)
      +cs2 = x64_cons_if(x64_is_cs_reg(dp1_r), dp1_r, cs1)
      +dp2_r = x64_pick_hreg(U32.is_ne(ha2, 0), acs, ce3, cs2)
      +ce3b = x64_cons_if(Bool.and(U32.is_ne(dp2_r, 0), Bool.not(x64_is_cs_reg(dp2_r))), dp2_r, ce3)
      +cs2b = x64_cons_if(x64_is_cs_reg(dp2_r), dp2_r, cs2)
      +mk0_r0 = x64_pick_hreg(U32.is_ne(ha0, 0), Bool.and(acs, U32.is_ne(dp0_r, 0)), ce3b, cs2b)
      +p0_v = U32.sub(ha0, 1)
      +p0_r = Bool.pick(U32, Bool.and(stc, Bool.and(U32.is_ne(ha0, 0), Bool.and(U32.is_lt(ha0, 65536), U32.is_zero(mk0_r0)))), ra_vec_get(U32, vd, 0, p0_v, rm), 100)
      +dem0 = Bool.and(x64_is_gpr(p0_r), Bool.not(x64_rm_other_has_reg(vd, U32.to_nat(nregs), 0, p0_r, p0_v, rm, c31, cm)))
      +rm1 = Bool.pick(RaVec<U32>, dem0, ra_vec_set(U32, vd, p0_v, U32.add(100, sc), rm), rm)
      +sc1 = Bool.pick(U32, dem0, U32.add(sc, 1), sc)
      +mk0_r = Bool.pick(U32, dem0, p0_r, mk0_r0)
      +ce4 = x64_cons_if(Bool.and(U32.is_ne(mk0_r, 0), Bool.and(Bool.not(dem0), Bool.not(x64_is_cs_reg(mk0_r)))), mk0_r, ce3b)
      +cs3 = x64_cons_if(x64_is_cs_reg(mk0_r), mk0_r, cs2b)
      +mk1_r = x64_pick_hreg(U32.is_ne(ha1, 0), Bool.and(acs, U32.is_ne(dp1_r, 0)), ce4, cs3)
      +ce4b = x64_cons_if(Bool.and(U32.is_ne(mk1_r, 0), Bool.not(x64_is_cs_reg(mk1_r))), mk1_r, ce4)
      +cs4 = x64_cons_if(x64_is_cs_reg(mk1_r), mk1_r, cs3)
      +mk2_r = x64_pick_hreg(U32.is_ne(ha2, 0), Bool.and(acs, U32.is_ne(dp2_r, 0)), ce4b, cs4)
      +ce5a = x64_cons_if(Bool.and(U32.is_ne(mk2_r, 0), Bool.not(x64_is_cs_reg(mk2_r))), mk2_r, ce4b)
      +mr = Bool.pick(U32, Bool.and(um, h_first), x64_pick_free_callee(ce5a), mr0)
      +has_mr = U32.is_ne(mr, 0)
      +has_md = Bool.and(um, Bool.not(has_mr))
      +ce5 = x64_cons_if(Bool.and(h_first, has_mr), mr, ce5a)
      +hr0 = Bool.pick(U32, U32.is_ne(hm0, 0), x64_pick_free_callee(ce5), 0)
      +ce6 = x64_cons_if(U32.is_ne(hr0, 0), hr0, ce5)
      +hr1 = Bool.pick(U32, U32.is_ne(hm1, 0), x64_pick_free_callee(ce6), 0)
      +ce = x64_cons_if(U32.is_ne(hr1, 0), hr1, ce6)
      +k = b5k_u32_list_len(ce)
      +state_off = U32.mul(U32.add(k, 1), 8)
      +sd = U32.sub(0, state_off)
      +b0 = Bool.pick(U32, has_md, U32.add(state_off, 8), state_off)
      +md = Bool.pick(U32, has_md, U32.sub(0, b0), 0)
      +need_dp0_s = Bool.and(U32.is_ne(ha0, 0), U32.is_zero(dp0_r))
      +b1a = Bool.pick(U32, need_dp0_s, U32.add(b0, 8), b0)
      +ha0_dp = Bool.pick(U32, U32.is_ne(dp0_r, 0), dp0_r, Bool.pick(U32, need_dp0_s, U32.sub(0, b1a), 0))
      +need_mk0_s = Bool.and(U32.is_ne(ha0, 0), U32.is_zero(mk0_r))
      +b1 = Bool.pick(U32, need_mk0_s, U32.add(b1a, 8), b1a)
      +ha0_mk = Bool.pick(U32, U32.is_ne(mk0_r, 0), mk0_r, Bool.pick(U32, need_mk0_s, U32.sub(0, b1), 0))
      +need_dp1_s = Bool.and(U32.is_ne(ha1, 0), U32.is_zero(dp1_r))
      +b2a = Bool.pick(U32, need_dp1_s, U32.add(b1, 8), b1)
      +ha1_dp = Bool.pick(U32, U32.is_ne(dp1_r, 0), dp1_r, Bool.pick(U32, need_dp1_s, U32.sub(0, b2a), 0))
      +need_mk1_s = Bool.and(U32.is_ne(ha1, 0), U32.is_zero(mk1_r))
      +b2 = Bool.pick(U32, need_mk1_s, U32.add(b2a, 8), b2a)
      +ha1_mk = Bool.pick(U32, U32.is_ne(mk1_r, 0), mk1_r, Bool.pick(U32, need_mk1_s, U32.sub(0, b2), 0))
      +need_dp2_s = Bool.and(U32.is_ne(ha2, 0), U32.is_zero(dp2_r))
      +b2c = Bool.pick(U32, need_dp2_s, U32.add(b2, 8), b2)
      +ha2_dp = Bool.pick(U32, U32.is_ne(dp2_r, 0), dp2_r, Bool.pick(U32, need_dp2_s, U32.sub(0, b2c), 0))
      +need_mk2_s = Bool.and(U32.is_ne(ha2, 0), U32.is_zero(mk2_r))
      +b2d = Bool.pick(U32, need_mk2_s, U32.add(b2c, 8), b2c)
      +ha2_mk = Bool.pick(U32, U32.is_ne(mk2_r, 0), mk2_r, Bool.pick(U32, need_mk2_s, U32.sub(0, b2d), 0))
      +has_u2 = U32.is_ne(u2p, 0)
      +b3 = Bool.pick(U32, has_u2, U32.add(b2d, 16), b2d)
      u2o0 = Bool.pick(U32, has_u2, U32.sub(0, U32.add(b2d, 8)), 0)
      u2o1 = Bool.pick(U32, has_u2, U32.sub(0, b3), 0)
      +sb = U32.add(b3, 8)
      +aw = x64_max_alloca_blks(blocks, 0)
      +ab = Bool.pick(U32, U32.is_zero(aw), 0, U32.add(256, x64_align16(U32.mul(aw, 8))))
      +frame = U32.sub(x64_align16(U32.add(U32.add(b3, U32.add(U32.mul(U32.max(16, arity), 8), ab)), U32.mul(sc1, 8))), U32.mul(k, 8))
      +is_leaf = Bool.and(Bool.and(Bool.and(U32.is_le(arity, 5), U32.is_zero(sc1)), Bool.and(Bool.not(um), Bool.and(U32.is_zero(ha0), Bool.not(nf)))), Bool.not(x64_blks_tail_scr(x64_mk_ctx(True{}, rm1, vd, 0, 0, 0, 0, 0, Nil{}, 0, x64_empty_meta()), blocks)))
      +nu = x64_run_nu(Bool.or(harr, um), vd, arity, fn_fid, ao, blocks)
      +ha0_sc1 = x64_nu_sc_ha_go(ha0_sc, U32.is_zero(ha0), ha0, vd, nu, ao, blocks)
      +ha1_sc1 = x64_nu_sc_ha_go(ha1_sc, U32.is_zero(ha1), ha1, vd, nu, ao, blocks)
      +ha2_sc1 = x64_nu_sc_ha_go(ha2_sc, U32.is_zero(ha2), ha2, vd, nu, ao, blocks)
      +ver_ok = Bool.and(Bool.and(stc, U32.is_ne(ha0, 0)), Bool.and(Bool.and(ha0_sc1, Bool.and(Bool.or(U32.is_zero(ha1), ha1_sc1), Bool.or(U32.is_zero(ha2), ha2_sc1))), U32.is_le(b5k_list_len(IrBlock, blocks), 64)))
      h_cs = Bool.or(Bool.and(U32.is_ne(ha0, 0), Bool.or(x64_is_cs_reg(ha0_dp), x64_is_cs_reg(ha0_mk))), Bool.or(Bool.and(U32.is_ne(ha1, 0), Bool.or(x64_is_cs_reg(ha1_dp), x64_is_cs_reg(ha1_mk))), Bool.and(U32.is_ne(ha2, 0), Bool.or(x64_is_cs_reg(ha2_dp), x64_is_cs_reg(ha2_mk)))))
      csm = U32.or(Bool.pick(U32, is_leaf, 0, x64_rm_cs_mask(vd, U32.to_nat(nregs), 0, rm1, 0)), Bool.pick(U32, h_cs, 2, 0))
      +ctx = x64_mk_ctx(True{}, rm1, vd, sb, sd, mr, md, frame, ce, heap_off, X64Meta{is_leaf, hu, is_sc, nu, ao, ha0, ha0_dp, ha0_mk, ha0_sc1, ha1, ha1_dp, ha1_mk, ha1_sc1, c31, cm, X64R2{csm, r2m, fn_fid, cur_r2, u2p, u2o0, u2o1, X64HMag{hm0, hr0, hm1, hr1, t0c, t0t, t0e, t0d, X64Bor{bpm, bbm, X64Ha2{ha2, ha2_dp, ha2_mk, ha2_sc1, False{}, 0}}}}})
      +sw_pak = Bool.pick(U32, is_leaf, 0, x64_sw_find_pak(arity, blocks))
      +sw_z = Bool.pick(U32, Bool.or(is_leaf, U32.is_ne(bpm, 0)), 0, x64_sw_find(arity, blocks))
      +sw = Bool.pick(U32, U32.is_ne(sw_z, 0), sw_z, sw_pak)
      +sw_own = Bool.pick(U32, is_leaf, 0, Bool.pick(U32, U32.is_ne(sw_pak, 0), sw_pak, x64_sw_find(arity, blocks)))
      a3 = x64_emit_if(U32.is_ne(hr1, 0), XMovRI32{hr1, hm1}, x64_emit_if(U32.is_ne(hr0, 0), XMovRI32{hr0, hm0}, x64_save_params_go(ctx, U32.to_nat(arity), 0, x64_emit_if(U32.is_ge(arity, 5), XMovRR{7, 9}, x64_emit_if(U32.is_ge(arity, 4), XMovRR{0, 8}, x64_o2_prologue_pre(is_leaf, sw, 0, arity, ce, frame, sd, has_mr, has_md, mr, md))))))
      st0 = x64_init_hoist_one(ctx, ha2, ha2_dp, ha2_mk, x64_init_hoist_one(ctx, ha1, ha1_dp, ha1_mk, x64_init_hoist_one(ctx, ha0, ha0_dp, ha0_mk, X64Acc{a3, 2147483648, Nil{}})))
      a3_own = x64_emit_if(U32.is_ne(hr1, 0), XMovRI32{hr1, hm1}, x64_emit_if(U32.is_ne(hr0, 0), XMovRI32{hr0, hm0}, x64_save_params_go(ctx, U32.to_nat(arity), 0, x64_emit_if(U32.is_ge(arity, 5), XMovRR{7, 9}, x64_emit_if(U32.is_ge(arity, 4), XMovRR{0, 8}, x64_o2_prologue_pre(is_leaf, sw_own, bpm, arity, ce, frame, sd, has_mr, has_md, mr, md))))))
      st0_own = Bool.pick(X64Acc, bor_own, x64_init_hoist_one(ctx, ha2, ha2_dp, ha2_mk, x64_init_hoist_one(ctx, ha1, ha1_dp, ha1_mk, x64_init_hoist_one(ctx, ha0, ha0_dp, ha0_mk, X64Acc{a3_own, 2147483648, Nil{}}))), X64Acc{Nil{}, 2147483648, Nil{}})
      x64_lower_fn_o2_w(U32.is_ne(bpm, 0), bor_own, ver_ok, ctx, fn_map, fn_fid, name, arity, bpm, uc, vd, rm1, blocks, st0, st0_own, acc)
type X64TcoOp is Data:
  X64TcoOp{hit: Bool, ops: List<&2, IrOp>, args: List<&2, U32>}
def x64_tco_ops(+fid: U32, +ar: U32, +rv: U32, ops: List<&2, IrOp>, rev: List<&2, IrOp>) -> X64TcoOp:
  match ops:
    case Nil{}: X64TcoOp{False{}, Nil{}, Nil{}}
    case Con{ICallDirect{dst, cfid, +args}, Nil{}}:
      ok = Bool.and(Bool.and(U32.is_eq(dst, rv), U32.is_eq(cfid, fid)), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), U32.is_le(ar, 64)))
      Bool.pick(X64TcoOp, ok, X64TcoOp{True{}, b5k_list_rev(IrOp, rev), args}, X64TcoOp{False{}, Nil{}, Nil{}})
    case Con{op, t}: x64_tco_ops(fid, ar, rv, t, Con{op, rev})
def x64_tco_blk_fin(r: X64TcoOp, id: U32, fid: U32, ops: List<&2, IrOp>, term: IrTerm) -> IrBlock:
  match r:
    case X64TcoOp{True{}, nops, args}: IrBlock{id, nops, TTailCall{fid, args}}
    case X64TcoOp{False{}, _, _}: IrBlock{id, ops, term}
def x64_tco_blks(+fid: U32, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, +ops, TRet{+rv}}, t}:
      Con{x64_tco_blk_fin(x64_tco_ops(fid, ar, rv, ops, Nil{}), id, fid, ops, TRet{rv}), x64_tco_blks(fid, ar, t)}
    case Con{b, t}: Con{b, x64_tco_blks(fid, ar, t)}
def x64_hist_cm(h: X64HiSt) -> RaVec<Bool>:
  match h:
    case X64HiSt{_, cm}: cm
def x64_lower_fn_o2_fin(fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, +fn_fid: U32, name: String, +arity: U32, +nregs: U32, eff: Bool, is_m: Bool, +blocks: List<&2, IrBlock>, rm: RaVec<U32>, +vd: Nat, ce0: List<&2, U32>, sc: U32, dst: X64DefSt, hst: X64HoistSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match r2s dst hst:
    case X64R2Scan{+r2m, u2m} X64DefSt{+c31, is_sc, nf, +stc, harr, +hc} X64HoistSt{ao, hused, hbad, hsca, hwr}:
      +uc = x64_uc_blks(vd, blocks, RVEmpty{})
      +hist = x64_hi_blks(vd, c31, blocks, X64HiSt{RVEmpty{}, RVEmpty{}})
      x64_lower_fn_o2_emit(fn_map, heap_off, X64R2Scan{r2m, u2m}, fn_fid, name, arity, nregs, blocks, rm, vd, ce0, sc, c31, is_sc, nf, stc, harr, hc, ao, x64_hoist_pick(vd, U32.to_nat(arity), 0, Bool.pick(U32, stc, 1, 2), hused, hbad, hsca, hwr, 0, 0, False{}, 0, 0, False{}, 0, 0, False{}), x64_run_hmag(stc, t0d, vd, arity, c31, x64_hist_cm(hist), uc, blocks), x64_scan_bor_go(Bool.and(Bool.and(hc, Bool.and(Bool.and(Bool.not(eff), Bool.not(is_m)), Bool.and(U32.is_gt(arity, 0), Bool.and(U32.is_le(arity, 8), U32.is_zero(ra_vec_get(U32, 8n, 0, fn_fid, r2m)))))), x64_bor_can(fn_fid, blocks)), vd, arity, nregs, fn_fid, blocks), uc, hist, acc)
def x64_lower_fn_o2_s2(fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, +fn_fid: U32, name: String, +arity: U32, nregs: U32, eff: Bool, is_m: Bool, +blocks: List<&2, IrBlock>, rm: RaVec<U32>, +vd: Nat, ce0: List<&2, U32>, sc: U32, dst: X64DefSt, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match dst:
    case X64DefSt{c31, +is_sc, nf, stc, +harr, hc}:
      x64_lower_fn_o2_fin(fn_map, heap_off, r2s, t0d, fn_fid, name, arity, nregs, eff, is_m, blocks, rm, vd, ce0, sc, X64DefSt{c31, is_sc, nf, stc, harr, hc}, x64_run_hoist(harr, vd, arity, fn_fid, is_sc, blocks), acc)
def x64_lower_fn_o2_go(fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, t0d: Bool, ra: RegAllocRes, f: IrFn, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match ra f:
    case RegAllocRes{rm, +vd, ce0, sc} IrFn{+fid, name, +arity, nregs, _, eff, is_m, blocks}:
      +blks = x64_tco_blks(fid, arity, blocks)
      x64_lower_fn_o2_s2(fn_map, heap_off, r2s, t0d, fid, name, arity, nregs, eff, is_m, blks, rm, vd, ce0, sc, x64_def_blks(vd, arity, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}}), acc)
def x64_seg_push_extra(n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      a1 = x64_emit(XPush{0}, x64_emit(XLoad{0, 7, U32.add(40, U32.mul(idx, 8))}, acc))
      x64_seg_push_extra(p, U32.sub(idx, 1), a1)
def x64_seg_load_regs(n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      a1 = x64_emit(XLoad{x64_arg_reg(idx), 7, U32.add(40, U32.mul(idx, 8))}, acc)
      x64_seg_load_regs(p, U32.add(idx, 1), a1)
def x64_seg_call(has_extra: Bool, +arity: U32, sym: String, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_extra:
    case False{}: x64_emit(XCallSym{sym}, x64_seg_load_regs(U32.to_nat(arity), 0, acc))
    case True{}:
      +extra_cnt = U32.sub(arity, 5)
      +odd = U32.is_eq(U32.and(extra_cnt, 1), 1)
      e1 = x64_seg_push_extra(U32.to_nat(extra_cnt), U32.sub(arity, 1), x64_emit_if(odd, XSubRsp{8}, acc))
      x64_emit(XAddRsp{U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)}, x64_emit(XCallSym{sym}, x64_seg_load_regs(5n, 0, e1)))
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
def x64_r2_num_sc(dst: X64DefSt) -> RaVec<U32>:
  match dst:
    case X64DefSt{_, sc, _, _, _, _}: sc
type X64R2Fn is Data:
  X64R2Fn{c1: U32, pm: U32}
def x64_r2_pmask(+ar: U32, +sc: RaVec<U32>, +v: U32) -> U32:
  Bool.pick(U32, U32.is_eq(ra_vec_get(U32, 8n, 0, v, sc), 2), 0, Bool.pick(U32, Bool.and(U32.is_lt(v, ar), U32.is_lt(v, 31)), U32.shln(1, U32.to_nat(v)), 2147483648))
def x64_r2_ret_ops(+ar: U32, +sc: RaVec<U32>, +v: U32, ops: List<&2, IrOp>, st: X64R2Fn) -> X64R2Fn:
  match ops st:
    case Con{ICtor{d, +cid, Con{a, Con{b, Nil{}}}}, Nil{}} X64R2Fn{+cur, pm}:
      +m = U32.or(pm, U32.or(x64_r2_pmask(ar, sc, a), x64_r2_pmask(ar, sc, b)))
      X64R2Fn{Bool.pick(U32, Bool.and(U32.is_lt(m, 2147483648), Bool.and(U32.is_eq(d, v), Bool.or(U32.is_zero(cur), U32.is_eq(cur, U32.add(cid, 1))))), U32.add(cid, 1), 4294967295), m}
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
def x64_z0_ops(+ar: U32, ops: List<&2, IrOp>, +z0: RaVec<U32>) -> RaVec<U32>:
  match ops:
    case Nil{}: z0
    case Con{ICtor{d, cid, Nil{}}, t}: x64_z0_ops(ar, t, x64_mc(8n, ar, d, cid, z0))
    case Con{ITake{ds, _}, t}: x64_z0_ops(ar, t, x64_m2s(8n, ds, z0))
    case Con{IArrOp{ds, _, _}, t}: x64_z0_ops(ar, t, x64_m2s(8n, ds, z0))
    case Con{+op, t}: x64_z0_ops(ar, t, Bool.pick(RaVec<U32>, U32.is_ne(x64_op_dst1(op), 0), x64_m2(8n, U32.sub(x64_op_dst1(op), 1), z0), z0))
def x64_z0_blks(+ar: U32, blks: List<&2, IrBlock>, z0: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: z0
    case Con{IrBlock{_, ops, _}, t}: x64_z0_blks(ar, t, x64_z0_ops(ar, ops, z0))
def x64_u2p_last_call(+fid: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Con{ICallDirect{dst, cfid, _}, Nil{}}: Bool.pick(U32, U32.is_eq(cfid, fid), U32.add(dst, 1), 0)
    case Con{_, t}: x64_u2p_last_call(fid, t)
    case Nil{}: 0
def x64_u2p_find(+fid: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{_, ops, TTailCall{tfid, targs}}, t}:
      +d1 = Bool.pick(U32, U32.is_eq(tfid, fid), x64_u2p_last_call(fid, ops), 0)
      +p1 = Bool.pick(U32, U32.is_ne(d1, 0), x64_u32_idx(U32.sub(d1, 1), targs, 0), 0)
      Bool.pick(U32, U32.is_ne(p1, 0), p1, x64_u2p_find(fid, t))
    case Con{_, t}: x64_u2p_find(fid, t)
def x64_u2p_ops_ok(+p: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{ITag{d, _}, t}: Bool.and(U32.is_ne(d, p), x64_u2p_ops_ok(p, t))
    case Con{ITake{Con{d0, Con{d1, Nil{}}}, _}, t}: Bool.and(Bool.and(U32.is_ne(d0, p), U32.is_ne(d1, p)), x64_u2p_ops_ok(p, t))
    case Con{ISink{_}, t}: x64_u2p_ops_ok(p, t)
    case Con{ITake{+ds, s}, t}: Bool.and(Bool.and(Bool.not(x64_u32_in(p, ds)), U32.is_ne(s, p)), x64_u2p_ops_ok(p, t))
    case Con{IArrOp{+ds, _, +args}, t}: Bool.and(Bool.and(Bool.not(x64_u32_in(p, ds)), Bool.not(x64_u32_in(p, args))), x64_u2p_ops_ok(p, t))
    case Con{+op, t}: Bool.and(Bool.and(U32.is_ne(x64_op_dst1(op), U32.add(p, 1)), U32.is_zero(ra_vec_get(U32, 8n, 0, p, x64_uc_op(8n, op, RVEmpty{})))), x64_u2p_ops_ok(p, t))
def x64_u2p_blks_ok(+fid: U32, +cid: U32, +p: U32, +uc: RaVec<U32>, +z0: RaVec<U32>, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{_, +ops, TTailCall{_, +targs}}, t}:
      +v = x64_u32_nth(targs, U32.to_nat(p))
      +e = ra_vec_get(U32, 8n, 0, v, z0)
      tok = Bool.and(Bool.not(x64_u32_in(p, targs)), Bool.or(Bool.and(x64_is_cval(e), U32.is_ne(U32.sub(e, 1), cid)), Bool.and(U32.is_eq(x64_u2p_last_call(fid, ops), U32.add(v, 1)), U32.is_eq(ra_vec_get(U32, 8n, 0, v, uc), 1))))
      Bool.and(Bool.and(x64_u2p_ops_ok(p, ops), tok), x64_u2p_blks_ok(fid, cid, p, uc, z0, t))
    case Con{IrBlock{_, +ops, term}, t}:
      Bool.and(Bool.and(x64_u2p_ops_ok(p, ops), U32.is_zero(ra_vec_get(U32, 8n, 0, p, x64_uc_term(8n, term, RVEmpty{})))), x64_u2p_blks_ok(fid, cid, p, uc, z0, t))
def x64_u2p_chk(has: Bool, +p1: U32, fid: U32, cid: U32, ar: U32, +blks: List<&2, IrBlock>) -> U32:
  match has:
    case False{}: 0
    case True{}: Bool.pick(U32, x64_u2p_blks_ok(fid, cid, U32.sub(p1, 1), x64_uc_blks(8n, blks, RVEmpty{}), x64_z0_blks(ar, blks, RVEmpty{}), blks), p1, 0)
type X64R2P1 is Data:
  X64R2P1{cand: RaVec<U32>, u2p: RaVec<U32>, pms: RaVec<U32>}
def x64_r2_p1_fin(res: X64R2Fn, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>, st: X64R2P1) -> X64R2P1:
  match res st:
    case X64R2Fn{+c1, pm} X64R2P1{+cand, +u2p, +pms}:
      +good = x64_is_cval(c1)
      +p1 = Bool.pick(U32, Bool.and(good, U32.is_le(ar, 32)), x64_u2p_find(fid, blks), 0)
      +u2v = x64_u2p_chk(U32.is_ne(p1, 0), p1, fid, U32.sub(c1, 1), ar, blks)
      X64R2P1{Bool.pick(RaVec<U32>, good, ra_vec_set(U32, 8n, fid, c1, cand), cand), Bool.pick(RaVec<U32>, U32.is_ne(u2v, 0), ra_vec_set(U32, 8n, fid, u2v, u2p), u2p), Bool.pick(RaVec<U32>, good, ra_vec_set(U32, 8n, fid, pm, pms), pms)}
def x64_r2_p1(fns: List<&2, IrFn>, st: X64R2P1) -> X64R2P1:
  match fns:
    case Nil{}: st
    case Con{IrFn{+fid, _, +ar, _, esc, eff, is_m, +blks}, t}:
      res = Bool.pick(X64R2Fn, Bool.and(Bool.and(Bool.not(esc), Bool.not(eff)), Bool.not(is_m)), x64_r2_fn_scan(ar, x64_r2_num_sc(x64_def_blks(8n, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})), fid, blks, X64R2Fn{0, 0}), X64R2Fn{0, 0})
      x64_r2_p1(t, x64_r2_p1_fin(res, fid, ar, blks, st))
type X64R2P2 is Data:
  X64R2P2{u2p: RaVec<U32>, ben: RaVec<Bool>, clo: RaVec<Bool>}
def x64_r2_is_tk(c1: U32, +dst: U32, uc: RaVec<U32>, t: List<&2, IrOp>) -> Bool:
  match t:
    case Con{ITake{Con{d0, Con{d1, Nil{}}}, tsrc}, _}: Bool.and(Bool.and(U32.is_ne(c1, 0), U32.is_eq(dst, tsrc)), Bool.and(U32.is_ne(d0, d1), U32.is_eq(ra_vec_get(U32, 8n, 0, dst, uc), 1)))
    case _: False{}
def x64_r2_p2_ops(+cur_fid: U32, +cand: RaVec<U32>, +pms: RaVec<U32>, +sc: RaVec<U32>, +uc: RaVec<U32>, +z0: RaVec<U32>, ops: List<&2, IrOp>, st: X64R2P2) -> X64R2P2:
  match ops st:
    case Nil{} _: st
    case Con{ICallClosure{_, cfid, _}, t} X64R2P2{u2p, ben, clo}: x64_r2_p2_ops(cur_fid, cand, pms, sc, uc, z0, t, X64R2P2{u2p, ben, ra_vec_set(Bool, 8n, cfid, True{}, clo)})
    case Con{ICallDirect{+dst, +cfid, +args}, +t} X64R2P2{+u2p, +ben, +clo}:
      +c1 = ra_vec_get(U32, 8n, 0, cfid, cand)
      +p1 = ra_vec_get(U32, 8n, 0, cfid, u2p)
      +pm = ra_vec_get(U32, 8n, 0, cfid, pms)
      +e = ra_vec_get(U32, 8n, 0, x64_u32_nth(args, U32.to_nat(U32.sub(p1, 1))), z0)
      x64_r2_p2_ops(cur_fid, cand, pms, sc, uc, z0, t, X64R2P2{Bool.pick(RaVec<U32>, Bool.and(U32.is_ne(p1, 0), Bool.not(Bool.and(x64_is_cval(e), U32.is_ne(U32.sub(e, 1), U32.sub(c1, 1))))), ra_vec_set(U32, 8n, cfid, 0, u2p), u2p), Bool.pick(RaVec<Bool>, x64_r2_is_tk(c1, dst, uc, t), ra_vec_set(Bool, 8n, cfid, True{}, ben), ben), Bool.pick(RaVec<Bool>, Bool.and(U32.is_ne(pm, 0), Bool.not(x64_r2_args_u32(pm, U32.is_eq(cfid, cur_fid), sc, args, 0))), ra_vec_set(Bool, 8n, cfid, True{}, clo), clo)})
    case Con{_, t} _: x64_r2_p2_ops(cur_fid, cand, pms, sc, uc, z0, t, st)
def x64_r2_p2_tc(+pms: RaVec<U32>, +sc: RaVec<U32>, term: IrTerm, st: X64R2P2) -> X64R2P2:
  match term st:
    case TTailCall{+tfid, args} X64R2P2{u2p, ben, +clo}:
      +pm = ra_vec_get(U32, 8n, 0, tfid, pms)
      X64R2P2{u2p, ben, Bool.pick(RaVec<Bool>, Bool.and(U32.is_ne(pm, 0), Bool.not(x64_r2_args_u32(pm, True{}, sc, args, 0))), ra_vec_set(Bool, 8n, tfid, True{}, clo), clo)}
    case _ _: st
def x64_r2_p2_blks(+cur_fid: U32, +cand: RaVec<U32>, +pms: RaVec<U32>, +sc: RaVec<U32>, +uc: RaVec<U32>, +z0: RaVec<U32>, blks: List<&2, IrBlock>, st: X64R2P2) -> X64R2P2:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}: x64_r2_p2_blks(cur_fid, cand, pms, sc, uc, z0, t, x64_r2_p2_tc(pms, sc, term, x64_r2_p2_ops(cur_fid, cand, pms, sc, uc, z0, ops, st)))
def x64_r2_p2(+cand: RaVec<U32>, +pms: RaVec<U32>, fns: List<&2, IrFn>, st: X64R2P2) -> X64R2P2:
  match fns:
    case Nil{}: st
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t}:
      x64_r2_p2(cand, pms, t, x64_r2_p2_blks(fid, cand, pms, x64_r2_num_sc(x64_def_blks(8n, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}})), x64_uc_blks(8n, blks, RVEmpty{}), x64_z0_blks(ar, blks, RVEmpty{}), blks, st))
def x64_r2_fin(+cand: RaVec<U32>, +u2p: RaVec<U32>, +ben: RaVec<Bool>, +clo: RaVec<Bool>, fns: List<&2, IrFn>, st: X64R2Scan) -> X64R2Scan:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, _, _, _, _, _, _}, t} X64R2Scan{+out, +u2o}:
      +c1 = ra_vec_get(U32, 8n, 0, fid, cand)
      +p1 = ra_vec_get(U32, 8n, 0, fid, u2p)
      +ok = Bool.and(Bool.and(U32.is_ne(c1, 0), Bool.not(ra_vec_get(Bool, 8n, False{}, fid, clo))), Bool.or(ra_vec_get(Bool, 8n, False{}, fid, ben), U32.is_ne(p1, 0)))
      x64_r2_fin(cand, u2p, ben, clo, t, X64R2Scan{Bool.pick(RaVec<U32>, ok, ra_vec_set(U32, 8n, fid, c1, out), out), Bool.pick(RaVec<U32>, Bool.and(ok, U32.is_ne(p1, 0)), ra_vec_set(U32, 8n, fid, p1, u2o), u2o)})
def x64_scan_ret2_s2(cand: RaVec<U32>, fns: List<&2, IrFn>, p2: X64R2P2) -> X64R2Scan:
  match p2:
    case X64R2P2{u2p1, ben, clo}: x64_r2_fin(cand, u2p1, ben, clo, fns, X64R2Scan{RVEmpty{}, RVEmpty{}})
def x64_scan_ret2_s1(+fns: List<&2, IrFn>, p1: X64R2P1) -> X64R2Scan:
  match p1:
    case X64R2P1{+cand, u2p0, pms}: x64_scan_ret2_s2(cand, fns, x64_r2_p2(cand, pms, fns, X64R2P2{u2p0, RVEmpty{}, RVEmpty{}}))
def x64_scan_ret2(is_o2: Bool, +fns: List<&2, IrFn>) -> X64R2Scan:
  match is_o2:
    case False{}: X64R2Scan{RVEmpty{}, RVEmpty{}}
    case True{}: x64_scan_ret2_s1(fns, x64_r2_p1(fns, X64R2P1{RVEmpty{}, RVEmpty{}, RVEmpty{}}))
def x64_rot_find_sub(+vd: Nat, +c31: RaVec<U32>, +p: U32, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{+p2, 1, a, k1}, t}:
      Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(a, p), U32.is_ne(p2, p)), U32.is_eq(ra_vec_get(U32, vd, 0, k1, c31), 2)), U32.add(p2, 1), x64_rot_find_sub(vd, c31, p, t))
    case Con{_, t}: x64_rot_find_sub(vd, c31, p, t)
def x64_rot_find_blk(+vd: Nat, +c31: RaVec<U32>, +p: U32, +bid: U32, blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 0
    case Con{IrBlock{id, ops, _}, t}: Bool.pick(U32, U32.is_eq(id, bid), x64_rot_find_sub(vd, c31, p, ops), x64_rot_find_blk(vd, c31, p, bid, t))
type X64RotChk is Data:
  X64RotChk{ok: Bool, dp2: U32, ntc: U32}
def x64_rot_chk_ops(+p: U32, +p2: U32, ops: List<&2, IrOp>, st: X64RotChk) -> X64RotChk:
  match ops st:
    case Nil{} _: st
    case Con{+op, t} X64RotChk{ok, dp2, ntc}:
      x64_rot_chk_ops(p, p2, t, X64RotChk{Bool.and(ok, Bool.not(x64_op_redefs(p, op))), U32.add(dp2, Bool.to_u32(x64_op_redefs(p2, op))), ntc})
def x64_rot_chk_tc(fid: U32, ar: U32, p: U32, p2: U32, tfid: U32, +args: List<&2, U32>, st: X64RotChk) -> X64RotChk:
  match st:
    case X64RotChk{ok, dp2, ntc}:
      +is_s = Bool.and(U32.is_eq(tfid, fid), U32.is_eq(b5k_u32_list_len(args), ar))
      ok2 = Bool.and(ok, Bool.or(Bool.not(is_s), U32.is_eq(x64_u32_nth(args, U32.to_nat(p)), p2)))
      X64RotChk{ok2, dp2, U32.add(ntc, Bool.to_u32(is_s))}
def x64_rot_chk_blks(+fid: U32, +ar: U32, +p: U32, +p2: U32, blks: List<&2, IrBlock>, st: X64RotChk) -> X64RotChk:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, TTailCall{tfid, args}}, t}:
      x64_rot_chk_blks(fid, ar, p, p2, t, x64_rot_chk_tc(fid, ar, p, p2, tfid, args, x64_rot_chk_ops(p, p2, ops, st)))
    case Con{IrBlock{_, ops, _}, t}: x64_rot_chk_blks(fid, ar, p, p2, t, x64_rot_chk_ops(p, p2, ops, st))
def x64_rot_rw_args(+p: U32, args: List<&2, U32>, +idx: U32) -> List<&2, U32>:
  match args:
    case Nil{}: Nil{}
    case Con{a, t}: Con{Bool.pick(U32, U32.is_eq(idx, p), p, a), x64_rot_rw_args(p, t, U32.add(idx, 1))}
def x64_rot_strip_ops(+p2: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{IBin{+d, 1, a, k1}, +t}: Bool.pick(List<&2, IrOp>, U32.is_eq(d, p2), t, Con{IBin{d, 1, a, k1}, x64_rot_strip_ops(p2, t)})
    case Con{op, t}: Con{op, x64_rot_strip_ops(p2, t)}
def x64_rot_rw_blks(+fid: U32, +bid: U32, +p: U32, +p2: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, TTailCall{+tfid, +args}}, t}:
      ops1 = Bool.pick(List<&2, IrOp>, U32.is_eq(id, bid), x64_rot_strip_ops(p2, ops), ops)
      args1 = Bool.pick(List<&2, U32>, U32.is_eq(tfid, fid), x64_rot_rw_args(p, args, 0), args)
      Con{IrBlock{id, ops1, TTailCall{tfid, args1}}, x64_rot_rw_blks(fid, bid, p, p2, t)}
    case Con{IrBlock{+id, +ops, term}, t}:
      ops1 = Bool.pick(List<&2, IrOp>, U32.is_eq(id, bid), x64_rot_strip_ops(p2, ops), ops)
      Con{IrBlock{id, ops1, term}, x64_rot_rw_blks(fid, bid, p, p2, t)}
type X64RotFn is Data:
  X64RotFn{fn: IrFn, t0d: Bool}
def x64_rot_try_fin(chk: X64RotChk, vd: Nat, uc: RaVec<U32>, +fid: U32, name: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, bid: U32, p: U32, +p2: U32) -> X64RotFn:
  match chk:
    case X64RotChk{ok, dp2, +ntc}:
      +good = Bool.and(Bool.and(ok, U32.is_eq(dp2, 1)), Bool.and(U32.is_gt(ntc, 0), U32.is_eq(ra_vec_get(U32, vd, 0, p2, uc), ntc)))
      X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, Bool.pick(List<&2, IrBlock>, good, x64_rot_rw_blks(fid, bid, p, p2, blks), blks)}, good}
def x64_rot_try(is_z: Bool, vd: Nat, uc: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, bid: U32, +p: U32, p2_1: U32) -> X64RotFn:
  match is_z:
    case True{}: X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{}}
    case False{}:
      +p2 = U32.sub(p2_1, 1)
      x64_rot_try_fin(x64_rot_chk_blks(fid, ar, p, p2, blks, X64RotChk{True{}, 0, 0}), vd, uc, fid, name, ar, nregs, esc, eff, is_m, blks, bid, p, p2)
def x64_rot_go(t0: X64T0, +vd: Nat, +c31: RaVec<U32>, +uc: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>) -> X64RotFn:
  match t0:
    case X64T0{+c, +tb, _}:
      +p = U32.sub(c, 1)
      +ok = Bool.and(Bool.and(U32.is_ne(c, 0), U32.is_lt(tb, 1024)), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 0, p, uc), 2), U32.is_eq(ra_vec_get(U32, 5n, 0, tb, x64_blk_preds(blks)), 1)))
      +p2_1 = Bool.pick(U32, ok, x64_rot_find_blk(vd, c31, p, tb, blks), 0)
      x64_rot_try(U32.is_zero(p2_1), vd, uc, fid, name, ar, nregs, esc, eff, is_m, blks, tb, p, p2_1)
def x64_rot_cd_go(ok: Bool, +vd: Nat, +c31: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>) -> X64RotFn:
  match ok:
    case False{}: X64RotFn{IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{}}
    case True{}:
      +uc = x64_uc_blks(vd, blks, RVEmpty{})
      cm = x64_hist_cm(x64_hi_blks(vd, c31, blks, X64HiSt{RVEmpty{}, RVEmpty{}}))
      x64_rot_go(x64_b0_t0(vd, ar, c31, cm, uc, blks), vd, c31, uc, fid, name, ar, nregs, esc, eff, is_m, blks)
def x64_rot_cd_st(dst: X64DefSt, vd: Nat, fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, blks: List<&2, IrBlock>) -> X64RotFn:
  match dst:
    case X64DefSt{c31, _, _, stc, _, _}: x64_rot_cd_go(Bool.and(stc, U32.is_le(ar, 64)), vd, c31, fid, name, ar, nregs, esc, eff, is_m, blks)
def x64_rot_countdown(f: IrFn) -> X64RotFn:
  match f:
    case IrFn{+fid, name, +ar, +nregs, esc, eff, is_m, blocks0}:
      +blks = x64_tco_blks(fid, ar, blocks0)
      +vd = ra_vd_of(U32.max(nregs, ar))
      x64_rot_cd_st(x64_def_blks(vd, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}}), vd, fid, name, ar, nregs, esc, eff, is_m, blks)
# L13-SIMD: General 4-Wide SSE2 FP Backend (Counted-Loop V4 Kernel + Caller Batching)
type V4Hdr is Data:
  V4Hdr{ok: Bool, vd: Nat, c31: RaVec<U32>, blks: List<&2, IrBlock>, sid: U32, sops: List<&2, IrOp>, pdec: U32, tf: List<&2, U32>}
type V4Cal is Data:
  V4Cal{fid: U32, name: String, arity: U32, nregs: U32, ops: List<&2, IrOp>, targs: List<&2, U32>}
def v4_find_blk(+bid: U32, blks: List<&2, IrBlock>) -> Maybe<&2, IrBlock>:
  match blks:
    case Nil{}: None{}
    case Con{IrBlock{+id, ops, term}, t}: Bool.pick(Maybe<&2, IrBlock>, U32.is_eq(id, bid), Some{IrBlock{id, ops, term}}, v4_find_blk(bid, t))
def v4_hdr_blk(mb: Maybe<&2, IrBlock>, vd: Nat, c31: RaVec<U32>, blks: List<&2, IrBlock>, sid: U32, fid: U32, ar: U32) -> V4Hdr:
  match mb:
    case Some{IrBlock{_, sops, TTailCall{tfid, Con{pdec, +tf}}}}:
      V4Hdr{Bool.and(U32.is_eq(tfid, fid), U32.is_eq(b5k_u32_list_len(tf), U32.sub(ar, 1))), vd, c31, blks, sid, sops, pdec, tf}
    case _: V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}}
def v4_hdr_t0(t0: X64T0, vd: Nat, c31: RaVec<U32>, +blks: List<&2, IrBlock>, fid: U32, ar: U32) -> V4Hdr:
  match t0:
    case X64T0{1, +tb, _}: v4_hdr_blk(v4_find_blk(tb, blks), vd, c31, blks, tb, fid, ar)
    case _: V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}}
def v4_hdr_st(dst: X64DefSt, +vd: Nat, +blks: List<&2, IrBlock>, fid: U32, +ar: U32) -> V4Hdr:
  match dst:
    case X64DefSt{+c31, _, _, True{}, _, _}:
      +uc = x64_uc_blks(vd, blks, RVEmpty{})
      v4_hdr_t0(x64_b0_t0(vd, ar, c31, x64_hist_cm(x64_hi_blks(vd, c31, blks, X64HiSt{RVEmpty{}, RVEmpty{}})), uc, blks), vd, c31, blks, fid, ar)
    case _: V4Hdr{False{}, 0n, RVEmpty{}, blks, 0, Nil{}, 0, Nil{}}
def v4_hdr_go(ok: Bool, +fid: U32, +ar: U32, nregs: U32, blks0: List<&2, IrBlock>) -> V4Hdr:
  match ok:
    case False{}: V4Hdr{False{}, 0n, RVEmpty{}, blks0, 0, Nil{}, 0, Nil{}}
    case True{}:
      +blks = x64_tco_blks(fid, ar, blks0)
      +vd = ra_vd_of(U32.max(nregs, ar))
      v4_hdr_st(x64_def_blks(vd, ar, fid, blks, X64DefSt{RVEmpty{}, RVEmpty{}, False{}, False{}, False{}, False{}}), vd, blks, fid, ar)
def v4_loop_hdr(f: IrFn) -> V4Hdr:
  match f:
    case IrFn{fid, _, +ar, nregs, _, False{}, False{}, blks0}: v4_hdr_go(Bool.and(U32.is_ge(ar, 2), U32.is_le(ar, 32)), fid, ar, nregs, blks0)
    case IrFn{_, _, _, _, _, _, _, blks0}: V4Hdr{False{}, 0n, RVEmpty{}, blks0, 0, Nil{}, 0, Nil{}}

def v4_chk_step(+vd: Nat, +c31: RaVec<U32>, +pdec: U32, ops: List<&2, IrOp>, +nf: U32, +acc: List<&2, IrOp>) -> Bool & List<&2, IrOp>:
  match ops:
    case Nil{}: (U32.is_ge(nf, 4), b5k_list_rev(IrOp, acc))
    case Con{IConst{_, 1}, t}: v4_chk_step(vd, c31, pdec, t, nf, acc)
    case Con{IFlt{d, bits}, t}: v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IFlt{d, bits}, acc})
    case Con{ICopy{d, +s}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.or(U32.is_zero(s), U32.is_eq(s, pdec)), (False{}, Nil{}), v4_chk_step(vd, c31, pdec, t, nf, Con{ICopy{d, s}, acc}))
    case Con{IBin{+d, 1, 0, r}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(U32.is_eq(d, pdec), U32.is_eq(ra_vec_get(U32, vd, 0, r, c31), 2)), v4_chk_step(vd, c31, pdec, t, nf, acc), (False{}, Nil{}))
    case Con{IBin{d, +bop, +l, +r}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), Bool.and(Bool.and(U32.is_ne(l, 0), U32.is_ne(r, 0)), Bool.and(U32.is_ne(l, pdec), U32.is_ne(r, pdec)))), v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IBin{d, bop, l, r}, acc}), (False{}, Nil{}))
    case Con{IUn{d, +uop, +s}, t}: Bool.pick(Bool & List<&2, IrOp>, Bool.and(Bool.or(U32.is_eq(uop, 2), U32.is_eq(uop, 3)), Bool.and(U32.is_ne(s, 0), U32.is_ne(s, pdec))), v4_chk_step(vd, c31, pdec, t, U32.add(nf, 1), Con{IUn{d, uop, s}, acc}), (False{}, Nil{}))
    case _: (False{}, Nil{})
def v4_match_fin(ok0: Bool, fid: U32, name: String, ar: U32, nregs: U32, tf: List<&2, U32>, res: Bool & List<&2, IrOp>) -> Maybe<&2, V4Cal>:
  (ok1, cops) = res
  Bool.pick(Maybe<&2, V4Cal>, Bool.and(ok0, ok1), Some{V4Cal{fid, name, ar, nregs, cops, tf}}, None{})
def v4_match_hdr(h: V4Hdr, fid: U32, name: String, ar: U32, nregs: U32) -> Maybe<&2, V4Cal>:
  match h:
    case V4Hdr{True{}, vd, c31, _, _, sops, +pdec, +tf}: v4_match_fin(Bool.and(Bool.not(x64_u32_in(0, tf)), Bool.not(x64_u32_in(pdec, tf))), fid, name, ar, nregs, tf, v4_chk_step(vd, c31, pdec, sops, 0, Nil{}))
    case _: None{}
def v4_match_fn(f: IrFn) -> Maybe<&2, V4Cal>:
  match f:
    case IrFn{+fid, +name, +ar, +nregs, esc, eff, is_m, blks}: v4_match_hdr(v4_loop_hdr(IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}), fid, name, ar, nregs)

def v4_disp(loc: U32) -> U32: U32.add(32, U32.mul(U32.sub(loc, 100), 32))
def v4_vex_op(vv: U32, bo: U32) -> U32: U32.add(256, U32.or(U32.shln(U32.and(vv, 15), 4n), bo))
def v4_xmm_io(is_ld: Bool, is_sp: Bool, +xmm: U32, +loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp:
    case True{} True{}: x64_emit(XXmmLoad{U32.add(32, xmm), 4, v4_disp(loc)}, acc)
    case False{} True{}: x64_emit(XXmmStore{4, v4_disp(loc), U32.add(48, xmm)}, acc)
    case True{} False{}: x64_emit_if(U32.is_ne(U32.sub(loc, 20), xmm), XXmmRR{263, xmm, U32.sub(loc, 20)}, acc)
    case False{} False{}: x64_emit_if(U32.is_ne(U32.sub(loc, 20), xmm), XXmmRR{263, U32.sub(loc, 20), xmm}, acc)
def v4_mem_io(is_ld: Bool, is_sp: Bool, +base: U32, +loc: U32, +off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ld is_sp:
    case True{} True{}: x64_emit(XXmmStore{4, v4_disp(loc), 48}, x64_emit(XXmmLoad{32, base, off}, acc))
    case True{} False{}: x64_emit(XXmmLoad{U32.add(32, U32.sub(loc, 20)), base, off}, acc)
    case False{} True{}: x64_emit(XXmmStore{base, off, 48}, x64_emit(XXmmLoad{32, 4, v4_disp(loc)}, acc))
    case False{} False{}: x64_emit(XXmmStore{base, off, U32.add(48, U32.sub(loc, 20))}, acc)
def v4_io_params(+is_ld: Bool, +rm: RaVec<U32>, +vd: Nat, n: Nat, +k: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      +loc = ra_vec_get(U32, vd, 0, k, rm)
      v4_io_params(is_ld, rm, vd, p, U32.add(k, 1), Bool.pick(List<&2, X64Inst>, U32.is_zero(loc), acc, v4_mem_io(is_ld, U32.is_ge(loc, 100), 2, loc, U32.mul(U32.sub(k, 1), 32), acc)))
def v4_emit_flt(is_z: Bool, +dx: U32, bits: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_z:
    case True{}: x64_emit(XXmmRR{v4_vex_op(dx, 6), dx, dx}, acc)
    case False{}: x64_emit(XXmmLoad{U32.add(48, dx), 4, 0}, x64_emit(XStore{4, 0, 0}, x64_emit(XMovRI32{0, bits}, acc)))
def v4_emit_sqrt(ssp: Bool, +dx: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ssp:
    case True{}: x64_emit(XXmmRR{260, dx, dx}, x64_emit(XXmmLoad{U32.add(32, dx), 4, v4_disp(sloc)}, acc))
    case False{}: x64_emit(XXmmRR{260, dx, U32.sub(sloc, 20)}, acc)
def v4_ld_sp(sp: Bool, xmm: U32, loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match sp:
    case True{}: x64_emit(XXmmLoad{U32.add(32, xmm), 4, v4_disp(loc)}, acc)
    case False{}: acc
def v4_emit_op(+rm: RaVec<U32>, +vd: Nat, op: IrOp, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case IFlt{d, +bits}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +ds = U32.is_ge(dl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      v4_xmm_io(False{}, ds, dx, dl, v4_emit_flt(U32.is_zero(bits), dx, bits, acc))
    case ICopy{d, s}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +sl = ra_vec_get(U32, vd, 0, s, rm)
      +ds = U32.is_ge(dl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      v4_xmm_io(False{}, ds, dx, dl, v4_xmm_io(True{}, U32.is_ge(sl, 100), dx, sl, acc))
    case IBin{d, +bop, l, r}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +ll = ra_vec_get(U32, vd, 0, l, rm)
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +ds = U32.is_ge(dl, 100)
      +ls = U32.is_ge(ll, 100)
      +rs = U32.is_ge(rl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      +lx = Bool.pick(U32, ls, 0, U32.sub(ll, 20))
      +rx = Bool.pick(U32, rs, 1, U32.sub(rl, 20))
      v4_xmm_io(False{}, ds, dx, dl, x64_emit(XXmmRR{v4_vex_op(lx, U32.sub(bop, 10)), dx, rx}, v4_ld_sp(rs, 1, rl, v4_ld_sp(ls, 0, ll, acc))))
    case IUn{d, 3, s}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +sl = ra_vec_get(U32, vd, 0, s, rm)
      +ds = U32.is_ge(dl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      v4_xmm_io(False{}, ds, dx, dl, v4_emit_sqrt(U32.is_ge(sl, 100), dx, sl, acc))
    case IUn{d, 2, s}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +sl = ra_vec_get(U32, vd, 0, s, rm)
      +ds = U32.is_ge(dl, 100)
      +ss = U32.is_ge(sl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      +sx = Bool.pick(U32, ss, 0, U32.sub(sl, 20))
      v4_xmm_io(False{}, ds, dx, dl, x64_emit(XXmmRR{v4_vex_op(sx, 6), dx, 1}, x64_emit(XXmmLoad{49, 4, 0}, x64_emit(XStore{4, 0, 0}, x64_emit(XMovRI32{0, 2147483648}, v4_ld_sp(ss, 0, sl, acc))))))
    case _: acc
def v4_emit_ops(+rm: RaVec<U32>, +vd: Nat, ops: List<&2, IrOp>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ops:
    case Nil{}: acc
    case Con{op, t}: v4_emit_ops(rm, vd, t, v4_emit_op(rm, vd, op, acc))
def v4_loc_src(+rm: RaVec<U32>, +vd: Nat, +loc: U32, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{r, t}:
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +il = ra_vec_get(U32, vd, 0, idx, rm)
      Bool.or(Bool.and(U32.is_ne(rl, il), U32.is_eq(rl, loc)), v4_loc_src(rm, vd, loc, t, U32.add(idx, 1)))
def v4_no_cycle(+rm: RaVec<U32>, +vd: Nat, +all: List<&2, U32>, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{r, t}:
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +il = ra_vec_get(U32, vd, 0, idx, rm)
      Bool.and(Bool.or(U32.is_eq(rl, il), Bool.not(v4_loc_src(rm, vd, il, all, 1))), v4_no_cycle(rm, vd, all, t, U32.add(idx, 1)))
def v4_tail_dir(+rm: RaVec<U32>, +vd: Nat, args: List<&2, U32>, +idx: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{r, t}:
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +il = ra_vec_get(U32, vd, 0, idx, rm)
      +is_d = U32.is_ge(il, 100)
      +dx = Bool.pick(U32, is_d, 0, U32.sub(il, 20))
      v4_tail_dir(rm, vd, t, U32.add(idx, 1), Bool.pick(List<&2, X64Inst>, U32.is_eq(rl, il), acc, v4_xmm_io(False{}, is_d, dx, il, v4_xmm_io(True{}, U32.is_ge(rl, 100), dx, rl, acc))))
def v4_tail_mv(+rm: RaVec<U32>, +vd: Nat, +sbase: U32, +is_ld: Bool, args: List<&2, U32>, +idx: U32, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{r, t}:
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +il = ra_vec_get(U32, vd, 0, idx, rm)
      +loc = Bool.pick(U32, is_ld, il, rl)
      v4_tail_mv(rm, vd, sbase, is_ld, t, U32.add(idx, 1), Bool.pick(List<&2, X64Inst>, U32.is_eq(rl, il), acc, v4_mem_io(is_ld, U32.is_ge(loc, 100), 4, loc, U32.add(sbase, U32.mul(idx, 32)), acc)))
def v4_emit_tail(nc: Bool, +rm: RaVec<U32>, +vd: Nat, +sbase: U32, +tf: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match nc:
    case True{}: v4_tail_dir(rm, vd, tf, 1, acc)
    case False{}: v4_tail_mv(rm, vd, sbase, True{}, tf, 1, v4_tail_mv(rm, vd, sbase, False{}, tf, 1, acc))
def x64_emit_v4_go(name: String, +ar: U32, ops: List<&2, IrOp>, +tf: List<&2, U32>, ra: RegAllocRes) -> X64Fn:
  match ra:
    case RegAllocRes{+rm, +vd, _, +sc}:
      +nc = v4_no_cycle(rm, vd, tf, tf, 1)
      +sbase = U32.add(32, U32.mul(sc, 32))
      +frame = x64_align16(U32.add(U32.add(sbase, 32), Bool.pick(U32, nc, 0, U32.mul(ar, 32))))
      +np = U32.to_nat(U32.sub(ar, 1))
      a0 = x64_emit(XJcc{4, 2}, x64_emit(XTestRR{6, 6}, x64_emit(XAluRI{5, 4, 4294967264}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))))
      a2 = v4_emit_ops(rm, vd, ops, x64_emit(XLabel{1}, v4_io_params(True{}, rm, vd, np, 1, a0)))
      a4 = v4_emit_tail(nc, rm, vd, sbase, tf, a2)
      a5 = v4_io_params(False{}, rm, vd, np, 1, x64_emit(XJcc{5, 1}, x64_emit(XAluRI{1, 6, 1}, a4)))
      X64Fn{String.append("$v8.", name), False{}, b5k_list_rev(X64Inst, x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, x64_emit(XXmmRR{14, 0, 0}, x64_emit(XLabel{2}, a5))))))}
def x64_emit_v4_fn(cal: V4Cal) -> X64Fn:
  V4Cal{+fid, +name, +ar, nregs, +ops, +tf} = cal
  x64_emit_v4_go(name, ar, ops, tf, b5k_regalloc_v4(IrFn{fid, name, ar, nregs, False{}, False{}, False{}, Con{IrBlock{0, ops, TTailCall{fid, Con{0, tf}}}, Nil{}}}))

type V4Scan is Data:
  V4Scan{vmap: RaVec<U32>, fn_map: Map<&2, String>, acc: List<&2, X64Fn>}
def v4_scan_one(mc: Maybe<&2, V4Cal>, st: V4Scan) -> V4Scan:
  match mc st:
    case None{} _: st
    case Some{V4Cal{+fid, +name, +ar, nregs, ops, tf}} V4Scan{vm, fm, acc}:
      V4Scan{ra_vec_set(U32, 8n, fid, ar, vm), Map.set(&2, String, fm, b5k_u32_to_str(U32.add(65536, fid)), String.append("$v8.", name)), Con{x64_emit_v4_fn(V4Cal{fid, name, ar, nregs, ops, tf}), acc}}
def v4_scan_fns(fns: List<&2, IrFn>, st: V4Scan) -> V4Scan:
  match fns:
    case Nil{}: st
    case Con{f, t}: v4_scan_fns(t, v4_scan_one(v4_match_fn(f), st))

def v4_inv_mask(targs: List<&2, U32>, +idx: U32, +m: U32) -> U32:
  match targs:
    case Nil{}: m
    case Con{a, t}: v4_inv_mask(t, U32.add(idx, 1), Bool.pick(U32, U32.is_eq(a, idx), U32.or(m, U32.shln(1, U32.to_nat(idx))), m))
def v4_v_ok(+ar: U32, +im: U32, +vd: Nat, +dm: RaVec<Bool>, +v: U32) -> Bool:
  Bool.pick(Bool, U32.is_lt(v, ar), Bool.or(U32.is_zero(v), U32.is_ne(U32.and(im, U32.shln(1, U32.to_nat(v))), 0)), ra_vec_get(Bool, vd, False{}, v, dm))
type V4Split is Data:
  V4Split{ok: Bool, setup: List<&2, IrOp>, w: U32, cfid: U32, cnt: U32, fargs: List<&2, U32>, post: List<&2, IrOp>, defs: List<&2, U32>}
def v4_split_ops(+vmap: RaVec<U32>, +ar: U32, +im: U32, +vd: Nat, ops: List<&2, IrOp>, +dm: RaVec<Bool>, +srev: List<&2, IrOp>, +drev: List<&2, U32>) -> V4Split:
  match ops:
    case Nil{}: V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}}
    case Con{ICallDirect{w, +cfid, Con{+cnt, +fargs}}, rest}:
      +car = ra_vec_get(U32, 8n, 0, cfid, vmap)
      V4Split{Bool.and(Bool.and(U32.is_ne(car, 0), U32.is_eq(b5k_u32_list_len(fargs), U32.sub(car, 1))), Bool.and(U32.is_lt(cnt, ar), U32.is_ne(U32.and(im, U32.shln(1, U32.to_nat(cnt))), 0))), b5k_list_rev(IrOp, srev), w, cfid, cnt, fargs, rest, b5k_list_rev(U32, drev)}
    case Con{IConst{+d, v}, t}: v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IConst{d, v}, srev}, Con{d, drev})
    case Con{IFlt{+d, b}, t}: v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IFlt{d, b}, srev}, Con{d, drev})
    case Con{ICopy{+d, +s}, t}: Bool.pick(V4Split, v4_v_ok(ar, im, vd, dm, s), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{ICopy{d, s}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{IBin{+d, bop, +l, +r}, t}: Bool.pick(V4Split, Bool.and(v4_v_ok(ar, im, vd, dm, l), v4_v_ok(ar, im, vd, dm, r)), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IBin{d, bop, l, r}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{IUn{+d, uop, +s}, t}: Bool.pick(V4Split, v4_v_ok(ar, im, vd, dm, s), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{IUn{d, uop, s}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case Con{ICmp{+d, cop, +l, +r}, t}: Bool.pick(V4Split, Bool.and(v4_v_ok(ar, im, vd, dm, l), v4_v_ok(ar, im, vd, dm, r)), v4_split_ops(vmap, ar, im, vd, t, ra_vec_set(Bool, vd, d, True{}, dm), Con{ICmp{d, cop, l, r}, srev}, Con{d, drev}), V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}})
    case _: V4Split{False{}, Nil{}, 0, 0, 0, Nil{}, Nil{}, Nil{}}
def v4_s0(+jl: U32, +v: U32) -> U32: Bool.pick(U32, U32.is_zero(v), jl, v)
def v4_s0l(+jl: U32, xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{v, t}: Con{v4_s0(jl, v), v4_s0l(jl, t)}
def v4_s0_op(+jl: U32, op: IrOp) -> IrOp:
  match op:
    case ICopy{d, s}: ICopy{d, v4_s0(jl, s)}
    case IBin{d, b, l, r}: IBin{d, b, v4_s0(jl, l), v4_s0(jl, r)}
    case IUn{d, u, s}: IUn{d, u, v4_s0(jl, s)}
    case ICmp{d, c, l, r}: ICmp{d, c, v4_s0(jl, l), v4_s0(jl, r)}
    case ICallDirect{d, f, a}: ICallDirect{d, f, v4_s0l(jl, a)}
    case ICtor{d, c, fs}: ICtor{d, c, v4_s0l(jl, fs)}
    case ITake{ds, s}: ITake{ds, v4_s0(jl, s)}
    case ITag{d, s}: ITag{d, v4_s0(jl, s)}
    case IKeep{d, s}: IKeep{d, v4_s0(jl, s)}
    case ISink{s}: ISink{v4_s0(jl, s)}
    case IReuse{d, sl, c, fs}: IReuse{d, v4_s0(jl, sl), c, v4_s0l(jl, fs)}
    case o: o
def v4_s0_ops(+jl: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{op, t}: Con{v4_s0_op(jl, op), v4_s0_ops(jl, t)}
def v4_live_outs(+vd: Nat, +pu: RaVec<U32>, ds: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ds:
    case Nil{}: b5k_list_rev(U32, acc)
    case Con{+d, t}: v4_live_outs(vd, pu, t, Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(ra_vec_get(U32, vd, 0, d, pu), 0), Bool.not(x64_u32_in(d, acc))), Con{d, acc}, acc))
def v4_io_fargs(+is_st: Bool, +p4: U32, xs: List<&2, U32>, +k: U32) -> List<&2, IrOp>:
  match xs:
    case Nil{}: Nil{}
    case Con{+v, t}: Con{Bool.pick(IrOp, is_st, IStore{p4, U32.add(65536, U32.mul(k, 8)), v}, ILoad{v, p4, U32.add(65536, U32.mul(k, 8))}), v4_io_fargs(is_st, p4, t, U32.add(k, 1))}
def v4_io_lo(+is_st: Bool, +p8: U32, xs: List<&2, U32>, +m: U32) -> List<&2, IrOp>:
  match xs:
    case Nil{}: Nil{}
    case Con{+v, t}: Con{Bool.pick(IrOp, is_st, IStore{p8, U32.mul(m, 8), v}, ILoad{v, p8, U32.mul(m, 8)}), v4_io_lo(is_st, p8, t, U32.add(m, 1))}
def v4_acc_cp(+ph2: Bool, targs: List<&2, U32>, +idx: U32, +nv: U32) -> List<&2, IrOp>:
  match targs:
    case Nil{}: Nil{}
    case Con{+a, +t}: Bool.pick(List<&2, IrOp>, U32.is_eq(a, idx), v4_acc_cp(ph2, t, U32.add(idx, 1), nv), Con{Bool.pick(IrOp, ph2, ICopy{idx, nv}, ICopy{nv, a}), v4_acc_cp(ph2, t, U32.add(idx, 1), U32.add(nv, 1))})
def v4_max_bid(blks: List<&2, IrBlock>, m: U32) -> U32:
  match blks:
    case Nil{}: m
    case Con{IrBlock{id, _, _}, t}: v4_max_bid(t, U32.max(m, id))
def v4_rw_b0(+sid: U32, +cid: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Con{IrBlock{0, ops, TBr{c, +tb, +eb}}, t}: Con{IrBlock{0, ops, TBr{c, Bool.pick(U32, U32.is_eq(tb, sid), cid, tb), Bool.pick(U32, U32.is_eq(eb, sid), cid, eb)}}, t}
    case bs: bs
def v4_seq(n: Nat, +i: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{i, v4_seq(p, U32.add(i, 1))}
def v4_build_caller(sp: V4Split, +fid: U32, name: String, +ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +sid: U32, +targs: List<&2, U32>) -> IrFn & Bool:
  match sp:
    case V4Split{False{}, _, _, _, _, _, _, _}: (IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{})
    case V4Split{True{}, setup, w, +cfid, cnt, +fargs, +post, defs}:
      +vd = ra_vd_of(U32.max(nregs, ar))
      +los = v4_live_outs(vd, x64_inc_uses(vd, targs, x64_uc_ops(vd, post, RVEmpty{})), defs, Nil{})
      +kf = b5k_u32_list_len(fargs)
      +ml = b5k_u32_list_len(los)
      +nb = U32.add(v4_max_bid(blks, 0), 1)
      +v = nregs
      +a_vs = v4_seq(U32.to_nat(kf), U32.add(v, 18))
      +v_ac = U32.add(U32.add(v, 18), kf)
      +b8_ops: List<&2, IrOp> = [IConst{U32.add(v, 8), U32.mul(kf, 32)}, IBin{U32.add(v, 9), 14, U32.add(v, 2), U32.add(v, 8)}, IConst{U32.add(v, 10), 3}, IBin{U32.add(v, 11), 8, U32.add(v, 3), U32.add(v, 10)}, IBin{U32.add(v, 12), 14, U32.add(v, 9), U32.add(v, 11)}]
      +p4_ops: List<&2, IrOp> = [IConst{U32.add(v, 5), 2}, IBin{U32.add(v, 6), 8, U32.add(v, 3), U32.add(v, 5)}, IBin{U32.add(v, 7), 14, U32.add(v, 2), U32.add(v, 6)}]
      +inc_ops: List<&2, IrOp> = [IConst{U32.add(v, 13), 1}, IBin{U32.add(v, 3), 0, U32.add(v, 3), U32.add(v, 13)}, ICmp{U32.add(v, 14), 2, U32.add(v, 3), v}]
      b_chk: IrBlock = IrBlock{nb, [IConst{v, 8}, ICmp{U32.add(v, 1), 5, 0, v}], TBr{U32.add(v, 1), U32.add(nb, 1), sid}}
      b_ini: IrBlock = IrBlock{U32.add(nb, 1), [IAlloca{U32.add(v, 2), U32.add(U32.mul(kf, 4), U32.mul(ml, 8))}, IConst{U32.add(v, 3), 0}], TJmp{U32.add(nb, 2)}}
      s_lo = Bool.pick(List<&2, IrOp>, U32.is_zero(ml), Nil{}, b5k_list_app(IrOp, b8_ops, v4_io_lo(True{}, U32.add(v, 12), los, 0)))
      b_set: IrBlock = IrBlock{U32.add(nb, 2), b5k_list_app(IrOp, Con{IBin{U32.add(v, 4), 1, 0, U32.add(v, 3)}, v4_s0_ops(U32.add(v, 4), setup)}, b5k_list_app(IrOp, p4_ops, b5k_list_app(IrOp, v4_io_fargs(True{}, U32.add(v, 7), fargs, 0), b5k_list_app(IrOp, s_lo, inc_ops)))), TBr{U32.add(v, 14), U32.add(nb, 2), U32.add(nb, 3)}}
      b_cal: IrBlock = IrBlock{U32.add(nb, 3), [ICallDirect{U32.add(v, 15), U32.add(65536, cfid), [cnt, U32.add(v, 2)]}, IConst{U32.add(v, 3), 0}], TJmp{U32.add(nb, 4)}}
      e_lo = Bool.pick(List<&2, IrOp>, U32.is_zero(ml), Nil{}, b5k_list_app(IrOp, b8_ops, v4_io_lo(False{}, U32.add(v, 12), los, 0)))
      b_epi: IrBlock = IrBlock{U32.add(nb, 4), b5k_list_app(IrOp, Con{IBin{U32.add(v, 4), 1, 0, U32.add(v, 3)}, p4_ops}, b5k_list_app(IrOp, v4_io_fargs(False{}, U32.add(v, 7), a_vs, 0), b5k_list_app(IrOp, e_lo, b5k_list_app(IrOp, [IConst{U32.add(v, 16), 0}, ICallDirect{w, cfid, Con{U32.add(v, 16), a_vs}}], b5k_list_app(IrOp, v4_s0_ops(U32.add(v, 4), post), b5k_list_app(IrOp, v4_acc_cp(False{}, targs, 1, v_ac), b5k_list_app(IrOp, v4_acc_cp(True{}, targs, 1, v_ac), inc_ops))))))), TBr{U32.add(v, 14), U32.add(nb, 4), U32.add(nb, 5)}}
      b_don: IrBlock = IrBlock{U32.add(nb, 5), [IBin{U32.add(v, 17), 1, 0, v}], TTailCall{fid, Con{U32.add(v, 17), v4_seq(U32.to_nat(U32.sub(ar, 1)), 1)}}}
      (IrFn{fid, name, ar, U32.add(v_ac, ar), esc, eff, is_m, b5k_list_app(IrBlock, v4_rw_b0(sid, nb, blks), [b_chk, b_ini, b_set, b_cal, b_epi, b_don])}, True{})
def v4_batch_hdr(h: V4Hdr, vmap: RaVec<U32>, fid: U32, name: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool) -> IrFn & Bool:
  match h:
    case V4Hdr{True{}, vd, _, blks, sid, sops, _, +tr}: v4_build_caller(v4_split_ops(vmap, ar, v4_inv_mask(tr, 1, 0), vd, sops, RVEmpty{}, Nil{}, Nil{}), fid, name, ar, nregs, esc, eff, is_m, blks, sid, tr)
    case V4Hdr{False{}, _, _, blks, _, _, _, _}: (IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}, False{})
# L14-SIMD-2: General 8-Wide AVX1 Counted FP Min/Argmin Reduction Vectorizer
type V8Op is Data:
  V8Lut{dst: U32, vs: List<&2, U32>}
  V8Flt{dst: U32, bits: U32}
  V8Copy{dst: U32, src: U32}
  V8Bin{dst: U32, bop: U32, lhs: U32, rhs: U32}
  V8Un{dst: U32, uop: U32, src: U32}
  V8Sel{dst: U32, cop: U32, lhs: U32, rhs: U32, tval: U32, eval: U32}
type V8Blk is Data:
  V8Blk{ok: Bool, ops: List<&2, IrOp>, term: IrTerm}
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
def v8r_no_red() -> V8Red: V8Red{False{}, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, Nil{}, Nil{}, 0}
def v8r_no_lin(nv: U32) -> V8Lin: V8Lin{False{}, Nil{}, Nil{}, 0, 0, 0, nv}
def v8c_v(c: V8Cmp) -> U32:
  match c:
    case V8Cmp{v, _, _}: v
def v8c_a(c: V8Cmp) -> U32:
  match c:
    case V8Cmp{_, a, _}: a
def v8c_b(c: V8Cmp) -> U32:
  match c:
    case V8Cmp{_, _, b}: b
def v8a_ok(x: V8Arm) -> Bool:
  match x:
    case V8Arm{o, _, _, _}: o
def v8a_d(x: V8Arm) -> U32:
  match x:
    case V8Arm{_, d, _, _}: d
def v8a_j(x: V8Arm) -> U32:
  match x:
    case V8Arm{_, _, j, _}: j
def v8a_b(x: V8Arm) -> U32:
  match x:
    case V8Arm{_, _, _, b}: b
def v8l_ok(x: V8Lin) -> Bool:
  match x:
    case V8Lin{o, _, _, _, _, _, _}: o
def v8l_ops(x: V8Lin) -> List<&2, V8Op>:
  match x:
    case V8Lin{_, os, _, _, _, _, _}: os
def v8l_nv(x: V8Lin) -> U32:
  match x:
    case V8Lin{_, _, _, _, _, _, n}: n
def v8h_ok(x: V8LutHit) -> Bool:
  match x:
    case V8LutHit{o, _, _, _}: o
def v8h_d(x: V8LutHit) -> U32:
  match x:
    case V8LutHit{_, d, _, _}: d
def v8h_j(x: V8LutHit) -> U32:
  match x:
    case V8LutHit{_, _, j, _}: j
def v8h_vs(x: V8LutHit) -> List<&2, U32>:
  match x:
    case V8LutHit{_, _, _, vs}: vs
type V8Pure is Data:
  V8Pure{ok: Bool, ops: List<&2, V8Op>}
def v8p_ok(p: V8Pure) -> Bool:
  match p:
    case V8Pure{o, _}: o
def v8p_ops(p: V8Pure) -> List<&2, V8Op>:
  match p:
    case V8Pure{_, os}: os
def v8r_get_blk(+bid: U32, blks: List<&2, IrBlock>) -> V8Blk:
  match blks:
    case Nil{}: V8Blk{False{}, Nil{}, TFail{0}}
    case Con{IrBlock{id, ops, term}, t}: Bool.pick(V8Blk, U32.is_eq(id, bid), V8Blk{True{}, ops, term}, v8r_get_blk(bid, t))
def v8r_cm_ops(+vd: Nat, ops: List<&2, IrOp>, cm: RaVec<U32>) -> RaVec<U32>:
  match ops:
    case Nil{}: cm
    case Con{IConst{d, val}, t}: v8r_cm_ops(vd, t, ra_vec_set(U32, vd, d, U32.add(val, 1), cm))
    case Con{_, t}: v8r_cm_ops(vd, t, cm)
def v8r_cm_blks(+vd: Nat, blks: List<&2, IrBlock>, cm: RaVec<U32>) -> RaVec<U32>:
  match blks:
    case Nil{}: cm
    case Con{IrBlock{_, ops, _}, t}: v8r_cm_blks(vd, t, v8r_cm_ops(vd, ops, cm))
def v8r_cmp_eq_ops(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +k: U32, +tb: U32, +eb: U32) -> V8Cmp:
  match ops:
    case Nil{}: V8Cmp{0, 0, 0}
    case Con{ICmp{d, +cop, +a, +b}, t}:
      +v1 = Bool.pick(U32, U32.is_eq(a, k), ra_vec_get(U32, vd, 0, b, cm), Bool.pick(U32, U32.is_eq(b, k), ra_vec_get(U32, vd, 0, a, cm), 0))
      +is0 = U32.is_zero(cop)
      Bool.pick(V8Cmp, Bool.and(Bool.and(U32.is_eq(d, c), U32.is_le(cop, 1)), U32.is_ne(v1, 0)), V8Cmp{v1, Bool.pick(U32, is0, tb, eb), Bool.pick(U32, is0, eb, tb)}, v8r_cmp_eq_ops(vd, cm, t, c, k, tb, eb))
    case Con{_, t}: v8r_cmp_eq_ops(vd, cm, t, c, k, tb, eb)
def v8r_cmp_eq(vd: Nat, cm: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +k: U32, +tb: U32, +eb: U32) -> V8Cmp:
  Bool.pick(V8Cmp, U32.is_eq(c, k), V8Cmp{1, eb, tb}, v8r_cmp_eq_ops(vd, cm, ops, c, k, tb, eb))
def v8r_cmp_z_ops(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>, +c: U32, +tb: U32, +eb: U32) -> V8Cmp:
  match ops:
    case Nil{}: V8Cmp{0, 0, 0}
    case Con{ICmp{d, +cop, +a, +b}, t}:
      +r1 = Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, b, cm), 1), U32.add(a, 1), Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, a, cm), 1), U32.add(b, 1), 0))
      +is0 = U32.is_zero(cop)
      Bool.pick(V8Cmp, Bool.and(Bool.and(U32.is_eq(d, c), U32.is_le(cop, 1)), U32.is_ne(r1, 0)), V8Cmp{r1, Bool.pick(U32, is0, tb, eb), Bool.pick(U32, is0, eb, tb)}, v8r_cmp_z_ops(vd, cm, t, c, tb, eb))
    case Con{_, t}: v8r_cmp_z_ops(vd, cm, t, c, tb, eb)
def v8r_cmp_z(vd: Nat, cm: RaVec<U32>, ar: U32, ops: List<&2, IrOp>, +c: U32, +tb: U32, +eb: U32) -> V8Cmp:
  Bool.pick(V8Cmp, U32.is_lt(c, ar), V8Cmp{U32.add(c, 1), eb, tb}, v8r_cmp_z_ops(vd, cm, ops, c, tb, eb))
def v8r_find_dec(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IBin{d, 1, 0, r}, t}: Bool.pick(U32, U32.is_eq(ra_vec_get(U32, vd, 0, r, cm), 2), U32.add(d, 1), v8r_find_dec(vd, cm, t))
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
def v8r_lut_arm(blk: V8Blk) -> V8Arm:
  match blk:
    case V8Blk{True{}, ops, TJmp{j}}:
      +a = v8r_arm_flt(ops, 0, 0, 0)
      V8Arm{v8a_ok(a), v8a_d(a), j, v8a_b(a)}
    case _: V8Arm{False{}, 0, 0, 0}
def v8b_kind(blk: V8Blk) -> U32:
  match blk:
    case V8Blk{True{}, _, TJmp{_}}: 1
    case V8Blk{True{}, _, TBr{_, _, _}}: 2
    case V8Blk{True{}, _, TTailCall{_, _}}: 3
    case _: 0
def v8b_ops(blk: V8Blk) -> List<&2, IrOp>:
  match blk:
    case V8Blk{_, os, _}: os
def v8b_a(blk: V8Blk) -> U32:
  match blk:
    case V8Blk{_, _, TJmp{n}}: n
    case V8Blk{_, _, TBr{c, _, _}}: c
    case V8Blk{_, _, TTailCall{f, _}}: f
    case _: 0
def v8b_b(blk: V8Blk) -> U32:
  match blk:
    case V8Blk{_, _, TBr{_, tb, _}}: tb
    case _: 0
def v8b_c(blk: V8Blk) -> U32:
  match blk:
    case V8Blk{_, _, TBr{_, _, eb}}: eb
    case _: 0
def v8b_args(blk: V8Blk) -> List<&2, U32>:
  match blk:
    case V8Blk{_, _, TTailCall{_, a}}: a
    case _: Nil{}
type V8LSt is Data:
  V8LSt{ok: Bool, ad: U32, aj: U32, bits: U32, neb: U32}
def v8ls_ok(s: V8LSt) -> Bool:
  match s:
    case V8LSt{o, _, _, _, _}: o
def v8ls_ad(s: V8LSt) -> U32:
  match s:
    case V8LSt{_, a, _, _, _}: a
def v8ls_aj(s: V8LSt) -> U32:
  match s:
    case V8LSt{_, _, a, _, _}: a
def v8ls_b(s: V8LSt) -> U32:
  match s:
    case V8LSt{_, _, _, b, _}: b
def v8ls_n(s: V8LSt) -> U32:
  match s:
    case V8LSt{_, _, _, _, n}: n
def v8r_lut_step(blk: V8Blk, vd: Nat, cm: RaVec<U32>, blks: List<&2, IrBlock>, k: U32, +idx: U32, res: U32, join: U32) -> V8LSt:
  match blk:
    case V8Blk{True{}, ops, TBr{c, tb, eb}}:
      +ec = v8r_cmp_eq(vd, cm, ops, c, k, tb, eb)
      +ar = v8r_lut_arm(v8r_get_blk(v8c_a(ec), blks))
      +ad = v8a_d(ar)
      +aj = v8a_j(ar)
      ok2 = Bool.and(Bool.and(U32.is_eq(v8c_v(ec), U32.add(idx, 1)), v8a_ok(ar)), Bool.or(U32.is_zero(idx), Bool.and(U32.is_eq(ad, res), U32.is_eq(aj, join))))
      V8LSt{ok2, ad, aj, v8a_b(ar), v8c_b(ec)}
    case _: V8LSt{False{}, 0, 0, 0, 0}
def v8r_try_lut_go(n: Nat, ok: Bool, +vd: Nat, +cm: RaVec<U32>, +blks: List<&2, IrBlock>, +k: U32, +idx: U32, +res: U32, +join: U32, acc: List<&2, U32>, bid: U32) -> V8LutHit:
  match n ok:
    case _ False{}: V8LutHit{False{}, 0, 0, Nil{}}
    case 0n True{}:
      +da = v8r_lut_arm(v8r_get_blk(bid, blks))
      V8LutHit{Bool.and(v8a_ok(da), Bool.and(U32.is_eq(v8a_d(da), res), U32.is_eq(v8a_j(da), join))), res, join, b5k_list_rev(U32, acc)}
    case 1n+p True{}:
      +st = v8r_lut_step(v8r_get_blk(bid, blks), vd, cm, blks, k, idx, res, join)
      v8r_try_lut_go(p, v8ls_ok(st), vd, cm, blks, k, U32.add(idx, 1), v8ls_ad(st), v8ls_aj(st), Con{v8ls_b(st), acc}, v8ls_n(st))
def v8r_rw_dst(+dst_h: U32, +new_d: U32, +d: U32) -> U32: Bool.pick(U32, Bool.and(U32.is_ne(dst_h, 0), U32.is_eq(d, U32.sub(dst_h, 1))), new_d, d)
def v8r_emit_pure(+vd: Nat, +cm: RaVec<U32>, ops: List<&2, IrOp>, +in_br: Bool, +dst_h: U32, +new_d: U32, acc: List<&2, V8Op>) -> V8Pure:
  match ops:
    case Nil{}: V8Pure{True{}, acc}
    case Con{IConst{_, _}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc)
    case Con{ICmp{_, _, _, _}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc)
    case Con{IFlt{d, b}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Flt{v8r_rw_dst(dst_h, new_d, d), b}, acc})
    case Con{ICopy{d, s}, t}: v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Copy{v8r_rw_dst(dst_h, new_d, d), s}, acc})
    case Con{IBin{_, 1, 0, r}, t}: Bool.pick(V8Pure, U32.is_eq(ra_vec_get(U32, vd, 0, r, cm), 2), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, acc), V8Pure{False{}, Nil{}})
    case Con{IBin{d, +bop, l, r}, t}: Bool.pick(V8Pure, Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Bin{v8r_rw_dst(dst_h, new_d, d), bop, l, r}, acc}), V8Pure{False{}, Nil{}})
    case Con{IUn{d, +uop, s}, t}: Bool.pick(V8Pure, Bool.or(U32.is_eq(uop, 2), U32.is_eq(uop, 3)), v8r_emit_pure(vd, cm, t, in_br, dst_h, new_d, Con{V8Un{v8r_rw_dst(dst_h, new_d, d), Bool.pick(U32, Bool.and(in_br, U32.is_eq(uop, 3)), 4, uop), s}, acc}), V8Pure{False{}, Nil{}})
    case _: V8Pure{False{}, Nil{}}
def v8r_last_dst(ops: List<&2, IrOp>, cur: U32) -> U32:
  match ops:
    case Nil{}: cur
    case Con{IFlt{d, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{ICopy{d, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{IBin{d, _, _, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{IUn{d, _, _}, t}: v8r_last_dst(t, U32.add(d, 1))
    case Con{_, t}: v8r_last_dst(t, cur)
def v8r_blk_jmp_info(blk: V8Blk) -> V8Arm:
  match blk:
    case V8Blk{True{}, ops, TJmp{j}}:
      +ld = v8r_last_dst(ops, 0)
      V8Arm{U32.is_ne(ld, 0), ld, j, 0}
    case _: V8Arm{False{}, 0, 0, 0}
def v8r_find_join(+blks: List<&2, IrBlock>, tb: U32, eb: U32) -> V8Arm:
  +a1 = v8r_blk_jmp_info(v8r_get_blk(tb, blks))
  Bool.pick(V8Arm, v8a_ok(a1), a1, v8r_blk_jmp_info(v8r_get_blk(eb, blks)))
def v8r_lin(fuel: Nat, go: Bool, +vd: Nat, +cm: RaVec<U32>, +fid: U32, +blks: List<&2, IrBlock>, +k: U32, +stop: U32, +dst_h: U32, +new_d: U32, +in_br: Bool, +bid: U32, +acc: List<&2, V8Op>, +nv: U32) -> V8Lin:
  match fuel go:
    case _ False{}: v8r_no_lin(nv)
    case 0n _: v8r_no_lin(nv)
    case 1n++p True{}:
      +done = U32.is_eq(bid, stop)
      +blk = v8r_get_blk(bid, blks)
      +kd = Bool.pick(U32, done, 9, v8b_kind(blk))
      +ops = v8b_ops(blk)
      +a0 = v8b_a(blk)
      +tb = v8b_b(blk)
      +eb = v8b_c(blk)
      +is_j = U32.is_eq(kd, 1)
      +is_b = U32.is_eq(kd, 2)
      +is_t = U32.is_eq(kd, 3)
      +pr = Bool.pick(V8Pure, is_j, v8r_emit_pure(vd, cm, ops, in_br, Bool.pick(U32, U32.is_eq(a0, stop), dst_h, 0), new_d, acc), Bool.pick(V8Pure, Bool.or(is_b, is_t), v8r_emit_pure(vd, cm, ops, in_br, 0, 0, acc), V8Pure{False{}, Nil{}}))
      +pok = v8p_ok(pr)
      +acc1 = v8p_ops(pr)
      +is_lut = Bool.and(is_b, U32.is_eq(v8c_v(v8r_cmp_eq(vd, cm, ops, a0, k, tb, eb)), 1))
      +lh = v8r_try_lut_go(8n, Bool.and(pok, is_lut), vd, cm, blks, k, 0, 0, 0, Nil{}, bid)
      +fc = v8r_fcmp(ops, a0)
      +ja = v8r_find_join(blks, tb, eb)
      +jn = v8a_j(ja)
      +dh = v8a_d(ja)
      +sok = Bool.and(Bool.and(is_b, Bool.and(pok, Bool.not(is_lut))), Bool.and(U32.is_ne(v8c_v(fc), 0), v8a_ok(ja)))
      +tv = nv
      +ev = U32.add(nv, 1)
      +r1 = v8r_lin(p, sok, vd, cm, fid, blks, k, jn, dh, tv, True{}, tb, acc1, U32.add(nv, 2))
      +r2 = v8r_lin(p, v8l_ok(r1), vd, cm, fid, blks, k, jn, dh, ev, True{}, eb, v8l_ops(r1), v8l_nv(r1))
      +sd = v8r_rw_dst(Bool.pick(U32, U32.is_eq(jn, stop), dst_h, 0), new_d, U32.sub(dh, 1))
      +lok = v8h_ok(lh)
      +ltc = v8r_last_flt_lt(ops, V8Cmp{0, 0, 0})
      +cd1 = v8c_v(ltc)
      n_go = Bool.or(Bool.and(is_j, pok), Bool.or(lok, v8l_ok(r2)))
      n_bid = Bool.pick(U32, is_j, a0, Bool.pick(U32, lok, v8h_j(lh), jn))
      n_acc = Bool.pick(List<&2, V8Op>, is_j, acc1, Bool.pick(List<&2, V8Op>, lok, Con{V8Lut{v8h_d(lh), v8h_vs(lh)}, acc1}, Con{V8Sel{sd, v8c_v(fc), v8c_a(fc), v8c_b(fc), tv, ev}, v8l_ops(r2)}))
      n_nv = Bool.pick(U32, Bool.or(is_j, lok), nv, v8l_nv(r2))
      tc_res: V8Lin = V8Lin{Bool.and(Bool.and(U32.is_eq(stop, 4294967295), U32.is_eq(a0, fid)), Bool.and(pok, U32.is_ne(cd1, 0))), acc1, v8b_args(blk), U32.sub(cd1, 1), v8c_a(ltc), v8c_b(ltc), nv}
      Bool.pick(V8Lin, done, V8Lin{True{}, acc, Nil{}, 0, 0, 0, nv}, Bool.pick(V8Lin, is_t, tc_res, v8r_lin(p, n_go, vd, cm, fid, blks, k, stop, dst_h, new_d, in_br, n_bid, n_acc, n_nv)))
def v8r_classify(tf: List<&2, U32>, tt: List<&2, U32>, go: Bool, +lt_p: U32, +cmp_d: U32, +cmp_t: U32, +cmp_bt: U32, +k_reg: U32, +idx: U32, +pt: U32, +pk: U32, +bi: U32, +invs: List<&2, U32>) -> V8Cls:
  match tf tt go:
    case _ _ False{}: V8Cls{False{}, 0, 0, 0, Nil{}}
    case Nil{} Nil{} True{}: V8Cls{Bool.and(U32.is_ne(pt, 0), Bool.or(U32.is_zero(pk), U32.is_ne(bi, 0))), pt, pk, bi, b5k_list_rev(U32, invs)}
    case Con{+af, rf} Con{+at, rt} True{}:
      +is_lt = U32.is_eq(idx, lt_p)
      +is_pt = Bool.and(Bool.not(is_lt), U32.is_eq(af, cmp_t))
      +is_pk = Bool.and(Bool.not(Bool.or(is_lt, is_pt)), U32.is_eq(af, k_reg))
      +is_id = Bool.and(Bool.not(Bool.or(is_lt, Bool.or(is_pt, is_pk))), U32.is_eq(af, idx))
      +ok = Bool.or(Bool.and(is_lt, U32.is_eq(af, cmp_d)), Bool.or(is_pt, Bool.or(is_pk, is_id)))
      +is_inv = Bool.and(is_id, Bool.and(U32.is_ne(idx, cmp_bt), U32.is_eq(at, idx)))
      +is_bi = Bool.and(is_id, Bool.and(U32.is_ne(idx, cmp_bt), U32.is_ne(at, idx)))
      v8r_classify(rf, rt, ok, lt_p, cmp_d, cmp_t, cmp_bt, k_reg, U32.add(idx, 1), Bool.pick(U32, is_pt, idx, pt), Bool.pick(U32, is_pk, idx, pk), Bool.pick(U32, is_bi, idx, bi), Bool.pick(List<&2, U32>, is_inv, Con{idx, invs}, invs))
    case _ _ _: V8Cls{False{}, 0, 0, 0, Nil{}}
def v8r_skip_z_go(blk: V8Blk, vd: Nat, cm: RaVec<U32>, ar: U32, bid: U32) -> U32:
  match blk:
    case V8Blk{True{}, ops, TBr{c, tb, eb}}:
      +cz = v8r_cmp_z(vd, cm, ar, ops, c, tb, eb)
      Bool.pick(U32, U32.is_eq(v8c_v(cz), 1), v8c_b(cz), bid)
    case _: bid
def v8r_blk_k_go(blk: V8Blk, vd: Nat, cm: RaVec<U32>, defk: U32) -> U32:
  match blk:
    case V8Blk{True{}, ops, _}:
      +k2 = v8r_find_dec(vd, cm, ops)
      Bool.pick(U32, U32.is_ne(k2, 0), U32.sub(k2, 1), defk)
    case _: defk
def v8r_match_cls(cls: V8Cls, fid: U32, name: String, +ar: U32, nv1: U32, sid: U32, lt_p: U32, k_reg: U32, fk: U32, ct: U32, +cbt: U32, cbt2: U32, fops: List<&2, V8Op>) -> V8Red:
  match cls:
    case V8Cls{cok, +pt, pk, bi, invs}:
      ok = Bool.and(Bool.and(U32.is_eq(fk, k_reg), U32.is_eq(cbt2, pt)), Bool.and(cok, Bool.and(U32.is_ge(cbt, 1), U32.is_lt(cbt, ar))))
      V8Red{ok, fid, name, ar, nv1, sid, lt_p, pt, pk, cbt, bi, invs, b5k_list_rev(V8Op, fops), ct}
def v8r_match_l2(l2: V8Lin, fid: U32, name: String, ar: U32, nv1: U32, sid: U32, +lt_p: U32, +k_reg: U32, fk: U32, ftr: List<&2, U32>, cd: U32, +ct: U32, +cbt: U32, fops: List<&2, V8Op>) -> V8Red:
  match l2:
    case V8Lin{True{}, _, Con{_, ttr}, _, _, cbt2, _}: v8r_match_cls(v8r_classify(ftr, ttr, True{}, lt_p, cd, ct, cbt, k_reg, 1, 0, 0, 0, Nil{}), fid, name, ar, nv1, sid, lt_p, k_reg, fk, ct, cbt, cbt2, fops)
    case _: v8r_no_red()
def v8r_match_fin(+vd: Nat, +cm: RaVec<U32>, +fid: U32, name: String, ar: U32, +blks: List<&2, IrBlock>, sid: U32, lt_p: U32, +k_reg: U32, +bt: U32, l1: V8Lin) -> V8Red:
  match l1:
    case V8Lin{True{}, fops, Con{fk, ftr}, cd, ct, cbt, +nv1}: v8r_match_l2(v8r_lin(64n, True{}, vd, cm, fid, blks, v8r_blk_k_go(v8r_get_blk(bt, blks), vd, cm, k_reg), 4294967295, 0, 0, False{}, bt, Nil{}, nv1), fid, name, ar, nv1, sid, lt_p, k_reg, fk, ftr, cd, ct, cbt, fops)
    case _: v8r_no_red()
def v8r_match_step(go: Bool, blk: V8Blk, +vd: Nat, +cm: RaVec<U32>, +fid: U32, name: String, +ar: U32, nregs: U32, +blks: List<&2, IrBlock>, sid: U32) -> V8Red:
  match go blk:
    case True{} V8Blk{True{}, +ops, TBr{c, tb, eb}}:
      +k1 = v8r_find_dec(vd, cm, ops)
      +cz = v8r_cmp_z(vd, cm, ar, ops, c, tb, eb)
      +lt1 = v8c_v(cz)
      +ok = Bool.and(U32.is_ne(k1, 0), Bool.and(U32.is_gt(lt1, 1), U32.is_lt(U32.sub(lt1, 1), ar)))
      +k_reg = U32.sub(k1, 1)
      v8r_match_fin(vd, cm, fid, name, ar, blks, sid, U32.sub(lt1, 1), k_reg, v8c_b(cz), v8r_lin(64n, ok, vd, cm, fid, blks, k_reg, 4294967295, 0, 0, False{}, v8c_a(cz), Nil{}, nregs))
    case _ _: v8r_no_red()
def v8r_match_b0(blk: V8Blk, +vd: Nat, +cm: RaVec<U32>, fid: U32, name: String, +ar: U32, nregs: U32, +blks: List<&2, IrBlock>) -> V8Red:
  match blk:
    case V8Blk{True{}, ops, TBr{c, tb, eb}}:
      +cz = v8r_cmp_z(vd, cm, ar, ops, c, tb, eb)
      +nzb = v8c_b(cz)
      +step = v8r_skip_z_go(v8r_get_blk(nzb, blks), vd, cm, ar, nzb)
      v8r_match_step(Bool.and(Bool.and(U32.is_ge(ar, 4), U32.is_le(ar, 20)), U32.is_eq(v8c_v(cz), 1)), v8r_get_blk(step, blks), vd, cm, fid, name, ar, nregs, blks, nzb)
    case _: v8r_no_red()
def v8r_match_fn(f: IrFn) -> V8Red:
  match f:
    case IrFn{fid, name, +ar, +nregs, _, False{}, False{}, +blks}:
      +vd = ra_vd_of(U32.max(nregs, ar))
      v8r_match_b0(v8r_get_blk(0, blks), vd, v8r_cm_blks(vd, blks, RVEmpty{}), fid, name, ar, nregs, blks)
    case _: v8r_no_red()

def v8r_dummy_ops(ops: List<&2, V8Op>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{V8Lut{d, _}, t}: Con{IFlt{d, 0}, v8r_dummy_ops(t)}
    case Con{V8Flt{d, b}, t}: Con{IFlt{d, b}, v8r_dummy_ops(t)}
    case Con{V8Copy{d, s}, t}: Con{ICopy{d, s}, v8r_dummy_ops(t)}
    case Con{V8Bin{d, b, l, r}, t}: Con{IBin{d, b, l, r}, v8r_dummy_ops(t)}
    case Con{V8Un{d, +u, s}, t}: Con{IUn{d, Bool.pick(U32, U32.is_eq(u, 4), 3, u), s}, v8r_dummy_ops(t)}
    case Con{V8Sel{+d, _, l, r, tv, ev}, t}: Con{IBin{d, 10, l, r}, Con{IBin{d, 10, tv, ev}, v8r_dummy_ops(t)}}
def v8r_emit_lut_vals(vs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match vs:
    case Nil{}: acc
    case Con{v, t}: v8r_emit_lut_vals(t, x64_emit(XExtReloc{1, "", v}, acc))
def v8r_emit_inv_one(is_z: Bool, is_sp: Bool, loc: U32, off: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_z is_sp:
    case True{} _: acc
    case False{} True{}: x64_emit(XXmmStore{4, v4_disp(loc), 48}, x64_emit(XXmmLoad{48, 6, off}, acc))
    case False{} False{}: x64_emit(XXmmLoad{U32.add(48, U32.sub(loc, 20)), 6, off}, acc)
def v8r_emit_invs(+rm: RaVec<U32>, +vd: Nat, invs: List<&2, U32>, +m: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match invs:
    case Nil{}: acc
    case Con{p, t}:
      +loc = ra_vec_get(U32, vd, 0, p, rm)
      v8r_emit_invs(rm, vd, t, U32.add(m, 1), v8r_emit_inv_one(U32.is_zero(loc), U32.is_ge(loc, 100), loc, U32.add(16, U32.mul(m, 4)), acc))
def v8r_emit_op(+rm: RaVec<U32>, +vd: Nat, op: V8Op, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case V8Lut{d, vs}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +ds = U32.is_ge(dl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      v4_xmm_io(False{}, ds, dx, dl, x64_emit(XXmmLoad{U32.add(32, dx), 0, 0}, v8r_emit_lut_vals(vs, x64_emit(XExtReloc{2, "", 0}, acc))))
    case V8Flt{d, b}: v4_emit_op(rm, vd, IFlt{d, b}, acc)
    case V8Copy{d, s}: v4_emit_op(rm, vd, ICopy{d, s}, acc)
    case V8Bin{d, b, l, r}: v4_emit_op(rm, vd, IBin{d, b, l, r}, acc)
    case V8Un{d, 4, s}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +sl = ra_vec_get(U32, vd, 0, s, rm)
      +ds = U32.is_ge(dl, 100)
      +ss = U32.is_ge(sl, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      v4_xmm_io(False{}, ds, dx, dl, x64_emit(XXmmRR{260, dx, dx}, x64_emit(XXmmRR{v4_vex_op(Bool.pick(U32, ss, 0, U32.sub(sl, 20)), 5), dx, 1}, x64_emit(XXmmRR{v4_vex_op(1, 6), 1, 1}, v4_ld_sp(ss, 0, sl, acc)))))
    case V8Un{d, u, s}: v4_emit_op(rm, vd, IUn{d, u, s}, acc)
    case V8Sel{d, +cop, l, r, tv, ev}:
      +dl = ra_vec_get(U32, vd, 0, d, rm)
      +ll = ra_vec_get(U32, vd, 0, l, rm)
      +rl = ra_vec_get(U32, vd, 0, r, rm)
      +tl = ra_vec_get(U32, vd, 0, tv, rm)
      +el = ra_vec_get(U32, vd, 0, ev, rm)
      +ds = U32.is_ge(dl, 100)
      +ls = U32.is_ge(ll, 100)
      +rs = U32.is_ge(rl, 100)
      +ts = U32.is_ge(tl, 100)
      +es = U32.is_ge(el, 100)
      +dx = Bool.pick(U32, ds, 0, U32.sub(dl, 20))
      +lx = Bool.pick(U32, ls, 0, U32.sub(ll, 20))
      +rx = Bool.pick(U32, rs, 1, U32.sub(rl, 20))
      +sw = U32.is_ge(cop, 10)
      a_c = x64_emit(XXmmRR{v4_vex_op(Bool.pick(U32, sw, rx, lx), Bool.pick(U32, Bool.or(U32.is_eq(cop, 8), U32.is_eq(cop, 10)), 8, 9)), 1, Bool.pick(U32, sw, lx, rx)}, v4_ld_sp(rs, 1, rl, v4_ld_sp(ls, 0, ll, acc)))
      +ex = Bool.pick(U32, es, Bool.pick(U32, ts, dx, 0), U32.sub(el, 20))
      +tx = Bool.pick(U32, ts, 0, U32.sub(tl, 20))
      v4_xmm_io(False{}, ds, dx, dl, x64_emit(XXmmRR{v4_vex_op(ex, 12), dx, tx}, v4_ld_sp(ts, 0, tl, v4_ld_sp(es, ex, el, a_c))))
def v8r_emit_ops(+rm: RaVec<U32>, +vd: Nat, ops: List<&2, V8Op>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ops:
    case Nil{}: acc
    case Con{op, t}: v8r_emit_ops(rm, vd, t, v8r_emit_op(rm, vd, op, acc))
def v8r_emit_fn_go(name: String, +has_idx: Bool, invs: List<&2, U32>, ops: List<&2, V8Op>, res_v: U32, ra: RegAllocRes) -> X64Fn:
  match ra:
    case RegAllocRes{+rm, +vd, _, sc}:
      +frame = x64_align16(U32.add(64, U32.mul(sc, 32)))
      a0 = x64_emit(XAluRI{5, 4, 4294967264}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = v8r_emit_ops(rm, vd, ops, v8r_emit_invs(rm, vd, invs, 0, a0))
      +rl = ra_vec_get(U32, vd, 0, res_v, rm)
      +rs = U32.is_ge(rl, 100)
      +rx = Bool.pick(U32, rs, 0, U32.sub(rl, 20))
      a2 = x64_emit(XXmmRR{14, 0, 0}, x64_emit(XXmmStore{4, 0, U32.add(48, rx)}, v4_ld_sp(rs, 0, rl, a1)))
      a3 = x64_emit_if(has_idx, XLoad{0, 6, 8}, x64_emit(XXmmLoad{0, 6, 0}, a2))
      a4 = x64_emit(XJcc{6, 2}, x64_emit(XXmmRR{5, 0, 1}, x64_emit(XXmmLoad{1, 2, 0}, x64_emit(XAluRI{1, 1, 1}, x64_emit(XLabel{1}, x64_emit(XMovRI32{1, 8}, x64_emit(XAluRI{0, 2, 28}, x64_emit(XMovRR{2, 4}, a3))))))))
      a5 = x64_emit_if(has_idx, XMovRR{0, 1}, x64_emit(XXmmRR{7, 0, 1}, a4))
      a6 = x64_emit_if(has_idx, XStore{6, 8, 0}, x64_emit(XXmmStore{6, 0, 32}, x64_emit(XJcc{5, 1}, x64_emit(XTestRR{1, 1}, x64_emit(XAluRI{1, 2, 4}, x64_emit(XLabel{2}, a5))))))
      X64Fn{String.append("$v8r.", name), False{}, b5k_list_rev(X64Inst, x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, a6))))}
def x64_emit_v8r_fn(red: V8Red) -> X64Fn:
  V8Red{_, fid, +name, ar, nregs, _, _, _, pk_p, _, _, +invs, +ops, +res_v} = red
  v8r_emit_fn_go(name, U32.is_ne(pk_p, 0), invs, ops, res_v, b5k_regalloc_v4(IrFn{fid, name, ar, nregs, False{}, False{}, False{}, Con{IrBlock{0, v8r_dummy_ops(ops), TRet{res_v}}, Nil{}}}))
def v8r_store_invs(+buf: U32, invs: List<&2, U32>, +m: U32) -> List<&2, IrOp>:
  match invs:
    case Nil{}: Nil{}
    case Con{p, t}: Con{IStore{buf, U32.add(65540, m), p}, v8r_store_invs(buf, t, U32.add(m, 1))}
def v8r_tc_args(n: Nat, +idx: U32, +lt_p: U32, +pt_p: U32, +pk_p: U32, +bt_p: U32, +bi_p: U32, +nbt: U32, +nbi: U32, +zv: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p:
      a = Bool.pick(U32, U32.is_eq(idx, lt_p), zv, Bool.pick(U32, Bool.or(U32.is_eq(idx, bt_p), U32.is_eq(idx, pt_p)), nbt, Bool.pick(U32, Bool.and(U32.is_ne(pk_p, 0), Bool.or(U32.is_eq(idx, bi_p), U32.is_eq(idx, pk_p))), nbi, idx)))
      Con{a, v8r_tc_args(p, U32.add(idx, 1), lt_p, pt_p, pk_p, bt_p, bi_p, nbt, nbi, zv)}
def v8r_splice(red: V8Red, f: IrFn) -> IrFn & Bool:
  match red f:
    case V8Red{False{}, _, _, _, _, _, _, _, _, _, _, _, _, _} _: (f, False{})
    case V8Red{True{}, +fid, _, +ar, _, +sid, +lt_p, +pt_p, +pk_p, +bt_p, +bi_p, +invs, _, _} IrFn{_, name, _, +nregs, esc, eff, is_m, +blks}:
      +hi = U32.is_ne(pk_p, 0)
      +nb = U32.add(v4_max_bid(blks, 0), 1)
      +v = nregs
      +buf = U32.add(v, 2)
      +words = U32.add(2, U32.shrn(U32.add(b5k_u32_list_len(invs), 1), 1n))
      b_chk: IrBlock = IrBlock{nb, [IConst{v, 8}, ICmp{U32.add(v, 1), 0, 0, v}], TBr{U32.add(v, 1), U32.add(nb, 1), sid}}
      b_ini: IrBlock = IrBlock{U32.add(nb, 1), [IAlloca{buf, words}, IConst{U32.add(v, 3), 0}, ICmp{U32.add(v, 4), 0, lt_p, U32.add(v, 3)}], TBr{U32.add(v, 4), U32.add(nb, 2), U32.add(nb, 3)}}
      s0 = Bool.pick(List<&2, IrOp>, hi, [IStore{buf, 65536, bt_p}, IStore{buf, 1, bi_p}], [IStore{buf, 65536, bt_p}])
      s1 = Bool.pick(List<&2, IrOp>, hi, [IStore{buf, 65536, pt_p}, IStore{buf, 1, pk_p}], [IStore{buf, 65536, pt_p}])
      b_lt0: IrBlock = IrBlock{U32.add(nb, 2), s0, TJmp{U32.add(nb, 4)}}
      b_lt1: IrBlock = IrBlock{U32.add(nb, 3), s1, TJmp{U32.add(nb, 4)}}
      +nbt = U32.add(v, 6)
      +nbi = U32.add(v, 7)
      +zv = U32.add(v, 8)
      lds = Bool.pick(List<&2, IrOp>, hi, [ILoad{nbt, buf, 65536}, ILoad{nbi, buf, 1}, IConst{zv, 0}], [ILoad{nbt, buf, 65536}, IConst{zv, 0}])
      b_cal: IrBlock = IrBlock{U32.add(nb, 4), b5k_list_app(IrOp, v8r_store_invs(buf, invs, 0), Con{ICallDirect{U32.add(v, 5), U32.add(131072, fid), [buf]}, lds}), TTailCall{fid, Con{zv, v8r_tc_args(U32.to_nat(U32.sub(ar, 1)), 1, lt_p, pt_p, pk_p, bt_p, bi_p, nbt, nbi, zv)}}}
      (IrFn{fid, name, ar, U32.add(v, 9), esc, eff, is_m, b5k_list_app(IrBlock, v4_rw_b0(sid, nb, blks), [b_chk, b_ini, b_lt0, b_lt1, b_cal])}, True{})
def v8r_scan_one(red: V8Red, st: V4Scan) -> V4Scan:
  match red st:
    case V8Red{False{}, _, _, _, _, _, _, _, _, _, _, _, _, _} _: st
    case V8Red{True{}, +fid, +name, ar, nregs, sid, lt_p, pt_p, pk_p, bt_p, bi_p, invs, ops, res_v} V4Scan{vm, fm, acc}:
      V4Scan{vm, Map.set(&2, String, fm, b5k_u32_to_str(U32.add(131072, fid)), String.append("$v8r.", name)), Con{x64_emit_v8r_fn(V8Red{True{}, fid, name, ar, nregs, sid, lt_p, pt_p, pk_p, bt_p, bi_p, invs, ops, res_v}), acc}}
def v8r_scan_fns(fns: List<&2, IrFn>, st: V4Scan) -> V4Scan:
  match fns:
    case Nil{}: st
    case Con{f, t}: v8r_scan_fns(t, v8r_scan_one(v8r_match_fn(f), st))
def v4_try_batch_go(vmap: RaVec<U32>, r: IrFn & Bool) -> IrFn & Bool:
  (f1, ok1) = r
  match f1 ok1:
    case f True{}: (f, True{})
    case IrFn{+fid, +name, +ar, +nregs, +esc, +eff, +is_m, blks} False{}: v4_batch_hdr(v4_loop_hdr(IrFn{fid, name, ar, nregs, esc, eff, is_m, blks}), vmap, fid, name, ar, nregs, esc, eff, is_m)
def v4_try_batch(vmap: RaVec<U32>, +f: IrFn) -> IrFn & Bool:
  v4_try_batch_go(vmap, v8r_splice(v8r_match_fn(f), f))
def x64_lower_all_o2(fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, rf: X64RotFn, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match rf:
    case X64RotFn{+f, t0d}: Con{x64_make_seg_wrapper(f), x64_lower_fn_o2_go(fn_map, heap_off, r2s, t0d, b5k_regalloc(f), f, acc)}
def x64_lower_one_o2(fn_map: Map<&2, String>, heap_off: U32, r2s: X64R2Scan, bf: IrFn & Bool, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  (+f, batched) = bf
  match batched:
    case True{}: Con{x64_make_seg_wrapper(f), x64_lower_fn_o2_go(fn_map, heap_off, r2s, False{}, b5k_regalloc(f), f, acc)}
    case False{}: x64_lower_all_o2(fn_map, heap_off, r2s, x64_rot_countdown(f), acc)
def x64_lower_all(+is_o2: Bool, +vmap: RaVec<U32>, +fn_map: Map<&2, String>, +heap_off: U32, +r2s: X64R2Scan, fns: List<&2, IrFn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_o2 fns:
    case _ Nil{}: acc
    case False{} Con{+f, t}: x64_lower_all(False{}, vmap, fn_map, heap_off, r2s, t, Con{x64_make_seg_wrapper(f), Con{x64_lower_fn(fn_map, heap_off, f), acc}})
    case True{} Con{f, t}: x64_lower_all(True{}, vmap, fn_map, heap_off, r2s, t, x64_lower_one_o2(fn_map, heap_off, r2s, v4_try_batch(vmap, f), acc))
def x64_codegen_v4(+fns: List<&2, IrFn>, heap_off: U32, sc: V4Scan) -> List<&2, X64Fn>:
  match sc:
    case V4Scan{vm, fm1, acc1}: b5k_list_rev(X64Fn, x64_lower_all(True{}, vm, fm1, heap_off, x64_scan_ret2(True{}, fns), fns, acc1))
def x64_codegen_go(is_o2: Bool, +fns: List<&2, IrFn>, heap_off: U32, fm0: Map<&2, String>, acc0: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_o2:
    case False{}: b5k_list_rev(X64Fn, x64_lower_all(False{}, RVEmpty{}, fm0, heap_off, x64_scan_ret2(False{}, fns), fns, acc0))
    case True{}: x64_codegen_v4(fns, heap_off, v8r_scan_fns(fns, v4_scan_fns(fns, V4Scan{RVEmpty{}, fm0, acc0})))
def x64_codegen(+is_o2: Bool, prog: IrProg) -> List<&2, X64Fn>:
  match prog:
    case IrProg{+fns, _, statics, _, _, _, _, _}:
      x64_codegen_go(is_o2, fns, x64_heap_off(statics), x64_build_fn_map_go(fns, Map.new(&2, String)), Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}})
def b5k_codegen(prog: IrProg) -> List<&2, X64Fn>:
  x64_codegen(False{}, prog)
def b5k_codegen_o2(prog: IrProg) -> List<&2, X64Fn>:
  x64_codegen(True{}, prog)
