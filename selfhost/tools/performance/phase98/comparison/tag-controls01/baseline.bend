import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p88_string_eq(a: String, b: String) -> Bool:
  p88_string_eq_go(a, b, True{})


def p98_tag_reference(
  +t: KTerm,
) -> String:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      tag
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      "Lam"
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      "Lit"


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

type P98TagCase is Data:
  P98TagCase{term: KTerm, key: String, original: Bool, candidate: Bool}

def p98_tag_case(+term: KTerm, +key: String) -> P98TagCase:
  P98TagCase{term, key, p88_string_eq(p98_tag_reference(term), key), p88_string_eq(p98_tag_reference(term), key)}

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
