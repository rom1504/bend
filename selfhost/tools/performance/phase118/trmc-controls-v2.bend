# Finite compiler-analysis controls. These do not execute malformed target IR.

def p118tc_target() -> P113PTarget:
  P113PTarget{[],kt("P118TRMC","walk",1,0,[]),True{},"$direct.walk",[]}

def p118tc_call(name: String, mode: U32, args: List<&2,KTerm>) -> KTerm:
  nd_reapply(kt("Ref",name,0,mode,[]),args)

def p118tc_ctor(fields: List<&2,KTerm>) -> KTerm:
  kt("Ctr","Con",0,0,fields)

@unsafe
def p118tc_last(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Con{P113DAgain{values},Nil{}}: U32.is_eq(nt_count(N111Value,values),3)
    case Con{head,rest}: p118tc_last(rest)
    case _: False{}

@unsafe
def p118tc_step() -> Bool:
  +code = p118t_extend(kt("NTRCons","Con",1,0,[var("",9),var("",10)]),
    [NC_Binding{9,"first",N_W32{}},NC_Binding{10,"next",N_W64{}}],p118tc_target(),20)
  String.is_empty(p113d_error(code)) && p118t_has_extend(p113d_body(code)) && p118tc_last(p113d_body(code))

@unsafe
def p118tc_finished(code: P113DCode) -> Bool:
  match code:
    case P113DCode{Con{P113DScalar{N111Call{name,typ,symbol,args}},Con{P113DResult{values},Nil{}}},fresh,error,calls}:
      String.eq(symbol,"p118_rt_finish") && U32.is_eq(nt_count(N111Arg,args),4) && U32.is_eq(nt_count(N111Value,values),1)
    case _: False{}

@unsafe
def p118tc_finish() -> Bool:
  p118tc_finished(p118t_finish([N111Const{0,0}],0))

@unsafe
def p118t_controls() -> List<&2,String>:
  +good = p118tc_ctor([var("",7),p118tc_call("walk",0,[var("",8)])])
  +target = p118tc_target()
  [p113ft_row("trmc-final-self",p118t_eligible(good,target,10)),
   p113ft_row("trmc-local-refuses",Bool.not(p118t_eligible(good,p113pl_local(target,["x"],atom("Absent")),10))),
   p113ft_row("trmc-other-callee-refuses",Bool.not(p118t_eligible(p118tc_ctor([var("",7),p118tc_call("other",0,[var("",8)])]),target,10))),
   p113ft_row("trmc-bang-refuses",Bool.not(p118t_eligible(p118tc_ctor([var("",7),p118tc_call("walk",3,[var("",8)])]),target,10))),
   p113ft_row("trmc-arity-refuses",Bool.not(p118t_eligible(p118tc_ctor([var("",7),p118tc_call("walk",0,[])]),target,10))),
   p113ft_row("trmc-prefix-recursion-refuses",Bool.not(p118t_eligible(p118tc_ctor([p118tc_call("walk",0,[var("",7)]),p118tc_call("walk",0,[var("",8)])]),target,10))),
   p113ft_row("trmc-nested-argument-refuses",Bool.not(p118t_eligible(p118tc_ctor([var("",7),p118tc_call("walk",0,[p118tc_call("walk",0,[var("",8)])])]),target,10))),
   p113ft_row("trmc-nonfinal-refuses",Bool.not(p118t_eligible(p118tc_ctor([p118tc_call("walk",0,[var("",8)]),var("",7)]),target,10))),
   p113ft_row("trmc-single-field-refuses",Bool.not(p118t_eligible(p118tc_ctor([p118tc_call("walk",0,[var("",8)])]),target,10))),
   p113ft_row("trmc-freshness-refuses",Bool.not(p118t_eligible(good,target,4294967200))),
   p113ft_row("trmc-structured-step",p118tc_step()),
   p113ft_row("trmc-terminal-completes",p118tc_finish()),
   p113ft_row("trmc-empty-terminal-refuses",Bool.not(String.is_empty(p113d_error(p118t_finish([],0))))),
   p113ft_row("trmc-no-raw-pointer-formals",U32.is_eq(nt_count(N111Value,p118t_tail_args([N111Const{4,0}])),3))]
