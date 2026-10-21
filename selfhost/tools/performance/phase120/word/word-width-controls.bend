# Finite renderer checks only; malformed triples are never executed natively.
@unsafe
def p120wp_first(+name: String, source: String, amount: U32, typ: N111Type) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,"shl",N111Local{source},N111Const{amount,0}}}

@unsafe
def p120wp_second(destination: String, source: String, amount: U32, typ: N111Type) -> P113DStmt:
  P113DScalar{N111Bin{destination,typ,"sar",N111Local{source},N111Const{amount,0}}}

@unsafe
def p120wp_controls(unit: Unit) -> List<&2,String>:
  +first = p120wp_first("value","a",32,N111U64{})
  +second = p120wp_second("value","value",40,N111U64{})
  +mask = p113wt_mask("value","value",4294967295,0)
  [p113wt_row("signed-word-triple",p120wp_triple(first,second,mask)),
   p113wt_row("signed-word-minimum",p120wp_triple(first,p120wp_second("value","value",33,N111U64{}),mask)),
   p113wt_row("signed-word-maximum",p120wp_triple(first,p120wp_second("value","value",63,N111U64{}),mask)),
   p113wt_row("signed-word-shift32-refused",Bool.not(p120wp_triple(first,p120wp_second("value","value",32,N111U64{}),mask))),
   p113wt_row("signed-word-shift64-refused",Bool.not(p120wp_triple(first,p120wp_second("value","value",64,N111U64{}),mask))),
   p113wt_row("signed-word-first-shift-refused",Bool.not(p120wp_triple(p120wp_first("value","a",31,N111U64{}),second,mask))),
   p113wt_row("signed-word-first-width-refused",Bool.not(p120wp_triple(p120wp_first("value","a",32,N111U32{}),second,mask))),
   p113wt_row("signed-word-second-width-refused",Bool.not(p120wp_triple(first,p120wp_second("value","value",40,N111U32{}),mask))),
   p113wt_row("signed-word-other-destination-refused",Bool.not(p120wp_triple(first,p120wp_second("other","value",40,N111U64{}),mask))),
   p113wt_row("signed-word-other-source-refused",Bool.not(p120wp_triple(first,p120wp_second("value","other",40,N111U64{}),mask))),
   p113wt_row("signed-word-near-mask-refused",Bool.not(p120wp_triple(first,second,p113wt_mask("value","value",4294967294,0)))),
   p113wt_row("signed-word-high-mask-refused",Bool.not(p120wp_triple(first,second,p113wt_mask("value","value",4294967295,1)))),
   p113wt_row("signed-word-other-mask-destination-refused",Bool.not(p120wp_triple(first,second,p113wt_mask("other","value",4294967295,0)))),
   p113wt_row("signed-word-other-mask-source-refused",Bool.not(p120wp_triple(first,second,p113wt_mask("value","other",4294967295,0)))),
   p113wt_row("signed-word-exact-emission",String.eq(p113wt_text([first,second,mask]),
     "%p113_width_7 =w sar %v_a, 8\n%v_value =l extuw %p113_width_7\nret 0\n")),
   p113wt_row("signed-word-alias-emission",String.eq(p113wt_text([p120wp_first("value","value",32,N111U64{}),second,mask]),
     "%p113_width_7 =w sar %v_value, 8\n%v_value =l extuw %p113_width_7\nret 0\n")),
   p113wt_row("signed-word-counter",p113wt_next(p113w_stmts([first,second,mask],[],N111Ids{missing(),missing()},P111QCode{[],7,False{},""}),8))]
