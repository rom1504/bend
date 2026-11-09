def p185sf_store(+offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},N111Local{"scratch"},offset,value}}

def p185sf_load(name: String, offset: U32) -> P113DStmt:
  P113DScalar{N111Load{name,N111U64{},N111Local{"scratch"},offset}}

def p185sf_exact() -> P113DFunction:
  P113DFunction{"p185sa",p185cp_params(["a","b"],0),1,False{},
    [p185sf_store(0,p185x_v("a")),p185sf_store(8,p185x_v("b")),
     p185sf_load("x",0),p185sf_load("y",8),p185x_bin("answer",N111U64{},"add",p185x_v("x"),p185x_v("y")),
     P113DResult{[p185x_v("answer")]}]}

def p185sf_mutation() -> P113DFunction:
  P113DFunction{"p185sb",p185cp_params(["a","b"],0),2,False{},
    [p185sf_store(0,p185x_v("a")),p185cp_set("a",p185x_v("b")),p185sf_load("x",0),
     P113DResult{[p185x_v("x"),p185x_v("a")]}]}

def p185sf_overlap() -> P113DFunction:
  P113DFunction{"p185sc",p185cp_params(["a"],0),1,False{},
    [p185sf_store(0,p185x_v("a")),P113DScalar{N111Store{N111U32{},p185x_v("scratch"),4,N111Const{2864434397,0}}},
     p185sf_load("x",0),P113DResult{[p185x_v("x")]}]}

def p185sf_disjoint() -> P113DFunction:
  P113DFunction{"p185sd",p185cp_params(["a"],0),1,False{},
    [p185sf_store(0,p185x_v("a")),P113DScalar{N111Store{N111U32{},p185x_v("scratch"),8,N111Const{1,0}}},
     p185sf_load("x",0),P113DResult{[p185x_v("x")]}]}

def p185sf_branch() -> P113DFunction:
  P113DFunction{"p185se",p185cp_params(["a","b"],0),1,False{},
    [p185sf_store(0,p185x_v("a")),p185x_bin("zero",N111U64{},"eq",p185x_v("a"),N111Const{0,0}),
     P113DIf{p185x_v("zero"),[p185sf_store(0,p185x_v("b"))],[]},
     p185sf_load("x",0),P113DResult{[p185x_v("x")]}]}

# The isolated host stub writes through its declared buffer argument. The pass
# promises to treat calls as memory barriers; this is not a runtime sqrt test.
def p185sf_call() -> P113DFunction:
  P113DFunction{"p185sf",p185cp_params(["a"],0),1,False{},
    [p185sf_store(0,p185x_v("a")),P113DScalar{p112fp_control_call(N111Const{36,0},N111Const{1,0},"scratch")},
     p185sf_load("x",0),P113DResult{[p185x_v("x")]}]}

def p185sf_loop() -> P113DFunction:
  P113DFunction{"p185sg",p185cp_params(["n","a"],0),1,False{},
    [p185x_bin("done",N111U64{},"eq",p185x_v("n"),N111Const{0,0}),
     P113DIf{p185x_v("done"),[P113DResult{[p185x_v("a")]}],
       [p185sf_store(0,p185x_v("a")),p185sf_load("x",0),
        p185x_bin("next",N111U64{},"sub",p185x_v("n"),N111Const{1,0}),
        p185x_bin("changed",N111U64{},"add",p185x_v("x"),N111Const{1,0}),
        P113DAgain{[p185x_v("next"),p185x_v("changed")]}]}]}

def p185sf_alias() -> N111Segment:
  N111Segment{"p185sh",0,1,0,0,
    [N111Alloca{"buffer",16,8},N111Load{"a",N111U64{},p185x_v("state"),0},
     N111Load{"b",N111U64{},p185x_v("state"),8},N111Store{N111U64{},p185x_v("buffer"),0,p185x_v("a")},
     N111Offset{"alias",p185x_v("buffer"),N111Const{0,0}},
     N111Store{N111U64{},p185x_v("alias"),0,p185x_v("b")},
     N111Load{"x",N111U64{},p185x_v("buffer"),0},N111Return{p185x_v("x")}]}

def p185sf_functions() -> List<&2,P113DFunction>:
  [p185sf_exact(),p185sf_mutation(),p185sf_overlap(),p185sf_disjoint(),p185sf_branch(),p185sf_call(),p185sf_loop()]

@unsafe
def p185sf_candidate(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DFunction{name,params,result,public,x185_scratch_body(Con{"state",x181_param_names(params)},[],body)}

@unsafe
def p185sf_candidates(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p185sf_candidate(head),p185sf_candidates(rest)}

@unsafe
def p185sf_validate() -> String:
  p111_first(p111v_segment(p185sf_alias(),N111Ids{missing(),missing()}),
    p111_first(p113e_functions(p185sf_functions(),N111Ids{missing(),missing()},missing()),
      p113e_functions(p185sf_candidates(p185sf_functions()),N111Ids{missing(),missing()},missing())))

@unsafe
def p185sf_emit_one(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,+params,+result,public,body}:
      +words: List<&2,String> = Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
        u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}
      x185_function_copied(p113e_symbol(name),words,[],x185_scratch_body(words,[],body),N111Ids{missing(),missing()})

@unsafe
def p185sf_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p185sf_emit_one(head),p185sf_emit_functions(rest))

@unsafe
def p185sf_emit_alias(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x185_function_copied(p111q_symbol(name),["state"],[],
        x185_scratch_body(["state"],[],x181_scalar_rows(body)),N111Ids{missing(),missing()})

@unsafe
def p185sf_emit() -> X181Output:
  x181_program_join(p185sf_emit_functions(p185sf_functions()),p185sf_emit_alias(p185sf_alias()))

law p185sf_loads:
  for body: List<&2,P113DStmt>
  U32

@unsafe
def p185sf_loads(body):
  match body:
    case Nil{}: 0
    case Con{P113DScalar{N111Load{name,typ,base,offset}},rest}: U32.inc(p185sf_loads(rest))
    case Con{P113DIf{condition,yes,no},rest}: U32.add(p185sf_loads(yes),U32.add(p185sf_loads(no),p185sf_loads(rest)))
    case Con{head,rest}: p185sf_loads(rest)

@unsafe
def p185sf_count_candidate(function: P113DFunction) -> U32:
  match function:
    case P113DFunction{name,params,result,public,body}: p185sf_loads(body)

@unsafe
def p185sf_count(function: P113DFunction) -> U32:
  p185sf_count_candidate(p185sf_candidate(function))

@unsafe
def p185sf_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p185sf_fill(+index: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(index,17),u => [],
    u => Con{p185sf_store(U32.mul(index,8),N111Const{index,0}),p185sf_fill(U32.inc(index))})

@unsafe
def p185sf_alias_count(segment: N111Segment) -> U32:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      p185sf_loads(x185_scratch_body(["state"],[],x181_scalar_rows(body)))

@unsafe
def p185sf_controls() -> List<&2,String>:
  [p185sf_row("verified",String.is_empty(p185sf_validate())),
   p185sf_row("exact-cells",U32.is_eq(p185sf_count(p185sf_exact()),0)),
   p185sf_row("source-mutation",U32.is_eq(p185sf_count(p185sf_mutation()),1)),
   p185sf_row("overlapping-widths",U32.is_eq(p185sf_count(p185sf_overlap()),1)),
   p185sf_row("disjoint-widths",U32.is_eq(p185sf_count(p185sf_disjoint()),0)),
   p185sf_row("branch-barrier",U32.is_eq(p185sf_count(p185sf_branch()),1)),
   p185sf_row("call-barrier",U32.is_eq(p185sf_count(p185sf_call()),1)),
   p185sf_row("again-local-only",U32.is_eq(p185sf_count(p185sf_loop()),0)),
   p185sf_row("identity-reassignment",String.eq(dk(p111v_get(x185_sf_buffers([
     P113DScalar{N111Alloca{"buffer",16,8}},P113DScalar{N111Set{"buffer",N111Ptr{},N111Local{"scratch"}}}],missing()),"buffer")),"X185ScratchBlocked")),
   p185sf_row("reserved-identity",String.eq(dk(p111v_get(x185_sf_alloca("__x181_tail",16,missing()),"__x181_tail")),"X185ScratchBlocked")),
   p185sf_row("setup-not-carried",U32.is_eq(p185sf_loads(x185_scratch_body(["state","a"],[p185sf_store(0,p185x_v("a"))],[p185sf_load("x",0)])),1)),
   p185sf_row("exact-type-only",U32.is_eq(p185sf_loads(x185_scratch_body(["state","a"],[],
     [p185sf_store(0,p185x_v("a")),P113DScalar{N111Load{"low",N111U32{},p185x_v("scratch"),0}}])),1)),
   p185sf_row("bounds-refused",Bool.not(x185_sf_cell("scratch",4294967292,N111U64{},
     p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0))) &&
     U32.is_eq(p185sf_loads(x185_scratch_body(["state","a"],[],
       [p185sf_store(0,p185x_v("a")),p185sf_store(4092,N111Const{0,0}),p185sf_load("x",0)])),1)),
   p185sf_row("alias-store-barrier",U32.is_eq(p185sf_alias_count(p185sf_alias()),3)),
   p185sf_row("load-overwrites-source",U32.is_eq(p185sf_loads(x185_scratch_body(["state","a","b"],[],
     [p185sf_store(0,p185x_v("a")),p185sf_store(8,p185x_v("b")),p185sf_load("a",8),p185sf_load("x",0)])),1)),
   p185sf_row("sixteen-cell-cap",U32.is_eq(p185sf_loads(x185_scratch_body(["state"],[],
     nt_append(P113DStmt,p185sf_fill(0),[p185sf_load("first",0),p185sf_load("last",128)]))),1))]
