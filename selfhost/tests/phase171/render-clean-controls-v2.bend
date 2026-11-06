# Requires unchanged lazy-admission-controls.bend. These are complete public
# emission observations, not execution of malformed/constructed runtime IR.
type P171RCObservation is Data:
  P171RCObservation{+mode: U32, +text: String, +direct: Bool, +directText: String,
    +originalClean: Bool, +hReady: Bool, +hView: Bool}

@unsafe
def p171rc_test_cont_body(body: List<&2,N111Stmt>, +name: String) -> List<&2,N111Stmt>:
  match body:
    case Con{+a,Con{+b,Con{+c,Con{+d,+rest}}}}:
      nt_append(N111Stmt,[a,b,c,d,N111Set{name,N111U64{},N111Const{0,0}}],rest)
    case _: body

@unsafe
def p171rc_test_cont(+segment: N111Segment, +mode: U32) -> N111Segment:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      match mode:
        case 32: N111Segment{name,arity,result,incoming,flags,p171rc_test_cont_body(body,"p112f_bad")}
        case 33: N111Segment{name,arity,result,incoming,flags,p171rc_test_cont_body(body,"p114r_bad")}
        case 34: N111Segment{name,arity,result,incoming,flags,p171rc_test_cont_body(body,"p114h_bad")}
        case _: segment

@unsafe
def p171rc_test_helper() -> List<&2,N111Stmt>:
  [N111Alloca{"scratch",2048,8},p171l_get("input","p111_rt_reg_get",0),
   N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}},
   N111Call{"frame",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"p171_cont"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}},
   N111Call{"jump",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{"p171_helper"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"jump"}}]

@unsafe
def p171rc_test_segment(+mode: U32) -> N111Segment:
  match mode:
    case 37: p171l_segment(20)
    case 38: p171l_segment(25)
    case 40: N111Segment{"p171_owner",1,1,0,0,p171rc_test_helper()}
    case 41: N111Segment{"p171_owner",1,1,0,0,p171rc_test_helper()}
    case 42: N111Segment{"p171_owner",1,1,0,0,p171rc_test_helper()}
    case 43: N111Segment{"p171_owner",1,1,0,0,
      nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},p171l_get("input","p111_rt_reg_get",0)],
        [N111If{N111Const{1,0},[N111Set{"copy",N111U64{},N111Local{"p112f_bad"}}],p171l_return(N111Local{"input"})}])}
    case _: p171l_segment(mode)

@unsafe
def p171rc_test_direct(mode: U32) -> KDef:
  match mode:
    case 36: p171l_direct("p171_owner",1,1,1)
    case 37: p171l_direct("p171_owner",1,1,1)
    case 38: p171l_direct("p171_owner",1,1,1)
    case 39: p171l_direct("p171_owner",1,1,0)
    case _: missing()

@unsafe
def p171rc_test_view(+mode: U32, +ready: KDef, +direct: KDef) -> KDef:
  match mode:
    case 40: p124r_view(ready,p171l_direct("p171_helper",1,1,1))
    case 41: p124r_view(ready,p171l_direct("p171_helper",1,1,0))
    case 42: p124r_view(ready,p171l_direct("p171_helper",9,1,1))
    case _: p124r_view(ready,direct)

@unsafe
def p171rc_test_emit(+mode: U32, +segment: N111Segment, +direct: KDef,
    +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +view: KDef) -> P171RCObservation:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      +function = p111v_get(direct,name)
      P171RCObservation{mode,p124r_public(segment,direct,index,ids,ready,view),
        String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1),p113e_public(name,arity),
        p112f_clean(body),p114h_valid(p114h_plan(segment,index,ready)),p114h_valid(p114h_plan(segment,index,view))}

@unsafe
def p171rc_case(+mode: U32) -> P171RCObservation:
  +segment = p171rc_test_segment(mode)
  +cont = p171rc_test_cont(p171l_cont(),mode)
  +segments = nt_choose(List<&2,N111Segment>,U32.is_eq(mode,35),u => [segment],u => [segment,cont])
  +ready = p171l_ready(mode)
  +direct = p171rc_test_direct(mode)
  +ids = p111q_ids(P111Program{[segment,cont,N111Segment{"p171_helper",1,1,0,0,[]}],
    [N_Constructor{"Pair",2,False{}}],[],[],[],True{}})
  p171rc_test_emit(mode,segment,direct,p112f_index(segments),ids,ready,p171rc_test_view(mode,ready,direct))
