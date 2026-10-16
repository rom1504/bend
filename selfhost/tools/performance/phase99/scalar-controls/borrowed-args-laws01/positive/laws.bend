import Base
import ./candidate.bend as H

# Argument order and failure propagation at the actual residual-list boundary.
# These contracts do not certify any word's type, root ancestry or lifetime.
law borrowed_args_preserve_order:
  for +id: U32
  for +tail: List<&2, H.KTerm>
  {H.nob_words_cons(H.kt("Var", "", id, 0, Nil{}), H.kt("NO_Args", "", 0, 0, tail)) == H.kt("NO_Args", "", 0, 0, Con{H.kt("Var", "", id, 0, Nil{}), tail}) : H.KTerm}

def borrowed_args_preserve_order(id, tail): {==}

law borrowed_args_rejected_head_poison:
  for tail: List<&2, H.KTerm>
  {H.nob_words_cons(H.atom("Absent"), H.kt("NO_Args", "", 0, 0, tail)) == H.atom("Absent") : H.KTerm}

def borrowed_args_rejected_head_poison(tail): {==}

law borrowed_args_rejected_tail_poison:
  for id: U32
  {H.nob_words_cons(H.kt("Var", "", id, 0, Nil{}), H.atom("Absent")) == H.atom("Absent") : H.KTerm}

def borrowed_args_rejected_tail_poison(id): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
