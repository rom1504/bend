# Finite differential controls. Each case obtains its boundary from ORIGINAL
# p114s_open in this invocation. No caller-created validity token is accepted.
# Malformed IR is checked only; these controls never emit or run it.

@unsafe
def p146ct_judgment(+program: P113AProgram, +ids: N111Ids, +valid: Bool,
    want_open: Bool, want_ok: Bool) -> Bool:
  +original = p113a_verify(program)
  +held = nt_choose(String,valid,u => p146c_verify(program,ids),u => p113a_verify(program))
  +raw = nt_choose(String,valid,u => p146c_verify_raw(program),u => p113a_verify(program))
  String.eq(original,held) && String.eq(original,raw) &&
    nt_choose(Bool,want_open,u => valid,u => Bool.not(valid)) &&
    nt_choose(Bool,want_ok,u => String.is_empty(original),u => Bool.not(String.is_empty(original)))

@unsafe
def p146ct_opened(opened: P114SBoundary, functions: List<&2,P113DFunction>,
    certificate: P113ACertificate, want_open: Bool, want_ok: Bool) -> Bool:
  match opened:
    case P114SBoundary{original,ids,old,valid}:
      p146ct_judgment(P113AProgram{P113DProgram{original,functions},certificate},ids,valid,want_open,want_ok)

@unsafe
def p146ct_case(first: P113DProgram, functions: List<&2,P113DFunction>,
    certificate: P113ACertificate, want_open: Bool, want_ok: Bool) -> Bool:
  p146ct_opened(p114s_open(first),functions,certificate,want_open,want_ok)

@unsafe
def p146ct_optimized(opened: P114SBoundary) -> Bool:
  match opened:
    case P114SBoundary{original,ids,functions,valid}:
      p146ct_judgment(P113AProgram{P113DProgram{original,functions},P113ACertificate{False{},False{}}},ids,valid,True{},True{})

@unsafe
def p146ct_optimization(which: U32) -> Bool:
  p146ct_optimized(p114s_ranges(p114s_inline(p114s_open(p114st_program(which)))))

def p146ct_bad_direct() -> P113DFunction:
  P113DFunction{"bad",[],1,False{},[P113DResult{[N111Local{"undefined"}]}]}

def p146ct_reserved(+name: String) -> P113DFunction:
  P113DFunction{"reserved",[NC_Binding{0,name,N_W64{}}],1,False{},[P113DResult{[N111Local{name}]}]}

def p146ct_raw(body: List<&2,N111Stmt>, constructors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, effects: List<&2,String>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,body}],constructors,[0],[],effects,True{}},nodes},[]}

def p146ct_failure(result: P111Emission) -> Bool:
  match result:
    case P111Emission{pieces,error}: String.eq(error,"array native lowering: prior failure")
    case _: False{}

@unsafe
def p146ct_lowering_failure() -> Bool:
  p146ct_failure(p128raw_session_finish(NR_Request{[],[],[],[],[],None{}},P113ACertificate{True{},True{}},
    P128RawLowering{P113DLowered{p114st_program(1),"prior failure"},[]}))

@unsafe
def p146ct_controls() -> List<&2,String>:
  +off = P113ACertificate{False{},False{}}
  +on = P113ACertificate{True{},True{}}
  +first = p114st_program(2)
  +bad = p146ct_bad_direct()
  +raw_bad = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[],[])
  +static_bad = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{1,"Box",[P112SRaw{7}]}],[])
  +both_bad = p146ct_raw([N111Return{N111Local{"undefined"}}],[],[P112SNode{1,"Missing",[]}],[])
  +effect_bad = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Box",1,False{}}],
    [P112SNode{0,"Box",[P112SRaw{7}]}],["Box"])
  +duplicate_raw = P113DProgram{P112StaticProgram{P111Program{
    [N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]},N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [],[0],[],[],True{}},[]},[]}
  +ctor_bad = p146ct_raw([N111Return{N111Const{0,0}}],[N_Constructor{"Huge",256,False{}}],[],[])
  +public_bad = P113DFunction{"main",[NC_Binding{0,"x",N_W64{}}],1,True{},[P113DResult{[N111Local{"x"}]}]}
  +unknown_call = P113DFunction{"caller",[],1,False{},[P113DCall{["answer"],"missing",[]},P113DResult{[N111Local{"answer"}]}]}
  +duplicate_direct = [p114st_identity(),p114st_identity()]
  +raw_namespace = p146ct_raw([N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"p114t_reserved"}}],[],[],[])
  [p114st_row("p146-context-empty",p146ct_optimization(0)),
   p114st_row("p146-context-identity",p146ct_optimization(1)),
   p114st_row("p146-context-calls",p146ct_optimization(2)),
   p114st_row("p146-context-branches",p146ct_optimization(3)),
   p114st_row("p146-context-loop",p146ct_optimization(4)),
   p114st_row("p146-context-public",p146ct_optimization(5)),
   p114st_row("p146-context-changed-invalid-body",p146ct_case(first,[bad],off,True{},False{})),
   p114st_row("p146-context-forward-callee",p146ct_case(first,[p114st_caller(),p114st_pair(),p114st_scalar()],off,True{},False{})),
   p114st_row("p146-context-public-arity",p146ct_case(first,[public_bad],off,True{},False{})),
   p114st_row("p146-context-unknown-callee",p146ct_case(first,[unknown_call],off,True{},False{})),
   p114st_row("p146-context-duplicate-direct",p146ct_case(first,duplicate_direct,off,True{},False{})),
   p114st_row("p146-context-array-namespace-on",p146ct_case(first,[p146ct_reserved("p113a_reserved")],on,True{},False{})),
   p114st_row("p146-context-array-namespace-off",p146ct_case(first,[p146ct_reserved("p113a_reserved")],off,True{},True{})),
   p114st_row("p146-context-transport-namespace",p146ct_case(first,[p146ct_reserved("p114t_reserved")],off,True{},False{})),
   p114st_row("p146-context-raw-namespace",p146ct_case(raw_namespace,[],off,True{},False{})),
   p114st_row("p146-context-invalid-raw-fallback",p146ct_case(raw_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-invalid-static-fallback",p146ct_case(static_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-raw-static-error-order",p146ct_case(both_bad,[bad],on,False{},False{})),
   p114st_row("p146-context-effect-static-fallback",p146ct_case(effect_bad,[bad],off,False{},False{})),
   p114st_row("p146-context-duplicate-header-fallback",p146ct_case(duplicate_raw,[bad],off,False{},False{})),
   p114st_row("p146-context-constructor-ABI-fallback",p146ct_case(ctor_bad,[],off,False{},False{})),
   p114st_row("p146-context-first-direct-failure",p146ct_case(P113DProgram{p114st_original(),[bad]},[],off,False{},True{})),
   p114st_row("p146-context-lowering-error-prefix",p146ct_lowering_failure()),
   p114st_row("p146-context-independent-factories",p146ct_optimization(1) && p146ct_case(static_bad,[],off,False{},False{}) && p146ct_optimization(5))]
