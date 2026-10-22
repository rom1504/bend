# Exact post-verification expansion of one runtime helper case. The original
# structured call remains present for signature/arity/buffer verification.
@unsafe
def p126nt_expand(+stmt: N111Stmt, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{4,0}},
      Con{N111Arg{N111U64{},+term},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_take") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")) && U32.is_le(site,4294967292),
          u => P114TExpansion{[
            N111Bin{p114t_name(site,"nat_pred"),N111U64{},"sub",term,N111Const{1,0}},
            N111Store{N111U64{},N111Local{buffer},0,p114t_local(site,"nat_pred")},
            N111Set{dest,N111U64{},N111Const{1,0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p126nt_previous_stmt(stmt: N111Stmt, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114t_stmt(stmt,ids,code)

@unsafe
def p126nt_emit(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(P111QCode,changed,u => p114t_expanded(P114TExpansion{body,changed},ids,code),u => p126nt_previous_stmt(stmt,ids,code))

@unsafe
def p111q_stmt(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,next,terminal,error}:
      nt_choose(P111QCode,Bool.not(terminal) && String.is_empty(error),
        u => p126nt_emit(stmt,ids,code,p126nt_expand(stmt,next)),u => p126nt_previous_stmt(stmt,ids,code))
