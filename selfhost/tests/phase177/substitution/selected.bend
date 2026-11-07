# One recursive owner includes ordinary substitution AND eager App beta work.
# A beta frame restores the enclosing substitution before its next sibling.
# This is an experimental named override, not maintained compiler source.
type P177SFrame is Data:
  P177SNode{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>}
  P177SBeta{oldId: U32, oldValue: KTerm}

@unsafe
def p177s_reverse(terms: List<&2,KTerm>, done: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: done
    case Con{head,rest}: p177s_reverse(rest,Con{head,done})

def p177s_visit_state(variable: Bool, hit: Bool) -> U32:
  match variable:
    case False{}: 2
    case True{}:
      match hit:
        case False{}: 4
        case True{}: 1

def p177s_rebuild_state(application: Bool) -> U32:
  match application:
    case False{}: 7
    case True{}: 6

def p177s_leaf_state(application: Bool) -> U32:
  match application:
    case False{}: 4
    case True{}: 6

def p177s_apply_state(lambda: Bool) -> U32:
  match lambda:
    case False{}: 9
    case True{}: 8

@unsafe
def p177s_loop(state: U32, +term: KTerm, +terms: List<&2,KTerm>,
  +id: U32, +value: KTerm, stack: List<&1,P177SFrame>) -> KTerm:
  match state:
    case 0:
      p177s_loop(p177s_visit_state(p98_tag_eq(term,"Var"),U32.is_eq(ix(term),id)),
        term,Nil{},id,value,stack)
    case 1:
      p177s_loop(4,value,Nil{},id,value,stack)
    case 2:
      match term:
        case KTerm{tag,name,n,quant,kids,removed,begin,end}:
          match kids:
            case Nil{}:
              p177s_loop(p177s_leaf_state(p88_string_eq(tag,"App")),
                term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KTerm{tag,name,n,quant,Nil{},removed,begin,end},rest,Nil{}},stack})
        case KLambda{name,n,quant,kids,removed,begin,end,present}:
          match kids:
            case Nil{}: p177s_loop(4,term,Nil{},id,value,stack)
            case Con{head,rest}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{KLambda{name,n,quant,Nil{},removed,begin,end,present},rest,Nil{}},stack})
        case KLiteral{kind,number,text,begin,end}:
          p177s_loop(4,term,Nil{},id,value,stack)
    case 4:
      match stack:
        case Nil{}: term
        case Con{P177SBeta{oldId,oldValue},tail}:
          p177s_loop(4,term,Nil{},oldId,oldValue,tail)
        case Con{P177SNode{shell,rest,done},tail}:
          match rest:
            case Nil{}:
              p177s_loop(5,shell,p177s_reverse(Con{term,done},Nil{}),id,value,tail)
            case Con{head,pending}:
              p177s_loop(0,head,Nil{},id,value,
                Con{P177SNode{shell,pending,Con{term,done}},tail})
    case 5:
      p177s_loop(p177s_rebuild_state(p98_tag_eq(term,"App")),
        term,terms,id,value,stack)
    case 6:
      p177s_loop(p177s_apply_state(p98_tag_eq(terms_at(terms,0),"Lam")),
        term,terms,id,value,stack)
    case 7:
      p177s_loop(4,k_with_children(term,terms),Nil{},id,value,stack)
    case 8:
      +function = terms_at(terms,0)
      p177s_loop(0,kid(function,0),Nil{},ix(function),terms_at(terms,1),
        Con{P177SBeta{id,value},stack})
    case _:
      p177s_loop(4,kt_span("App","",0,0,[terms_at(terms,0),terms_at(terms,1)],kb(term),ke(term)),
        Nil{},id,value,stack)

@unsafe
def subst(+t: KTerm, +id: U32, +v: KTerm) -> KTerm:
  p177s_entry(t,id,v)

@unsafe
def subst_node(t,id0,v):
  p177s_node_entry(t,id0,v)

@unsafe
def p177s_entry(t,id,value):
  p177s_loop(0,t,Nil{},id,value,Nil{})

@unsafe
def p177s_node_entry(t,id,value):
  p177s_loop(2,t,Nil{},id,value,Nil{})
