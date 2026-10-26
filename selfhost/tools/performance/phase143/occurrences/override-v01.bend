# Candidate only. The selected source's exact declaration interface is retained;
# only its body delegates to the independently screened modular predicate.
@unsafe
def nd_comb_fresh(+body: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +left: U32) -> Bool:
  p143o_range(body,args,env,n,left)
