# Bounded normalized typed-family walk. The flat queue shares one work budget;
# the seen owner set avoids recursive/copy expansion. Unknown/exhaustion=>true.
@unsafe
def j_string_family(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  match todo:
    case Nil{}: False{}
    case Con{ty, rest}:
      kc(Bool, U32.is_eq(fuel, 0), u => True{}, u =>
        j_string_family_head(book, wnf(book, ty), rest, seen, U32.sub(fuel, 1)))

@unsafe
def j_string_family_head(+book: List<&2,KDef>, +ty: KTerm, +todo: List<&2,KTerm>, +seen: List<&2,String>, +fuel: U32) -> Bool:
  kc(Bool, String.eq(nm(ty), "String") || String.eq(nm(ty), "Char"), u => True{}, u =>
  kc(Bool, j_region_scalar(book, ty), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "All"), u => j_string_family(book, Con{kid(ty, 0), Con{kid(ty, 1), todo}}, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "Qua") && List.is_empty(&2, KTerm, ks(ty)), u => j_string_family(book, todo, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "Lam") && U32.is_eq(terms_len(ks(ty)), 1), u => j_string_family(book, Con{kid(ty, 0), todo}, seen, fuel), u =>
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(dk(lookup(book, nm(ty))), "ADT"), u =>
    kc(Bool, has_name(seen, nm(ty)), u => j_string_family(book, List.append(&2, KTerm, ks(ty), todo), seen, fuel), u =>
      j_string_family(book, j_string_family_ctors(book, dc(lookup(book, nm(ty))), ks(ty), List.append(&2, KTerm, ks(ty), todo)), Con{nm(ty), seen}, fuel)), u => True{}))))))

@unsafe
def j_string_family_ctors(+book: List<&2,KDef>, +cs: List<&2,KDef>, +args: List<&2,KTerm>, +todo: List<&2,KTerm>) -> List<&2,KTerm>:
  match cs:
    case Nil{}: todo
    case Con{c, rest}: Con{j_specialize(book, dt(c), args), j_string_family_ctors(book, rest, args, todo)}
