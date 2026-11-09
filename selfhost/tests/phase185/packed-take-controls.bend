# Append to the checked compiler API. The unchanged direct verifier checks
# every generated function before either target emitter sees it.

@unsafe
def p185pc_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids([N_Constructor{"$ctor.P185Unary",1,False{}}],42,missing())}

@unsafe
def p185pc_function(name: String, +input: String, +status: Bool) -> P113DFunction:
  P113DFunction{name,[NC_Binding{0,input,N_W64{}}],1,False{},
    nt_append(P113DStmt,p113d_scalars(p111_take("$ctor.P185Unary",N111Local{input},1,0)),
      [P113DResult{[N111Local{nt_choose(String,status,u => "ignored",u => "v_4294967295")}]}])}

@unsafe
def p185pc_functions() -> List<&2,P113DFunction>:
  [p185pc_function("p185ta","word",False{}),
   p185pc_function("p185tb","ignored",False{}),
   p185pc_function("p185tc","v_4294967295",False{}),
   p185pc_function("p185td","p185pt_0_word",False{}),
   p185pc_function("p185te","p185pt_0_guard",False{}),
   p185pc_function("p185tf","p185ptr_nearby",False{}),
   p185pc_function("p185tg","word",True{})]

@unsafe
def p185pc_validate() -> String:
  p113e_functions(p185pc_functions(),p185pc_ids(),missing())

@unsafe
def p185pc_text(+name: String, +word: N111Value, +count: U32, +previous: Bool) -> String:
  p111q_body_text(p111q_stmts(nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,previous,
    u => p185pt_previous(name,word,count,0),u => p111_take(name,word,count,0)),[N111Return{N111Const{0,0}}]),
    p185pc_ids(),P111QCode{[],0,False{},""}))

@unsafe
def p185pc_same(+name: String, +count: U32) -> Bool:
  String.eq(p185pc_text(name,N111Local{"word"},count,True{}),p185pc_text(name,N111Local{"word"},count,False{}))

@unsafe
def p185pc_reserved(+name: String) -> Bool:
  Bool.not(p185pt_admitted("$ctor.P185Unary",N111Local{name},1)) &&
    String.eq(p185pc_text("$ctor.P185Unary",N111Local{name},1,True{}),p185pc_text("$ctor.P185Unary",N111Local{name},1,False{}))

@unsafe
def p185pc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p185pc_controls() -> List<&2,String>:
  +text = p185pc_text("$ctor.P185Unary",N111Local{"word"},1,False{})
  [p185pc_row("verified-functions",String.is_empty(p185pc_validate())),
   p185pc_row("ordinary-one",p185pt_admitted("$ctor.P185Unary",N111Local{"word"},1)),
   p185pc_row("ordinary-zero-refused",Bool.not(p185pt_admitted("$ctor.P185Unary",N111Local{"word"},0))),
   p185pc_row("ordinary-two-refused",Bool.not(p185pt_admitted("$ctor.P185Unary",N111Local{"word"},2))),
   p185pc_row("special-refused",Bool.not(p185pt_admitted("Succ",N111Local{"word"},1))),
   p185pc_row("unqualified-refused",Bool.not(p185pt_admitted("P185Unary",N111Local{"word"},1))),
   p185pc_row("symbol-refused",Bool.not(p185pt_admitted("$ctor.P185Unary",N111Symbol{"word"},1))),
   p185pc_row("function-id-refused",Bool.not(p185pt_admitted("$ctor.P185Unary",N111FuncId{"word"},1))),
   p185pc_row("constructor-word-refused",Bool.not(p185pt_admitted("$ctor.P185Unary",N111CtorId{"$ctor.P185Unary"},1))),
   p185pc_row("literal-admitted",p185pt_admitted("$ctor.P185Unary",N111Const{4294967295,2164271871},1)),
   p185pc_row("reserved-word",p185pc_reserved("p185pt_0_word")),
   p185pc_row("reserved-guard",p185pc_reserved("p185pt_0_guard")),
   p185pc_row("reserved-expected",p185pc_reserved("p185pt_0_expected")),
   p185pc_row("reserved-payload",p185pc_reserved("p185pt_0_payload")),
   p185pc_row("reserved-other-site",p185pc_reserved("p185pt_17_word")),
   p185pc_row("nearby-prefix",p185pt_admitted("$ctor.P185Unary",N111Local{"p185ptr_nearby"},1)),
   p185pc_row("special-byte-identical",p185pc_same("Succ",1)),
   p185pc_row("wide-byte-identical",p185pc_same("$ctor.P185Unary",2)),
   p185pc_row("zero-byte-identical",p185pc_same("$ctor.P185Unary",0)),
   p185pc_row("identity-unresolved-rejected",Bool.not(String.is_empty(p113e_functions(p185pc_functions(),N111Ids{missing(),missing()},missing())))),
   p185pc_row("snapshot-first",String.starts_with(text,"%v_p185pt_0_word =l copy %v_word\n")),
   p185pc_row("tag-and-cid",String.contains(text,"_shape =l and %v_p185pt_0_bits, 8388607") && String.contains(text,"_expected =l or 42, 65536")),
   p185pc_row("payload-forty-bits",String.contains(text,"_payload =l and %v_p185pt_0_word, 1099511627775")),
   p185pc_row("original-fallback",String.contains(text,"call $p125_rt_take1(l %state, l %v_word, l %v_scratch)")),
   p185pc_row("original-field-load",String.contains(text,"%v_v_4294967295 =l loadl %v_scratch")),
   p185pc_row("original-status",String.contains(text,"%v_ignored =l copy 1"))]
