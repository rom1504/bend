def p190cc_v(name: String) -> N111Value: N111Local{name}
def p190cc_result(n: U32) -> P113DStmt: P113DResult{[N111Const{n,0}]}
def p190cc_cmp(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}

@unsafe
def p190cc_complement(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "ne",u => nt_choose(String,String.eq(op,"ne"),u => "eq",u =>
  nt_choose(String,String.eq(op,"ult"),u => "uge",u => nt_choose(String,String.eq(op,"uge"),u => "ult",u =>
  nt_choose(String,String.eq(op,"ule"),u => "ugt",u => nt_choose(String,String.eq(op,"ugt"),u => "ule",u =>
  nt_choose(String,String.eq(op,"slt"),u => "sge",u => nt_choose(String,String.eq(op,"sge"),u => "slt",u =>
  nt_choose(String,String.eq(op,"sle"),u => "sgt",u => "sle")))))))))

def p190cc_ops() -> List<&2,String>: ["eq","ne","ult","ule","ugt","uge","slt","sle","sgt","sge"]

@unsafe
def p190cc_arm(+name: String, typ: N111Type, op: String, left: N111Value, right: N111Value, yes: U32, no: U32) -> List<&2,P113DStmt>:
  [p190cc_cmp(name,typ,op,left,right),P113DIf{p190cc_v(name),[p190cc_result(yes)],[p190cc_result(no)]}]

@unsafe
def p190cc_body(+typ: N111Type, +op: String, +inner: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Load{"a",typ,p190cc_v("state"),0}},P113DScalar{N111Load{"b",typ,p190cc_v("state"),8}},
   p190cc_cmp("outer",typ,op,p190cc_v("a"),p190cc_v("b")),P113DIf{p190cc_v("outer"),
     p190cc_arm("iy",typ,inner,p190cc_v("a"),p190cc_v("b"),11,13),
     p190cc_arm("in",typ,inner,p190cc_v("a"),p190cc_v("b"),17,19)}]

@unsafe
def p190cc_one(+symbol: String, +body: List<&2,P113DStmt>) -> X181Output:
  x185_function_frame(symbol,[],body,N111Ids{missing(),missing()},x181_frame(symbol,["state"],body))

@unsafe
def p190cc_emit_ops(ops: List<&2,String>, +typ: N111Type, +width: String) -> X181Output:
  match ops:
    case Nil{}: X181Output{[],""}
    case Con{+op,rest}:
      x181_program_join(p190cc_one("p190cc_" ++ width ++ "_" ++ op,p190cc_body(typ,op,p190cc_complement(op))),
        x181_program_join(p190cc_one("p190cs_" ++ width ++ "_" ++ op,p190cc_body(typ,op,op)),p190cc_emit_ops(rest,typ,width)))

def p190cc_emit() -> X181Output:
  x181_program_join(p190cc_emit_ops(p190cc_ops(),N111U32{},"32"),p190cc_emit_ops(p190cc_ops(),N111U64{},"64"))

@unsafe
def p190cc_is_result(body: List<&2,P113DStmt>, +n: U32) -> Bool:
  match body:
    case Con{P113DResult{Con{N111Const{lo,0},Nil{}}},Nil{}}: U32.is_eq(lo,n)
    case _: False{}

@unsafe
def p190cc_probe(+op: String, +inner: String, +truth: Bool, +arm: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x190_branch_arm_when(True{},N111U64{},op,p190cc_v("a"),p190cc_v("b"),truth,arm,x190_branch_facts([],[],arm))

@unsafe
def p190cc_rows(ops: List<&2,String>) -> List<&2,String>:
  match ops:
    case Nil{}: []
    case Con{+op,rest}:
      +opposite = p190cc_complement(op)
      +arm = p190cc_arm("inner",N111U64{},opposite,p190cc_v("a"),p190cc_v("b"),11,13)
      +same = p190cc_arm("inner",N111U64{},op,p190cc_v("a"),p190cc_v("b"),11,13)
      Con{"complement-" ++ op ++ nt_choose(String,p190cc_is_result(p190cc_probe(op,opposite,True{},arm),13) &&
        p190cc_is_result(p190cc_probe(op,opposite,False{},arm),11),u => "=1",u => "=0"),
        Con{"same-" ++ op ++ nt_choose(String,p190cc_is_result(p190cc_probe(op,op,True{},same),11) &&
          p190cc_is_result(p190cc_probe(op,op,False{},same),13),u => "=1",u => "=0"),p190cc_rows(rest)}}

@unsafe
def p190cc_controls() -> List<&2,String>:
  +arm = p190cc_arm("inner",N111U64{},"ne",p190cc_v("a"),p190cc_v("b"),11,13)
  +changed = p190cc_arm("inner",N111U64{},"ne",p190cc_v("a"),N111Const{1,0},11,13)
  +write: P113DStmt = P113DScalar{N111Set{"a",N111U64{},N111Const{7,0}}}
  +continuation: List<&2,P113DStmt> = [p190cc_cmp("inner",N111U64{},"ne",p190cc_v("a"),p190cc_v("b")),
    P113DIf{p190cc_v("inner"),[],[p190cc_result(13)]},p190cc_result(17)]
  +read: P113DStmt = P113DScalar{N111Store{N111U64{},p190cc_v("state"),16,p190cc_v("inner")}}
  nt_append(String,p190cc_rows(p190cc_ops()),[
    "different-operands=" ++ nt_choose(String,Bool.not(p190cc_is_result(p190cc_probe("eq","ne",True{},changed),13)),u => "=1",u => "=0"),
    "intervening-write=" ++ nt_choose(String,Bool.not(p190cc_is_result(p190cc_probe("eq","ne",True{},Con{write,arm}),13)),u => "=1",u => "=0"),
    "terminal-continuation=" ++ nt_choose(String,p190cc_is_result(p190cc_probe("eq","ne",True{},continuation),13) &&
      p190cc_is_result(p190cc_probe("eq","ne",False{},continuation),17),u => "=1",u => "=0"),
    "unpaired-read=" ++ nt_choose(String,Bool.not(p190cc_is_result(p190cc_probe("eq","ne",True{},
      [p190cc_cmp("inner",N111U64{},"ne",p190cc_v("a"),p190cc_v("b")),
       P113DIf{p190cc_v("inner"),[read,p190cc_result(11)],[p190cc_result(13)]}]),13)),u => "=1",u => "=0")])
