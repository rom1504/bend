
# Module: src/back/js/shared-text.bend:16
law j_escape_char:
  for +c: Char
  String

# Module: src/back/js/shared-text.bend:24
law j_escape_char_on:
  for +c: Char
  for +key: U32
  String

# Module: src/back/js/shared-text.bend:47
law j_quote:
  for +s: String
  String

# Module: src/back/js/shared-text.bend:7
@unsafe
def j_escape(
  +s: String,
) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{c, t}:
      j_escape_char(c) ++ j_escape(t)

# Module: src/back/js/shared-text.bend:21
@unsafe
def j_escape_char(c):
  j_escape_char_on(c, Char.to_u32(c))

# Module: src/back/js/shared-text.bend:30
@unsafe
def j_escape_char_on(c, key):
  match key:
    case 34:
      "\\\""
    case 92:
      "\\\\"
    case 10:
      "\\n"
    case 13:
      "\\r"
    case 9:
      "\\t"
    case 0:
      "\\x00"
    case n:
      kc(String, U32.is_gt(n, 1114111) || (U32.is_ge(n, 55296) && U32.is_le(n, 57343)),
        u => "\\uDC00" ++ j_escape_unit(U32.shrn(n, 22n)) ++
          j_escape_unit(U32.and(U32.shrn(n, 11n), 2047)) ++ j_escape_unit(U32.and(n, 2047)),
        u => Char.show(Char.from_u32(n)))

# Emit ASCII source for the three payload units of a non-scalar Char. Raw
# non-scalars would be replaced when compiler output crosses its host boundary.
@unsafe
def j_escape_unit(+n: U32) -> String:
  "\\u{" ++ kc(String, U32.is_eq(n, 0), u => "0", u => U32.hex(n)) ++ "}"

# Module: src/back/js/shared-text.bend:52
@unsafe
def j_quote(s):
  "\"" ++ j_escape(s) ++ "\""

# Module: src/back/js/shared-text.bend:56
@unsafe
def j_private_float_magnitude(+bits: U32) -> String:
  +exponent = U32.and(U32.shrn(bits, 23n), 255)
  +fraction = U32.and(bits, 8388607)
  kc(String, U32.is_eq(exponent, 0),
    u => kc(String, U32.is_eq(fraction, 0), u => "0", u => "(" ++ U32.show(fraction) ++ "*2**(-149))"),
    u => "(" ++ U32.show(U32.add(fraction, 8388608)) ++ "*2**(" ++ j_private_float_power(exponent) ++ "))")

# Module: src/back/js/shared-text.bend:64
@unsafe
def j_private_float_power(+exponent: U32) -> String:
  kc(String, U32.is_ge(exponent, 150), u => U32.show(U32.sub(exponent, 150)),
    u => "-" ++ U32.show(U32.sub(150, exponent)))

# Module: src/back/js/shared-text.bend:68
@unsafe
def j_foreign_path(
  +paths: List<&2, KTerm>,
) -> String:
  match paths:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, String.ends_with(nm(h), ".js\"") || String.ends_with(nm(h), ".js"), u => nm(h), u => j_foreign_path(rest))
