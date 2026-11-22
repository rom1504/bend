# Shared suffix appended to each kernel after bench(size, seed).
def number(value: Maybe<&2,U32>) -> U32:
  match value:
    case Some{n}: n
    case None{}: 0

def timed_fold(left: Nat,+n: U32,+seed: U32,+index: U32,h: U32) -> U32:
  match left:
    case 0n: h
    case 1n+p:
      input = U32.add(seed,U32.mul(U32.and(index,31),2654435761))
      next = U32.add(U32.mul(h,16777619),bench(n,input))
      timed_fold(p,n,seed,U32.inc(index),next)

def execute(reps: U32,warm: U32,+n: U32,+seed: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(bench(n,seed)))
    Unit <- IO.print(U32.show(timed_fold(U32.to_nat(warm),n,seed,0,0)))
    start : Nat <- IO.now()
    Unit <- IO.print(U32.show(timed_fold(U32.to_nat(reps),n,seed,0,0)))
    stop : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(stop,start)))

def dispatch(args: List<String>) -> IO(Unit):
  match args:
    case r <> w <> n <> s <> Nil{}: execute(number(U32.read(r)),number(U32.read(w)),number(U32.read(n)),number(U32.read(s)))
    case head <> rest: dispatch(rest)
    case Nil{}: IO.print("expected repetitions warmups size seed")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    dispatch(args)
