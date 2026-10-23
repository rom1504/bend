# Exact selected Phase130 lookup/helper definitions, renamed only for a differential oracle.

@unsafe
def p131ir_original_index_find(
  +tree: KDef,
  +name: String,
  +hash: U32,
  +bits: U32,
) -> KDef:
  match tree:
    case KDef{label, kind, arity, templates, typ, value, ctors, native, unsafe}:
      p131ir_original_index_find_absent(tree, name, hash, bits, p88_string_eq(kind, "Absent"))
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(stored, hash), u => index_bucket(bucket, name), u => missing())
    case KIndexNode{stored, mask, left, right}:
      kc(KDef, U32.is_eq(mask, 0),
        u => p131ir_original_index_find_hash(tree, name, U32.is_eq(stored, hash)),
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => p131ir_original_index_find(left, name, hash, bits), v => p131ir_original_index_find(right, name, hash, bits)))

# Module: src/core/index.bend:89

@unsafe
def p131ir_original_index_find_absent(
  +tree: KDef,
  +name: String,
  +hash: U32,
  +bits: U32,
  +absent: Bool,
) -> KDef:
  match absent:
    case True{}: missing()
    case False{}:
      p131ir_original_index_find_leaf(tree, name, hash, bits, U32.is_eq(dx(tree), 0))

# Module: src/core/index.bend:102

@unsafe
def p131ir_original_index_find_leaf(
  +tree: KDef,
  +name: String,
  +hash: U32,
  +bits: U32,
  +leaf: Bool,
) -> KDef:
  match leaf:
    case True{}:
      p131ir_original_index_find_hash(tree, name, U32.is_eq(da(tree), hash))
    case False{}:
      p131ir_original_index_find(index_child(tree, Bool.not(U32.is_eq(U32.and(hash, dx(tree)), 0))), name, hash, bits)

# Module: src/core/index.bend:116

@unsafe
def p131ir_original_index_find_hash(
  +tree: KDef,
  +name: String,
  +same: Bool,
) -> KDef:
  match same:
    case True{}: index_bucket(dc(tree), name)
    case False{}: missing()

# Module: src/core/index.bend:126

@unsafe
def p131ir_probe(+tree: KDef, +name: String, +hash: U32, +bits: U32, +old: Bool) -> KDef:
  kc(KDef, old,
    u => p131ir_original_index_find(tree, name, hash, bits),
    u => index_find(tree, name, hash, bits))
