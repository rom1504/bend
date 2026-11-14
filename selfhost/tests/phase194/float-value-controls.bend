def p194fvc_v(name: String) -> N111Value: N111Local{name}
def p194fvc_c(lo: U32) -> N111Value: N111Const{lo,0}
def p194fvc_f(name: String, id: U32, a: N111Value, b: N111Value) -> X186FloatNode:
  X186FloatValues{name,id,a,b}
def p194fvc_copy(name: String, value: N111Value) -> X186FloatNode:
  X186FloatPlain{P113DScalar{N111Set{name,N111U64{},value}}}
def p194fvc_end() -> X186FloatNode:
  X186FloatPlain{P113DResult{[p194fvc_v("value")]}}

# Modes 0..3 are closed overwrite/copy chains. Others exercise hard cuts,
# noncanonical publications, input-name collision and branch-local identities.
@unsafe
def p194fvc_rows(+mode: U32) -> List<&2,X186FloatNode>:
  +first = p194fvc_f("value",28,p194fvc_v("a"),p194fvc_v("b"))
  +last = p194fvc_f("value",27,p194fvc_v("value"),p194fvc_v("a"))
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,0),u => [first,last],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,1),u => [first,p194fvc_copy("saved",p194fvc_v("value")),last,
    p194fvc_f("value",26,p194fvc_v("value"),p194fvc_v("saved"))],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,2),u => [first,p194fvc_copy("saved",p194fvc_v("value")),
    p194fvc_copy("value",p194fvc_v("b"))],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,3),u => [first,
    p194fvc_f("value",58,p194fvc_v("value"),p194fvc_v("value"))],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,4),u => [first,
    X186FloatPlain{P113DScalar{N111Set{"value",N111U32{},p194fvc_v("b")}}}],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,5),u => [first,
    X186FloatPlain{P113DScalar{N111Call{"ignored",N111U64{},"p194fvc_barrier",[
      N111Arg{N111Ptr{},p194fvc_v("state")},N111Arg{N111U64{},p194fvc_v("value")}]}}},last],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,6),u => [first,
    X186FloatPlain{P113DScalar{N111Store{N111U64{},p194fvc_v("state"),16,p194fvc_v("value")}}},last],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,7),u => [first,
    X186FloatBranch{p194fvc_v("condition"),[last,last],[last,last]}],u =>
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(mode,8),u => [first,
    p194fvc_copy("p194fv_collision",p194fvc_v("value")),last],u => [first])))))))))

law p194fvc_count:
  for nodes: List<&2,X186FloatNode>
  U32
@unsafe
def p194fvc_count(nodes):
  match nodes:
    case Nil{}: 0
    case Con{X186FloatValues{name,id,left,right},rest}:
      U32.add(nt_choose(U32,String.starts_with(name,"p194fv_"),u => 1,u => 0),p194fvc_count(rest))
    case Con{X186FloatBranch{condition,yes,no},rest}:
      U32.add(p194fvc_count(yes),U32.add(p194fvc_count(no),p194fvc_count(rest)))
    case Con{head,rest}: p194fvc_count(rest)

@unsafe
def p194fvc_shapes(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(mode,10),u => [],u =>
    Con{"float-value-mode-" ++ U32.show(mode) ++ "=" ++ nt_choose(String,
      U32.is_eq(p194fvc_count(x194fv_nodes(["state","a","b","condition"],[],p194fvc_rows(mode))),
        nt_choose(U32,U32.is_eq(mode,1) || U32.is_eq(mode,7),v => 2,v =>
          nt_choose(U32,U32.is_lt(mode,4),w => 1,w => 0))),v => "1",v => "0"),p194fvc_shapes(U32.inc(mode))})

def p194fvc_controls() -> List<&2,String>: nt_append(String,p194fvc_shapes(0),p194fvc_extra())

@unsafe
def p194fvc_emit_one(+mode: U32, +candidate: Bool) -> X181Output:
  +nodes = nt_append(X186FloatNode,[p194fvc_copy("saved",p194fvc_c(0))],
    nt_append(X186FloatNode,p194fvc_rows(mode),[
      X186FloatPlain{P113DScalar{N111Store{N111U64{},p194fvc_v("state"),0,p194fvc_v("value")}}},
      X186FloatPlain{P113DScalar{N111Store{N111U64{},p194fvc_v("state"),8,p194fvc_v("saved")}}},p194fvc_end()]))
  x186_f_place("p194fvc_" ++ nt_choose(String,candidate,u => "new_",u => "old_") ++ U32.show(mode),
    ["state","a","b","condition"],[],nt_choose(List<&2,X186FloatNode>,candidate,
      u => x194fv_nodes(["state","a","b","condition"],[],nodes),u => nodes),N111Ids{missing(),missing()})

@unsafe
def p194fvc_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(mode,10),u => X181Output{[],""},u =>
    x181_program_join(p194fvc_emit_one(mode,False{}),x181_program_join(p194fvc_emit_one(mode,True{}),p194fvc_emit_modes(U32.inc(mode)))))

def p194fvc_emit() -> X181Output: p194fvc_emit_modes(0)


def p194fvc_row(label: String, ok: Bool) -> String:
  label ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

@unsafe
def p194fvc_padding(+count: U32) -> List<&2,X186FloatNode>:
  nt_choose(List<&2,X186FloatNode>,U32.is_eq(count,0),u => [p194fvc_f("value",26,p194fvc_v("a"),p194fvc_v("b"))],u =>
    Con{p194fvc_copy("other",p194fvc_v("a")),p194fvc_padding(U32.sub(count,1))})

# Inspect operand-before-rebind and final original-name publication directly.
def p194fvc_pair(nodes: List<&2,X186FloatNode>) -> Bool:
  match nodes:
    case Con{X186FloatValues{first,28,N111Local{a},N111Local{b}},
      Con{X186FloatValues{last,27,N111Local{read},N111Local{subtract}},Nil{}}}:
      String.eq(first,"p194fv_0") && String.eq(last,"value") && String.eq(read,"p194fv_0") &&
      String.eq(a,"a") && String.eq(b,"b") && String.eq(subtract,"a")
    case _: False{}

@unsafe
def p194fvc_extra() -> List<&2,String>:
  +last = p194fvc_f("value",26,p194fvc_v("a"),p194fvc_v("b"))
  [p194fvc_row("float-value-operand-order",p194fvc_pair(x194fv_nodes([],[],p194fvc_rows(0)))),
   p194fvc_row("float-value-off",U32.is_eq(p194fvc_count(x194fv_when(False{},[],[],p194fvc_rows(0))),0)),
   p194fvc_row("float-value-param-collision",U32.is_eq(p194fvc_count(x194fv_nodes(["p194fv_0"],[],p194fvc_rows(0))),0)),
   p194fvc_row("float-value-setup-collision",U32.is_eq(p194fvc_count(x194fv_nodes([],
     [P113DScalar{N111Set{"p194fv_0",N111U64{},p194fvc_c(0)}}],p194fvc_rows(0))),0)),
   p194fvc_row("float-value-again-cut",Bool.not(x194fv_closed([
     X186FloatPlain{P113DAgain{[p194fvc_v("value")]}},last],"value",32))),
   p194fvc_row("float-value-return-cut",Bool.not(x194fv_closed([
     X186FloatPlain{P113DScalar{N111Return{p194fvc_v("value")}}},last],"value",32))),
   p194fvc_row("float-value-load-cut",Bool.not(x194fv_closed([
     X186FloatPlain{P113DScalar{N111Load{"other",N111U64{},p194fvc_v("state"),0}}},last],"value",32))),
   p194fvc_row("float-value-bound-refusal",Bool.not(x194fv_closed(p194fvc_padding(32),"value",32))),
   p194fvc_row("float-value-bound-admission",x194fv_closed(p194fvc_padding(31),"value",32)),
   p194fvc_row("float-value-xmm-home",String.eq(dk(p111v_get(x186_x_homes([],[],
     x194fv_nodes([],[],p194fvc_rows(0))),"p194fv_0")),"X186Xmm"))]
