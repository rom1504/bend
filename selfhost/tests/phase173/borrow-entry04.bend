# Three selected direct-body dispatchers. No verifier/runtime replacement.
@unsafe
def p113w_stmts(body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  p173b_stmts(body,params,ids,code)

@unsafe
def p126i_stmts(body: List<&2,P113DStmt>, +ctx: P126ICtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  p173b_i_stmts(body,ctx,facts,code)

@unsafe
def p126l_stmts(body: List<&2,P113DStmt>, +ctx: P126LCtx, +facts: List<&2,P114FLFact>, +code: P111QCode) -> P111QCode:
  p173b_l_stmts(body,ctx,facts,code)

# Preserve the already checked per-constructor publication policy in the private
# N111Id metadata. All pre-existing consumers ignore these two fields.
@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,
          KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],hot,True{}},
          index_hash(name,2166136261),32))
