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
