# Canonical array effects share one typed contract in both private layouts.
# No operation name alone authorizes lowering: the source native owner, erased
# kind, complete live telescope and element-preserving result are checked.
@unsafe
def j_array_effect_element(+book: List<&2,KDef>, +ty: KTerm) -> String:
  +head = wnf(book, ty)
  kc(String, j_primitive_type(book, head, "U32"), u => "U32", u =>
    kc(String, j_primitive_type(book, head, "F32"), u => "F32", u => ""))

@unsafe
def j_array_effect_array(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, String.eq(tg(ty), "ADT") && String.eq(nm(ty), "Array") &&
    U32.is_eq(terms_len(ks(ty)), 1) && List.is_empty(&2, String, rm(ty)) &&
    j_u32_native_ctor(book, "Array", "ALeaf") && j_u32_native_ctor(book, "Array", "ANode"),
    u => Bool.not(String.eq(j_array_effect_element(book, kid(ty, 0)), "")), u => False{})

@unsafe
def j_array_effect_array_of(+book: List<&2,KDef>, +ty: KTerm, +element: String) -> Bool:
  kc(Bool, j_array_effect_array(book, ty),
    u => String.eq(j_array_effect_element(book, kid(ty, 0)), element), u => False{})

@unsafe
def j_array_effect_known(+name: String) -> Bool:
  String.contains("|Array.new|Array.get|Array.set|Array.swap|Array.size|", "|" ++ name ++ "|")

@unsafe
def j_array_effect_arity(+name: String) -> U32:
  kc(U32, String.eq(name, "Array.size"), u => 2, u =>
    kc(U32, String.eq(name, "Array.set") || String.eq(name, "Array.swap"), u => 4, u => 3))

@unsafe
def j_array_effect_native(+book: List<&2,KDef>, +spine: KTerm) -> Bool:
  kc(Bool, String.eq(nm(spine), "F32.to_u32"), u =>
    String.eq(tg(spine), "Call") && U32.is_eq(terms_len(ks(spine)), 1) && j_pure_native(book, lookup(book, nm(spine))), u =>
    kc(Bool, String.eq(tg(spine), "Call") && j_array_effect_known(nm(spine)) &&
      U32.is_eq(terms_len(ks(spine)), j_array_effect_arity(nm(spine))),
      u => j_array_effect_definition(book, lookup(book, nm(spine)), kid(spine, 0)), u => False{}))

@unsafe
def j_array_effect_definition(+book: List<&2,KDef>, +d: KDef, +element: KTerm) -> Bool:
  kc(Bool, String.eq(dk(d), "Def") && db(d) && U32.is_eq(dx(d), 0) &&
    U32.is_eq(da(d), j_array_effect_arity(dn(d))) &&
    Bool.not(String.eq(tg(j_strip(dv(d))), "Foreign")),
    u => j_array_effect_definition_head(book, d, element, wnf(book, dt(d))), u => False{})

# Bool.and evaluates both operands. Reject nonnative/live argument positions
# before asking normalization to interpret the erased element as a type.
@unsafe
def j_array_effect_definition_head(+book: List<&2,KDef>, +d: KDef, +element: KTerm, +head: KTerm) -> Bool:
  kc(Bool, String.eq(tg(head), "All") && U32.is_eq(qt(head), 0),
    u => j_array_effect_definition_element(book, d, element, head, j_array_effect_element(book, element)), u => False{})

@unsafe
def j_array_effect_definition_element(+book: List<&2,KDef>, +d: KDef, +element: KTerm, +head: KTerm, +name: String) -> Bool:
  kc(Bool, Bool.not(String.eq(name, "")), u => j_array_effect_kind(book, kid(head, 0), dn(d)) &&
    j_array_effect_telescope(book, j_app_type(head, element), dn(d), name, 1, da(d)), u => False{})

@unsafe
def j_array_effect_kind(+book: List<&2,KDef>, +ty: KTerm, +name: String) -> Bool:
  +head = wnf(book, ty)
  String.eq(tg(head), "Typ") && U32.is_eq(terms_len(ks(head)), 1) && String.eq(tg(kid(head, 0)), "Qua") &&
    U32.is_eq(qt(kid(head, 0)), kc(U32, String.eq(name, "Array.new") || String.eq(name, "Array.get"), u => 2, u => 1))

@unsafe
def j_array_effect_telescope(+book: List<&2,KDef>, +ty: KTerm, +name: String, +element: String, +at: U32, +total: U32) -> Bool:
  +head = wnf(book, ty)
  kc(Bool, U32.is_eq(at, total), u =>
    kc(Bool, String.eq(name, "Array.new") || String.eq(name, "Array.set"),
      u => j_array_effect_array_of(book, head, element),
      u => j_array_effect_pair_of(book, head, element, kc(String, String.eq(name, "Array.size"), u => "U32", u => element))), u =>
    kc(Bool, String.eq(tg(head), "All") && Bool.not(U32.is_eq(qt(head), 0)) &&
      j_array_effect_input(book, wnf(book, kid(head, 0)), name, element, at),
      u => j_array_effect_telescope(book, kid(head, 1), name, element, U32.inc(at), total), u => False{}))

@unsafe
def j_array_effect_input(+book: List<&2,KDef>, +ty: KTerm, +name: String, +element: String, +at: U32) -> Bool:
  kc(Bool, U32.is_eq(at, 1), u =>
    kc(Bool, String.eq(name, "Array.new"), u => j_primitive_type(book, ty, "Nat"), u => j_array_effect_array_of(book, ty, element)),
    u => j_primitive_type(book, ty, kc(String, String.eq(name, "Array.new") || U32.is_eq(at, 3), u => element, u => "U32")))

# General read consumers accept both element-valued and size-valued pairs.
# Native admission below still checks its exact expected array/value types.
@unsafe
def j_array_effect_pair(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  kc(Bool, j_region_local_sigma(book, ty), u =>
    j_array_effect_pair_fields(book, wnf(book, j_region_local_fields(book, ty)), "", ""), u => False{})

@unsafe
def j_array_effect_pair_of(+book: List<&2,KDef>, +ty: KTerm, +element: String, +value: String) -> Bool:
  kc(Bool, j_region_local_sigma(book, ty), u =>
    j_array_effect_pair_fields(book, wnf(book, j_region_local_fields(book, ty)), element, value), u => False{})

@unsafe
def j_array_effect_pair_fields(+book: List<&2,KDef>, +tel: KTerm, +element: String, +value: String) -> Bool:
  +array = wnf(book, kid(tel, 0))
  +rest = wnf(book, kid(tel, 1))
  +item = wnf(book, kid(rest, 0))
  String.eq(tg(tel), "All") && Bool.not(U32.is_eq(qt(tel), 0)) && j_array_effect_array(book, array) &&
    (String.eq(element, "") || String.eq(j_array_effect_element(book, kid(array, 0)), element)) &&
    String.eq(tg(rest), "All") && Bool.not(U32.is_eq(qt(rest), 0)) &&
    kc(Bool, String.eq(value, ""), u => j_primitive_type(book, item, "U32") ||
      String.eq(j_array_effect_element(book, item), j_array_effect_element(book, kid(array, 0))),
      u => j_primitive_type(book, item, value)) &&
    String.eq(tg(wnf(book, kid(rest, 1))), "ADT") && String.eq(nm(wnf(book, kid(rest, 1))), "Sigma")

# Values are evaluated once in source order before the effect. A swap deliberately
# performs TWO Number conversions/length reads. F32 stores add no new rounding.
@unsafe
def j_array_effect_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +raw: Bool) -> String:
  kc(String, String.eq(nm(t), "F32.to_u32"),
    u => "regionF32ToU32(" ++ j_apply_args(book, env, ks(t), dt(lookup(book, nm(t)))) ++ ")", u =>
    kc(String, raw,
      u => j_array_effect_raw(nm(t)) ++ j_apply_args(book, env, ks(t), dt(lookup(book, nm(t)))) ++ ")",
      u => kc(String, String.eq(nm(t), "Array.new"),
        u => "((_t,d,v)=>arrayfill(v,d,'^'))(" ++ j_apply_args(book, env, ks(t), dt(lookup(book, nm(t)))) ++ ")",
        u => j_array_effect_handles(book, env, t, ks(t)))))

@unsafe
def j_array_effect_raw(+name: String) -> String:
  kc(String, String.eq(name, "Array.new"), u => "((_t,d,v)=>arrayfill(v,d,'^').array)(", u =>
  kc(String, String.eq(name, "Array.get"), u => "((_t,a,i)=>[a,a[Number(i)%a.length]])(", u =>
  kc(String, String.eq(name, "Array.set"), u => "((_t,a,i,v)=>{a[Number(i)%a.length]=v;return a;})(", u =>
  kc(String, String.eq(name, "Array.swap"), u => "((_t,a,i,v)=>{const old=a[Number(i)%a.length];a[Number(i)%a.length]=v;return [a,old];})(",
    u => "((_t,a)=>[a,a.length])("))))

@unsafe
def j_array_effect_handles(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +args: List<&2,KTerm>) -> String:
  match args:
    case Nil{}: "undefined"
    case Con{erased, live}:
      kc(String, String.eq(nm(t), "Array.get"), u => "arrayget(", u =>
      kc(String, String.eq(nm(t), "Array.set"), u => "arrayset(", u =>
      kc(String, String.eq(nm(t), "Array.swap"), u => "((a,i,v)=>{const old=arrayget(a,i)[1];return [arrayset(a,i,v),old];})(",
        u => "(a=>[a,arraydata(a).length])("))) ++
      j_apply_args(book, env, live, j_app_type(wnf(book, dt(lookup(book, nm(t)))), erased)) ++ ")"
