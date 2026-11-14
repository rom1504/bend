# Bounded owned-projection ceiling, not a new optimizer or admission rule.
# Both routes use the existing IR/runtime. Baseline depth is statically <=8.
def p195o_v(name: String) -> N111Value: N111Local{name}
def p195o_c(n: U32) -> N111Value: N111Const{n,0}
def p195o_s(stmt: N111Stmt) -> P113DStmt: P113DScalar{stmt}
def p195o_arg(name: String) -> N111Arg: N111Arg{N111U64{},p195o_v(name)}
def p195o_call(name: String, symbol: String, args: List<&2,N111Arg>) -> P113DStmt:
  p195o_s(N111Call{name,N111U64{},symbol,Con{p111_state(),args}})
def p195o_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  p195o_s(N111Bin{name,N111U64{},op,left,right})
def p195o_load(name: String, offset: U32) -> P113DStmt:
  p195o_s(N111Load{name,N111U64{},p195o_v("scratch"),offset})
def p195o_store(offset: U32, name: String) -> P113DStmt:
  p195o_s(N111Store{N111U64{},p195o_v("scratch"),offset,p195o_v(name)})
def p195o_take(count: U32) -> P113DStmt:
  p195o_call("status","p111_rt_take",[p195o_arg("tree"),p111_scratch(),p111_u32(count)])
def p195o_borrow(ctor: String, count: U32) -> P113DStmt:
  p195o_call("status","p118_rt_borrow_fields",[p195o_arg("tree"),p111_scratch(),
    N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(count)])
def p195o_ctor(ctor: String, count: U32) -> P113DStmt:
  p195o_call("tree","p111_rt_ctor",[N111Arg{N111U32{},N111CtorId{ctor}},p111_scratch(),p111_u32(count)])
def p195o_basename(depth: U32) -> String: "p195o_base_" ++ U32.show(depth)
def p195o_candidate(depth: U32) -> String: "p195o_fast_" ++ U32.show(depth)
def p195o_params() -> List<&2,NC_Binding>:
  [NC_Binding{0,"tree",N_W64{}},NC_Binding{1,"query",N_W64{}}]

@unsafe
def p195o_leaf_finish(+hit: Bool) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,nt_choose(List<&2,P113DStmt>,hit,
    u => [p195o_call("payload","p111_rt_keep",[p195o_arg("payload")])],u => []),
    [p195o_store(0,"key"),p195o_store(8,"payload"),p195o_ctor("OLeaf",2),
     P113DResult{[p195o_v("tree"),p195o_c(Bool.to_u32(hit)),
       nt_choose(N111Value,hit,u => p195o_v("payload"),u => p195o_c(0)),p195o_c(0)]}])

@unsafe
def p195o_base_leaf() -> List<&2,P113DStmt>:
  [p195o_take(2),p195o_load("key",0),p195o_load("payload",8),
   p195o_bin("same","eq",p195o_v("key"),p195o_v("query")),
   P113DIf{p195o_v("same"),p195o_leaf_finish(True{}),p195o_leaf_finish(False{})}]

@unsafe
def p195o_base_child(depth: U32, +left: Bool) -> List<&2,P113DStmt>:
  [P113DCall{["child","hit","payload","route"],p195o_basename(U32.sub(depth,1)),
     [p195o_v(nt_choose(String,left,u => "left",u => "right")),p195o_v("query")]},
   p195o_store(0,"pivot"),p195o_store(8,nt_choose(String,left,u => "child",u => "left")),
   p195o_store(16,nt_choose(String,left,u => "right",u => "child")),p195o_ctor("ONode",3),
   P113DResult{[p195o_v("tree"),p195o_v("hit"),p195o_v("payload"),p195o_c(0)]}]

@unsafe
def p195o_base_node(+depth: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(depth,0),u =>
    [p195o_call("status","p111_rt_fail",[p111_u32(4)]),P113DResult{[p195o_v("tree"),p195o_c(0),p195o_c(0),p195o_c(0)]}],u =>
    [p195o_take(3),p195o_load("pivot",0),p195o_load("left",8),p195o_load("right",16),
     p195o_bin("less","ult",p195o_v("query"),p195o_v("pivot")),
     P113DIf{p195o_v("less"),p195o_base_child(depth,True{}),p195o_base_child(depth,False{})}])

@unsafe
def p195o_base(+depth: U32) -> P113DFunction:
  P113DFunction{p195o_basename(depth),p195o_params(),4,False{},
    [p195o_call("cid","p111_rt_tag",[p195o_arg("tree")]),
     p195o_bin("empty","eq",p195o_v("cid"),N111CtorId{"OEmpty"}),
     P113DIf{p195o_v("empty"),[P113DResult{[p195o_v("tree"),p195o_c(0),p195o_c(0),p195o_c(0)]}],
       [p195o_bin("leaf","eq",p195o_v("cid"),N111CtorId{"OLeaf"}),
        P113DIf{p195o_v("leaf"),p195o_base_leaf(),p195o_base_node(depth)}]}]}

@unsafe
def p195o_read() -> P113DFunction:
  P113DFunction{"p195o_read",p195o_params(),2,False{},
    [p195o_call("cid","p111_rt_tag",[p195o_arg("tree")]),
     p195o_bin("empty","eq",p195o_v("cid"),N111CtorId{"OEmpty"}),
     P113DIf{p195o_v("empty"),[P113DResult{[p195o_c(0),p195o_c(0)]}],
       [p195o_bin("leaf","eq",p195o_v("cid"),N111CtorId{"OLeaf"}),
        P113DIf{p195o_v("leaf"),
          [p195o_borrow("OLeaf",2),p195o_load("key",0),p195o_load("payload",8),
           p195o_bin("same","eq",p195o_v("key"),p195o_v("query")),
           P113DIf{p195o_v("same"),[P113DResult{[p195o_c(1),p195o_v("payload")]}],
             [P113DResult{[p195o_c(0),p195o_c(0)]}]}],
          [p195o_borrow("ONode",3),p195o_load("pivot",0),p195o_load("left",8),p195o_load("right",16),
           p195o_bin("less","ult",p195o_v("query"),p195o_v("pivot")),
           P113DIf{p195o_v("less"),[P113DAgain{[p195o_v("left"),p195o_v("query")]}],
             [P113DAgain{[p195o_v("right"),p195o_v("query")]}]}]}]}]}

# RFC/packed/immediate fields can be acquired without changing the parent word.
# A raw CTR field must use reconstruction, which installs the new RFC word back
# into its parent. Static raw constructors conservatively use that fallback too.
@unsafe
def p195o_fast(+depth: U32) -> P113DFunction:
  P113DFunction{p195o_candidate(depth),p195o_params(),4,False{},
    [P113DCall{["hit","payload"],"p195o_read",[p195o_v("tree"),p195o_v("query")]},
     p195o_bin("miss","eq",p195o_v("hit"),p195o_c(0)),
     P113DIf{p195o_v("miss"),[P113DResult{[p195o_v("tree"),p195o_c(0),p195o_c(0),p195o_c(1)]}],
       [p195o_bin("rfc","shr",p195o_v("payload"),p195o_c(63)),
        p195o_bin("tag","shr",p195o_v("payload"),p195o_c(56)),
        p195o_bin("tag","and",p195o_v("tag"),p195o_c(127)),
        p195o_bin("trivial","ule",p195o_v("tag"),p195o_c(1)),
        p195o_bin("shared","ne",p195o_v("rfc"),p195o_c(0)),
        p195o_s(N111Bin{"safe",N111U32{},"or",p195o_v("trivial"),p195o_v("shared")}),
        P113DIf{p195o_v("safe"),
          [p195o_call("payload","p111_rt_keep",[p195o_arg("payload")]),
           P113DResult{[p195o_v("tree"),p195o_c(1),p195o_v("payload"),p195o_c(1)]}],
          [P113DCall{["rebuilt","found","owned","route"],p195o_basename(depth),[p195o_v("tree"),p195o_v("query")]},
           P113DResult{[p195o_v("rebuilt"),p195o_v("found"),p195o_v("owned"),p195o_c(0)]}]}]}]}

@unsafe
def p195o_bases(+depth: U32) -> List<&2,P113DFunction>:
  nt_choose(List<&2,P113DFunction>,U32.is_gt(depth,8),u => [],u => Con{p195o_base(depth),p195o_bases(U32.inc(depth))})
@unsafe
def p195o_fasts(+depth: U32) -> List<&2,P113DFunction>:
  nt_choose(List<&2,P113DFunction>,U32.is_gt(depth,8),u => [],u => Con{p195o_fast(depth),p195o_fasts(U32.inc(depth))})
def p195o_functions() -> List<&2,P113DFunction>:
  nt_append(P113DFunction,p195o_bases(0),Con{p195o_read(),p195o_fasts(0)})

def p195o_constructors() -> List<&2,N_Constructor>:
  [N_Constructor{"OEmpty",0,True{}},N_Constructor{"OLeaf",2,False{}},N_Constructor{"ONode",3,False{}}]
# Numeric IDs begin at18 to agree with the independent public runtime descriptor.
@unsafe
def p195o_emit_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids(p195o_constructors(),18,missing())}
@unsafe
def p195o_verify_ids() -> N111Ids: N111Ids{missing(),ns_ctor_index(p195o_constructors(),missing())}
@unsafe
def p195o_validate() -> String:
  p118b_verify_projected(p195o_verify_ids(),p118b_project_functions(p195o_functions(),p195o_verify_ids()))
@unsafe
def p195o_outputs(functions: List<&2,P113DFunction>) -> X181Output:
  match functions:
    case Nil{}: X181Output{[],""}
    case Con{function,rest}: x181_program_join(x181_direct(function,p195o_emit_ids()),p195o_outputs(rest))
@unsafe
def p195o_emit() -> X181Output: p195o_outputs(p195o_functions())
def p195o_controls() -> List<&2,String>:
  ["original-ir-verified=" ++ nt_choose(String,String.is_empty(p195o_validate()),u => "1",u => "0")]
