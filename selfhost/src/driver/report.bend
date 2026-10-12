# Transitive promise reporting follows type, constructor-field and body refs.
# Every declaration outside Base contributes to the trust verdict.
law dr_bad_names:
  for +book: List<&2,KDef>
  for names: List<&2,String>
  List<&2,String>

law dr_relies:
  for +book: List<&2,KDef>
  for todo: List<&2,String>
  for +seen: List<&2,String>
  Bool

law dr_relies_def:
  for +book: List<&2,KDef>
  for +todo: List<&2,String>
  for +seen: List<&2,String>
  for +d: KDef
  Bool

law dr_verdict:
  for +names: List<&2,String>
  String

law dr_count:
  for names: List<&2,String>
  U32

law dr_lines:
  for names: List<&2,String>
  String

@unsafe
def driver_report(
  +book: List<&2,KDef>,
  +names: List<&2,String>,
) -> String:
  dr_verdict(driver_bad_names(book))

@unsafe
def dr_bad_names(book, names):
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      kc(List<&2,String>, dr_relies(book, [name], Nil{}),
        u => Con{name, dr_bad_names(book, rest)}, u => dr_bad_names(book, rest))

@unsafe
def dr_relies(book, todo, seen):
  match todo:
    case Nil{}: False{}
    case Con{+name, +rest}:
      kc(Bool, has_name(seen, name),
        u => dr_relies(book, rest, seen),
        u => dr_relies_def(book, rest, Con{name, seen}, kr_resolve(book, name)))

@unsafe
def dr_relies_def(book, todo, seen, d):
  kc(Bool, du(d) || (String.eq(tg(dv(d)), "Foreign") && Bool.not(db(d))),
    u => True{},
    u => dr_relies(book, kr_dependencies(d, Nil{}, todo), seen))

@unsafe
def dr_verdict(names):
  match names:
    case Nil{}: "ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n"
    case Con{+name, +rest}:
      "SOME PROOFS FAIL\nError: " ++ U32.show(dr_count(names)) ++
      kc(String, U32.is_eq(dr_count(names), 1), u => " def relies", u => " defs rely") ++
      " on unsafe or foreign code:\n" ++ dr_lines(names)

@unsafe
def dr_count(names):
  match names:
    case Nil{}: 0
    case Con{+name, +rest}: U32.add(1, dr_count(rest))

@unsafe
def dr_lines(names):
  match names:
    case Nil{}: ""
    case Con{+name, +rest}: "- " ++ name_key(name) ++ "\n" ++ dr_lines(rest)

@unsafe
def driver_bad_names(
  +book: List<&2,KDef>,
) -> List<&2,String>:
  dr_bad_names(book_cached(book_final_fast(book, Nil{}), norm_max_book(book)), dr_own_names(book, Nil{}))

@unsafe
def dr_own_names(
  +book: List<&2,KDef>,
  +seen: List<&2,String>,
) -> List<&2,String>:
  match book:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,String>, db(d) || has_name(seen, dn(d)),
        u => dr_own_names(rest, seen),
        u => Con{dn(d), dr_own_names(rest, Con{dn(d), seen})})

# Owned successful requests need the same dependency result for both fields.
# This query only follows names; no fresh binder allocation consults the bound.
type DR_Report is Data:
  DR_Report{+verdict: String, +names: List<&2, String>}

@unsafe
def driver_report_data(+book: List<&2, KDef>) -> DR_Report:
  +names = dr_cached_names(book_cached(book_final_fast(book, Nil{}), 0), dr_own_names(book, Nil{}), missing())
  DR_Report{dr_verdict(names), names}

# A completed safe traversal proves every visited name safe in this immutable
# book. A traversal stopped by unsafe code proves only its original root unsafe:
# never mark the other visited branches unsafe or safe from that partial result.
type DR_Closure is Data:
  DR_Closure{+bad: Bool, +seen: List<&2, String>}

@unsafe
def dr_known(+safe: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(safe, name, index_hash(name, 2166136261), 32)), "ReportSafe")

@unsafe
def dr_mark_safe(names: List<&2, String>, +safe: KDef) -> KDef:
  match names:
    case Nil{}: safe
    case Con{+name, rest}:
      dr_mark_safe(rest, index_set(safe, KDef{name, "ReportSafe", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32))

@unsafe
def dr_walk(+book: List<&2, KDef>, todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef) -> DR_Closure:
  match todo:
    case Nil{}: DR_Closure{False{}, seen}
    case Con{+name, +rest}:
      kc(DR_Closure, has_name(seen, name) || dr_known(safe, name),
        u => dr_walk(book, rest, seen, safe),
        u => dr_walk_def(book, rest, Con{name, seen}, safe, kr_resolve(book, name)))

@unsafe
def dr_walk_def(+book: List<&2, KDef>, +todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef, +d: KDef) -> DR_Closure:
  kc(DR_Closure, du(d) || (String.eq(tg(dv(d)), "Foreign") && Bool.not(db(d))),
    u => DR_Closure{True{}, seen},
    u => dr_walk(book, kr_dependencies(d, Nil{}, todo), seen, safe))

@unsafe
def dr_cached_names(+book: List<&2, KDef>, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      dr_cached_step(book, name, rest, safe, dr_walk(book, [name], Nil{}, safe))

@unsafe
def dr_cached_step(+book: List<&2, KDef>, +name: String, +rest: List<&2, String>, +safe: KDef, result: DR_Closure) -> List<&2, String>:
  match result:
    case DR_Closure{+bad, +seen}:
      kc(List<&2, String>, bad, u => Con{name, dr_cached_names(book, rest, safe)},
        u => dr_cached_names(book, rest, dr_mark_safe(seen, safe)))
