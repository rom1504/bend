# Checked-entry certificate. Raw nc_compile never consumes this analysis.
# Every array representation demand must agree on a scalar element layout.
@unsafe
def ns_scalar(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  String.eq(tg(head), "ADT") && db(lookup(book, nm(head))) && nb_contains(["U32", "F32", "Char"], nm(head))

@unsafe
def ns_array_type(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  String.eq(tg(head), "ADT") && String.eq(nm(head), "Array") && db(lookup(book, "Array")) && ns_scalar(book, kid(head, 0))

@unsafe
def ns_generic_array(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  String.eq(tg(t), "Ref") && nc_native_def(lookup(book, nm(t))) && nb_contains(["array_new", "array_get", "array_set", "array_swap", "array_size", "array_clone"], nc_primitive_name(nm(t)))

@unsafe
def ns_array_pattern(+t: KTerm) -> Bool:
  (String.eq(tg(t), "Ctr") || String.eq(tg(t), "Mat")) && (String.eq(nm(t), "ALeaf") || String.eq(nm(t), "ANode"))

@unsafe
def ns_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: ns_term(book, h) && ns_terms(book, rest)

@unsafe
def ns_annotated(+book: List<&2, KDef>, +value: KTerm, +ty: KTerm) -> Bool:
  nt_choose(Bool, ns_array_pattern(value),
    u => ns_array_type(book, nt_choose(KTerm, String.eq(tg(value), "Mat"), v => kid(nq_layout_type(book, ty), 0), v => ty)) && ns_terms(book, ks(value)),
    u => ns_term(book, value))

@unsafe
def ns_term(+book: List<&2, KDef>, +t: KTerm) -> Bool:
  nt_choose(Bool, String.eq(tg(t), "Ann"), u => ns_annotated(book, kid(t, 0), kid(t, 1)), u =>
  nt_choose(Bool, String.eq(tg(t), "Rwt") || ns_array_pattern(t), u => False{}, u =>
  nt_choose(Bool, String.eq(tg(t), "App") && ns_generic_array(book, nc_unann(kid(t, 0))), u => ns_scalar(book, kid(t, 1)), u =>
  nt_choose(Bool, ns_generic_array(book, t), u => False{}, u => ns_terms(book, ks(t))))))

@unsafe
def ns_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      (nc_native_def(d) || nt_choose(Bool, nc_foreign(d),
        u => db(d) && nb_contains(["IO.args", "IO.print", "IO.now"], dn(d)),
        u => ns_term(book, dv(d)))) && ns_definitions(book, rest)

# Preconditions: checked/specialized/annotated book, validated layouts, trusted
# runtime and effect ABI. The host proves the narrow effect-source permission.
@unsafe
def nc_compile_checked(+book: List<&2, KDef>, runtime: String, requests: String, effects_safe: Bool) -> NC_Result:
  +names = nc_live_names(book, ["main"], Nil{})
  +packed = effects_safe && ns_definitions(book, names)
  +unshared = packed && ns_unshared_definitions(book, names)
  nc_compile(book, "#define NATIVE_TYPED_SCALARS " ++ nt_choose(String, packed, u => "1", u => "0") ++ "\n#define NATIVE_COLD_USER_CTORS " ++ nt_choose(String, unshared, u => "1", u => "0") ++ "\n#define NATIVE_SCALAR_ARRAYS " ++ nt_choose(String, packed, u => "1", u => "0") ++ "\n#define NATIVE_UNSHARED_ARRAYS " ++ nt_choose(String, unshared, u => "1", u => "0") ++ "\n" ++ runtime, requests)

# Conservative array-free values. Functions/IO can capture arrays, so decline.
# Container parameters are inspected recursively; an unknown type stays opaque.
@unsafe
def ns_array_free(+book: List<&2, KDef>, +ty: KTerm) -> Bool:
  +head = nq_layout_type(book, ty)
  nt_choose(Bool, String.eq(tg(head), "Qua") || String.eq(tg(head), "Qnt"), u => True{}, u =>
  nt_choose(Bool, String.eq(tg(head), "Lam"), u => ns_array_free(book, kid(head, 0)), u =>
    String.eq(tg(head), "ADT") && db(lookup(book, nm(head))) && nb_contains(["Nat", "U32", "F32", "Char", "Bool", "Unit", "String", "List", "Maybe", "Result", "Sigma", "Word.Nil", "Word.Con"], nm(head)) && ns_types_free(book, ks(head))))

@unsafe
def ns_types_free(+book: List<&2, KDef>, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{h, rest}: ns_array_free(book, h) && ns_types_free(book, rest)

@unsafe
def ns_unshared_terms(+book: List<&2, KDef>, +body: KTerm, ts: List<&2, KTerm>) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t, +rest}:
      nt_choose(Bool, String.eq(tg(t), "Ann"),
        u => nt_choose(Bool, String.eq(tg(kid(t, 0)), "Var"),
          v => nt_choose(Bool, ns_array_free(book, kid(t, 1)), w => ns_unshared_terms(book, body, rest), w => nt_choose(Bool, U32.is_le(nq_uses(body, ix(kid(t, 0))), 1), x => ns_unshared_terms(book, body, rest), x => False{})),
          v => ns_unshared_terms(book, body, Con{kid(t, 0), rest})),
        u => nt_choose(Bool, String.eq(tg(t), "Var"),
          v => nt_choose(Bool, U32.is_le(nq_uses(body, ix(t)), 1), w => ns_unshared_terms(book, body, nt_append(KTerm, ks(t), rest)), w => False{}),
          v => ns_unshared_terms(book, body, nt_append(KTerm, ks(t), rest))))

@unsafe
def ns_unshared_definitions(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      (nc_native_def(d) || nc_foreign(d) || ns_unshared_terms(book, nc_erase(book, dv(d)), [dv(d)])) && ns_unshared_definitions(book, rest)
