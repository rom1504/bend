# Independent Phase191 profitability controls. Append to the checked API source;
# p191lp_controls returns named assertions, each expected to end in '=1'.
# p191lp_assembly exports a pressure loop for an independent execution driver.
def p191lp_v(name: String) -> N111Value: N111Local{name}
def p191lp_c(n: U32) -> N111Value: N111Const{n,0}
def p191lp_bin(name: String, op: String, a: N111Value, b: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,a,b}}

@unsafe
def p191lp_count(name: String, reads: X181ReadCounts) -> U32:
  match reads:
    case X181ReadCounts{counts,names}: da(p111v_get(counts,name))

@unsafe
def p191lp_hot(name: String, summary: X191LoopReads) -> U32:
  match summary:
    case X191LoopReads{reads,reaches,falls}: p191lp_count(name,reads)

@unsafe
def p191lp_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

def p191lp_params() -> List<&2,String>:
  ["state","n","acc","h0","h1","h2","h3","base","mask","salt"]

def p191lp_tail() -> List<&2,String>:
  ["n","acc","h0","h1","h2","h3","base","mask","salt"]

# Nine persistent values compete with short arithmetic/address-shaped values.
# Four handles are only consumed on exit and forwarded identically on Again.
# Return is acc+h0+h1+h2+h3; each iteration adds (((n+base)&mask)*8)+salt.
def p191lp_body() -> List<&2,P113DStmt>:
  [p191lp_bin("done","eq",p191lp_v("n"),p191lp_c(0)),
   P113DIf{p191lp_v("done"),
     [p191lp_bin("e0","add",p191lp_v("h0"),p191lp_v("h1")),
      p191lp_bin("e1","add",p191lp_v("h2"),p191lp_v("h3")),
      p191lp_bin("e2","add",p191lp_v("e0"),p191lp_v("e1")),
      p191lp_bin("answer","add",p191lp_v("acc"),p191lp_v("e2")),
      P113DScalar{N111Return{p191lp_v("answer")}}],
     [p191lp_bin("index","add",p191lp_v("n"),p191lp_v("base")),
      p191lp_bin("bounded","and",p191lp_v("index"),p191lp_v("mask")),
      p191lp_bin("scaled","mul",p191lp_v("bounded"),p191lp_c(8)),
      p191lp_bin("address","add",p191lp_v("scaled"),p191lp_v("salt")),
      p191lp_bin("next_acc","add",p191lp_v("acc"),p191lp_v("address")),
      p191lp_bin("next_n","sub",p191lp_v("n"),p191lp_c(1)),
      P113DAgain{[p191lp_v("next_n"),p191lp_v("next_acc"),p191lp_v("h0"),p191lp_v("h1"),
        p191lp_v("h2"),p191lp_v("h3"),p191lp_v("base"),p191lp_v("mask"),p191lp_v("salt")]}]}]

# One arm exits through a scalar conditional; its foreign call must remain in
# emitted code, but its argument must receive no repeated-use profitability.
def p191lp_mixed() -> List<&2,P113DStmt>:
  [P113DIf{p191lp_v("pick"),
    [P113DScalar{N111If{p191lp_v("exit_pick"),
      [N111Call{"x",N111U64{},"p191lp_effect",[N111Arg{N111U64{},p191lp_v("cold")} ]},N111Return{p191lp_v("x")}],
      [N111Return{p191lp_v("other")} ]}}],
    [P113DScalar{N111Call{"hot_call",N111U64{},"p191lp_effect",[N111Arg{N111U64{},p191lp_v("hot")}]}},
     P113DAgain{[p191lp_v("hot_call"),p191lp_v("carry")]}]}]

# Both arms fall into one shared Again. The continuation read counts once.
def p191lp_join() -> List<&2,P113DStmt>:
  [P113DIf{p191lp_v("pick"),
    [p191lp_bin("next","add",p191lp_v("left"),p191lp_c(1))],
    [p191lp_bin("next","add",p191lp_v("right"),p191lp_c(2))]},
   P113DAgain{[p191lp_v("next")]}]

@unsafe
def p191lp_counts() -> X181ReadCounts:
  x191_loop_counted(x181_reads_stmts(p191lp_body(),X181ReadCounts{missing(),[]}),
    x191_loop_reads(p191lp_body(),p191lp_tail(),False{}))

@unsafe
def p191lp_frame() -> X181Frame:
  x190_j_counted(x181_frame("p191lp_pressure",p191lp_params(),p191lp_body()),
    p191lp_params(),[],p191lp_body(),p191lp_body(),p191lp_counts())

@unsafe
def p191lp_slot(name: String, frame: X181Frame) -> KDef:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: p111v_get(slots,name)

@unsafe
def p191lp_controls() -> List<&2,String>:
  +pressure = p191lp_counts()
  +mixed = x191_loop_reads(p191lp_mixed(),["n","carry"],False{})
  +joined = x191_loop_reads(p191lp_join(),["n"],False{})
  +dead = x191_loop_reads([P113DResult{[p191lp_v("exit")]},
    p191lp_bin("dead","add",p191lp_v("unreachable"),p191lp_c(1)),P113DAgain{[p191lp_v("dead")]}],["n"],False{})
  +home = p191lp_slot("index",p191lp_frame())
  [p191lp_row("exit-handle-score-two",U32.is_eq(p191lp_count("h0",pressure),2)),
   p191lp_row("repeated-temporary-score-eight",U32.is_eq(p191lp_count("index",pressure),8)),
   p191lp_row("changed-backedge-score-eight",U32.is_eq(p191lp_count("next_acc",pressure),8)),
   p191lp_row("hot-temporary-register",Bool.not(String.eq(dk(home),"X181Stack"))),
   p191lp_row("exit-call-no-bonus",U32.is_eq(p191lp_hot("cold",mixed),0)),
   p191lp_row("nested-exit-condition-no-bonus",U32.is_eq(p191lp_hot("exit_pick",mixed),0)),
   p191lp_row("continuing-call-bonus",U32.is_eq(p191lp_hot("hot",mixed),1)),
   p191lp_row("identity-again-no-bonus",U32.is_eq(p191lp_hot("carry",mixed),0)),
   p191lp_row("joining-left-bonus",U32.is_eq(p191lp_hot("left",joined),1)),
   p191lp_row("joining-right-bonus",U32.is_eq(p191lp_hot("right",joined),1)),
   p191lp_row("continuation-counted-once",U32.is_eq(p191lp_hot("next",joined),1)),
   p191lp_row("unreachable-no-bonus",U32.is_eq(p191lp_hot("unreachable",dead),0)),
   p191lp_row("unchanged-call-crossing-validator",Bool.not(x190_j_valid(["a"],[1],[],1,[0,0,0,0,1,0,0,0,0])))]

@unsafe
def p191lp_emit() -> X181Output:
  x185_function_frame("p191lp_pressure",[],p191lp_body(),N111Ids{missing(),missing()},p191lp_frame())

@unsafe
def p191lp_assembly_result(result: X181Output) -> List<&2,String>:
  match result:
    case X181Output{chunks,+error}:
      [nt_choose(String,String.is_empty(error),u => x188_render(x188_many(chunks)),u => ".error \"" ++ error ++ "\"\n")]

@unsafe
def p191lp_assembly() -> List<&2,String>:
  p191lp_assembly_result(p191lp_emit())
