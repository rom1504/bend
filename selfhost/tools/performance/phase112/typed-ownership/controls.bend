# Reflected data controls for facts and ownership insertion. These are not
# certificates for arbitrary caller-supplied books or NC_Binding records.
@unsafe
def p112to_test_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)

def p112to_binding(kind: N_WordKind) -> NC_Binding:
  NC_Binding{7,"v_7",kind}

@unsafe
def p112to_keeps(kind: N_WordKind) -> U32:
  nt_count(N111Stmt,p111_keep([p112to_binding(kind)],nu_add(NU_Empty{},7)))

def p112to_drop_count(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)

@unsafe
def p112to_drops(kind: N_WordKind) -> U32:
  p112to_drop_count(p111_partition([p112to_binding(kind)],NU_Empty{}))

def p112to_binding_scalar(binding: NC_Binding) -> Bool:
  match binding:
    case NC_Binding{id,word,kind}: p112to_nonowning(kind)

def p112to_type(+name: String) -> KTerm:
  kt("ADT",name,0,0,[])

def p112to_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,atom("Data"),atom("Absent"),[],builtin,False{}}

@unsafe
def p112to_canonical(+name: String, builtin: Bool) -> Bool:
  p112to_nonowning(nf_scalar_kind([p112to_owner(name,builtin)],p112to_type(name)))

@unsafe
def p112to_book(+name: String, builtin: Bool) -> List<&2,KDef>:
  [p112to_owner(name,builtin),KDef{"probe","Def",1,0,
    kt("All","x",1,1,[p112to_type(name),p112to_type(name)]),
    k_lam("x",1,1,[var("",1)],0,0,False{}),[],False{},False{}}]

@unsafe
def p112to_seed(+name: String, builtin: Bool, +arity: U32) -> Bool:
  p112to_nonowning(nk_kind(nc_id(10),nk_typed_bindings(nd_entry_params(arity,10),nf_worker_kinds(p112to_book(name,builtin),"probe",arity))))

@unsafe
def p112to_capture_kind() -> Bool:
  p112to_nonowning(nk_kind(7,nc_live_uses([p112to_binding(N_W32{})],nu_add(NU_Empty{},7))))

def p112to_word_load(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{name,N111U64{},symbol,args},Nil{}}: String.eq(symbol,"p111_rt_reg_get")
    case _: False{}

@unsafe
def p112to_control_report() -> List<&2,String>:
  [p112to_test_name("scalar-keep-eliminated",U32.is_eq(p112to_keeps(N_W32{}),0)),
   p112to_test_name("opaque-keep-preserved",U32.is_eq(p112to_keeps(N_W64{}),1)),
   p112to_test_name("boxed-keep-preserved",U32.is_eq(p112to_keeps(N_Box{}),1)),
   p112to_test_name("scalar-sink-eliminated",U32.is_eq(p112to_drops(N_W32{}),0)),
   p112to_test_name("opaque-sink-preserved",U32.is_eq(p112to_drops(N_W64{}),1)),
   p112to_test_name("boxed-sink-preserved",U32.is_eq(p112to_drops(N_Box{}),1)),
   p112to_test_name("scalar-alias",p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W32{})]))),
   p112to_test_name("opaque-alias",Bool.not(p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W64{})])))),
   p112to_test_name("shadowed-id-stays-opaque",Bool.not(p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W64{}),p112to_binding(N_W32{})])))),
   p112to_test_name("different-id-stays-opaque",Bool.not(p112to_binding_scalar(nk_binding(8,var("",9),[p112to_binding(N_W32{})])))),
   p112to_test_name("word-literal",p112to_binding_scalar(nk_binding(8,kt("NWord","4294967295",0,0,[]),[]))),
   p112to_test_name("primitive-result-conservative",Bool.not(p112to_binding_scalar(nk_binding(8,kt("NOp","u32_add",0,0,[]),[])))),
   p112to_test_name("ordinary-call-conservative",Bool.not(p112to_binding_scalar(nk_binding(8,kt("NCall","probe",0,0,[]),[])))),
   p112to_test_name("capture-preserves-kind",p112to_capture_kind()),
   p112to_test_name("machine-parameter-stays-u64",p112to_word_load(p111_params([p112to_binding(N_W32{})],0,0,0))),
   p112to_test_name("canonical-u32",p112to_canonical("U32",True{})),
   p112to_test_name("canonical-f32",p112to_canonical("F32",True{})),
   p112to_test_name("canonical-char",p112to_canonical("Char",True{})),
   p112to_test_name("canonical-bool",p112to_canonical("Bool",True{})),
   p112to_test_name("nat-stays-opaque",Bool.not(p112to_canonical("Nat",True{}))),
   p112to_test_name("lookalike-bool-refused",Bool.not(p112to_canonical("Bool",False{}))),
   p112to_test_name("nonbuiltin-u32-refused",Bool.not(p112to_canonical("U32",False{}))),
   p112to_test_name("typed-parameter-seed",p112to_seed("U32",True{},1)),
   p112to_test_name("typed-bool-seed",p112to_seed("Bool",True{},1)),
   p112to_test_name("wrong-live-arity-conservative",Bool.not(p112to_seed("U32",True{},2))),
   p112to_test_name("typed-nat-conservative",Bool.not(p112to_seed("Nat",True{},1))),
   p112to_test_name("typed-lookalike-conservative",Bool.not(p112to_seed("Bool",False{},1)))]
