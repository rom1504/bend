# Append public-fusion-controls.bend for its scalar fixture constructors.
# These are ordinary independently verified segments. The ready set is produced
# by the original worker admission, rather than a manufactured valid plan.
@unsafe
def p193rf_helper() -> N111Segment:
  N111Segment{"p193rf_helper",2,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_get("a",0),x193fc_get("b",1),
    N111Bin{"twice",N111U64{},"add",N111Local{"a"},N111Local{"a"}},
    N111Bin{"answer",N111U64{},"add",N111Local{"twice"},N111Local{"b"}}],x193fc_return(N111Local{"answer"}))}

@unsafe
def p193rf_owner() -> N111Segment:
  N111Segment{"p193rf_owner",2,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_get("x",0),x193fc_get("y",1),x193fc_store(0,N111Local{"x"}),
    N111Call{"framed",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"p193rf_cont"}},p111_scratch(),p111_u32(1)]},
    N111Bin{"x",N111U64{},"add",N111Local{"x"},N111Const{6,0}},
    N111Bin{"x",N111U64{},"add",N111Local{"x"},N111Local{"framed"}},
    x193fc_store(0,N111Local{"x"}),x193fc_store(1,N111Local{"y"})],x193fc_jump("p193rf_helper",2))}

@unsafe
def p193rf_cont() -> N111Segment:
  N111Segment{"p193rf_cont",2,1,1,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_stack("p111_rt_stack_pop","popped",1),x193fc_stack("p111_rt_stack_get","captured",0),x193fc_get("child",0),
    N111Bin{"answer",N111U64{},"add",N111Local{"captured"},N111Local{"child"}},
    N111Bin{"answer",N111U64{},"add",N111Local{"answer"},N111Local{"popped"}}],x193fc_return(N111Local{"answer"}))}

@unsafe
def p193rf_tail() -> N111Segment:
  N111Segment{"p193rf_tail",2,1,0,0,nt_append(N111Stmt,[N111Alloca{"scratch",2048,8},
    x193fc_get("x",0),x193fc_get("y",1),x193fc_store(0,N111Local{"y"}),
    x193fc_store(1,N111Local{"x"})],x193fc_jump("p193rf_helper",2))}

def p193rf_segments() -> List<&2,N111Segment>:
  [p193rf_owner(),p193rf_cont(),p193rf_helper(),p193rf_tail()]

@unsafe
def p193rf_ids() -> N111Ids:
  N111Ids{p111q_function_ids(p193rf_segments(),0,missing()),missing()}

@unsafe
def p193rf_ready() -> KDef: p112w_index([p193rf_helper()])

# This exact private provider is emitted below. Its arity and single-word ABI
# agree with the original admitted helper and the ordinary public helper body.
@unsafe
def p193rf_available() -> KDef:
  p111v_put(missing(),p112w_symbol("p193rf_helper"),"X181Forward",2,1)

@unsafe
def p193rf_plan(segment: N111Segment, fusion: Bool, tail: Bool) -> X193FBody:
  x193f_plan(segment,p112f_index(p193rf_segments()),p193rf_ready(),p193rf_available(),fusion,tail)

@unsafe
def p193rf_validate() -> String:
  nt_choose(String,x193fc_verified(p193rf_segments(),p193rf_ids()) &&
    p112w_admitted(p112w_plan(p193rf_helper(),missing())),u => "",u => "original ready fusion fixture refused")

def p193rf_row(name: String, pass: Bool) -> String:
  name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")

@unsafe
def p193rf_controls() -> List<&2,String>:
  [p193rf_row("original-segments-verified",String.is_empty(p193rf_validate())),
   p193rf_row("helper-original-admission",p112w_ready(p193rf_ready(),"p193rf_helper")),
   p193rf_row("capture-gap-original-fusion",U32.is_eq(x193fc_fusions(p112c_plan_index(p193rf_owner(),p112f_index(p193rf_segments()),p193rf_ready())),1)),
   p193rf_row("fusion-preserves-public-return",x193fc_has(p193rf_plan(p193rf_owner(),True{},False{}),"p111_rt_return",1)),
   p193rf_row("fusion-removes-local-frame",x193fc_has(p193rf_plan(p193rf_owner(),True{},False{}),"p111_rt_frame",0)),
   p193rf_row("plain-preserves-local-frame",x193fc_has(p193rf_plan(p193rf_owner(),False{},False{}),"p111_rt_frame",1)),
   p193rf_row("tail-original-ready-transfer",x193fc_has(p193rf_plan(p193rf_tail(),False{},True{}),p112w_symbol("p193rf_helper"),1)),
   p193rf_row("tail-preserves-public-return",x193fc_has(p193rf_plan(p193rf_tail(),False{},True{}),"p111_rt_return",1)),
   p193rf_row("unavailable-refuses",x193fc_refused(x193f_plan(p193rf_owner(),p112f_index(p193rf_segments()),p193rf_ready(),missing(),True{},True{}))),
   p193rf_row("missing-ready-keeps-frame",x193fc_has(x193f_plan(p193rf_owner(),p112f_index(p193rf_segments()),missing(),p193rf_available(),True{},True{}),"p111_rt_frame",1)),
   p193rf_row("wrong-ready-arity-keeps-jump",x193fc_has(x193f_plan(p193rf_tail(),p112f_index(p193rf_segments()),
     p111v_put(missing(),"p193rf_helper","P112Worker",1,0),p193rf_available(),False{},True{}),"p111_rt_jump",1)),
   p193rf_row("malformed-frame-original-refusal",Bool.not(String.is_empty(p111v_segment(
     N111Segment{"p193rf_bad",0,1,0,0,[N111Alloca{"scratch",2048,8},
       N111Call{"framed",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"p193rf_cont"}},p111_scratch(),p111_u32(0)]},
       N111Return{N111Local{"framed"}}]},p193rf_ids())))),
   p193rf_row("nested-reserved-use-refuses",Bool.not(x193f_clean([N111If{N111Const{1,0},[N111Return{N111Local{"p193f_reply"}}],[]}])))]

@unsafe
def p193rf_named(symbol: String, segment: N111Segment, plan: X193FBody) -> X181Output:
  match plan:
    case X193FBody{body,calls,+error}:
      nt_choose(X181Output,String.is_empty(error),u => x181_function(symbol,["state"],x181_scalar_rows(body),p193rf_ids()),
        u => X181Output{[],error})

@unsafe
def p193rf_original(symbol: String, segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x181_function(symbol,["state"],x181_scalar_rows(body),p193rf_ids())

@unsafe
def p193rf_private() -> X181Output:
  x181_function(p112w_symbol("p193rf_helper"),["state","a","b"],[
    P113DScalar{N111Bin{"twice",N111U64{},"add",N111Local{"a"},N111Local{"a"}}},
    P113DScalar{N111Bin{"answer",N111U64{},"add",N111Local{"twice"},N111Local{"b"}}},
    P113DResult{[N111Local{"answer"}]}],p193rf_ids())

@unsafe
def p193rf_emit(+fusion: Bool, +tail: Bool) -> X181Output:
  x181_program_join(p193rf_private(),x181_program_join(
    p193rf_named("p193rf_owner",p193rf_owner(),p193rf_plan(p193rf_owner(),fusion,tail)),x181_program_join(
    p193rf_named("p193rf_tail",p193rf_tail(),p193rf_plan(p193rf_tail(),fusion,tail)),x181_program_join(
    p193rf_original("p193rf_cont",p193rf_cont()),p193rf_original("p193rf_helper",p193rf_helper())))))

@unsafe
def p193rf_emit_plain() -> X181Output: p193rf_emit(False{},False{})
@unsafe
def p193rf_emit_fusion() -> X181Output: p193rf_emit(True{},False{})
@unsafe
def p193rf_emit_tail() -> X181Output: p193rf_emit(False{},True{})
@unsafe
def p193rf_emit_both() -> X181Output: p193rf_emit(True{},True{})
