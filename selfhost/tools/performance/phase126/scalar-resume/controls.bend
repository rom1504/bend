# Pure eligibility controls; invented IR is never executed as target code.
@unsafe
def p126rc_tail(+target: String, +count: U32) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"x"}},
   N111Call{"reply",N111U64{},"p111_rt_jump",[p111_state(),N111Arg{N111U32{},N111FuncId{target}},p111_scratch(),p111_u32(count)]},
   N111Return{N111Local{"reply"}}]

@unsafe
def p126rc_shift() -> N111Stmt:
  N111If{N111Local{"small"},[
    N111Bin{"shift",N111U64{},"shl",N111Const{1,0},N111Local{"n"}},
    N111Bin{"shift",N111U64{},"and",N111Local{"shift"},N111Const{4294967295,0}}],[
    N111Set{"shift",N111U64{},N111Const{0,0}}]}

@unsafe
def p126rc_row(+label: String, +body: List<&2,N111Stmt>, +old_expected: Bool, +new_expected: Bool) -> String:
  +old = p114r_arguments(body,"owner",1)
  +new = p126r_arguments(body,"owner",1)
  nt_choose(String,U32.is_eq(Bool.to_u32(old),Bool.to_u32(old_expected)) && U32.is_eq(Bool.to_u32(new),Bool.to_u32(new_expected)),
    u => label ++ ":pass",u => label ++ ":FAIL")

@unsafe
def p126rc_branch(stmt: N111Stmt) -> List<&2,N111Stmt>:
  Con{N111If{N111Local{"condition"},[stmt],[]},p126rc_tail("owner",1)}

@unsafe
def p126rc_preserved() -> String:
  +body = Con{p126rc_shift(),p126rc_tail("owner",1)}
  +kept = p114r_without_transition(body)
  nt_choose(String,U32.is_eq(nt_count(N111Stmt,kept),2),u => "branch-and-stores-retained:pass",u => "branch-and-stores-retained:FAIL")

@unsafe
def p126rc_controls() -> List<&2,String>:
  [p126rc_row("old-tail",p126rc_tail("owner",1),True{},True{}),
   p126rc_row("old-scalar-prefix",Con{N111Set{"x",N111U64{},N111Const{3,0}},p126rc_tail("owner",1)},True{},True{}),
   p126rc_row("shift-diamond",Con{p126rc_shift(),p126rc_tail("owner",1)},False{},True{}),
   p126rc_row("nested-diamond",p126rc_branch(p126rc_shift()),False{},True{}),
   p126rc_row("wrong-target",Con{p126rc_shift(),p126rc_tail("other",1)},False{},False{}),
   p126rc_row("wrong-arity",Con{p126rc_shift(),p126rc_tail("owner",2)},False{},False{}),
   p126rc_row("branch-return",p126rc_branch(N111Return{N111Const{0,0}}),False{},False{}),
   p126rc_row("unknown-call",p126rc_branch(N111Call{"x",N111U64{},"external",[]}),False{},False{}),
   p126rc_row("bank-read",p126rc_branch(N111Call{"x",N111U64{},"p111_rt_reg_get",[p111_state(),p111_u32(0)]}),False{},False{}),
   p126rc_row("frame-change",p126rc_branch(N111Call{"x",N111U64{},"p111_rt_frame",[p111_state(),N111Arg{N111U32{},N111FuncId{"cont"}},p111_scratch(),p111_u32(0)]}),False{},False{}),
   p126rc_row("state-store",p126rc_branch(N111Store{N111U64{},N111Local{"state"},0,N111Const{0,0}}),False{},False{}),
   p126rc_row("pointer-write",p126rc_branch(N111Set{"scratch",N111Ptr{},N111Local{"state"}}),False{},False{}),
   p126rc_preserved()]
