
# Module: src/back/native/identity.bend:6
law nc_ctor_owned:
  for +book: List<&2, KDef>
  for +name: String
  Bool

# Module: src/back/native/identity.bend:11
law nc_ctor_encode:
  for +name: String
  String

# Module: src/back/native/identity.bend:15
law nc_ctor_codes:
  for +name: String
  String

# Module: src/back/native/identity.bend:19
law nc_ctor_decode:
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/identity.bend:27
law nc_ctor_decode_step:
  for +h: Char
  for +rest: String
  for +acc: U32
  for +digits: U32
  for +out: String
  for +original: String
  String

# Module: src/back/native/identity.bend:37
@unsafe
def nc_ctor_identity(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  kc(String, nc_ctor_owned(book, name), u => name, u => nc_ctor_encode(name))

# Module: src/back/native/identity.bend:44
@unsafe
def nc_ctor_owned(book, name):
  p144o_owned(book,name)

@unsafe
def nc_ctor_encode(name):
  "$ctor." ++ nc_ctor_codes(name)

# Module: src/back/native/identity.bend:58
@unsafe
def nc_ctor_codes(name):
  match name:
    case SNil{}:
      ""
    case SCon{h, rest}:
      U32.show(Char.to_u32(h)) ++ "_" ++ nc_ctor_codes(rest)

# Module: src/back/native/identity.bend:66
@unsafe
def nc_ctor_display(
  +name: String,
) -> String:
  kc(String, String.starts_with(name, "$ctor."),
    u => nc_ctor_decode(String.drop(name, String.length("$ctor.")), 0, 0, "", name),
    u => name)

# Module: src/back/native/identity.bend:74
@unsafe
def nc_ctor_decode(rest, acc, digits, out, original):
  match rest:
    case SNil{}:
      kc(String, U32.is_eq(digits, 0) && p88_string_eq(nc_ctor_encode(out), original), u => out, u => original)
    case SCon{h, tail}:
      nc_ctor_decode_step(h, tail, acc, digits, out, original)

# Module: src/back/native/identity.bend:82
@unsafe
def nc_ctor_decode_step(h, rest, acc, digits, out, original):
  kc(String, Char.is_eq(h, '_'),
    u => kc(String, U32.is_gt(digits, 0) && U32.is_le(acc, 1114111) && Bool.not(U32.is_ge(acc, 55296) && U32.is_le(acc, 57343)),
      u => nc_ctor_decode(rest, 0, 0, out ++ Char.show(Char.from_u32(acc)), original),
      u => original),
    u => kc(String, U32.is_ge(Char.to_u32(h), 48) && U32.is_le(Char.to_u32(h), 57) && U32.is_lt(digits, 7),
      u => nc_ctor_decode(rest, U32.add(U32.mul(acc, 10), U32.sub(Char.to_u32(h), 48)), U32.add(digits, 1), out, original),
      u => original))
