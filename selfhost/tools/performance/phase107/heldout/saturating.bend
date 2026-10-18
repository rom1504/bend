import Base

def held_sat_pick(overflow: Bool, sum: U32) -> U32:
  match overflow:
    case True{}: 4294967295
    case False{}: sum

def held_sat(+n: U32, seed: U32) -> U32:
  +sum = U32.add(n, seed)
  held_sat_pick(U32.is_lt(sum, n), sum)

def held_upper(high: Bool, value: U32) -> U32:
  match high:
    case True{}: U32.xor(value, 2147483648)
    case False{}: U32.sub(value, 257)

def held_piece(small: Bool, +value: U32) -> U32:
  match small:
    case True{}: U32.mul(value, 3)
    case False{}: held_upper(U32.is_ge(value, 2147483648), value)

def bench(n: U32, seed: U32) -> U32:
  +sum = held_sat(n, seed)
  held_piece(U32.is_lt(sum, 257), sum)

def main() -> U32:
  bench(4294967000, 500)
