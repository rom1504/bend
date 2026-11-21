@unsafe
def x198w_calc(+id: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,24),u => x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),u =>
    nt_choose(X188Seq,U32.is_eq(id,25),v => x188_i2("movl",X187Mem{10,0},x188_reg(11,32)),v =>
      nt_choose(X188Seq,U32.is_eq(id,63),w =>
        x188_many([x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),x188_i2("subq",X187Mem{10,8},x188_reg(11,64)),
          x188_i2("movabsq",X187Imm{0,0},x188_reg(10,64)),x188_i2("cmovbq",x188_reg(10,64),x188_reg(11,64))]),w =>
        x188_many([x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),x188_i2("cmpq",X187Mem{10,8},x188_reg(11,64)),
          x188_i1("setb",x188_reg(11,8)),x188_i2("movzbl",x188_reg(11,8),x188_reg(11,32))]))))

@unsafe
def x198w_probe(op: X198WOp,stmt: N111Stmt,+ids: N111Ids,+frame: X181Frame) -> X188Seq:
  match op:
    case X198WOp{name,buf,id}: x188_many([x181_load(N111Local{buf},ids,frame,x188_reg(10,64)),
      x198w_calc(id),x181_store(name,frame,x188_reg(11,64))])
    case _: x186_u32_float_probe_when(x186_u32_float_enabled(),stmt,ids,frame)

@unsafe
def x186_u32_float_probe(+stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x198w_probe(x198w_op(stmt),stmt,ids,frame)
