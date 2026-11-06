# Compiler-data fixtures only: no constructed runtime program is executed.
# Complete plans are observed through separately source-checked old/new APIs.

type P171LObservation is Data:
  P171LObservation{+mode: U32, +size: U32, +legacy: U32, +known: U32,
    +clean: U32, +hclean: U32, +rvalid: U32, +gvalid: U32, +hvalid: U32,
    +rplan: P114RPlan, +gplan: P114GPlan, +hplan: P114HPlan, +cplan: P112FusionBody}

def p171l_bit(value: Bool) -> U32:
  match value:
    case True{}: 1
    case False{}: 0

def p171l_gvalid(plan: P114GPlan) -> U32:
  match plan:
    case P114GPlan{valid,params,body,continuation,captures,result,pop,resume}: p171l_bit(valid)

@unsafe
def p171l_get(+dest: String, +symbol: String, slot: U32) -> N111Stmt:
  N111Call{dest,N111U64{},symbol,[p111_state(),N111Arg{N111U32{},N111Const{slot,0}}]}

@unsafe
def p171l_return(value: N111Value) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},0,value},
   N111Call{"done",N111U64{},"p111_rt_return",[p111_state(),N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"done"}}]

@unsafe
def p171l_descend() -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}},
   N111Call{"frame",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"p171_cont"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}},
   N111Call{"jump",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{"p171_owner"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"jump"}}]

@unsafe
def p171l_cont() -> N111Segment:
  N111Segment{"p171_cont",2,1,1,0,
    nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
      p171l_get("pop","p111_rt_stack_pop",1),p171l_get("head","p111_rt_stack_get",0),
      p171l_get("recursive","p111_rt_reg_get",0),
      N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"head"}},
      N111Store{N111U64{},N111Local{"scratch"},8,N111Local{"recursive"}},
      N111Call{"rebuilt",N111U64{},"p111_rt_ctor",[p111_state(),N111Arg{N111U32{},N111CtorId{"Pair"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{2,0}}]}],
      p171l_return(N111Local{"rebuilt"}))}

@unsafe
def p171l_pad(+count: U32, tail: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match count:
    case 0: tail
    case _: Con{N111Store{N111U64{},N111Local{"scratch"},0,N111Const{0,0}},p171l_pad(U32.sub(count,1),tail)}

@unsafe
def p171l_prefix(mode: U32) -> List<&2,N111Stmt>:
  match mode:
    case 15: p171l_pad(500,[])
    case 16: p171l_pad(501,[])
    case 17: p171l_pad(502,[])
    case 18: [N111If{N111Const{1,0},p171l_pad(500,[]),[]}]
    case 19: [N111If{N111Const{1,0},p171l_pad(501,[]),[]}]
    case 20: [N111Set{"p112f_bad",N111U64{},N111Const{0,0}}]
    case 21: [N111Set{"copy",N111U64{},N111Local{"p112f_bad"}}]
    case 22: [N111Set{"p114h_bad",N111U64{},N111Const{0,0}}]
    case 23: [N111Set{"copy",N111U64{},N111Local{"p114r_bad"}}]
    case 24: [N111Set{"p114hX",N111U64{},N111Const{0,0}}]
    case 25: p171l_pad(600,[N111Set{"p112f_bad",N111U64{},N111Const{0,0}}])
    case 26: [N111Set{"p112f_bad",N111U64{},N111Const{0,0}}]
    case _: []

@unsafe
def p171l_body(mode: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},p171l_get("input","p111_rt_reg_get",0)],
    nt_append(N111Stmt,p171l_prefix(mode),[N111If{N111Const{1,0},p171l_descend(),p171l_return(N111Local{"input"})}]))

@unsafe
def p171l_segment(+mode: U32) -> N111Segment:
  match mode:
    case 1: N111Segment{"p171_owner",0,1,0,0,p171l_body(mode)}
    case 2: N111Segment{"p171_owner",8,1,0,0,p171l_body(mode)}
    case 3: N111Segment{"p171_owner",9,1,0,0,p171l_body(mode)}
    case 4: N111Segment{"p171_owner",1,0,0,0,p171l_body(mode)}
    case 5: N111Segment{"p171_owner",1,2,0,0,p171l_body(mode)}
    case 6: N111Segment{"p171_owner",1,1,1,0,p171l_body(mode)}
    case 7: N111Segment{"p171_owner",1,1,0,1,p171l_body(mode)}
    case 25: N111Segment{"p171_owner",1,0,0,0,p171l_body(mode)}
    case _: N111Segment{"p171_owner",1,1,0,0,p171l_body(mode)}

@unsafe
def p171l_worker(count: U32) -> KDef:
  p111v_put(missing(),"p171_owner","P112Worker",count,0)

@unsafe
def p171l_direct(name: String, count: U32, result: U32, public: U32) -> KDef:
  index_build([KDef{name,"P113Direct",count,result,atom("Absent"),kt("P113Public","",public,0,[]),[],False{},False{}}])

@unsafe
def p171l_ready(mode: U32) -> KDef:
  match mode:
    case 8: p171l_worker(1)
    case 9: p111v_put(missing(),"p171_owner","WrongKind",1,0)
    case 10: p124r_view(missing(),p171l_direct("p171_owner",1,1,1))
    case 11: p124r_view(missing(),p171l_direct("p171_owner",1,0,1))
    case 12: p124r_view(missing(),p171l_direct("p171_owner",1,1,0))
    case 13: p124r_view(missing(),p171l_direct("p171_owner",9,1,1))
    case 14: p124r_view(p171l_worker(1),missing())
    case 26: p171l_worker(1)
    case 27: p124r_view(missing(),p171l_direct("another_owner",1,1,1))
    case 28: p171l_direct("p171_owner",1,1,1)
    case 29: p124r_view(p171l_worker(1),p171l_direct("p171_owner",1,0,1))
    case 30: p171l_worker(9)
    case 31: p124r_view(p171l_worker(9),missing())
    case _: missing()

@unsafe
def p171l_observe(mode: U32, +segment: N111Segment, +ready: KDef,
    +r: P114RPlan, +g: P114GPlan, +h: P114HPlan, c: P112FusionBody) -> P171LObservation:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,+body}:
      P171LObservation{mode,p112f_size(body),p171l_bit(p112w_ready(ready,name)),p171l_bit(p124r_known(ready,name)),
        p171l_bit(p112f_clean(body)),p171l_bit(p114h_clean(body)),p171l_bit(p114r_valid(r)),p171l_gvalid(g),p171l_bit(p114h_valid(h)),r,g,h,c}

@unsafe
def p171l_plans(mode: U32, +segment: N111Segment, +ready: KDef, +index: P112FusionIndex) -> P171LObservation:
  p171l_observe(mode,segment,ready,p114r_plan(segment,index),p114g_plan(segment,index,ready),
    p114h_plan(segment,index,ready),p112c_plan_index(segment,index,ready))

@unsafe
def p171l_case(+mode: U32) -> P171LObservation:
  +segment = p171l_segment(mode)
  p171l_plans(mode,segment,p171l_ready(mode),p112f_index([segment,p171l_cont()]))
