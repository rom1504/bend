def p192pf_v(name: String) -> N111Value: N111Local{name}
def p192pf_c(n: U32) -> N111Value: N111Const{n,0}
def p192pf_set(name: String, value: N111Value) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},value}}
def p192pf_bin(name: String, typ: N111Type, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,typ,op,left,right}}
def p192pf_ret(n: U32) -> P113DStmt: P113DResult{[p192pf_c(n)]}

@unsafe
def p192pf_tag(+prefix: String, source: String) -> List<&2,P113DStmt>:
  [p192pf_bin(prefix,N111U64{},"shr",p192pf_v(source),p192pf_c(40)),
   p192pf_bin(prefix,N111U64{},"and",p192pf_v(prefix),p192pf_c(65535)),
   p192pf_bin(prefix ++ "c",N111U64{},"eq",p192pf_v(prefix),p192pf_c(25))]

@unsafe
def p192pf_test_body(+mode: U32) -> List<&2,P113DStmt>:
  +change = nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,1),u => [p192pf_set("a",p192pf_v("b"))],u =>
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,2),v => [P113DScalar{N111Load{"a",N111U64{},p192pf_v("state"),8}}],v =>
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,3),w => [P113DScalar{N111Call{"ignored",N111U64{},"p192pf_barrier",[N111Arg{N111Ptr{},p192pf_v("state")}]}}],w =>
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,4),z => [P113DScalar{N111Store{N111U64{},p192pf_v("state"),0,p192pf_v("b")}}],z =>
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,5),q => [P113DScalar{N111Store{N111U64{},p192pf_v("state"),0,p192pf_v("b")}},P113DScalar{N111Load{"a",N111U64{},p192pf_v("state"),0}}],q =>
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,9),r => [p192pf_set("a",p192pf_v("b"))],r => []))))))
  +source = nt_choose(String,U32.is_eq(mode,9),u => "saved",u => "a")
  nt_append(P113DStmt,[p192pf_set("saved",p192pf_v("a"))],nt_append(P113DStmt,p192pf_tag("outer",source),[
    P113DIf{p192pf_v("outerc"),nt_append(P113DStmt,change,nt_append(P113DStmt,p192pf_tag("inner",source),[
      P113DIf{p192pf_v("innerc"),[p192pf_ret(1)],[p192pf_ret(2)]}])),[p192pf_ret(3)]}]))

@unsafe
def p192pf_bool(+prefix: String) -> List<&2,P113DStmt>:
  [p192pf_bin(prefix ++ "r",N111U64{},"eq",p192pf_v("a"),p192pf_c(1)),
   p192pf_bin(prefix ++ "s",N111U64{},"shr",p192pf_v("a"),p192pf_c(40)),
   p192pf_bin(prefix ++ "s",N111U64{},"and",p192pf_v(prefix ++ "s"),p192pf_c(8388607)),
   p192pf_bin(prefix ++ "t",N111U64{},"eq",p192pf_v(prefix ++ "s"),p192pf_c(65538)),
   p192pf_bin(prefix,N111U32{},"or",p192pf_v(prefix ++ "r"),p192pf_v(prefix ++ "t"))]

@unsafe
def p192pf_saturate(+n: U32, +rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(n,0),u => rest,u =>
    Con{p192pf_bin("unused",N111U64{},"add",p192pf_v("a"),p192pf_c(U32.add(n,100))),p192pf_saturate(U32.sub(n,1),rest)})

@unsafe
def p192pf_extra(+mode: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,11),u => [
    p192pf_bin("outer",N111U64{},"eq",p192pf_v("a"),N111Const{1,1}),
    P113DIf{p192pf_v("outer"),[P113DScalar{N111Set{"a",N111U32{},p192pf_v("a")}},
      p192pf_bin("inner",N111U64{},"eq",p192pf_v("a"),N111Const{1,1}),
      P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}],[p192pf_ret(3)]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,14),v => [P113DIf{p192pf_v("a"),[
    p192pf_bin("inner",N111U64{},"eq",p192pf_v("a"),p192pf_c(1)),
    P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}],[p192pf_ret(3)]}],v =>
    [p192pf_bin("x",N111U64{},"ult",p192pf_v("a"),p192pf_v("b")),
     p192pf_bin("y",N111U64{},"eq",p192pf_v("a"),p192pf_c(1)),
     p192pf_bin("z",N111U32{},nt_choose(String,U32.is_eq(mode,12) || U32.is_eq(mode,15),w => "and",w => "or"),p192pf_v("x"),p192pf_v("y")),
     P113DIf{p192pf_v("z"),nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,12) || U32.is_eq(mode,16),w => [
       p192pf_bin("inner",N111U64{},"ult",p192pf_v("a"),p192pf_v("b")),
       P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}],w => [p192pf_ret(3)]),
       nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,12) || U32.is_eq(mode,16),w => [p192pf_ret(3)],w => [
         p192pf_bin("inner",N111U64{},"ult",p192pf_v("a"),p192pf_v("b")),
         P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}])}]))

@unsafe
def p192pf_rows(+mode: U32) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_ge(mode,11),u => p192pf_extra(mode),u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,6),u => [
    p192pf_bin("outer",N111U32{},"eq",p192pf_v("a"),p192pf_c(1)),
    P113DIf{p192pf_v("outer"),[p192pf_bin("inner",N111U64{},"eq",p192pf_v("a"),p192pf_c(1)),
      P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}],[p192pf_ret(3)]}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,7),v => nt_append(P113DStmt,p192pf_bool("outer"),[
    p192pf_bin("outer",N111U32{},"xor",p192pf_v("outer"),p192pf_c(1)),
    P113DIf{p192pf_v("outer"),[p192pf_ret(3)],nt_append(P113DStmt,p192pf_bool("inner"),[
      P113DIf{p192pf_v("inner"),[p192pf_ret(1)],[p192pf_ret(2)]}])}]),v =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,8),w => [
    p192pf_bin("c",N111U64{},"ult",p192pf_v("a"),p192pf_v("b")),
    P113DIf{p192pf_v("c"),[p192pf_set("a",p192pf_v("b"))],[]},
    p192pf_bin("d",N111U64{},"ult",p192pf_v("a"),p192pf_v("b")),
    P113DIf{p192pf_v("d"),[p192pf_ret(1)],[p192pf_ret(2)]}],w =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,10),z => p192pf_saturate(100,p192pf_test_body(0)),z => p192pf_test_body(mode))))))

law p192pf_ifs:
  for body: List<&2,P113DStmt>
  U32
@unsafe
def p192pf_ifs(body):
  match body:
    case Nil{}: 0
    case Con{P113DIf{condition,yes,no},rest}: U32.add(1,U32.add(p192pf_ifs(yes),U32.add(p192pf_ifs(no),p192pf_ifs(rest))))
    case Con{head,rest}: p192pf_ifs(rest)

@unsafe
def p192pf_shapes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,17),u => [],u =>
    Con{"path-mode-" ++ U32.show(mode) ++ "=" ++ nt_choose(String,
      U32.is_eq(p192pf_ifs(x192_path_facts_body(p192pf_rows(mode))),
        nt_choose(U32,U32.is_eq(mode,0) || U32.is_eq(mode,4) || U32.is_eq(mode,7) || U32.is_eq(mode,9) || U32.is_eq(mode,12) || U32.is_eq(mode,13),v => 1,v => 2)),
      v => "1",v => "0"),p192pf_shapes(U32.inc(mode))})

def p192pf_controls() -> List<&2,String>: p192pf_shapes(0)

@unsafe
def p192pf_emit_mode(+mode: U32) -> X181Output:
  +symbol = "p192pf_" ++ U32.show(mode)
  +input = nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p192pf_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p192pf_v("state"),8}}],p192pf_rows(mode))
  +body = x185_dead_body([],x190_local_values_body([],x192_path_facts_body(input)))
  x185_function_frame(symbol,[],body,N111Ids{missing(),missing()},x181_frame(symbol,["state"],body))

@unsafe
def p192pf_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,17),u => X181Output{[],""},u =>
    x181_program_join(p192pf_emit_mode(mode),p192pf_emit_modes(U32.inc(mode))))

def p192pf_emit() -> X181Output: p192pf_emit_modes(0)
