# Exact ABI11102 U32.to_f32. The unchanged verifier proves a readable U64
# buffer cell and authenticated state/import signature. Reading the low32 as
# unsigned before signed64 conversion covers all U32 values, including bit31.
# MOVD to r10d clears the entire published upper word. No host FP computation
# or constant folding is involved. Other passes still treat this IR as a call.
def x186_u32_float_enabled() -> Bool: True{}

@unsafe
def x186_u32_float_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))])

@unsafe
def x186_u32_float_probe_when(enabled: Bool, stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{23,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(X188Seq,enabled && String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
            Bool.not(String.eq(buffer,"state")),
          u => x186_u32_float_text(name,buffer,ids,frame),u => X188Empty{})
    case _: X188Empty{}

@unsafe
def x186_u32_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x186_u32_float_probe_when(x186_u32_float_enabled(),stmt,ids,frame)
