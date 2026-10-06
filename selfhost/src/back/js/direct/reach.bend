# Direct reachability follows emitter-owned JD_REF metadata, like JD_USE for
# local demand. The initial checked/type closure remains available to emission;
# only runtime definitions and their foreign initializers are pruned here.
# This deliberately reuses numeric row pruning, erased arguments, constructor
# folding and dead-let demand rather than maintaining a second expression walk.
type JDReach is Data:
  JDReach{+defs: List<&2,KDef>, +error: String}

@unsafe
def jd_reach_defs(+r: JDReach) -> List<&2,KDef>:
  match r:
    case JDReach{defs, error}: defs

@unsafe
def jd_reach_error(+r: JDReach) -> String:
  match r:
    case JDReach{defs, error}: error

@unsafe
def jd_reach_selected(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>) -> JDReach:
  jd_reach_context(defs, roots, jd_calls_context(jd_selected_context(book, defs), defs))

@unsafe
def jd_reach_context(+defs: List<&2,KDef>, +roots: List<&2,String>, +book: List<&2,KDef>) -> JDReach:
  kc(JDReach, jd_calls_valid(book), u =>
    jd_reach_visit(book, book_cached(jd_reach_names(defs), 0), defs, roots, missing(), jd_definition_budget(), 65536),
    u => JDReach{Nil{}, "direct reachability tail-call analysis refused"})

@unsafe
def jd_reach_names(+defs: List<&2,KDef>) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: Con{KDef{jd_name(dn(d)), "JDReachName", 0, 0, atom("Absent"),
      ref(dn(d)), Nil{}, False{}, False{}}, jd_reach_names(rest)}

# Scan only physical-line metadata emitted by jd_ref. Quoted source strings
# cannot create physical newlines, and jd_name cannot create a comment delimiter.
# A 2,097,152-character scan cap fails closed; no partial graph is accepted.
@unsafe
def jd_reach_refs(+names: List<&2,KDef>, +text: String, +line: Bool, +fuel: U32,
  +out: List<&2,String>) -> Maybe<&2,List<&2,String>>:
  match text:
    case SNil{}: Some{out}
    case SCon{h, rest}: kc(Maybe<&2,List<&2,String>>, U32.is_gt(fuel, 0), u =>
      kc(Maybe<&2,List<&2,String>>, line && String.starts_with(text, "/*JD_REF:"), v =>
        kc(Maybe<&2,List<&2,String>>, U32.is_ge(fuel, 9), w =>
          jd_reach_marker(names, String.drop(text, 9n), "", U32.sub(fuel, 9), out), w => None{}),
        v => jd_reach_refs(names, rest, Char.is_eq(h, '\n'), U32.sub(fuel, 1), out)), u => None{})

@unsafe
def jd_reach_marker(+names: List<&2,KDef>, +text: String, +rev: String, +fuel: U32,
  +out: List<&2,String>) -> Maybe<&2,List<&2,String>>:
  match text:
    case SNil{}: None{}
    case SCon{h, rest}: kc(Maybe<&2,List<&2,String>>, U32.is_gt(fuel, 0), u =>
      kc(Maybe<&2,List<&2,String>>, Char.is_eq(h, '*'), v =>
        kc(Maybe<&2,List<&2,String>>, String.starts_with(rest, "/") && U32.is_ge(fuel, 2), w =>
          jd_reach_marker_done(names, String.drop(rest, 1n), U32.sub(fuel, 2), out,
            lookup(names, String.reverse(rev))), w => None{}),
        v => jd_reach_marker(names, rest, SCon{h, rev}, U32.sub(fuel, 1), out)), u => None{})

@unsafe
def jd_reach_marker_done(+names: List<&2,KDef>, +rest: String, +fuel: U32,
  +out: List<&2,String>, +d: KDef) -> Maybe<&2,List<&2,String>>:
  kc(Maybe<&2,List<&2,String>>, String.eq(dk(d), "JDReachName"), u =>
    jd_reach_refs(names, rest, False{}, fuel, Con{nm(dv(d)), out}), u => None{})

@unsafe
def jd_reach_visit(+book: List<&2,KDef>, +names: List<&2,KDef>, +defs: List<&2,KDef>,
  +todo: List<&2,String>, +seen: KDef, +left: U32, +fuel: U32) -> JDReach:
  match todo:
    case Nil{}: JDReach{jd_reach_filter(defs, seen), ""}
    case Con{name, rest}: kc(JDReach, U32.is_gt(fuel, 0), u =>
      kc(JDReach, String.eq(dk(index_find(seen, name, index_hash(name, 2166136261), 32)), "Absent"), v =>
        kc(JDReach, U32.is_gt(left, 0), w =>
          jd_reach_definition(book, names, defs, rest, seen, U32.sub(left, 1), U32.sub(fuel, 1), lookup(book, name)),
          w => JDReach{Nil{}, "direct reachability definition budget"}),
        v => jd_reach_visit(book, names, defs, rest, seen, left, U32.sub(fuel, 1))),
        u => JDReach{Nil{}, "direct reachability edge budget"})

@unsafe
def jd_reach_definition(+book: List<&2,KDef>, +names: List<&2,KDef>, +defs: List<&2,KDef>,
  +rest: List<&2,String>, +seen: KDef, +left: U32, +fuel: U32, +d: KDef) -> JDReach:
  kc(JDReach, String.eq(dk(d), "Def") && U32.is_eq(dx(d), 0), u =>
    jd_reach_follow(book, names, defs, rest, index_set(seen, d, index_hash(dn(d), 2166136261), 32), left, fuel,
      jd_reach_refs(names, jd_definition(book, d), False{}, 2097152, Nil{})),
    u => JDReach{Nil{}, "direct reachability missing emitted definition"})

@unsafe
def jd_reach_follow(+book: List<&2,KDef>, +names: List<&2,KDef>, +defs: List<&2,KDef>,
  +rest: List<&2,String>, +seen: KDef, +left: U32, +fuel: U32, +refs: Maybe<&2,List<&2,String>>) -> JDReach:
  match refs:
    case None{}: JDReach{Nil{}, "direct reachability metadata refused"}
    case Some{edges}: jd_reach_visit(book, names, defs, List.append(&2,String, edges, rest), seen, left, fuel)

@unsafe
def jd_reach_filter(+defs: List<&2,KDef>, +seen: KDef) -> List<&2,KDef>:
  match defs:
    case Nil{}: Nil{}
    case Con{d, rest}: kc(List<&2,KDef>, Bool.not(String.eq(dk(d), "Def")) ||
      Bool.not(String.eq(dk(index_find(seen, dn(d), index_hash(dn(d), 2166136261), 32)), "Absent")),
      u => Con{d, jd_reach_filter(rest, seen)}, u => jd_reach_filter(rest, seen))
