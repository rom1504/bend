# All-trivial roots have constant-time adapter disposal, including static graphs.
# Only schema root positions participate; scalar argument bits are irrelevant.
@unsafe
def no_all_trivial_roots(params: List<&2, N_Param>, +roots: List<&2, U32>, +i: U32) -> String:
  match params:
    case Nil{}: "1"
    case Con{N_Param{+word, kind}, rest}:
      nt_choose(String, no_root_index(roots, i), u => "term_triv(" ++ word ++ ") && ", u => "") ++ no_all_trivial_roots(rest, roots, U32.inc(i))
