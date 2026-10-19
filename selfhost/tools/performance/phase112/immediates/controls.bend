@unsafe
def p112i_control_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

def p112i_control_call(symbol: String, value: N111Value) -> N111Stmt:
  N111Call{"value",N111U64{},symbol,[p111_state(),N111Arg{N111U64{},value}]}

def p112i_control_expanded(result: P112IEmission) -> Bool:
  match result:
    case P112IEmission{expanded,code}: expanded

@unsafe
def p112i_control_probe(stmt: N111Stmt) -> Bool:
  p112i_control_expanded(p112i_expand(stmt,N111Ids{missing(),missing()},P111QCode{[],40,False{},""}))

@unsafe
def p112i_control_counter(result: P112IEmission) -> Bool:
  match result:
    case P112IEmission{expanded,P111QCode{chunks,next,terminal,error}}:
      expanded && U32.is_eq(next,43) && Bool.not(terminal) && String.is_empty(error)

@unsafe
def p112i_control_verifier(body: List<&2,N111Stmt>) -> Bool:
  String.is_empty(p111v_segment(N111Segment{"probe",0,1,0,0,body},N111Ids{missing(),missing()}))

@unsafe
def p112i_control_report() -> List<&2,String>:
  [p112i_control_name("keep-constant",p112i_control_probe(p112i_control_call("p111_rt_keep",N111Const{0,0}))),
   p112i_control_name("sink-constant",p112i_control_probe(p112i_control_call("p111_rt_sink",N111Const{4294967295,33554431}))),
   p112i_control_name("keep-alias",p112i_control_probe(p112i_control_call("p111_rt_keep",N111Local{"value"}))),
   p112i_control_name("sink-alias",p112i_control_probe(p112i_control_call("p111_rt_sink",N111Local{"value"}))),
   p112i_control_name("heap-keeps-conditional-fallback",p112i_control_probe(p112i_control_call("p111_rt_keep",N111Const{0,33554432}))),
   p112i_control_name("rfc-keeps-conditional-fallback",p112i_control_probe(p112i_control_call("p111_rt_keep",N111Const{0,2147483648}))),
   p112i_control_name("fresh-labels-and-temporary",p112i_control_counter(p112i_expand(p112i_control_call("p111_rt_keep",N111Const{1,0}),N111Ids{missing(),missing()},P111QCode{[],40,False{},""}))),
   p112i_control_name("other-helper-fallback",Bool.not(p112i_control_probe(p112i_control_call("p111_rt_tag",N111Const{1,0})))),
   p112i_control_name("other-state-fallback",Bool.not(p112i_control_probe(N111Call{"value",N111U64{},"p111_rt_keep",[N111Arg{N111Ptr{},N111Local{"other"}},N111Arg{N111U64{},N111Const{1,0}}]}))),
   p112i_control_name("wrong-result-type-fallback",Bool.not(p112i_control_probe(N111Call{"value",N111U32{},"p111_rt_keep",[p111_state(),N111Arg{N111U64{},N111Const{1,0}}]}))),
   p112i_control_name("wrong-operand-type-fallback",Bool.not(p112i_control_probe(N111Call{"value",N111U64{},"p111_rt_keep",[p111_state(),p111_u32(1)]}))),
   p112i_control_name("extra-argument-fallback",Bool.not(p112i_control_probe(N111Call{"value",N111U64{},"p111_rt_keep",[p111_state(),N111Arg{N111U64{},N111Const{1,0}},p111_u32(0)]}))),
   p112i_control_name("noncall-fallback",Bool.not(p112i_control_probe(N111Set{"value",N111U64{},N111Const{1,0}}))),
   p112i_control_name("original-valid-alias",p112i_control_verifier([N111Set{"value",N111U64{},N111Const{1,0}},p112i_control_call("p111_rt_keep",N111Local{"value"}),N111Return{N111Local{"value"}}])),
   p112i_control_name("original-unbound-refusal",Bool.not(p112i_control_verifier([p112i_control_call("p111_rt_keep",N111Local{"missing"}),N111Return{N111Local{"value"}}])))]
