# Close the legacy dispatch inside the recursive lookup itself. The selected
# source crosses index_find_absent/index_find_leaf before recursing; this creates
# a helper SCC and reconstructs records that the next helper takes apart again.
# Every legacy/zero-mask/collision decision remains, in the same order. No
# canonical-tree precondition is added: this rewrite preserves arbitrary input
# shapes admitted by the previous internal function, including malformed nodes.

@unsafe
def index_find(+tree: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      kc(KDef, p88_string_eq(kind, "Absent"), u => missing(),
        u => kc(KDef, U32.is_eq(templates, 0),
          v => kc(KDef, U32.is_eq(arity, hash),
            w => index_bucket(ctors, name), w => missing()),
          v => index_find(index_child_list(ctors,
            Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(stored, hash),
        u => index_bucket(bucket, name), u => missing())
    case KIndexNode{stored, +mask, +left, +right}:
      kc(KDef, U32.is_eq(mask, 0),
        u => kc(KDef, U32.is_eq(stored, hash),
          v => index_bucket([left, right], name), v => missing()),
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_find(left, name, hash, bits),
          v => index_find(right, name, hash, bits)))
