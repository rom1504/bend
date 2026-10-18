# Sequential, bounded load forwarding from fresh allocation provenance.
# Never deletes/moves a store, allocation or free. Unknown effects erase facts.
type NxMAddr is Data:
  NxMAddr{+root: U32, +offset: U32, +extent: U32}
type NxMPtr is Data:
  NxMPtr{+name: String, +address: NxMAddr}
type NxMCell is Data:
  NxMCell{+address: NxMAddr, +typ: NxType, +value: NxExpr}
type NxMWrite is Data:
  NxMWrite{+address: NxMAddr, +width: U32}
type NxMState is Data:
  NxMState{+pointers: List<&2, NxMPtr>, +cells: List<&2, NxMCell>, +next: U32, +writes: List<&2, NxMWrite>, +known: Bool}
type NxMBlock is Data:
  NxMBlock{+body: List<&2, NxStmt>, +state: NxMState}

def nx_m_empty(next: U32) -> NxMState:
  NxMState{[], [], next, [], False{}}

def nx_m_width(typ: NxType) -> U32:
  match typ:
    case NxU32{}: 4
    case _: 8

# Atomic stored values never increase expression size when replacing a load.
def nx_m_atom(value: NxExpr) -> Bool:
  match value:
    case NxConst{typ, value}: True{}
    case NxVar{name}: True{}
    case NxFunc{name}: True{}
    case _: False{}

# Subtraction is guarded; no potentially overflowing end-address addition.
def nx_m_disjoint(+a: NxMAddr, +aw: U32, +b: NxMAddr, +bw: U32) -> Bool:
  match a b:
    case NxMAddr{ar, ao, ae} NxMAddr{br, bo, be}:
      Bool.not(U32.is_eq(ar, br)) || nx_choose(Bool, U32.is_le(ao, bo),
        u => U32.is_le(aw, U32.sub(bo, ao)), u => U32.is_le(bw, U32.sub(ao, bo)))

def nx_m_equal(a: NxMAddr, b: NxMAddr) -> Bool:
  match a b:
    case NxMAddr{ar, ao, ae} NxMAddr{br, bo, be}: U32.is_eq(ar, br) && U32.is_eq(ao, bo)

@unsafe
def nx_m_pointer(+name: String, +pointers: List<&2, NxMPtr>) -> Maybe<&2, NxMAddr>:
  match pointers:
    case Nil{}: None{}
    case Con{NxMPtr{key, address}, rest}:
      nx_choose(Maybe<&2, NxMAddr>, String.eq(name, key), u => Some{address}, u => nx_m_pointer(name, rest))

def nx_m_offset(+base: Maybe<&2, NxMAddr>, +offset: U32) -> Maybe<&2, NxMAddr>:
  match base:
    case None{}: None{}
    case Some{NxMAddr{root, start, extent}}:
      nx_choose(Maybe<&2, NxMAddr>, U32.is_le(start, extent) && U32.is_le(offset, U32.sub(extent, start)),
        u => Some{NxMAddr{root, U32.add(start, offset), extent}}, u => None{})

@unsafe
def nx_m_address(+expr: NxExpr, +pointers: List<&2, NxMPtr>) -> Maybe<&2, NxMAddr>:
  match expr:
    case NxVar{name}: nx_m_pointer(name, pointers)
    case NxOffset{ptr, NxConst{NxU32{}, offset}}: nx_m_offset(nx_m_address(ptr, pointers), offset)
    case _: None{}

def nx_m_range(+address: Maybe<&2, NxMAddr>, +width: U32) -> Maybe<&2, NxMAddr>:
  match address:
    case None{}: None{}
    case Some{NxMAddr{root, offset, extent}}:
      nx_choose(Maybe<&2, NxMAddr>, U32.is_le(width, extent) && U32.is_le(offset, U32.sub(extent, width)),
        u => address, u => None{})

@unsafe
def nx_m_access(+ptr: NxExpr, +offset: U32, +typ: NxType, +pointers: List<&2, NxMPtr>) -> Maybe<&2, NxMAddr>:
  nx_m_range(nx_m_offset(nx_m_address(ptr, pointers), offset), nx_m_width(typ))

@unsafe
def nx_m_uses(+expr: NxExpr, +name: String) -> Bool:
  match expr:
    case NxVar{key}: String.eq(key, name)
    case NxBin{op, left, right}: nx_m_uses(left, name) || nx_m_uses(right, name)
    case NxOffset{ptr, bytes}: nx_m_uses(ptr, name) || nx_m_uses(bytes, name)
    case _: False{}

@unsafe
def nx_m_forget_ptr(+name: String, +pointers: List<&2, NxMPtr>) -> List<&2, NxMPtr>:
  match pointers:
    case Nil{}: []
    case Con{NxMPtr{key, address}, rest}:
      nx_choose(List<&2, NxMPtr>, String.eq(name, key), u => nx_m_forget_ptr(name, rest),
        u => Con{NxMPtr{key, address}, nx_m_forget_ptr(name, rest)})

@unsafe
def nx_m_forget_cells(+name: String, +cells: List<&2, NxMCell>) -> List<&2, NxMCell>:
  match cells:
    case Nil{}: []
    case Con{NxMCell{address, typ, value}, rest}:
      nx_choose(List<&2, NxMCell>, nx_m_uses(value, name), u => nx_m_forget_cells(name, rest),
        u => Con{NxMCell{address, typ, value}, nx_m_forget_cells(name, rest)})

@unsafe
def nx_m_forget(+name: String, +state: NxMState) -> NxMState:
  match state:
    case NxMState{pointers, cells, next, writes, known}:
      NxMState{nx_m_forget_ptr(name, pointers), nx_m_forget_cells(name, cells), next, writes, known}

@unsafe
def nx_m_lookup(+address: NxMAddr, +typ: NxType, +cells: List<&2, NxMCell>) -> Maybe<&2, NxExpr>:
  match cells:
    case Nil{}: None{}
    case Con{NxMCell{key, kind, value}, rest}:
      nx_choose(Maybe<&2, NxExpr>, nx_m_equal(address, key) && nx_type_equal(typ, kind),
        u => Some{value}, u => nx_m_lookup(address, typ, rest))

@unsafe
def nx_m_overwrite(+address: NxMAddr, +width: U32, +cells: List<&2, NxMCell>) -> List<&2, NxMCell>:
  match cells:
    case Nil{}: []
    case Con{NxMCell{key, typ, value}, rest}:
      nx_choose(List<&2, NxMCell>, nx_m_disjoint(address, width, key, nx_m_width(typ)),
        u => Con{NxMCell{key, typ, value}, nx_m_overwrite(address, width, rest)}, u => nx_m_overwrite(address, width, rest))

def nx_m_value(+found: Maybe<&2, NxExpr>, +original: NxExpr) -> NxExpr:
  match found:
    case None{}: original
    case Some{value}: value

@unsafe
def nx_m_forward(+expr: NxExpr, +state: NxMState) -> NxExpr:
  match expr state:
    case NxLoad{typ, ptr, offset} NxMState{pointers, cells, next, writes, known}:
      nx_m_forward_at(nx_m_access(ptr, offset, typ, pointers), typ, expr, cells)
    case _ _: expr

@unsafe
def nx_m_forward_at(+address: Maybe<&2, NxMAddr>, +typ: NxType, +original: NxExpr, +cells: List<&2, NxMCell>) -> NxExpr:
  match address:
    case None{}: original
    case Some{key}: nx_m_value(nx_m_lookup(key, typ, cells), original)

def nx_m_bind_pointer(+name: String, +address: Maybe<&2, NxMAddr>, +state: NxMState) -> NxMState:
  match address state:
    case None{} _: state
    case Some{value} NxMState{pointers, cells, next, writes, known}:
      NxMState{Con{NxMPtr{name, value}, pointers}, cells, next, writes, known}

@unsafe
def nx_m_record_load(+name: String, +original: NxExpr, +before: NxMState, +after: NxMState) -> NxMState:
  match original before:
    case NxLoad{typ, ptr, offset} NxMState{pointers, cells, next, writes, known}:
      nx_m_record_at(nx_m_access(ptr, offset, typ, pointers), typ, NxVar{name}, after)
    case _ _: after

@unsafe
def nx_m_record_at(+address: Maybe<&2, NxMAddr>, +typ: NxType, +value: NxExpr, +state: NxMState) -> NxMState:
  match address state:
    case None{} _: state
    case Some{key} NxMState{pointers, cells, next, writes, known}:
      NxMState{pointers, Con{NxMCell{key, typ, value}, nx_m_overwrite(key, nx_m_width(typ), cells)}, next, writes, known}

@unsafe
def nx_m_assignment(+name: String, +original: NxExpr, +value: NxExpr, +before: NxMState) -> NxMState:
  match before:
    case NxMState{pointers, cells, next, writes, known}:
      nx_m_record_load(name, original, before,
        nx_m_bind_pointer(name, nx_m_address(value, pointers), nx_m_forget(name, before)))

@unsafe
def nx_m_allocate(+name: String, +bytes: NxExpr, +before: NxMState) -> NxMState:
  match bytes before:
    case NxConst{NxU32{}, extent} NxMState{pointers, cells, next, writes, known}:
      nx_choose(NxMState, U32.is_eq(extent, 0), u => nx_m_empty(next),
        u => nx_m_allocated(name, NxMAddr{next, 0, extent}, nx_m_forget(name, before)))
    case _ NxMState{pointers, cells, next, writes, known}: nx_m_empty(next)

def nx_m_allocated(+name: String, +address: NxMAddr, +state: NxMState) -> NxMState:
  match state:
    case NxMState{pointers, cells, next, writes, known}:
      NxMState{Con{NxMPtr{name, address}, pointers}, cells, U32.inc(next), writes, False{}}

@unsafe
def nx_m_store(+ptr: NxExpr, +offset: U32, +typ: NxType, +value: NxExpr, +state: NxMState) -> NxMState:
  match state:
    case NxMState{pointers, cells, next, writes, known}:
      nx_m_store_at(nx_m_access(ptr, offset, typ, pointers), typ, value, state)

@unsafe
def nx_m_store_at(+address: Maybe<&2, NxMAddr>, +typ: NxType, +value: NxExpr, +state: NxMState) -> NxMState:
  match address state:
    case None{} NxMState{pointers, cells, next, writes, known}: NxMState{pointers, [], next, writes, False{}}
    case Some{key} NxMState{pointers, cells, next, writes, known}:
      NxMState{pointers, nx_choose(List<&2, NxMCell>, nx_m_atom(value),
        u => Con{NxMCell{key, typ, value}, nx_m_overwrite(key, nx_m_width(typ), cells)},
        u => nx_m_overwrite(key, nx_m_width(typ), cells)), next,
        Con{NxMWrite{key, nx_m_width(typ)}, writes}, known}

@unsafe
def nx_m_body(+body: List<&2, NxStmt>, +state: NxMState, +loops: Bool) -> NxMBlock:
  match body:
    case Nil{}: NxMBlock{[], state}
    case Con{head, rest}: nx_m_after(nx_m_stmt(head, state, loops), rest, loops)

@unsafe
def nx_m_after(+head: NxMBlock, +rest: List<&2, NxStmt>, +loops: Bool) -> NxMBlock:
  match head:
    case NxMBlock{body, state}: nx_m_prepend(body, nx_m_body(rest, state, loops))

@unsafe
def nx_m_prepend(+head: List<&2, NxStmt>, +tail: NxMBlock) -> NxMBlock:
  match tail:
    case NxMBlock{body, state}: NxMBlock{nx_i_join(head, body), state}

@unsafe
def nx_m_stmt(+stmt: NxStmt, +state: NxMState, +loops: Bool) -> NxMBlock:
  match stmt state:
    case NxSet{name, NxAlloc{bytes}} _: NxMBlock{[stmt], nx_m_allocate(name, bytes, state)}
    case NxSet{name, NxCall{target, args}} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxSet{name, NxICall{callee, args, params, result}} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxSet{name, value} _: nx_m_set(name, value, nx_m_forward(value, state), state)
    case NxStore{typ, ptr, offset, value} _: NxMBlock{[stmt], nx_m_store(ptr, offset, typ, value, state)}
    case NxFree{ptr} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxReturn{NxCall{target, args}} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxReturn{NxICall{callee, args, params, result}} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxReturn{NxAlloc{bytes}} NxMState{pointers, cells, next, writes, known}: NxMBlock{[stmt], nx_m_empty(next)}
    case NxReturn{value} _: NxMBlock{[NxReturn{nx_m_forward(value, state)}], state}
    case NxIf{condition, yes, no} NxMState{pointers, cells, next, writes, known}:
      nx_m_if(condition, nx_m_body(yes, nx_m_empty(next), loops), nx_m_body(no, nx_m_empty(next), loops), next)
    case NxWhile{condition, body} NxMState{pointers, cells, next, writes, known}:
      nx_choose(NxMBlock, loops, u => nx_m_loop(condition, body, state), u => NxMBlock{[stmt], nx_m_empty(next)})

@unsafe
def nx_m_set(+name: String, +original: NxExpr, +value: NxExpr, +state: NxMState) -> NxMBlock:
  NxMBlock{[NxSet{name, value}], nx_m_assignment(name, original, value, state)}

def nx_m_if(+condition: NxExpr, +yes: NxMBlock, +no: NxMBlock, +next: U32) -> NxMBlock:
  match yes no:
    case NxMBlock{yb, ys} NxMBlock{nb, ns}: NxMBlock{[NxIf{condition, yb, nb}], nx_m_empty(next)}

# Loop candidates must not depend on locals assigned anywhere in the body.
@unsafe
def nx_m_assigned(+body: List<&2, NxStmt>, +state: NxMState) -> NxMState:
  match body:
    case Nil{}: state
    case Con{NxSet{name, value}, rest}: nx_m_assigned(rest, nx_m_forget(name, state))
    case Con{NxIf{condition, yes, no}, rest}: nx_m_assigned(rest, nx_m_assigned(yes, nx_m_assigned(no, state)))
    case Con{NxWhile{condition, loop}, rest}: nx_m_assigned(rest, nx_m_assigned(loop, state))
    case Con{head, rest}: nx_m_assigned(rest, state)

def nx_m_seed(+state: NxMState) -> NxMState:
  match state:
    case NxMState{pointers, cells, next, writes, known}: NxMState{pointers, cells, next, [], True{}}

@unsafe
def nx_m_stable(+address: NxMAddr, +width: U32, +writes: List<&2, NxMWrite>) -> Bool:
  match writes:
    case Nil{}: True{}
    case Con{NxMWrite{key, size}, rest}: nx_m_disjoint(address, width, key, size) && nx_m_stable(address, width, rest)

@unsafe
def nx_m_filter_writes(+cells: List<&2, NxMCell>, +writes: List<&2, NxMWrite>) -> List<&2, NxMCell>:
  match cells:
    case Nil{}: []
    case Con{NxMCell{address, typ, value}, rest}:
      nx_choose(List<&2, NxMCell>, nx_m_stable(address, nx_m_width(typ), writes),
        u => Con{NxMCell{address, typ, value}, nx_m_filter_writes(rest, writes)}, u => nx_m_filter_writes(rest, writes))

@unsafe
def nx_m_all_stable(+cells: List<&2, NxMCell>, +writes: List<&2, NxMWrite>) -> Bool:
  match cells:
    case Nil{}: True{}
    case Con{NxMCell{address, typ, value}, rest}: nx_m_stable(address, nx_m_width(typ), writes) && nx_m_all_stable(rest, writes)

@unsafe
def nx_m_loop(+condition: NxExpr, +body: List<&2, NxStmt>, +state: NxMState) -> NxMBlock:
  nx_m_loop_seed(condition, body, nx_m_seed(nx_m_assigned(body, state)))

@unsafe
def nx_m_loop_seed(+condition: NxExpr, +body: List<&2, NxStmt>, +seed: NxMState) -> NxMBlock:
  nx_m_loop_probe(condition, body, seed, nx_m_body(body, seed, False{}))

@unsafe
def nx_m_loop_probe(+condition: NxExpr, +body: List<&2, NxStmt>, +seed: NxMState, +probe: NxMBlock) -> NxMBlock:
  match seed probe:
    case NxMState{pointers, cells, next, oldwrites, oldknown} NxMBlock{ignored, NxMState{pp, pc, pn, writes, known}}:
      nx_choose(NxMBlock, known,
        u => nx_m_loop_validate(condition, body, NxMState{pointers, nx_m_filter_writes(cells, writes), next, [], True{}}),
        u => NxMBlock{[NxWhile{condition, body}], nx_m_empty(next)})

@unsafe
def nx_m_loop_validate(+condition: NxExpr, +body: List<&2, NxStmt>, +seed: NxMState) -> NxMBlock:
  nx_m_loop_done(condition, body, seed, nx_m_body(body, seed, False{}))

@unsafe
def nx_m_loop_done(+condition: NxExpr, +original: List<&2, NxStmt>, +seed: NxMState, +candidate: NxMBlock) -> NxMBlock:
  match seed candidate:
    case NxMState{pointers, cells, next, oldwrites, oldknown} NxMBlock{body, NxMState{pp, pc, pn, writes, known}}:
      nx_choose(NxMBlock, known && nx_m_all_stable(cells, writes),
        u => NxMBlock{[NxWhile{condition, body}], seed},
        u => NxMBlock{[NxWhile{condition, original}], nx_m_empty(next)})

@unsafe
def nx_m_function(+function: NxFunction) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, U32.is_le(nx_i_body_nodes(body), 4096),
        u => nx_m_function_done(function, nx_m_body(body, nx_m_empty(0), True{})), u => function)

def nx_m_function_done(+function: NxFunction, +block: NxMBlock) -> NxFunction:
  match function block:
    case NxFunction{name, params, result, locals, oldbody} NxMBlock{body, state}: NxFunction{name, params, result, locals, body}

@unsafe
def nx_m_functions(+functions: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match functions:
    case Nil{}: []
    case Con{head, rest}: Con{nx_m_function(head), nx_m_functions(rest)}

@unsafe
def nx_m_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, functions}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(functions), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_m_verify(NxProgram{entry, nx_m_functions(functions)}, program), u => program)

@unsafe
def nx_m_verify(+candidate: NxProgram, +original: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(candidate), u => candidate, u => original)

@unsafe
def nx_memory_forward(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(program), u => nx_m_program(program), u => program)
