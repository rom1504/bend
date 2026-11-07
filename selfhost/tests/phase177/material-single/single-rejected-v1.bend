# Higher and lower retain their original ordering in one recursive owner.
# The returned term and pending bit travel in loop arguments, not a wrapper.
type P177MSFrame is Data:
  P177MSNode{shell: KTerm, rest: List<&2,KTerm>, built: List<&2,KTerm>,
    pending: Bool, lower: Bool}
  P177MSFinish{}

@unsafe
def p177ms_reverse(terms: List<&2,KTerm>, built: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: built
    case Con{head,rest}: p177ms_reverse(rest,Con{head,built})

@unsafe
def p177ms_enter(+term: KTerm, lower: Bool) -> U32:
  f_choose(U32,f_context_stop(term),u => 1,
    u => f_choose(U32,lower,u => 4,
      u => f_choose(U32,f_eq(tg(term),"FName"),u => 2,
        u => f_choose(U32,f_eq(tg(term),"Ref") && f_implicit_operator(nm(term)),
          u => 3,u => 4))))

def p177ms_child(lower: Bool, deferred: Bool) -> U32:
  match deferred:
    case False{}: 8
    case True{}:
      match lower:
        case False{}: 7
        case True{}: 9

def p177ms_done(beta: Bool) -> U32:
  match beta:
    case False{}: 11
    case True{}: 10

def p177ms_finish(pending: Bool) -> U32:
  match pending:
    case False{}: 11
    case True{}: 0

@unsafe
def p177ms_loop(state: U32, +term: KTerm, +children: List<&2,KTerm>,
  +built: List<&2,KTerm>, +pending: Bool, +lower: Bool,
  stack: List<&1,P177MSFrame>) -> KTerm:
  match state:
    case 0:
      p177ms_loop(p177ms_enter(term,lower),term,Nil{},Nil{},False{},lower,stack)
    case 1:
      term
    case 2:
      p177ms_loop(0,k_with_span(kid(term,1),kb(term),ke(term)),Nil{},Nil{},False{},False{},stack)
    case 3:
      f_operator_error(term)
    case 4:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}: p177ms_loop(6,term,Nil{},Nil{},False{},lower,stack)
            case Con{head,rest}:
              p177ms_loop(5,KTerm{tag,name,n,quant,Nil{},removed,begin,end},
                kids,Nil{},False{},lower,stack)
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177ms_loop(6,term,Nil{},Nil{},False{},lower,stack)
            case Con{head,rest}:
              p177ms_loop(5,KLambda{name,n,quant,Nil{},removed,begin,end,present},
                kids,Nil{},False{},lower,stack)
        case KLiteral{kind,number,text,begin,end}:
          p177ms_loop(6,term,Nil{},Nil{},False{},lower,stack)
    case 5:
      match children:
        case Nil{}:
          p177ms_loop(6,k_with_children(term,p177ms_reverse(built,Nil{})),
            Nil{},Nil{},pending,lower,stack)
        case Con{+head,+rest}:
          p177ms_loop(p177ms_child(lower,f_context_material_deferred(term,rest,built)),
            term,children,built,pending,lower,stack)
    case 6:
      p177ms_loop(p177ms_done(Bool.not(lower) && f_eq(tg(term),"App") && f_eq(tg(kid(term,0)),"Lam")),
        term,Nil{},Nil{},pending,lower,stack)
    case 7:
      match children:
        case Nil{}: p177ms_loop(5,term,children,built,pending,lower,stack)
        case Con{head,rest}:
          p177ms_loop(5,term,rest,Con{head,built},True{},False{},stack)
    case 8:
      match children:
        case Nil{}: p177ms_loop(5,term,children,built,pending,lower,stack)
        case Con{head,rest}:
          p177ms_loop(0,head,Nil{},Nil{},False{},lower,
            Con{P177MSNode{term,rest,built,pending,lower},stack})
    case 9:
      match children:
        case Nil{}: p177ms_loop(5,term,children,built,pending,lower,stack)
        case Con{head,rest}:
          p177ms_loop(0,head,Nil{},Nil{},False{},False{},
            Con{P177MSFinish{},Con{P177MSNode{term,rest,built,pending,lower},stack}})
    case 10:
      p177ms_loop(0,f_scope_app_span(kid(term,0),kid(term,1),kb(term),ke(term)),
        Nil{},Nil{},False{},False{},stack)
    case _:
      match stack:
        case Nil{}: term
        case Con{P177MSFinish{},tail}:
          p177ms_loop(p177ms_finish(pending),term,Nil{},Nil{},False{},True{},tail)
        case Con{P177MSNode{shell,rest,done,parentPending,parentLower},tail}:
          p177ms_loop(5,shell,rest,Con{term,done},parentPending || pending,parentLower,tail)

@unsafe
def f_context_materialize(+term: KTerm) -> KTerm:
  p177ms_entry(term)

@unsafe
def p177ms_entry(term):
  p177ms_loop(0,term,Nil{},Nil{},False{},False{},[P177MSFinish{}])
