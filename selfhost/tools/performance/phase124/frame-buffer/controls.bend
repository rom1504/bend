# Pure scoped-expansion controls; no fabricated IR is executed or emitted.
@unsafe
def p124fc_frame(buffer: String, count: U32, high: U32, fid: String) -> N111Stmt:
  N111Call{"ignored",N111U64{},"p111_rt_frame",[p111_state(),
    N111Arg{N111U32{},N111FuncId{fid}},N111Arg{N111Ptr{},N111Local{buffer}},
    N111Arg{N111U32{},N111Const{count,high}}]}

def p124fc_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p124fc_try(buffer: String, count: U32, high: U32, fid: String, expected: String) -> Bool:
  p124fc_changed(p124f_expand(p124fc_frame(buffer,count,high,fid),expected,
    N111Ids{p111v_put(missing(),"resume","N111Id",0,0),missing()},0))

@unsafe
def p124fc_controls() -> List<&2,String>:
  [p113ft_row("case0",p124fc_try("p114h_case_0_local_scratch",1,0,"resume","p114h_case_0_local_scratch")),
   p113ft_row("case7-boundary",p124fc_try("p114h_case_7_local_scratch",8,0,"resume","p114h_case_7_local_scratch")),
   p113ft_row("zero-captures",p124fc_try("p114h_case_0_local_scratch",0,0,"resume","p114h_case_0_local_scratch")),
   p113ft_row("wrong-current-buffer",Bool.not(p124fc_try("p114h_case_0_local_scratch",1,0,"resume","p114h_case_1_local_scratch"))),
   p113ft_row("index8-refused",Bool.not(p124fc_try("p114h_case_8_local_scratch",1,0,"resume","p114h_case_8_local_scratch"))),
   p113ft_row("name-suffix-refused",Bool.not(p124fc_try("p114h_case_0_local_scratch_other",1,0,"resume","p114h_case_0_local_scratch_other"))),
   p113ft_row("unknown-fid",Bool.not(p124fc_try("p114h_case_0_local_scratch",1,0,"missing","p114h_case_0_local_scratch"))),
   p113ft_row("count9-refused",Bool.not(p124fc_try("p114h_case_0_local_scratch",9,0,"resume","p114h_case_0_local_scratch"))),
   p113ft_row("highword-refused",Bool.not(p124fc_try("p114h_case_0_local_scratch",1,1,"resume","p114h_case_0_local_scratch"))),
   p113ft_row("ordinary-buffer-delegated",Bool.not(p124fc_try("scratch",1,0,"resume","scratch"))),
   p113ft_row("global-recognizer-unchanged",Bool.not(p114t_buffer("p114h_case_0_local_scratch"))),
   p113ft_row("h-plan-original-prefix-reserved",Bool.not(p114h_clean_name("p114h_case_0_local_scratch")))]
