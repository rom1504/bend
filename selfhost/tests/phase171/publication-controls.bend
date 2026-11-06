# Finite observation controls, not a proof and not yet executed.

@unsafe
def p171s_observe(+before: List<&2,KDef>, +after: List<&2,KDef>, names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: U32.is_eq(norm_book_bound(before),norm_book_bound(after))
    case Con{+name,rest}:
      p140r_def(lookup(before,name),lookup(after,name)) &&
      p134v_bool(constructor_exists(before,name),constructor_exists(after,name)) &&
      p171s_observe(before,after,rest)

@unsafe
def p171s_steps(+old: List<&2,KDef>, +fast: List<&2,KDef>, updates: List<&2,KDef>, +names: List<&2,String>) -> Bool:
  match updates:
    case Nil{}: p171s_observe(old,fast,names)
    case Con{+definition,rest}:
      p171s_observe(old,fast,names) &&
      String.eq(event_error(old,definition,lookup(old,dn(definition))),
        event_error(fast,definition,lookup(fast,dn(definition)))) &&
      p171s_steps(book_put(old,definition),p171s_put(fast,definition),rest,names)

@unsafe
def p171s_fixture(name: String, kind: String, value: KTerm, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,atom("Typ"),value,children,False{},False{}}

@unsafe
def p171s_controls() -> List<&2,Bool>:
  +ctor = p171s_fixture("C","Ctr",atom("Absent"),[])
  +adt = p171s_fixture("T","ADT",atom("Absent"),[ctor])
  +declaration = p171s_fixture("f","Def",atom("Absent"),[])
  +fill = p171s_fixture("f","Def",atom("Typ"),[])
  +names : List<&2,String> = ["T","C","f","missing",""]
  +seen = book_cached([declaration,adt],123)
  +raw : List<&2,KDef> = [declaration,adt]
  [p171s_observe(seen,p171s_seed(seen),names),
   p171s_steps(seen,p171s_seed(seen),[fill,adt,declaration,fill],names),
   p171s_steps(raw,p171s_seed(raw),[fill,adt],names),
   p171s_steps(seen,p171s_seed(seen),
     [p171s_fixture("T","Def",atom("Typ"),[]),adt],names),
   p171s_steps(book_cached([],7),p171s_seed(book_cached([],7)),
     [p171s_fixture("","Def",atom("Absent"),[]),p171s_fixture("","Def",atom("Typ"),[])],names)]
