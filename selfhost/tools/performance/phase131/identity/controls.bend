# API-only differential controls; not included in production experiments.
# Compare original/candidate complete returned KDef values, not just lookup keys.

@unsafe
def p131ic_record(+key: U32, +version: U32) -> KDef:
  KDef{"identity." ++ U32.show(key), "P131Identity", key, version,
    kt("ProbeType", "type", key, version, []),
    kt("ProbeValue", "value", version, key, [atom("nested")]),
    [KDef{"payload", "P131Child", version, key, atom("Type"), atom("Value"), [], False{}, True{}}],
    U32.is_eq(U32.mod(version, 2), 0), U32.is_eq(U32.mod(version, 3), 0)}

@unsafe
def p131ic_hash(+key: U32, +mode: U32) -> U32:
  kc(U32, U32.is_eq(mode, 0), u => index_hash("identity." ++ U32.show(key), 2166136261), u =>
  kc(U32, U32.is_eq(mode, 1), u => 0, u =>
  kc(U32, U32.is_eq(mode, 2), u => 4294967295, u =>
  kc(U32, U32.is_eq(mode, 3), u => U32.mul(key, 2147483648), u =>
  kc(U32, U32.is_eq(mode, 4), u => U32.mul(key, 65536), u =>
  kc(U32, U32.is_eq(mode, 5), u => key, u =>
    U32.add(U32.mul(key, 2654435761), 2246822519)))))))

@unsafe
def p131ic_sequence(+tree: KDef, +seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  kc(KDef, U32.is_eq(count, 0), u => tree, u =>
    p131ic_sequence_step(tree, seed, count, mode, old, U32.mod(seed, 31)))

@unsafe
def p131ic_sequence_step(+tree: KDef, +seed: U32, +count: U32, +mode: U32,
                        +old: Bool, +key: U32) -> KDef:
  +record = p131ic_record(key, count)
  +hash = p131ic_hash(key, mode)
  +next = kc(KDef, old,
    u => p131i_original_set(tree, record, hash, 32),
    u => p131i_insert(tree, record, hash))
  p131ic_sequence(next, U32.add(U32.mul(seed, 1664525), 1013904223),
    U32.sub(count, 1), mode, old)

@unsafe
def p131ic_case(+seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  p131ic_sequence(missing(), seed, count, mode, old)

@unsafe
def p131ic_queries(+tree: KDef, +key: U32, +left: U32, +mode: U32) -> List<&2,KDef>:
  kc(List<&2,KDef>, U32.is_eq(left, 0), u => [], u =>
    Con{index_find(tree, "identity." ++ U32.show(key), p131ic_hash(key, mode), 32),
      p131ic_queries(tree, U32.inc(key), U32.sub(left, 1), mode)})

@unsafe
def p131ic_legacy(+tree: KDef) -> KDef:
  match tree:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}: tree
    case KIndexLeaf{hash, bucket}:
      KDef{"", "IndexLeaf", hash, 0, atom("Absent"), atom("Absent"), bucket, False{}, False{}}
    case KIndexNode{hash, mask, left, right}:
      KDef{"", "IndexNode", hash, mask, atom("Absent"), atom("Absent"),
        [p131ic_legacy(left), p131ic_legacy(right)], False{}, False{}}

@unsafe
def p131ic_legacy_case(+seed: U32, +count: U32, +mode: U32, +old: Bool) -> KDef:
  +prefix = p131ic_case(seed, 17, mode, True{})
  p131ic_sequence(p131ic_legacy(prefix), U32.add(seed, 91), count, mode, old)
