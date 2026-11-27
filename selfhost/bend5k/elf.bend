# bend5k/elf.bend — Direct x86-64 Machine Code & ELF64 Relocatable Emitter
# ========================================================================
# Encodes X64Fn lists directly into x86-64 machine bytes (2-pass with dense
# label map, zero string scanning) and emits a standard ELF64 ET_REL (.o)
# object with P111 ABI v11102 metadata:
#   .text   (AX):  main, p111_seg_<fid>, $direct.<name>
#   .rodata (A):   p111_fid_*, p111_cid_arity, p111_cid_names_*, p111_show_desc
#   .data   (WA):  p111_cid_hot, p111_segments, p111_cid_names, p111_program
def elf_rex(w: U32, r: U32, x: U32, b: U32) -> U32: U32.or(U32.or(64, U32.shln(U32.and(w, 1), 3n)), U32.or(U32.shln(U32.and(U32.shrn(r, 3n), 1), 2n), U32.or(U32.shln(U32.and(U32.shrn(x, 3n), 1), 1n), U32.and(U32.shrn(b, 3n), 1))))
def elf_modrm(md: U32, reg: U32, rm: U32) -> U32: U32.or(U32.or(U32.shln(U32.and(md, 3), 6n), U32.shln(U32.and(reg, 7), 3n)), U32.and(rm, 7))
def elf_is_hi(a: U32, b: U32) -> Bool: Bool.or(U32.is_ge(a, 8), U32.is_ge(b, 8))
def elf_alu_rr_op(+op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 0), 1, Bool.pick(U32, U32.is_eq(op, 1), 41, Bool.pick(U32, U32.is_eq(op, 5), 33, Bool.pick(U32, U32.is_eq(op, 6), 9, 49))))
def elf_alu_ri_sub(+op: U32) -> U32: Bool.pick(U32, U32.is_eq(op, 0), 0, Bool.pick(U32, U32.is_eq(op, 1), 5, Bool.pick(U32, U32.is_eq(op, 5), 4, Bool.pick(U32, U32.is_eq(op, 6), 1, 6))))
def elf_is_simm8(v: U32) -> Bool: U32.is_lt(U32.add(v, 128), 256)
def elf_mem_mod(+base: U32, +disp: U32) -> U32: Bool.pick(U32, Bool.and(U32.is_zero(disp), U32.is_ne(U32.and(base, 7), 5)), 0, Bool.pick(U32, elf_is_simm8(disp), 1, 2))
def elf_mem_extra(+base: U32, disp: U32) -> U32: (+md = elf_mem_mod(base, disp); U32.add(Bool.pick(U32, U32.is_eq(U32.and(base, 7), 4), 1, 0), Bool.pick(U32, U32.is_zero(md), 0, Bool.pick(U32, U32.is_eq(md, 1), 1, 4))))
def elf_alu_ri32_len(+dst: U32, imm: U32) -> U32: U32.add(Bool.pick(U32, U32.is_ge(dst, 8), 1, 0), Bool.pick(U32, elf_is_simm8(imm), 3, 6))
def elf_shl32_len(+dst: U32, amt: U32) -> U32: U32.add(Bool.pick(U32, U32.is_ge(dst, 8), 1, 0), Bool.pick(U32, U32.is_eq(amt, 1), 2, 3))
def elf_inst_len(inst: X64Inst) -> U32:
  match inst:
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
    case XCmpRI{lhs, imm}: elf_alu_ri32_len(lhs, imm)
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
    case XJmpSym{_}: 5
    case XCallReg{reg}: Bool.pick(U32, U32.is_lt(reg, 8), 2, 3)
    case XRet{}: 1
    case XXmmRR{+op, dst, src}: Bool.pick(U32, U32.is_ge(op, 256), Bool.pick(U32, U32.is_ge(U32.and(op, 15), 8), 6, 5), Bool.pick(U32, U32.is_eq(op, 14), 3, U32.add(U32.add(3, Bool.pick(U32, U32.is_eq(op, 13), 1, 0)), U32.add(Bool.pick(U32, U32.is_lt(op, 5), 1, 0), Bool.pick(U32, elf_is_hi(dst, src), 1, 0)))))
    case XXmmLoad{+dst, +base, disp}: U32.add(Bool.pick(U32, U32.is_ge(dst, 32), 5, U32.add(Bool.pick(U32, U32.is_ge(dst, 16), 3, 4), Bool.pick(U32, elf_is_hi(U32.and(dst, 15), base), 1, 0))), elf_mem_extra(base, disp))
    case XXmmStore{+base, disp, +src}: U32.add(Bool.pick(U32, U32.is_ge(src, 48), 5, U32.add(Bool.pick(U32, Bool.and(U32.is_ge(src, 16), U32.is_lt(src, 32)), 3, 4), Bool.pick(U32, elf_is_hi(U32.and(src, 15), base), 1, 0))), elf_mem_extra(base, disp))
    case XCvt{op, dst, src}: Bool.pick(U32, Bool.or(U32.is_lt(op, 2), elf_is_hi(dst, src)), 5, 4)
    case XExtReloc{+k, _, _}: Bool.pick(U32, U32.is_eq(k, 2), 7, Bool.pick(U32, U32.is_eq(k, 3), 3, 0))
    case _: 3
def elf_lbl_key(+id: U32) -> U32: Bool.pick(U32, U32.is_ge(id, 2147483648), U32.add(U32.sub(id, 2147483648), 131072), id)
def elf_not_flag_read(xs: List<&2, X64Inst>) -> Bool:
  match xs:
    case Con{h, _}: U32.is_zero(peep_flag_cc(h))
    case Nil{}: True{}
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
    case True{} Con{XAluRR{0, +d2, +s2}, Con{XLoad{+d3, +b3, 0}, t3}}: (+nf = elf_not_flag_read(t3); Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), Bool.and(Bool.and(U32.is_eq(d3, idx), U32.is_eq(b3, idx)), nf)), U32.add(16, s2), Bool.pick(U32, Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), U32.add(32, s2), Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(s2, idx), U32.is_ne(d2, idx)), Bool.and(Bool.and(U32.is_eq(d3, idx), U32.is_ne(b3, idx)), nf)), U32.add(48, d2), 0))))
    case True{} Con{XAluRR{0, +d2, +s2}, Con{XStore{+b3, 0, +v3}, Con{+nxt, t4}}}: Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), Bool.and(Bool.and(U32.is_eq(b3, idx), U32.is_ne(v3, idx)), Bool.and(elf_kills_reg(idx, nxt), elf_not_flag_read(t4)))), U32.add(U32.add(64, s2), U32.shln(v3, 8n)), Bool.pick(U32, Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), U32.add(32, s2), 0))
    case True{} Con{XAluRR{0, +d2, +s2}, Con{+nxt, +t3}}: Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(d2, idx), U32.is_ne(s2, idx)), elf_not_flag_read(Con{nxt, t3})), U32.add(32, s2), Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(s2, idx), U32.is_ne(d2, idx)), Bool.and(elf_kills_reg(idx, nxt), elf_not_flag_read(t3))), U32.add(48, d2), 0))
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
def elf_mul_len(+ok: Bool, +d: U32, +s: U32) -> U32: (+md = Bool.pick(U32, U32.is_eq(U32.and(d, 7), 5), 1, 0); Bool.pick(U32, U32.is_ge(s, 17), Bool.pick(U32, ok, U32.add(3, U32.add(Bool.pick(U32, U32.is_ge(d, 8), 1, 0), md)), U32.add(4, md)), Bool.pick(U32, ok, Bool.pick(U32, elf_is_hi(d, s), 4, 3), 4)))
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
    case 1n+p Con{h, t}: (+u = peep_reg_use(r, h); Bool.pick(Bool, U32.is_eq(u, 1), True{}, Bool.pick(Bool, U32.is_eq(u, 2), False{}, elf_dead_rmw(p, r, t))))
def elf_load_code(+tmp: U32, +base: U32, +disp: U32, t: List<&2, X64Inst>) -> U32:
  match t:
    case Con{XAluRR{+op, +d, +s}, +t2}: Bool.pick(U32, peep_and_dead(Bool.and(U32.is_eq(s, tmp), U32.is_ne(d, tmp)), 6n, tmp, t2), U32.or(Bool.pick(U32, elf_head_is_mask32(t2, d), 2, 1), U32.or(U32.shln(U32.add(elf_alu_rr_op(op), 2), 4n), U32.shln(d, 12n))), 0)
    case Con{XCmpRR{+a, +b}, +t2}: (+cr = Bool.and(U32.is_eq(b, tmp), U32.is_ne(a, tmp)); Bool.pick(U32, peep_and_dead(Bool.or(cr, Bool.and(U32.is_eq(a, tmp), U32.is_ne(b, tmp))), 6n, tmp, t2), U32.or(1, U32.or(U32.shln(Bool.pick(U32, cr, 59, 57), 4n), U32.shln(Bool.pick(U32, cr, a, b), 12n))), 0))
    case Con{XAluRI{+op, +r2, _}, Con{XShift{8, +m1, 32, False{}}, Con{XShift{9, +m2, 32, False{}}, Con{XStore{+b2, +d2, +r3}, +t4}}}}: Bool.pick(U32, opt_if(Bool, Bool.and(Bool.and(Bool.and(U32.is_eq(r2, tmp), U32.is_eq(r3, tmp)), Bool.and(U32.is_eq(m1, tmp), U32.is_eq(m2, tmp))), Bool.and(Bool.and(U32.is_ne(tmp, base), U32.is_ne(base, 5)), Bool.and(Bool.and(U32.is_eq(b2, base), U32.is_eq(d2, disp)), elf_not_flag_read(t4)))), _ => elf_dead_rmw(6n, tmp, t4), _ => False{}), U32.or(4, U32.shln(elf_alu_ri_sub(op), 4n)), 0)
    case Con{XAluRI{+op, +r2, _}, Con{XStore{+b2, +d2, +r3}, +t3}}: Bool.pick(U32, peep_and_dead(Bool.and(Bool.and(U32.is_eq(r2, tmp), U32.is_eq(r3, tmp)), Bool.and(U32.is_ne(tmp, base), Bool.and(U32.is_eq(b2, base), U32.is_eq(d2, disp)))), 6n, tmp, t3), U32.or(3, U32.shln(elf_alu_ri_sub(op), 4n)), 0)
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
    case Con{XXmmRR{6, +x, x1}, Con{XMovRI32{+g, +v}, Con{XCvt{2, +x2, g1}, Con{XXmmRR{1, x3, x2b}, r}}}}: elf_lut_arm_fin(Bool.and(Bool.and(U32.is_eq(x, x1), U32.is_eq(g, g1)), Bool.and(U32.is_eq(x, x3), Bool.and(U32.is_eq(x2, x2b), U32.is_ne(x, x2)))), True{}, Bool.pick(U32, U32.is_zero(v), 0, U32.xor(v, 2147483648)), x, g, r)
    case Con{XXmmRR{6, +x, x1}, r}: elf_lut_arm_fin(U32.is_eq(x, x1), True{}, 0, x, 16, r)
    case _: LutArm{False{}, False{}, 0, 0, 0, 16, 0, xs}
type LutSt is Data:
  LutSt{done: Bool, is_xmm: Bool, idx: U32, dst: U32, copy: U32, gtmp: U32, join: U32, elbl: U32, k: U32, vals: List<&2, U32>, xs: List<&2, X64Inst>}
def elf_lut_step(a: LutArm, lcnt: RaVec<U32>, +is_xmm: Bool, +idx: U32, +dst: U32, +copy: U32, +gtmp: U32, +join: U32, +elbl: U32, +k: U32, +vals: List<&2, U32>, +lid: U32, +r: U32, +kv: U32, +nlbl: U32, body: List<&2, X64Inst>) -> LutSt:
  LutArm{aok, axmm, av, ad, ac, +ag, aj, arest} = a
  ok = Bool.and(Bool.and(Bool.and(U32.is_eq(lid, elbl), peep_lbl_once(lid, lcnt)), Bool.and(U32.is_eq(r, idx), U32.is_eq(kv, k))), Bool.and(Bool.and(aok, U32.is_eq(Bool.to_u32(axmm), Bool.to_u32(is_xmm))), Bool.and(Bool.and(U32.is_eq(ad, dst), U32.is_eq(ac, copy)), Bool.and(U32.is_eq(aj, join), Bool.or(U32.is_eq(ag, 16), Bool.or(U32.is_eq(gtmp, 16), U32.is_eq(ag, gtmp)))))))
  Bool.pick(LutSt, ok, LutSt{False{}, is_xmm, idx, dst, copy, Bool.pick(U32, U32.is_eq(gtmp, 16), ag, gtmp), join, nlbl, U32.add(k, 1), Con{av, vals}, arest}, LutSt{True{}, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals, Con{XLabel{lid}, Con{XCmpRI{r, kv}, Con{XJcc{5, nlbl}, body}}}})
def elf_lut_no() -> LutHit: LutHit{False{}, False{}, 0, 0, 0, 16, 0, 0, 0, Nil{}, Nil{}}
def elf_lut_chain(fuel: Nat, +lcnt: RaVec<U32>, st: LutSt) -> LutHit:
  match fuel st:
    case 1n+p LutSt{False{}, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals, Con{XLabel{lid}, Con{XCmpRI{r, kv}, Con{XJcc{5, nlbl}, +body}}}}: elf_lut_chain(p, lcnt, elf_lut_step(elf_lut_arm(body), lcnt, is_xmm, idx, dst, copy, gtmp, join, elbl, k, vals, lid, r, kv, nlbl, body))
    case _ LutSt{_, +is_xmm, +idx, +dst, copy, +gtmp, join, +elbl, +k, vals_rev, Con{XLabel{+lid}, t}}:
      LutHit{Bool.and(Bool.and(U32.is_ge(k, 5), U32.is_eq(lid, elbl)), Bool.and(U32.is_ne(idx, 4), Bool.pick(Bool, is_xmm, Bool.and(U32.is_zero(gtmp), U32.is_ne(idx, 0)), Bool.and(U32.is_ne(dst, idx), U32.is_ne(dst, 4))))), is_xmm, idx, dst, copy, gtmp, join, elbl, k, b5k_list_rev(U32, vals_rev), Con{XLabel{lid}, t}}
    case _ _: elf_lut_no()
def elf_lut_start_k(lcnt: RaVec<U32>, idx: U32, nlbl: U32, a: LutArm) -> LutHit:
  match a:
    case LutArm{True{}, is_xmm, v0, dst, copy, gtmp, join, rest}: elf_lut_chain(256n, lcnt, LutSt{False{}, is_xmm, idx, dst, copy, gtmp, join, nlbl, 1, Con{v0, Nil{}}, rest})
    case LutArm{False{}, _, _, _, _, _, _, _}: elf_lut_no()
def elf_lut_start(ok: Bool, lcnt: RaVec<U32>, idx: U32, nlbl: U32, body: List<&2, X64Inst>) -> LutHit:
  match ok:
    case False{}: elf_lut_no()
    case True{}: elf_lut_start_k(lcnt, idx, nlbl, elf_lut_arm(body))
def elf_lut_len(+is_xmm: Bool, +idx: U32, +dst: U32, +copy: U32, +gtmp: U32, n: U32) -> U32: (+base = Bool.pick(U32, is_xmm, gtmp, dst); l_ld = U32.add(U32.add(Bool.pick(U32, is_xmm, 5, 3), Bool.to_u32(Bool.or(U32.is_ge(dst, 8), Bool.or(U32.is_ge(idx, 8), U32.is_ge(base, 8))))), Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0)); U32.add(U32.add(Bool.pick(U32, elf_is_simm8(n), 4, 7), 18), U32.add(l_ld, Bool.pick(U32, U32.is_eq(copy, dst), 0, Bool.pick(U32, is_xmm, U32.add(3, Bool.to_u32(elf_is_hi(copy, dst))), 3)))))
type P1St is Data:
  P1St{xs: List<&2, X64Inst>, skip: Nat, off: U32, lbls: RaVec<U32>}
def elf_alu_lut(do_lut: Bool, op: U32, d: U32, ok32: Bool, lcnt: RaVec<U32>, t: List<&2, X64Inst>) -> LutHit:
  match do_lut op ok32 t:
    case True{} 1 True{} Con{_, Con{_, Con{XJcc{5, nlbl}, body}}}: elf_lut_start(True{}, lcnt, d, nlbl, body)
    case True{} 1 False{} Con{XJcc{5, nlbl}, body}: elf_lut_start(True{}, lcnt, d, nlbl, body)
    case _ _ _ _: elf_lut_no()
def elf_p1_lut(lh: LutHit, off_hit: U32, off_miss: U32, skip_miss: Nat, t: List<&2, X64Inst>, lbls: RaVec<U32>) -> P1St:
  match lh:
    case LutHit{True{}, is_xmm, idx, dst, copy, gtmp, _, _, n, _, rest}: P1St{rest, 0n, U32.add(off_hit, elf_lut_len(is_xmm, idx, dst, copy, gtmp, n)), lbls}
    case LutHit{False{}, _, _, _, _, _, _, _, _, _, _}: P1St{t, skip_miss, off_miss, lbls}
def elf_pass1_go(fuel: Nat, +do_lut: Bool, +lcnt: RaVec<U32>, st: P1St) -> RaVec<U32>:
  match fuel st:
    case 0n P1St{_, _, _, lbls}: lbls
    case _ P1St{Nil{}, _, _, lbls}: lbls
    case 1n+p P1St{Con{_, t}, 1n+sk, off, lbls}: elf_pass1_go(p, do_lut, lcnt, P1St{t, sk, off, lbls})
    case 1n+p P1St{Con{XLabel{id}, t}, _, +off, lbls}: elf_pass1_go(p, do_lut, lcnt, P1St{t, 0n, off, ra_vec_set(U32, 9n, elf_lbl_key(id), off, lbls)})
    case 1n+p P1St{Con{XTestRR{+a, +b}, Con{XJcc{5, +nlbl}, +body}}, _, +off, lbls}: elf_pass1_go(p, do_lut, lcnt, elf_p1_lut(elf_lut_start(Bool.and(do_lut, U32.is_eq(a, b)), lcnt, a, nlbl, body), off, U32.add(off, 3), 0n, Con{XJcc{5, nlbl}, body}, lbls))
    case 1n+p P1St{Con{XCmpRI{+a, 0}, Con{XJcc{5, +nlbl}, +body}}, _, +off, lbls}: elf_pass1_go(p, do_lut, lcnt, elf_p1_lut(elf_lut_start(do_lut, lcnt, a, nlbl, body), off, U32.add(off, elf_inst_len(XCmpRI{a, 0})), 0n, Con{XJcc{5, nlbl}, body}, lbls))
    case 1n+p P1St{Con{XLoad{+d, +base, +disp}, +t}, _, off, lbls}: (+lc = elf_load_code(d, base, disp, t); +k = U32.and(lc, 15); +ex = elf_mem_extra(base, disp); +li = Bool.pick(U32, elf_is_simm8(elf_head_ri_imm(t)), 1, 4); elf_pass1_go(p, do_lut, lcnt, P1St{t, elf_load_skip(k), U32.add(off, Bool.pick(U32, U32.is_eq(k, 2), U32.add(U32.add(2, Bool.pick(U32, elf_is_hi(U32.shrn(lc, 12n), base), 1, 0)), ex), Bool.pick(U32, U32.is_eq(k, 3), U32.add(U32.add(3, ex), li), Bool.pick(U32, U32.is_eq(k, 4), U32.add(U32.add(U32.add(2, Bool.pick(U32, U32.is_ge(base, 8), 1, 0)), ex), li), U32.add(3, ex))))), lbls}))
    case 1n+p P1St{Con{XAluRR{+op, +d, +s}, +t}, _, off, lbls}: (+ok = elf_head_is_mask32(t, d); elf_pass1_go(p, do_lut, lcnt, P1St{t, Bool.pick(Nat, ok, 2n, 0n), U32.add(off, Bool.pick(U32, ok, elf_alu_rr32_len(op, d, s), Bool.pick(U32, Bool.and(U32.is_eq(op, 7), Bool.and(U32.is_eq(d, s), U32.is_lt(d, 8))), 2, 3))), lbls}))
    case 1n+p P1St{Con{XAluRI{+op, +d, +imm}, +t}, _, off, lbls}: (+ok = elf_head_is_mask32(t, d); +no = U32.add(off, Bool.pick(U32, ok, elf_alu_ri32_len(d, imm), Bool.pick(U32, elf_is_simm8(imm), 4, 7))); elf_pass1_go(p, do_lut, lcnt, elf_p1_lut(elf_alu_lut(do_lut, op, d, ok, lcnt, t), no, no, Bool.pick(Nat, ok, 2n, 0n), t, lbls)))
    case 1n+p P1St{Con{XMul{+d, +s}, +t}, _, off, lbls}: (+ok = elf_head_is_mask32(t, d); elf_pass1_go(p, do_lut, lcnt, P1St{t, Bool.pick(Nat, ok, 2n, 0n), U32.add(off, elf_mul_len(ok, d, s)), lbls}))
    case 1n+p P1St{Con{XShift{8, +d, +amt, False{}}, +t}, _, off, lbls}: (+sc = elf_shl3_code(Bool.and(U32.is_eq(amt, 3), U32.is_ne(d, 4)), d, t); +ok_shl = Bool.and(U32.is_zero(sc), Bool.and(U32.is_lt(amt, 32), elf_head_is_mask32(t, d))); +ok_mov = Bool.and(U32.is_eq(amt, 32), elf_head_is_shr32(t, d)); elf_pass1_go(p, do_lut, lcnt, P1St{t, elf_shl_skip(sc, U32.and(U32.shrn(sc, 4n), 7), ok_shl, ok_mov), U32.add(off, Bool.pick(U32, U32.is_ne(sc, 0), elf_sib8_len(U32.and(sc, 15)), Bool.pick(U32, ok_shl, elf_shl32_len(d, amt), Bool.pick(U32, ok_mov, elf_mov32_len(d), Bool.pick(U32, U32.is_eq(amt, 1), 3, 4))))), lbls}))
    case 1n+p P1St{Con{inst, t}, _, off, lbls}: elf_pass1_go(p, do_lut, lcnt, P1St{t, 0n, U32.add(off, elf_inst_len(inst)), lbls})
type TextAcc is Data:
  TextAcc{buf: ByteBuf, rels: List<&2, ElfReloc>}
def elf_un_ta(-R: Type, ta: TextAcc, k: ByteBuf -> List<&2, ElfReloc> -> R) -> R:
  TextAcc{b, rels} = ta
  k(b, rels)
def e_b1(r: List<&2, U32>, a: U32) -> List<&2, U32>: Con{U32.and(a, 255), r}
def e_b2(r: List<&2, U32>, a: U32, b: U32) -> List<&2, U32>: Con{U32.and(b, 255), Con{U32.and(a, 255), r}}
def e_b3(r: List<&2, U32>, a: U32, b: U32, c: U32) -> List<&2, U32>: Con{U32.and(c, 255), Con{U32.and(b, 255), Con{U32.and(a, 255), r}}}
def e_b4(r: List<&2, U32>, a: U32, b: U32, c: U32, d: U32) -> List<&2, U32>: Con{U32.and(d, 255), Con{U32.and(c, 255), Con{U32.and(b, 255), Con{U32.and(a, 255), r}}}}
def e_u32(r: List<&2, U32>, +v: U32) -> List<&2, U32>: Con{U32.and(U32.shrn(v, 24n), 255), Con{U32.and(U32.shrn(v, 16n), 255), Con{U32.and(U32.shrn(v, 8n), 255), Con{U32.and(v, 255), r}}}}
def elf_opt_b(cond: Bool, b: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, cond, Con{b, r}, r)
def elf_emit_disp(+md: U32, +disp: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, U32.is_zero(md), r, Bool.pick(List<&2, U32>, U32.is_eq(md, 1), e_b1(r, disp), e_u32(r, disp)))
def elf_emit_modrm_mem(reg: U32, +base: U32, +disp: U32, r: List<&2, U32>) -> List<&2, U32>: (+md = elf_mem_mod(base, disp); elf_emit_disp(md, disp, elf_opt_b(U32.is_eq(U32.and(base, 7), 4), 36, Con{elf_modrm(md, reg, base), r})))
def elf_emit_mem_rev(+w: U32, opc: U32, +reg: U32, +base: U32, disp: U32, r: List<&2, U32>) -> List<&2, U32>: elf_emit_modrm_mem(reg, base, disp, e_b1(elf_opt_b(Bool.or(U32.is_ne(w, 0), elf_is_hi(reg, base)), elf_rex(w, reg, 0, base), r), opc))
def elf_emit_mem_w(+w: U32, opc: U32, +reg: U32, +base: U32, +disp: U32, off: U32, r: List<&2, U32>) -> ByteBuf:
  ByteBuf{U32.add(off, U32.add(U32.add(2, Bool.to_u32(Bool.or(U32.is_ne(w, 0), elf_is_hi(reg, base)))), elf_mem_extra(base, disp))), elf_emit_mem_rev(w, opc, reg, base, disp, r)}
def elf_emit_vex(mp: U32, pp: U32, vv: U32, +reg: U32, +rm: U32, r: List<&2, U32>) -> List<&2, U32>: e_b3(r, 196, U32.or(U32.or(64, mp), U32.or(U32.shln(U32.xor(U32.and(U32.shrn(reg, 3n), 1), 1), 7n), U32.shln(U32.xor(U32.and(U32.shrn(rm, 3n), 1), 1), 5n))), U32.or(U32.or(4, pp), U32.shln(U32.and(U32.sub(15, vv), 15), 3n)))
def elf_emit_vex_mem(mp: U32, pp: U32, opc: U32, +reg: U32, +base: U32, disp: U32, r: List<&2, U32>) -> List<&2, U32>: elf_emit_modrm_mem(reg, base, disp, e_b1(elf_emit_vex(mp, pp, 0, reg, base, r), opc))
def elf_emit_xmm_mem(+pfx: U32, opc: U32, +reg: U32, +base: U32, disp: U32, r: List<&2, U32>) -> List<&2, U32>: elf_emit_modrm_mem(reg, base, disp, e_b2(elf_opt_b(elf_is_hi(reg, base), elf_rex(0, reg, 0, base), elf_opt_b(U32.is_ne(pfx, 0), pfx, r)), 15, opc))
def elf_xmm_rr_opc(+op: U32) -> U32: (+o = Bool.pick(U32, Bool.and(U32.is_ge(op, 8), U32.is_le(op, 12)), U32.sub(op, 8), op); Bool.pick(U32, U32.is_eq(o, 0), 88, Bool.pick(U32, U32.is_eq(o, 1), 92, Bool.pick(U32, U32.is_eq(o, 2), 89, Bool.pick(U32, U32.is_eq(o, 3), 94, Bool.pick(U32, U32.is_eq(o, 4), 81, Bool.pick(U32, U32.is_eq(o, 5), 46, Bool.pick(U32, U32.is_eq(o, 6), 87, Bool.pick(U32, U32.is_eq(o, 13), 198, 40)))))))))
def elf_emit_vex_rr(+op: U32, +dst: U32, +src: U32, r: List<&2, U32>) -> List<&2, U32>: (+bo = U32.and(op, 15); +is_bl = U32.is_eq(bo, 12); +is_cm = Bool.or(U32.is_eq(bo, 8), U32.is_eq(bo, 9)); elf_opt_b(Bool.or(is_bl, is_cm), Bool.pick(U32, is_bl, 16, Bool.pick(U32, U32.is_eq(bo, 8), 1, 2)), e_b2(elf_emit_vex(Bool.pick(U32, is_bl, 3, 1), Bool.pick(U32, is_bl, 1, 0), U32.and(U32.shrn(op, 4n), 15), dst, src, r), Bool.pick(U32, is_bl, 74, Bool.pick(U32, is_cm, 194, Bool.pick(U32, U32.is_eq(bo, 5), 95, elf_xmm_rr_opc(bo)))), elf_modrm(3, dst, src))))
def elf_emit_xmm_rr(+op: U32, +dst: U32, +src: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, U32.is_ge(op, 256), elf_emit_vex_rr(op, dst, src, r), Bool.pick(List<&2, U32>, U32.is_eq(op, 14), e_b3(r, 197, 248, 119), elf_opt_b(U32.is_eq(op, 13), 0, e_b3(elf_opt_b(elf_is_hi(dst, src), elf_rex(0, dst, 0, src), elf_opt_b(U32.is_lt(op, 5), 243, r)), 15, elf_xmm_rr_opc(op), elf_modrm(3, dst, src)))))
def elf_emit_cvt(+op: U32, +dst: U32, +src: U32, r: List<&2, U32>) -> List<&2, U32>: (+is_m = U32.is_ge(op, 2); +reg = Bool.pick(U32, U32.is_eq(op, 3), src, dst); +rm = Bool.pick(U32, U32.is_eq(op, 3), dst, src); e_b3(elf_opt_b(Bool.or(Bool.not(is_m), elf_is_hi(reg, rm)), elf_rex(Bool.pick(U32, is_m, 0, 1), reg, 0, rm), Con{Bool.pick(U32, is_m, 102, 243), r}), 15, Bool.pick(U32, U32.is_eq(op, 0), 42, Bool.pick(U32, U32.is_eq(op, 1), 44, Bool.pick(U32, U32.is_eq(op, 2), 110, 126))), elf_modrm(3, reg, rm)))
def elf_emit_shl32_imm(is_one: Bool, +sub: U32, +dst: U32, amt: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, is_one, e_b2(r, 209, elf_modrm(3, sub, dst)), e_b3(r, 193, elf_modrm(3, sub, dst), amt))
def elf_emit_shift(by_cl: Bool, +sub: U32, +dst: U32, +amt: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, by_cl, e_b3(r, elf_rex(1, 0, 0, dst), 211, elf_modrm(3, sub, dst)), elf_emit_shl32_imm(U32.is_eq(amt, 1), sub, dst, amt, Con{elf_rex(1, 0, 0, dst), r}))
def elf_emit_alu_rr(is_zero: Bool, op: U32, +dst: U32, +src: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, is_zero, e_b2(elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, dst, 0, dst), r), 49, elf_modrm(3, dst, dst)), e_b3(r, elf_rex(1, src, 0, dst), elf_alu_rr_op(op), elf_modrm(3, src, dst)))
def elf_emit_imm_rm(is_i8: Bool, +sub: U32, +dst: U32, +imm: U32, +r: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, is_i8, e_b3(r, 131, elf_modrm(3, sub, dst), imm), e_u32(e_b2(r, 129, elf_modrm(3, sub, dst)), imm))
def elf_emit_sib8(opc: U32, +dst: U32, +base: U32, +idx: U32, r: List<&2, U32>) -> List<&2, U32>: (+md = Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0); elf_emit_disp(md, 0, e_b4(r, elf_rex(1, dst, idx, base), opc, elf_modrm(md, dst, 4), U32.or(192, U32.or(U32.shln(U32.and(idx, 7), 3n), U32.and(base, 7))))))
def elf_em_rr(+ok: Bool, +op: U32, +d: U32, +s: U32, b: ByteBuf) -> ByteBuf:
  ByteBuf{off, +rev} = b
  +is_z = Bool.and(U32.is_eq(op, 7), U32.is_eq(d, s))
  ByteBuf{U32.add(off, Bool.pick(U32, ok, elf_alu_rr32_len(op, d, s), Bool.pick(U32, Bool.and(is_z, U32.is_lt(d, 8)), 2, 3))), Bool.pick(List<&2, U32>, ok, e_b2(elf_opt_b(elf_is_hi(d, s), elf_rex(0, s, 0, d), rev), elf_alu_rr_op(op), elf_modrm(3, s, d)), elf_emit_alu_rr(is_z, op, d, s, rev))}
def elf_em_ri(+ok: Bool, op: U32, +d: U32, +imm: U32, b: ByteBuf) -> ByteBuf:
  ByteBuf{off, rev} = b
  +rx = Bool.or(Bool.not(ok), U32.is_ge(d, 8))
  ByteBuf{U32.add(off, U32.add(Bool.to_u32(rx), Bool.pick(U32, elf_is_simm8(imm), 3, 6))), elf_emit_imm_rm(elf_is_simm8(imm), elf_alu_ri_sub(op), d, imm, elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), 0, 0, d), rev))}
def elf_em_mul_go(is_lea: Bool, +ok: Bool, +d: U32, +s: U32, b: ByteBuf) -> ByteBuf:
  match is_lea b:
    case True{} ByteBuf{off, rev}:
      +md = Bool.pick(U32, U32.is_eq(U32.and(d, 7), 5), 1, 0)
      +rx = Bool.or(Bool.not(ok), U32.is_ge(d, 8))
      ByteBuf{U32.add(off, U32.add(3, U32.add(Bool.to_u32(rx), md))), elf_emit_disp(md, 0, e_b3(elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), d, d, d), rev), 141, elf_modrm(md, d, 4), U32.or(U32.shln(U32.sub(s, 16), 6n), U32.or(U32.shln(U32.and(d, 7), 3n), U32.and(d, 7)))))}
    case False{} ByteBuf{off, rev}:
      +rx = Bool.or(Bool.not(ok), elf_is_hi(d, s))
      ByteBuf{U32.add(off, Bool.pick(U32, rx, 4, 3)), e_b3(elf_opt_b(rx, elf_rex(Bool.pick(U32, ok, 0, 1), d, 0, s), rev), 15, 175, elf_modrm(3, d, s))}
def elf_em_shl(is_sib: Bool, +k: U32, +base: U32, val: U32, ok_shl: Bool, ok_mov: Bool, +d: U32, +amt: U32, b: ByteBuf) -> ByteBuf:
  match is_sib ok_shl ok_mov b:
    case True{} _ _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_sib8_len(base)), elf_emit_sib8(Bool.pick(U32, U32.is_eq(k, 1), 139, Bool.pick(U32, U32.is_eq(k, 4), 137, 141)), Bool.pick(U32, U32.is_eq(k, 3), base, Bool.pick(U32, U32.is_eq(k, 4), val, d)), base, d, rev)}
    case False{} True{} _ ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_shl32_len(d, amt)), elf_emit_shl32_imm(U32.is_eq(amt, 1), 4, d, amt, elf_opt_b(U32.is_ge(d, 8), elf_rex(0, 0, 0, d), rev))}
    case False{} False{} True{} ByteBuf{off, rev}: ByteBuf{U32.add(off, elf_mov32_len(d)), e_b2(elf_opt_b(U32.is_ge(d, 8), elf_rex(0, d, 0, d), rev), 137, elf_modrm(3, d, d))}
    case False{} False{} False{} ByteBuf{off, rev}: ByteBuf{U32.add(off, Bool.pick(U32, U32.is_eq(amt, 1), 3, 4)), elf_emit_shift(False{}, 4, d, amt, rev)}
def elf_em_load_fin(is_rmw: Bool, i8: Bool, +imm: U32, b1: ByteBuf) -> ByteBuf:
  ByteBuf{+o1, +r1} = b1
  Bool.pick(ByteBuf, is_rmw, Bool.pick(ByteBuf, i8, ByteBuf{U32.add(o1, 1), e_b1(r1, imm)}, ByteBuf{U32.add(o1, 4), e_u32(r1, imm)}), ByteBuf{o1, r1})
def elf_em_load(+k: U32, +opc: U32, +rg: U32, d: U32, +base: U32, +disp: U32, +imm: U32, b: ByteBuf) -> ByteBuf:
  ByteBuf{off, rev} = b
  +i8 = elf_is_simm8(imm)
  +is_rmw = U32.is_ge(k, 3)
  elf_em_load_fin(is_rmw, i8, imm, elf_emit_mem_w(Bool.to_u32(Bool.or(U32.is_zero(k), Bool.or(U32.is_eq(k, 1), U32.is_eq(k, 3)))), Bool.pick(U32, is_rmw, Bool.pick(U32, i8, 131, 129), Bool.pick(U32, U32.is_zero(k), 139, opc)), Bool.pick(U32, is_rmw, opc, Bool.pick(U32, U32.is_zero(k), d, rg)), base, disp, off, rev))
def elf_emit_inst_rev(inst: X64Inst, +rev: List<&2, U32>) -> List<&2, U32>:
  match inst:
    case XMovRR{+dst, +src}: e_b3(rev, elf_rex(1, src, 0, dst), 137, elf_modrm(3, src, dst))
    case XMovRI32{+dst, imm}: e_u32(e_b1(elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, 0, 0, dst), rev), U32.add(184, U32.and(dst, 7))), imm)
    case XMovRI64{+dst, lo, hi}: e_u32(e_u32(e_b2(rev, elf_rex(1, 0, 0, dst), U32.add(184, U32.and(dst, 7))), lo), hi)
    case XStore{base, disp, src}: elf_emit_mem_rev(1, 137, src, base, disp, rev)
    case XShift{10, +dst, +amt, False{}}: elf_emit_shl32_imm(U32.is_eq(amt, 1), 7, dst, amt, elf_opt_b(U32.is_ge(dst, 8), elf_rex(0, 0, 0, dst), rev))
    case XShift{op, dst, amt, by_cl}: elf_emit_shift(by_cl, Bool.pick(U32, U32.is_eq(op, 8), 4, 5), dst, amt, rev)
    case XDiv{+src, is_signed}: e_b3(rev, elf_rex(1, 0, 0, src), 247, elf_modrm(3, Bool.pick(U32, is_signed, 7, 6), src))
    case XCmpRR{+lhs, +rhs}: e_b3(rev, elf_rex(1, rhs, 0, lhs), 57, elf_modrm(3, rhs, lhs))
    case XCmpRI{+lhs, +imm}: elf_emit_imm_rm(elf_is_simm8(imm), 7, lhs, imm, elf_opt_b(U32.is_ge(lhs, 8), elf_rex(0, 0, 0, lhs), rev))
    case XTestRR{+lhs, +rhs}: e_b3(rev, elf_rex(1, rhs, 0, lhs), 133, elf_modrm(3, rhs, lhs))
    case XSetcc{cc, +dst}: e_b3(elf_opt_b(U32.is_ge(dst, 4), elf_rex(0, 0, 0, dst), rev), 15, U32.add(144, U32.and(cc, 15)), elf_modrm(3, 0, dst))
    case XCmov{cc, +dst, +src}: e_b4(rev, elf_rex(1, dst, 0, src), 15, U32.add(64, U32.and(cc, 15)), elf_modrm(3, dst, src))
    case XPush{+reg}: e_b1(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), U32.add(80, U32.and(reg, 7)))
    case XPop{+reg}: e_b1(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), U32.add(88, U32.and(reg, 7)))
    case XSubRsp{+imm}: elf_emit_imm_rm(elf_is_simm8(imm), 5, 4, imm, Con{elf_rex(1, 0, 0, 4), rev})
    case XAddRsp{+imm}: elf_emit_imm_rm(elf_is_simm8(imm), 0, 4, imm, Con{elf_rex(1, 0, 0, 4), rev})
    case XCallReg{+reg}: e_b2(elf_opt_b(U32.is_ge(reg, 8), elf_rex(0, 0, 0, reg), rev), 255, elf_modrm(3, 2, reg))
    case XRet{}: Con{195, rev}
    case XXmmRR{op, dst, src}: elf_emit_xmm_rr(op, dst, src, rev)
    case XXmmLoad{+dst, +base, +disp}: Bool.pick(List<&2, U32>, U32.is_ge(dst, 32), elf_emit_vex_mem(Bool.pick(U32, U32.is_ge(dst, 48), 2, 1), Bool.pick(U32, U32.is_ge(dst, 48), 1, 0), Bool.pick(U32, U32.is_ge(dst, 48), 24, 16), U32.and(dst, 15), base, disp, rev), elf_emit_xmm_mem(Bool.pick(U32, U32.is_ge(dst, 16), 0, 243), 16, U32.and(dst, 15), base, disp, rev))
    case XXmmStore{+base, +disp, +src}: Bool.pick(List<&2, U32>, U32.is_ge(src, 48), elf_emit_vex_mem(1, 0, 17, U32.and(src, 15), base, disp, rev), elf_emit_xmm_mem(Bool.pick(U32, U32.is_ge(src, 32), 243, Bool.pick(U32, U32.is_ge(src, 16), 0, 102)), Bool.pick(U32, U32.is_ge(src, 16), 17, 214), U32.and(src, 15), base, disp, rev))
    case XCvt{op, dst, src}: elf_emit_cvt(op, dst, src, rev)
    case XExtReloc{3, _, _}: e_b3(rev, 139, 4, 136)
    case _: rev
def elf_emit_inst_bytes_go(+inst: X64Inst, off: U32, rev: List<&2, U32>) -> ByteBuf: ByteBuf{U32.add(off, elf_inst_len(inst)), elf_emit_inst_rev(inst, rev)}
def elf_emit_lut_ld(is_xmm: Bool, +dst: U32, +base: U32, +idx: U32, +rev: List<&2, U32>) -> List<&2, U32>: (+md = Bool.pick(U32, U32.is_eq(U32.and(base, 7), 5), 1, 0); +sib = U32.or(128, U32.or(U32.shln(U32.and(idx, 7), 3n), U32.and(base, 7))); +rx = Bool.or(U32.is_ge(dst, 8), Bool.or(U32.is_ge(idx, 8), U32.is_ge(base, 8))); elf_emit_disp(md, 0, Bool.pick(List<&2, U32>, is_xmm, e_b4(elf_opt_b(rx, elf_rex(0, dst, idx, base), Con{243, rev}), 15, 16, elf_modrm(md, dst, 4), sib), e_b3(elf_opt_b(rx, elf_rex(0, dst, idx, base), rev), 139, elf_modrm(md, dst, 4), sib))))
def elf_emit_lut_cp(same: Bool, is_xmm: Bool, +dst: U32, +copy: U32, +rev: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, same, rev, Bool.pick(List<&2, U32>, is_xmm, elf_emit_xmm_rr(7, copy, dst, rev), e_b3(rev, elf_rex(1, dst, 0, copy), 137, elf_modrm(3, dst, copy))))
def elf_emit_u32_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf: opt_foldl0(~U32, ~ByteBuf, ~(x => a => bb_emit_u32(a, x)), xs, b)
type EmitSt is Data:
  EmitSt{xs: List<&2, X64Inst>, skip: Nat, buf: ByteBuf, rels: List<&2, ElfReloc>, luts: ByteBuf}
def elf_emit_lut(lh: LutHit, +lbls: RaVec<U32>, miss_sk: Nat, miss_b: ByteBuf, t: List<&2, X64Inst>, b: ByteBuf, rels: List<&2, ElfReloc>, +luts: ByteBuf) -> EmitSt:
  match lh b:
    case LutHit{True{}, +is_xmm, +idx, +dst, +copy, +gtmp, join, def_lbl, +n, vals, rest} ByteBuf{+off, rev}:
      +base = Bool.pick(U32, is_xmm, gtmp, dst)
      +i8 = elf_is_simm8(n)
      +o2 = U32.add(off, Bool.pick(U32, i8, 10, 13))
      +o_end = U32.add(off, elf_lut_len(is_xmm, idx, dst, copy, gtmp, n))
      r3 = e_u32(e_b3(e_u32(e_b2(elf_emit_imm_rm(i8, 7, idx, n, Con{elf_rex(1, 0, 0, idx), rev}), 15, 131), U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(def_lbl), lbls), o2)), elf_rex(1, base, 0, 0), 141, elf_modrm(0, base, 5)), 0)
      EmitSt{rest, 0n, ByteBuf{o_end, e_u32(Con{233, elf_emit_lut_cp(U32.is_eq(copy, dst), is_xmm, dst, copy, elf_emit_lut_ld(is_xmm, dst, base, idx, r3))}, U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(join), lbls), o_end))}, Con{ElfReloc{U32.add(o2, 3), ".rodata", 2, U32.sub(bb_len(luts), 4)}, rels}, elf_emit_u32_arr(vals, luts)}
    case LutHit{False{}, _, _, _, _, _, _, _, _, _, _} _: EmitSt{t, miss_sk, miss_b, rels, luts}
def elf_emit_insts_go(fuel: Nat, +do_lut: Bool, +lcnt: RaVec<U32>, +lbls: RaVec<U32>, st: EmitSt) -> ByteBuf & (List<&2, ElfReloc> & ByteBuf):
  match fuel st:
    case 0n EmitSt{_, _, b, rels, luts}: (b, (rels, luts))
    case _ EmitSt{Nil{}, _, b, rels, luts}: (b, (rels, luts))
    case 1n+p EmitSt{Con{_, t}, 1n+sk, b, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, sk, b, rels, luts})
    case 1n+p EmitSt{Con{XExtReloc{1, _, v}, t}, _, b, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, b, rels, bb_emit_u32(luts, v)})
    case 1n+p EmitSt{Con{XExtReloc{2, _, +reg}, t}, _, ByteBuf{+off, rev}, rels, +luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 7), e_u32(e_b3(rev, elf_rex(1, reg, 0, 0), 141, elf_modrm(0, reg, 5)), 0)}, Con{ElfReloc{U32.add(off, 3), ".rodata", 2, U32.sub(bb_len(luts), 4)}, rels}, luts})
    case 1n+p EmitSt{Con{XTestRR{+a, +b0}, Con{XJcc{5, +nlbl}, +body}}, _, ByteBuf{+off, +rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, elf_emit_lut(elf_lut_start(Bool.and(do_lut, U32.is_eq(a, b0)), lcnt, a, nlbl, body), lbls, 0n, elf_emit_inst_bytes_go(XTestRR{a, b0}, off, rev), Con{XJcc{5, nlbl}, body}, ByteBuf{off, rev}, rels, luts))
    case 1n+p EmitSt{Con{XCmpRI{+a, 0}, Con{XJcc{5, +nlbl}, +body}}, _, ByteBuf{+off, +rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, elf_emit_lut(elf_lut_start(do_lut, lcnt, a, nlbl, body), lbls, 0n, elf_emit_inst_bytes_go(XCmpRI{a, 0}, off, rev), Con{XJcc{5, nlbl}, body}, ByteBuf{off, rev}, rels, luts))
    case 1n+p EmitSt{Con{XLoad{+d, +base, +disp}, +t}, _, b, rels, luts}: (+lc = elf_load_code(d, base, disp, t); +k = U32.and(lc, 15); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, elf_load_skip(k), elf_em_load(k, U32.and(U32.shrn(lc, 4n), 255), U32.shrn(lc, 12n), d, base, disp, elf_head_ri_imm(t), b), rels, luts}))
    case 1n+p EmitSt{Con{XAluRR{op, +d, s}, +t}, _, b, rels, luts}: (+ok = elf_head_is_mask32(t, d); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, Bool.pick(Nat, ok, 2n, 0n), elf_em_rr(ok, op, d, s, b), rels, luts}))
    case 1n+p EmitSt{Con{XAluRI{+op, +d, +imm}, +t}, _, b, rels, luts}: (+ok = elf_head_is_mask32(t, d); +b1 = elf_em_ri(ok, op, d, imm, b); elf_emit_insts_go(p, do_lut, lcnt, lbls, elf_emit_lut(elf_alu_lut(do_lut, op, d, ok, lcnt, t), lbls, Bool.pick(Nat, ok, 2n, 0n), b1, t, b1, rels, luts)))
    case 1n+p EmitSt{Con{XMul{+d, +s}, +t}, _, b, rels, luts}: (+ok = elf_head_is_mask32(t, d); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, Bool.pick(Nat, ok, 2n, 0n), elf_em_mul_go(U32.is_ge(s, 17), ok, d, s, b), rels, luts}))
    case 1n+p EmitSt{Con{XShift{8, +d, +amt, False{}}, +t}, _, b, rels, luts}: (+sc = elf_shl3_code(Bool.and(U32.is_eq(amt, 3), U32.is_ne(d, 4)), d, t); +k = U32.and(U32.shrn(sc, 4n), 7); +ok_shl = Bool.and(U32.is_zero(sc), Bool.and(U32.is_lt(amt, 32), elf_head_is_mask32(t, d))); +ok_mov = Bool.and(U32.is_eq(amt, 32), elf_head_is_shr32(t, d)); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, elf_shl_skip(sc, k, ok_shl, ok_mov), elf_em_shl(U32.is_ne(k, 0), k, U32.and(sc, 15), U32.shrn(sc, 8n), ok_shl, ok_mov, d, amt, b), rels, luts}))
    case 1n+p EmitSt{Con{XLeaRip{+dst, sym}, t}, _, ByteBuf{+off, rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 7), e_u32(e_b3(rev, elf_rex(1, dst, 0, 0), 141, elf_modrm(0, dst, 5)), 0)}, Con{ElfReloc{U32.add(off, 3), sym, 2, U32.sub(0, 4)}, rels}, luts})
    case 1n+p EmitSt{Con{XJmp{target}, t}, _, ByteBuf{off, rev}, rels, luts}: (+n_off = U32.add(off, 5); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{n_off, e_u32(Con{233, rev}, U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls), n_off))}, rels, luts}))
    case 1n+p EmitSt{Con{XJcc{cc, target}, t}, _, ByteBuf{off, rev}, rels, luts}: (+n_off = U32.add(off, 6); elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{n_off, e_u32(e_b2(rev, 15, U32.add(128, U32.and(cc, 15))), U32.sub(ra_vec_get(U32, 9n, 0, elf_lbl_key(target), lbls), n_off))}, rels, luts}))
    case 1n+p EmitSt{Con{XCallSym{sym}, t}, _, ByteBuf{+off, rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 5), e_u32(Con{232, rev}, 0)}, Con{ElfReloc{U32.add(off, 1), sym, 4, U32.sub(0, 4)}, rels}, luts})
    case 1n+p EmitSt{Con{XJmpSym{sym}, t}, _, ByteBuf{+off, rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, ByteBuf{U32.add(off, 5), e_u32(Con{233, rev}, 0)}, Con{ElfReloc{U32.add(off, 1), sym, 4, U32.sub(0, 4)}, rels}, luts})
    case 1n+p EmitSt{Con{inst, t}, _, ByteBuf{off, rev}, rels, luts}: elf_emit_insts_go(p, do_lut, lcnt, lbls, EmitSt{t, 0n, elf_emit_inst_bytes_go(inst, off, rev), rels, luts})
# ELF Symbol Table & Alignment Helpers
type ElfSym is Data:
  ElfSym{name: String, info: U32, shndx: U32, value: U32, size: U32}
type TextRes is Data:
  TextRes{buf: ByteBuf, rels: List<&2, ElfReloc>, lsyms: List<&2, ElfSym>, gsyms: List<&2, ElfSym>, luts: ByteBuf}
def elf_pad_to(+b: ByteBuf, +align: U32) -> ByteBuf: (+rem = U32.mod(bb_len(b), align); bb_emit_zeros(b, Bool.pick(U32, U32.is_zero(rem), 0, U32.sub(align, rem))))
def elf_encode_fn_fin(name: String, +is_glob: Bool, +start: U32, +ls: List<&2, ElfSym>, +gs: List<&2, ElfSym>, ea: ByteBuf & (List<&2, ElfReloc> & ByteBuf)) -> TextRes:
  (+b2, (rels2, luts2)) = ea
  +sym: ElfSym = ElfSym{name, Bool.pick(U32, is_glob, 18, 2), 1, start, U32.sub(bb_len(b2), start)}
  TextRes{b2, rels2, Bool.pick(List<&2, ElfSym>, is_glob, ls, Con{sym, ls}), Bool.pick(List<&2, ElfSym>, is_glob, Con{sym, gs}, gs), luts2}
def elf_encode_fns_go(+do_lut: Bool, fns: List<&2, X64Fn>, tr: TextRes) -> TextRes:
  match fns tr:
    case Nil{} TextRes{b, rels, ls, gs, luts}: TextRes{b, b5k_list_rev(ElfReloc, rels), ls, gs, luts}
    case Con{X64Fn{name, +is_glob, +insts}, t} TextRes{b0, rels0, +ls, +gs, luts0}: (+b1 = elf_pad_to(b0, 16); +start = bb_len(b1); +n_insts = b5k_list_len(X64Inst, insts); +lcnt = opt_if(RaVec<U32>, Bool.and(do_lut, U32.is_ge(n_insts, 25)), _ => peep_count_lbls(insts, RVEmpty{}), _ => RVEmpty{}); +fuel = U32.to_nat(n_insts); elf_encode_fns_go(do_lut, t, elf_encode_fn_fin(name, is_glob, start, ls, gs, elf_emit_insts_go(fuel, do_lut, lcnt, elf_pass1_go(fuel, do_lut, lcnt, P1St{insts, 0n, start, RVEmpty{}}), EmitSt{insts, 0n, b1, rels0, luts0}))))
# P111 Metadata & Core Constructor Normalization
def elf_core_ctors() -> List<&2, IrCtor>: [IrCtor{0, "SNil", 0, False{}}, IrCtor{1, "SCon", 2, False{}}, IrCtor{2, "WNil", 0, False{}}, IrCtor{3, "WCon", 2, False{}}, IrCtor{4, "Nil", 0, False{}}, IrCtor{5, "Con", 2, False{}}, IrCtor{6, "Tuple", 2, False{}}, IrCtor{7, "Unit", 0, False{}}, IrCtor{8, "None", 0, False{}}, IrCtor{9, "Some", 1, False{}}, IrCtor{10, "Fail", 1, False{}}, IrCtor{11, "Done", 1, False{}}, IrCtor{12, "Emit", 1, False{}}, IrCtor{13, "Halt", 2, False{}}, IrCtor{14, "True", 0, False{}}, IrCtor{15, "False", 0, False{}}, IrCtor{16, "LT", 0, False{}}, IrCtor{17, "EQ", 0, False{}}, IrCtor{18, "GT", 0, False{}}, IrCtor{19, "Chr", 1, False{}}, IrCtor{20, "Zero", 0, False{}}, IrCtor{21, "Succ", 1, False{}}, IrCtor{22, "Exit", 1, False{}}, IrCtor{23, "Pair", 2, False{}}, IrCtor{24, "Inl", 1, False{}}, IrCtor{25, "Inr", 1, False{}}]
def elf_has_ctor_name(ctors: List<&2, IrCtor>, +nm: String) -> Bool:
  match ctors:
    case Nil{}: False{}
    case Con{IrCtor{_, cname, _, _}, t}: Bool.or(b5k_str_eq(cname, nm), elf_has_ctor_name(t, nm))
def elf_merge_core_go(core: List<&2, IrCtor>, +existing: List<&2, IrCtor>, +nc: U32, +acc: List<&2, IrCtor>) -> List<&2, IrCtor>:
  match core:
    case Nil{}: b5k_list_app(IrCtor, existing, b5k_list_rev(IrCtor, acc))
    case Con{IrCtor{_, +nm, ar, hot}, t}: (+has = elf_has_ctor_name(existing, nm); elf_merge_core_go(t, existing, Bool.pick(U32, has, nc, U32.add(nc, 1)), Bool.pick(List<&2, IrCtor>, has, acc, Con{IrCtor{nc, nm, ar, hot}, acc})))
def elf_fid_meta(fns: List<&2, IrFn>, b: ByteBuf, ma: U32) -> ByteBuf & U32:
  match fns:
    case Nil{}: (b, ma)
    case Con{IrFn{_, _, +ar, _, _, _, _, _}, t}: elf_fid_meta(t, bb_emit_u8(b, ar), U32.max(ma, ar))
def elf_cid_meta(ctors: List<&2, IrCtor>, b: ByteBuf, nms: List<&2, String>) -> ByteBuf & List<&2, String>:
  match ctors:
    case Nil{}: (b, b5k_list_rev(String, nms))
    case Con{IrCtor{_, nm, ar, _}, t}: elf_cid_meta(t, bb_emit_u8(b, ar), Con{nm, nms})
# Whole-Program Per-Constructor cid_hot Analysis (capabilities = 9)
def elf_bs_bit(k: U32) -> U32: U32.shln(1, U32.to_nat(U32.and(k, 31)))
def elf_bs_word(d: Nat, k: U32, m: RaVec<U32>) -> U32: ra_vec_get(U32, d, 0, U32.shrn(k, 5n), m)
def elf_bs_has(d: Nat, +k: U32, m: RaVec<U32>) -> Bool: U32.is_ne(U32.and(elf_bs_word(d, k, m), elf_bs_bit(k)), 0)
def elf_bs_set(d: Nat, +k: U32, w: U32, m: RaVec<U32>) -> RaVec<U32>: ra_vec_set(U32, d, U32.shrn(k, 5n), U32.or(w, elf_bs_bit(k)), m)
def elf_bs_mark(+d: Nat, ra: RaVec<U32> & Bool, +k: U32) -> RaVec<U32> & Bool:
  (+m, chg) = ra
  +miss = Bool.not(elf_bs_has(d, k, m))
  (opt_if(RaVec<U32>, miss, _ => elf_bs_set(d, k, elf_bs_word(d, k, m), m), _ => m), Bool.or(chg, miss))
def elf_reach_walk(go: Bool, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match go blks ops:
    case False{} _ _: ra
    case True{} Nil{} Nil{}: ra
    case True{} Con{IrBlock{_, ops1, TTailCall{cfid, _}}, t} Nil{}: elf_reach_walk(True{}, t, ops1, elf_bs_mark(4n, ra, cfid))
    case True{} Con{IrBlock{_, ops1, _}, t} Nil{}: elf_reach_walk(True{}, t, ops1, ra)
    case True{} _ Con{ICallDirect{_, cfid, _}, ot}: elf_reach_walk(True{}, blks, ot, elf_bs_mark(4n, ra, cfid))
    case True{} _ Con{ICallClosure{_, cfid, _}, ot}: elf_reach_walk(True{}, blks, ot, elf_bs_mark(4n, ra, cfid))
    case True{} _ Con{IApply{_, _, _}, ot}: elf_reach_walk(True{}, blks, ot, elf_bs_mark(4n, ra, 0))
    case True{} _ Con{_, ot}: elf_reach_walk(True{}, blks, ot, ra)
def elf_reach_fns(fns: List<&2, IrFn>, ra: RaVec<U32> & Bool) -> RaVec<U32> & Bool:
  match fns:
    case Nil{}: ra
    case Con{IrFn{fid, _, _, _, _, _, _, blks}, t}:
      (+m, +chg) = ra
      elf_reach_fns(t, elf_reach_walk(elf_bs_has(4n, fid, m), blks, Nil{}, (m, chg)))
def elf_reach_fix(fuel: Nat, +fns: List<&2, IrFn>, ra: RaVec<U32> & Bool) -> RaVec<U32>:
  match fuel ra:
    case 0n Tuple{m, _}: m
    case _ Tuple{m, False{}}: m
    case 1n+p Tuple{m, True{}}: elf_reach_fix(p, fns, elf_reach_fns(fns, (m, False{})))
type HotSt is Data:
  HotSt{hot_cid: RaVec<U32>, kept_param: RaVec<U32>, kept_ret: RaVec<U32>, chg: Bool}
type HotFnSt is Data:
  HotFnSt{kreg: RaVec<U32>, rchg: Bool, hs: HotSt}
def elf_hot_mark_reg(+rd: Nat, cond: Bool, fst: HotFnSt, +r: U32) -> HotFnSt:
  HotFnSt{+kr, +rc, +hs} = fst
  opt_if(HotFnSt, cond, _ => ra_un_pair(RaVec<U32>, Bool, HotFnSt, elf_bs_mark(rd, (kr, rc), r), kr1 => rc1 => HotFnSt{kr1, rc1, hs}), _ => HotFnSt{kr, rc, hs})
def elf_hot_mark_regs(+rd: Nat, cond: Bool, rs: List<&2, U32>, +fst: HotFnSt) -> HotFnSt: opt_if(HotFnSt, cond, _ => opt_foldl(~U32, ~Nat, ~HotFnSt, ~(d => r => st => elf_hot_mark_reg(d, True{}, st, r)), rd, rs, fst), _ => fst)
def elf_hot_mark_hs_if(+is_ret: Bool, cond: Bool, fst: HotFnSt, +k: U32) -> HotFnSt:
  match cond fst:
    case False{} _: fst
    case True{} HotFnSt{kr, rc, HotSt{+hc, kp, +kret, chg}}: ra_un_pair(RaVec<U32>, Bool, HotFnSt, elf_bs_mark(4n, (Bool.pick(RaVec<U32>, is_ret, kret, hc), chg), k), v1 => chg1 => (+v1a = v1; HotFnSt{kr, rc, HotSt{Bool.pick(RaVec<U32>, is_ret, hc, v1a), kp, Bool.pick(RaVec<U32>, is_ret, v1a, kret), chg1}}))
def elf_hot_any_reg(+rd: Nat, +kr: RaVec<U32>, rs: List<&2, U32>) -> Bool: Bool.not(opt_alll2(~U32, ~Nat, ~RaVec<U32>, ~(d => k => r => Bool.not(elf_bs_has(d, r, k))), rd, kr, rs))
def elf_hot_call_args_go(+rd: Nat, args: List<&2, U32>, mask: U32, fst: HotFnSt) -> HotFnSt:
  match args mask:
    case Nil{} _: fst
    case _ 0: fst
    case Con{a, t} +m: elf_hot_call_args_go(rd, t, U32.shr(m), elf_hot_mark_reg(rd, U32.is_ne(U32.and(m, 1), 0), fst, a))
def elf_hot_call_args(rd: Nat, cfid: U32, args: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  HotFnSt{kr, rc, HotSt{hc, +kp, kret, chg}} = fst
  elf_hot_call_args_go(rd, args, ra_vec_get(U32, 7n, 0, cfid, kp), HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}})
def elf_hot_ctor_fin(rd: Nat, cid: U32, fields: List<&2, U32>, fst2: HotFnSt) -> HotFnSt:
  HotFnSt{kr2, rc2, HotSt{+hc2, kp2, kret2, chg2}} = fst2
  elf_hot_mark_regs(rd, elf_bs_has(4n, cid, hc2), fields, HotFnSt{kr2, rc2, HotSt{hc2, kp2, kret2, chg2}})
def elf_hot_ctor(+rd: Nat, dst: U32, +cid: U32, fields: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  HotFnSt{+kr, rc, hs} = fst
  elf_hot_ctor_fin(rd, cid, fields, elf_hot_mark_hs_if(False{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, cid))
def elf_hot_arrop(+rd: Nat, aop: U32, args: List<&2, U32>, fst: HotFnSt) -> HotFnSt:
  match aop args:
    case 71 Con{_, Con{v, _}}: elf_hot_mark_reg(rd, True{}, fst, v)
    case 73 Con{_, Con{_, Con{v, _}}}: elf_hot_mark_reg(rd, True{}, fst, v)
    case 74 Con{_, Con{_, Con{v, _}}}: elf_hot_mark_reg(rd, True{}, fst, v)
    case 8 Con{v, _}: elf_hot_mark_reg(rd, True{}, fst, v)
    case 9 Con{l, Con{r, _}}: elf_hot_mark_reg(rd, True{}, elf_hot_mark_reg(rd, True{}, fst, l), r)
    case _ _: fst
def elf_hot_walk(+rd: Nat, +fid: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>, fst: HotFnSt) -> HotFnSt:
  match blks ops fst:
    case Nil{} Nil{} _: fst
    case Con{IrBlock{_, ops1, TRet{v}}, t} Nil{} HotFnSt{kr, rc, HotSt{hc, kp, +kret, chg}}: elf_hot_walk(rd, fid, t, b5k_list_rev(IrOp, ops1), elf_hot_mark_reg(rd, elf_bs_has(4n, fid, kret), HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}, v))
    case Con{IrBlock{_, ops1, TTailCall{+cfid, args}}, t} Nil{} HotFnSt{kr, rc, HotSt{hc, kp, +kret, chg}}: elf_hot_walk(rd, fid, t, b5k_list_rev(IrOp, ops1), elf_hot_call_args(rd, cfid, args, elf_hot_mark_hs_if(True{}, elf_bs_has(4n, fid, kret), HotFnSt{kr, rc, HotSt{hc, kp, kret, chg}}, cfid)))
    case Con{IrBlock{_, ops1, _}, t} Nil{} _: elf_hot_walk(rd, fid, t, b5k_list_rev(IrOp, ops1), fst)
    case _ Con{IKeep{_, src}, ot} _: elf_hot_walk(rd, fid, blks, ot, elf_hot_mark_reg(rd, True{}, fst, src))
    case _ Con{ICopy{dst, src}, ot} HotFnSt{+kr, rc, hs}: elf_hot_walk(rd, fid, blks, ot, elf_hot_mark_reg(rd, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, src))
    case _ Con{ICtor{dst, cid, fields}, ot} _: elf_hot_walk(rd, fid, blks, ot, elf_hot_ctor(rd, dst, cid, fields, fst))
    case _ Con{IReuse{dst, _, cid, fields}, ot} _: elf_hot_walk(rd, fid, blks, ot, elf_hot_ctor(rd, dst, cid, fields, fst))
    case _ Con{ITake{dsts, src}, ot} HotFnSt{+kr, rc, hs}: elf_hot_walk(rd, fid, blks, ot, elf_hot_mark_reg(rd, elf_hot_any_reg(rd, kr, dsts), HotFnSt{kr, rc, hs}, src))
    case _ Con{ICallDirect{dst, +cfid, args}, ot} HotFnSt{+kr, rc, hs}: elf_hot_walk(rd, fid, blks, ot, elf_hot_call_args(rd, cfid, args, elf_hot_mark_hs_if(True{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, cfid)))
    case _ Con{ICallClosure{dst, +cfid, +caps}, ot} HotFnSt{+kr, rc, hs}: elf_hot_walk(rd, fid, blks, ot, elf_hot_call_args(rd, cfid, caps, elf_hot_mark_regs(rd, elf_bs_has(rd, dst, kr), caps, HotFnSt{kr, rc, hs})))
    case _ Con{IApply{dst, clo, arg}, ot} HotFnSt{+kr, rc, hs}: elf_hot_walk(rd, fid, blks, ot, elf_hot_call_args(rd, 0, [clo, arg], elf_hot_mark_hs_if(True{}, elf_bs_has(rd, dst, kr), HotFnSt{kr, rc, hs}, 0)))
    case _ Con{IArrOp{_, aop, args}, ot} _: elf_hot_walk(rd, fid, blks, ot, elf_hot_arrop(rd, aop, args, fst))
    case _ Con{_, ot} _: elf_hot_walk(rd, fid, blks, ot, fst)
def elf_hot_fn_fix(fuel: Nat, +rd: Nat, +fid: U32, +blks: List<&2, IrBlock>, fst: HotFnSt) -> HotFnSt:
  match fuel fst:
    case 0n _: fst
    case _ HotFnSt{kr, False{}, hs}: HotFnSt{kr, False{}, hs}
    case 1n+p HotFnSt{kr, True{}, hs}: elf_hot_fn_fix(p, rd, fid, blks, elf_hot_walk(rd, fid, blks, Nil{}, HotFnSt{kr, False{}, hs}))
def elf_hot_fn_fin(rd: Nat, +fid: U32, +ar: U32, fst: HotFnSt) -> HotSt:
  HotFnSt{kr, _, HotSt{hc, +kp, kret, chg}} = fst
  +old = ra_vec_get(U32, 7n, 0, fid, kp)
  +nw = U32.or(old, U32.and(ra_vec_get(U32, rd, 0, 0, kr), Bool.pick(U32, U32.is_ge(ar, 32), 4294967295, U32.sub(U32.shln(1, U32.to_nat(ar)), 1))))
  +diff = U32.is_ne(nw, old)
  HotSt{hc, ra_vec_set_if(U32, 7n, diff, fid, nw, kp), kret, Bool.or(chg, diff)}
def elf_hot_fns(+reach: RaVec<U32>, fns: List<&2, IrFn>, hs: HotSt) -> HotSt: opt_foldl(~IrFn, ~RaVec<U32>, ~HotSt, ~(rc => f => +h => opt_un_fn(HotSt, f, fid => _ => ar => nregs => _ => _ => _ => blks => (+f0 = fid; +nr = nregs; +rd = Bool.pick(Nat, U32.is_lt(nr, 512), 2n, Bool.pick(Nat, U32.is_lt(nr, 2048), 3n, 5n)); opt_if(HotSt, elf_bs_has(4n, f0, rc), _ => elf_hot_fn_fin(rd, f0, ar, elf_hot_fn_fix(16n, rd, f0, b5k_list_rev(IrBlock, blks), HotFnSt{RVEmpty{}, True{}, h})), _ => h)))), reach, fns, hs)
def elf_hot_mark_cids(cids: List<&2, U32>, hs: HotSt) -> HotSt:
  match cids hs:
    case Nil{} _: hs
    case Con{c, t} HotSt{hc, kp, kret, chg}: ra_un_pair(RaVec<U32>, Bool, HotSt, elf_bs_mark(4n, (hc, chg), c), hc1 => chg1 => elf_hot_mark_cids(t, HotSt{hc1, kp, kret, chg1}))
def elf_hot_fix_step(hs1: HotSt) -> HotSt:
  HotSt{+hc1, +kp1, +kr1, +ch1} = hs1
  Bool.pick(HotSt, U32.is_ne(U32.and(ra_vec_get(U32, 7n, 0, 2, kp1), 2), 0), elf_hot_mark_cids([1, 5, 6, 10, 11], HotSt{hc1, kp1, kr1, ch1}), HotSt{hc1, kp1, kr1, ch1})
def elf_hot_fix(fuel: Nat, +reach: RaVec<U32>, +fns1: List<&2, IrFn>, +fns2: List<&2, IrFn>, hs: HotSt) -> RaVec<U32>:
  match fuel hs:
    case 0n HotSt{hc, _, _, _}: hc
    case _ HotSt{hc, _, _, False{}}: hc
    case 1n+p HotSt{hc, kp, kret, True{}}: elf_hot_fix(p, reach, fns2, fns1, elf_hot_fix_step(elf_hot_fns(reach, fns1, HotSt{hc, kp, kret, False{}})))
def elf_compute_cid_hot(+fns: List<&2, IrFn>, main_fid: U32, main_pure: Bool) -> RaVec<U32>: (+rfns = b5k_list_rev(IrFn, fns); +m0 = elf_bs_set(4n, main_fid, 0, RVEmpty{}); reach = elf_reach_fix(64n, rfns, (Bool.pick(RaVec<U32>, main_pure, m0, ra_vec_set(U32, 4n, 0, U32.or(ra_vec_get(U32, 4n, 0, 0, m0), 6), m0)), True{})); elf_hot_fix(32n, reach, rfns, fns, HotSt{RVEmpty{}, RVEmpty{}, RVEmpty{}, True{}}))
def elf_emit_cid_hots(+all_hot: Bool, ctors: List<&2, IrCtor>, +hot_map: RaVec<U32>, b: ByteBuf) -> ByteBuf:
  match ctors:
    case Nil{}: b
    case Con{IrCtor{cid, _, _, hot}, t}: elf_emit_cid_hots(all_hot, t, hot_map, bb_emit_u8(b, Bool.to_u32(Bool.or(all_hot, Bool.or(hot, elf_bs_has(4n, cid, hot_map))))))
type RoSt is Data:
  RoSt{buf: ByteBuf, offs: List<&2, U32>}
def elf_emit_cstr_list_go(ss: List<&2, String>, +b: ByteBuf, offs: List<&2, U32>) -> RoSt:
  match ss:
    case Nil{}: RoSt{b, b5k_list_rev(U32, offs)}
    case Con{s, t}: elf_emit_cstr_list_go(t, bb_emit_cstr(b, s), Con{bb_len(b), offs})
def elf_ro_buf(r: RoSt) -> ByteBuf:
  RoSt{b, _} = r
  b
def elf_ro_offs(r: RoSt) -> List<&2, U32>:
  RoSt{_, o} = r
  o
def elf_emit_u64_arr(xs: List<&2, U32>, b: ByteBuf) -> ByteBuf: opt_foldl0(~U32, ~ByteBuf, ~(+x => a => (+is_hi = U32.is_ge(x, 2147483648); +is_nil = U32.is_eq(x, 2147483648); bb_emit_u64(a, Bool.pick(U32, is_hi, Bool.pick(U32, is_nil, 0, U32.add(51413504, U32.sub(x, 2147483649))), x), Bool.pick(U32, is_hi, Bool.pick(U32, is_nil, 16777216, 33554688), 0)))), xs, b)
def elf_emit_ptr_slot(ta: TextAcc, use_ptr: Bool, sym: String, addend: U32) -> TextAcc:
  TextAcc{+b, +rels} = ta
  TextAcc{bb_emit_u64(b, 0, 0), Bool.pick(List<&2, ElfReloc>, use_ptr, Con{ElfReloc{bb_len(b), sym, 1, addend}, rels}, rels)}
def elf_emit_seg_ptrs(fns: List<&2, IrFn>, ta: TextAcc) -> TextAcc: opt_foldl0(~IrFn, ~TextAcc, ~(f => a => opt_un_fn(TextAcc, f, fid => _ => _ => _ => _ => _ => _ => _ => elf_emit_ptr_slot(a, True{}, x64_seg_sym(fid), 0))), fns, ta)
def elf_emit_ro_ptrs(offs: List<&2, U32>, ta: TextAcc) -> TextAcc: opt_foldl0(~U32, ~TextAcc, ~(o => a => elf_emit_ptr_slot(a, True{}, ".rodata", o)), offs, ta)
def elf_ta_len(ta: TextAcc) -> U32:
  TextAcc{b, _} = ta
  bb_len(b)
def elf_ta_u64s(xs: List<&2, U32>, ta: TextAcc) -> TextAcc: opt_foldl0(~U32, ~TextAcc, ~(x => a => elf_un_ta(TextAcc, a, b => rels => TextAcc{bb_emit_u64(b, x, 0), rels})), xs, ta)
# Symtab, Strtab, Rela, Shdr Serialization
type RelaAcc is Data:
  RelaAcc{buf: ByteBuf, imap: RaVec<List<&2, StrEnt>>, next_idx: U32, undefs: List<&2, ElfSym>}
def elf_ser_rela_u_m(is_new: Bool, +sym: String, b2: ByteBuf, +next_idx: U32, undefs: List<&2, ElfSym>, m1: RaVec<List<&2, StrEnt>>) -> RelaAcc:
  match is_new:
    case True{}: RelaAcc{b2, strmap_set(m1, sym, U32.add(next_idx, 1)), U32.add(next_idx, 1), Con{ElfSym{sym, 16, 0, 0, 0}, undefs}}
    case False{}: RelaAcc{b2, m1, next_idx, undefs}
def elf_ser_rela_u_k(roff: U32, +sym: String, rtype: U32, +addend: U32, off: U32, rev: List<&2, U32>, +next_idx: U32, undefs: List<&2, ElfSym>, m1: RaVec<List<&2, StrEnt>>, +found: U32) -> RelaAcc: (+is_new = U32.is_zero(found); +sidx = Bool.pick(U32, is_new, next_idx, U32.sub(found, 1)); b2: ByteBuf = ByteBuf{U32.add(off, 24), e_u32(e_u32(e_u32(e_u32(e_u32(e_u32(rev, roff), 0), rtype), sidx), addend), Bool.pick(U32, U32.is_ge(addend, 2147483648), 4294967295, 0))}; elf_ser_rela_u_m(is_new, sym, b2, next_idx, undefs, m1))
def elf_ser_rela_u(rels: List<&2, ElfReloc>, ra: RelaAcc) -> RelaAcc:
  match rels ra:
    case Nil{} _: ra
    case Con{ElfReloc{roff, +sym, rtype, addend}, t} RelaAcc{ByteBuf{off, rev}, +imap, next_idx, undefs}: elf_ser_rela_u(t, elf_ser_rela_u_k(roff, sym, rtype, addend, off, rev, next_idx, undefs, imap, strmap_get(imap, sym)))
type SymTabRes is Data:
  SymTabRes{symtab: ByteBuf, strtab: ByteBuf, imap: RaVec<List<&2, StrEnt>>, next_idx: U32}
def elf_ser_syms_go(syms: List<&2, ElfSym>, sr: SymTabRes) -> SymTabRes:
  match syms sr:
    case Nil{} _: sr
    case Con{ElfSym{SNil{}, info, shndx, val, sz}, t} SymTabRes{sb, strb, imap, idx}: elf_ser_syms_go(t, SymTabRes{bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, 0), info), 0), shndx), val, 0), sz, 0), strb, imap, U32.add(idx, 1)})
    case Con{ElfSym{+nm, info, shndx, val, sz}, t} SymTabRes{sb, +strb, imap, +idx}: elf_ser_syms_go(t, SymTabRes{bb_emit_u64(bb_emit_u64(bb_emit_u16(bb_emit_u8(bb_emit_u8(bb_emit_u32(sb, bb_len(strb)), info), 0), shndx), val, 0), sz, 0), bb_emit_cstr(strb, nm), strmap_set(imap, nm, U32.add(idx, 1)), U32.add(idx, 1)})
def elf_emit_shdr(b: ByteBuf, nm: U32, typ: U32, flg: U32, off: U32, sz: U32, lnk: U32, inf: U32, aln: U32, ent: U32) -> ByteBuf: bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u32(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u32(b, nm), typ), flg, 0), 0, 0), off, 0), sz, 0), lnk), inf), aln, 0), ent, 0)
def elf_emit_ehdr(shoff: U32) -> ByteBuf: bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u16(bb_emit_u32(bb_emit_u64(bb_emit_u64(bb_emit_u64(bb_emit_u32(bb_emit_u16(bb_emit_u16(bb_emit_zeros(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_emit_u8(bb_new(), 127), 69), 76), 70), 2), 1), 1), 0), 8), 1), 62), 1), 0, 0), 0, 0), shoff, 0), 0), 64), 0), 0), 64), 9), 8)
def elf_prepend_bb(b: ByteBuf, tail: List<&2, U32>) -> List<&2, U32>:
  ByteBuf{_, rev} = b
  b5k_list_rev_go(U32, rev, tail)
def elf_prepend_zeros(n: Nat, tail: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: tail
    case 1n+p: elf_prepend_zeros(p, Con{0, tail})
def elf_pack_sec(b: ByteBuf, +end_off: U32, tail: List<&2, U32>) -> List<&2, U32>: (+rem = U32.mod(end_off, 16); elf_prepend_bb(b, elf_prepend_zeros(U32.to_nat(Bool.pick(U32, U32.is_zero(rem), 0, U32.sub(16, rem))), tail)))
def elf_pack_bytes(+text_buf: ByteBuf, +ro_buf: ByteBuf, +data_buf: ByteBuf, +rtxt_buf: ByteBuf, +rdat_buf: ByteBuf, first_glob: U32, sr: SymTabRes) -> List<&2, U32>:
  SymTabRes{+symtab_buf, +strtab_buf, _, _} = sr
  +shstr_buf = bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_cstr(bb_emit_u8(bb_new(), 0), ".text"), ".rela.text"), ".rodata"), ".data"), ".rela.data"), ".symtab"), ".strtab"), ".shstrtab")
  +sz_text = bb_len(text_buf)
  +sz_rtxt = bb_len(rtxt_buf)
  +sz_ro = bb_len(ro_buf)
  +sz_dat = bb_len(data_buf)
  +sz_rdat = bb_len(rdat_buf)
  +sz_sym = bb_len(symtab_buf)
  +sz_str = bb_len(strtab_buf)
  +sz_shst = bb_len(shstr_buf)
  +off_rtxt = x64_align16(U32.add(64, sz_text))
  +off_ro = x64_align16(U32.add(off_rtxt, sz_rtxt))
  +off_dat = x64_align16(U32.add(off_ro, sz_ro))
  +off_rdat = x64_align16(U32.add(off_dat, sz_dat))
  +off_sym = x64_align16(U32.add(off_rdat, sz_rdat))
  +off_str = U32.add(off_sym, sz_sym)
  +off_shst = U32.add(off_str, sz_str)
  +shoff = x64_align16(U32.add(off_shst, sz_shst))
  h4 = elf_emit_shdr(elf_emit_shdr(elf_emit_shdr(elf_emit_shdr(bb_new(), 0, 0, 0, 0, 0, 0, 0, 0, 0), 1, 1, 6, 64, sz_text, 0, 0, 16, 0), 7, 4, 64, off_rtxt, sz_rtxt, 6, 1, 8, 24), 18, 1, 2, off_ro, sz_ro, 0, 0, 8, 0)
  shdrs = elf_emit_shdr(elf_emit_shdr(elf_emit_shdr(elf_emit_shdr(elf_emit_shdr(h4, 26, 1, 3, off_dat, sz_dat, 0, 0, 8, 0), 32, 4, 64, off_rdat, sz_rdat, 6, 4, 8, 24), 43, 2, 0, off_sym, sz_sym, 7, first_glob, 8, 24), 51, 3, 0, off_str, sz_str, 0, 0, 1, 0), 59, 3, 0, off_shst, sz_shst, 0, 0, 1, 0)
  b7 = elf_prepend_bb(symtab_buf, elf_prepend_bb(strtab_buf, elf_pack_sec(shstr_buf, U32.add(off_shst, sz_shst), elf_prepend_bb(shdrs, Nil{}))))
  elf_prepend_bb(elf_emit_ehdr(shoff), elf_pack_sec(text_buf, U32.add(64, sz_text), elf_pack_sec(rtxt_buf, U32.add(off_rtxt, sz_rtxt), elf_pack_sec(ro_buf, U32.add(off_ro, sz_ro), elf_pack_sec(data_buf, U32.add(off_dat, sz_dat), elf_pack_sec(rdat_buf, U32.add(off_rdat, sz_rdat), b7))))))
def elf_pack_fin_s2(text_buf: ByteBuf, ro_buf: ByteBuf, data_buf: ByteBuf, rtxt_buf: ByteBuf, first_glob: U32, sb0: ByteBuf, strb0: ByteBuf, ra2: RelaAcc) -> List<&2, U32>:
  RelaAcc{rdat_buf, imap2, nidx2, und2} = ra2
  elf_pack_bytes(text_buf, ro_buf, data_buf, rtxt_buf, rdat_buf, first_glob, elf_ser_syms_go(b5k_list_rev(ElfSym, und2), SymTabRes{sb0, strb0, imap2, nidx2}))
def elf_pack_fin_s1(text_buf: ByteBuf, ro_buf: ByteBuf, data_buf: ByteBuf, data_rels: List<&2, ElfReloc>, first_glob: U32, sb0: ByteBuf, strb0: ByteBuf, ra1: RelaAcc) -> List<&2, U32>:
  RelaAcc{rtxt_buf, imap1, nidx1, und1} = ra1
  elf_pack_fin_s2(text_buf, ro_buf, data_buf, rtxt_buf, first_glob, sb0, strb0, elf_ser_rela_u(data_rels, RelaAcc{bb_new(), imap1, nidx1, und1}))
def elf_pack_fin_s0(text_buf: ByteBuf, ro_buf: ByteBuf, data_buf: ByteBuf, text_rels: List<&2, ElfReloc>, data_rels: List<&2, ElfReloc>, first_glob: U32, sr0: SymTabRes) -> List<&2, U32>:
  SymTabRes{sb0, strb0, imap0, nidx0} = sr0
  elf_pack_fin_s1(text_buf, ro_buf, data_buf, data_rels, first_glob, sb0, strb0, elf_ser_rela_u(text_rels, RelaAcc{bb_new(), imap0, nidx0, Nil{}}))
def elf_emit_elf_fin(prog: IrProg, tres: TextRes, +all_ctors: List<&2, IrCtor>, +show_desc: List<&2, U32>, p0: ByteBuf & U32) -> List<&2, U32>:
  IrProg{+ir_fns, _, +statics, +main_fid, +main_pure, +effects, _, +show_names} = prog
  TextRes{text_buf, +text_rels, text_lsyms, text_gsyms, +luts} = tres
  (+ro1, max_ar) = p0
  +n_segs = b5k_list_len(IrFn, ir_fns)
  +n_ctors = b5k_list_len(IrCtor, all_ctors)
  +n_stat = b5k_u32_list_len(statics)
  +n_show = b5k_u32_list_len(show_desc)
  +n_sname = b5k_list_len(String, show_names)
  +n_eff = b5k_list_len(String, effects)
  +ro2 = bb_emit_zeros(ro1, n_segs)
  +ro3 = bb_emit_zeros(ro2, n_segs)
  +rs1 = ra_un_pair(ByteBuf, List<&2, String>, RoSt, elf_cid_meta(all_ctors, ro3, Nil{}), ro4 => c_names => elf_emit_cstr_list_go(c_names, ro4, Nil{}))
  +ro6 = elf_pad_to(elf_ro_buf(rs1), 4)
  +rs2 = elf_emit_cstr_list_go(show_names, elf_emit_u32_arr(show_desc, ro6), Nil{})
  +rs3 = elf_emit_cstr_list_go(effects, elf_ro_buf(rs2), Nil{})
  +ro10 = elf_pad_to(elf_ro_buf(rs3), 8)
  ro_buf = elf_emit_u64_arr(statics, ro10)
  +big = U32.is_gt(n_segs, 384)
  hot_map = opt_if(RaVec<U32>, big, _ => RVEmpty{}, _ => elf_compute_cid_hot(ir_fns, main_fid, main_pure))
  +da1 = elf_pad_to(elf_emit_cid_hots(big, all_ctors, hot_map, bb_new()), 8)
  +ta2 = elf_emit_seg_ptrs(ir_fns, TextAcc{da1, Nil{}})
  +ta3 = elf_emit_ro_ptrs(elf_ro_offs(rs1), ta2)
  +ta4 = elf_emit_ro_ptrs(elf_ro_offs(rs2), ta3)
  +ta6 = elf_un_ta(TextAcc, elf_emit_ro_ptrs(elf_ro_offs(rs3), ta4), b6 => r6 => TextAcc{elf_pad_to(b6, 8), r6})
  q6 = elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_emit_ptr_slot(elf_ta_u64s([11102, 192, n_segs, n_ctors, main_fid, Bool.to_u32(main_pure), U32.max(2, max_ar), 1, n_stat, n_show, n_sname, 9], ta6), True{}, "p111_segments", 0), True{}, "p111_fid_arity", 0), True{}, "p111_fid_flags", 0), True{}, "p111_fid_results", 0), True{}, "p111_cid_arity", 0), True{}, "p111_cid_hot", 0), True{}, "p111_cid_names", 0), U32.is_gt(n_stat, 0), "p111_static_image", 0)
  q7 = elf_emit_ptr_slot(elf_ta_u64s([n_eff], elf_emit_ptr_slot(elf_emit_ptr_slot(q6, U32.is_gt(n_show, 0), "p111_show_desc", 0), U32.is_gt(n_sname, 0), ".data", elf_ta_len(ta3))), U32.is_gt(n_eff, 0), ".data", elf_ta_len(ta4))
  +locals = b5k_list_app(ElfSym, [ElfSym{"", 0, 0, 0, 0}, ElfSym{".text", 3, 1, 0, 0}, ElfSym{".rodata", 3, 3, 0, 0}, ElfSym{".data", 3, 4, 0, 0}, ElfSym{"p111_fid_arity", 1, 3, bb_len(luts), n_segs}, ElfSym{"p111_fid_flags", 1, 3, bb_len(ro1), n_segs}, ElfSym{"p111_fid_results", 1, 3, bb_len(ro2), n_segs}, ElfSym{"p111_cid_arity", 1, 3, bb_len(ro3), n_ctors}, ElfSym{"p111_show_desc", 1, 3, bb_len(ro6), U32.mul(n_show, 4)}, ElfSym{"p111_static_image", 1, 3, bb_len(ro10), U32.mul(n_stat, 8)}, ElfSym{"p111_cid_hot", 1, 4, 0, n_ctors}, ElfSym{"p111_segments", 1, 4, bb_len(da1), U32.mul(n_segs, 8)}, ElfSym{"p111_cid_names", 1, 4, elf_ta_len(ta2), U32.mul(n_ctors, 8)}], b5k_list_rev(ElfSym, text_lsyms))
  +def_globs: List<&2, ElfSym> = Con{ElfSym{"p111_program", 17, 4, elf_ta_len(ta6), 192}, b5k_list_rev(ElfSym, text_gsyms)}
  elf_un_ta(List<&2, U32>, q7, data_buf => dr_rev => elf_pack_fin_s0(text_buf, ro_buf, data_buf, text_rels, b5k_list_rev(ElfReloc, dr_rev), b5k_list_len(ElfSym, locals), elf_ser_syms_go(def_globs, elf_ser_syms_go(locals, SymTabRes{bb_new(), bb_emit_u8(bb_new(), 0), RVEmpty{}, 0}))))
def elf_emit_elf_go(+prog: IrProg, +tres: TextRes) -> List<&2, U32>:
  IrProg{+ir_fns, +ir_ctors, _, _, +main_pure, _, show_desc_in, _} = prog
  TextRes{_, _, _, _, luts} = tres
  elf_emit_elf_fin(prog, tres, elf_merge_core_go(elf_core_ctors(), ir_ctors, b5k_list_len(IrCtor, ir_ctors), Nil{}), Bool.pick(List<&2, U32>, Bool.and(main_pure, U32.is_zero(b5k_u32_list_len(show_desc_in))), Con{0, Nil{}}, show_desc_in), elf_fid_meta(ir_fns, luts, 0))
def b5k_emit_elf_bytes(+prog: IrProg, fns: List<&2, X64Fn>) -> List<&2, U32>:
  IrProg{ir_fns, _, _, _, _, _, _, _} = prog
  elf_emit_elf_go(prog, elf_encode_fns_go(U32.is_le(b5k_list_len(IrFn, ir_fns), 384), fns, TextRes{bb_new(), Nil{}, Nil{}, Nil{}, bb_new()}))
