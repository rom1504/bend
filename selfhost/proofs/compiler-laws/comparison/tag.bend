import Base
import ./production.bend as P
import ./candidate.bend as H
import ./held-simple.bend as B

# Support: exact fused read and exact production tg for all three constructors.
law tag_read_matches_projection:
  for term: H.KTerm
  for key: String
  {H.p88_string_eq(H.tg(term), key) == H.p98_tag_eq_read(term, key) : Bool}

def tag_read_matches_projection(term, key):
  match term:
    case H.KTerm{tag, name, id, quant, kids, removed, begin, end}: {==}
    case H.KLambda{name, id, quant, kids, removed, begin, end, present}: {==}
    case H.KLiteral{kind, number, text, begin, end}: {==}

# Public: complete Bool preservation relative to the original D04 comparison.
# Tags, metadata, children, payloads and keys are arbitrary; no enum assumption.
law tag_comparison_preserves:
  for +term: H.KTerm
  for +key: String
  {H.p98_tag_eq(term, key) == P.p88_string_eq(H.tg(term), key) : Bool}

def tag_comparison_preserves(term, key):
  %tag_read_matches_projection(term, key) : {_ == P.p88_string_eq(H.tg(term), key) : Bool}
  %B.held_comparison_preserves(H.tg(term), key) : {_ == P.p88_string_eq(H.tg(term), key) : Bool}
  {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
