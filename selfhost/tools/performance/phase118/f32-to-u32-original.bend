# Captured current divmod hook; only the declaration name changes.
@unsafe
def p118f_original_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt code:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+op,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}}
      P111QCode{chunks,+next,terminal,error}:
        nt_choose(P111QCode,String.eq(symbol,"p111_rt_op") && String.eq(state,"state") &&
          (U32.is_eq(op,18) || U32.is_eq(op,19)) && p114t_buffer(buffer),
          u => p118u_divmod(dest,buffer,op,next,code),
          u => p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code))
    case _ P111QCode{chunks,next,terminal,error}:
      p114t_expanded(p114t_expand(p118q_sized(stmt),ids,next),ids,code)
