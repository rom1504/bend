# A native occurrence set holds full U32 IDs. Each Patricia leaf packs the
# membership of32 adjacent IDs; repeated insertion retains the existing tree.
type NU_Set is Data:
  NU_Empty{}
  NU_Leaf{key: U32, bits: U32}
  NU_Node{mask: U32, +left: NU_Set, +right: NU_Set}

@unsafe
def nu_tip(+s: NU_Set, +key: U32) -> NU_Set:
  match s:
    case NU_Node{+mask, +left, +right}:
      nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0), u => nu_tip(left, key), u => nu_tip(right, key))
    case _: s

@unsafe
def nu_join(+s: NU_Set, +key: U32, +bits: U32, +mask: U32) -> NU_Set:
  nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
    u => NU_Node{mask, NU_Leaf{key, bits}, s}, u => NU_Node{mask, s, NU_Leaf{key, bits}})

@unsafe
def nu_insert(+s: NU_Set, +key: U32, +bits: U32, +split: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key, bits}
    case NU_Leaf{stored, old}:
      nt_choose(NU_Set, U32.is_eq(split, 0), u => NU_Leaf{key, bits}, u => nu_join(s, key, bits, split))
    case NU_Node{+mask, +left, +right}:
      nt_choose(NU_Set, U32.is_ne(split, 0) && U32.is_lt(split, mask), u => nu_join(s, key, bits, split),
        u => nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
          v => NU_Node{mask, nu_insert(left, key, bits, split), right},
          v => NU_Node{mask, left, nu_insert(right, key, bits, split)}))

@unsafe
def nu_add_seen(+s: NU_Set, +key: U32, +bit: U32, seen: NU_Set) -> NU_Set:
  match seen:
    case NU_Leaf{+stored, +bits}:
      +same = U32.is_eq(key, stored)
      nt_choose(NU_Set, same && U32.is_ne(U32.and(bits, bit), 0), u => s,
        u => nu_insert(s, key, nt_choose(U32, same, v => U32.or(bits, bit), v => bit), index_split_bit(U32.xor(key, stored))))
    case _: NU_Leaf{key, bit}

@unsafe
def nu_add(+s: NU_Set, +id: U32) -> NU_Set:
  +key = U32.shrn(id, 5n)
  nu_add_seen(s, key, U32.shln(1, U32.to_nat(U32.and(id, 31))), nu_tip(s, key))

@unsafe
def nu_has(+s: NU_Set, +id: U32) -> Bool:
  nu_has_leaf(nu_tip(s, U32.shrn(id, 5n)), id)

@unsafe
def nu_has_leaf(s: NU_Set, +id: U32) -> Bool:
  match s:
    case NU_Leaf{key, bits}: U32.is_eq(key, U32.shrn(id, 5n)) && U32.is_ne(U32.and(bits, U32.shln(1, U32.to_nat(U32.and(id, 31)))), 0)
    case _: False{}
