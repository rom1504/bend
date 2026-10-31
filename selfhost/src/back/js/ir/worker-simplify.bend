
# Module: src/back/js/ir/worker-simplify.bend:6
@unsafe
def jw_simplify_functions(+functions: List<&2,JWFunction>) -> List<&2,JWFunction>:
  match functions:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, jw_simplify_code(code), valid}, jw_simplify_functions(rest)}

# Cases produced by lowering terminate their instruction list. Only flatten
# that form: a malformed case with following instructions retains its original
# shape and cannot accidentally make previously unreachable work executable.

# Module: src/back/js/ir/worker-simplify.bend:16
@unsafe
def jw_simplify_code(+code: List<&2,JWInstruction>) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{JWCase{layout, name, input, yes, no}, Nil{}}:
      kc(List<&2,JWInstruction>, p88_string_eq(layout, "tuple") || p88_string_eq(layout, "char"),
        u => jw_simplify_code(yes),
        u => [JWCase{layout, name, input, jw_simplify_code(yes), jw_simplify_code(no)}])
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      Con{JWCase{layout, name, input, jw_simplify_code(yes), jw_simplify_code(no)}, jw_simplify_code(rest)}
    case Con{instruction, rest}: Con{instruction, jw_simplify_code(rest)}
