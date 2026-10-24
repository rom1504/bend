@unsafe
def p137qi_take(symbol: String, count: N111Value) -> N111Stmt:
  N111Call{"ignored",N111U64{},symbol,[p111_state(),p111_word(N111Local{"owner"}),p111_scratch(),N111Arg{N111U32{},count}]}

@unsafe
def p137qi_done(stmt: N111Stmt) -> List<&2,P113DStmt>:
  [P113DScalar{stmt},P113DResult{[N111Const{1,0}]}]

@unsafe
def p137qi_controls() -> List<&2,String>:
  +wide = p137qi_take("p111_rt_take",N111Const{9,0})
  +small = p137qi_take("p111_rt_take",N111Const{8,0})
  +result : List<&2,P113DStmt> = [P113DResult{[N111Const{1,0}]}]
  [p113ft_row("retain-8-unchanged",p137qi_scalar(small)),
   p113ft_row("retain-9-deferred",Bool.not(p137qi_scalar(wide))),
   p113ft_row("retain-16-deferred",Bool.not(p137qi_scalar(p137qi_take("p111_rt_take",N111Const{16,0})))),
   p113ft_row("retain-17-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Const{17,0}))),
   p113ft_row("retain-highword-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Const{9,1}))),
   p113ft_row("retain-dynamic-unchanged",p137qi_scalar(p137qi_take("p111_rt_take",N111Local{"count"}))),
   p113ft_row("retain-other-import-unchanged",p137qi_scalar(p137qi_take("p111_rt_ctor",N111Const{9,0}))),
   p113ft_row("retain-nested-scalar",Bool.not(p137qi_scalar(N111If{N111Const{1,0},[wide],[]}))),
   p113ft_row("retain-straight-return",Bool.not(p137qi_returns(p137qi_done(wide),1))),
   p113ft_row("retain-small-return",p137qi_returns(p137qi_done(small),1)),
   p113ft_row("retain-nested-direct",Bool.not(p137qi_returns([P113DIf{N111Const{1,0},p137qi_done(wide),result}],1))),
   p113ft_row("retain-shared-suffix",Bool.not(p137qi_returns([P113DIf{N111Const{1,0},[P113DScalar{wide}],[]},P113DResult{[N111Const{1,0}]}],1))),
   p113ft_row("retain-original-return-shape-unchanged",p113j_returns(p137qi_done(wide),1)),
   p113ft_row("retain-original-loop-refused",Bool.not(p137qi_returns([P113DAgain{[N111Const{1,0}]}],1))),
   p113ft_row("retain-wrong-result-count-refused",Bool.not(p137qi_returns(result,2)))]
