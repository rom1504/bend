# Same private walker and root lifetime as v1; no explicit carrier datatype.
def p98_eq_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p98_eq_walk(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p98_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p98_eq_walk(a, b, True{}), a, b)
