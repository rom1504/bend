#!/usr/bin/env python3
"""Track S1 (Wave 3): Composable Algorithmic Self-Compile Optimizer for compiler.bend.

Eliminates O(N^2) scans, String.order.go overhead, double-hashing, and redundant
backend passes while preserving 100% bit-identical .o output on all programs.

Usage: python3 -B apply_sc_algo.py <in_compiler.bend> <out_compiler.bend>
"""
import sys
from pathlib import Path


def replace_once(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return src.replace(old, new, 1)


def replace_string_eq_calls(src: str) -> tuple[str, int, int]:
    """Replace real String.eq( calls (outside string literals and comments):
    - Inside @unsafe defs -> agy_str_eq( (immediate short-circuit)
    - Inside safe defs -> p88_string_eq( (safe, no String.order.go)
    """
    out_lines = []
    n_fast = 0
    n_safe = 0
    in_unsafe = False
    pending_unsafe = False
    for line in src.splitlines(keepends=True):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            out_lines.append(line)
            continue
        if stripped.startswith("@unsafe"):
            pending_unsafe = True
            out_lines.append(line)
            continue
        if stripped.startswith("def "):
            in_unsafe = pending_unsafe
            pending_unsafe = False
        elif stripped.startswith(("type ", "law ")):
            in_unsafe = False
            pending_unsafe = False
        target = "agy_str_eq(" if in_unsafe else "p88_string_eq("
        res = []
        in_str = False
        esc = False
        i = 0
        n = len(line)
        while i < n:
            c = line[i]
            if in_str:
                res.append(c)
                if esc:
                    esc = False
                elif c == "\\":
                    esc = True
                elif c == '"':
                    in_str = False
                i += 1
            else:
                if c == '"':
                    in_str = True
                    res.append(c)
                    i += 1
                elif c == "#":
                    res.append(line[i:])
                    break
                elif line[i:i + 10] == "String.eq(" and (i == 0 or not (line[i - 1].isalnum() or line[i - 1] in "_.")):
                    res.append(target)
                    if in_unsafe:
                        n_fast += 1
                    else:
                        n_safe += 1
                    i += 10
                else:
                    res.append(c)
                    i += 1
        out_lines.append("".join(res))
    return "".join(out_lines), n_fast, n_safe


def apply_all(src: str) -> str:
    # ------------------------------------------------------------------
    # Opt 1: Fast short-circuit p88_string_eq_fast + p98_tag_eq_read
    # ------------------------------------------------------------------
    old_eq = """def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)"""

    new_eq = """def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

@unsafe
def agy_str_eq_go(same: Bool, a: String, b: String) -> Bool:
  match same:
    case False{}: False{}
    case True{}:
      match a b:
        case SNil{} SNil{}: True{}
        case SCon{h1, t1} SCon{h2, t2}:
          agy_str_eq_go(U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)), t1, t2)
        case _ _: False{}

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(agy_str_eq_go(True{}, a, b), a, b)"""

    src = replace_once(src, old_eq, new_eq, "Opt1:p88_string_eq_fast")

    old_tag = """def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)"""

    new_tag = """def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq_go("Lam", key, True{})
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq_go("Lit", key, True{})"""

    src = replace_once(src, old_tag, new_tag, "Opt1:p98_tag_eq_read")

    # ------------------------------------------------------------------
    # Opt 2: O(1) ctor->ADT parent index, O(1) dr_walk seen_set & raw deps,
    #        O(1) stops hash-trie in p142j_checked_error & ka_defs_except
    # ------------------------------------------------------------------
    old_ka = """def annotate_selected(book, selected, stops):
  ka_defs_except(book_context(book), selected, stops)

# Module: src/check/annotate.bend:148
@unsafe
def ka_defs_except(book, ds, stops):
  match ds:
    case Nil{}:
      Nil{}
    case Con{d, rest}:
      Con{kc(KDef, has_name(stops, dn(d)), u => d, u => ka_def(book, d)), ka_defs_except(book, rest, stops)}"""

    new_ka = """def agy_ka_defs_indexed(+book: List<&2, KDef>, ds: List<&2, KDef>, +stops_set: KDef) -> List<&2, KDef>:
  match ds:
    case Nil{}:
      Nil{}
    case Con{+d, rest}:
      +name = dn(d)
      +h = index_hash(name, 2166136261)
      Con{kc(KDef, p88_string_eq(dk(index_find(stops_set, name, h, 32)), "P142JSeen"), u => d, u => ka_def(book, d)), agy_ka_defs_indexed(book, rest, stops_set)}

@unsafe
def agy_stops_set(names: List<&2, String>, acc: KDef) -> KDef:
  match names:
    case Nil{}: acc
    case Con{+name, rest}:
      agy_stops_set(rest, index_set(acc, KDef{name, "P142JSeen", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}},
        index_hash(name, 2166136261), 32))

@unsafe
def annotate_selected(book, selected, stops):
  agy_ka_defs_indexed(book_context(book), selected, agy_stops_set(stops, missing()))

# Module: src/check/annotate.bend:148
@unsafe
def ka_defs_except(book, ds, stops):
  agy_ka_defs_indexed(book, ds, agy_stops_set(stops, missing()))"""

    src = replace_once(src, old_ka, new_ka, "Opt2:ka_defs_except")

    old_dr = """# Module: src/driver/report.bend:130
@unsafe
def dr_walk(+book: List<&2, KDef>, todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef) -> DR_Closure:
  match todo:
    case Nil{}: DR_Closure{False{}, seen}
    case Con{+name, +rest}:
      kc(DR_Closure, has_name(seen, name) || dr_known(safe, name),
        u => dr_walk(book, rest, seen, safe),
        u => dr_walk_def(book, rest, Con{name, seen}, safe, kr_resolve(book, name)))

# Module: src/driver/report.bend:139
@unsafe
def dr_walk_def(+book: List<&2, KDef>, +todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef, +d: KDef) -> DR_Closure:
  kc(DR_Closure, du(d) || (p98_tag_eq(dv(d), "Foreign") && Bool.not(db(d))),
    u => DR_Closure{True{}, seen},
    u => dr_walk(book, kr_dependencies(d, Nil{}, todo), seen, safe))

# Module: src/driver/report.bend:145
@unsafe
def dr_cached_names(+book: List<&2, KDef>, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      dr_cached_step(book, name, rest, safe, dr_walk(book, [name], Nil{}, safe))

# Module: src/driver/report.bend:152
@unsafe
def dr_cached_step(+book: List<&2, KDef>, +name: String, +rest: List<&2, String>, +safe: KDef, result: DR_Closure) -> List<&2, String>:
  match result:
    case DR_Closure{+bad, +seen}:
      kc(List<&2, String>, bad, u => Con{name, dr_cached_names(book, rest, safe)},
        u => dr_cached_names(book, rest, dr_mark_safe(seen, safe)))"""

    new_dr = """@unsafe
def agy_ctor_parent_add(ctors: List<&2, KDef>, +adt: KDef, +acc: KDef) -> KDef:
  match ctors:
    case Nil{}: acc
    case Con{+c, rest}:
      +cname = dn(c)
      +entry : KDef = KDef{cname, "AgyCtorParent", 0, 0,
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
        {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{adt, Nil{}}, False{}, False{}}
      agy_ctor_parent_add(rest, adt, index_set(acc, entry, index_hash(cname, 2166136261), 32))

@unsafe
def agy_ctor_parent_index(book: List<&2, KDef>, +acc: KDef) -> KDef:
  match book:
    case Nil{}: acc
    case Con{+d, rest}:
      agy_ctor_parent_index(rest, kc(KDef, p88_string_eq(dk(d), "ADT"),
        u => agy_ctor_parent_add(dc(d), d, acc), u => acc))

@unsafe
def agy_kr_resolve_cidx(+book: List<&2, KDef>, +cidx: KDef, +name: String, +hash: U32) -> KDef:
  +d = lookup(book, name)
  kc(KDef, p88_string_eq(dk(d), "Absent"),
    u => index_first(dc(index_find(cidx, name, hash, 32))), u => d)

law agy_dr_refs:
  for +t: KTerm
  for +todo: List<&2, String>
  List<&2, String>

@unsafe
def agy_dr_refs_list(terms: List<&2, KTerm>, +todo: List<&2, String>) -> List<&2, String>:
  match terms:
    case Nil{}: todo
    case Con{h, rest}: agy_dr_refs(h, agy_dr_refs_list(rest, todo))

@unsafe
def agy_dr_refs(t, todo):
  agy_dr_refs_list(ks(t), kc(List<&2, String>, p98_tag_eq(t, "Ref") || p98_tag_eq(t, "ADT") || p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Mat"),
    u => Con{nm(t), todo}, u => todo))

@unsafe
def agy_dr_ctor_refs(ctors: List<&2, KDef>, +todo: List<&2, String>) -> List<&2, String>:
  match ctors:
    case Nil{}: todo
    case Con{d, rest}: agy_dr_refs(dt(d), agy_dr_ctor_refs(rest, todo))

@unsafe
def agy_dr_deps(+d: KDef, +todo: List<&2, String>) -> List<&2, String>:
  agy_dr_refs(dt(d), agy_dr_ctor_refs(dc(d), agy_dr_refs(dv(d), todo)))

law agy_dr_walk_def:
  for +book: List<&2, KDef>
  for +cidx: KDef
  for +todo: List<&2, String>
  for +seen: List<&2, String>
  for +seen_set: KDef
  for +safe: KDef
  for +d: KDef
  DR_Closure

@unsafe
def agy_dr_walk(+book: List<&2, KDef>, +cidx: KDef, todo: List<&2, String>, +seen: List<&2, String>, +seen_set: KDef, +safe: KDef) -> DR_Closure:
  match todo:
    case Nil{}: DR_Closure{False{}, seen}
    case Con{+name, +rest}:
      +h = index_hash(name, 2166136261)
      kc(DR_Closure, p88_string_eq(dk(index_find(seen_set, name, h, 32)), "ReportSeen") ||
          p88_string_eq(dk(index_find(safe, name, h, 32)), "ReportSafe"),
        u => agy_dr_walk(book, cidx, rest, seen, seen_set, safe),
        u => agy_dr_walk_def(book, cidx, rest, Con{name, seen},
          index_set(seen_set, KDef{name, "ReportSeen", 0, 0,
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},
            {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, h, 32),
          safe, agy_kr_resolve_cidx(book, cidx, name, h)))

@unsafe
def agy_dr_walk_def(book, cidx, todo, seen, seen_set, safe, d):
  kc(DR_Closure, du(d) || (p98_tag_eq(dv(d), "Foreign") && Bool.not(db(d))),
    u => DR_Closure{True{}, seen},
    u => agy_dr_walk(book, cidx, agy_dr_deps(d, todo), seen, seen_set, safe))

law agy_dr_cached_step:
  for +book: List<&2, KDef>
  for +cidx: KDef
  for +name: String
  for +rest: List<&2, String>
  for +safe: KDef
  for result: DR_Closure
  List<&2, String>

@unsafe
def agy_dr_cached_go(+book: List<&2, KDef>, +cidx: KDef, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      agy_dr_cached_step(book, cidx, name, rest, safe, agy_dr_walk(book, cidx, [name], Nil{}, missing(), safe))

@unsafe
def agy_dr_cached_step(book, cidx, name, rest, safe, result):
  match result:
    case DR_Closure{+bad, +seen}:
      kc(List<&2, String>, bad, u => Con{name, agy_dr_cached_go(book, cidx, rest, safe)},
        u => agy_dr_cached_go(book, cidx, rest, dr_mark_safe(seen, safe)))

# Module: src/driver/report.bend:130
@unsafe
def dr_walk(+book: List<&2, KDef>, todo: List<&2, String>, +seen: List<&2, String>, +safe: KDef) -> DR_Closure:
  agy_dr_walk(book, agy_ctor_parent_index(book, missing()), todo, seen, missing(), safe)

# Module: src/driver/report.bend:145
@unsafe
def dr_cached_names(+book: List<&2, KDef>, names: List<&2, String>, +safe: KDef) -> List<&2, String>:
  agy_dr_cached_go(book, agy_ctor_parent_index(book, missing()), names, safe)"""

    src = replace_once(src, old_dr, new_dr, "Opt2:dr_walk_and_ctor_index")

    # Also speed up p142j_checked_error (stops -> hash trie) and p142r_kr_visit (cidx -> O(1) kr_resolve)
    old_p142j = """@unsafe
def p142j_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  kc(String,p142j_visit(book_context(book),book_cached(defs,0),roots,missing(),stops),
    u => "an open Array element type",u => "")


@unsafe
def p142j_visit(+book: List<&2,KDef>, +defs: List<&2,KDef>, todo: List<&2,String>, +seen: KDef, +stops: List<&2,String>) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      kc(Bool,p88_string_eq(name,"$layout.open-array"),u => True{},
        u => p142j_name(book,defs,name,rest,seen,stops,index_hash(name,2166136261)))


@unsafe
def p142j_name(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: List<&2,String>, +hash: U32) -> Bool:
  kc(Bool,p142j_member(seen,name,hash) || has_name(stops,name),
    u => p142j_visit(book,defs,rest,seen,stops),
    u => p142j_def(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops))


@unsafe
def p142j_def(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: List<&2,String>) -> Bool:
  p142j_visit(book,defs,kc(List<&2,String>,p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),
    u => jl_term(book,dv(d),todo),u => todo),seen,stops)"""

    new_p142j = """law p142j_visit_set:
  for +book: List<&2,KDef>
  for +defs: List<&2,KDef>
  for todo: List<&2,String>
  for +seen: KDef
  for +stops: KDef
  Bool

@unsafe
def p142j_checked_error(+book: List<&2,KDef>, +defs: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> String:
  kc(String,p142j_visit_set(book_context(book),book_cached(defs,0),roots,missing(),p142j_members(stops,missing())),
    u => "an open Array element type",u => "")


@unsafe
def p142j_def_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +d: KDef, +todo: List<&2,String>, +seen: KDef, +stops: KDef) -> Bool:
  p142j_visit_set(book,defs,kc(List<&2,String>,p88_string_eq(dk(d),"Def") && U32.is_eq(dx(d),0),
    u => jl_term(book,dv(d),todo),u => todo),seen,stops)


@unsafe
def p142j_name_set(+book: List<&2,KDef>, +defs: List<&2,KDef>, +name: String, +rest: List<&2,String>, +seen: KDef, +stops: KDef, +hash: U32) -> Bool:
  kc(Bool,p142j_member(seen,name,hash) || p142j_member(stops,name,hash),
    u => p142j_visit_set(book,defs,rest,seen,stops),
    u => p142j_def_set(book,defs,lookup(defs,name),rest,p142j_mark(seen,name,hash),stops))


@unsafe
def p142j_visit_set(book, defs, todo, seen, stops):
  match todo:
    case Nil{}: False{}
    case Con{+name,+rest}:
      kc(Bool,p88_string_eq(name,"$layout.open-array"),u => True{},
        u => p142j_name_set(book,defs,name,rest,seen,stops,index_hash(name,2166136261)))"""

    src = replace_once(src, old_p142j, new_p142j, "Opt2:p142j_stops_set")

    old_p142r = """@unsafe
def p142r_kr_visit(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>) -> List<&2,String>:
  p142r_visit(book,todo,seen,p142j_members(seen,missing()),stops)


@unsafe
def p142r_visit(+book: List<&2,KDef>, todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: seen
    case Con{+name,rest}:
      p142r_name(book,rest,seen,members,stops,name,index_hash(name,2166136261))


@unsafe
def p142r_name(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>, +name: String, +hash: U32) -> List<&2,String>:
  kc(List<&2,String>,p142j_member(members,name,hash),
    u => p142r_visit(book,todo,seen,members,stops),
    u => p142r_def(book,todo,Con{name,seen},p142j_mark(members,name,hash),stops,kr_resolve(book,name)))


@unsafe
def p142r_def(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>, +d: KDef) -> List<&2,String>:
  kc(List<&2,String>,p88_string_eq(dk(d),"Absent"),
    u => p142r_visit(book,todo,seen,members,stops),
    u => p142r_resolved(book,todo,seen,members,stops,d,dn(d)))


@unsafe
def p142r_resolved(book: List<&2,KDef>, todo: List<&2,String>, seen: List<&2,String>, members: KDef, +stops: List<&2,String>, d: KDef, +name: String) -> List<&2,String>:
  p142r_visit(book,kr_dependencies(d,stops,todo),Con{name,seen},p142j_mark(members,name,index_hash(name,2166136261)),stops)"""

    new_p142r = """law p142r_visit_c:
  for +book: List<&2,KDef>
  for +cidx: KDef
  for todo: List<&2,String>
  for +seen: List<&2,String>
  for +members: KDef
  for +stops: KDef
  List<&2,String>

@unsafe
def p142r_kr_visit(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>) -> List<&2,String>:
  p142r_visit_c(book,agy_ctor_parent_index(book,missing()),todo,seen,p142j_members(seen,missing()),p142j_members(stops,missing()))


@unsafe
def p142r_resolved_c(book: List<&2,KDef>, cidx: KDef, +todo: List<&2,String>, seen: List<&2,String>, members: KDef, +stops: KDef, +d: KDef, +name: String) -> List<&2,String>:
  +h = index_hash(name,2166136261)
  +deps = agy_dr_refs(dt(d),agy_dr_ctor_refs(dc(d),kc(List<&2,String>,p142j_member(stops,name,h),u => todo,u => agy_dr_refs(dv(d),todo))))
  p142r_visit_c(book,cidx,deps,Con{name,seen},p142j_mark(members,name,h),stops)


@unsafe
def p142r_def_c(+book: List<&2,KDef>, +cidx: KDef, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: KDef, +d: KDef) -> List<&2,String>:
  kc(List<&2,String>,p88_string_eq(dk(d),"Absent"),
    u => p142r_visit_c(book,cidx,todo,seen,members,stops),
    u => p142r_resolved_c(book,cidx,todo,seen,members,stops,d,dn(d)))


@unsafe
def p142r_name_c(+book: List<&2,KDef>, +cidx: KDef, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: KDef, +name: String, +hash: U32) -> List<&2,String>:
  kc(List<&2,String>,p142j_member(members,name,hash),
    u => p142r_visit_c(book,cidx,todo,seen,members,stops),
    u => p142r_def_c(book,cidx,todo,Con{name,seen},p142j_mark(members,name,hash),stops,agy_kr_resolve_cidx(book,cidx,name,hash)))


@unsafe
def p142r_visit_c(book, cidx, todo, seen, members, stops):
  match todo:
    case Nil{}: seen
    case Con{+name,rest}:
      p142r_name_c(book,cidx,rest,seen,members,stops,name,index_hash(name,2166136261))"""

    src = replace_once(src, old_p142r, new_p142r, "Opt2:p142r_cidx_and_raw_deps")

    # ------------------------------------------------------------------
    # Opt 3: p112r_buffer O(1) prefix guard
    # ------------------------------------------------------------------
    old_buf = """@unsafe
def p112r_buffer(+name: String, +sites: U32) -> Bool:
  U32.is_le(sites,8) && (String.eq(name,"scratch") || p112r_buffer_sites(name,sites,0))"""

    new_buf = """@unsafe
def p112r_buffer(+name: String, +sites: U32) -> Bool:
  U32.is_le(sites,8) && (p88_string_eq(name,"scratch") || (String.starts_with(name,"p112f_") && p112r_buffer_sites(name,sites,0)))"""

    src = replace_once(src, old_buf, new_buf, "Opt3:p112r_buffer")

    # ------------------------------------------------------------------
    # Opt 4: Pre-filter & shrink worklist in agy_p114h_fixpoint
    # ------------------------------------------------------------------
    old_hfp = """type AgyHPass is Data:
  AgyHPass{+hready: KDef, +added: Bool}

@unsafe
def agy_p114h_scan_segs(segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +view: KDef, +available: KDef, +hready: KDef, +added: Bool) -> AgyHPass:
  match segs:
    case Nil{}: AgyHPass{hready,added}
    case Con{+seg,+rest}:
      match seg:
        case N111Segment{+name,+arity,result,incoming,flags,body}:
          nt_choose(AgyHPass,agy_p114h_seg_eligible(seg,direct,hready) &&
              agy_p114h_plan_hygiene(name,available,p114h_plan(seg,index,view)),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,p111v_put(hready,name,"AgyHReady",arity,1),True{}),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,hready,added))

law agy_p114h_fixpoint:
  for +segs: List<&2,N111Segment>
  for +index: P112FusionIndex
  for +direct: KDef
  for +ready: KDef
  for +available: KDef
  for +hready: KDef
  for +fuel: U32
  KDef

@unsafe
def agy_p114h_fixpoint_next(+segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +fuel: U32, pass: AgyHPass) -> KDef:
  match pass:
    case AgyHPass{+hready2,added}:
      nt_choose(KDef,added,
        u => agy_p114h_fixpoint(segs,index,direct,ready,available,hready2,U32.sub(fuel,1)),
        u => hready2)

@unsafe
def agy_p114h_fixpoint(segs,index,direct,ready,available,hready,fuel):
  nt_choose(KDef,U32.is_eq(fuel,0),u => hready,u =>
    agy_p114h_fixpoint_next(segs,index,direct,ready,available,fuel,
      agy_p114h_scan_segs(segs,index,direct,agy_p124r_hview(ready,direct,hready),available,hready,False{})))"""

    new_hfp = """type AgyHPass is Data:
  AgyHPass{+hready: KDef, +rem: List<&2,N111Segment>, +added: Bool}

@unsafe
def agy_p114h_filter_segs(segs: List<&2,N111Segment>, +direct: KDef, +acc: List<&2,N111Segment>) -> List<&2,N111Segment>:
  match segs:
    case Nil{}: nt_reverse(N111Segment,acc,[])
    case Con{+seg,+rest}:
      agy_p114h_filter_segs(rest,direct,nt_choose(List<&2,N111Segment>,agy_p114h_seg_eligible(seg,direct,missing()),
        u => Con{seg,acc},u => acc))

@unsafe
def agy_p114h_scan_segs(segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +view: KDef, +available: KDef, +hready: KDef, +rem: List<&2,N111Segment>, +added: Bool) -> AgyHPass:
  match segs:
    case Nil{}: AgyHPass{hready,nt_reverse(N111Segment,rem,[]),added}
    case Con{+seg,+rest}:
      match seg:
        case N111Segment{+name,+arity,result,incoming,flags,body}:
          nt_choose(AgyHPass,agy_p114h_plan_hygiene(name,available,p114h_plan(seg,index,view)),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,p111v_put(hready,name,"AgyHReady",arity,1),rem,True{}),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,hready,Con{seg,rem},added))

law agy_p114h_fixpoint_loop:
  for +segs: List<&2,N111Segment>
  for +index: P112FusionIndex
  for +direct: KDef
  for +ready: KDef
  for +available: KDef
  for +hready: KDef
  for +fuel: U32
  KDef

@unsafe
def agy_p114h_fixpoint_next(+index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +fuel: U32, pass: AgyHPass) -> KDef:
  match pass:
    case AgyHPass{+hready2,+rem,added}:
      nt_choose(KDef,added && Bool.not(List.is_empty(&2,N111Segment,rem)),
        u => agy_p114h_fixpoint_loop(rem,index,direct,ready,available,hready2,U32.sub(fuel,1)),
        u => hready2)

@unsafe
def agy_p114h_fixpoint_loop(segs,index,direct,ready,available,hready,fuel):
  nt_choose(KDef,U32.is_eq(fuel,0) || List.is_empty(&2,N111Segment,segs),u => hready,u =>
    agy_p114h_fixpoint_next(index,direct,ready,available,fuel,
      agy_p114h_scan_segs(segs,index,direct,agy_p124r_hview(ready,direct,hready),available,hready,[],False{})))

@unsafe
def agy_p114h_fixpoint(+segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +hready: KDef, +fuel: U32) -> KDef:
  agy_p114h_fixpoint_loop(agy_p114h_filter_segs(segs,direct,[]),index,direct,ready,available,hready,fuel)"""

    src = replace_once(src, old_hfp, new_hfp, "Opt4:agy_p114h_fixpoint")

    # ------------------------------------------------------------------
    # Opt 5: Single-hash fusion in x181_reads_record, x185_copy_write, x190_register_scores
    # ------------------------------------------------------------------
    old_reads = """@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +old = p111v_get(counts,name)
      +fresh = String.eq(dk(old),"Absent")
      X181ReadCounts{p111v_put(counts,name,"X181Reads",
        nt_choose(U32,fresh,u => 1,u => x181_read_increment(da(old))),0),
        nt_choose(List<&2,String>,fresh,u => Con{name,reversedNames},u => reversedNames)}"""

    new_reads = """@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +h = index_hash(name,2166136261)
      +old = index_find(counts,name,h,32)
      +fresh = p88_string_eq(dk(old),"Absent")
      X181ReadCounts{index_set(counts,KDef{name,"X181Reads",
        nt_choose(U32,fresh,u => 1,u => x181_read_increment(da(old))),0,atom("Absent"),atom("Absent"),[],False{},False{}},h,32),
        nt_choose(List<&2,String>,fresh,u => Con{name,reversedNames},u => reversedNames)}"""

    src = replace_once(src, old_reads, new_reads, "Opt5:x181_reads_record")

    old_scores = """@unsafe
def x190_register_scores(names: List<&2,String>, +writes: KDef,
    +params: List<&2,String>, +policy: U32, +counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{+name,rest}:
      x190_register_scores(rest,writes,params,policy,
        p111v_put(counts,name,"X181Reads",x190_register_score(da(p111v_get(counts,name)),
          nb_contains(params,name) || U32.is_eq(da(p111v_get(writes,name)),0),policy),0))"""

    new_scores = """@unsafe
def x190_register_scores(names: List<&2,String>, +writes: KDef,
    +params: List<&2,String>, +policy: U32, +counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{+name,rest}:
      +h = index_hash(name,2166136261)
      x190_register_scores(rest,writes,params,policy,
        index_set(counts,KDef{name,"X181Reads",x190_register_score(da(index_find(counts,name,h,32)),
          nb_contains(params,name) || U32.is_eq(da(index_find(writes,name,h,32)),0),policy),0,
          atom("Absent"),atom("Absent"),[],False{},False{}},h,32))"""

    src = replace_once(src, old_scores, new_scores, "Opt5:x190_register_scores")

    old_cwrite = """@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  p111v_put(counts,name,"X185Writes",U32.min(2,U32.inc(da(p111v_get(counts,name)))),0)"""

    new_cwrite = """@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  +h = index_hash(name,2166136261)
  index_set(counts,KDef{name,"X185Writes",U32.min(2,U32.inc(da(index_find(counts,name,h,32)))),0,
    atom("Absent"),atom("Absent"),[],False{},False{}},h,32)"""

    src = replace_once(src, old_cwrite, new_cwrite, "Opt5:x185_copy_write")

    # ------------------------------------------------------------------
    # Opt 6: Skip no-op x185_copy_body when aliases is Absent;
    #        Skip w2_asr_body + 3rd x185_dead_body when body has no shr!
    # ------------------------------------------------------------------
    old_cfunc = """@unsafe
def x185_copy_function(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_copy_body(body,x185_copy_aliases(body,
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),params,missing())),
    u => body)"""

    new_cfunc = """@unsafe
def agy_x185_copy_apply(+body: List<&2,P113DStmt>, +aliases: KDef) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,p88_string_eq(dk(aliases),"Absent"),u => body,u => x185_copy_body(body,aliases))

@unsafe
def x185_copy_function(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => agy_x185_copy_apply(body,x185_copy_aliases(body,
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),params,missing())),
    u => body)"""

    src = replace_once(src, old_cfunc, new_cfunc, "Opt6:x185_copy_function")

    old_fmem = """@unsafe
def x186_function_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,agy_reuse_body(symbol,ids,x185_dead_body(setup,w2_asr_body(w2_asr_strip_self(x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))))))),ids)"""

    new_fmem = """@unsafe
def agy_has_asr_or_strip(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Bin{name,typ,op,left,right}},rest}:
      p88_string_eq(op,"shr") || p88_string_eq(op,"mul") || agy_has_asr_or_strip(rest)
    case Con{P113DScalar{N111Set{a,N111U64{},N111Local{b}}},rest}:
      p88_string_eq(a,b) || agy_has_asr_or_strip(rest)
    case Con{P113DIf{c,yes,no},rest}:
      agy_has_asr_or_strip(yes) || agy_has_asr_or_strip(no) || agy_has_asr_or_strip(rest)
    case Con{head,rest}: agy_has_asr_or_strip(rest)

@unsafe
def agy_asr_and_dead(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,agy_has_asr_or_strip(body),
    u => x185_dead_body(setup,w2_asr_body(w2_asr_strip_self(body))),
    u => body)

@unsafe
def x186_function_memory(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x185_function_copied(symbol,params,setup,agy_reuse_body(symbol,ids,agy_asr_and_dead(setup,x185_dead_body(setup,
    x185_copy_function(params,setup,x186_expression_body(setup,
      x190_local_values_body(setup,x192_predicate_body(x186_private_body(params,setup,body)))))))),ids)"""

    src = replace_once(src, old_fmem, new_fmem, "Opt6:x186_function_memory")

    # ------------------------------------------------------------------
    # Opt 7: Route hottest @unsafe string compares through agy_str_eq
    # ------------------------------------------------------------------
    src = replace_once(
        src,
        """@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  p88_string_eq(a, b)""",
        """@unsafe
def f_eq(
  +a: String,
  +b: String,
) -> Bool:
  agy_str_eq(a, b)""",
        "Opt7:f_eq",
    )

    src = replace_once(
        src,
        """@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, p88_string_eq(dn(h), name), u => h, u => index_bucket(rest, name))""",
        """@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, agy_str_eq(dn(h), name), u => h, u => index_bucket(rest, name))""",
        "Opt7:index_bucket",
    )

    src = replace_once(
        src,
        """@unsafe
def p137q_name_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(name,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("",key)""",
        """@unsafe
def p137q_name_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: agy_str_eq(name,key)
    case KIndexLeaf{hash,bucket}: agy_str_eq("",key)
    case KIndexNode{hash,mask,left,right}: agy_str_eq("",key)""",
        "Opt7:p137q_name_eq",
    )

    # ------------------------------------------------------------------
    # Opt 8: Skip no-op x185_copy_function #2 when x185_fact_returns(body);
    #        Skip x185_scratch_body when body has no Load/Store/Alloca
    # ------------------------------------------------------------------
    src = replace_once(
        src,
        """@unsafe
def x185_prepare_body(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x185_dead_body(setup,x185_copy_function(params,setup,x185_fact_body(x185_copy_function(params,setup,body))))""",
        """@unsafe
def agy_x185_fact_and_copy(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_fact_enabled() && U32.is_lt(p113i_size(body),4096) && Bool.not(x185_fact_returns(body)),
    u => x185_copy_function(params,setup,x185_fact_result(p113k_body(body,missing()))),
    u => body)

@unsafe
def x185_prepare_body(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x185_dead_body(setup,agy_x185_fact_and_copy(params,setup,x185_copy_function(params,setup,body)))""",
        "Opt8:x185_prepare_body",
    )

    src = replace_once(
        src,
        """@unsafe
def x185_scratch_body(params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_scratch_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_sf_body(body,x185_sf_buffers(body,x185_sf_buffers(setup,
      x185_sf_blocks(params,p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),[]),u => body)""",
        """@unsafe
def agy_has_mem_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Load{n,t,b,o},rest}: True{}
    case Con{N111Store{t,b,o,v},rest}: True{}
    case Con{N111Offset{n,b,by},rest}: True{}
    case Con{N111Alloca{n,by,al},rest}: True{}
    case Con{N111If{c,yes,no},rest}: agy_has_mem_scalars(yes) || agy_has_mem_scalars(no) || agy_has_mem_scalars(rest)
    case Con{head,rest}: agy_has_mem_scalars(rest)

@unsafe
def agy_has_mem_body(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Load{n,t,b,o}},rest}: True{}
    case Con{P113DScalar{N111Store{t,b,o,v}},rest}: True{}
    case Con{P113DScalar{N111Offset{n,b,by}},rest}: True{}
    case Con{P113DScalar{N111Alloca{n,by,al}},rest}: True{}
    case Con{P113DScalar{N111If{c,yes,no}},rest}: agy_has_mem_scalars(yes) || agy_has_mem_scalars(no) || agy_has_mem_body(rest)
    case Con{P113DIf{c,yes,no},rest}: agy_has_mem_body(yes) || agy_has_mem_body(no) || agy_has_mem_body(rest)
    case Con{head,rest}: agy_has_mem_body(rest)

@unsafe
def x185_scratch_body(params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_scratch_enabled() && agy_has_mem_body(body) &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_sf_body(body,x185_sf_buffers(body,x185_sf_buffers(setup,
      x185_sf_blocks(params,p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),[]),u => body)""",
        "Opt8:x185_scratch_body",
    )

    # ------------------------------------------------------------------
    # Opt 1b: Replace all real String.eq( calls with agy_str_eq( / p88_string_eq(
    # ------------------------------------------------------------------
    src, n_fast, n_safe = replace_string_eq_calls(src)
    print(f"apply_sc_algo: applied Opts 1-8 cleanly (replaced {n_fast} unsafe -> agy_str_eq, {n_safe} safe -> p88_string_eq)")
    return src


def main():
    if len(sys.argv) != 3:
        sys.exit("Usage: apply_sc_algo.py <in.bend> <out.bend>")
    src_path = Path(sys.argv[1])
    dst_path = Path(sys.argv[2])
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    out = apply_all(src_path.read_text())
    dst_path.write_text(out)
    print(f"Wrote {dst_path} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
