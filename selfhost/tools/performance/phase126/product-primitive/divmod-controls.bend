# Pure import/shape controls, including invalid analysis records: no targets.
@unsafe
def p126dpc_tuple() -> KTerm:
  kt("NQShape","Tuple",2,0,[])

@unsafe
def p126dpc_args(+output: String) -> List<&2,N111Arg>:
  [p111_state(),p111_word(N111Local{"a"}),p111_word(N111Local{"b"}),N111Arg{N111Ptr{},N111Local{output}}]

@unsafe
def p126dpc_verified(body: List<&2,P113DStmt>, values: List<&2,N111Value>) -> String:
  p113e_functions([P113DFunction{"$p126.divmod.control",[NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}],2,False{},
    nt_append(P113DStmt,body,[P113DResult{values}])}],N111Ids{missing(),missing()},missing())

@unsafe
def p126dpc_code(code: P113PValueCode) -> String:
  match code:
    case P113PValueCode{body,values,+error}:
      nt_choose(String,String.is_empty(error),u => p126dpc_verified(p113d_scalars(body),values),u => error)

@unsafe
def p126dpc_import(+bytes: U32, +output: String, +typ: N111Type) -> String:
  p126dpc_verified([P113DScalar{N111Alloca{"out",bytes,8}},
    P113DScalar{N111Call{"status",typ,"p126_rt_nat_divmod",p126dpc_args(output)}}],
    [N111Local{"a"},N111Local{"b"}])

@unsafe
def p126dpc_row(+name: String, +ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126dpc_shape(value: KTerm) -> Bool:
  p113p_known(p126dp_value_shape([],value,NC_Scheduler{}))

@unsafe
def p126dp_controls() -> List<&2,String>:
  [p126dpc_row("local-shape-admitted",p126dpc_shape(kt("NOp","nat_divmod",0,0,[var("",1),var("",2)]))),
   p126dpc_row("local-wrong-arity-refused",Bool.not(p126dpc_shape(kt("NOp","nat_divmod",0,0,[var("",1)])))),
   p126dpc_row("shared-C-predicate-unchanged",Bool.not(nq_pair_primitive("nat_divmod"))),
   p126dpc_row("exact-product-selected",p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],p126dpc_tuple())),
   p126dpc_row("full64-operands-selected",p126dp_selected("nat_divmod",[N111Const{4294967295,65535},N111Const{33,0}],p126dpc_tuple())),
   p126dpc_row("wrong-operation-refused",Bool.not(p126dp_selected("nat_add",[N111Const{0,0},N111Const{0,0}],p126dpc_tuple()))),
   p126dpc_row("wrong-arity-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0}],p126dpc_tuple()))),
   p126dpc_row("opaque-result-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],atom("Absent")))),
   p126dpc_row("wrong-constructor-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],kt("NQShape","Other",2,0,[])))),
   p126dpc_row("wrong-width-refused",Bool.not(p126dp_selected("nat_divmod",[N111Const{0,0},N111Const{0,0}],kt("NQShape","Tuple",1,0,[])))),
   p126dpc_row("generated-function-verifies",String.is_empty(p126dpc_code(p126dp_code(N111Local{"a"},N111Local{"b"},7)))),
   p126dpc_row("exact-output-buffer",String.is_empty(p126dpc_import(16,"out",N111U64{}))),
   p126dpc_row("small-output-refused",Bool.not(String.is_empty(p126dpc_import(8,"out",N111U64{})))),
   p126dpc_row("state-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"state",N111U64{})))),
   p126dpc_row("missing-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"missing",N111U64{})))),
   p126dpc_row("wrong-result-width-refused",Bool.not(String.is_empty(p126dpc_import(16,"out",N111U32{}))))]
