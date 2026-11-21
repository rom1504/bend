import Base

# Integrate two telemetry segments into a circular window. Each segment has its
# own absolute timestamp; the second segment starts with the first segment's state.
def frame.integrate(+stamp: U32, +carry: U32, read: Array<U32> & U32) -> Array<U32> & U32:
  (ring, sample) = read
  +sum = U32.add(carry, sample)
  (ring[stamp] <- U32.xor(sum, stamp), sum)

def frame.sample(+stamp: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  (ring, carry) = state
  frame.integrate(stamp, carry, Array.get(U32, ring, stamp))

def frame.segment(+length: Nat, +stamp: U32, state: Array<U32> & U32) -> Array<U32> & U32:
  match length:
    case 0n:
      state
    case 1n+rest:
      frame.segment(rest, U32.inc(stamp), frame.sample(stamp, state))

def frame.packet(+size: U32, +seed: U32) -> Array<U32> & U32:
  raw = [U32.xor(seed, 2654435769) : U32*64n]
  first = raw[0] <- U32.add(seed, 270544960)
  second = first[17] <- U32.xor(seed, 2147483648)
  ring = second[63] <- U32.add(U32.mul(seed, 17), 3)
  left = frame.segment(U32.to_nat(size), U32.sub(2, U32.and(seed, 7)), (ring, U32.xor(seed, 2779096485)))
  frame.segment(U32.to_nat(U32.add(U32.div(size, 5), 3)), U32.xor(seed, 4294967280), left)

def frame.hash(length: Nat, +slot: U32, read: Array<U32> & U32, hash: U32) -> U32:
  match length:
    case 0n: hash
    case 1n+rest:
      (ring, sample) = read
      frame.hash(rest, U32.inc(slot), Array.get(U32, ring, U32.inc(slot)), U32.mul(U32.xor(hash, sample), 16777619))

def frame.value(state: Array<U32> & U32) -> U32:
  (ring, carry) = state
  frame.hash(64n, 0, Array.get(U32, ring, 0), U32.xor(carry, 2166136261))

def frame.words(length: Nat, +slot: U32, read: Array<U32> & U32) -> String:
  match length:
    case 0n: SNil{}
    case 1n+rest:
      (ring, sample) = read
      String.append(",", String.append(U32.show(sample), frame.words(rest, U32.inc(slot), Array.get(U32, ring, U32.inc(slot)))))

def frame.render(state: Array<U32> & U32) -> String:
  (ring, carry) = state
  String.append(U32.show(carry), frame.words(64n, 0, Array.get(U32, ring, 0)))

def frame.goal(alternate: Bool) -> U32:
  match alternate:
    case True{}: 1289343279
    case False{}: 2148527053

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 6147), p93.word(second, 305419899)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (6147, 305419899))

def p93.value(a: U32, b: U32) -> U32:
  frame.value(frame.packet(a, b))

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, frame.goal(U32.is_eq(a, 263)))
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(frame.render(frame.packet(a, b)))
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
