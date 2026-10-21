import Base

def witness.pick(test: Bool, a: U32, b: U32) -> U32:
  match test:
    case True{}: a
    case False{}: b

def witness.minimum(+a: U32, +b: U32) -> U32:
  witness.pick(U32.is_lt(a, b), a, b)

def witness.maximum(+a: U32, +b: U32) -> U32:
  witness.pick(Bool.not(U32.is_lt(a, b)), a, b)

def witness.cost(+a: U32, +b: U32) -> U32:
  witness.pick(U32.is_eq(a, b), 0, 1)

def witness.observe(+a: U32, +b: U32) -> IO(Unit):
  IO.print(U32.show(witness.minimum(a, b)) ++ ":" ++ U32.show(witness.maximum(a, b)) ++ ":" ++ U32.show(witness.cost(a, b)) ++ ":" ++ U32.show(U32.add(witness.minimum(a, b), 1)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- witness.observe(0, 0)
    Unit <- witness.observe(0, 1)
    Unit <- witness.observe(0, 2147483647)
    Unit <- witness.observe(0, 2147483648)
    Unit <- witness.observe(0, 4294967295)
    Unit <- witness.observe(1, 0)
    Unit <- witness.observe(1, 1)
    Unit <- witness.observe(1, 2147483647)
    Unit <- witness.observe(1, 2147483648)
    Unit <- witness.observe(1, 4294967295)
    Unit <- witness.observe(2147483647, 0)
    Unit <- witness.observe(2147483647, 1)
    Unit <- witness.observe(2147483647, 2147483647)
    Unit <- witness.observe(2147483647, 2147483648)
    Unit <- witness.observe(2147483647, 4294967295)
    Unit <- witness.observe(2147483648, 0)
    Unit <- witness.observe(2147483648, 1)
    Unit <- witness.observe(2147483648, 2147483647)
    Unit <- witness.observe(2147483648, 2147483648)
    Unit <- witness.observe(2147483648, 4294967295)
    Unit <- witness.observe(4294967295, 0)
    Unit <- witness.observe(4294967295, 1)
    Unit <- witness.observe(4294967295, 2147483647)
    Unit <- witness.observe(4294967295, 2147483648)
    witness.observe(4294967295, 4294967295)
