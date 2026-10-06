import Base

# Shared JavaScript text utilities for direct and compatibility emission.
# Quoting, numeric expression spelling and JavaScript foreign-path selection are target-specific.

@unsafe
def j_escape(
  +s: String,
) -> String:
  match s:
    case SNil{}:
      ""
    case SCon{c, t}:
      j_escape_char(c) ++ j_escape(t)

law j_escape_char:
  for +c: Char
  String

@unsafe
def j_escape_char(c):
  j_escape_char_on(c, Char.to_u32(c))

law j_escape_char_on:
  for +c: Char
  for +key: U32
  String

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
      Char.show(Char.from_u32(n))

law j_quote:
  for +s: String
  String

@unsafe
def j_quote(s):
  "\"" ++ j_escape(s) ++ "\""

@unsafe
def j_private_float_magnitude(+bits: U32) -> String:
  +exponent = U32.and(U32.shrn(bits, 23n), 255)
  +fraction = U32.and(bits, 8388607)
  kc(String, U32.is_eq(exponent, 0),
    u => kc(String, U32.is_eq(fraction, 0), u => "0", u => "(" ++ U32.show(fraction) ++ "*2**(-149))"),
    u => "(" ++ U32.show(U32.add(fraction, 8388608)) ++ "*2**(" ++ j_private_float_power(exponent) ++ "))")

@unsafe
def j_private_float_power(+exponent: U32) -> String:
  kc(String, U32.is_ge(exponent, 150), u => U32.show(U32.sub(exponent, 150)),
    u => "-" ++ U32.show(U32.sub(150, exponent)))
@unsafe
def j_foreign_path(
  +paths: List<&2, KTerm>,
) -> String:
  match paths:
    case Nil{}:
      ""
    case Con{h, rest}:
      kc(String, String.ends_with(nm(h), ".js\"") || String.ends_with(nm(h), ".js"), u => nm(h), u => j_foreign_path(rest))
