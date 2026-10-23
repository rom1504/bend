# Append after controls.bend when selecting selector-literals-v02.bend.
@unsafe
def p131sc_controls_v02() -> List<&2,String>:
  List.append(&2,String,p131sc_controls(),
    [p131sc_row("selector-source-u32-closed",nbc_closed(kl_make("U32",0,""),[])),
     p131sc_row("selector-source-nat-closed",nbc_closed(kl_make("Nat",7,""),[])),
     p131sc_row("selector-source-float-closed",nbc_closed(kl_make("F32",0,""),[])),
     p131sc_row("selector-source-string-refused",Bool.not(nbc_closed(kl_make("String",0,"large strings must never expand here"),[]))),
     p131sc_row("selector-unknown-literal-refused",Bool.not(nbc_closed(kl_make("not-a-scalar-kind",0,""),[])))])
