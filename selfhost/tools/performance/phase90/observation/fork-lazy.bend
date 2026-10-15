# Private lazy indexed variant: explicit thunks avoid eager Bool.and/or work.
# Finite well-formed Data results preserve root order, duplicates and fuel.
# Unchecked partial/cyclic host values may have different demand/failure behavior.
@unsafe
def p90_fork_member(+seen: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(seen, name, index_hash(name, 2166136261), 32)), "$p90.fork")

@unsafe
def p90_fork_mark(+seen: KDef, +name: String) -> KDef:
  index_set(seen, KDef{name, "$p90.fork", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, index_hash(name, 2166136261), 32)

@unsafe
def p90_fork_index(roots: List<&2, String>, seen: KDef) -> KDef:
  match roots:
    case Nil{}: seen
    case Con{name, rest}: p90_fork_index(rest, p90_fork_mark(seen, name))

@unsafe
def p90_fork_reaches(refs: List<&2, String>, +seen: KDef) -> Bool:
  match refs:
    case Nil{}: False{}
    case Con{name, rest}:
      nt_choose(Bool, p90_fork_member(seen, name),
        u => True{}, u => p90_fork_reaches(rest, seen))

law p90_fork_round:
  for +ss: List<&2, N_Segment>
  for +roots: List<&2, String>
  for +seen: KDef
  for +fuel: U32
  List<&2, String>

law p90_fork_scan:
  for +whole: List<&2, N_Segment>
  for ss: List<&2, N_Segment>
  for +roots: List<&2, String>
  for +seen: KDef
  for +before: U32
  for +fuel: U32
  List<&2, String>

@unsafe
def p90_fork_round(ss, roots, seen, fuel):
  match fuel:
    case 0: roots
    case _: p90_fork_scan(ss, ss, roots, seen, nt_count(String, roots), U32.sub(fuel, 1))

@unsafe
def p90_fork_scan(whole, ss, roots, seen, before, fuel):
  match ss:
    case Nil{}:
      nt_choose(List<&2, String>, U32.is_eq(before, nt_count(String, roots)),
        u => roots, u => p90_fork_round(whole, roots, seen, fuel))
    case Con{N_Segment{+k, ps, r, f, b, +refs, h, s, +fork, bang}, +rest}:
      nt_choose(List<&2, String>, nt_choose(Bool, fork,
        u => False{}, u => nt_choose(Bool, p90_fork_member(seen, k),
          v => False{}, v => p90_fork_reaches(refs, seen))),
        u => p90_fork_scan(whole, rest, Con{k, roots}, p90_fork_mark(seen, k), before, fuel),
        u => p90_fork_scan(whole, rest, roots, seen, before, fuel))

# Preserve zero-fuel and empty-segment returns without constructing any index.
@unsafe
def nb_fork_close(+ss: List<&2, N_Segment>, +roots: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(fuel, 0) || List.is_empty(&2, N_Segment, ss),
    u => roots, u => p90_fork_round(ss, roots, p90_fork_index(roots, missing()), fuel))

@unsafe
def p90_flags_indexed(ss: List<&2, N_Segment>, +seen: KDef, acc: List<&2, String>) -> String:
  match ss:
    case Nil{}: nt_text_finish(acc, "2, 0")
    case Con{N_Segment{+k, ps, r, f, b, refs, h, s, +fork, +bang}, rest}:
      p90_flags_indexed(rest, seen, Con{U32.show(U32.add(nt_bool(bang), U32.mul(2, nt_bool(nt_choose(Bool, fork, u => False{}, u => Bool.not(p90_fork_member(seen, k))))))) ++ ", ", acc})

@unsafe
def nb_flags_chunks(+ss: List<&2, N_Segment>, +forks: List<&2, String>, +acc: List<&2, String>) -> String:
  nt_choose(String, List.is_empty(&2, N_Segment, ss),
    u => nt_text_finish(acc, "2, 0"), u => p90_flags_indexed(ss, p90_fork_index(forks, missing()), acc))
