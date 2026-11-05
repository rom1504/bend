# Optional retained-original gate controls. Requires hybrid-controls.bend.
# Internal fabricated candidates are rejected; no malformed program is executed.

@unsafe
def p164ic_original() -> P112StaticProgram:
  P112StaticProgram{P111Program{[p164a_segment("main",0)],
    [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.B",1,True{}}],
    [0],[],[],True{}},[]}

def p164ic_accepted(emission: P111Emission) -> Bool:
  match emission:
    case P134Planned{P134Admitted{program}}: True{}
    case _: False{}

@unsafe
def p164ic_try(constructors: List<&2,N_Constructor>, functions: List<&2,P113DFunction>) -> Bool:
  p164ic_accepted(p164i_rebuild(p164c_book(),[],p164c_adapters(),p164ic_original(),
    P113ACertificate{False{},False{}},constructors,functions))

@unsafe
def p164ic_bound_result(emission: P111Emission) -> Bool:
  match emission:
    case P134Planned{P134Admitted{P113AProgram{
      P113DProgram{P112StaticProgram{P111Program{Con{segment,Nil{}},constructors,Con{0,Nil{}},Nil{},Nil{},True{}},Nil{}},functions},
      P113ACertificate{False{},False{}}}}}:
        p164a_shape(segment) && p164i_ctor_schema(constructors,
          [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.B",1,True{}}])
    case _: False{}

# Late data deliberately carries no generic entry, another descriptor/static
# image, and a forged stronger certificate. Reconstruction must use only the
# previously admitted generic/static fields and original certificate.
@unsafe
def p164ic_late_fields_ignored() -> Bool:
  +changed : P134EmissionPlan = P134Admitted{P113AProgram{
    P113DProgram{P112StaticProgram{P111Program{[],
      [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.B",1,True{}}],
      [999],["forged-show"],["forged-effect"],False{}},
      [P112SNode{0,"p164.B",[P112SRaw{123}]}]},[p164c_main()]},
    P113ACertificate{True{},True{}}}}
  p164ic_bound_result(p164i_plan(p164c_book(),[],p164c_adapters(),p164ic_original(),
    P113ACertificate{False{},False{}},changed))

@unsafe
def p164ic_controls() -> List<&2,String>:
  +constructors : List<&2,N_Constructor> = [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.B",1,True{}}]
  [p164c_row("retained-valid",p164ic_try(constructors,[p164c_main()])),
   p164c_row("retained-lost-worker-refused",Bool.not(p164ic_try(constructors,[]))),
   p164c_row("retained-ctor-order-refused",Bool.not(p164ic_try(
     [N_Constructor{"p164.B",1,True{}},N_Constructor{"p164.A",0,True{}}],[p164c_main()]))),
   p164c_row("retained-ctor-arity-refused",Bool.not(p164ic_try(
     [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.B",2,True{}}],[p164c_main()]))),
   p164c_row("retained-ctor-name-refused",Bool.not(p164ic_try(
     [N_Constructor{"p164.A",0,True{}},N_Constructor{"p164.other",1,True{}}],[p164c_main()]))),
   p164c_row("retained-malformed-final-body-refused",Bool.not(p164ic_try(constructors,
     [P113DFunction{"main",[],1,True{},[P113DResult{[N111Local{"not_assigned"}]}]}]))),
   p164c_row("retained-late-fields-and-certificate-ignored",p164ic_late_fields_ignored())]
