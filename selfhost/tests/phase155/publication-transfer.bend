# Actual source-order publication/constructor-history replay. Additive only.
# Caller supplies the unchanged FLoadTrace.result.book, including law/fill events.
# The full declaration seed and full suffix schedule are built before any prefix
# limit is applied. No type checking or template/specialization work is simulated.
type P155PTState is Data:
  P155PTState{+canon: P155PCanon, +seen: List<&2,KDef>, +ctors: KDef, +processed: U32}
type P155PTResult is Data:
  P155PTResult{+book: List<&2,KDef>, +seen: List<&2,KDef>, +error: String, +processed: U32, +admitted: Bool}

@unsafe
def p155pt_admitted(events: List<&2,KDef>) -> Bool:
  match events:
    case Nil{}: True{}
    case Con{KDef{name,+kind,arity,templates,typ,value,+ctors,native,unsafe},rest}:
      Bool.not(p88_string_eq(kind,"BookCache")) &&
        (p88_string_eq(kind,"ADT") || defs_empty(ctors)) && p155pt_admitted(rest)
    case Con{other,rest}: False{}

@unsafe
def p155pt_finish(state: P155PTState, error: String, admitted: Bool) -> P155PTResult:
  match state:
    case P155PTState{canon,seen,ctors,processed}:
      P155PTResult{p155p_finish(canon),seen,error,processed,admitted}

@unsafe
def p155pt_publish(canon: P155PCanon, +definition: KDef, +next: KDef, +compact: Bool) -> P155PCanon:
  match canon:
    case P155PCanon{+book,+dirty}:
      kc(P155PCanon,p88_string_eq(dk(next),"Absent"),
        u => kc(P155PCanon,compact,
          u => p155p_put(P155PCanon{book,dirty},definition),
          u => P155PCanon{p143cp_put_log(book,definition),True{}}),
        u => P155PCanon{book,dirty})

@unsafe
def p155pt_error(+definition: KDef, +old: KDef, +seen: List<&2,KDef>, +ctors: KDef, cached: Bool) -> String:
  kc(String,cached && p88_string_eq(dk(old),"Absent") && p88_string_eq(dk(definition),"ADT"),
    u => p155p_ctor_error(ctors,dc(definition),[]),u => event_error(seen,definition,old))

@unsafe
def p155pt_next(rest: List<&2,P143CEvent>, +definition: KDef, next: KDef, state: P155PTState,
    left: U32, +compact: Bool, +cached: Bool, +error: String) -> P155PTResult:
  match state:
    case P155PTState{+canon,+seen,+ctors,+processed}:
      kc(P155PTResult,String.is_empty(error),
        u => p155pt_walk(rest,P155PTState{p155pt_publish(canon,definition,next,compact),book_put(seen,definition),
          kc(KDef,cached && p88_string_eq(dk(definition),"ADT"),u => p155p_ctor_index(dc(definition),ctors),u => ctors),U32.inc(processed)},
          U32.sub(left,1),compact,cached),
        u => p155pt_finish(P155PTState{canon,seen,ctors,processed},dn(definition) ++ ": " ++ error,True{}))

@unsafe
def p155pt_walk(events: List<&2,P143CEvent>, +state: P155PTState, +left: U32, +compact: Bool, +cached: Bool) -> P155PTResult:
  match events state left:
    case Nil{} saved _: p155pt_finish(saved,"",True{})
    case _ saved 0: p155pt_finish(saved,"",True{})
    case Con{P143CEvent{+definition,next},rest} P155PTState{canon,+seen,+ctors,processed} n:
      p155pt_next(rest,definition,next,P155PTState{canon,seen,ctors,processed},n,compact,cached,
        p155pt_error(definition,lookup(seen,dn(definition)),seen,ctors,cached))

@unsafe
def p155pt_run(+events: List<&2,KDef>, +limit: U32, +compact: Bool, +cached: Bool) -> P155PTResult:
  kc(P155PTResult,p155pt_admitted(events),
    u => p155pt_walk(p143cs_plan(events),P155PTState{
      P155PCanon{check_declarations(events,book_cached([],0)),False{}},book_cached([],0),missing(),0},limit,compact,cached),
    u => P155PTResult{[],[],"publication transfer: unsupported cache/index event or childful non-ADT",0,False{}})

@unsafe
def p155pt_text(result: P155PTResult) -> String:
  match result:
    case P155PTResult{book,seen,error,processed,admitted}:
      p155p_bool(admitted) ++ U32.show(processed) ++ ";" ++ p155p_string(error) ++ p155p_defs(book) ++ p155p_defs(seen)

@unsafe
def p155pt_05_raw_old(+events: List<&2,KDef>, limit: U32) -> P155PTResult:
  p155pt_run(events,limit,False{},False{})

@unsafe
def p155pt_05_raw_new(+events: List<&2,KDef>, limit: U32) -> P155PTResult:
  p155pt_run(events,limit,True{},False{})

@unsafe
def p155pt_07_raw_old(+events: List<&2,KDef>, limit: U32) -> P155PTResult:
  p155pt_run(events,limit,False{},False{})

@unsafe
def p155pt_07_raw_new(+events: List<&2,KDef>, limit: U32) -> P155PTResult:
  p155pt_run(events,limit,False{},True{})

@unsafe
def p155pt_05_old(+events: List<&2,KDef>, limit: U32) -> String:
  p155pt_text(p155pt_05_raw_old(events,limit))

@unsafe
def p155pt_05_new(+events: List<&2,KDef>, limit: U32) -> String:
  p155pt_text(p155pt_05_raw_new(events,limit))

@unsafe
def p155pt_07_old(+events: List<&2,KDef>, limit: U32) -> String:
  p155pt_text(p155pt_07_raw_old(events,limit))

@unsafe
def p155pt_07_new(+events: List<&2,KDef>, limit: U32) -> String:
  p155pt_text(p155pt_07_raw_new(events,limit))

# Both independent prefix failures keep the actual current book and seen history.
# This list is a finite admission/error control; transfer workloads come from files.
@unsafe
def p155pt_controls(+limit: U32) -> String:
  +events : List<&2,KDef> = [p155p_function("before",0),p155p_adt("A","Ctor"),
    p155p_function("middle",1),p155p_adt("B","Ctor"),p155p_function("unreached",2)]
  +old = p155pt_05_old(events,limit)
  p155p_bool(String.eq(old,p155pt_05_new(events,limit)) && String.eq(old,p155pt_07_new(events,limit)))
