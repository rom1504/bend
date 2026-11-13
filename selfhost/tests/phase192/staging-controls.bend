# Compiler-data controls for the existing private-operation plan. These invoke
# the actual forward/read-footprint/prune pipeline, bypassing earlier scalar
# cleanup so that alias, mutation and observation hazards remain visible.
# The unary effect/value implementation must admit exact op23/op58 arity1.
# Rejection rows are finite compiler-data controls, not executable bad programs.
def p192st_v(name: String) -> N111Value: N111Local{name}

def p192st_alloc(name: String, bytes: U32) -> P113DStmt:
  P113DScalar{N111Alloca{name,bytes,8}}

def p192st_store(buffer: String, offset: U32, value: N111Value) -> P113DStmt:
  P113DScalar{N111Store{N111U64{},p192st_v(buffer),offset,value}}

def p192st_call(destination: String, id: U32, count: U32, buffer: String) -> P113DStmt:
  P113DScalar{N111Call{destination,N111U64{},"p111_rt_op",[
    N111Arg{N111Ptr{},p192st_v("state")},N111Arg{N111U32{},N111Const{id,0}},
    N111Arg{N111Ptr{},p192st_v(buffer)},N111Arg{N111U32{},N111Const{count,0}}]}}

def p192st_unknown(args: List<&2,N111Arg>) -> P113DStmt:
  P113DScalar{N111Call{"unknown",N111U64{},"p192st_external",args}}

@unsafe
def p192st_ready(+params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>) -> List<&2,X186FloatNode>:
  x186_f_ready(params,setup,x186_f_plan(body,x186_f_buffers(params,setup,body),[]))

@unsafe
def p192st_plan(body: List<&2,P113DStmt>) -> List<&2,X186FloatNode>:
  p192st_ready(["state","a","b","condition","external"],[],body)

# kind 1: value operations; 2: stores; 3: allocas; 4: original calls.
law p192st_count:
  for nodes: List<&2,X186FloatNode>
  for +kind: U32
  U32

@unsafe
def p192st_count(nodes,kind):
  match nodes:
    case Nil{}: 0
    case Con{X186FloatBranch{condition,yes,no},rest}:
      U32.add(U32.add(p192st_count(yes,kind),p192st_count(no,kind)),p192st_count(rest,kind))
    case Con{X186FloatValues{destination,id,left,right},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,1),u => 1,u => 0),p192st_count(rest,kind))
    case Con{X186FloatPlain{P113DScalar{N111Store{typ,base,offset,value}}},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,2),u => 1,u => 0),p192st_count(rest,kind))
    case Con{X186FloatPlain{P113DScalar{N111Alloca{name,bytes,align}}},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,3),u => 1,u => 0),p192st_count(rest,kind))
    case Con{X186FloatPlain{P113DScalar{N111Call{name,typ,symbol,args}}},rest}:
      U32.add(nt_choose(U32,U32.is_eq(kind,4),u => 1,u => 0),p192st_count(rest,kind))
    case Con{head,rest}: p192st_count(rest,kind)

@unsafe
def p192st_shape(+nodes: List<&2,X186FloatNode>, values: U32, stores: U32, allocas: U32, calls: U32) -> Bool:
  U32.is_eq(p192st_count(nodes,1),values) && U32.is_eq(p192st_count(nodes,2),stores) &&
    U32.is_eq(p192st_count(nodes,3),allocas) && U32.is_eq(p192st_count(nodes,4),calls)

@unsafe
def p192st_case(name: String, body: List<&2,P113DStmt>, values: U32, stores: U32, allocas: U32, calls: U32) -> String:
  p192st_row(name,p192st_shape(p192st_plan(body),values,stores,allocas,calls))

@unsafe
def p192st_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

def p192st_chain() -> List<&2,P113DStmt>:
  [p192st_alloc("buffer",16),p192st_store("buffer",0,p192st_v("a")),
   p192st_call("fa",23,1,"buffer"),p192st_store("buffer",0,p192st_v("fa")),
   p192st_store("buffer",8,p192st_v("b")),p192st_call("sum",26,2,"buffer"),
   p192st_store("buffer",0,p192st_v("sum")),p192st_call("word",58,1,"buffer"),
   P113DResult{[p192st_v("word")]}]

@unsafe
def p192st_unary(+id: U32) -> Bool:
  p192st_shape(p192st_plan([p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
    p192st_call("result",id,1,"buffer"),P113DResult{[p192st_v("result")]}]),1,0,0,0)

@unsafe
def p192st_snapshot(nodes: List<&2,X186FloatNode>) -> Bool:
  match nodes:
    case Con{X186FloatValues{destination,id,N111Local{left},N111Local{right}},Nil{}}:
      String.eq(destination,"a") && U32.is_eq(id,58) && String.eq(left,"a") && String.eq(right,"a")
    case _: False{}

@unsafe
def p192st_controls() -> List<&2,String>:
  [p192st_row("unary23-eight-byte-buffer",p192st_unary(23)),
   p192st_row("unary58-eight-byte-buffer",p192st_unary(58)),
   p192st_case("conversion-arithmetic-conversion-store-free",p192st_chain(),3,0,0,0),
   p192st_case("unknown-call-without-buffer-after-plan",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     p192st_unknown([])],1,0,0,1),
   p192st_case("unknown-call-buffer-escape-after-plan",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     p192st_unknown([N111Arg{N111Ptr{},p192st_v("buffer")}])],1,1,1,1),
   p192st_case("unknown-call-between-store-and-operation",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_unknown([]),
     p192st_call("result",58,1,"buffer")],0,1,1,2),
   p192st_case("source-reassignment-refuses-forwarding",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DScalar{N111Set{"a",N111U64{},p192st_v("b")}},p192st_call("result",58,1,"buffer")],0,1,1,1),
   p192st_case("overlapping-narrow-store-refuses-forwarding",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DScalar{N111Store{N111U32{},p192st_v("buffer"),4,N111Const{0,0}}},
     p192st_call("result",58,1,"buffer")],0,2,1,1),
   p192st_case("ordinary-read-retains-staging",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     P113DScalar{N111Load{"observed",N111U64{},p192st_v("buffer"),0}}],1,1,1,0),
   p192st_case("unrelated-cell-read-keeps-only-observed-cell",[
     p192st_alloc("buffer",16),p192st_store("buffer",0,p192st_v("a")),p192st_store("buffer",8,p192st_v("b")),
     p192st_call("result",58,1,"buffer"),P113DScalar{N111Load{"observed",N111U64{},p192st_v("buffer"),8}}],1,1,1,0),
   p192st_case("address-copy-escapes-entire-buffer",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DScalar{N111Set{"alias",N111Ptr{},p192st_v("buffer")}},p192st_call("result",58,1,"buffer")],1,1,1,0),
   p192st_case("alias-store-kills-forwarding",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DScalar{N111Offset{"alias",p192st_v("buffer"),N111Const{0,0}}},
     p192st_store("alias",0,p192st_v("b")),p192st_call("result",58,1,"buffer")],0,2,1,1),
   p192st_case("returned-address-escapes-buffer",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     P113DResult{[p192st_v("buffer")]}],1,1,1,0),
   p192st_case("again-address-escapes-buffer",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     P113DAgain{[p192st_v("buffer")]}],1,1,1,0),
   p192st_case("address-stored-elsewhere-escapes-buffer",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer"),
     p192st_store("external",0,p192st_v("buffer"))],1,2,1,0),
   p192st_case("branch-before-operation-drops-facts",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DIf{p192st_v("condition"),[],[]},p192st_call("result",58,1,"buffer")],0,1,1,1),
   p192st_case("branch-local-staging-pruned-both-arms",[
     p192st_alloc("buffer",8),P113DIf{p192st_v("condition"),
       [p192st_store("buffer",0,p192st_v("a")),p192st_call("result",23,1,"buffer")],
       [p192st_store("buffer",0,p192st_v("b")),p192st_call("result",58,1,"buffer")]}],2,0,0,0),
   p192st_case("branch-observation-retains-all-cell-stores",[
     p192st_alloc("buffer",8),P113DIf{p192st_v("condition"),
       [p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer")],
       [p192st_store("buffer",0,p192st_v("b")),P113DScalar{N111Load{"observed",N111U64{},p192st_v("buffer"),0}}]}],1,2,1,0),
   p192st_case("branch-escape-retains-all-cell-stores",[
     p192st_alloc("buffer",8),P113DIf{p192st_v("condition"),
       [p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer")],
       [p192st_unknown([N111Arg{N111Ptr{},p192st_v("buffer")}])]}],1,1,1,1),
   p192st_case("escape-of-other-buffer-does-not-block-prune",[
     p192st_alloc("buffer",8),p192st_alloc("other",8),p192st_store("buffer",0,p192st_v("a")),
     p192st_store("other",0,p192st_v("b")),p192st_call("result",58,1,"buffer"),
     p192st_unknown([N111Arg{N111Ptr{},p192st_v("other")}])],1,1,1,1),
   p192st_case("wrong-unary-count-keeps-original",[
     p192st_alloc("buffer",16),p192st_store("buffer",0,p192st_v("a")),p192st_store("buffer",8,p192st_v("b")),
     p192st_call("result",58,2,"buffer")],0,2,1,1),
   p192st_case("unsupported-operation-keeps-original",[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",36,1,"buffer")],0,1,1,1),
   p192st_case("nonprivate-address-keeps-original",[
     p192st_store("external",0,p192st_v("a")),p192st_call("result",58,1,"external")],0,1,0,1),
   p192st_row("incoming-buffer-not-private",p192st_shape(p192st_ready(["state","buffer","a"],[],[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer")]),0,1,1,1)),
   p192st_row("setup-observation-retains-body-staging",p192st_shape(p192st_ready(["state","a"],[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),
     P113DScalar{N111Load{"observed",N111U64{},p192st_v("buffer"),0}}],[
     p192st_store("buffer",0,p192st_v("a")),p192st_call("result",58,1,"buffer")]),1,1,0,0)),
   p192st_row("setup-facts-not-forwarded-into-loop",p192st_shape(p192st_ready(["state","a"],[
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a"))],[p192st_call("result",58,1,"buffer")]),0,0,0,1)),
   p192st_row("same-name-result-reads-old-source",p192st_snapshot(p192st_plan([
     p192st_alloc("buffer",8),p192st_store("buffer",0,p192st_v("a")),p192st_call("a",58,1,"buffer")])))]
