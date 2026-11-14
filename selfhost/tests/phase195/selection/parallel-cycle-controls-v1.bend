def p195cy_v(name: String) -> N111Value: N111Local{name}
def p195cy_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

def p195cy_values(mode: U32) -> List<&2,N111Value>:
  match mode:
    case 0: [p195cy_v("b"),p195cy_v("a"),p195cy_v("c"),p195cy_v("d"),p195cy_v("e"),p195cy_v("f")]
    case 1: [p195cy_v("b"),p195cy_v("c"),p195cy_v("a"),p195cy_v("d"),p195cy_v("e"),p195cy_v("f")]
    case 2: [p195cy_v("b"),p195cy_v("a"),p195cy_v("d"),p195cy_v("c"),p195cy_v("e"),p195cy_v("f")]
    case 3: [p195cy_v("b"),p195cy_v("a"),p195cy_v("a"),p195cy_v("c"),N111Const{2309737967,4275878552},p195cy_v("f")]
    case 4: [p195cy_v("c"),p195cy_v("b"),p195cy_v("a"),p195cy_v("d"),p195cy_v("f"),p195cy_v("e")]
    case 5: [p195cy_v("a"),p195cy_v("b"),p195cy_v("c"),p195cy_v("d"),p195cy_v("e"),p195cy_v("f")]
    case 6: [p195cy_v("bb"),p195cy_v("aa"),p195cy_v("c"),p195cy_v("d"),p195cy_v("e"),p195cy_v("f")]
    case _: [p195cy_v("b"),p195cy_v("a"),p195cy_v("c"),p195cy_v("d"),p195cy_v("f"),p195cy_v("e")]

def p195cy_prefix(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 5: [P113DScalar{N111Set{"a",N111U32{},p195cy_v("a")}}]
    case 6: [P113DScalar{N111Set{"aa",N111U64{},p195cy_v("a")}},P113DScalar{N111Set{"bb",N111U64{},p195cy_v("b")}}]
    case 7: [P113DScalar{N111Set{"d",N111U32{},p195cy_v("d")}}]
    case _: []

@unsafe
def p195cy_body(+mode: U32) -> List<&2,P113DStmt>:
  [p195cy_bin("done","eq",p195cy_v("n"),N111Const{0,0}),
    P113DIf{p195cy_v("done"),[P113DResult{[p195cy_v("a"),p195cy_v("b"),p195cy_v("c"),p195cy_v("d"),p195cy_v("e"),p195cy_v("f")]}],
      nt_append(P113DStmt,p195cy_prefix(mode),[p195cy_bin("next","sub",p195cy_v("n"),N111Const{1,0}),
        P113DAgain{Con{p195cy_v("next"),p195cy_values(mode)}}])}]

@unsafe
def p195cy_install(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(slots,
        "a","X181Register",1,8),"b","X181Register",2,8),"aa","X181Register",1,8),"bb","X181Register",2,8),
        "e","X185Transient",3,8),"f","X185Transient",4,8),bytes,calls,params,symbol}

@unsafe
def p195cy_frame(+name: String, +mode: U32) -> X181Frame:
  p195cy_install(x181_frame(name,["state","__x181_result_out","n","a","b","c","d","e","f"],p195cy_body(mode)))

@unsafe
def p195cy_plan(mode: U32) -> Maybe<&2,X188Seq>:
  x186_parallel(["a","b","c","d","e","f"],p195cy_values(mode),N111Ids{missing(),missing()},p195cy_frame("probe",0))

def p195cy_present(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case Some{text}: True{}
    case None{}: False{}

def p195cy_empty(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case Some{text}: x188_empty(text)
    case None{}: False{}

@unsafe
def p195cy_row(name: String, yes: Bool) -> String:
  name ++ "=" ++ nt_choose(String,yes,u => "1",u => "0")

@unsafe
def p195cy_rows(+n: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(n,8),u => [],u =>
    Con{p195cy_row("plan-" ++ U32.show(n),p195cy_present(p195cy_plan(n))),p195cy_rows(U32.inc(n))})

@unsafe
def p195cy_bad_bank(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(slots,"__x181_tail","X181Buffer",8,8),bytes,calls,params,symbol}

@unsafe
def p195cy_duplicate(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(slots,"b","X181Register",1,8),bytes,calls,params,symbol}

@unsafe
def p195cy_controls() -> List<&2,String>:
  nt_append(String,p195cy_rows(0),[
    p195cy_row("self-empty",p195cy_empty(p195cy_plan(5))),
    p195cy_row("short-bank-refused",Bool.not(p195cy_present(x186_parallel(["a","b"],[p195cy_v("b"),p195cy_v("a")],
      N111Ids{missing(),missing()},p195cy_bad_bank(p195cy_frame("probe",0)))))),
    p195cy_row("duplicate-home-refused",Bool.not(p195cy_present(x186_parallel(["a","b"],[p195cy_v("b"),p195cy_v("a")],
      N111Ids{missing(),missing()},p195cy_duplicate(p195cy_frame("probe",0)))))),
    p195cy_row("buffer-source-refused",Bool.not(p195cy_present(x186_parallel(["a"],[p195cy_v("scratch")],
      N111Ids{missing(),missing()},p195cy_frame("probe",0))))),
    p195cy_row("state-destination-refused",Bool.not(p195cy_present(x186_parallel(["state"],[p195cy_v("a")],
      N111Ids{missing(),missing()},p195cy_frame("probe",0))))),
    p195cy_row("mismatched-vector-refused",Bool.not(p195cy_present(x186_parallel(["a","b"],[p195cy_v("b")],
      N111Ids{missing(),missing()},p195cy_frame("probe",0)))))])

@unsafe
def p195cy_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,8),u => X181Output{[],""},u =>
    x181_program_join(x185_function_frame("p195cy_" ++ U32.show(mode),[],p195cy_body(mode),N111Ids{missing(),missing()},
      p195cy_frame("p195cy_" ++ U32.show(mode),mode)),p195cy_emit_at(U32.inc(mode))))

def p195cy_emit() -> X181Output: p195cy_emit_at(0)
