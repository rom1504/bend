# Proposed exact proofs; integrate only with all runtime/capture consumers.
@unsafe
def j_string_owner(+book: List<&2,KDef>, +ty: KTerm, +name: String, +count: U32) -> Bool:
  +owner = lookup(book, name)
  +kind = wnf(book, dt(owner))
  String.eq(tg(ty), "ADT") && String.eq(nm(ty), name) && List.is_empty(&2, KTerm, ks(ty)) && List.is_empty(&2, String, rm(ty)) &&
    String.eq(dk(owner), "ADT") && db(owner) && U32.is_eq(da(owner), 0) && U32.is_eq(dx(owner), 0) &&
    U32.is_eq(j_region_def_count(dc(owner)), count) && String.eq(tg(kind), "Typ") && U32.is_eq(terms_len(ks(kind)), 1) &&
    String.eq(tg(kid(kind, 0)), "Qua") && U32.is_eq(qt(kid(kind, 0)), 2) && List.is_empty(&2, KTerm, ks(kid(kind, 0)))

@unsafe
def j_string_char(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +c = lookup(dc(lookup(book, "Char")), "Chr")
  +tel = wnf(book, dt(c))
  j_string_owner(book, ty, "Char", 1) && j_pure_native_ctor(c, "Chr", 1) &&
    String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) && U32.is_eq(terms_len(ks(tel)), 2) &&
    j_primitive_type(book, wnf(book, kid(tel, 0)), "U32") && j_string_owner(book, wnf(book, kid(tel, 1)), "Char", 1)

@unsafe
def j_string_string(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  +cs = dc(lookup(book, "String"))
  +nil = lookup(cs, "SNil")
  +con = lookup(cs, "SCon")
  +tel = wnf(book, dt(con))
  +rest = wnf(book, kid(tel, 1))
  j_string_owner(book, ty, "String", 2) && j_pure_native_ctor(nil, "SNil", 0) && j_pure_native_ctor(con, "SCon", 2) &&
    j_string_owner(book, wnf(book, dt(nil)), "String", 2) && String.eq(tg(tel), "All") && U32.is_eq(qt(tel), 1) &&
    U32.is_eq(terms_len(ks(tel)), 2) && j_string_char(book, wnf(book, kid(tel, 0))) &&
    String.eq(tg(rest), "All") && U32.is_eq(qt(rest), 1) && U32.is_eq(terms_len(ks(rest)), 2) &&
    j_string_owner(book, wnf(book, kid(rest, 0)), "String", 2) && j_string_owner(book, wnf(book, kid(rest, 1)), "String", 2)

@unsafe
def j_string_literal(+book: List<&2,KDef>, +d: KDef) -> Bool:
  +body = j_strip(dv(d))
  +head = wnf(book, dt(d))
  String.eq(dk(d), "Def") && Bool.not(db(d)) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0) &&
    String.eq(tg(body), "Lit") && String.eq(nm(body), nm(head)) && j_pure_type(book, head) &&
    String.contains("|U32|Nat|F32|String|Char|", "|" ++ nm(body) ++ "|") && j_u32_bounded([body], 256)

# Conservatively mark every syntactic String/Char/native constructor occurrence;
# unknown/fuel exhaustion marks the host family too, never silently ignores it.
@unsafe
def j_string_uses(+todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{t, rest}:
      kc(Bool, U32.is_eq(fuel, 0) || String.contains("|String|Char|SNil|SCon|Chr|", "|" ++ nm(t) ++ "|"), u => True{}, u =>
        j_string_uses(List.append(&2, KTerm, ks(t), rest), U32.sub(fuel, 1)))
