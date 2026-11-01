

@unsafe
def p113_scalar_result_name(+name: String) -> Bool:
  nb_contains([
    "u32_add", "u32_sub", "u32_and", "u32_or", "u32_xor", "u32_mul",
    "u32_is_eq", "u32_is_ne", "u32_is_lt", "u32_is_le", "u32_is_gt", "u32_is_ge",
    "u32_inc", "u32_shl", "u32_shr", "u32_shln", "u32_shrn", "u32_div", "u32_mod", "u32_not", "u32_is_zero",
    "u32_to_f32", "u32_from_nat",
    "f32_add", "f32_sub", "f32_mul", "f32_div",
    "f32_is_eq", "f32_is_ne", "f32_is_lt", "f32_is_le", "f32_is_gt", "f32_is_ge",
    "f32_sqrt", "f32_exp", "f32_log", "f32_log2", "f32_log10", "f32_sin", "f32_cos", "f32_tan",
    "f32_asin", "f32_acos", "f32_atan", "f32_sinh", "f32_cosh", "f32_tanh",
    "f32_floor", "f32_ceil", "f32_trunc", "f32_abs", "f32_pow", "f32_atan2", "f32_mod", "f32_neg",
    "f32_to_u32", "f32_bits", "nat_is_lt", "bool_or", "bool_xor"], name)


@unsafe
def p113_primitive_kind(+name: String, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind,p113n_primitive(name),
    u => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),v => N_Imm64{},v => N_W64{}),
    u => nt_choose(N_WordKind,p113_scalar_result_name(name),
      v => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),w => N_W32{},w => N_W64{}),v => N_W64{}))

@unsafe
def p113_result_tele(+book: List<&2,KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, U32.is_eq(fuel,0), u => N_W64{},
    u => p113_result_head(book,nq_layout_type(book,ty),left,U32.sub(fuel,1)))


@unsafe
def p113_result_head(+book: List<&2,KDef>, +head: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"All"),
    u => nt_choose(N_WordKind, U32.is_eq(terms_len(ks(head)),2) && Bool.not(nc_occurs(kid(head,1),ix(head))),
      v => nt_choose(N_WordKind, U32.is_eq(qt(head),0),
        w => p113_result_tele(book,kid(head,1),left,fuel),
        w => nt_choose(N_WordKind, U32.is_gt(left,0),
          z => p113_result_tele(book,kid(head,1),U32.sub(left,1),fuel), z => N_W64{})),
      v => N_W64{}),
    u => nt_choose(N_WordKind, U32.is_eq(left,0), v => p113n_type_kind(book,head), v => N_W64{}))

@unsafe
def p113_callee_def(+book: List<&2,KDef>, +d: KDef, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, String.eq(dk(d),"Def") && Bool.not(nc_native_def(d)) && Bool.not(nc_foreign(d)),
    u => nt_choose(N_WordKind, U32.is_eq(arity,nd_arity(book,dn(d))),
      v => p113_result_tele(book,dt(d),arity,256), v => N_W64{}),
    u => N_W64{})


@unsafe
def p113_callee_kind(+book: List<&2,KDef>, +head: KTerm, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113_callee_def(book,lookup(book,nm(head)),arity), u => N_W64{})


@unsafe
def p113_application_kind(+book: List<&2,KDef>, +value: KTerm, +native: String) -> N_WordKind:
  nt_choose(N_WordKind, String.is_empty(native),
    u => p113_callee_kind(book,nd_head(value),terms_len(nd_args(value,[]))),
    u => p113_primitive_kind(native,terms_len(nd_args(value,[]))))

@unsafe
def p113_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"NStatic"),
    u => nt_choose(N_WordKind,p152c_immediate(book,value),v => N_Imm64{},v => p152c_prior_kind(book,value,env)),
    u => p152c_prior_kind(book,value,env))

@unsafe
def p113_binding(+book: List<&2,KDef>, +id: U32, +value: KTerm, +env: List<&2,NC_Binding>) -> NC_Binding:
  NC_Binding{id,"v_" ++ U32.show(id),p113_value_kind(book,value,env)}


@unsafe
def p113_fact_control_report() -> List<&2,String>:
  [p113ft_row("alias-scalar",p113ft_scalar(p113_value_kind([],var("",7),[NC_Binding{7,"v_7",N_W32{}}]))),
   p113ft_row("alias-opaque",Bool.not(p113ft_scalar(p113_value_kind([],var("",7),[NC_Binding{7,"v_7",N_W64{}}])))),
   p113ft_row("alias-box-preserved",p113ft_box(p113_value_kind([],var("",7),[NC_Binding{7,"v_7",N_Box{}}]))),
   p113ft_row("alias-shadow-first",Bool.not(p113ft_scalar(p113_value_kind([],var("",7),[NC_Binding{7,"v_7",N_W64{}},NC_Binding{7,"shadow",N_W32{}}])))),
   p113ft_row("missing-alias",Bool.not(p113ft_scalar(p113_value_kind([],var("",7),[])))),
   p113ft_row("nword-preserved",p113ft_scalar(p113_value_kind([],kt("NWord","4294967295",0,0,[]),[]))),
   p113ft_row("u32-binary-result",p113ft_op("u32_add",2)),
   p113ft_row("u32-unary-result",p113ft_op("u32_not",1)),
   p113ft_row("u32-bool-result",p113ft_op("u32_is_eq",2)),
   p113ft_row("u32-f32-result",p113ft_op("u32_to_f32",1)),
   p113ft_row("nat-u32-result",p113ft_op("u32_from_nat",1)),
   p113ft_row("f32-arithmetic-result",p113ft_op("f32_add",2)),
   p113ft_row("f32-unary-result",p113ft_op("f32_sqrt",1)),
   p113ft_row("f32-bool-result",p113ft_op("f32_is_lt",2)),
   p113ft_row("f32-bits-result",p113ft_op("f32_bits",1)),
   p113ft_row("bool-result",p113ft_op("bool_xor",2)),
   p113ft_row("nat-bool-result",p113ft_op("nat_is_lt",2)),
   p113ft_row("primitive-partial-refused",Bool.not(p113ft_op("u32_add",1))),
   p113ft_row("primitive-overapplied-refused",Bool.not(p113ft_op("u32_add",3))),
   p113ft_row("primitive-empty-refused",Bool.not(p113ft_op("u32_add",0))),
   p113ft_row("unknown-primitive-refused",Bool.not(p113ft_op("u32_custom",2))),
   p113ft_row("primitive-case-sensitive",Bool.not(p113ft_op("U32_ADD",2))),
   p113ft_row("u32-ordering-refused",Bool.not(p113ft_op("u32_cmp",2))),
   p113ft_row("nat-ordering-refused",Bool.not(p113ft_op("nat_cmp",2))),
   p113ft_row("nat-result-refused",Bool.not(p113ft_op("u32_to_nat",1))),
   p113ft_row("nat-arithmetic-refused",Bool.not(p113ft_op("nat_add",2))),
   p113ft_row("string-result-refused",Bool.not(p113ft_op("f32_show",1))),
   p113ft_row("parsed-result-refused",Bool.not(p113ft_op("f32_read",1))),
   p113ft_row("tuple-result-refused",Bool.not(p113ft_op("nat_divmod",2))),
   p113ft_row("array-get-refused",Bool.not(p113ft_op("array_get",2))),
   p113ft_row("array-size-refused",Bool.not(p113ft_op("array_size",1))),
   p113ft_row("array-atomic-refused",Bool.not(p113ft_op("array_atomic_add",3))),
   p113ft_row("authenticated-native",p113ft_native(True{},2,0)),
   p113ft_row("ordinary-name-not-intrinsic",Bool.not(p113ft_native(False{},2,0))),
   p113ft_row("native-partial-refused",Bool.not(p113ft_native(True{},1,0))),
   p113ft_row("native-overapplied-refused",Bool.not(p113ft_native(True{},3,0))),
   p113ft_row("native-bang-refused",Bool.not(p113ft_native(True{},2,3))),
   p113ft_row("checked-u32-callee",p113ft_call(p113ft_book(p113ft_type("U32"),True{}),1,0)),
   p113ft_row("checked-f32-callee",p113ft_call(p113ft_book(p113ft_type("F32"),True{}),1,0)),
   p113ft_row("checked-bool-callee",p113ft_call(p113ft_book(p113ft_type("Bool"),True{}),1,0)),
   p113ft_row("checked-char-callee",p113ft_call(p113ft_book(p113ft_type("Char"),True{}),1,0)),
   p113ft_row("callee-nat-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("Nat"),True{}),1,0))),
   p113ft_row("callee-string-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("String"),True{}),1,0))),
   p113ft_row("callee-lookalike-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("U32"),False{}),1,0))),
   p113ft_row("callee-dependent-refused",Bool.not(p113ft_call(p113ft_book(var("",7),True{}),1,0))),
   p113ft_row("callee-partial-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("U32"),True{}),0,0))),
   p113ft_row("callee-overapplied-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("U32"),True{}),2,0))),
   p113ft_row("callee-bang-refused",Bool.not(p113ft_call(p113ft_book(p113ft_type("U32"),True{}),1,3))),
   p113ft_row("callee-foreign-refused",Bool.not(p113ft_foreign())),
   p113ft_row("zero-arity-result",p113ft_zero()),
   p113ft_row("unknown-callee-refused",Bool.not(p113ft_call([],1,0))),
   p113ft_row("lowered-name-not-guessed",Bool.not(p113ft_scalar(p113_value_kind([],kt("NCall","probe",0,0,[]),[])))),
   p113ft_row("closure-not-scalar",Bool.not(p113ft_scalar(p113_value_kind([],k_lam("x",7,1,[var("",7)],0,0,False{}),[])))),
   p113ft_row("binding-id-word-preserved",p113ft_binding_shape(p113_binding([],9,kt("NOp","u32_add",0,0,nc_prim_args(2,0)),[]))),
   p113ft_row("scalar-result-keep-elided",U32.is_eq(p113ft_keep(kt("NOp","u32_add",0,0,nc_prim_args(2,0))),0)),
   p113ft_row("scalar-result-sink-elided",U32.is_eq(p113ft_drop(kt("NOp","u32_add",0,0,nc_prim_args(2,0))),0)),
   p113ft_row("string-result-keep-retained",U32.is_eq(p113ft_keep(kt("NOp","f32_show",0,0,nc_prim_args(1,0))),1)),
   p113ft_row("string-result-sink-retained",U32.is_eq(p113ft_drop(kt("NOp","f32_show",0,0,nc_prim_args(1,0))),1))]


@unsafe
def p113_field_control_report() -> List<&2,String>:
  [
    p113dft_row("field-one-scalar",U32.is_eq(p113dft_mask(1,1),1)),
    p113dft_row("field-mixed-slots",U32.is_eq(p113dft_mask(4,5),5)),
    p113dft_row("field-eight-scalars",U32.is_eq(p113dft_mask(8,255),255)),
    p113dft_row("field-all-unknown",U32.is_eq(p113dft_mask(4,0),0)),
    p113dft_row("field-outside-mask-fallback",U32.is_eq(p113dft_mask(3,8),0)),
    p113dft_row("field-width-nine-fallback",U32.is_eq(p113dft_mask(9,511),0)),
    p113dft_row("field-empty",U32.is_eq(p113dft_mask(0,0),0)),
    p113dft_row("field-legacy-arity-fallback",U32.is_eq(p113df_mask(kt("Mat","record",0,3,[]),2),0)),
    p113dft_row("field-mismatched-arity-fallback",U32.is_eq(p113df_mask(p113dft_mat("record",3,3),2),0)),
    p113dft_row("field-wrong-tag-fallback",U32.is_eq(p113df_mask(kt("Ctr","record",3,3,[]),2),0)),
    p113dft_row("field-erased-slot-does-not-shift",U32.is_eq(p113dft_erased(),2)),
    p113dft_row("field-U32-string",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(p113dft_type("U32"),p113dft_type("String")),2,0),1)),
    p113dft_row("field-bool-char",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(p113dft_type("Bool"),p113dft_type("Char")),2,0),3)),
    p113dft_row("field-transparent-alias",U32.is_eq(p113dft_alias(),1)),
    p113dft_row("field-shadow-F32",U32.is_eq(nh_field_mask([p113dft_owner("F32",False{})],p113dft_tele(p113dft_type("F32"),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}),2,0),0)),
    p113dft_row("field-dependent-stays-unknown",U32.is_eq(nh_field_mask(p113dft_book(),p113dft_tele(var("",99),p113dft_type("U32")),2,0),2)),
    p113dft_row("field-Nat-stays-unknown",U32.is_eq(nh_field_mask(Con{p113dft_owner("Nat",True{}),p113dft_book()},p113dft_tele(p113dft_type("Nat"),p113dft_type("U32")),2,0),2)),
    p113dft_row("bundle-refines-first-only",U32.is_eq(p113dft_bits(p113dft_bundle(1),0),1)),
    p113dft_row("bundle-keeps-word-and-id",p113dft_names(p113dft_bundle(3))),
    p113dft_row("bundle-preserves-old-opaque-kind",p113dft_box(nk_kind(12,p113dft_bundle(1)))),
    p113dft_row("bundle-constructor-mismatch",U32.is_eq(p113dft_bits(p113df_bundle_env(p113dft_mat("different",2,3),kt("NQBundle","record",0,0,[var("",11),var("",12)]),p113dft_env()),0),0)),
    p113dft_row("bundle-nonvariable-refusal",U32.is_eq(p113dft_bits(p113df_bundle_env(p113dft_mat("record",2,3),kt("NQBundle","record",0,0,[var("",11),{KTerm{"NWord", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]),p113dft_env()),0),0)),
    p113dft_row("bundle-keep-only-owner",U32.is_eq(nt_count(N111Stmt,p111_keep(p113dft_bundle(1),nu_add(nu_add(NU_Empty{},11),12))),1)),
    p113dft_row("bundle-drop-only-owner",U32.is_eq(p113dft_drop(p111_partition(p113dft_bundle(1),NU_Empty{})),1))
  ]


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


@unsafe
def p113_nat_match_control_report() -> List<&2,String>:
  [p113ft_row("nat-match-canonical-succ",p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,0),1)),
   p113ft_row("nat-match-unknown-book-refused",Bool.not(p113nm_eligible([],p113nmt_mat("Succ",2,0),1))),
   p113ft_row("nat-match-lookalike-refused",Bool.not(p113nm_eligible(p113nt_book(False{}),p113nmt_mat("Succ",2,0),1))),
   p113ft_row("nat-match-wrong-constructor",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Some",2,0),1))),
   p113ft_row("nat-match-zero-keeps-no-fields",List.is_empty(&2,N111Stmt,p113nm_take(p113nt_book(True{}),p113nmt_mat("Zero",1,0),N111Const{0,0},0,0))),
   p113ft_row("nat-match-legacy-arity-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",0,0),1))),
   p113ft_row("nat-match-wrong-arity-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",3,0),1))),
   p113ft_row("nat-match-wrong-field-count",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,0),2))),
   p113ft_row("nat-match-narrow-mask-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,1),1))),
   p113ft_row("nat-match-wrong-tag-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),kt("Ctr","Succ",2,0,[{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Efq", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}]),1))),
   p113ft_row("nat-match-missing-arms-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),kt("Mat","Succ",2,0,[]),1))),
   p113ft_row("nat-match-local-single-sub",p113nmt_local(p113nm_take(p113nt_book(True{}),p113nmt_mat("Succ",2,0),N111Local{"original_nat"},1,7))),
   p113ft_row("nat-match-one-fullword",p113nmt_word(1,0)),
   p113ft_row("nat-match-2pow32-fullword",p113nmt_word(0,1)),
   p113ft_row("nat-match-2pow40-fullword",p113nmt_word(0,256)),
   p113ft_row("nat-match-2pow48-minus1-fullword",p113nmt_word(4294967295,65535)),
   p113ft_row("nat-match-unknown-uses-original-special",p113nmt_fallback(p113nm_take([],p113nmt_mat("Succ",2,0),N111Local{"original_nat"},1,7),"p111_rt_special_take")),
   p113ft_row("nat-match-generic-uses-original-take",p113nmt_fallback(p113nm_take(p113nt_book(True{}),p113nmt_mat("Some",2,0),N111Local{"owner"},1,7),"p111_rt_take")),
   p113ft_row("nat-match-char-keeps-special-take",p113nmt_fallback(p113nm_take(p113nt_book(True{}),p113nmt_mat("Chr",2,1),N111Local{"character"},1,7),"p111_rt_special_take"))]


@unsafe
def p113_closure_control_report() -> List<&2,String>:
  +literal = p113dct_identity()
  +body = p113dct_body()
  [
    p113dct_row("closure-partial-residual-lambda",String.eq(tg(p113dct_plan(body,[literal,literal],0,[],100)),"Lam")),
    p113dct_row("closure-one-argument-residual-lambda",String.eq(tg(p113dct_plan(body,[literal],0,[],100)),"Lam")),
    p113dct_row("closure-saturated-linear",p113dct_valid(p113dct_plan(body,[literal,literal,var("",99)],0,[nc_binding(99)],100))),
    p113dct_row("closure-ordered-nonliteral-actuals",p113dct_order(p113dct_plan(body,[var("",98),literal,var("",99)],0,[nc_binding(98),nc_binding(99)],100))),
    p113dct_row("closure-captured-owner",p113dct_valid(p113dct_plan(body,[p113dct_lambda(90,app(var("",98),var("",90))),literal],0,[nc_binding(98)],100))),
    p113dct_row("closure-no-literal-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[var("",98),var("",99)],0,[nc_binding(98),nc_binding(99)],100)))),
    p113dct_row("closure-bang-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal],3,[],100)))),
    p113dct_row("closure-zero-actuals-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[],0,[],100)))),
    p113dct_row("closure-overapplication-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal,literal,literal],0,[],100)))),
    p113dct_row("closure-repeated-formal-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",11),app(var("",10),app(var("",10),var("",12)))),[literal,literal],0,[],100)))),
    p113dct_row("closure-unused-formal-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",10),var("",12)),[literal,literal],0,[],100)))),
    p113dct_row("closure-free-body-variable-fallback",Bool.not(p113dct_valid(p113dct_plan(app(var("",11),app(var("",10),var("",98))),[literal,literal],0,[nc_binding(98)],100)))),
    p113dct_row("closure-reference-body-fallback",Bool.not(p113dct_valid(p113dct_plan(app(kt("Ref","external",0,0,[]),body),[literal,literal],0,[],100)))),
    p113dct_row("closure-reserved-argument-id-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,var("",nc_id(100))],0,[nc_binding(nc_id(100))],100)))),
    p113dct_row("closure-reserved-capture-id-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[p113dct_lambda(90,app(var("",nc_id(101)),var("",90))),literal],0,[nc_binding(nc_id(101))],100)))),
    p113dct_row("closure-fresh-overflow-fallback",Bool.not(p113dct_valid(p113dct_plan(body,[literal,literal],0,[],4294967295)))),
    p113dct_row("closure-missing-definition-fallback",Bool.not(p113dct_valid(p113dc_plan([],p113dct_head(0),[literal],[],100)))),
    p113dct_row("closure-dynamic-head-fallback",Bool.not(p113dct_valid(p113dc_plan([p113dct_definition(body)],var("",11),[literal],[],100))))
  ]


@unsafe
def p113_width_control_report() -> List<&2,String>:
  +mask = p113wt_mask("value","value",4294967295,0)
  +first = p113wt_first("add")
  [p113wt_row("width-add",p113wt_accept("add")),
   p113wt_row("width-sub",p113wt_accept("sub")),
   p113wt_row("width-mul",p113wt_accept("mul")),
   p113wt_row("width-and",p113wt_accept("and")),
   p113wt_row("width-or",p113wt_accept("or")),
   p113wt_row("width-xor",p113wt_accept("xor")),
   p113wt_row("width-shl-refused",Bool.not(p113wt_accept("shl"))),
   p113wt_row("width-shr-refused",Bool.not(p113wt_accept("shr"))),
   p113wt_row("width-sar-refused",Bool.not(p113wt_accept("sar"))),
   p113wt_row("width-div-refused",Bool.not(p113wt_accept("udiv"))),
   p113wt_row("width-compare-refused",Bool.not(p113wt_accept("ult"))),
   p113wt_row("width-different-destination",Bool.not(p113w_pair(first,p113wt_mask("other","value",4294967295,0)))),
   p113wt_row("width-different-source",Bool.not(p113w_pair(first,p113wt_mask("value","other",4294967295,0)))),
   p113wt_row("width-near-mask",Bool.not(p113w_pair(first,p113wt_mask("value","value",4294967294,0)))),
   p113wt_row("width-high-mask",Bool.not(p113w_pair(first,p113wt_mask("value","value",4294967295,1)))),
   p113wt_row("width-u32-input-statement-refused",Bool.not(p113w_pair(P113DScalar{N111Bin{"value",N111U32{},"add",N111Local{"a"},N111Local{"b"}}},mask))),
   p113wt_row("width-branch-barrier",Bool.not(p113w_pair(first,P113DIf{N111Const{1,0},[mask],[mask]}))),
   p113wt_row("width-exact-emission",String.eq(p113wt_text([first,mask]),"%p113_width_7 =w add %v_a, %v_b\n%v_value =l extuw %p113_width_7\nret 0\n")),
   p113wt_row("width-mask-zero-extension",String.eq(p113wt_text([p113wt_mask("value","a",4294967295,0)]),"%p113_width_7 =w copy %v_a\n%v_value =l extuw %p113_width_7\nret 0\n")),
   p113wt_row("width-counter-consumed",p113wt_next(p113w_stmts([first,mask],[],N111Ids{missing(),missing()},P111QCode{[],7,False{},""}),8)),
   p113wt_row("width-counter-overflow-fallback",Bool.not(p113w_room(P111QCode{[],4294967295,False{},""}))),
   p113wt_row("width-destination-alias",String.eq(p113wt_text([P113DScalar{N111Bin{"value",N111U64{},"mul",N111Local{"value"},N111Local{"value"}}},mask]),"%p113_width_7 =w mul %v_value, %v_value\n%v_value =l extuw %p113_width_7\nret 0\n"))]


@unsafe
def p113_width_function(+which: U32) -> P113DFunction:
  P113DFunction{"p113_width_case_" ++ U32.show(which),[NC_Binding{0,"a",N_W64{}},NC_Binding{1,"b",N_W64{}}],1,False{},p113wt_case_body(which)}


@unsafe
def p113_width_case_error(which: U32) -> String:
  p113e_function(p113_width_function(which),N111Ids{missing(),missing()},missing())


@unsafe
def p113_width_case_qbe(+which: U32) -> String:
  nt_choose(String,String.is_empty(p113_width_case_error(which)),
    u => "export " ++ p113e_private(p113_width_function(which),N111Ids{missing(),missing()}),
    u => "INVALID_WIDTH_CONTROL\n")
