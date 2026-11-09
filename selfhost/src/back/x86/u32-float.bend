# Exact ABI11102 U32.to_f32. The unchanged verifier proves a readable U64
# buffer cell and authenticated state/import signature. Reading the low32 as
# unsigned before signed64 conversion covers all U32 values, including bit31.
# MOVD to r10d clears the entire published upper word. No host FP computation
# or constant folding is involved. Other passes still treat this IR as a call.
def x186_u32_float_enabled() -> Bool: True{}

@unsafe
def x186_u32_float_text(name: String, buffer: String, +ids: N111Ids, +frame: X181Frame) -> String:
  x181_load(N111Local{buffer},ids,frame,"%r10") ++
    "  movq 0(%r10), %r10\n  movl %r10d, %r10d\n  pxor %xmm0, %xmm0\n" ++
    "  cvtsi2ssq %r10, %xmm0\n  movd %xmm0, %r10d\n" ++ x181_store(name,frame,"%r10")

@unsafe
def x186_u32_float_probe_when(enabled: Bool, stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame) -> String:
  match stmt:
    case N111Call{name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111Const{23,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(String,enabled && String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
            Bool.not(String.eq(buffer,"state")),
          u => x186_u32_float_text(name,buffer,ids,frame),u => "")
    case _: ""

@unsafe
def x186_u32_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> String:
  x186_u32_float_probe_when(x186_u32_float_enabled(),stmt,ids,frame)
