# Statement emission is independent of source types and private proof plans.
# A Let in return position needs lexical bindings, not an immediately invoked
# function. Evaluate all RHSs before opening the block that binds source names:
# putting temporary declarations beside those names would introduce a temporal
# dead zone and break parallel shadowing. Each nested Let owns its temporary
# scope; source binder names use x<id>, never the reserved $jir<index> names.
# Const bindings preserve snapshots captured by escaping closures. Other nodes
# retain the expression printer's demand, tail-message and public ABI behavior.
@unsafe
def jir_emit_return(+book: List<&2,KDef>, +node: JIRExpr) -> String:
  match node:
    case JIRLet{params, values, body}:
      "{" ++ jir_statement_values(book, values, 0) ++ "{" ++
        jir_statement_bindings(params, 0) ++ jir_emit_return(book, body) ++ "}}"
    case JIRChoice{condition, yes, no}:
      "/* choice */if(" ++ jir_emit(book, condition) ++ "){" ++ jir_emit_return(book, yes) ++
        "}else{" ++ jir_emit_return(book, no) ++ "}"
    case other: "return " ++ jir_emit(book, other) ++ ";"

@unsafe
def jir_statement_values(+book: List<&2,KDef>, +values: List<&2,JIRExpr>, +at: U32) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}:
      "const $jir" ++ U32.show(at) ++ "=" ++ jir_emit(book, value) ++ ";" ++
        jir_statement_values(book, rest, U32.inc(at))

@unsafe
def jir_statement_bindings(+params: List<&2,JIRParam>, +at: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{param, rest}:
      "const " ++ j_local(jir_param_id(param)) ++ "=$jir" ++ U32.show(at) ++ ";" ++
        jir_statement_bindings(rest, U32.inc(at))
