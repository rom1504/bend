
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

# Module: src/back/js/ir/projection.bend:5
type JIRProjection is Data:
  JIRProjectionNone{}
  JIRProjectionEmptyString{}
  JIRProjectionString{}
  JIRProjectionChar{}

# Module: src/back/js/ir/projection.bend:12
@unsafe
def jir_projection_plan(+book: List<&2,KDef>, +input: KTerm, +name: String) -> JIRProjection:
  kc(JIRProjection, j_string_string(book, input) && (p88_string_eq(name, "SNil") || p88_string_eq(name, "SCon")),
    u => kc(JIRProjection, p88_string_eq(name, "SNil"), u => JIRProjectionEmptyString{}, u => JIRProjectionString{}),
    u => kc(JIRProjection, j_string_char_type(book, input) && p88_string_eq(name, "Chr"),
      u => JIRProjectionChar{}, u => JIRProjectionNone{}))

# Module: src/back/js/ir/projection.bend:19
@unsafe
def jir_projection_condition(+plan: JIRProjection, +value: String) -> String:
  match plan:
    case JIRProjectionEmptyString{}: "(" ++ value ++ ")===\"\""
    case JIRProjectionString{}: "(" ++ value ++ ")!==\"\""
    case JIRProjectionChar{}: "true"
    case JIRProjectionNone{}: ""

# Capture the input once, including for a zero-field match. Keep both original
# codePointAt calls and the slice receiver/argument order. The active private
# proof excludes request/prototype hooks; no new proof is granted by this plan.

# Module: src/back/js/ir/projection.bend:30
@unsafe
def jir_projection_bindings(+plan: JIRProjection, +value: String, +slot: String) -> String:
  match plan:
    case JIRProjectionNone{}: ""
    case other:
      "const " ++ slot ++ "$value=" ++ value ++ ";" ++
        jir_projection_slots(other, slot)

# Module: src/back/js/ir/projection.bend:38
@unsafe
def jir_projection_slots(+plan: JIRProjection, +slot: String) -> String:
  match plan:
    case JIRProjectionString{}:
      "const " ++ slot ++ "$0=" ++ slot ++ "$value.codePointAt(0);" ++
      "const " ++ slot ++ "$1=" ++ slot ++ "$value.slice(" ++ slot ++ "$value.codePointAt(0)>65535?2:1);"
    case JIRProjectionChar{}:
      "const " ++ slot ++ "$0=typeof " ++ slot ++ "$value==='string'?" ++ slot ++ "$value.codePointAt(0):" ++ slot ++ "$value;"
    case other: ""

# Module: src/back/js/ir/projection.bend:48
@unsafe
def jir_projection_fields(+plan: JIRProjection, +slot: String, +rest: List<&2,String>) -> List<&2,String>:
  match plan:
    case JIRProjectionString{}: Con{slot ++ "$0", Con{slot ++ "$1", rest}}
    case JIRProjectionChar{}: Con{slot ++ "$0", rest}
    case other: rest
