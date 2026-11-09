# Scoped local-continuation frame adapter. Machine wrappers intentionally
# expose the post-verification template; independent original verifier rows
# below check the admission obligations separately.

@unsafe
def p185ff_ids() -> N111Ids:
  N111Ids{p111q_insert(missing(),"resume",37),missing()}

@unsafe
def p185ff_buffer(index: U32) -> String:
  p112f_name(p114h_prefix(index),"scratch")

@unsafe
def p185ff_call(symbol: String, state: String, buffer: String, fid: N111Value, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},fid},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p185ff_ordinary(buffer: String, count: U32) -> N111Stmt:
  p185ff_call("p111_rt_frame","state",buffer,N111FuncId{"resume"},N111Const{count,0},N111U64{})

def p185ff_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p185ff_admitted(stmt: N111Stmt, current: String, ids: N111Ids, site: U32) -> Bool:
  p185ff_changed(p185fr_expand(stmt,current,ids,site))

@unsafe
def p185ff_verified(count: U32, arity: U32, incoming: U32, capacity: U32) -> Bool:
  +ids : N111Ids = N111Ids{p111v_put(missing(),"resume","function",arity,incoming),missing()}
  +live = p111v_put(p111v_put(missing(),"state","local",3,0),"scratch","alloca",3,capacity)
  p111v_call("p111_rt_frame",N111U64{},[p111_state(),N111Arg{N111U32{},N111FuncId{"resume"}},
    p111_scratch(),p111_u32(count)],live,ids,0,0,0)

@unsafe
def p185ff_text(+current: String) -> String:
  p111q_body_text(p185fr_stmts([p185ff_ordinary(p185ff_buffer(0),1),N111Return{N111Local{"status"}}],
    current,p185ff_ids(),P111QCode{[],0,False{},""}))

@unsafe
def p185ff_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p185ff_controls() -> List<&2,String>:
  +buffer = p185ff_buffer(0)
  +call = p185ff_ordinary(buffer,1)
  +ids = p185ff_ids()
  +text = p185ff_text(buffer)
  [p185ff_row("scoped-one",p185ff_admitted(call,buffer,ids,0)),
   p185ff_row("scoped-zero",p185ff_admitted(p185ff_ordinary(buffer,0),buffer,ids,0)),
   p185ff_row("scoped-eight",p185ff_admitted(p185ff_ordinary(buffer,8),buffer,ids,0)),
   p185ff_row("case-seven",p185ff_admitted(p185ff_ordinary(p185ff_buffer(7),1),p185ff_buffer(7),ids,0)),
   p185ff_row("unscoped-refused",Bool.not(p185ff_admitted(call,"",ids,0))),
   p185ff_row("foreign-buffer-refused",Bool.not(p185ff_admitted(call,p185ff_buffer(1),ids,0))),
   p185ff_row("ordinary-context-unchanged",Bool.not(p185ff_admitted(p185ff_ordinary("scratch",1),"scratch",ids,0))),
   p185ff_row("case-eight-refused",Bool.not(p185ff_admitted(p185ff_ordinary(p185ff_buffer(8),1),p185ff_buffer(8),ids,0))),
   p185ff_row("forged-suffix-refused",Bool.not(p185ff_admitted(p185ff_ordinary("p114h_case_0_local_scratch_extra",1),"p114h_case_0_local_scratch_extra",ids,0))),
   p185ff_row("count-nine-refused",Bool.not(p185ff_admitted(p185ff_ordinary(buffer,9),buffer,ids,0))),
   p185ff_row("counter-bound-refused",Bool.not(p185ff_admitted(call,buffer,ids,4294967295))),
   p185ff_row("unknown-fid-refused",Bool.not(p185ff_admitted(call,buffer,N111Ids{missing(),missing()},0))),
   p185ff_row("runtime-fid-refused",Bool.not(p185ff_admitted(call,buffer,N111Ids{p111q_insert(missing(),"resume",65532),missing()},0))),
   p185ff_row("numeric-fid-refused",Bool.not(p185ff_admitted(p185ff_call("p111_rt_frame","state",buffer,N111Const{37,0},N111Const{1,0},N111U64{}),buffer,ids,0))),
   p185ff_row("high-count-refused",Bool.not(p185ff_admitted(p185ff_call("p111_rt_frame","state",buffer,N111FuncId{"resume"},N111Const{1,1},N111U64{}),buffer,ids,0))),
   p185ff_row("state-refused",Bool.not(p185ff_admitted(p185ff_call("p111_rt_frame","other",buffer,N111FuncId{"resume"},N111Const{1,0},N111U64{}),buffer,ids,0))),
   p185ff_row("result-width-refused",Bool.not(p185ff_admitted(p185ff_call("p111_rt_frame","state",buffer,N111FuncId{"resume"},N111Const{1,0},N111Ptr{}),buffer,ids,0))),
   p185ff_row("other-import-refused",Bool.not(p185ff_admitted(p185ff_call("p111_rt_jump","state",buffer,N111FuncId{"resume"},N111Const{1,0},N111U64{}),buffer,ids,0))),
   p185ff_row("global-name-alone-refused",Bool.not(p185ff_changed(p114t_expand(call,ids,0)))),
   p185ff_row("verifier-proves-valid",p185ff_verified(1,2,1,2048)),
   p185ff_row("verifier-rejects-wrong-arity",Bool.not(p185ff_verified(2,2,1,2048))),
   p185ff_row("verifier-rejects-noncontinuation",Bool.not(p185ff_verified(1,1,0,2048))),
   p185ff_row("verifier-rejects-short-buffer",Bool.not(p185ff_verified(1,2,1,0))),
   p185ff_row("factory-excludes-user-namespace",Bool.not(p114h_clean_name(buffer))),
   p185ff_row("scoped-call-eliminated",Bool.not(String.contains(text,"call $p111_rt_frame"))),
   p185ff_row("unscoped-call-retained",String.contains(p185ff_text(""),"call $p111_rt_frame")),
   p185ff_row("capture-load",String.contains(text,"_capture =l loadl %v_p114h_case_0_local_scratch")),
   p185ff_row("result-zero",String.contains(text,"%v_status =l copy 0\n") && String.contains(text,"ret %v_status\n"))]

@unsafe
def p185ff_oracle_function(name: String, +buffer: String, current: String, count: U32) -> String:
  "export function l $" ++ name ++ "(l %state, l " ++ p111q_local(buffer) ++ ") {\n@entry\n" ++
    p111q_body_text(p185fr_stmts([p185ff_ordinary(buffer,count),N111Return{N111Local{"status"}}],
      current,p185ff_ids(),P111QCode{[],0,False{},""})) ++ "}\n"

@unsafe
def p185ff_oracle_module() -> String:
  p185ff_oracle_function("p185fr_zero",p185ff_buffer(0),p185ff_buffer(0),0) ++
  p185ff_oracle_function("p185fr_one",p185ff_buffer(0),p185ff_buffer(0),1) ++
  p185ff_oracle_function("p185fr_eight",p185ff_buffer(0),p185ff_buffer(0),8) ++
  p185ff_oracle_function("p185fr_last",p185ff_buffer(7),p185ff_buffer(7),3) ++
  p185ff_oracle_function("p185fr_unscoped",p185ff_buffer(0),"",1) ++
  p185ff_oracle_function("p185fr_foreign",p185ff_buffer(0),p185ff_buffer(1),1) ++
  p185ff_oracle_function("p185fr_outside",p185ff_buffer(8),p185ff_buffer(8),1)

def p185ff_body(expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}: body

@unsafe
def p185ff_oracle_xfunction(name: String, +buffer: String, current: String, count: U32) -> X181Output:
  +ids = p185ff_ids()
  x181_function(name,["state",buffer],x181_scalar_rows(nt_append(N111Stmt,
    p185ff_body(p185fr_expand(p185ff_ordinary(buffer,count),current,ids,0)),
    [N111Return{N111Local{"status"}}])),ids)

@unsafe
def p185ff_oracle_x86() -> X181Output:
  x181_program_join(p185ff_oracle_xfunction("p185fr_zero",p185ff_buffer(0),p185ff_buffer(0),0),
  x181_program_join(p185ff_oracle_xfunction("p185fr_one",p185ff_buffer(0),p185ff_buffer(0),1),
  x181_program_join(p185ff_oracle_xfunction("p185fr_eight",p185ff_buffer(0),p185ff_buffer(0),8),
  x181_program_join(p185ff_oracle_xfunction("p185fr_last",p185ff_buffer(7),p185ff_buffer(7),3),
  x181_program_join(p185ff_oracle_xfunction("p185fr_unscoped",p185ff_buffer(0),"",1),
  x181_program_join(p185ff_oracle_xfunction("p185fr_foreign",p185ff_buffer(0),p185ff_buffer(1),1),
    p185ff_oracle_xfunction("p185fr_outside",p185ff_buffer(8),p185ff_buffer(8),1)))))))
