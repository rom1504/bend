
# Module: src/front/unicode.bend:2
type FDecoded is Data:
  FDecoded{code: U32, +rest: String, +error: String}

# Module: src/front/unicode.bend:5
law f_decode_char:
  for +s: String
  FDecoded

# Module: src/front/unicode.bend:9
law f_decode_escape:
  for +s: String
  FDecoded

# Module: src/front/unicode.bend:13
law f_escape_valid:
  for +c: Char
  Bool

# Module: src/front/unicode.bend:17
law f_decode_unicode:
  for +s: String
  for +code: U32
  for +count: U32
  FDecoded

# Module: src/front/unicode.bend:23
law f_char_literal:
  for +s: String
  KTerm

# Module: src/front/unicode.bend:27
law f_char_decoded:
  for +d: FDecoded
  KTerm

# Module: src/front/unicode.bend:32
@unsafe
def f_decode_char(s):
  f_choose(FDecoded, String.is_empty(s), u => FDecoded{0, "", "expected character"}, u => f_choose(FDecoded, Char.is_eq(f_head(s), '\\'), u => f_decode_escape(f_tail(s)), u => FDecoded{Char.to_u32(f_head(s)), f_tail(s), ""}))

# Module: src/front/unicode.bend:36
@unsafe
def f_decode_escape(s):
  f_choose(FDecoded, Char.is_eq(Char.to_lower(f_head(s)), 'u') && Char.is_eq(f_head(f_tail(s)), '{'), u => f_decode_unicode(f_tail(f_tail(s)), 0, 0), u => f_choose(FDecoded, f_escape_valid(f_head(s)), u => FDecoded{f_escape_code(f_head(s)), f_tail(s), ""}, u => FDecoded{0, s, "invalid character escape"}))

# Module: src/front/unicode.bend:40
@unsafe
def f_escape_valid(c):
  Char.is_eq(c, 'n') || Char.is_eq(c, 't') || Char.is_eq(c, 'r') || Char.is_eq(c, '0') || Char.is_eq(c, '\\') || Char.is_eq(c, '\'') || Char.is_eq(c, '"')

# Module: src/front/unicode.bend:44
@unsafe
def f_hex(
  +c: Char,
) -> U32:
  f_choose(U32, Char.is_digit(c), u => U32.sub(Char.to_u32(c), 48), u => f_choose(U32, U32.is_ge(Char.to_u32(Char.to_lower(c)), 97) && U32.is_le(Char.to_u32(Char.to_lower(c)), 102), u => U32.sub(Char.to_u32(Char.to_lower(c)), 87), u => 16))

# Upstream permits one to eight hex digits, including non-scalar U32 values.
# The digit limit rejects overflow spellings before U32 accumulation can wrap.
# Module: src/front/unicode.bend:50
@unsafe
def f_decode_unicode(s, code, count):
  f_choose(FDecoded, Char.is_eq(f_head(s), '}') && U32.is_gt(count, 0), u => FDecoded{code, f_tail(s), ""}, u => f_choose(FDecoded, U32.is_lt(f_hex(f_head(s)), 16) && U32.is_lt(count, 8), u => f_decode_unicode(f_tail(s), U32.add(U32.mul(code, 16), f_hex(f_head(s))), U32.add(count, 1)), u => FDecoded{0, s, "invalid Unicode escape"}))

# Module: src/front/unicode.bend:54
@unsafe
def f_char_literal(s):
  f_char_decoded(f_decode_char(s))

# Module: src/front/unicode.bend:58
@unsafe
def f_char_decoded(d):
  match d:
    case FDecoded{code, +rest, +err}:
      f_choose(KTerm, String.is_empty(err) && f_eq(rest, "'"), u => kt("Ctr", "Chr", 0, 1, [f_u32(code)]), u => kt("Error", "character literal requires one character and a closing quote", 0, 0, Nil{}))

# Module: src/front/unicode.bend:64
@unsafe
def f_float_bits(
  +bits: U32,
) -> KTerm:
  f_choose(KTerm, U32.is_eq(U32.and(bits, 2139095040), 2139095040), u => kt("Error", "float literal must be finite", 0, 0, Nil{}), u => kl_make("F32", bits, ""))

# Module: src/front/unicode.bend:71
@unsafe
def f_string_decoded_at(+d: FDecoded, +origin: KTerm) -> KTerm:
  match d:
    case FDecoded{code, rest, err}:
      f_choose(KTerm, String.is_empty(err), u => f_string_cons(code, f_string_at(rest, origin)),
        u => f_choose(KTerm, U32.is_gt(kb(origin), 0), u => f_escape_seek(origin, f_tail(nm(origin)), err), u => kt("Error", err, 0, 0, Nil{})))

# Module: src/front/unicode.bend:78
@unsafe
def f_escape_seek(+origin: KTerm, +rest: String, +legacy: String) -> KTerm:
  f_choose(KTerm, String.is_empty(rest) || Char.is_eq(f_head(rest), '"'), u => kt("Error", legacy, 0, 0, Nil{}),
    u => f_escape_decoded(origin, rest, legacy, f_decode_char(rest)))

# Module: src/front/unicode.bend:83
@unsafe
def f_escape_decoded(+origin: KTerm, +rest: String, +legacy: String, +decoded: FDecoded) -> KTerm:
  match decoded:
    case FDecoded{code, tail, error}:
      f_choose(KTerm, String.is_empty(error), u => f_escape_seek(origin, tail, legacy),
        u => fpe_expected_at(k_with_span(origin, U32.add(U32.sub(ke(origin), dg_width(rest)), 2), U32.add(U32.sub(ke(origin), dg_width(rest)), 2)), legacy, "an escape (\\n \\t \\r \\0 \\\\ \\\' \\\" \\u{1F600})", "'" ++ SCon{f_head(f_tail(f_tail(rest))), ""} ++ "'"))

# Invalid scalar escapes keep the reference constructor-chain representation.

# Module: src/front/unicode.bend:91
@unsafe
def f_string_cons(+code: U32, +tail: KTerm) -> KTerm:
  f_choose(KTerm, U32.is_le(code, 1114111) && (U32.is_lt(code, 55296) || U32.is_gt(code, 57343)),
    u => f_choose(KTerm, core_literal(tail) && p88_string_eq(nm(tail), "String"), u => kl_make("String", 0, SCon{Char.from_u32(code), kl_text(tail)}), u => kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(code)]), tail])),
    u => kt("Ctr", "SCon", 0, 1, [kt("Ctr", "Chr", 0, 1, [f_u32(code)]), f_string_expand(tail)]))

# Module: src/front/unicode.bend:97
@unsafe
def f_string_expand(+t: KTerm) -> KTerm:
  f_choose(KTerm, core_literal(t) && p88_string_eq(nm(t), "String"), u => f_string_expand(core_literal_step(t)),
    u => f_choose(KTerm, p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "SCon"), u => k_with_children(t, [kid(t, 0), f_string_expand(kid(t, 1))]), u => t))
