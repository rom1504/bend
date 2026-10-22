# Local renderer context: all function parameters/results remain full Terms.
type P126LCtx is Data:
  P126LCtx{+params: List<&2,NC_Binding>, +buffers: List<&2,String>, +ids: N111Ids}

# Preserve the selected emitter's two-phase full-word backedge. Its temporary
# spelling is intentionally retained to allow byte-exact QBE comparison.
@unsafe
def p126l_snapshot(params: List<&2,NC_Binding>, values: List<&2,N111Value>, +ids: N111Ids, +index: U32, +code: P111QCode) -> P111QCode:
  match params values code:
    case Nil{} Nil{} _: code
    case Con{NC_Binding{id,word,kind},rest} Con{value,more} P111QCode{chunks,site,terminal,error}:
      p126l_snapshot(rest,more,ids,U32.inc(index),
        p111q_line("%p126_next_" ++ U32.show(index) ++ " =l copy " ++ p111q_value(value,ids) ++ "\n",code))
    case _ _ _: p111q_problem("typed backedge arity",code)

@unsafe
def p126l_moves(params: List<&2,NC_Binding>, +index: U32, +code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p113e_again_end(code)
    case Con{NC_Binding{id,word,kind},rest}:
      p126l_moves(rest,U32.inc(index),p111q_line(
        p111q_local(word) ++ " =l copy %p126_next_" ++ U32.show(index) ++ "\n",code))
