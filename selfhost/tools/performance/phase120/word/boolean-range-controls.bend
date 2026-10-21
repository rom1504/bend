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

@unsafe
def p120wb_controls(unit: Unit) -> List<&2,String>:
  +facts = p113k_put(missing(),"x",p113k_bound(1))
  [p120wb_check("bool-eq1-copy",[p120wb_compare("eq",1)],facts,"copy"),
   p120wb_check("bool-eq0-invert",[p120wb_compare("eq",0)],facts,"xor"),
   p120wb_check("bool-ne0-copy",[p120wb_compare("ne",0)],facts,"copy"),
   p120wb_check("bool-ne1-invert",[p120wb_compare("ne",1)],facts,"xor"),
   p120wb_check("bool-nonboolean-refused",[p120wb_compare("eq",1)],p113k_put(missing(),"x",p113k_bound(32)),"eq"),
   p120wb_check("bool-unknown-refused",[p120wb_compare("eq",1)],missing(),"eq"),
   p120wb_check("bool-overwrite-invalidates",[N111Set{"x",N111U64{},N111Local{"unknown"}},p120wb_compare("eq",1)],facts,"eq"),
   p120wb_check("bool-constant-false",[N111Set{"x",N111U64{},N111Const{0,0}},p120wb_compare("eq",1)],facts,"constant0"),
   p120wb_check("bool-constant-true",[N111Set{"x",N111U64{},N111Const{1,0}},p120wb_compare("eq",1)],facts,"constant1"),
   p120wb_check("bool-agreeing-range-join",[N111If{N111Local{"condition"},[N111Set{"x",N111U64{},N111Const{0,0}}],[N111Set{"x",N111U64{},N111Const{1,0}}]},p120wb_compare("eq",1)],missing(),"copy"),
   p120wb_check("bool-wider-join-refused",[N111If{N111Local{"condition"},[N111Set{"x",N111U64{},N111Const{0,0}}],[N111Set{"x",N111U64{},N111Const{2,0}}]},p120wb_compare("eq",1)],missing(),"eq")]
