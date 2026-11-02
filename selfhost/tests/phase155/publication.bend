# Private Phase155 publication witnesses. No checker/verifier replacement.
# All observed strings serialize every field, including index shape and payloads.
type P155PCanon is Data:
  P155PCanon{+book: List<&2,KDef>, +dirty: Bool}
type P155POutcome is Data:
  P155POutcome{+book: List<&2,KDef>, +error: String}

@unsafe
def p155p_width(text: String) -> U32:
  match text:
    case SNil{}: 0
    case SCon{head,rest}: U32.inc(p155p_width(rest))

@unsafe
def p155p_string(+text: String) -> String:
  U32.show(p155p_width(text)) ++ ":" ++ text

def p155p_bool(value: Bool) -> String:
  match value:
    case True{}: "1"
    case False{}: "0"

@unsafe
def p155p_strings(values: List<&2,String>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p155p_string(head) ++ p155p_strings(rest)

@unsafe
def p155p_term(value: KTerm) -> String:
  match value:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}:
      "T" ++ p155p_string(tag) ++ p155p_string(name) ++ U32.show(id) ++ "," ++ U32.show(quant) ++ "," ++
        U32.show(begin) ++ "," ++ U32.show(end) ++ ";" ++ p155p_terms(kids) ++ p155p_strings(removed)
    case KLambda{name,id,quant,kids,removed,begin,end,present}:
      "L" ++ p155p_string(name) ++ U32.show(id) ++ "," ++ U32.show(quant) ++ "," ++
        U32.show(begin) ++ "," ++ U32.show(end) ++ ";" ++ p155p_bool(present) ++ p155p_terms(kids) ++ p155p_strings(removed)
    case KLiteral{kind,number,text,begin,end}:
      "V" ++ p155p_string(kind) ++ U32.show(number) ++ "," ++ p155p_string(text) ++ U32.show(begin) ++ "," ++ U32.show(end) ++ ";"

@unsafe
def p155p_terms(values: List<&2,KTerm>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p155p_term(head) ++ p155p_terms(rest)

@unsafe
def p155p_def(value: KDef) -> String:
  match value:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      "D" ++ p155p_string(name) ++ p155p_string(kind) ++ U32.show(arity) ++ "," ++ U32.show(templates) ++ ";" ++
        p155p_term(typ) ++ p155p_term(value) ++ p155p_defs(ctors) ++ p155p_bool(native) ++ p155p_bool(unsafe)
    case KIndexLeaf{hash,bucket}: "F" ++ U32.show(hash) ++ ";" ++ p155p_defs(bucket)
    case KIndexNode{hash,mask,left,right}: "N" ++ U32.show(hash) ++ "," ++ U32.show(mask) ++ ";" ++ p155p_def(left) ++ p155p_def(right)

@unsafe
def p155p_defs(values: List<&2,KDef>) -> String:
  match values:
    case Nil{}: "]"
    case Con{head,rest}: p155p_def(head) ++ p155p_defs(rest)

def p155p_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

@unsafe
def p155p_function(name: String, +version: U32) -> KDef:
  KDef{name,"Def",0,0,typ(1),KTerm{"Typ","",0,0,[qua(0)],[],version,U32.inc(version)},[],False{},False{}}

@unsafe
def p155p_ctor(name: String, owner: String) -> KDef:
  KDef{name,"Ctr",0,0,ref(owner),p155p_absent(),[],False{},False{}}

@unsafe
def p155p_adt(+name: String, ctor: String) -> KDef:
  KDef{name,"ADT",0,0,typ(1),p155p_absent(),[p155p_ctor(ctor,name)],False{},False{}}

@unsafe
def p155p_events(n: U32) -> List<&2,KDef>:
  match n:
    case 0: []
    case +i:
      Con{p155p_adt("Type" ++ U32.show(i),"Ctor" ++ U32.show(i)),
        Con{p155p_function("body" ++ U32.show(i),i),p155p_events(U32.sub(i,1))}}

# 05: private provenance bit. Clean is established by check_declarations or by
# the exact original canonicalization+book_put path; logging alone makes dirty.
# All exits still call the independent original p143cp_canon.
@unsafe
def p155p_put(state: P155PCanon, +definition: KDef) -> P155PCanon:
  match state:
    case P155PCanon{+book,+dirty}: p155p_put_book(book,dirty,definition)

@unsafe
def p155p_put_book(+book: List<&2,KDef>, +dirty: Bool, +definition: KDef) -> P155PCanon:
  match book:
    case Nil{}: P155PCanon{book_put(book,definition),False{}}
    case Con{+cache,+rest}:
      kc(P155PCanon,p88_string_eq(dk(cache),"BookCache") && p143cp_childless(definition) &&
        p143cp_childless(index_lookup(cache,dn(definition))),
        u => P155PCanon{p143cp_logged(cache,rest,definition),True{}},
        u => P155PCanon{book_put(kc(List<&2,KDef>,dirty,u => p143cp_canon(book),u => book),definition),False{}})

@unsafe
def p155p_replay(state: P155PCanon, updates: List<&2,KDef>) -> List<&2,KDef>:
  match updates:
    case Nil{}: p155p_finish(state)
    case Con{head,rest}: p155p_replay(p155p_put(state,head),rest)

@unsafe
def p155p_finish(state: P155PCanon) -> List<&2,KDef>:
  match state:
    case P155PCanon{book,dirty}: p143cp_canon(book)

# Realistic exposure: ADT runs between ordinary Def runs. An alternating-only
# stream would become dirty before every ADT and correctly show little benefit.
@unsafe
def p155p_types(n: U32) -> List<&2,KDef>:
  match n:
    case 0: []
    case +i: Con{p155p_adt("Type" ++ U32.show(i),"Ctor" ++ U32.show(i)),p155p_types(U32.sub(i,1))}

@unsafe
def p155p_bodies(n: U32) -> List<&2,KDef>:
  match n:
    case 0: []
    case +i: Con{p155p_function("body" ++ U32.show(i),i),p155p_bodies(U32.sub(i,1))}

@unsafe
def p155p_updates(+n: U32) -> List<&2,KDef>:
  List.append(&2,KDef,p155p_bodies(n),p155p_types(n))

@unsafe
def p155p_05_old(+n: U32) -> String:
  +updates = p155p_updates(n)
  p155p_defs(p143cp_replay(check_declarations(updates,book_cached([],0)),updates,True{}))

@unsafe
def p155p_05_new(+n: U32) -> String:
  +updates = p155p_updates(n)
  p155p_defs(p155p_replay(P155PCanon{check_declarations(updates,book_cached([],0)),False{}},updates))

# 06: only declaration installation is batched, never the dependent checking
# loop. Existing book_put_many retains malformed/cache-event fallback semantics.
@unsafe
def p155p_declared(events: List<&2,KDef>) -> List<&2,KDef>:
  match events:
    case Nil{}: []
    case Con{+head,rest}: Con{kc(KDef,p98_tag_eq(dv(head),"Foreign"),u => head,u => declared(head)),p155p_declared(rest)}

@unsafe
def p155p_declarations(events: List<&2,KDef>, done: List<&2,KDef>) -> List<&2,KDef>:
  book_put_many(done,p155p_declared(events))

@unsafe
def p155p_06_old(+n: U32) -> String:
  p155p_defs(check_declarations(p155p_events(n),book_cached([p155p_function("Base.seed",0)],0)))

@unsafe
def p155p_06_new(+n: U32) -> String:
  p155p_defs(p155p_declarations(p155p_events(n),book_cached([p155p_function("Base.seed",0)],0)))

# 07: constructor metadata belongs to successful append-only event history,
# not the replaceable checker world. Only successful events update this index.
@unsafe
def p155p_ctor_index(ctors: List<&2,KDef>, +index: KDef) -> KDef:
  match ctors:
    case Nil{}: index
    case Con{+head,rest}: p155p_ctor_index(rest,index_set(index,head,index_hash(dn(head),2166136261),32))

@unsafe
def p155p_ctor_error(+index: KDef, ctors: List<&2,KDef>, +local: List<&2,String>) -> String:
  match ctors:
    case Nil{}: ""
    case Con{+head,rest}:
      kc(String,has_name(local,dn(head)) || Bool.not(p88_string_eq(dk(index_find(index,dn(head),index_hash(dn(head),2166136261),32)),"Absent")),
        u => "duplicate constructor name",u => p155p_ctor_error(index,rest,Con{dn(head),local}))

@unsafe
def p155p_ctor_walk(events: List<&2,KDef>, +seen: List<&2,KDef>, +index: KDef, +cached: Bool) -> P155POutcome:
  match events:
    case Nil{}: P155POutcome{seen,""}
    case Con{+head,rest}:
      p155p_ctor_next(rest,seen,index,cached,head,kc(String,cached,
        u => p155p_ctor_error(index,dc(head),[]),u => constructor_names(seen,dc(head),[])))

@unsafe
def p155p_ctor_next(rest: List<&2,KDef>, +seen: List<&2,KDef>, +index: KDef, +cached: Bool, +head: KDef, +error: String) -> P155POutcome:
  kc(P155POutcome,String.is_empty(error),
    u => p155p_ctor_walk(rest,book_put(seen,head),kc(KDef,cached,u => p155p_ctor_index(dc(head),index),u => index),cached),
    u => P155POutcome{seen,dn(head) ++ ": " ++ error})

@unsafe
def p155p_ctor_events(+n: U32) -> List<&2,KDef>:
  List.append(&2,KDef,p155p_types(n),kc(List<&2,KDef>,U32.is_eq(U32.and(n,1),1),
    u => [p155p_adt("Duplicate","Ctor1")],u => []))

@unsafe
def p155p_outcome(result: P155POutcome) -> String:
  match result:
    case P155POutcome{book,error}: p155p_string(error) ++ p155p_defs(book)

@unsafe
def p155p_ctor_control(+events: List<&2,KDef>) -> Bool:
  String.eq(p155p_outcome(p155p_ctor_walk(events,book_cached([],0),missing(),False{})),
    p155p_outcome(p155p_ctor_walk(events,book_cached([],0),missing(),True{})))

@unsafe
def p155p_07_old(+n: U32) -> String:
  p155p_outcome(p155p_ctor_walk(p155p_ctor_events(n),book_cached([],0),missing(),False{}))

@unsafe
def p155p_07_new(+n: U32) -> String:
  p155p_outcome(p155p_ctor_walk(p155p_ctor_events(n),book_cached([],0),missing(),True{}))

# Complete structure controls for arbitrary finite prefixes, collisions, empty
# names, childful Def transitions, Foreign and duplicate declarations.
@unsafe
def p155p_equal_replay(+seed: List<&2,KDef>, +updates: List<&2,KDef>) -> Bool:
  String.eq(p155p_defs(p143cp_replay(seed,updates,True{})),
    p155p_defs(p155p_replay(P155PCanon{seed,False{}},updates)))

@unsafe
def p155p_prefixes(+seed: List<&2,KDef>, updates: List<&2,KDef>, +prefix: List<&2,KDef>) -> Bool:
  match updates:
    case Nil{}: p155p_equal_replay(seed,prefix)
    case Con{head,rest}: p155p_equal_replay(seed,prefix) &&
      p155p_prefixes(seed,rest,List.append(&2,KDef,prefix,[head]))

@unsafe
def p155p_controls(+n: U32) -> String:
  +a = p155p_function("costarring",0)
  +b = p155p_function("liquid",1)
  +foreign : KDef = KDef{"foreign","Def",0,0,typ(1),KTerm{"Foreign","ffi",0,0,[],[],0,0},[],True{},False{}}
  +childful : KDef = KDef{"costarring","Def",0,0,typ(1),typ(0),[b],False{},False{}}
  +events : List<&2,KDef> = [a,b,p155p_function("",0),childful,foreign,a,p155p_function("",1)]
  +seed = check_declarations(events,book_cached([],0))
  +within : KDef = KDef{"Within","ADT",0,0,typ(1),p155p_absent(),[p155p_ctor("X","Within"),p155p_ctor("X","Within")],False{},False{}}
  p155p_bool(p155p_prefixes(seed,events,[]) &&
    String.eq(p155p_defs(check_declarations(events,book_cached([],0))),p155p_defs(p155p_declarations(events,book_cached([],0)))) &&
    p155p_ctor_control([p155p_adt("A","costarring"),p155p_adt("B","liquid"),p155p_adt("C","costarring")]) &&
    p155p_ctor_control([p155p_adt("A",""),p155p_adt("B","")]) && p155p_ctor_control([within,p155p_adt("Later","X")]) &&
    String.eq(p155p_05_old(n),p155p_05_new(n)) && String.eq(p155p_06_old(n),p155p_06_new(n)) &&
    String.eq(p155p_07_old(n),p155p_07_new(n)))

# Executable counterexample: blindly logging a replaced ADT retains a stale
# constructor visible to constructor_exists even after authoritative lookup changed.
@unsafe
def p155p_stale_adt(+n: U32) -> String:
  +old = p155p_adt("A","Old")
  +next = p155p_adt("A","New")
  +seed = book_cached([old],n)
  p155p_stale_cache(seed,next)

@unsafe
def p155p_stale_cache(+seed: List<&2,KDef>, +next: KDef) -> String:
  match seed:
    case Nil{}: "invalid fixture"
    case Con{cache,rest}:
      p155p_bool(constructor_exists(book_put(seed,next),"Old")) ++ ":" ++
        p155p_bool(constructor_exists(p143cp_logged(cache,rest,next),"Old"))

# Initial declarations expose types, not completed bodies. Delaying a successful
# publication therefore changes later definitional equality, even without calls.
@unsafe
def p155p_deferred_type(+n: U32) -> String:
  +alias = p155p_function("Alias",0)
  +seed = check_declarations([alias],book_cached([],n))
  p155p_bool(compare(seed,ref("Alias"),typ(0),False{})) ++ ":" ++
    p155p_bool(compare(book_put(seed,alias),ref("Alias"),typ(0),False{}))
