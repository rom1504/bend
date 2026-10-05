import Base

def glyph.join(a: String, b: String) -> String:
  String.append(a, b)

def glyph.weave(+n: Nat, +left: String, +right: String, middle: String) -> String:
  match n:
    case 0n: middle
    case 1n+p:
      +next: String = glyph.join(left, glyph.join(middle, right))
      glyph.weave(p, left, right, next)

def bench(turns: U32, seed: U32) -> String:
  +suffix: String = glyph.join(U32.show(seed), "é")
  glyph.weave(U32.to_nat(turns), "α🙂", suffix, "")

def append(a: String, b: String) -> String:
  glyph.join(a, b)

def reversed(a: String, b: String) -> String:
  glyph.join(b, a)

def fork(+a: String, +b: String) -> String:
  glyph.join(glyph.join(a, b), glyph.join(b, a))

def selected(flag: Bool, +a: String, +b: String) -> String:
  match flag:
    case True{}: glyph.join(a, b)
    case False{}: glyph.join(b, a)

def pair(+a: String, +b: String) -> String & String:
  (glyph.join(a, b), glyph.join(b, a))

type Label is Data:
  LabelBox{left: String, right: String, whole: String}

def record(+a: String, +b: String) -> Label:
  LabelBox{a, b, glyph.join(a, b)}
