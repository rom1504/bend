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
      nt_choose(List<&2, String>, nb_contains(hot, "*"), u => hot, u => nh_definitions(book, rest, nt_choose(List<&2, String>, nc_native_def(d) || nc_foreign(d), v => hot, v => nh_terms(book, nc_compact_definition(book, d, 0), [dv(d)], hot))))

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

# A checked recursive root can be cold even when its root reference is shared:
# every destructive consumer must borrow while shared, or be a scheduler-only
# root-preserving observer. Unregistered helpers, bangs and private bypasses
# prevent this stronger certificate. Ordinary release remains safe on cold
# children; immutable borrowed walks only peek while retaining an owning root.
@unsafe
def nh_ctor_names(cs: List<&2, KDef>) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{c, rest}: Con{nc_ctor_encode(dn(c)), nh_ctor_names(rest)}

@unsafe
def nh_matches(ts: List<&2, KTerm>, +ctors: List<&2, String>) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{+t, +rest}:
      nt_choose(Bool, String.eq(tg(t), "Mat") && nb_contains(ctors, nm(t)), u => True{}, u => nh_matches(nt_append(KTerm, ks(t), rest), ctors))

@unsafe
def nh_borrowed(+name: String, +entries: List<&2, KDef>, +ready: List<&2, String>) -> Bool:
  +entry = lookup(entries, nd_name(name))
  String.eq(dk(entry), "NOScalarObserver") || (String.eq(dk(entry), "NOObserverEntry") && Bool.not(nb_contains(ready, name) || nb_contains(ready, "$product." ++ name)))

@unsafe
def nh_consumers(+book: List<&2, KDef>, names: List<&2, String>, +all: List<&2, String>, +ctors: List<&2, String>, +entries: List<&2, KDef>, +ready: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+name, +rest}:
      nt_choose(Bool, nh_matches([nc_compact_definition(book, lookup(book, name), 0)], ctors),
        u => nt_choose(Bool, nh_borrowed(name, entries, ready), v => nh_direct_uses(book, all, name, nd_arity(book, name)) && nh_consumers(book, rest, all, ctors, entries, ready), v => False{}),
        u => nh_consumers(book, rest, all, ctors, entries, ready))

@unsafe
def nh_cold_undef(ctors: List<&2, String>) -> String:
  match ctors:
    case Nil{}: ""
    case Con{ctor, rest}: "#undef NATIVE_HOT_" ++ nt_cid(ctor) ++ "\n" ++ nh_cold_undef(rest)

@unsafe
def nh_observer_types(+book: List<&2, KDef>, types: List<&2, KTerm>, +names: List<&2, String>, +entries: List<&2, KDef>, +ready: List<&2, String>, +seen: List<&2, String>) -> String:
  match types:
    case Nil{}: ""
    case Con{+ty, +rest}:
      +d = lookup(book, nm(ty))
      +ctors = nh_ctor_names(dc(d))
      nt_choose(String, nb_contains(seen, nm(ty)), u => nh_observer_types(book, rest, names, entries, ready, seen), u =>
        nt_choose(String, String.eq(dk(d), "ADT") && Bool.not(db(d)) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0),
          v => nt_choose(String, nh_consumers(book, names, names, ctors, entries, ready), w => nh_cold_undef(ctors), w => ""), v => "") ++ nh_observer_types(book, rest, names, entries, ready, Con{nm(ty), seen}))

@unsafe
def nh_entry_types(entries: List<&2, KDef>) -> List<&2, KTerm>:
  match entries:
    case Nil{}: Nil{}
    case Con{entry, rest}: nt_append(KTerm, ks(dt(entry)), nh_entry_types(rest))

@unsafe
def nh_observer_macros(+book: List<&2, KDef>, +entries: List<&2, KDef>, +ready: List<&2, String>) -> String:
  nt_choose(String, List.is_empty(&2, KDef, entries), u => "", u =>
    "#if !DEVICE && NATIVE_COLD_CTORS\n" ++ nh_observer_types(book, nh_entry_types(entries), nc_live_names(book, ["main"], Nil{}), book_cached(entries, 0), ready, Nil{}) ++ "#endif\n")

# A partial application reaches the original closure body, not necessarily its
# direct observer entry. Refuse this escape even when all named matches qualify.
@unsafe
def nh_saturated(ts: List<&2, KTerm>, +owner: String, +arity: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t, +rest}:
      +head = nd_head(t)
      nt_choose(Bool, String.eq(tg(head), "Ref") && String.eq(nm(head), owner),
        u => Bool.not(U32.is_eq(qt(head), 3)) && U32.is_eq(terms_len(nd_args(t, Nil{})), arity) && nh_saturated(nt_append(KTerm, nd_args(t, Nil{}), rest), owner, arity),
        u => nh_saturated(nt_append(KTerm, ks(t), rest), owner, arity))

@unsafe
def nh_direct_uses(+book: List<&2, KDef>, names: List<&2, String>, +owner: String, +arity: U32) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}: nt_choose(Bool, nh_saturated([nc_compact_definition(book, lookup(book, name), 0)], owner, arity), u => nh_direct_uses(book, rest, owner, arity), u => False{})

# Monomorphic constructor fields retain their checked scalar width across
# matches and private flat transport. Parametric/indexed fields stay opaque.
@unsafe
def nh_field_test(+ctor: String, +i: U32) -> String:
  "!DEVICE && NATIVE_FIELD32_" ++ nt_cid(ctor) ++ "_" ++ U32.show(i)

@unsafe
def nh_field_type(+ctor: String, +i: U32) -> String:
  "#if " ++ nh_field_test(ctor, i) ++ "\nu32\n#else\nTerm\n#endif\n"

@unsafe
def nh_cast_words(+ctor: String, words: List<&2, String>, +i: U32) -> String:
  match words:
    case Nil{}: ""
    case Con{+word, rest}: "#if " ++ nh_field_test(ctor, i) ++ "\n" ++ word ++ " = (u32)" ++ word ++ ";\n#endif\n" ++ nh_cast_words(ctor, rest, U32.inc(i))

@unsafe
def nh_field_telescope(+book: List<&2, KDef>, +ctor: String, +ty: KTerm, +left: U32, +i: U32) -> String:
  nt_choose(String, U32.is_eq(left, 0) || U32.is_gt(left, 8), u => "", u => nh_field_header(book, ctor, nq_layout_type(book, ty), left, i))

@unsafe
def nh_field_header(+book: List<&2, KDef>, +ctor: String, +head: KTerm, +left: U32, +i: U32) -> String:
  nt_choose(String, String.eq(tg(head), "All"), u =>
    nt_choose(String, Bool.not(U32.is_eq(qt(head), 0)) && ns_scalar(book, kid(head, 0)), v => "#define NATIVE_FIELD32_" ++ nt_cid(ctor) ++ "_" ++ U32.show(i) ++ " 1\n", v => "") ++ nh_field_telescope(book, ctor, kid(head, 1), U32.sub(left, 1), U32.add(i, nt_bool(Bool.not(U32.is_eq(qt(head), 0))))), u => "")

@unsafe
def nh_field_ctors(+book: List<&2, KDef>, cs: List<&2, KDef>) -> String:
  match cs:
    case Nil{}: ""
    case Con{+c, rest}: nh_field_telescope(book, nc_ctor_encode(dn(c)), dt(c), da(c), 0) ++ nh_field_ctors(book, rest)

@unsafe
def nh_field_macros(+book: List<&2, KDef>, ds: List<&2, KDef>) -> String:
  match ds:
    case Nil{}: ""
    case Con{+d, rest}:
      nt_choose(String, String.eq(dk(d), "ADT") && Bool.not(db(d)) && U32.is_eq(da(d), 0) && U32.is_eq(dx(d), 0), u => nh_field_ctors(book, dc(d)), u => "") ++ nh_field_macros(book, rest)

@unsafe
def nh_param_facts(args: List<&2, KTerm>, +env: List<&2, NC_Binding>) -> String:
  match args:
    case Nil{}: ""
    case Con{+arg, rest}: nt_choose(String, String.eq(tg(arg), "NQBundle"), u => nh_cast_words(nm(arg), nc_values(ks(arg), env), 0), u => "") ++ nh_param_facts(rest, env)
