# Analysis-only calls, including invalid shapes, are never executed as targets.
@unsafe
def p126ntc_call(+symbol: String, +kind: U32, +kindhi: U32, +count: U32, +counthi: U32, +state: String, +buffer: String, +dest: String, +term: N111Value) -> N111Stmt:
  N111Call{dest,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},N111Const{kind,kindhi}},p111_word(term),
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{count,counthi}}]}

@unsafe
def p126ntc_valid(+term: N111Value, +dest: String, +buffer: String) -> N111Stmt:
  p126ntc_call("p111_rt_special_take",4,0,1,0,"state",buffer,dest,term)

@unsafe
def p126ntc_changed(value: P114TExpansion) -> Bool:
  match value:
    case P114TExpansion{body,changed}: changed

@unsafe
def p126ntc_order(value: P114TExpansion, +lo: U32, +hi: U32) -> Bool:
  match value:
    case P114TExpansion{Con{N111Bin{temp,N111U64{},op,N111Const{a,b},N111Const{1,0}},
      Con{N111Store{N111U64{},N111Local{buffer},0,N111Local{read}},
      Con{N111Set{dest,N111U64{},N111Const{1,0}},Nil{}}}},True{}}:
        String.eq(temp,"p114t_7_nat_pred") && String.eq(read,temp) && String.eq(op,"sub") &&
          String.eq(buffer,"scratch") && String.eq(dest,"answer") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def p126ntc_word(+lo: U32, +hi: U32) -> Bool:
  p126ntc_order(p126nt_expand(p126ntc_valid(N111Const{lo,hi},"answer","scratch"),7),lo,hi)

@unsafe
def p126ntc_refused(+stmt: N111Stmt) -> Bool:
  Bool.not(p126ntc_changed(p126nt_expand(stmt,7)))

@unsafe
def p126ntc_row(+name: String, +result: Bool) -> String:
  nt_choose(String,result,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p126nt_controls() -> List<&2,String>:
  [p126ntc_row("one-full-word",p126ntc_word(1,0)),
   p126ntc_row("2pow32",p126ntc_word(0,1)),
   p126ntc_row("2pow40",p126ntc_word(0,256)),
   p126ntc_row("2pow48-minus1",p126ntc_word(4294967295,65535)),
   p126ntc_row("analysis-only-u64-max",p126ntc_word(4294967295,4294967295)),
   p126ntc_row("destination-alias-input",p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"answer"},"answer","scratch"),7))),
   p126ntc_row("renamed-continuation-buffer",p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"n"},"ignored","p114h_case_0_local_scratch"),7))),
   p126ntc_row("wrong-symbol",p126ntc_refused(p126ntc_call("p111_rt_take",4,0,1,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("zero-case-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",3,0,0,0,"state","scratch","answer",N111Const{0,0}))),
   p126ntc_row("char-case-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",5,0,1,0,"state","scratch","answer",N111Const{65,0}))),
   p126ntc_row("wrong-count",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,2,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("kind-high-word",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,1,1,0,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("count-high-word",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,1,"state","scratch","answer",N111Const{1,0}))),
   p126ntc_row("wrong-state",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,0,"other","scratch","answer",N111Const{1,0}))),
   p126ntc_row("state-output-refused",p126ntc_refused(p126ntc_call("p111_rt_special_take",4,0,1,0,"state","state","answer",N111Const{1,0}))),
   p126ntc_row("counter-limit",Bool.not(p126ntc_changed(p126nt_expand(p126ntc_valid(N111Local{"n"},"answer","scratch"),4294967295))))]
