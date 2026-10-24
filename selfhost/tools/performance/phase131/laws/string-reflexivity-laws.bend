import Base
import ./string-production.bend as P
import ./compare-laws.bend as C

law char_equal_reflexive:
  for +value: Char
  {Char.is_eq(value,value) == True{} : Bool}

def char_equal_reflexive(value):
  match value:
    case Chr{+bits}:
      %C.u32_compare_reflexive(bits) : {Cmp.is_eq(U32.cmp(bits,bits)) == Cmp.is_eq(_) : Bool}
      {==}

# A pending mismatch must never be changed to True by an identity shortcut.
law string_diagonal_preserves_flag:
  for +value: String
  for +same: Bool
  {P.p88_string_eq_go(value,value,same) == same : Bool}

def string_diagonal_preserves_flag(value,same):
  match value same:
    case SNil{} False{}: {==}
    case SNil{} True{}: {==}
    case SCon{head,tail} False{}: {==}
    case SCon{+head,+tail} True{}:
      %Equal.sym(Bool,Char.is_eq(head,head),True{},char_equal_reflexive(head)) : {P.p88_string_eq_go(tail,tail,_) == True{} : Bool}
      string_diagonal_preserves_flag(tail,True{})

law string_equal_reflexive:
  for +value: String
  {P.p88_string_eq(value,value) == True{} : Bool}

def string_equal_reflexive(value):
  string_diagonal_preserves_flag(value,True{})

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
