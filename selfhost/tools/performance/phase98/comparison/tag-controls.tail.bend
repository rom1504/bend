type P98TagCase is Data:
  P98TagCase{term: KTerm, key: String, original: Bool, candidate: Bool}

def p98_tag_case(+term: KTerm, +key: String) -> P98TagCase:
  P98TagCase{term, key, p88_string_eq(p98_tag_reference(term), key), p98_tag_eq(term, key)}

def p98_tag_columns(+term: KTerm, keys: List<&2,String>) -> List<&2,P98TagCase>:
  match keys:
    case Nil{}: Nil{}
    case Con{key, rest}: Con{p98_tag_case(term, key), p98_tag_columns(term, rest)}

def p98_tag_rows(terms: List<&2,KTerm>, +keys: List<&2,String>) -> List<&2,P98TagCase>:
  match terms:
    case Nil{}: Nil{}
    case Con{term, rest}: List.append(&2, P98TagCase, p98_tag_columns(term, keys), p98_tag_rows(rest, keys))

def p98_tag_child() -> KTerm:
  KTerm{"Ref", "childλ", 99, 2, Nil{}, ["gone", ""], 42, 43}

def p98_tag_terms() -> List<&2,KTerm>:
  [KTerm{"Var", "x", 4294967295, 2, [p98_tag_child()], ["removed", "λ"], 8, 33},
   KTerm{"", "", 0, 0, Nil{}, Nil{}, 0, 0},
   KTerm{"λ🙂", "tag", 4, 9, [p98_tag_child()], Nil{}, 3, 99},
   KTerm{"Lam", "generic", 23, 1, Nil{}, ["removed"], 7, 8},
   KLambda{"lambda", 17, 2, [p98_tag_child()], ["name"], 12, 32, True{}},
   KLambda{"", 0, 0, Nil{}, Nil{}, 0, 0, False{}},
   KLiteral{"String", 0, "λ🙂\n", 1, 200},
   KLiteral{"Odd", 4294967295, "payload", 8, 9}]

def main() -> List<&2,P98TagCase>:
  p98_tag_rows(p98_tag_terms(), ["", "Var", "Lam", "Lit", "App", "λ🙂", "L", "La", "Lams", "Li", "Lits", "Ref"])
