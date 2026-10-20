@unsafe
def p113nmt_mat(+name: String, +arity: U32, +mask: U32) -> KTerm:
  kt("Mat",name,arity,mask,[atom("Efq"),atom("Efq")])

@unsafe
def p113nmt_shape(code: List<&2,N111Stmt>, +n: U32, +lo: U32, +hi: U32) -> Bool:
  match code:
    case Con{N111Bin{name,N111U64{},op,N111Const{a,b},N111Const{1,0}},Nil{}}:
      String.eq(name,"v_" ++ U32.show(nc_id(n))) && String.eq(op,"sub") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def p113nmt_word(+lo: U32, +hi: U32) -> Bool:
  p113nmt_shape(p113nm_take(p113nt_book(True{}),p113nmt_mat("Succ",2,0),N111Const{lo,hi},1,11),11,lo,hi)

@unsafe
def p113nmt_local(code: List<&2,N111Stmt>) -> Bool:
  match code:
    case Con{N111Bin{name,N111U64{},op,N111Local{word},N111Const{1,0}},Nil{}}:
      String.eq(name,"v_" ++ U32.show(nc_id(7))) && String.eq(op,"sub") && String.eq(word,"original_nat")
    case _: False{}

@unsafe
def p113nmt_fallback(code: List<&2,N111Stmt>, +expected: String) -> Bool:
  match code:
    case Con{N111Call{name,N111U64{},symbol,args},rest}: String.eq(name,"ignored") && String.eq(symbol,expected)
    case _: False{}

@unsafe
def p113_nat_match_control_report() -> List<&2,String>:
  [p113ft_row("nat-match-canonical-succ",p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,0),1)),
   p113ft_row("nat-match-unknown-book-refused",Bool.not(p113nm_eligible([],p113nmt_mat("Succ",2,0),1))),
   p113ft_row("nat-match-lookalike-refused",Bool.not(p113nm_eligible(p113nt_book(False{}),p113nmt_mat("Succ",2,0),1))),
   p113ft_row("nat-match-wrong-constructor",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Some",2,0),1))),
   p113ft_row("nat-match-zero-keeps-no-fields",List.is_empty(&2,N111Stmt,p113nm_take(p113nt_book(True{}),p113nmt_mat("Zero",1,0),N111Const{0,0},0,0))),
   p113ft_row("nat-match-legacy-arity-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",0,0),1))),
   p113ft_row("nat-match-wrong-arity-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",3,0),1))),
   p113ft_row("nat-match-wrong-field-count",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,0),2))),
   p113ft_row("nat-match-narrow-mask-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),p113nmt_mat("Succ",2,1),1))),
   p113ft_row("nat-match-wrong-tag-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),kt("Ctr","Succ",2,0,[atom("Efq"),atom("Efq")]),1))),
   p113ft_row("nat-match-missing-arms-refused",Bool.not(p113nm_eligible(p113nt_book(True{}),kt("Mat","Succ",2,0,[]),1))),
   p113ft_row("nat-match-local-single-sub",p113nmt_local(p113nm_take(p113nt_book(True{}),p113nmt_mat("Succ",2,0),N111Local{"original_nat"},1,7))),
   p113ft_row("nat-match-one-fullword",p113nmt_word(1,0)),
   p113ft_row("nat-match-2pow32-fullword",p113nmt_word(0,1)),
   p113ft_row("nat-match-2pow40-fullword",p113nmt_word(0,256)),
   p113ft_row("nat-match-2pow48-minus1-fullword",p113nmt_word(4294967295,65535)),
   p113ft_row("nat-match-unknown-uses-original-special",p113nmt_fallback(p113nm_take([],p113nmt_mat("Succ",2,0),N111Local{"original_nat"},1,7),"p111_rt_special_take")),
   p113ft_row("nat-match-generic-uses-original-take",p113nmt_fallback(p113nm_take(p113nt_book(True{}),p113nmt_mat("Some",2,0),N111Local{"owner"},1,7),"p111_rt_take")),
   p113ft_row("nat-match-char-keeps-special-take",p113nmt_fallback(p113nm_take(p113nt_book(True{}),p113nmt_mat("Chr",2,1),N111Local{"character"},1,7),"p111_rt_special_take"))]
