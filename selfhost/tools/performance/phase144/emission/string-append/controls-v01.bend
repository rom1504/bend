# Pure verifier/admission controls. Reflected malformed IR is never executed.
@unsafe
def p144ap_definition(name: String, kind: String, arity: U32, templates: U32,
    native: Bool, body: KTerm) -> KDef:
  KDef{name,kind,arity,templates,atom("Absent"),body,[],native,False{}}

@unsafe
def p144ap_args(left: N111Arg, empty: String, link: String) -> List<&2,N111Arg>:
  [p111_state(),left,p111_word(N111Local{"b"}),
   N111Arg{N111U32{},N111CtorId{empty}},N111Arg{N111U32{},N111CtorId{link}}]

@unsafe
def p144ap_verified(symbol: String, typ: N111Type, args: List<&2,N111Arg>,
    empty_arity: U32, link_arity: U32) -> String:
  p113e_functions([
    P113DFunction{"$p144.append.control",[NC_Binding{1,"a",N_W64{}},NC_Binding{2,"b",N_W64{}}],1,False{},
      [P113DScalar{N111Call{"answer",typ,symbol,args}},P113DResult{[N111Local{"answer"}]}]}],
    N111Ids{missing(),ns_ctor_index([N_Constructor{"End",empty_arity,False{}},N_Constructor{"Link",link_arity,False{}}],missing())},missing())

@unsafe
def p144ap_controls() -> List<&2,String>:
  +body = dv(p125pc_equation("End","Link",1,2,3,4,"join"))
  +args = p144ap_args(p111_word(N111Local{"a"}),"End","Link")
  [p113ft_row("append-ordinary-source-definition",p144ap_source_definition(p144ap_definition("join","Def",2,0,False{},body))),
   p113ft_row("append-native-library-source-definition",p144ap_source_definition(p144ap_definition("library.join","Def",2,0,True{},body))),
   p113ft_row("append-intrinsic-substitution-refused",Bool.not(p144ap_source_definition(p144ap_definition("U32.add","Def",2,0,True{},body)))),
   p113ft_row("append-ordinary-intrinsic-spelling-source",p144ap_source_definition(p144ap_definition("U32.add","Def",2,0,False{},body))),
   p113ft_row("append-foreign-body-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,0,True{},atom("Foreign"))))),
   p113ft_row("append-absent-body-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,0,False{},atom("Absent"))))),
   p113ft_row("append-templates-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",2,1,False{},body)))),
   p113ft_row("append-arity-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Def",3,0,False{},body)))),
   p113ft_row("append-nondefinition-refused",Bool.not(p144ap_source_definition(p144ap_definition("join","Ctr",2,0,False{},body)))),
   p113ft_row("append-global-js-fusion-policy-unchanged",Bool.not(j_fusion_def(p144ap_definition("library.join","Def",2,0,True{},body),2))),
   p113ft_row("append-full-verifier-valid",String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,0,2))),
   p113ft_row("append-full-verifier-empty-arity",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,1,2)))),
   p113ft_row("append-full-verifier-link-arity",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},args,0,1)))),
   p113ft_row("append-full-verifier-result-width",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U32{},args,0,2)))),
   p113ft_row("append-full-verifier-operand-width",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(N111Arg{N111U32{},N111Local{"a"}},"End","Link"),0,2)))),
   p113ft_row("append-full-verifier-state-as-word",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"state"}),"End","Link"),0,2)))),
   p113ft_row("append-full-verifier-missing-constructor",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"a"}),"Missing","Link"),0,2)))),
   p113ft_row("append-full-verifier-constructor-alias",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},p144ap_args(p111_word(N111Local{"a"}),"End","End"),0,2)))),
   p113ft_row("append-full-verifier-argument-count",Bool.not(String.is_empty(p144ap_verified("p125_rt_concat_typed",N111U64{},[p111_state(),p111_word(N111Local{"a"})],0,2)))),
   p113ft_row("append-full-verifier-unknown-import",Bool.not(String.is_empty(p144ap_verified("p144_unknown_concat",N111U64{},args,0,2)))),
   p113ft_row("append-transport-valid",p118z_scalar(N111Call{"answer",N111U64{},"p125_rt_concat_typed",args},True{})),
   p113ft_row("append-transport-wrong-result",Bool.not(p118z_scalar(N111Call{"answer",N111U32{},"p125_rt_concat_typed",args},True{}))),
   p113ft_row("append-transport-unknown-import",Bool.not(p118z_scalar(N111Call{"answer",N111U64{},"p144_unknown_concat",args},True{})))]
