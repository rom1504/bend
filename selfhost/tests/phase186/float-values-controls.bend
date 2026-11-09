# The original verified IR is preserved. The custom emitter invokes only the
# final private F32 plan so prior copy/fact passes cannot erase these hazards.
def p186fv_store(offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),offset,value}}

def p186fv_load(name: String, offset: U32) -> P113DStmt:
  P113DScalar{N111Load{name,N111U64{},p186ie_v("scratch"),offset}}

@unsafe
def p186fv_mutation() -> P113DFunction:
  p186ie_fn("p186va",["a","b","changed"],2,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     P113DScalar{N111Set{"a",N111U64{},p186ie_v("changed")}},
     P113DScalar{p186ie_call("result",26,2,"scratch")},
     P113DResult{[p186ie_v("result"),p186ie_v("a")]}])

@unsafe
def p186fv_observed() -> P113DFunction:
  p186ie_fn("p186vb",["a","b"],3,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     P113DScalar{p186ie_call("result",26,2,"scratch")},p186fv_load("left",0),p186fv_load("right",8),
     P113DResult{[p186ie_v("result"),p186ie_v("left"),p186ie_v("right")]}])

@unsafe
def p186fv_overlap() -> P113DFunction:
  p186ie_fn("p186vc",["a","b"],1,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     P113DScalar{N111Store{N111U32{},p186ie_v("scratch"),0,N111Const{1073741824,0}}},
     P113DScalar{p186ie_call("result",26,2,"scratch")},P113DResult{[p186ie_v("result")]}])

@unsafe
def p186fv_barrier() -> P113DFunction:
  p186ie_fn("p186vd",["a","b"],1,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     P113DScalar{p186ie_call("ignored",36,1,"scratch")},
     P113DScalar{p186ie_call("result",26,2,"scratch")},P113DResult{[p186ie_v("result")]}])

@unsafe
def p186fv_branch() -> P113DFunction:
  p186ie_fn("p186ve",["a","b","marker"],1,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     p186ie_bin("zero","eq",p186ie_v("marker"),N111Const{0,0}),
     P113DIf{p186ie_v("zero"),[p186fv_store(0,N111Const{1073741824,0})],[]},
     P113DScalar{p186ie_call("result",26,2,"scratch")},P113DResult{[p186ie_v("result")]}])

@unsafe
def p186fv_again() -> P113DFunction:
  p186ie_fn("p186vf",["n","word"],1,
    [p186ie_bin("done","eq",p186ie_v("n"),N111Const{0,0}),
     P113DIf{p186ie_v("done"),[P113DResult{[p186ie_v("word")]}],
       [p186fv_store(0,p186ie_v("word")),p186fv_store(8,N111Const{1056964608,0}),
        P113DScalar{p186ie_call("result",26,2,"scratch")},
        p186ie_bin("next","sub",p186ie_v("n"),N111Const{1,0}),
        P113DAgain{[p186ie_v("next"),p186ie_v("result")]}]}])

def p186fv_alias() -> N111Segment:
  N111Segment{"p186vg",0,1,0,0,
    [N111Alloca{"buffer",16,8},N111Load{"a",N111U64{},p186ie_v("state"),0},
     N111Load{"b",N111U64{},p186ie_v("state"),8},
     N111Store{N111U64{},p186ie_v("buffer"),0,p186ie_v("a")},
     N111Store{N111U64{},p186ie_v("buffer"),8,p186ie_v("b")},
     N111Offset{"alias",p186ie_v("buffer"),N111Const{0,0}},
     N111Store{N111U64{},p186ie_v("alias"),0,N111Const{1073741824,0}},
     p186ie_call("result",26,2,"buffer"),N111Return{p186ie_v("result")}]}

@unsafe
def p186fv_escape() -> P113DFunction:
  p186ie_fn("p186vh",["a","b"],2,
    [p186fv_store(0,p186ie_v("a")),p186fv_store(8,p186ie_v("b")),
     P113DScalar{p186ie_call("result",26,2,"scratch")},
     P113DScalar{p186ie_call("escaped",36,1,"scratch")},
     P113DResult{[p186ie_v("result"),p186ie_v("escaped")]}])

@unsafe
def p186fv_functions() -> List<&2,P113DFunction>:
  [p186fv_mutation(),p186fv_observed(),p186fv_overlap(),p186fv_barrier(),p186fv_branch(),p186fv_again(),p186fv_escape()]

@unsafe
def p186fv_names(+params: List<&2,NC_Binding>, result: U32) -> List<&2,String>:
  Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),u => x181_param_names(params),
    u => Con{"__x181_result_out",x181_param_names(params)})}

@unsafe
def p186fv_emit_function(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x186_float_function(p113e_symbol(name),p186fv_names(params,result),[],body,N111Ids{missing(),missing()})

@unsafe
def p186fv_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p186fv_emit_function(head),p186fv_emit_functions(rest))

@unsafe
def p186fv_emit_segment(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x186_float_function(p111q_symbol(name),["state"],[],x181_scalar_rows(body),N111Ids{missing(),missing()})

@unsafe
def p186fv_emit() -> X181Output:
  x181_program_join(p186fv_emit_functions(nt_append(P113DFunction,p186ie_functions(),p186fv_functions())),
    x181_program_join(p186fv_emit_segment(p186ie_pointer("p186im")),
      x181_program_join(p186fv_emit_segment(p186ie_pointer("p186in")),p186fv_emit_segment(p186fv_alias()))))

@unsafe
def p186fv_validate() -> String:
  p111_first(p186ie_validate(),p111_first(p113e_functions(p186fv_functions(),N111Ids{missing(),missing()},missing()),
    p111v_segment(p186fv_alias(),N111Ids{missing(),missing()})))

@unsafe
def p186fv_nodes(function: P113DFunction) -> List<&2,X186FloatNode>:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      +names = p186fv_names(params,result)
      x186_f_ready(names,[],x186_f_plan(body,x186_f_buffers(names,[],body),[]))

law p186fv_count:
  for nodes: List<&2,X186FloatNode>
  for +kind: U32
  U32

@unsafe
def p186fv_count(nodes,kind):
  match nodes:
    case Nil{}: 0
    case Con{X186FloatValues{destination,id,left,right},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,1),u => 1,u => 0),p186fv_count(rest,kind))
    case Con{X186FloatPlain{P113DScalar{N111Store{typ,base,offset,value}}},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,2),u => 1,u => 0),p186fv_count(rest,kind))
    case Con{X186FloatBranch{condition,yes,no},rest}:
      U32.add(U32.add(p186fv_count(yes,kind),p186fv_count(no,kind)),p186fv_count(rest,kind))
    case Con{head,rest}: p186fv_count(rest,kind)

@unsafe
def p186fv_all(+id: U32) -> Bool:
  nt_choose(Bool,U32.is_gt(id,35),u => True{},u =>
    U32.is_eq(p186fv_count(p186fv_nodes(p186ie_binary("probe",id)),1),1) &&
    U32.is_eq(p186fv_count(p186fv_nodes(p186ie_binary("probe",id)),2),0) && p186fv_all(U32.inc(id)))

@unsafe
def p186fv_controls() -> List<&2,String>:
  [p186ie_row("original-ir-verified",String.is_empty(p186fv_validate())),
   p186ie_row("all-ten-forwarded-store-free",p186fv_all(26)),
   p186ie_row("mutation-refused",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_mutation()),1),0)),
   p186ie_row("mutation-stores-retained",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_mutation()),2),2)),
   p186ie_row("observed-still-forwarded",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_observed()),1),1)),
   p186ie_row("observed-stores-retained",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_observed()),2),2)),
   p186ie_row("overlap-refused",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_overlap()),1),0)),
   p186ie_row("call-barrier-refused",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_barrier()),1),0)),
   p186ie_row("branch-barrier-refused",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_branch()),1),0)),
   p186ie_row("again-body-forwarded",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_again()),1),1)),
   p186ie_row("again-stores-removed",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_again()),2),0)),
   p186ie_row("escape-still-forwarded",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_escape()),1),1)),
   p186ie_row("escape-stores-retained",U32.is_eq(p186fv_count(p186fv_nodes(p186fv_escape()),2),2)),
   p186ie_row("result-input-alias-forwarded",U32.is_eq(p186fv_count(p186fv_nodes(p186ie_alias()),1),1)),
   p186ie_row("unsupported-call-retained",U32.is_eq(p186fv_count(p186fv_nodes(p186ie_fallback()),1),0))]
