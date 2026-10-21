# Finite reflected metadata controls; no malformed native input is executed.
@unsafe
def p120nr_ctor_control_report() -> String:
  +empty = missing()
  +ids: N111Ids = N111Ids{empty,p111v_put(empty,"Plain","ctor",0,0)}
  nt_choose(String,
    p120nr_operand(N111CtorId{"Plain"},[]) &&
    p111v_value(N111CtorId{"Plain"},1,empty,ids) &&
    p111v_value(N111CtorId{"Plain"},2,empty,ids) &&
    Bool.not(p111v_value(N111CtorId{"Plain"},3,empty,ids)) &&
    Bool.not(p111v_value(N111CtorId{"Unknown"},2,empty,ids)) &&
    Bool.not(p120nr_operand(N111Symbol{"Plain"},[])) &&
    Bool.not(p120nr_operand(N111FuncId{"Plain"},[])) &&
    String.eq(p111q_value(N111CtorId{"Plain"},ids),"0"),
    u => "PASS ctor-id-integer-known-only\n",u => "FAIL ctor-id-integer-known-only\n")
