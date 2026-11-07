# Compile this SAME observation module with original/precedence/lookahead/both.
# Compare complete returned values against the independently checked original.
# Parser observations are syntax tests, not claims that all terms typecheck.
def p175p_prec_cases() -> List<&2,String>:
  ["=>","->","&","|","||","&&","<",">op","<=",">=","<>","++","<&>",".|.",".^.",".&.","<<",">>op","+","-","*","/","%",
   "",">",">>","=","==","!=","!","(",")","[","]","{","}",",",":",";","\n","<eof>","word","long-name","&&&","|||","+++","---","<><","<<=",">>=","=>x","->x",".||.",".&","&.","<&&>",">opx",">>opx",">o",">>o",">>pp",">opp","a+","+a","\u{3bb}","\u{1f642}"]

@unsafe
def p175p_prec_values(xs: List<&2,String>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{head,rest}: Con{f_prec(head),p175p_prec_values(rest)}

def p175p_prec_observe() -> List<&2,U32>:
  p175p_prec_values(p175p_prec_cases())

@unsafe
def p175p_expression(+source: String, +min: U32) -> FParsed:
  f_expr(f_input(f_lex_cursor(source,1,0,0,[],1,1)),min)

@unsafe
def p175p_parser_observe() -> List<&2,FParsed>:
  [p175p_expression("a + b * c",0),
   p175p_expression("a + b * c",11),
   p175p_expression("a - b",0),
   p175p_expression("a -b",0),
   p175p_expression("a % b",0),
   p175p_expression("a %b",0),
   p175p_expression("a\n+ b",0),
   p175p_expression("a\n-b",0),
   p175p_expression("a\n- b",0),
   p175p_expression("a\n% b",0),
   p175p_expression("a\n\n;\n+ b",0),
   p175p_expression("a!(b)",0),
   p175p_expression("a! (b)",0),
   p175p_expression("a!\n(b)",0),
   p175p_expression("a[0]",0),
   p175p_expression("a < b",0),
   p175p_expression("a<b>",0),
   p175p_expression("a<b<c>>",0),
   p175p_expression("a >> b",0),
   p175p_expression("a >> )",0),
   p175p_expression("a >> }",0),
   p175p_expression("a >> ,",0),
   p175p_expression("a >> :",0),
   p175p_expression("a >> >",0),
   p175p_expression("a >>\n",0),
   p175p_expression("a >> ->",0),
   p175p_expression("a >> ]",0),
   p175p_expression("a >>",0),
   p175p_expression("a => a",0),
   p175p_expression("(a : Type) -> Type",0),
   p175p_expression("a .|. b .^. c .&. d",0),
   p175p_expression("a <&> b",0),
   p175p_expression("a || b && c",0),
   p175p_expression("a(\n)",0),
   p175p_expression("a +",0),
   p175p_expression("(",0),
   p175p_expression("",0),
   p175p_expression("a + b",4294967295)]

@unsafe
def p175p_growth_boundaries() -> List<&2,FParsed>:
  +empty = f_input([])
  +error : KTerm = KTerm{"Error","preserve-exact-error",7,9,[],["note"],11,13}
  [f_grow_base(FParsed{error,empty},0),
   f_grow_existing(FParsed{error,empty},0),
   f_grow_base(FParsed{KTerm{"Ref","r",0,1,[],[],0,0},empty},0)]
