import Base

# Frozen scalar semantics for the pure U32 constant-folding sublanguage.
# Base U32 operations are the checked Word(32) definitions, so arithmetic wraps.
# Effects, memory, variables, U64 operations and shifts are outside this model.
type ScalarOp is Data:
  ScalarAdd{}
  ScalarSub{}
  ScalarMul{}
  ScalarAnd{}
  ScalarOr{}
  ScalarXor{}
  ScalarEq{}
  ScalarUlt{}

def bool_word(value: Bool) -> U32:
  match value:
    case True{}: 1
    case False{}: 0

def evaluate(op: ScalarOp, a: U32, b: U32) -> U32:
  match op:
    case ScalarAdd{}: U32.add(a, b)
    case ScalarSub{}: U32.sub(a, b)
    case ScalarMul{}: U32.mul(a, b)
    case ScalarAnd{}: U32.and(a, b)
    case ScalarOr{}: U32.or(a, b)
    case ScalarXor{}: U32.xor(a, b)
    case ScalarEq{}: bool_word(U32.is_eq(a, b))
    case ScalarUlt{}: bool_word(U32.is_lt(a, b))
