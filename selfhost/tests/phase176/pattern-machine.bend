# Explicit frames replace the parent/list non-tail traversal cycle. This is a
# speculative source transform, not a proved optimization or selected compiler.
# The shell has no children, so completed ancestors do not retain whole inputs.
type P176Frame is Data:
  P176Frame{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>,
    mode: U32, begin: U32, end: U32}

law p176pm_visit:
  for +term: KTerm
  for +id: U32
  for +value: KTerm
  for +mode: U32
  for begin: U32
  for end: U32
  for stack: List<&1,P176Frame>
  KTerm

law p176pm_return:
  for term: KTerm
  for id: U32
  for value: KTerm
  for stack: List<&1,P176Frame>
  KTerm

@unsafe
def p176pm_reverse(terms: List<&2,KTerm>, done: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: done
    case Con{head,rest}: p176pm_reverse(rest,Con{head,done})

@unsafe
def p176pm_children(shell: KTerm, terms: List<&2,KTerm>, id: U32, value: KTerm,
  +mode: U32, +begin: U32, +end: U32, stack: List<&1,P176Frame>) -> KTerm:
  match terms:
    case Nil{}: p176pm_return(shell,id,value,stack)
    case Con{head,rest}:
      p176pm_visit(head,id,value,mode,begin,end,
        Con{P176Frame{shell,rest,Nil{},mode,begin,end},stack})

# All continuation cycles call the next state in tail position. Metadata span
# rewriting follows the original rule: only a positive occurrence begin wins.
@unsafe
def p176pm_rebuild(term: KTerm, id: U32, value: KTerm,
  mode: U32, +begin: U32, +end: U32, stack: List<&1,P176Frame>) -> KTerm:
  match term:
    case KTerm{tag,name,n,quant,kids,removed,oldBegin,oldEnd}:
      p176pm_children(KTerm{tag,name,n,quant,Nil{},removed,
        f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
        f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd)},
        kids,id,value,mode,begin,end,stack)
    case KLambda{name,n,quant,kids,removed,oldBegin,oldEnd,present}:
      p176pm_children(KLambda{name,n,quant,Nil{},removed,
        f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
        f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd),present},
        kids,id,value,mode,begin,end,stack)
    case KLiteral{kind,number,text,oldBegin,oldEnd}:
      p176pm_return(KLiteral{kind,number,text,
        f_choose(U32,U32.is_gt(begin,0),u => begin,u => oldBegin),
        f_choose(U32,U32.is_gt(begin,0),u => end,u => oldEnd)},id,value,stack)

@unsafe
def p176pm_decide(hit: Bool, +term: KTerm, id: U32, +value: KTerm, mode: U32,
  begin: U32, end: U32, stack: List<&1,P176Frame>) -> KTerm:
  match hit:
    case True{}: p176pm_rebuild(value,id,value,1,kb(term),ke(term),stack)
    case False{}: p176pm_rebuild(term,id,value,mode,begin,end,stack)

@unsafe
def p176pm_visit(term, id, value, mode, begin, end, stack):
  p176pm_decide(U32.is_eq(mode,0) && f_eq(tg(term),"Var") && U32.is_eq(ix(term),id),
    term,id,value,mode,begin,end,stack)

@unsafe
def p176pm_return(term, id, value, stack):
  match stack:
    case Nil{}: term
    case Con{P176Frame{shell,rest,done,+mode,+begin,+end},tail}:
      match rest:
        case Nil{}:
          p176pm_return(k_with_children(shell,p176pm_reverse(Con{term,done},Nil{})),id,value,tail)
        case Con{head,pending}:
          p176pm_visit(head,id,value,mode,begin,end,
            Con{P176Frame{shell,pending,Con{term,done},mode,begin,end},tail})

@unsafe
def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:
  p176pm_sub_entry(t,id,value)

@unsafe
def f_pattern_value(+t: KTerm, +begin: U32, +end: U32) -> KTerm:
  p176pm_value_entry(t,begin,end)

@unsafe
def p176pm_sub_entry(t,id,value):
  p176pm_visit(t,id,value,0,0,0,Nil{})

@unsafe
def p176pm_value_entry(t,begin,end):
  p176pm_visit(t,0,KLiteral{"U32",0,"",0,0},1,begin,end,Nil{})
