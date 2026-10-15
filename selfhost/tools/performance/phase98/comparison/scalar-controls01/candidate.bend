import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p98_ix_reference(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

def p98_qt_reference(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      quant
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      quant
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

def p98_term_scalar_finish(value: U32, term: KTerm) -> U32:
  value

def p98_ix_read(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      id
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      id
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0

def p98_qt_read(
  +t: KTerm,
) -> U32:
  match t:
    case KTerm{tag, name, id, quant, kids, removed, originBegin, originEnd}:
      quant
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      quant
    case KLiteral{kind, number, text, literalBegin, literalEnd}:
      0


def ix(+t: KTerm) -> U32:
  p98_term_scalar_finish(p98_ix_read(t), t)

def qt(+t: KTerm) -> U32:
  p98_term_scalar_finish(p98_qt_read(t), t)

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

type P98ScalarCase is Data:
  P98ScalarCase{term: KTerm, oldIx: U32, newIx: U32, oldQt: U32, newQt: U32, ownedIx: U32, ownedQt: U32}

def p98_scalar_copy(term: KTerm) -> KTerm:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}: KTerm{tag, name, id, quant, kids, removed, begin, end}
    case KLambda{name, id, quant, kids, removed, begin, end, present}: KLambda{name, id, quant, kids, removed, begin, end, present}
    case KLiteral{kind, number, text, begin, end}: KLiteral{kind, number, text, begin, end}

def p98_scalar_case(+term: KTerm) -> P98ScalarCase:
  P98ScalarCase{term, p98_ix_reference(term), ix(term), p98_qt_reference(term), qt(term), ix(p98_scalar_copy(term)), qt(p98_scalar_copy(term))}

def p98_scalar_cases(terms: List<&2,KTerm>) -> List<&2,P98ScalarCase>:
  match terms:
    case Nil{}: Nil{}
    case Con{term, rest}: Con{p98_scalar_case(term), p98_scalar_cases(rest)}

def main() -> List<&2,P98ScalarCase>:
  p98_scalar_cases(Con{KTerm{"wide", "λ🙂", 4294967295, 4294967295, [p98_tag_child()], ["a", "a", ""], 4294967295, 0}, Con{KLambda{"wide", 4294967295, 4294967295, [p98_tag_child()], ["λ"], 0, 4294967295, True{}}, p98_tag_terms()}})
