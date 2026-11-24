# bend5k/elf.bend — Direct x86-64 Machine Code & ELF64 Relocatable Emitter
# ========================================================================
# Encodes X64Fn lists directly into x86-64 machine bytes (2-pass with dense
# label map, zero string scanning) and emits a standard ELF64 ET_REL (.o)
# object with P111 ABI v11102 metadata:
#   .text   (AX):  main, p111_seg_<fid>, $direct.<name>
#   .rodata (A):   p111_fid_*, p111_cid_arity, p111_cid_names_*, p111_show_desc
#   .data   (WA):  p111_cid_hot, p111_segments, p111_cid_names, p111_program

def elf_snd_u32(p: Map<&2, U32> & U32) -> U32:
  (_, v) = p
  v

def elf_map_u32(m: Map<&2, U32>, k: String) -> U32:
  elf_snd_u32(Map.get(U32, 0, m, k))

def elf_rex(w: U32, r: U32, x: U32, b: U32) -> U32:
  r0 = U32.or(64, U32.shln(U32.and(w, 1), 3n))
  r1 = U32.or(r0, U32.shln(U32.and(U32.shrn(r, 3n), 1), 2n))
  r2 = U32.or(r1, U32.shln(U32.and(U32.shrn(x, 3n), 1), 1n))
  U32.or(r2, U32.and(U32.shrn(b, 3n), 1))

def elf_modrm(md: U32, reg: U32, rm: U32) -> U32:
  m0 = U32.shln(U32.and(md, 3), 6n)
  U32.or(U32.or(m0, U32.shln(U32.and(reg, 7), 3n)), U32.and(rm, 7))

def elf_alu_rr_op(+op: U32) -> U32:
  a3 = Bool.pick(U32, U32.is_eq(op, 6), 9, 49)
  a2 = Bool.pick(U32, U32.is_eq(op, 5), 33, a3)
  a1 = Bool.pick(U32, U32.is_eq(op, 1), 41, a2)
  Bool.pick(U32, U32.is_eq(op, 0), 1, a1)

def elf_alu_ri_sub(+op: U32) -> U32:
  a3 = Bool.pick(U32, U32.is_eq(op, 6), 1, 6)
  a2 = Bool.pick(U32, U32.is_eq(op, 5), 4, a3)
  a1 = Bool.pick(U32, U32.is_eq(op, 1), 5, a2)
  Bool.pick(U32, U32.is_eq(op, 0), 0, a1)

def elf_shift_sub(op: U32) -> U32:
  Bool.pick(U32, U32.is_eq(op, 8), 4, 5)

def elf_inst_len(inst: X64Inst) -> U32:
  match inst:
    case XMovRR{_, _}: 3
    case XMovRI32{_, _}: 6
    case XMovRI64{_, _, _}: 10
    case XLoad{_, base, _}: Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 8, 7)
    case XStore{base, _, _}: Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 8, 7)
    case XLeaRip{_, _}: 7
    case XAluRR{_, _, _}: 3
    case XAluRI{_, _, _}: 7
    case XShift{_, _, _, by_cl}: Bool.pick(U32, by_cl, 3, 4)
    case XMul{_, _}: 4
    case XDiv{_, _}: 3
    case XCmpRR{_, _}: 3
    case XCmpRI{_, _}: 7
    case XTestRR{_, _}: 3
    case XSetcc{_, _}: 4
    case XPush{_}: 2
    case XPop{_}: 2
    case XSubRsp{_}: 7
    case XAddRsp{_}: 7
    case XLabel{_}: 0
    case XJmp{_}: 5
    case XJcc{_, _}: 6
    case XCallSym{_}: 5
    case XCallReg{_}: 3
    case XRet{}: 1
    case XXmmRR{op, _, _}: Bool.pick(U32, U32.is_ge(op, 5), 4, 5)
    case XXmmLoad{_, base, _}: Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 10, 9)
    case XXmmStore{base, _, _}: Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 10, 9)
    case XCvt{_, _, _}: 5
    case XExtReloc{_, _, _}: 0

def elf_lbl_key(+id: U32) -> U32:
  Bool.pick(U32, U32.is_ge(id, 2147483648), U32.add(U32.sub(id, 2147483648), 131072), id)

def elf_pass1_go(insts: List<&2, X64Inst>, +off: U32, lbls: RaVec<U32>) -> RaVec<U32>:
  match insts:
    case Nil{}: lbls
    case Con{XLabel{id}, t}:
      elf_pass1_go(t, off, ra_vec_set(U32, 9n, elf_lbl_key(id), off, lbls))
    case Con{inst, t}:
      elf_pass1_go(t, U32.add(off, elf_inst_len(inst)), lbls)

type TextAcc is Data:
  TextAcc{buf: ByteBuf, rels: List<&2, ElfReloc>}

def elf_opt_sib(need_sib: Bool, b: ByteBuf) -> ByteBuf:
  match need_sib:
    case True{}: bb_emit_u8(b, 36)
    case False{}: b

def elf_emit_mem(opc: U32, +reg: U32, +base: U32, disp: U32, b: ByteBuf) -> ByteBuf:
  b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, reg, 0, base)), opc), elf_modrm(2, reg, base))
  bb_emit_u32(elf_opt_sib(U32.is_eq(U32.and(base, 7), 4), b1), disp)

def elf_emit_xmm_mem(pfx: U32, opc: U32, +reg: U32, +base: U32, disp: U32, b: ByteBuf) -> ByteBuf:
  b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(b, pfx), elf_rex(0, reg, 0, base)), 15), opc), elf_modrm(2, reg, base))
  bb_emit_u32(elf_opt_sib(U32.is_eq(U32.and(base, 7), 4), b1), disp)

def elf_xmm_rr_opc(+op: U32) -> U32:
  o6 = Bool.pick(U32, U32.is_eq(op, 6), 87, 40)
  o5 = Bool.pick(U32, U32.is_eq(op, 5), 46, o6)
  o4 = Bool.pick(U32, U32.is_eq(op, 4), 81, o5)
  o3 = Bool.pick(U32, U32.is_eq(op, 3), 94, o4)
  o2 = Bool.pick(U32, U32.is_eq(op, 2), 89, o3)
  o1 = Bool.pick(U32, U32.is_eq(op, 1), 92, o2)
  Bool.pick(U32, U32.is_eq(op, 0), 88, o1)

def elf_emit_xmm_rr_pfx(no_pfx: Bool, b: ByteBuf) -> ByteBuf:
  match no_pfx:
    case True{}: b
    case False{}: bb_emit_u8(b, 243)

def elf_emit_xmm_rr(+op: U32, +dst: U32, +src: U32, b: ByteBuf) -> ByteBuf:
  b0 = elf_emit_xmm_rr_pfx(U32.is_ge(op, 5), b)
  bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(b0, elf_rex(0, dst, 0, src)), 15), elf_xmm_rr_opc(op)), elf_modrm(3, dst, src))

def elf_emit_cvt(+op: U32, +dst: U32, +src: U32, b: ByteBuf) -> ByteBuf:
  +is_m = U32.is_ge(op, 2)
  +is_st = U32.is_eq(op, 3)
  pfx = Bool.pick(U32, is_m, 102, 243)
  w = Bool.pick(U32, is_m, 0, 1)
  +reg = Bool.pick(U32, is_st, src, dst)
  +rm = Bool.pick(U32, is_st, dst, src)
  opc = Bool.pick(U32, U32.is_eq(op, 0), 42, Bool.pick(U32, U32.is_eq(op, 1), 44, Bool.pick(U32, U32.is_eq(op, 2), 110, 126)))
  bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(b, pfx), elf_rex(w, reg, 0, rm)), 15), opc), elf_modrm(3, reg, rm))

def elf_emit_shift(by_cl: Bool, sub: U32, +dst: U32, amt: U32, b: ByteBuf) -> ByteBuf:
  match by_cl:
    case True{}: bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, 0, 0, dst)), 211), elf_modrm(3, sub, dst))
    case False{}: bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, 0, 0, dst)), 193), elf_modrm(3, sub, dst)), amt)

def elf_emit_inst_go(inst: X64Inst, lbls: RaVec<U32>, b: ByteBuf, rels: List<&2, ElfReloc>, off: U32) -> TextAcc:
  match inst:
    case XMovRR{+dst, +src}:
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, src, 0, dst)), 137), elf_modrm(3, src, dst)), rels}
    case XMovRI32{+dst, imm}:
      TextAcc{bb_emit_u32(bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, dst)), U32.add(184, U32.and(dst, 7))), imm), rels}
    case XMovRI64{+dst, lo, hi}:
      TextAcc{bb_emit_u64(bb_emit_u8(bb_emit_u8(b, elf_rex(1, 0, 0, dst)), U32.add(184, U32.and(dst, 7))), lo, hi), rels}
    case XLoad{dst, base, disp}: TextAcc{elf_emit_mem(139, dst, base, disp, b), rels}
    case XStore{base, disp, src}: TextAcc{elf_emit_mem(137, src, base, disp, b), rels}
    case XLeaRip{+dst, sym}:
      b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, dst, 0, 0)), 141), elf_modrm(0, dst, 5))
      TextAcc{bb_emit_u32(b1, 0), Con{ElfReloc{U32.add(off, 3), sym, 2, U32.sub(0, 4)}, rels}}
    case XAluRR{op, +dst, +src}:
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, src, 0, dst)), elf_alu_rr_op(op)), elf_modrm(3, src, dst)), rels}
    case XAluRI{op, +dst, imm}:
      b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, 0, 0, dst)), 129), elf_modrm(3, elf_alu_ri_sub(op), dst))
      TextAcc{bb_emit_u32(b1, imm), rels}
    case XShift{op, dst, amt, by_cl}:
      TextAcc{elf_emit_shift(by_cl, elf_shift_sub(op), dst, amt, b), rels}
    case XMul{+dst, +src}:
      b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, dst, 0, src)), 15), 175)
      TextAcc{bb_emit_u8(b1, elf_modrm(3, dst, src)), rels}
    case XDiv{+src, is_signed}:
      sub = Bool.pick(U32, is_signed, 7, 6)
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, 0, 0, src)), 247), elf_modrm(3, sub, src)), rels}
    case XCmpRR{+lhs, +rhs}:
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, rhs, 0, lhs)), 57), elf_modrm(3, rhs, lhs)), rels}
    case XCmpRI{+lhs, imm}:
      b1 = bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, lhs)), 129), elf_modrm(3, 7, lhs))
      TextAcc{bb_emit_u32(b1, imm), rels}
    case XTestRR{+lhs, +rhs}:
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(1, rhs, 0, lhs)), 133), elf_modrm(3, rhs, lhs)), rels}
    case XSetcc{cc, +dst}:
      b1 = bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, dst)), 15)
      TextAcc{bb_emit_u8(bb_emit_u8(b1, U32.add(144, U32.and(cc, 15))), elf_modrm(3, 0, dst)), rels}
    case XPush{+reg}: TextAcc{bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, reg)), U32.add(80, U32.and(reg, 7))), rels}
    case XPop{+reg}: TextAcc{bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, reg)), U32.add(88, U32.and(reg, 7))), rels}
    case XSubRsp{imm}: TextAcc{bb_emit_u32(bb_emit_u8(bb_emit_u8(bb_emit_u8(b, 72), 129), 236), imm), rels}
    case XAddRsp{imm}: TextAcc{bb_emit_u32(bb_emit_u8(bb_emit_u8(bb_emit_u8(b, 72), 129), 196), imm), rels}
    case XLabel{_}: TextAcc{b, rels}
    case XJmp{target}:
      toff = ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls)
      TextAcc{bb_emit_u32(bb_emit_u8(b, 233), U32.sub(toff, U32.add(off, 5))), rels}
    case XJcc{cc, target}:
      toff = ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls)
      b1 = bb_emit_u8(bb_emit_u8(b, 15), U32.add(128, U32.and(cc, 15)))
      TextAcc{bb_emit_u32(b1, U32.sub(toff, U32.add(off, 6))), rels}
    case XCallSym{sym}:
      TextAcc{bb_emit_u32(bb_emit_u8(b, 232), 0), Con{ElfReloc{U32.add(off, 1), sym, 4, U32.sub(0, 4)}, rels}}
    case XCallReg{+reg}:
      TextAcc{bb_emit_u8(bb_emit_u8(bb_emit_u8(b, elf_rex(0, 0, 0, reg)), 255), elf_modrm(3, 2, reg)), rels}
    case XRet{}: TextAcc{bb_emit_u8(b, 195), rels}
    case XXmmRR{op, dst, src}: TextAcc{elf_emit_xmm_rr(op, dst, src, b), rels}
    case XXmmLoad{dst, base, disp}: TextAcc{elf_emit_xmm_mem(243, 16, dst, base, disp, b), rels}
    case XXmmStore{base, disp, src}: TextAcc{elf_emit_xmm_mem(102, 214, src, base, disp, b), rels}
    case XCvt{op, dst, src}: TextAcc{elf_emit_cvt(op, dst, src, b), rels}
    case XExtReloc{_, _, _}: TextAcc{b, rels}

def elf_emit_inst(inst: X64Inst, lbls: RaVec<U32>, ta: TextAcc) -> TextAcc:
  match ta:
    case TextAcc{+b, rels}: elf_emit_inst_go(inst, lbls, b, rels, bb_len(b))

def elf_emit_insts(insts: List<&2, X64Inst>, +lbls: RaVec<U32>, ta: TextAcc) -> TextAcc:
  match insts:
    case Nil{}: ta
    case Con{inst, t}: elf_emit_insts(t, lbls, elf_emit_inst(inst, lbls, ta))

# ELF Symbol Table & Alignment Helpers
# ------------------------------------

type ElfSym is Data:
  ElfSym{name: String, info: U32, shndx: U32, value: U32, size: U32}

type TextRes is Data:
  TextRes{buf: ByteBuf, rels: List<&2, ElfReloc>, lsyms: List<&2, ElfSym>, gsyms: List<&2, ElfSym>}

def elf_pad_fin(is_z: Bool, b: ByteBuf, pad: U32) -> ByteBuf:
  match is_z:
    case True{}: b
    case False{}: bb_emit_zeros(b, pad)

def elf_pad_to(+b: ByteBuf, +align: U32) -> ByteBuf:
  +rem = U32.mod(bb_len(b), align)
  elf_pad_fin(U32.is_zero(rem), b, U32.sub(align, rem))

def elf_encode_one(is_glob: Bool, name: String, +start: U32, ta2: TextAcc, ls: List<&2, ElfSym>, gs: List<&2, ElfSym>) -> TextRes:
  match is_glob ta2:
    case True{} TextAcc{+b2, rels2}:
      TextRes{b2, rels2, ls, Con{ElfSym{name, 18, 1, start, U32.sub(bb_len(b2), start)}, gs}}
    case False{} TextAcc{+b2, rels2}:
      TextRes{b2, rels2, Con{ElfSym{name, 2, 1, start, U32.sub(bb_len(b2), start)}, ls}, gs}

def elf_encode_fns_go(fns: List<&2, X64Fn>, tr: TextRes) -> TextRes:
  match fns tr:
    case Nil{} TextRes{b, rels, ls, gs}: TextRes{b, b5k_list_rev(ElfReloc, rels), ls, gs}
    case Con{X64Fn{name, is_glob, +insts}, t} TextRes{b0, rels0, ls, gs}:
      +b1 = elf_pad_to(b0, 16)
      +start = bb_len(b1)
      lbls = elf_pass1_go(insts, start, RVEmpty{})
      tr1 = elf_encode_one(is_glob, name, start, elf_emit_insts(insts, lbls, TextAcc{b1, rels0}), ls, gs)
      elf_encode_fns_go(t, tr1)

# P111 Metadata & Core Constructor Normalization
# ----------------------------------------------

def elf_core_ctors() -> List<&2, IrCtor>:
  Con{IrCtor{0, "SNil", 0, False{}}, Con{IrCtor{1, "SCon", 2, False{}},
  Con{IrCtor{2, "WNil", 0, False{}}, Con{IrCtor{3, "WCon", 2, False{}},
  Con{IrCtor{4, "Nil", 0, False{}}, Con{IrCtor{5, "Con", 2, False{}},
  Con{IrCtor{6, "Tuple", 2, False{}}, Con{IrCtor{7, "Unit", 0, False{}},
  Con{IrCtor{8, "None", 0, False{}}, Con{IrCtor{9, "Some", 1, False{}},
  Con{IrCtor{10, "Fail", 1, False{}}, Con{IrCtor{11, "Done", 1, False{}},
  Con{IrCtor{12, "Emit", 1, False{}}, Con{IrCtor{13, "Halt", 2, False{}},
  Con{IrCtor{14, "True", 0, False{}}, Con{IrCtor{15, "False", 0, False{}},
  Con{IrCtor{16, "LT", 0, False{}}, Con{IrCtor{17, "EQ", 0, False{}},
  Con{IrCtor{18, "GT", 0, False{}}, Con{IrCtor{19, "Chr", 1, False{}},
  Con{IrCtor{20, "Zero", 0, False{}}, Con{IrCtor{21, "Succ", 1, False{}},
  Con{IrCtor{22, "Exit", 1, False{}}, Con{IrCtor{23, "Pair", 2, False{}},
  Con{IrCtor{24, "Inl", 1, False{}}, Con{IrCtor{25, "Inr", 1, False{}}, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}

def elf_has_ctor_name(ctors: List<&2, IrCtor>, +nm: String) -> Bool:
  match ctors:
    case Nil{}: False{}
    case Con{IrCtor{_, cname, _, _}, t}: Bool.or(b5k_str_eq(cname, nm), elf_has_ctor_name(t, nm))

type MergeAcc is Data:
  MergeAcc{next_cid: U32, acc: List<&2, IrCtor>}

def elf_merge_one(found: Bool, nm: String, ar: U32, hot: Bool, ma: MergeAcc) -> MergeAcc:
  match found ma:
    case True{} _: ma
    case False{} MergeAcc{+nc, acc}: MergeAcc{U32.add(nc, 1), Con{IrCtor{nc, nm, ar, hot}, acc}}

def elf_merge_core_go(core: List<&2, IrCtor>, +existing: List<&2, IrCtor>, ma: MergeAcc) -> List<&2, IrCtor>:
  match core ma:
    case Nil{} MergeAcc{_, acc}: b5k_list_app(IrCtor, existing, b5k_list_rev(IrCtor, acc))
    case Con{IrCtor{_, +nm, ar, hot}, t} _:
      elf_merge_core_go(t, existing, elf_merge_one(elf_has_ctor_name(existing, nm), nm, ar, hot, ma))

def elf_emit_fid_arities(fns: List<&2, IrFn>, b: ByteBuf) -> ByteBuf:
  match fns:
    case Nil{}: b
    case Con{IrFn{_, _, ar, _, _, _, _, _}, t}: elf_emit_fid_arities(t, bb_emit_u8(b, ar))

def elf_max_arity(fns: List<&2, IrFn>, acc: U32) -> U32:
  match fns:
    case Nil{}: acc
    case Con{IrFn{_, _, ar, _, _, _, _, _}, t}: elf_max_arity(t, U32.max(acc, ar))

def elf_emit_cid_arities(ctors: List<&2, IrCtor>, b: ByteBuf) -> ByteBuf:
  match ctors:
    case Nil{}: b
    case Con{IrCtor{_, _, ar, _}, t}: elf_emit_cid_arities(t, bb_emit_u8(b, ar))

def elf_emit_cid_hots(ctors: List<&2, IrCtor>, b: ByteBuf) -> ByteBuf:
  match ctors:
    case Nil{}: b
    case Con{IrCtor{_, _, _, hot}, t}: elf_emit_cid_hots(t, bb_emit_u8(b, Bool.to_u32(hot)))

type StrPool is Data:
  StrPool{buf: ByteBuf, offs: List<&2, U32>}

def elf_emit_cstr_list_go(ss: List<&2, String>, +b: ByteBuf, offs: List<&2, U32>) -> StrPool:
  match ss:
    case Nil{}: StrPool{b, b5k_list_rev(U32, offs)}
    case Con{s, t}: elf_emit_cstr_list_go(t, bb_emit_cstr(b, s), Con{bb_len(b), offs})

def elf_ctor_names(ctors: List<&2, IrCtor>) -> List<&2, String>:
  match ctors:
    case Nil{}: Nil{}
    case Con{IrCtor{_, nm, _, _}, t}: Con{nm, elf_ctor_names(t)}

def elf_emit_u32_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf:
  match xs:
    case Nil{}: b
    case Con{x, t}: elf_emit_u32_arr(t, bb_emit_u32(b, x))

def elf_emit_u64_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf:
  match xs:
    case Nil{}: b
    case Con{x, t}: elf_emit_u64_arr(t, bb_emit_u64(b, x, 0))

def elf_emit_seg_ptrs(fns: List<&2, IrFn>, ta: TextAcc) -> TextAcc:
  match fns ta:
    case Nil{} _: ta
    case Con{IrFn{fid, _, _, _, _, _, _, _}, t} TextAcc{+b, rels}:
      elf_emit_seg_ptrs(t, TextAcc{bb_emit_u64(b, 0, 0), Con{ElfReloc{bb_len(b), x64_seg_sym(fid), 1, 0}, rels}})

def elf_emit_ro_ptrs(offs: List<&2, U32>, ta: TextAcc) -> TextAcc:
  match offs ta:
    case Nil{} _: ta
    case Con{ro_off, t} TextAcc{+b, rels}:
      elf_emit_ro_ptrs(t, TextAcc{bb_emit_u64(b, 0, 0), Con{ElfReloc{bb_len(b), ".rodata", 1, ro_off}, rels}})

def elf_emit_ptr_slot(ta: TextAcc, use_ptr: Bool, sym: String, addend: U32) -> TextAcc:
  match ta use_ptr:
    case TextAcc{+b, rels} True{}: TextAcc{bb_emit_u64(b, 0, 0), Con{ElfReloc{bb_len(b), sym, 1, addend}, rels}}
    case TextAcc{b, rels} False{}: TextAcc{bb_emit_u64(b, 0, 0), rels}

def elf_ta_len(ta: TextAcc) -> U32:
  match ta:
    case TextAcc{b, _}: bb_len(b)

def elf_ta_u64(ta: TextAcc, lo: U32, hi: U32) -> TextAcc:
  match ta:
    case TextAcc{b, rels}: TextAcc{bb_emit_u64(b, lo, hi), rels}

def elf_ta_pad8(ta: TextAcc) -> TextAcc:
  match ta:
    case TextAcc{b, rels}: TextAcc{elf_pad_to(b, 8), rels}

# Symtab, Strtab, Rela, Shdr Serialization
# ----------------------------------------

type UndefAcc is Data:
  UndefAcc{defined: Map<&2, U32>, acc: List<&2, ElfSym>}

def elf_collect_step(miss: Bool, +sym: String, m1: Map<&2, U32>, acc: List<&2, ElfSym>) -> UndefAcc:
  match miss:
    case True{}: UndefAcc{Map.set(&2, U32, m1, sym, 1), Con{ElfSym{sym, 16, 0, 0, 0}, acc}}
    case False{}: UndefAcc{m1, acc}

def elf_collect_got(got: Map<&2, U32> & U32, sym: String, acc: List<&2, ElfSym>) -> UndefAcc:
  (m1, found) = got
  elf_collect_step(U32.is_zero(found), sym, m1, acc)

def elf_collect_undefs_go(rels: List<&2, ElfReloc>, ua: UndefAcc) -> List<&2, ElfSym>:
  match rels ua:
    case Nil{} UndefAcc{_, acc}: acc
    case Con{ElfReloc{_, +sym, _, _}, t} UndefAcc{defined, acc}:
      elf_collect_undefs_go(t, elf_collect_got(Map.get(U32, 0, defined, sym), sym, acc))

def elf_mark_syms_go(syms: List<&2, ElfSym>, m: Map<&2, U32>) -> Map<&2, U32>:
  match syms:
    case Nil{}: m
    case Con{ElfSym{nm, _, _, _, _}, t}: elf_mark_syms_go(t, Map.set(&2, U32, m, nm, 1))

type SymTabRes is Data:
  SymTabRes{symtab: ByteBuf, strtab: ByteBuf, imap: Map<&2, U32>}

def elf_ser_sym_one(is_empty: Bool, +nm: String, info: U32, shndx: U32, val: U32, sz: U32, +idx: U32, sr: SymTabRes) -> SymTabRes:
  match is_empty sr:
    case True{} SymTabRes{sb, strb, imap}:
      s1 = bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, 0), info), 0), shndx), val, 0), sz, 0)
      SymTabRes{s1, strb, imap}
    case False{} SymTabRes{sb, +strb, imap}:
      s1 = bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, bb_len(strb)), info), 0), shndx), val, 0), sz, 0)
      SymTabRes{s1, bb_emit_cstr(strb, nm), Map.set(&2, U32, imap, nm, idx)}

def elf_ser_syms_go(syms: List<&2, ElfSym>, +idx: U32, sr: SymTabRes) -> SymTabRes:
  match syms:
    case Nil{}: sr
    case Con{ElfSym{+nm, info, shndx, val, sz}, t}:
      elf_ser_syms_go(t, U32.add(idx, 1), elf_ser_sym_one(String.is_empty(nm), nm, info, shndx, val, sz, idx, sr))

def elf_ser_rela_go(rels: List<&2, ElfReloc>, +imap: Map<&2, U32>, b: ByteBuf) -> ByteBuf:
  match rels:
    case Nil{}: b
    case Con{ElfReloc{off, sym, rtype, +addend}, t}:
      sidx = elf_map_u32(imap, sym)
      add_hi = Bool.pick(U32, U32.is_ge(addend, 2147483648), 4294967295, 0)
      b1 = bb_emit_u64(bb_emit_u64(bb_emit_u64(b, off, 0), rtype, sidx), addend, add_hi)
      elf_ser_rela_go(t, imap, b1)

def elf_emit_shdr(b: ByteBuf, nm: U32, typ: U32, flg: U32, off: U32, sz: U32, lnk: U32, inf: U32, aln: U32, ent: U32) -> ByteBuf:
  b1 = bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u32(b, nm), typ), flg, 0), 0, 0)
  b2 = bb_emit_u32(bb_emit_u32(bb_emit_u64(bb_emit_u64(b1, off, 0), sz, 0), lnk), inf)
  bb_emit_u64(bb_emit_u64(b2, aln, 0), ent, 0)

def elf_emit_ehdr(shoff: U32) -> ByteBuf:
  b0 = bb_emit_zeros(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_new(), 127), 69), 76), 70), 2), 1), 1), 0), 8)
  b1 = bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u16(bb_emit_u16(b0, 1), 62), 1), 0, 0), 0, 0), shoff, 0)
  bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u32(b1, 0), 64), 0), 0), 64), 9), 8)

def elf_build_shstrtab() -> ByteBuf:
  b0 = bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_u8(bb_new(), 0), ".text"), ".rela.text"), ".rodata")
  bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(b0, ".data"), ".rela.data"), ".symtab"), ".strtab"), ".shstrtab")

def elf_default_show(need_def: Bool, show_in: List<&2, U32>) -> List<&2, U32>:
  match need_def:
    case True{}: Con{0, Nil{}}
    case False{}: show_in

type RoData is Data:
  RoData{buf: ByteBuf, cid_offs: List<&2, U32>, show_offs: List<&2, U32>, eff_offs: List<&2, U32>, off_fid_ar: U32, off_fid_fl: U32, off_fid_rs: U32, off_cid_ar: U32, off_show: U32, off_stat: U32}

def elf_ro_s3(p3: StrPool, statics: List<&2, U32>, cid_offs: List<&2, U32>, show_offs: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32) -> RoData:
  match p3:
    case StrPool{ro9, eff_offs}:
      +ro10 = elf_pad_to(ro9, 8)
      off_stat = bb_len(ro10)
      RoData{elf_emit_u64_arr(statics, ro10), cid_offs, show_offs, eff_offs, off_far, off_ffl, off_frs, off_car, off_shd, off_stat}

def elf_ro_s2(p2: StrPool, effects: List<&2, String>, statics: List<&2, U32>, cid_offs: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32) -> RoData:
  match p2:
    case StrPool{ro8, show_offs}:
      elf_ro_s3(elf_emit_cstr_list_go(effects, ro8, Nil{}), statics, cid_offs, show_offs, off_far, off_ffl, off_frs, off_car, off_shd)

def elf_ro_s1(p1: StrPool, show_desc: List<&2, U32>, show_names: List<&2, String>, effects: List<&2, String>, statics: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32) -> RoData:
  match p1:
    case StrPool{ro5, cid_offs}:
      +ro6 = elf_pad_to(ro5, 4)
      off_shd = bb_len(ro6)
      ro7 = elf_emit_u32_arr(show_desc, ro6)
      elf_ro_s2(elf_emit_cstr_list_go(show_names, ro7, Nil{}), effects, statics, cid_offs, off_far, off_ffl, off_frs, off_car, off_shd)

def elf_build_rodata(ir_fns: List<&2, IrFn>, +all_ctors: List<&2, IrCtor>, +n_segs: U32, show_desc: List<&2, U32>, show_names: List<&2, String>, effects: List<&2, String>, statics: List<&2, U32>) -> RoData:
  +ro1 = elf_emit_fid_arities(ir_fns, bb_new())
  +ro2 = bb_emit_zeros(ro1, n_segs)
  +ro3 = bb_emit_zeros(ro2, n_segs)
  ro4 = elf_emit_cid_arities(all_ctors, ro3)
  elf_ro_s1(elf_emit_cstr_list_go(elf_ctor_names(all_ctors), ro4, Nil{}), show_desc, show_names, effects, statics, 0, bb_len(ro1), bb_len(ro2), bb_len(ro3))

def elf_pack_image(+text_buf: ByteBuf, +ro_buf: ByteBuf, +data_buf: ByteBuf, text_rels: List<&2, ElfReloc>, data_rels: List<&2, ElfReloc>, first_glob: U32, sr: SymTabRes) -> ByteBuf:
  match sr:
    case SymTabRes{+symtab_buf, +strtab_buf, +idx_map}:
      +rela_text_buf = elf_ser_rela_go(text_rels, idx_map, bb_new())
      +rela_data_buf = elf_ser_rela_go(data_rels, idx_map, bb_new())
      +shstr_buf = elf_build_shstrtab()
      +sz_text = bb_len(text_buf)
      +sz_rtxt = bb_len(rela_text_buf)
      +sz_ro   = bb_len(ro_buf)
      +sz_dat  = bb_len(data_buf)
      +sz_rdat = bb_len(rela_data_buf)
      +sz_sym  = bb_len(symtab_buf)
      +sz_str  = bb_len(strtab_buf)
      +sz_shst = bb_len(shstr_buf)
      +off_text = U32.add(64, 0)
      +off_rtxt = x64_align16(U32.add(off_text, sz_text))
      +off_ro   = x64_align16(U32.add(off_rtxt, sz_rtxt))
      +off_dat  = x64_align16(U32.add(off_ro, sz_ro))
      +off_rdat = x64_align16(U32.add(off_dat, sz_dat))
      +off_sym  = x64_align16(U32.add(off_rdat, sz_rdat))
      +off_str  = U32.add(off_sym, sz_sym)
      +off_shst = U32.add(off_str, sz_str)
      +off_shdr = x64_align16(U32.add(off_shst, sz_shst))
      e1 = bb_append_bytes(elf_emit_ehdr(off_shdr), bb_to_bytes(text_buf))
      e2 = bb_append_bytes(elf_pad_to(e1, 16), bb_to_bytes(rela_text_buf))
      e3 = bb_append_bytes(elf_pad_to(e2, 16), bb_to_bytes(ro_buf))
      e4 = bb_append_bytes(elf_pad_to(e3, 16), bb_to_bytes(data_buf))
      e5 = bb_append_bytes(elf_pad_to(e4, 16), bb_to_bytes(rela_data_buf))
      e6 = bb_append_bytes(elf_pad_to(e5, 16), bb_to_bytes(symtab_buf))
      e7 = bb_append_bytes(e6, bb_to_bytes(strtab_buf))
      h0 = elf_pad_to(bb_append_bytes(e7, bb_to_bytes(shstr_buf)), 16)
      h1 = elf_emit_shdr(h0, 0,  0, 0,  0,        0,       0, 0,          0,  0)
      h2 = elf_emit_shdr(h1, 1,  1, 6,  off_text, sz_text, 0, 0,          16, 0)
      h3 = elf_emit_shdr(h2, 7,  4, 64, off_rtxt, sz_rtxt, 6, 1,          8,  24)
      h4 = elf_emit_shdr(h3, 18, 1, 2,  off_ro,   sz_ro,   0, 0,          8,  0)
      h5 = elf_emit_shdr(h4, 26, 1, 3,  off_dat,  sz_dat,  0, 0,          8,  0)
      h6 = elf_emit_shdr(h5, 32, 4, 64, off_rdat, sz_rdat, 6, 4,          8,  24)
      h7 = elf_emit_shdr(h6, 43, 2, 0,  off_sym,  sz_sym,  7, first_glob, 8,  24)
      h8 = elf_emit_shdr(h7, 51, 3, 0,  off_str,  sz_str,  0, 0,          1,  0)
      elf_emit_shdr(h8, 59, 3, 0, off_shst, sz_shst, 0, 0, 1, 0)

def elf_cons_sym(s: ElfSym, xs: List<&2, ElfSym>) -> List<&2, ElfSym>:
  Con{s, xs}

def elf_finish_data(text_buf: ByteBuf, +text_rels: List<&2, ElfReloc>, text_lsyms: List<&2, ElfSym>, text_gsyms: List<&2, ElfSym>, ro_buf: ByteBuf, da: TextAcc, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32, off_sta: U32, off_segs: U32, off_cnm: U32, off_prog: U32, +n_segs: U32, +n_ctors: U32, n_show: U32, n_stat: U32) -> ByteBuf:
  match da:
    case TextAcc{data_buf, dr_rev}:
      +data_rels = b5k_list_rev(ElfReloc, dr_rev)
      +locals = b5k_list_app(ElfSym,
        Con{ElfSym{"", 0, 0, 0, 0}, Con{ElfSym{".text", 3, 1, 0, 0}, Con{ElfSym{".rodata", 3, 3, 0, 0},
        Con{ElfSym{".data", 3, 4, 0, 0}, Con{ElfSym{"p111_fid_arity", 1, 3, off_far, n_segs},
        Con{ElfSym{"p111_fid_flags", 1, 3, off_ffl, n_segs}, Con{ElfSym{"p111_fid_results", 1, 3, off_frs, n_segs},
        Con{ElfSym{"p111_cid_arity", 1, 3, off_car, n_ctors}, Con{ElfSym{"p111_show_desc", 1, 3, off_shd, U32.mul(n_show, 4)},
        Con{ElfSym{"p111_static_image", 1, 3, off_sta, U32.mul(n_stat, 8)}, Con{ElfSym{"p111_cid_hot", 1, 4, 0, n_ctors},
        Con{ElfSym{"p111_segments", 1, 4, off_segs, U32.mul(n_segs, 8)}, Con{ElfSym{"p111_cid_names", 1, 4, off_cnm, U32.mul(n_ctors, 8)}, Nil{}}}}}}}}}}}}}},
        b5k_list_rev(ElfSym, text_lsyms))
      first_glob = b5k_list_len(ElfSym, locals)
      +def_globs = elf_cons_sym(ElfSym{"p111_program", 17, 4, off_prog, B5K_P111_DESC_BYTES()}, b5k_list_rev(ElfSym, text_gsyms))
      def_map1 = elf_mark_syms_go(def_globs, elf_mark_syms_go(locals, Map.new(&2, U32)))
      undefs = b5k_list_rev(ElfSym, elf_collect_undefs_go(b5k_list_app(ElfReloc, text_rels, data_rels), UndefAcc{def_map1, Nil{}}))
      all_syms = b5k_list_app(ElfSym, locals, b5k_list_app(ElfSym, def_globs, undefs))
      sr = elf_ser_syms_go(all_syms, 0, SymTabRes{bb_new(), bb_emit_u8(bb_new(), 0), Map.new(&2, U32)})
      elf_pack_image(text_buf, ro_buf, data_buf, text_rels, data_rels, first_glob, sr)

def elf_finish_ro(ro: RoData, text_buf: ByteBuf, text_rels: List<&2, ElfReloc>, text_lsyms: List<&2, ElfSym>, text_gsyms: List<&2, ElfSym>, ir_fns: List<&2, IrFn>, all_ctors: List<&2, IrCtor>, +n_segs: U32, +n_ctors: U32, main_fid: U32, main_pure: Bool, reg_w: U32, +n_stat: U32, +n_show: U32, +n_sname: U32, +n_eff: U32) -> ByteBuf:
  match ro:
    case RoData{ro_buf, cid_offs, show_offs, eff_offs, off_far, off_ffl, off_frs, off_car, off_shd, off_sta}:
      +da1 = elf_pad_to(elf_emit_cid_hots(all_ctors, bb_new()), 8)
      +off_segs = bb_len(da1)
      +ta2 = elf_emit_seg_ptrs(ir_fns, TextAcc{da1, Nil{}})
      +off_cnm = elf_ta_len(ta2)
      +ta3 = elf_emit_ro_ptrs(cid_offs, ta2)
      +off_snm = elf_ta_len(ta3)
      +ta4 = elf_emit_ro_ptrs(show_offs, ta3)
      +off_eff = elf_ta_len(ta4)
      +ta5 = elf_ta_pad8(elf_emit_ro_ptrs(eff_offs, ta4))
      off_prog = elf_ta_len(ta5)
      p0 = elf_ta_u64(elf_ta_u64(ta5, B5K_P111_ABI_VER(), 0), B5K_P111_DESC_BYTES(), 0)
      p1 = elf_ta_u64(elf_ta_u64(p0, n_segs, 0), n_ctors, 0)
      p2 = elf_ta_u64(elf_ta_u64(p1, main_fid, 0), Bool.to_u32(main_pure), 0)
      p3 = elf_ta_u64(elf_ta_u64(p2, reg_w, 0), 1, 0)
      p4 = elf_ta_u64(elf_ta_u64(p3, n_stat, 0), n_show, 0)
      p5 = elf_ta_u64(elf_ta_u64(p4, n_sname, 0), B5K_P111_SEQUENTIAL(), 0)
      q0 = elf_emit_ptr_slot(p5, True{}, "p111_segments", 0)
      q1 = elf_emit_ptr_slot(q0, True{}, "p111_fid_arity", 0)
      q2 = elf_emit_ptr_slot(q1, True{}, "p111_fid_flags", 0)
      q3 = elf_emit_ptr_slot(q2, True{}, "p111_fid_results", 0)
      q4 = elf_emit_ptr_slot(q3, True{}, "p111_cid_arity", 0)
      q5 = elf_emit_ptr_slot(q4, True{}, "p111_cid_hot", 0)
      q6 = elf_emit_ptr_slot(q5, True{}, "p111_cid_names", 0)
      q7 = elf_emit_ptr_slot(q6, U32.is_gt(n_stat, 0), "p111_static_image", 0)
      q8 = elf_emit_ptr_slot(q7, U32.is_gt(n_show, 0), "p111_show_desc", 0)
      q9 = elf_emit_ptr_slot(q8, U32.is_gt(n_sname, 0), ".data", off_snm)
      q10 = elf_emit_ptr_slot(elf_ta_u64(q9, n_eff, 0), U32.is_gt(n_eff, 0), ".data", off_eff)
      elf_finish_data(text_buf, text_rels, text_lsyms, text_gsyms, ro_buf, q10, off_far, off_ffl, off_frs, off_car, off_shd, off_sta, off_segs, off_cnm, off_prog, n_segs, n_ctors, n_show, n_stat)

def elf_finish(tres: TextRes, +ir_fns: List<&2, IrFn>, +ir_ctors: List<&2, IrCtor>, +statics: List<&2, U32>, main_fid: U32, +main_pure: Bool, +effects: List<&2, String>, +show_desc_in: List<&2, U32>, +show_names: List<&2, String>) -> ByteBuf:
  match tres:
    case TextRes{text_buf, text_rels, text_lsyms, text_gsyms}:
      +all_ctors = elf_merge_core_go(elf_core_ctors(), ir_ctors, MergeAcc{b5k_list_len(IrCtor, ir_ctors), Nil{}})
      +n_segs = b5k_list_len(IrFn, ir_fns)
      +n_ctors = b5k_list_len(IrCtor, all_ctors)
      +n_stat = b5k_u32_list_len(statics)
      +show_desc = elf_default_show(Bool.and(main_pure, U32.is_zero(b5k_u32_list_len(show_desc_in))), show_desc_in)
      +n_show = b5k_u32_list_len(show_desc)
      +n_sname = b5k_list_len(String, show_names)
      +n_eff = b5k_list_len(String, effects)
      reg_w = U32.max(2, elf_max_arity(ir_fns, 0))
      ro = elf_build_rodata(ir_fns, all_ctors, n_segs, show_desc, show_names, effects, statics)
      elf_finish_ro(ro, text_buf, text_rels, text_lsyms, text_gsyms, ir_fns, all_ctors, n_segs, n_ctors, main_fid, main_pure, reg_w, n_stat, n_show, n_sname, n_eff)

def b5k_emit_elf(prog: IrProg, fns: List<&2, X64Fn>) -> ByteBuf:
  match prog:
    case IrProg{ir_fns, ir_ctors, statics, main_fid, main_pure, effects, show_desc_in, show_names}:
      tres = elf_encode_fns_go(fns, TextRes{bb_new(), Nil{}, Nil{}, Nil{}})
      elf_finish(tres, ir_fns, ir_ctors, statics, main_fid, main_pure, effects, show_desc_in, show_names)
