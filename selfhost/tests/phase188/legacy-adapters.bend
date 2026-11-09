# Test-only text observation boundary for the unchanged Phase186 adversarial
# machine fixtures. Production selection remains typed; these wrappers render
# selected instructions only where a frozen fixture asserts textual order.
type P188TextOutput is Data:
  P188TextOutput{+chunks: List<&2,String>, +error: String}

def p188_test_reg(name: String) -> X187Operand:
  match name:
    case "%r10": x188_reg(10,64)
    case "%r11": x188_reg(11,64)
    case _: X187Reg{99,64,False{}}

@unsafe
def p188_test_load(value: N111Value, ids: N111Ids, frame: X181Frame, reg: String) -> String:
  x188_render(x181_load(value,ids,frame,p188_test_reg(reg)))
@unsafe
def p188_test_store(name: String, frame: X181Frame, reg: String) -> String:
  x188_render(x181_store(name,frame,p188_test_reg(reg)))
@unsafe
def p188_test_prologue(frame: X181Frame) -> String: x188_render(x181_prologue(frame))
@unsafe
def p188_test_epilogue(frame: X181Frame) -> String: x188_render(x181_epilogue(frame))
@unsafe
def p188_test_call_selected(enabled: Bool, args: List<&2,N111Arg>, ids: N111Ids,
    frame: X181Frame, plan: X186CallPlan) -> String:
  x188_render(x186_call_selected(enabled,args,ids,frame,plan))
@unsafe
def p188_test_call_arguments(args: List<&2,N111Arg>, ids: N111Ids, frame: X181Frame) -> String:
  x188_render(x186_call_arguments(args,ids,frame))
@unsafe
def p188_test_u32_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> String:
  x188_render(x186_u32_float_probe(stmt,ids,frame))
@unsafe
def p188_test_u32_float_probe_when(enabled: Bool, stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> String:
  x188_render(x186_u32_float_probe_when(enabled,stmt,ids,frame))

def p188_test_home_text(home: Maybe<&2,X187Operand>) -> String:
  match home:
    case Some{reg}: x188_operand_text(reg)
    case None{}: ""
@unsafe
def p188_test_x_home(name: String, homes: KDef) -> String:
  p188_test_home_text(x186_x_home(name,homes))
