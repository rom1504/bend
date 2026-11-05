# Independent structural controls. Native lifetime/output controls are separate.

def p163dc_id() -> P113DFunction:
  P113DFunction{"p163.id",[NC_Binding{0,"x",N_W64{}}],1,False{},[P113DResult{[N111Local{"x"}]}]}

def p163dc_call(target: String) -> P113DFunction:
  P113DFunction{"p163.call",[NC_Binding{0,"x",N_W64{}}],1,False{},[
    P113DCall{["y"],target,[N111Local{"x"}]},P113DResult{[N111Local{"y"}]}]}

def p163dc_literal(value: N111Value) -> P113DFunction:
  P113DFunction{"p163.literal",[],1,False{},[P113DResult{[value]}]}

@unsafe
def p163dc_pass(functions: List<&2,P113DFunction>) -> Bool:
  String.is_empty(p163d_verify([],[],functions))

@unsafe
def p163dc_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p163dc_controls() -> List<&2,String>:
  [p163dc_row("word-return",p163dc_pass([p163dc_id()])),
   p163dc_row("ordered-direct-dependency",p163dc_pass([p163dc_id(),p163dc_call("p163.id")])),
   p163dc_row("unknown-call-refused",Bool.not(p163dc_pass([p163dc_call("absent")]))),
   p163dc_row("forward-call-refused",Bool.not(p163dc_pass([p163dc_call("p163.id"),p163dc_id()]))),
   p163dc_row("duplicate-worker-refused",Bool.not(p163dc_pass([p163dc_id(),p163dc_id()]))),
   p163dc_row("scheduler-fid-refused",Bool.not(p163dc_pass([p163dc_literal(N111FuncId{"absent"})]))),
   p163dc_row("unbound-symbol-refused",Bool.not(p163dc_pass([p163dc_literal(N111Symbol{"absent"})]))),
   p163dc_row("unknown-constructor-refused",Bool.not(p163dc_pass([p163dc_literal(N111CtorId{"absent"})]))),
   p163dc_row("public-scheduler-claim-refused",Bool.not(p163dc_pass([
     P113DFunction{"p163.public",[],1,True{},[P113DResult{[N111Const{0,0}]}]}]))),
   p163dc_row("nonterminal-refused",Bool.not(p163dc_pass([P113DFunction{"p163.open",[],1,False{},[]}]))),
   p163dc_row("duplicate-constructor-refused",Bool.not(String.is_empty(p163d_verify(
     [N_Constructor{"p163.C",0,False{}},N_Constructor{"p163.C",0,False{}}],[],[p163dc_id()])))),
   p163dc_row("static-self-reference-refused",Bool.not(String.is_empty(p163d_verify(
     [N_Constructor{"p163.C",1,False{}}],
     [P112SNode{0,"p163.C",[P112SBox{"p163.C",0}]}],[p163dc_id()])))),
   p163dc_row("static-offset-refused",Bool.not(String.is_empty(p163d_verify(
     [N_Constructor{"p163.C",1,False{}}],
     [P112SNode{1,"p163.C",[P112SRaw{7}]}],[p163dc_id()])))),
   p163dc_row("static-valid-prefix",String.is_empty(p163d_verify(
     [N_Constructor{"p163.C",1,False{}}],
     [P112SNode{0,"p163.C",[P112SRaw{7}]}],[p163dc_id()])))]
