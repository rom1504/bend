@unsafe
def nl_c_type(+k: N_WordKind) -> String:
  match k:
    case N_W32{}: "#if !DEVICE && NATIVE_TYPED_SCALARS\nu32\n#else\nTerm\n#endif\n"
    case N_W64{}: "Term"
    case N_Box{}: "Term"


# Carry known scalar kinds with ownership bindings, so captures retain the
# same proof at a continuation entry. Unknown values remain full Terms.
@unsafe
def nk_kind(+id: U32, env: List<&2, NC_Binding>) -> N_WordKind:
  match env:
    case Nil{}: N_W64{}
    case Con{NC_Binding{at, word, +kind}, rest}: nt_choose(N_WordKind, U32.is_eq(id, at), u => kind, u => nk_kind(id, rest))

@unsafe
def nk_value(+value: KTerm, +env: List<&2, NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind, String.eq(tg(value), "Var"), u => nk_kind(ix(value), env), u => nt_choose(N_WordKind, String.eq(tg(value), "NWord"), v => N_W32{}, v => N_W64{}))

@unsafe
def nk_binding(+id: U32, +value: KTerm, +env: List<&2, NC_Binding>) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id), nk_value(value, env)}

@unsafe
def nk_typed_bindings(params: List<&2, NC_Binding>, kinds: List<&2, N_WordKind>) -> List<&2, NC_Binding>:
  match params, kinds:
    case Con{NC_Binding{id, word, old}, rest}, Con{kind, more}: Con{NC_Binding{id, word, kind}, nk_typed_bindings(rest, more)}
    case _, _: params

@unsafe
def nk_field_binding(+id: U32, +mask: U32, +i: U32) -> NC_Binding:
  NC_Binding{id, "v_" ++ U32.show(id), nt_choose(N_WordKind, U32.is_ne(U32.and(mask, U32.shln(1, U32.to_nat(i))), 0), u => N_W32{}, u => N_W64{})}
