# Late-template controls are separate from original verified call admission.
# Invalid words occur only in isolated fallback-routing observers, never in a
# production runtime invocation.

@unsafe
def p186uc_call(symbol: String, state: String, word: N111Value, buffer: String, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U64{},word},
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p186uc_ordinary(buffer: String, count: U32) -> N111Stmt:
  p186uc_call("p111_rt_take","state",N111Local{"word"},buffer,N111Const{count,0},N111U64{})

def p186uc_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p186uc_admitted(stmt: N111Stmt, site: U32) -> Bool:
  p186uc_changed(p186ut_expand(stmt,site))

@unsafe
def p186uc_text(+stmt: N111Stmt, original: Bool) -> String:
  +ids : N111Ids = N111Ids{missing(),missing()}
  +code : P111QCode = P111QCode{[],0,False{},""}
  +emitted = nt_choose(P111QCode,original,u => p186rt_previous(stmt,ids,code),u => p186ut_stmt(stmt,ids,code))
  p111q_body_text(p186rt_previous(N111Return{N111Local{"status"}},ids,emitted))

@unsafe
def p186uc_same(+stmt: N111Stmt) -> Bool:
  String.eq(p186uc_text(stmt,False{}),p186uc_text(stmt,True{}))

@unsafe
def p186uc_verified(count: U32, capacity: U32) -> Bool:
  +live = p111v_put(p111v_put(p111v_put(missing(),"state","local",3,0),"word","local",2,0),"scratch","alloca",3,capacity)
  p111v_call("p111_rt_take",N111U64{},[p111_state(),p111_word(N111Local{"word"}),p111_scratch(),p111_u32(count)],
    live,N111Ids{missing(),missing()},0,0,0)

@unsafe
def p186uc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p186uc_controls() -> List<&2,String>:
  +call = p186uc_ordinary("scratch",2)
  +text = p186uc_text(call,False{})
  [p186uc_row("one",p186uc_admitted(p186uc_ordinary("scratch",1),0)),
   p186uc_row("two",p186uc_admitted(call,0)),
   p186uc_row("three",p186uc_admitted(p186uc_ordinary("scratch",3),0)),
   p186uc_row("four",p186uc_admitted(p186uc_ordinary("scratch",4),0)),
   p186uc_row("zero-refused",p186uc_same(p186uc_ordinary("scratch",0))),
   p186uc_row("five-refused",p186uc_same(p186uc_ordinary("scratch",5))),
   p186uc_row("foreign-buffer-refused",p186uc_same(p186uc_ordinary("foreign",2))),
   p186uc_row("state-buffer-refused",p186uc_same(p186uc_ordinary("state",2))),
   p186uc_row("fusion-buffer",p186uc_admitted(p186uc_ordinary("p112f_7_local_scratch",2),0)),
   p186uc_row("inline-buffer",p186uc_admitted(p186uc_ordinary("p113i_0_local_scratch",2),0)),
   p186uc_row("local-continuation-refused",p186uc_same(p186uc_ordinary("p114h_case_0_local_scratch",2))),
   p186uc_row("counter-refused",Bool.not(p186uc_admitted(call,4294967295))),
   p186uc_row("high-count-refused",p186uc_same(p186uc_call("p111_rt_take","state",N111Local{"word"},"scratch",N111Const{2,1},N111U64{}))),
   p186uc_row("dynamic-count-refused",p186uc_same(p186uc_call("p111_rt_take","state",N111Local{"word"},"scratch",N111Local{"count"},N111U64{}))),
   p186uc_row("word-symbol-refused",p186uc_same(p186uc_call("p111_rt_take","state",N111Symbol{"word"},"scratch",N111Const{2,0},N111U64{}))),
   p186uc_row("reserved-word-refused",p186uc_same(p186uc_call("p111_rt_take","state",N111Local{"p114t_0_take_tag"},"scratch",N111Const{2,0},N111U64{}))),
   p186uc_row("literal-word",p186uc_admitted(p186uc_call("p111_rt_take","state",N111Const{51413520,33555200},"scratch",N111Const{2,0},N111U64{}),0)),
   p186uc_row("state-identity-refused",p186uc_same(p186uc_call("p111_rt_take","other",N111Local{"word"},"scratch",N111Const{2,0},N111U64{}))),
   p186uc_row("result-type-refused",p186uc_same(p186uc_call("p111_rt_take","state",N111Local{"word"},"scratch",N111Const{2,0},N111Ptr{}))),
   p186uc_row("other-import-refused",p186uc_same(p186uc_call("p111_rt_other","state",N111Local{"word"},"scratch",N111Const{2,0},N111U64{}))),
   p186uc_row("verified-call",p186uc_verified(2,2048)),
   p186uc_row("short-buffer-rejected",Bool.not(p186uc_verified(2,8))),
   p186uc_row("unique-tag-guard",String.contains(text,"_take_unique =w ceql")),
   p186uc_row("constructor-bound-guard",String.contains(text,"_take_cid_high =w cultl")),
   p186uc_row("arity-byte-window",String.contains(text,"_take_arity_word =l loaduw") && String.contains(text,"_take_arity =w shr")),
   p186uc_row("static-boundary-guard",String.contains(text,"_take_dynamic =w cugel")),
   p186uc_row("handoff-threshold-guard",String.contains(text,"_take_cached =w cultl")),
   p186uc_row("original-sized-fallback",String.contains(text,"call $p125_rt_take2"))]

@unsafe
def p186uc_oracle_function(name: String, +buffer: String, count: U32) -> String:
  "export function l $" ++ name ++ "(l %state, l %v_word, l " ++ p111q_local(buffer) ++ ") {\n@entry\n" ++
    p186uc_text(p186uc_ordinary(buffer,count),False{}) ++ "}\n"

@unsafe
def p186uc_oracle_module() -> String:
  p186uc_oracle_function("p186ut_one","scratch",1) ++
  p186uc_oracle_function("p186ut_two","scratch",2) ++
  p186uc_oracle_function("p186ut_three","scratch",3) ++
  p186uc_oracle_function("p186ut_four","scratch",4) ++
  p186uc_oracle_function("p186ut_foreign","foreign",2)
