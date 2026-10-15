import Base

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)))

type P98EqHeld is Data:
  P98EqHeld{same: Bool, left: String, right: String}

def p98_eq_finish(observation: P98EqHeld) -> Bool:
  match observation:
    case P98EqHeld{same, left, right}: same

def p98_eq_observe(+a: String, +b: String) -> P98EqHeld:
  P98EqHeld{p88_string_eq_go(a, b, True{}), a, b}

def p88_string_eq(a: String, b: String) -> Bool:
  p98_eq_finish(p98_eq_observe(a, b))

