# Direct-mode layouts follow the pinned TypeScript backend. Constructor fields
# are selected from the checked, parameter-specialized telescope; erased source
# fields are never evaluated. Unit remains {$:"Unit"}, as in comp.ts.

@unsafe
def jd_ctor(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, core_literal(t), u => jd_ctor_literal(book, t),
    u => jd_ctor_type(book, env, t, wnf(book, ty)))

@unsafe
def jd_ctor_literal(+book: List<&2,KDef>, +t: KTerm) -> String:
  kc(String, db(lookup(book, nm(t))),
    u => kc(String, String.eq(nm(t), "String"), v => j_quote(kl_text(t)), v =>
      kc(String, String.eq(nm(t), "F32"), w => jd_float_literal(kl_number(t)), w =>
      kc(String, core_nat(t) || String.eq(nm(t), "U32"), z => U32.show(kl_number(t)),
        z => jd_fail("unsupported compact literal")))),
    u => jd_fail("compact literal has no native owner"))

@unsafe
def jd_ctor_type(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  kc(String, String.eq(tg(ty), "ADT"),
    u => jd_ctor_checked(book, env, t, ty, j_layout_ctor(book, ty, nm(t))),
    u => jd_fail("constructor needs a checked datatype"))

@unsafe
def jd_ctor_checked(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +ctor: KDef) -> String:
  kc(String, String.eq(dk(ctor), "Ctr"),
    u => jd_ctor_emit(book, env, t, ty, j_specialize(book, dt(ctor), ks(ty))),
    u => jd_fail("missing constructor telescope"))

@unsafe
def jd_ctor_emit(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tel: KTerm) -> String:
  jd_ctor_inverse_done(book, env, t, ty, tel, jd_ctor_inverse(env, t, ty))

@unsafe
def jd_ctor_inverse_done(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tel: KTerm, +inverse: String) -> String:
  kc(String, jd_native_layout(book, ty),
    u => kc(String, Bool.not(String.eq(inverse, "")), v => inverse, v =>
      kc(String, String.eq(nm(ty), "U32") || String.eq(nm(ty), "F32"),
      v => jd_ctor_word(book, env, t, ty, tel, j_word(j_strip(kid(t, 0)), 0, 0)),
      v => kc(String, String.eq(nm(ty), "Char"),
        w => jd_ctor_char(book, env, t, ty, tel, j_u32(kid(t, 0))),
        w => jd_ctor_native(nm(ty), nm(t), jd_ctor_values(book, env, ks(t), tel))))),
    u => "({$:" ++ j_quote(nm(t)) ++ jd_ctor_fields(book, env, ks(t), tel) ++ "})")

# Only the body emitter creates these entries for compiler-generated bare
# native views. Retain the original scalar alongside the textual view so inverse
# constructors never infer an optimization from arbitrary generated source.
@unsafe
def jd_view_binding(+id: U32, +ty: KTerm, +value: String) -> KTerm:
  kt("$JD.View", value, id, 0, [ty, jd_view_metadata(value)])

@unsafe
def jd_view_metadata(+value: String) -> KTerm:
  kc(KTerm, String.starts_with(value, "u32_to_word("),
    u => jd_word_metadata(String.take(String.drop(value, 12n), Nat.sub(String.length(value), 13n))),
    u => kt("Char", String.take(value, Nat.sub(String.length(value), 15n)), 0, 0, Nil{}))

@unsafe
def jd_word_metadata(+bits: String) -> KTerm:
  kc(KTerm, String.starts_with(bits, "f32_bits("),
    u => kt("F32", String.take(String.drop(bits, 9n), Nat.sub(String.length(bits), 10n)), 0, 0, Nil{}),
    u => kt("U32", bits, 0, 0, Nil{}))

@unsafe
def jd_ctor_inverse(+env: List<&2,KTerm>, +t: KTerm, +ty: KTerm) -> String:
  jd_ctor_inverse_field(env, j_strip(kid(t, 0)), nm(ty))

@unsafe
def jd_ctor_inverse_field(+env: List<&2,KTerm>, +field: KTerm, +owner: String) -> String:
  kc(String, String.eq(tg(field), "Var"),
    u => jd_ctor_inverse_env(env, ix(field), owner), u => "")

@unsafe
def jd_ctor_inverse_env(+env: List<&2,KTerm>, +id: U32, +owner: String) -> String:
  match env:
    case Nil{}: ""
    case Con{entry, rest}:
      kc(String, U32.is_eq(ix(entry), id),
        u => kc(String, String.eq(tg(entry), "$JD.View"),
          v => jd_ctor_inverse_view(id, owner, kid(entry, 1)), v => ""),
        u => jd_ctor_inverse_env(rest, id, owner))

@unsafe
def jd_ctor_inverse_view(+id: U32, +owner: String, +view: KTerm) -> String:
  +value = nm(view)
  +code = kc(String, String.eq(owner, "Char") && String.eq(tg(view), "Char"), u => value, u =>
    kc(String, String.eq(owner, "U32"), u =>
      kc(String, String.eq(tg(view), "U32"), v => value, v =>
        kc(String, String.eq(tg(view), "F32"), w => "f32_bits(" ++ value ++ ")", w => "")), u =>
    kc(String, String.eq(owner, "F32"), u =>
      kc(String, String.eq(tg(view), "F32"), v => value, v =>
        kc(String, String.eq(tg(view), "U32"), w => "f32_from_bits(" ++ value ++ ")", w => "")), u => "")))
  kc(String, String.eq(code, ""), u => "", u => "(" ++ jd_use(id) ++ code ++ ")")

# Like upstream ctr_adt and Char's intrinsic, fold closed literals before
# generating constructor fields. Runtime Word allocation and host conversion
# hooks must not be introduced for constants already resolved by the compiler.
@unsafe
def jd_ctor_word(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tel: KTerm, +value: Maybe<&2,U32>) -> String:
  match value:
    case None{}: jd_ctor_native(nm(ty), nm(t), jd_ctor_values(book, env, ks(t), tel))
    case Some{bits}: kc(String, String.eq(nm(ty), "F32"), u => jd_float_literal(bits), u => U32.show(bits))

@unsafe
def jd_ctor_char(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +tel: KTerm, +value: Maybe<&2,U32>) -> String:
  match value:
    case None{}: jd_ctor_native(nm(ty), nm(t), jd_ctor_values(book, env, ks(t), tel))
    case Some{code}:
      kc(String, U32.is_le(code, 1114111) && (U32.is_lt(code, 55296) || U32.is_gt(code, 57343)),
        u => j_quote(SCon{Char.from_u32(code), SNil{}}),
        u => "char_new(" ++ U32.show(code) ++ ")")

@unsafe
def jd_float_literal(+bits: U32) -> String:
  kc(String, j_private_float_finite(bits),
    u => kc(String, U32.is_eq(U32.and(bits, 2147483648), 0),
      v => j_private_float_magnitude(bits), v => "(-" ++ j_private_float_magnitude(bits) ++ ")"),
    u => kc(String, U32.is_eq(U32.and(bits, 8388607), 0),
      v => kc(String, U32.is_eq(U32.and(bits, 2147483648), 0), w => "Infinity", w => "(-Infinity)"),
      v => "NaN"))

# Native ownership is a property of the checked datatype, not a constructor
# spelling. The direct driver separately rejects unsupported/shadowed Base ABI.
@unsafe
def jd_native_layout(+book: List<&2,KDef>, +ty: KTerm) -> Bool:
  String.eq(tg(ty), "ADT") && db(lookup(book, nm(ty))) &&
    String.contains("|Nat|Bool|U32|F32|Char|String|Array|", "|" ++ nm(ty) ++ "|")

@unsafe
def jd_ctor_values(+book: List<&2,KDef>, +env: List<&2,KTerm>, +fields: List<&2,KTerm>, +tel: KTerm) -> List<&2,String>:
  match fields:
    case Nil{}:
      kc(List<&2,String>, String.eq(tg(tel), "All"),
        u => [jd_fail("missing constructor field")], u => Nil{})
    case Con{field, rest}:
      kc(List<&2,String>, String.eq(tg(tel), "All"),
        u => kc(List<&2,String>, U32.is_eq(qt(tel), 0),
          v => jd_ctor_values(book, env, rest, j_app_type(tel, field)),
          v => Con{jd_expr(book, env, field, kid(tel, 0)), jd_ctor_values(book, env, rest, j_app_type(tel, field))}),
        u => [jd_fail("extra constructor field")])

@unsafe
def jd_ctor_fields(+book: List<&2,KDef>, +env: List<&2,KTerm>, +fields: List<&2,KTerm>, +tel: KTerm) -> String:
  match fields:
    case Nil{}:
      kc(String, String.eq(tg(tel), "All"), u => ",[\"$error\"]:" ++ jd_fail("missing constructor field"), u => "")
    case Con{field, rest}:
      kc(String, String.eq(tg(tel), "All"),
        u => kc(String, U32.is_eq(qt(tel), 0), v => "",
          v => ",[" ++ j_quote(nm(tel)) ++ "]:" ++ jd_expr(book, env, field, kid(tel, 0))) ++
          jd_ctor_fields(book, env, rest, j_app_type(tel, field)),
        u => ",[\"$error\"]:" ++ jd_fail("extra constructor field"))

@unsafe
def jd_arg(+args: List<&2,String>, +index: U32) -> String:
  match args:
    case Nil{}: jd_fail("missing native constructor argument")
    case Con{arg, rest}:
      kc(String, U32.is_eq(index, 0), u => arg, u => jd_arg(rest, U32.sub(index, 1)))

@unsafe
def jd_ctor_native(+owner: String, +name: String, +args: List<&2,String>) -> String:
  kc(String, String.eq(owner, "Nat"),
    u => kc(String, String.eq(name, "Zero"), v => "0", v => "nat_chk((" ++ jd_arg(args, 0) ++ ")+1)"), u =>
  kc(String, String.eq(owner, "Bool"),
    u => kc(String, String.eq(name, "True"), v => "true", v => "false"), u =>
  kc(String, String.eq(owner, "U32"), u => "word_to_u32(" ++ jd_arg(args, 0) ++ ")", u =>
  kc(String, String.eq(owner, "F32"), u => "f32_from_bits(word_to_u32(" ++ jd_arg(args, 0) ++ "))", u =>
  kc(String, String.eq(owner, "Char"), u => "char_new(" ++ jd_arg(args, 0) ++ ")", u =>
  kc(String, String.eq(owner, "String"),
    u => kc(String, String.eq(name, "SNil"), v => "\"\"", v => "(" ++ jd_arg(args, 0) ++ "+" ++ jd_arg(args, 1) ++ ")"), u =>
  kc(String, String.eq(owner, "Array"),
    u => kc(String, String.eq(name, "ALeaf"), v => "[" ++ jd_arg(args, 0) ++ "]",
      v => "array_node(" ++ jd_arg(args, 0) ++ "," ++ jd_arg(args, 1) ++ ")"),
    u => jd_fail("unsupported native constructor"))))))))
