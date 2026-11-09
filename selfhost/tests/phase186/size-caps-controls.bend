# Admission boundaries only. No generated function below is executed. Existing
# stacked-frame source/machine controls remain the semantic gate for the H path.
@unsafe
def p186hc_padding(+left: U32, +tail: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(left,0),u => tail,u =>
    Con{N111Set{"padding",N111U64{},N111Const{0,0}},p186hc_padding(U32.sub(left,1),tail)})

@unsafe
def p186hc_control_cont(nodes: U32) -> N111Segment:
  p111_segment("cap-cont",[NC_Binding{0,"result",N_W64{}}],0,1,
    p186hc_padding(U32.sub(nodes,3),p111_body(p111_return(N111Local{"result"},0))))

@unsafe
def p186hc_control_owner(nodes: U32) -> N111Segment:
  p111_segment("cap-owner",[NC_Binding{0,"n",N_W64{}}],0,0,
    p186hc_padding(U32.sub(nodes,6),nt_append(N111Stmt,p111_frame([],"cap-cont"),
      p111_body(p111_jump("cap-owner",[N111Local{"n"}],0)))))

@unsafe
def p186hc_control_h(+nodes: U32) -> Bool:
  p114h_valid(p114h_plan(p186hc_control_owner(nodes),
    p112f_index([p186hc_control_owner(nodes),p186hc_control_cont(3)]),missing()))

@unsafe
def p186hc_control_parser(nodes: U32) -> Bool:
  p186hc_cont_valid(p112f_cont(p186hc_control_cont(nodes),0))

def p186hc_control_size(segment: N111Segment) -> U32:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: p112f_size(body)

def p186hc_control_suffix(cont: Maybe<&2,P112FusionCont>) -> U32:
  match cont:
    case Some{P112FusionCont{captures,result,pop,body}}: p112f_size(body)
    case None{}: 4294967295

@unsafe
def p186hc_control_verified_scan(+segments: List<&2,N111Segment>, scan: P111VScan) -> String:
  match scan:
    case P111VScan{index,+error,count}:
      nt_choose(String,String.is_empty(error),u => p111v_segments(segments,N111Ids{index,missing()}),u => error)

@unsafe
def p186hc_control_verified(+owner: U32, +continuation: U32) -> String:
  +segments: List<&2,N111Segment> = [p186hc_control_owner(owner),p186hc_control_cont(continuation)]
  p186hc_control_verified_scan(segments,p111v_functions(segments,P111VScan{missing(),"",0}))

def p186hc_control_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ p186hc_bool(ok)

@unsafe
def p186hc_controls(+widened: Bool) -> List<&2,String>:
  [p186hc_control_row("owner-size-exact",U32.is_eq(p186hc_control_size(p186hc_control_owner(2049)),2049)),
   p186hc_control_row("continuation-size-exact",U32.is_eq(p186hc_control_suffix(p186hc_cont(p186hc_control_cont(1025),0)),1025)),
   p186hc_control_row("original-ir-verified",String.is_empty(p186hc_control_verified(2049,1025))),
   p186hc_control_row("owner512",p186hc_control_h(512)),
   p186hc_control_row("owner513",U32.is_eq(nt_bool(p186hc_control_h(513)),nt_bool(widened))),
   p186hc_control_row("owner2048",U32.is_eq(nt_bool(p186hc_control_h(2048)),nt_bool(widened))),
   p186hc_control_row("owner2049-refused",Bool.not(p186hc_control_h(2049))),
   p186hc_control_row("continuation128",p186hc_control_parser(128)),
   p186hc_control_row("continuation129",U32.is_eq(nt_bool(p186hc_control_parser(129)),nt_bool(widened))),
   p186hc_control_row("continuation1024",U32.is_eq(nt_bool(p186hc_control_parser(1024)),nt_bool(widened))),
   p186hc_control_row("continuation1025-refused",Bool.not(p186hc_control_parser(1025)))]
