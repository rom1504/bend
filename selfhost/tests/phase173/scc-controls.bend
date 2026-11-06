# Finite transformation controls. Final p113e verification is independent of
# discovery/admission; these controls are not a proof of compiler correctness.

@unsafe
def p173scc_test_function(+name: String, +other: String) -> P113DFunction:
  P113DFunction{name,[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],2,False{},[
    P113DScalar{N111Bin{"done",N111U64{},"eq",N111Local{"x"},N111Const{0,0}}},
    P113DIf{N111Local{"done"},[P113DResult{[N111Local{"y"},N111Local{"x"}]}],[
      P113DScalar{N111Bin{"next",N111U64{},"sub",N111Local{"x"},N111Const{1,0}}},
      P113DCall{["a","b"],other,[N111Local{"next"},N111Local{"y"}]},
      P113DResult{[N111Local{"a"},N111Local{"b"}]}]}]}

@unsafe
def p173scc_candidate(+function: P113DFunction) -> P113DCandidate:
  P113DCandidate{function,"",p113j_calls(p126sc_body(function))}

@unsafe
def p173scc_good() -> List<&2,P113DCandidate>:
  [p173scc_candidate(p173scc_test_function("alpha","beta")),
   p173scc_candidate(p173scc_test_function("beta","gamma")),
   p173scc_candidate(p173scc_test_function("gamma","alpha"))]

@unsafe
def p173scc_verified(+candidates: List<&2,P113DCandidate>, +count: U32) -> Bool:
  +functions = p113d_passes(candidates,missing(),[],32)
  U32.is_eq(nt_count(P113DFunction,functions),count) &&
    String.is_empty(p113e_functions(functions,N111Ids{missing(),missing()},missing())) &&
    String.is_empty(p147d_functions(functions,N111Ids{missing(),missing()},missing()))

@unsafe
def p173scc_non_tail() -> P113DFunction:
  P113DFunction{"alpha",[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],2,False{},[
    P113DCall{["a","b"],"beta",[N111Local{"x"},N111Local{"y"}]},
    P113DScalar{N111Bin{"later",N111U64{},"add",N111Local{"a"},N111Const{1,0}}},
    P113DResult{[N111Local{"later"},N111Local{"b"}]}]}

@unsafe
def p173scc_reversed_result() -> P113DFunction:
  P113DFunction{"alpha",[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],2,False{},[
    P113DCall{["a","b"],"beta",[N111Local{"x"},N111Local{"y"}]},
    P113DResult{[N111Local{"b"},N111Local{"a"}]}]}

@unsafe
def p173scc_wrong_width() -> P113DFunction:
  P113DFunction{"alpha",[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],1,False{},[
    P113DCall{["a","b"],"beta",[N111Local{"x"},N111Local{"y"}]},
    P113DResult{[N111Local{"a"}]}]}

@unsafe
def p173scc_wrong_args() -> P113DFunction:
  P113DFunction{"alpha",[NC_Binding{0,"x",N_W64{}},NC_Binding{1,"y",N_W64{}}],2,False{},[
    P113DCall{["a","b"],"beta",[N111Local{"x"}]},
    P113DResult{[N111Local{"a"},N111Local{"b"}]}]}

@unsafe
def p173scc_with(+first: P113DFunction) -> List<&2,P113DCandidate>:
  [p173scc_candidate(first),p173scc_candidate(p173scc_test_function("beta","gamma")),
   p173scc_candidate(p173scc_test_function("gamma","alpha"))]

@unsafe
def p173scc_unchanged(+candidates: List<&2,P113DCandidate>) -> Bool:
  U32.is_eq(nt_count(P113DCandidate,candidates),nt_count(P113DCandidate,p173sc_candidates(candidates)))

@unsafe
def p173scc_ring(+size: U32, +at: U32) -> List<&2,P113DCandidate>:
  +next = nt_choose(U32,U32.is_eq(U32.inc(at),size),u => 0,u => U32.inc(at))
  +name = "ring." ++ U32.show(at)
  +other = "ring." ++ U32.show(next)
  nt_choose(List<&2,P113DCandidate>,U32.is_eq(size,at),u => [],u =>
    Con{p173scc_candidate(p173scc_test_function(name,other)),p173scc_ring(size,U32.inc(at))})

@unsafe
def p173scc_row(+name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

@unsafe
def p173scc_prefix(+prefix: List<&2,P113DStmt>, +function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      P113DFunction{name,params,result,public,nt_append(P113DStmt,prefix,body)}

@unsafe
def p173scc_prefixed(+prefix: List<&2,P113DStmt>) -> List<&2,P113DCandidate>:
  [p173scc_candidate(p173scc_prefix(prefix,p173scc_test_function("alpha","beta"))),
   p173scc_candidate(p173scc_prefix(prefix,p173scc_test_function("beta","gamma"))),
   p173scc_candidate(p173scc_prefix(prefix,p173scc_test_function("gamma","alpha")))]

@unsafe
def p173scc_many(+left: U32) -> List<&2,P113DStmt>:
  match left:
    case 0: []
    case _: Con{P113DScalar{N111Set{"extra",N111U64{},N111Const{0,0}}},p173scc_many(U32.sub(left,1))}

@unsafe
def p173scc_stale() -> List<&2,P113DCandidate>:
  [P113DCandidate{p173scc_test_function("alpha","beta"),"",[]},
   P113DCandidate{p173scc_test_function("beta","gamma"),"",[]},
   P113DCandidate{p173scc_test_function("gamma","alpha"),"",[]}]

@unsafe
def p173scc_array_prefix() -> List<&2,P113DStmt>:
  [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"x"}}},
   P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{0,0}}},
   P113DScalar{N111Alloca{"p113p_out_0",16,8}},
   P113DScalar{N111Call{"array_status",N111U64{},"p113_rt_array_pair",
     [p111_state(),p111_u32(72),p111_scratch(),p111_u32(2),N111Arg{N111Ptr{},N111Local{"p113p_out_0"}},p111_u32(2)]}}]

@unsafe
def p173sc_controls() -> List<&2,String>:
  +good = p173scc_good()
  +fused = p173sc_candidates(good)
  +collision : P113DFunction = P113DFunction{"$p173scc.0",[],2,False{},[P113DResult{[N111Const{0,0},N111Const{0,0}]}]}
  +duplicate = p173scc_candidate(p173scc_test_function("alpha","beta"))
  [p173scc_row("three-member-two-result-fuses",U32.is_eq(nt_count(P113DCandidate,fused),4)),
   p173scc_row("three-member-two-result-independent-verifier",p173scc_verified(fused,4)),
   p173scc_row("two-member-two-result-fuses",U32.is_eq(nt_count(P113DCandidate,p173sc_candidates(p173scc_ring(2,0))),3)),
   p173scc_row("four-member-two-result-independent-verifier",p173scc_verified(p173sc_candidates(p173scc_ring(4,0)),5)),
   p173scc_row("non-tail-refuses",p173scc_unchanged(p173scc_with(p173scc_non_tail()))),
   p173scc_row("permuted-result-refuses",p173scc_unchanged(p173scc_with(p173scc_reversed_result()))),
   p173scc_row("mixed-result-width-refuses",p173scc_unchanged(p173scc_with(p173scc_wrong_width()))),
   p173scc_row("wrong-argument-count-refuses",p173scc_unchanged(p173scc_with(p173scc_wrong_args()))),
   p173scc_row("duplicate-identity-refuses",p173scc_unchanged(Con{duplicate,good})),
   p173scc_row("generated-identity-collision-refuses",p173scc_unchanged(Con{p173scc_candidate(collision),good})),
   p173scc_row("oversized-component-refuses",p173scc_unchanged(p173scc_ring(65,0))),
   p173scc_row("aggregate-body-budget-refuses",p173scc_unchanged(p173scc_prefixed(p173scc_many(3000)))),
   p173scc_row("aggregate-stack-budget-refuses",p173scc_unchanged(p173scc_prefixed([P113DScalar{N111Alloca{"extra",8192,8}}]))),
   p173scc_row("stale-call-metadata-not-trusted",p173scc_verified(p173sc_candidates(p173scc_stale()),4)),
   p173scc_row("renamed-array-import-independent-verifiers",p173scc_verified(p173sc_candidates(p173scc_prefixed(p173scc_array_prefix())),4)),
   p173scc_row("prefix63-array-authentication",p113j_buffer_origin(p112f_name(p173sc_prefix(63),"scratch"),True{}) && p113j_buffer_origin(p112f_name(p173sc_prefix(63),"p113p_out_0"),False{})),
   p173scc_row("prefix16-differs-prefix1",Bool.not(String.eq(p112f_name(p173sc_prefix(16),"scratch"),p112f_name(p173sc_prefix(1),"scratch")))),
   p173scc_row("singleton-unchanged",p173scc_unchanged([p173scc_candidate(collision)]))]
