# Normal verified direct IR is the semantic boundary. This plan is an ordinary
# full-word constant decision; table rendering is a separate exact projection.
@unsafe
def p126s_decision(+word: String, values: List<&2,U32>, +index: U32) -> List<&2,P113DStmt>:
  match values:
    case Nil{}: []
    case Con{bits,Nil{}}: [P113DResult{[N111Const{bits,0}]}]
    case Con{bits,rest}:
      +condition = "p126_select_" ++ U32.show(index)
      [P113DScalar{N111Bin{condition,N111U64{},"eq",N111Local{word},N111Const{index,0}}},
       P113DIf{N111Local{condition},[P113DResult{[N111Const{bits,0}]}],p126s_decision(word,rest,U32.inc(index))}]

@unsafe
def p126s_original_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>) -> P113DCandidate:
  +arity = nd_arity(book,name)
  +params = nk_typed_bindings(nd_entry_params(arity,0),nf_worker_kinds(book,name,arity))
  +owner = p113d_public(book,name)
  +body = nc_compact_definition(book,lookup(book,name),0)
  p113pl_candidate_code(owner,params,atom("Absent"),True{},
    p113pl_lower(book,nd_reapply(body,nd_entry_args(params)),params,P113PTarget{[],atom("Absent"),True{},owner,signatures},arity))

@unsafe
def p126s_candidate_params(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, +values: List<&2,U32>, params: List<&2,NC_Binding>) -> P113DCandidate:
  match params:
    case [NC_Binding{+id,+word,+kind}]:
      P113DCandidate{P113DFunction{p113d_public(book,name),[NC_Binding{id,word,kind}],1,True{},p126s_decision(word,values,0)},"",[]}
    case _: p126s_original_candidate(book,name,signatures)

@unsafe
def p126s_candidate(+book: List<&2,KDef>, +name: String, +signatures: List<&2,KDef>, plan: Maybe<&2,List<&2,U32>>) -> P113DCandidate:
  match plan:
    case None{}: p126s_original_candidate(book,name,signatures)
    case Some{+values}:
      nt_choose(P113DCandidate,U32.is_ge(nt_count(U32,values),4),u =>
        p126s_candidate_params(book,name,signatures,values,nk_typed_bindings(nd_entry_params(1,0),nf_worker_kinds(book,name,1))),
        u => p126s_original_candidate(book,name,signatures))
