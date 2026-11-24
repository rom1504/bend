# bend5k/x64.bend — Direct x86-64 Codegen (-O0 Stack-Slot Baseline)
# ==================================================================
# Lowers IrProg into typed X64Inst sequences (X64Fn) targeting System V
# AMD64 ABI + P111 ABI v11102 runtime.
#
# Calling convention for `$direct.<name>`:
#   %rdi = P111State *state
#   %rsi, %rdx, %rcx, %r8, %r9 = first 5 Bend args (extra args on stack)
#   %rax = return value
# Stack frame layout:
#   [rbp - 8]              = saved P111State *state
#   [rbp - 16 - 8*v]       = vreg v (0 .. nregs-1)
#   [rsp + 0 .. rsp + 127] = 16-word scratch array for p111_rt_* calls

def X64_RAX() -> U32: 0
def X64_RCX() -> U32: 1
def X64_RDX() -> U32: 2
def X64_RSP() -> U32: 4
def X64_RBP() -> U32: 5
def X64_RSI() -> U32: 6
def X64_RDI() -> U32: 7
def X64_R8()  -> U32: 8
def X64_R9()  -> U32: 9

def x64_arg_reg(+i: U32) -> U32:
  r3 = Bool.pick(U32, U32.is_eq(i, 3), 8, 9)
  r2 = Bool.pick(U32, U32.is_eq(i, 2), 1, r3)
  r1 = Bool.pick(U32, U32.is_eq(i, 1), 2, r2)
  Bool.pick(U32, U32.is_eq(i, 0), 6, r1)

def x64_cmp_cc(+op: U32) -> U32:
  c4 = Bool.pick(U32, U32.is_eq(op, 4), 7, 3)
  c3 = Bool.pick(U32, U32.is_eq(op, 3), 6, c4)
  c2 = Bool.pick(U32, U32.is_eq(op, 2), 2, c3)
  c1 = Bool.pick(U32, U32.is_eq(op, 1), 5, c2)
  Bool.pick(U32, U32.is_eq(op, 0), 4, c1)

def x64_vreg_disp(v: U32) -> U32:
  U32.sub(0, U32.add(16, U32.mul(v, 8)))

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

def x64_load_vreg(reg: U32, v: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XLoad{reg, 5, x64_vreg_disp(v)}, acc}

def x64_store_vreg(v: U32, reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XStore{5, x64_vreg_disp(v), reg}, acc}

def x64_load_state(reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XLoad{reg, 5, x64_state_disp()}, acc}

def x64_store_scratch_go(vs: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match vs:
    case Nil{}: acc
    case Con{v, t}:
      a1 = x64_load_vreg(0, v, acc)
      x64_store_scratch_go(t, U32.add(idx, 1), x64_emit(XStore{4, U32.mul(idx, 8), 0}, a1))

def x64_load_scratch_go(dsts: List<&2, U32>, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match dsts:
    case Nil{}: acc
    case Con{d, t}:
      a1 = x64_emit(XLoad{0, 4, U32.mul(idx, 8)}, acc)
      x64_load_scratch_go(t, U32.add(idx, 1), x64_store_vreg(d, 0, a1))

def x64_save_param_one(in_reg: Bool, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match in_reg:
    case True{}: x64_store_vreg(idx, x64_arg_reg(idx), acc)
    case False{}:
      off = U32.add(16, U32.mul(U32.sub(idx, 5), 8))
      x64_store_vreg(idx, 0, Con{XLoad{0, 5, off}, acc})

def x64_save_params_go(n: Nat, +idx: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match n:
    case 0n: acc
    case 1n+p:
      a1 = x64_save_param_one(U32.is_lt(idx, 5), idx, acc)
      x64_save_params_go(p, U32.add(idx, 1), a1)

def x64_drop_u32(n: Nat, xs: List<&2, U32>) -> List<&2, U32>:
  match n xs:
    case 0n ys: ys
    case 1n+p Nil{}: Nil{}
    case 1n+p Con{_, t}: x64_drop_u32(p, t)

def x64_push_extra_args(rev_extra: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match rev_extra:
    case Nil{}: acc
    case Con{v, t}:
      a1 = x64_load_vreg(0, v, acc)
      x64_push_extra_args(t, Con{XPush{0}, a1})

def x64_load_reg_args(args: List<&2, U32>, +idx: U32, in_reg: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match args in_reg:
    case Nil{} _: acc
    case _ False{}: acc
    case Con{v, t} True{}:
      +nxt = U32.add(idx, 1)
      x64_load_reg_args(t, nxt, U32.is_lt(nxt, 5), x64_load_vreg(x64_arg_reg(idx), v, acc))

def x64_opt_sub_rsp(odd: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match odd:
    case True{}: Con{XSubRsp{8}, acc}
    case False{}: acc

def x64_emit_call_go(has_extra: Bool, nargs: U32, sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match has_extra:
    case False{}:
      a1 = x64_load_reg_args(args, 0, True{}, acc)
      Con{XCallSym{sym}, x64_load_state(7, a1)}
    case True{}:
      +extra_cnt = U32.sub(nargs, 5)
      +odd = U32.is_eq(U32.and(extra_cnt, 1), 1)
      a0 = x64_opt_sub_rsp(odd, acc)
      extra_rev = b5k_list_rev(U32, x64_drop_u32(5n, args))
      a1 = x64_push_extra_args(extra_rev, a0)
      a2 = x64_load_reg_args(args, 0, True{}, a1)
      a3 = x64_emit(XCallSym{sym}, x64_load_state(7, a2))
      pop_bytes = U32.mul(U32.add(extra_cnt, Bool.to_u32(odd)), 8)
      Con{XAddRsp{pop_bytes}, a3}

def x64_emit_call(sym: String, +args: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +nargs = b5k_u32_list_len(args)
  x64_emit_call_go(U32.is_gt(nargs, 5), nargs, sym, args, acc)

def x64_mask32(+reg: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  Con{XShift{9, reg, 32, False{}}, Con{XShift{8, reg, 32, False{}}, acc}}

def x64_bin_step4(is_sh: Bool, op: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_sh:
    case True{}: x64_mask32(0, Con{XShift{op, 0, 0, True{}}, acc})
    case False{}: x64_mask32(0, Con{XAluRR{op, 0, 1}, acc})

def x64_bin_step3(is_mod: Bool, +op: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_mod:
    case True{}: Con{XMovRR{0, 2}, Con{XDiv{1, False{}}, Con{XMovRI32{2, 0}, acc}}}
    case False{}: x64_bin_step4(U32.is_ge(op, 8), op, acc)

def x64_bin_step2(is_div: Bool, +op: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_div:
    case True{}: Con{XDiv{1, False{}}, Con{XMovRI32{2, 0}, acc}}
    case False{}: x64_bin_step3(U32.is_eq(op, 4), op, acc)

def x64_bin_step1(is_mul: Bool, +op: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_mul:
    case True{}: x64_mask32(0, Con{XMul{0, 1}, acc})
    case False{}: x64_bin_step2(U32.is_eq(op, 3), op, acc)

def x64_emit_bin(dst: U32, +op: U32, lhs: U32, rhs: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  a1 = x64_load_vreg(1, rhs, x64_load_vreg(0, lhs, acc))
  a2 = x64_bin_step1(U32.is_eq(op, 2), op, a1)
  x64_store_vreg(dst, 0, a2)

def x64_un_step(is_neg: Bool, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_neg:
    case True{}:
      a1 = x64_emit(XAluRR{1, 1, 0}, x64_emit(XMovRI32{1, 0}, acc))
      x64_mask32(0, x64_emit(XMovRR{0, 1}, a1))
    case False{}:
      x64_emit(XAluRR{7, 0, 1}, x64_emit(XMovRI32{1, 4294967295}, acc))

def x64_emit_ctor(dst: U32, cid: U32, +fields: List<&2, U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  cnt = b5k_u32_list_len(fields)
  a1 = x64_load_state(7, x64_store_scratch_go(fields, 0, acc))
  a2 = x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, cid}, a1)))
  x64_store_vreg(dst, 0, x64_emit(XCallSym{"p111_rt_ctor"}, a2))

def x64_emit_op(fn_map: Map<&2, String>, op: IrOp, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match op:
    case IConst{dst, val}: x64_store_vreg(dst, 0, x64_emit(XMovRI32{0, val}, acc))
    case IFlt{dst, bits}: x64_store_vreg(dst, 0, x64_emit(XMovRI32{0, bits}, acc))
    case ICopy{dst, src}: x64_store_vreg(dst, 0, x64_load_vreg(0, src, acc))
    case IBin{dst, bop, lhs, rhs}: x64_emit_bin(dst, bop, lhs, rhs, acc)
    case IUn{dst, uop, src}: x64_store_vreg(dst, 0, x64_un_step(U32.is_eq(uop, 0), x64_load_vreg(0, src, acc)))
    case ICmp{dst, cop, lhs, rhs}:
      a1 = x64_load_vreg(1, rhs, x64_load_vreg(0, lhs, acc))
      a2 = x64_emit(XSetcc{x64_cmp_cc(cop), 0}, x64_emit(XMovRI32{0, 0}, x64_emit(XCmpRR{0, 1}, a1)))
      x64_store_vreg(dst, 0, a2)
    case ICallDirect{dst, fid, args}:
      x64_store_vreg(dst, 0, x64_emit_call(x64_lookup_fn_sym(fn_map, fid), args, acc))
    case ICallClosure{dst, fid, +caps}:
      cnt = b5k_u32_list_len(caps)
      a1 = x64_load_state(7, x64_store_scratch_go(caps, 0, acc))
      a2 = x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, fid}, a1)))
      x64_store_vreg(dst, 0, x64_emit(XCallSym{"p111_rt_closure"}, a2))
    case IApply{dst, clo, arg}:
      a1 = x64_load_state(7, x64_load_vreg(2, arg, x64_load_vreg(6, clo, acc)))
      x64_store_vreg(dst, 0, x64_emit(XCallSym{"p111_rt_apply"}, a1))
    case ICtor{dst, cid, fields}: x64_emit_ctor(dst, cid, fields, acc)
    case ITake{+dsts, src}:
      cnt = b5k_u32_list_len(dsts)
      a1 = x64_load_state(7, x64_load_vreg(6, src, acc))
      a2 = x64_emit(XCallSym{"p111_rt_take"}, x64_emit(XMovRI32{1, cnt}, x64_emit(XMovRR{2, 4}, a1)))
      x64_load_scratch_go(dsts, 0, a2)
    case ITag{dst, src}:
      a1 = x64_load_state(7, x64_load_vreg(6, src, acc))
      x64_store_vreg(dst, 0, x64_emit(XCallSym{"p111_rt_tag"}, a1))
    case IKeep{dst, src}:
      a1 = x64_load_state(7, x64_load_vreg(6, src, acc))
      x64_store_vreg(dst, 0, x64_emit(XCallSym{"p111_rt_keep"}, a1))
    case ISink{src}:
      x64_emit(XCallSym{"p111_rt_sink"}, x64_load_state(7, x64_load_vreg(6, src, acc)))
    case IReuse{dst, _, cid, fields}: x64_emit_ctor(dst, cid, fields, acc)
    case IStatic{dst, idx}:
      a1 = x64_emit(XLoad{0, 0, U32.mul(idx, 8)}, x64_emit(XLeaRip{0, "p111_static_image"}, acc))
      x64_store_vreg(dst, 0, a1)
    case IArrOp{+dsts, aop, +args}:
      acnt = b5k_u32_list_len(args)
      ocnt = b5k_u32_list_len(dsts)
      a1 = x64_load_state(7, x64_store_scratch_go(args, 0, acc))
      a2 = x64_emit(XMovRI32{9, ocnt}, x64_emit(XMovRR{8, 4}, x64_emit(XMovRI32{1, acnt}, x64_emit(XMovRR{2, 4}, x64_emit(XMovRI32{6, aop}, a1)))))
      x64_load_scratch_go(dsts, 0, x64_emit(XCallSym{"p113_rt_array_pair"}, a2))
    case IAlloca{dst, _}: x64_store_vreg(dst, 4, acc)
    case ILoad{dst, base, off}:
      x64_store_vreg(dst, 0, x64_emit(XLoad{0, 0, U32.mul(off, 8)}, x64_load_vreg(0, base, acc)))
    case IStore{base, off, val}:
      a1 = x64_load_vreg(1, val, x64_load_vreg(0, base, acc))
      x64_emit(XStore{0, U32.mul(off, 8), 1}, a1)
    case IFail{code}:
      x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(7, acc)))

def x64_emit_ops(+fn_map: Map<&2, String>, ops: List<&2, IrOp>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ops:
    case Nil{}: acc
    case Con{op, t}: x64_emit_ops(fn_map, t, x64_emit_op(fn_map, op, acc))

def x64_emit_switch_arms(arms: List<&2, IrSwitchArm>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match arms:
    case Nil{}: acc
    case Con{IrArm{tag, target}, t}:
      x64_emit_switch_arms(t, x64_emit(XJcc{4, target}, x64_emit(XCmpRI{0, tag}, acc)))

def x64_emit_epilogue(acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XMovRR{4, 5}, acc)))

def x64_emit_term(fn_map: Map<&2, String>, term: IrTerm, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match term:
    case TJmp{target}: x64_emit(XJmp{target}, acc)
    case TBr{cond, then_blk, else_blk}:
      a1 = x64_emit(XTestRR{0, 0}, x64_load_vreg(0, cond, acc))
      x64_emit(XJmp{else_blk}, x64_emit(XJcc{5, then_blk}, a1))
    case TSwitch{scrut, arms, def_blk}:
      x64_emit(XJmp{def_blk}, x64_emit_switch_arms(arms, x64_load_vreg(0, scrut, acc)))
    case TRet{val}: x64_emit_epilogue(x64_load_vreg(0, val, acc))
    case TTailCall{fid, args}:
      x64_emit_epilogue(x64_emit_call(x64_lookup_fn_sym(fn_map, fid), args, acc))
    case TFail{code}:
      x64_emit_epilogue(x64_emit(XCallSym{"p111_rt_fail"}, x64_emit(XMovRI32{6, code}, x64_load_state(7, acc))))

def x64_emit_blocks(+fn_map: Map<&2, String>, blks: List<&2, IrBlock>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{id, ops, term}, t}:
      a1 = x64_emit_ops(fn_map, ops, x64_emit(XLabel{id}, acc))
      x64_emit_blocks(fn_map, t, x64_emit_term(fn_map, term, a1))

def x64_lower_fn(fn_map: Map<&2, String>, f: IrFn) -> X64Fn:
  match f:
    case IrFn{_, name, +arity, +nregs, _, _, _, blocks}:
      frame = x64_align16(U32.add(144, U32.mul(U32.max(nregs, arity), 8)))
      a0 = x64_emit(XStore{5, x64_state_disp(), 7}, x64_emit(XSubRsp{frame}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))
      a1 = x64_save_params_go(U32.to_nat(arity), 0, a0)
      X64Fn{x64_fn_sym(name), True{}, b5k_list_rev(X64Inst, x64_emit_blocks(fn_map, blocks, a1))}

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
      a2 = x64_emit(XMovRI32{2, 1}, x64_emit(XMovRR{6, 4}, x64_load_state(7, x64_emit(XStore{4, 0, 0}, a1))))
      a3 = x64_emit_epilogue(x64_emit(XCallSym{"p111_rt_return"}, a2))
      X64Fn{x64_seg_sym(fid), True{}, b5k_list_rev(X64Inst, a3)}

def x64_make_main_stub() -> X64Fn:
  a0 = x64_emit(XRet{}, x64_emit(XPop{5}, x64_emit(XCallSym{"p111_rt_main"}, x64_emit(XLeaRip{2, "p111_program"}, x64_emit(XMovRR{5, 4}, x64_emit(XPush{5}, Nil{}))))))
  X64Fn{"main", True{}, b5k_list_rev(X64Inst, a0)}

def x64_lower_all(+fn_map: Map<&2, String>, fns: List<&2, IrFn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match fns:
    case Nil{}: acc
    case Con{+f, t}:
      x64_lower_all(fn_map, t, Con{x64_make_seg_wrapper(f), Con{x64_lower_fn(fn_map, f), acc}})

def b5k_codegen(prog: IrProg) -> List<&2, X64Fn>:
  match prog:
    case IrProg{+fns, _, _, _, _, _, _, _}:
      fn_map = x64_build_fn_map_go(fns, Map.new(&2, String))
      b5k_list_rev(X64Fn, x64_lower_all(fn_map, fns, Con{x64_make_main_stub(), Nil{}}))
