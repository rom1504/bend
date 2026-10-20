@unsafe
def p113wt_row(+name: String, valid: Bool) -> String:
  nt_choose(String,valid,u => "PASS " ++ name,u => "FAIL " ++ name)

def p113wt_first(op: String) -> P113DStmt:
  P113DScalar{N111Bin{"value",N111U64{},op,N111Local{"a"},N111Local{"b"}}}

def p113wt_mask(destination: String, source: String, lo: U32, hi: U32) -> P113DStmt:
  P113DScalar{N111Bin{destination,N111U64{},"and",N111Local{source},N111Const{lo,hi}}}

@unsafe
def p113wt_accept(op: String) -> Bool:
  p113w_pair(p113wt_first(op),p113wt_mask("value","value",4294967295,0))

@unsafe
def p113wt_text(+body: List<&2,P113DStmt>) -> String:
  p111q_body_text(p113w_stmts(body,[],N111Ids{missing(),missing()},P111QCode{[],7,False{},""}))

@unsafe
def p113wt_next(code: P111QCode, +expected: U32) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_eq(next,expected)

@unsafe
def p113_width_control_report() -> List<&2,String>:
  +mask = p113wt_mask("value","value",4294967295,0)
  +first = p113wt_first("add")
  [p113wt_row("width-add",p113wt_accept("add")),
   p113wt_row("width-sub",p113wt_accept("sub")),
   p113wt_row("width-mul",p113wt_accept("mul")),
   p113wt_row("width-and",p113wt_accept("and")),
   p113wt_row("width-or",p113wt_accept("or")),
   p113wt_row("width-xor",p113wt_accept("xor")),
   p113wt_row("width-shl-refused",Bool.not(p113wt_accept("shl"))),
   p113wt_row("width-shr-refused",Bool.not(p113wt_accept("shr"))),
   p113wt_row("width-sar-refused",Bool.not(p113wt_accept("sar"))),
   p113wt_row("width-div-refused",Bool.not(p113wt_accept("udiv"))),
   p113wt_row("width-compare-refused",Bool.not(p113wt_accept("ult"))),
   p113wt_row("width-different-destination",Bool.not(p113w_pair(first,p113wt_mask("other","value",4294967295,0)))),
   p113wt_row("width-different-source",Bool.not(p113w_pair(first,p113wt_mask("value","other",4294967295,0)))),
   p113wt_row("width-near-mask",Bool.not(p113w_pair(first,p113wt_mask("value","value",4294967294,0)))),
   p113wt_row("width-high-mask",Bool.not(p113w_pair(first,p113wt_mask("value","value",4294967295,1)))),
   p113wt_row("width-u32-input-statement-refused",Bool.not(p113w_pair(P113DScalar{N111Bin{"value",N111U32{},"add",N111Local{"a"},N111Local{"b"}}},mask))),
   p113wt_row("width-branch-barrier",Bool.not(p113w_pair(first,P113DIf{N111Const{1,0},[mask],[mask]}))),
   p113wt_row("width-exact-emission",String.eq(p113wt_text([first,mask]),"%p113_width_7 =w add %v_a, %v_b\n%v_value =l extuw %p113_width_7\n")),
   p113wt_row("width-mask-zero-extension",String.eq(p113wt_text([p113wt_mask("value","a",4294967295,0)]),"%p113_width_7 =w copy %v_a\n%v_value =l extuw %p113_width_7\n")),
   p113wt_row("width-counter-consumed",p113wt_next(p113w_stmts([first,mask],[],N111Ids{missing(),missing()},P111QCode{[],7,False{},""}),8)),
   p113wt_row("width-counter-overflow-fallback",Bool.not(p113w_room(P111QCode{[],4294967295,False{},""}))),
   p113wt_row("width-destination-alias",String.eq(p113wt_text([P113DScalar{N111Bin{"value",N111U64{},"mul",N111Local{"value"},N111Local{"value"}}},mask]),"%p113_width_7 =w mul %v_value, %v_value\n%v_value =l extuw %p113_width_7\n"))]
