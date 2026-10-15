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
