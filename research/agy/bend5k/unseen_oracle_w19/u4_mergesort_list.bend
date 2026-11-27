import Base
# u4_mergesort_list: Pure functional top-down mergesort on List<&2, U32>
# Unseen benchmark testing allocation/TRMC/IReuse/ret2 in split-and-merge.
# N = 8192 elements per list, ROUNDS = 20 rounds.

type LSplit is Data:
  Split{a: List<&2, U32>, b: List<&2, U32>}

type MState is Data:
  MCheck{xs: List<&2, U32>, ys: List<&2, U32>}
  MPick{le: Bool, x: U32, xs: List<&2, U32>, y: U32, ys: List<&2, U32>}

type MSortArg is Data:
  MOne{xs: List<&2, U32>}
  MTwo{sp: LSplit}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def gen_list(+n: Nat, +seed: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      acc
    case 1n+p:
      +ns = prng(seed)
      gen_list(p, ns, Con{ns, acc})

def split_list(xs: List<&2, U32>, a: List<&2, U32>, b: List<&2, U32>) -> LSplit:
  match xs:
    case Nil{}:
      Split{a, b}
    case Con{x, rest}:
      split_list(rest, b, Con{x, a})

def merge_go(+fuel: Nat, st: MState) -> List<&2, U32>:
  match fuel:
    case 0n:
      Nil{}
    case 1n+f:
      match st:
        case MCheck{xs, ys}:
          match xs:
            case Nil{}:
              ys
            case Con{+x, xrest}:
              match ys:
                case Nil{}:
                  Con{x, xrest}
                case Con{+y, yrest}:
                  merge_go(f, MPick{U32.is_le(x, y), x, xrest, y, yrest})
        case MPick{le, x, xs, y, ys}:
          match le:
            case True{}:
              Con{x, merge_go(f, MCheck{xs, Con{y, ys}})}
            case False{}:
              Con{y, merge_go(f, MCheck{Con{x, xs}, ys})}

def msort(+fuel: Nat, arg: MSortArg) -> List<&2, U32>:
  match fuel:
    case 0n:
      match arg:
        case MOne{xs}:
          xs
        case MTwo{sp}:
          Split{a, b} = sp
          a
    case 1n+f:
      match arg:
        case MTwo{sp}:
          Split{a, b} = sp
          merge_go(32768n, MCheck{msort(f, MOne{a}), msort(f, MOne{b})})
        case MOne{xs}:
          match xs:
            case Nil{}:
              Nil{}
            case Con{x, rest}:
              match rest:
                case Nil{}:
                  Con{x, Nil{}}
                case Con{y, rest2}:
                  msort(f, MTwo{split_list(rest2, Con{x, Nil{}}, Con{y, Nil{}})})

def hash_list(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case Con{x, rest}:
      hash_list(rest, U32.xor(U32.mul(acc, 2654435761), x))

def run_rounds(+rounds: Nat, +seed: U32, +acc: U32) -> U32:
  match rounds:
    case 0n:
      acc
    case 1n+p:
      xs = gen_list(8192n, seed, Nil{})
      ys = msort(40n, MOne{xs})
      +nacc = hash_list(ys, acc)
      run_rounds(p, prng(seed), nacc)

def main() -> U32:
  run_rounds(20n, 314159265, 2166136261)
