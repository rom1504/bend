# Version02 includes the independent full-function width boundary.
# Pure existing range-state controls; no target execution or forged runtime data.
@unsafe
def p120wb_kind(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,N111Const{lo,hi}}: "constant" ++ U32.show(lo)
    case N111Set{name,typ,N111Local{word}}: "copy"
    case N111Bin{name,typ,op,left,right}: op
    case _: "other"

@unsafe
def p120wb_last(body: List<&2,N111Stmt>, current: String) -> String:
  match body:
    case Nil{}: current
    case Con{stmt,rest}: p120wb_last(rest,p120wb_kind(stmt))

@unsafe
def p120wb_result(result: P113KScalar) -> String:
  match result:
    case P113KScalar{body,facts}: p120wb_last(body,"")

@unsafe
def p120wb_compare(op: String, value: U32) -> N111Stmt:
  N111Bin{"answer",N111U64{},op,N111Local{"x"},N111Const{value,0}}

@unsafe
def p120wb_check(name: String, body: List<&2,N111Stmt>, facts: KDef, expected: String) -> String:
  p113wt_row(name,String.eq(p120wb_result(p113k_scalars(body,facts)),expected))

# A complete width-correct private function, or the rejected old replacement.
# The negative body is used only as input to the independent verifier.
@unsafe
def p120wb_verified_fixture(invalid: Bool) -> P113DFunction:
  P113DFunction{"$control.boolean_range",[NC_Binding{0,"input",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"x",N111U64{},"and",N111Local{"input"},N111Const{1,0}}},
     P113DScalar{nt_choose(N111Stmt,invalid,
       u => N111Set{"predicate",N111U32{},N111Local{"x"}},
       u => N111Bin{"predicate",N111U64{},"eq",N111Local{"x"},N111Const{1,0}})},
     P113DScalar{N111If{N111Local{"predicate"},
       [N111Set{"answer",N111U64{},N111Const{1,0}}],
       [N111Set{"answer",N111U64{},N111Const{0,0}}]}},
     P113DResult{[N111Local{"answer"}]}]}

@unsafe
def p120wb_verify(function: P113DFunction) -> String:
  p113e_function(function,N111Ids{missing(),missing()},missing())

@unsafe
def p120wb_controls(unit: Unit) -> List<&2,String>:
  +facts = p113k_put(missing(),"x",p113k_bound(1))
  [p120wb_check("bool-eq1-to-ne0",[p120wb_compare("eq",1)],facts,"ne"),
   p120wb_check("bool-eq0-unchanged",[p120wb_compare("eq",0)],facts,"eq"),
   p120wb_check("bool-ne0-unchanged",[p120wb_compare("ne",0)],facts,"ne"),
   p120wb_check("bool-ne1-to-eq0",[p120wb_compare("ne",1)],facts,"eq"),
   p120wb_check("bool-nonboolean-refused",[p120wb_compare("eq",1)],p113k_put(missing(),"x",p113k_bound(32)),"eq"),
   p120wb_check("bool-unknown-refused",[p120wb_compare("eq",1)],missing(),"eq"),
   p120wb_check("bool-overwrite-invalidates",[N111Set{"x",N111U64{},N111Local{"unknown"}},p120wb_compare("eq",1)],facts,"eq"),
   p120wb_check("bool-constant-false",[N111Set{"x",N111U64{},N111Const{0,0}},p120wb_compare("eq",1)],facts,"constant0"),
   p120wb_check("bool-constant-true",[N111Set{"x",N111U64{},N111Const{1,0}},p120wb_compare("eq",1)],facts,"constant1"),
   p120wb_check("bool-agreeing-range-join",[N111If{N111Local{"condition"},[N111Set{"x",N111U64{},N111Const{0,0}}],[N111Set{"x",N111U64{},N111Const{1,0}}]},p120wb_compare("eq",1)],missing(),"ne"),
   p120wb_check("bool-wider-join-refused",[N111If{N111Local{"condition"},[N111Set{"x",N111U64{},N111Const{0,0}}],[N111Set{"x",N111U64{},N111Const{2,0}}]},p120wb_compare("eq",1)],missing(),"eq"),
   p113wt_row("bool-complete-original-verifies",String.is_empty(p120wb_verify(p120wb_verified_fixture(False{})))),
   p113wt_row("bool-complete-transformed-verifies",String.is_empty(p120wb_verify(p113k_function(p120wb_verified_fixture(False{}))))),
   p113wt_row("bool-old-width-copy-refused",String.eq(p120wb_verify(p120wb_verified_fixture(True{})),"ill-typed or undefined assignment"))]
