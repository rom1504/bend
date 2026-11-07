# Experimental source ceiling: the existing materializer carries metadata but
# no original child list across recursive transformation. Its child loop,
# deferred scheduling, first-error rule and final reduction remain unchanged.
@unsafe
def f_context_higher(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(term), u => term,
    u => f_choose(KTerm, f_eq(tg(term), "FName"), u => f_context_higher(k_with_span(kid(term, 1), kb(term), ke(term))),
      u => f_choose(KTerm, f_eq(tg(term), "Ref") && f_implicit_operator(nm(term)), u => f_operator_error(term),
        u => p173cm_enter(term, False{}))))

# Preserve the existing no-child identity route, including arbitrary record
# metadata and literal variants. This observer ends before owned decomposition.
@unsafe
def p173cm_enter(term, lower):
  f_choose(KTerm, List.is_empty(&2,KTerm,ks(term)),
    u => f_context_material_done(term,lower),
    u => p173cm_split(term,lower))

# Consuming the root exposes ordinary owned fields. Genuine external aliases
# retain their normal ownership; there is no uniqueness assumption or raw heap
# pointer, and the preserved shell never contains the original kids.
@unsafe
def p173cm_split(term, lower):
  match term:
    case KTerm{tag,name,nodeId,quant,kids,removed,begin,end}:
      f_context_material_children(KTerm{tag,name,nodeId,quant,Nil{},removed,begin,end},kids,Nil{},lower)
    case KLambda{name,nodeId,quant,kids,removed,begin,end,present}:
      f_context_material_children(KLambda{name,nodeId,quant,Nil{},removed,begin,end,present},kids,Nil{},lower)
    case KLiteral{kind,number,text,begin,end}:
      f_context_material_done(term,lower)
