# Uses the unchanged lazy-admission fixture builders. Every observation is a
# complete public function string; malformed fixture programs are never run.
type P171PEObservation is Data:
  P171PEObservation{+mode: U32, +text: String, +tailPath: Bool, +fusedPublicPath: Bool}

@unsafe
def p171pe_tc_tail(+target: String, +slot: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},slot,N111Const{7,0}},
   N111Call{"jump",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{target}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"jump"}}]

@unsafe
def p171pe_tc_body(mode: U32) -> List<&2,N111Stmt>:
  match mode:
    case 32: []
    case 33: [N111Return{N111Const{7,0}}]
    case 34: [N111Return{N111Const{7,0}},N111Store{N111U64{},N111Local{"scratch"},0,N111Const{8,0}}]
    case 35: [N111Return{N111Const{7,0}},N111If{N111Const{1,0},[],[]}]
    case 36: [N111If{N111Const{1,0},[N111Return{N111Const{7,0}}],[N111Return{N111Const{8,0}}]},N111Return{N111Const{9,0}}]
    case 37: [N111If{N111Const{1,0},[N111Return{N111Const{7,0}}],[N111Set{"fall",N111U64{},N111Const{8,0}}]},N111Return{N111Const{9,0}}]
    case 38: [N111If{N111Const{1,0},[N111If{N111Const{2,0},[],[N111Set{"a",N111U32{},N111Const{3,0}}]}],[]},N111Return{N111Const{9,0}}]
    case 39: p171pe_tc_tail("p171_helper",0)
    case 40: p171pe_tc_tail("p171_helper",8)
    case 41: p171pe_tc_tail("p171_owner",0)
    case 42: p171pe_tc_tail("p171_helper",0)
    case 43: [N111Return{N111Const{7,0}}]
    case 44: p171pe_tc_tail("p171_helper",0)
    case 45: p171l_body(0)
    case 46: [N111Call{"jump",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{"p171_helper"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{0,0}}]},N111Return{N111Local{"jump"}}]
    case 47: [N111If{N111Const{1,0},[N111Return{N111Const{7,0}},N111Set{"bad",N111U32{},N111Const{8,0}}],[N111Set{"other",N111U32{},N111Const{9,0}}]},N111Return{N111Const{0,0}}]
    case _: p171l_body(mode)

@unsafe
def p171pe_tc_base(segment: N111Segment) -> N111Segment:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      N111Segment{name,arity,result,1,flags,body}

@unsafe
def p171pe_tc_special(+mode: U32) -> N111Segment:
  match mode:
    case 43: N111Segment{"p171_owner",1,0,1,0,p171pe_tc_body(mode)}
    case 45: N111Segment{"p171_owner",1,1,0,0,p171pe_tc_body(mode)}
    case _: N111Segment{"p171_owner",1,1,1,0,p171pe_tc_body(mode)}

@unsafe
def p171pe_tc_segment(+mode: U32) -> N111Segment:
  nt_choose(N111Segment,U32.is_lt(mode,32),u => p171pe_tc_base(p171l_segment(mode)),
    u => p171pe_tc_special(mode))

@unsafe
def p171pe_tc_ready(+mode: U32) -> KDef:
  match mode:
    case 39: p111v_put(missing(),"p171_helper","P112Worker",1,1)
    case 40: p111v_put(missing(),"p171_helper","P112Worker",1,1)
    case 41: p111v_put(missing(),"p171_owner","P112Worker",1,1)
    case 42: p111v_put(missing(),"p171_helper","P112Worker",2,1)
    case 44: p111v_put(missing(),"p171_helper","WrongKind",1,1)
    case 46: p111v_put(missing(),"p171_helper","P112Worker",0,1)
    case _: p171l_ready(mode)

@unsafe
def p171pe_tc_emit(+mode: U32, +segment: N111Segment, +ids: N111Ids, +ready: KDef) -> P171PEObservation:
  match segment:
    case N111Segment{name,arity,+result,incoming,+flags,body}:
      +tail = p112t_admitted(p112t_plan(segment))
      P171PEObservation{mode,p112w_public_segment(segment,ids,ready),tail,
        Bool.not(tail) && U32.is_eq(result,1) && U32.is_eq(flags,0)}

@unsafe
def p171pe_case(+mode: U32) -> P171PEObservation:
  +segment = p171pe_tc_segment(mode)
  +ids = p111q_ids(P111Program{[segment,p171l_cont(),N111Segment{"p171_helper",1,1,0,0,[]}],
    [N_Constructor{"Pair",2,False{}}],[],[],[],True{}})
  p171pe_tc_emit(mode,segment,ids,p171pe_tc_ready(mode))
