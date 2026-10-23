# Scalar-code discriminator. Roots stay structurally first and all state is
# nonowning. Two primitive predicates replace U32.cmp's enum transport.
def p130u_finish(same: Bool, less: Bool, ending: U32) -> U32:
  match same less:
    case True{} _: ending
    case False{} True{}: 1
    case False{} False{}: 3

def p130u_go(a: String, b: String, same: Bool, less: Bool) -> U32:
  match a b same:
    case SNil{} SNil{} equal:
      p130u_finish(equal,less,2)
    case SNil{} SCon{head,tail} equal:
      p130u_finish(equal,less,1)
    case SCon{head,tail} SNil{} equal:
      p130u_finish(equal,less,3)
    case SCon{ha,ta} SCon{hb,tb} False{}:
      p130u_finish(False{},less,2)
    case SCon{+ha,ta} SCon{+hb,tb} True{}:
      p130u_go(ta,tb,U32.is_eq(Char.to_u32(ha),Char.to_u32(hb)),
        U32.is_lt(Char.to_u32(ha),Char.to_u32(hb)))

def p130u_order(a: String, b: String) -> U32:
  p130u_go(a,b,True{},False{})
