# A native occurrence set holds U32 binder IDs, not named definitions. The
# compressed low-bit trie retains exact keys and allocates nothing on a hit.
type NU_Set is Data:
  NU_Empty{}
  NU_Leaf{key: U32}
  NU_Node{mask: U32, +left: NU_Set, +right: NU_Set}

@unsafe
def nu_tip(s: NU_Set, +key: U32) -> U32:
  match s:
    case NU_Empty{}: key
    case NU_Leaf{stored}: stored
    case NU_Node{+mask, +left, +right}:
      nt_choose(U32, U32.is_eq(U32.and(key, mask), 0), u => nu_tip(left, key), u => nu_tip(right, key))

@unsafe
def nu_join(+s: NU_Set, +key: U32, +mask: U32) -> NU_Set:
  nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
    u => NU_Node{mask, NU_Leaf{key}, s}, u => NU_Node{mask, s, NU_Leaf{key}})

@unsafe
def nu_insert(+s: NU_Set, +key: U32, +split: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case NU_Leaf{stored}: nu_join(s, key, split)
    case NU_Node{+mask, +left, +right}:
      nt_choose(NU_Set, U32.is_lt(split, mask), u => nu_join(s, key, split),
        u => nt_choose(NU_Set, U32.is_eq(U32.and(key, mask), 0),
          v => NU_Node{mask, nu_insert(left, key, split), right},
          v => NU_Node{mask, left, nu_insert(right, key, split)}))

@unsafe
def nu_add(+s: NU_Set, +key: U32) -> NU_Set:
  match s:
    case NU_Empty{}: NU_Leaf{key}
    case _:
      +split = index_split_bit(U32.xor(key, nu_tip(s, key)))
      nt_choose(NU_Set, U32.is_eq(split, 0), u => s, u => nu_insert(s, key, split))

@unsafe
def nu_has(s: NU_Set, +key: U32) -> Bool:
  match s:
    case NU_Empty{}: False{}
    case NU_Leaf{stored}: U32.is_eq(stored, key)
    case NU_Node{+mask, +left, +right}:
      nt_choose(Bool, U32.is_eq(U32.and(key, mask), 0), u => nu_has(left, key), u => nu_has(right, key))
