# Only the already whole-graph-proved producer context may nest constructors.
# Leaves keep the existing atom/primitive grammar; typed argument planning still
# checks every constructor and field. Ordinary public/root admission is unchanged.
@unsafe
def j_producer_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +left: U32, +active: List<&2,String>) -> Bool:
  kc(Bool, has_name(active, "@producer"), u => j_producer_nested_fields(book, xs, left, 128),
    u => j_fold_terminal_fields(book, xs, left))

@unsafe
def j_producer_nested_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +left: U32, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: U32.is_eq(left, 0)
    case Con{h, rest}:
      kc(Bool, U32.is_gt(left, 0) && U32.is_gt(fuel, 0), u =>
        j_producer_nested_field(book, h, U32.sub(fuel, 1)) &&
          j_producer_nested_fields(book, rest, U32.sub(left, 1), U32.sub(fuel, 1)), u => False{})

@unsafe
def j_producer_nested_field(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, j_fold_terminal_expr(book, body, fuel), u => True{}, u =>
      kc(Bool, String.eq(tg(body), "Ctr"), u =>
        j_producer_nested_fields(book, ks(body), terms_len(ks(body)), U32.sub(fuel, 1)), u => False{})), u => False{})
