# Same explicit frames, but ONE recursive owner instead of mutually recursive
# visit/rebuild/children/return functions. Tests direct-worker admission separately.
type P176SFrame is Data:
  P176SFrame{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>,
    mode: U32, begin: U32, end: U32}

@unsafe
def p176ps_reverse(terms: List<&2,KTerm>, done: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: done
    case Con{head,rest}: p176ps_reverse(rest,Con{head,done})

def p176ps_state(hit: Bool) -> U32:
  match hit:
    case True{}: 1
    case False{}: 2

@unsafe
def p176ps_loop(state: U32, +term: KTerm, terms: List<&2,KTerm>, +id: U32,
  +value: KTerm, +mode: U32, +begin: U32, +end: U32,
  stack: List<&1,P176SFrame>) -> KTerm:
  match state:
    case 0:
      p176ps_loop(p176ps_state(U32.is_eq(mode,0) && f_eq(tg(term),"Var") && U32.is_eq(ix(term),id)),
        term,Nil{},id,value,mode,begin,end,stack)
    case 1:
      p176ps_loop(2,value,Nil{},id,value,1,kb(term),ke(term),stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,oldBegin,oldEnd}:
          p176ps_loop(3,KTerm{tag,name,n,quant,Nil{},removed,
            f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
            f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd)},
            kids,id,value,mode,begin,end,stack)
        case KLambda{name,n,quant,kids,removed,oldBegin,oldEnd,present}:
          p176ps_loop(3,KLambda{name,n,quant,Nil{},removed,
            f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
            f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd),present},
            kids,id,value,mode,begin,end,stack)
        case KLiteral{kind,number,text,oldBegin,oldEnd}:
          p176ps_loop(4,KLiteral{kind,number,text,
            f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
            f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd)},
            Nil{},id,value,mode,begin,end,stack)
    case 3:
      match terms:
        case Nil{}: p176ps_loop(4,term,Nil{},id,value,mode,begin,end,stack)
        case Con{head,rest}:
          p176ps_loop(0,head,Nil{},id,value,mode,begin,end,
            Con{P176SFrame{term,rest,Nil{},mode,begin,end},stack})
    case _:
      match stack:
        case Nil{}: term
        case Con{P176SFrame{shell,rest,done,+oldMode,+oldBegin,+oldEnd},tail}:
          match rest:
            case Nil{}:
              p176ps_loop(4,k_with_children(shell,p176ps_reverse(Con{term,done},Nil{})),
                Nil{},id,value,oldMode,oldBegin,oldEnd,tail)
            case Con{head,pending}:
              p176ps_loop(0,head,Nil{},id,value,oldMode,oldBegin,oldEnd,
                Con{P176SFrame{shell,pending,Con{term,done},oldMode,oldBegin,oldEnd},tail})

@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  p176ps_sub_entry(t,id,value)

@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  p176ps_value_entry(t,begin,end)

@unsafe
def p176ps_sub_entry(t,id,value):
  p176ps_loop(0,t,Nil{},id,value,0,0,0,Nil{})

@unsafe
def p176ps_value_entry(t,begin,end):
  p176ps_loop(2,t,Nil{},0,KLiteral{"U32",0,"",0,0},1,begin,end,Nil{})
