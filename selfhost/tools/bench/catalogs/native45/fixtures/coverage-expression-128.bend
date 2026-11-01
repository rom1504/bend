# a tiny expression interpreter: an AST of Lit/Add/Mul/Sub evaluates over
# wrapping words; (2+3)*(10-4) + 5*0xFFFFFFFF computed structurally
# ported from bend3: infix word ops become U32.add/mul/sub; the bend3
# `--eval eval` def-printing block is bend3-only and is dropped
import Base

type Expr is Data:
  Lit{n: U32}
  Add{a: Expr, b: Expr}
  Mul{a: Expr, b: Expr}
  Sub{a: Expr, b: Expr}

law eval:
  for e: Expr
  U32

def eval(e):
  match e:
    case Lit{n}:
      n
    case Add{a, b}:
      U32.add(eval(a), eval(b))
    case Mul{a, b}:
      U32.mul(eval(a), eval(b))
    case Sub{a, b}:
      U32.sub(eval(a), eval(b))

law main.out:
  U32

def main.out():
  e1 = {Mul{Add{Lit{2}, Lit{3}}, Sub{Lit{10}, Lit{4}}} : Expr}
  e2 = {Mul{Lit{5}, Lit{4294967295}} : Expr}
  U32.add(eval(e1), eval(e2))

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|25

# Phase37 wrapper: upstream body above is unchanged.
# Non-balanced expression tree: one recursive child and one varying shallow arm.
def p37.expr.pick(op: Nat, e: Expr, +seed: U32) -> Expr:
  match op:
    case 0n:
      Add{e, Mul{Lit{seed}, Lit{3}}}
    case 1n+0n:
      Mul{e, Add{Lit{U32.mod(seed, 5)}, Lit{1}}}
    case 1n+1n+p:
      Sub{e, Add{Lit{seed}, Lit{7}}}

def p37.expr(n: Nat, +seed: U32) -> Expr:
  match n:
    case 0n:
      Lit{seed}
    case 1n+p:
      p37.expr.pick(U32.to_nat(U32.mod(seed, 3)), p37.expr(p, U32.add(seed, 1)), seed)

def bench(size: U32, seed: U32) -> U32:
  eval(p37.expr(U32.to_nat(size), seed))

# Phase93: fixed catalog inputs, repeated complete-result validation.
# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p93.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.number(text: String, fallback: Nat) -> Nat:
  p93.parsed(Nat.read(text), fallback)

def p93.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.word(text: String, fallback: U32) -> U32:
  p93.word_parsed(U32.read(text), fallback)

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 128), p93.word(second, 123)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (128, 123))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 3393903617)
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p93.value(a, b)))
    Unit <- IO.print(U32.show(p93.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p93.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
