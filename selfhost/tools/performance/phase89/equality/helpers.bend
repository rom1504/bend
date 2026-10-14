def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match same:
    case False{}: False{}
    case True{}:
      match a b:
        case SNil{} SNil{}: True{}
        case SNil{} SCon{h, t}: False{}
        case SCon{h, t} SNil{}: False{}
        case SCon{h1, t1} SCon{h2, t2}:
          p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p88_string_eq(a: String, b: String) -> Bool:
  p88_string_eq_go(a, b, True{})
