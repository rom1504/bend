# Positive, finite structural controls only. These are ordinary valid direct
# IR examples, not source ownership witnesses or malformed-input probes.
@unsafe
def p114st_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => "PASS " ++ name,u => "FAIL " ++ name)

def p114st_original() -> P112StaticProgram:
  P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],[],[0],[],[],True{}},[]}

def p114st_identity() -> P113DFunction:
  P113DFunction{"p114_identity",[NC_Binding{0,"a",N_W64{}}],1,False{},[P113DResult{[N111Local{"a"}]}]}

def p114st_scalar() -> P113DFunction:
  P113DFunction{"p114_scalar",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"sum",N111U64{},"add",N111Local{"a"},N111Const{1,0}}},
     P113DScalar{N111Bin{"sum",N111U64{},"and",N111Local{"sum"},N111Const{4294967295,0}}},
     P113DResult{[N111Local{"sum"}]}]}

def p114st_pair() -> P113DFunction:
  P113DFunction{"p114_pair",[NC_Binding{0,"a",N_W64{}},NC_Binding{1,"b",N_W64{}}],2,False{},
    [P113DResult{[N111Local{"b"},N111Local{"a"}]}]}

def p114st_caller() -> P113DFunction:
  P113DFunction{"p114_caller",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DCall{["first","second"],"p114_pair",[N111Local{"a"},N111Const{9,0}]},
     P113DCall{["answer"],"p114_scalar",[N111Local{"second"}]},
     P113DResult{[N111Local{"answer"}]}]}

def p114st_branch() -> P113DFunction:
  P113DFunction{"p114_branch",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"is_zero",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
     P113DIf{N111Local{"is_zero"},[P113DResult{[N111Const{1,0}]}],
       [P113DCall{["answer"],"p114_scalar",[N111Local{"a"}]},P113DResult{[N111Local{"answer"}]}]}]}

def p114st_loop() -> P113DFunction:
  P113DFunction{"p114_loop",[NC_Binding{0,"a",N_W64{}}],1,False{},
    [P113DScalar{N111Bin{"is_zero",N111U64{},"eq",N111Local{"a"},N111Const{0,0}}},
     P113DIf{N111Local{"is_zero"},[P113DResult{[N111Const{0,0}]}],
       [P113DScalar{N111Bin{"next",N111U64{},"sub",N111Local{"a"},N111Const{1,0}}},P113DAgain{[N111Local{"next"}]}]}]}

def p114st_public() -> P113DFunction:
  P113DFunction{"main",[],1,True{},[P113DResult{[N111Const{0,0}]}]}

def p114st_functions(which: U32) -> List<&2,P113DFunction>:
  match which:
    case 0: []
    case 1: [p114st_identity()]
    case 2: [p114st_scalar(),p114st_pair(),p114st_caller()]
    case 3: [p114st_scalar(),p114st_branch()]
    case 4: [p114st_loop()]
    case _: [p114st_public()]

def p114st_program(which: U32) -> P113DProgram:
  P113DProgram{p114st_original(),p114st_functions(which)}

def p114st_valid(boundary: P114SBoundary) -> Bool:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}: valid

@unsafe
def p114st_equivalent(+program: P113DProgram) -> Bool:
  +baseline = p113k_optimize(p113i_optimize(program))
  +candidate = p114s_optimize(program)
  String.is_empty(p113d_verify(baseline)) && String.is_empty(p113d_verify(candidate)) &&
    String.eq(p113d_text(baseline),p113d_text(candidate))

@unsafe
def p114st_case(+which: U32, +label: String) -> List<&2,String>:
  +program = p114st_program(which)
  [p114st_row(label ++ "-original",String.is_empty(p113d_verify(program))),
   p114st_row(label ++ "-opened",p114st_valid(p114s_open(program))),
   p114st_row(label ++ "-exact-output",p114st_equivalent(program))]

@unsafe
def p114s_control_report() -> List<&2,String>:
  nt_append(String,p114st_case(0,"scaling-empty"),
  nt_append(String,p114st_case(1,"scaling-identity"),
  nt_append(String,p114st_case(2,"scaling-product-calls"),
  nt_append(String,p114st_case(3,"scaling-branch"),
  nt_append(String,p114st_case(4,"scaling-tail-loop"),p114st_case(5,"scaling-public-main"))))))

# Optional same-request check for small, genuinely checked source fixtures.
# Full compiler inputs should use the split driver and compare file pins;
# this control intentionally computes both pipelines and rendered strings.
@unsafe
def p114s_control_lowered(lowered: P113DLowering) -> Bool:
  match lowered:
    case P113DLowered{program,+error}:
      String.is_empty(error) && p114st_equivalent(program)

@unsafe
def p114s_control_request(request: NR_Request) -> Bool:
  p114s_control_lowered(p113pl_lower_request(request))
