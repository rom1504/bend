import Base

type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}

# Module: src/back/native/ir.bend:8
type N_Param is Data:
  N_Param{+name: String, +kind: N_WordKind}

# Module: src/back/native/ir.bend:11
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.

# Module: src/back/native/text.bend:10
def no_root_index(roots: List<&2, U32>, +i: U32) -> Bool:
  match roots:
    case Nil{}: False{}
    case Con{root, rest}: U32.is_eq(root, i) || no_root_index(rest, i)

# Module: src/back/native/observer-adapter.bend:20
def no_all_trivial_roots(params: List<&2, N_Param>, +roots: List<&2, U32>, +i: U32) -> String:
  match params:
    case Nil{}: "0"
    case Con{N_Param{+word, kind}, rest}:
      nt_choose(String, no_root_index(roots, i), u => "term_triv(" ++ word ++ ") && ", u => "") ++ no_all_trivial_roots(rest, roots, U32.inc(i))

# Module: src/back/native/observer-integration.bend:110
