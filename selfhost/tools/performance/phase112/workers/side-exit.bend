# A side exit cannot reach Again: its complete suffix must end in the exact
# failure transition and corresponding machine return. Keep this as an additive
# override of scan so the first loop snapshot remains independently replayable.
@unsafe
def p112t_failure_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{code,0}},Nil{}}}:
      String.eq(state,"state") && U32.is_gt(code,0) && U32.is_le(code,8)
    case _: False{}

@unsafe
def p112t_failure_frame(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111FuncId{target}},Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}:
      String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(scratch,"scratch") && U32.is_le(count,255)
    case _: False{}

@unsafe
def p112t_failure(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}:
      String.eq(symbol,"p111_rt_fail") && String.eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112t_failure(rest)
    case _: False{}

# Failure recognition runs once at block entry. Ordinary scalar tails use this
# path directly, avoiding repeated full-suffix failure scans.
@unsafe
def p112t_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P112TailBody:
  nt_choose(P112TailBody,p112t_tail(body,owner,arity,0),
    u => P112TailBody{True{},1,p112t_tail_nodes(body,arity)},
    u => nt_choose(P112TailBody,p112t_transition(body),
      v => P112TailBody{True{},0,p112t_scalars(body)},v => p112t_scan_next(body,owner,arity)))
