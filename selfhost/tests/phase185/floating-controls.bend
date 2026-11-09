# Machine boundaries reuse Phase112's frozen F32 bit cases. Unsupported23/36
# remain calls and are observed through an isolated routing stub, not a runtime.
@unsafe
def p185fp_function(name: String, +id: U32) -> P113DFunction:
  P113DFunction{name,p185cp_params(["a","b"],0),1,False{},
    [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"a"}}},
     P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Local{"b"}}},
     P113DScalar{p112fp_control_call(N111Const{id,0},N111Const{
       nt_choose(U32,U32.is_ge(id,26) && U32.is_le(id,35),u => 2,u => 1),0},"scratch")},
     P113DResult{[N111Local{"result"}]}]}

def p185fp_functions() -> List<&2,P113DFunction>:
  [p185fp_function("p185fa",26),p185fp_function("p185fb",27),p185fp_function("p185fc",28),
   p185fp_function("p185fd",29),p185fp_function("p185fe",30),p185fp_function("p185ff",31),
   p185fp_function("p185fg",32),p185fp_function("p185fh",33),p185fp_function("p185fi",34),
   p185fp_function("p185fj",35),p185fp_function("p185fk",23),p185fp_function("p185fl",36)]

@unsafe
def p185fp_validate() -> String:
  p113e_functions(p185fp_functions(),N111Ids{missing(),missing()},missing())

@unsafe
def p185fp_frame() -> X181Frame:
  x181_frame("floating_probe",["state"],
    [P113DScalar{N111Alloca{"buffer",16,8}},P113DScalar{N111Alloca{"p112f_site0_scratch",16,8}},
     P113DScalar{N111Set{"result",N111U64{},N111Const{0,0}}}])

@unsafe
def p185fp_probe(stmt: N111Stmt) -> Bool:
  Bool.not(String.is_empty(x185_float_probe(stmt,N111Ids{missing(),missing()},p185fp_frame())))

@unsafe
def p185fp_binary(+id: U32) -> Bool:
  nt_choose(Bool,U32.is_gt(id,35),u => True{},
    u => p185fp_probe(p112fp_control_call(N111Const{id,0},N111Const{2,0},"scratch")) && p185fp_binary(U32.inc(id)))

@unsafe
def p185fp_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p185fp_controls() -> List<&2,String>:
  [p185fp_row("verified",String.is_empty(p185fp_validate())),
   p185fp_row("binary-ten-supported",p185fp_binary(26)),
   p185fp_row("conversion-fallback",Bool.not(p185fp_probe(p112fp_control_call(N111Const{23,0},N111Const{1,0},"scratch")))),
   p185fp_row("sqrt-fallback",Bool.not(p185fp_probe(p112fp_control_call(N111Const{36,0},N111Const{1,0},"scratch")))),
   p185fp_row("bits-fallback",Bool.not(p185fp_probe(p112fp_control_call(N111Const{59,0},N111Const{1,0},"scratch")))),
   p185fp_row("wrong-arity",Bool.not(p185fp_probe(p112fp_control_call(N111Const{26,0},N111Const{1,0},"scratch")))),
   p185fp_row("high-op",Bool.not(p185fp_probe(p112fp_control_call(N111Const{26,1},N111Const{2,0},"scratch")))),
   p185fp_row("high-count",Bool.not(p185fp_probe(p112fp_control_call(N111Const{26,0},N111Const{2,1},"scratch")))),
   p185fp_row("dynamic-op",Bool.not(p185fp_probe(p112fp_control_call(N111Local{"op"},N111Const{2,0},"scratch")))),
   p185fp_row("dynamic-count",Bool.not(p185fp_probe(p112fp_control_call(N111Const{26,0},N111Local{"count"},"scratch")))),
   p185fp_row("integer-fallback",Bool.not(p185fp_probe(p112fp_control_call(N111Const{1,0},N111Const{2,0},"scratch")))),
   p185fp_row("alternate-buffer",p185fp_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"buffer"))),
   p185fp_row("fusion-buffer",p185fp_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"p112f_site0_scratch"))),
   p185fp_row("wrong-state",Bool.not(p185fp_probe(N111Call{"result",N111U64{},"p111_rt_op",[
     N111Arg{N111Ptr{},N111Local{"other"}},p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p185fp_row("state-width",Bool.not(p185fp_probe(N111Call{"result",N111U64{},"p111_rt_op",[
     N111Arg{N111U64{},N111Local{"state"}},p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p185fp_row("nonlocal-buffer",Bool.not(p185fp_probe(N111Call{"result",N111U64{},"p111_rt_op",[
     p111_state(),p111_u32(26),N111Arg{N111Ptr{},N111Const{0,0}},p111_u32(2)]}))),
   p185fp_row("buffer-width",Bool.not(p185fp_probe(N111Call{"result",N111U64{},"p111_rt_op",[
     p111_state(),p111_u32(26),N111Arg{N111U64{},N111Local{"scratch"}},p111_u32(2)]}))),
   p185fp_row("result-width",Bool.not(p185fp_probe(N111Call{"result",N111U32{},"p111_rt_op",[
     p111_state(),p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p185fp_row("wrong-symbol",Bool.not(p185fp_probe(N111Call{"result",N111U64{},"p111_rt_other",[
     p111_state(),p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p185fp_row("noncall",Bool.not(p185fp_probe(N111Set{"result",N111U64{},N111Const{0,0}}))),
   p185fp_row("short-buffer-refused",Bool.not(p112fp_control_verified("buffer",8)))]
