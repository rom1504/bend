# Standalone native-IR controls for the active fixed-home register policy.
# Machine fixtures use the ordinary placement pipeline; no homes are forced.
# The separate legality probe intentionally includes backend-reserved names.
def p190r_v(name: String) -> N111Value: N111Local{name}
def p190r_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}
def p190r_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}
def p190r_store(buffer: String, offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p190r_v(buffer),offset,value}}
def p190r_load(name: String, buffer: String, offset: U32) -> P113DStmt:
  P113DScalar{N111Load{name,N111U64{},p190r_v(buffer),offset}}

@unsafe
def p190r_params(names: List<&2,String>, +index: U32) -> List<&2,NC_Binding>:
  match names:
    case Nil{}: []
    case Con{name,rest}: Con{NC_Binding{index,name,N_W64{}},p190r_params(rest,U32.inc(index))}

@unsafe
def p190r_fn(name: String, params: List<&2,String>, result: U32,
    body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,p190r_params(params,0),result,False{},body}

# Four-cycle sources must be captured before any parameter home is changed.
# State, output pointer and five user arguments cross the six-register ABI.
@unsafe
def p190r_rotate() -> P113DFunction:
  p190r_fn("p190ra",["n","a","b","c","d"],4,
    [p190r_bin("done","eq",p190r_v("n"),N111Const{0,0}),
     P113DIf{p190r_v("done"),[P113DResult{[p190r_v("a"),p190r_v("b"),p190r_v("c"),p190r_v("d")]}],
       [p190r_bin("next","sub",p190r_v("n"),N111Const{1,0}),
        P113DAgain{[p190r_v("next"),p190r_v("b"),p190r_v("c"),p190r_v("d"),p190r_v("a")]}]}])

@unsafe
def p190r_helper() -> P113DFunction:
  p190r_fn("p190rb",["a","b","c","d"],4,
    [p190r_bin("u","add",p190r_v("a"),p190r_v("b")),
     p190r_bin("v","xor",p190r_v("b"),p190r_v("c")),
     p190r_bin("w","add",p190r_v("c"),p190r_v("d")),
     p190r_bin("x","sub",p190r_v("d"),p190r_v("a")),
     P113DResult{[p190r_v("u"),p190r_v("v"),p190r_v("w"),p190r_v("x")]}])

# The helper's four-result ABI and two nested branch paths retain live input
# homes across calls, then exercise several different parallel backedges.
@unsafe
def p190r_calls() -> P113DFunction:
  p190r_fn("p190rc",["n","a","b","c","d"],4,
    [p190r_bin("done","eq",p190r_v("n"),N111Const{0,0}),
     P113DIf{p190r_v("done"),[P113DResult{[p190r_v("a"),p190r_v("b"),p190r_v("c"),p190r_v("d")]}],
       [p190r_bin("next","sub",p190r_v("n"),N111Const{1,0}),
        P113DCall{["u","v","w","x"],"p190rb",[p190r_v("a"),p190r_v("b"),p190r_v("c"),p190r_v("d")]},
        p190r_bin("nbit","and",p190r_v("n"),N111Const{1,0}),
        p190r_bin("odd","ne",p190r_v("nbit"),N111Const{0,0}),
        P113DIf{p190r_v("odd"),
          [p190r_bin("abit","and",p190r_v("a"),N111Const{1,0}),
           p190r_bin("aodd","ne",p190r_v("abit"),N111Const{0,0}),
           P113DIf{p190r_v("aodd"),
             [P113DAgain{[p190r_v("next"),p190r_v("u"),p190r_v("v"),p190r_v("w"),p190r_v("x")]}],
             [P113DAgain{[p190r_v("next"),p190r_v("v"),p190r_v("w"),p190r_v("x"),p190r_v("u")]}]}],
          [P113DAgain{[p190r_v("next"),p190r_v("x"),p190r_v("w"),p190r_v("v"),p190r_v("u")]}]}]}])

def p190r_setup() -> List<&2,P113DStmt>:
  [p190r_set("saved_a",p190r_v("a")),p190r_set("saved_b",p190r_v("b"))]
def p190r_setup_body() -> List<&2,P113DStmt>:
  [p190r_bin("done","eq",p190r_v("n"),N111Const{0,0}),
   P113DIf{p190r_v("done"),
     [P113DResult{[p190r_v("a"),p190r_v("b"),p190r_v("saved_a"),p190r_v("saved_b")]}],
     [p190r_bin("next","sub",p190r_v("n"),N111Const{1,0}),
      p190r_bin("new_a","add",p190r_v("a"),N111Const{1,0}),
      p190r_bin("new_b","xor",p190r_v("b"),p190r_v("a")),
      P113DAgain{[p190r_v("next"),p190r_v("new_a"),p190r_v("new_b")]}]}]

@unsafe
def p190r_setup_function() -> P113DFunction:
  p190r_fn("p190rd",["n","a","b"],4,nt_append(P113DStmt,p190r_setup(),p190r_setup_body()))

# Frequent address reads must never turn an alloca into a scalar register home.
@unsafe
def p190r_buffers() -> P113DFunction:
  p190r_fn("p190re",["a","b"],4,
    [P113DScalar{N111Alloca{"buffer",24,8}},
     p190r_store("buffer",0,p190r_v("a")),p190r_store("buffer",8,p190r_v("b")),
     p190r_store("scratch",0,p190r_v("a")),p190r_store("scratch",8,p190r_v("b")),
     p190r_load("u","buffer",0),p190r_load("v","buffer",8),
     p190r_load("w","scratch",0),p190r_load("x","scratch",8),
     p190r_bin("sum","add",p190r_v("u"),p190r_v("v")),
     p190r_bin("bits","xor",p190r_v("w"),p190r_v("x")),
     p190r_store("buffer",16,p190r_v("sum")),p190r_load("again","buffer",16),
     P113DResult{[p190r_v("u"),p190r_v("v"),p190r_v("again"),p190r_v("bits")]}])

def p190r_functions() -> List<&2,P113DFunction>:
  [p190r_rotate(),p190r_helper(),p190r_calls(),p190r_setup_function(),p190r_buffers()]

@unsafe
def p190r_validate() -> String:
  p113e_functions(p190r_functions(),N111Ids{missing(),missing()},missing())

@unsafe
def p190r_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{P113DFunction{+name,params,result,public,body},rest}:
      x181_program_join(nt_choose(X181Output,String.eq(name,"p190rd"),
        u => x185_function_setup(p113e_symbol(name),["state","__x181_result_out","n","a","b"],
          p190r_setup(),p190r_setup_body(),N111Ids{missing(),missing()}),
        u => x181_direct(P113DFunction{name,params,result,public,body},N111Ids{missing(),missing()})),
        p190r_emit_functions(rest))

@unsafe
def p190r_emit() -> X181Output: p190r_emit_functions(p190r_functions())

@unsafe
def p190r_row(name: String, +good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p190r_legality_body() -> List<&2,P113DStmt>:
  [P113DScalar{N111Alloca{"buffer",24,8}},
   p190r_store("buffer",0,N111Const{11,0}),p190r_load("u","buffer",0),
   p190r_store("buffer",8,p190r_v("u")),p190r_load("v","buffer",8),
   p190r_store("scratch",0,p190r_v("u")),p190r_load("w","scratch",0),
   p190r_store("scratch",8,p190r_v("v")),p190r_load("x","scratch",8),
   p190r_load("s0","state",0),p190r_load("s1","state",8),p190r_load("s2","state",16),
   p190r_set("u0",p190r_v("__x181_probe")),p190r_set("u1",p190r_v("__x181_probe")),
   p190r_set("u2",p190r_v("__x181_probe")),p190r_set("u3",p190r_v("__x181_probe")),
   P113DAgain{[p190r_v("__x181_probe")]}]

@unsafe
def p190r_legality(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      String.eq(dk(p111v_get(slots,"state")),"X181Register") && U32.is_eq(da(p111v_get(slots,"state")),0) &&
      String.eq(dk(p111v_get(slots,"scratch")),"X181Buffer") &&
      String.eq(dk(p111v_get(slots,"buffer")),"X181Buffer") &&
      String.eq(dk(p111v_get(slots,"__x181_probe")),"X181Stack") &&
      String.eq(dk(p111v_get(slots,"__x181_tail")),"X181Buffer") &&
      String.eq(dk(p111v_get(slots,"__x181_results")),"X181Buffer")

@unsafe
def p190r_legal_policy(policy: U32) -> Bool:
  +body = p190r_legality_body()
  p190r_legality(x190_register_frame(x181_frame("probe",["state","__x181_probe"],body),body,policy))

@unsafe
def p190r_lowuse(+policy: U32) -> Bool:
  +body: List<&2,P113DStmt> = [p190r_bin("done","eq",p190r_v("n"),N111Const{0,0}),
    P113DIf{p190r_v("done"),[P113DResult{[p190r_v("a")]}],
      [p190r_bin("next","sub",p190r_v("n"),N111Const{1,0}),P113DAgain{[p190r_v("next"),p190r_v("a")]}]}]
  p190r_a_register(x190_register_frame(x181_frame("probe",["state","n","a"],body),body,policy))

@unsafe
def p190r_a_register(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      String.eq(dk(p111v_get(slots,"a")),"X181Register")

@unsafe
def p190r_competing_frame(policy: U32) -> X181Frame:
  +body: List<&2,P113DStmt> =
    [p190r_set("t0",N111Const{0,0}),p190r_set("t1",N111Const{1,0}),
     p190r_set("t2",N111Const{2,0}),p190r_set("t3",N111Const{3,0}),
     p190r_store("scratch",0,p190r_v("t0")),p190r_store("scratch",8,p190r_v("t0")),
     p190r_store("scratch",16,p190r_v("t1")),p190r_store("scratch",24,p190r_v("t1")),
     p190r_store("scratch",32,p190r_v("t2")),p190r_store("scratch",40,p190r_v("t2")),
     p190r_store("scratch",48,p190r_v("t3")),p190r_store("scratch",56,p190r_v("t3")),
     P113DAgain{[p190r_v("a"),p190r_v("b"),p190r_v("c"),p190r_v("d")]}]
  x190_register_frame(x181_frame("probe",["state","a","b","c","d"],body),body,policy)

@unsafe
def p190r_homes_kind(names: List<&2,String>, +kind: String, +slots: KDef) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: String.eq(dk(p111v_get(slots,name)),kind) && p190r_homes_kind(rest,kind,slots)

@unsafe
def p190r_competing(frame: X181Frame, +state: Bool) -> Bool:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      p190r_homes_kind(["a","b","c","d"],nt_choose(String,state,u => "X181Register",u => "X181Stack"),slots) &&
      p190r_homes_kind(["t0","t1","t2","t3"],nt_choose(String,state,u => "X181Stack",u => "X181Register"),slots)

@unsafe
def p190r_nonloop(policy: U32) -> Bool:
  +body: List<&2,P113DStmt> = [P113DResult{[p190r_v("a")]}]
  Bool.not(p190r_a_register(x190_register_frame(x181_frame("probe",["state","a"],body),body,policy)))

@unsafe
def p190r_controls() -> List<&2,String>:
  [p190r_row("verified",String.is_empty(p190r_validate())),
   p190r_row("baseline-reserved-buffer-homes",p190r_legal_policy(0)),
   p190r_row("weighted-reserved-buffer-homes",p190r_legal_policy(1)),
   p190r_row("state-reserved-buffer-homes",p190r_legal_policy(2)),
   p190r_row("baseline-lowuse-stack",Bool.not(p190r_lowuse(0))),
   p190r_row("weighted-lowuse-register",p190r_lowuse(1)),
   p190r_row("state-lowuse-register",p190r_lowuse(2)),
   p190r_row("unknown-policy-baseline",Bool.not(p190r_lowuse(3))),
   p190r_row("weighted-competing-temps",p190r_competing(p190r_competing_frame(1),False{})),
   p190r_row("state-competing-params",p190r_competing(p190r_competing_frame(2),True{})),
   p190r_row("weighted-nonloop-baseline",p190r_nonloop(1)),
   p190r_row("state-nonloop-baseline",p190r_nonloop(2)),
   p190r_row("weighted-score",U32.is_eq(x190_register_score(2,False{},1),16)),
   p190r_row("state-score",U32.is_eq(x190_register_score(2,True{},2),64)),
   p190r_row("transient-score",U32.is_eq(x190_register_score(2,False{},2),16)),
   p190r_row("score-saturation",U32.is_eq(x190_register_score(4294967295,True{},2),4294967295))]
