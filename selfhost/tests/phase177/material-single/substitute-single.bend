# Frontend f_sub differs from core subst: misses traverse stored Var children,
# Apps never beta-reduce, and a hit may fill only the replacement ROOT span.
type P177FSFrame is Data:
  P177FSFrame{shell: KTerm, rest: List<&2,KTerm>, built: List<&2,KTerm>}

@unsafe
def p177fs_reverse(terms: List<&2,KTerm>, built: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: built
    case Con{head,rest}: p177fs_reverse(rest,Con{head,built})

def p177fs_state(hit: Bool) -> U32:
  match hit:
    case True{}: 1
    case False{}: 2

@unsafe
def p177fs_loop(state: U32, +term: KTerm, +id: U32, +value: KTerm,
  +fill: Bool, stack: List<&1,P177FSFrame>) -> KTerm:
  match state:
    case 0:
      p177fs_loop(p177fs_state(f_eq(tg(term),"Var") && U32.is_eq(ix(term),id)),
        term,id,value,fill,stack)
    case 1:
      p177fs_loop(3,f_choose(KTerm,fill,u => k_with_span(value,kb(term),ke(term)),u => value),
        id,value,fill,stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}: p177fs_loop(3,term,id,value,fill,stack)
            case Con{head,rest}:
              p177fs_loop(0,head,id,value,fill,
                Con{P177FSFrame{KTerm{tag,name,n,quant,Nil{},removed,begin,end},rest,Nil{}},stack})
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177fs_loop(3,term,id,value,fill,stack)
            case Con{head,rest}:
              p177fs_loop(0,head,id,value,fill,
                Con{P177FSFrame{KLambda{name,n,quant,Nil{},removed,begin,end,present},rest,Nil{}},stack})
        case KLiteral{kind,number,text,begin,end}:
          p177fs_loop(3,term,id,value,fill,stack)
    case _:
      match stack:
        case Nil{}: term
        case Con{P177FSFrame{shell,rest,built},tail}:
          match rest:
            case Nil{}:
              p177fs_loop(3,k_with_children(shell,p177fs_reverse(Con{term,built},Nil{})),
                id,value,fill,tail)
            case Con{head,pending}:
              p177fs_loop(0,head,id,value,fill,
                Con{P177FSFrame{shell,pending,Con{term,built}},tail})

@unsafe
def f_sub(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  p177fs_entry(t,id,v)

@unsafe
def p177fs_entry(term,id,value):
  p177fs_loop(0,term,id,value,
    U32.is_eq(kb(value),0) && U32.is_eq(ke(value),0) && Bool.not(f_eq(tg(value),"FUnboundVar")),Nil{})
