# Same mature known-lambda rewrite and guards as Phase112 p112b_ref_app. Its
# structured result is lowered into the complete function instead of frames.
@unsafe
def p113db_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,p98_tag_eq(selected,"Absent"),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,U32.add(n,64)))

@unsafe
def p113db_ref_app(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,U32.is_eq(qt(head),3),
    u => p113db_original_ref_app(book,head,args,env,owner,target,n),
    u => nt_choose(P113DCode,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P113DCode,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p113db_selected(book,head,args,env,owner,target,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p113db_original_ref_app(book,head,args,env,owner,target,n)),
      v => p113db_original_ref_app(book,head,args,env,owner,target,n)))
