import Base

# Exact Base go/fin ordering: law for the fuel-matching function, typed
# helper first, then the inferred fuel-matching definition.
law turn:
  for n: Nat
  for a: Nat
  for b: Nat
  Nat

def turn_more(n: Nat, a: Nat, b: Nat, flag: Bool) -> Nat:
  match flag:
    case True{}: turn(n,a,b)
    case False{}: b

def turn(n,a,b):
  match n:
    case 0n: a
    case 1n+p: turn_more(p,b,a,True{})

# An owning accumulator remains an owner across every fused transition.
law owner:
  for n: Nat
  for a: String
  for b: String
  String

def owner_more(n: Nat, a: String, b: String) -> String:
  owner(n,a,b)

def owner(n,a,b):
  match n:
    case 0n: a
    case 1n+p: owner_more(p,b,a)

# A non-tail cycle must retain its existing generic fallback.
law non_tail:
  for n: Nat
  Nat

def non_tail_more(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: Nat.add(1n,non_tail(p))

def non_tail(n):
  match n:
    case 0n: 0n
    case 1n+p: Nat.add(1n,non_tail_more(p))

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
