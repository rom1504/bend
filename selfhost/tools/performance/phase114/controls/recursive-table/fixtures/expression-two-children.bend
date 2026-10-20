import Base

type Expr is Data:
  Literal{value: U32}
  Add{left: Expr, right: Expr}
  Mul{left: Expr, right: Expr}
  Sub{left: Expr, right: Expr}

# Each binary case resumes after one child by evaluating the second child,
# then resumes again to combine both values. All arithmetic here is in range.
def evaluate(expression: Expr) -> U32:
  match expression:
    case Literal{value}: value
    case Add{left, right}: U32.add(evaluate(left), evaluate(right))
    case Mul{left, right}: U32.mul(evaluate(left), evaluate(right))
    case Sub{left, right}: U32.sub(evaluate(left), evaluate(right))

def grow(n: Nat, expression: Expr) -> Expr:
  match n:
    case 0n: expression
    case 1n+p:
      +child = grow(p, expression)
      Add{child, child}

def shared(+expression: Expr) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(evaluate(expression)))
    IO.print(U32.show(evaluate(expression)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(evaluate(Literal{0})))
    Unit <- IO.print(U32.show(evaluate(Sub{Literal{100}, Literal{37}})))
    Unit <- IO.print(U32.show(evaluate(Sub{Mul{Add{Literal{7}, Literal{5}}, Sub{Literal{9}, Literal{3}}}, Add{Mul{Literal{4}, Literal{3}}, Literal{2}}})))
    Unit <- IO.print(U32.show(evaluate(Add{Mul{Literal{3}, Add{Literal{4}, Literal{5}}}, Sub{Literal{21}, Mul{Literal{2}, Literal{6}}}})))
    shared(grow(6n, Literal{3}))

#|0
#|63
#|58
#|36
#|192
#|192
