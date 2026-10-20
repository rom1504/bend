# Optional table-only rendering overlay. The qualified transport template owns
# every stack offset and reserves its sites in the shared QBE counter.
@unsafe
def p114hs_stack(symbol: String, dest: String, count: U32, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114t_stmt(N111Call{dest,N111U64{},symbol,[p111_state(),N111Arg{N111U32{},N111Const{count,0}}]},ids,code)

@unsafe
def p114hs_restore(captures: List<&2,String>, +index: U32, +prefix: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match captures:
    case Nil{}: code
    case Con{name,rest}: p114hs_restore(rest,U32.inc(index),prefix,ids,
      p114hs_stack("p111_rt_stack_get",p112f_name(prefix,name),index,ids,code))

@unsafe
def p114hs_case(+captures: List<&2,String>, result: String, pop: String, +index: U32, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +count = nt_count(String,captures)
  p111q_line(p111q_local(p112f_name(p114h_prefix(index),result)) ++ " =l copy %p114r_value\n",
    p114hs_restore(captures,0,p114h_prefix(index),ids,p111q_line(p114h_pop_text(pop,p114h_prefix(index)),
      nt_choose(P111QCode,U32.is_eq(count,0),u => code,
        u => p114hs_stack("p111_rt_stack_pop","p114h_popped",count,ids,code)))))

@unsafe
def p114h_cases(cases: List<&2,P114HCase>, +index: U32, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match cases code:
    case Nil{} _: code
    case Con{P114HCase{name,captures,result,pop,body},rest} P111QCode{chunks,n,terminal,error}:
      p114h_cases(rest,U32.inc(index),params,ids,p114h_terminal(p114h_stmts(p114h_rename(body,p114h_prefix(index)),params,
        p112f_name(p114h_prefix(index),"scratch"),ids,p114hs_case(captures,result,pop,index,ids,
          P111QCode{Con{"@p114h_case_" ++ U32.show(index) ++ "\n",chunks},n,False{},error}))))

@unsafe
def p114hs_dispatch(+cases: List<&2,P114HCase>, params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114h_cases(cases,0,params,ids,P111QCode{Con{
        "%p114h_fid =l copy " ++ p111q_local("p114h_fid") ++ "\n" ++ p114h_dispatch(cases,0,ids,""),chunks},n,True{},error})

@unsafe
def p114h_unwind(+cases: List<&2,P114HCase>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114hs_dispatch(cases,params,ids,p114hs_stack("p111_rt_stack_get","p114h_fid",0,ids,
        p114hs_stack("p111_rt_stack_pop","p114h_popped",1,ids,P111QCode{Con{
          "@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114h_dispatch, @p114h_done\n@p114h_done\nret %p114r_value\n@p114h_dispatch\n%p114r_depth =l sub %p114r_depth, 1\n",chunks},n,False{},error})))
