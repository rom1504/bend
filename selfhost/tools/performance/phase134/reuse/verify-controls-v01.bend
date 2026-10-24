# Controls for the actual integrated verified-function reuse implementation.

@unsafe
def p134v_boundary_same(a: P114SBoundary, b: P114SBoundary) -> Bool:
  match a b:
    case P114SBoundary{ao,ai,af,av} P114SBoundary{bo,bi,bf,bv}:
      p134v_bool(av,bv) && p134v_list(P113DFunction,p134v_function,af,bf)
@unsafe
def p134v_control(+original: P113DProgram, +candidate: List<&2,P113DFunction>) -> Bool:
  +boundary = p114s_open(original)
  p134v_boundary_same(p114s_commit(boundary,candidate),p134v_commit(boundary,candidate))
@unsafe
def p134v_controls() -> List<&2,String>:
  +identity = p114st_identity()
  +bad : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}
  +changed : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{9,0}]}]}
  +arity : P113DFunction = P113DFunction{"p114_identity",[],1,False{},[P113DResult{[N111Const{9,0}]}]}
  +scalar_good : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Const{7,0}]}]}
  +scalar_bad : P113DFunction = P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"undefined"}]}]}
  +published : P113DFunction = P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,True{},[P113DResult{[N111Local{"a"}]}]}
  +invalid : P113DProgram = P113DProgram{p114st_original(),[bad]}
  [p114st_row("reuse-empty",p134v_control(p114st_program(0),[])),
   p114st_row("reuse-identical",p134v_control(p114st_program(1),[identity])),
   p114st_row("reuse-changed-valid",p134v_control(p114st_program(1),[changed])),
   p114st_row("reuse-changed-invalid",p134v_control(p114st_program(1),[bad])),
   p114st_row("reuse-header-fallback",p134v_control(p114st_program(1),[arity])),
   p114st_row("reuse-length-fallback",p134v_control(p114st_program(1),[])),
   p114st_row("reuse-duplicate-fallback",p134v_control(p114st_program(1),[identity,identity])),
   p114st_row("reuse-invalid-boundary",p134v_control(invalid,[identity])),
   p114st_row("reuse-forward-call-fallback",p134v_control(p114st_program(2),[p114st_caller(),p114st_scalar(),p114st_pair()])),
   p114st_row("reuse-call-context",p134v_control(p114st_program(2),p114st_functions(2))),
   p114st_row("reuse-branch-context",p134v_control(p114st_program(3),p114st_functions(3))),
   p114st_row("reuse-loop-context",p134v_control(p114st_program(4),p114st_functions(4))),
   p114st_row("reuse-public-context",p134v_control(p114st_program(5),p114st_functions(5))),
   p114st_row("reuse-const-high-word",Bool.not(p134v_value(N111Const{1,0},N111Const{1,1}))),
   p114st_row("reuse-local-symbol",Bool.not(p134v_value(N111Local{"x"},N111Symbol{"x"}))),
   p114st_row("reuse-width",Bool.not(p134v_scalar(N111Set{"x",N111U32{},N111Const{0,0}},N111Set{"x",N111U64{},N111Const{0,0}}))),
   p114st_row("reuse-store-offset",Bool.not(p134v_scalar(N111Store{N111U64{},N111Local{"x"},0,N111Const{0,0}},N111Store{N111U64{},N111Local{"x"},8,N111Const{0,0}}))),
   p114st_row("reuse-alloca-alignment",Bool.not(p134v_scalar(N111Alloca{"x",8,8},N111Alloca{"x",8,16}))),
   p114st_row("reuse-terminal-kind",Bool.not(p134v_stmt(P113DResult{[N111Const{0,0}]},P113DAgain{[N111Const{0,0}]}))),
   p114st_row("reuse-callee-body-changed-valid",p134v_control(p114st_program(2),[scalar_good,p114st_pair(),p114st_caller()])),
   p114st_row("reuse-callee-body-changed-invalid",p134v_control(p114st_program(2),[scalar_bad,p114st_pair(),p114st_caller()])),
   p114st_row("reuse-public-change-fallback",p134v_control(p114st_program(1),[published])),
   p114st_row("reuse-runtime-symbol",Bool.not(p134v_scalar(N111Call{"x",N111U64{},"first",[]},N111Call{"x",N111U64{},"second",[]}))),
   p114st_row("reuse-call-arg-type",Bool.not(p134v_scalar(N111Call{"x",N111U64{},"first",[N111Arg{N111U32{},N111Const{0,0}}]},N111Call{"x",N111U64{},"first",[N111Arg{N111U64{},N111Const{0,0}}]}))),
   p114st_row("reuse-call-target",Bool.not(p134v_stmt(P113DCall{["x"],"first",[]},P113DCall{["x"],"second",[]}))),
   p114st_row("reuse-binding-kind",Bool.not(p134v_binding(NC_Binding{0,"a",N_W32{}},NC_Binding{0,"a",N_W64{}})))]
