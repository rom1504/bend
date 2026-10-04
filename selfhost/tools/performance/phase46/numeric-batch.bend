# Phase46 common JS/C workload. Source SHA256: 36f803ed8d88bf20c5878092a572d4ae2ef48d71fd6710024f05a57349f4b0f3
# Arguments: repetitions warmups; read last two values across IO.args ABIs.
# Input schedule repeats every 16 iterations; digest observes every return.
# Time includes measured checksum formatting/print, forcing full observation.
import Base
import ../phase37/fixtures-new/numeric-recurrence.bend as W

def p46.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p46.number(text: String, fallback: Nat) -> Nat:
  p46.parsed(Nat.read(text), fallback)

def p46.warm(args: List<String>) -> Nat:
  match args:
    case Nil{}:
      2n
    case value <> rest:
      p46.number(value, 2n)

def p46.options(args: List<String>) -> Nat & Nat:
  match args:
    case Nil{}:
      (8n, 2n)
    case value <> rest:
      (p46.number(value, 8n), p46.warm(rest))

def p46.arguments(args: List<String>) -> Nat & Nat:
  match args:
    case first <> second <> Nil{}:
      (p46.number(first, 8n), p46.number(second, 2n))
    case head <> rest:
      p46.arguments(rest)
    case Nil{}:
      (8n, 2n)

def p46.loop(n: Nat, +i: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      v = W.bench(U32.add(1024, U32.and(i, 1)), U32.add(123, U32.and(i, 15)))
      p46.loop(p, U32.inc(i), U32.xor(U32.mul(h, 16777619), U32.add(v, i)))

def p46.batch(n: Nat) -> U32:
  p46.loop(n, 0, 2166136261)

def p46.run(options: Nat & Nat) -> IO(Unit):
  (repetitions, warmups) = options
  do IO<Unit>:
    Unit <- IO.print(U32.show(W.bench(1024, 123)))
    Unit <- IO.print(U32.show(p46.batch(warmups)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p46.batch(repetitions)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p46.run(p46.arguments(args))
