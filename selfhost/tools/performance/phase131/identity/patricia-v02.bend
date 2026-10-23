# Optional v02 ablation. Same canonical-index algorithm/invariant as v01.
# Test lower-bit disagreement first and compute lowestbit only when splitting.
# Keep the branch local to avoid the extra seven-argument helper boundary.
# This is unmeasured and must pass the same complete controls before admission.

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
      +diff = U32.xor(hash, stored)
      kc(KDef, U32.is_eq(split, 0),
        u => p131i_original_set(tree, d, hash, 32),
        u => kc(KDef, Bool.not(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0)),
          v => index_join(tree, d, hash, index_split_bit(diff)),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash)))))

@unsafe
def index_set(+tree: KDef, +d: KDef, +hash: U32, +bits: U32) -> KDef:
  p131i_insert(tree, d, hash)
