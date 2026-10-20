@unsafe
def p113p_test_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => " PASS\n",u => " FAIL\n")

@unsafe
def p113p_test_call(+id: U32, +count: U32, +input: String, +output: String, +outputs: U32) -> List<&2,N111Arg>:
  [p111_state(),p111_u32(id),N111Arg{N111Ptr{},N111Local{input}},p111_u32(count),N111Arg{N111Ptr{},N111Local{output}},p111_u32(outputs)]

@unsafe
def p113p_test_values(code: P113PValueCode, +width: U32, +error: Bool) -> Bool:
  match code:
    case P113PValueCode{body,values,+message}: U32.is_eq(nt_count(N111Value,values),width) && nt_choose(Bool,error,u => Bool.not(String.is_empty(message)),u => String.is_empty(message))

@unsafe
def p113p_control_report() -> String:
  +pair = kt("NQShape","Tuple",2,0,[])
  p113p_test_row("layout-one",p113p_known(kt("NQShape","C",1,0,[]))) ++
  p113p_test_row("layout-eight",p113p_known(kt("NQShape","C",8,0,[]))) ++
  p113p_test_row("layout-zero-refuses",Bool.not(p113p_known(kt("NQShape","C",0,0,[])))) ++
  p113p_test_row("layout-nine-refuses",Bool.not(p113p_known(kt("NQShape","C",9,0,[])))) ++
  p113p_test_row("array-get",p113p_array_pair("array_get",2)) ++
  p113p_test_row("array-swap",p113p_array_pair("array_swap",3)) ++
  p113p_test_row("array-size",p113p_array_pair("array_size",1)) ++
  p113p_test_row("array-clone",p113p_array_pair("array_clone",1)) ++
  p113p_test_row("array-set-boxed",Bool.not(p113p_array_pair("array_set",3))) ++
  p113p_test_row("wrong-arity-refuses",Bool.not(p113p_array_pair("array_get",1))) ++
  p113p_test_row("exact-import",p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","p113p_out_1",2))) ++
  p113p_test_row("state-input-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"state","p113p_out_1",2)))) ++
  p113p_test_row("state-output-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","state",2)))) ++
  p113p_test_row("wrong-output-count-refuses",Bool.not(p113p_array_call("p113_rt_array_pair",p113p_test_call(72,2,"scratch","p113p_out_1",1)))) ++
  p113p_test_row("exact-vector",p113p_test_values(p113p_transfer(pair,pair,[N111Const{1,0},N111Const{2,0}]),2,False{})) ++
  p113p_test_row("wrong-shape-refuses",p113p_test_values(p113p_transfer(pair,kt("NQShape","Other",2,0,[]),[N111Const{1,0},N111Const{2,0}]),0,True{})) ++
  p113p_test_row("boxing-boundary",p113p_test_values(p113p_transfer(pair,atom("Absent"),[N111Const{1,0},N111Const{2,0}]),1,False{})) ++
  p113p_test_row("width-mismatch-refuses",p113p_test_values(p113p_transfer(pair,pair,[N111Const{1,0}]),0,True{})) ++
  p113p_test_row("one-field-constructor-mismatch-refuses",p113p_test_values(p113p_constructor("Other",[N111Const{1,0}],kt("NQShape","C",1,0,[])),0,True{})) ++
  p113p_test_row("one-field-primitive-mismatch-refuses",p113p_test_values(p113p_primitive("array_size",[N111Const{1,0}],kt("NQShape","C",1,0,[]),0),0,True{}))
