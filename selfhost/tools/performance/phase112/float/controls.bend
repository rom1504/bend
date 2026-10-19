@unsafe
def p112fp_control_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

def p112fp_control_call(id: N111Value, count: N111Value, buffer: String) -> N111Stmt:
  N111Call{"result",N111U64{},"p111_rt_op",[p111_state(),N111Arg{N111U32{},id},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

def p112fp_control_expanded(result: P112FPEmission) -> Bool:
  match result:
    case P112FPEmission{expanded,code}: expanded

@unsafe
def p112fp_control_probe(stmt: N111Stmt) -> Bool:
  p112fp_control_expanded(p112fp_expand(stmt,P111QCode{[],40,False{},""}))

@unsafe
def p112fp_control_temps(result: P112FPEmission) -> Bool:
  match result:
    case P112FPEmission{expanded,P111QCode{chunks,next,terminal,error}}: expanded && U32.is_eq(next,49) && Bool.not(terminal) && String.is_empty(error)

@unsafe
def p112fp_control_verified(+buffer: String, bytes: U32) -> Bool:
  +segment : N111Segment = N111Segment{"probe",0,1,0,0,[N111Alloca{buffer,bytes,8},p112fp_control_call(N111Const{26,0},N111Const{2,0},buffer),N111Return{N111Local{"result"}}]}
  String.is_empty(p111v_segment(segment,N111Ids{missing(),missing()}))

@unsafe
def p112fp_control_report() -> List<&2,String>:
  [p112fp_control_name("add",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("division",p112fp_control_probe(p112fp_control_call(N111Const{29,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("comparison",p112fp_control_probe(p112fp_control_call(N111Const{35,0},N111Const{2,0},"scratch"))),
   p112fp_control_name("unsigned-conversion",p112fp_control_probe(p112fp_control_call(N111Const{23,0},N111Const{1,0},"scratch"))),
   p112fp_control_name("sqrt-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{36,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("to-u32-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{58,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("wrong-arity-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{1,0},"scratch")))),
   p112fp_control_name("high-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,1},N111Const{2,0},"scratch")))),
   p112fp_control_name("high-count-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,1},"scratch")))),
   p112fp_control_name("dynamic-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Local{"op"},N111Const{2,0},"scratch")))),
   p112fp_control_name("other-buffer-supported",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"buffer"))),
   p112fp_control_name("integer-op-fallback",Bool.not(p112fp_control_probe(p112fp_control_call(N111Const{1,0},N111Const{2,0},"scratch")))),
   p112fp_control_name("noncall-fallback",Bool.not(p112fp_control_probe(N111Set{"result",N111U64{},N111Const{0,0}}))),
   p112fp_control_name("fresh-temporary-counter",p112fp_control_temps(p112fp_expand(p112fp_control_call(N111Const{26,0},N111Const{2,0},"scratch"),P111QCode{[],40,False{},""}))),
   p112fp_control_name("fusion-buffer-supported",p112fp_control_probe(p112fp_control_call(N111Const{26,0},N111Const{2,0},"p112f_site0_scratch"))),
   p112fp_control_name("alternate-buffer-original-verifier",p112fp_control_verified("buffer",16)),
   p112fp_control_name("fusion-buffer-original-verifier",p112fp_control_verified("p112f_site0_scratch",16)),
   p112fp_control_name("short-buffer-original-refusal",Bool.not(p112fp_control_verified("buffer",8))),
   p112fp_control_name("wrong-state-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U64{},"p111_rt_op",[N111Arg{N111Ptr{},N111Local{"other_state"}},p111_u32(26),p111_scratch(),p111_u32(2)]}))),
   p112fp_control_name("nonlocal-buffer-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U64{},"p111_rt_op",[p111_state(),p111_u32(26),N111Arg{N111Ptr{},N111Const{0,0}},p111_u32(2)]}))),
   p112fp_control_name("wrong-result-width-fallback",Bool.not(p112fp_control_probe(N111Call{"result",N111U32{},"p111_rt_op",[p111_state(),p111_u32(26),p111_scratch(),p111_u32(2)]})))]
