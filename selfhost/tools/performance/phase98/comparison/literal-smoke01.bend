import Base

# Safe structural recognizers: no borrowed pointers, closures, or second String.
def p98_eq_var(value: String) -> Bool:
  match value:
    case SCon{Chr{86}, SCon{Chr{97}, SCon{Chr{114}, SNil{}}}}: True{}
    case other: False{}

def p98_eq_empty(value: String) -> Bool:
  match value:
    case SNil{}: True{}
    case other: False{}

def p98_eq_unicode(value: String) -> Bool:
  match value:
    case SCon{Chr{955}, SCon{Chr{128578}, SNil{}}}: True{}
    case other: False{}

type P98Comparison is Data:
  P98Comparison{input: String, oldVar: Bool, newVar: Bool, oldEmpty: Bool, newEmpty: Bool, oldUnicode: Bool, newUnicode: Bool}

def p98_compare(+value: String) -> P98Comparison:
  P98Comparison{value, String.eq(value, "Var"), p98_eq_var(value), String.eq(value, ""), p98_eq_empty(value), String.eq(value, "λ🙂"), p98_eq_unicode(value)}

def main() -> List<&2,P98Comparison>:
  [p98_compare(""), p98_compare("Var"), p98_compare("V"), p98_compare("Va"), p98_compare("Vars"), p98_compare("var"), p98_compare("λ🙂"), p98_compare("λ"), p98_compare("λ🙃"), p98_compare("λ🙂x")]
