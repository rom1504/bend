def p186_v(name: String) -> N111Value: N111Local{name}
def p186_set(name: String, value: N111Value) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},value}}
def p186_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

@unsafe
def p186_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p186_params(rest,U32.inc(index))}

def p186_store(buffer: String, offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p186_v(buffer),offset,value}}
def p186_load(name: String, buffer: String, offset: U32) -> P113DStmt:
  P113DScalar{N111Load{name,N111U64{},p186_v(buffer),offset}}

def p186pm_dead() -> P113DFunction:
  P113DFunction{"p186ma",p186_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"dead",16,8}},p186_store("dead",0,p186_v("a")),p186_store("dead",8,p186_v("b")),
     P113DScalar{N111Alloca{"live",16,8}},p186_store("live",0,p186_v("a")),p186_load("x","live",0),P113DResult{[p186_v("x")]}]}

def p186pm_field() -> P113DFunction:
  P113DFunction{"p186mb",p186_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"buffer",16,8}},p186_store("buffer",0,p186_v("a")),p186_store("buffer",8,p186_v("b")),
     P113DScalar{N111Load{"high",N111U32{},p186_v("buffer"),4}},p186_store("scratch",0,N111Const{0,0}),
     P113DScalar{N111Store{N111U32{},p186_v("scratch"),0,p186_v("high")}},p186_load("x","scratch",0),P113DResult{[p186_v("x")]}]}

def p186pm_call() -> P113DFunction:
  P113DFunction{"p186mc",p186_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"buffer",16,8}},p186_store("buffer",0,p186_v("a")),
     P113DScalar{p112fp_control_call(N111Const{36,0},N111Const{1,0},"buffer")},
     p186_load("x","buffer",0),P113DResult{[p186_v("x")]}]}

def p186pm_branch() -> P113DFunction:
  P113DFunction{"p186md",p186_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"buffer",16,8}},p186_store("buffer",0,p186_v("a")),
     p186_bin("zero","eq",p186_v("a"),N111Const{0,0}),
     P113DIf{p186_v("zero"),[p186_load("x","buffer",0),P113DResult{[p186_v("x")]}],[P113DResult{[p186_v("b")]}]}]}

def p186pm_float() -> P113DFunction:
  P113DFunction{"p186me",p186_params(["a","b"],0),1,False{},
    [P113DScalar{N111Alloca{"buffer",24,8}},p186_store("buffer",0,p186_v("a")),p186_store("buffer",8,p186_v("b")),
     p186_store("buffer",16,N111Const{99,0}),P113DScalar{p112fp_control_call(N111Const{26,0},N111Const{2,0},"buffer")},
     P113DResult{[p186_v("result")]}]}

def p186pm_alias() -> N111Segment:
  N111Segment{"p186mf",0,1,0,0,
    [N111Alloca{"buffer",16,8},N111Load{"a",N111U64{},p186_v("state"),0},N111Load{"b",N111U64{},p186_v("state"),8},
     N111Store{N111U64{},p186_v("buffer"),0,p186_v("a")},N111Offset{"alias",p186_v("buffer"),N111Const{0,0}},
     N111Store{N111U64{},p186_v("alias"),0,p186_v("b")},N111Load{"x",N111U64{},p186_v("buffer"),0},N111Return{p186_v("x")}]}

def p186pm_functions() -> List<&2,P113DFunction>:
  [p186pm_dead(),p186pm_field(),p186pm_call(),p186pm_branch(),p186pm_float()]

@unsafe
def p186pm_candidate(function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{name,+params,result,public,body}:
      P113DFunction{name,params,result,public,x186_private_body(Con{"state",x181_param_names(params)},[],body)}

@unsafe
def p186pm_candidates(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{head,rest}: Con{p186pm_candidate(head),p186pm_candidates(rest)}

@unsafe
def p186pm_validate() -> String:
  p111_first(p111v_segment(p186pm_alias(),N111Ids{missing(),missing()}),
    p111_first(p113e_functions(p186pm_functions(),N111Ids{missing(),missing()},missing()),
      p113e_functions(p186pm_candidates(p186pm_functions()),N111Ids{missing(),missing()},missing())))

@unsafe
def p186pm_emit_one(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +words: List<&2,String> = Con{"state",x181_param_names(params)}
      x185_function_copied(p113e_symbol(name),words,[],x186_private_body(words,[],body),N111Ids{missing(),missing()})

@unsafe
def p186pm_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p186pm_emit_one(head),p186pm_emit_functions(rest))

@unsafe
def p186pm_emit_alias(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x185_function_copied(p111q_symbol(name),["state"],[],x186_private_body(["state"],[],x181_scalar_rows(body)),N111Ids{missing(),missing()})

@unsafe
def p186pm_emit() -> X181Output:
  x181_program_join(p186pm_emit_functions(p186pm_functions()),p186pm_emit_alias(p186pm_alias()))

law p186pm_count:
  for body: List<&2,P113DStmt>
  for +buffer: String
  U32

@unsafe
def p186pm_count(body,buffer):
  match body:
    case Nil{}: 0
    case Con{P113DScalar{N111Store{typ,N111Local{name},offset,value}},rest}:
      U32.add(Bool.to_u32(String.eq(name,buffer)),p186pm_count(rest,buffer))
    case Con{P113DIf{condition,yes,no},rest}: U32.add(p186pm_count(yes,buffer),U32.add(p186pm_count(no,buffer),p186pm_count(rest,buffer)))
    case Con{head,rest}: p186pm_count(rest,buffer)

@unsafe
def p186pm_stores(function: P113DFunction, buffer: String) -> U32:
  match function:
    case P113DFunction{name,params,result,public,body}: p186pm_count(body,buffer)

@unsafe
def p186pm_defined(function: P113DFunction, name: String) -> Bool:
  match function:
    case P113DFunction{symbol,params,result,public,body}:
      U32.is_gt(da(p111v_get(x185_copy_writes(body,missing()),name)),0)

@unsafe
def p186pm_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p186pm_controls() -> List<&2,String>:
  [p186pm_row("verified",String.is_empty(p186pm_validate())),
   p186pm_row("dead-buffer-stores",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_dead()),"dead"),0)),
   p186pm_row("dead-buffer-allocation",Bool.not(p186pm_defined(p186pm_candidate(p186pm_dead()),"dead"))),
   p186pm_row("live-buffer-store",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_dead()),"live"),1)),
   p186pm_row("overlapping-read",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_field()),"buffer"),1)),
   p186pm_row("unknown-call-escape",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_call()),"buffer"),1)),
   p186pm_row("branch-read-union",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_branch()),"buffer"),1)),
   p186pm_row("inline-f32-reads",U32.is_eq(p186pm_stores(p186pm_candidate(p186pm_float()),"buffer"),2)),
   p186pm_row("allocation-preserves-other-facts",U32.is_eq(nt_count(X185ScratchCell,x186_sf_allocated(
     [X185ScratchCell{"first",0,N111U64{},N111Const{1,0}}],"second")),1)),
   p186pm_row("allocation-kills-own-facts",U32.is_eq(nt_count(X185ScratchCell,x186_sf_allocated(
     [X185ScratchCell{"first",0,N111U64{},N111Const{1,0}}],"first")),0)),
   p186pm_row("setup-escape",U32.is_eq(p186pm_count(x186_private_body(["state"],
     [P113DScalar{N111Alloca{"buffer",16,8}},P113DScalar{p112fp_control_call(N111Const{36,0},N111Const{1,0},"buffer")}],
     [p186_store("buffer",0,N111Const{7,0})]),"buffer"),1)),
   p186pm_row("branch-escape",U32.is_eq(p186pm_count(x186_private_body(["state"],[],
     [P113DScalar{N111Alloca{"buffer",16,8}},P113DIf{N111Const{0,0},
       [P113DScalar{p112fp_control_call(N111Const{36,0},N111Const{1,0},"buffer")}],[]},
      p186_store("buffer",0,N111Const{7,0})]),"buffer"),1)),
   p186pm_row("stored-address-escape",U32.is_eq(p186pm_count(x186_private_body(["state"],[],
     [P113DScalar{N111Alloca{"buffer",16,8}},P113DScalar{N111Alloca{"holder",8,8}},
      P113DScalar{N111Store{N111Ptr{},p186_v("holder"),0,p186_v("buffer")}},p186_store("buffer",0,N111Const{7,0})]),"buffer"),1))]
