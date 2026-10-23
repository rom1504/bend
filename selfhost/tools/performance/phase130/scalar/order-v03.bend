# Uses the structurally decreasing first String argument and the safe matched
# shape previously exercised in Phase89/equality/controls.bend. The accumulator
# follows the roots; a single ordered multi-match avoids v01's binder violation.
def p130s_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match a b order:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h,t} LT{}: LT{}
    case SNil{} SCon{h,t} EQ{}: LT{}
    case SNil{} SCon{h,t} GT{}: GT{}
    case SCon{h,t} SNil{} LT{}: LT{}
    case SCon{h,t} SNil{} EQ{}: GT{}
    case SCon{h,t} SNil{} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} LT{}: LT{}
    case SCon{ha,ta} SCon{hb,tb} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} EQ{}:
      p130s_order_go(ta,tb,U32.cmp(Char.to_u32(ha),Char.to_u32(hb)))

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(a,b,EQ{})
