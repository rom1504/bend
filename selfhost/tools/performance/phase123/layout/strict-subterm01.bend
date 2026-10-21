# Experimental one-level admission only. Original shape/quantity/dependency
# checks and all field ownership remain unchanged. No recursive flattening.
@unsafe
def nq_layout_leaf(+field: KTerm, +owner: KTerm, +seen: List<&2, U32>) -> Bool:
  Bool.not(String.eq(tg(field), "Absent") || String.eq(tg(field), "Ref")) && Bool.not(nq_layout_dep(field, seen)) &&
    (Bool.not(String.eq(tg(field), "ADT") && String.eq(nm(field), nm(owner))) || p123l_sigma_child(field, owner))

# A strict syntactic subterm is finite and cannot equal its enclosing type.
# This intentionally misses alias-expanded children absent from original syntax.
# Bound both inputs before exact comparisons; don't normalize or expand aliases.
@unsafe
def p123l_sigma_child(+field: KTerm, +owner: KTerm) -> Bool:
  String.eq(tg(owner), "ADT") && String.eq(nm(owner), "Sigma") && String.eq(nm(field), "Sigma") &&
    U32.is_eq(terms_len(ks(owner)), 4) && U32.is_eq(terms_len(ks(field)), 4) &&
    List.is_empty(&2, String, rm(field)) && List.is_empty(&2, String, rm(owner)) &&
    U32.is_gt(nq_layout_remaining([owner, field], 257), 0) &&
    p123l_contains(field, ks(owner))

@unsafe
def p123l_contains(+needle: KTerm, work: List<&2, KTerm>) -> Bool:
  match work:
    case Nil{}: False{}
    case Con{+head, rest}:
      norm_exact(needle, head) || p123l_contains(needle, List.append(&2, KTerm, ks(head), rest))
