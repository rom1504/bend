# Raw typed-IR controls isolate final branch selection from earlier DCE/facts.
# The independent C observer covers every predicate at both machine widths.
def p190bc_v(name: String) -> N111Value: N111Local{name}
def p190bc_result(value: U32) -> P113DStmt: P113DResult{[N111Const{value,0}]}
def p190bc_bin(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}

def p190bc_compare(typ: N111Type, op: String) -> P113DStmt:
  p190bc_bin("predicate",typ,op,p190bc_v("a"),p190bc_v("b"))

@unsafe
def p190bc_inputs(+typ: N111Type, body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Load{"a",typ,p190bc_v("state"),0}},
    Con{P113DScalar{N111Load{"b",typ,p190bc_v("state"),8}},body}}

def p190bc_pair(typ: N111Type, op: String) -> List<&2,P113DStmt>:
  [p190bc_compare(typ,op),P113DIf{p190bc_v("predicate"),[p190bc_result(11)],[p190bc_result(29)]}]

@unsafe
def p190bc_emit_body(+symbol: String, +params: List<&2,String>, +body: List<&2,P113DStmt>) -> X181Output:
  x185_function_frame(symbol,[],body,N111Ids{missing(),missing()},x181_frame(symbol,params,body))

@unsafe
def p190bc_operations(ops: List<&2,String>, +typ: N111Type, +width: String) -> X181Output:
  match ops:
    case Nil{}: X181Output{[],""}
    case Con{+op,rest}:
      x181_program_join(p190bc_emit_body("p190b_" ++ width ++ "_" ++ op,["state"],p190bc_inputs(typ,p190bc_pair(typ,op))),
        p190bc_operations(rest,typ,width))

def p190bc_ops() -> List<&2,String>:
  ["eq","ne","ult","ule","ugt","uge","slt","sle","sgt","sge"]

def p190bc_alias() -> List<&2,P113DStmt>:
  p190bc_inputs(N111U64{},[p190bc_bin("a",N111U64{},"ult",p190bc_v("a"),p190bc_v("b")),
    P113DIf{p190bc_v("a"),[p190bc_result(11)],[p190bc_result(29)]}])

def p190bc_same() -> List<&2,P113DStmt>:
  p190bc_inputs(N111U64{},[p190bc_bin("predicate",N111U64{},"eq",p190bc_v("a"),p190bc_v("a")),
    P113DIf{p190bc_v("predicate"),[p190bc_result(11)],[p190bc_result(29)]}])

def p190bc_reuse() -> List<&2,P113DStmt>:
  p190bc_inputs(N111U64{},[p190bc_compare(N111U64{},"ult"),P113DIf{p190bc_v("predicate"),[],[]},
    P113DScalar{N111Store{N111U32{},p190bc_v("state"),16,p190bc_v("predicate")}},p190bc_result(47)])

def p190bc_nested() -> List<&2,P113DStmt>:
  p190bc_inputs(N111U64{},[p190bc_compare(N111U64{},"ult"),
    P113DIf{p190bc_v("predicate"),
      [p190bc_bin("inner",N111U64{},"sgt",p190bc_v("b"),p190bc_v("a")),
       P113DIf{p190bc_v("inner"),[p190bc_result(11)],[p190bc_result(29)]}],
      [p190bc_result(47)]}])

def p190bc_again() -> List<&2,P113DStmt>:
  [p190bc_bin("predicate",N111U64{},"eq",p190bc_v("n"),N111Const{0,0}),
   P113DIf{p190bc_v("predicate"),[P113DResult{[p190bc_v("acc")]}],
     [p190bc_bin("next",N111U64{},"sub",p190bc_v("n"),N111Const{1,0}),
      p190bc_bin("sum",N111U64{},"add",p190bc_v("acc"),p190bc_v("n")),
      P113DAgain{[p190bc_v("next"),p190bc_v("sum")]}]}]

@unsafe
def p190bc_emit() -> X181Output:
  x181_program_join(p190bc_operations(p190bc_ops(),N111U32{},"32"),
  x181_program_join(p190bc_operations(p190bc_ops(),N111U64{},"64"),
  x181_program_join(p190bc_emit_body("p190b_alias",["state"],p190bc_alias()),
  x181_program_join(p190bc_emit_body("p190b_same",["state"],p190bc_same()),
  x181_program_join(p190bc_emit_body("p190b_reuse",["state"],p190bc_reuse()),
  x181_program_join(p190bc_emit_body("p190b_nested",["state"],p190bc_nested()),
    p190bc_emit_body("p190b_again",["state","n","acc"],p190bc_again())))))))

def p190bc_plain_pair() -> List<&2,P113DStmt>:
  [p190bc_compare(N111U64{},"ult"),P113DIf{p190bc_v("predicate"),[],[]}]

@unsafe
def p190bc_admitted(params: List<&2,String>, setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> Bool:
  x190_branch_allowed("predicate",N111U64{},"ult",p190bc_v("predicate"),x190_branch_facts(params,setup,body))

def p190bc_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p190bc_controls() -> List<&2,String>:
  +pair = p190bc_plain_pair()
  +definition: P113DStmt = P113DScalar{N111Set{"predicate",N111U32{},N111Const{0,0}}}
  +read: P113DStmt = P113DScalar{N111Set{"copy",N111U32{},p190bc_v("predicate")}}
  +facts = x190_branch_facts([],[],pair)
  [p190bc_row("single-use",p190bc_admitted([],[],pair)),
   p190bc_row("parameter-refused",Bool.not(p190bc_admitted(["predicate"],[],pair))),
   p190bc_row("setup-refused",Bool.not(p190bc_admitted([],[definition],pair))),
   p190bc_row("duplicate-write-refused",Bool.not(p190bc_admitted([],[],Con{definition,pair}))),
   p190bc_row("earlier-read-refused",Bool.not(p190bc_admitted([],[],Con{read,pair}))),
   p190bc_row("continuation-read-refused",Bool.not(p190bc_admitted([],[],nt_append(P113DStmt,pair,[read])))),
   p190bc_row("again-read-refused",Bool.not(p190bc_admitted([],[],nt_append(P113DStmt,pair,[P113DAgain{[p190bc_v("predicate")]}])))),
   p190bc_row("branch-read-refused",Bool.not(p190bc_admitted([],[],
     [p190bc_compare(N111U64{},"ult"),P113DIf{p190bc_v("predicate"),[read],[]}]))),
   p190bc_row("outer-read-refused",Bool.not(p190bc_admitted([],[],
     [P113DIf{N111Const{1,0},pair,[]},read]))),
   p190bc_row("operand-alias-refused",Bool.not(p190bc_admitted([],[],
     [p190bc_bin("predicate",N111U64{},"ult",p190bc_v("predicate"),p190bc_v("b")),P113DIf{p190bc_v("predicate"),[],[]}]))),
   p190bc_row("wrong-condition-refused",Bool.not(x190_branch_allowed("predicate",N111U64{},"ult",p190bc_v("other"),facts))),
   p190bc_row("arithmetic-refused",Bool.not(x190_branch_allowed("predicate",N111U64{},"add",p190bc_v("predicate"),facts))),
   p190bc_row("pointer-refused",Bool.not(x190_branch_allowed("predicate",N111Ptr{},"eq",p190bc_v("predicate"),facts))),
   p190bc_row("signed-inverse",String.eq(x190_branch_inverse("slt"),"jge") && String.eq(x190_branch_inverse("sge"),"jl")),
   p190bc_row("unsigned-inverse",String.eq(x190_branch_inverse("ult"),"jae") && String.eq(x190_branch_inverse("uge"),"jb")),
   p190bc_row("u64-high-immediate-refused",x188_empty(x190_branch_immediate(N111U64{},N111Const{2147483648,0}))),
   p190bc_row("u32-high-immediate",Bool.not(x188_empty(x190_branch_immediate(N111U32{},N111Const{2147483648,0})))),
   p190bc_row("full-word-immediate-refused",x188_empty(x190_branch_immediate(N111U64{},N111Const{0,2147483648})))]
