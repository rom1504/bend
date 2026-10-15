# Requires the exact production KTerm datatype and admitted p88_string_eq_go.
# No String field escapes the observer. The outer product owns both roots.
def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term key:
    case KTerm{tag, name, id, quant, kids, removed, begin, end} key:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present} SCon{Chr{76}, SCon{Chr{97}, SCon{Chr{109}, SNil{}}}}: True{}
    case KLambda{name, id, quant, kids, removed, begin, end, present} other: False{}
    case KLiteral{kind, number, text, begin, end} SCon{Chr{76}, SCon{Chr{105}, SCon{Chr{116}, SNil{}}}}: True{}
    case KLiteral{kind, number, text, begin, end} other: False{}

type P98TagEqHeld is Data:
  P98TagEqHeld{same: Bool, term: KTerm, key: String}

def p98_tag_eq_finish(observation: P98TagEqHeld) -> Bool:
  match observation:
    case P98TagEqHeld{same, term, key}: same

def p98_tag_eq_observe(+term: KTerm, +key: String) -> P98TagEqHeld:
  P98TagEqHeld{p98_tag_eq_read(term, key), term, key}

def p98_tag_eq(term: KTerm, key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_observe(term, key))
