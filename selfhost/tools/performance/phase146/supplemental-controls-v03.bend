# Additional finite controls for the ACTUAL ordinary request factory. These
# never emit malformed IR: every fixture must fail at checking/lowering, with
# an empty output list and an exact independently specified diagnostic.
# context-v01.bend and controls-v02.bend remain unchanged.

def p146cf_emission(result: P111Emission, expected: String) -> Bool:
  match result:
    case P111Emission{Nil{},error}: String.eq(error,expected)
    case _: False{}

@unsafe
def p146cf_opened(opened: P114SBoundary, want_open: Bool) -> Bool:
  match opened:
    case P114SBoundary{original,ids,functions,+valid}:
      nt_choose(Bool,want_open,u => valid,u => Bool.not(valid))

@unsafe
def p146cf_case(+program: P113DProgram, +certificate: P113ACertificate,
    +expected: String, want_open: Bool) -> Bool:
  +baseline = p113a_verify(P113AProgram{program,certificate})
  Bool.not(String.is_empty(expected)) && String.eq(baseline,expected) &&
    p146cf_opened(p114s_open(program),want_open) &&
    p146cf_emission(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},certificate,
      P128RawLowering{P113DLowered{program,""},[]}),"array structured IR: " ++ expected)

@unsafe
def p146cf_prior(+program: P113DProgram) -> Bool:
  String.eq(p113a_verify(P113AProgram{program,P113ACertificate{True{},True{}}}),
    "main: segment return must be U64") &&
    p146cf_emission(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},P113ACertificate{True{},True{}},
      P128RawLowering{P113DLowered{program,"prior failure"},[]}),"array native lowering: prior failure")

@unsafe
def p146cf_controls() -> List<&2,String>:
  +off : P113ACertificate = P113ACertificate{False{},False{}}
  +on : P113ACertificate = P113ACertificate{True{},True{}}
  +raw_bad : P113DProgram = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[],[])
  +static_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{1,"Box",[P112SRaw{7}]}],[])
  +direct_bad : P113DProgram = P113DProgram{p114st_original(),[p146ct_bad_direct()]}
  +priority_bad : P113DProgram = p146ct_raw([
    N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"undefined"}}],
    [],[P112SNode{1,"Missing",[]}],[])
  +effect_bad : P113DProgram = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{0,"Box",[P112SRaw{7}]}],["Box"])
  +array_bad : P113DProgram = P113DProgram{p114st_original(),[p146ct_reserved("p113a_reserved")]}
  +transport_bad : P113DProgram = p146ct_raw([
    N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"p114t_reserved"}}],[],[],[])
  [p114st_row("p146-factory-invalid-raw",p146cf_case(raw_bad,off,"main: segment return must be U64",False{})),
   p114st_row("p146-factory-invalid-static",p146cf_case(static_bad,off,"static image offset or word budget invalid",False{})),
   p114st_row("p146-factory-first-direct-invalid",p146cf_case(direct_bad,off,"direct terminal vector has wrong arity/type or undefined value",False{})),
   p114st_row("p146-factory-raw-before-static-and-namespace",p146cf_case(priority_bad,on,"main: segment return must be U64",False{})),
   p114st_row("p146-factory-effect-static",p146cf_case(effect_bad,off,"static image constructor or arity invalid",False{})),
   p114st_row("p146-factory-array-namespace-valid-open",p146cf_case(array_bad,on,"reserved private array-template local",True{})),
   p114st_row("p146-factory-transport-namespace-valid-open",p146cf_case(transport_bad,off,"reserved transport-template local",True{})),
   p114st_row("p146-factory-lowering-error-before-invalid-raw",p146cf_prior(raw_bad))]
