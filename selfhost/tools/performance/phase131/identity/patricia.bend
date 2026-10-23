# Phase131 candidate: insert into a canonical Patricia index in one descent.
# This is an internal index algorithm, not a relaxed verifier or hash-only map.
# Exact bucket names, replacement order, payloads and node hashes are preserved.
# Canonical nodes have increasing least-significant split bits and a stored
# representative hash sharing all bits below their split with every descendant.
# KDef legacy indexes and zero-mask nodes retain the frozen implementation.

@unsafe
def p131i_original_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  kc(KDef, p88_string_eq(dk(tree), "Absent"), u => index_leaf(d, hash, Nil{}),
    u => index_insert(tree, d, hash, index_split_bit(U32.xor(hash, da(index_tip(tree, hash))))))

@unsafe
def p131i_insert(+tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131i_original_set(tree, d, hash, 32)
    case KIndexLeaf{stored, bucket}:
      +mask = index_split_bit(U32.xor(hash, stored))
      kc(KDef, U32.is_eq(mask, 0),
        u => index_leaf(d, hash, bucket),
        u => index_join(tree, d, hash, mask))
    case KIndexNode{stored, split, left, right}:
      kc(KDef, U32.is_eq(split, 0),
        u => p131i_original_set(tree, d, hash, 32),
        u => p131i_branch(tree, d, hash, stored, split, left, right))

@unsafe
def p131i_branch(+tree: KDef, +d: KDef, +hash: U32, +stored: U32,
                +split: U32, +left: KDef, +right: KDef) -> KDef:
  +mask = index_split_bit(U32.xor(hash, stored))
  kc(KDef, Bool.not(U32.is_eq(mask, 0)) && U32.is_lt(mask, split),
    u => index_join(tree, d, hash, mask),
    u => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
      v => index_node(stored, split, p131i_insert(left, d, hash), right),
      v => index_node(stored, split, left, p131i_insert(right, d, hash))))

@unsafe
def index_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  p131i_insert(tree, d, hash)
