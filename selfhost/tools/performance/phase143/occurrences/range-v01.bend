# A Bool summary of collision with the exact cyclic fresh-ID interval.
# If M=2^32, candidate(i)=M-1-((n+i) mod M). Its unique inverse step
# is ((M-1-id)-n) mod M. Since left is a U32 (<M), membership is step<left.
@unsafe
def p143o_in_range(+id: U32, +n: U32, +left: U32) -> Bool:
  U32.is_lt(U32.sub(nc_id(id),n),left)

@unsafe
def p143o_range_term(+t: KTerm, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,p98_tag_eq(t,"Var"),u => p143o_in_range(ix(t),n,left),
    u => p143o_range_terms(ks(t),n,left))

@unsafe
def p143o_range_terms(terms: List<&2,KTerm>, +n: U32, +left: U32) -> Bool:
  match terms:
    case Nil{}: False{}
    case Con{head,rest}: p143o_range_term(head,n,left) || p143o_range_terms(rest,n,left)

# Preserve first-match nc_word and its literal sentinel semantics. This loop
# has the same U32 sequence and termination budget as nd_comb_fresh.
@unsafe
def p143o_range_env(+env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    nt_choose(Bool,p88_string_eq(nc_word(nc_id(n),env),"NATIVE_UNBOUND_VARIABLE"),
      u => p143o_range_env(env,U32.inc(n),U32.sub(left,1)),u => False{}))

@unsafe
def p143o_range(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    Bool.not(p143o_range_term(body,n,left)) && Bool.not(p143o_range_terms(args,n,left)) &&
      p143o_range_env(env,n,left))
