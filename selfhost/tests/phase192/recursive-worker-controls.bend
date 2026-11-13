# Append immutable phase186/stacked-frame-controls.bend first. Its original
# verifier, segment family and admitted plans remain the semantic fixture.
# This adapter uses the SAME worker construction as the x86 H experiment.
@unsafe
def p192hc_planned(plan: P114HPlan, symbol: String, ids: N111Ids) -> X181Output:
  match plan:
    case P114HPlan{+valid,+params,body,+cases}:
      nt_choose(X181Output,valid,u => x185_function_setup(symbol,x192h_formals(params),
        Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)},
        x192h_worker_body(params,body,cases),ids),u => X181Output{[],"recursive control plan refused"})

@unsafe
def p192hc_mode(+mode: U32) -> X181Output:
  p192hc_planned(p186sfc_plan(mode),"p192h_control_" ++ U32.show(mode),
    N111Ids{p111q_function_ids(p186sfc_segments(mode),0,missing()),missing()})

@unsafe
def p192hc_controls() -> List<&2,String>:
  [p186sfc_row("original-mode0-verified",String.is_empty(p186sfc_verified(0))),
   p186sfc_row("original-mode1-verified",String.is_empty(p186sfc_verified(1))),
   p186sfc_row("mode0-admitted",p114h_valid(p186sfc_plan(0))),
   p186sfc_row("mode1-admitted",p114h_valid(p186sfc_plan(1))),
   p186sfc_row("mode0-two-cases",U32.is_eq(p186sfc_count(p186sfc_plan(0)),2)),
   p186sfc_row("mode1-two-cases",U32.is_eq(p186sfc_count(p186sfc_plan(1)),2))]

def p192hc_emit() -> X181Output: x181_program_join(p192hc_mode(0),p192hc_mode(1))
