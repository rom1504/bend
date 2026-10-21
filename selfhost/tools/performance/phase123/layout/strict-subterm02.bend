# Experimental one-level admission. Version01 is retained as rejected evidence:
# eager Boolean operands could enter the traversal despite failed size guards.
@unsafe
def nq_layout_leaf(+field: KTerm, +owner: KTerm, +seen: List<&2, U32>) -> Bool:
  nt_choose(Bool, String.eq(tg(field), "Absent") || String.eq(tg(field), "Ref") || nq_layout_dep(field, seen),
    u => False{}, u =>
    nt_choose(Bool, String.eq(tg(field), "ADT") && String.eq(nm(field), nm(owner)),
      v => p123l_sigma_child(field, owner), v => True{}))

# Stage expensive operations explicitly. Total syntax bound precedes arity,
# exact equality and worklist traversal; aliases are never expanded here.
@unsafe
def p123l_sigma_child(+field: KTerm, +owner: KTerm) -> Bool:
  nt_choose(Bool, String.eq(tg(owner), "ADT") && String.eq(nm(owner), "Sigma") && String.eq(nm(field), "Sigma"),
    u => nt_choose(Bool, U32.is_gt(nq_layout_remaining([owner, field], 257), 0),
      v => nt_choose(Bool, U32.is_eq(terms_len(ks(owner)), 4) && U32.is_eq(terms_len(ks(field)), 4) && List.is_empty(&2, String, rm(field)) && List.is_empty(&2, String, rm(owner)),
        w => p123l_contains(field, ks(owner), 256), w => False{}),
      v => False{}),
    u => False{})

@unsafe
def p123l_contains(+needle: KTerm, +work: List<&2, KTerm>, +fuel: U32) -> Bool:
  nt_choose(Bool, U32.is_eq(fuel, 0), u => False{}, u => p123l_visit(needle, work, U32.sub(fuel, 1)))

@unsafe
def p123l_visit(+needle: KTerm, work: List<&2, KTerm>, +fuel: U32) -> Bool:
  match work:
    case Nil{}: False{}
    case Con{+head, +rest}:
      nt_choose(Bool, norm_exact(needle, head), u => True{},
        u => p123l_contains(needle, List.append(&2, KTerm, ks(head), rest), fuel))

# Cheap checked-book diagnostics, independent of emission or machine building.
@unsafe
def p123l_inspect(request: NR_Request, name: String) -> KDef:
  match request:
    case NR_Request{source, book, names, paths, scope, bound}: nq_signature_def(book, name)

@unsafe
def p123l_type(request: NR_Request, name: String) -> KTerm:
  match request:
    case NR_Request{source, book, names, paths, scope, bound}: dt(lookup(book, name))
