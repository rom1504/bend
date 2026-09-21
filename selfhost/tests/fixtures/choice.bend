import Base

law kc:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

@unsafe
def kc(A, b, yes, no):
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})


@unsafe
def picked(+b: Bool) -> Nat:
  kc(Nat, b, u => 7n, u => 9n)

@unsafe
def partial(+b: Bool) -> Nat:
  f = kc(Nat, b)
  f(u => 11n, u => 12n)

@unsafe
def loop(+n: U32) -> U32:
  kc(U32, U32.is_eq(n, 0), u => 17, u => loop(U32.sub(n, 1)))

@unsafe
def thunk() -> Unit -> Nat:
  u => 23n

@unsafe
def dynamic(+b: Bool) -> Nat:
  kc(Nat, b, thunk(), u => 29n)

law swapped:
  for -A: Type
  for +b: Bool
  for yes: Unit -> A
  for no: Unit -> A
  A

@unsafe
def swapped(A, b, yes, no):
  match b:
    case True{}: no(Unit{})
    case False{}: yes(Unit{})

@unsafe
def reversed(+b: Bool) -> Nat:
  swapped(Nat, b, u => 31n, u => 37n)

@unsafe
def condition(+b: Bool) -> Bool:
  b

@unsafe
def selected(+n: Nat) -> Nat:
  n

@unsafe
def ordered(+b: Bool) -> Nat:
  kc(Nat, condition(b), u => selected(41n), u => selected(43n))
