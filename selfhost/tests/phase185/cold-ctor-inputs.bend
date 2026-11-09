import Base

# Ordinary source coverage for each allocated width, nested reference fields,
# duplicated children, and retained outer aliases. Full output is the oracle.
type CachePacket is Data:
  CacheOne{+a: List<&2,U32>}
  CacheTwo{+a: List<&2,U32>, +b: List<&2,U32>}
  CacheThree{+a: List<&2,U32>, +b: List<&2,U32>, +c: List<&2,U32>}
  CacheFour{+a: List<&2,U32>, +b: List<&2,U32>, +c: List<&2,U32>, +d: List<&2,U32>}

@unsafe
def cache_values(n: Nat, +next: U32) -> List<&2,U32>:
  match n:
    case 0n: []
    case 1n+p: Con{next,cache_values(p,U32.inc(next))}

@unsafe
def cache_sum(values: List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{value,rest}: U32.add(value,cache_sum(rest))

def cache_score(packet: CachePacket) -> U32:
  match packet:
    case CacheOne{a}: cache_sum(a)
    case CacheTwo{a,b}: U32.add(cache_sum(a),cache_sum(b))
    case CacheThree{a,b,c}: U32.add(cache_sum(a),U32.add(cache_sum(b),cache_sum(c)))
    case CacheFour{a,b,c,d}: U32.add(U32.add(cache_sum(a),cache_sum(b)),U32.add(cache_sum(c),cache_sum(d)))

def main() -> List<&2,U32>:
  +values = cache_values(64n,1)
  +packet : CachePacket = CacheFour{values,values,values,values}
  [cache_score(CacheOne{values}),cache_score(CacheTwo{values,values}),
   cache_score(CacheThree{values,values,values}),cache_score(packet),
   U32.add(cache_score(packet),cache_score(packet))]

#|[2080, 4160, 6240, 8320, 16640]
