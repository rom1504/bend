@unsafe
def p147qc_ids() -> N111Ids:
  N111Ids{p111q_insert(missing(),"worker",7),p111q_insert(missing(),"Pair",9)}

@unsafe
def p147qc_same(left: P111QCode, right: P111QCode, +expected: String) -> Bool:
  match left right:
    case P111QCode{+a,+an,+at,+ae} P111QCode{+b,+bn,+bt,+be}:
      U32.is_eq(an,bn) && U32.is_eq(Bool.to_u32(at),Bool.to_u32(bt)) && String.eq(ae,be) &&
      String.eq(nt_text_finish(a,""),expected) && String.eq(nt_text_finish(b,""),expected) &&
      String.eq(p144e_body_tail(P111QCode{a,an,at,ae},"}\n"),p144e_body_tail(P111QCode{b,bn,bt,be},"}\n"))

@unsafe
def p147qc_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +code: P111QCode, expected: String) -> Bool:
  p147qc_same(p112a_original_stmt(N111Call{name,typ,symbol,args},p147qc_ids(),code),
    p147q_call(name,typ,symbol,args,p147qc_ids(),code),expected)

@unsafe
def p147qc_row(name: String, bit: Bool) -> String:
  name ++ nt_choose(String,bit,u => ":pass",u => ":FAIL")

@unsafe
def p147qc_body(+body: List<&2,N111Stmt>, +expected: String) -> Bool:
  String.eq(p144e_body_tail(p147q_stmts(body,p147qc_ids(),False{},P111QCode{[],0,False{},""}),"}\n"),expected) &&
  String.eq(p144e_body_tail(p147q_stmts(body,p147qc_ids(),True{},P111QCode{[],0,False{},""}),"}\n"),expected)

@unsafe
def p147q_controls() -> List<&2,String>:
  [p147qc_row("empty-args",p147qc_call("x",N111U64{},"target",[],P111QCode{[],0,False{},""},"%v_x =l call $target()\n")),
   p147qc_row("mixed-args-widths",p147qc_call("x",N111U32{},"target",[
     N111Arg{N111U32{},N111Const{4294967295,0}},N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U64{},N111Const{0,1}}],
     P111QCode{[],11,False{},""},"%v_x =w call $target(w 4294967295, l %state, l 4294967296)\n")),
   p147qc_row("function-constructor-symbol",p147qc_call("state",N111Ptr{},"target",[
     N111Arg{N111U32{},N111FuncId{"worker"}},N111Arg{N111U32{},N111CtorId{"Pair"}},N111Arg{N111Ptr{},N111Symbol{"table"}}],
     P111QCode{[],0,False{},""},"%state =l call $target(w 7, w 9, l $table)\n")),
   p147qc_row("missing-id-marker",p147qc_call("x",N111U64{},"target",[N111Arg{N111U32{},N111FuncId{"unknown"}}],
     P111QCode{[],0,False{},""},"%v_x =l call $target(w INVALID_N111_ID)\n")),
   p147qc_row("prior-chunks-order",p147qc_call("x",N111U64{},"target",[],P111QCode{["second\n","first\n"],0,False{},""},
     "first\nsecond\n%v_x =l call $target()\n")),
   p147qc_row("metadata-max-terminal-error",p147qc_call("x",N111U64{},"target",[],P111QCode{[],4294967295,True{},"earlier error"},
     "%v_x =l call $target()\n")),
   p147qc_row("unicode-text-preserved",p147qc_call("商",N111U64{},"𐀀",[],P111QCode{[],0,False{},""},"%v_商 =l call $𐀀()\n")),
   p147qc_row("complete-call-return",p147qc_body([N111Call{"x",N111U64{},"target",[]},N111Return{N111Local{"x"}}],
     "%v_x =l call $target()\nret %v_x\n}\n")),
   p147qc_row("fallthrough-marker",p147qc_body([N111Call{"x",N111U64{},"target",[]}],"INVALID_N111_FALLTHROUGH\n}\n")),
   p147qc_row("statement-after-terminal",p147qc_body([N111Return{N111Const{0,0}},N111Call{"x",N111U64{},"target",[]}],"INVALID_N111_BODY\n}\n"))]
