# Placement controls deliberately bypass copy/facts and the old four-register
# chooser. Machine fixture IR passes the unchanged verifier before emission;
# explicitly marked metadata-only controls do not enter that emitted inventory.
def p185tr_v(name: String) -> N111Value: N111Local{name}

def p185tr_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

def p185tr_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}

@unsafe
def p185tr_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p185tr_params(rest,U32.inc(index))}

@unsafe
def p185tr_fn(name: String, params: List<&2,String>, result: U32, body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,p185tr_params(params,0),result,False{},body}

@unsafe
def p185tr_chain() -> P113DFunction:
  p185tr_fn("p185tr0",["a","b"],1,
    [p185tr_bin("x","add",p185tr_v("a"),p185tr_v("b")),
     p185tr_bin("y","xor",p185tr_v("x"),p185tr_v("b")),
     p185tr_bin("z","add",p185tr_v("y"),N111Const{7,0}),P113DResult{[p185tr_v("z")]}])

@unsafe
def p185tr_pressure() -> P113DFunction:
  p185tr_fn("p185tr1",["a"],6,
    [p185tr_bin("x0","add",p185tr_v("a"),N111Const{1,0}),
     p185tr_bin("x1","add",p185tr_v("a"),N111Const{2,0}),
     p185tr_bin("x2","add",p185tr_v("a"),N111Const{3,0}),
     p185tr_bin("x3","add",p185tr_v("a"),N111Const{4,0}),
     p185tr_bin("x4","add",p185tr_v("a"),N111Const{5,0}),
     p185tr_bin("x5","add",p185tr_v("a"),N111Const{6,0}),
     P113DResult{[p185tr_v("x0"),p185tr_v("x1"),p185tr_v("x2"),p185tr_v("x3"),p185tr_v("x4"),p185tr_v("x5")]}])

@unsafe
def p185tr_deadwrite() -> P113DFunction:
  p185tr_fn("p185tr2",["a","b"],2,
    [p185tr_bin("x","add",p185tr_v("a"),N111Const{1,0}),
     p185tr_bin("saved","add",p185tr_v("x"),N111Const{1,0}),
     p185tr_bin("y","add",p185tr_v("b"),N111Const{9,0}),
     p185tr_set("x",N111Const{99,0}),P113DResult{[p185tr_v("y"),p185tr_v("saved")]}])

@unsafe
def p185tr_branch() -> P113DFunction:
  p185tr_fn("p185tr3",["a"],1,
    [p185tr_bin("x","add",p185tr_v("a"),N111Const{1,0}),
     p185tr_bin("zero","eq",p185tr_v("a"),N111Const{0,0}),
     P113DIf{p185tr_v("zero"),[p185tr_bin("y","add",p185tr_v("x"),N111Const{2,0})],
       [p185tr_bin("y","add",p185tr_v("x"),N111Const{3,0})]},P113DResult{[p185tr_v("y")]}])

@unsafe
def p185tr_target() -> P113DFunction:
  p185tr_fn("p185tr5",["a","b","c","d","e","f"],1,
    [p185tr_bin("b2","mul",p185tr_v("b"),N111Const{2,0}),
     p185tr_bin("c3","mul",p185tr_v("c"),N111Const{3,0}),
     p185tr_bin("d4","mul",p185tr_v("d"),N111Const{4,0}),
     p185tr_bin("e5","mul",p185tr_v("e"),N111Const{5,0}),
     p185tr_bin("f6","mul",p185tr_v("f"),N111Const{6,0}),
     p185tr_bin("ab","add",p185tr_v("a"),p185tr_v("b2")),
     p185tr_bin("cd","add",p185tr_v("c3"),p185tr_v("d4")),
     p185tr_bin("ef","add",p185tr_v("e5"),p185tr_v("f6")),
     p185tr_bin("abcd","add",p185tr_v("ab"),p185tr_v("cd")),
     p185tr_bin("all","add",p185tr_v("abcd"),p185tr_v("ef")),P113DResult{[p185tr_v("all")]}])

@unsafe
def p185tr_call() -> P113DFunction:
  p185tr_fn("p185tr4",["a","b"],1,
    [p185tr_bin("left","add",p185tr_v("a"),N111Const{1,0}),
     p185tr_bin("right","add",p185tr_v("b"),N111Const{2,0}),
     p185tr_bin("across","xor",p185tr_v("a"),p185tr_v("b")),
     P113DCall{["reply"],"p185tr5",[p185tr_v("right"),p185tr_v("left"),p185tr_v("right"),
       p185tr_v("left"),p185tr_v("right"),p185tr_v("left")]},
     p185tr_bin("answer","add",p185tr_v("reply"),p185tr_v("across")),P113DResult{[p185tr_v("answer")]}])

@unsafe
def p185tr_again() -> P113DFunction:
  p185tr_fn("p185tr6",["n","a","b"],2,
    [p185tr_bin("zero","eq",p185tr_v("n"),N111Const{0,0}),
     P113DIf{p185tr_v("zero"),[P113DResult{[p185tr_v("a"),p185tr_v("b")]}],
       [p185tr_bin("next","sub",p185tr_v("n"),N111Const{1,0}),
        p185tr_bin("ta","add",p185tr_v("b"),N111Const{1,0}),
        p185tr_bin("tb","add",p185tr_v("a"),N111Const{2,0}),
        P113DAgain{[p185tr_v("next"),p185tr_v("ta"),p185tr_v("tb")]}]}])

def p185tr_setup() -> List<&2,P113DStmt>:
  [p185tr_bin("snapshot","add",p185tr_v("a"),N111Const{5,0})]

def p185tr_setup_body() -> List<&2,P113DStmt>:
  [p185tr_bin("zero","eq",p185tr_v("n"),N111Const{0,0}),
   P113DIf{p185tr_v("zero"),[P113DResult{[p185tr_v("snapshot")]}],
     [p185tr_bin("next","sub",p185tr_v("n"),N111Const{1,0}),
      p185tr_bin("changed","add",p185tr_v("a"),N111Const{1,0}),
      P113DAgain{[p185tr_v("next"),p185tr_v("changed")]}]}]

@unsafe
def p185tr_setup_function() -> P113DFunction:
  p185tr_fn("p185tr7",["n","a"],1,nt_append(P113DStmt,p185tr_setup(),p185tr_setup_body()))

@unsafe
def p185tr_memory() -> P113DFunction:
  p185tr_fn("p185tr8",["a","b"],1,
    [P113DScalar{N111Store{N111U64{},p185tr_v("scratch"),0,p185tr_v("a")}},
     P113DScalar{N111Store{N111U64{},p185tr_v("scratch"),8,p185tr_v("b")}},
     P113DScalar{N111Load{"low",N111U32{},p185tr_v("scratch"),0}},
     P113DScalar{N111Load{"amount",N111U32{},p185tr_v("scratch"),8}},
     P113DScalar{N111Bin{"shifted",N111U32{},"shl",p185tr_v("low"),p185tr_v("amount")}},
     P113DScalar{N111Store{N111U64{},p185tr_v("scratch"),16,N111Const{0,0}}},
     P113DScalar{N111Store{N111U32{},p185tr_v("scratch"),16,p185tr_v("shifted")}},
     P113DScalar{N111Load{"answer",N111U64{},p185tr_v("scratch"),16}},P113DResult{[p185tr_v("answer")]}])

@unsafe
def p185tr_functions() -> List<&2,P113DFunction>:
  [p185tr_target(),p185tr_chain(),p185tr_pressure(),p185tr_deadwrite(),p185tr_branch(),
   p185tr_call(),p185tr_again(),p185tr_memory()]

@unsafe
def p185tr_names(+params: List<&2,NC_Binding>, result: U32) -> List<&2,String>:
  Con{"state",nt_choose(List<&2,String>,U32.is_eq(result,1),
    u => x181_param_names(params),u => Con{"__x181_result_out",x181_param_names(params)})}

@unsafe
def p185tr_frame(function: P113DFunction) -> X181Frame:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      +names = p185tr_names(params,result)
      x185_transient_frame(x181_frame(p113e_symbol(name),names,body),names,[],body)

@unsafe
def p185tr_home(frame: X181Frame, name: String) -> KDef:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: p111v_get(slots,name)

@unsafe
def p185tr_slot(function: P113DFunction, name: String) -> KDef:
  p185tr_home(p185tr_frame(function),name)

@unsafe
def p185tr_is(function: P113DFunction, name: String, kind: String) -> Bool:
  String.eq(dk(p185tr_slot(function,name)),kind)

# Metadata-only placement check: N111Offset is outside direct-function verifier
# admission, so this synthetic body is neither validated nor machine-emitted.
@unsafe
def p185tr_pointer_metadata() -> Bool:
  p185tr_is(p185tr_fn("pointer_metadata",[],1,
    [P113DScalar{N111Offset{"pointer",p185tr_v("scratch"),N111Const{0,0}}},
     P113DScalar{N111Load{"value",N111U64{},p185tr_v("pointer"),0}},
     P113DResult{[p185tr_v("value")]}]),"pointer","X185Transient")

@unsafe
def p185tr_emit(function: P113DFunction, +ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,params,result,public,+body}:
      +names = p185tr_names(params,result)
      x185_function_frame(p113e_symbol(name),[],body,ids,
        x185_transient_frame(x181_frame(p113e_symbol(name),names,body),names,[],body))

@unsafe
def p185tr_emit_setup() -> X181Output:
  +names : List<&2,String> = ["state","n","a"]
  +frame = x181_frame(p113e_symbol("p185tr7"),names,nt_append(P113DStmt,p185tr_setup(),p185tr_setup_body()))
  x185_function_frame(p113e_symbol("p185tr7"),p185tr_setup(),p185tr_setup_body(),N111Ids{missing(),missing()},
    x185_transient_frame(frame,names,p185tr_setup(),p185tr_setup_body()))

@unsafe
def p185tr_setup_slot() -> KDef:
  +names : List<&2,String> = ["state","n","a"]
  p185tr_home(x185_transient_frame(x181_frame("setup",names,nt_append(P113DStmt,p185tr_setup(),p185tr_setup_body())),
    names,p185tr_setup(),p185tr_setup_body()),"snapshot")

@unsafe
def p185tr_validate() -> String:
  p113e_functions(Con{p185tr_setup_function(),p185tr_functions()},N111Ids{missing(),missing()},missing())

@unsafe
def p185tr_runtime() -> P113DFunction:
  p185tr_fn("runtime",["a"],1,[p185tr_bin("x","add",p185tr_v("a"),N111Const{1,0}),
    P113DScalar{N111Call{"reply",N111U64{},"p111_rt_tag",[p111_state(),p111_word(p185tr_v("x"))]}},
    P113DResult{[p185tr_v("reply")]}])

@unsafe
def p185tr_callee_slot() -> KDef:
  +body : List<&2,P113DStmt> = [p185tr_bin("x","add",N111Const{1,0},N111Const{2,0}),P113DResult{[p185tr_v("x")]}]
  +frame = x181_register_install("x",1,x181_frame("callee",["state"],body))
  p185tr_home(x185_transient_frame(frame,["state"],[],body),"x")

@unsafe
def p185tr_tree(+depth: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(depth,0),u => [p185tr_set("leaf",N111Const{0,0})],
    u => [P113DIf{N111Const{0,0},p185tr_tree(U32.sub(depth,1)),p185tr_tree(U32.sub(depth,1))}])

@unsafe
def p185tr_capped() -> Bool:
  +small : List<&2,P113DStmt> = [p185tr_set("x",N111Const{1,0})]
  +frame = x181_frame("cap",["state"],small)
  String.eq(dk(p185tr_home(x185_transient_frame(frame,["state"],[],
    nt_append(P113DStmt,small,p185tr_tree(12))),"x")),"X181Stack")

@unsafe
def p185tr_controls() -> List<&2,String>:
  +chain = p185tr_chain()
  +pressure = p185tr_pressure()
  +dead = p185tr_deadwrite()
  +call = p185tr_call()
  [p113ft_row("transient-verified",String.is_empty(p185tr_validate())),
   p113ft_row("transient-chain-promoted",p185tr_is(chain,"x","X185Transient") && p185tr_is(chain,"y","X185Transient") && p185tr_is(chain,"z","X185Transient")),
   p113ft_row("transient-chain-reuses",U32.is_eq(da(p185tr_slot(chain,"x")),da(p185tr_slot(chain,"z")))),
   p113ft_row("transient-same-statement-overlap",U32.is_ne(da(p185tr_slot(chain,"x")),da(p185tr_slot(chain,"y")))),
   p113ft_row("transient-five-registers",p185tr_is(pressure,"x0","X185Transient") && p185tr_is(pressure,"x4","X185Transient") && U32.is_eq(da(p185tr_slot(pressure,"x4")),4)),
   p113ft_row("transient-pressure-fallback",p185tr_is(pressure,"x5","X181Stack")),
   p113ft_row("transient-parameter-fallback",p185tr_is(chain,"a","X181Stack")),
   p113ft_row("transient-dead-write-extends",U32.is_ne(da(p185tr_slot(dead,"x")),da(p185tr_slot(dead,"y")))),
   p113ft_row("transient-cross-branch-fallback",p185tr_is(p185tr_branch(),"x","X181Stack") && p185tr_is(p185tr_branch(),"y","X181Stack")),
   p113ft_row("transient-call-arguments-fallback",p185tr_is(call,"left","X181Stack") && p185tr_is(call,"right","X181Stack")),
   p113ft_row("transient-cross-call-fallback",p185tr_is(call,"across","X181Stack")),
   p113ft_row("transient-call-result-fallback",p185tr_is(call,"reply","X181Stack")),
   p113ft_row("transient-after-call-promoted",p185tr_is(call,"answer","X185Transient")),
   p113ft_row("transient-again-values-promoted",p185tr_is(p185tr_again(),"next","X185Transient") && p185tr_is(p185tr_again(),"ta","X185Transient") && p185tr_is(p185tr_again(),"tb","X185Transient")),
   p113ft_row("transient-setup-fallback",String.eq(dk(p185tr_setup_slot()),"X181Stack")),
   p113ft_row("transient-pointer-promoted",p185tr_pointer_metadata()),
   p113ft_row("transient-buffer-kept",p185tr_is(p185tr_memory(),"scratch","X181Buffer")),
   p113ft_row("transient-runtime-argument-fallback",p185tr_is(p185tr_runtime(),"x","X181Stack")),
   p113ft_row("transient-runtime-result-fallback",p185tr_is(p185tr_runtime(),"reply","X181Stack")),
   p113ft_row("transient-callee-home-kept",String.eq(dk(p185tr_callee_slot()),"X181Register") && U32.is_eq(da(p185tr_callee_slot()),1)),
   p113ft_row("transient-size-cap",p185tr_capped()),
   p113ft_row("transient-read-before-definition",p185tr_is(p185tr_fn("bad",[],1,
     [p185tr_bin("x","add",p185tr_v("x"),N111Const{1,0}),P113DResult{[p185tr_v("x")]}]),"x","X181Stack")),
   p113ft_row("transient-reserved-name",p185tr_is(p185tr_fn("reserved",[],1,
     [p185tr_set("__x181_t",N111Const{1,0}),P113DResult{[p185tr_v("__x181_t")]}]),"__x181_t","X181Stack"))]
