import Base
# Helpers copied unchanged from pinned upstream Mandelbrot.
def b2u(b: Bool) -> U32:
  match b:
    case False{}:
      0
    case True{}:
      1

def sel.go(x: U32, y: U32, z: Bool) -> U32:
  match z:
    case True{}:
      x
    case False{}:
      y

def sel(t: U32, x: U32, y: U32) -> U32:
  sel.go(x, y, U32.is_zero(t))

# arithmetic shift right by 8 over two's-complement u32
def asr8(+v: U32) -> U32:
  U32.or(U32.shrn(v, 8n), sel(U32.shrn(v, 31n), 0, 4278190080))

# ITERS branchless escape-time iterations: z steps while esc == 0 and
# freezes after (sel), it counts the pre-escape iterations
def mit(n: Nat, +cr: U32, +ci: U32, +zr: U32, +zi: U32, esc: U32,
        it: U32) -> U32:
  match n:
    case 0n:
      it
    case 1n+p:
      +r2 = asr8(U32.mul(zr, zr))
      +i2 = asr8(U32.mul(zi, zi))
      +e2 = U32.or(esc, b2u(U32.is_gt(U32.add(r2, i2), 1024)))
      nzr = U32.add(U32.sub(r2, i2), cr)
      nzi = U32.add(asr8(U32.mul(2, U32.mul(zr, zi))), ci)
      sr = sel(e2, nzr, zr)
      si = sel(e2, nzi, zi)
      mit(p, cr, ci, sr, si, e2, U32.add(it, b2u(U32.is_zero(e2))))

# Phase29: exact upstream helper bodies above; only these adapters are new.
def bench(size: U32, +seed: U32) -> U32:
  cr = U32.sub(U32.and(seed, 1023), 512)
  ci = U32.sub(U32.and(U32.shrn(seed, 10n), 1023), 512)
  mit(U32.to_nat(size), cr, ci, 0, 0, 0, 0)

def point(n: U32, cr: U32, ci: U32, zr: U32, zi: U32, esc: U32, it: U32) -> U32:
  mit(U32.to_nat(n), cr, ci, zr, zi, esc, it)

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 0), p93.word(second, 524800)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (0, 524800))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 0)
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
