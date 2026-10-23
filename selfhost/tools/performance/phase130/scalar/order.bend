# A source-level ceiling, not a compiler recognizer. This safe scalar function
# computes the second field of Base String.cmp without reconstructing its roots.
def p130s_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match order:
    case LT{}: LT{}
    case GT{}: GT{}
    case EQ{}:
      match a b:
        case SNil{} SNil{}: EQ{}
        case SNil{} SCon{head,tail}: LT{}
        case SCon{head,tail} SNil{}: GT{}
        case SCon{ha,ta} SCon{hb,tb}:
          p130s_order_go(ta,tb,U32.cmp(Char.to_u32(ha),Char.to_u32(hb)))

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(a,b,EQ{})
