@unsafe
def p126sc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126sc_test_function(+name: String, +other: String) -> P113DFunction:
  P113DFunction{name,[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],1,False{},[
    P113DScalar{N111Bin{"stop",N111U64{},"eq",N111Local{"x"},N111Const{0,0}}},
    P113DIf{N111Local{"stop"},[P113DResult{[N111Local{"y"}]}],[P113DCall{["answer"],other,[N111Local{"y"},N111Local{"x"}]},P113DResult{[N111Local{"answer"}]}]}]}

@unsafe
def p126sc_test_candidate(+function: P113DFunction) -> P113DCandidate:
  P113DCandidate{function,"",p113j_calls(p126sc_body(function))}

@unsafe
def p126sc_test_functions(candidates: List<&2,P113DCandidate>) -> List<&2,P113DFunction>:
  match candidates:
    case Nil{}: []
    case Con{P113DCandidate{function,error,calls},rest}: Con{function,p126sc_test_functions(rest)}

@unsafe
def p126sc_full_word(values: List<&2,N111Value>) -> Bool:
  match values:
    case Con{N111Const{1,0},Con{N111Const{4294967295,4294967295},Con{N111Const{0,256},Con{N111Const{0,0},Nil{}}}}}: True{}
    case _: False{}

@unsafe
def p126sc_controls() -> List<&2,String>:
  +left = p126sc_test_function("a","b")
  +right = p126sc_test_function("b","a")
  +ca = p126sc_test_candidate(left)
  +cb = p126sc_test_candidate(right)
  +merged = p126sc_candidates([ca,cb])
  +ids : N111Ids = N111Ids{missing(),missing()}
  +params = p126sc_params(left)
  +nonterminal : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"},N111Local{"y"}]},P113DScalar{N111Set{"extra",N111U64{},N111Local{"z"}}},P113DResult{[N111Local{"extra"}]}]}
  +wrong_result : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"},N111Local{"y"}]},P113DResult{[N111Local{"x"}]}]}
  +wrong_arity : P113DFunction = P113DFunction{"a",params,1,False{},[
    P113DCall{["z"],"b",[N111Local{"x"}]},P113DResult{[N111Local{"z"}]}]}
  +multi : P113DFunction = P113DFunction{"a",params,2,False{},p126sc_body(left)}
  +oneway = p126sc_test_function("b","outside")
  +collision = p126sc_test_candidate(p126sc_test_function("$p126scc.0","outside"))
  [p126sc_row("pair-tail-admitted",p126sc_pair_safe(left,right)),
   p126sc_row("nonterminal-refused",Bool.not(p126sc_pair_safe(nonterminal,right))),
   p126sc_row("different-result-refused",Bool.not(p126sc_pair_safe(wrong_result,right))),
   p126sc_row("wrong-arity-refused",Bool.not(p126sc_pair_safe(wrong_arity,right))),
   p126sc_row("multi-result-refused",Bool.not(p126sc_pair_safe(multi,right))),
   p126sc_row("one-way-refused",Bool.not(p126sc_pair_safe(left,oneway))),
   p126sc_row("three-candidates",U32.is_eq(nt_count(P113DCandidate,merged),3)),
   p126sc_row("unchanged-verifier",String.is_empty(p113e_functions(p126sc_test_functions(merged),ids,missing()))),
   p126sc_row("duplicate-name-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca,ca,cb])),3)),
   p126sc_row("generated-name-collision-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca,cb,collision])),3)),
   p126sc_row("single-candidate-fallback",U32.is_eq(nt_count(P113DCandidate,p126sc_candidates([ca])),1)),
   p126sc_row("full-u64-lanes",p126sc_full_word(p126sc_lanes(1,[N111Const{4294967295,4294967295},N111Const{0,256}],3))),
   p126sc_row("self-tail-accepted",p126sc_safe([P113DAgain{[N111Local{"x"},N111Local{"y"}]}],"a","b",2,2,2)),
   p126sc_row("self-tail-arity-refused",Bool.not(p126sc_safe([P113DAgain{[N111Local{"x"}]}],"a","b",2,2,2))),
   p126sc_row("external-dependency-preserved",p126sc_has(p126sc_external(["a","outside","b"],"a","b"),"outside")),
   p126sc_row("internal-dependencies-removed",U32.is_eq(nt_count(String,p126sc_external(["a","b","a"],"a","b")),0))]
