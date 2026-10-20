# Independent expected classifications over reflected inputs. The production
# boundary still requires the original checked book and authenticated modules.
def p113ft_scalar(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}

def p113ft_box(kind: N_WordKind) -> Bool:
  match kind:
    case N_Box{}: True{}
    case _: False{}

@unsafe
def p113ft_row(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

@unsafe
def p113ft_op(+name: String, +arity: U32) -> Bool:
  p113ft_scalar(p113_value_kind([],kt("NOp",name,0,0,nc_prim_args(arity,0)),[]))

def p113ft_type(name: String) -> KTerm:
  kt("ADT",name,0,0,[])

def p113ft_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,atom("Data"),atom("Absent"),[],builtin,False{}}

@unsafe
def p113ft_book(+result: KTerm, builtin: Bool) -> List<&2,KDef>:
  [p113ft_owner("U32",builtin),p113ft_owner("F32",True{}),p113ft_owner("Bool",True{}),p113ft_owner("Char",True{}),
   KDef{"probe","Def",1,0,kt("All","x",7,1,[p113ft_type("U32"),result]),k_lam("x",7,1,[var("",7)],0,0,False{}),[],False{},False{}}]

@unsafe
def p113ft_call(+book: List<&2,KDef>, +arity: U32, +mode: U32) -> Bool:
  p113ft_scalar(p113_value_kind(book,nd_reapply(kt("Ref","probe",0,mode,[]),nc_prim_args(arity,0)),[]))

@unsafe
def p113ft_native(+builtin: Bool, +arity: U32, +mode: U32) -> Bool:
  +d : KDef = KDef{"U32.add","Def",2,0,
    kt("All","x",1,1,[p113ft_type("U32"),kt("All","y",2,1,[p113ft_type("U32"),p113ft_type("String")])]),
    k_lam("x",1,1,[k_lam("y",2,1,[var("",1)],0,0,False{})],0,0,False{}),[],builtin,False{}}
  p113ft_scalar(p113_value_kind([p113ft_owner("U32",True{}),d],nd_reapply(kt("Ref","U32.add",0,mode,[]),nc_prim_args(arity,0)),[]))

@unsafe
def p113ft_zero() -> Bool:
  +d : KDef = KDef{"constant","Def",0,0,p113ft_type("Bool"),kt("NWord","1",0,0,[]),[],False{},False{}}
  p113ft_scalar(p113_value_kind([p113ft_owner("Bool",True{}),d],kt("Ref","constant",0,0,[]),[]))

@unsafe
def p113ft_foreign() -> Bool:
  +d : KDef = KDef{"probe","Def",1,0,kt("All","x",7,1,[p113ft_type("U32"),p113ft_type("U32")]),atom("Foreign"),[],False{},False{}}
  p113ft_call([p113ft_owner("U32",True{}),d],1,0)

@unsafe
def p113ft_keep(+value: KTerm) -> U32:
  nt_count(N111Stmt,p111_keep([p113_binding([],9,value,[])],nu_add(NU_Empty{},9)))

def p113ft_drop_count(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)

@unsafe
def p113ft_drop(+value: KTerm) -> U32:
  p113ft_drop_count(p111_partition([p113_binding([],9,value,[])],NU_Empty{}))

def p113ft_binding_shape(binding: NC_Binding) -> Bool:
  match binding:
    case NC_Binding{id,word,kind}: U32.is_eq(id,9) && String.eq(word,"v_9") && p113ft_scalar(kind)

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
