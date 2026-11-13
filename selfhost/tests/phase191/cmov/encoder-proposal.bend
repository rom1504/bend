# Proposal only: integer CMOVcc, AT&T source first. Memory sources are read
# unconditionally. The32-bit form zeroes destination high32 even when false.
@unsafe
def x191cm_pair(+src: X187Operand, +dst: X187Operand, +width: U32, +code: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,(U32.is_eq(width,32) || U32.is_eq(width,64)) &&
      U32.is_ge(code,64) && U32.is_le(code,79) &&
      x187_e_reg(dst,width,False{}) && x187_e_rm(src,width,False{}),u =>
    x187_e_modrm(0,[15,code],U32.is_eq(width,64),x187_e_index(dst),src,False{},[],offset),
    u => x187_e_error())

@unsafe
def x191cm_spec(+op: String) -> X187Op:
  nt_choose(X187Op,String.eq(op,"cmovel"),u => X187Op{16,32,68,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovnel"),u => X187Op{16,32,69,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbl"),u => X187Op{16,32,66,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbel"),u => X187Op{16,32,70,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmoval"),u => X187Op{16,32,71,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovael"),u => X187Op{16,32,67,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovll"),u => X187Op{16,32,76,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovlel"),u => X187Op{16,32,78,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgl"),u => X187Op{16,32,79,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgel"),u => X187Op{16,32,77,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmoveq"),u => X187Op{16,64,68,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovneq"),u => X187Op{16,64,69,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbq"),u => X187Op{16,64,66,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbeq"),u => X187Op{16,64,70,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovaq"),u => X187Op{16,64,71,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovaeq"),u => X187Op{16,64,67,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovlq"),u => X187Op{16,64,76,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovleq"),u => X187Op{16,64,78,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgq"),u => X187Op{16,64,79,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgeq"),u => X187Op{16,64,77,0,0},u =>
  X187OpNone{}))))))))))))))))))))
