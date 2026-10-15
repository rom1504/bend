import Base
import ./candidate.bend as H

# Public: exact original id projection for every complete term value.
law retained_id_preserves:
  for term: H.KTerm
  {H.ix(term) == H.p98_original_ix(term) : U32}

def retained_id_preserves(term):
  match term:
    case H.KTerm{tag, name, id, quant, kids, removed, begin, end}: {==}
    case H.KLambda{name, id, quant, kids, removed, begin, end, present}: {==}
    case H.KLiteral{kind, number, text, begin, end}: {==}

# Public: exact original quantity projection, including arbitrary U32 values.
law retained_quantity_preserves:
  for term: H.KTerm
  {H.qt(term) == H.p98_original_qt(term) : U32}

def retained_quantity_preserves(term):
  match term:
    case H.KTerm{tag, name, id, quant, kids, removed, begin, end}: {==}
    case H.KLambda{name, id, quant, kids, removed, begin, end, present}: {==}
    case H.KLiteral{kind, number, text, begin, end}: {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
