# DCE controls exercise the pass directly, avoiding preceding copy/fact passes
# that could erase the intended liveness hazards. All original IR is verified.

def p185dc_math() -> P113DFunction:
  P113DFunction{"p185da",p185cp_params(["a","b"],0),1,False{},
    [p185x_bin("dead_first",N111U64{},"add",p185x_v("a"),N111Const{4294967295,4294967295}),
     p185x_bin("dead_second",N111U64{},"mul",p185x_v("dead_first"),p185x_v("b")),
     p185cp_set("dead_copy",p185x_v("dead_second")),
     p185x_bin("answer",N111U64{},"sub",p185x_v("a"),p185x_v("b")),
     P113DResult{[p185x_v("answer")]}]}

def p185dc_memory() -> P113DFunction:
  P113DFunction{"p185db",p185cp_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"buffer",16,8}},
     P113DScalar{N111Store{N111U64{},p185x_v("buffer"),0,p185x_v("a")}},
     P113DScalar{N111Load{"unused_load",N111U64{},p185x_v("buffer"),0}},
     p185x_bin("dead_after_load",N111U64{},"add",p185x_v("unused_load"),N111Const{1,0}),
     P113DScalar{N111Store{N111U64{},p185x_v("buffer"),8,p185x_v("b")}},
     P113DScalar{N111Load{"answer",N111U64{},p185x_v("buffer"),8}},
     P113DResult{[p185x_v("answer")]}]}

def p185dc_branch() -> P113DFunction:
  P113DFunction{"p185dc",p185cp_params(["a","b"],0),1,False{},
    [p185cp_set("answer",p185x_v("a")),
     p185x_bin("zero",N111U64{},"eq",p185x_v("a"),N111Const{0,0}),
     P113DIf{p185x_v("zero"),[p185cp_set("answer",p185x_v("b"))],
       [p185x_bin("dead_branch",N111U64{},"add",p185x_v("a"),N111Const{1,0})]},
     P113DResult{[p185x_v("answer")]}]}

def p185dc_callee() -> P113DFunction:
  P113DFunction{"p185dd",p185cp_params(["a"],0),2,False{},
    [p185x_bin("next",N111U64{},"add",p185x_v("a"),N111Const{1,0}),
     P113DResult{[p185x_v("a"),p185x_v("next")]}]}

def p185dc_calls() -> P113DFunction:
  P113DFunction{"p185de",p185cp_params(["a"],0),1,False{},
    [p185x_bin("before",N111U64{},"mul",p185x_v("a"),N111Const{3,0}),
     P113DCall{["unused_first","unused_second"],"p185dd",[p185x_v("a")]},
     P113DCall{["left","right"],"p185dd",[p185x_v("a")]},
     p185cp_set("dead_call_copy",p185x_v("left")),
     p185x_bin("answer",N111U64{},"add",p185x_v("before"),p185x_v("right")),
     P113DResult{[p185x_v("answer")]}]}

def p185dc_setup() -> List<&2,P113DStmt>:
  [p185cp_set("saved",p185x_v("a"))]

def p185dc_setup_body() -> List<&2,P113DStmt>:
  [p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
   P113DIf{p185x_v("done"),[P113DResult{[p185x_v("saved")]}],
     [p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
      p185x_bin("saved",N111U64{},"add",p185x_v("saved"),N111Const{1,0}),
      P113DAgain{[p185x_v("next"),p185x_v("a")]}]}]

@unsafe
def p185dc_setup_function(+candidate: Bool) -> P113DFunction:
  P113DFunction{"p185df",p185cp_params(["n","a"],0),1,False{},
    nt_append(P113DStmt,p185dc_setup(),nt_choose(List<&2,P113DStmt>,candidate,
      u => x185_dead_body(p185dc_setup(),p185dc_setup_body()),u => p185dc_setup_body()))}

def p185dc_segment() -> N111Segment:
  N111Segment{"p185dg",0,1,0,0,
    [N111Alloca{"buffer",16,8},N111Offset{"dead_offset",p185x_v("buffer"),N111Const{8,0}},
     N111Store{N111U64{},p185x_v("buffer"),0,N111Const{5,0}},
     N111Load{"answer",N111U64{},p185x_v("buffer"),0},N111Return{p185x_v("answer")}]}

def p185dc_functions() -> List<&2,P113DFunction>:
  [p185dc_math(),p185dc_memory(),p185dc_branch(),p185dc_callee(),p185dc_calls()]

@unsafe
def p185dc_candidate(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,x185_dead_body([],body)}

@unsafe
def p185dc_candidates(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p185dc_candidate(head),p185dc_candidates(rest)}

@unsafe
def p185dc_validate() -> String:
  p111_first(p111v_segment(p185dc_segment(),N111Ids{missing(),missing()}),
    p111_first(p113e_functions(Con{p185dc_setup_function(False{}),p185dc_functions()},N111Ids{missing(),missing()},missing()),
      p113e_functions(Con{p185dc_setup_function(True{}),p185dc_candidates(p185dc_functions())},N111Ids{missing(),missing()},missing())))

@unsafe
def p185dc_emit_one(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      x185_function_copied(p113e_symbol(name),Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
        u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})},[],
        x185_dead_body([],body),N111Ids{missing(),missing()})

@unsafe
def p185dc_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p185dc_emit_one(head),p185dc_emit_functions(rest))

@unsafe
def p185dc_emit_segment(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x185_function_copied(p111q_symbol(name),["state"],[],x185_dead_body([],x181_scalar_rows(body)),N111Ids{missing(),missing()})

@unsafe
def p185dc_emit() -> X181Output:
  x181_program_join(p185dc_emit_functions(p185dc_functions()),
    x181_program_join(x185_function_copied(p113e_symbol("p185df"),["state","n","a"],p185dc_setup(),
      x185_dead_body(p185dc_setup(),p185dc_setup_body()),N111Ids{missing(),missing()}),p185dc_emit_segment(p185dc_segment())))

@unsafe
def p185dc_has(function: P113DFunction, name: String) -> Bool:
  match function:
    case P113DFunction{symbol,params,result,public,body}:
      U32.is_gt(da(p111v_get(x185_copy_writes(x185_dead_body([],body),missing()),name)),0)

@unsafe
def p185dc_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p185dc_controls() -> List<&2,String>:
  [p185dc_row("dead-chain-removed",Bool.not(p185dc_has(p185dc_math(),"dead_first")) && Bool.not(p185dc_has(p185dc_math(),"dead_second")) && Bool.not(p185dc_has(p185dc_math(),"dead_copy"))),
   p185dc_row("dead-load-retained",p185dc_has(p185dc_memory(),"unused_load")),
   p185dc_row("dead-load-consumer-removed",Bool.not(p185dc_has(p185dc_memory(),"dead_after_load"))),
   p185dc_row("alloca-retained",p185dc_has(p185dc_memory(),"buffer")),
   p185dc_row("dead-call-retained",p185dc_has(p185dc_calls(),"unused_first") && p185dc_has(p185dc_calls(),"unused_second")),
   p185dc_row("call-consumer-removed",Bool.not(p185dc_has(p185dc_calls(),"dead_call_copy"))),
   p185dc_row("branch-join-retained",p185dc_has(p185dc_branch(),"answer") && Bool.not(p185dc_has(p185dc_branch(),"dead_branch"))),
   p185dc_row("entry-value-live-across-again",U32.is_eq(da(p111v_get(x185_copy_writes(x185_dead_body(p185dc_setup(),p185dc_setup_body()),missing()),"saved")),1))]
