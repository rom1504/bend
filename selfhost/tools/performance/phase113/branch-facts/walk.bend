@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => p113k_scalar_join(condition,p113k_scalars(yes,p113l_assume(facts,condition,True{})),p113k_scalars(no,p113l_assume(facts,condition,False{}))))

@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => p113k_body_join(condition,p113k_body(yes,p113l_assume(facts,condition,True{})),p113k_body(no,p113l_assume(facts,condition,False{}))))
