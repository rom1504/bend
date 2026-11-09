# Bounded straight-line value numbering for pure Bin/Offset expressions. Copy
# aliases are analysis metadata only: every original Set retains its snapshot.
# Every local write kills dependent keys/results/aliases. Unknown effects and
# control edges forget all facts; no memory load or statement is moved.
type X186Expr is Data:
  X186Expr{+name: String, +kind: U32, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value}
type X186Alias is Data:
  X186Alias{+name: String, +value: N111Value}
type X186ExprState is Data:
  X186ExprState{+facts: List<&2,X186Expr>, +aliases: List<&2,X186Alias>}
type X186ExprStep is Data:
  X186ExprStep{+stmt: P113DStmt, +state: X186ExprState}

def x186_expression_enabled() -> Bool: True{}
def x186_e_empty() -> X186ExprState: X186ExprState{[],[]}

@unsafe
def x186_e_equal(left: N111Value, right: N111Value) -> Bool:
  match left right:
    case N111Local{a} N111Local{b}: String.eq(a,b)
    case N111Const{al,ah} N111Const{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
    case N111Symbol{a} N111Symbol{b}: String.eq(a,b)
    case N111FuncId{a} N111FuncId{b}: String.eq(a,b)
    case N111CtorId{a} N111CtorId{b}: String.eq(a,b)
    case _ _: False{}

@unsafe
def x186_e_alias(aliases: List<&2,X186Alias>, +name: String) -> N111Value:
  match aliases:
    case Nil{}: N111Local{name}
    case Con{X186Alias{other,value},rest}:
      nt_choose(N111Value,String.eq(name,other),u => value,u => x186_e_alias(rest,name))

@unsafe
def x186_e_value(value: N111Value, aliases: List<&2,X186Alias>) -> N111Value:
  match value:
    case N111Local{name}: x186_e_alias(aliases,name)
    case _: value

@unsafe
def x186_e_kill_facts(facts: List<&2,X186Expr>, +name: String) -> List<&2,X186Expr>:
  match facts:
    case Nil{}: []
    case Con{+fact,+rest}:
      match fact:
        case X186Expr{result,kind,typ,op,left,right}:
          nt_choose(List<&2,X186Expr>,String.eq(result,name) || x185_sf_source(left,name) || x185_sf_source(right,name),
            u => x186_e_kill_facts(rest,name),u => Con{fact,x186_e_kill_facts(rest,name)})

@unsafe
def x186_e_kill_aliases(aliases: List<&2,X186Alias>, +name: String) -> List<&2,X186Alias>:
  match aliases:
    case Nil{}: []
    case Con{+alias,+rest}:
      match alias:
        case X186Alias{result,value}:
          nt_choose(List<&2,X186Alias>,String.eq(result,name) || x185_sf_source(value,name),
            u => x186_e_kill_aliases(rest,name),u => Con{alias,x186_e_kill_aliases(rest,name)})

@unsafe
def x186_e_written(state: X186ExprState, +name: String) -> X186ExprState:
  match state:
    case X186ExprState{facts,aliases}: X186ExprState{x186_e_kill_facts(facts,name),x186_e_kill_aliases(aliases,name)}

@unsafe
def x186_e_remember_alias(state: X186ExprState, +name: String, +typ: N111Type, +value: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{facts,+aliases}:
      X186ExprState{facts,nt_choose(List<&2,X186Alias>,Bool.not(U32.is_eq(p111v_type(typ),1)) &&
          Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),16),
        u => Con{X186Alias{name,value},aliases},u => aliases)}

@unsafe
def x186_e_set(+stmt: N111Stmt, +name: String, +typ: N111Type, value: N111Value, +state: X186ExprState) -> X186ExprStep:
  x186_e_set_state(state,stmt,name,typ,value)

@unsafe
def x186_e_set_state(+state: X186ExprState, stmt: N111Stmt, +name: String, typ: N111Type, value: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,aliases}:
      X186ExprStep{P113DScalar{stmt},x186_e_remember_alias(x186_e_written(state,name),name,typ,x186_e_value(value,aliases))}

@unsafe
def x186_e_find(facts: List<&2,X186Expr>, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value) -> Maybe<&2,String>:
  match facts:
    case Nil{}: None{}
    case Con{X186Expr{name,other,width,operation,a,b},rest}:
      nt_choose(Maybe<&2,String>,U32.is_eq(kind,other) && U32.is_eq(p111v_type(typ),p111v_type(width)) &&
          String.eq(op,operation) && x186_e_equal(left,a) && x186_e_equal(right,b),
        u => Some{name},u => x186_e_find(rest,kind,typ,op,left,right))

@unsafe
def x186_e_insert(state: X186ExprState, +name: String, kind: U32, typ: N111Type, op: String,
    +left: N111Value, +right: N111Value) -> X186ExprState:
  match state:
    case X186ExprState{+facts,aliases}:
      X186ExprState{nt_choose(List<&2,X186Expr>,Bool.not(x185_sf_source(left,name) || x185_sf_source(right,name)) &&
          U32.is_lt(nt_count(X186Expr,facts),16),
        u => Con{X186Expr{name,kind,typ,op,left,right},facts},u => facts),aliases}

@unsafe
def x186_e_result_type(+kind: U32, typ: N111Type, op: String) -> N111Type:
  nt_choose(N111Type,U32.is_eq(kind,1),u => N111Ptr{},
    u => nt_choose(N111Type,p111v_comparison(op),v => N111U32{},v => typ))

@unsafe
def x186_e_found(found: Maybe<&2,String>, stmt: N111Stmt, +name: String, kind: U32, +typ: N111Type,
    state: X186ExprState) -> X186ExprStep:
  match found:
    case None{}: X186ExprStep{P113DScalar{stmt},state}
    case Some{+source}: X186ExprStep{P113DScalar{nt_choose(N111Stmt,U32.is_eq(kind,1),
        u => stmt,u => N111Set{name,typ,N111Local{source}})},
      x186_e_result_alias(state,name,typ,source)}

# Offset declarations retain their exact capacity-propagating verifier row.
# Their value equivalence may canonicalize later keys, but never replaces that row.
@unsafe
def x186_e_result_alias(state: X186ExprState, name: String, typ: N111Type, source: String) -> X186ExprState:
  match state:
    case X186ExprState{+facts,+aliases}:
      x186_e_remember_alias(X186ExprState{facts,aliases},name,typ,x186_e_alias(aliases,source))

@unsafe
def x186_e_expression(+state: X186ExprState, stmt: N111Stmt, +name: String, +kind: U32,
    +typ: N111Type, +op: String, left: N111Value, right: N111Value) -> X186ExprStep:
  match state:
    case X186ExprState{facts,+aliases}:
      x186_e_key(stmt,name,kind,typ,op,x186_e_value(left,aliases),x186_e_value(right,aliases),facts,x186_e_written(state,name))

@unsafe
def x186_e_key(stmt: N111Stmt, +name: String, +kind: U32, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, facts: List<&2,X186Expr>, state: X186ExprState) -> X186ExprStep:
  x186_e_found(x186_e_find(facts,kind,typ,op,left,right),stmt,name,kind,x186_e_result_type(kind,typ,op),
    x186_e_insert(state,name,kind,typ,op,left,right))

@unsafe
def x186_e_scalar(+stmt: N111Stmt, +state: X186ExprState) -> X186ExprStep:
  match stmt:
    case N111Set{name,typ,value}: x186_e_set(stmt,name,typ,value,state)
    case N111Bin{name,typ,op,left,right}: x186_e_expression(state,stmt,name,0,typ,op,left,right)
    case N111Offset{name,base,bytes}: x186_e_expression(state,stmt,name,1,N111Ptr{},"offset",base,bytes)
    case N111Load{name,typ,base,offset}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case N111Alloca{name,bytes,align}: X186ExprStep{P113DScalar{stmt},x186_e_written(state,name)}
    case _: X186ExprStep{P113DScalar{stmt},x186_e_empty()}

law x186_e_body:
  for body: List<&2,P113DStmt>
  for state: X186ExprState
  List<&2,P113DStmt>

@unsafe
def x186_e_after(rest: List<&2,P113DStmt>, step: X186ExprStep) -> List<&2,P113DStmt>:
  match step:
    case X186ExprStep{stmt,state}: Con{stmt,x186_e_body(rest,state)}

@unsafe
def x186_e_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  Con{P113DIf{condition,x186_e_body(yes,x186_e_empty()),x186_e_body(no,x186_e_empty())},x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_e_body(body,state):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x186_e_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest)
    case Con{P113DIf{condition,yes,no},rest}: x186_e_if(condition,yes,no,rest)
    case Con{P113DScalar{stmt},rest}: x186_e_after(rest,x186_e_scalar(stmt,state))
    case Con{head,rest}: Con{head,x186_e_body(rest,x186_e_empty())}

@unsafe
def x186_expression_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_expression_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_e_body(body,x186_e_empty()),u => body)
