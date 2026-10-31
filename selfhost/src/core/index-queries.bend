
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
        u => kc(KDef, U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash))),
          v => index_join(tree, d, hash, index_split_bit(diff))))

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

@unsafe
def p131il_original_lookup(
  +book: List<&2, KDef>,
  +name: String,
) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{d, rest}:
      p131il_original_lookup_cached(d, rest, name, p88_string_eq(dk(d), "BookCache"))

# Module: src/core/term.bend:289


@unsafe
def p131il_original_lookup_cached(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +cached: Bool,
) -> KDef:
  match cached:
    case True{}: p131il_original_index_lookup(d, name)
    case False{}: p131il_original_lookup_named(d, rest, name, p88_string_eq(dn(d), name))

# Module: src/core/term.bend:300


@unsafe
def p131il_original_lookup_named(
  +d: KDef,
  +rest: List<&2, KDef>,
  +name: String,
  +same: Bool,
) -> KDef:
  match same:
    case True{}: d
    case False{}: p131il_original_lookup(rest, name)

# Module: src/core/term.bend:311


@unsafe
def p131il_original_index_lookup(+cache: KDef, +name: String) -> KDef:
  p131ir_original_index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)

# Module: src/core/index.bend:263


@unsafe
def p131il_probe(+book: List<&2,KDef>, +name: String, +old: Bool) -> KDef:
  kc(KDef, old,
    u => p131il_original_lookup(book, name),
    u => lookup(book, name))
