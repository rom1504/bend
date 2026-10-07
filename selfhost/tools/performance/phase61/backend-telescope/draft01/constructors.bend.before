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
  jd_ctor_inverse_scalar(env, t, ty, jd_ctor_inverse_field(env, j_strip(kid(t, 0)), nm(ty)))

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

# Fragment facts come only from canonical U32 numeric rows. Recomposition
# proves every one of 32 positions; unknown/moved/mixed-origin fields refuse.
# Literal prefix bits are reproduced, not assumed from the selected row test.
# Thus the final unconditional default row needs no additional branch fact.
type JDScalarBits is Data:
  JDScalarBits{+keep: U32, +literal: U32}

@unsafe
def jd_ctor_inverse_scalar(+env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +prior: String) -> String:
  kc(String, Bool.not(String.eq(prior, "")), u => prior, u =>
    kc(String, String.eq(nm(ty), "U32"), v =>
      jd_scalar_origin_done(env, j_strip(kid(t, 0)), jd_scalar_origin(env, j_strip(kid(t, 0)))), v => ""))

@unsafe
def jd_scalar_entry(+env: List<&2,KTerm>, +id: U32) -> KTerm:
  match env:
    case Nil{}: atom("Absent")
    case Con{entry, rest}:
      kc(KTerm, U32.is_eq(ix(entry), id),
        u => kc(KTerm, String.eq(tg(entry), "$JD.U32Fragment"), v => kid(entry, 1), v => atom("Absent")),
        u => jd_scalar_entry(rest, id))

@unsafe
def jd_scalar_origin(+env: List<&2,KTerm>, +t: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(t), "Var"), u => jd_scalar_entry(env, ix(t)), u =>
    kc(KTerm, String.eq(tg(t), "Ctr") && String.eq(nm(t), "WCon") && U32.is_eq(terms_len(ks(t)), 2),
      v => jd_scalar_origin_tail(env, j_strip(kid(t, 1)), jd_scalar_origin(env, j_strip(kid(t, 0)))),
      v => atom("Absent")))

@unsafe
def jd_scalar_origin_tail(+env: List<&2,KTerm>, +tail: KTerm, +head: KTerm) -> KTerm:
  kc(KTerm, String.eq(tg(head), "Absent"), u => jd_scalar_origin(env, tail), u => head)

@unsafe
def jd_scalar_origin_done(+env: List<&2,KTerm>, +word: KTerm, +origin: KTerm) -> String:
  kc(String, String.eq(tg(origin), "Bit") || String.eq(tg(origin), "Tail"),
    u => jd_scalar_result(nm(origin), jd_scalar_word(env, word, 0, nm(origin))), u => "")

@unsafe
def jd_scalar_result(+origin: String, +proof: Maybe<&2,JDScalarBits>) -> String:
  match proof:
    case None{}: ""
    case Some{bits}: jd_scalar_code(origin, bits)

@unsafe
def jd_scalar_code(+origin: String, +bits: JDScalarBits) -> String:
  match bits:
    case JDScalarBits{keep, literal}:
      "(\n/*JD_SCALAR_WORD*/((" ++ origin ++ "&" ++ U32.show(keep) ++ ")|" ++ U32.show(literal) ++ ")>>>0)"

@unsafe
def jd_scalar_word(+env: List<&2,KTerm>, +t: KTerm, +depth: U32, +origin: String) -> Maybe<&2,JDScalarBits>:
  kc(Maybe<&2,JDScalarBits>, String.eq(tg(t), "Var"),
    u => jd_scalar_tail(jd_scalar_entry(env, ix(t)), depth, origin), u =>
    kc(Maybe<&2,JDScalarBits>, String.eq(tg(t), "Ctr") && String.eq(nm(t), "WNil") &&
      U32.is_eq(depth, 32) && List.is_empty(&2,KTerm, ks(t)), v => Some{JDScalarBits{0, 0}}, v =>
      kc(Maybe<&2,JDScalarBits>, U32.is_lt(depth, 32) && String.eq(tg(t), "Ctr") &&
        String.eq(nm(t), "WCon") && U32.is_eq(terms_len(ks(t)), 2), w =>
        jd_scalar_join(jd_scalar_head(env, j_strip(kid(t, 0)), depth, origin),
          jd_scalar_word(env, j_strip(kid(t, 1)), U32.inc(depth), origin)), w => None{})))

@unsafe
def jd_scalar_tail(+view: KTerm, +depth: U32, +origin: String) -> Maybe<&2,JDScalarBits>:
  kc(Maybe<&2,JDScalarBits>, String.eq(tg(view), "Tail") && String.eq(nm(view), origin) &&
    U32.is_eq(ix(view), depth) && U32.is_le(depth, 32),
    u => Some{JDScalarBits{kc(U32, U32.is_eq(depth, 32), v => 0,
      v => U32.shln(4294967295, U32.to_nat(depth))), 0}}, u => None{})

@unsafe
def jd_scalar_head(+env: List<&2,KTerm>, +t: KTerm, +depth: U32, +origin: String) -> Maybe<&2,JDScalarBits>:
  kc(Maybe<&2,JDScalarBits>, String.eq(tg(t), "Var"),
    u => jd_scalar_bit(jd_scalar_entry(env, ix(t)), depth, origin), u =>
    kc(Maybe<&2,JDScalarBits>, String.eq(tg(t), "Ctr") && List.is_empty(&2,KTerm, ks(t)) &&
      (String.eq(nm(t), "True") || String.eq(nm(t), "False")),
      v => Some{JDScalarBits{0, kc(U32, String.eq(nm(t), "True"),
        w => U32.shln(1, U32.to_nat(depth)), w => 0)}}, v => None{}))

@unsafe
def jd_scalar_bit(+view: KTerm, +depth: U32, +origin: String) -> Maybe<&2,JDScalarBits>:
  kc(Maybe<&2,JDScalarBits>, String.eq(tg(view), "Bit") && String.eq(nm(view), origin) && U32.is_eq(ix(view), depth),
    u => Some{JDScalarBits{U32.shln(1, U32.to_nat(depth)), 0}}, u => None{})

@unsafe
def jd_scalar_join(+head: Maybe<&2,JDScalarBits>, +tail: Maybe<&2,JDScalarBits>) -> Maybe<&2,JDScalarBits>:
  match head:
    case None{}: None{}
    case Some{h}: jd_scalar_join_tail(h, tail)

@unsafe
def jd_scalar_join_tail(+head: JDScalarBits, +tail: Maybe<&2,JDScalarBits>) -> Maybe<&2,JDScalarBits>:
  match tail:
    case None{}: None{}
    case Some{t}: jd_scalar_join_bits(head, t)

@unsafe
def jd_scalar_join_bits(+head: JDScalarBits, +tail: JDScalarBits) -> Maybe<&2,JDScalarBits>:
  match head:
    case JDScalarBits{keep, literal}: jd_scalar_join_fields(keep, literal, tail)

@unsafe
def jd_scalar_join_fields(+keep: U32, +literal: U32, +tail: JDScalarBits) -> Maybe<&2,JDScalarBits>:
  match tail:
    case JDScalarBits{more, fixed}: Some{JDScalarBits{U32.or(keep, more), U32.or(literal, fixed)}}

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
        u => kc(String, U32.is_eq(qt(tel), 0),
          v => jd_ctor_fields(book, env, rest, j_app_type(tel, field)),
          v => jd_ctor_field_join(nm(tel), jd_expr(book, env, field, kid(tel, 0)),
            jd_ctor_fields(book, env, rest, j_app_type(tel, field)))),
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

# The final live constructor field and every __proto__ key stay computed.
@unsafe
def jd_ctor_field_join(+name: String, +value: String, +rest: String) -> String:
  "," ++ jd_literal_field_key(name, String.eq(rest, "")) ++ ":" ++ value ++ rest

@unsafe
def jd_literal_field_key(+name: String, +last: Bool) -> String:
  +quoted = j_quote(name)
  kc(String, last || String.eq(name, "__proto__"), u => "[" ++ quoted ++ "]", u => quoted)
