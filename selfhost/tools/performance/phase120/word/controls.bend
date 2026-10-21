# Pure analysis data only. These are not emitted as native failure probes.
type P120WControl is Data:
  P120WControl{+name: String, +actualHits: U32, +expectedHits: U32, +body: List<&2,P113DStmt>}

@unsafe
def p120wc_set(name: String, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,N111U64{},value}}

@unsafe
def p120wc_const(name: String, value: U32) -> P113DStmt:
  p120wc_set(name,N111Const{value,0})

@unsafe
def p120wc_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

@unsafe
def p120wc_body(+count: U32, +mask: U32, +reverse: Bool, +invert: Bool, +partial: Bool,
    signRoot: String, between: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,
    [p120wc_bin("x","and",N111Local{"a"},N111Const{4294967295,0}),
     p120wc_bin("other","and",N111Local{"b"},N111Const{4294967295,0}),
     p120wc_bin("shift","shr",N111Local{"x"},N111Const{count,0}),
     p120wc_bin("sign","shr",N111Local{signRoot},N111Const{31,0}),
     p120wc_bin("zero","eq",N111Local{"sign"},N111Const{0,0}),
     P113DScalar{N111If{N111Local{"zero"},[N111Set{"bool",N111U64{},N111Const{1,0}}],
       [N111Set{"bool",N111U64{},N111Const{0,0}}]}},
     p120wc_set("copy",N111Local{"bool"}),
     p120wc_bin("decode","eq",N111Local{"copy"},N111Const{1,0}),
     P113DIf{N111Local{"decode"},
       [p120wc_const("fill",nt_choose(U32,invert,u => mask,u => 0))],
       nt_choose(List<&2,P113DStmt>,partial,u => [],
         u => [p120wc_const("fill",nt_choose(U32,invert,v => 0,v => mask))])}],
    nt_append(P113DStmt,between,
      [p120wc_bin("out","or",nt_choose(N111Value,reverse,u => N111Local{"fill"},u => N111Local{"shift"}),
        nt_choose(N111Value,reverse,u => N111Local{"shift"},u => N111Local{"fill"})),
       P113DResult{[N111Local{"out"}]}]))

@unsafe
def p120wc_result(name: String, expected: U32, scan: P120WScan) -> P120WControl:
  match scan:
    case P120WScan{reversed,facts,next,hits}:
      P120WControl{name,hits,expected,nt_reverse(P113DStmt,reversed,[])}

@unsafe
def p120wc_case(name: String, body: List<&2,P113DStmt>, expected: U32) -> P120WControl:
  p120wc_result(name,expected,p120w_walk(body,P120WScan{[],
    p120w_seed([NC_Binding{0,"a",N_Box{}},NC_Binding{1,"b",N_Box{}}],1,[]),3,0}))

@unsafe
def p120w_controls(_: Unit) -> List<&2,P120WControl>:
  +update : P113DStmt = p120wc_set("x",N111Local{"other"})
  +call : P113DStmt = P113DCall{["unused"],"unknown",[N111Local{"x"}]}
  +store : P113DStmt = P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"x"}}}
  [p120wc_case("constant-shift8",p120wc_body(8,4278190080,False{},False{},False{},"x",[]),1),
   p120wc_case("commuted-or",p120wc_body(8,4278190080,True{},False{},False{},"x",[]),1),
   p120wc_case("constant-shift1",p120wc_body(1,2147483648,False{},False{},False{},"x",[]),1),
   p120wc_case("constant-shift16",p120wc_body(16,4294901760,False{},False{},False{},"x",[]),1),
   p120wc_case("wrong-mask-refused",p120wc_body(8,4294901760,False{},False{},False{},"x",[]),0),
   p120wc_case("different-origin-refused",p120wc_body(8,4278190080,False{},False{},False{},"other",[]),0),
   p120wc_case("overwritten-origin-refused",p120wc_body(8,4278190080,False{},False{},False{},"x",[update]),0),
   p120wc_case("retained-alias-accepted",p120wc_body(8,4278190080,False{},False{},False{},"x",[p120wc_set("held",N111Local{"x"}),update]),1),
   p120wc_case("partial-join-refused",p120wc_body(8,4278190080,False{},False{},True{},"x",[]),0),
   p120wc_case("inverse-fill-refused",p120wc_body(8,4278190080,False{},True{},False{},"x",[]),0),
   p120wc_case("unknown-call-invalidates",p120wc_body(8,4278190080,False{},False{},False{},"x",[call]),0),
   p120wc_case("unknown-memory-invalidates",p120wc_body(8,4278190080,False{},False{},False{},"x",[store]),0),
   p120wc_case("shift32-refused",p120wc_body(32,0,False{},False{},False{},"x",[]),0),
   p120wc_case("sign-only-shift31-fallback",p120wc_body(31,4294967294,False{},False{},False{},"x",[]),0)]
