# One recursive owner for the existing freshening worklist. FFFrame, exact
# preorder ID allocation, simultaneous let scope and all reconstruction APIs
# are unchanged. The old mutually recursive definitions remain as controls.

@unsafe
def f_fresh_stack(+term: KTerm, +env: List<&2,KTerm>, +next: U32) -> FFresh:
  p177ff_entry(term,env,next)

@unsafe
def p177ff_tag(+term: KTerm) -> U32:
  f_choose(U32,p98_tag_eq(term,"FName"),u => 1,
    u => f_choose(U32,p98_tag_eq(term,"FGlobal"),u => 2,
    u => f_choose(U32,p98_tag_eq(term,"FUnboundVar"),u => 3,
    u => f_choose(U32,p98_tag_eq(term,"Var"),u => 4,
    u => f_choose(U32,p98_tag_eq(term,"All"),u => 5,
    u => f_choose(U32,p98_tag_eq(term,"Lam"),u => 6,
    u => f_choose(U32,p98_tag_eq(term,"Let"),u => 7,u => 8)))))))

law p177ff_loop:
  for state: U32
  for +term: KTerm
  for +env: List<&2,KTerm>
  for +bodyenv: List<&2,KTerm>
  for pending: List<&2,KTerm>
  for built: List<&2,KTerm>
  for +next: U32
  for stack: List<&2,FFFrame>
  FFresh

@unsafe
def p177ff_loop(state,term,env,bodyenv,pending,built,next,stack):
  match state:
    case 0:
      p177ff_loop(p177ff_tag(term),term,env,Nil{},Nil{},Nil{},next,stack)
    case 1:
      p177ff_loop(0,k_with_span(kid(term,1),kb(term),ke(term)),env,Nil{},Nil{},Nil{},next,stack)
    case 2:
      p177ff_loop(9,kt_span("Ref",nm(term),0,1,Nil{},kb(term),ke(term)),Nil{},Nil{},Nil{},Nil{},next,stack)
    case 3:
      p177ff_loop(9,term,Nil{},Nil{},Nil{},Nil{},next,stack)
    case 4:
      p177ff_loop(9,f_rename_var(term,env),Nil{},Nil{},Nil{},Nil{},next,stack)
    case 5:
      p177ff_loop(0,kid(term,0),env,Nil{},Nil{},Nil{},U32.add(next,1),Con{FFAllA{term,env,next},stack})
    case 6:
      p177ff_loop(0,kid(term,0),Con{kt("Map","",ix(term),0,[var(nm(term),next)]),env},Nil{},Nil{},Nil{},U32.add(next,1),Con{FFLambda{term,next},stack})
    case 7:
      p177ff_loop(10,KLiteral{"U32",0,"",0,0},env,env,ks(term),Nil{},next,Con{FFOrigin{kb(term),ke(term)},stack})
    case 8:
      p177ff_loop(11,term,env,Nil{},ks(term),Nil{},next,stack)
    case 9:
      match stack:
        case Nil{}: FFresh{term,next}
        case Con{frame,rest}:
          match frame:
            case FFAllA{+parent,+outer,+id}:
              p177ff_loop(0,kid(parent,1),Con{kt("Map","",ix(parent),0,[var(nm(parent),id)]),outer},Nil{},Nil{},Nil{},next,Con{FFAllB{parent,id,term},rest})
            case FFAllB{+parent,id,typ}:
              p177ff_loop(9,kt_span("All",nm(parent),id,qt(parent),[typ,term],kb(parent),ke(parent)),Nil{},Nil{},Nil{},Nil{},next,rest)
            case FFLambda{+parent,id}:
              p177ff_loop(9,k_lam(nm(parent),id,qt(parent),[term],kb(parent),ke(parent),k_quantity_present(parent)),Nil{},Nil{},Nil{},Nil{},next,rest)
            case FFKids{parent,outer,remaining,done}:
              p177ff_loop(11,parent,outer,Nil{},remaining,Con{term,done},next,rest)
            case FFLetValue{outer,inner,+id,+binding,remaining,done}:
              p177ff_loop(10,KLiteral{"U32",0,"",0,0},outer,Con{kt("Map","",ix(binding),0,[var(nm(binding),id)]),inner},remaining,Con{kt_span("Bind",nm(binding),id,qt(binding),[term],kb(binding),ke(binding)),done},next,rest)
            case FFOrigin{begin,end}:
              p177ff_loop(9,k_with_span(term,begin,end),Nil{},Nil{},Nil{},Nil{},next,rest)
            case FFLetBody{done}:
              p177ff_loop(9,kt("Let","",0,1,ffw_reverse_onto(done,[term])),Nil{},Nil{},Nil{},Nil{},next,rest)
    case 10:
      match pending:
        case Nil{}:
          p177ff_loop(9,kt("Error","empty core let",0,0,Nil{}),Nil{},Nil{},Nil{},Nil{},next,stack)
        case Con{+binding,+tail}:
          match tail:
            case Nil{}:
              p177ff_loop(0,binding,bodyenv,Nil{},Nil{},Nil{},next,Con{FFLetBody{built},stack})
            case Con{head,rest}:
              p177ff_loop(0,kid(binding,0),env,Nil{},Nil{},Nil{},U32.add(next,1),Con{FFLetValue{env,bodyenv,next,binding,tail,built},stack})
    case _:
      match pending:
        case Nil{}:
          p177ff_loop(9,k_with_children(term,ffw_reverse_onto(built,Nil{})),Nil{},Nil{},Nil{},Nil{},next,stack)
        case Con{head,rest}:
          p177ff_loop(0,head,env,Nil{},Nil{},Nil{},next,Con{FFKids{term,env,rest,built},stack})

@unsafe
def p177ff_entry(term,env,next):
  p177ff_loop(0,term,env,Nil{},Nil{},Nil{},next,Nil{})
