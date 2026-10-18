# Effect-preserving leaf inlining, NOT purity or ownership inference.
# Every admitted helper is call-free and loop-free. Verified pointer operations
# retain their exact order and aliasing; parameters are snapshotted by the common
# expander and all locals are reset at every invocation, including in caller loops.
def nx_l_type(+typ: NxType) -> Bool:
  nx_scalar(typ) || nx_type_equal(typ, NxPtr{})

@unsafe
def nx_l_params(+params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}: nx_l_type(typ) && nx_l_params(rest)

@unsafe
def nx_l_rhs(+expr: NxExpr) -> Bool:
  match expr:
    case NxAlloc{bytes}: nx_pure(bytes)
    case NxLoad{typ, ptr, offset}: nx_pure(ptr)
    case _: nx_pure(expr)

# Fallthrough branches cannot contain any return. Pure operand restrictions and
# well-typed pointer access are already enforced by the whole-program verifier.
@unsafe
def nx_l_fallthrough(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{NxSet{name, value}, rest}: nx_l_rhs(value) && nx_l_fallthrough(rest)
    case Con{NxStore{typ, ptr, offset, value}, rest}: nx_l_fallthrough(rest)
    case Con{NxFree{ptr}, rest}: nx_l_fallthrough(rest)
    case Con{NxIf{condition, yes, no}, rest}: nx_l_fallthrough(yes) && nx_l_fallthrough(no) && nx_l_fallthrough(rest)
    case _: False{}

@unsafe
def nx_l_tail(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Con{NxSet{name, value}, rest}: nx_l_rhs(value) && nx_l_tail(rest)
    case Con{NxStore{typ, ptr, offset, value}, rest}: nx_l_tail(rest)
    case Con{NxFree{ptr}, rest}: nx_l_tail(rest)
    case Con{NxReturn{value}, Nil{}}: nx_l_rhs(value)
    case Con{NxIf{condition, yes, no}, Nil{}}: nx_l_tail(yes) && nx_l_tail(no)
    case Con{NxIf{condition, yes, no}, rest}: nx_l_fallthrough(yes) && nx_l_fallthrough(no) && nx_l_tail(rest)
    case _: False{}

@unsafe
def nx_l_eligible(+fs: List<&2, NxFunction>) -> List<&2, String>:
  match fs:
    case Nil{}: []
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      nx_choose(List<&2, String>, nx_l_type(result) && nx_l_params(params) && nx_l_params(locals)
        && U32.is_le(nx_i_param_count(params), 16) && U32.is_le(nx_i_param_count(locals), 32)
        && U32.is_le(nx_i_body_nodes(body), 256) && nx_l_tail(body),
        u => Con{name, nx_l_eligible(rest)}, u => nx_l_eligible(rest))

@unsafe
def nx_l_checked(+candidate: NxProgram, +original: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(candidate), u => candidate, u => original)

@unsafe
def nx_l_program(+program: NxProgram, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_l_checked(nx_e_certified(program, nx_l_eligible(fs), budget), program), u => program)

@unsafe
def nx_inline_leaf(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_choose(NxProgram, U32.is_eq(budget, 0), u => program,
    u => nx_choose(NxProgram, nx_verify(program), u => nx_l_program(program, nx_inline_budget(budget)), u => program))
