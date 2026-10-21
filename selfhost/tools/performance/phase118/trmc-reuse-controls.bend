# Finite projection controls, appended only to the research API.

@unsafe
def p118rc_take(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DScalar{N111Call{name,N111U64{},symbol,args}},Con{P113DScalar{N111Set{dest,N111U64{},N111Const{count,0}}},Nil{}}}:
      String.eq(name,"p118_credit") && String.eq(symbol,"p118_rt_reuse_take") &&
        U32.is_eq(nt_count(N111Arg,args),5) && String.eq(dest,"old_count") && U32.is_eq(count,2)
    case _: False{}

@unsafe
def p118rc_extend(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DScalar{N111Call{name,N111U64{},symbol,args}},Con{P113DScalar{N111Load{dest,N111U64{},N111Local{out},0}},Nil{}}}:
      String.eq(name,"node") && String.eq(symbol,"p118_rt_reuse_extend") &&
        U32.is_eq(nt_count(N111Arg,args),7) && String.eq(dest,"p118_credit") && String.eq(out,"p118_credit_out")
    case _: False{}

@unsafe
def p118rc_finish(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DScalar{N111Call{name,N111U64{},symbol,args}},Nil{}}:
      String.eq(name,"result") && String.eq(symbol,"p118_rt_reuse_finish") && U32.is_eq(nt_count(N111Arg,args),5)
    case _: False{}

@unsafe
def p118rc_again(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DAgain{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),4)
    case _: False{}

@unsafe
def p118r_controls() -> List<&2,String>:
  +take = N111Call{"old_count",N111U64{},"p111_rt_take",[p111_state(),p111_word(N111Local{"term"}),p111_scratch(),p111_u32(2)]}
  +extend = N111Call{"node",N111U64{},"p118_rt_extend",[p111_state(),p111_word(N111Local{"p118_parent"}),
    N111Arg{N111U32{},N111CtorId{"Con"}},p111_scratch(),p111_u32(1)]}
  +finish = N111Call{"result",N111U64{},"p118_rt_finish",[p111_state(),p111_word(N111Local{"p118_root"}),
    p111_word(N111Local{"p118_parent"}),p111_word(N111Local{"value"})]}
  [p113ft_row("reuse-take-preserves-old-count",p118rc_take(p118r_scalar(take))),
   p113ft_row("reuse-extend-updates-private-credit",p118rc_extend(p118r_scalar(extend))),
   p113ft_row("reuse-finish-consumes-private-credit",p118rc_finish(p118r_scalar(finish))),
   p113ft_row("reuse-backedge-has-credit",p118rc_again(p118r_body([P113DAgain{[N111Const{0,0},N111Const{0,0},N111Const{0,0}]}]))),
   p113ft_row("reuse-nested-finish-refuses",Bool.not(p118r_shape([P113DScalar{N111If{N111Const{1,0},[finish],[]}}]))),
   p113ft_row("reuse-nested-old-take-remains-safe",p118r_shape([P113DScalar{N111If{N111Const{1,0},[take],[]}}])),
   p113ft_row("reuse-output-alias-refuses",Bool.not(p118r_separate(N111Local{"same"},N111Local{"same"}))),
   p113ft_row("reuse-distinct-local-buffers",p118r_separate(N111Local{"scratch"},N111Local{"p118_credit_out"}))]
