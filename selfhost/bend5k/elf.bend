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
def elf_rex(w: U32, r: U32, x: U32, b: U32) -> U32: U32.or(U32.or(64, U32.shln(U32.and(w, 1), 3n)), U32.or(U32.shln(U32.and(U32.shrn(r, 3n), 1), 2n), U32.or(U32.shln(U32.and(U32.shrn(x, 3n), 1), 1n), U32.and(U32.shrn(b, 3n), 1))))
def elf_modrm(md: U32, reg: U32, rm: U32) -> U32: U32.or(U32.or(U32.shln(U32.and(md, 3), 6n), U32.shln(U32.and(reg, 7), 3n)), U32.and(rm, 7))
def elf_is_hi(a: U32, b: U32) -> Bool: Bool.or(U32.is_ge(a, 8), U32.is_ge(b, 8))
def elf_alu_rr_op(+op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 0), 1, Bool.pick(U32, U32.is_eq(op, 1), 41, Bool.pick(U32, U32.is_eq(op, 5), 33, Bool.pick(U32, U32.is_eq(op, 6), 9, 49))))
def elf_alu_ri_sub(+op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 0), 0, Bool.pick(U32, U32.is_eq(op, 1), 5, Bool.pick(U32, U32.is_eq(op, 5), 4, Bool.pick(U32, U32.is_eq(op, 6), 1, 6))))
def elf_shift_sub(op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 8), 4, 5)
def elf_is_simm8(v: U32) -> Bool: U32.is_lt(U32.add(v, 128), 256)
def elf_mem_mod(+base: U32, +disp: U32) -> U32: Bool.pick(U32, Bool.and(U32.is_zero(disp), U32.is_ne(U32.and(base, 7), 5)), 0, Bool.pick(U32, elf_is_simm8(disp), 1, 2))
def elf_disp_len(+md: U32) -> U32: Bool.pick(U32, U32.is_zero(md), 0, Bool.pick(U32, U32.is_eq(md, 1), 1, 4))
def elf_mem_extra(+base: U32, disp: U32) -> U32: U32.add(Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 1, 0), elf_disp_len(elf_mem_mod(base, disp)))
def elf_alu_ri32_len(+dst: U32, imm: U32) -> U32: U32.add(Bool.pick(U32, U32.is_ge(dst, 8), 1, 0), Bool.pick(U32, elf_is_simm8(imm), 3, 6))
def elf_shl32_len(+dst: U32, amt: U32) -> U32: U32.add(Bool.pick(U32, U32.is_ge(dst, 8), 1, 0), Bool.pick(U32, U32.is_eq(amt, 1), 2, 3))
def elf_inst_len(inst: X64Inst) -> U32:
  match inst:
    case XMovRR{_, _}: 3
    case XMovRI32{dst, _}: Bool.pick(U32, U32.is_lt(dst, 8), 5, 6)
    case XMovRI64{_, _, _}: 10
    case XLoad{_, base, disp}: U32.add(3, elf_mem_extra(base, disp))
    case XStore{base, disp, _}: U32.add(3, elf_mem_extra(base, disp))
    case XLeaRip{_, _}: 7
    case XAluRR{op, +dst, src}: Bool.pick(U32, Bool.and(U32.is_eq(op, 7), Bool.and(U32.is_eq(dst, src), U32.is_lt(dst, 8))), 2, 3)
    case XAluRI{_, _, imm}: Bool.pick(U32, elf_is_simm8(imm), 4, 7)
    case XShift{10, dst, amt, False{}}: elf_shl32_len(dst, amt)
    case XShift{_, _, amt, by_cl}: Bool.pick(U32, Bool.or(by_cl, U32.is_eq(amt, 1)), 3, 4)
    case XMul{_, _}: 4
    case XDiv{_, _}: 3
    case XCmpRR{_, _}: 3
    case XCmpRI{lhs, imm}: elf_alu_ri32_len(lhs, imm)
    case XTestRR{_, _}: 3
    case XSetcc{_, dst}: Bool.pick(U32, U32.is_ge(dst, 4), 4, 3)
    case XCmov{_, _, _}: 4
    case XPush{reg}: Bool.pick(U32, U32.is_lt(reg, 8), 1, 2)
    case XPop{reg}: Bool.pick(U32, U32.is_lt(reg, 8), 1, 2)
    case XSubRsp{imm}: Bool.pick(U32, elf_is_simm8(imm), 4, 7)
    case XAddRsp{imm}: Bool.pick(U32, elf_is_simm8(imm), 4, 7)
    case XLabel{_}: 0
    case XJmp{_}: 5
    case XJcc{_, _}: 6
    case XCallSym{_}: 5
    case XCallReg{reg}: Bool.pick(U32, U32.is_lt(reg, 8), 2, 3)
    case XRet{}: 1
    case XXmmRR{op, dst, src}: U32.add(3, U32.add(Bool.pick(U32, U32.is_ge(op, 5), 0, 1), Bool.pick(U32, elf_is_hi(dst, src), 1, 0)))
    case XXmmLoad{dst, +base, disp}: U32.add(U32.add(4, Bool.pick(U32, elf_is_hi(dst, base), 1, 0)), elf_mem_extra(base, disp))
    case XXmmStore{+base, disp, src}: U32.add(U32.add(4, Bool.pick(U32, elf_is_hi(src, base), 1, 0)), elf_mem_extra(base, disp))
    case XCvt{op, dst, src}: Bool.pick(U32, Bool.or(U32.is_lt(op, 2), elf_is_hi(dst, src)), 5, 4)
    case XExtReloc{_, _, _}: 0
def elf_lbl_key(+id: U32) -> U32: Bool.pick(U32, U32.is_ge(id, 2147483648), U32.add(U32.sub(id, 2147483648), 131072), id)
def elf_not_flag_read(xs: List<&2, X64Inst>) -> Bool:
  match xs:
    case Con{XJcc{_, _}, _}: False{}
    case Con{XSetcc{_, _}, _}: False{}
    case Con{XCmov{_, _, _}, _}: False{}
    case _: True{}
def elf_kills_reg(+r: U32, inst: X64Inst) -> Bool:
  match inst:
    case XLoad{d, b, _}: Bool.and(U32.is_eq(d, r), U32.is_ne(b, r))
    case XMovRR{d, s}: Bool.and(U32.is_eq(d, r), U32.is_ne(s, r))
    case XMovRI32{d, _}: U32.is_eq(d, r)
    case XAluRR{7, d, s}: Bool.and(U32.is_eq(d, r), U32.is_eq(s, r))
    case _: False{}
def elf_sib8_len(+base: U32) -> U32: Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 5, 4)
def elf_shl3_code(ok: Bool, +idx: U32, xs: List<&2, X64Inst>) -> U32:
  match ok xs:
    case False{} _: 0
    case True{} Con{XAluRR{0, +d2, +s2}, Con{XLoad{+d3, +b3, 0}, t3}}:
      +nf = elf_not_flag_read(t3)
      ok_ld = Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), Bool.and(Bool.and(U32.is_eq(d3, idx), U32.is_eq(b3, idx)), nf))
      ok_b  = Bool.and(Bool.and(U32.is_eq(s2, idx), U32.is_ne(d2, idx)), Bool.and(Bool.and(U32.is_eq(d3, idx), U32.is_ne(b3, idx)), nf))
      Bool.pick(U32, ok_ld, U32.add(16, s2), Bool.pick(U32, Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), U32.add(32, s2), Bool.pick(U32, ok_b, U32.add(48, d2), 0)))
    case True{} Con{XAluRR{0, +d2, +s2}, Con{XStore{+b3, 0, +v3}, Con{+nxt, t4}}}:
      ok_st = Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), Bool.and(Bool.and(U32.is_eq(b3, idx), U32.is_ne(v3, idx)), Bool.and(elf_kills_reg(idx, nxt), elf_not_flag_read(t4))))
      Bool.pick(U32, ok_st, U32.add(U32.add(64, s2), U32.shln(v3, 8n)), Bool.pick(U32, Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), U32.add(32, s2), 0))
    case True{} Con{XAluRR{0, +d2, +s2}, Con{+nxt, +t3}}:
      ok_a = Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), elf_not_flag_read(Con{nxt, t3}))
      ok_b = Bool.and(Bool.and(U32.is_eq(s2, idx), U32.is_ne(d2, idx)), Bool.and(elf_kills_reg(idx, nxt), elf_not_flag_read(t3)))
      Bool.pick(U32, ok_a, U32.add(32, s2), Bool.pick(U32, ok_b, U32.add(48, d2), 0))
    case True{} Con{XAluRR{0, +d2, +s2}, Nil{}}: Bool.pick(U32, Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), U32.add(32, s2), 0)
    case True{} _: 0
def elf_head_is_mask32(xs: List<&2, X64Inst>, +reg: U32) -> Bool:
  match xs:
    case Con{XShift{8, r1, 32, False{}}, Con{XShift{9, r2, 32, False{}}, _}}: Bool.and(U32.is_eq(r1, reg), U32.is_eq(r2, reg))
    case _: False{}
def elf_head_is_shr32(xs: List<&2, X64Inst>, reg: U32) -> Bool:
  match xs:
    case Con{XShift{9, r2, 32, False{}}, t}: Bool.and(U32.is_eq(r2, reg), elf_not_flag_read(t))
    case _: False{}
def elf_alu_rr32_len(op: U32, +dst: U32, +src: U32) -> U32: Bool.pick(U32, Bool.pick(Bool, Bool.and(U32.is_eq(op, 7), U32.is_eq(dst, src)), U32.is_ge(dst, 8), elf_is_hi(dst, src)), 3, 2)
def elf_mul_len(+ok: Bool, +d: U32, +s: U32) -> U32:
  +md = Bool.pick(U32, U32.is_eq(U32.and(d, 7), 5), 1, 0)
  l32 = U32.add(3, U32.add(Bool.pick(U32, U32.is_ge(d, 8), 1, 0), md))
  Bool.pick(U32, U32.is_ge(s, 17), Bool.pick(U32, ok, l32, U32.add(4, md)), Bool.pick(U32, ok, Bool.pick(U32, elf_is_hi(d, s), 4, 3), 4))
def elf_mov32_len(r: U32) -> U32: Bool.pick(U32, U32.is_ge(r, 8), 3, 2)
def elf_head_ri_imm(t: List<&2, X64Inst>) -> U32:
  match t:
    case Con{XAluRI{_, _, imm}, _}: imm
    case _: 0
def elf_dead_rmw(fuel: Nat, +r: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel xs:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{XLabel{_}, t}: Bool.and(U32.is_zero(r), elf_dead_rmw(p, 0, t))
    case 1n+p Con{XJcc{_, _}, t}: Bool.and(U32.is_zero(r), peep_dead_reg(6n, 0, t))
    case 1n+p Con{+h, t}: Bool.pick(Bool, peep_kills_reg(r, h), True{}, Bool.pick(Bool, peep_reads_reg(r, h), False{}, elf_dead_rmw(p, r, t)))
def elf_and_dead_rmw(c: Bool, fuel: Nat, r: U32, xs: List<&2, X64Inst>) -> Bool:
  match c:
    case False{}: False{}
    case True{}: elf_dead_rmw(fuel, r, xs)
def elf_load_code(+tmp: U32, +base: U32, +disp: U32, t: List<&2, X64Inst>) -> U32:
  match t:
    case Con{XAluRR{+op, +d, +s}, +t2}:
      +ok = peep_and_dead(Bool.and(U32.is_eq(s, tmp), U32.is_ne(d, tmp)), 6n, tmp, t2)
      Bool.pick(U32, ok, U32.or(Bool.pick(U32, elf_head_is_mask32(t2, d), 2, 1), U32.or(U32.shln(U32.add(elf_alu_rr_op(op), 2), 4n), U32.shln(d, 12n))), 0)
    case Con{XCmpRR{+a, +b}, +t2}:
      +cr = Bool.and(U32.is_eq(b, tmp), U32.is_ne(a, tmp))
      +ok = peep_and_dead(Bool.or(cr, Bool.and(U32.is_eq(a, tmp), U32.is_ne(b, tmp))), 6n, tmp, t2)
      Bool.pick(U32, ok, U32.or(1, U32.or(U32.shln(Bool.pick(U32, cr, 59, 57), 4n), U32.shln(Bool.pick(U32, cr, a, b), 12n))), 0)
    case Con{XAluRI{+op, +r2, _}, Con{XShift{8, +m1, 32, False{}}, Con{XShift{9, +m2, 32, False{}}, Con{XStore{+b2, +d2, +r3}, +t4}}}}:
      c = Bool.and(Bool.and(Bool.and(U32.is_eq(r2, tmp), U32.is_eq(r3, tmp)), Bool.and(U32.is_eq(m1, tmp), U32.is_eq(m2, tmp))), Bool.and(Bool.and(U32.is_ne(tmp, base), U32.is_ne(base, 5)), Bool.and(Bool.and(U32.is_eq(b2, base), U32.is_eq(d2, disp)), elf_not_flag_read(t4))))
      Bool.pick(U32, elf_and_dead_rmw(c, 6n, tmp, t4), U32.or(4, U32.shln(elf_alu_ri_sub(op), 4n)), 0)
    case Con{XAluRI{+op, +r2, _}, Con{XStore{+b2, +d2, +r3}, +t3}}:
      c = Bool.and(Bool.and(U32.is_eq(r2, tmp), U32.is_eq(r3, tmp)), Bool.and(U32.is_ne(tmp, base), Bool.and(U32.is_eq(b2, base), U32.is_eq(d2, disp))))
      Bool.pick(U32, peep_and_dead(c, 6n, tmp, t3), U32.or(3, U32.shln(elf_alu_ri_sub(op), 4n)), 0)
    case _: 0
def elf_load_skip(+k: U32) -> Nat: Bool.pick(Nat, U32.is_eq(k, 2), 3n, Bool.pick(Nat, U32.is_eq(k, 3), 2n, U32.to_nat(k)))
def elf_shl_skip(sc: U32, +k: U32, ok_shl: Bool, ok_mov: Bool) -> Nat: Bool.pick(Nat, U32.is_ne(sc, 0), Bool.pick(Nat, Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 4)), 2n, 1n), Bool.pick(Nat, ok_shl, 2n, Bool.pick(Nat, ok_mov, 1n, 0n)))
type LutArm is Data:
  LutArm{ok: Bool, is_xmm: Bool, val: U32, dst: U32, copy: U32, gtmp: U32, join: U32, rest: List<&2, X64Inst>}
type LutHit is Data:
  LutHit{ok: Bool, is_xmm: Bool, idx: U32, dst: U32, copy: U32, gtmp: U32, join: U32, def_lbl: U32, n: U32, vals: List<&2, U32>, rest: List<&2, X64Inst>}
def elf_lut_arm_fin(ok: Bool, is_xmm: Bool, val: U32, +dst: U32, gtmp: U32, tail: List<&2, X64Inst>) -> LutArm:
  match is_xmm tail:
    case False{} Con{XMovRR{c, d2}, Con{XJmp{j}, r}}: LutArm{Bool.and(ok, U32.is_eq(dst, d2)), False{}, val, dst, c, gtmp, j, r}
    case True{} Con{XXmmRR{7, c, x2}, Con{XJmp{j}, r}}: LutArm{Bool.and(ok, U32.is_eq(dst, x2)), True{}, val, dst, c, gtmp, j, r}
    case _ Con{XJmp{j}, r}: LutArm{ok, is_xmm, val, dst, dst, gtmp, j, r}
    case _ _: LutArm{False{}, False{}, 0, 0, 0, 16, 0, tail}
def elf_lut_arm(xs: List<&2, X64Inst>) -> LutArm:
  match xs:
    case Con{XMovRI32{+g, v}, Con{XCvt{2, +x, g1}, r}}: elf_lut_arm_fin(U32.is_eq(g, g1), True{}, v, x, g, r)
    case Con{XMovRI32{+d, v}, r}: elf_lut_arm_fin(True{}, False{}, v, d, 16, r)
    case Con{XAluRR{7, +d, d1}, r}: elf_lut_arm_fin(U32.is_eq(d, d1), False{}, 0, d, 16, r)
    case Con{XXmmRR{6, +x, x1}, Con{XMovRI32{+g, +v}, Con{XCvt{2, +x2, g1}, Con{XXmmRR{1, x3, x2b}, r}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(x, x1), U32.is_eq(g, g1)), Bool.and(U32.is_eq(x, x3), Bool.and(U32.is_eq(x2, x2b), U32.is_ne(x, x2))))
      elf_lut_arm_fin(ok, True{}, Bool.pick(U32, U32.is_zero(v), 0, U32.xor(v, 2147483648)), x, g, r)
    case Con{XXmmRR{6, +x, x1}, r}: elf_lut_arm_fin(U32.is_eq(x, x1), True{}, 0, x, 16, r)
    case _: LutArm{False{}, False{}, 0, 0, 0, 16, 0, xs}
type LutSt is Data:
  LutSt{done: Bool, is_xmm: Bool, idx: U32, dst: U32, copy: U32, gtmp: U32, join: U32, elbl: U32, k: U32, vals: List<&2, U32>, xs: List<&2, X64Inst>}
def elf_lut_fin(st: LutSt) -> LutHit:
  LutSt{_, +is_xmm, +idx, +dst, copy, +gtmp, join, +elbl, +k, vals_rev, xs} = st
  match xs:
    case Con{XLabel{+lid}, t}:
      base_ok = Bool.pick(Bool, is_xmm, Bool.and(U32.is_zero(gtmp), U32.is_ne(idx, 0)), Bool.and(U32.is_ne(dst, idx), U32.is_ne(dst, 4)))
      ok = Bool.and(Bool.and(U32.is_ge(k, 5), U32.is_eq(lid, elbl)), Bool.and(U32.is_ne(idx, 4), base_ok))
      LutHit{ok, is_xmm, idx, dst, copy, gtmp, join, elbl, k, b5k_list_rev(U32, vals_rev), Con{XLabel{lid}, t}}
    case rest: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, rest}
def elf_lut_step(ok_hdr: Bool, arm: LutArm, st: LutSt, nlbl: U32) -> LutSt:
  match ok_hdr arm st:
    case True{} LutArm{aok, axmm, av, ad, ac, +ag, aj, arest} LutSt{_, +is_xmm, +idx, +dst, +copy, +gtmp, +join, elbl, +k, +vals_rev, orig}:
      g_ok = Bool.or(U32.is_eq(ag, 16), Bool.or(U32.is_eq(gtmp, 16), U32.is_eq(ag, gtmp)))
      m_ok = Bool.and(Bool.and(aok, U32.is_eq(Bool.to_u32(axmm), Bool.to_u32(is_xmm))), Bool.and(Bool.and(U32.is_eq(ad, dst), U32.is_eq(ac, copy)), Bool.and(U32.is_eq(aj, join), g_ok)))
      Bool.pick(LutSt, m_ok, LutSt{False{}, is_xmm, idx, dst, copy, Bool.pick(U32, U32.is_eq(gtmp, 16), ag, gtmp), join, nlbl, U32.add(k, 1), Con{av, vals_rev}, arest}, LutSt{True{}, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals_rev, orig})
    case _ _ LutSt{_, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals_rev, orig}:
      LutSt{True{}, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals_rev, orig}
def elf_lut_chain(fuel: Nat, +lcnt: RaVec<U32>, st: LutSt) -> LutHit:
  match fuel st:
    case 1n+p LutSt{False{}, is_xmm, +idx, dst, copy, gtmp, join, +elbl, +k, vals, Con{XLabel{+lid}, Con{XCmpRI{+r, +kv}, Con{XJcc{5, +nlbl}, +body}}}}:
      ok_h = Bool.and(Bool.and(U32.is_eq(lid, elbl), peep_lbl_once(lid, lcnt)), Bool.and(U32.is_eq(r, idx), U32.is_eq(kv, k)))
      elf_lut_chain(p, lcnt, elf_lut_step(ok_h, elf_lut_arm(body), LutSt{False{}, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals, Con{XLabel{lid}, Con{XCmpRI{r, kv}, Con{XJcc{5, nlbl}, body}}}}, nlbl))
    case _ st0: elf_lut_fin(st0)
def elf_lut_start_go(arm: LutArm, lcnt: RaVec<U32>, idx: U32, nlbl: U32) -> LutHit:
  match arm:
    case LutArm{True{}, is_xmm, v0, dst, copy, gtmp, join, rest}:
      elf_lut_chain(256n, lcnt, LutSt{False{}, is_xmm, idx, dst, copy, gtmp, join, nlbl, 1, Con{v0, Nil{}}, rest})
    case _: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, Nil{}}
def elf_lut_start(ok: Bool, lcnt: RaVec<U32>, idx: U32, nlbl: U32, body: List<&2, X64Inst>) -> LutHit:
  match ok:
    case False{}: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, Nil{}}
    case True{}: elf_lut_start_go(elf_lut_arm(body), lcnt, idx, nlbl)
def elf_lut_len(+is_xmm: Bool, +idx: U32, +dst: U32, +copy: U32, +gtmp: U32, n: U32) -> U32:
  +base = Bool.pick(U32, is_xmm, gtmp, dst)
  md = Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0)
  rx = Bool.or(U32.is_ge(dst, 8), Bool.or(U32.is_ge(idx, 8), U32.is_ge(base, 8)))
  l_ld = U32.add(U32.add(Bool.pick(U32, is_xmm, 5, 3), Bool.pick(U32, rx, 1, 0)), md)
  l_cp = Bool.pick(U32, U32.is_eq(copy, dst), 0, Bool.pick(U32, is_xmm, U32.add(3, Bool.pick(U32, elf_is_hi(copy, dst), 1, 0)), 3))
  U32.add(U32.add(Bool.pick(U32, elf_is_simm8(n), 4, 7), 18), U32.add(l_ld, l_cp))
type P1St is Data:
  P1St{xs: List<&2, X64Inst>, skip: Nat, off: U32, lbls: RaVec<U32>}
def elf_drop2(xs: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match xs:
    case Con{_, Con{_, r}}: r
    case r: r
def elf_alu_lut_go(lcnt: RaVec<U32>, d: U32, xs: List<&2, X64Inst>) -> LutHit:
  match xs:
    case Con{XJcc{5, nlbl}, body}: elf_lut_start(True{}, lcnt, d, nlbl, body)
    case _: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, Nil{}}
def elf_alu_lut(op: U32, d: U32, ok32: Bool, lcnt: RaVec<U32>, +t: List<&2, X64Inst>) -> LutHit:
  match op:
    case 1: elf_alu_lut_go(lcnt, d, Bool.pick(List<&2, X64Inst>, ok32, elf_drop2(t), t))
    case _: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, Nil{}}
def elf_p1_lut(lh: LutHit, off_hit: U32, off_miss: U32, skip_miss: Nat, t: List<&2, X64Inst>, lbls: RaVec<U32>) -> P1St:
  match lh:
    case LutHit{True{}, is_xmm, idx, dst, copy, gtmp, _, _, n, _, rest}:
      P1St{rest, 0n, U32.add(off_hit, elf_lut_len(is_xmm, idx, dst, copy, gtmp, n)), lbls}
    case LutHit{False{}, _, _, _, _, _, _, _, _, _, _}:
      P1St{t, skip_miss, off_miss, lbls}
def elf_pass1_go(fuel: Nat, +lcnt: RaVec<U32>, st: P1St) -> RaVec<U32>:
  match fuel st:
    case 0n P1St{_, _, _, lbls}: lbls
    case _ P1St{Nil{}, _, _, lbls}: lbls
    case 1n+p P1St{Con{_, t}, 1n+sk, off, lbls}: elf_pass1_go(p, lcnt, P1St{t, sk, off, lbls})
    case 1n+p P1St{Con{XLabel{id}, t}, _, +off, lbls}: elf_pass1_go(p, lcnt, P1St{t, 0n, off, ra_vec_set(U32, 9n, elf_lbl_key(id), off, lbls)})
    case 1n+p P1St{Con{XTestRR{+a, +b}, Con{XJcc{5, +nlbl}, +body}}, _, +off, lbls}:
      elf_pass1_go(p, lcnt, elf_p1_lut(elf_lut_start(U32.is_eq(a, b), lcnt, a, nlbl, body), off, U32.add(off, 3), 0n, Con{XJcc{5, nlbl}, body}, lbls))
    case 1n+p P1St{Con{XCmpRI{+a, 0}, Con{XJcc{5, +nlbl}, +body}}, _, +off, lbls}:
      elf_pass1_go(p, lcnt, elf_p1_lut(elf_lut_start(True{}, lcnt, a, nlbl, body), off, U32.add(off, elf_inst_len(XCmpRI{a, 0})), 0n, Con{XJcc{5, nlbl}, body}, lbls))
    case 1n+p P1St{Con{XLoad{+d, +base, +disp}, +t}, _, off, lbls}:
      +lc = elf_load_code(d, base, disp, t)
      +k = U32.and(lc, 15)
      +ex = elf_mem_extra(base, disp)
      +li = Bool.pick(U32, elf_is_simm8(elf_head_ri_imm(t)), 1, 4)
      dl = Bool.pick(U32, U32.is_eq(k, 2), U32.add(U32.add(2, Bool.pick(U32, elf_is_hi(U32.shrn(lc, 12n), base), 1, 0)), ex), Bool.pick(U32, U32.is_eq(k, 3), U32.add(U32.add(3, ex), li), Bool.pick(U32, U32.is_eq(k, 4), U32.add(U32.add(U32.add(2, Bool.pick(U32, U32.is_ge(base, 8), 1, 0)), ex), li), U32.add(3, ex))))
      elf_pass1_go(p, lcnt, P1St{t, elf_load_skip(k), U32.add(off, dl), lbls})
    case 1n+p P1St{Con{XAluRR{+op, +d, +s}, +t}, _, off, lbls}:
      +ok = elf_head_is_mask32(t, d)
      dl = Bool.pick(U32, ok, elf_alu_rr32_len(op, d, s), Bool.pick(U32, Bool.and(U32.is_eq(op, 7), Bool.and(U32.is_eq(d, s), U32.is_lt(d, 8))), 2, 3))
      elf_pass1_go(p, lcnt, P1St{t, Bool.pick(Nat, ok, 2n, 0n), U32.add(off, dl), lbls})
    case 1n+p P1St{Con{XAluRI{+op, +d, +imm}, +t}, _, off, lbls}:
      +ok = elf_head_is_mask32(t, d)
      +no = U32.add(off, Bool.pick(U32, ok, elf_alu_ri32_len(d, imm), Bool.pick(U32, elf_is_simm8(imm), 4, 7)))
      elf_pass1_go(p, lcnt, elf_p1_lut(elf_alu_lut(op, d, ok, lcnt, t), no, no, Bool.pick(Nat, ok, 2n, 0n), t, lbls))
    case 1n+p P1St{Con{XMul{+d, +s}, +t}, _, off, lbls}:
      +ok = elf_head_is_mask32(t, d)
      elf_pass1_go(p, lcnt, P1St{t, Bool.pick(Nat, ok, 2n, 0n), U32.add(off, elf_mul_len(ok, d, s)), lbls})
    case 1n+p P1St{Con{XShift{8, +d, +amt, False{}}, +t}, _, off, lbls}:
      +sc = elf_shl3_code(Bool.and(U32.is_eq(amt, 3), U32.is_ne(d, 4)), d, t)
      +k = U32.and(U32.shrn(sc, 4n), 7)
      +ok_shl = Bool.and(U32.is_zero(sc), Bool.and(U32.is_lt(amt, 32), elf_head_is_mask32(t, d)))
      +ok_mov = Bool.and(U32.is_eq(amt, 32), elf_head_is_shr32(t, d))
      dl = Bool.pick(U32, U32.is_ne(sc, 0), elf_sib8_len(U32.and(sc, 15)), Bool.pick(U32, ok_shl, elf_shl32_len(d, amt), Bool.pick(U32, ok_mov, elf_mov32_len(d), Bool.pick(U32, U32.is_eq(amt, 1), 3, 4))))
      elf_pass1_go(p, lcnt, P1St{t, elf_shl_skip(sc, k, ok_shl, ok_mov), U32.add(off, dl), lbls})
    case 1n+p P1St{Con{inst, t}, _, off, lbls}: elf_pass1_go(p, lcnt, P1St{t, 0n, U32.add(off, elf_inst_len(inst)), lbls})
type TextAcc is Data:
  TextAcc{buf: ByteBuf, rels: List<&2, ElfReloc>}
def e_b1(r: List<&2, U32>, a: U32) -> List<&2, U32>: Con{U32.and(a, 255), r}
def e_b2(r: List<&2, U32>, a: U32, b: U32) -> List<&2, U32>: Con{U32.and(b, 255), Con{U32.and(a, 255), r}}
def e_b3(r: List<&2, U32>, a: U32, b: U32, c: U32) -> List<&2, U32>: Con{U32.and(c, 255), Con{U32.and(b, 255), Con{U32.and(a, 255), r}}}
def e_b4(r: List<&2, U32>, a: U32, b: U32, c: U32, d: U32) -> List<&2, U32>: Con{U32.and(d, 255), Con{U32.and(c, 255), Con{U32.and(b, 255), Con{U32.and(a, 255), r}}}}
def e_u32(r: List<&2, U32>, +v: U32) -> List<&2, U32>: Con{U32.and(U32.shrn(v, 24n), 255), Con{U32.and(U32.shrn(v, 16n), 255), Con{U32.and(U32.shrn(v, 8n), 255), Con{U32.and(v, 255), r}}}}
def elf_opt_b(cond: Bool, b: U32, r: List<&2, U32>) -> List<&2, U32>:
  match cond:
    case True{}: Con{b, r}
    case False{}: r
def elf_emit_disp(md: U32, disp: U32, r: List<&2, U32>) -> List<&2, U32>:
  match md:
    case 0: r
    case 1: e_b1(r, disp)
    case _: e_u32(r, disp)
def elf_emit_mem_w(+w: U32, opc: U32, +reg: U32, +base: U32, +disp: U32, off: U32, r: List<&2, U32>) -> ByteBuf:
  +md = elf_mem_mod(base, disp)
  +sp = U32.is_eq(U32.and(base, 7), 4)
  +rx = Bool.or(U32.is_ne(w, 0), elf_is_hi(reg, base))
  dl = U32.add(U32.add(2, Bool.pick(U32, rx, 1, 0)), U32.add(Bool.pick(U32, sp, 1, 0), elf_disp_len(md)))
  ByteBuf{U32.add(off, dl), elf_emit_disp(md, disp, elf_opt_b(sp, 36, e_b2(elf_opt_b(rx, elf_rex(w, reg, 0, base), r), opc, elf_modrm(md, reg, base))))}
def elf_emit_imm_bb(i8: Bool, imm: U32, b: ByteBuf) -> ByteBuf:
  match i8 b:
    case True{} ByteBuf{off, r}: ByteBuf{U32.add(off, 1), e_b1(r, imm)}
    case False{} ByteBuf{off, r}: ByteBuf{U32.add(off, 4), e_u32(r, imm)}
def elf_emit_xmm_mem(pfx: U32, opc: U32, +reg: U32, +base: U32, +disp: U32, r: List<&2, U32>) -> List<&2, U32>:
  +md = elf_mem_mod(base, disp)
  r0 = elf_opt_b(elf_is_hi(reg, base), elf_rex(0, reg, 0, base), Con{pfx, r})
  elf_emit_disp(md, disp, elf_opt_b(U32.is_eq(U32.and(base, 7), 4), 36, e_b3(r0, 15, opc, elf_modrm(md, reg, base))))
def elf_xmm_rr_opc(+op: U32) -> U32:
  o4 = Bool.pick(U32, U32.is_eq(op, 4), 81, Bool.pick(U32, U32.is_eq(op, 5), 46, Bool.pick(U32, U32.is_eq(op, 6), 87, 40)))
  Bool.pick(U32, U32.is_eq(op, 0), 88, Bool.pick(U32, U32.is_eq(op, 1), 92, Bool.pick(U32, U32.is_eq(op, 2), 89, Bool.pick(U32, U32.is_eq(op, 3), 94, o4))))
def elf_emit_xmm_rr(+op: U32, +dst: U32, +src: U32, r: List<&2, U32>) -> List<&2, U32>:
  r0 = elf_opt_b(elf_is_hi(dst, src), elf_rex(0, dst, 0, src), elf_opt_b(U32.is_lt(op, 5), 243, r))
  e_b3(r0, 15, elf_xmm_rr_opc(op), elf_modrm(3, dst, src))
def elf_emit_cvt(+op: U32, +dst: U32, +src: U32, r: List<&2, U32>) -> List<&2, U32>:
  +is_m = U32.is_ge(op, 2)
  +is_st = U32.is_eq(op, 3)
  +w = Bool.pick(U32, is_m, 0, 1)
  +reg = Bool.pick(U32, is_st, src, dst)
  +rm = Bool.pick(U32, is_st, dst, src)
  opc = Bool.pick(U32, U32.is_eq(op, 0), 42, Bool.pick(U32, U32.is_eq(op, 1), 44, Bool.pick(U32, U32.is_eq(op, 2), 110, 126)))
  r0 = elf_opt_b(Bool.or(U32.is_ne(w, 0), elf_is_hi(reg, rm)), elf_rex(w, reg, 0, rm), Con{Bool.pick(U32, is_m, 102, 243), r})
  e_b3(r0, 15, opc, elf_modrm(3, reg, rm))
def elf_emit_shl32_imm(is_one: Bool, sub: U32, +dst: U32, amt: U32, r: List<&2, U32>) -> List<&2, U32>:
  match is_one:
    case True{}: e_b2(r, 209, elf_modrm(3, sub, dst))
    case False{}: e_b3(r, 193, elf_modrm(3, sub, dst), amt)
def elf_emit_shift(by_cl: Bool, sub: U32, +dst: U32, +amt: U32, r: List<&2, U32>) -> List<&2, U32>:
  match by_cl:
    case True{}: e_b3(r, elf_rex(1, 0, 0, dst), 211, elf_modrm(3, sub, dst))
    case False{}: elf_emit_shl32_imm(U32.is_eq(amt, 1), sub, dst, amt, Con{elf_rex(1, 0, 0, dst), r})
def elf_emit_alu_rr(is_zero: Bool, op: U32, +dst: U32, +src: U32, r: List<&2, U32>) -> List<&2, U32>:
  match is_zero:
    case True{}: e_b2(elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, dst, 0, dst), r), 49, elf_modrm(3, dst, dst))
    case False{}: e_b3(r, elf_rex(1, src, 0, dst), elf_alu_rr_op(op), elf_modrm(3, src, dst))
def elf_emit_imm_rm(is_i8: Bool, sub: U32, dst: U32, imm: U32, r: List<&2, U32>) -> List<&2, U32>:
  match is_i8:
    case True{}: e_b3(r, 131, elf_modrm(3, sub, dst), imm)
    case False{}: e_u32(e_b2(r, 129, elf_modrm(3, sub, dst)), imm)
def elf_emit_sib8(opc: U32, +dst: U32, +base: U32, +idx: U32, r: List<&2, U32>) -> List<&2, U32>:
  +md = Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0)
  sib = U32.or(192, U32.or(U32.shln(U32.and(idx, 7), 3n), U32.and(base, 7)))
  elf_emit_disp(md, 0, e_b4(r, elf_rex(1, dst, idx, base), opc, elf_modrm(md, dst, 4), sib))
def elf_em_rr(ok: Bool, +op: U32, +d: U32, +s: U32, b: ByteBuf) -> ByteBuf:
  match ok b:
    case True{} ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_alu_rr32_len(op, d, s)), e_b2(elf_opt_b(elf_is_hi(d, s), elf_rex(0, s, 0, d), rev), elf_alu_rr_op(op), elf_modrm(3, s, d))}
    case False{} ByteBuf{off, rev}:
      +is_z = Bool.and(U32.is_eq(op, 7), U32.is_eq(d, s))
      ByteBuf{U32.add(off, Bool.pick(U32, Bool.and(is_z, U32.is_lt(d, 8)), 2, 3)), elf_emit_alu_rr(is_z, op, d, s, rev)}
def elf_em_ri(+ok: Bool, op: U32, +d: U32, +imm: U32, b: ByteBuf) -> ByteBuf:
  ByteBuf{off, rev} = b
  +rx = Bool.or(Bool.not(ok), U32.is_ge(d, 8))
  dl = U32.add(Bool.pick(U32, rx, 1, 0), Bool.pick(U32, elf_is_simm8(imm), 3, 6))
  ByteBuf{U32.add(off, dl), elf_emit_imm_rm(elf_is_simm8(imm), elf_alu_ri_sub(op), d, imm, elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), 0, 0, d), rev))}
def elf_em_mul_go(is_lea: Bool, +ok: Bool, +d: U32, +s: U32, b: ByteBuf) -> ByteBuf:
  match is_lea b:
    case True{} ByteBuf{off, rev}:
      +md = Bool.pick(U32, U32.is_eq(U32.and(d, 7), 5), 1, 0)
      sib = U32.or(U32.shln(U32.sub(s, 16), 6n), U32.or(U32.shln(U32.and(d, 7), 3n), U32.and(d, 7)))
      +rx = Bool.or(Bool.not(ok), U32.is_ge(d, 8))
      ByteBuf{U32.add(off, U32.add(3, U32.add(Bool.pick(U32, rx, 1, 0), md))), elf_emit_disp(md, 0, e_b3(elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), d, d, d), rev), 141, elf_modrm(md, d, 4), sib))}
    case False{} ByteBuf{off, rev}:
      +rx = Bool.or(Bool.not(ok), elf_is_hi(d, s))
      ByteBuf{U32.add(off, Bool.pick(U32, rx, 4, 3)), e_b3(elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), d, 0, s), rev), 15, 175, elf_modrm(3, d, s))}
def elf_em_shl(k: U32, +base: U32, val: U32, ok_shl: Bool, ok_mov: Bool, +d: U32, +amt: U32, b: ByteBuf) -> ByteBuf:
  match k ok_shl ok_mov b:
    case 1 _ _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_sib8_len(base)), elf_emit_sib8(139, d, base, d, rev)}
    case 2 _ _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_sib8_len(base)), elf_emit_sib8(141, d, base, d, rev)}
    case 3 _ _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_sib8_len(base)), elf_emit_sib8(141, base, base, d, rev)}
    case 4 _ _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_sib8_len(base)), elf_emit_sib8(137, val, base, d, rev)}
    case _ True{} _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_shl32_len(d, amt)), elf_emit_shl32_imm(U32.is_eq(amt, 1), 4, d, amt, elf_opt_b(U32.is_ge(d, 8), elf_rex(0, 0, 0, d), rev))}
    case _ False{} True{} ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_mov32_len(d)), e_b2(elf_opt_b(U32.is_ge(d, 8), elf_rex(0, d, 0, d), rev), 137, elf_modrm(3, d, d))}
    case _ False{} False{} ByteBuf{off, rev}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_eq(amt, 1), 3, 4)), elf_emit_shift(False{}, 4, d, amt, rev)}
def elf_em_load(k: U32, opc: U32, rg: U32, d: U32, base: U32, disp: U32, +imm: U32, b: ByteBuf) -> ByteBuf:
  match k b:
    case 1 ByteBuf{off, rev}: elf_emit_mem_w(1, opc, rg, base, disp, off, rev)
    case 2 ByteBuf{off, rev}: elf_emit_mem_w(0, opc, rg, base, disp, off, rev)
    case 3 ByteBuf{off, rev}: elf_emit_imm_bb(elf_is_simm8(imm), imm, elf_emit_mem_w(1, Bool.pick(U32, elf_is_simm8(imm), 131, 129), opc, base, disp, off, rev))
    case 4 ByteBuf{off, rev}: elf_emit_imm_bb(elf_is_simm8(imm), imm, elf_emit_mem_w(0, Bool.pick(U32, elf_is_simm8(imm), 131, 129), opc, base, disp, off, rev))
    case _ ByteBuf{off, rev}: elf_emit_mem_w(1, 139, d, base, disp, off, rev)
def elf_emit_inst_bytes_go(inst: X64Inst, +off: U32, rev: List<&2, U32>) -> ByteBuf:
  match inst:
    case XMovRR{+dst, +src}: ByteBuf{U32.add(off, 3), e_b3(rev, elf_rex(1, src, 0, dst), 137, elf_modrm(3, src, dst))}
    case XMovRI32{+dst, imm}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_lt(dst, 8), 5, 6)), e_u32(e_b1(elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, 0, 0, dst), rev), U32.add(184, U32.and(dst, 7))), imm)}
    case XMovRI64{+dst, lo, hi}: ByteBuf{U32.add(off, 10), e_u32(e_u32(e_b2(rev, elf_rex(1, 0, 0, dst), U32.add(184, U32.and(dst, 7))), lo), hi)}
    case XStore{base, disp, src}: elf_emit_mem_w(1, 137, src, base, disp, off, rev)
    case XShift{10, +dst, +amt, False{}}: ByteBuf{U32.add(off, elf_shl32_len(dst, amt)), elf_emit_shl32_imm(U32.is_eq(amt, 1), 7, dst, amt, elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, 0, 0, dst), rev))}
    case XShift{op, dst, +amt, +by_cl}: ByteBuf{U32.add(off, Bool.pick(U32, Bool.or(by_cl, U32.is_eq(amt, 1)), 3, 4)), elf_emit_shift(by_cl, elf_shift_sub(op), dst, amt, rev)}
    case XDiv{+src, is_signed}: ByteBuf{U32.add(off, 3), e_b3(rev, elf_rex(1, 0, 0, src), 247, elf_modrm(3, Bool.pick(U32, is_signed, 7, 6), src))}
    case XCmpRR{+lhs, +rhs}: ByteBuf{U32.add(off, 3), e_b3(rev, elf_rex(1, rhs, 0, lhs), 57, elf_modrm(3, rhs, lhs))}
    case XCmpRI{+lhs, +imm}: ByteBuf{U32.add(off, elf_alu_ri32_len(lhs, imm)), elf_emit_imm_rm(elf_is_simm8(imm), 7, lhs, imm, elf_opt_b(U32.is_ge(lhs, 8), elf_rex(0, 0, 0, lhs), rev))}
    case XTestRR{+lhs, +rhs}: ByteBuf{U32.add(off, 3), e_b3(rev, elf_rex(1, rhs, 0, lhs), 133, elf_modrm(3, rhs, lhs))}
    case XSetcc{cc, +dst}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_ge(dst, 4), 4, 3)), e_b3(elf_opt_b(U32.is_ge(dst, 4), elf_rex(0, 0, 0, dst), rev), 15, U32.add(144, U32.and(cc, 15)), elf_modrm(3, 0, dst))}
    case XCmov{cc, +dst, +src}: ByteBuf{U32.add(off, 4), e_b4(rev, elf_rex(1, dst, 0, src), 15, U32.add(64, U32.and(cc, 15)), elf_modrm(3, dst, src))}
    case XPush{+reg}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_lt(reg, 8), 1, 2)), e_b1(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), U32.add(80, U32.and(reg, 7)))}
    case XPop{+reg}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_lt(reg, 8), 1, 2)), e_b1(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), U32.add(88, U32.and(reg, 7)))}
    case XSubRsp{imm}: elf_em_ri(False{}, 1, 4, imm, ByteBuf{off, rev})
    case XAddRsp{imm}: elf_em_ri(False{}, 0, 4, imm, ByteBuf{off, rev})
    case XCallReg{+reg}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_lt(reg, 8), 2, 3)), e_b2(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), 255, elf_modrm(3, 2, reg))}
    case XRet{}: ByteBuf{U32.add(off, 1), Con{195, rev}}
    case XXmmRR{+op, +dst, +src}: ByteBuf{U32.add(off, U32.add(3, U32.add(Bool.pick(U32, U32.is_ge(op, 5), 0, 1), Bool.pick(U32, elf_is_hi(dst, src), 1, 0)))), elf_emit_xmm_rr(op, dst, src, rev)}
    case XXmmLoad{+dst, +base, +disp}: ByteBuf{U32.add(off, U32.add(U32.add(4, Bool.pick(U32, elf_is_hi(dst, base), 1, 0)), elf_mem_extra(base, disp))), elf_emit_xmm_mem(243, 16, dst, base, disp, rev)}
    case XXmmStore{+base, +disp, +src}: ByteBuf{U32.add(off, U32.add(U32.add(4, Bool.pick(U32, elf_is_hi(src, base), 1, 0)), elf_mem_extra(base, disp))), elf_emit_xmm_mem(102, 214, src, base, disp, rev)}
    case XCvt{+op, +dst, +src}: ByteBuf{U32.add(off, Bool.pick(U32, Bool.or(U32.is_lt(op, 2), elf_is_hi(dst, src)), 5, 4)), elf_emit_cvt(op, dst, src, rev)}
    case _: ByteBuf{off, rev}
def elf_emit_lut_ld_go(is_xmm: Bool, +md: U32, +dst: U32, +base: U32, +idx: U32, sib: U32, rx: Bool, rev: List<&2, U32>) -> List<&2, U32>:
  match is_xmm:
    case False{}: elf_emit_disp(md, 0, e_b3(elf_opt_b(rx, elf_rex(0, dst, idx, base), rev), 139, elf_modrm(md, dst, 4), sib))
    case True{}: elf_emit_disp(md, 0, e_b4(elf_opt_b(rx, elf_rex(0, dst, idx, base), Con{243, rev}), 15, 16, elf_modrm(md, dst, 4), sib))
def elf_emit_lut_ld(is_xmm: Bool, +dst: U32, +base: U32, +idx: U32, rev: List<&2, U32>) -> List<&2, U32>: elf_emit_lut_ld_go(is_xmm, Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0), dst, base, idx, U32.or(128, U32.or(U32.shln(U32.and(idx, 7), 3n), U32.and(base, 7))), Bool.or(U32.is_ge(dst, 8), Bool.or(U32.is_ge(idx, 8), U32.is_ge(base, 8))), rev)
def elf_emit_lut_cp(same: Bool, is_xmm: Bool, +dst: U32, +copy: U32, rev: List<&2, U32>) -> List<&2, U32>:
  match same is_xmm:
    case True{} _: rev
    case False{} False{}: e_b3(rev, elf_rex(1, dst, 0, copy), 137, elf_modrm(3, dst, copy))
    case False{} True{}: elf_emit_xmm_rr(7, copy, dst, rev)
def elf_emit_u32_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf:
  match xs:
    case Nil{}: b
    case Con{x, t}: elf_emit_u32_arr(t, bb_emit_u32(b, x))
type EmitSt is Data:
  EmitSt{xs: List<&2, X64Inst>, skip: Nat, buf: ByteBuf, rels: List<&2, ElfReloc>, luts: ByteBuf}
def elf_emit_lut(lh: LutHit, +lbls: RaVec<U32>, orig: X64Inst, t: List<&2, X64Inst>, b: ByteBuf, rels: List<&2, ElfReloc>, +luts: ByteBuf) -> EmitSt:
  match lh b:
    case LutHit{True{}, +is_xmm, +idx, +dst, +copy, +gtmp, join, def_lbl, +n, vals, rest} ByteBuf{+off, rev}:
      +base = Bool.pick(U32, is_xmm, gtmp, dst)
      +i8 = elf_is_simm8(n)
      r1 = elf_emit_imm_rm(i8, 7, idx, n, Con{elf_rex(1, 0, 0, idx), rev})
      +o1 = U32.add(off, Bool.pick(U32, i8, 4, 7))
      +o2 = U32.add(o1, 6)
      r2 = e_u32(e_b2(r1, 15, 131), U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(def_lbl), lbls), o2))
      r3 = e_u32(e_b3(r2, elf_rex(1, base, 0, 0), 141, elf_modrm(0, base, 5)), 0)
      r4 = elf_emit_lut_cp(U32.is_eq(copy, dst), is_xmm, dst, copy, elf_emit_lut_ld(is_xmm, dst, base, idx, r3))
      +o_end = U32.add(off, elf_lut_len(is_xmm, idx, dst, copy, gtmp, n))
      r5 = e_u32(Con{233, r4}, U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(join), lbls), o_end))
      EmitSt{rest, 0n, ByteBuf{o_end, r5}, Con{ElfReloc{U32.add(o2, 3), ".rodata", 2, U32.sub(bb_len(luts), 4)}, rels}, elf_emit_u32_arr(vals, luts)}
    case LutHit{False{}, _, _, _, _, _, _, _, _, _, _} ByteBuf{off, rev}:
      EmitSt{t, 0n, elf_emit_inst_bytes_go(orig, off, rev), rels, luts}
def elf_emit_alu_lut(lh: LutHit, +lbls: RaVec<U32>, ok32: Bool, t: List<&2, X64Inst>, b1: ByteBuf, rels: List<&2, ElfReloc>, luts: ByteBuf) -> EmitSt:
  match lh:
    case LutHit{True{}, is_xmm, idx, dst, copy, gtmp, join, def_lbl, n, vals, rest}:
      elf_emit_lut(LutHit{True{}, is_xmm, idx, dst, copy, gtmp, join, def_lbl, n, vals, rest}, lbls, XRet{}, t, b1, rels, luts)
    case LutHit{False{}, _, _, _, _, _, _, _, _, _, _}:
      EmitSt{t, Bool.pick(Nat, ok32, 2n, 0n), b1, rels, luts}
def elf_emit_insts_go(fuel: Nat, +lcnt: RaVec<U32>, +lbls: RaVec<U32>, st: EmitSt) -> ByteBuf & (List<&2, ElfReloc> & ByteBuf):
  match fuel st:
    case 0n EmitSt{_, _, b, rels, luts}: (b, (rels, luts))
    case _ EmitSt{Nil{}, _, b, rels, luts}: (b, (rels, luts))
    case 1n+p EmitSt{Con{_, t}, 1n+sk, b, rels, luts}: elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, sk, b, rels, luts})
    case 1n+p EmitSt{Con{XTestRR{+a, +b0}, Con{XJcc{5, +nlbl}, +body}}, _, b, rels, luts}:
      elf_emit_insts_go(p, lcnt, lbls, elf_emit_lut(elf_lut_start(U32.is_eq(a, b0), lcnt, a, nlbl, body), lbls, XTestRR{a, b0}, Con{XJcc{5, nlbl}, body}, b, rels, luts))
    case 1n+p EmitSt{Con{XCmpRI{+a, 0}, Con{XJcc{5, +nlbl}, +body}}, _, b, rels, luts}:
      elf_emit_insts_go(p, lcnt, lbls, elf_emit_lut(elf_lut_start(True{}, lcnt, a, nlbl, body), lbls, XCmpRI{a, 0}, Con{XJcc{5, nlbl}, body}, b, rels, luts))
    case 1n+p EmitSt{Con{XLoad{+d, +base, +disp}, +t}, _, b, rels, luts}:
      +lc = elf_load_code(d, base, disp, t)
      +k = U32.and(lc, 15)
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, elf_load_skip(k), elf_em_load(k, U32.and(U32.shrn(lc, 4n), 255), U32.shrn(lc, 12n), d, base, disp, elf_head_ri_imm(t), b), rels, luts})
    case 1n+p EmitSt{Con{XAluRR{op, +d, s}, +t}, _, b, rels, luts}:
      +ok = elf_head_is_mask32(t, d)
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, Bool.pick(Nat, ok, 2n, 0n), elf_em_rr(ok, op, d, s, b), rels, luts})
    case 1n+p EmitSt{Con{XAluRI{+op, +d, +imm}, +t}, _, b, rels, luts}:
      +ok = elf_head_is_mask32(t, d)
      elf_emit_insts_go(p, lcnt, lbls, elf_emit_alu_lut(elf_alu_lut(op, d, ok, lcnt, t), lbls, ok, t, elf_em_ri(ok, op, d, imm, b), rels, luts))
    case 1n+p EmitSt{Con{XMul{+d, +s}, +t}, _, b, rels, luts}:
      +ok = elf_head_is_mask32(t, d)
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, Bool.pick(Nat, ok, 2n, 0n), elf_em_mul_go(U32.is_ge(s, 17), ok, d, s, b), rels, luts})
    case 1n+p EmitSt{Con{XShift{8, +d, +amt, False{}}, +t}, _, b, rels, luts}:
      +sc = elf_shl3_code(Bool.and(U32.is_eq(amt, 3), U32.is_ne(d, 4)), d, t)
      +k = U32.and(U32.shrn(sc, 4n), 7)
      +ok_shl = Bool.and(U32.is_zero(sc), Bool.and(U32.is_lt(amt, 32), elf_head_is_mask32(t, d)))
      +ok_mov = Bool.and(U32.is_eq(amt, 32), elf_head_is_shr32(t, d))
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, elf_shl_skip(sc, k, ok_shl, ok_mov), elf_em_shl(k, U32.and(sc, 15), U32.shrn(sc, 8n), ok_shl, ok_mov, d, amt, b), rels, luts})
    case 1n+p EmitSt{Con{XLeaRip{+dst, sym}, t}, _, ByteBuf{+off, rev}, rels, luts}:
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 7), e_u32(e_b3(rev, elf_rex(1, dst, 0, 0), 141, elf_modrm(0, dst, 5)), 0)}, Con{ElfReloc{U32.add(off, 3), sym, 2, U32.sub(0, 4)}, rels}, luts})
    case 1n+p EmitSt{Con{XJmp{target}, t}, _, ByteBuf{off, rev}, rels, luts}:
      +n_off = U32.add(off, 5)
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, 0n, ByteBuf{n_off, e_u32(Con{233, rev}, U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls), n_off))}, rels, luts})
    case 1n+p EmitSt{Con{XJcc{cc, target}, t}, _, ByteBuf{off, rev}, rels, luts}:
      +n_off = U32.add(off, 6)
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, 0n, ByteBuf{n_off, e_u32(e_b2(rev, 15, U32.add(128, U32.and(cc, 15))), U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls), n_off))}, rels, luts})
    case 1n+p EmitSt{Con{XCallSym{sym}, t}, _, ByteBuf{+off, rev}, rels, luts}:
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 5), e_u32(Con{232, rev}, 0)}, Con{ElfReloc{U32.add(off, 1), sym, 4, U32.sub(0, 4)}, rels}, luts})
    case 1n+p EmitSt{Con{inst, t}, _, ByteBuf{off, rev}, rels, luts}:
      elf_emit_insts_go(p, lcnt, lbls, EmitSt{t, 0n, elf_emit_inst_bytes_go(inst, off, rev), rels, luts})
# ELF Symbol Table & Alignment Helpers
type ElfSym is Data:
  ElfSym{name: String, info: U32, shndx: U32, value: U32, size: U32}
type TextRes is Data:
  TextRes{buf: ByteBuf, rels: List<&2, ElfReloc>, lsyms: List<&2, ElfSym>, gsyms: List<&2, ElfSym>, luts: ByteBuf}
def elf_pad_to(+b: ByteBuf, +align: U32) -> ByteBuf:
  +rem = U32.mod(bb_len(b), align)
  bb_emit_zeros(b, Bool.pick(U32, U32.is_zero(rem), 0, U32.sub(align, rem)))
def elf_opt_lcnt(big: Bool, insts: List<&2, X64Inst>) -> RaVec<U32>:
  match big:
    case True{}: peep_count_lbls(insts, RVEmpty{})
    case False{}: RVEmpty{}
def elf_encode_one(+is_glob: Bool, name: String, +start: U32, ea: ByteBuf & (List<&2, ElfReloc> & ByteBuf), +ls: List<&2, ElfSym>, +gs: List<&2, ElfSym>) -> TextRes:
  (+b2, (rels2, luts2)) = ea
  +sym: ElfSym = ElfSym{name, Bool.pick(U32, is_glob, 18, 2), 1, start, U32.sub(bb_len(b2), start)}
  TextRes{b2, rels2, Bool.pick(List<&2, ElfSym>, is_glob, ls, Con{sym, ls}), Bool.pick(List<&2, ElfSym>, is_glob, Con{sym, gs}, gs), luts2}
def elf_encode_fns_go(fns: List<&2, X64Fn>, tr: TextRes) -> TextRes:
  match fns tr:
    case Nil{} TextRes{b, rels, ls, gs, luts}: TextRes{b, b5k_list_rev(ElfReloc, rels), ls, gs, luts}
    case Con{X64Fn{name, is_glob, +insts}, t} TextRes{b0, rels0, ls, gs, luts0}:
      +b1 = elf_pad_to(b0, 16)
      +start = bb_len(b1)
      +n_insts = b5k_list_len(X64Inst, insts)
      +lcnt = elf_opt_lcnt(U32.is_ge(n_insts, 25), insts)
      +fuel = U32.to_nat(n_insts)
      lbls = elf_pass1_go(fuel, lcnt, P1St{insts, 0n, start, RVEmpty{}})
      elf_encode_fns_go(t, elf_encode_one(is_glob, name, start, elf_emit_insts_go(fuel, lcnt, lbls, EmitSt{insts, 0n, b1, rels0, luts0}), ls, gs))
# P111 Metadata & Core Constructor Normalization
def elf_core_ctors() -> List<&2, IrCtor>:
  [IrCtor{0, "SNil", 0, False{}}, IrCtor{1, "SCon", 2, False{}}, IrCtor{2, "WNil", 0, False{}}, IrCtor{3, "WCon", 2, False{}},
   IrCtor{4, "Nil", 0, False{}}, IrCtor{5, "Con", 2, False{}}, IrCtor{6, "Tuple", 2, False{}}, IrCtor{7, "Unit", 0, False{}},
   IrCtor{8, "None", 0, False{}}, IrCtor{9, "Some", 1, False{}}, IrCtor{10, "Fail", 1, False{}}, IrCtor{11, "Done", 1, False{}},
   IrCtor{12, "Emit", 1, False{}}, IrCtor{13, "Halt", 2, False{}}, IrCtor{14, "True", 0, False{}}, IrCtor{15, "False", 0, False{}},
   IrCtor{16, "LT", 0, False{}}, IrCtor{17, "EQ", 0, False{}}, IrCtor{18, "GT", 0, False{}}, IrCtor{19, "Chr", 1, False{}},
   IrCtor{20, "Zero", 0, False{}}, IrCtor{21, "Succ", 1, False{}}, IrCtor{22, "Exit", 1, False{}}, IrCtor{23, "Pair", 2, False{}},
   IrCtor{24, "Inl", 1, False{}}, IrCtor{25, "Inr", 1, False{}}]
def elf_has_ctor_name(ctors: List<&2, IrCtor>, +nm: String) -> Bool:
  match ctors:
    case Nil{}: False{}
    case Con{IrCtor{_, cname, _, _}, t}: Bool.or(b5k_str_eq(cname, nm), elf_has_ctor_name(t, nm))
type MergeAcc is Data:
  MergeAcc{next_cid: U32, acc: List<&2, IrCtor>}
def elf_merge_core_go(core: List<&2, IrCtor>, +existing: List<&2, IrCtor>, ma: MergeAcc) -> List<&2, IrCtor>:
  match core ma:
    case Nil{} MergeAcc{_, acc}: b5k_list_app(IrCtor, existing, b5k_list_rev(IrCtor, acc))
    case Con{IrCtor{_, +nm, ar, hot}, t} MergeAcc{+nc, +acc}:
      elf_merge_core_go(t, existing, Bool.pick(MergeAcc, elf_has_ctor_name(existing, nm), MergeAcc{nc, acc}, MergeAcc{U32.add(nc, 1), Con{IrCtor{nc, nm, ar, hot}, acc}}))
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
# Whole-Program Per-Constructor cid_hot Analysis (capabilities = 9)
def elf_bs_bit(k: U32) -> U32: U32.shln(1, U32.to_nat(U32.and(k, 31)))
def elf_bs_word(d: Nat, k: U32, m: RaVec<U32>) -> U32: ra_vec_get(U32, d, 0, U32.shrn(k, 5n), m)
def elf_bs_has(d: Nat, +k: U32, m: RaVec<U32>) -> Bool: U32.is_ne(U32.and(elf_bs_word(d, k, m), elf_bs_bit(k)), 0)
def elf_bs_set(d: Nat, +k: U32, w: U32, m: RaVec<U32>) -> RaVec<U32>: ra_vec_set(U32, d, U32.shrn(k, 5n), U32.or(w, elf_bs_bit(k)), m)
def elf_bs_mark_go(d: Nat, miss: Bool, m: RaVec<U32>, chg: Bool, k: U32, w: U32) -> RaVec<U32> & Bool:
  match miss:
    case True{}: (elf_bs_set(d, k, w, m), True{})
    case False{}: (m, chg)
def elf_bs_mark(+d: Nat, ra: RaVec<U32> & Bool, +k: U32) -> RaVec<U32> & Bool:
  (+m, chg) = ra
  +w = elf_bs_word(d, k, m)
  elf_bs_mark_go(d, U32.is_zero(U32.and(w, elf_bs_bit(k))), m, chg, k, w)
def elf_reach_ops(ops: List<&2, IrOp>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match ops:
    case Nil{}: ra
    case Con{ICallDirect{_, cfid, _}, t}: elf_reach_ops(t, elf_bs_mark(4n, ra, cfid))
    case Con{ICallClosure{_, cfid, _}, t}: elf_reach_ops(t, elf_bs_mark(4n, ra, cfid))
    case Con{IApply{_, _, _}, t}: elf_reach_ops(t, elf_bs_mark(4n, ra, 0))
    case Con{_, t}: elf_reach_ops(t, ra)
def elf_reach_blks(blks: List<&2, IrBlock>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match blks:
    case Nil{}: ra
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}: elf_reach_blks(t, elf_bs_mark(4n, elf_reach_ops(ops, ra), cfid))
    case Con{IrBlock{_, ops, _}, t}: elf_reach_blks(t, elf_reach_ops(ops, ra))
def elf_reach_fn_if(live: Bool, blks: List<&2, IrBlock>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match live:
    case True{}: elf_reach_blks(blks, ra)
    case False{}: ra
def elf_reach_fns(fns: List<&2, IrFn>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match fns:
    case Nil{}: ra
    case Con{IrFn{fid, _, _, _, _, _, _, blks}, t}:
      (+m, chg) = ra
      elf_reach_fns(t, elf_reach_fn_if(elf_bs_has(4n, fid, m), blks, (m, chg)))
def elf_reach_fix(fuel: Nat, +fns: List<&2, IrFn>, ra: RaVec<U32> & Bool) -> RaVec<U32>:
  match fuel:
    case 0n:
      (m, _) = ra
      m
    case 1n+p:
      (m, chg) = ra
      match chg:
        case False{}: m
        case True{}: elf_reach_fix(p, fns, elf_reach_fns(fns, (m, False{})))
def elf_compute_reach(fns: List<&2, IrFn>, main_fid: U32, main_pure: Bool) -> RaVec<U32>:
  +m0 = elf_bs_set(4n, main_fid, 0, RVEmpty{})
  elf_reach_fix(64n, fns, (Bool.pick(RaVec<U32>, main_pure, m0, ra_vec_set(U32, 4n, 0, U32.or(ra_vec_get(U32, 4n, 0, 0, m0), 6), m0)), True{}))
type HotSt is Data:
  HotSt{hot_cid: RaVec<U32>, kept_param: RaVec<U32>, kept_ret: RaVec<U32>, chg: Bool}
type HotFnSt is Data:
  HotFnSt{kreg: RaVec<U32>, rchg: Bool, hs: HotSt}
def elf_hot_put_kr(ra: RaVec<U32> & Bool, hs: HotSt) -> HotFnSt:
  (kr1, rc1) = ra
  HotFnSt{kr1, rc1, hs}
def elf_hot_put_hc(ra: RaVec<U32> & Bool, kp: RaVec<U32>, kret: RaVec<U32>) -> HotSt:
  (hc1, chg1) = ra
  HotSt{hc1, kp, kret, chg1}
def elf_hot_put_kret(ra: RaVec<U32> & Bool, kr: RaVec<U32>, rc: Bool, hc: RaVec<U32>, kp: RaVec<U32>) -> HotFnSt:
  (kret1, chg1) = ra
  HotFnSt{kr, rc, HotSt{hc, kp, kret1, chg1}}
def elf_hot_mark_reg(+rd: Nat, fst: HotFnSt, +r: U32) -> HotFnSt:
  HotFnSt{kr, rc, hs} = fst
  elf_hot_put_kr(elf_bs_mark(rd, (kr, rc), r), hs)
def elf_hot_mark_reg_if(rd: Nat, cond: Bool, fst: HotFnSt, r: U32) -> HotFnSt:
  match cond:
    case True{}: elf_hot_mark_reg(rd, fst, r)
    case False{}: fst
def elf_hot_mark_regs(+rd: Nat, rs: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  match rs:
    case Nil{}: fst
    case Con{r, t}: elf_hot_mark_regs(rd, t, elf_hot_mark_reg(rd, fst, r))
def elf_hot_mark_regs_if(rd: Nat, cond: Bool, rs: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  match cond:
    case True{}: elf_hot_mark_regs(rd, rs, fst)
    case False{}: fst
def elf_hot_mark_hs_if(is_ret: Bool, cond: Bool, fst: HotFnSt, +k: U32) -> HotFnSt:
  match is_ret cond fst:
    case _ False{} _: fst
    case False{} True{} HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}: HotFnSt{kr, rc, elf_hot_put_hc(elf_bs_mark(4n, (hc, chg), k), kp, kret)}
    case True{} True{} HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}: elf_hot_put_kret(elf_bs_mark(4n, (kret, chg), k), kr, rc, hc, kp)
def elf_hot_any_reg(+rd: Nat, +kr: RaVec<U32>, rs: List<&2, U32>) -> Bool:
  match rs:
    case Nil{}: False{}
    case Con{r, t}: Bool.or(elf_bs_has(rd, r, kr), elf_hot_any_reg(rd, kr, t))
def elf_hot_call_args_go(+rd: Nat, args: List<&2, U32>, +mask: U32, fst: HotFnSt) -> HotFnSt:
  match args:
    case Nil{}: fst
    case Con{a, t}: elf_hot_call_args_go(rd, t, U32.shr(mask), elf_hot_mark_reg_if(rd, U32.is_ne(U32.and(mask, 1), 0), fst, a))
def elf_hot_call_args_if(mask: U32, rd: Nat, args: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  match mask:
    case 0: fst
    case m: elf_hot_call_args_go(rd, args, m, fst)
def elf_hot_call_args(rd: Nat, cfid: U32, args: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  HotFnSt{kr, rc, HotSt{hc, +kp, kret, chg}} = fst
  elf_hot_call_args_if(ra_vec_get(U32, 7n, 0, cfid, kp), rd, args, HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}})
def elf_hot_ctor_fields(rd: Nat, +cid: U32, fields: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  HotFnSt{kr2, rc2, HotSt{+hc2, kp2, kret2, chg2}} = fst
  elf_hot_mark_regs_if(rd, elf_bs_has(4n, cid, hc2), fields, HotFnSt{kr2, rc2, HotSt{hc2, kp2, kret2, chg2}})
def elf_hot_ctor(+rd: Nat, dst: U32, +cid: U32, fields: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  HotFnSt{+kr, rc, hs} = fst
  elf_hot_ctor_fields(rd, cid, fields, elf_hot_mark_hs_if(False{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, cid))
def elf_hot_arrop(+rd: Nat, aop: U32, args: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  match aop args:
    case 71 Con{_, Con{v, _}}: elf_hot_mark_reg(rd, fst, v)
    case 73 Con{_, Con{_, Con{v, _}}}: elf_hot_mark_reg(rd, fst, v)
    case 74 Con{_, Con{_, Con{v, _}}}: elf_hot_mark_reg(rd, fst, v)
    case 8 Con{v, _}: elf_hot_mark_reg(rd, fst, v)
    case 9 Con{l, Con{r, _}}: elf_hot_mark_reg(rd, elf_hot_mark_reg(rd, fst, l), r)
    case _ _: fst
def elf_hot_op(+rd: Nat, fst: HotFnSt, op: IrOp) -> HotFnSt:
  HotFnSt{+kr, rc, hs} = fst
  match op:
    case IKeep{_, src}: elf_hot_mark_reg(rd, HotFnSt{kr, rc, hs}, src)
    case ICopy{dst, src}: elf_hot_mark_reg_if(rd, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, src)
    case ICtor{dst, cid, fields}: elf_hot_ctor(rd, dst, cid, fields, HotFnSt{kr, rc, hs})
    case IReuse{dst, _, cid, fields}: elf_hot_ctor(rd, dst, cid, fields, HotFnSt{kr, rc, hs})
    case ITake{dsts, src}: elf_hot_mark_reg_if(rd, elf_hot_any_reg(rd, kr, dsts), HotFnSt{kr, rc, hs}, src)
    case ICallDirect{dst, +cfid, args}: elf_hot_call_args(rd, cfid, args, elf_hot_mark_hs_if(True{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, cfid))
    case ICallClosure{dst, +cfid, +caps}: elf_hot_call_args(rd, cfid, caps, elf_hot_mark_regs_if(rd, elf_bs_has(rd, dst, kr), caps, HotFnSt{kr, rc, hs}))
    case IApply{dst, clo, arg}: elf_hot_call_args(rd, 0, [clo, arg], elf_hot_mark_hs_if(True{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, 0))
    case IArrOp{_, aop, args}: elf_hot_arrop(rd, aop, args, HotFnSt{kr, rc, hs})
    case _: HotFnSt{kr, rc, hs}
def elf_hot_ops(+rd: Nat, ops: List<&2, IrOp>, fst: HotFnSt) -> HotFnSt:
  match ops:
    case Nil{}: fst
    case Con{op, t}: elf_hot_ops(rd, t, elf_hot_op(rd, fst, op))
def elf_hot_term(+rd: Nat, +fid: U32, term: IrTerm, fst: HotFnSt) -> HotFnSt:
  match term fst:
    case TRet{v} HotFnSt{kr, rc, HotSt{hc, kp, +kret, chg}}:
      elf_hot_mark_reg_if(rd, elf_bs_has(4n, fid, kret), HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}, v)
    case TTailCall{+cfid, args} HotFnSt{kr, rc, HotSt{hc, kp, +kret, chg}}:
      elf_hot_call_args(rd, cfid, args, elf_hot_mark_hs_if(True{}, elf_bs_has(4n, fid, kret), HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}, cfid))
    case _ _: fst
def elf_hot_blks(+rd: Nat, +fid: U32, blks: List<&2, IrBlock>, fst: HotFnSt) -> HotFnSt:
  match blks:
    case Nil{}: fst
    case Con{IrBlock{_, ops, term}, t}:
      elf_hot_blks(rd, fid, t, elf_hot_ops(rd, b5k_list_rev(IrOp, ops), elf_hot_term(rd, fid, term, fst)))
def elf_hot_fn_fix(fuel: Nat, +rd: Nat, +fid: U32, +blks: List<&2, IrBlock>, fst: HotFnSt) -> HotFnSt:
  match fuel fst:
    case 0n _: fst
    case _ HotFnSt{kr, False{}, hs}: HotFnSt{kr, False{}, hs}
    case 1n+p HotFnSt{kr, True{}, hs}:
      elf_hot_fn_fix(p, rd, fid, blks, elf_hot_blks(rd, fid, blks, HotFnSt{kr, False{}, hs}))
def elf_hot_export_mask(miss: Bool, fid: U32, nw: U32, hc: RaVec<U32>, kp: RaVec<U32>, kret: RaVec<U32>, chg: Bool) -> HotSt:
  match miss:
    case True{}: HotSt{hc, ra_vec_set(U32, 7n, fid, nw, kp), kret, True{}}
    case False{}: HotSt{hc, kp, kret, chg}
def elf_hot_one_fin(rd: Nat, +ar: U32, +fid: U32, fst: HotFnSt) -> HotSt:
  HotFnSt{kr, _, HotSt{hc, +kp, kret, chg}} = fst
  amask = Bool.pick(U32, U32.is_ge(ar, 32), 4294967295, U32.sub(U32.shln(1, U32.to_nat(ar)), 1))
  pbits = U32.and(ra_vec_get(U32, rd, 0, 0, kr), amask)
  +old = ra_vec_get(U32, 7n, 0, fid, kp)
  +nw = U32.or(old, pbits)
  elf_hot_export_mask(U32.is_ne(nw, old), fid, nw, hc, kp, kret, chg)
def elf_hot_fn_if(live: Bool, +fid: U32, ar: U32, +nregs: U32, blks: List<&2, IrBlock>, hs: HotSt) -> HotSt:
  match live:
    case True{}:
      +rd = Bool.pick(Nat, U32.is_lt(nregs, 512), 2n, Bool.pick(Nat, U32.is_lt(nregs, 2048), 3n, 5n))
      elf_hot_one_fin(rd, ar, fid, elf_hot_fn_fix(16n, rd, fid, b5k_list_rev(IrBlock, blks), HotFnSt{RVEmpty{}, True{}, hs}))
    case False{}: hs
def elf_hot_fns(+reach: RaVec<U32>, fns: List<&2, IrFn>, hs: HotSt) -> HotSt:
  match fns:
    case Nil{}: hs
    case Con{IrFn{+fid, _, ar, nregs, _, _, _, blks}, t}:
      elf_hot_fns(reach, t, elf_hot_fn_if(elf_bs_has(4n, fid, reach), fid, ar, nregs, blks, hs))
def elf_hot_mark_cids(cids: List<&2, U32>, hs: HotSt) -> HotSt:
  match cids hs:
    case Nil{} _: hs
    case Con{c, t} HotSt{hc, kp, kret, chg}:
      elf_hot_mark_cids(t, elf_hot_put_hc(elf_bs_mark(4n, (hc, chg), c), kp, kret))
def elf_hot_io_cont(hs: HotSt) -> HotSt:
  HotSt{+hc, +kp, +kret, +chg} = hs
  Bool.pick(HotSt, U32.is_ne(U32.and(ra_vec_get(U32, 7n, 0, 2, kp), 2), 0), elf_hot_mark_cids([1, 5, 6, 10, 11], HotSt{hc, kp, kret, chg}), HotSt{hc, kp, kret, chg})
def elf_hot_fix(fuel: Nat, +reach: RaVec<U32>, +fns1: List<&2, IrFn>, +fns2: List<&2, IrFn>, hs: HotSt) -> RaVec<U32>:
  match fuel hs:
    case 0n HotSt{hc, _, _, _}: hc
    case _ HotSt{hc, _, _, False{}}: hc
    case 1n+p HotSt{hc, kp, kret, True{}}:
      elf_hot_fix(p, reach, fns2, fns1, elf_hot_io_cont(elf_hot_fns(reach, fns1, HotSt{hc, kp, kret, False{}})))
def elf_compute_cid_hot(+fns: List<&2, IrFn>, main_fid: U32, main_pure: Bool) -> RaVec<U32>:
  +rfns = b5k_list_rev(IrFn, fns)
  reach = elf_compute_reach(rfns, main_fid, main_pure)
  elf_hot_fix(32n, reach, rfns, fns, HotSt{RVEmpty{}, RVEmpty{}, RVEmpty{}, True{}})
def elf_emit_cid_hots(ctors: List<&2, IrCtor>, +hot_map: RaVec<U32>, b: ByteBuf) -> ByteBuf:
  match ctors:
    case Nil{}: b
    case Con{IrCtor{cid, _, _, hot}, t}:
      elf_emit_cid_hots(t, hot_map, bb_emit_u8(b, Bool.to_u32(Bool.or(hot, elf_bs_has(4n, cid, hot_map)))))
def elf_emit_cstr_list_go(ss: List<&2, String>, +b: ByteBuf, offs: List<&2, U32>) -> ByteBuf & List<&2, U32>:
  match ss:
    case Nil{}: (b, b5k_list_rev(U32, offs))
    case Con{s, t}: elf_emit_cstr_list_go(t, bb_emit_cstr(b, s), Con{bb_len(b), offs})
def elf_ctor_names(ctors: List<&2, IrCtor>) -> List<&2, String>:
  match ctors:
    case Nil{}: Nil{}
    case Con{IrCtor{_, nm, _, _}, t}: Con{nm, elf_ctor_names(t)}
def elf_emit_u64_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf:
  match xs:
    case Nil{}: b
    case Con{+x, t}:
      +is_hi = U32.is_ge(x, 2147483648)
      +is_nil = U32.is_eq(x, 2147483648)
      lo = Bool.pick(U32, is_hi, Bool.pick(U32, is_nil, 0, U32.add(51413504, U32.sub(x, 2147483649))), x)
      hi = Bool.pick(U32, is_hi, Bool.pick(U32, is_nil, 16777216, 33554688), 0)
      elf_emit_u64_arr(t, bb_emit_u64(b, lo, hi))
def elf_emit_ptr_slot(ta: TextAcc, use_ptr: Bool, sym: String, addend: U32) -> TextAcc:
  match ta use_ptr:
    case TextAcc{+b, rels} True{}: TextAcc{bb_emit_u64(b, 0, 0), Con{ElfReloc{bb_len(b), sym, 1, addend}, rels}}
    case TextAcc{b, rels} False{}: TextAcc{bb_emit_u64(b, 0, 0), rels}
def elf_emit_seg_ptrs(fns: List<&2, IrFn>, ta: TextAcc) -> TextAcc:
  match fns:
    case Nil{}: ta
    case Con{IrFn{fid, _, _, _, _, _, _, _}, t}: elf_emit_seg_ptrs(t, elf_emit_ptr_slot(ta, True{}, x64_seg_sym(fid), 0))
def elf_emit_ro_ptrs(offs: List<&2, U32>, ta: TextAcc) -> TextAcc:
  match offs:
    case Nil{}: ta
    case Con{ro_off, t}: elf_emit_ro_ptrs(t, elf_emit_ptr_slot(ta, True{}, ".rodata", ro_off))
def elf_ta_len(ta: TextAcc) -> U32:
  TextAcc{b, _} = ta
  bb_len(b)
def elf_ta_pad8(ta: TextAcc) -> TextAcc:
  TextAcc{b, rels} = ta
  TextAcc{elf_pad_to(b, 8), rels}
def elf_ta_u64s(xs: List<&2, U32>, ta: TextAcc) -> TextAcc:
  match xs ta:
    case Nil{} _: ta
    case Con{x, t} TextAcc{b, rels}: elf_ta_u64s(t, TextAcc{bb_emit_u64(b, x, 0), rels})
# Symtab, Strtab, Rela, Shdr Serialization
type UndefAcc is Data:
  UndefAcc{defined: Map<&2, U32>, acc: List<&2, ElfSym>}
def elf_collect_got(got: Map<&2, U32> & U32, +sym: String, acc: List<&2, ElfSym>) -> UndefAcc:
  (m1, found) = got
  match found:
    case 0: UndefAcc{Map.set(&2, U32, m1, sym, 1), Con{ElfSym{sym, 16, 0, 0, 0}, acc}}
    case _: UndefAcc{m1, acc}
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
      SymTabRes{bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, 0), info), 0), shndx), val, 0), sz, 0), strb, imap}
    case False{} SymTabRes{sb, +strb, imap}:
      SymTabRes{bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, bb_len(strb)), info), 0), shndx), val, 0), sz, 0), bb_emit_cstr(strb, nm), Map.set(&2, U32, imap, nm, idx)}
def elf_ser_syms_go(syms: List<&2, ElfSym>, +idx: U32, sr: SymTabRes) -> SymTabRes:
  match syms:
    case Nil{}: sr
    case Con{ElfSym{+nm, info, shndx, val, sz}, t}:
      elf_ser_syms_go(t, U32.add(idx, 1), elf_ser_sym_one(String.is_empty(nm), nm, info, shndx, val, sz, idx, sr))
def elf_ser_rela_go(rels: List<&2, ElfReloc>, +imap: Map<&2, U32>, b: ByteBuf) -> ByteBuf:
  match rels b:
    case Nil{} _: b
    case Con{ElfReloc{roff, sym, rtype, +addend}, t} ByteBuf{off, rev}:
      add_hi = Bool.pick(U32, U32.is_ge(addend, 2147483648), 4294967295, 0)
      r1 = e_u32(e_u32(e_u32(e_u32(e_u32(e_u32(rev, roff), 0), rtype), elf_snd_u32(Map.get(U32, 0, imap, sym))), addend), add_hi)
      elf_ser_rela_go(t, imap, ByteBuf{U32.add(off, 24), r1})
def elf_emit_shdr(b: ByteBuf, nm: U32, typ: U32, flg: U32, off: U32, sz: U32, lnk: U32, inf: U32, aln: U32, ent: U32) -> ByteBuf: bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u32(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u32(b, nm), typ), flg, 0), 0, 0), off, 0), sz, 0), lnk), inf), aln, 0), ent, 0)
def elf_emit_ehdr(shoff: U32) -> ByteBuf:
  b0 = bb_emit_zeros(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_new(), 127), 69), 76), 70), 2), 1), 1), 0), 8)
  bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u32(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u16(bb_emit_u16(b0, 1), 62), 1), 0, 0), 0, 0), shoff, 0), 0), 64), 0), 0), 64), 9), 8)
def elf_build_shstrtab() -> ByteBuf: bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_u8(bb_new(), 0), ".text"), ".rela.text"), ".rodata"), ".data"), ".rela.data"), ".symtab"), ".strtab"), ".shstrtab")
type RoData is Data:
  RoData{buf: ByteBuf, cid_offs: List<&2, U32>, show_offs: List<&2, U32>, eff_offs: List<&2, U32>, off_fid_ar: U32, off_fid_fl: U32, off_fid_rs: U32, off_cid_ar: U32, off_show: U32, off_stat: U32}
def elf_ro_s3(p3: ByteBuf & List<&2, U32>, statics: List<&2, U32>, cid_offs: List<&2, U32>, show_offs: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32) -> RoData:
  (ro9, eff_offs) = p3
  +ro10 = elf_pad_to(ro9, 8)
  RoData{elf_emit_u64_arr(statics, ro10), cid_offs, show_offs, eff_offs, off_far, off_ffl, off_frs, off_car, off_shd, bb_len(ro10)}
def elf_ro_s2(p2: ByteBuf & List<&2, U32>, effects: List<&2, String>, statics: List<&2, U32>, cid_offs: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32) -> RoData:
  (ro8, show_offs) = p2
  elf_ro_s3(elf_emit_cstr_list_go(effects, ro8, Nil{}), statics, cid_offs, show_offs, off_far, off_ffl, off_frs, off_car, off_shd)
def elf_ro_s1(p1: ByteBuf & List<&2, U32>, show_desc: List<&2, U32>, show_names: List<&2, String>, effects: List<&2, String>, statics: List<&2, U32>, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32) -> RoData:
  (ro5, cid_offs) = p1
  +ro6 = elf_pad_to(ro5, 4)
  elf_ro_s2(elf_emit_cstr_list_go(show_names, elf_emit_u32_arr(show_desc, ro6), Nil{}), effects, statics, cid_offs, off_far, off_ffl, off_frs, off_car, bb_len(ro6))
def elf_build_rodata(+luts: ByteBuf, ir_fns: List<&2, IrFn>, +all_ctors: List<&2, IrCtor>, +n_segs: U32, show_desc: List<&2, U32>, show_names: List<&2, String>, effects: List<&2, String>, statics: List<&2, U32>) -> RoData:
  +ro1 = elf_emit_fid_arities(ir_fns, luts)
  +ro2 = bb_emit_zeros(ro1, n_segs)
  +ro3 = bb_emit_zeros(ro2, n_segs)
  elf_ro_s1(elf_emit_cstr_list_go(elf_ctor_names(all_ctors), elf_emit_cid_arities(all_ctors, ro3), Nil{}), show_desc, show_names, effects, statics, bb_len(luts), bb_len(ro1), bb_len(ro2), bb_len(ro3))
def elf_append_buf(dst: ByteBuf, src: ByteBuf) -> ByteBuf:
  ByteBuf{dl, dr} = dst
  ByteBuf{sl, sr} = src
  ByteBuf{U32.add(dl, sl), b5k_list_app(U32, sr, dr)}
def elf_pack_image(+text_buf: ByteBuf, +ro_buf: ByteBuf, +data_buf: ByteBuf, +text_rels: List<&2, ElfReloc>, +data_rels: List<&2, ElfReloc>, first_glob: U32, sr: SymTabRes) -> ByteBuf:
  SymTabRes{+symtab_buf, +strtab_buf, +idx_map} = sr
  +shstr_buf = elf_build_shstrtab()
  +sz_text = bb_len(text_buf)
  +sz_rtxt = U32.mul(b5k_list_len(ElfReloc, text_rels), 24)
  +sz_ro   = bb_len(ro_buf)
  +sz_dat  = bb_len(data_buf)
  +sz_rdat = U32.mul(b5k_list_len(ElfReloc, data_rels), 24)
  +sz_sym  = bb_len(symtab_buf)
  +sz_str  = bb_len(strtab_buf)
  +sz_shst = bb_len(shstr_buf)
  +off_rtxt = x64_align16(U32.add(64, sz_text))
  +off_ro   = x64_align16(U32.add(off_rtxt, sz_rtxt))
  +off_dat  = x64_align16(U32.add(off_ro, sz_ro))
  +off_rdat = x64_align16(U32.add(off_dat, sz_dat))
  +off_sym  = x64_align16(U32.add(off_rdat, sz_rdat))
  +off_str  = U32.add(off_sym, sz_sym)
  +off_shst = U32.add(off_str, sz_str)
  +off_shdr = x64_align16(U32.add(off_shst, sz_shst))
  e4 = elf_append_buf(elf_pad_to(elf_append_buf(elf_pad_to(elf_ser_rela_go(text_rels, idx_map, elf_pad_to(elf_append_buf(elf_emit_ehdr(off_shdr), text_buf), 16)), 16), ro_buf), 16), data_buf)
  h0 = elf_pad_to(elf_append_buf(elf_append_buf(elf_append_buf(elf_pad_to(elf_ser_rela_go(data_rels, idx_map, elf_pad_to(e4, 16)), 16), symtab_buf), strtab_buf), shstr_buf), 16)
  h1 = elf_emit_shdr(h0, 0,  0, 0,  0,        0,       0, 0,          0,  0)
  h2 = elf_emit_shdr(h1, 1,  1, 6,  64,       sz_text, 0, 0,          16, 0)
  h3 = elf_emit_shdr(h2, 7,  4, 64, off_rtxt, sz_rtxt, 6, 1,          8,  24)
  h4 = elf_emit_shdr(h3, 18, 1, 2,  off_ro,   sz_ro,   0, 0,          8,  0)
  h5 = elf_emit_shdr(h4, 26, 1, 3,  off_dat,  sz_dat,  0, 0,          8,  0)
  h6 = elf_emit_shdr(h5, 32, 4, 64, off_rdat, sz_rdat, 6, 4,          8,  24)
  h7 = elf_emit_shdr(h6, 43, 2, 0,  off_sym,  sz_sym,  7, first_glob, 8,  24)
  h8 = elf_emit_shdr(h7, 51, 3, 0,  off_str,  sz_str,  0, 0,          1,  0)
  elf_emit_shdr(h8, 59, 3, 0, off_shst, sz_shst, 0, 0, 1, 0)
def elf_finish_data(text_buf: ByteBuf, +text_rels: List<&2, ElfReloc>, text_lsyms: List<&2, ElfSym>, text_gsyms: List<&2, ElfSym>, ro_buf: ByteBuf, da: TextAcc, off_far: U32, off_ffl: U32, off_frs: U32, off_car: U32, off_shd: U32, off_sta: U32, off_segs: U32, off_cnm: U32, off_prog: U32, +n_segs: U32, +n_ctors: U32, n_show: U32, n_stat: U32) -> ByteBuf:
  TextAcc{data_buf, dr_rev} = da
  +data_rels = b5k_list_rev(ElfReloc, dr_rev)
  +locals = b5k_list_app(ElfSym,
    [ElfSym{"", 0, 0, 0, 0}, ElfSym{".text", 3, 1, 0, 0}, ElfSym{".rodata", 3, 3, 0, 0}, ElfSym{".data", 3, 4, 0, 0},
     ElfSym{"p111_fid_arity", 1, 3, off_far, n_segs}, ElfSym{"p111_fid_flags", 1, 3, off_ffl, n_segs},
     ElfSym{"p111_fid_results", 1, 3, off_frs, n_segs}, ElfSym{"p111_cid_arity", 1, 3, off_car, n_ctors},
     ElfSym{"p111_show_desc", 1, 3, off_shd, U32.mul(n_show, 4)}, ElfSym{"p111_static_image", 1, 3, off_sta, U32.mul(n_stat, 8)},
     ElfSym{"p111_cid_hot", 1, 4, 0, n_ctors}, ElfSym{"p111_segments", 1, 4, off_segs, U32.mul(n_segs, 8)},
     ElfSym{"p111_cid_names", 1, 4, off_cnm, U32.mul(n_ctors, 8)}],
    b5k_list_rev(ElfSym, text_lsyms))
  first_glob = b5k_list_len(ElfSym, locals)
  +def_globs: List<&2, ElfSym> = Con{ElfSym{"p111_program", 17, 4, off_prog, 192}, b5k_list_rev(ElfSym, text_gsyms)}
  def_map1 = elf_mark_syms_go(def_globs, elf_mark_syms_go(locals, Map.new(&2, U32)))
  undefs = b5k_list_rev(ElfSym, elf_collect_undefs_go(b5k_list_app(ElfReloc, text_rels, data_rels), UndefAcc{def_map1, Nil{}}))
  all_syms = b5k_list_app(ElfSym, locals, b5k_list_app(ElfSym, def_globs, undefs))
  sr = elf_ser_syms_go(all_syms, 0, SymTabRes{bb_new(), bb_emit_u8(bb_new(), 0), Map.new(&2, U32)})
  elf_pack_image(text_buf, ro_buf, data_buf, text_rels, data_rels, first_glob, sr)
def elf_finish_ro(ro: RoData, text_buf: ByteBuf, text_rels: List<&2, ElfReloc>, text_lsyms: List<&2, ElfSym>, text_gsyms: List<&2, ElfSym>, +ir_fns: List<&2, IrFn>, all_ctors: List<&2, IrCtor>, +n_segs: U32, +n_ctors: U32, +main_fid: U32, +main_pure: Bool, reg_w: U32, +n_stat: U32, +n_show: U32, +n_sname: U32, +n_eff: U32) -> ByteBuf:
  RoData{ro_buf, cid_offs, show_offs, eff_offs, off_far, off_ffl, off_frs, off_car, off_shd, off_sta} = ro
  +da1 = elf_pad_to(elf_emit_cid_hots(all_ctors, elf_compute_cid_hot(ir_fns, main_fid, main_pure), bb_new()), 8)
  +off_segs = bb_len(da1)
  +ta2 = elf_emit_seg_ptrs(ir_fns, TextAcc{da1, Nil{}})
  +off_cnm = elf_ta_len(ta2)
  +ta3 = elf_emit_ro_ptrs(cid_offs, ta2)
  +off_snm = elf_ta_len(ta3)
  +ta4 = elf_emit_ro_ptrs(show_offs, ta3)
  +off_eff = elf_ta_len(ta4)
  +ta6 = elf_ta_pad8(elf_emit_ro_ptrs(eff_offs, ta4))
  off_prog = elf_ta_len(ta6)
  p5 = elf_ta_u64s([11102, 192, n_segs, n_ctors, main_fid, Bool.to_u32(main_pure), reg_w, 1, n_stat, n_show, n_sname, 9], ta6)
  q0 = elf_emit_ptr_slot(elf_emit_ptr_slot(p5, True{}, "p111_segments", 0), True{}, "p111_fid_arity", 0)
  q2 = elf_emit_ptr_slot(elf_emit_ptr_slot(q0, True{}, "p111_fid_flags", 0), True{}, "p111_fid_results", 0)
  q4 = elf_emit_ptr_slot(elf_emit_ptr_slot(q2, True{}, "p111_cid_arity", 0), True{}, "p111_cid_hot", 0)
  q6 = elf_emit_ptr_slot(elf_emit_ptr_slot(q4, True{}, "p111_cid_names", 0), U32.is_gt(n_stat, 0), "p111_static_image", 0)
  q8 = elf_emit_ptr_slot(elf_emit_ptr_slot(q6, U32.is_gt(n_show, 0), "p111_show_desc", 0), U32.is_gt(n_sname, 0), ".data", off_snm)
  q10 = elf_emit_ptr_slot(elf_ta_u64s([n_eff], q8), U32.is_gt(n_eff, 0), ".data", off_eff)
  elf_finish_data(text_buf, text_rels, text_lsyms, text_gsyms, ro_buf, q10, off_far, off_ffl, off_frs, off_car, off_shd, off_sta, off_segs, off_cnm, off_prog, n_segs, n_ctors, n_show, n_stat)
def elf_finish(tres: TextRes, +ir_fns: List<&2, IrFn>, +ir_ctors: List<&2, IrCtor>, +statics: List<&2, U32>, main_fid: U32, +main_pure: Bool, +effects: List<&2, String>, +show_desc_in: List<&2, U32>, +show_names: List<&2, String>) -> ByteBuf:
  TextRes{text_buf, text_rels, text_lsyms, text_gsyms, luts} = tres
  +all_ctors = elf_merge_core_go(elf_core_ctors(), ir_ctors, MergeAcc{b5k_list_len(IrCtor, ir_ctors), Nil{}})
  +n_segs = b5k_list_len(IrFn, ir_fns)
  +n_ctors = b5k_list_len(IrCtor, all_ctors)
  +n_stat = b5k_u32_list_len(statics)
  +show_desc = Bool.pick(List<&2, U32>, Bool.and(main_pure, U32.is_zero(b5k_u32_list_len(show_desc_in))), Con{0, Nil{}}, show_desc_in)
  +n_show = b5k_u32_list_len(show_desc)
  +n_sname = b5k_list_len(String, show_names)
  +n_eff = b5k_list_len(String, effects)
  elf_finish_ro(elf_build_rodata(luts, ir_fns, all_ctors, n_segs, show_desc, show_names, effects, statics), text_buf, text_rels, text_lsyms, text_gsyms, ir_fns, all_ctors, n_segs, n_ctors, main_fid, main_pure, U32.max(2, elf_max_arity(ir_fns, 0)), n_stat, n_show, n_sname, n_eff)
def b5k_emit_elf(prog: IrProg, fns: List<&2, X64Fn>) -> ByteBuf:
  IrProg{ir_fns, ir_ctors, statics, main_fid, main_pure, effects, show_desc_in, show_names} = prog
  elf_finish(elf_encode_fns_go(fns, TextRes{bb_new(), Nil{}, Nil{}, Nil{}, bb_new()}), ir_fns, ir_ctors, statics, main_fid, main_pure, effects, show_desc_in, show_names)
