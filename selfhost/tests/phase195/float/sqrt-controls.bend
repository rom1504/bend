def p195sc_v(name: String) -> N111Value: N111Local{name}
def p195sc_c(value: U32) -> N111Value: N111Const{value,0}
def p195sc_call(name: String, symbol: String, state: String, op: U32, buffer: String, count: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[N111Arg{N111Ptr{},p195sc_v(state)},
    N111Arg{N111U32{},p195sc_c(op)},N111Arg{N111Ptr{},p195sc_v(buffer)},N111Arg{N111U32{},p195sc_c(count)}]}
def p195sc_pick(value: Maybe<&2,X195Sqrt>) -> Bool:
  match value:
    case Some{value}: True{}
    case None{}: False{}
def p195sc_cut(value: X186InlineOp) -> Bool:
  match value:
    case X186InlineNone{}: True{}
    case _: False{}
@unsafe
def p195sc_bytes(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && p195sc_bytes(xs,ys)
    case _ _: False{}
def p195sc_encoded(result: X187Encoded, expected: List<&2,U32>) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}: String.is_empty(error) && p195sc_bytes(bytes,expected) && U32.is_eq(nt_count(X187Relocation,relocs),0)
def p195sc_refused(result: X187Encoded) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}: Bool.not(String.is_empty(error))
def p195sc_row(name: String, pass: Bool) -> String:
  "sqrt-" ++ name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")
@unsafe
def p195sc_controls() -> List<&2,String>:
  +call = p195sc_call("out","p111_rt_op","state",36,"buffer",1)
  [p195sc_row("shape",p195sc_pick(x195s_pick(True{},call))),
   p195sc_row("off",Bool.not(p195sc_pick(x195s_pick(False{},call)))),
   p195sc_row("unknown-call-boundary",p195sc_cut(x186_inline_op(call))),
   p195sc_row("near-op",Bool.not(p195sc_pick(x195s_pick(True{},p195sc_call("out","p111_rt_op","state",35,"buffer",1))))),
   p195sc_row("count",Bool.not(p195sc_pick(x195s_pick(True{},p195sc_call("out","p111_rt_op","state",36,"buffer",2))))),
   p195sc_row("state",Bool.not(p195sc_pick(x195s_pick(True{},p195sc_call("out","p111_rt_op","other",36,"buffer",1))))),
   p195sc_row("symbol",Bool.not(p195sc_pick(x195s_pick(True{},p195sc_call("out","p195sc_runtime","state",36,"buffer",1))))),
   p195sc_row("buffer-state",Bool.not(p195sc_pick(x195s_pick(True{},p195sc_call("out","p111_rt_op","state",36,"state",1))))),
   p195sc_row("destination-rebind",p195sc_pick(x195s_pick(True{},p195sc_call("buffer","p111_rt_op","state",36,"buffer",1)))),
   p195sc_row("type",Bool.not(p195sc_pick(x195s_pick(True{},N111Call{"out",N111U32{},"p111_rt_op",[
     N111Arg{N111Ptr{},p195sc_v("state")},N111Arg{N111U32{},p195sc_c(36)},
     N111Arg{N111Ptr{},p195sc_v("buffer")},N111Arg{N111U32{},p195sc_c(1)}]})))),
   p195sc_row("encode-low",p195sc_encoded(x187_encode(X187Instruction{"sqrtss",[x188_xmm(0),x188_xmm(0)]},0),[243,15,81,192])),
   p195sc_row("encode-high",p195sc_encoded(x187_encode(X187Instruction{"sqrtss",[x188_xmm(9),x188_xmm(10)]},0),[243,69,15,81,209])),
   p195sc_row("encode-memory",p195sc_encoded(x187_encode(X187Instruction{"sqrtss",[X187Mem{10,0},x188_xmm(0)]},0),[243,65,15,81,2])),
   p195sc_row("reject-gpr",p195sc_refused(x187_encode(X187Instruction{"sqrtss",[x188_reg(0,32),x188_xmm(0)]},0))),
   p195sc_row("reject-destination",p195sc_refused(x187_encode(X187Instruction{"sqrtss",[x188_xmm(0),X187Mem{10,0}]},0))),
   p195sc_row("reject-arity",p195sc_refused(x187_encode(X187Instruction{"sqrtss",[x188_xmm(0)]},0))),
   p195sc_row("reject-offset",p195sc_refused(x187_encode(X187Instruction{"sqrtss",[x188_xmm(0),x188_xmm(0)]},4294967295)))]
@unsafe
def p195sc_rows(+mode: U32, +symbol: String) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,0),u => [
    P113DScalar{p195sc_call("out",symbol,"state",36,"buffer",1)},P113DResult{[p195sc_v("out")]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,1),u => [
    P113DScalar{N111Alloca{"private",8,8}},
    P113DScalar{N111Load{"raw",N111U64{},p195sc_v("buffer"),0}},
    P113DScalar{N111Store{N111U64{},p195sc_v("private"),0,p195sc_v("raw")}},
    P113DScalar{p195sc_call("out",symbol,"state",36,"private",1)},P113DResult{[p195sc_v("out")]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,2),u => [
    P113DScalar{p195sc_call("first",symbol,"state",36,"buffer",1)},
    P113DScalar{N111Store{N111U64{},p195sc_v("state"),40,p195sc_v("first")}},
    P113DScalar{p195sc_call("second",symbol,"state",36,"buffer",1)},
    P113DScalar{N111Store{N111U64{},p195sc_v("state"),48,p195sc_v("second")}},
    P113DScalar{N111Bin{"sum",N111U64{},"add",p195sc_v("first"),p195sc_v("second")}},
    P113DScalar{N111Bin{"out",N111U64{},"add",p195sc_v("sum"),p195sc_v("salt")}},
    P113DResult{[p195sc_v("out")]}],u => [
    P113DScalar{p195sc_call("buffer",symbol,"state",36,"buffer",1)},P113DResult{[p195sc_v("buffer")]}])))
@unsafe
def p195sc_emit_mode(+mode: U32) -> X181Output:
  x181_program_join(
    x181_function("p195sc_old_" ++ U32.show(mode),["state","buffer","salt"],p195sc_rows(mode,"p195sc_runtime"),N111Ids{missing(),missing()}),
    x181_function("p195sc_new_" ++ U32.show(mode),["state","buffer","salt"],p195sc_rows(mode,"p111_rt_op"),N111Ids{missing(),missing()}))
@unsafe
def p195sc_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(mode,4),u => X181Output{[],""},u =>
    x181_program_join(p195sc_emit_mode(mode),p195sc_emit_modes(U32.inc(mode))))
def p195sc_emit() -> X181Output: p195sc_emit_modes(0)
