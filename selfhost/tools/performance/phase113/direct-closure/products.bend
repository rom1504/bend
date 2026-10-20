@unsafe
def p113dc_product_selected(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32, +selected: KTerm) -> P113DCode:
  nt_choose(P113DCode,String.eq(tg(selected),"Absent"),
    u => p113pb_ref_app(book,head,args,env,target,n),
    u => p113pl_lower(book,selected,env,target,p113dc_next(book,head,n)))

@unsafe
def p113dc_product(+book: List<&2,KDef>, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +target: P113PTarget, +n: U32) -> P113DCode:
  p113dc_product_selected(book,head,args,env,target,n,p113dc_plan(book,head,args,env,n))
