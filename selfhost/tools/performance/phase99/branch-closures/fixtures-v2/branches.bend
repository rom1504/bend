import Base

def select_branch(-A: Type, +flag: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match flag:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}:
      select_branch(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

def overflow(n: Nat) -> Nat:
  1n+n

def captures(+a: String, +b: String, flag: Bool) -> IO(Unit):
  +result = select_branch(String, flag, u => a ++ "/" ++ b, u => b ++ "/" ++ a)
  do IO<Unit>:
    Unit <- IO.print(result)
    Unit <- IO.print(a)
    IO.print(b)

def returns_closure(+a: String, +b: String, flag: Bool) -> String:
  selected = select_branch(Unit -> String, flag, u => v => a, u => v => b)
  selected(Unit{})

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- captures("left", "right", True{})
    Unit <- captures("left", "right", False{})
    Unit <- IO.print(returns_closure("A", "B", True{}))
    Unit <- IO.print(returns_closure("A", "B", False{}))
    Unit <- IO.print(name_key("alpha:beta:tail"))
    Unit <- IO.print(name_key("plain"))
    Unit <- IO.print(Nat.show(select_branch(Nat, True{}, u => 7n, u => overflow(Nat.add(Nat.pow(2n, 47n), Nat.sub(Nat.pow(2n, 47n), 1n))))))
    Unit <- select_branch(IO(Unit), True{}, u => IO.print("selected-effect"), u => IO.print("BAD-unselected-effect"))
    select_branch(IO(Unit), False{}, u => IO.print("BAD-unselected-effect"), u => IO.print("other-effect"))

#|left/right
#|left
#|right
#|right/left
#|left
#|right
#|A
#|B
#|alpha.beta:tail
#|plain
#|7
#|selected-effect
#|other-effect
