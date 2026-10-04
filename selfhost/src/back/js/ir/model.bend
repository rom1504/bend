# Runtime expression IR, separate from the checked dependent KTerm core.
# Lowering resolves source typing, erasure and application boundaries once.
# Optimization transforms these nodes; emission prints their runtime behavior.
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

# Global loads may recompute an initializer, throw or observe public mutation.
# Word float=true invokes the runtime bit reinterpretation helper; unlike an
# integer token it is not a movable constant under arbitrary host mutation.
# Construct retains ordinary public layout. Tail fields are delayed trampoline
# computations, while other fields are eagerly evaluated in source order.
# Primitive and Shift retain exact source admission but contain only runtime
# operands. Choice evaluates its condition once and only the selected branch.
# Legacy is an explicit migration boundary for private constructor layouts,
# recursively compressed constructor literals, deep closures and private plans.
# It is opaque to optimization;
# effects, demand and binder uses must not be inferred from its outer tag.
# CallPlan preserves the existing guarded call selection around a structured
# generic fallback. It also retains source binder uses and is an effect barrier.
# Neither adapter authorizes a new proof or changes a public representation.

@unsafe
def jir_param_id(+p: JIRParam) -> U32:
  match p:
    case JIRParam{id, erased}: id

@unsafe
def jir_param_erased(+p: JIRParam) -> Bool:
  match p:
    case JIRParam{id, erased}: erased
