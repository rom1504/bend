# Join after a delimiter-preserving split is a homomorphism on concatenation.
def stream.separator(x: U32, hit: Bool, tail: String) -> String:
  match hit:
    case True{}: SCon{Chr{124}, tail}
    case False{}: SCon{Chr{x}, tail}

def stream.replace(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{+x}, t}: stream.separator(x, U32.is_eq(x,44), stream.replace(t))

def bench(size: U32, seed: U32) -> String:
  block = String.append("α,β,🍎,中,", String.append(U32.show(seed), ","))
  p37.text.repeat(U32.to_nat(size), stream.replace(block))
