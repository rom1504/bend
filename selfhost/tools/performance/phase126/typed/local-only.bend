# Ablation: exact same persistent local-lane emitter, no typed ABI candidates.
type P126TPlan is Data:
  P126TPlan{+function: P113DFunction, +floats: List<&2,String>}

def p126t_plans(functions: List<&2,P113DFunction>) -> List<&2,P126TPlan>:
  []

def p126t_find(plans: List<&2,P126TPlan>, name: String) -> Maybe<&2,P126TPlan>:
  None{}
