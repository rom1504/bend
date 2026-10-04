# A native field-view plan for already admitted private matches. Selection uses
# exactly the existing String/Char ownership proofs; public matcher projection
# and the enclosing host/source/input guards are unchanged. Scalar bindings
# replace only the temporary projection vector, never the represented value.
type JIRProjection is Data:
  JIRProjectionNone{}
  JIRProjectionEmptyString{}
  JIRProjectionString{}
  JIRProjectionChar{}

@unsafe
def jir_projection_plan(+book: List<&2,KDef>, +input: KTerm, +name: String) -> JIRProjection:
  kc(JIRProjection, j_string_string(book, input) && (String.eq(name, "SNil") || String.eq(name, "SCon")),
    u => kc(JIRProjection, String.eq(name, "SNil"), u => JIRProjectionEmptyString{}, u => JIRProjectionString{}),
    u => kc(JIRProjection, j_string_char_type(book, input) && String.eq(name, "Chr"),
      u => JIRProjectionChar{}, u => JIRProjectionNone{}))

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
@unsafe
def jir_projection_bindings(+plan: JIRProjection, +value: String, +slot: String) -> String:
  match plan:
    case JIRProjectionNone{}: ""
    case other:
      "const " ++ slot ++ "$value=" ++ value ++ ";" ++
        jir_projection_slots(other, slot)

@unsafe
def jir_projection_slots(+plan: JIRProjection, +slot: String) -> String:
  match plan:
    case JIRProjectionString{}:
      "const " ++ slot ++ "$0=" ++ slot ++ "$value.codePointAt(0);" ++
      "const " ++ slot ++ "$1=" ++ slot ++ "$value.slice(" ++ slot ++ "$value.codePointAt(0)>65535?2:1);"
    case JIRProjectionChar{}:
      "const " ++ slot ++ "$0=typeof " ++ slot ++ "$value==='string'?" ++ slot ++ "$value.codePointAt(0):" ++ slot ++ "$value;"
    case other: ""

@unsafe
def jir_projection_fields(+plan: JIRProjection, +slot: String, +rest: List<&2,String>) -> List<&2,String>:
  match plan:
    case JIRProjectionString{}: Con{slot ++ "$0", Con{slot ++ "$1", rest}}
    case JIRProjectionChar{}: Con{slot ++ "$0", rest}
    case other: rest
