# Independent call-fact controls: opaque mutating C helper and typed multi-result callee.
def p195cf_v(name: String) -> N111Value: N111Local{name}
def p195cf_c(n: U32) -> N111Value: N111Const{n,0}
def p195cf_set(name: String, typ: N111Type, value: N111Value) -> P113DStmt:
  P113DScalar{N111Set{name,typ,value}}
def p195cf_state(step: X190ValueStep) -> X190Values:
  match step:
    case X190ValueStep{stmt,state}: state

@unsafe
def p195cf_seed() -> X190Values:
  x190_v_alias("copy",p195cf_v("a"),x190_v_alias("saved",p195cf_v("a"),
    X190Values{[],p111v_put(p111v_put(missing(),"a","X190Zero32",1,0),"b","X190Zero32",1,0)}))

@unsafe
def p195cf_is_value(value: N111Value, wanted: String) -> Bool:
  match value:
    case N111Local{actual}: String.eq(actual,wanted)
    case _: False{}

@unsafe
def p195cf_is(state: X190Values, name: String, wanted: String) -> Bool:
  p195cf_is_value(x190_v_value(p195cf_v(name),state),wanted)

@unsafe
def p195cf_step(name: String, state: X190Values) -> X190ValueStep:
  x195cf_scalar(N111Call{name,N111U32{},"p195cf_mutate",[N111Arg{N111U64{},p195cf_v("saved")}]},state)

@unsafe
def p195cf_argument(step: X190ValueStep) -> Bool:
  match step:
    case X190ValueStep{P113DScalar{N111Call{name,typ,symbol,Con{N111Arg{atyp,N111Local{actual}},Nil{}}}},state}: String.eq(actual,"a")
    case _: False{}

def p195cf_row(name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")

@unsafe
def p195cf_controls() -> List<&2,String>:
  +s: X190Values = p195cf_seed()
  [p195cf_row("scalar-unrelated-alias",p195cf_is(p195cf_state(p195cf_step("out",s)),"saved","a")),
   p195cf_row("scalar-unrelated-width",x190_v_zero(p195cf_v("a"),p195cf_state(p195cf_step("out",s)))),
   p195cf_row("scalar-source-kill",p195cf_is(p195cf_state(p195cf_step("a",s)),"saved","saved")),
   p195cf_row("scalar-destination-kill",p195cf_is(p195cf_state(p195cf_step("saved",s)),"saved","saved")),
   p195cf_row("scalar-result-width-unknown",Bool.not(x190_v_zero(p195cf_v("a"),p195cf_state(p195cf_step("a",s))))),
   p195cf_row("scalar-other-width-kept",x190_v_zero(p195cf_v("b"),p195cf_state(p195cf_step("a",s)))),
   p195cf_row("scalar-argument-before-result",p195cf_argument(p195cf_step("a",s))),
   p195cf_row("multi-source-kill",p195cf_is(x195cf_after_call(["a","other"],s),"saved","saved")),
   p195cf_row("multi-destination-kill",p195cf_is(x195cf_after_call(["saved","other"],s),"saved","saved")),
   p195cf_row("multi-other-alias-kept",p195cf_is(x195cf_after_call(["out","other"],s),"saved","a")),
   p195cf_row("multi-result-width-unknown",Bool.not(x190_v_zero(p195cf_v("b"),x195cf_after_call(["a","b"],s)))),
   p195cf_row("intermediate-kill-keeps-flattened-copy",p195cf_is(x195cf_after_call(["saved"],s),"copy","a"))]

@unsafe
def p195cf_prefix(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 4: [p195cf_set("saved",N111U32{},p195cf_v("a"))]
    case _: [p195cf_set("saved",N111U64{},p195cf_v("a"))]

@unsafe
def p195cf_mutation(name: String) -> P113DStmt:
  P113DScalar{N111Call{name,N111U64{},"p195cf_mutate",[
    N111Arg{N111Ptr{},p195cf_v("ptr")},N111Arg{N111U64{},p195cf_v("saved")},N111Arg{N111U64{},p195cf_v("nar")}]}}

@unsafe
def p195cf_call(mode: U32) -> P113DStmt:
  match mode:
    case 1: p195cf_mutation("a")
    case 2: p195cf_mutation("saved")
    case 3: p195cf_mutation("nar")
    case 5: P113DIf{p195cf_v("cond"),[p195cf_mutation("out")],[]}
    case 6: P113DCall{["a","nar"],"p195cf_pair",[p195cf_v("saved"),p195cf_v("nar")]}
    case 7: P113DCall{["saved","nar"],"p195cf_pair",[p195cf_v("saved"),p195cf_v("nar")]}
    case 8: P113DCall{["out","other"],"p195cf_pair",[p195cf_v("saved"),p195cf_v("nar")]}
    case _: p195cf_mutation("out")

@unsafe
def p195cf_tail() -> List<&2,P113DStmt>:
  [p195cf_set("after",N111U32{},p195cf_v("nar")),
   P113DScalar{N111Load{"fresh",N111U64{},p195cf_v("ptr"),0}},
   P113DScalar{N111Bin{"sum1",N111U64{},"add",p195cf_v("after"),p195cf_v("saved")}},
   P113DScalar{N111Bin{"sum2",N111U64{},"add",p195cf_v("sum1"),p195cf_v("copy")}},
   P113DScalar{N111Bin{"sum3",N111U64{},"add",p195cf_v("sum2"),p195cf_v("a")}},
   P113DScalar{N111Bin{"sum4",N111U64{},"add",p195cf_v("sum3"),p195cf_v("narcopy")}},
   P113DScalar{N111Bin{"sum5",N111U64{},"add",p195cf_v("sum4"),p195cf_v("fresh")}},
   P113DScalar{N111Bin{"sum6",N111U64{},"add",p195cf_v("sum5"),p195cf_v("out")}},
   P113DScalar{N111Bin{"result",N111U64{},"add",p195cf_v("sum6"),p195cf_v("other")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),24,p195cf_v("saved")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),32,p195cf_v("copy")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),40,p195cf_v("a")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),48,p195cf_v("nar")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),56,p195cf_v("after")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),64,p195cf_v("fresh")}},
   P113DScalar{N111Store{N111U64{},p195cf_v("state"),72,p195cf_v("result")}},
   P113DResult{[p195cf_v("result")]}]

@unsafe
def p195cf_body(+mode: U32) -> List<&2,P113DStmt>:
  nt_append(P113DStmt,[P113DScalar{N111Load{"a",N111U64{},p195cf_v("state"),0}},
    P113DScalar{N111Load{"b",N111U64{},p195cf_v("state"),8}},
    P113DScalar{N111Load{"cond",N111U64{},p195cf_v("state"),16}},
    p195cf_set("ptr",N111Ptr{},p195cf_v("state")),
    p195cf_set("nar",N111U32{},p195cf_v("b")),
    p195cf_set("narcopy",N111U32{},p195cf_v("nar")),
    p195cf_set("out",N111U64{},p195cf_c(0)),p195cf_set("other",N111U64{},p195cf_c(0))],
    nt_append(P113DStmt,p195cf_prefix(mode),
      nt_append(P113DStmt,[p195cf_set("copy",N111U64{},p195cf_v("saved")),p195cf_call(mode)],p195cf_tail())))

@unsafe
def p195cf_pair_body() -> List<&2,P113DStmt>:
  [P113DScalar{N111Call{"first",N111U64{},"p195cf_mutate",[
    N111Arg{N111Ptr{},p195cf_v("state")},N111Arg{N111U64{},p195cf_v("x")},N111Arg{N111U64{},p195cf_v("y")}]}}
   ,P113DScalar{N111Bin{"second",N111U64{},"xor",p195cf_v("first"),N111Const{16909060,4275878552}}}
   ,P113DResult{[p195cf_v("first"),p195cf_v("second")]}]

@unsafe
def p195cf_emit_at(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,9),u => X181Output{[],""},u =>
    x181_program_join(x185_function_setup("p195cf_" ++ U32.show(mode),["state"],[],p195cf_body(mode),N111Ids{missing(),missing()}),
      p195cf_emit_at(U32.inc(mode))))

@unsafe
def p195cf_emit() -> X181Output:
  x181_program_join(x185_function_setup(p113e_symbol("p195cf_pair"),["state","__x181_result_out","x","y"],[],
    p195cf_pair_body(),N111Ids{missing(),missing()}),p195cf_emit_at(0))
