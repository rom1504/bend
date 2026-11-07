# Only this private result carries the producer fact. It is never a KTerm tag.
# False pending proves that lower is the identity on the completed higher term.
type P177CMaterial is Data:
  P177CMaterial{term: KTerm, pending: Bool}

@unsafe
def f_context_materialize(+term: KTerm) -> KTerm:
  p177cm_entry(term)

# The one changed existing recursive edge uses the same ordered high/low
# computation, retaining its private high-pass fact until low-pass admission.
@unsafe
def f_context_material_children(+term: KTerm, +children: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool) -> KTerm:
  match children:
    case Nil{}:
      f_context_material_done(f_choose(KTerm,List.is_empty(&2,KTerm,built),u => term,u => k_with_children(term,List.reverse(&2,KTerm,built))),lower)
    case Con{head,rest}:
      +deferred = f_context_material_deferred(term,rest,built)
      f_choose(KTerm,Bool.not(lower) && deferred,
        u => f_context_material_children(term,rest,Con{head,built},lower),
        u => f_context_material_next(term,rest,built,lower,
          f_choose(KTerm,lower,
            u => f_choose(KTerm,deferred,u => p177cm_entry(head),u => f_context_lower(head)),
            u => f_context_higher(head))))

law p177cm_higher:
  for +term: KTerm
  P177CMaterial

law p177cm_children:
  for +term: KTerm
  for +children: List<&2,KTerm>
  for +built: List<&2,KTerm>
  for pending: Bool
  P177CMaterial

law p177cm_next:
  for term: KTerm
  for rest: List<&2,KTerm>
  for built: List<&2,KTerm>
  for pending: Bool
  for head: P177CMaterial
  P177CMaterial

law p177cm_done:
  for +term: KTerm
  for pending: Bool
  P177CMaterial

@unsafe
def p177cm_higher(term):
  f_choose(P177CMaterial,f_context_stop(term),u => P177CMaterial{term,False{}},
    u => f_choose(P177CMaterial,f_eq(tg(term),"FName"),u => p177cm_higher(k_with_span(kid(term,1),kb(term),ke(term))),
      u => f_choose(P177CMaterial,f_eq(tg(term),"Ref") && f_implicit_operator(nm(term)),
        u => P177CMaterial{f_operator_error(term),False{}},
        u => p177cm_children(term,ks(term),Nil{},False{}))))

@unsafe
def p177cm_children(term,children,built,pending):
  match children:
    case Nil{}:
      p177cm_done(f_choose(KTerm,List.is_empty(&2,KTerm,built),u => term,u => k_with_children(term,List.reverse(&2,KTerm,built))),pending)
    case Con{+head,+rest}:
      f_choose(P177CMaterial,f_context_material_deferred(term,rest,built),
        u => p177cm_children(term,rest,Con{head,built},True{}),
        u => p177cm_next(term,rest,built,pending,p177cm_higher(head)))

@unsafe
def p177cm_next(term,rest,built,pending,head):
  match head:
    case P177CMaterial{+value,childPending}:
      f_choose(P177CMaterial,f_context_stop(value),
        u => P177CMaterial{value,False{}},
        u => p177cm_children(term,rest,Con{value,built},pending || childPending))

@unsafe
def p177cm_done(term,pending):
  f_choose(P177CMaterial,f_eq(tg(term),"App") && f_eq(tg(kid(term,0)),"Lam"),
    u => p177cm_higher(f_scope_app_span(kid(term,0),kid(term,1),kb(term),ke(term))),
    u => P177CMaterial{term,pending})

@unsafe
def p177cm_finish(result: P177CMaterial) -> KTerm:
  match result:
    case P177CMaterial{+term,pending}:
      f_choose(KTerm,pending,u => f_context_lower(term),u => term)

@unsafe
def p177cm_entry(term):
  p177cm_finish(p177cm_higher(term))
