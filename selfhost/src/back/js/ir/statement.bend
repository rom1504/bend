
# Module: src/back/js/ir/statement.bend:10
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

# Module: src/back/js/ir/statement.bend:21
@unsafe
def jir_statement_values(+book: List<&2,KDef>, +values: List<&2,JIRExpr>, +at: U32) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}:
      "const $jir" ++ U32.show(at) ++ "=" ++ jir_emit(book, value) ++ ";" ++
        jir_statement_values(book, rest, U32.inc(at))

# Module: src/back/js/ir/statement.bend:29
@unsafe
def jir_statement_bindings(+params: List<&2,JIRParam>, +at: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{param, rest}:
      "const " ++ j_local(jir_param_id(param)) ++ "=$jir" ++ U32.show(at) ++ ";" ++
        jir_statement_bindings(rest, U32.inc(at))
