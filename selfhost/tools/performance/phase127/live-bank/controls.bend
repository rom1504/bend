# Transport admission is additional to the unchanged full verifier. These
# fabricated statements are inspected as data and never executed as native code.

@unsafe
def p127lb_call(output: String) -> N111Stmt:
  N111Call{"status",N111U64{},"p126_rt_nat_divmod",p126dpc_args(output)}

@unsafe
def p127lb_import(args: List<&2,N111Arg>) -> String:
  p126dpc_verified([P113DScalar{N111Alloca{"out",16,8}},
    P113DScalar{N111Call{"status",N111U64{},"p126_rt_nat_divmod",args}}],
    [N111Local{"a"},N111Local{"b"}])

@unsafe
def p127lb_body(code: P113PValueCode) -> Bool:
  match code:
    case P113PValueCode{body,values,error}:
      String.is_empty(error) && p118z_direct(p113d_scalars(body))

@unsafe
def p127lb_controls() -> List<&2,String>:
  +alias : N111Stmt = N111Set{"alias",N111Ptr{},N111Local{"state"}}
  +offset : N111Stmt = N111Offset{"alias",N111Local{"state"},N111Const{40,0}}
  +read : N111Stmt = N111Call{"value",N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(0)]}
  [p126dpc_row("transport-divmod-import-admitted",p118z_runtime("p126_rt_nat_divmod")),
   p126dpc_row("transport-unknown-import-refused",Bool.not(p118z_scalar(
     N111Call{"status",N111U64{},"p127_unknown_import",p126dpc_args("out")},True{}))),
   p126dpc_row("transport-concat-not-added",Bool.not(p118z_runtime("p125_rt_concat_typed"))),
   p126dpc_row("transport-valid-divmod-call",p118z_scalar(p127lb_call("out"),True{})),
   p126dpc_row("transport-state-output-refused",Bool.not(p118z_scalar(p127lb_call("state"),True{}))),
   p126dpc_row("transport-wrong-result-type-refused",Bool.not(p118z_scalar(
     N111Call{"status",N111U32{},"p126_rt_nat_divmod",p126dpc_args("out")},True{}))),
   p126dpc_row("transport-state-alias-refused",Bool.not(p118z_scalar(alias,True{}))),
   p126dpc_row("transport-state-offset-refused",Bool.not(p118z_scalar(offset,True{}))),
   p126dpc_row("transport-nested-state-alias-refused",Bool.not(p118z_scalar(
     N111If{N111Const{1,0},[alias],[]},True{}))),
   p126dpc_row("transport-direct-register-read-refused",Bool.not(p118z_scalar(read,True{}))),
   p126dpc_row("verifier-exact-output-buffer",String.is_empty(p126dpc_import(16,"out",N111U64{}))),
   p126dpc_row("verifier-small-output-refused",Bool.not(String.is_empty(p126dpc_import(8,"out",N111U64{})))),
   p126dpc_row("verifier-state-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"state",N111U64{})))),
   p126dpc_row("verifier-missing-output-refused",Bool.not(String.is_empty(p126dpc_import(16,"missing",N111U64{})))),
   p126dpc_row("verifier-wrong-result-type-refused",Bool.not(String.is_empty(p126dpc_import(16,"out",N111U32{})))),
   p126dpc_row("verifier-wrong-argument-count-refused",Bool.not(String.is_empty(p127lb_import(
     [p111_state(),p111_word(N111Local{"a"}),p111_word(N111Local{"b"})])))),
   p126dpc_row("verifier-wrong-operand-type-refused",Bool.not(String.is_empty(p127lb_import(
     [p111_state(),N111Arg{N111U32{},N111Local{"a"}},p111_word(N111Local{"b"}),N111Arg{N111Ptr{},N111Local{"out"}}])))),
   p126dpc_row("verifier-null-output-refused",Bool.not(String.is_empty(p127lb_import(
     [p111_state(),p111_word(N111Local{"a"}),p111_word(N111Local{"b"}),N111Arg{N111Ptr{},N111Const{0,0}}])))),
   p126dpc_row("verifier-output-before-declaration-refused",Bool.not(String.is_empty(p126dpc_verified(
     [P113DScalar{p127lb_call("out")},P113DScalar{N111Alloca{"out",16,8}}],[N111Local{"a"},N111Local{"b"}])))),
   p126dpc_row("transport-generated-divmod-body",p127lb_body(p126dp_code(N111Local{"a"},N111Local{"b"},7)))]
