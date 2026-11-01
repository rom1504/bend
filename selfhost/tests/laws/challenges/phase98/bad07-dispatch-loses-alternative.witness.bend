@unsafe
def p98_bad07_dispatch_loses_alternative_actual() -> P98CheckNode:
  p98_check_node_select("Efq")

@unsafe
def p98_bad07_dispatch_loses_alternative_baseline_expected() -> P98CheckNode:
  P98CheckNode2{}

@unsafe
def p98_bad07_dispatch_loses_alternative_challenge_expected() -> P98CheckNode:
  P98CheckNodeDefault{}

