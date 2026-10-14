# Private checked native-entry experiment. Exact membership only; source book,
# dependency expansion, first-match resolution and returned order are unchanged.
law p90_reach_names:
  for +book: List<&2,KDef>
  for todo: List<&2,String>
  for +seen: KDef
  for +stops: List<&2,String>
  KDef

law p90_reach_name:
  for +book: List<&2,KDef>
  for +name: String
  for +todo: List<&2,String>
  for +seen: KDef
  for +stops: List<&2,String>
  for +hash: U32
  KDef

law p90_reach_def:
  for +book: List<&2,KDef>
  for +todo: List<&2,String>
  for +seen: KDef
  for +stops: List<&2,String>
  for +d: KDef
  KDef

@unsafe
def p90_live_has(+seen: KDef, +name: String, +hash: U32) -> Bool:
  String.eq(dk(index_find(seen, name, hash, 32)), "$p90.live")

@unsafe
def p90_live_mark(+seen: KDef, +name: String, +hash: U32) -> KDef:
  index_set(seen, KDef{name, "$p90.live", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, hash, 32)

@unsafe
def p90_reach_names(book, todo, seen, stops):
  match todo:
    case Nil{}: seen
    case Con{name, rest}: p90_reach_name(book, name, rest, seen, stops, index_hash(name, 2166136261))

@unsafe
def p90_reach_name(book, name, todo, seen, stops, hash):
  kc(KDef, p90_live_has(seen, name, hash),
    u => p90_reach_names(book, todo, seen, stops),
    u => p90_reach_def(book, todo, p90_live_mark(seen, name, hash), stops, kr_resolve(book, name)))

@unsafe
def p90_reach_def(book, todo, seen, stops, d):
  kc(KDef, String.eq(dk(d), "Absent"),
    u => p90_reach_names(book, todo, seen, stops),
    u => p90_reach_names(book, kr_dependencies(d, stops, todo), p90_live_mark(seen, dn(d), index_hash(dn(d), 2166136261)), stops))

@unsafe
def p90_reach_filter(book: List<&2,KDef>, +live: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      kc(List<&2,KDef>, p90_live_has(live, dn(d), index_hash(dn(d), 2166136261)),
        u => Con{d, p90_reach_filter(rest, live)}, u => p90_reach_filter(rest, live))

@unsafe
def p90_reach_book(+book: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> List<&2,KDef>:
  p90_reach_filter(book, p90_reach_names(book, roots, missing(), stops))
