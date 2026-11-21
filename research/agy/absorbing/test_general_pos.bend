import Base

type Counter is Data:
  CDone{acc: U32}
  CStep{rem: Nat, acc: U32}

def cstep(+k: U32, st: Counter) -> Counter:
  match st:
    case CDone{acc}: CDone{acc}
    case CStep{0n, acc}: CDone{acc}
    case CStep{1n+r, acc}: CStep{r, U32.add(acc, k)}

def crun(fuel: Nat, +k: U32, st: Counter) -> Counter:
  match fuel:
    case 0n: st
    case 1n+p: crun(p, k, cstep(k, st))

def cget(c: Counter) -> U32:
  match c:
    case CDone{acc}: acc
    case CStep{_, acc}: acc

def main() -> IO(Unit):
  IO.print(U32.show(cget(crun(U32.to_nat(20000000), 7, CStep{10n, 3}))))
