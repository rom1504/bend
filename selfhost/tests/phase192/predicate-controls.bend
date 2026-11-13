def p192pc_v(name: String) -> N111Value: N111Local{name}
def p192pc_c(n: U32) -> N111Value: N111Const{n,0}
def p192pc_set(name: String, value: N111Value) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},value}}
def p192pc_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}
def p192pc_arm(value: N111Value) -> List<&2,P113DStmt>:
  [p192pc_set("c",value),p192pc_set("d",p192pc_v("c"))]
def p192pc_diamond(+invert: Bool) -> P113DStmt:
  P113DIf{p192pc_v("c"),p192pc_arm(p192pc_c(nt_choose(U32,invert,u => 0,u => 1))),
    p192pc_arm(p192pc_c(nt_choose(U32,invert,u => 1,u => 0)))}

@unsafe
def p192pc_rows(+mode: U32) -> List<&2,P113DStmt>:
  +test = p192pc_bin("c","ult",p192pc_v("a"),p192pc_v("b"))
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,0),u => [test,p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,1),u => [test,p192pc_diamond(True{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,2),u => [p192pc_set("c",p192pc_v("a")),p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,3),u => [test,p192pc_set("c",p192pc_v("a")),p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,4),u => [test,
    P113DScalar{N111Call{"ignored",N111U64{},"p192pc_barrier",[N111Arg{N111Ptr{},p192pc_v("state")}] }},p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,5),u => [test,
    P113DScalar{N111Load{"c",N111U64{},p192pc_v("state"),0}},p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,6),u => [test,
    P113DIf{p192pc_v("c"),[p192pc_set("c",p192pc_v("a"))],[p192pc_set("c",p192pc_v("b"))]},p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,7),u => [p192pc_set("c",p192pc_v("b")),
    P113DIf{p192pc_v("c"),p192pc_arm(p192pc_v("a")),p192pc_arm(p192pc_v("a"))}],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,8),u => [test,
    p192pc_bin("c","eq",p192pc_v("c"),p192pc_c(1)),p192pc_diamond(False{})],u =>
  nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,9),u => [test,
    p192pc_bin("c","eq",p192pc_v("c"),p192pc_c(0)),p192pc_diamond(False{})],u =>
    [test,p192pc_bin("c","xor",p192pc_v("c"),p192pc_c(1)),p192pc_diamond(False{})]))))))))))

law p192pc_ifs:
  for body: List<&2,P113DStmt>
  U32
@unsafe
def p192pc_ifs(body):
  match body:
    case Nil{}: 0
    case Con{P113DIf{condition,yes,no},rest}: U32.add(1,U32.add(p192pc_ifs(yes),U32.add(p192pc_ifs(no),p192pc_ifs(rest))))
    case Con{head,rest}: p192pc_ifs(rest)

@unsafe
def p192pc_shapes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,11),u => [],u =>
    Con{"predicate-mode-" ++ U32.show(mode) ++ "=" ++ nt_choose(String,
      U32.is_eq(p192pc_ifs(x192_predicate_body(p192pc_rows(mode))),
        nt_choose(U32,U32.is_eq(mode,6),v => 2,v => nt_choose(U32,U32.is_ge(mode,2) && U32.is_le(mode,5),w => 1,w => 0))),
      v => "1",v => "0"),p192pc_shapes(U32.inc(mode))})

@unsafe
def p192pc_controls() -> List<&2,String>: p192pc_shapes(0)

@unsafe
def p192pc_body(mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p192pc_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p192pc_v("state"),8}}],
    nt_append(P113DStmt,p192pc_rows(mode),[
      P113DScalar{N111Store{N111U64{},p192pc_v("state"),16,p192pc_v("c")}},
      P113DScalar{N111Store{N111U64{},p192pc_v("state"),24,p192pc_v("d")}},P113DResult{[p192pc_v("d")]}]))

# Bypass earlier preparation and run the candidate directly, then the existing
# local-value and dead-write passes. The C observer checks every written lane.
@unsafe
def p192pc_emit_mode(+mode: U32) -> X181Output:
  +symbol = "p192pc_" ++ U32.show(mode)
  +body = x185_dead_body([],x190_local_values_body([],x192_predicate_body(p192pc_body(mode))))
  x185_function_frame(symbol,[],body,N111Ids{missing(),missing()},x181_frame(symbol,["state"],body))

@unsafe
def p192pc_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,11),u => X181Output{[],""},u =>
    x181_program_join(p192pc_emit_mode(mode),p192pc_emit_modes(U32.inc(mode))))

def p192pc_emit() -> X181Output: p192pc_emit_modes(0)
