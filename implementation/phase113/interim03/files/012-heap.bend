# Separate stable-base experiment. The sole extra entry instruction is a
# structured load from state->e.mem. It precedes the self-loop label, so Again
# does not reload it. All operation predicates and payload loads stay in place.
@unsafe
def p113ah_loop(+body: List<&2,P113DStmt>, +params: List<&2,NC_Binding>, +ids: N111Ids, entry: P111QCode) -> P111QCode:
  match entry:
    case P111QCode{chunks,n,terminal,error}:
      p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",chunks}},n,False{},error})

@unsafe
def p113ah_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p111q_body_text(p113ah_loop(body,params,ids,
          p111q_stmt(N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},ids,P111QCode{allocas,0,False{},""}))) ++ "}\n"

@unsafe
def p113ah_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,params,result,public,+body}:
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0),
        u => p113e_private(function,ids),
        u => p113ah_private(p113a_function(function,heap_min),ids))

@unsafe
def p113ah_private_chunks(functions: List<&2,P113DFunction>, +ids: N111Ids, +heap_min: U32, acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{function,rest}: p113ah_private_chunks(rest,ids,heap_min,Con{p113ah_function(function,ids,heap_min),acc})
