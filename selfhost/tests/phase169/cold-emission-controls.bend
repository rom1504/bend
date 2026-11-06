# Finite metadata/authority-boundary controls. Runtime targets are unchanged.
@unsafe
def p169cc_original() -> P113AProgram:
  P113AProgram{P113DProgram{P112StaticProgram{
    P111Program{[p169svc_generic()],[N_Constructor{"Box",1,True{}},N_Constructor{"Other",2,True{}}],
      [0],[],[],True{}},[]},[]},P113ACertificate{False{},False{}}}

@unsafe
def p169cc_flags(admitted: P113AProgram, +first: Bool) -> Bool:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{Con{segment,Nil{}},
      Con{N_Constructor{"Box",1,hot},Con{N_Constructor{"Other",2,True{}},Nil{}}},
      Con{0,Nil{}},Nil{},Nil{},True{}},Nil{}},Nil{}},P113ACertificate{False{},False{}}}:
        U32.is_eq(Bool.to_u32(hot),Bool.to_u32(first))
    case _: False{}

@unsafe
def p169c_controls() -> List<&2,String>:
  +request : NR_Request = p169npc_request(["p108_missing"])
  +original : P113AProgram = p169cc_original()
  [p167c_row("cold-actual-source-permission-false",Bool.not(p169c_scalar(p113a_certificate(request)))),
   p167c_row("cold-scalar-false-unshared-true",Bool.not(p169c_scalar(P113ACertificate{False{},True{}}))),
   p167c_row("cold-scalar-true-unshared-false",p169c_scalar(P113ACertificate{True{},False{}})),
   p167c_row("cold-false-source-fact-preserves-program",p169cc_flags(p169c_selected(request,original),True{})),
   p167c_row("cold-valid-plan-changes-only-selected-flag",p169cc_flags(
     p118c_apply_plan(original,P118CPlan{request,[],["Box"],True{},""}),False{})),
   p167c_row("cold-invalid-plan-preserves-flags",p169cc_flags(
     p118c_apply_plan(original,P118CPlan{request,[],["Box"],False{},""}),True{})),
   p167c_row("cold-error-plan-preserves-flags",p169cc_flags(
     p118c_apply_plan(original,P118CPlan{request,[],["Box"],True{},"refused"}),True{})),
   p167c_row("cold-namespace-error-order",p169npc_error(
     p169c_emitted(request,original,False{},"reserved private array-template local"),
     "adapter imports view verification: reserved private array-template local"))]
