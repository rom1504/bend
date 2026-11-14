def p195ph_row(name: String, pass: Bool) -> String:
  "pool-physical-" ++ name ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")
def p195ph_slot(+name: String, kind: String, home: U32) -> KDef:
  p111v_get(p111v_put(missing(),name,kind,home,8),name)
def p195ph_frame() -> X181Frame:
  X181Frame{p111v_put(p111v_put(p111v_put(missing(),"state","X181Stack",64,8),
    "cx","X185Transient",5,8),"saved","X181Register",0,8),64,64,["state"],"p195ph"}
def p195ph_narrow(value: Maybe<&2,X187Operand>) -> Bool:
  match value:
    case Some{operand}: x188_operand_same(operand,x188_reg(1,32))
    case None{}: False{}
def p195ph_snapshot(plan: X186CallPlan) -> Bool:
  match plan:
    case X186CallPlan{kind,count}: U32.is_eq(kind,2) && U32.is_eq(count,1)
def p195ph_controls() -> List<&2,String>:
  [p195ph_row("rcx-load",x188_operand_same(x185_transient_reg(5),x188_reg(1,64))),
   p195ph_row("rcx-physical",x185_physical_same(x185_physical_transient(5),x188_reg(1,64))),
   p195ph_row("r12-physical",x185_physical_same(x185_physical_callee(0),x188_reg(12,64))),
   p195ph_row("call-snapshot",p195ph_snapshot(x186_call_plan([N111Arg{N111U64{},N111Local{"cx"}}],p195ph_frame()))),
   p195ph_row("call-bound",U32.is_eq(x186_call_slot(p195ph_slot("bad","X185Transient",6),64),0)),
   p195ph_row("float-narrow",p195ph_narrow(x186_float_home("cx",p195ph_frame(),False{}))),
   p195ph_row("r12-parallel-destination",x186_p_word_home(p195ph_slot("saved","X181Register",0),True{})),
   p195ph_row("rcx-parallel-destination",x186_p_word_home(p195ph_slot("cx","X185Transient",5),True{})),
   p195ph_row("parallel-bound",Bool.not(x186_p_word_home(p195ph_slot("bad","X185Transient",6),True{}))),
   p195ph_row("state-stack-protected",Bool.not(x186_p_word_home(p195ph_slot("state","X181Stack",64),True{}))),
   p195ph_row("state-register-protected",Bool.not(x186_p_word_home(p195ph_slot("state","X181Register",0),True{}))),
   p195ph_row("state-readable",x186_p_word_home(p195ph_slot("state","X181Stack",64),False{})),
   p195ph_row("callee-preservation",U32.is_eq(x186_saves_mask(x186_saves_frame(p195ph_frame())),1))]
