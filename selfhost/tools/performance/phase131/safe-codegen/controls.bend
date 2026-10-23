@unsafe
def p131sc_row(+name: String, pass: Bool) -> String:
  name ++ nt_choose(String,pass,u => ":pass",u => ":FAIL")

# Structural admission controls. These do not replace ordinary independent
# output checking, strictness/failure controls, or native machine inspection.
@unsafe
def p131sc_controls() -> List<&2,String>:
  +word = kt("NWord","0",0,0,[])
  +literal = kl_make("U32",0,"")
  +unit = kt("Ctr","Unit",0,0,[])
  +closed = k_lam("v",1,1,[k_lam("tail",2,1,[
    kt("Mat","LT",1,0,[app(var("",2),unit),
      kt("Mat","EQ",1,0,[var("",1),
        kt("Mat","GT",1,0,[literal,atom("Efq")])])])],0,0,False{})],0,0,False{})
  +args : List<&2,KTerm> = [kl_make("U32",7,""),k_lam("u",8,1,[kl_make("U32",9,"")],0,0,False{}),kt("Ctr","EQ",0,0,[])]
  +expanded = p131sc_definition_body(closed,args,[],100,3)
  [p131sc_row("selector-canonical-zero",nbc_closed(word,[])),
   p131sc_row("selector-canonical-max",nbc_closed(kt("NWord","4294967295",0,0,[]),[])),
   p131sc_row("selector-negative-refused",Bool.not(nbc_closed(kt("NWord","-1",0,0,[]),[]))),
   p131sc_row("selector-overflow-refused",Bool.not(nbc_closed(kt("NWord","4294967296",0,0,[]),[]))),
   p131sc_row("selector-noncanonical-refused",Bool.not(nbc_closed(kt("NWord","00",0,0,[]),[]))),
   p131sc_row("selector-word-child-refused",Bool.not(nbc_closed(kt("NWord","0",0,0,[unit]),[]))),
   p131sc_row("selector-reference-refused",Bool.not(nbc_closed(kt("Ref","arbitrary",0,0,[]),[]))),
   p131sc_row("selector-operation-refused",Bool.not(nbc_closed(kt("NOp","u32_add",0,0,[word,word]),[]))),
   p131sc_row("selector-free-variable-refused",Bool.not(nbc_closed(var("",7),[]))),
   p131sc_row("selector-data-field-refused",Bool.not(nbc_closed(kt("Ctr","Tuple",0,0,[word,word]),[]))),
   p131sc_row("selector-compact-scalar",nbc_closed(nc_compact(literal),[])),
   p131sc_row("selector-mixed-callback-admitted",Bool.not(p98_tag_eq(expanded,"Absent"))),
   p131sc_row("selector-first-actual-still-strict",p98_tag_eq(expanded,"NSeqLet") || p98_tag_eq(expanded,"Let")),
   p131sc_row("selector-fresh-collision-refused",p98_tag_eq(p131sc_definition_body(closed,args,[nc_binding(nc_id(100))],100,3),"Absent"))]
