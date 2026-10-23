# Structural probes of the actual unchanged observer gates. Ordinary checked
# fixture emission/execution must establish positive admission and semantics.

@unsafe
def p131rg_control_context() -> NO_Context:
  NO_Context{[],"reader",NO_Schema{[var("String",10)],[0],var("Bool",11),11,"Bool",[],12,""},[]}

@unsafe
def p131rg_control_opaque() -> KTerm:
  noa_atom(p131rg_opaque(),kt("OField","Record",1,0,[kt("OArg","",0,0,[]),ref("Record")]),var("",13))

@unsafe
def p131rg_control_match() -> Bool:
  +fn = kt("OM","",0,0,[kt("Mat","SCon",3,0,[]),atom("Env"),atom("Stack")])
  +spec : Maybe<&2,NO_Spec> = Some{NO_Spec{NO_Layout{"SCon","SCon","Boxed",2},"String",["Char","String"]}}
  Bool.not(String.is_empty(noa_error(noa_match_spec(p131rg_control_context(),fn,p131rg_control_opaque(),[],0,32,NO_KFinish{},spec))))

@unsafe
def p131rg_controls() -> List<&2,String>:
  +opaque = p131rg_control_opaque()
  +ctx = p131rg_control_context()
  +reserved : KDef = KDef{p131rg_opaque(),"ADT",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
  [p128bs_control_row("region-width-zero",p131rg_width(0)),
   p128bs_control_row("region-width-two",p131rg_width(2)),
   p128bs_control_row("region-width-eight",p131rg_width(8)),
   p128bs_control_row("region-packed-single-refused",Bool.not(p131rg_width(1))),
   p128bs_control_row("region-wide-refused",Bool.not(p131rg_width(9))),
   p128bs_control_row("region-empty-symbol-available",p131rg_symbol_available([])),
   p128bs_control_row("region-symbol-collision-refused",Bool.not(p131rg_symbol_available([reserved]))),
   p128bs_control_row("region-opaque-not-scalar",String.eq(tg(noa_scalar(ctx,opaque)),"Absent")),
   p128bs_control_row("region-opaque-not-readable",p131rg_control_match()),
   p128bs_control_row("region-opaque-not-string-helper",Bool.not(p128br_arguments(ctx,[var("String",20)],[0],[opaque],0))),
   p128bs_control_row("region-opaque-cannot-escape",String.eq(tg(noa_finish_value(ctx,opaque,var("Bool",11),[])),"Absent")),
   p128bs_control_row("region-opaque-cannot-recur",Bool.not(noa_loop_valid(ctx,[var("String",10)],[opaque],0,False{}))),
   p128bs_control_row("region-valid-held-string-retained",p128br_test_accept(p128br_test_arg("OA","String",kt("OArg","",0,0,[]))))]
