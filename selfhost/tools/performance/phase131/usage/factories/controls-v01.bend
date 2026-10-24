@unsafe
def p131cf_word(n: U32) -> KTerm:
  kt("NWord",U32.show(n),0,0,[])

@unsafe
def p131cf_def(name: String, body: KTerm) -> KDef:
  KDef{name,"Def",0,0,atom("Absent"),body,[],False{},False{}}

@unsafe
def p131cf_fact(d: KDef) -> KDef:
  KDef{dn(d),"NativeErasedBody",0,1,atom("Absent"),dv(d),[],False{},False{}}

@unsafe
def p131cf_facts(defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: []
    case Con{d,rest}: Con{p131cf_fact(d),p131cf_facts(rest)}

@unsafe
def p131cf_test_book() -> List<&2,KDef>:
  +defs = [
    p131cf_def("make",k_lam("x",7,2,[kt("Ctr","Packet",0,0,[var("",7),p131cf_word(9)])],0,0,True{})),
    p131cf_def("nested",app(ref("make"),p131cf_word(4))),
    p131cf_def("dup",k_lam("x",7,2,[kt("Ctr","Packet",0,0,[var("",7),var("",7)])],0,0,True{})),
    p131cf_def("drop",k_lam("x",7,2,[kt("Ctr","Packet",0,0,[p131cf_word(0),p131cf_word(0)])],0,0,True{})),
    p131cf_def("cycle",ref("cycle")),
    p131cf_def("effect",kt("NOp","u32_add",0,0,[p131cf_word(1),p131cf_word(2)])),
    p131cf_def("foreign",kt("Foreign","",0,0,[]))]
  ns_attach_book(book_cached(defs,0),p131cf_facts(defs),0,[])

@unsafe
def p131cf_test_ctors() -> KDef:
  ns_ctor_index([N_Constructor{"Packet",2,False{}}],missing())

@unsafe
def p131cf_equal(result: P131CFResult, expected: KTerm) -> Bool:
  match result:
    case P131CFValue{value}: norm_exact(value,expected)
    case P131CFRefused{}: False{}

@unsafe
def p131cf_refused(result: P131CFResult) -> Bool:
  match result:
    case P131CFValue{value}: False{}
    case P131CFRefused{}: True{}

@unsafe
def p131cf_row(name: String, valid: Bool) -> String:
  match valid:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"

@unsafe
def p131cf_controls() -> List<&2,String>:
  +book = p131cf_test_book()
  +ctors = p131cf_test_ctors()
  +word = p131cf_word(4)
  +packet = kt("Ctr","Packet",0,0,[word,p131cf_word(9)])
  [p131cf_row("closed-two-hop",p131cf_equal(p131cf_eval(book,ctors,ref("nested"),4),packet)),
   p131cf_row("saturated-parameter",p131cf_equal(p131cf_eval(book,ctors,app(ref("make"),word),4),packet)),
   p131cf_row("closed-duplicate",p131cf_equal(p131cf_eval(book,ctors,app(ref("dup"),word),4),kt("Ctr","Packet",0,0,[word,word]))),
   p131cf_row("open-actual-refused",p131cf_refused(p131cf_eval(book,ctors,app(ref("make"),var("",99)),4))),
   p131cf_row("unused-open-actual-refused",p131cf_refused(p131cf_eval(book,ctors,app(ref("drop"),var("",99)),4))),
   p131cf_row("unknown-actual-refused",p131cf_refused(p131cf_eval(book,ctors,app(ref("drop"),ref("unknown")),4))),
   p131cf_row("partial-refused",p131cf_refused(p131cf_eval(book,ctors,ref("make"),4))),
   p131cf_row("overapplied-refused",p131cf_refused(p131cf_eval(book,ctors,app(app(ref("make"),word),word),4))),
   p131cf_row("cycle-bounded",p131cf_refused(p131cf_eval(book,ctors,ref("cycle"),4))),
   p131cf_row("exhausted-refused",p131cf_refused(p131cf_eval(book,ctors,ref("nested"),0))),
   p131cf_row("primitive-refused",p131cf_refused(p131cf_eval(book,ctors,ref("effect"),4))),
   p131cf_row("foreign-refused",p131cf_refused(p131cf_eval(book,ctors,ref("foreign"),4))),
   p131cf_row("effect-constructor-refused",p131cf_refused(p131cf_eval(book,ctors,kt("Ctr","Emit",0,0,[]),4))),
   p131cf_row("unknown-constructor-refused",p131cf_refused(p131cf_eval(book,ctors,kt("Ctr","Unknown",0,0,[]),4))),
   p131cf_row("wrong-arity-refused",p131cf_refused(p131cf_eval(book,ctors,kt("Ctr","Packet",0,0,[word]),4))),
   p131cf_row("stale-marker-refused",p131cf_refused(p131cf_eval(book,ctors,kt("NStatic","Packet",0,0,[]),4))),
   p131cf_row("noncanonical-word-refused",p131cf_refused(p131cf_eval(book,ctors,kt("NWord","04",0,0,[]),4)))]

# Read-only API discriminator on an actual checked request. No request book,
# prepared image or production emitter is mutated by this probe.
@unsafe
def p131cf_request(request: NR_Request, name: String) -> P131CFResult:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +constructors = p112s_block_effects(ns_ctor_index(nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)),missing()),p111_effects(book,names))
      p131cf_eval(book,constructors,nc_compact(nc_source_body(book,lookup(book,name),0)),4)
