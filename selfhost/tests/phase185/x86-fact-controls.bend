# Public segments retain scalar Return, which is outside p113k's private
# terminal model. The emitter must preserve these valid conditional returns.

def p185rf_segment(name: String, condition: U32) -> N111Segment:
  N111Segment{name,0,1,0,0,
    [N111Set{"condition",N111U32{},N111Const{condition,0}},
     N111If{N111Local{"condition"},[N111Return{N111Const{1,0}}],[]},
     N111Return{N111Const{2,0}}]}

def p185rf_nested() -> N111Segment:
  N111Segment{"p185o",0,1,0,0,
    [N111Set{"condition",N111U32{},N111Const{1,0}},
     N111If{N111Local{"condition"},[
       N111If{N111Local{"condition"},[N111Return{N111Const{3,0}}],[]}],[]},
     N111Return{N111Const{9,0}}]}

def p185rf_segments() -> List<&2,N111Segment>:
  [p185rf_segment("p185m",1),p185rf_segment("p185n",0),p185rf_nested()]

@unsafe
def p185rf_validate() -> String:
  p111v_segments(p185rf_segments(),N111Ids{missing(),missing()})

@unsafe
def p185rf_emit_segments(segments: List<&2,N111Segment>) -> X181Output:
  match segments:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}:
      x181_program_join(x181_segment(head,N111Ids{missing(),missing()}),p185rf_emit_segments(rest))

@unsafe
def p185rf_emit() -> X181Output:
  p185rf_emit_segments(p185rf_segments())
