# Optional integration-only update to the explicit width policy control.
# The original thirteen controls and all safety predicates remain present.
@unsafe
def p131rg_controls() -> List<&2,String>:
  +opaque = p131rg_control_opaque()
  +ctx = p131rg_control_context()
  +reserved : KDef = KDef{p131rg_opaque(),"ADT",0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
  [p128bs_control_row("region-width-zero",p131rg_width(0)),
   p128bs_control_row("region-width-two",p131rg_width(2)),
   p128bs_control_row("region-width-eight",p131rg_width(8)),
   p128bs_control_row("region-packed-single-refused",Bool.not(p131rg_width(1))),
   p128bs_control_row("region-width-seventeen-refused",Bool.not(p131rg_width(17))),
   p128bs_control_row("region-empty-symbol-available",p131rg_symbol_available([])),
   p128bs_control_row("region-symbol-collision-refused",Bool.not(p131rg_symbol_available([reserved]))),
   p128bs_control_row("region-opaque-not-scalar",String.eq(tg(noa_scalar(ctx,opaque)),"Absent")),
   p128bs_control_row("region-opaque-not-readable",p131rg_control_match()),
   p128bs_control_row("region-opaque-not-string-helper",Bool.not(p128br_arguments(ctx,[var("String",20)],[0],[opaque],0))),
   p128bs_control_row("region-opaque-cannot-escape",String.eq(tg(noa_finish_value(ctx,opaque,var("Bool",11),[])),"Absent")),
   p128bs_control_row("region-opaque-cannot-recur",Bool.not(noa_loop_valid(ctx,[var("String",10)],[opaque],0,False{}))),
   p128bs_control_row("region-valid-held-string-retained",p128br_test_accept(p128br_test_arg("OA","String",kt("OArg","",0,0,[]))))]

