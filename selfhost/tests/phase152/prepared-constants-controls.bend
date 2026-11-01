# Finite compiler-data controls only; malformed graphs are never native targets.
# Retain the incumbent 19 selector admission controls as an unchanged prefix.
@unsafe
def p152t_ctors() -> KDef:
  p112s_ctors([N_Constructor{"Unit",0,False{}},N_Constructor{"Sentinel",0,False{}},
    N_Constructor{"$ctor.Box",1,False{}},N_Constructor{"Zero",0,False{}},
    N_Constructor{"True",0,False{}},N_Constructor{"Emit",0,False{}},N_Constructor{"Done",0,False{}}],0,missing())

@unsafe
def p152t_ctor(name: String, id: U32, arity: U32) -> KDef:
  index_build([KDef{name,"P112StaticCtor",id,arity,atom("Absent"),atom("Absent"),[],False{},False{}}])

@unsafe
def p152t_marker(name: String) -> KTerm:
  kt("NStatic",name,0,1,[])

@unsafe
def p152t_source(unit: KTerm) -> KTerm:
  k_lam("v",1,1,[k_lam("tail",2,1,[
    kt("Mat","LT",1,0,[app(var("",2),unit),
      kt("Mat","EQ",1,0,[var("",1),
        kt("Mat","GT",1,0,[kl_make("U32",0,""),atom("Efq")])])])],0,0,False{})],0,0,False{})

@unsafe
def p152t_args() -> List<&2,KTerm>:
  [kl_make("U32",7,""),k_lam("u",8,1,[kl_make("U32",9,"")],0,0,False{}),kt("Ctr","EQ",0,0,[])]

@unsafe
def p152t_term(result: P112STerm) -> KTerm:
  match result:
    case P112STerm{term,image}: term

# Use the real static preparation factory for the positive prepared body.
@unsafe
def p152t_prepared(source: KTerm) -> KTerm:
  p152t_term(p112s_term(ns_ctor_index([N_Constructor{"Unit",0,False{}}],missing()),
    nc_compact(source),P112SImage{0,[],missing(),""}))

@unsafe
def p152t_fact(source: KTerm, prepared: KTerm, priorName: String) -> KDef:
  KDef{"probe","NativeStaticBody",0,0,atom("Absent"),prepared,
    [KDef{priorName,"NativeErasedBody",0,0,atom("Absent"),source,[],False{},False{}}],False{},False{}}

@unsafe
def p152t_book(fact: KDef, constructors: KDef, image: String) -> List<&2,KDef>:
  [KDef{"cache","BookCache",0,0,atom("Absent"),atom("Absent"),[missing(),
    KDef{"$native.static","NativeStaticContext",0,0,kt(image,"",0,0,[]),atom("Absent"),
      [index_build([fact]),missing(),constructors,missing()],False{},False{}}],False{},False{}}]

@unsafe
def p152t_definition(source: KTerm, native: Bool) -> KDef:
  KDef{"probe","Def",0,0,atom("Absent"),source,[],native,False{}}

@unsafe
def p152t_has_static(terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: False{}
    case Con{+head,rest}: p98_tag_eq(head,"NStatic") || p152t_has_static(ks(head)) || p152t_has_static(rest)

@unsafe
def p152t_fallback(+book: List<&2,KDef>, +source: KTerm, fact: KDef) -> Bool:
  +result = p152c_fact(book,"probe",source,fact)
  Bool.not(p152t_has_static([result])) && p152c_pair(p152t_ctors(),source,result)

@unsafe
def p152t_dropped(parts: P111Partition) -> Bool:
  match parts:
    case P111Partition{Nil{},Nil{}}: True{}
    case _: False{}

@unsafe
def p152t_word(result: P111ValueCode) -> Bool:
  match result:
    case P111ValueCode{Nil{},N111Const{lo,hi},error}:
      U32.is_eq(lo,0) && U32.is_eq(hi,16777216) && String.is_empty(error)
    case _: False{}

@unsafe
def p152t_deep(+left: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(left,0),u => atom("Efq"),u => k_lam("x",left,1,[p152t_deep(U32.sub(left,1))],0,0,False{}))

@unsafe
def p152t_nullary_controls() -> List<&2,String>:
  +ctors = p152t_ctors()
  +unit = p152t_marker("Unit")
  [p131sc_row("prepared-unit-nullary",p152c_nullary(ctors,unit)),
   p131sc_row("prepared-arbitrary-nullary",p152c_nullary(ctors,p152t_marker("Sentinel"))),
   p131sc_row("prepared-cid-max",p152c_nullary(p152t_ctor("Unit",65535,0),unit)),
   p131sc_row("prepared-cid-overflow-refused",Bool.not(p152c_nullary(p152t_ctor("Unit",65536,0),unit))),
   p131sc_row("prepared-unknown-refused",Bool.not(p152c_nullary(ctors,p152t_marker("Unknown")))),
   p131sc_row("prepared-one-field-zero-refused",Bool.not(p152c_nullary(ctors,p152t_marker("$ctor.Box")))),
   p131sc_row("prepared-box-refused",Bool.not(p152c_nullary(ctors,kt("NStatic","Unit",0,0,[])))),
   p131sc_row("prepared-payload-refused",Bool.not(p152c_nullary(ctors,kt("NStatic","Unit",1,1,[])))),
   p131sc_row("prepared-child-refused",Bool.not(p152c_nullary(ctors,kt("NStatic","Unit",0,1,[atom("Efq")])))),
   p131sc_row("prepared-quantity-refused",Bool.not(p152c_nullary(ctors,kt("NStatic","Unit",0,2,[])))),
   p131sc_row("prepared-special-nat-refused",Bool.not(p152c_nullary(ctors,p152t_marker("Zero")))),
   p131sc_row("prepared-special-bool-refused",Bool.not(p152c_nullary(ctors,p152t_marker("True")))),
   p131sc_row("prepared-special-emit-refused",Bool.not(p152c_nullary(ctors,p152t_marker("Emit")))),
   p131sc_row("prepared-special-done-refused",Bool.not(p152c_nullary(ctors,p152t_marker("Done")))),
   p131sc_row("prepared-foreign-catalog-refused",Bool.not(p152c_nullary(p112s_block_effects(ctors,["Unit"]),unit)))]

@unsafe
def p152t_correspondence_controls() -> List<&2,String>:
  +ctors = p152t_ctors()
  +unit = kt("Ctr","Unit",0,0,[])
  +marker = p152t_marker("Unit")
  [p131sc_row("prepared-leaf-correspondence",p152c_pair(ctors,unit,marker)),
   p131sc_row("prepared-name-change-refused",Bool.not(p152c_pair(ctors,unit,p152t_marker("Sentinel")))),
   p131sc_row("prepared-source-field-refused",Bool.not(p152c_pair(ctors,kt("Ctr","Unit",0,0,[unit]),marker))),
   p131sc_row("prepared-source-marker-refused",Bool.not(p152c_pair(ctors,marker,marker))),
   p131sc_row("prepared-literal-change-refused",Bool.not(p152c_pair(ctors,kt("NWord","7",0,0,[]),kt("NWord","8",0,0,[])))),
   p131sc_row("prepared-binder-change-refused",Bool.not(p152c_pair(ctors,k_lam("x",1,1,[unit],0,0,False{}),k_lam("x",2,1,[marker],0,0,False{})))),
   p131sc_row("prepared-lambda-quantity-refused",Bool.not(p152c_pair(ctors,k_lam("x",1,1,[unit],0,0,False{}),k_lam("x",1,1,[marker],0,0,True{})))),
   p131sc_row("prepared-span-change-refused",Bool.not(p152c_pair(ctors,kt_span("NWord","7",0,0,[],1,2),kt_span("NWord","7",0,0,[],1,3))))]

@unsafe
def p152t_context_controls() -> List<&2,String>:
  +source = p152t_source(kt("Ctr","Unit",0,0,[]))
  +compact = nc_compact(source)
  +prepared = p152t_prepared(source)
  +fact = p152t_fact(source,prepared,"probe")
  +book = p152t_book(fact,p152t_ctors(),"P112StaticImage")
  +args = p152t_args()
  +expanded = nbc_definition(book,p152t_definition(source,False{}),args,[],100,3)
  +native : KDef = KDef{"U32.add","Def",0,0,atom("Absent"),source,[],True{},False{}}
  [p131sc_row("prepared-factory-correspondence",p152c_pair(p152t_ctors(),compact,prepared)),
   p131sc_row("prepared-expansion-retains-marker",p152t_has_static([expanded])),
   p131sc_row("prepared-expansion-original-order",p152c_pair(p152t_ctors(),nc_compact(p131sc_definition_body(source,args,[],100,3)),nc_compact(expanded))),
   p131sc_row("prepared-no-image-fallback",p152t_fallback([],compact,fact)),
   p131sc_row("prepared-legacy-image-fallback",p152t_fallback(p152t_book(fact,p152t_ctors(),"StaticWords"),compact,fact)),
   p131sc_row("prepared-wrong-prior-fallback",p152t_fallback(book,compact,p152t_fact(source,prepared,"different"))),
   p131sc_row("prepared-different-body-fallback",p152t_fallback(book,compact,p152t_fact(source,kt("NWord","999",0,0,[]),"probe"))),
   p131sc_row("prepared-oversized-fact-fallback",p152t_fallback(book,compact,p152t_fact(source,p152t_deep(33),"probe"))),
   p131sc_row("prepared-freshness-refused",p98_tag_eq(nbc_definition(book,p152t_definition(source,False{}),args,[nc_binding(nc_id(100))],100,3),"Absent")),
   p131sc_row("prepared-native-definition-refused",nc_native_def(native) && p98_tag_eq(nbc_definition(book,native,args,[],100,3),"Absent")),
   p131sc_row("prepared-foreign-definition-refused",p98_tag_eq(nbc_definition(book,p152t_definition(atom("Foreign"),False{}),args,[],100,3),"Absent")),
   p131sc_row("prepared-raw-source-marker-refused",p98_tag_eq(p152c_source(book,"probe",p152t_source(p152t_marker("Unit")),args,[],100,3),"Absent"))]

@unsafe
def p152t_ownership_controls() -> List<&2,String>:
  +source = p152t_source(kt("Ctr","Unit",0,0,[]))
  +fact = p152t_fact(source,p152t_prepared(source),"probe")
  +book = p152t_book(fact,p152t_ctors(),"P112StaticImage")
  +unit = p152t_marker("Unit")
  +binding = p113_binding(book,7,unit,[])
  +alias = p113_binding(book,8,var("",7),[binding])
  [p131sc_row("prepared-binding-full-width",p113n_is_imm(p113_value_kind(book,unit,[]))),
   p131sc_row("prepared-alias-full-width",p113n_is_imm(p113_value_kind(book,var("",8),[alias,binding]))),
   p131sc_row("prepared-owned-alias-preserved",p113ft_box(p113_value_kind(book,var("",9),[NC_Binding{9,"owned",N_Box{}}]))),
   p131sc_row("prepared-alias-shadow-refused",Bool.not(p112to_nonowning(p113_value_kind(book,var("",7),[NC_Binding{7,"opaque",N_W64{}},binding])))),
   p131sc_row("prepared-missing-alias-refused",Bool.not(p112to_nonowning(p113_value_kind(book,var("",9),[])))),
   p131sc_row("prepared-discard-needs-no-sink",p152t_dropped(p111_partition([binding],NU_Empty{}))),
   p131sc_row("prepared-sharing-needs-no-keep",List.is_empty(&2,N111Stmt,p111_keep([binding],nu_add(NU_Empty{},7)))),
   p131sc_row("prepared-word-tag-preserved",p152t_word(p112s_value(book,unit))),
   p131sc_row("prepared-unprepared-stays-owning",Bool.not(p112to_nonowning(p113_value_kind([],unit,[])))),
   p131sc_row("prepared-invalid-payload-stays-owning",Bool.not(p112to_nonowning(p113_value_kind(book,kt("NStatic","Unit",1,1,[]),[])))),
   p131sc_row("prepared-one-field-stays-owning",Bool.not(p112to_nonowning(p113_value_kind(book,p152t_marker("$ctor.Box"),[])))),
   p131sc_row("prepared-ordinary-word-unchanged",p113ft_scalar(p113_value_kind(book,kt("NWord","7",0,0,[]),[])))]

@unsafe
def p152c_controls() -> List<&2,String>:
  List.append(&2,String,p131sc_controls_v02(),List.append(&2,String,p152t_nullary_controls(),
    List.append(&2,String,p152t_correspondence_controls(),List.append(&2,String,p152t_context_controls(),p152t_ownership_controls()))))

@unsafe
def p152t_ok(rows: List<&2,String>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{row,rest}: Bool.not(String.ends_with(row,":FAIL")) && p152t_ok(rest)

@unsafe
def p152c_controls_ok() -> Bool:
  p152t_ok(p152c_controls())
