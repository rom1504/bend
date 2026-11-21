# Keep the historical entry and its complete Bool-state contract. The neutral
# worker carries only the two string cursors, and never enters another recursive
# character iteration after a mismatch. Root lifetime stays with p88_string_eq.
def p202n_eq(a: String, b: String) -> Bool:
  match a b:
    case SNil{} SNil{}: True{}
    case SNil{} SCon{h, t}: False{}
    case SCon{h, t} SNil{}: False{}
    case SCon{h1, t1} SCon{h2, t2}:
      match Char.is_eq(h1, h2):
        case False{}: False{}
        case True{}: p202n_eq(t1, t2)

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match same:
    case False{}: False{}
    case True{}: p202n_eq(a, b)
