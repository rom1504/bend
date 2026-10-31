
# Module: src/back/native/scalar-array.bend:4
@unsafe
def ns_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  p98_tag_eq(head, "ADT") && db(lookup(book, nm(head))) && nb_contains(["U32", "F32", "Char", "Bool"], nm(head))

# Module: src/back/native/scalar-array.bend:9
@unsafe
def ns_array_type(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  nt_choose(Bool, p98_tag_eq(head, "ADT") && p88_string_eq(nm(head), "Array") && db(lookup(book, "Array")),
    u => ns_scalar(book, kid(head, 0)), u => False{})

# Module: src/back/native/scalar-array.bend:15
@unsafe
def ns_generic_array(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Ref"),
    u => nt_choose(Bool, nc_native_def(lookup(book, nm(t))),
      v => nb_contains(["array_new", "array_get", "array_set", "array_swap", "array_size", "array_clone"], nc_primitive_name(nm(t))), v => False{}), u => False{})

# Module: src/back/native/scalar-array.bend:21
@unsafe
def ns_array_pattern(+t: KTerm) -> Bool:
  (p98_tag_eq(t, "Ctr") || p98_tag_eq(t, "Mat")) && (p88_string_eq(nm(t), "ALeaf") || p88_string_eq(nm(t), "ANode"))

# Module: src/back/native/scalar-array.bend:25
@unsafe
def ns_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_term(book, h), u => ns_terms(book, rest), u => False{})

# Module: src/back/native/scalar-array.bend:31
@unsafe
def ns_annotated(+book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  nt_choose(Bool, ns_array_pattern(value),
    u => ns_array_type(book, nt_choose(KTerm, p98_tag_eq(value, "Mat"), v => kid(nq_layout_type(book, ty), 0), v => ty)) && ns_terms(book, ks(value)),
    u => ns_term(book, value))

# Module: src/back/native/scalar-array.bend:37
@unsafe
def ns_term(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool, p98_tag_eq(t, "Ann"), u => ns_annotated(book, kid(t, 0), kid(t, 1)), u =>
  nt_choose(Bool, p98_tag_eq(t, "Rwt") || ns_array_pattern(t), u => False{}, u =>
  nt_choose(Bool, nt_choose(Bool, p98_tag_eq(t, "App"), v => ns_generic_array(book, nc_unann(kid(t, 0))), v => False{}), u => ns_scalar(book, kid(t, 1)), u =>
  nt_choose(Bool, ns_generic_array(book, t), u => False{}, u => ns_terms(book, ks(t))))))

# Module: src/back/native/scalar-array.bend:44
@unsafe
def ns_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d), u => True{}, u => nt_choose(Bool, nc_foreign(d),
        v => db(d) && nb_contains(["IO.args", "IO.print", "IO.now"], dn(d)),
        v => ns_term(book, dv(d)))), u => ns_definitions(book, rest), u => False{})

@unsafe
def nc_compile_checked(+book: List<&2, KDef>, runtime: String, requests: String, +effects_safe: Bool) -> NC_Result:
  +names = nc_live_names(book, ["main"], Nil{})
  +packed = nt_choose(Bool, effects_safe, u => ns_definitions(book, names), u => False{})
  +unshared = nt_choose(Bool, packed, u => ns_unshared_definitions(book, names), u => False{})
  +observers = nt_choose(Bool, effects_safe, u => no_effect_definitions(book, names), u => False{})
  +error = nc_compile_error(book)
  nt_choose(NC_Result, String.eq(error, ""), u =>
    ns_compile_scoped(book, NE_Text{ns_checked_runtime(book, runtime, packed, unshared)}, requests, observers, packed),
    u => NC_Result{"", error})

# Module: src/back/native/scalar-array.bend:67
@unsafe
def ns_checked_runtime(+book: List<&2, KDef>, +runtime: String, +packed: Bool, +unshared: Bool) -> String:
  nt_choose(String, packed, u => nh_field_macros(book, book), u => "") ++ "#define NATIVE_TYPED_SCALARS " ++ nt_choose(String, packed, u => "1", u => "0") ++ "\n#define NATIVE_COLD_USER_CTORS " ++ nt_choose(String, unshared, u => "1", u => "0") ++ "\n#define NATIVE_SCALAR_ARRAYS " ++ nt_choose(String, packed, u => "1", u => "0") ++ "\n#define NATIVE_UNSHARED_ARRAYS " ++ nt_choose(String, unshared, u => "1", u => "0") ++ "\n" ++ runtime

# Conservative array-free values. Functions/IO can capture arrays, so decline.
# Container parameters are inspected recursively; an unknown type stays opaque.

# Module: src/back/native/scalar-array.bend:73
@unsafe
def ns_array_free(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  nt_choose(Bool, p98_tag_eq(head, "Qua") || p98_tag_eq(head, "Qnt"), u => True{}, u =>
  nt_choose(Bool, p98_tag_eq(head, "Lam"), u => ns_array_free(book, kid(head, 0)), u =>
    nt_choose(Bool, p98_tag_eq(head, "ADT") && db(lookup(book, nm(head))) && nb_contains(["Nat", "U32", "F32", "Char", "Bool", "Unit", "String", "List", "Maybe", "Result", "Sigma", "Word.Nil", "Word.Con"], nm(head)),
      u => ns_types_free(book, ks(head)), u => False{})))

# Module: src/back/native/scalar-array.bend:81
@unsafe
def ns_types_free(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: nt_choose(Bool, ns_array_free(book, h), u => ns_types_free(book, rest), u => False{})

# Module: src/back/native/scalar-array.bend:87
@unsafe
def ns_unshared_terms(+book: List<&2,KDef>, body: KTerm, terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p131u_unshared(book,p131u_build(body),Con{head,rest})

@unsafe
def ns_unshared_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d) || nc_foreign(d), u => True{}, u => ns_unshared_terms(book, nc_erase(book, dv(d)), [dv(d)])),
        u => ns_unshared_definitions(book, rest), u => False{})
