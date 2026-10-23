@unsafe
def p128bi_test_params() -> List<&2,NC_Binding>:
  [NC_Binding{1,"x",N_W64{}},NC_Binding{2,"y",N_W64{}}]

@unsafe
def p128bi_test_wrapper(+name: String, args: List<&2,N111Value>) -> P113DFunction:
  P113DFunction{name,p128bi_test_params(),1,True{},
    [P113DCall{["answer"],"worker",args},P113DResult{[N111Local{"answer"}]}]}

@unsafe
def p128bi_test_pattern() -> List<&2,N111Value>:
  [N111Const{1,0},N111Local{"x"},N111Local{"y"},N111Const{0,0}]

@unsafe
def p128bi_test_call(+selector: N111Value) -> P113DStmt:
  P113DCall{["out"],"worker",[selector,N111Local{"u"},N111Local{"v"},N111Const{0,0}]}

@unsafe
def p128bi_test_target(stmt: P113DStmt) -> String:
  match stmt:
    case P113DCall{out,target,args}: target
    case _: "not-call"

@unsafe
def p128bi_test_bound(stmt: P113DStmt, +left: String, +right: String) -> Bool:
  match stmt:
    case P113DCall{out,target,Con{N111Local{a},Con{N111Local{b},Nil{}}}}:
      String.eq(target,"observe") && String.eq(a,left) && String.eq(b,right)
    case _: False{}

@unsafe
def p128bi_test_caller(name: String) -> P113DFunction:
  P113DFunction{name,p128bi_test_params(),1,False{},
    [P113DCall{["answer"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"answer"}]}]}

@unsafe
def p128bi_test_body_target(+name: String, functions: List<&2,P113DFunction>) -> String:
  match functions:
    case Nil{}: "missing"
    case Con{P113DFunction{target,params,result,public,body},rest}:
      nt_choose(String,String.eq(name,target),
        u => p128bi_test_first(body),u => p128bi_test_body_target(name,rest))

@unsafe
def p128bi_test_first(body: List<&2,P113DStmt>) -> String:
  match body:
    case Con{head,rest}: p128bi_test_target(head)
    case _: "empty"

@unsafe
def p128bi_test_walk() -> List<&2,P113DFunction>:
  +original = p128bi_test_wrapper("observe",p128bi_test_pattern())
  +replacement : List<&2,P113DFunction> = [p128bi_test_caller("owned"),
    P113DFunction{"observe",p128bi_test_params(),1,True{},
      [P113DCall{["answer"],"owned",[N111Local{"x"},N111Local{"y"}]},P113DResult{[N111Local{"answer"}]}]}]
  p128br_apply([p128bi_test_caller("before"),original,p128bi_test_caller("after")],
    [P128BRPatch{"observe",replacement}])

@unsafe
def p128bi_controls() -> List<&2,String>:
  +good = p128bi_rule(p128bi_test_wrapper("observe",p128bi_test_pattern()))
  +index = p128bi_index(missing(),good)
  +permuted = p128bi_index(missing(),p128bi_rule(p128bi_test_wrapper("observe",
    [N111Const{1,0},N111Local{"y"},N111Local{"x"},N111Const{0,0}])))
  +duplicate = p128bi_rule(p128bi_test_wrapper("observe",[N111Local{"x"},N111Local{"x"}]))
  +missing_arg = p128bi_rule(p128bi_test_wrapper("observe",[N111Local{"x"}]))
  +bad_result = p128bi_rule(P113DFunction{"observe",p128bi_test_params(),1,True{},
    [P113DCall{["answer"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"different"}]}]})
  +permuted_result = p128bi_rule(P113DFunction{"observe",p128bi_test_params(),2,True{},
    [P113DCall{["a","b"],"worker",p128bi_test_pattern()},P113DResult{[N111Local{"b"},N111Local{"a"}]}]})
  +ambiguous = p128bi_index(index,p128bi_rule(p128bi_test_wrapper("alternative",p128bi_test_pattern())))
  +walk = p128bi_test_walk()
  [p128bs_control_row("boundary-exact-wrapper",String.eq(dk(good),"P128BIRule")),
   p128bs_control_row("boundary-inverse-bindings",p128bi_test_bound(p128bi_call(p128bi_test_call(N111Const{1,0}),index),"u","v")),
   p128bs_control_row("boundary-inverse-permutation",p128bi_test_bound(p128bi_call(p128bi_test_call(N111Const{1,0}),permuted),"v","u")),
   p128bs_control_row("boundary-wrong-selector-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{0,0}),index)),"worker")),
   p128bs_control_row("boundary-high-selector-bits-preserved",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{1,1}),index)),"worker")),
   p128bs_control_row("boundary-dynamic-selector-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Local{"dynamic"}),index)),"worker")),
   p128bs_control_row("boundary-repeated-formal-refused",String.eq(dk(duplicate),"Absent")),
   p128bs_control_row("boundary-missing-formal-refused",String.eq(dk(missing_arg),"Absent")),
   p128bs_control_row("boundary-different-result-refused",String.eq(dk(bad_result),"Absent")),
   p128bs_control_row("boundary-result-permutation-refused",String.eq(dk(permuted_result),"Absent")),
   p128bs_control_row("boundary-ambiguous-rule-falls-back",String.eq(p128bi_test_target(p128bi_call(p128bi_test_call(N111Const{1,0}),ambiguous)),"worker")),
   p128bs_control_row("boundary-earlier-caller-untouched",String.eq(p128bi_test_body_target("before",walk),"worker")),
   p128bs_control_row("boundary-later-caller-rewritten",String.eq(p128bi_test_body_target("after",walk),"observe")),
   p128bs_control_row("boundary-owning-fallback-untouched",String.eq(p128bi_test_body_target("owned",walk),"worker")),
   p128bs_control_row("boundary-new-adapter-untouched",String.eq(p128bi_test_body_target("observe",walk),"owned"))]
