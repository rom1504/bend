import Base
import ./production-v01.bend as P

# Endpoint/thunk parameters are erased: the proof inspects only the total Bool.

law kc_negated_branch_swap:
  for -A: Type
  for b: Bool
  for -yes: Unit -> A
  for -no: Unit -> A
  {P.kc(A,Bool.not(b),yes,no) == P.kc(A,b,no,yes) : A}

def kc_negated_branch_swap(A,b,yes,no):
  match b:
    case False{}: {==}
    case True{}: {==}

law nt_choose_negated_branch_swap:
  for -A: Type
  for b: Bool
  for -yes: Unit -> A
  for -no: Unit -> A
  {P.nt_choose(A,Bool.not(b),yes,no) == P.nt_choose(A,b,no,yes) : A}

def nt_choose_negated_branch_swap(A,b,yes,no):
  match b:
    case False{}: {==}
    case True{}: {==}

law f_choose_negated_branch_swap:
  for -A: Type
  for b: Bool
  for -yes: Unit -> A
  for -no: Unit -> A
  {P.f_choose(A,Bool.not(b),yes,no) == P.f_choose(A,b,no,yes) : A}

def f_choose_negated_branch_swap(A,b,yes,no):
  match b:
    case False{}: {==}
    case True{}: {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
