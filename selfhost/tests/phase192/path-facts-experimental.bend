# Experimental pure-value numbering and branch facts. Never numbers memory.
# Mutable names bind immutable IDs. Calls, joins and backedges reset all facts.
# Saturation allocates fresh opaque IDs; it never conflates unknown values.
type X192PFExpr is Data:
  X192PFExpr{+id: U32, +kind: U32, +width: U32, +label: String, +a: U32, +b: U32, +boolean: Bool}
type X192PFState is Data:
  X192PFState{+locals: KDef, +expressions: List<&2,X192PFExpr>, +truth: KDef, +next: U32, +count: U32}
type X192PFValue is Data:
  X192PFValue{+number: U32, +state: X192PFState}

def x192_path_facts_enabled() -> Bool: True{}
def x192pf_empty() -> X192PFState: X192PFState{missing(),[],missing(),1,0}

@unsafe
def x192pf_find(expressions: List<&2,X192PFExpr>, +kind: U32, +width: U32,
    +label: String, +a: U32, +b: U32) -> U32:
  match expressions:
    case Nil{}: 0
    case Con{X192PFExpr{id,k,w,s,x,y,boolean},rest}:
      nt_choose(U32,U32.is_eq(kind,k) && U32.is_eq(width,w) && String.eq(label,s) && U32.is_eq(a,x) && U32.is_eq(b,y),
        u => id,u => x192pf_find(rest,kind,width,label,a,b))

@unsafe
def x192pf_get(expressions: List<&2,X192PFExpr>, +id: U32) -> X192PFExpr:
  match expressions:
    case Nil{}: X192PFExpr{0,0,0,"",0,0,False{}}
    case Con{+head,rest}:
      match head:
        case X192PFExpr{n,kind,width,label,a,b,boolean}:
          nt_choose(X192PFExpr,U32.is_eq(id,n),u => head,u => x192pf_get(rest,id))

@unsafe
def x192pf_expr(id: U32, state: X192PFState) -> X192PFExpr:
  match state:
    case X192PFState{locals,expressions,truth,next,count}: x192pf_get(expressions,id)

def x192pf_bool_expr(expr: X192PFExpr) -> Bool:
  match expr:
    case X192PFExpr{id,kind,width,label,a,b,boolean}: boolean

def x192pf_boolean(id: U32, state: X192PFState) -> Bool: x192pf_bool_expr(x192pf_expr(id,state))

@unsafe
def x192pf_fresh(state: X192PFState) -> X192PFValue:
  match state:
    case X192PFState{locals,expressions,truth,+next,count}:
      X192PFValue{next,X192PFState{locals,expressions,truth,U32.inc(next),count}}

@unsafe
def x192pf_interned(+found: U32, kind: U32, width: U32, label: String, a: U32, b: U32,
    boolean: Bool, +state: X192PFState) -> X192PFValue:
  match state:
    case X192PFState{locals,expressions,truth,+next,+count}:
      nt_choose(X192PFValue,U32.is_gt(found,0),u => X192PFValue{found,state},u =>
        nt_choose(X192PFValue,U32.is_lt(count,96),v =>
          X192PFValue{next,X192PFState{locals,Con{X192PFExpr{next,kind,width,label,a,b,boolean},expressions},truth,U32.inc(next),U32.inc(count)}},
          v => x192pf_fresh(state)))

@unsafe
def x192pf_intern(+kind: U32, +width: U32, +label: String, +a: U32, +b: U32,
    boolean: Bool, +state: X192PFState) -> X192PFValue:
  match state:
    case X192PFState{locals,expressions,truth,next,count}:
      x192pf_interned(x192pf_find(expressions,kind,width,label,a,b),kind,width,label,a,b,boolean,state)

@unsafe
def x192pf_bind(name: String, number: U32, state: X192PFState) -> X192PFState:
  match state:
    case X192PFState{locals,expressions,truth,next,count}:
      X192PFState{p111v_put(locals,name,"X192PFLocal",number,0),expressions,truth,next,count}

@unsafe
def x192pf_local_new(name: String, value: X192PFValue) -> X192PFValue:
  match value:
    case X192PFValue{+number,state}: X192PFValue{number,x192pf_bind(name,number,state)}

@unsafe
def x192pf_local(+name: String, +state: X192PFState) -> X192PFValue:
  match state:
    case X192PFState{locals,expressions,truth,next,count}:
      +number = da(p111v_get(locals,name))
      nt_choose(X192PFValue,U32.is_gt(number,0),u => X192PFValue{number,state},
        u => x192pf_local_new(name,x192pf_fresh(state)))

@unsafe
def x192pf_value(value: N111Value, +state: X192PFState) -> X192PFValue:
  match value:
    case N111Local{name}: x192pf_local(name,state)
    case N111Const{+lo,+hi}: x192pf_intern(1,0,"",lo,hi,U32.is_eq(hi,0) && U32.is_le(lo,1),state)
    case N111CtorId{name}: x192pf_intern(2,0,name,0,0,False{},state)
    case N111FuncId{name}: x192pf_intern(3,0,name,0,0,False{},state)
    case _: x192pf_fresh(state)

@unsafe
def x192pf_known_expr(expr: X192PFExpr, truth: KDef) -> Maybe<&2,U32>:
  match expr:
    case X192PFExpr{+id,+kind,width,label,+a,b,boolean}:
      +fact = p111v_get(truth,U32.show(id))
      nt_choose(Maybe<&2,U32>,U32.is_eq(kind,1),u => Some{nt_choose(U32,U32.is_eq(a,0),v => 0,v => 1)},u =>
        nt_choose(Maybe<&2,U32>,String.eq(dk(fact),"X192PFTruth"),v => Some{da(fact)},v => None{}))

@unsafe
def x192pf_known(id: U32, +state: X192PFState) -> Maybe<&2,U32>:
  match state:
    case X192PFState{locals,expressions,truth,next,count}: x192pf_known_expr(x192pf_expr(id,state),truth)

@unsafe
def x192pf_mark(id: U32, value: U32, state: X192PFState) -> X192PFState:
  match state:
    case X192PFState{locals,expressions,truth,next,count}:
      X192PFState{locals,expressions,p111v_put(truth,U32.show(id),"X192PFTruth",value,0),next,count}

def x192pf_const_one_expr(expr: X192PFExpr) -> Bool:
  match expr:
    case X192PFExpr{n,kind,width,label,a,b,boolean}: U32.is_eq(kind,1) && U32.is_eq(a,1) && U32.is_eq(b,0)

@unsafe
def x192pf_const_one(id: U32, state: X192PFState) -> Bool:
  x192pf_const_one_expr(x192pf_expr(id,state))

law x192pf_assume:
  for +id: U32
  for +value: U32
  for +state: X192PFState
  for +fuel: U32
  X192PFState

@unsafe
def x192pf_assume_expr(expr: X192PFExpr, +value: U32, +state: X192PFState, +fuel: U32) -> X192PFState:
  match expr:
    case X192PFExpr{id,+kind,width,+label,+a,+b,boolean}:
      nt_choose(X192PFState,U32.is_eq(kind,4) && String.eq(label,"xor") && x192pf_const_one(b,state) && x192pf_boolean(a,state),
        u => x192pf_assume(a,U32.xor(value,1),state,fuel),u =>
      nt_choose(X192PFState,U32.is_eq(kind,4) && ((String.eq(label,"and") && U32.is_eq(value,1)) ||
          (String.eq(label,"or") && U32.is_eq(value,0))) && x192pf_boolean(a,state) && x192pf_boolean(b,state),
        u => x192pf_assume(b,value,x192pf_assume(a,value,state,fuel),fuel),u => state))

@unsafe
def x192pf_assume(id,value,state,fuel):
  nt_choose(X192PFState,U32.is_gt(fuel,0) && x192pf_boolean(id,state),u =>
    x192pf_assume_expr(x192pf_expr(id,state),value,x192pf_mark(id,value,state),U32.sub(fuel,1)),u => state)

# Only total integer operations enter the table. Equality identities do not
# rely on source typing, heap state, ownership, signed overflow or division.
@unsafe
def x192pf_op(+typ: N111Type, +op: String) -> Bool:
  x190_branch_width(typ) && (p111v_comparison(op) || String.eq(op,"add") || String.eq(op,"sub") ||
    String.eq(op,"mul") || String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") ||
    String.eq(op,"shl") || String.eq(op,"shr") || String.eq(op,"sar"))

law x192pf_body:
  for body: List<&2,P113DStmt>
  for state: X192PFState
  List<&2,P113DStmt>

@unsafe
def x192pf_publish(+stmt: N111Stmt, name: String, value: X192PFValue, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match value:
    case X192PFValue{number,state}: Con{P113DScalar{stmt},x192pf_body(rest,x192pf_bind(name,number,state))}

@unsafe
def x192pf_binary_known(+name: String, +typ: N111Type, stmt: N111Stmt, +value: X192PFValue,
    rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match value:
    case X192PFValue{+number,+state}:
      x192pf_binary_result(name,typ,stmt,value,rest,x192pf_known(number,state),x192pf_boolean(number,state))

@unsafe
def x192pf_binary_result(+name: String, typ: N111Type, stmt: N111Stmt, value: X192PFValue,
    rest: List<&2,P113DStmt>, known: Maybe<&2,U32>, boolean: Bool) -> List<&2,P113DStmt>:
  match known:
    case Some{truth}: x192pf_publish(nt_choose(N111Stmt,boolean,
      u => N111Set{name,typ,N111Const{truth,0}},u => stmt),name,value,rest)
    case None{}: x192pf_publish(stmt,name,value,rest)

@unsafe
def x192pf_binary_right(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +a: U32, result: X192PFValue, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match result:
    case X192PFValue{+b,+state}:
      x192pf_binary_known(name,nt_choose(N111Type,p111v_comparison(op),u => N111U32{},u => typ),
        N111Bin{name,typ,op,left,right},x192pf_intern(4,p111v_type(typ),op,a,b,
          p111v_comparison(op) || ((String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor")) &&
            x192pf_boolean(a,state) && x192pf_boolean(b,state)),state),rest)

@unsafe
def x192pf_binary_left(name: String, typ: N111Type, op: String, left: N111Value, +right: N111Value,
    +result: X192PFValue, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match result:
    case X192PFValue{a,state}: x192pf_binary_right(name,typ,op,left,right,a,x192pf_value(right,state),rest)

@unsafe
def x192pf_set_value(+name: String, +typ: N111Type, value: N111Value,
    +result: X192PFValue, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  match result:
    case X192PFValue{+number,+state}:
      x192pf_publish(N111Set{name,typ,value},name,nt_choose(X192PFValue,U32.is_eq(p111v_type(typ),1) && Bool.not(x192pf_boolean(number,state)),
        u => x192pf_intern(5,1,"truncate",number,0,False{},state),u => result),rest)

@unsafe
def x192pf_scalar(+stmt: N111Stmt, +rest: List<&2,P113DStmt>, +state: X192PFState) -> List<&2,P113DStmt>:
  match stmt:
    case N111Bin{+name,+typ,+op,+left,+right}:
      nt_choose(List<&2,P113DStmt>,x192pf_op(typ,op),u =>
        x192pf_binary_left(name,typ,op,left,right,x192pf_value(left,state),rest),u => x192pf_publish(stmt,name,x192pf_fresh(state),rest))
    case N111Set{+name,+typ,+value}:
      nt_choose(List<&2,P113DStmt>,x190_branch_width(typ),u =>
        x192pf_set_value(name,typ,value,x192pf_value(value,state),rest),u => x192pf_publish(stmt,name,x192pf_fresh(state),rest))
    case N111Load{name,typ,base,offset}: x192pf_publish(stmt,name,x192pf_fresh(state),rest)
    case N111Offset{name,base,bytes}: x192pf_publish(stmt,name,x192pf_fresh(state),rest)
    case N111Alloca{name,bytes,align}: x192pf_publish(stmt,name,x192pf_fresh(state),rest)
    case N111Store{typ,base,offset,value}: Con{P113DScalar{stmt},x192pf_body(rest,state)}
    case _: Con{P113DScalar{stmt},x192pf_body(rest,x192pf_empty())}

@unsafe
def x192pf_if_known(known: Maybe<&2,U32>, condition: N111Value, +yes: List<&2,P113DStmt>,
    +no: List<&2,P113DStmt>, +rest: List<&2,P113DStmt>, +number: U32, +state: X192PFState) -> List<&2,P113DStmt>:
  match known:
    case Some{value}: x192pf_body(x190_branch_append(nt_choose(List<&2,P113DStmt>,U32.is_eq(value,0),u => no,u => yes),rest),state)
    case None{}: Con{P113DIf{condition,x192pf_body(yes,x192pf_assume(number,1,state,8)),
      x192pf_body(no,x192pf_assume(number,0,state,8))},x192pf_body(rest,x192pf_empty())}

@unsafe
def x192pf_if_value(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, value: X192PFValue) -> List<&2,P113DStmt>:
  match value:
    case X192PFValue{+number,+state}: x192pf_if_known(x192pf_known(number,state),condition,yes,no,rest,number,state)

@unsafe
def x192pf_if(+condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, state: X192PFState) -> List<&2,P113DStmt>:
  x192pf_if_value(condition,yes,no,rest,x192pf_value(condition,state))

@unsafe
def x192pf_body(body,state):
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x192pf_if(condition,yes,no,rest,state)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}: x192pf_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,state)
    case Con{P113DScalar{stmt},rest}: x192pf_scalar(stmt,rest,state)
    case Con{head,rest}: Con{head,x192pf_body(rest,x192pf_empty())}

@unsafe
def x192_path_facts_body(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x192_path_facts_enabled() && U32.is_le(p113i_size(body),1024),
    u => x192pf_body(body,x192pf_empty()),u => body)
