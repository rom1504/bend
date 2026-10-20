# Until direct Word-row recovery is qualified, retain the existing facts path.
@unsafe
def p113d_match(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +owner: String, +target: P113DTarget, +n: U32) -> P113DCode:
  nt_choose(P113DCode,nw_applicable(kid(t,0)),
    u => p113d_fail("direct: Word pattern retains qualified generic recovery",n),
    u => p113dm_original_match(book,t,env,owner,target,n))
