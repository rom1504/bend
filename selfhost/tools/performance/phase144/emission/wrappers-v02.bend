@unsafe
def p111q_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
      p144e_body_tail(p111q_stmts(body,ids,P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n")


# Phase111 module: selfhost/tools/performance/phase111/qbe/program.bend
# Assemble separately emitted functions and ABI data. IDs use a Patricia index
# built once; emitting a reference never scans all previously emitted segments.

@unsafe
def p112q_planned(+segment: N111Segment, +ids: N111Ids, plan: P112TailPlan) -> String:
  match segment plan:
    case N111Segment{+name,arity,result,incoming,flags,+original} P112TailPlan{valid,loops,+params,+prefix,+body}:
      nt_choose(String,valid,
        u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
          p144e_body_tail(p112q_loop_body(body,params,ids,
            p111q_stmts(prefix,ids,P111QCode{p111q_allocas(original,[]),0,False{},""})),"}\n"),
        u => p111q_segment(segment,ids))

@unsafe
def p112w_private(+segment: N111Segment, +ids: N111Ids, plan: P112WorkerPlan) -> String:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,+original} P112WorkerPlan{+valid,calls,+params,+body}:
      nt_choose(String,valid,u => "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p112w_stmts(body,params,False{},ids,
          P111QCode{Con{"@p112_again\n",Con{"jmp @p112_again\n",p111q_allocas(original,[])}},0,False{},""}),"}\n"),
        u => "INVALID_P112_PRIVATE_PLAN\n")

@unsafe
def p112w_public_segment(+segment: N111Segment, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,p112t_admitted(p112t_plan(segment)),u => p112q_segment(segment,ids),u =>
        nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
          u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
            p144e_body_tail(p112w_stmts(p112w_public(body,name,ready),[],True{},ids,
              P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n"),
          u => p111q_segment(segment,ids)))

@unsafe
def p113e_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113e_stmts(body,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""}),"}\n")

@unsafe
def p113ah_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113ah_loop(body,params,ids,
          p111q_stmt(N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},ids,P111QCode{allocas,0,False{},""})),"}\n")

@unsafe
def p114r_private(+name: String, +ids: N111Ids, plan: P114RPlan) -> String:
  match plan:
    case P114RPlan{valid,+params,body,continuation,head,result,unwind}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
      p144e_body_tail(p114r_unwind(head,result,unwind,ids,p114r_stmts(body,params,ids,
        P111QCode{["%v_scratch =l alloc8 2048\n%v_p114r_resume_local_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""})),"}\n")

@unsafe
def p114g_resume(+name: String, +captures: List<&2,String>, +result: String, pop: String, body: List<&2,P112WorkerStmt>, +ids: N111Ids) -> String:
  "function l $" ++ p114g_resume_symbol(name) ++ "(" ++ p114g_formals(nt_count(String,captures),0,"l %state") ++ ") {\n@entry\n" ++
    p144e_body_tail(p114g_stmts(body,ids,
      p111q_line(p111q_local(result) ++ " =l copy %p114g_input\n",
        p114g_restore(captures,0,p114g_pop(pop,P111QCode{["%v_scratch =l alloc8 2048\n"],0,False{},""})))),"}\n")

@unsafe
def p114g_private(+name: String, +ids: N111Ids, plan: P114GPlan) -> String:
  match plan:
    case P114GPlan{valid,+params,body,continuation,+captures,result,pop,resume}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p114g_unwind(name,nt_count(String,captures),p114r_stmts(body,params,ids,
          P111QCode{["%v_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""})),"}\n") ++
        p114g_resume(name,captures,result,pop,resume,ids)

@unsafe
def p114h_private(+name: String, +ids: N111Ids, plan: P114HPlan) -> String:
  match plan:
    case P114HPlan{valid,+params,body,+cases}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p114h_unwind(cases,params,ids,p114h_terminal(p114h_stmts(body,params,"scratch",ids,
          P111QCode{["%v_scratch =l alloc8 2048\n" ++ p114h_buffers(nt_count(P114HCase,cases),0,"") ++
            "%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""}))),"}\n")

@unsafe
def p117h_private(function: P113DFunction, +ids: N111Ids, prelude: List<&2,N111Stmt>) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113ah_loop(body,params,ids,p111q_stmts(
          Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude},ids,P111QCode{allocas,0,False{},""})),"}\n")

@unsafe
def p117v_fallback_ready(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      "function l $p117v_" ++ nt_fid(name) ++ "(" ++ p117v_signature(params,result) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113ah_loop(body,params,ids,p111q_stmt(
          N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},ids,P111QCode{p117v_allocas(body),0,False{},""})),"}\n")

@unsafe
def p117v_private(function: P113DFunction, +ids: N111Ids, +prelude: List<&2,N111Stmt>, +used: U32) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +dispatch = "jnz %v_p113a_version_guard, @p117_fast, @p117_fallback\n@p117_fallback\n%p117_fallback_value =l call $p117v_" ++ nt_fid(name) ++ "(" ++ p117v_signature(params,result) ++ ")\nret %p117_fallback_value\n@p117_fast\n"
      +setup = nt_append(N111Stmt,Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude},
        Con{N111Set{"p113a_version_guard",N111U32{},N111Const{1,0}},p117v_guard(params,1,used)})
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p117v_signature(params,result) ++ ") {\n@entry\n" ++
        p144e_body_tail(p113ah_loop(body,params,ids,p111q_line(dispatch,p111q_stmts(setup,ids,P111QCode{p117v_allocas(body),0,False{},""}))),"}\n")

@unsafe
def p114so_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p144e_body_tail(p114so_stmts(body,buffers,params,ids,P111QCode{Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}},0,False{},""}),"}\n")

@unsafe
def p126l_private(function: P113DFunction, +ids: N111Ids) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +buffers = p114so_buffers(body)
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++
        p144e_body_tail(p126l_stmts(body,P126LCtx{params,buffers,ids},[],
          P111QCode{Con{"",Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""}),"}\n")

@unsafe
def p126i_private(function: P113DFunction, +tables: List<&2,P126ITable>, +ids: N111Ids, +buffers: List<&2,String>) -> String:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      +base = nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,base) ++ ") {\n@entry\n" ++
        p144e_body_tail(p126i_stmts(body,P126ICtx{params,buffers,ids,tables},[],
          P111QCode{Con{"",Con{"@p113_loop\n",Con{"jmp @p113_loop\n",allocas}}},0,False{},""}),"}\n")

# Expensive recognition is staged: array refusal, one buffer audit, then only
# bufferless functions need the compact table-call presence walk.

