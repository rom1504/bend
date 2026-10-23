import Base

# Different arities, full-width Nat payloads and parallel permutation.
law turn_more:
  for n: Nat
  for a: Nat
  for b: Nat
  for flag: Bool
  Nat

def turn(n: Nat, a: Nat, b: Nat) -> Nat:
  match n:
    case 0n: a
    case 1n+p: turn_more(p,b,a,True{})
def turn_more(n,a,b,flag):
  match flag:
    case True{}: turn(n,a,b)
    case False{}: b

# An owning accumulator remains an owner across every fused transition.
law owner_more:
  for n: Nat
  for a: String
  for b: String
  String

def owner(n: Nat, a: String, b: String) -> String:
  match n:
    case 0n: a
    case 1n+p: owner_more(p,b,a)
def owner_more(n,a,b):
  owner(n,a,b)

# A non-tail cycle must retain its existing generic fallback.
law non_tail_more:
  for n: Nat
  Nat

def non_tail(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: Nat.add(1n,non_tail_more(p))
def non_tail_more(n):
  match n:
    case 0n: 0n
    case 1n+p: Nat.add(1n,non_tail(p))

def main() -> IO(Unit):
  +shared = String.append("al","pha")
  do IO<Unit>:
    Unit <- IO.print(Nat.show(turn(0n,Nat.mul(1048576n,1048576n),7n)))
    Unit <- IO.print(Nat.show(turn(1n,Nat.mul(1048576n,1048576n),7n)))
    Unit <- IO.print(Nat.show(turn(2n,Nat.mul(1048576n,1048576n),7n)))
    Unit <- IO.print(Nat.show(turn(100001n,Nat.mul(1048576n,1048576n),7n)))
    Unit <- IO.print(owner(0n,"alpha","beta"))
    Unit <- IO.print(owner(1n,"alpha","beta"))
    Unit <- IO.print(owner(100001n,"alpha","beta"))
    Unit <- IO.print(owner(100001n,shared,shared))
    Unit <- IO.print(Nat.show(non_tail(8n)))
    IO.print(U32.show(4294967295))

#|1099511627776
#|7
#|1099511627776
#|7
#|alpha
#|beta
#|beta
#|alpha
#|8
#|4294967295
