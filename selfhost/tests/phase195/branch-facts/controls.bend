def p195bf_v(name: String) -> N111Value: N111Local{name}
def p195bf_c(n: U32) -> N111Value: N111Const{n,0}
def p195bf_set(name: String, typ: N111Type, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,typ,value}}
def p195bf_state(step: X190ValueStep) -> X190Values:
  match step:
    case X190ValueStep{stmt,state}: state

@unsafe
def p195bf_entry() -> X190Values:
  x190_v_alias("saved",p195bf_v("a"),X190Values{[],p111v_put(missing(),"a","X190Zero32",1,0)})

@unsafe
def p195bf_is(state: X190Values, name: String, wanted: String) -> Bool:
  match x190_v_value(p195bf_v(name),state):
    case N111Local{actual}: String.eq(actual,wanted)
    case _: False{}

def p195bf_row(name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")

@unsafe
def p195bf_controls() -> List<&2,String>:
  +s = p195bf_entry()
  +write = [p195bf_set("a",N111U64{},p195bf_v("b"))]
  +call = [P113DScalar{N111Call{"unused",N111U64{},"p195bf_external",[N111Arg{N111U64{},p195bf_v("a")}]}}]
  +nested = [P113DIf{p195bf_v("cond"),write,[]}]
  +narrow = p195bf_state(x190_v_set("saved",N111U32{},p195bf_v("a"),x190_v_empty()))
  +wide = p195bf_state(x190_v_set("saved",N111U32{},p195bf_v("a"),s))
  [p195bf_row("empty-preserves",p195bf_is(x195bf_join([],[],s),"saved","a")),
   p195bf_row("yes-source-kill",p195bf_is(x195bf_join(write,[],s),"saved","saved")),
   p195bf_row("no-source-kill",p195bf_is(x195bf_join([],write,s),"saved","saved")),
   p195bf_row("destination-kill",p195bf_is(x195bf_join([p195bf_set("saved",N111U64{},p195bf_v("b"))],[],s),"saved","saved")),
   p195bf_row("nested-source-kill",p195bf_is(x195bf_join(nested,[],s),"saved","saved")),
   p195bf_row("call-clears",p195bf_is(x195bf_join(call,[],s),"saved","saved")),
   p195bf_row("again-clears",p195bf_is(x195bf_join([P113DAgain{[p195bf_v("a")]}],[],s),"saved","saved")),
   p195bf_row("result-clears",p195bf_is(x195bf_join([P113DResult{[p195bf_v("a")]}],[],s),"saved","saved")),
   p195bf_row("store-preserves",p195bf_is(x195bf_join([P113DScalar{N111Store{N111U64{},p195bf_v("state"),0,p195bf_v("a")}}],[],s),"saved","a")),
   p195bf_row("width-killed",Bool.not(x190_v_zero(p195bf_v("a"),x195bf_join(write,[],s)))),
   p195bf_row("no-new-join-width",Bool.not(x190_v_zero(p195bf_v("b"),x195bf_join([p195bf_set("b",N111U32{},p195bf_c(1))],[p195bf_set("b",N111U32{},p195bf_c(2))],s)))),
   p195bf_row("narrow-snapshot",p195bf_is(narrow,"saved","saved")),
   p195bf_row("known-narrow-alias",p195bf_is(wide,"saved","a"))]

@unsafe
def p195bf_prefix(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 4: [p195bf_set("saved",N111U32{},p195bf_v("a"))]
    case 5: [p195bf_set("saved",N111U32{},p195bf_v("a")),p195bf_set("copy",N111U64{},p195bf_v("saved"))]
    case 6: [p195bf_set("saved",N111U64{},p195bf_v("a")),p195bf_set("copy",N111U64{},p195bf_v("saved"))]
    case _: [p195bf_set("saved",N111U64{},p195bf_v("a"))]

@unsafe
def p195bf_yes(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 0: [p195bf_set("inside",N111U64{},p195bf_v("saved"))]
    case 1: [p195bf_set("a",N111U64{},p195bf_v("b"))]
    case 3: [p195bf_set("saved",N111U64{},p195bf_v("b"))]
    case 4: [p195bf_set("a",N111U64{},p195bf_v("b"))]
    case 5: [p195bf_set("saved",N111U64{},p195bf_v("b"))]
    case 6: [P113DIf{p195bf_v("cond"),[p195bf_set("a",N111U64{},p195bf_v("b"))],[]}]
    case 7: [p195bf_set("fresh",N111U32{},p195bf_v("b"))]
    case 8: [P113DScalar{N111Call{"a",N111U64{},"p195bf_external",[N111Arg{N111U64{},p195bf_v("a")}]}}]
    case 9: [P113DScalar{N111Load{"a",N111U64{},p195bf_v("state"),8}}]
    case _: []

@unsafe
def p195bf_no(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 0: [p195bf_set("inside",N111U64{},p195bf_v("saved"))]
    case 2: [p195bf_set("a",N111U64{},p195bf_v("b"))]
    case 7: [p195bf_set("fresh",N111U64{},p195bf_v("a"))]
    case _: []

@unsafe
def p195bf_result(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 0: [p195bf_set("a",N111U64{},p195bf_v("b")),p195bf_set("result",N111U64{},p195bf_v("inside"))]
    case 5: [P113DScalar{N111Bin{"result",N111U64{},"add",p195bf_v("copy"),p195bf_v("saved")}}]
    case 6: [P113DScalar{N111Bin{"result",N111U64{},"add",p195bf_v("copy"),p195bf_v("saved")}}]
    case 7: [P113DScalar{N111Bin{"result",N111U64{},"add",p195bf_v("fresh"),p195bf_v("saved")}}]
    case _: [P113DScalar{N111Bin{"result",N111U64{},"add",p195bf_v("saved"),p195bf_v("a")}}]

@unsafe
def p195bf_body(+mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p195bf_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p195bf_v("state"),8}},
    P113DScalar{N111Load{"cond",N111U64{},p195bf_v("state"),16}}],
    nt_append(P113DStmt,p195bf_prefix(mode),nt_append(P113DStmt,[P113DIf{p195bf_v("cond"),p195bf_yes(mode),p195bf_no(mode)}],
      nt_append(P113DStmt,p195bf_result(mode),[
        P113DScalar{N111Store{N111U64{},p195bf_v("state"),24,p195bf_v("saved")}},
        P113DScalar{N111Store{N111U64{},p195bf_v("state"),32,p195bf_v("a")}},
        P113DScalar{N111Store{N111U64{},p195bf_v("state"),40,p195bf_v("result")}},P113DResult{[p195bf_v("result")]}]))))

@unsafe
def p195bf_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,10),u => X181Output{[],""},u =>
    x181_program_join(x191_ordinary("p195bf_" ++ U32.show(mode),["state"],[],p195bf_body(mode),N111Ids{missing(),missing()}),
      p195bf_emit_at(U32.inc(mode))))

def p195bf_emit() -> X181Output: p195bf_emit_at(0)
