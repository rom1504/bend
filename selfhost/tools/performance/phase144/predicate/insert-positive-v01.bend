# Exact source-level ceiling: preserve every insertion/fallback operation and
# its condition, but consume the positive equality directly with swapped arms.
# No ownership annotation, layout, runtime helper, or admission policy changes.
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
      +diff = U32.xor(hash, stored)
      kc(KDef, U32.is_eq(split, 0),
        u => p131i_original_set(tree, d, hash, 32),
        u => kc(KDef, U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash))),
          v => index_join(tree, d, hash, index_split_bit(diff))))
