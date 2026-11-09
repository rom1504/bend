# Experimental replacement definitions only. Each differs from its current
# maintained definition by one size literal. All semantic predicates remain.

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114HPlan,p124r_known(ready,name),v => p114h_refused(),
          v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),2048),
            w => nt_choose(P114HPlan,p112f_clean(body),
              x => nt_choose(P114HPlan,p114h_clean_segment(segment),
                y => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),y => p114h_refused()),
              x => p114h_refused()),w => p114h_refused())),
        u => p114h_refused())

@unsafe
def p112f_cont_result(body: List<&2,N111Stmt>, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_reg_get") && String.eq(state,"state") && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")) && p112f_safe(rest) && U32.is_le(p112f_size(rest),1024),
        u => Some{P112FusionCont{nt_reverse(String,captures,[]),word,pop,rest}},u => None{})
    case _: None{}
