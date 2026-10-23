import Base

law word_compare_reflexive:
  for n: Nat
  for +value: Word(n)
  {Word.cmp(n,value,value) == EQ{} : Cmp}

def word_compare_reflexive(n,value):
  match n:
    case 0n: {==}
    case 1n+p:
      match value:
        case WCon{False{},+rest}:
          %word_compare_reflexive(p,rest) : {Word.cmp.fin(False{},False{},Word.cmp(p,rest,rest)) == Word.cmp.fin(False{},False{},_) : Cmp}
          {==}
        case WCon{True{},+rest}:
          %word_compare_reflexive(p,rest) : {Word.cmp.fin(True{},True{},Word.cmp(p,rest,rest)) == Word.cmp.fin(True{},True{},_) : Cmp}
          {==}

law u32_compare_reflexive:
  for +value: U32
  {U32.cmp(value,value) == EQ{} : Cmp}

def u32_compare_reflexive(value):
  match value:
    case U32{+bits}: word_compare_reflexive(32n,bits)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
