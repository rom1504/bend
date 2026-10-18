# Whole-function scalar replacement for closed, fully resolved heap objects.
# Analysis completes before rewriting; allocations/free and pointer stores stay.
type NxPField is Data:
  NxPField{+address: NxMAddr, +typ: NxType, +index: U32}
type NxPState is Data:
  NxPState{+pointers: List<&2, NxMPtr>, +fields: List<&2, NxPField>, +next: U32, +ok: Bool}
type NxPFound is Data:
  NxPFound{+field: Maybe<&2, NxPField>, +ok: Bool}
type NxPAccess is Data:
  NxPAccess{+name: String, +state: NxPState}
type NxPExpr is Data:
  NxPExpr{+value: NxExpr, +state: NxPState}
type NxPBlock is Data:
  NxPBlock{+body: List<&2, NxStmt>, +state: NxPState}

def nx_p_fail(+state: NxPState) -> NxPState:
  match state:
    case NxPState{pointers, fields, next, ok}: NxPState{pointers, fields, next, False{}}

@unsafe
def nx_p_known(+expr: NxExpr, +env: List<&2, NxParam>, +pointers: List<&2, NxMPtr>) -> Bool:
  match expr:
    case NxConst{typ, value}: True{}
    case NxVar{name}: Bool.not(nx_type_equal(nx_lookup(name, env), NxPtr{})) || nx_p_has_address(nx_m_pointer(name, pointers))
    case NxBin{op, left, right}: nx_p_known(left, env, pointers) && nx_p_known(right, env, pointers)
    case NxOffset{ptr, bytes}: nx_p_has_address(nx_m_address(expr, pointers))
    case _: False{}

def nx_p_has_address(address: Maybe<&2, NxMAddr>) -> Bool:
  match address:
    case None{}: False{}
    case Some{value}: True{}

@unsafe
def nx_p_fields_count(+fields: List<&2, NxPField>) -> U32:
  match fields:
    case Nil{}: 0
    case Con{head, rest}: U32.inc(nx_p_fields_count(rest))

@unsafe
def nx_p_find_field(+address: NxMAddr, +typ: NxType, +fields: List<&2, NxPField>) -> NxPFound:
  match fields:
    case Nil{}: NxPFound{None{}, True{}}
    case Con{NxPField{key, kind, index}, rest}:
      nx_choose(NxPFound, nx_m_equal(address, key) && nx_type_equal(typ, kind),
        u => NxPFound{Some{NxPField{key, kind, index}}, True{}},
        u => nx_choose(NxPFound, nx_m_disjoint(address, nx_m_width(typ), key, nx_m_width(kind)),
          v => nx_p_find_field(address, typ, rest), v => NxPFound{None{}, False{}}))

@unsafe
def nx_p_access(+address: Maybe<&2, NxMAddr>, +typ: NxType, +state: NxPState, +prefix: String) -> NxPAccess:
  match address state:
    case None{} _: NxPAccess{"", nx_p_fail(state)}
    case Some{key} NxPState{pointers, fields, next, ok}:
      nx_p_access_found(nx_p_find_field(key, typ, fields), key, typ, state, prefix)

@unsafe
def nx_p_access_found(+found: NxPFound, +address: NxMAddr, +typ: NxType, +state: NxPState, +prefix: String) -> NxPAccess:
  match found state:
    case NxPFound{Some{NxPField{key, kind, index}}, valid} _:
      NxPAccess{prefix ++ U32.show(index), state}
    case NxPFound{None{}, valid} NxPState{pointers, fields, next, ok}:
      nx_choose(NxPAccess, valid && U32.is_lt(nx_p_fields_count(fields), 128),
        u => nx_p_new_field(address, typ, nx_p_fields_count(fields), state, prefix),
        u => NxPAccess{"", nx_p_fail(state)})

def nx_p_new_field(+address: NxMAddr, +typ: NxType, +index: U32, +state: NxPState, +prefix: String) -> NxPAccess:
  match state:
    case NxPState{pointers, fields, next, ok}:
      NxPAccess{prefix ++ U32.show(index), NxPState{pointers, Con{NxPField{address, typ, index}, fields}, next, ok}}

@unsafe
def nx_p_expr(+expr: NxExpr, +env: List<&2, NxParam>, +state: NxPState, +prefix: String) -> NxPExpr:
  match expr state:
    case NxLoad{typ, ptr, offset} NxPState{pointers, fields, next, ok}:
      nx_choose(NxPExpr, nx_scalar(typ),
        u => nx_p_loaded(expr, nx_p_access(nx_m_access(ptr, offset, typ, pointers), typ, state, prefix), prefix),
        u => NxPExpr{expr, nx_p_fail(state)})
    case _ NxPState{pointers, fields, next, ok}:
      NxPExpr{expr, nx_choose(NxPState, nx_p_known(expr, env, pointers), u => state, u => nx_p_fail(state))}

def nx_p_loaded(+original: NxExpr, +access: NxPAccess, +prefix: String) -> NxPExpr:
  match access:
    case NxPAccess{name, state}: NxPExpr{nx_choose(NxExpr, String.eq(prefix, ""), u => original, u => NxVar{name}), state}

@unsafe
def nx_p_bind(+name: String, +original: NxExpr, +state: NxPState) -> NxPState:
  match state:
    case NxPState{pointers, fields, next, ok}:
      nx_p_bound(name, nx_m_address(original, pointers), NxPState{nx_m_forget_ptr(name, pointers), fields, next, ok})

def nx_p_bound(+name: String, +address: Maybe<&2, NxMAddr>, +state: NxPState) -> NxPState:
  match address state:
    case None{} _: state
    case Some{value} NxPState{pointers, fields, next, ok}: NxPState{Con{NxMPtr{name, value}, pointers}, fields, next, ok}

@unsafe
def nx_p_allocate(+name: String, +bytes: NxExpr, +state: NxPState, +inside: Bool) -> NxPState:
  match bytes state:
    case NxConst{NxU32{}, extent} NxPState{pointers, fields, next, ok}:
      nx_choose(NxPState, Bool.not(inside) && Bool.not(U32.is_eq(extent, 0)),
        u => NxPState{Con{NxMPtr{name, NxMAddr{next, 0, extent}}, nx_m_forget_ptr(name, pointers)}, fields, U32.inc(next), ok},
        u => nx_p_fail(state))
    case _ _: nx_p_fail(state)

@unsafe
def nx_p_drop_root(+root: U32, +pointers: List<&2, NxMPtr>) -> List<&2, NxMPtr>:
  match pointers:
    case Nil{}: []
    case Con{NxMPtr{name, NxMAddr{key, offset, extent}}, rest}:
      nx_choose(List<&2, NxMPtr>, U32.is_eq(root, key), u => nx_p_drop_root(root, rest),
        u => Con{NxMPtr{name, NxMAddr{key, offset, extent}}, nx_p_drop_root(root, rest)})

@unsafe
def nx_p_free(+ptr: NxExpr, +state: NxPState, +inside: Bool) -> NxPState:
  match ptr state:
    case NxConst{NxPtr{}, 0} _: nx_choose(NxPState, inside, u => nx_p_fail(state), u => state)
    case _ NxPState{pointers, fields, next, ok}:
      nx_choose(NxPState, inside, u => nx_p_fail(state), u => nx_p_free_at(nx_m_address(ptr, pointers), state))

@unsafe
def nx_p_free_at(+address: Maybe<&2, NxMAddr>, +state: NxPState) -> NxPState:
  match address state:
    case None{} _: nx_p_fail(state)
    case Some{NxMAddr{root, offset, extent}} NxPState{pointers, fields, next, ok}:
      NxPState{nx_p_drop_root(root, pointers), fields, next, ok && U32.is_eq(offset, 0)}

@unsafe
def nx_p_store(+stmt: NxStmt, +typ: NxType, +ptr: NxExpr, +offset: U32, +value: NxExpr, +env: List<&2, NxParam>, +state: NxPState, +prefix: String) -> NxPBlock:
  match state:
    case NxPState{pointers, fields, next, ok}:
      nx_p_stored(stmt, typ, value, nx_p_access(nx_m_access(ptr, offset, typ, pointers), typ,
        nx_choose(NxPState, nx_p_known(value, env, pointers), u => state, u => nx_p_fail(state)), prefix), prefix)

def nx_p_stored(+original: NxStmt, +typ: NxType, +value: NxExpr, +access: NxPAccess, +prefix: String) -> NxPBlock:
  match access:
    case NxPAccess{name, state}:
      NxPBlock{[nx_choose(NxStmt, nx_scalar(typ) && Bool.not(String.eq(prefix, "")), u => NxSet{name, value}, u => original)], state}

@unsafe
def nx_p_body(+body: List<&2, NxStmt>, +env: List<&2, NxParam>, +state: NxPState, +prefix: String, +inside: Bool) -> NxPBlock:
  match body:
    case Nil{}: NxPBlock{[], state}
    case Con{head, rest}: nx_p_after(nx_p_stmt(head, env, state, prefix, inside), rest, env, prefix, inside)

@unsafe
def nx_p_after(+head: NxPBlock, +rest: List<&2, NxStmt>, +env: List<&2, NxParam>, +prefix: String, +inside: Bool) -> NxPBlock:
  match head:
    case NxPBlock{body, state}: nx_p_prepend(body, nx_p_body(rest, env, state, prefix, inside))

@unsafe
def nx_p_prepend(+head: List<&2, NxStmt>, +tail: NxPBlock) -> NxPBlock:
  match tail:
    case NxPBlock{body, state}: NxPBlock{nx_i_join(head, body), state}

@unsafe
def nx_p_stmt(+stmt: NxStmt, +env: List<&2, NxParam>, +state: NxPState, +prefix: String, +inside: Bool) -> NxPBlock:
  match stmt:
    case NxSet{name, NxAlloc{bytes}}: NxPBlock{[stmt], nx_p_allocate(name, bytes, state, inside)}
    case NxSet{name, value}: nx_p_set(name, value, nx_p_expr(value, env, state, prefix))
    case NxReturn{value}: nx_p_return(nx_p_expr(value, env, state, prefix))
    case NxStore{typ, ptr, offset, value}: nx_p_store(stmt, typ, ptr, offset, value, env, state, prefix)
    case NxFree{ptr}: NxPBlock{[stmt], nx_p_free(ptr, state, inside)}
    case NxIf{condition, yes, no}: NxPBlock{[stmt], nx_p_fail(state)}
    case NxWhile{condition, body}:
      nx_choose(NxPBlock, inside, u => NxPBlock{[stmt], nx_p_fail(state)},
        u => nx_p_loop(condition, body, env, state, prefix))

@unsafe
def nx_p_set(+name: String, +original: NxExpr, +result: NxPExpr) -> NxPBlock:
  match result:
    case NxPExpr{value, state}: NxPBlock{[NxSet{name, value}], nx_p_bind(name, original, state)}

def nx_p_return(+result: NxPExpr) -> NxPBlock:
  match result:
    case NxPExpr{value, state}: NxPBlock{[NxReturn{value}], state}

@unsafe
def nx_p_loop(+condition: NxExpr, +body: List<&2, NxStmt>, +env: List<&2, NxParam>, +state: NxPState, +prefix: String) -> NxPBlock:
  match state:
    case NxPState{pointers, fields, next, ok}:
      nx_p_loop_stable(condition, body, env, state, prefix, nx_m_assigned(body, NxMState{pointers, [], next, [], True{}}))

@unsafe
def nx_p_loop_stable(+condition: NxExpr, +body: List<&2, NxStmt>, +env: List<&2, NxParam>, +state: NxPState, +prefix: String, +stable: NxMState) -> NxPBlock:
  match state stable:
    case NxPState{oldp, fields, next, ok} NxMState{pointers, cells, mn, writes, known}:
      nx_p_loop_done(condition, pointers, nx_p_body(body, env,
        NxPState{pointers, fields, next, ok && nx_p_known(condition, env, pointers)}, prefix, True{}))

def nx_p_loop_done(+condition: NxExpr, +pointers: List<&2, NxMPtr>, +result: NxPBlock) -> NxPBlock:
  match result:
    case NxPBlock{body, NxPState{ignored, fields, next, ok}}: NxPBlock{[NxWhile{condition, body}], NxPState{pointers, fields, next, ok}}

@unsafe
def nx_p_locals(+fields: List<&2, NxPField>, +prefix: String) -> List<&2, NxParam>:
  match fields:
    case Nil{}: []
    case Con{NxPField{address, typ, index}, rest}:
      nx_choose(List<&2, NxParam>, nx_scalar(typ),
        u => Con{NxParam{prefix ++ U32.show(index), typ}, nx_p_locals(rest, prefix)}, u => nx_p_locals(rest, prefix))

@unsafe
def nx_p_prefix(+fields: List<&2, NxPField>, +env: List<&2, NxParam>, +attempt: U32) -> Maybe<&2, String>:
  nx_choose(Maybe<&2, String>, U32.is_eq(attempt, 64), u => None{},
    u => nx_p_prefix_check("p107_p" ++ U32.show(attempt) ++ "_f", fields, env, attempt))

@unsafe
def nx_p_prefix_check(+prefix: String, +fields: List<&2, NxPField>, +env: List<&2, NxParam>, +attempt: U32) -> Maybe<&2, String>:
  nx_choose(Maybe<&2, String>, nx_i_disjoint(nx_p_locals(fields, prefix), env),
    u => Some{prefix}, u => nx_p_prefix(fields, env, U32.inc(attempt)))

@unsafe
def nx_p_function(+function: NxFunction) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, nx_scalar(result) && nx_i_scalar_params(params) && U32.is_le(nx_i_body_nodes(body), 4096),
        u => nx_p_analyzed(function, nx_p_body(body, nx_params_join(params, locals), NxPState{[], [], 0, True{}}, "", False{})),
        u => function)

@unsafe
def nx_p_analyzed(+function: NxFunction, +analysis: NxPBlock) -> NxFunction:
  match function analysis:
    case NxFunction{name, params, result, locals, body} NxPBlock{ignored, NxPState{pointers, fields, next, ok}}:
      nx_choose(NxFunction, ok && Bool.not(U32.is_eq(nx_p_fields_count(fields), 0)),
        u => nx_p_rewrite(function, fields, nx_p_prefix(fields, nx_params_join(params, locals), 0)), u => function)

@unsafe
def nx_p_rewrite(+function: NxFunction, +fields: List<&2, NxPField>, +prefix: Maybe<&2, String>) -> NxFunction:
  match function prefix:
    case _ None{}: function
    case NxFunction{name, params, result, locals, body} Some{stem}:
      nx_p_rewritten(function, stem, fields,
        nx_p_body(body, nx_params_join(params, locals), NxPState{[], fields, 0, True{}}, stem, False{}))

@unsafe
def nx_p_rewritten(+function: NxFunction, +prefix: String, +fields: List<&2, NxPField>, +rewritten: NxPBlock) -> NxFunction:
  match function rewritten:
    case NxFunction{name, params, result, locals, oldbody} NxPBlock{body, NxPState{pointers, finalfields, next, ok}}:
      nx_choose(NxFunction, ok && U32.is_eq(nx_p_fields_count(fields), nx_p_fields_count(finalfields)),
        u => NxFunction{name, params, result, nx_params_join(locals, nx_p_locals(fields, prefix)), body}, u => function)

@unsafe
def nx_p_functions(+functions: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match functions:
    case Nil{}: []
    case Con{head, rest}: Con{nx_p_function(head), nx_p_functions(rest)}

@unsafe
def nx_p_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, functions}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(functions), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_m_verify(NxProgram{entry, nx_p_functions(functions)}, program), u => program)

@unsafe
def nx_p_allocation_stmt(+stmt: NxStmt) -> Bool:
  match stmt:
    case NxSet{name, NxAlloc{bytes}}: True{}
    case NxIf{condition, yes, no}: nx_p_allocation_body(yes) || nx_p_allocation_body(no)
    case NxWhile{condition, body}: nx_p_allocation_body(body)
    case _: False{}

@unsafe
def nx_p_allocation_body(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{head, rest}: nx_p_allocation_stmt(head) || nx_p_allocation_body(rest)

@unsafe
def nx_p_allocation_functions(+functions: List<&2, NxFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{NxFunction{name, params, result, locals, body}, rest}: nx_p_allocation_body(body) || nx_p_allocation_functions(rest)

@unsafe
def nx_p_has_allocation(+program: NxProgram) -> Bool:
  match program:
    case NxProgram{entry, functions}: nx_p_allocation_functions(functions)

# Fresh allocations are necessary for this pass. Avoid verification/analysis
# when promotion is impossible; invalid inputs also remain exactly unchanged.
@unsafe
def nx_scalar_promote(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_p_has_allocation(program),
    u => nx_choose(NxProgram, nx_verify(program), v => nx_p_program(program), v => program), u => program)
