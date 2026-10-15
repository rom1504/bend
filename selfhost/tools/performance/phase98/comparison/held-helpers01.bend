# Preserve whole roots across a private read-only walk, then consume them once.
# The walker has exactly the admitted Phase88 recursive body under a new name.
# Upstream borrowed-parameter inference must be verified in actual emitted C.
def p98_eq_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p98_eq_walk(t1, t2, Char.is_eq(h1, h2))

type P98EqHeld is Data:
  P98EqHeld{same: Bool, left: String, right: String}

def p98_eq_finish(observation: P98EqHeld) -> Bool:
  match observation:
    case P98EqHeld{same, left, right}: same

def p98_eq_observe(+a: String, +b: String) -> P98EqHeld:
  P98EqHeld{p98_eq_walk(a, b, True{}), a, b}

def p98_string_eq(a: String, b: String) -> Bool:
  p98_eq_finish(p98_eq_observe(a, b))
