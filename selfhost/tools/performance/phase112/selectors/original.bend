# Exact Phase112 failstop-source01 p111_ref_app, with only its name changed.
@unsafe
def p112b_original_ref_app(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code, U32.is_eq(qt(head), 3), u => p111_slow_app(book, t, env, n),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), nd_arity(book, nm(head))),
      v => p111_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)))
