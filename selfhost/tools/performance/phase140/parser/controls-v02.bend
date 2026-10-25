@unsafe
def p140pt_header(+text: String, +start: U32) -> FHeader:
  f_header_scan(text,text,start,1,0,"")

@unsafe
def p140pt_fresh(+text: String, scope: FParseScope, +start: U32) -> FResult:
  f_body_header(text,p140pt_header(text,start),scope,start)

@unsafe
def p140pt_same(a: FResult, b: FResult) -> Bool:
  match a b:
    case FResult{ab,ae,ai} FResult{bb,be,bi}:
      String.eq(ae,be) && p140p_defs(ab,bb) && f_fresh_prefix_exact_terms(ai,bi)

@unsafe
def p140pt_after(+old: String, +current: String, +newscope: FParseScope, +newstart: U32, +hit: Bool, +seed: P140PParsed) -> Bool:
  p140pt_resumed(p140pt_same(p140p_parsed_result(seed),p140pt_fresh(old,f_parse_scope_empty(),1)),
    p140pt_fresh(current,newscope,newstart),hit,
    p140p_resume(current,p140pt_header(current,newstart),newscope,newstart,p140p_parsed_cache(seed)))

@unsafe
def p140pt_resumed(seed_same: Bool, fresh: FResult, expected: Bool, resumed: P140PParsed) -> Bool:
  match resumed:
    case P140PParsed{result,cache,hit}:
      seed_same && Bool.not(Bool.xor(hit,expected)) && p140pt_same(fresh,result)

@unsafe
def p140pt_case(+old: String, current: String, hint: U32, scope: FParseScope, start: U32, hit: Bool) -> Bool:
  p140pt_after(old,current,scope,start,hit,p140p_seed(old,p140pt_header(old,1),f_parse_scope_empty(),1,hint))

@unsafe
def p140pt_source() -> String:
  "def first(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  first(1)\n"

@unsafe
def p140p_controls() -> List<&2,String>:
  +old = p140pt_source()
  +edited : String = "def first(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  first(2)\n"
  +unicode : String = "# 😀\ndef first(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  first(1)\n"
  [p128bs_control_row("parser-noop-hit",p140pt_case(old,old,20,f_parse_scope_empty(),1,True{})),
   p128bs_control_row("parser-numeric-edit-hit",p140pt_case(old,edited,20,f_parse_scope_empty(),1,True{})),
   p128bs_control_row("parser-binder-edit-hit",p140pt_case(old,"def first(x: U32) -> U32:\n  x\n\ndef main(y: U32) -> U32:\n  first(y)\n",20,f_parse_scope_empty(),1,True{})),
   p128bs_control_row("parser-prefix-edit-miss",p140pt_case(old,"def other(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  other(1)\n",20,f_parse_scope_empty(),1,False{})),
   p128bs_control_row("parser-header-edit-miss",p140pt_case(old,"# changed\n" ++ edited,20,f_parse_scope_empty(),1,False{})),
   p128bs_control_row("parser-invalid-suffix-hit",p140pt_case(old,"def first(x: U32) -> U32:\n  x\n\ndef main( -> U32:\n",20,f_parse_scope_empty(),1,True{})),
   p128bs_control_row("parser-unicode-prefix-hit",p140pt_case(unicode,"# 😀\ndef first(x: U32) -> U32:\n  x\n\ndef main() -> U32:\n  first(2)\n",26,f_parse_scope_empty(),1,True{})),
   p128bs_control_row("parser-namespace-miss",p140pt_case(old,edited,20,FParseScope{[],missing(),missing(),"Other",[]},1,False{})),
   p128bs_control_row("parser-alias-miss",p140pt_case(old,edited,20,FParseScope{[],missing(),missing(),"",[kt("Alias","Other",0,0,[])]},1,False{})),
   p128bs_control_row("parser-origin-miss",p140pt_case(old,edited,20,f_parse_scope_empty(),17,False{})),
   p128bs_control_row("parser-no-boundary-miss",p140pt_case(old,edited,4294967295,f_parse_scope_empty(),1,False{})),
   p128bs_control_row("parser-utf16-half-refused",p140pt_half(p140p_prefix("😀x","😀y",1))),
   p128bs_control_row("parser-utf16-full-prefix",p140pt_match(p140p_prefix("😀x","😀y",2))),
   p128bs_control_row("parser-index-variant-distinct",Bool.not(p140p_defs([KIndexLeaf{0,[]}],[KDef{"","IndexLeaf",0,0,atom("Absent"),atom("Absent"),[],True{},False{}}])))]

@unsafe
def p140pt_half(result: P140PMatch) -> Bool:
  match result:
    case P140PMatch{tail,same}: Bool.not(same)

@unsafe
def p140pt_match(result: P140PMatch) -> Bool:
  match result:
    case P140PMatch{tail,same}: same && String.eq(tail,"y")
