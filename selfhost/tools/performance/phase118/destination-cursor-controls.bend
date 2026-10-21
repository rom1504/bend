# Finite source-producer controls, not malformed target execution.

def p118ct_target() -> P113PTarget:
  P113PTarget{[],kt("P118TRMC","walk",1,0,[]),True{},"$direct.walk",[]}

@unsafe
def p118ct_carries(body: List<&2,P113DStmt>, +cursor: String) -> Bool:
  match body:
    case Con{P113DAgain{Con{arg,Con{root,Con{N111Local{last},Nil{}}}}},Nil{}}: String.eq(last,cursor)
    case Con{head,rest}: p118ct_carries(rest,cursor)
    case _: False{}

@unsafe
def p118ct_scan(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DScalar{N111Call{name,N111U64{},symbol,args}},
      Con{P113DScalar{N111Load{+cursor,N111U64{},N111Local{buffer},0}},rest}}:
        String.eq(symbol,"p118_rt_extend_cursor") && U32.is_eq(nt_count(N111Arg,args),5) &&
          String.eq(buffer,"scratch") && p118ct_carries(rest,cursor)
    case Con{head,rest}: p118ct_scan(rest)
    case _: False{}

@unsafe
def p118ct_step(code: P113DCode) -> Bool:
  match code:
    case P113DCode{+body,fresh,error,calls}: String.is_empty(error) && p118t_has_extend(body) && p118ct_scan(body)

# Update only the previous terminal-producer observation to the new helper ABI;
# original admission/refusal controls continue to exercise the same source law.
@unsafe
def p118tc_finished(code: P113DCode) -> Bool:
  match code:
    case P113DCode{Con{P113DScalar{N111Call{name,typ,symbol,args}},Con{P113DResult{values},Nil{}}},fresh,error,calls}:
      String.eq(symbol,"p118_rt_finish_cursor") && U32.is_eq(nt_count(N111Arg,args),4) && U32.is_eq(nt_count(N111Value,values),1)
    case _: False{}

@unsafe
def p118ct_controls() -> List<&2,String>:
  [p113ft_row("cursor-step-loads-and-carries-slot",p118ct_step(p118t_extend(kt("NTRCons","Con",1,0,[var("",9),var("",10)]),
      [NC_Binding{9,"first",N_W32{}},NC_Binding{10,"next",N_W64{}}],p118ct_target(),20))),
   p113ft_row("cursor-finish-uses-private-abi",p118tc_finished(p118t_finish([N111Const{0,0}],0))),
   p113ft_row("cursor-no-additional-formal",U32.is_eq(nt_count(N111Value,p118t_tail_args([N111Const{5,0}])),3)),
   p113ft_row("cursor-extend-import",p118t_import("p118_rt_extend_cursor")),
   p113ft_row("cursor-finish-import",p118t_import("p118_rt_finish_cursor")),
   p113ft_row("cursor-unknown-import-refused",Bool.not(p118t_import("p118_unrelated")))]
