# Backend transfer of the consuming traversal practice. Preserve the exact Var
# hit/miss path, including its refusal to descend into even a nonempty Var.
# Only the non-Var reconstruction consumes the parent before child recursion.
@unsafe
def nq_layout_subst(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(t,"Var"),
    u => nt_choose(KTerm,U32.is_eq(ix(t),id),v => value,v => t),
    u => p173nq_owned(t,id,value))

@unsafe
def p173nq_owned(t, id, value):
  match t:
    case KTerm{tag,name,nodeId,quant,kids,removed,begin,end}:
      KTerm{tag,name,nodeId,quant,nq_layout_subst_list(kids,id,value),removed,begin,end}
    case KLambda{name,nodeId,quant,kids,removed,begin,end,present}:
      KLambda{name,nodeId,quant,nq_layout_subst_list(kids,id,value),removed,begin,end,present}
    case KLiteral{kind,number,text,begin,end}: t
