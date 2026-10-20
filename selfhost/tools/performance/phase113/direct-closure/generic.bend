@unsafe
def p113dc_generic_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,String.eq(tg(selected),"Absent"),
    u => p112b_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,p113dc_next(book,head,n)))

@unsafe
def p113dc_generic(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  p113dc_generic_selected(book,t,head,args,env,n,p113dc_plan(book,head,args,env,n))
