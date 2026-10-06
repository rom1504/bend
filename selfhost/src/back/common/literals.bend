import Base

# Shared checked-term literal and binary32 classification queries.
# Existing j_ names and bodies are retained; no JavaScript is emitted here.

law j_strip:
  for +t: KTerm
  KTerm

@unsafe
def j_strip(t):
  kc(KTerm, String.eq(tg(t), "Ann"), u => j_strip(kid(t, 0)), u => t)

law j_u32:
  for +t: KTerm
  Maybe<&2, U32>

@unsafe
def j_u32(t):
  j_u32_node(j_strip(t))

law j_u32_node:
  for +t: KTerm
  Maybe<&2, U32>

@unsafe
def j_u32_node(t):
  kc(Maybe<&2,U32>, core_literal(t) && String.eq(nm(t), "U32"), u => Some{kl_number(t)}, u => kc(Maybe<&2, U32>, String.eq(tg(t), "Ctr") && String.eq(nm(t), "U32"), u => j_word(j_strip(kid(t, 0)), 0, 0), u => None{}))

law j_word:
  for +t: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def j_word(t, at, acc):
  kc(Maybe<&2, U32>, String.eq(tg(t), "Ctr"), u => kc(Maybe<&2, U32>, String.eq(nm(t), "WNil"), u => kc(Maybe<&2, U32>, U32.is_eq(at, 32), u => Some{acc}, u => None{}), u => kc(Maybe<&2, U32>, String.eq(nm(t), "WCon") && U32.is_lt(at, 32), u => j_word_bit(j_strip(kid(t, 0)), j_strip(kid(t, 1)), at, acc), u => None{})), u => None{})

law j_word_bit:
  for +bit: KTerm
  for +rest: KTerm
  for +at: U32
  for +acc: U32
  Maybe<&2, U32>

@unsafe
def j_word_bit(bit, rest, at, acc):
  kc(Maybe<&2, U32>, String.eq(tg(bit), "Ctr") && (String.eq(nm(bit), "True") || String.eq(nm(bit), "False")), u => j_word(rest, U32.add(at, 1), U32.or(acc, kc(U32, String.eq(nm(bit), "True"), u => U32.shln(1, U32.to_nat(at)), u => 0))), u => None{})

@unsafe
def j_private_float_finite(+bits: U32) -> Bool:
  Bool.not(U32.is_eq(U32.and(U32.shrn(bits, 23n), 255), 255))
