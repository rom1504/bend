# These controls apply only transient placement, deliberately retaining the
# call-shaped IR and operand stores. Other passes cannot erase the hazards.
# The public pointer controls pass the unchanged segment verifier; Offset is
# intentionally not smuggled through the narrower direct-function verifier.
def p186ie_v(name: String) -> N111Value: N111Local{name}

def p186ie_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

def p186ie_call(name: String, id: U32, count: U32, buffer: String) -> N111Stmt:
  N111Call{name,N111U64{},"p111_rt_op",[p111_state(),p111_u32(id),
    N111Arg{N111Ptr{},N111Local{buffer}},p111_u32(count)]}

@unsafe
def p186ie_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p186ie_params(rest,U32.inc(index))}

@unsafe
def p186ie_fn(name: String, params: List<&2,String>, result: U32, body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,p186ie_params(params,0),result,False{},body}

@unsafe
def p186ie_binary(name: String, id: U32) -> P113DFunction:
  p186ie_fn(name,["a","b","marker"],3,
    [p186ie_bin("live","xor",p186ie_v("marker"),N111Const{2779096485,1515870810}),
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),0,p186ie_v("a")}},
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),8,p186ie_v("b")}},
     P113DScalar{p186ie_call("result",id,2,"scratch")},
     p186ie_bin("after","add",p186ie_v("live"),N111Const{1,0}),
     P113DResult{[p186ie_v("result"),p186ie_v("live"),p186ie_v("after")]}])

@unsafe
def p186ie_alias() -> P113DFunction:
  p186ie_fn("p186ik",["a","b"],2,
    [P113DScalar{N111Set{"result",N111U64{},p186ie_v("a")}},
     P113DScalar{N111Set{"saved",N111U64{},p186ie_v("result")}},
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),0,p186ie_v("result")}},
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),8,p186ie_v("b")}},
     P113DScalar{p186ie_call("result",26,2,"scratch")},
     P113DResult{[p186ie_v("result"),p186ie_v("saved")]}])

@unsafe
def p186ie_fallback() -> P113DFunction:
  p186ie_fn("p186il",["a","marker"],2,
    [p186ie_bin("live","add",p186ie_v("marker"),N111Const{7,0}),
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),0,p186ie_v("a")}},
     P113DScalar{p186ie_call("result",36,1,"scratch")},
     P113DResult{[p186ie_v("result"),p186ie_v("live")]}])

@unsafe
def p186ie_pressure() -> P113DFunction:
  p186ie_fn("p186io",["a","b","marker"],6,
    [p186ie_bin("live0","add",p186ie_v("marker"),N111Const{1,0}),
     p186ie_bin("live1","add",p186ie_v("marker"),N111Const{2,0}),
     p186ie_bin("live2","add",p186ie_v("marker"),N111Const{3,0}),
     p186ie_bin("live3","add",p186ie_v("marker"),N111Const{4,0}),
     p186ie_bin("live4","add",p186ie_v("marker"),N111Const{5,0}),
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),0,p186ie_v("a")}},
     P113DScalar{N111Store{N111U64{},p186ie_v("scratch"),8,p186ie_v("b")}},
     P113DScalar{p186ie_call("result",26,2,"scratch")},
     P113DResult{[p186ie_v("result"),p186ie_v("live0"),p186ie_v("live1"),
       p186ie_v("live2"),p186ie_v("live3"),p186ie_v("live4")]}])

@unsafe
def p186ie_functions() -> List<&2,P113DFunction>:
  [p186ie_binary("p186ia",26),p186ie_binary("p186ib",27),p186ie_binary("p186ic",28),
   p186ie_binary("p186id",29),p186ie_binary("p186ie",30),p186ie_binary("p186if",31),
   p186ie_binary("p186ig",32),p186ie_binary("p186ih",33),p186ie_binary("p186ii",34),
   p186ie_binary("p186ij",35),p186ie_alias(),p186ie_fallback(),p186ie_pressure()]

def p186ie_pointer(name: String) -> N111Segment:
  N111Segment{name,0,1,0,0,
    [N111Alloca{"buffer",16,8},N111Offset{"address",p186ie_v("buffer"),N111Const{0,0}},
     N111Load{"a",N111U64{},p186ie_v("state"),0},
     N111Load{"b",N111U64{},p186ie_v("state"),8},
     N111Load{"live",N111U64{},p186ie_v("state"),16},
     N111Store{N111U64{},p186ie_v("address"),0,p186ie_v("a")},
     N111Store{N111U64{},p186ie_v("address"),8,p186ie_v("b")},
     p186ie_call("result",26,2,"address"),
     N111Bin{"answer",N111U64{},"xor",p186ie_v("result"),p186ie_v("live")},
     N111Return{p186ie_v("answer")}]}

@unsafe
def p186ie_names(params: List<&2,NC_Binding>) -> List<&2,String>:
  Con{"state",Con{"__x181_result_out",x181_param_names(params)}}

@unsafe
def p186ie_frame(function: P113DFunction) -> X181Frame:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      +names = p186ie_names(params)
      x185_transient_frame(x181_frame(p113e_symbol(name),names,body),names,[],body)

@unsafe
def p186ie_pointer_frame(segment: N111Segment, +transient: Bool) -> X181Frame:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      +rows = x181_scalar_rows(body)
      +frame = x181_frame(p111q_symbol(name),["state"],rows)
      nt_choose(X181Frame,transient,u => x185_transient_frame(frame,["state"],[],rows),u => frame)

@unsafe
def p186ie_home(frame: X181Frame, name: String) -> KDef:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: p111v_get(slots,name)

@unsafe
def p186ie_is(function: P113DFunction, name: String, kind: String) -> Bool:
  String.eq(dk(p186ie_home(p186ie_frame(function),name)),kind)

@unsafe
def p186ie_emit_function(+function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x185_function_frame(p113e_symbol(name),[],body,N111Ids{missing(),missing()},p186ie_frame(function))

@unsafe
def p186ie_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p186ie_emit_function(head),p186ie_emit_functions(rest))

@unsafe
def p186ie_emit_pointer(+segment: N111Segment, transient: Bool) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x185_function_frame(p111q_symbol(name),[],x181_scalar_rows(body),N111Ids{missing(),missing()},
        p186ie_pointer_frame(segment,transient))

@unsafe
def p186ie_emit() -> X181Output:
  x181_program_join(p186ie_emit_functions(p186ie_functions()),
    x181_program_join(p186ie_emit_pointer(p186ie_pointer("p186im"),True{}),
      p186ie_emit_pointer(p186ie_pointer("p186in"),False{})))

@unsafe
def p186ie_validate() -> String:
  p111_first(p113e_functions(p186ie_functions(),N111Ids{missing(),missing()},missing()),
    p111v_segments([p186ie_pointer("p186im"),p186ie_pointer("p186in")],N111Ids{missing(),missing()}))

def p186ie_admitted(operation: X186InlineOp) -> Bool:
  match operation:
    case X186InlineF32{destination,id,buffer}: True{}
    case X186InlineNone{}: False{}

@unsafe
def p186ie_all_binary(+id: U32) -> Bool:
  nt_choose(Bool,U32.is_gt(id,35),u => True{},u =>
    p186ie_admitted(x186_inline_op(p186ie_call("result",id,2,"scratch"))) &&
    p186ie_is(p186ie_binary("probe",id),"live","X185Transient") &&
    p186ie_is(p186ie_binary("probe",id),"result","X185Transient") && p186ie_all_binary(U32.inc(id)))

@unsafe
def p186ie_pressure_homes(+index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,5),u => True{},u =>
    U32.is_eq(da(p186ie_home(p186ie_frame(p186ie_pressure()),"live" ++ U32.show(index))),index) &&
    p186ie_is(p186ie_pressure(),"live" ++ U32.show(index),"X185Transient") && p186ie_pressure_homes(U32.inc(index)))

@unsafe
def p186ie_pointer_distinct() -> Bool:
  +frame = p186ie_pointer_frame(p186ie_pointer("probe"),True{})
  +address = p186ie_home(frame,"address")
  +result = p186ie_home(frame,"result")
  String.eq(dk(address),"X185Transient") && String.eq(dk(result),"X185Transient") && Bool.not(U32.is_eq(da(address),da(result)))

@unsafe
def p186ie_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p186ie_controls() -> List<&2,String>:
  [p186ie_row("verified",String.is_empty(p186ie_validate())),
   p186ie_row("all-ten-live-across",p186ie_all_binary(26)),
   p186ie_row("disabled-summary",Bool.not(p186ie_admitted(x186_inline_op_when(False{},p186ie_call("result",26,2,"scratch"))))),
   p186ie_row("unsupported-barrier",Bool.not(p186ie_admitted(x186_inline_op(p186ie_call("result",36,1,"scratch"))))),
   p186ie_row("fallback-live-stacked",p186ie_is(p186ie_fallback(),"live","X181Stack")),
   p186ie_row("fallback-result-stacked",p186ie_is(p186ie_fallback(),"result","X181Stack")),
   p186ie_row("input-result-overwrite",p186ie_is(p186ie_alias(),"result","X185Transient")),
   p186ie_row("old-input-survives",p186ie_is(p186ie_alias(),"saved","X185Transient")),
   p186ie_row("all-five-homes-live",p186ie_pressure_homes(0)),
   p186ie_row("pressure-result-stacked",p186ie_is(p186ie_pressure(),"result","X181Stack")),
   p186ie_row("pointer-read-before-result",p186ie_pointer_distinct()),
   p186ie_row("pointer-stack-home",String.eq(dk(p186ie_home(p186ie_pointer_frame(p186ie_pointer("probe"),False{}),"address")),"X181Stack")),
   p186ie_row("wrong-count",Bool.not(p186ie_admitted(x186_inline_op(p186ie_call("result",26,1,"scratch"))))),
   p186ie_row("conversion-call",Bool.not(p186ie_admitted(x186_inline_op(p186ie_call("result",23,1,"scratch"))))),
   p186ie_row("wrong-state",Bool.not(p186ie_admitted(x186_inline_op(N111Call{"result",N111U64{},"p111_rt_op",[
     N111Arg{N111Ptr{},N111Local{"other"}},p111_u32(26),p111_scratch(),p111_u32(2)]})))),
   p186ie_row("wrong-symbol",Bool.not(p186ie_admitted(x186_inline_op(N111Call{"result",N111U64{},"p111_rt_other",[
     p111_state(),p111_u32(26),p111_scratch(),p111_u32(2)]}))))]
