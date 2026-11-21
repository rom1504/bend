@unsafe
def index_hash(+name: String, +acc: U32) -> U32:
  match name:
    case SNil{}: acc
    case SCon{a,SNil{}}: U32.mul(U32.xor(acc,Char.to_u32(a)),16777619)
    case SCon{a,SCon{b,rest}}:
      +one = U32.mul(U32.xor(acc,Char.to_u32(a)),16777619)
      index_hash(rest,U32.mul(U32.xor(one,Char.to_u32(b)),16777619))
