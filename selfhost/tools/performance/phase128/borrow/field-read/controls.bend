@unsafe
def p128bf_test_ids() -> N111Ids:
  N111Ids{missing(),p111q_constructor_ids(
    [N_Constructor{"pair",2,False{}},N_Constructor{"packed",1,False{}},N_Constructor{"large",8,False{}}],0,missing())}

@unsafe
def p128bf_test_call(symbol: String, state: String, buffer: String, ctor: N111Value, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},p111_word(N111Local{"word"}),
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},ctor},N111Arg{N111U32{},count}]}

@unsafe
def p128bf_test_ordinary(+ctor: String, count: U32) -> N111Stmt:
  p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{ctor},N111Const{count,0},N111U64{})

@unsafe
def p128bf_test_admitted(stmt: N111Stmt, ids: N111Ids, site: U32) -> Bool:
  match p128bf_match(stmt,ids,site):
    case P128BFRead{dest,term,buffer,ctor,count}: True{}
    case _: False{}

@unsafe
def p128bf_test_text(+stmt: N111Stmt, +previous: Bool) -> String:
  +ids = p128bf_test_ids()
  +code = P111QCode{[],0,False{},""}
  p111q_body_text(p111q_stmt(N111Return{N111Local{"status"}},ids,
    nt_choose(P111QCode,previous,u => p128bf_previous(stmt,ids,code),u => p111q_stmt(stmt,ids,code))))

@unsafe
def p128bf_test_same(+stmt: N111Stmt) -> Bool:
  String.eq(p128bf_test_text(stmt,True{}),p128bf_test_text(stmt,False{}))

@unsafe
def p128bf_controls() -> List<&2,String>:
  +ids = p128bf_test_ids()
  +read = p128bf_test_ordinary("pair",2)
  +text = p128bf_test_text(read,False{})
  [p128bs_control_row("field-pair-admitted",p128bf_test_admitted(read,ids,0)),
   p128bs_control_row("field-eight-admitted",p128bf_test_admitted(p128bf_test_ordinary("large",8),ids,0)),
   p128bs_control_row("field-packed-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("packed",1),ids,0))),
   p128bs_control_row("field-wrong-width-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("pair",3),ids,0))),
   p128bs_control_row("field-unknown-ctor-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("absent",2),ids,0))),
   p128bs_control_row("field-zero-refused",Bool.not(p128bf_test_admitted(p128bf_test_ordinary("pair",0),ids,0))),
   p128bs_control_row("field-counter-bound-refused",Bool.not(p128bf_test_admitted(read,ids,4294967295))),
   p128bs_control_row("field-missing-metadata-refused",Bool.not(p128bf_test_admitted(read,N111Ids{missing(),p111q_insert(missing(),"pair",0)},0))),
   p128bs_control_row("field-numeric-cid-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111Const{0,0},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-high-count-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{"pair"},N111Const{2,1},N111U64{}),ids,0))),
   p128bs_control_row("field-wrong-state-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","other","scratch",N111CtorId{"pair"},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-unknown-buffer-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","arbitrary",N111CtorId{"pair"},N111Const{2,0},N111U64{}),ids,0))),
   p128bs_control_row("field-pointer-result-refused",Bool.not(p128bf_test_admitted(p128bf_test_call("p118_rt_borrow_fields","state","scratch",N111CtorId{"pair"},N111Const{2,0},N111Ptr{}),ids,0))),
   p128bs_control_row("field-other-import-unchanged",p128bf_test_same(p128bf_test_call("other","state","scratch",N111CtorId{"pair"},N111Const{2,0},N111U64{}))),
   p128bs_control_row("field-packed-byte-identical",p128bf_test_same(p128bf_test_ordinary("packed",1))),
   p128bs_control_row("field-ids-preserved",String.eq(p111q_value(N111CtorId{"large"},ids),"2")),
   p128bs_control_row("field-template-contains-guard",String.contains(text,"_borrow_guard =w and ") && String.contains(text,"jnz %v_p114t_0_borrow_guard")),
   p128bs_control_row("field-template-contains-rfc",String.contains(text,"_borrow_high =l loaduw ") && String.contains(text,"_borrow_header_word =l or ")),
   p128bs_control_row("field-original-fallback-retained",String.contains(text,"call $p118_rt_borrow_fields(l %state, l %v_word, l %v_scratch, w 0, w 2)")),
   p128bs_control_row("field-exact-status",String.contains(text,"%v_status =l copy 2\n") && String.contains(text,"ret %v_status\n")),
   p128bs_control_row("field-not-blanket-pointer-admission",Bool.not(p111v_memory(N111Local{"arbitrary"},0,2,missing(),ids)))]
