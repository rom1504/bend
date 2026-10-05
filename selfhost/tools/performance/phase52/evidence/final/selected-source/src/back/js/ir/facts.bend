# Bounded lexical value facts shared by runtime IR transformations. Only a
# local immutable value or null may be substituted. Global loads, constructors,
# closures, primitive operations and opaque adapters confer no effect proof.
type JIRCopy is Data:
  JIRCopy{+id: U32, +value: JIRExpr}

@unsafe
def jir_copy_lookup(+copies: List<&2, JIRCopy>, +id: U32) -> JIRExpr:
  match copies:
    case Nil{}: JIRLocal{id}
    case Con{JIRCopy{key, value}, rest}:
      kc(JIRExpr, U32.is_eq(key, id), u => value, u => jir_copy_lookup(rest, id))

@unsafe
def jir_copy_reads(+value: JIRExpr, +id: U32) -> Bool:
  match value:
    case JIRLocal{key}: U32.is_eq(key, id)
    case other: False{}

# Shadowing invalidates both the copied binder and its ultimate source. This
# matters even with normally unique IDs: synthetic backend inputs may shadow.
@unsafe
def jir_copy_shadow(+copies: List<&2, JIRCopy>, +id: U32) -> List<&2, JIRCopy>:
  match copies:
    case Nil{}: Nil{}
    case Con{JIRCopy{key, value}, rest}:
      kc(List<&2, JIRCopy>, U32.is_eq(key, id) || jir_copy_reads(value, id),
        u => jir_copy_shadow(rest, id), u => Con{JIRCopy{key, value}, jir_copy_shadow(rest, id)})

@unsafe
def jir_copy_scope(+copies: List<&2, JIRCopy>, +params: List<&2, JIRParam>) -> List<&2, JIRCopy>:
  match params:
    case Nil{}: copies
    case Con{param, rest}: jir_copy_scope(jir_copy_shadow(copies, jir_param_id(param)), rest)

@unsafe
def jir_copy_take(+copies: List<&2, JIRCopy>, +left: U32) -> List<&2, JIRCopy>:
  match copies:
    case Nil{}: Nil{}
    case Con{copy, rest}:
      kc(List<&2, JIRCopy>, U32.is_eq(left, 0), u => Nil{},
        u => Con{copy, jir_copy_take(rest, U32.sub(left, 1))})

@unsafe
def jir_param_has(+params: List<&2, JIRParam>, +id: U32) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{param, rest}:
      kc(Bool, U32.is_eq(jir_param_id(param), id), u => True{}, u => jir_param_has(rest, id))

# Parallel RHSs refer to the outer scope. A source local rebound anywhere in
# this Let therefore cannot replace a body local after the new scope opens.
@unsafe
def jir_copy_admit(+value: JIRExpr, +params: List<&2, JIRParam>) -> Bool:
  match value:
    case JIRLocal{id}: Bool.not(jir_param_has(params, id))
    case JIRNull{}: True{}
    case other: False{}

# At most 64 facts survive, and at most 64 bindings are candidates per scope.
# Larger scopes remain correct and simply receive less propagation. Together
# with scope invalidation this bounds work by a constant times the IR surface.
@unsafe
def jir_copy_bind(+params: List<&2, JIRParam>, +values: List<&2, JIRExpr>, +scope: List<&2, JIRParam>, +copies: List<&2, JIRCopy>, +left: U32) -> List<&2, JIRCopy>:
  match params:
    case Nil{}: copies
    case Con{param, rest}:
      match values:
        case Nil{}: copies
        case Con{value, more}:
          kc(List<&2, JIRCopy>, U32.is_eq(left, 0), u => copies, u =>
            jir_copy_bind(rest, more, scope,
              kc(List<&2, JIRCopy>, jir_copy_admit(value, scope),
                u => Con{JIRCopy{jir_param_id(param), value}, jir_copy_take(copies, 63)}, u => copies),
              U32.sub(left, 1)))

