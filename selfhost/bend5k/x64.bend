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

def X64_RAX() -> U32: 0
def X64_RCX() -> U32: 1
def X64_RDX() -> U32: 2
def X64_RSP() -> U32: 4
def X64_RBP() -> U32: 5
def X64_RSI() -> U32: 6
def X64_RDI() -> U32: 7
def X64_R8()  -> U32: 8
def X64_R9()  -> U32: 9

type X64Ctx is Data:
  X64Ctx{is_o2: Bool, reg_map: RaVec<U32>, vd: Nat, spill_base: U32, state_disp: U32, mem_reg: U32, mem_disp: U32, frame: U32, used_callee: List<&2, U32>, heap_off: U32}

def x64_mk_ctx(is_o2: Bool, rm: RaVec<U32>, vd: Nat, sb: U32, sd: U32, mr: U32, md: U32, frame: U32, ce: List<&2, U32>, ho: U32) -> X64Ctx:
  X64Ctx{is_o2, rm, vd, sb, sd, mr, md, frame, ce, ho}

def x64_ctx_heap_off(ctx: X64Ctx) -> U32:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, _, ho}: ho

def x64_ctx_vd(ctx: X64Ctx) -> Nat:
  match ctx:
    case X64Ctx{_, _, vd, _, _, _, _, _, _, _}: vd

def x64_heap_off(statics: List<&2, U32>) -> U32:
  n = b5k_u32_list_len(statics)
  U32.add(51413504, U32.and(U32.add(n, 127), U32.sub(0, 128)))

def x64_arg_reg(+i: U32) -> U32:
  r3 = Bool.pick(U32, U32.is_eq(i, 3), 8, 9)
  r2 = Bool.pick(U32, U32.is_eq(i, 2), 1, r3)
  r1 = Bool.pick(U32, U32.is_eq(i, 1), 2, r2)
  Bool.pick(U32, U32.is_eq(i, 0), 6, r1)

def x64_o2_arg_reg(+i: U32) -> U32:
  r3 = Bool.pick(U32, U32.is_eq(i, 3), 0, 7)
  r2 = Bool.pick(U32, U32.is_eq(i, 2), 1, r3)
  r1 = Bool.pick(U32, U32.is_eq(i, 1), 2, r2)
  Bool.pick(U32, U32.is_eq(i, 0), 6, r1)

def x64_cmp_cc(+op: U32) -> U32:
  c4 = Bool.pick(U32, U32.is_eq(op, 4), 7, 3)
  c3 = Bool.pick(U32, U32.is_eq(op, 3), 6, c4)
  c2 = Bool.pick(U32, U32.is_eq(op, 2), 2, c3)
  c1 = Bool.pick(U32, U32.is_eq(op, 1), 5, c2)
  Bool.pick(U32, U32.is_eq(op, 0), 4, c1)

def x64_state_disp() -> U32:
  U32.sub(0, 8)

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

def x64_opt_mov(cond: Bool, d: U32, s: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match cond:
    case True{}: Con{XMovRR{d, s}, acc}
    case False{}: acc

def x64_vreg_loc(ctx: X64Ctx, v: U32) -> U32:
  match ctx:
    case X64Ctx{False{}, _, _, _, _, _, _, _, _, _}: U32.add(100, v)
    case X64Ctx{True{}, rm, vd, _, _, _, _, _, _, _}: ra_vec_get(U32, vd, 0, v, rm)

def x64_spill_disp(ctx: X64Ctx, loc: U32) -> U32:
  match ctx:
    case X64Ctx{_, _, _, sb, _, _, _, _, _, _}: U32.sub(0, U32.add(sb, U32.mul(U32.sub(loc, 100), 8)))

def x64_is_o2(ctx: X64Ctx) -> Bool:
  match ctx:
    case X64Ctx{o2, _, _, _, _, _, _, _, _, _}: o2

def x64_is_gpr(loc: U32) -> Bool:
  U32.is_lt(loc, 20)

def x64_is_xmm(+loc: U32) -> Bool:
  Bool.and(U32.is_ge(loc, 20), U32.is_lt(loc, 100))

def x64_load_vreg_go(is_sp: Bool, is_xm: Bool, same: Bool, ctx: X64Ctx, reg: U32, loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm same:
    case True{} _ _: Con{XLoad{reg, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{} _: Con{XCvt{3, reg, U32.sub(loc, 20)}, acc}
    case False{} False{} True{}: acc
    case False{} False{} False{}: Con{XMovRR{reg, loc}, acc}

def x64_load_vreg(+ctx: X64Ctx, +reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_load_vreg_go(U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, reg, loc, acc)

def x64_store_vreg_go(is_sp: Bool, is_xm: Bool, same: Bool, ctx: X64Ctx, loc: U32, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm same:
    case True{} _ _: Con{XStore{5, x64_spill_disp(ctx, loc), reg}, acc}
    case False{} True{} _: Con{XCvt{2, U32.sub(loc, 20), reg}, acc}
    case False{} False{} True{}: acc
    case False{} False{} False{}: Con{XMovRR{loc, reg}, acc}

def x64_store_vreg(+ctx: X64Ctx, v: U32, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_store_vreg_go(U32.is_ge(loc, 100), x64_is_xmm(loc), U32.is_eq(loc, reg), ctx, loc, reg, acc)

def x64_opt_xmm_mov(same: Bool, dst: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match same:
    case True{}: acc
    case False{}: Con{XXmmRR{7, dst, src}, acc}

def x64_load_xmm_go(is_sp: Bool, is_xm: Bool, ctx: X64Ctx, +xmm: U32, +loc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm:
    case True{} _: Con{XXmmLoad{xmm, 5, x64_spill_disp(ctx, loc)}, acc}
    case False{} True{}:
      +xr = U32.sub(loc, 20)
      x64_opt_xmm_mov(U32.is_eq(xr, xmm), xmm, xr, acc)
    case False{} False{}: Con{XCvt{2, xmm, loc}, acc}

def x64_load_xmm(+ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_load_xmm_go(U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, xmm, loc, acc)

def x64_store_xmm_go(is_sp: Bool, is_xm: Bool, ctx: X64Ctx, +loc: U32, +xmm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm:
    case True{} _: Con{XXmmStore{5, x64_spill_disp(ctx, loc), xmm}, acc}
    case False{} True{}:
      +xr = U32.sub(loc, 20)
      x64_opt_xmm_mov(U32.is_eq(xr, xmm), xr, xmm, acc)
    case False{} False{}: Con{XCvt{3, loc, xmm}, acc}

def x64_store_xmm(+ctx: X64Ctx, v: U32, xmm: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +loc = x64_vreg_loc(ctx, v)
  x64_store_xmm_go(U32.is_ge(loc, 100), x64_is_xmm(loc), ctx, loc, xmm, acc)

def x64_emit_const_go(is_sp: Bool, is_xm: Bool, ctx: X64Ctx, loc: U32, val: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp is_xm:
    case True{} _: Con{XStore{5, x64_spill_disp(ctx, loc), 0}, Con{XMovRI32{0, val}, acc}}
    case False{} True{}: Con{XCvt{2, U32.sub(loc, 20), 0}, Con{XMovRI32{0, val}, acc}}
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
    case X64Ctx{_, _, _, _, sd, _, _, _, _, _}: Con{XLoad{reg, 5, sd}, acc}

def x64_load_mem_go(has_r: Bool, has_d: Bool, mr: U32, md: U32, sd: U32, +reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r has_d:
    case True{} _: Con{XMovRR{reg, mr}, acc}
    case False{} True{}: Con{XLoad{reg, 5, md}, acc}
    case False{} False{}: Con{XLoad{reg, reg, 0}, Con{XLoad{reg, 5, sd}, acc}}

def x64_load_mem(ctx: X64Ctx, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, sd, +mr, +md, _, _, _}:
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
    case True{}:
      a1 = x64_opt_mov(U32.is_ge(nargs, 4), 8, 0, acc)
      x64_opt_mov(U32.is_ge(nargs, 5), 9, 7, a1)

def x64_opt_sub_rsp(odd: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match odd:
    case True{}: Con{XSubRsp{8}, acc}
    case False{}: acc

def x64_emit_call_go(+ctx: X64Ctx, has_extra: Bool, +nargs: U32, sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_extra:
    case False{}:
      a1 = x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, acc))
      Con{XCallSym{sym}, x64_load_state(ctx, 7, a1)}
    case True{}:
      +extra_cnt = U32.sub(nargs, 5)
      +odd = U32.is_eq(U32.and(extra_cnt, 1), 1)
      a0 = x64_opt_sub_rsp(odd, acc)
      extra_rev = b5k_list_rev(U32, x64_drop_u32(5n, args))
      a1 = x64_push_extra_args(ctx, extra_rev, a0)
      a2 = x64_finish_o2_call_args(x64_is_o2(ctx), nargs, x64_load_reg_args(ctx, args, 0, True{}, a1))
      a3 = x64_emit(XCallSym{sym}, x64_load_state(ctx, 7, a2))
      pop_bytes = U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)
      Con{XAddRsp{pop_bytes}, a3}

def x64_emit_call(ctx: X64Ctx, sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +nargs = b5k_u32_list_len(args)
  x64_emit_call_go(ctx, U32.is_gt(nargs, 5), nargs, sym, args, acc)

def x64_mask32(+reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XShift{9, reg, 32, False{}}, Con{XShift{8, reg, 32, False{}}, acc}}

def x64_opt_mask32(need: Bool, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match need:
    case True{}: x64_mask32(reg, acc)
    case False{}: acc

def x64_bin_step4(is_sh: Bool, +op: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sh:
    case True{}: x64_opt_mask32(U32.is_eq(op, 8), 0, Con{XShift{op, 0, 0, True{}}, acc})
    case False{}: x64_opt_mask32(U32.is_le(op, 1), 0, Con{XAluRR{op, 0, 1}, acc})

def x64_bin_step3(is_mod: Bool, +op: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_mod:
    case True{}:
      a1 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, acc))
      a2 = x64_emit(XMovRR{0, 2}, x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, a1)))
      x64_mask32(0, x64_emit(XLabel{lbl}, a2))
    case False{}: x64_bin_step4(U32.is_ge(op, 8), op, acc)

def x64_bin_step2(is_div: Bool, +op: U32, +lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_div:
    case True{}:
      a1 = x64_emit(XMovRI32{0, 0}, x64_emit(XMovRR{2, 0}, acc))
      a2 = x64_emit(XJcc{4, lbl}, x64_emit(XTestRR{1, 1}, a1))
      a3 = x64_emit(XDiv{1, False{}}, x64_emit(XMovRI32{2, 0}, x64_emit(XMovRR{0, 2}, a2)))
      x64_emit(XLabel{lbl}, a3)
    case False{}: x64_bin_step3(U32.is_eq(op, 4), op, lbl, acc)

def x64_bin_step1(is_mul: Bool, +op: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_mul:
    case True{}: x64_mask32(0, Con{XMul{0, 1}, acc})
    case False{}: x64_bin_step2(U32.is_eq(op, 3), op, lbl, acc)

def x64_is_simple_alu(+op: U32) -> Bool:
  Bool.or(U32.is_le(op, 1), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))

def x64_is_comm_alu(+op: U32) -> Bool:
  Bool.or(U32.is_zero(op), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))

def x64_fbin_rhs_xmm(rxm: Bool, ctx: X64Ctx, fop: U32, dx: U32, rhs: U32, rloc: U32, a1: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match rxm:
    case True{}: x64_emit(XXmmRR{fop, dx, U32.sub(rloc, 20)}, a1)
    case False{}: x64_emit(XXmmRR{fop, dx, 1}, x64_load_xmm(ctx, 1, rhs, a1))

def x64_fbin_dst_eq_rhs(comm: Bool, lxm: Bool, ctx: X64Ctx, fop: U32, +dx: U32, lhs: U32, lloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match comm lxm:
    case True{} True{}: x64_emit(XXmmRR{fop, dx, U32.sub(lloc, 20)}, acc)
    case True{} False{}: x64_emit(XXmmRR{fop, dx, 1}, x64_load_xmm(ctx, 1, lhs, acc))
    case False{} _:
      a1 = x64_emit(XXmmRR{fop, 0, dx}, x64_load_xmm(ctx, 0, lhs, acc))
      x64_emit(XXmmRR{7, dx, 0}, a1)

def x64_fbin_dxmm(eq_lr: Bool, ne_dr: Bool, comm: Bool, +ctx: X64Ctx, +fop: U32, +dx: U32, lhs: U32, rhs: U32, +lloc: U32, +rloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq_lr ne_dr:
    case True{} _: x64_emit(XXmmRR{fop, dx, dx}, x64_load_xmm(ctx, dx, lhs, acc))
    case False{} True{}:
      a1 = x64_load_xmm(ctx, dx, lhs, acc)
      x64_fbin_rhs_xmm(x64_is_xmm(rloc), ctx, fop, dx, rhs, rloc, a1)
    case False{} False{}: x64_fbin_dst_eq_rhs(comm, x64_is_xmm(lloc), ctx, fop, dx, lhs, lloc, acc)

def x64_fbin_spill(eq_lr: Bool, rxm: Bool, +ctx: X64Ctx, dst: U32, fop: U32, lhs: U32, rhs: U32, rloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq_lr rxm:
    case True{} _: x64_store_xmm(ctx, dst, 0, x64_emit(XXmmRR{fop, 0, 0}, x64_load_xmm(ctx, 0, lhs, acc)))
    case False{} True{}: x64_store_xmm(ctx, dst, 0, x64_emit(XXmmRR{fop, 0, U32.sub(rloc, 20)}, x64_load_xmm(ctx, 0, lhs, acc)))
    case False{} False{}:
      a1 = x64_load_xmm(ctx, 1, rhs, x64_load_xmm(ctx, 0, lhs, acc))
      x64_store_xmm(ctx, dst, 0, x64_emit(XXmmRR{fop, 0, 1}, a1))

def x64_emit_fbin_go(dxm: Bool, +ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dxm:
    case True{}:
      fop = U32.sub(op, 10)
      comm = Bool.or(U32.is_eq(op, 10), U32.is_eq(op, 12))
      x64_fbin_dxmm(U32.is_eq(lloc, rloc), U32.is_ne(dloc, rloc), comm, ctx, fop, U32.sub(dloc, 20), lhs, rhs, lloc, rloc, acc)
    case False{}: x64_fbin_spill(U32.is_eq(lloc, rloc), x64_is_xmm(rloc), ctx, dst, U32.sub(op, 10), lhs, rhs, rloc, acc)

def x64_ibin_fallback(+ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
  x64_store_vreg(ctx, dst, 0, x64_bin_step1(U32.is_eq(op, 2), op, lbl, a1))

def x64_ibin_reg_go(is_alu: Bool, is_mul: Bool, is_comm_eq: Bool, +ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, lloc: U32, rloc: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_alu is_mul is_comm_eq:
    case True{} _ _:
      a1 = x64_load_vreg(ctx, dloc, lhs, acc)
      x64_opt_mask32(U32.is_le(op, 1), dloc, x64_emit(XAluRR{op, dloc, rloc}, a1))
    case False{} True{} _:
      a1 = x64_load_vreg(ctx, dloc, lhs, acc)
      x64_mask32(dloc, x64_emit(XMul{dloc, rloc}, a1))
    case False{} False{} True{}:
      x64_opt_mask32(U32.is_zero(op), dloc, x64_emit(XAluRR{op, dloc, lloc}, acc))
    case False{} False{} False{}: x64_ibin_fallback(ctx, dst, op, lhs, rhs, lbl, acc)

def x64_emit_ibin_imm(imm_alu: Bool, imm_sh: Bool, +ctx: X64Ctx, dst: U32, +op: U32, lhs: U32, rhs: U32, +dloc: U32, +lloc: U32, +rloc: U32, c: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match imm_alu imm_sh:
    case True{} _:
      a1 = x64_load_vreg(ctx, dloc, lhs, acc)
      x64_opt_mask32(U32.is_le(op, 1), dloc, x64_emit(XAluRI{op, dloc, c}, a1))
    case False{} True{}:
      a1 = x64_load_vreg(ctx, dloc, lhs, acc)
      x64_opt_mask32(U32.is_eq(op, 8), dloc, x64_emit(XShift{op, dloc, c, False{}}, a1))
    case False{} False{}:
      +dr_ok = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(dloc), x64_is_gpr(rloc)))
      +ne_dr = U32.is_ne(dloc, rloc)
      is_alu = Bool.and(Bool.and(dr_ok, ne_dr), x64_is_simple_alu(op))
      is_mul = Bool.and(Bool.and(dr_ok, ne_dr), U32.is_eq(op, 2))
      is_ceq = Bool.and(Bool.and(dr_ok, Bool.not(ne_dr)), Bool.and(x64_is_comm_alu(op), x64_is_gpr(lloc)))
      x64_ibin_reg_go(is_alu, is_mul, is_ceq, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, lbl, acc)

def x64_emit_bin_go(+ctx: X64Ctx, is_flt: Bool, consts: RaVec<U32>, +dst: U32, +op: U32, +lhs: U32, +rhs: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_flt:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      x64_emit_fbin_go(x64_is_xmm(dloc), ctx, dst, op, lhs, rhs, dloc, lloc, rloc, acc)
    case False{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      +rc = Bool.pick(U32, x64_is_o2(ctx), ra_vec_get(U32, x64_ctx_vd(ctx), 0, rhs, consts), 0)
      +has_c = Bool.and(U32.is_ne(rc, 0), x64_is_gpr(dloc))
      +c = U32.sub(rc, 1)
      imm_alu = Bool.and(has_c, x64_is_simple_alu(op))
      imm_sh = Bool.and(has_c, Bool.and(U32.is_ge(op, 8), U32.is_lt(c, 64)))
      x64_emit_ibin_imm(imm_alu, imm_sh, ctx, dst, op, lhs, rhs, dloc, lloc, rloc, c, lbl, acc)

def x64_emit_bin(ctx: X64Ctx, consts: RaVec<U32>, dst: U32, +op: U32, lhs: U32, rhs: U32, lbl: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit_bin_go(ctx, U32.is_ge(op, 10), consts, dst, op, lhs, rhs, lbl, acc)

def x64_u2f_go(dxm: Bool, sgpr: Bool, +ctx: X64Ctx, dst: U32, src: U32, dloc: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dxm sgpr:
    case True{} True{}: x64_emit(XCvt{0, U32.sub(dloc, 20), sloc}, acc)
    case True{} False{}: x64_emit(XCvt{0, U32.sub(dloc, 20), 0}, x64_load_vreg(ctx, 0, src, acc))
    case False{} True{}: x64_store_xmm(ctx, dst, 0, x64_emit(XCvt{0, 0, sloc}, acc))
    case False{} False{}: x64_store_xmm(ctx, dst, 0, x64_emit(XCvt{0, 0, 0}, x64_load_vreg(ctx, 0, src, acc)))

def x64_f2u_go(sxm: Bool, +ctx: X64Ctx, dst: U32, src: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match sxm:
    case True{}: x64_store_vreg(ctx, dst, 0, x64_mask32(0, x64_emit(XCvt{1, 0, U32.sub(sloc, 20)}, acc)))
    case False{}: x64_store_vreg(ctx, dst, 0, x64_mask32(0, x64_emit(XCvt{1, 0, 0}, x64_load_xmm(ctx, 0, src, acc))))

def x64_un_f32_s3(+ctx: X64Ctx, is_u2f: Bool, +dst: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_u2f:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_u2f_go(x64_is_xmm(dloc), x64_is_gpr(sloc), ctx, dst, src, dloc, sloc, acc)
    case False{}:
      +sloc = x64_vreg_loc(ctx, src)
      x64_f2u_go(x64_is_xmm(sloc), ctx, dst, src, sloc, acc)

def x64_emit_sqrt(direct: Bool, +ctx: X64Ctx, dst: U32, src: U32, dloc: U32, sloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match direct:
    case True{}: x64_emit(XXmmRR{4, U32.sub(dloc, 20), U32.sub(sloc, 20)}, acc)
    case False{}:
      a1 = x64_emit(XXmmRR{4, 0, 0}, x64_load_xmm(ctx, 0, src, acc))
      x64_store_xmm(ctx, dst, 0, a1)

def x64_un_f32_s2(+ctx: X64Ctx, is_sqrt: Bool, uop: U32, +dst: U32, +src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sqrt:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_emit_sqrt(Bool.and(x64_is_xmm(dloc), x64_is_xmm(sloc)), ctx, dst, src, dloc, sloc, acc)
    case False{}: x64_un_f32_s3(ctx, U32.is_eq(uop, 4), dst, src, acc)

def x64_un_f32_s1(+ctx: X64Ctx, is_fneg: Bool, +uop: U32, dst: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_fneg:
    case True{}:
      a1 = x64_emit(XAluRR{7, 0, 1}, x64_emit(XMovRI32{1, 2147483648}, x64_load_vreg(ctx, 0, src, acc)))
      x64_store_vreg(ctx, dst, 0, a1)
    case False{}: x64_un_f32_s2(ctx, U32.is_eq(uop, 3), uop, dst, src, acc)

def x64_un_step(is_neg: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_neg:
    case True{}:
      a1 = x64_emit(XAluRR{1, 1, 0}, x64_emit(XMovRI32{1, 0}, acc))
      x64_mask32(0, x64_emit(XMovRR{0, 1}, a1))
    case False{}:
      x64_emit(XAluRR{7, 0, 1}, x64_emit(XMovRI32{1, 4294967295}, acc))

def x64_emit_un_go(+ctx: X64Ctx, is_flt: Bool, dst: U32, +uop: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_flt:
    case True{}: x64_un_f32_s1(ctx, U32.is_eq(uop, 2), uop, dst, src, acc)
    case False{}: x64_store_vreg(ctx, dst, 0, x64_un_step(U32.is_eq(uop, 0), x64_load_vreg(ctx, 0, src, acc)))

def x64_emit_un(ctx: X64Ctx, dst: U32, +uop: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit_un_go(ctx, U32.is_ge(uop, 2), dst, uop, src, acc)

def x64_emit_fcmp_s2(is_ne: Bool, +fop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_ne:
    case True{}:
      a1 = x64_emit(XSetcc{10, 1}, x64_emit(XSetcc{5, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc))))
      x64_emit(XAluRR{6, 0, 1}, a1)
    case False{}:
      cc = Bool.pick(U32, Bool.or(U32.is_eq(fop, 2), U32.is_eq(fop, 4)), 7, 3)
      x64_emit(XSetcc{cc, 0}, x64_emit(XMovRI32{0, 0}, acc))

def x64_emit_fcmp_s1(is_eq: Bool, +fop: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_eq:
    case True{}:
      a1 = x64_emit(XSetcc{11, 1}, x64_emit(XSetcc{4, 0}, x64_emit(XMovRI32{1, 0}, x64_emit(XMovRI32{0, 0}, acc))))
      x64_emit(XAluRR{5, 0, 1}, a1)
    case False{}: x64_emit_fcmp_s2(U32.is_eq(fop, 1), fop, acc)

def x64_emit_icmp_go(direct: Bool, +ctx: X64Ctx, +dst: U32, cop: U32, lhs: U32, rhs: U32, lloc: U32, rloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match direct:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_emit(XSetcc{x64_cmp_cc(cop), dreg}, x64_emit(XMovRI32{dreg, 0}, x64_emit(XCmpRR{lloc, rloc}, acc)))
      x64_store_vreg(ctx, dst, dreg, a1)
    case False{}:
      a1 = x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
      a2 = x64_emit(XSetcc{x64_cmp_cc(cop), 0}, x64_emit(XMovRI32{0, 0}, x64_emit(XCmpRR{0, 1}, a1)))
      x64_store_vreg(ctx, dst, 0, a2)

def x64_opt_load_xmm(skip: Bool, ctx: X64Ctx, xmm: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}: x64_load_xmm(ctx, xmm, v, acc)

def x64_emit_cmp_go(+ctx: X64Ctx, is_flt: Bool, dst: U32, +cop: U32, +lhs: U32, +rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
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
      x64_store_vreg(ctx, dst, 0, x64_emit_fcmp_s1(U32.is_eq(fop, 0), fop, a2))
    case False{}:
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      dir = Bool.and(x64_is_o2(ctx), Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc)))
      x64_emit_icmp_go(dir, ctx, dst, cop, lhs, rhs, lloc, rloc, acc)

def x64_emit_cmp(ctx: X64Ctx, dst: U32, +cop: U32, lhs: U32, rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit_cmp_go(ctx, U32.is_ge(cop, 6), dst, cop, lhs, rhs, acc)

def x64_cls_fit(+cnt: U32) -> U32:
  c2 = Bool.pick(U32, U32.is_le(cnt, 4), 2, 3)
  c1 = Bool.pick(U32, U32.is_eq(cnt, 2), 1, c2)
  Bool.pick(U32, U32.is_le(cnt, 1), 0, c1)

def x64_cls_step(+cls: U32) -> U32:
  s2 = Bool.pick(U32, U32.is_eq(cls, 2), 4, 8)
  s1 = Bool.pick(U32, U32.is_eq(cls, 1), 2, s2)
  Bool.pick(U32, U32.is_zero(cls), 1, s1)

def x64_ctor_slow(+ctx: X64Ctx, cid: U32, fields: List<&2, U32>, cnt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, fields, 0, acc))
  a2 = x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, cid}, a1)))
  x64_emit(XCallSym{"p111_rt_ctor"}, a2)

type X64Acc is Data:
  X64Acc{insts: List<&2, X64Inst>, next_lbl: U32}

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
    case Con{f, t} X64Acc{acc, +lbl}:
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
      x64_ctor_store_fields(ctx, t, U32.add(idx, 1), X64Acc{a9, U32.add(lbl, 1)})

def x64_ctor_fin(+ctx: X64Ctx, dst: U32, +cid: U32, fields: List<&2, U32>, cnt: U32, lbl_slow: U32, +lbl_done: U32, lbl_pack: U32, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{a6, nl}:
      hi = U32.or(33554432, U32.shln(cid, 8n))
      a7 = x64_emit(XJmp{lbl_done}, x64_emit(XAluRR{6, 0, 2}, x64_emit(XMovRI64{0, 0, hi}, x64_emit(XLabel{lbl_pack}, a6))))
      a8 = x64_ctor_slow(ctx, cid, fields, cnt, x64_emit(XLabel{lbl_slow}, a7))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XLabel{lbl_done}, a8)), nl}

def x64_emit_ctor_o2(+ctx: X64Ctx, +dst: U32, +cid: U32, +fields: List<&2, U32>, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, is_z: Bool, is_sm: Bool) -> X64Acc:
  match is_z is_sm:
    case True{} _:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      hi = U32.or(16777216, U32.shln(cid, 8n))
      X64Acc{x64_store_vreg(ctx, dst, dreg, x64_emit(XMovRI64{dreg, 0, hi}, acc)), lbl}
    case False{} True{}:
      +cls = x64_cls_fit(cnt)
      +coff = U32.mul(cls, 8)
      +loff = U32.add(256, coff)
      +lbl_slow = lbl
      +lbl_done = U32.add(lbl, 1)
      +lbl_seal = U32.add(lbl, 2)
      +lbl_pack = U32.add(lbl, 3)
      a1 = x64_emit(XJcc{4, lbl_slow}, x64_emit(XTestRR{2, 2}, x64_emit(XLoad{2, 6, coff}, x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, acc)))))
      a2 = x64_emit(XJcc{6, lbl_slow}, x64_emit(XCmpRI{0, cnt}, x64_emit(XLoad{0, 6, 256}, a1)))
      a3 = x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XMovRR{1, 2}, x64_load_mem(ctx, 7, a2))))
      a4 = x64_emit(XStore{6, coff, 1}, x64_emit(XLoad{1, 7, 0}, a3))
      a5 = x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{1, 1, x64_cls_step(cls)}, x64_emit(XLoad{1, 6, loff}, a4)))
      a5b = x64_emit(XJcc{4, lbl_seal}, x64_emit(XAluRI{5, 1, 8}, x64_emit(XLoad{1, 1, 88}, x64_emit(XLeaRip{1, "p111_program"}, a5))))
      a5c = x64_emit(XJcc{5, lbl_seal}, x64_emit(XAluRI{5, 1, 255}, x64_emit(XLoad{1, 1, cid}, x64_emit(XLeaRip{1, "p111_cid_hot"}, a5b))))
      a5d = x64_emit(XLabel{lbl_seal}, x64_emit(XJmp{lbl_pack}, x64_ctor_store_raw(ctx, fields, 0, a5c)))
      st6 = x64_ctor_store_fields(ctx, fields, 0, X64Acc{a5d, U32.add(lbl, 4)})
      x64_ctor_fin(ctx, dst, cid, fields, cnt, lbl_slow, lbl_done, lbl_pack, st6)
    case False{} False{}:
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_ctor_slow(ctx, cid, fields, cnt, acc)), lbl}

def x64_emit_ctor_go(is_o2: Bool, +ctx: X64Ctx, dst: U32, cid: U32, +fields: List<&2, U32>, lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_o2:
    case True{}:
      +cnt = b5k_u32_list_len(fields)
      x64_emit_ctor_o2(ctx, dst, cid, fields, cnt, lbl, acc, U32.is_zero(cnt), U32.is_le(cnt, 8))
    case False{}:
      cnt = b5k_u32_list_len(fields)
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_ctor_slow(ctx, cid, fields, cnt, acc)), lbl}

def x64_emit_ctor(+ctx: X64Ctx, dst: U32, cid: U32, fields: List<&2, U32>, lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  x64_emit_ctor_go(x64_is_o2(ctx), ctx, dst, cid, fields, lbl, acc)

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
  a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))
  a2 = x64_emit(XCallSym{"p111_rt_take"}, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, a1)))
  x64_load_scratch_go(ctx, dsts, 0, a2)

def x64_emit_take_o2(+ctx: X64Ctx, +dsts: List<&2, U32>, +src: U32, +cnt: U32, +lbl: U32, acc: List<&2, X64Inst>, is_z: Bool, is_sm: Bool) -> X64Acc:
  match is_z is_sm:
    case True{} _: X64Acc{acc, lbl}
    case False{} True{}:
      +cls = x64_cls_fit(cnt)
      +coff = U32.mul(cls, 8)
      +loff = U32.add(256, coff)
      +lbl_slow = lbl
      +lbl_done = U32.add(lbl, 1)
      +lbl_unsh = U32.add(lbl, 2)
      +ho = x64_ctx_heap_off(ctx)
      a1 = x64_load_vreg(ctx, 2, src, acc)
      a2 = x64_emit(XJcc{5, lbl_slow}, x64_emit(XCmpRI{1, 2}, x64_emit(XAluRI{5, 1, 127}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 2}, a1)))))
      a3 = x64_emit(XShift{9, 2, 24, False{}}, x64_emit(XShift{8, 2, 24, False{}}, x64_emit(XMovRR{0, 2}, a2)))
      a4 = x64_emit(XLoad{6, 7, 8}, x64_load_state(ctx, 7, a3))
      a5 = x64_emit(XJcc{3, lbl_slow}, x64_emit(XCmpRI{1, 247}, x64_emit(XLoad{1, 6, loff}, a4)))
      a6 = x64_emit(XJcc{9, lbl_unsh}, x64_emit(XTestRR{0, 0}, x64_load_mem(ctx, 7, a5)))
      a7 = x64_emit(XJcc{3, lbl_slow}, x64_emit(XCmpRI{1, 247}, x64_emit(XLoad{1, 6, 256}, a6)))
      a8 = x64_emit(XAluRR{0, 1, 7}, x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XMovRR{1, 2}, a7)))
      a9 = x64_emit(XJcc{5, lbl_slow}, x64_emit(XCmpRI{0, 1}, x64_emit(XAluRI{5, 0, 16777215}, x64_emit(XLoad{0, 1, 0}, a8))))
      a10 = x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 1, 0}, a9))
      a11 = x64_emit(XJcc{2, lbl_slow}, x64_emit(XCmpRR{0, 2}, x64_emit(XMovRI32{2, ho}, x64_emit(XStore{4, 0, 2}, a10))))
      a12 = x64_emit(XStore{1, 0, 2}, x64_emit(XLoad{2, 6, 0}, x64_emit(XStore{4, 8, 0}, a11)))
      a13 = x64_emit(XStore{6, 0, 2}, x64_emit(XLoad{2, 4, 0}, a12))
      a14 = x64_emit(XLoad{2, 4, 8}, x64_emit(XStore{6, 256, 0}, x64_emit(XAluRI{0, 0, 1}, x64_emit(XLoad{0, 6, 256}, a13))))
      a15 = x64_emit(XJcc{2, lbl_slow}, x64_emit(XCmpRR{2, 0}, x64_emit(XMovRI32{0, ho}, x64_emit(XLabel{lbl_unsh}, a14))))
      a16 = x64_emit(XAluRR{0, 7, 1}, x64_emit(XShift{8, 1, 3, False{}}, x64_emit(XMovRR{1, 2}, a15)))
      a17 = x64_take_load_fields(ctx, dsts, 0, a16)
      a18 = x64_emit(XStore{6, coff, 2}, x64_emit(XStore{7, 0, 1}, x64_emit(XLoad{1, 6, coff}, a17)))
      a19 = x64_emit(XJmp{lbl_done}, x64_emit(XStore{6, loff, 1}, x64_emit(XAluRI{0, 1, x64_cls_step(cls)}, x64_emit(XLoad{1, 6, loff}, a18))))
      a20 = x64_take_slow(ctx, dsts, src, cnt, x64_emit(XLabel{lbl_slow}, a19))
      X64Acc{x64_emit(XLabel{lbl_done}, a20), U32.add(lbl, 3)}
    case False{} False{}:
      X64Acc{x64_take_slow(ctx, dsts, src, cnt, acc), lbl}

def x64_emit_take_go(is_o2: Bool, +ctx: X64Ctx, +dsts: List<&2, U32>, src: U32, lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_o2:
    case True{}:
      +cnt = b5k_u32_list_len(dsts)
      x64_emit_take_o2(ctx, dsts, src, cnt, lbl, acc, U32.is_zero(cnt), U32.is_le(cnt, 8))
    case False{}:
      cnt = b5k_u32_list_len(dsts)
      X64Acc{x64_take_slow(ctx, dsts, src, cnt, acc), lbl}

def x64_emit_tag(is_o2: Bool, +ctx: X64Ctx, +dst: U32, src: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_o2:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +dreg = Bool.pick(U32, x64_is_gpr(dloc), dloc, 0)
      a1 = x64_emit(XAluRI{5, dreg, 65535}, x64_emit(XShift{9, dreg, 40, False{}}, x64_load_vreg(ctx, dreg, src, acc)))
      x64_store_vreg(ctx, dst, dreg, a1)
    case False{}:
      a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))
      x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_tag"}, a1))

def x64_keep_o2_go(both_g: Bool, +ctx: X64Ctx, dst: U32, src: U32, +dloc: U32, +sloc: U32, +lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match both_g:
    case True{}:
      a0 = x64_opt_mov(U32.is_ne(dloc, sloc), dloc, sloc, acc)
      a1 = x64_emit(XJcc{6, lbl}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, dloc}, a0))))
      a2 = x64_emit(XMovRR{dloc, 0}, x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_emit(XMovRR{6, dloc}, a1))))
      X64Acc{x64_emit(XLabel{lbl}, a2), U32.add(lbl, 1)}
    case False{}:
      a1 = x64_load_vreg(ctx, 0, src, acc)
      a2 = x64_emit(XJcc{6, lbl}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, a1))))
      a3 = x64_emit(XCallSym{"p111_rt_keep"}, x64_load_state(ctx, 7, x64_emit(XMovRR{6, 0}, a2)))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XLabel{lbl}, a3)), U32.add(lbl, 1)}

def x64_emit_keep(is_o2: Bool, +ctx: X64Ctx, +dst: U32, +src: U32, +lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_o2:
    case True{}:
      +dloc = x64_vreg_loc(ctx, dst)
      +sloc = x64_vreg_loc(ctx, src)
      x64_keep_o2_go(Bool.and(x64_is_gpr(dloc), x64_is_gpr(sloc)), ctx, dst, src, dloc, sloc, lbl, acc)
    case False{}:
      a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_keep"}, a1)), lbl}

def x64_sink_o2_go(is_g: Bool, +ctx: X64Ctx, src: U32, +sloc: U32, +lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_g:
    case True{}:
      a1 = x64_emit(XJcc{6, lbl}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, sloc}, acc))))
      a2 = x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(ctx, 7, x64_emit(XMovRR{6, sloc}, a1)))
      X64Acc{x64_emit(XLabel{lbl}, a2), U32.add(lbl, 1)}
    case False{}:
      a1 = x64_load_vreg(ctx, 6, src, acc)
      a2 = x64_emit(XJcc{6, lbl}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 6}, a1))))
      a3 = x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(ctx, 7, a2))
      X64Acc{x64_emit(XLabel{lbl}, a3), U32.add(lbl, 1)}

def x64_emit_sink(is_o2: Bool, +ctx: X64Ctx, +src: U32, +lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_o2:
    case True{}:
      +sloc = x64_vreg_loc(ctx, src)
      x64_sink_o2_go(x64_is_gpr(sloc), ctx, src, sloc, lbl, acc)
    case False{}:
      X64Acc{x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(ctx, 7, x64_load_vreg(ctx, 6, src, acc))), lbl}

def x64_arr_slow_pair(+ctx: X64Ctx, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  acnt = b5k_u32_list_len(args)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_emit(XMovRI32{9, 2}, x64_emit(XMovRR{8, 4}, x64_emit(XMovRI32{1, acnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, aop}, a1)))))
  x64_load_scratch_go(ctx, dsts, 0, x64_emit(XCallSym{"p113_rt_array_pair"}, a2))

def x64_store_head(ctx: X64Ctx, dsts: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Con{d, _}: x64_store_vreg(ctx, d, 0, acc)
    case Nil{}: acc

def x64_arr_slow_one(+ctx: X64Ctx, sym: String, dsts: List<&2, U32>, aop: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  acnt = b5k_u32_list_len(args)
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_emit(XCallSym{sym}, x64_emit(XMovRI32{1, acnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, aop}, a1))))
  x64_store_head(ctx, dsts, a2)

def x64_arr_slow_get_val(+ctx: X64Ctx, dv: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, args, 0, acc))
  a2 = x64_emit(XMovRI32{9, 2}, x64_emit(XMovRR{8, 4}, x64_emit(XMovRI32{1, 2}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, 72}, a1)))))
  x64_store_vreg(ctx, dv, 0, x64_emit(XLoad{0, 4, 8}, x64_emit(XCallSym{"p113_rt_array_pair"}, a2)))

def x64_arr_slow_get_val_l(ctx: X64Ctx, dsts: List<&2, U32>, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Con{dv, _}: x64_arr_slow_get_val(ctx, dv, args, acc)
    case Nil{}: acc

def x64_arr_slow(+ctx: X64Ctx, dsts: List<&2, U32>, +aop: U32, args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match aop:
    case 8: x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, 8, args, acc)
    case 9: x64_arr_slow_one(ctx, "p111_rt_special_ctor", dsts, 9, args, acc)
    case 71: x64_arr_slow_one(ctx, "p111_rt_op", dsts, 71, args, acc)
    case 73: x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, acc)
    case 78: x64_arr_slow_get_val_l(ctx, dsts, args, acc)
    case _: x64_arr_slow_pair(ctx, dsts, aop, args, acc)

def x64_arr_elem_ptr(+ctx: X64Ctx, a: U32, i: U32, +lbl_slow: U32, +lbl_unsh: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_vreg(ctx, 2, i, x64_load_vreg(ctx, 6, a, acc))
  a2 = x64_emit(XJcc{5, lbl_slow}, x64_emit(XCmpRI{0, 6}, x64_emit(XAluRI{5, 0, 127}, x64_emit(XShift{9, 0, 56, False{}}, x64_emit(XMovRR{0, 6}, a1)))))
  a3 = x64_emit(XAluRR{5, 2, 0}, x64_emit(XAluRI{1, 0, 1}, x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, a2)))))))
  a4 = x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XShift{8, 0, 24, False{}}, x64_emit(XMovRR{0, 6}, x64_load_mem(ctx, 7, a3))))
  a5 = x64_emit(XJcc{9, lbl_unsh}, x64_emit(XTestRR{6, 6}, a4))
  a6 = x64_emit(XLabel{lbl_unsh}, x64_emit(XShift{9, 0, 24, False{}}, x64_emit(XLoad{0, 0, 0}, x64_emit(XAluRR{0, 0, 7}, x64_emit(XShift{8, 0, 3, False{}}, a5)))))
  x64_emit(XAluRR{0, 7, 0}, x64_emit(XShift{8, 0, 3, False{}}, x64_emit(XAluRR{0, 0, 2}, a6)))

def x64_opt_store_arr_go(same: Bool, ctx: X64Ctx, da: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match same:
    case True{}: acc
    case False{}: x64_store_vreg(ctx, da, 6, acc)

def x64_opt_store_arr(+ctx: X64Ctx, +da: U32, a: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_opt_store_arr_go(U32.is_eq(x64_vreg_loc(ctx, da), x64_vreg_loc(ctx, a)), ctx, da, acc)

def x64_arr_set_val(is_g: Bool, ctx: X64Ctx, v: U32, +vloc: U32, l_slow: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_g:
    case True{}:
      a1 = x64_emit(XJcc{4, l_slow}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, vloc}, acc))))
      x64_emit(XStore{7, 0, vloc}, a1)
    case False{}:
      a1 = x64_load_vreg(ctx, 0, v, acc)
      a2 = x64_emit(XJcc{4, l_slow}, x64_emit(XCmpRI{1, 2}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, a1))))
      x64_emit(XStore{7, 0, 0}, a2)

def x64_emit_arrop_o2(+ctx: X64Ctx, +aop: U32, +dsts: List<&2, U32>, +args: List<&2, U32>, +lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match aop dsts args:
    case 72 Con{da, Con{dv, _}} Con{+a, Con{i, _}}:
      +l_slow = lbl
      +l_unsh = U32.add(lbl, 1)
      +l_done = U32.add(lbl, 2)
      a1 = x64_emit(XLoad{0, 7, 0}, x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, acc))
      a2 = x64_emit(XJcc{7, l_slow}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, a1))))
      a3 = x64_emit(XJmp{l_done}, x64_store_vreg(ctx, dv, 0, x64_opt_store_arr(ctx, da, a, a2)))
      a4 = x64_arr_slow_pair(ctx, dsts, 72, args, x64_emit(XLabel{l_slow}, a3))
      X64Acc{x64_emit(XLabel{l_done}, a4), U32.add(lbl, 3)}
    case 73 Con{dst, _} Con{+a, Con{i, Con{+v, _}}}:
      +l_slow = lbl
      +l_unsh = U32.add(lbl, 1)
      +l_done = U32.add(lbl, 2)
      +vloc = x64_vreg_loc(ctx, v)
      a1 = x64_emit(XLoad{0, 7, 0}, x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, acc))
      a2 = x64_emit(XJcc{7, l_slow}, x64_emit(XCmpRI{0, 1}, x64_emit(XShift{9, 0, 56, False{}}, a1)))
      a3 = x64_arr_set_val(x64_is_gpr(vloc), ctx, v, vloc, l_slow, a2)
      a4 = x64_emit(XJmp{l_done}, x64_opt_store_arr(ctx, dst, a, a3))
      a5 = x64_arr_slow_one(ctx, "p111_rt_op", dsts, 73, args, x64_emit(XLabel{l_slow}, a4))
      X64Acc{x64_emit(XLabel{l_done}, a5), U32.add(lbl, 3)}
    case 74 Con{da, Con{dold, _}} Con{+a, Con{i, Con{+v, _}}}:
      +l_slow = lbl
      +l_unsh = U32.add(lbl, 1)
      +l_done = U32.add(lbl, 2)
      +vloc = x64_vreg_loc(ctx, v)
      a1 = x64_emit(XLoad{2, 7, 0}, x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, acc))
      a2 = x64_arr_set_val(x64_is_gpr(vloc), ctx, v, vloc, l_slow, a1)
      a3 = x64_emit(XJmp{l_done}, x64_store_vreg(ctx, dold, 2, x64_opt_store_arr(ctx, da, a, a2)))
      a4 = x64_arr_slow_pair(ctx, dsts, 74, args, x64_emit(XLabel{l_slow}, a3))
      X64Acc{x64_emit(XLabel{l_done}, a4), U32.add(lbl, 3)}
    case 75 Con{da, Con{dsz, _}} Con{+a, _}:
      a1 = x64_load_vreg(ctx, 6, a, acc)
      a2 = x64_emit(XShift{8, 0, 0, True{}}, x64_emit(XMovRI32{0, 1}, x64_emit(XAluRI{5, 1, 31}, x64_emit(XShift{9, 1, 40, False{}}, x64_emit(XMovRR{1, 6}, a1)))))
      X64Acc{x64_store_vreg(ctx, dsz, 0, x64_opt_store_arr(ctx, da, a, a2)), lbl}
    case 78 Con{dv, _} Con{a, Con{i, _}}:
      +l_slow = lbl
      +l_unsh = U32.add(lbl, 1)
      +l_done = U32.add(lbl, 2)
      a1 = x64_emit(XLoad{0, 7, 0}, x64_arr_elem_ptr(ctx, a, i, l_slow, l_unsh, acc))
      a2 = x64_emit(XJcc{7, l_slow}, x64_emit(XCmpRI{1, 1}, x64_emit(XShift{9, 1, 56, False{}}, x64_emit(XMovRR{1, 0}, a1))))
      a3 = x64_emit(XJmp{l_done}, x64_store_vreg(ctx, dv, 0, a2))
      a4 = x64_arr_slow_get_val(ctx, dv, args, x64_emit(XLabel{l_slow}, a3))
      X64Acc{x64_emit(XLabel{l_done}, a4), U32.add(lbl, 3)}
    case _ _ _: X64Acc{x64_arr_slow(ctx, dsts, aop, args, acc), lbl}

def x64_emit_arrop(is_o2: Bool, +ctx: X64Ctx, dsts: List<&2, U32>, aop: U32, args: List<&2, U32>, lbl: U32, acc: List<&2, X64Inst>) -> X64Acc:
  match is_o2:
    case True{}: x64_emit_arrop_o2(ctx, aop, dsts, args, lbl, acc)
    case False{}: X64Acc{x64_arr_slow(ctx, dsts, aop, args, acc), lbl}

def x64_clr_const(vd: Nat, v: U32, cs: RaVec<U32>) -> RaVec<U32>:
  match cs:
    case RVEmpty{}: RVEmpty{}
    case _: ra_vec_set(U32, vd, v, 0, cs)

def x64_clr_consts(+vd: Nat, vs: List<&2, U32>, cs: RaVec<U32>) -> RaVec<U32>:
  match vs cs:
    case Nil{} _: cs
    case _ RVEmpty{}: RVEmpty{}
    case Con{v, t} _: x64_clr_consts(vd, t, ra_vec_set(U32, vd, v, 0, cs))

def x64_set_const(ok: Bool, vd: Nat, dst: U32, val: U32, cs: RaVec<U32>) -> RaVec<U32>:
  match ok:
    case True{}: ra_vec_set(U32, vd, dst, U32.add(val, 1), cs)
    case False{}: x64_clr_const(vd, dst, cs)

def x64_upd_consts(is_o2: Bool, vd: Nat, op: IrOp, cs: RaVec<U32>) -> RaVec<U32>:
  match is_o2 op:
    case False{} _: cs
    case True{} IConst{dst, +val}: x64_set_const(U32.is_lt(val, 2147483647), vd, dst, val, cs)
    case True{} IFlt{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} ICopy{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} IBin{dst, _, _, _}: x64_clr_const(vd, dst, cs)
    case True{} IUn{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} ICmp{dst, _, _, _}: x64_clr_const(vd, dst, cs)
    case True{} ICallDirect{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} ICallClosure{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} IApply{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} ICtor{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} ITake{dsts, _}: x64_clr_consts(vd, dsts, cs)
    case True{} ITag{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} IKeep{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} IReuse{dst, _, _, _}: x64_clr_const(vd, dst, cs)
    case True{} IStatic{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} IArrOp{dsts, _, _}: x64_clr_consts(vd, dsts, cs)
    case True{} IAlloca{dst, _}: x64_clr_const(vd, dst, cs)
    case True{} ILoad{dst, _, _}: x64_clr_const(vd, dst, cs)
    case True{} _: cs

def x64_emit_op(+ctx: X64Ctx, fn_map: Map<&2, String>, consts: RaVec<U32>, op: IrOp, acc: List<&2, X64Inst>, +lbl: U32) -> X64Acc:
  match op:
    case IConst{dst, val}: X64Acc{x64_emit_const(ctx, dst, val, acc), lbl}
    case IFlt{dst, bits}: X64Acc{x64_emit_const(ctx, dst, bits, acc), lbl}
    case ICopy{dst, src}: X64Acc{x64_emit_copy(ctx, dst, src, acc), lbl}
    case IBin{dst, bop, lhs, rhs}: X64Acc{x64_emit_bin(ctx, consts, dst, bop, lhs, rhs, lbl, acc), U32.add(lbl, 1)}
    case IUn{dst, uop, src}: X64Acc{x64_emit_un(ctx, dst, uop, src, acc), lbl}
    case ICmp{dst, cop, lhs, rhs}: X64Acc{x64_emit_cmp(ctx, dst, cop, lhs, rhs, acc), lbl}
    case ICallDirect{dst, fid, args}:
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, fid), args, acc)), lbl}
    case ICallClosure{dst, fid, +caps}:
      cnt = b5k_u32_list_len(caps)
      a1 = x64_load_state(ctx, 7, x64_store_scratch_go(ctx, caps, 0, acc))
      a2 = x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, fid}, a1)))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"p111_rt_closure"}, a2)), lbl}
    case IApply{dst, clo, arg}:
      a1 = x64_load_state(ctx, 7, x64_load_vreg(ctx, 2, arg, x64_load_vreg(ctx, 6, clo, acc)))
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XCallSym{"$b5k_apply"}, a1)), lbl}
    case ICtor{dst, cid, fields}: x64_emit_ctor(ctx, dst, cid, fields, lbl, acc)
    case ITake{dsts, src}: x64_emit_take_go(x64_is_o2(ctx), ctx, dsts, src, lbl, acc)
    case ITag{dst, src}: X64Acc{x64_emit_tag(x64_is_o2(ctx), ctx, dst, src, acc), lbl}
    case IKeep{dst, src}: x64_emit_keep(x64_is_o2(ctx), ctx, dst, src, lbl, acc)
    case ISink{src}: x64_emit_sink(x64_is_o2(ctx), ctx, src, lbl, acc)
    case IReuse{dst, _, cid, fields}: x64_emit_ctor(ctx, dst, cid, fields, lbl, acc)
    case IStatic{dst, idx}:
      a1 = x64_emit(XLoad{0, 0, U32.mul(idx, 8)}, x64_emit(XLeaRip{0, "p111_static_image"}, acc))
      X64Acc{x64_store_vreg(ctx, dst, 0, a1), lbl}
    case IArrOp{dsts, aop, args}: x64_emit_arrop(x64_is_o2(ctx), ctx, dsts, aop, args, lbl, acc)
    case IAlloca{dst, _}: X64Acc{x64_store_vreg(ctx, dst, 4, acc), lbl}
    case ILoad{dst, base, off}:
      X64Acc{x64_store_vreg(ctx, dst, 0, x64_emit(XLoad{0, 0, U32.mul(off, 8)}, x64_load_vreg(ctx, 0, base, acc))), lbl}
    case IStore{base, off, val}:
      a1 = x64_load_vreg(ctx, 1, val, x64_load_vreg(ctx, 0, base, acc))
      X64Acc{x64_emit(XStore{0, U32.mul(off, 8), 1}, a1), lbl}
    case IFail{code}:
      X64Acc{x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))), lbl}

def x64_emit_switch_arms(+reg: U32, arms: List<&2, IrSwitchArm>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match arms:
    case Nil{}: acc
    case Con{IrArm{tag, target}, t}:
      x64_emit_switch_arms(reg, t, x64_emit(XJcc{4, target}, x64_emit(XCmpRI{reg, tag}, acc)))

def x64_push_list(regs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match regs:
    case Nil{}: acc
    case Con{r, t}: x64_push_list(t, Con{XPush{r}, acc})

def x64_pop_list(regs: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match regs:
    case Nil{}: acc
    case Con{r, t}: x64_pop_list(t, Con{XPop{r}, acc})

def x64_emit_epilogue(acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, acc)))

def x64_emit_epilogue_ctx(ctx: X64Ctx, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ctx:
    case X64Ctx{_, _, _, _, _, _, _, _, Nil{}, _}: x64_emit_epilogue(acc)
    case X64Ctx{_, _, _, _, _, _, _, frame, ce, _}:
      a1 = x64_pop_list(b5k_list_rev(U32, ce), x64_emit(XAddRsp{frame}, acc))
      x64_emit(XRet{}, x64_emit(XPop{5}, a1))

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

def x64_tail_direct_one(do_dir: Bool, ctx: X64Ctx, idx: U32, r: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match do_dir:
    case True{}: x64_emit_copy(ctx, idx, r, acc)
    case False{}: acc

def x64_tail_direct(+ctx: X64Ctx, +srcs: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      do_dir = Bool.and(U32.is_ne(rloc, iloc), Bool.not(x64_u32_in(iloc, srcs)))
      x64_tail_direct(ctx, srcs, t, U32.add(idx, 1), x64_tail_direct_one(do_dir, ctx, idx, r, acc))

def x64_tail_to_one_go(is_xm: Bool, ctx: X64Ctx, r: U32, rloc: U32, idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_xm:
    case True{}: x64_emit(XXmmStore{4, U32.mul(idx, 8), U32.sub(rloc, 20)}, acc)
    case False{}: x64_emit(XStore{4, U32.mul(idx, 8), 0}, x64_load_vreg(ctx, 0, r, acc))

def x64_tail_to_one(skip: Bool, +ctx: X64Ctx, +r: U32, idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}:
      +rloc = x64_vreg_loc(ctx, r)
      x64_tail_to_one_go(x64_is_xmm(rloc), ctx, r, rloc, idx, acc)

def x64_tail_to_scratch(+ctx: X64Ctx, +srcs: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{+r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      skip = Bool.or(U32.is_eq(rloc, iloc), Bool.not(x64_u32_in(iloc, srcs)))
      x64_tail_to_scratch(ctx, srcs, t, U32.add(idx, 1), x64_tail_to_one(skip, ctx, r, idx, acc))

def x64_tail_from_one_go(is_xm: Bool, ctx: X64Ctx, +idx: U32, iloc: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_xm:
    case True{}: x64_emit(XXmmLoad{U32.sub(iloc, 20), 4, U32.mul(idx, 8)}, acc)
    case False{}: x64_store_vreg(ctx, idx, 0, x64_emit(XLoad{0, 4, U32.mul(idx, 8)}, acc))

def x64_tail_from_one(skip: Bool, +ctx: X64Ctx, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match skip:
    case True{}: acc
    case False{}:
      +iloc = x64_vreg_loc(ctx, idx)
      x64_tail_from_one_go(x64_is_xmm(iloc), ctx, idx, iloc, acc)

def x64_tail_from_scratch(+ctx: X64Ctx, +srcs: List<&2, U32>, args: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args:
    case Nil{}: acc
    case Con{r, t}:
      +rloc = x64_vreg_loc(ctx, r)
      +iloc = x64_vreg_loc(ctx, idx)
      skip = Bool.or(U32.is_eq(rloc, iloc), Bool.not(x64_u32_in(iloc, srcs)))
      x64_tail_from_scratch(ctx, srcs, t, U32.add(idx, 1), x64_tail_from_one(skip, ctx, idx, acc))

def x64_emit_tail(+ctx: X64Ctx, use_jmp: Bool, fn_map: Map<&2, String>, fid: U32, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match use_jmp:
    case False{}: x64_emit_epilogue_ctx(ctx, x64_emit_call(ctx, x64_lookup_fn_sym(fn_map, fid), args, acc))
    case True{}:
      +srcs = x64_tail_src_locs(ctx, args, 0, Nil{})
      a0 = x64_tail_direct(ctx, srcs, args, 0, acc)
      a1 = x64_tail_to_scratch(ctx, srcs, args, 0, a0)
      a2 = x64_tail_from_scratch(ctx, srcs, args, 0, a1)
      x64_emit(XJmp{0}, a2)

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

def x64_emit_switch_go(is_sp: Bool, ctx: X64Ctx, loc: U32, arms: List<&2, IrSwitchArm>, db: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sp:
    case True{}: x64_emit(XJmp{db}, x64_emit_switch_arms(0, arms, Con{XLoad{0, 5, x64_spill_disp(ctx, loc)}, acc}))
    case False{}: x64_emit(XJmp{db}, x64_emit_switch_arms(loc, arms, acc))

def x64_emit_term(+ctx: X64Ctx, fn_map: Map<&2, String>, term: IrTerm, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match term:
    case TJmp{target}: x64_emit(XJmp{target}, acc)
    case TBr{cond, then_blk, else_blk}:
      +loc = x64_vreg_loc(ctx, cond)
      x64_emit_br_go(U32.is_ge(loc, 100), ctx, loc, then_blk, else_blk, nxt, acc)
    case TSwitch{scrut, arms, def_blk}:
      +loc = x64_vreg_loc(ctx, scrut)
      x64_emit_switch_go(U32.is_ge(loc, 100), ctx, loc, arms, def_blk, acc)
    case TRet{val}: x64_emit_epilogue_ctx(ctx, x64_load_vreg(ctx, 0, val, acc))
    case TTailCall{fid, +args}:
      n = b5k_u32_list_len(args)
      x64_emit_tail(ctx, U32.is_le(n, 32), fn_map, fid, args, acc)
    case TFail{code}:
      x64_emit_epilogue_ctx(ctx, x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(ctx, 7, acc))))

def x64_emit_term_acc(ctx: X64Ctx, fn_map: Map<&2, String>, term: IrTerm, nxt: U32, st: X64Acc) -> X64Acc:
  match st:
    case X64Acc{a1, lbl1}:
      X64Acc{x64_emit_term(ctx, fn_map, term, nxt, a1), lbl1}

def x64_emit_fused_cmp_go(dir: Bool, +ctx: X64Ctx, cop: U32, lhs: U32, rhs: U32, lloc: U32, rloc: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dir:
    case True{}: x64_emit_jcc_pair(x64_cmp_cc(cop), tb, eb, nxt, x64_emit(XCmpRR{lloc, rloc}, acc))
    case False{}:
      a1 = x64_load_vreg(ctx, 1, rhs, x64_load_vreg(ctx, 0, lhs, acc))
      x64_emit_jcc_pair(x64_cmp_cc(cop), tb, eb, nxt, x64_emit(XCmpRR{0, 1}, a1))

def x64_emit_fused_cmp_fin(fuse: Bool, +ctx: X64Ctx, fn_map: Map<&2, String>, dst: U32, cop: U32, +lhs: U32, +rhs: U32, cond: U32, tb: U32, eb: U32, nxt: U32, acc: List<&2, X64Inst>, lbl: U32) -> X64Acc:
  match fuse:
    case True{}:
      +lloc = x64_vreg_loc(ctx, lhs)
      +rloc = x64_vreg_loc(ctx, rhs)
      dir = Bool.and(x64_is_gpr(lloc), x64_is_gpr(rloc))
      X64Acc{x64_emit_fused_cmp_go(dir, ctx, cop, lhs, rhs, lloc, rloc, tb, eb, nxt, acc), lbl}
    case False{}:
      x64_emit_term_acc(ctx, fn_map, TBr{cond, tb, eb}, nxt, X64Acc{x64_emit_cmp(ctx, dst, cop, lhs, rhs, acc), lbl})

def x64_emit_ops_fused(+ctx: X64Ctx, +fn_map: Map<&2, String>, ops: List<&2, IrOp>, +consts: RaVec<U32>, +uc: RaVec<U32>, +term: IrTerm, +nxt: U32, st: X64Acc) -> X64Acc:
  match ops term st:
    case Nil{} _ _: x64_emit_term_acc(ctx, fn_map, term, nxt, st)
    case Con{ICmp{+dst, +cop, lhs, rhs}, Nil{}} TBr{+cond, tb, eb} X64Acc{acc, lbl}:
      fuse = Bool.and(Bool.and(x64_is_o2(ctx), U32.is_lt(cop, 6)),
             Bool.and(U32.is_eq(dst, cond), U32.is_eq(ra_vec_get(U32, x64_ctx_vd(ctx), 0, dst, uc), 1)))
      x64_emit_fused_cmp_fin(fuse, ctx, fn_map, dst, cop, lhs, rhs, cond, tb, eb, nxt, acc, lbl)
    case Con{+op, t} _ X64Acc{acc, lbl}:
      cs1 = x64_upd_consts(x64_is_o2(ctx), x64_ctx_vd(ctx), op, consts)
      x64_emit_ops_fused(ctx, fn_map, t, cs1, uc, term, nxt, x64_emit_op(ctx, fn_map, consts, op, acc, lbl))

def x64_next_blk_id(blks: List<&2, IrBlock>) -> U32:
  match blks:
    case Nil{}: 4294967295
    case Con{IrBlock{id, _, _}, _}: id

def x64_emit_blocks(+ctx: X64Ctx, +fn_map: Map<&2, String>, +uc: RaVec<U32>, blks: List<&2, IrBlock>, st: X64Acc) -> X64Acc:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{id, ops, term}, +t} X64Acc{acc, lbl}:
      nxt = x64_next_blk_id(t)
      x64_emit_blocks(ctx, fn_map, uc, t, x64_emit_ops_fused(ctx, fn_map, ops, RVEmpty{}, uc, term, nxt, X64Acc{x64_emit(XLabel{id}, acc), lbl}))

def x64_acc_insts(st: X64Acc) -> List<&2, X64Inst>:
  match st:
    case X64Acc{insts, _}: insts

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

def x64_lower_fn(fn_map: Map<&2, String>, heap_off: U32, f: IrFn) -> X64Fn:
  match f:
    case IrFn{_, name, +arity, +nregs, _, _, _, blocks}:
      scr = Bool.pick(U32, U32.is_gt(arity, 16), 272, 144)
      +frame = x64_align16(U32.add(scr, U32.mul(U32.max(nregs, arity), 8)))
      +ctx = x64_mk_ctx(False{}, RVEmpty{}, 0n, 16, x64_state_disp(), 0, 0, frame, Nil{}, heap_off)
      a0 = x64_emit(XStore{5, x64_state_disp(), 7}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_save_params_go(ctx, U32.to_nat(arity), 0, a0)
      X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_blocks(ctx, fn_map, RVEmpty{}, blocks, X64Acc{a1, 2147483648})))}

def x64_op_uses_mem(op: IrOp) -> Bool:
  match op:
    case ICtor{_, _, Con{_, _}}: True{}
    case IReuse{_, _, _, Con{_, _}}: True{}
    case ITake{Con{_, _}, _}: True{}
    case IArrOp{_, +aop, _}: Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), U32.is_eq(aop, 78))
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
  r3 = Bool.pick(U32, x64_u32_in(3, ce), 0, 3)
  r12 = Bool.pick(U32, x64_u32_in(12, ce), r3, 12)
  r13 = Bool.pick(U32, x64_u32_in(13, ce), r12, 13)
  r14 = Bool.pick(U32, x64_u32_in(14, ce), r13, 14)
  Bool.pick(U32, x64_u32_in(15, ce), r14, 15)

def x64_init_mem(has_r: Bool, has_d: Bool, mr: U32, md: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_r has_d:
    case True{} _: x64_emit(XLoad{mr, 7, 0}, acc)
    case False{} True{}: x64_emit(XStore{5, md, 0}, x64_emit(XLoad{0, 7, 0}, acc))
    case False{} False{}: acc

def x64_lower_fn_o2_go(fn_map: Map<&2, String>, heap_off: U32, name: String, +arity: U32, +blocks: List<&2, IrBlock>, ra: RegAllocRes) -> X64Fn:
  match ra:
    case RegAllocRes{rm, +vd, +ce0, sc}:
      +um = x64_blks_use_mem(blocks)
      +mr = Bool.pick(U32, um, x64_pick_free_callee(ce0), 0)
      +has_mr = U32.is_ne(mr, 0)
      +has_md = Bool.and(um, Bool.not(has_mr))
      +ce = x64_cons_if(has_mr, mr, ce0)
      +k = b5k_u32_list_len(ce)
      +state_off = U32.mul(U32.add(k, 1), 8)
      +sd = U32.sub(0, state_off)
      +base_off = Bool.pick(U32, has_md, U32.add(state_off, 8), state_off)
      +md = Bool.pick(U32, has_md, U32.sub(0, base_off), 0)
      +sb = U32.add(base_off, 8)
      scr = Bool.pick(U32, U32.is_gt(arity, 16), 256, 128)
      tot = x64_align16(U32.add(U32.add(base_off, scr), U32.mul(sc, 8)))
      +frame = U32.sub(tot, U32.mul(k, 8))
      +ctx = x64_mk_ctx(True{}, rm, vd, sb, sd, mr, md, frame, ce, heap_off)
      a0 = x64_push_list(ce, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{})))
      a1 = x64_init_mem(has_mr, has_md, mr, md, x64_emit(XStore{5, sd, 7}, x64_emit(XSubRsp{frame}, a0)))
      a2 = x64_opt_mov(U32.is_ge(arity, 5), 7, 9, x64_opt_mov(U32.is_ge(arity, 4), 0, 8, a1))
      a3 = x64_save_params_go(ctx, U32.to_nat(arity), 0, a2)
      uc = x64_uc_blks(vd, blocks, RVEmpty{})
      X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_acc_insts(x64_emit_blocks(ctx, fn_map, uc, blocks, X64Acc{a3, 2147483648})))}

def x64_lower_fn_o2_wrap(fn_map: Map<&2, String>, heap_off: U32, ra: RegAllocRes, f: IrFn) -> X64Fn:
  match f:
    case IrFn{_, name, arity, _, _, _, _, blocks}:
      x64_lower_fn_o2_go(fn_map, heap_off, name, arity, blocks, ra)

def x64_lower_fn_o2(fn_map: Map<&2, String>, heap_off: U32, +f: IrFn) -> X64Fn:
  x64_lower_fn_o2_wrap(fn_map, heap_off, b5k_regalloc(f), f)

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
    case False{}:
      x64_emit(XCallSym{sym}, x64_seg_load_regs(U32.to_nat(arity), 0, acc))
    case True{}:
      +extra_cnt = U32.sub(arity, 5)
      +odd = U32.is_eq(U32.and(extra_cnt, 1), 1)
      e0 = x64_opt_sub_rsp(odd, acc)
      e1 = x64_seg_push_extra(U32.to_nat(extra_cnt), U32.sub(arity, 1), e0)
      e2 = x64_emit(XCallSym{sym}, x64_seg_load_regs(5n, 0, e1))
      x64_emit(XAddRsp{U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)}, e2)

def x64_make_seg_wrapper(f: IrFn) -> X64Fn:
  match f:
    case IrFn{fid, name, +arity, _, _, _, _, _}:
      a0 = x64_emit(XStore{5, x64_state_disp(), 7}, x64_emit(XSubRsp{32}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_seg_call(U32.is_gt(arity, 5), arity, x64_fn_sym(name), a0)
      a2 = x64_emit(XMovRI32{2, 1}, x64_emit(XMovRR{6, 4}, x64_emit(XLoad{7, 5, x64_state_disp()}, x64_emit(XStore{4, 0, 0}, a1))))
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

def x64_lower_all(+is_o2: Bool, +fn_map: Map<&2, String>, +heap_off: U32, fns: List<&2, IrFn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match is_o2 fns:
    case _ Nil{}: acc
    case False{} Con{+f, t}:
      x64_lower_all(False{}, fn_map, heap_off, t, Con{x64_make_seg_wrapper(f), Con{x64_lower_fn(fn_map, heap_off, f), acc}})
    case True{} Con{+f, t}:
      x64_lower_all(True{}, fn_map, heap_off, t, Con{x64_make_seg_wrapper(f), Con{x64_lower_fn_o2(fn_map, heap_off, f), acc}})

def b5k_codegen(prog: IrProg) -> List<&2, X64Fn>:
  match prog:
    case IrProg{+fns, _, statics, _, _, _, _, _}:
      fn_map = x64_build_fn_map_go(fns, Map.new(&2, String))
      b5k_list_rev(X64Fn, x64_lower_all(False{}, fn_map, x64_heap_off(statics), fns, Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}}))

def b5k_codegen_o2(prog: IrProg) -> List<&2, X64Fn>:
  match prog:
    case IrProg{+fns, _, statics, _, _, _, _, _}:
      fn_map = x64_build_fn_map_go(fns, Map.new(&2, String))
      b5k_list_rev(X64Fn, x64_lower_all(True{}, fn_map, x64_heap_off(statics), fns, Con{x64_make_apply_stub(), Con{x64_make_main_stub(), Nil{}}}))
