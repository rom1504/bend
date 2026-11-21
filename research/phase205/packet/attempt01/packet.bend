import Base

# Independently named framing operation; split preserves every empty field.
def frame.push(c: Char, parts: List<&2, String>) -> List<&2, String>:
  match parts:
    case Nil{}: [SCon{c, SNil{}}]
    case h <> t: SCon{c, h} <> t

def frame.choose(x: U32, parts: List<&2, String>, hit: Bool) -> List<&2, String>:
  match hit:
    case True{}: SNil{} <> parts
    case False{}: frame.push(Chr{x}, parts)

def frame.fields(+delimiter: U32, input: String) -> List<&2, String>:
  match input:
    case SNil{}: [SNil{}]
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      frame.choose(x, frame.fields(delimiter, tail), U32.is_eq(x, delimiter))

def frame.join.rest(+separator: String, parts: List<&2, String>, head: String) -> String:
  match parts:
    case Nil{}: head
    case h <> t: String.append(head, String.append(separator, frame.join.rest(separator, t, h)))

def frame.join(separator: String, parts: List<&2, String>) -> String:
  match parts:
    case Nil{}: SNil{}
    case h <> t: frame.join.rest(separator, t, h)

def frame.emit(separator: String, x: U32, tail: String, hit: Bool) -> String:
  match hit:
    case True{}: String.append(separator, tail)
    case False{}: SCon{Chr{x}, tail}

def frame.onepass(+separator: String, +delimiter: U32, input: String) -> String:
  match input:
    case SNil{}: SNil{}
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      frame.emit(separator, x, frame.onepass(separator, delimiter, tail), U32.is_eq(x, delimiter))

def frame.repeat(n: Nat, +block: String) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: String.append(block, frame.repeat(p, block))

# Serialize raw character words as ASCII; never pass invalid scalars to UTF-8 IO.
def frame.words(input: String) -> String:
  match input:
    case SNil{}: ""
    case SCon{Chr{x0}, tail}:
      x = {x0 : U32}
      String.append(U32.show(x), String.append(",", frame.words(tail)))

def packet.word(+index: U32, seed: U32) -> U32:
  match U32.is_eq(U32.and(index, 3), 0):
    case True{}: 30
    case False{}: U32.xor(seed, U32.mul(index, 2654435761))

def packet.block(n: Nat, +seed: U32, +index: U32) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: SCon{Chr{packet.word(index, seed)}, packet.block(p, seed, U32.add(index, 1))}

def packet.render(n: Nat, +block: String) -> String:
  separator = {SCon{Chr{30}, SCon{Chr{58}, SCon{Chr{31}, SNil{}}}} : String}
  frame.join(separator, frame.fields(30, frame.repeat(n, block)))

# Hash every raw U32 word, including non-Unicode values; also report exact length.
def packet.digest(input: String, h: U32, g: U32, n: U32) -> String:
  match input:
    case SNil{}: String.append(U32.show(n), String.append(":", String.append(U32.show(h), String.append(":", U32.show(g)))))
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      packet.digest(tail, U32.mul(U32.xor(h, x), 16777619), U32.add(U32.mul(g, 33), x), U32.add(n, 1))

def packet.value(n: U32, block: String) -> String:
  packet.digest(packet.render(U32.to_nat(n), block), 2166136261, 5381, 0)

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

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & (U32 & U32)):
  match args:
    case repetitions <> warmups <> count <> size <> seed <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(count, 16), (p93.word(size, 16), p93.word(seed, 17))))
    case head <> rest: p93.arguments(rest)
    case Nil{}: ((8n, 2n), (16, (16, 17)))

def p93.loop(repetitions: Nat, +n: U32, +block: String, +expected: String, h: U32) -> U32:
  match repetitions:
    case 0n: h
    case 1n+p:
      value = packet.value(n, block)
      valid = String.eq(value, expected)
      p93.loop(p, n, block, expected, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +n: U32, size: U32, seed: U32) -> IO(Unit):
  # Original dynamic argument evaluation occurs once before all timed invocations.
  +block = {packet.block(U32.to_nat(size), seed, 0) : String}
  +expected = {packet.value(n, block) : String}
  do IO<Unit>:
    Unit <- IO.print(expected)
    Unit <- IO.print(U32.show(p93.loop(warmups, n, block, expected, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, n, block, expected, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & (U32 & U32))) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (n, rest) = arguments
  (size, seed) = rest
  p93.execute(repetitions, warmups, n, size, seed)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
