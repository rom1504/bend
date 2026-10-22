# Pure analysis/emission controls; invented IR is not executed natively.
@unsafe
def p126lc_call(+name: String, +symbol: String, +count: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[p111_state(),p111_u32(58),p111_scratch(),p111_u32(count)]}

@unsafe
def p126lc_yes(group: P114SOGroup) -> Bool:
  match group:
    case P114SOYes{buffer,name,id,left,right,rest}: True{}
    case P114SONo{}: False{}

@unsafe
def p126lc_row(+label: String, actual: Bool, expected: Bool) -> String:
  nt_choose(String,U32.is_eq(Bool.to_u32(actual),Bool.to_u32(expected)),u => label ++ ":pass",u => label ++ ":FAIL")

@unsafe
def p126lc_group(+name: String, symbol: String, +count: U32, left: N111Value) -> Bool:
  p126lc_yes(p114so_group_call(p126lc_call(name,symbol,count),"scratch",left,N111Const{0,0},count,[]))

@unsafe
def p126lc_float_result() -> Bool:
  +facts = p114fl_result([P114FLFact{"x","%old"},P114FLFact{"other","%kept"}],"x",58,0)
  String.is_empty(p114fl_find(facts,"x")) && String.eq(p114fl_find(facts,"other"),"%kept")

@unsafe
def p126lc_text() -> Bool:
  String.eq(p126l_to_u32("x",0,P114FLOperand{"","%lane"}),
    "%t_2 =w cges %lane, s_0\n%t_3 =w clts %lane, s_4294967296\n%t_4 =w and %t_2, %t_3\njnz %t_4, @b_0, @b_1\n@b_0\n%t_5 =w stoui %lane\n%v_x =l extuw %t_5\njmp @b_2\n@b_1\n%v_x =l copy 0\njmp @b_2\n@b_2\n")

@unsafe
def p126lc_buffers(+extra: List<&2,P113DStmt>) -> Bool:
  +body : List<&2,P113DStmt> = nt_append(P113DStmt,[
    P113DScalar{N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"input"}}},
    P113DScalar{p126lc_call("answer","p111_rt_op",1)}],extra)
  p114so_member(p114so_buffers(body),"scratch")

@unsafe
def p126lc_controls() -> List<&2,String>:
  [p126lc_row("unary58",p126lc_group("x","p111_rt_op",1,N111Local{"input"}),True{}),
   p126lc_row("wrong-arity",p126lc_group("x","p111_rt_op",2,N111Local{"input"}),False{}),
   p126lc_row("wrong-symbol",p126lc_group("x","other",1,N111Local{"input"}),False{}),
   p126lc_row("destination-alias",p126lc_group("scratch","p111_rt_op",1,N111Local{"input"}),False{}),
   p126lc_row("operand-alias",p126lc_group("x","p111_rt_op",1,N111Local{"scratch"}),False{}),
   p126lc_row("result-is-word",p126lc_float_result(),True{}),
   p126lc_row("exact-guarded-conversion",p126lc_text(),True{}),
   p126lc_row("whole-buffer-admitted",p126lc_buffers([P113DResult{[N111Local{"answer"}]}]),True{}),
   p126lc_row("whole-buffer-observed",p126lc_buffers([P113DScalar{N111Load{"raw",N111U64{},N111Local{"scratch"},0}}]),False{})]
