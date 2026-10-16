import Base

def select_branch(-A: Type, +flag: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match flag:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Exact hot source-level name_key algorithm, with only the chooser renamed.
def name_key(+name: String) -> String:
  match name:
    case SNil{}: ""
    case SCon{c, rest}:
      select_branch(String, Char.is_eq(c, ':'), u => "." ++ rest, u => SCon{c, name_key(rest)})

def checksum(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{h, t}: checksum(t, U32.add(acc, Char.to_u32(h)))

def repeat(n: Nat, +input: String, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+rest: repeat(rest, input, U32.add(acc, checksum(name_key(input), 0)))

def run(args: List<&1, String>) -> IO(Unit):
  match args:
    case Nil{}: IO.print("missing input")
    case Con{+input, rest}:
      do IO<Unit>:
        Unit <- IO.print(U32.show(repeat(200000n, input, 0)))
        IO.print(input)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    run(args)
