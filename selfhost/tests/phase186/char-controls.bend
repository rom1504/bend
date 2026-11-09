# Checked metadata and independent native observation module for ABI11102.

@unsafe
def p186chc_take(dest: String, symbol: String, state: String, buffer: String, kind: N111Value, count: N111Value, word: N111Value) -> N111Stmt:
  N111Call{dest,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},kind},
    N111Arg{N111U64{},word},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p186chc_ctor(dest: String, symbol: String, state: String, buffer: String, kind: N111Value, count: N111Value) -> N111Stmt:
  N111Call{dest,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},kind},
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p186chc_t(dest: String, buffer: String) -> N111Stmt:
  p186chc_take(dest,"p111_rt_special_take","state",buffer,N111Const{5,0},N111Const{1,0},N111Local{"word"})

@unsafe
def p186chc_c(dest: String, buffer: String) -> N111Stmt:
  p186chc_ctor(dest,"p111_rt_special_ctor","state",buffer,N111Const{5,0},N111Const{1,0})

def p186chc_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p186chc_admitted(stmt: N111Stmt) -> Bool:
  p186chc_changed(p186ch_expand(stmt))

@unsafe
def p186chc_text(stmt: N111Stmt) -> String:
  p186chc_chunks(p186ch_stmt(stmt,N111Ids{missing(),missing()},P111QCode{[],0,False{},""}))

@unsafe
def p186chc_chunks(code: P111QCode) -> String:
  match code:
    case P111QCode{chunks,next,terminal,+error}:
      nt_choose(String,String.is_empty(error),u => nt_text_finish(chunks,""),u => "INVALID_CONTROL: " ++ error)

@unsafe
def p186chc_same(+stmt: N111Stmt) -> Bool:
  String.eq(p186chc_text(stmt),p186chc_chunks(p186rt_stmt(stmt,N111Ids{missing(),missing()},P111QCode{[],0,False{},""})))

@unsafe
def p186chc_verified(stmt: N111Stmt, capacity: U32) -> Bool:
  p186chc_verified_live(stmt,p111v_put(p111v_put(p111v_put(missing(),"state","local",3,0),"word","local",2,0),"scratch","alloca",3,capacity))

@unsafe
def p186chc_verified_live(stmt: N111Stmt, live: KDef) -> Bool:
  match stmt:
    case N111Call{dest,typ,symbol,args}: p111v_call(symbol,typ,args,live,N111Ids{missing(),missing()},0,0,0)
    case _: False{}

@unsafe
def p186chc_shape(+stmt: N111Stmt, typ: N111Type, extra: List<&2,N111Arg>) -> N111Stmt:
  match stmt:
    case N111Call{dest,old,symbol,args}: N111Call{dest,typ,symbol,nt_append(N111Arg,args,extra)}
    case _: stmt

@unsafe
def p186chc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p186chc_controls() -> List<&2,String>:
  +take = p186chc_text(p186chc_t("word","scratch"))
  +ctor = p186chc_text(p186chc_c("scratch","scratch"))
  [p186chc_row("take",p186chc_admitted(p186chc_t("answer","scratch"))),
   p186chc_row("ctor",p186chc_admitted(p186chc_c("answer","scratch"))),
   p186chc_row("take-input-alias",p186chc_admitted(p186chc_t("word","scratch"))),
   p186chc_row("take-buffer-alias",p186chc_admitted(p186chc_t("scratch","scratch"))),
   p186chc_row("ctor-buffer-alias",p186chc_admitted(p186chc_c("scratch","scratch"))),
   p186chc_row("full64-constant",p186chc_admitted(p186chc_take("answer","p111_rt_special_take","state","scratch",N111Const{5,0},N111Const{1,0},N111Const{4294967295,4294967295}))),
   p186chc_row("store-before-status",String.eq(take,"storel %v_word, %v_scratch\n%v_word =l copy 1\n")),
   p186chc_row("load-before-destination",String.eq(ctor,"%v_scratch =l loadl %v_scratch\n")),
   p186chc_row("wrong-kind",p186chc_same(p186chc_take("answer","p111_rt_special_take","state","scratch",N111Const{4,0},N111Const{1,0},N111Local{"word"}))),
   p186chc_row("wrong-count",p186chc_same(p186chc_take("answer","p111_rt_special_take","state","scratch",N111Const{5,0},N111Const{2,0},N111Local{"word"}))),
   p186chc_row("zero-count",p186chc_same(p186chc_c_ctor_zero())),
   p186chc_row("kind-high",p186chc_same(p186chc_ctor("answer","p111_rt_special_ctor","state","scratch",N111Const{5,1},N111Const{1,0}))),
   p186chc_row("count-high",p186chc_same(p186chc_ctor("answer","p111_rt_special_ctor","state","scratch",N111Const{5,0},N111Const{1,1}))),
   p186chc_row("state-alias-refused",Bool.not(p186chc_admitted(p186chc_t("answer","state")))),
   p186chc_row("wrong-state",p186chc_same(p186chc_ctor("answer","p111_rt_special_ctor","other","scratch",N111Const{5,0},N111Const{1,0}))),
   p186chc_row("wrong-import",p186chc_same(p186chc_ctor("answer","p111_rt_ctor","state","scratch",N111Const{5,0},N111Const{1,0}))),
   p186chc_row("wrong-result-type",Bool.not(p186chc_admitted(p186chc_shape(p186chc_t("answer","scratch"),N111Ptr{},[])))),
   p186chc_row("extra-argument",Bool.not(p186chc_admitted(p186chc_shape(p186chc_c("answer","scratch"),N111U64{},[p111_u32(0)])))),
   p186chc_row("verified-take",p186chc_verified(p186chc_t("answer","scratch"),8)),
   p186chc_row("verified-constructor",p186chc_verified(p186chc_c("answer","scratch"),8)),
   p186chc_row("short-buffer-rejected",Bool.not(p186chc_verified(p186chc_t("answer","scratch"),0))),
   p186chc_row("other-statement",p186chc_same(N111Set{"answer",N111U64{},N111Const{42,0}}))]

@unsafe
def p186chc_c_ctor_zero() -> N111Stmt:
  p186chc_ctor("answer","p111_rt_special_ctor","state","scratch",N111Const{5,0},N111Const{0,0})

@unsafe
def p186chc_function(name: String, stmt: N111Stmt, suffix: String) -> String:
  "export function l $" ++ name ++ "(l %state, l %v_word, l %v_scratch) {\n@entry\n" ++ p186chc_text(stmt) ++ suffix ++ "}\n"

@unsafe
def p186chc_oracle_module() -> String:
  p186chc_function("p186char_take",p186chc_t("answer","scratch"),"%result =l loadl %v_scratch\nret %result\n") ++
  p186chc_function("p186char_status",p186chc_t("answer","scratch"),"ret %v_answer\n") ++
  p186chc_function("p186char_input_alias",p186chc_t("word","scratch"),"ret %v_word\n") ++
  p186chc_function("p186char_buffer_alias",p186chc_t("scratch","scratch"),"ret %v_scratch\n") ++
  p186chc_function("p186char_ctor",p186chc_c("answer","scratch"),"ret %v_answer\n") ++
  p186chc_function("p186char_ctor_alias",p186chc_c("scratch","scratch"),"ret %v_scratch\n")
