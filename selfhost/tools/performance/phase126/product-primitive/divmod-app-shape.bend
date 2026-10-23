# The checked let value is still App before p113pl_app sequences native operands.
# Reuse its exact built-in identity, saturation and non-bang authentication.
@unsafe
def p126dp_value_shape(+book: List<&2,KDef>, +value: KTerm, +target: NC_Target) -> KTerm:
  nt_choose(KTerm,String.eq(tg(value),"NOp") && U32.is_eq(p111_op_id(nm(value)),70) && U32.is_eq(terms_len(ks(value)),2),
    u => kt("NQShape","Tuple",2,0,[]),
    u => nt_choose(KTerm,String.eq(tg(value),"App"),
      v => nt_choose(KTerm,U32.is_eq(p111_op_id(nd_native_call(book,value)),70),
        w => kt("NQShape","Tuple",2,0,[]),w => nq_value_shape(book,value,target)),
      v => nq_value_shape(book,value,target)))

@unsafe
def p126dpa_native(+builtin: Bool, +arity: U32, +mode: U32) -> Bool:
  +d : KDef = KDef{"Nat.divmod","Def",2,0,atom("Type"),atom("Body"),[],builtin,False{}}
  p113p_known(p126dp_value_shape([d],nd_reapply(kt("Ref","Nat.divmod",0,mode,[]),nc_prim_args(arity,0)),NC_Scheduler{}))

@unsafe
def p126dp_app_controls() -> List<&2,String>:
  [p126dpc_row("app-authenticated-native",p126dpa_native(True{},2,0)),
   p126dpc_row("app-ordinary-lookalike-refused",Bool.not(p126dpa_native(False{},2,0))),
   p126dpc_row("app-partial-refused",Bool.not(p126dpa_native(True{},1,0))),
   p126dpc_row("app-overapplied-refused",Bool.not(p126dpa_native(True{},3,0))),
   p126dpc_row("app-bang-refused",Bool.not(p126dpa_native(True{},2,3)))]
