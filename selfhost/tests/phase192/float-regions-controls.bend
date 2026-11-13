# Direct home/canonical-map controls. These do not claim machine execution.
def p192fr_v(name: String) -> N111Value: N111Local{name}
def p192fr_float(name: String, value: N111Value) -> X186FloatNode:
  X186FloatValues{name,26,value,N111Const{1065353216,0}}
def p192fr_plain(stmt: N111Stmt) -> X186FloatNode: X186FloatPlain{P113DScalar{stmt}}
def p192fr_bin(name: String, value: N111Value) -> N111Stmt:
  N111Bin{name,N111U64{},"add",value,N111Const{1,0}}

@unsafe
def p192fr_has(name: String, homes: KDef) -> Bool:
  String.eq(dk(p111v_get(homes,name)),"X186Xmm")

@unsafe
def p192fr_spans(+middle: N111Stmt) -> Bool:
  +nodes = [p192fr_float("a",N111Const{1065353216,0}),p192fr_plain(middle),
    p192fr_float("b",p192fr_v("a"))]
  p192fr_has("a",x192fr_homes([],[],nodes)) && Bool.not(p192fr_has("a",p192fr_baseline_homes(nodes)))

@unsafe
def p192fr_blocked(+name: String, middle: N111Stmt) -> Bool:
  Bool.not(p192fr_has(name,x192fr_homes([],[],[
    p192fr_float(name,N111Const{1065353216,0}),p192fr_plain(middle),p192fr_float("b",p192fr_v(name))])))

@unsafe
def p192fr_crosscut(middle: X186FloatNode) -> Bool:
  Bool.not(p192fr_has("a",x192fr_homes([],[],[
    p192fr_float("a",N111Const{1065353216,0}),middle,p192fr_float("b",p192fr_v("a"))])))

@unsafe
def p192fr_noncanonical_copy() -> Bool:
  Bool.not(p192fr_has("copy",x192fr_homes([],[],[
    p192fr_float("a",N111Const{1065353216,0}),p192fr_plain(p192fr_bin("a",N111Const{0,1})),
    p192fr_plain(N111Set{"copy",N111U64{},p192fr_v("a")}),p192fr_float("b",p192fr_v("copy"))])))

@unsafe
def p192fr_canonical_copy() -> Bool:
  p192fr_has("copy",x192fr_homes([],[],[
    p192fr_float("a",N111Const{1065353216,0}),p192fr_plain(p192fr_bin("integer",N111Const{0,1})),
    p192fr_plain(N111Set{"copy",N111U64{},p192fr_v("a")}),p192fr_float("b",p192fr_v("copy"))]))

@unsafe
def p192fr_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p192fr_controls() -> List<&2,String>:
  [p192fr_row("span-integer-bin",p192fr_spans(p192fr_bin("integer",N111Const{0,1}))),
   p192fr_row("span-u32-set",p192fr_spans(N111Set{"integer",N111U32{},N111Const{1,0}})),
   p192fr_row("span-load",p192fr_spans(N111Load{"integer",N111U64{},p192fr_v("base"),0})),
   p192fr_row("span-store",p192fr_spans(N111Store{N111U64{},p192fr_v("base"),0,p192fr_v("integer")})),
   p192fr_row("span-offset",p192fr_spans(N111Offset{"address",p192fr_v("base"),p192fr_v("offset")})),
   p192fr_row("bin-read-blocked",p192fr_blocked("a",p192fr_bin("integer",p192fr_v("a")))),
   p192fr_row("bin-write-blocked",p192fr_blocked("a",p192fr_bin("a",N111Const{0,1}))),
   p192fr_row("narrow-set-read-blocked",p192fr_blocked("a",N111Set{"integer",N111U32{},p192fr_v("a")})),
   p192fr_row("narrow-set-write-blocked",p192fr_blocked("a",N111Set{"a",N111U32{},N111Const{1,0}})),
   p192fr_row("load-base-blocked",p192fr_blocked("a",N111Load{"integer",N111U64{},p192fr_v("a"),0})),
   p192fr_row("load-result-blocked",p192fr_blocked("a",N111Load{"a",N111U64{},p192fr_v("base"),0})),
   p192fr_row("store-base-blocked",p192fr_blocked("a",N111Store{N111U64{},p192fr_v("a"),0,p192fr_v("integer")})),
   p192fr_row("store-value-blocked",p192fr_blocked("a",N111Store{N111U64{},p192fr_v("base"),0,p192fr_v("a")})),
   p192fr_row("offset-base-blocked",p192fr_blocked("a",N111Offset{"address",p192fr_v("a"),N111Const{8,0}})),
   p192fr_row("offset-bytes-blocked",p192fr_blocked("a",N111Offset{"address",p192fr_v("base"),p192fr_v("a")})),
   p192fr_row("offset-result-blocked",p192fr_blocked("a",N111Offset{"a",p192fr_v("base"),N111Const{8,0}})),
   p192fr_row("canonical-copy-survives",p192fr_canonical_copy()),
   p192fr_row("noncanonical-copy-not-truncated",p192fr_noncanonical_copy()),
   p192fr_row("call-cuts",p192fr_crosscut(p192fr_plain(N111Call{"integer",N111U64{},"external",[]}))),
   p192fr_row("allocation-cuts",p192fr_crosscut(p192fr_plain(N111Alloca{"buffer",8,8}))),
   p192fr_row("backedge-cuts",p192fr_crosscut(X186FloatPlain{P113DAgain{[]}})),
   p192fr_row("result-cuts",p192fr_crosscut(X186FloatPlain{P113DResult{[]}})),
   p192fr_row("branch-cuts",p192fr_crosscut(X186FloatBranch{N111Const{1,0},[],[]})),
   p192fr_row("unsupported-bin-cuts",p192fr_crosscut(p192fr_plain(N111Bin{"integer",N111U64{},"div",N111Const{1,0},N111Const{1,0}})))]

@unsafe
def p192fr_baseline_homes(nodes: List<&2,X186FloatNode>) -> KDef:
  x186_x_scanned(x186_x_scan(nodes,X186XScan{X185TScan{missing(),[],1,0},missing()}))
