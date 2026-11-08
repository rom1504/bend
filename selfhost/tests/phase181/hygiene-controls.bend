# Legal verified IR may use the backend's implicit local spellings. All five
# collision functions and both segments below must pass the unchanged verifier
# and then refuse in x86 before producing assembly. A nearby prefix stays legal.

def p181h_ids() -> N111Ids:
  N111Ids{missing(),missing()}

def p181h_leaf() -> P113DFunction:
  P113DFunction{"p181h_leaf",[],1,False{},[P113DResult{[N111Const{37,0}]}]}

def p181h_parameter() -> P113DFunction:
  P113DFunction{"p181h_parameter",[NC_Binding{0,"__x181_result_out",N_W64{}}],1,False{},
    [P113DResult{[N111Local{"__x181_result_out"}]}]}

def p181h_future() -> P113DFunction:
  P113DFunction{"p181h_future",[NC_Binding{0,"__x181future",N_W64{}}],1,False{},
    [P113DResult{[N111Local{"__x181future"}]}]}

def p181h_local() -> P113DFunction:
  P113DFunction{"p181h_local",[],1,False{},
    [P113DIf{N111Const{1,0},
       [P113DScalar{N111Set{"__x181_results",N111U64{},N111Const{7,0}}}],
       [P113DScalar{N111Set{"__x181_results",N111U64{},N111Const{9,0}}}]},
     P113DResult{[N111Local{"__x181_results"}]}]}

def p181h_alloca() -> P113DFunction:
  P113DFunction{"p181h_alloca",[],1,False{},
    [P113DIf{N111Const{1,0},
       [P113DScalar{N111If{N111Const{1,0},[N111Alloca{"__x181_tail",8,8}],[]}}],[]},
     P113DResult{[N111Const{0,0}]}]}

def p181h_destination() -> P113DFunction:
  P113DFunction{"p181h_destination",[],1,False{},
    [P113DCall{["__x181_result_out"],"p181h_leaf",[]},P113DResult{[N111Local{"__x181_result_out"}]}]}

def p181h_nearby() -> P113DFunction:
  P113DFunction{"p181h_nearby",[NC_Binding{0,"__x18_value",N_W64{}}],1,False{},
    [P113DResult{[N111Local{"__x18_value"}]}]}

def p181h_segment_local() -> N111Segment:
  N111Segment{"p181h_segment_local",0,1,0,0,
    [N111If{N111Const{1,0},[N111Set{"__x181_results",N111U64{},N111Const{1,0}}],[]},
     N111Return{N111Const{0,0}}]}

def p181h_segment_alloca() -> N111Segment:
  N111Segment{"p181h_segment_alloca",0,1,0,0,
    [N111If{N111Const{1,0},[N111Alloca{"__x181_tail",8,8}],[]},N111Return{N111Const{0,0}}]}

def p181h_functions() -> List<&2,P113DFunction>:
  [p181h_leaf(),p181h_parameter(),p181h_future(),p181h_local(),p181h_alloca(),p181h_destination(),p181h_nearby()]

def p181h_segments() -> List<&2,N111Segment>:
  [p181h_segment_local(),p181h_segment_alloca()]

@unsafe
def p181h_validate() -> String:
  p111_first(p113e_functions(p181h_functions(),p181h_ids(),missing()),p111v_segments(p181h_segments(),p181h_ids()))

@unsafe
def p181h_refused(output: X181Output) -> Bool:
  match output:
    case X181Output{chunks,error}: List.is_empty(&2,String,chunks) && String.starts_with(error,"x86 reserved local name: ")

@unsafe
def p181h_accepted(output: X181Output) -> Bool:
  match output:
    case X181Output{chunks,error}: Bool.not(List.is_empty(&2,String,chunks)) && String.is_empty(error)

@unsafe
def p181h_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

# Export this finite observation with p181h_validate. Every row must end in =1.
@unsafe
def p181h_controls() -> List<&2,String>:
  [p181h_row("valid-ir",String.is_empty(p181h_validate())),
   p181h_row("hidden-result-parameter",p181h_refused(x181_direct(p181h_parameter(),p181h_ids()))),
   p181h_row("reserved-prefix",p181h_refused(x181_direct(p181h_future(),p181h_ids()))),
   p181h_row("nested-local",p181h_refused(x181_direct(p181h_local(),p181h_ids()))),
   p181h_row("nested-alloca",p181h_refused(x181_direct(p181h_alloca(),p181h_ids()))),
   p181h_row("call-destination",p181h_refused(x181_direct(p181h_destination(),p181h_ids()))),
   p181h_row("segment-local",p181h_refused(x181_segment(p181h_segment_local(),p181h_ids()))),
   p181h_row("segment-alloca",p181h_refused(x181_segment(p181h_segment_alloca(),p181h_ids()))),
   p181h_row("ordinary-accepted",p181h_accepted(x181_direct(p181h_leaf(),p181h_ids()))),
   p181h_row("nearby-prefix-accepted",p181h_accepted(x181_direct(p181h_nearby(),p181h_ids())))]
