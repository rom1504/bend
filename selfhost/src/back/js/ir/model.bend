
# Module: src/back/js/ir/model.bend:4
type JIRParam is Data:
  JIRParam{+id: U32, +erased: Bool}

# Apply owns one already-proved saturation chunk. Its callee is evaluated
# before its arguments; tail means a trampoline message, not a direct JS call.
# Let evaluates every value left-to-right in the outer scope before introducing
# params. The two lists have equal length; erased values are JIRNull without
# lowering their source expressions. Lambda params retain the public ABI slots
# and flatten only consecutive leading lambdas. Its body is delayed and lowered
# in tail mode. Match constructs a matcher value: arm and fallback expressions
# execute only on demand; arm constructs its function rather than invoking it.
# A single-constructor Match has JIRNull fallback, which is never emitted.

# Module: src/back/js/ir/model.bend:16
type JIRExpr is Data:
  JIRLocal{+id: U32}
  JIRGlobal{+name: String}
  JIRNull{}
  JIRWord{+number: U32, +float: Bool}
  JIRNat{+number: U32}
  JIRString{+text: String}
  JIRConstruct{+name: String, +fields: List<&2, JIRExpr>, +tail: Bool}
  JIRPrimitive{+name: String, +a: JIRExpr, +b: JIRExpr}
  JIRShift{+name: String, +left: JIRExpr, +count: U32}
  JIRChoice{+condition: JIRExpr, +yes: JIRExpr, +no: JIRExpr}
  JIRApply{+callee: JIRExpr, +args: List<&2, JIRExpr>, +tail: Bool}
  JIRLet{+params: List<&2, JIRParam>, +values: List<&2, JIRExpr>, +body: JIRExpr}
  JIRLambda{+params: List<&2, JIRParam>, +body: JIRExpr}
  JIRMatch{+name: String, +single: Bool, +arm: JIRExpr, +fallback: JIRExpr}
  JIRCallPlan{+env: List<&2, KTerm>, +spine: KTerm, +fallback: JIRExpr}
  JIRLegacy{+env: List<&2, KTerm>, +term: KTerm, +typ: KTerm, +tail: Bool}

# Module: src/back/js/ir/model.bend:50
@unsafe
def jir_param_id(+p: JIRParam) -> U32:
  match p:
    case JIRParam{id, erased}: id

# Module: src/back/js/ir/model.bend:55
@unsafe
def jir_param_erased(+p: JIRParam) -> Bool:
  match p:
    case JIRParam{id, erased}: erased
