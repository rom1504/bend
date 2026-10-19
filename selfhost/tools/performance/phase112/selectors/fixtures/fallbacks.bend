import Base

def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Actuals are variables at this callsite: no literal-closure specialization.
def dynamic(flag: Bool, yes: Unit -> String, no: Unit -> String) -> String:
  nt_choose(String,flag,yes,no)

def identity(s: String) -> String:
  s

# References in the selector's own body are excluded by nbc_closed.
def referenced(+flag: Bool, yes: Unit -> String, no: Unit -> String) -> String:
  match flag:
    case True{}: identity(yes(Unit{}))
    case False{}: identity(no(Unit{}))

type Choice is Data:
  Empty{}
  Box{value: Nat}

# This discriminator owns a field; the nullary matcher rule must refuse it.
def field_choose(value: Choice, yes: Nat -> String, no: Unit -> String) -> String:
  match value:
    case Box{n}: yes(n)
    case Empty{}: no(Unit{})

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(dynamic(True{},u => "dynamic",u => "BAD"))
    Unit <- IO.print(referenced(False{},u => "BAD",u => "reference"))
    Unit <- IO.print(field_choose(Box{7n},n => Nat.show(n),u => "BAD"))
    IO.print(field_choose(Empty{},n => "BAD",u => "empty"))

#|dynamic
#|reference
#|7
#|empty
