import Base

# A packet header updates a caller-supplied rolling word. A delimiter changes
# the high and low bits without contributing a payload byte. A non-ASCII
# payload occupies one code point in the String stream.
def packet.choose(delimiter: Bool, state: U32, code: U32) -> U32:
  match delimiter:
    case True{}: U32.xor(state, 2779096485)
    case False{}: U32.add(U32.mul(state, 33), code)

def packet.step(+code: U32, state: U32) -> U32:
  packet.choose(U32.is_eq(code, 124), state, code)

def packet.fold(bytes: String, state: U32) -> U32:
  match bytes:
    case SNil{}: state
    case SCon{Chr{byte}, tail}: packet.fold(tail, packet.step(byte, state))

def p205unfold_fn0(+state: U32) -> U32:
  +p205unfold_v0 : U32 = packet.step(72, state)
  +p205unfold_v1 : U32 = packet.step(124, p205unfold_v0)
  +p205unfold_v2 : U32 = packet.step(76, p205unfold_v1)
  +p205unfold_v3 : U32 = packet.step(69, p205unfold_v2)
  +p205unfold_v4 : U32 = packet.step(78, p205unfold_v3)
  +p205unfold_v5 : U32 = packet.step(58, p205unfold_v4)
  +p205unfold_v6 : U32 = packet.step(937, p205unfold_v5)
  +p205unfold_v7 : U32 = packet.step(124, p205unfold_v6)
  +p205unfold_v8 : U32 = packet.step(80, p205unfold_v7)
  +p205unfold_v9 : U32 = packet.step(65, p205unfold_v8)
  +p205unfold_v10 : U32 = packet.step(89, p205unfold_v9)
  +p205unfold_v11 : U32 = packet.step(124, p205unfold_v10)
  +p205unfold_v12 : U32 = packet.step(124, p205unfold_v11)
  +p205unfold_v13 : U32 = packet.step(67, p205unfold_v12)
  +p205unfold_v14 : U32 = packet.step(82, p205unfold_v13)
  +p205unfold_v15 : U32 = packet.step(67, p205unfold_v14)
  +p205unfold_v16 : U32 = packet.step(58, p205unfold_v15)
  +p205unfold_v17 : U32 = packet.step(46, p205unfold_v16)
  p205unfold_v17

def packet.apply(state: U32) -> U32:
  p205unfold_fn0(state)

def packet.batch(n: Nat, state: U32) -> U32:
  match n:
    case 0n: state
    case 1n+k: packet.batch(k, packet.apply(state))

def bench(count: U32, state: U32) -> U32:
  packet.batch(U32.to_nat(count), state)

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 8), p93.word(second, 0)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (8, 0))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 4274317329)
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
