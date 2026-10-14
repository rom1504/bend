# Consuming compiler-host helpers. No reconstructed input pair or host closure.
# Deliberately safe: checked ownership must suffice without @unsafe.
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

def p88_string_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match a b order:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} LT{}: LT{}
    case SNil{} SCon{h, t} EQ{}: LT{}
    case SNil{} SCon{h, t} GT{}: GT{}
    case SCon{h, t} SNil{} LT{}: LT{}
    case SCon{h, t} SNil{} EQ{}: GT{}
    case SCon{h, t} SNil{} GT{}: GT{}
    case SCon{h1, t1} SCon{h2, t2} LT{}: LT{}
    case SCon{h1, t1} SCon{h2, t2} GT{}: GT{}
    case SCon{h1, t1} SCon{h2, t2} EQ{}:
      p88_string_order_go(t1, t2, U32.cmp(Char.to_u32(h1), Char.to_u32(h2)))

def p88_string_order(a: String, b: String) -> Cmp:
  p88_string_order_go(a, b, EQ{})
