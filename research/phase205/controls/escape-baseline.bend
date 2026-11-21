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

# Fixed literal expansion by character, with a direct SCon continuation.
# No split, join, delimiter, String.append or captured separator in this encoder.
def wire.prefix(word: U32, rest: String) -> String:
  match word:
    case 0: SCon{Chr{92}, SCon{Chr{48}, rest}}
    case 10: SCon{Chr{92}, SCon{Chr{110}, rest}}
    case 34: SCon{Chr{92}, SCon{Chr{34}, rest}}
    case 92: SCon{Chr{92}, SCon{Chr{92}, rest}}
    case other: SCon{Chr{other}, rest}

def wire.escape(input: String) -> String:
  match input:
    case SNil{}: SNil{}
    case SCon{Chr{raw}, tail}:
      word = {raw : U32}
      wire.prefix(word, wire.escape(tail))

# Consume the complete transformed sequence; no encoded-text output in timing kernel.
def wire.hash(input: String, h: U32) -> U32:
  match input:
    case SNil{}: h
    case SCon{Chr{raw}, tail}:
      word = {raw : U32}
      wire.hash(tail, U32.add(U32.mul(h, 65599), word))

def wire.render(n: Nat, word: U32) -> String:
  prefix = {SCon{Chr{34}, SCon{Chr{115}, SCon{Chr{101}, SCon{Chr{110}, SCon{Chr{115}, SCon{Chr{111}, SCon{Chr{114}, SCon{Chr{34}, SCon{Chr{0}, SCon{Chr{10}, SCon{Chr{92}, SCon{Chr{945}, SCon{Chr{128752}, SNil{}}}}}}}}}}}}}} : String}
  block = String.append(prefix, SCon{Chr{word}, SNil{}})
  wire.escape(frame.repeat(n, block))

def bench(size: U32, seed: U32) -> U32:
  wire.hash(wire.render(U32.to_nat(size), seed), 17)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(frame.words(wire.render(0n, 0)))
    Unit <- IO.print(U32.show(bench(0, 0)))
    Unit <- IO.print(frame.words(wire.render(1n, 92)))
    Unit <- IO.print(U32.show(bench(1, 92)))
    Unit <- IO.print(frame.words(wire.render(5n, 4294967295)))
    Unit <- IO.print(U32.show(bench(5, 4294967295)))
    Unit <- IO.print(frame.words(wire.render(64n, 1114111)))
    IO.print(U32.show(bench(64, 1114111)))
