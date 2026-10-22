# Exact selected private renderer retained under an alias. This hook is reached
# by the normal heap renderer and by the unplanned typed-companion fallback.
@unsafe
def p126s_original_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p111q_body_text(p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""})) ++ "}\n"

@unsafe
def p113e_private(+function: P113DFunction, +ids: N111Ids) -> String:
  +table = p126s_emit(function)
  nt_choose(String,String.is_empty(table),u => p126s_original_private(function,ids),u => table)
