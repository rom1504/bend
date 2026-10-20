# Exact width consumer replacement: Imm64 remains Term in both C paths.
@unsafe
def nl_c_type(+k: N_WordKind) -> String:
  match k:
    case N_W32{}: "#if !DEVICE && NATIVE_TYPED_SCALARS\nu32\n#else\nTerm\n#endif\n"
    case N_W64{}: "Term"
    case N_Box{}: "Term"
    case N_Imm64{}: "Term"

def p112to_nonowning(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case N_Imm64{}: True{}
    case _: False{}

# Preserve the original telescope traversal and its exact live-arity gate.
@unsafe
def nf_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, p98_tag_eq(head, "All"),
    u => nt_choose(List<&2, N_WordKind>, U32.is_eq(qt(head), 0), v => nf_kind_tele(book, kid(head, 1), left, fuel), v => Con{p113n_type_kind(book, kid(head, 0)), nf_kind_tele(book, kid(head, 1), U32.sub(left, 1), fuel)}),
    u => nf_opaque_kinds(left))

@unsafe
def p113_primitive_kind(+name: String, +arity: U32) -> N_WordKind:
  nt_choose(N_WordKind,p113n_primitive(name),
    u => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),v => N_Imm64{},v => N_W64{}),
    u => nt_choose(N_WordKind,p113_scalar_result_name(name),
      v => nt_choose(N_WordKind,U32.is_eq(arity,nc_primitive_arity(name)),w => N_W32{},w => N_W64{}),v => N_W64{}))

@unsafe
def p113_result_head(+book: List<&2,KDef>, +head: KTerm, +left: U32, +fuel: U32) -> N_WordKind:
  nt_choose(N_WordKind, p98_tag_eq(head,"All"),
    u => nt_choose(N_WordKind, U32.is_eq(terms_len(ks(head)),2) && Bool.not(nc_occurs(kid(head,1),ix(head))),
      v => nt_choose(N_WordKind, U32.is_eq(qt(head),0),
        w => p113_result_tele(book,kid(head,1),left,fuel),
        w => nt_choose(N_WordKind, U32.is_gt(left,0),
          z => p113_result_tele(book,kid(head,1),U32.sub(left,1),fuel), z => N_W64{})),
      v => N_W64{}),
    u => nt_choose(N_WordKind, U32.is_eq(left,0), v => p113n_type_kind(book,head), v => N_W64{}))

@unsafe
def p113_value_kind(+book: List<&2,KDef>, +value: KTerm, +env: List<&2,NC_Binding>) -> N_WordKind:
  nt_choose(N_WordKind,p98_tag_eq(value,"Ctr") || p98_tag_eq(value,"NCtr"),
    u => nt_choose(N_WordKind,p113n_constructor(book,nm(value),terms_len(ks(value))),v => N_Imm64{},v => p113n_original_value_kind(book,value,env)),
    u => p113n_original_value_kind(book,value,env))
