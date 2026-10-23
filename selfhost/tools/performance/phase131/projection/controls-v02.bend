# Structural tests for the small virtual-wrapper substitution boundary.
# Fabricated plans remain data; native execution uses independently checked books.
@unsafe
def p131p_controls() -> List<&2,String>:
  +a : KTerm = var("String",10)
  +b : KTerm = var("String",11)
  +r : KTerm = var("Cmp",12)
  +params : List<&2,KTerm> = [a,b]
  +left : KTerm = noa_atom("String",kt("OArg","",0,0,[]),var("",101))
  +right : KTerm = noa_atom("String",kt("OChild","",1,0,[kt("OArg","",1,0,[])]),var("",102))
  +scalar : KTerm = noa_atom("Cmp",kt("OUnique","",200,0,[]),var("",200))
  +roots : KTerm = kt("Ctr","Tuple",0,0,[a,b])
  +wrapper : KTerm = kt("Ctr","Tuple",0,0,[roots,r])
  +value : KTerm = p131p_virtual(wrapper,params,[left,right],12,scalar)
  [p128bs_control_row("projection-known-wrapper",p131p_wrapper_ok(wrapper,params,12,0)),
   p128bs_control_row("projection-scalar-wrapper",p131p_wrapper_ok(r,params,12,0)),
   p128bs_control_row("projection-unbound-refused",Bool.not(p131p_wrapper_ok(var("String",99),params,12,0))),
   p128bs_control_row("projection-effect-refused",Bool.not(p131p_wrapper_ok(kt("App","",0,0,[a,b]),params,12,0))),
   p128bs_control_row("projection-extra-shell-refused",Bool.not(p131p_wrapper_ok(kt("Ctr","Tuple",0,0,[wrapper,r]),params,12,0))),
   p128bs_control_row("projection-result-disjoint",Bool.not(p131p_parameter(12,params))),
   p128bs_control_row("projection-collision-detected",p131p_parameter(10,params)),
   p128bs_control_row("projection-outer-virtual",String.eq(tg(value),"OC") && String.eq(nm(value),"Tuple")),
   p128bs_control_row("projection-inner-virtual",String.eq(tg(kid(value,0)),"OC")),
   p128bs_control_row("projection-left-origin-preserved",norm_exact(kid(kid(value,0),0),left)),
   p128bs_control_row("projection-right-origin-preserved",norm_exact(kid(kid(value,0),1),right)),
   p128bs_control_row("projection-result-rebound",norm_exact(kid(value,1),scalar)),
   p128bs_control_row("projection-scalar-unchanged",norm_exact(p131p_virtual(r,params,[left,right],12,scalar),scalar)),
   p128bs_control_row("projection-missing-reader-refused",Bool.not(p131p_reader("missing",2,[])))]
