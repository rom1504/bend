import Base

type N_WordKind is Data:
  N_W32{}
  N_W64{}
  N_Box{}

type NC_Binding is Data:
  NC_Binding{+id: U32, +word: String, +kind: N_WordKind}

def nk_typed_bindings(params: List<&2, NC_Binding>, kinds: List<&2, N_WordKind>) -> List<&2, NC_Binding>:
  match params, kinds:
    case Con{NC_Binding{id, word, old}, rest}, Con{kind, more}: Con{NC_Binding{0, "lost", kind}, nk_typed_bindings(rest, more)}
    case _, _: params

def nl_c_type(+k: N_WordKind) -> String:
  match k:
    case N_W32{}: "#if !DEVICE && NATIVE_TYPED_SCALARS\nu32\n#else\nTerm\n#endif\n"
    case N_W64{}: "Term"
    case N_Box{}: "Term"

def nf_param_type(kind: N_WordKind) -> String:
  match kind:
    case N_W32{}: "NF_SCALAR"
    case _: "Term"
