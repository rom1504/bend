import Base

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p88_string_eq(a: String, b: String) -> Bool:
  p88_string_eq_go(a, b, True{})

@unsafe
def has_name(
  +ns: List<&2, String>,
  +name: String,
) -> Bool:
  match ns:
    case Nil{}:
      False{}
    case Con{h, t}:
      has_name_next(t, name, p88_string_eq(h, name))

@unsafe
def has_name_next(+rest: List<&2,String>, +name: String, +same: Bool) -> Bool:
  match same:
    case True{}: True{}
    case False{}: has_name(rest, name)

@unsafe
def nb_contains(+xs: List<&2, String>, +k: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, +t}: p88_string_eq(h, k) || nb_contains(t, k)
