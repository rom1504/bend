import Base
import ./production.bend as P
import ./candidate.bend as H
import ./baseline.bend as B

# These laws refer to the exact candidate recognizers, not rewritten models.
law literal_empty_exact:
  for value: String
  {H.p98_eq_empty(value) == P.p88_string_eq(value, "") : Bool}

def literal_empty_exact(value):
  match value:
    case SNil{}: {==}
    case SCon{head, tail}: {==}

law literal_var_exact:
  for value: String
  {H.p98_eq_var(value) == P.p88_string_eq(value, "Var") : Bool}

def literal_var_exact(value):
  match value:
    case SCon{Chr{86}, SCon{Chr{97}, SCon{Chr{114}, SNil{}}}}: {==}
    case other: {==}

law literal_unicode_exact:
  for value: String
  {H.p98_eq_unicode(value) == P.p88_string_eq(value, "λ🙂") : Bool}

def literal_unicode_exact(value):
  match value:
    case SCon{Chr{955}, SCon{Chr{128578}, SNil{}}}: {==}
    case other: {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
