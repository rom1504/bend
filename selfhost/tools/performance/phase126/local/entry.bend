# All formals/calls/results use the existing full-Term ABI. A function with no
# admitted local operand buffer keeps the exact selected fallback, including
# the separately composed finite-selector hook.
@unsafe
def p126l_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++
        p111q_body_text(p126l_stmts(body,P126LCtx{params,buffers,ids},[],
          P111QCode{Con{"",Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""})) ++ "}\n"

@unsafe
def p126l_emit_one(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0) && Bool.not(List.is_empty(&2,String,p114so_buffers(body))),
        u => p126l_private(function,ids),u => p113ah_function(function,ids,heap_min))

@unsafe
def p126l_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p126l_chunks(rest,ids,heap_min,Con{p126l_emit_one(head,ids,heap_min),acc})

@unsafe
def p113ah_private_chunks(+functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, +acc: List<&2,String>) -> List<&2,String>:
  p126l_chunks(functions,ids,heap_min,acc)
