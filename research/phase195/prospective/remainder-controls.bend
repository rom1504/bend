def p195rc_v(name: String) -> N111Value: N111Local{name}
def p195rc_c(value: U32) -> N111Value: N111Const{value,0}
def p195rc_call(name: String, symbol: String, state: String, op: U32, buffer: String, count: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[N111Arg{N111Ptr{},p195rc_v(state)},N111Arg{N111U32{},p195rc_c(op)},N111Arg{N111Ptr{},p195rc_v(buffer)},N111Arg{N111U32{},p195rc_c(count)}]}
def p195rc_facts(d: U32) -> List<&2,X185ScratchCell>:
  [X185ScratchCell{"private",0,N111U64{},p195rc_v("n")},X185ScratchCell{"private",8,N111U64{},p195rc_c(d)}]
def p195rc_count(stmt: N111Stmt, facts: List<&2,X185ScratchCell>, expected: U32) -> Bool:
  U32.is_eq(nt_count(N111Stmt,x195rem_scalar(stmt,facts)),expected)
def p195rc_row(name: String, good: Bool) -> String:
  "rem-" ++ name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")
@unsafe
def p195rc_controls() -> List<&2,String>:
  [p195rc_row("admit-6",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(6),5)),
   p195rc_row("admit-10",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(10),5)),
   p195rc_row("admit-26",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(26),5)),
   p195rc_row("admit-80",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(80),5)),
   p195rc_row("refuse-0",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(0),1)),
   p195rc_row("refuse-1",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(1),1)),
   p195rc_row("refuse-7",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),p195rc_facts(7),1)),
   p195rc_row("symbol",p195rc_count(p195rc_call("out","p195rc_runtime","state",19,"private",2),p195rc_facts(26),1)),
   p195rc_row("state",p195rc_count(p195rc_call("out","p111_rt_op","other",19,"private",2),p195rc_facts(26),1)),
   p195rc_row("op",p195rc_count(p195rc_call("out","p111_rt_op","state",18,"private",2),p195rc_facts(26),1)),
   p195rc_row("arity",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",1),p195rc_facts(26),1)),
   p195rc_row("buffer-state",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"state",2),p195rc_facts(26),1)),
   p195rc_row("destination-alias",p195rc_count(p195rc_call("n","p111_rt_op","state",19,"private",2),p195rc_facts(26),1)),
   p195rc_row("unknown-facts",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),[],1)),
   p195rc_row("unknown-divisor",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),[X185ScratchCell{"private",0,N111U64{},p195rc_v("n")},X185ScratchCell{"private",8,N111U64{},p195rc_v("salt")}],1)),
   p195rc_row("wrong-width",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),[X185ScratchCell{"private",0,N111U32{},p195rc_v("n")},X185ScratchCell{"private",8,N111U64{},p195rc_c(26)}],1)),
   p195rc_row("high-divisor-bits",p195rc_count(p195rc_call("out","p111_rt_op","state",19,"private",2),[X185ScratchCell{"private",0,N111U64{},p195rc_v("n")},X185ScratchCell{"private",8,N111U64{},N111Const{26,1}}],1))]
@unsafe
def p195rc_rows(+d: U32, +name: String, symbol: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Alloca{"private",16,8}},
   P113DScalar{N111Store{N111U64{},p195rc_v("private"),0,p195rc_v("n")}},
   P113DScalar{N111Store{N111U64{},p195rc_v("private"),8,p195rc_c(d)}},
   P113DScalar{p195rc_call(name,symbol,"state",19,"private",2)},
   P113DScalar{N111Bin{"answer",N111U64{},"add",p195rc_v(name),p195rc_v("salt")}},P113DResult{[p195rc_v("answer")]}]
@unsafe
def p195rc_pair(+d: U32, +mode: U32, +name: String) -> X181Output:
  x181_program_join(x181_function("p195rc_old_" ++ U32.show(mode),["state","n","salt"],p195rc_rows(d,name,"p195rc_runtime"),N111Ids{missing(),missing()}),
    x181_function("p195rc_new_" ++ U32.show(mode),["state","n","salt"],p195rc_rows(d,name,"p111_rt_op"),N111Ids{missing(),missing()}))
@unsafe
def p195rc_emit() -> X181Output:
  x181_program_join(p195rc_pair(6,0,"out"),x181_program_join(p195rc_pair(10,1,"out"),x181_program_join(p195rc_pair(26,2,"out"),x181_program_join(p195rc_pair(7,3,"out"),x181_program_join(p195rc_pair(0,4,"out"),x181_program_join(p195rc_pair(1,5,"out"),x181_program_join(p195rc_pair(97,6,"out"),x181_program_join(p195rc_pair(80,7,"out"),x181_program_join(p195rc_pair(4294967295,8,"out"),x181_program_join(p195rc_pair(26,9,"n"),X181Output{[],""}))))))))))
