# Append the unchanged phase140/checker/equality-v02.bend observer before this
# test module. Equality observes complete worlds, indexes, errors and diagnostics.

@unsafe
def p143cc_schedule(todo: List<&2,KDef>, events: List<&2,P143CEvent>) -> Bool:
  match todo events:
    case Nil{} Nil{}: True{}
    case Con{+definition,+rest} Con{P143CEvent{planned,next},more}:
      p140eq_def(definition,planned) && p140eq_def(lookup(rest,dn(definition)),next) &&
        p143cc_schedule(rest,more)
    case _ _: False{}

def p143cc_def(name: String, value: KTerm) -> KDef:
  KDef{name,"Def",0,0,typ(1),value,[],False{},False{}}

@unsafe
def p143cc_parse(text: String) -> FResult:
  f_load_graph("Unit",[FSource{"Unit","/phase143-checker.bend",text}])

@unsafe
def p143cc_text(text: String) -> Bool:
  p143cc_parsed(p143cc_parse(text))

@unsafe
def p143cc_parsed(parsed: FResult) -> Bool:
  match parsed:
    case FResult{+book,error,imports}:
      String.is_empty(error) && p143cc_book(book)

@unsafe
def p143cc_book(+book: List<&2,KDef>) -> Bool:
  p143cc_schedule(book,p143cs_plan(book)) &&
    p140ce_checked(p143cp_check(book,False{}),dg_check_world(book)) &&
    p140ce_checked(p143cp_check(book,True{}),dg_check_world(book))

@unsafe
def p143cc_replay(+updates: List<&2,KDef>) -> Bool:
  +seed = book_cached([],0)
  +book = check_declarations(updates,seed)
  p140eq_list(p143cp_replay(book,updates,True{}),p143cp_replay(book,updates,False{}))

@unsafe
def p143cc_definitions(count: U32) -> List<&2,KDef>:
  match count:
    case 0: []
    case n: Con{p143cc_def("decl" ++ U32.show(n),typ(0)),p143cc_definitions(U32.sub(n,1))}

@unsafe
def p143cc_expected(parsed: FResult, +success: Bool) -> Bool:
  match parsed:
    case FResult{+book,error,imports}:
      String.is_empty(error) && p143cc_checked_status(dg_check_world(book),success) && p143cc_book(book)

def p143cc_checked_status(checked: DChecking, success: Bool) -> Bool:
  match checked:
    case DChecking{result,diagnostic}: p134v_bool(String.is_empty(ce(result)),success)

@unsafe
def p143cc_many_text(count: U32) -> String:
  match count:
    case 0: ""
    case n: "def keep" ++ U32.show(n) ++ "() -> Bit:\n  Off{}\n" ++ p143cc_many_text(U32.sub(n,1))

@unsafe
def p143cc_many(count: U32) -> FResult:
  p143cc_parse("type Bit is Data:\n  Off{}\n" ++ p143cc_many_text(count))

@unsafe
def p143cc_controls() -> List<&2,String>:
  +a = p143cc_def("a",typ(0))
  +b = p143cc_def("b",typ(0))
  +collision = [p143cc_def("costarring",typ(0)),p143cc_def("liquid",typ(0)),a,b,a]
  [p131u_row(p143cc_schedule([],p143cs_plan([])),"suffix-empty"),
   p131u_row(p143cc_schedule([a,b,a],p143cs_plan([a,b,a])),"suffix-first-later-duplicate"),
   p131u_row(p143cc_schedule([a,p143cc_def("a",typ(1)),p143cc_def("a",typ(2))],
     p143cs_plan([a,p143cc_def("a",typ(1)),p143cc_def("a",typ(2))])),"suffix-first-not-last-payload"),
   p131u_row(p143cc_schedule(collision,p143cs_plan(collision)),"suffix-real-hash-collision"),
   p131u_row(p143cc_schedule(Con{a,List.append(&2,KDef,book_cached([b],0),[a])},
     p143cs_plan(Con{a,List.append(&2,KDef,book_cached([b],0),[a])})),"suffix-bookcache-barrier"),
   p131u_row(p143cc_replay([a,b,a]),"publication-order-and-duplicate"),
   p131u_row(p143cc_replay(collision),"publication-full-collision-index"),
   p131u_row(p143cc_replay([p143cc_def("",typ(0)),a,p143cc_def("",typ(1))]),"publication-empty-name"),
   p131u_row(p143cc_replay(p143cc_definitions(300)),"publication-large-canonicalization-branch"),
   p131u_row(p143cc_replay([a,KDef{"a","Def",0,0,typ(1),typ(0),[b],False{},False{}},b]),"publication-childful-fallback"),
   p131u_row(p143cc_text("type Bit is Data:\n  Off{}\n  Onn{}\ndef keep() -> Bit:\n  Off{}\ndef edit() -> Bit:\n  Onn{}\n"),"checker-valid-complete-world"),
   p131u_row(p143cc_text("type Bit is Data:\n  Off{}\ndef keep() -> Bit:\n  Bit\n"),"checker-type-error-complete-world"),
   p131u_row(p143cc_text("type Bit is Data:\n  Off{}\ndef keep() -> Bit:\n  Other{}\n"),"checker-constructor-diagnostic"),
   p131u_row(p143cc_book([a,b,a]),"checker-duplicate-definition-error"),
   p131u_row(p143cc_book([p143cc_def("a",KTerm{"Absent","",0,0,[],[],0,0}),b,a]),"checker-law-fill-state"),
   p131u_row(p143cc_book(collision),"checker-collision-and-duplicate-error"),
   p131u_row(p140ce_checked(p143cp_seed([],4294967295,True{}),dg_check_seed([],4294967295)),"checker-deferred-fresh-empty-world"),
   p131u_row(p140ce_checked(p143cp_seed(book_cached([a],0),0,True{}),dg_check_seed(book_cached([a],0),0)),"checker-cache-event-fallback"),
   p131u_row(p143cc_expected(p143cc_parse("type Bit is Data:\n  Off{}\ndef early() -> Bit:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Bit:\n  ident(~Bit, Off{})\n"),True{}),"checker-template-success-and-rollback"),
   p131u_row(p143cc_expected(p143cc_parse("type Bit is Data:\n  Off{}\ndef early() -> Bit:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Bit:\n  ident(~Bit, Off{})\ndef bad() -> Bit:\n  Bit\n"),False{}),"checker-failure-after-template-instantiation")]
