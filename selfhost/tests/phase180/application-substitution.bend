# Experimental overrides for canonical KApply terms. The retained generic App
# path still visits every supplied child before canonicalizing its first pair.
# Requires KApply and k_apply_span from the representation overlay.
type P177SFrame is Data:
  P177SNode{shell: KTerm, rest: List<&2,KTerm>, done: List<&2,KTerm>}
  P177SBeta{oldId: U32, oldValue: KTerm}
  P177SApplyFunction{argument: KTerm, begin: U32, end: U32}
  P177SApplyArgument{+function: KTerm, begin: U32, end: U32}

def p180s_apply_state(lambda: Bool) -> U32:
  match lambda:
    case True{}: 10
    case False{}: 11

# Function and argument are traversed in the ordinary left-to-right order.
# Neither compact branch constructs a semantic child list or a generic shell.
# Beta substitution has the same owner and restores the enclosing id/value
# before returning to either a compact or generic parent's next sibling.
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
        case KApply{function,argument,begin,end}:
          p177s_loop(0,function,Nil{},id,value,
            Con{P177SApplyFunction{argument,begin,end},stack})
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
        case Con{P177SApplyFunction{argument,begin,end},tail}:
          p177s_loop(0,argument,Nil{},id,value,
            Con{P177SApplyArgument{term,begin,end},tail})
        case Con{P177SApplyArgument{function,begin,end},tail}:
          p177s_loop(p180s_apply_state(p98_tag_eq(function,"Lam")),term,Nil{},id,value,stack)
    case 10:
      match stack:
        case Con{P177SApplyArgument{function,begin,end},tail}:
          p177s_loop(0,kid(function,0),Nil{},ix(function),term,
            Con{P177SBeta{id,value},tail})
        case _: term
    case 11:
      match stack:
        case Con{P177SApplyArgument{function,begin,end},tail}:
          p177s_loop(4,k_apply_span(function,term,begin,end),Nil{},id,value,tail)
        case _: term
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
      p177s_loop(4,k_apply_span(terms_at(terms,0),terms_at(terms,1),kb(term),ke(term)),
        Nil{},id,value,stack)

# Independent controls should observe complete values, including source spans:
# - a compact neutral App with a substituted argument retains its outer span;
# - substituting a Lambda for the function enters beta work after the argument;
# - beta in the function restores the outer substitution before the argument;
# - beta in an argument restores it before the next generic parent sibling;
# - a matched Var returns its replacement verbatim, even a reducible KApply;
# - subst_node traverses a Var's stored children instead of replacing its root;
# - generic Apps with zero, one, or excess children keep their previous behavior;
# - mixed legacy/KLambda binders keep quantity presence and removed metadata.
