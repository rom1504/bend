# The scalar accumulator precedes the strings, matching Bend's binder-order
# rule. The original v01 parser failure is preserved as negative fixture data.
def p130s_order_go(order: Cmp, a: String, b: String) -> Cmp:
  match order:
    case LT{}: LT{}
    case GT{}: GT{}
    case EQ{}:
      match a b:
        case SNil{} SNil{}: EQ{}
        case SNil{} SCon{head,tail}: LT{}
        case SCon{head,tail} SNil{}: GT{}
        case SCon{ha,ta} SCon{hb,tb}:
          p130s_order_go(U32.cmp(Char.to_u32(ha),Char.to_u32(hb)),ta,tb)

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(EQ{},a,b)
