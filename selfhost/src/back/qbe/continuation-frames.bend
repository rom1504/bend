# Scoped adapter for an already admitted P114H local-continuation plan.
# Ordinary frames already use p114t_frame. Case bodies are hygienically
# renamed after verification and use p114h_buffers' separate 2048-byte stack
# allocation; that new buffer was deliberately absent from p114t_buffer.
# Keep the global buffer policy unchanged. Only the two frame-list consumers
# in p114h_stmt pass their current, factory-created case buffer here.

@unsafe
def p185fr_buffer(+buffer: String, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,8),u => False{},u =>
    nt_choose(Bool,String.eq(buffer,p112f_name(p114h_prefix(index),"scratch")),
      v => True{},v => p185fr_buffer(buffer,U32.inc(index))))

@unsafe
def p185fr_fid(+fid: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(functions,fid,index_hash(fid,2166136261),32)
      String.eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65532)

# The independent original verifier proved count+incoming==arity, incoming>0,
# symbolic FID existence, exact state identity, and capture buffer capacity.
# p114h_plan/close require clean source/case namespaces and at most eight
# cases; the paired buffer is allocated by p114h_buffers before case entry.
# Matching a generated-looking name outside that scoped caller is not enough.
@unsafe
def p185fr_expand(+stmt: N111Stmt, +current: String, +ids: N111Ids, +site: U32) -> P114TExpansion:
  match stmt:
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+fid}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") &&
          String.eq(buffer,current) && p185fr_buffer(current,0) && U32.is_eq(high,0) &&
          U32.is_le(count,8) && p185fr_fid(fid,ids) && U32.is_le(site,4294967200),
          u => P114TExpansion{p114t_frame(dest,fid,buffer,count,site),True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}

@unsafe
def p185fr_emit(+stmt: N111Stmt, +ids: N111Ids, +code: P111QCode, +expansion: P114TExpansion) -> P111QCode:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(P111QCode,changed,u => p114t_expanded(expansion,ids,code),u => p111q_stmt(stmt,ids,code))

@unsafe
def p185fr_stmt(+stmt: N111Stmt, +current: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,+next,+terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows terminal instruction",code),
          u => p185fr_emit(stmt,ids,code,p185fr_expand(stmt,current,ids,next))),u => code)

@unsafe
def p185fr_stmts(body: List<&2,N111Stmt>, +current: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p185fr_stmts(rest,current,ids,p185fr_stmt(stmt,current,ids,code))
