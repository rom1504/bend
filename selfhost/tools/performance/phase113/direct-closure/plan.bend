# Bounded literal-combinator reuse. The mature semantic plan proves a closed
# App/Var body, exactly one use of each formal, and freshness before replacing
# literal function actuals. Nonliteral actuals remain ordered outer lets.
@unsafe
def p113dc_definition(+book: List<&2,KDef>, +d: KDef, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  nt_choose(KTerm,String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => nt_choose(KTerm,U32.is_eq(nd_leading(dv(d),0),arity) && U32.is_le(n,U32.sub(4294967295,arity)),
      v => nd_comb_try(nc_erase(book,dv(d)),args,env,n,arity),
      v => atom("Absent")),
    u => atom("Absent"))

@unsafe
def p113dc_arity(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +arity: U32) -> KTerm:
  +count = terms_len(args)
  nt_choose(KTerm,U32.is_gt(arity,0) && U32.is_le(arity,8) && U32.is_gt(count,0) && U32.is_le(count,arity) && nd_comb_literal(args),
    u => p113dc_definition(book,lookup(book,nm(head)),args,env,n,arity),
    u => atom("Absent"))

@unsafe
def p113dc_plan(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> KTerm:
  nt_choose(KTerm,String.eq(tg(head),"Ref") && Bool.not(U32.is_eq(qt(head),3)),
    u => p113dc_arity(book,head,args,env,n,nd_arity(book,nm(head))),
    u => atom("Absent"))

@unsafe
def p113dc_next(+book: List<&2,KDef>, +head: KTerm, +n: U32) -> U32:
  U32.add(n,nd_arity(book,nm(head)))
