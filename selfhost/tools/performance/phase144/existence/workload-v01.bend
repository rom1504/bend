# Actual parsed compiler-prefix events, with unchanged prepared Base scope.
# Parsing is outside timing. This is a consumer replay, not captured checking.
@unsafe
def p144cet_parse(seed: P86Seed, +text: String) -> FResult:
  match seed:
    case P86Seed{source,book,fresh,ready,world}:
      +input: FSource = FSource{"Main","/phase144/compiler-prefix.bend",text}
      f_source_body(input,f_source_header(input),book,"",[],0)

@unsafe
def p144cet_seed_seen(seed: P86Seed) -> List<&2,KDef>:
  match seed:
    case P86Seed{source,book,fresh,ready,world}:
      match world:
        case KBasePreparedWorld{state,prefix,final,saved,checked,seen,todos,bound}: seen

# Exact old event guard; only the ADT constructor-name consumer is substituted.
@unsafe
def p144ce_event_error(+done: List<&2,KDef>, +d: KDef, +old: KDef) -> String:
  kc(String,p88_string_eq(dk(old),"Absent"),
    u => kc(String,p88_string_eq(dk(d),"ADT"),u => p144ce_names(done,dc(d),[]),u => ""),
    u => kc(String,p88_string_eq(dk(old),"Def") && p88_string_eq(dk(d),"Def") &&
      p98_tag_eq(dv(old),"Absent") && Bool.not(p98_tag_eq(dv(d),"Absent")),
      v => kc(String,compare(done,dt(old),dt(d),False{}) && U32.is_eq(dx(old),dx(d)),
        w => "",w => "definition does not match prior law signature"),
      v => "duplicate declaration"))

@unsafe
def p144cet_original(events: List<&2,KDef>, +seen: List<&2,KDef>) -> String:
  match events:
    case Nil{}: ""
    case Con{+d,rest}: p144cet_original_next(rest,seen,d,event_error(seen,d,lookup(seen,dn(d))))

@unsafe
def p144cet_original_next(rest: List<&2,KDef>, seen: List<&2,KDef>, +d: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),
    u => p144cet_original(rest,book_put(seen,d)),u => dn(d) ++ ": " ++ error)

@unsafe
def p144cet_indexed(events: List<&2,KDef>, +seen: List<&2,KDef>) -> String:
  match events:
    case Nil{}: ""
    case Con{+d,rest}: p144cet_indexed_next(rest,seen,d,p144ce_event_error(seen,d,lookup(seen,dn(d))))

@unsafe
def p144cet_indexed_next(rest: List<&2,KDef>, seen: List<&2,KDef>, +d: KDef, +error: String) -> String:
  nt_choose(String,String.is_empty(error),
    u => p144cet_indexed(rest,book_put(seen,d)),u => dn(d) ++ ": " ++ error)
