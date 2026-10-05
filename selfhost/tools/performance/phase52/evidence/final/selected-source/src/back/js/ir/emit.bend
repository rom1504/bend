# The production pass schedule is explicit and shared by compatibility entries.
@unsafe
def jir_compile(+book: List<&2,KDef>, +node: JIRExpr) -> String:
  jir_emit(book, jir_simplify(node))

# Print explicit operations. This layer makes no type, arity or purity guesses;
# inherited specialized plans are isolated behind the two compatibility nodes.
@unsafe
def jir_emit(+book: List<&2,KDef>, +node: JIRExpr) -> String:
  match node:
    case JIRLocal{id}: j_local(id)
    case JIRGlobal{name}: "get(G," ++ j_quote(name) ++ ")"
    case JIRNull{}: "null"
    case JIRWord{number, float}: j_word_text(Some{number}, float)
    case JIRNat{number}: U32.show(number) ++ "n"
    case JIRString{text}: j_quote(text)
    case JIRConstruct{name, fields, tail}:
      kc(String, tail, u => "build(", u => "ctor(") ++ j_quote(name) ++ ",[" ++
        kc(String, tail, u => jir_emit_thunks(book, fields), u => jir_emit_values(book, fields)) ++ "])"
    case JIRPrimitive{name, a, b}:
      "(/* primitive */" ++ j_primitive_code(name, "(" ++ jir_emit(book, a) ++ ")",
        "(" ++ kc(String, U32.is_eq(j_primitive_arity(name), 2), u => jir_emit(book, b), u => "") ++ ")") ++ ")"
    case JIRShift{name, left, count}:
      "(/* primitive */" ++ j_primitive_shift_literal(name, "(" ++ jir_emit(book, left) ++ ")", count) ++ ")"
    case JIRChoice{condition, yes, no}:
      "(/* choice */" ++ jir_emit(book, condition) ++ "?" ++ jir_emit(book, yes) ++ ":" ++ jir_emit(book, no) ++ ")"
    case JIRApply{callee, args, tail}:
      kc(String, tail, u => "jump(", u => "callOwned(") ++ jir_emit(book, callee) ++ ",[" ++
        jir_emit_apply_args(book, args) ++ "])"
    case JIRLet{params, values, body}:
      "((" ++ jir_emit_params(params) ++ ")=>" ++ jir_emit(book, body) ++ ")(" ++ jir_emit_values(book, values) ++ ")"
    case JIRLambda{params, body}:
      "fn(" ++ U32.show(jir_emit_arity(params)) ++ ",function(a){" ++ jir_emit_lambda_bindings(params, 0) ++
        jir_emit_return(book, body) ++ "})"
    case JIRMatch{name, single, arm, fallback}:
      kc(String, single, u => "matcher1(", u => "matcher(") ++ j_quote(name) ++ ",()=>" ++ jir_emit(book, arm) ++
        kc(String, single, u => "", u => ",()=>" ++ jir_emit(book, fallback)) ++ ")"
    case JIRCallPlan{env, spine, fallback}: j_finite_call(book, env, spine, jir_emit(book, fallback))
    case JIRLegacy{env, term, typ, tail}: j_expr_legacy(book, env, term, typ, tail)

@unsafe
def jir_emit_arity(+params: List<&2,JIRParam>) -> U32:
  match params:
    case Nil{}: 0
    case Con{param, rest}: U32.inc(jir_emit_arity(rest))

@unsafe
def jir_emit_params(+params: List<&2,JIRParam>) -> String:
  match params:
    case Nil{}: ""
    case Con{param, rest}: j_local(jir_param_id(param)) ++ "," ++ jir_emit_params(rest)

@unsafe
def jir_emit_values(+book: List<&2,KDef>, +values: List<&2,JIRExpr>) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}: jir_emit(book, value) ++ "," ++ jir_emit_values(book, rest)

@unsafe
def jir_emit_thunks(+book: List<&2,KDef>, +values: List<&2,JIRExpr>) -> String:
  match values:
    case Nil{}: ""
    case Con{value, rest}: "()=>" ++ jir_emit(book, value) ++ "," ++ jir_emit_thunks(book, rest)

# Preserve the historical output spelling while exposing a uniform IR list:
# a one-step application has no trailing comma; a grouped prefix has one.
@unsafe
def jir_emit_apply_args(+book: List<&2,KDef>, +args: List<&2,JIRExpr>) -> String:
  match args:
    case Nil{}: ""
    case Con{arg, Nil{}}: jir_emit(book, arg)
    case Con{arg, rest}: jir_emit_values(book, args)

@unsafe
def jir_emit_lambda_bindings(+params: List<&2,JIRParam>, +at: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{param, rest}:
      "const " ++ j_local(jir_param_id(param)) ++ "=" ++
        kc(String, jir_param_erased(param), u => "null", u => "a[" ++ U32.show(at) ++ "]") ++ ";" ++
        jir_emit_lambda_bindings(rest, U32.inc(at))
