# Force the isolated XMM emitter; production selection may remain disabled.
# Existing635 independent observations are re-emitted without changing their IR.
@unsafe
def p186xm_op(name: String, id: U32, left: N111Value, right: N111Value) -> List<&2,P113DStmt>:
  [p186fv_store(0,left),p186fv_store(8,right),P113DScalar{p186ie_call(name,id,2,"scratch")}]

@unsafe
def p186xm_join(rows: List<&2,List<&2,P113DStmt>>) -> List<&2,P113DStmt>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_append(P113DStmt,head,p186xm_join(rest))

@unsafe
def p186xm_rhs() -> P113DFunction:
  p186ie_fn("p186xa",["a"],1,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    p186xm_op("x",27,N111Const{1073741824,0},p186ie_v("x")),
    p186xm_op("result",28,p186ie_v("x"),N111Const{1065353216,0}),[P113DResult{[p186ie_v("result")]}]]))

@unsafe
def p186xm_copy() -> P113DFunction:
  p186ie_fn("p186xb",["a"],1,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    [P113DScalar{N111Set{"copy",N111U64{},p186ie_v("x")}}],
    p186xm_op("result",28,p186ie_v("copy"),N111Const{1065353216,0}),[P113DResult{[p186ie_v("result")]}]]))

@unsafe
def p186xm_raw() -> P113DFunction:
  p186ie_fn("p186xc",["a","marker"],2,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    [P113DScalar{N111Set{"x",N111U64{},p186ie_v("marker")}},P113DScalar{N111Set{"saved",N111U64{},p186ie_v("x")}}],
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    p186xm_op("result",28,p186ie_v("x"),N111Const{1065353216,0}),
    [P113DResult{[p186ie_v("result"),p186ie_v("saved")]}]]))

@unsafe
def p186xm_definitions(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(n,16),u => [],u =>
    nt_append(P113DStmt,p186xm_op("v" ++ U32.show(n),28,p186ie_v("a"),N111Const{1065353216,0}),p186xm_definitions(U32.inc(n))))

@unsafe
def p186xm_sums(+n: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(n,16),u => [P113DResult{[p186ie_v("sum15")]}],u =>
    nt_append(P113DStmt,p186xm_op("sum" ++ U32.show(n),26,
      nt_choose(N111Value,U32.is_eq(n,1),v => p186ie_v("v0"),v => p186ie_v("sum" ++ U32.show(U32.sub(n,1)))),
      p186ie_v("v" ++ U32.show(n))),p186xm_sums(U32.inc(n))))

@unsafe
def p186xm_pressure() -> P113DFunction:
  p186ie_fn("p186xd",["a"],1,nt_append(P113DStmt,p186xm_definitions(0),p186xm_sums(1)))

@unsafe
def p186xm_call() -> P113DFunction:
  p186ie_fn("p186xe",["a","marker"],2,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    [p186fv_store(0,p186ie_v("marker")),P113DScalar{p186ie_call("ignored",36,1,"scratch")}],
    p186xm_op("result",28,p186ie_v("x"),N111Const{1065353216,0}),
    [P113DResult{[p186ie_v("result"),p186ie_v("ignored")]}]]))

@unsafe
def p186xm_arm() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p186xm_op("result",28,p186ie_v("x"),N111Const{1065353216,0}),[P113DResult{[p186ie_v("result")]}])

@unsafe
def p186xm_branch() -> P113DFunction:
  p186ie_fn("p186xf",["a","marker"],1,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    [p186ie_bin("zero","eq",p186ie_v("marker"),N111Const{0,0}),P113DIf{p186ie_v("zero"),p186xm_arm(),p186xm_arm()}]]))

@unsafe
def p186xm_divide() -> P113DFunction:
  p186ie_fn("p186xg",["a"],1,p186xm_join([
    p186xm_op("x",28,p186ie_v("a"),N111Const{1065353216,0}),
    p186xm_op("x",29,N111Const{1073741824,0},p186ie_v("x")),
    p186xm_op("result",28,p186ie_v("x"),N111Const{1065353216,0}),[P113DResult{[p186ie_v("result")]}]]))

@unsafe
def p186xm_compare(name: String, id: U32) -> P113DFunction:
  p186ie_fn(name,["a","b"],1,p186xm_join([
    p186xm_op("cmp",id,p186ie_v("a"),p186ie_v("b")),
    p186xm_op("result",28,p186ie_v("cmp"),N111Const{1073741824,0}),[P113DResult{[p186ie_v("result")]}]]))

def p186xm_functions() -> List<&2,P113DFunction>:
  [p186xm_rhs(),p186xm_copy(),p186xm_raw(),p186xm_pressure(),p186xm_call(),p186xm_branch(),p186xm_divide(),
   p186xm_compare("p186xh",30),p186xm_compare("p186xi",31),p186xm_compare("p186xj",32),
   p186xm_compare("p186xk",33),p186xm_compare("p186xl",34),p186xm_compare("p186xm",35)]

@unsafe
def p186xm_validate() -> String:
  p111_first(p186fv_validate(),p113e_functions(p186xm_functions(),N111Ids{missing(),missing()},missing()))

@unsafe
def p186xm_emit_function(function: P113DFunction) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x186_x_function(p113e_symbol(name),p186fv_names(params,result),[],body,N111Ids{missing(),missing()})

@unsafe
def p186xm_emit_functions(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p186xm_emit_function(head),p186xm_emit_functions(rest))

@unsafe
def p186xm_emit_segment(segment: N111Segment) -> X181Output:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      x186_x_function(p111q_symbol(name),["state"],[],x181_scalar_rows(body),N111Ids{missing(),missing()})

@unsafe
def p186xm_emit() -> X181Output:
  x181_program_join(p186xm_emit_functions(nt_append(P113DFunction,p186ie_functions(),
    nt_append(P113DFunction,p186fv_functions(),p186xm_functions()))),
    x181_program_join(p186xm_emit_segment(p186ie_pointer("p186im")),
      x181_program_join(p186xm_emit_segment(p186ie_pointer("p186in")),p186xm_emit_segment(p186fv_alias()))))

@unsafe
def p186xm_homes(+function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x186_x_homes(p186fv_names(params,result),[],p186fv_nodes(function))

@unsafe
def p186xm_has(function: P113DFunction, name: String) -> Bool:
  Bool.not(String.is_empty(x186_x_home(name,p186xm_homes(function))))

@unsafe
def p186xm_live(+n: U32, +homes: KDef) -> U32:
  nt_choose(U32,U32.is_eq(n,16),u => 0,u => U32.add(
    Bool.to_u32(Bool.not(String.is_empty(x186_x_home("v" ++ U32.show(n),homes)))),p186xm_live(U32.inc(n),homes)))

@unsafe
def p186xm_compare_homes(+id: U32) -> Bool:
  nt_choose(Bool,U32.is_gt(id,35),u => True{},u =>
    p186xm_has(p186xm_compare("probe",id),"cmp") && p186xm_compare_homes(U32.inc(id)))

@unsafe
def p186xm_controls() -> List<&2,String>:
  [p186ie_row("original-ir-verified",String.is_empty(p186xm_validate())),
   p186ie_row("rhs-destination-home",p186xm_has(p186xm_rhs(),"x")),
   p186ie_row("rhs-divide-destination-home",p186xm_has(p186xm_divide(),"x")),
   p186ie_row("assigned-comparison-homes",p186xm_compare_homes(30)),
   p186ie_row("canonical-source-home",p186xm_has(p186xm_copy(),"x")),
   p186ie_row("canonical-copy-home",p186xm_has(p186xm_copy(),"copy")),
   p186ie_row("result-boundary-refused",Bool.not(p186xm_has(p186xm_copy(),"result"))),
   p186ie_row("parameter-refused",Bool.not(p186xm_has(p186xm_copy(),"a"))),
   p186ie_row("raw-write-refused",Bool.not(p186xm_has(p186xm_raw(),"x"))),
   p186ie_row("raw-copy-refused",Bool.not(p186xm_has(p186xm_raw(),"saved"))),
   p186ie_row("fourteen-live-homes",U32.is_eq(p186xm_live(0,p186xm_homes(p186xm_pressure())),14)),
   p186ie_row("fifteenth-live-fallback",Bool.not(p186xm_has(p186xm_pressure(),"v14"))),
   p186ie_row("sixteenth-live-fallback",Bool.not(p186xm_has(p186xm_pressure(),"v15"))),
   p186ie_row("unknown-call-boundary",Bool.not(p186xm_has(p186xm_call(),"x"))),
   p186ie_row("branch-boundary",Bool.not(p186xm_has(p186xm_branch(),"x"))),
   p186ie_row("again-boundary",Bool.not(p186xm_has(p186fv_again(),"result"))),
   p186ie_row("setup-definition-refused",String.is_empty(x186_x_home("x",x186_x_homes(["state","a"],
     [P113DScalar{N111Set{"x",N111U64{},N111Const{0,0}}}],p186fv_nodes(p186xm_rhs())))))]
