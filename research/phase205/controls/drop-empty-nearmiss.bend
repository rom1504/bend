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

def trim.keep(piece: String, tail: List<&2, String>) -> List<&2, String>:
  match piece:
    case SNil{}: tail
    case SCon{c, rest}: SCon{c, rest} <> tail

def trim.parts(parts: List<&2, String>) -> List<&2, String>:
  match parts:
    case Nil{}: Nil{}
    case h <> t: trim.keep(h, trim.parts(t))

def main() -> IO(Unit):
  IO.print(frame.words(frame.join("|", trim.parts(frame.fields(44, ",a,,b,")))))
