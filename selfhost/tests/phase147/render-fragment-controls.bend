@unsafe
def p147fc_next(code: P111QCode, expected: U32) -> Bool:
  match code:
    case P111QCode{chunks,next,terminal,error}: U32.is_eq(next,expected)

@unsafe
def p147fc_stmt(+stmt: N111Stmt, +code: P111QCode, expected: String, next: U32) -> Bool:
  p147qc_same(p112a_original_stmt(stmt,p147qc_ids(),code),p147f_stmt(stmt,p147qc_ids(),code),expected) &&
  p147fc_next(p147f_stmt(stmt,p147qc_ids(),code),next)

@unsafe
def p147fc_body(+body: List<&2,N111Stmt>, +code: P111QCode, +expected: String) -> Bool:
  String.eq(p144e_body_tail(p147f_stmts(body,p147qc_ids(),0,code),"}\n"),expected) &&
  String.eq(p144e_body_tail(p147f_stmts(body,p147qc_ids(),2,code),"}\n"),expected)

@unsafe
def p147f_controls() -> List<&2,String>:
  [p147qc_row("loaduw-zero-offset",p147fc_stmt(N111Load{"x",N111U32{},N111Local{"state"},0},
     P111QCode{[],7,False{},""},"%v_x =l loaduw %state\n",7)),
   p147qc_row("load64-offset",p147fc_stmt(N111Load{"x",N111U64{},N111Local{"base"},8},
     P111QCode{[],7,False{},""},"%t_7 =l add %v_base, 8\n%v_x =l loadl %t_7\n",8)),
   p147qc_row("load-pointer-symbol",p147fc_stmt(N111Load{"state",N111Ptr{},N111Symbol{"pool"},0},
     P111QCode{[],0,False{},""},"%state =l loadl $pool\n",0)),
   p147qc_row("store32-zero-offset",p147fc_stmt(N111Store{N111U32{},N111Local{"state"},0,N111Const{4294967295,0}},
     P111QCode{[],4294967295,False{},""},"storew 4294967295, %state\n",4294967295)),
   p147qc_row("store-temp-wrap",p147fc_stmt(N111Store{N111U64{},N111Symbol{"pool"},4294967295,N111Const{0,1}},
     P111QCode{[],4294967295,False{},""},"%t_4294967295 =l add $pool, 4294967295\nstorel 4294967296, %t_4294967295\n",0)),
   p147qc_row("load-temp-wrap",p147fc_stmt(N111Load{"x",N111U32{},N111Local{"base"},1},
     P111QCode{[],4294967295,False{},""},"%t_4294967295 =l add %v_base, 1\n%v_x =l loaduw %t_4294967295\n",0)),
   p147qc_row("store-pointer-id",p147fc_stmt(N111Store{N111Ptr{},N111Local{"base"},0,N111FuncId{"worker"}},
     P111QCode{[],3,False{},""},"storel 7, %v_base\n",3)),
   p147qc_row("store-missing-id",p147fc_stmt(N111Store{N111U32{},N111Local{"base"},0,N111CtorId{"missing"}},
     P111QCode{[],3,False{},""},"storew INVALID_N111_ID, %v_base\n",3)),
   p147qc_row("set-u64-max",p147fc_stmt(N111Set{"x",N111U64{},N111Const{4294967295,4294967295}},
     P111QCode{[],4,False{},""},"%v_x =l copy 18446744073709551615\n",4)),
   p147qc_row("set-constructor",p147fc_stmt(N111Set{"x",N111U32{},N111CtorId{"Pair"}},
     P111QCode{[],4,False{},""},"%v_x =w copy 9\n",4)),
   p147qc_row("bin-comparison-width",p147fc_stmt(N111Bin{"x",N111U64{},"eq",N111Const{0,1},N111Const{0,1}},
     P111QCode{[],5,False{},""},"%v_x =w ceql 4294967296, 4294967296\n",5)),
   p147qc_row("bin-invalid-marker",p147fc_stmt(N111Bin{"x",N111U32{},"unsupported",N111Local{"a"},N111Const{1,0}},
     P111QCode{[],5,False{},""},"%v_x =w INVALID_N111_BINARY %v_a, 1\n",5)),
   p147qc_row("offset-high-word",p147fc_stmt(N111Offset{"x",N111Symbol{"pool"},N111Const{0,1}},
     P111QCode{[],6,False{},""},"%v_x =l add $pool, 4294967296\n",6)),
   p147qc_row("prior-fragments-order",p147fc_stmt(N111Set{"商",N111Ptr{},N111Symbol{"𐀀"}},
     P111QCode{["line\n","prior "],2,False{},""},"prior line\n%v_商 =l copy $𐀀\n",2)),
   p147qc_row("direct-error-terminal-state",p147fc_stmt(N111Load{"x",N111U32{},N111Local{"base"},8},
     P111QCode{[],4294967295,True{},"earlier error"},"%t_4294967295 =l add %v_base, 8\n%v_x =l loaduw %t_4294967295\n",0)),
   p147qc_row("body-earlier-error",p147fc_body([N111Store{N111U32{},N111Local{"state"},1,N111Const{1,0}}],
     P111QCode{["prior"],4294967295,False{},"earlier error"},"INVALID_N111_BODY\n}\n")),
   p147qc_row("body-after-terminal",p147fc_body([N111Return{N111Const{0,0}},N111Set{"x",N111U32{},N111Const{1,0}}],
     P111QCode{[],0,False{},""},"INVALID_N111_BODY\n}\n")),
   p147qc_row("body-fallthrough",p147fc_body([N111Set{"x",N111U32{},N111Const{1,0}}],
     P111QCode{[],0,False{},""},"INVALID_N111_FALLTHROUGH\n}\n"))]
