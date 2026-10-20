@unsafe
def p113k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P113KBody) -> P113DFunction:
  match scan:
    case P113KBody{body,facts,terminal}: P113DFunction{name,params,result,public,body}

@unsafe
def p113k_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),4096),
        u => p113k_function_done(name,params,result,public,p113k_body(body,missing())),u => function)

@unsafe
def p113k_functions(functions: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: []
    case Con{function,rest}: Con{p113k_function(function),p113k_functions(rest)}

@unsafe
def p113k_admitted(program: P113DProgram) -> P113DProgram:
  match program:
    case P113DProgram{original,functions}: P113DProgram{original,p113k_functions(functions)}

@unsafe
def p113k_verified(+original: P113DProgram, +candidate: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(candidate)),u => candidate,u => original)

@unsafe
def p113k_optimize(+program: P113DProgram) -> P113DProgram:
  nt_choose(P113DProgram,String.is_empty(p113d_verify(program)),
    u => p113k_verified(program,p113k_admitted(program)),u => program)

@unsafe
def p113k_lowered(+lowered: P113DLowering) -> P113DLowering:
  match lowered:
    case P113DLowered{program,+error}:
      nt_choose(P113DLowering,String.is_empty(error),u => P113DLowered{p113k_optimize(program),error},u => lowered)
