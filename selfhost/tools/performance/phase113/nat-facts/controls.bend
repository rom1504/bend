# New expectations supplement the existing Phase113 facts report; they do not
# relabel Imm64 as W32 or fabricate a Nat from an arbitrary U64 machine value.
@unsafe
def p113nt_type() -> KTerm:
  kt("ADT","Nat",0,0,[])

@unsafe
def p113nt_book(+builtin: Bool) -> List<&2,KDef>:
  +nat = p113nt_type()
  +succ : KDef = KDef{"Succ","Ctr",1,0,kt("All","pred",7,1,[nat,nat]),atom("Absent"),[],builtin,False{}}
  +zero : KDef = KDef{"Zero","Ctr",0,0,nat,atom("Absent"),[],builtin,False{}}
  [KDef{"Nat","ADT",0,0,atom("Data"),atom("Absent"),[zero,succ],builtin,False{}},
   KDef{"probe","Def",1,0,kt("All","n",7,1,[nat,nat]),k_lam("n",7,1,[var("",7)],0,0,False{}),[],False{},False{}}]

@unsafe
def p113nt_kind(+name: String, +count: U32) -> N_WordKind:
  p113_value_kind([],kt("NOp",name,0,0,nc_prim_args(count,0)),[])

@unsafe
def p113nt_seed(+builtin: Bool, +arity: U32) -> N_WordKind:
  nk_kind(nc_id(10),nk_typed_bindings(nd_entry_params(arity,10),nf_worker_kinds(p113nt_book(builtin),"probe",arity)))

@unsafe
def p113nt_call(+builtin: Bool, +count: U32) -> N_WordKind:
  p113_value_kind(p113nt_book(builtin),nd_reapply(kt("Ref","probe",0,0,[]),nc_prim_args(count,0)),[])

@unsafe
def p113nt_captured() -> N_WordKind:
  nk_kind(7,nc_live_uses([NC_Binding{7,"v_7",N_Imm64{}}],nu_add(NU_Empty{},7)))

@unsafe
def p113nt_field(+builtin: Bool, +count: U32, +index: U32) -> N_WordKind:
  p113n_field_kind(p113nt_book(builtin),kt("Mat","Succ",2,0,[]),count,index)

@unsafe
def p113nt_keep(kind: N_WordKind) -> U32:
  nt_count(N111Stmt,p111_keep([NC_Binding{7,"v_7",kind}],nu_add(NU_Empty{},7)))

@unsafe
def p113nt_drop(kind: N_WordKind) -> U32:
  p113ft_drop_count(p111_partition([NC_Binding{7,"v_7",kind}],NU_Empty{}))

# The same full-width constant must survive each structured return unchanged.
@unsafe
def p113nt_u64(+lo: U32, +hi: U32) -> Bool:
  p113nt_return_shape(p111_return(N111Const{lo,hi},0),lo,hi)

@unsafe
def p113nt_return_shape(code: P111Code, +lo: U32, +hi: U32) -> Bool:
  match code:
    case P111Code{Con{N111Store{N111U64{},N111Local{base},0,N111Const{a,b}},rest},segments,fresh,error}:
      String.eq(base,"scratch") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def p113_nat_control_report() -> List<&2,String>:
  [p113ft_row("nat-canonical-type",p113n_is_imm(p113n_type_kind(p113nt_book(True{}),p113nt_type()))),
   p113ft_row("nat-lookalike-refused",Bool.not(p113n_is_imm(p113n_type_kind(p113nt_book(False{}),p113nt_type())))),
   p113ft_row("nat-type-arguments-refused",Bool.not(p113n_is_imm(p113n_type_kind(p113nt_book(True{}),kt("ADT","Nat",0,0,[p113nt_type()]))))),
   p113ft_row("nat-unknown-type-refused",Bool.not(p113n_is_imm(p113n_type_kind([],p113nt_type())))),
   p113ft_row("nat-parameter-seed",p113n_is_imm(p113nt_seed(True{},1))),
   p113ft_row("nat-parameter-wrong-arity",Bool.not(p113n_is_imm(p113nt_seed(True{},2)))),
   p113ft_row("nat-lookalike-parameter",Bool.not(p113n_is_imm(p113nt_seed(False{},1)))),
   p113ft_row("nat-callee-result",p113n_is_imm(p113nt_call(True{},1))),
   p113ft_row("nat-callee-partial",Bool.not(p113n_is_imm(p113nt_call(True{},0)))),
   p113ft_row("nat-callee-overapplied",Bool.not(p113n_is_imm(p113nt_call(True{},2)))),
   p113ft_row("nat-callee-lookalike",Bool.not(p113n_is_imm(p113nt_call(False{},1)))),
   p113ft_row("nat-add-result",p113n_is_imm(p113nt_kind("nat_add",2))),
   p113ft_row("nat-sub-result",p113n_is_imm(p113nt_kind("nat_sub",2))),
   p113ft_row("nat-mul-result",p113n_is_imm(p113nt_kind("nat_mul",2))),
   p113ft_row("nat-double-result",p113n_is_imm(p113nt_kind("nat_double",1))),
   p113ft_row("u32-to-nat-result",p113n_is_imm(p113nt_kind("u32_to_nat",1))),
   p113ft_row("nat-wrong-primitive-arity",Bool.not(p113n_is_imm(p113nt_kind("nat_add",1)))),
   p113ft_row("nat-unknown-primitive",Bool.not(p113n_is_imm(p113nt_kind("nat_custom",2)))),
   p113ft_row("nat-ordering-carrier-opaque",Bool.not(p112to_nonowning(p113nt_kind("nat_cmp",2)))),
   p113ft_row("nat-divmod-carrier-owned",Bool.not(p112to_nonowning(p113nt_kind("nat_divmod",2)))),
   p113ft_row("string-result-still-owned",Bool.not(p112to_nonowning(p113nt_kind("f32_show",1)))),
   p113ft_row("nat-alias",p113n_is_imm(nk_value(var("",7),[NC_Binding{7,"v_7",N_Imm64{}}]))),
   p113ft_row("nat-capture",p113n_is_imm(p113nt_captured())),
   p113ft_row("nat-alias-shadowed",Bool.not(p113n_is_imm(nk_value(var("",7),[NC_Binding{7,"v_7",N_W64{}},NC_Binding{7,"v_7",N_Imm64{}}])))),
   p113ft_row("nat-succ-field",p113n_is_imm(p113nt_field(True{},1,0))),
   p113ft_row("nat-lookalike-field",Bool.not(p113n_is_imm(p113nt_field(False{},1,0)))),
   p113ft_row("nat-wrong-field-count",Bool.not(p113n_is_imm(p113nt_field(True{},2,0)))),
   p113ft_row("nat-outside-field-index",Bool.not(p113n_is_imm(p113nt_field(True{},1,1)))),
   p113ft_row("nat-zero-constructor",p113n_is_imm(p113_value_kind(p113nt_book(True{}),kt("Ctr","Zero",0,0,[]),[]))),
   p113ft_row("nat-succ-constructor",p113n_is_imm(p113_value_kind(p113nt_book(True{}),kt("NCtr","Succ",0,0,[var("",7)]),[]))),
   p113ft_row("nat-lookalike-constructor",Bool.not(p113n_is_imm(p113_value_kind(p113nt_book(False{}),kt("Ctr","Succ",0,0,[var("",7)]),[])))),
   p113ft_row("nat-constructor-wrong-arity",Bool.not(p113n_is_imm(p113_value_kind(p113nt_book(True{}),kt("NCtr","Succ",0,0,[]),[])))),
   p113ft_row("nat-field-producer",p113n_is_imm(nk_kind(nc_id(10),p113df_field_env(p113nt_book(True{}),kt("Mat","Succ",2,0,[]),1,0,10)))),
   p113ft_row("nat-field-malformed-mask",Bool.not(p113n_is_imm(p113n_field_kind(p113nt_book(True{}),kt("Mat","Succ",2,2,[]),1,0)))),
   p113ft_row("nat-keep-elided",U32.is_eq(p113nt_keep(N_Imm64{}),0)),
   p113ft_row("nat-sink-elided",U32.is_eq(p113nt_drop(N_Imm64{}),0)),
   p113ft_row("opaque-keep-retained",U32.is_eq(p113nt_keep(N_W64{}),1)),
   p113ft_row("opaque-sink-retained",U32.is_eq(p113nt_drop(N_W64{}),1)),
   p113ft_row("boxed-keep-retained",U32.is_eq(p113nt_keep(N_Box{}),1)),
   p113ft_row("boxed-sink-retained",U32.is_eq(p113nt_drop(N_Box{}),1)),
   p113ft_row("nat-c-type-term",String.eq(nl_c_type(N_Imm64{}),"Term")),
   p113ft_row("nat-private-type-term",String.eq(nf_param_type(N_Imm64{}),"Term")),
   p113ft_row("nat-not-u32",Bool.not(p113ft_scalar(N_Imm64{}))),
   p113ft_row("nat-2pow32-fullword",p113nt_u64(0,1)),
   p113ft_row("nat-2pow40-fullword",p113nt_u64(0,256)),
   p113ft_row("nat-2pow48-minus1-fullword",p113nt_u64(4294967295,65535))]
