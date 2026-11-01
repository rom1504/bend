# Finite transport controls use the existing stream fixtures and independent
# current renderer. Real source/product equivalence is a separate gate.

@unsafe
def p149rc_plan(regions: U32, +plan: P134EmissionPlan) -> Bool:
  p134ec_chunks(p149r_collect_cursor(regions,p134e_begin(plan),[],[]),
    p134e_collect_cursor(p134e_begin(plan),[],[]))


@unsafe
def p149rc_empty_transitions(+regions: U32) -> Bool:
  +program = p134ec_program()
  +context : P134Context = P134Context{p111q_ids(program),p112f_index([]),missing(),missing(),missing(),[],0,0}
  +cursor : P134Cursor = P134Private{[],context,P134Legacy{[],context,
    P134Public{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{7,0}}]}],context,P134Main{}}}}
  p134ec_chunks(p149r_collect_cursor(regions,cursor,[],[]),p134e_collect_cursor(cursor,[],[]))


@unsafe
def p149rc_tables(+regions: U32) -> Bool:
  +cursor : P134Cursor = P134Tables{[P111QData{"empty",1,False{},[]},
    P111QData{"boundary",4,False{},p134ec_datum_rows(257,[])}]}
  p134ec_chunks(p149r_collect_cursor(regions,cursor,[],[]),p134e_collect_cursor(cursor,[],[]))


@unsafe
def p149r_controls() -> List<&2,String>:
  +program = p134ec_program()
  +static : P112StaticProgram = P112StaticProgram{program,[]}
  +direct : P113DProgram = P113DProgram{static,[p134ec_function()]}
  +arrays : P113AProgram = P113AProgram{direct,P113ACertificate{True{},True{}}}
  [p113ft_row("region-current-raw-exact",p149rc_plan(0,P134Raw{program})),
   p113ft_row("region-current-admitted-exact",p149rc_plan(0,P134Admitted{arrays})),
   p113ft_row("region-h-raw-fallback-exact",p149rc_plan(1,P134Raw{program})),
   p113ft_row("region-generic-raw-fallback-exact",p149rc_plan(2,P134Raw{program})),
   p113ft_row("region-h-complete-direct-preserved",p149rc_plan(1,P134Direct{direct})),
   p113ft_row("region-generic-complete-direct-preserved",p149rc_plan(2,P134Direct{direct})),
   p113ft_row("region-h-admitted-direct-preserved",p149rc_plan(1,P134Admitted{arrays})),
   p113ft_row("region-generic-admitted-direct-preserved",p149rc_plan(2,P134Admitted{arrays})),
   p113ft_row("region-h-empty-transitions",p149rc_empty_transitions(1)),
   p113ft_row("region-generic-empty-transitions",p149rc_empty_transitions(2)),
   p113ft_row("region-h-table-boundaries",p149rc_tables(1)),
   p113ft_row("region-generic-table-boundaries",p149rc_tables(2)),
   p113ft_row("region-h-error-preserved",p134ec_same_error(p149r_collect(1,P111Emission{[],"frozen-refusal"}))),
   p113ft_row("region-generic-error-preserved",p134ec_same_error(p149r_collect(2,P111Emission{[],"frozen-refusal"})))]
