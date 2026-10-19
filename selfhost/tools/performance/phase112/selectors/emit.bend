# Reuse the mature Phase99 checked-erasure selector rewrite. The only new
# operation is routing its ordinary KTerm result into structured P111 lowering.
# Do not broaden these gates independently of the mature ownership guards.
@unsafe
def p112b_guard(+args: List<&2,KTerm>, +n: U32, +count: U32) -> Bool:
  U32.is_gt(count,0) && U32.is_le(count,4) && U32.is_lt(n,4294967231) && nd_comb_literal(args)

@unsafe
def p112b_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,p98_tag_eq(selected,"Absent"),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,U32.add(n,64)))

@unsafe
def p112b_ref_app(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,U32.is_eq(qt(head),3),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => nt_choose(P111Code,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P111Code,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p112b_selected(book,t,head,args,env,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p112b_original_ref_app(book,t,head,args,env,n)),
      v => p112b_original_ref_app(book,t,head,args,env,n)))
