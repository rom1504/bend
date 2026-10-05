# Bounded local copy propagation. This pass neither consults the checked book
# nor emits JavaScript. It preserves all evaluations and opaque nodes. Bindings
# remain unless the entire body is exactly the single introduced local; opaque
# Legacy and CallPlan source uses therefore never lose their binding scope.
@unsafe
def jir_simplify_many(+terms: List<&2, JIRExpr>, +copies: List<&2, JIRCopy>) -> List<&2, JIRExpr>:
  match terms:
    case Nil{}: Nil{}
    case Con{term, rest}: Con{jir_simplify_with(term, copies), jir_simplify_many(rest, copies)}

@unsafe
def jir_simplify_let(+params: List<&2, JIRParam>, +values: List<&2, JIRExpr>, +body: JIRExpr, +copies: List<&2, JIRCopy>) -> JIRExpr:
  +rewritten = jir_simplify_many(values, copies)
  jir_simplify_let_select(params, rewritten, body, copies)

# An identity binding evaluates its sole RHS once and returns that exact value.
# Inspect the original body before copy propagation changes a Local/Null alias.
# Reuse the RHS node unchanged: in particular a non-tail application stays
# demanded, and an eager constructor never becomes a deferred tail constructor.
# The RHS already has the outer scope, including when its ID shadows this Let.
@unsafe
def jir_simplify_let_select(+params: List<&2, JIRParam>, +values: List<&2, JIRExpr>, +body: JIRExpr, +copies: List<&2, JIRCopy>) -> JIRExpr:
  match params:
    case Con{param, Nil{}}:
      match values:
        case Con{value, Nil{}}:
          match body:
            case JIRLocal{id}:
              kc(JIRExpr, U32.is_eq(jir_param_id(param), id), u => value,
                u => jir_simplify_let_body(params, values, body, copies))
            case other: jir_simplify_let_body(params, values, body, copies)
        case other: jir_simplify_let_body(params, values, body, copies)
    case other: jir_simplify_let_body(params, values, body, copies)

@unsafe
def jir_simplify_let_body(+params: List<&2, JIRParam>, +rewritten: List<&2, JIRExpr>, +body: JIRExpr, +copies: List<&2, JIRCopy>) -> JIRExpr:
  +inner = jir_copy_bind(params, rewritten, params, jir_copy_scope(copies, params), 64)
  JIRLet{params, rewritten, jir_simplify_with(body, inner)}

@unsafe
def jir_simplify_with(+t: JIRExpr, +copies: List<&2, JIRCopy>) -> JIRExpr:
  match t:
    case JIRLocal{id}: jir_copy_lookup(copies, id)
    case JIRApply{callee, args, tail}:
      JIRApply{jir_simplify_with(callee, copies), jir_simplify_many(args, copies), tail}
    case JIRConstruct{name, fields, tail}:
      JIRConstruct{name, jir_simplify_many(fields, copies), tail}
    case JIRPrimitive{name, a, b}:
      jir_fold_primitive(name, jir_simplify_with(a, copies), jir_simplify_with(b, copies))
    case JIRShift{name, left, count}:
      JIRShift{name, jir_simplify_with(left, copies), count}
    case JIRLet{params, values, body}: jir_simplify_let(params, values, body, copies)
    case JIRLambda{params, body}:
      JIRLambda{params, jir_simplify_with(body, jir_copy_scope(copies, params))}
    case JIRMatch{name, single, arm, fallback}:
      JIRMatch{name, single, jir_simplify_with(arm, copies), jir_simplify_with(fallback, copies)}
    case JIRChoice{condition, yes, no}:
      JIRChoice{jir_simplify_with(condition, copies), jir_simplify_with(yes, copies), jir_simplify_with(no, copies)}
    case JIRCallPlan{env, spine, fallback}:
      JIRCallPlan{env, spine, jir_simplify_with(fallback, copies)}
    case other: t

@unsafe
def jir_simplify(+t: JIRExpr) -> JIRExpr:
  jir_simplify_with(t, Nil{})
