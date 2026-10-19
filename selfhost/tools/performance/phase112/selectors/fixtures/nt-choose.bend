import Base

@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(nt_choose(String,True{},u => "yes",u => "BAD"))
    IO.print(nt_choose(String,False{},u => "BAD",u => "no"))

#|yes
#|no
