
# Module: src/back/common/literals.bend:6
law j_strip:
  for +t: KTerm
  KTerm

# Module: src/back/common/literals.bend:14
law j_u32:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:22
law j_u32_node:
  for +t: KTerm
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:30
law j_word:
  for +t: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:40
law j_word_bit:
  for +bit: KTerm
  for +rest: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

# Module: src/back/common/literals.bend:11
@unsafe
def j_strip(t):
  kc(KTerm, p98_tag_eq(t, "Ann"), u => j_strip(kid(t, 0)), u => t)

# Module: src/back/common/literals.bend:19
@unsafe
def j_u32(t):
  j_u32_node(j_strip(t))

# Module: src/back/common/literals.bend:27
@unsafe
def j_u32_node(t):
  kc(Maybe<&2,U32>, core_literal(t) && p88_string_eq(nm(t), "U32"), u => Some{kl_number(t)}, u => kc(Maybe<&2, U32>, p98_tag_eq(t, "Ctr") && p88_string_eq(nm(t), "U32"), u => j_word(j_strip(kid(t, 0)), 0, 0), u => None{}))

# Module: src/back/common/literals.bend:37
@unsafe
def j_word(t, at, acc):
  kc(Maybe<&2, U32>, p98_tag_eq(t, "Ctr"), u => kc(Maybe<&2, U32>, p88_string_eq(nm(t), "WNil"), u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), u => Some{acc}, u => None{}), u => kc(Maybe<&2, U32>, p88_string_eq(nm(t), "WCon") && U32.is_lt(at, 32), u => j_word_bit(j_strip(kid(t, 0)), j_strip(kid(t, 1)), at, acc), u => None{})), u => None{})

# Module: src/back/common/literals.bend:48
@unsafe
def j_word_bit(bit, rest, at, acc):
  kc(Maybe<&2, U32>, p98_tag_eq(bit, "Ctr") && (p88_string_eq(nm(bit), "True") || p88_string_eq(nm(bit), "False")), u => j_word(rest, U32.add(at, 1), U32.or(acc, kc(U32, p88_string_eq(nm(bit), "True"), u => U32.shln(1, U32.to_nat(at)), u => 0))), u => None{})

# Module: src/back/common/literals.bend:52
@unsafe
def j_private_float_finite(+bits: U32) -> Bool:
  Bool.not(U32.is_eq(U32.and(U32.shrn(bits, 23n), 255), 255))
