import Base

def p98_shared_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p98_shared_walk(t1, t2, Char.is_eq(h1, h2))

def p98_shared_repeat(left: Nat, +a: String, +b: String, total: U32) -> U32:
  match left:
    case 0n: total
    case 1n+rest:
      p98_shared_repeat(rest, a, b, U32.add(total, Bool.to_u32(p98_shared_walk(a, b, True{}))))

def p98_shared_inputs(args: List<&1, String>) -> IO(Unit):
  match args:
    case Nil{}: IO.print("missing input")
    case Con{a, Nil{}}: IO.print("missing second input")
    case Con{+a, Con{+b, rest}}:
      do IO<Unit>:
        Unit <- IO.print_err("phase98-shared-micro")
        Unit <- IO.print(U32.show(p98_shared_repeat(100000n, a, b, 0)))
        Unit <- IO.print(a)
        IO.print(b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1, String> <- IO.args()
    p98_shared_inputs(args)
