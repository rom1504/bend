# Data-only metadata controls. Use the real constructor catalogue producer.
# The first control used kind "ctor" instead of "N111Id" and its render check
# failed; that fixture and its failed receipt remain preserved.
@unsafe
def p120nr_ctor_line(+name: String, good: Bool) -> String:
  match good:
    case True{}: "PASS " ++ name ++ "\n"
    case False{}: "FAIL " ++ name ++ "\n"

@unsafe
def p120nr_ctor_control_report() -> String:
  +empty = missing()
  +ids: N111Ids = N111Ids{empty,p111q_constructor_ids([N_Constructor{"Plain",0,False{}}],0,empty)}
  p120nr_ctor_line("ctor-id-region-operand",p120nr_operand(N111CtorId{"Plain"},[])) ++
  p120nr_ctor_line("ctor-id-known-u32",p111v_value(N111CtorId{"Plain"},1,empty,ids)) ++
  p120nr_ctor_line("ctor-id-known-u64",p111v_value(N111CtorId{"Plain"},2,empty,ids)) ++
  p120nr_ctor_line("ctor-id-pointer-refused",Bool.not(p111v_value(N111CtorId{"Plain"},3,empty,ids))) ++
  p120nr_ctor_line("ctor-id-unknown-refused",Bool.not(p111v_value(N111CtorId{"Unknown"},2,empty,ids))) ++
  p120nr_ctor_line("ctor-id-symbol-refused",Bool.not(p120nr_operand(N111Symbol{"Plain"},[]))) ++
  p120nr_ctor_line("ctor-id-function-id-refused",Bool.not(p120nr_operand(N111FuncId{"Plain"},[]))) ++
  p120nr_ctor_line("ctor-id-render-exact",String.eq(p111q_value(N111CtorId{"Plain"},ids),"0")) ++
  p120nr_ctor_line("ctor-id-render-rejects-wrong-kind",String.eq(p111q_id(p111v_put(empty,"Plain","ctor",0,0),"Plain"),"INVALID_N111_ID"))
