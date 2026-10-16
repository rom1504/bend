import Base
import ./candidate.bend as H

# These constrain the exact C predicate text from the actual source helper.
# They do not prove the meaning of term_triv or any native root lifetime.
law trivial_guard_conjoins_both_roots:
  for +left: String
  for +right: String
  {H.no_all_trivial_roots([H.N_Param{left, H.N_Box{}}, H.N_Param{right, H.N_Box{}}], [0, 1], 0) == ("term_triv(" ++ left ++ ") && ") ++ (("term_triv(" ++ right ++ ") && ") ++ "1") : String}

def trivial_guard_conjoins_both_roots(left, right): {==}

law trivial_guard_skips_scalar_slot:
  for +left: String
  for scalar: String
  for +right: String
  {H.no_all_trivial_roots([H.N_Param{left, H.N_Box{}}, H.N_Param{scalar, H.N_W64{}}, H.N_Param{right, H.N_Box{}}], [0, 2], 0) == ("term_triv(" ++ left ++ ") && ") ++ (("term_triv(" ++ right ++ ") && ") ++ "1") : String}

def trivial_guard_skips_scalar_slot(left, scalar, right): {==}

law trivial_guard_empty_tail_identity:
  for roots: List<&2, U32>
  for start: U32
  {H.no_all_trivial_roots(Nil{}, roots, start) == "1" : String}

def trivial_guard_empty_tail_identity(roots, start): {==}

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
