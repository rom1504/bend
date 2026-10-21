# Diagnostic transport only: retain exact structured functions after the normal
# request lowering and verifier. No emitted text is parsed or transformed.
# A checked hosted API may JSON-serialize this ordinary Bend data unchanged.
# Names are supplied by the caller; there are no workload names in this module.

type P118BPInspection is Data:
  P118BPInspection{+functions: List<&2,P113DFunction>, +error: String}

@unsafe
def p118bp_select(functions: List<&2,P113DFunction>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{+function,+rest}:
      match function:
        case P113DFunction{name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,nb_contains(names,name),
            u => Con{function,p118bp_select(rest,names)},
            u => p118bp_select(rest,names))

@unsafe
def p118bp_verified(program: P113AProgram, names: List<&2,String>, +error: String) -> P118BPInspection:
  match program:
    case P113AProgram{P113DProgram{original,functions},certificate}:
      nt_choose(P118BPInspection,String.is_empty(error),
        u => P118BPInspection{p118bp_select(functions,names),""},
        u => P118BPInspection{[],error})

@unsafe
def p118bp_program(+program: P113AProgram, names: List<&2,String>) -> P118BPInspection:
  p118bp_verified(program,names,p113a_verify(program))

@unsafe
def p118bp_lowered(lowered: P113ALowering, names: List<&2,String>) -> P118BPInspection:
  match lowered:
    case P113ALowered{program,+error}:
      nt_choose(P118BPInspection,String.is_empty(error),
        u => p118bp_program(program,names),
        u => P118BPInspection{[],error})

@unsafe
def p118bp_request(request: NR_Request, names: List<&2,String>) -> P118BPInspection:
  p118bp_lowered(p113a_lower_request(request),names)
