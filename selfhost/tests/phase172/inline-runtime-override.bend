# Experimental late emitter only. The ordinary final verifier is unchanged.
@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  p172ir_emit(stmt,ids,code)

# Preserve numeric constructor identity and arity. In the N111Id namespace,
# native carries the already checked hot flag; unsafe marks its presence.
# All pre-existing N111Id consumers ignore both flags.
@unsafe
def p111q_constructor_ids(constructors: List<&2,N_Constructor>, +next: U32, tree: KDef) -> KDef:
  match constructors:
    case Nil{}: tree
    case Con{N_Constructor{+name,arity,hot},rest}:
      p111q_constructor_ids(rest,U32.inc(next),
        index_set(tree,KDef{name,"N111Id",next,arity,
          KTerm{"Absent","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},[],hot,True{}},
          index_hash(name,2166136261),32))
