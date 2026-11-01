# Additive experiment: original (0), call-only (1), simple-line fragments (2).
# Reversed P111QCode chunks are flattened only by the existing body boundary.
@unsafe
def p147f_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value, +store: Bool, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +at = nt_choose(String,U32.is_eq(offset,0),u => p111q_value(base,ids),u => p111q_tmp(n))
      +prefix = nt_choose(List<&2,String>,U32.is_eq(offset,0),u => chunks,u =>
        Con{"\n",Con{U32.show(offset),Con{", ",Con{p111q_value(base,ids),Con{" =l add ",Con{at,chunks}}}}}})
      +parts = nt_choose(List<&2,String>,store,
        u => Con{"\n",Con{at,Con{", ",Con{p111q_value(value,ids),Con{" ",Con{p111q_type(typ),Con{"store",prefix}}}}}}},
        u => Con{"\n",Con{at,Con{nt_choose(String,String.eq(p111q_type(typ),"w"),
          v => " =l loaduw ",v => " =" ++ p111q_type(typ) ++ " load" ++ p111q_type(typ) ++ " "),Con{p111q_local(name),prefix}}}})
      P111QCode{parts,nt_choose(U32,U32.is_eq(offset,0),u => n,u => U32.inc(n)),terminal,error}

@unsafe
def p147f_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Set{name,typ,value} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(value,ids),Con{" copy ",Con{p111q_type(typ),Con{" =",Con{p111q_local(name),chunks}}}}}},n,terminal,error}
    case N111Bin{name,+typ,+op,left,right} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(right,ids),Con{", ",Con{p111q_value(left,ids),Con{" ",Con{p111q_binop(op,typ),Con{" ",Con{
        nt_choose(String,p111q_comparison(op),u => "w",u => p111q_type(typ)),Con{" =",Con{p111q_local(name),chunks}}}}}}}}}},n,terminal,error}
    case N111Call{name,typ,symbol,args} _: p147q_call(name,typ,symbol,args,ids,code)
    case N111Load{name,typ,base,offset} _: p147f_memory(name,typ,base,offset,N111Const{0,0},False{},ids,code)
    case N111Store{typ,base,offset,value} _: p147f_memory("",typ,base,offset,value,True{},ids,code)
    case N111Offset{name,base,bytes} P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"\n",Con{p111q_value(bytes,ids),Con{", ",Con{p111q_value(base,ids),Con{" =l add ",Con{p111q_local(name),chunks}}}}}},n,terminal,error}
    case _ _: p112a_original_stmt(stmt,ids,code)

@unsafe
def p147f_selected(+stmt: N111Stmt, +ids: N111Ids, mode: U32, +code: P111QCode) -> P111QCode:
  match mode:
    case 0: p112a_original_stmt(stmt,ids,code)
    case 1: p147q_stmt(stmt,ids,code)
    case _: p147f_stmt(stmt,ids,code)

@unsafe
def p147f_stmts(body: List<&2,N111Stmt>, +ids: N111Ids, +mode: U32, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p147f_head(stmt,rest,ids,mode,code)

@unsafe
def p147f_head(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +ids: N111Ids, +mode: U32, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows terminal instruction",code),u =>
          p147f_stmts(rest,ids,mode,p147f_selected(stmt,ids,mode,code))),u => code)

# Whole captured function. Nested branches deliberately retain identical current
# canonical dispatch in every mode; this experiment changes simple top-level lines.
@unsafe
def p147f_render_segment(segment: N111Segment, +ids: N111Ids, +mode: U32) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
      p144e_body_tail(p147f_stmts(body,ids,mode,P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n")
