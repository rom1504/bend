# Simplify established worker layout facts, not source-language admission.
# A proved native tuple or Char has one constructor, and the emitter's case
# condition is already true. Its input was evaluated by preceding instructions;
# retaining the selected branch retains every field read and its order.
@unsafe
def jw_simplify_functions(+functions: List<&2,JWFunction>) -> List<&2,JWFunction>:
  match functions:
    case Nil{}: Nil{}
    case Con{JWFunction{name, arity, code, valid}, rest}:
      Con{JWFunction{name, arity, jw_simplify_code(code), valid}, jw_simplify_functions(rest)}

# Cases produced by lowering terminate their instruction list. Only flatten
# that form: a malformed case with following instructions retains its original
# shape and cannot accidentally make previously unreachable work executable.
@unsafe
def jw_simplify_code(+code: List<&2,JWInstruction>) -> List<&2,JWInstruction>:
  match code:
    case Nil{}: Nil{}
    case Con{JWCase{layout, name, input, yes, no}, Nil{}}:
      kc(List<&2,JWInstruction>, String.eq(layout, "tuple") || String.eq(layout, "char"),
        u => jw_simplify_code(yes),
        u => [JWCase{layout, name, input, jw_simplify_code(yes), jw_simplify_code(no)}])
    case Con{JWCase{layout, name, input, yes, no}, rest}:
      Con{JWCase{layout, name, input, jw_simplify_code(yes), jw_simplify_code(no)}, jw_simplify_code(rest)}
    case Con{instruction, rest}: Con{instruction, jw_simplify_code(rest)}
