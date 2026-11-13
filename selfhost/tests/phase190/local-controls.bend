# Raw local-value controls bypass earlier copy/fact passes. The existing DCE
# follows the new pass, matching the proposed integration order.
def p190lc_v(name: String) -> N111Value: N111Local{name}
def p190lc_c(n: U32) -> N111Value: N111Const{n,0}
def p190lc_set(name: String, typ: N111Type, value: N111Value) -> P113DStmt: P113DScalar{N111Set{name,typ,value}}
def p190lc_bin(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}
def p190lc_ret(value: N111Value) -> P113DStmt: P113DResult{[value]}

def p190lc_inputs(body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Load{"a",N111U64{},p190lc_v("state"),0}},
    Con{P113DScalar{N111Load{"b",N111U64{},p190lc_v("state"),8}},body}}

@unsafe
def p190lc_emit_body(+symbol: String, +body: List<&2,P113DStmt>) -> X181Output:
  +ready = x185_dead_body([],x190_local_values_body([],body))
  x185_function_frame(symbol,[],ready,N111Ids{missing(),missing()},x181_frame(symbol,["state"],ready))

@unsafe
def p190lc_ops(ops: List<&2,String>) -> X181Output:
  match ops:
    case Nil{}: X181Output{[],""}
    case Con{+op,rest}:
      x181_program_join(p190lc_emit_body("p190lc_" ++ op,p190lc_inputs([
        p190lc_bin("value",N111U64{},op,p190lc_v("a"),p190lc_v("b")),
        p190lc_bin("value",N111U64{},"and",p190lc_v("value"),p190lc_c(4294967295)),p190lc_ret(p190lc_v("value"))])),p190lc_ops(rest))

def p190lc_mutable() -> List<&2,P113DStmt>:
  p190lc_inputs([p190lc_set("saved",N111U64{},p190lc_v("a")),p190lc_set("chain",N111U64{},p190lc_v("saved")),
    p190lc_bin("a",N111U64{},"add",p190lc_v("a"),p190lc_c(1)),
    p190lc_bin("out",N111U64{},"xor",p190lc_v("chain"),p190lc_v("a")),p190lc_ret(p190lc_v("out"))])

def p190lc_branch() -> List<&2,P113DStmt>:
  p190lc_inputs([p190lc_set("saved",N111U64{},p190lc_v("a")),
    p190lc_bin("pick",N111U64{},"ne",p190lc_v("b"),p190lc_c(0)),
    P113DIf{p190lc_v("pick"),[p190lc_set("a",N111U64{},p190lc_c(10))],[p190lc_set("a",N111U64{},p190lc_c(20))]},
    p190lc_bin("out",N111U64{},"add",p190lc_v("saved"),p190lc_v("a")),p190lc_ret(p190lc_v("out"))])

def p190lc_call() -> List<&2,P113DStmt>:
  p190lc_inputs([p190lc_set("saved",N111U64{},p190lc_v("a")),
    P113DScalar{N111Call{"a",N111U64{},"p190lc_external",[N111Arg{N111U64{},p190lc_v("a")}]}} ,
    p190lc_bin("out",N111U64{},"xor",p190lc_v("saved"),p190lc_v("a")),p190lc_ret(p190lc_v("out"))])

def p190lc_memory() -> List<&2,P113DStmt>:
  p190lc_inputs([p190lc_set("saved",N111U64{},p190lc_v("a")),
    P113DScalar{N111Store{N111U64{},p190lc_v("state"),0,p190lc_v("b")}},
    P113DScalar{N111Load{"a",N111U64{},p190lc_v("state"),0}},
    p190lc_bin("out",N111U64{},"xor",p190lc_v("saved"),p190lc_v("a")),p190lc_ret(p190lc_v("out"))])

def p190lc_width() -> List<&2,P113DStmt>:
  [P113DScalar{N111Load{"a",N111U32{},p190lc_v("state"),0}},
   p190lc_set("copy",N111U32{},p190lc_v("a")),
   p190lc_bin("copy",N111U64{},"and",p190lc_v("copy"),p190lc_c(4294967295)),
   p190lc_bin("out",N111U64{},"shl",p190lc_v("copy"),p190lc_c(32)),p190lc_ret(p190lc_v("out"))]

@unsafe
def p190lc_emit() -> X181Output:
  x181_program_join(p190lc_ops(["add","sub","mul","and","or","xor","shr","shl","sar"]),
  x181_program_join(p190lc_emit_body("p190lc_mutable",p190lc_mutable()),
  x181_program_join(p190lc_emit_body("p190lc_branch",p190lc_branch()),
  x181_program_join(p190lc_emit_body("p190lc_call",p190lc_call()),
  x181_program_join(p190lc_emit_body("p190lc_memory",p190lc_memory()),
    p190lc_emit_body("p190lc_width",p190lc_width()))))))

@unsafe
def p190lc_narrow_shape(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DScalar{N111Bin{name,N111U32{},op,left,right}},Nil{}}: True{}
    case _: False{}

@unsafe
def p190lc_shapes(ops: List<&2,String>) -> List<&2,String>:
  match ops:
    case Nil{}: []
    case Con{+op,rest}:
      +narrow = p190lc_narrow_shape(x190_v_body([
        p190lc_bin("value",N111U64{},op,p190lc_v("a"),p190lc_v("b")),
        p190lc_bin("value",N111U64{},"and",p190lc_v("value"),p190lc_c(4294967295))],x190_v_empty()))
      Con{"narrow-" ++ op ++ nt_choose(String,Bool.not(Bool.xor(narrow,x190_v_narrow_op(op))),u => "=1",u => "=0"),p190lc_shapes(rest)}

def p190lc_controls() -> List<&2,String>: p190lc_shapes(["add","sub","mul","and","or","xor","shr","shl","sar"])
