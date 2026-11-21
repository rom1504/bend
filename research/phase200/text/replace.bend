# One-pass join/split fusion for arbitrary Unicode text and separator strings.
def p200.text.emit(sep: String, x: U32, rest: String, match_: Bool) -> String:
  match match_:
    case True{}:
      String.append(sep, rest)
    case False{}:
      SCon{Chr{x}, rest}

def p200.text.replace(+sep: String, +needle: U32, s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{Chr{x0}, tail}:
      +x = {x0 : U32}
      p200.text.emit(sep, x, p200.text.replace(sep, needle, tail), U32.is_eq(x, needle))
