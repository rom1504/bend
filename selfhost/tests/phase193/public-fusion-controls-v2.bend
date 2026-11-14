# Finite N111 data fixtures. ORIGINAL p111v_segment, p112c_plan_index and
# p112w_public provide independent admission. No executable compiler is run here.
# Runtime oracle: helper(x)=x+1; captured=(1<<32)+7; argument=(2<<32)+11;
# fused owner returns (3<<32)+19, through the caller's pending continuation.

def x193fc_store(index: U32, value: N111Value) -> N111Stmt:
  N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),value}

def x193fc_get(name: String, index: U32) -> N111Stmt:
  N111Call{name,N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(index)]}

def x193fc_stack(symbol: String, name: String, index: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[p111_state(),p111_u32(index)]}

def x193fc_jump(target: String, count: U32) -> List<&2,N111Stmt>:
  [N111Call{"transition",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{target}},p111_scratch(),p111_u32(count)]},
   N111Return{N111Local{"transition"}}]

def x193fc_return(value: N111Value) -> List<&2,N111Stmt>:
  [x193fc_store(0,value),
   N111Call{"reply",N111U64{},"p111_rt_return",[p111_state(),p111_scratch(),p111_u32(1)]},
   N111Return{N111Local{"reply"}}]

@unsafe
def x193fc_helper() -> N111Segment:
  N111Segment{"p193fc_helper",1,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},x193fc_get("input",0),
    N111Bin{"answer",N111U64{},"add",N111Local{"input"},N111Const{1,0}}],x193fc_return(N111Local{"answer"}))}

@unsafe
def x193fc_cont() -> N111Segment:
  N111Segment{"p193fc_cont",2,1,1,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_stack("p111_rt_stack_pop","popped",1),x193fc_stack("p111_rt_stack_get","captured",0),x193fc_get("child",0),
    N111Bin{"answer",N111U64{},"add",N111Local{"captured"},N111Local{"child"}}],x193fc_return(N111Local{"answer"}))}

@unsafe
def x193fc_owner() -> N111Segment:
  N111Segment{"p193fc_owner",0,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_store(0,N111Const{7,1}),
    N111Call{"framed",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"p193fc_cont"}},p111_scratch(),p111_u32(1)]},
    x193fc_store(0,N111Const{11,2})],x193fc_jump("p193fc_helper",1))}

@unsafe
def x193fc_tail() -> N111Segment:
  N111Segment{"p193fc_tail",0,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_store(0,N111Const{11,2})],x193fc_jump("p193fc_helper",1))}

@unsafe
def x193fc_self() -> N111Segment:
  N111Segment{"p193fc_helper",1,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_get("input",0),x193fc_store(0,N111Local{"input"})],x193fc_jump("p193fc_helper",1))}

@unsafe
def x193fc_segments() -> List<&2,N111Segment>:
  [x193fc_owner(),x193fc_cont(),x193fc_helper(),x193fc_tail()]

@unsafe
def x193fc_ready() -> KDef: p111v_put(missing(),"p193fc_helper","P112Worker",1,0)

@unsafe
def x193fc_available() -> KDef: p111v_put(missing(),p112w_symbol("p193fc_helper"),"X181Forward",1,1)

@unsafe
def x193fc_ids() -> N111Ids:
  N111Ids{p111q_function_ids(x193fc_segments(),0,missing()),missing()}

@unsafe
def x193fc_plan(segment: N111Segment, fusion: Bool, tail: Bool, available: KDef) -> X193FBody:
  x193f_plan(segment,p112f_index(x193fc_segments()),x193fc_ready(),available,fusion,tail)

@unsafe
def x193fc_verified(segments: List<&2,N111Segment>, +ids: N111Ids) -> Bool:
  match segments:
    case Nil{}: True{}
    case Con{segment,rest}: String.is_empty(p111v_segment(segment,ids)) && x193fc_verified(rest,ids)

@unsafe
def x193fc_count(body: List<&2,N111Stmt>, +symbol: String) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111Call{name,typ,target,args},rest}:
      U32.add(nt_choose(U32,String.eq(symbol,target),u => 1,u => 0),x193fc_count(rest,symbol))
    case Con{N111If{condition,yes,no},rest}:
      U32.add(x193fc_count(yes,symbol),U32.add(x193fc_count(no,symbol),x193fc_count(rest,symbol)))
    case Con{stmt,rest}: x193fc_count(rest,symbol)

@unsafe
def x193fc_has(plan: X193FBody, symbol: String, count: U32) -> Bool:
  match plan:
    case X193FBody{body,calls,error}: String.is_empty(error) && U32.is_eq(x193fc_count(body,symbol),count)

def x193fc_refused(plan: X193FBody) -> Bool:
  match plan:
    case X193FBody{body,calls,error}: Bool.not(String.is_empty(error))

def x193fc_fusions(plan: P112FusionBody) -> U32:
  match plan:
    case P112FusionBody{body,count,site}: count

@unsafe
def x193fc_meta(segment: N111Segment, result: U32, flags: U32) -> N111Segment:
  match segment:
    case N111Segment{name,arity,old,incoming,prior,body}: N111Segment{name,arity,result,incoming,flags,body}

@unsafe
def x193fc_collision(segment: N111Segment) -> N111Segment:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      N111Segment{name,arity,result,incoming,flags,Con{N111Set{"p193f_result",N111U64{},N111Const{0,0}},body}}

@unsafe
def x193fc_row(+name: String, pass: Bool) -> String:
  nt_choose(String,pass,u => "PASS " ++ name,u => "FAIL " ++ name)

@unsafe
def x193fc_controls() -> List<&2,String>:
  +fused = x193fc_plan(x193fc_owner(),True{},False{},x193fc_available())
  +plain = x193fc_plan(x193fc_owner(),False{},False{},x193fc_available())
  +tail = x193fc_plan(x193fc_tail(),False{},True{},x193fc_available())
  [x193fc_row("original-segments-verified",x193fc_verified(x193fc_segments(),x193fc_ids())),
   x193fc_row("original-fusion-planner-one-site",U32.is_eq(x193fc_fusions(p112c_plan_index(x193fc_owner(),p112f_index(x193fc_segments()),x193fc_ready())),1)),
   x193fc_row("fusion-disabled-retains-frame",x193fc_has(plain,"p111_rt_frame",1)),
   x193fc_row("fusion-disabled-retains-jump",x193fc_has(plain,"p111_rt_jump",1)),
   x193fc_row("fusion-removes-frame",x193fc_has(fused,"p111_rt_frame",0)),
   x193fc_row("fusion-removes-jump",x193fc_has(fused,"p111_rt_jump",0)),
   x193fc_row("fusion-calls-ready-helper",x193fc_has(fused,p112w_symbol("p193fc_helper"),1)),
   x193fc_row("fusion-retains-pending-return",x193fc_has(fused,"p111_rt_return",1)),
   x193fc_row("tail-removes-jump",x193fc_has(tail,"p111_rt_jump",0)),
   x193fc_row("tail-calls-ready-helper",x193fc_has(tail,p112w_symbol("p193fc_helper"),1)),
   x193fc_row("tail-retains-pending-return",x193fc_has(tail,"p111_rt_return",1)),
   x193fc_row("tail-disabled-retains-jump",x193fc_has(x193fc_plan(x193fc_tail(),False{},False{},x193fc_available()),"p111_rt_jump",1)),
   x193fc_row("unavailable-fused-helper-refuses",x193fc_refused(x193fc_plan(x193fc_owner(),True{},False{},missing()))),
   x193fc_row("unavailable-tail-helper-refuses",x193fc_refused(x193fc_plan(x193fc_tail(),False{},True{},missing()))),
   x193fc_row("reserved-name-refuses",x193fc_refused(x193fc_plan(x193fc_collision(x193fc_tail()),False{},True{},x193fc_available()))),
   x193fc_row("reserved-read-refuses",Bool.not(x193f_clean([N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p193f_arg_0"}}]))),
   x193fc_row("self-tail-keeps-original",x193fc_has(x193fc_plan(x193fc_self(),False{},True{},x193fc_available()),"p111_rt_jump",1)),
   x193fc_row("flags-keep-original",x193fc_has(x193fc_plan(x193fc_meta(x193fc_tail(),1,1),False{},True{},x193fc_available()),"p111_rt_jump",1)),
   x193fc_row("multi-result-keeps-original",x193fc_has(x193fc_plan(x193fc_meta(x193fc_tail(),2,0),False{},True{},x193fc_available()),"p111_rt_jump",1)),
   x193fc_row("private-again-refuses",x193fc_refused(x193f_worker(P112WorkerAgain{}))),
   x193fc_row("private-result-refuses",x193fc_refused(x193f_worker(P112WorkerResult{})))]

# Direct typed emitter for root's independent machine observer. The helper
# exactly matches the ordinary one-result private ABI; no runtime C is altered.
@unsafe
def x193fc_private() -> X181Output:
  x181_function(p112w_symbol("p193fc_helper"),["state","input"],[
    P113DScalar{N111Bin{"answer",N111U64{},"add",N111Local{"input"},N111Const{1,0}}},
    P113DResult{[N111Local{"answer"}]}],x193fc_ids())

@unsafe
def x193fc_emit(+fusion: Bool, +tail: Bool) -> X181Output:
  x181_program_join(x193fc_private(),
    x181_program_join(x193f_emit_planned(x193fc_owner(),x193fc_ids(),x193fc_plan(x193fc_owner(),fusion,tail,x193fc_available())),
      x181_program_join(x181_segment(x193fc_cont(),x193fc_ids()),
        x181_program_join(x181_segment(x193fc_helper(),x193fc_ids()),
          x193f_emit_planned(x193fc_tail(),x193fc_ids(),x193fc_plan(x193fc_tail(),fusion,tail,x193fc_available()))))))
