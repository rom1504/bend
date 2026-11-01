# Experiment only. Canonical scalar emission and the runtime ABI are unchanged.
# Keep the original reversed-fragment order; flatten only at the body boundary.
@unsafe
def p147q_call_args(args: List<&2,N111Arg>, +ids: N111Ids, +first: Bool, chunks: List<&2,String>) -> List<&2,String>:
  match args:
    case Nil{}: chunks
    case Con{N111Arg{typ,value},rest}:
      p147q_call_args(rest,ids,False{},Con{p111q_type(typ) ++ " " ++ p111q_value(value,ids),
        Con{nt_choose(String,first,u => "",u => ", "),chunks}})

@unsafe
def p147q_call(+name: String, +typ: N111Type, +symbol: String, args: List<&2,N111Arg>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{")\n",p147q_call_args(args,ids,True{},
        Con{p111q_local(name) ++ " =" ++ p111q_type(typ) ++ " call $" ++ symbol ++ "(",chunks})},n,terminal,error}

@unsafe
def p147q_stmt(+stmt: N111Stmt, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match stmt:
    case N111Call{name,typ,symbol,args}: p147q_call(name,typ,symbol,args,ids,code)
    case _: p112a_original_stmt(stmt,ids,code)

# Same original scalar-rendering policy in both arms. Nested branches retain the
# canonical renderer in both arms; the retained benchmark segments are straight-line.
@unsafe
def p147q_stmts(body: List<&2,N111Stmt>, +ids: N111Ids, +candidate: Bool, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p147q_head(stmt,rest,ids,candidate,code)

@unsafe
def p147q_head(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +ids: N111Ids, +candidate: Bool, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows terminal instruction",code),u =>
          p147q_stmts(rest,ids,candidate,nt_choose(P111QCode,candidate,
            v => p147q_stmt(stmt,ids,code),v => p112a_original_stmt(stmt,ids,code)))),u => code)

@unsafe
def p147q_render_segment(segment: N111Segment, +ids: N111Ids, +candidate: Bool) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
      p144e_body_tail(p147q_stmts(body,ids,candidate,P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n")
