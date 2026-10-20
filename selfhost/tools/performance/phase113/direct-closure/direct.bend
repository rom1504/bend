@unsafe
def p113dc_direct_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,String.eq(tg(selected),"Absent"),
    u => p113db_ref_app(book,head,args,env,owner,target,n),
    u => p113d_lower(book,selected,env,owner,target,p113dc_next(book,head,n)))

@unsafe
def p113dc_direct(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  p113dc_direct_selected(book,head,args,env,owner,target,n,p113dc_plan(book,head,args,env,n))
