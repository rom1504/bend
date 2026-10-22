# Pure admission controls. These never execute invented runtime IR.
@unsafe
def p126ac_op(+name: String, +id: U32, +value: N111Value) -> List<&2,P113DStmt>:
  [P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,value}},
   P113DScalar{N111Store{N111U64{},N111Local{"scratch"},8,N111Const{1065353216,0}}},
   P113DScalar{N111Call{name,N111U64{},"p111_rt_op",[
     N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U32{},N111Const{id,0}},
     N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{2,0}}]}}]

@unsafe
def p126ac_function(+name: String, +params: List<&2,NC_Binding>, +body: List<&2,P113DStmt>) -> P113DFunction:
  P113DFunction{name,params,1,False{},body}

@unsafe
def p126ac_params() -> List<&2,NC_Binding>:
  [NC_Binding{"x","x",N_W64{}}]

@unsafe
def p126ac_row(+label: String, +body: List<&2,P113DStmt>, +expected: Bool) -> String:
  +actual = p114so_member(p126t_analyze(p126ac_function("control",p126ac_params(),body),[]),"x")
  nt_choose(String,U32.is_eq(Bool.to_u32(actual),Bool.to_u32(expected)),u => label ++ ":pass",u => label ++ ":FAIL")

@unsafe
def p126ac_return(+name: String) -> List<&2,P113DStmt>:
  [P113DResult{[N111Local{name}]}]

@unsafe
def p126ac_float() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p126ac_op("z",28,N111Local{"x"}),p126ac_return("z"))

@unsafe
def p126ac_copy() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Set{"y",N111U64{},N111Local{"x"}}}],
    nt_append(P113DStmt,p126ac_op("z",28,N111Local{"y"}),p126ac_return("z")))

@unsafe
def p126ac_branch() -> List<&2,P113DStmt>:
  [P113DIf{N111Const{1,0},p126ac_float(),p126ac_return("x")}]

@unsafe
def p126ac_overwrite() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Set{"y",N111U64{},N111Local{"x"}}},
    P113DScalar{N111Set{"y",N111U64{},N111Const{0,0}}}],
    nt_append(P113DStmt,p126ac_op("z",28,N111Local{"x"}),p126ac_return("y")))

@unsafe
def p126ac_backedge() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p126ac_op("z",28,N111Local{"x"}),[P113DAgain{[N111Local{"x"}]}])

@unsafe
def p126ac_bad_scratch() -> List<&2,P113DStmt>:
  nt_append(P113DStmt,p126ac_op("z",28,N111Local{"x"}),[
    P113DScalar{N111Load{"raw",N111U64{},N111Local{"scratch"},0}},P113DResult{[N111Local{"raw"}]}])

@unsafe
def p126ac_callee() -> String:
  +leaf = p126ac_function("leaf",p126ac_params(),p126ac_float())
  +caller = p126ac_function("caller",p126ac_params(),[
    P113DCall{["z"],"leaf",[N111Local{"x"}]},P113DResult{[N111Local{"z"}]}])
  +plans = p126t_plans([leaf,caller])
  p126ac_callee_result(p126t_find(plans,"caller"))

@unsafe
def p126ac_callee_result(plan: Maybe<&2,P126TPlan>) -> String:
  match plan:
    case None{}: "callee-contract:FAIL"
    case Some{P126TPlan{function,floats}}:
      nt_choose(String,p114so_member(floats,"x"),u => "callee-contract:pass",u => "callee-contract:FAIL")

@unsafe
def p126ac_cross_backedge() -> String:
  +function = p126ac_function("cross",[NC_Binding{"x","x",N_W64{}},NC_Binding{"y","y",N_W64{}}],[
    P113DIf{N111Const{1,0},
      nt_append(P113DStmt,p126ac_op("z",28,N111Local{"x"}),[P113DAgain{[N111Local{"x"},N111Local{"x"}]}]),
      p126ac_return("y")}])
  nt_choose(String,List.is_empty(&2,String,p126t_analyze(function,[])),u => "cross-backedge:pass",u => "cross-backedge:FAIL")

@unsafe
def p126ac_controls() -> List<&2,String>:
  [p126ac_row("float-use",p126ac_float(),True{}),
   p126ac_row("copy-closure",p126ac_copy(),True{}),
   p126ac_row("raw-result",p126ac_return("x"),False{}),
   p126ac_row("unknown-call",[P113DCall{["z"],"unknown",[N111Local{"x"}]},P113DResult{[N111Local{"z"}]}],False{}),
   p126ac_row("branch-fullword",p126ac_branch(),False{}),
   p126ac_row("overwrite-conservative",p126ac_overwrite(),False{}),
   p126ac_row("backedge-self",p126ac_backedge(),True{}),
   p126ac_row("scratch-observation",p126ac_bad_scratch(),False{}),
   p126ac_callee(),p126ac_cross_backedge()]
