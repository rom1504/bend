# Driver only: retain the exact canonical f_span_created/g_share_head and
# k_with_children/k_with_span definitions when assembling this dependency slice.
# This exercises two complete allocating compiler computations and exposes all
# resulting term/graph fields to the ordinary generated-program readback.
type P173BWReport is Data:
  P173BWReport{+located: List<&2,KTerm>, +shared: List<&2,GResult>, +replaced: KTerm}

def p173bw_terms() -> List<&2,KTerm>:
  [KTerm{"Ctr","Pair",17,2,[
      KLiteral{"U32",7,"7",0,0},
      KLambda{"item",23,2,[KTerm{"Var","item",23,2,[],["var-note"],0,0}],
        ["lambda-note"],0,0,True{}}],["root-note"],0,0},
   KTerm{"Eql","equality",9,0,[KLiteral{"String",0,"payload",0,0},
      KTerm{"Ref","preserve-origin",3,1,[],[],71,79}],[],0,0},
   KLambda{"bound",31,0,[KTerm{"Var","bound",31,0,[],[],0,0}],[],0,0,False{}}]

@unsafe
def p173bw_locate(terms: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: []
    case Con{term,rest}: Con{f_span_created(term,11,49),p173bw_locate(rest)}

@unsafe
def p173bw_share(terms: List<&2,KTerm>) -> List<&2,GResult>:
  match terms:
    case Nil{}: []
    case Con{term,rest}: Con{g_share_head(GState{GEmpty{},1},term),p173bw_share(rest)}

def p173bw_result() -> P173BWReport:
  P173BWReport{p173bw_locate(p173bw_terms()),p173bw_share(p173bw_terms()),
    k_with_span(k_with_children(KTerm{"Ctr","Replacement",19,2,
      [KLiteral{"String",0,"old-child",1,8}],["retain-me"],1,8},
      [KLiteral{"U32",13,"13",2,4},KTerm{"Ref","new-child",5,2,[],[],2,4}]),51,60)}
