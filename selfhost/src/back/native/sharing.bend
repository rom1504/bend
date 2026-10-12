# A checked, whole-program constructor-sharing certificate. Every duplicated
# runtime variable heats its annotated datatype and its transitive live fields.
# Unknown/open types or exhausted syntax budgets heat everything. This is
# separate from array sharing: an array-free List can still be duplicated.
@unsafe
def nh_add(+key: String, +hot: List<&2, String>) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(hot, key), u => hot, u => Con{key, hot})

@unsafe
def nh_types(+book: List<&2, KDef>, ts: List<&2, KTerm>, hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  match ts:
    case Nil{}: hot
    case Con{h, rest}: nh_types(book, rest, nh_type(book, h, hot, fuel), fuel)

@unsafe
def nh_type(+book: List<&2, KDef>, +ty: KTerm, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(hot, "*") || U32.is_eq(fuel, 0), u => nh_add("*", hot), u => nh_head(book, nq_layout_type(book, ty), hot, U32.sub(fuel, 1)))

@unsafe
def nh_head(+book: List<&2, KDef>, +t: KTerm, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, nb_contains(["Qua", "Qnt", "Typ", "Eql", "Rfl", "Lit", "Num", "Chr"], tg(t)), u => hot, u =>
    nt_choose(List<&2, String>, String.eq(tg(t), "Lam"), v => nh_type(book, kid(t, 0), hot, fuel), v =>
      nt_choose(List<&2, String>, String.eq(tg(t), "ADT") && List.is_empty(&2, String, rm(t)) && U32.is_le(nq_layout_size([t], 4097), 4096), w => nh_adt(book, t, lookup(book, nm(t)), hot, fuel), w => nh_add("*", hot))))

@unsafe
def nh_adt(+book: List<&2, KDef>, +t: KTerm, +d: KDef, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, db(d) && nb_contains(["Nat", "U32", "F32", "Char", "Bool", "Unit"], nm(t)) && List.is_empty(&2, KTerm, ks(t)), u => hot, u =>
    nt_choose(List<&2, String>, String.eq(dk(d), "ADT") && U32.is_eq(da(d), terms_len(ks(t))) && U32.is_eq(dx(d), 0),
      v => nh_adt_fields(book, t, d, nh_types(book, ks(t), hot, fuel), fuel), v => nh_add("*", hot)))

@unsafe
def nh_adt_fields(+book: List<&2, KDef>, +t: KTerm, +d: KDef, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  +key = "type:" ++ term_key(t)
  nt_choose(List<&2, String>, nb_contains(hot, key), u => hot, u => nh_ctors(book, dc(d), ks(t), db(d), nh_add(key, hot), fuel))

@unsafe
def nh_ctors(+book: List<&2, KDef>, cs: List<&2, KDef>, +args: List<&2, KTerm>, +base: Bool, hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  match cs:
    case Nil{}: hot
    case Con{+c, rest}:
      +key = nt_choose(String, base, u => dn(c), u => nc_ctor_encode(dn(c)))
      nh_ctors(book, rest, args, base, nh_fields(book, nq_layout_specialize(dt(c), args, 64), da(c), nh_add("ctor:" ++ key, hot), fuel), fuel)

@unsafe
def nh_fields(+book: List<&2, KDef>, +tel: KTerm, +left: U32, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(left, 0), u => hot, u =>
    nt_choose(List<&2, String>, U32.is_eq(fuel, 0), v => nh_add("*", hot), v => nh_field(book, nq_layout_type(book, tel), left, hot, U32.sub(fuel, 1))))

@unsafe
def nh_field(+book: List<&2, KDef>, +head: KTerm, +left: U32, +hot: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, String.eq(tg(head), "All"),
    u => nh_fields(book, kid(head, 1), U32.sub(left, 1), nt_choose(List<&2, String>, U32.is_eq(qt(head), 0), v => hot, v => nh_type(book, kid(head, 0), hot, fuel)), fuel),
    u => nh_add("*", hot))

@unsafe
def nh_terms(+book: List<&2, KDef>, +body: KTerm, ts: List<&2, KTerm>, +hot: List<&2, String>) -> List<&2, String>:
  match ts:
    case Nil{}: hot
    case Con{+t, +rest}:
      nt_choose(List<&2, String>, nb_contains(hot, "*"), u => hot, u =>
        nt_choose(List<&2, String>, String.eq(tg(t), "Ann"), v =>
          nt_choose(List<&2, String>, String.eq(tg(kid(t, 0)), "Var"), w =>
            nh_terms(book, body, rest, nt_choose(List<&2, String>, U32.is_gt(nq_uses(body, ix(kid(t, 0))), 1), x => nh_type(book, kid(t, 1), hot, 64), x => hot)),
            w => nh_terms(book, body, Con{kid(t, 0), rest}, hot)), v =>
          nt_choose(List<&2, String>, String.eq(tg(t), "Var"), w => nt_choose(List<&2, String>, U32.is_gt(nq_uses(body, ix(t)), 1), x => nh_add("*", hot), x => nh_terms(book, body, rest, hot)), w => nh_terms(book, body, nt_append(KTerm, ks(t), rest), hot))))

@unsafe
def nh_definitions(+book: List<&2, KDef>, names: List<&2, String>, +hot: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: hot
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, String>, nb_contains(hot, "*"), u => hot, u => nh_definitions(book, rest, nt_choose(List<&2, String>, nc_native_def(d) || nc_foreign(d), v => hot, v => nh_terms(book, nc_erase(book, dv(d)), [dv(d)], hot))))

@unsafe
def nh_condition(hot: List<&2, String>) -> String:
  match hot:
    case Nil{}: ""
    case Con{+key, rest}: nt_choose(String, String.starts_with(key, "ctor:"), u => "#define NATIVE_HOT_" ++ nt_cid(String.drop(key, 5n)) ++ " 1\n", u => "") ++ nh_condition(rest)

@unsafe
def nh_macros(+book: List<&2, KDef>, +names: List<&2, String>, +permission: Bool) -> String:
  nt_choose(String, permission, u => nh_macros_hot(nh_definitions(book, names, Nil{})), u => "")

@unsafe
def nh_macros_hot(+hot: List<&2, String>) -> String:
  nt_choose(String, nb_contains(hot, "*"), u => "", u => "#define NATIVE_COLD_CTORS 1\n" ++ nh_condition(hot))
