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

# Optional local word facts. Original snapshots remain until the existing
# backward dead-write pass proves them unused. Aliases are flattened on insert;
# every write kills both its own alias and aliases of the overwritten source.
type X190Values is Data:
  X190Values{+aliases: List<&2,X186Alias>, +widths: KDef}
type X190ValueStep is Data:
  X190ValueStep{+stmt: P113DStmt, +state: X190Values}

def x190_local_values_enabled() -> Bool: True{}
def x190_v_empty() -> X190Values: X190Values{[],missing()}

@unsafe
def x190_v_value(value: N111Value, state: X190Values) -> N111Value:
  match state:
    case X190Values{aliases,widths}: x186_e_value(value,aliases)

@unsafe
def x190_v_values(values: List<&2,N111Value>, +state: X190Values) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{x190_v_value(head,state),x190_v_values(rest,state)}

@unsafe
def x190_v_args(args: List<&2,N111Arg>, +state: X190Values) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,x190_v_value(value,state)},x190_v_args(rest,state)}

@unsafe
def x190_v_zero(value: N111Value, state: X190Values) -> Bool:
  match value state:
    case N111Const{lo,hi} _: U32.is_eq(hi,0)
    case N111Local{name} X190Values{aliases,widths}: U32.is_gt(da(p111v_get(widths,name)),0)
    case _ _: False{}

@unsafe
def x190_v_written(+name: String, known: Bool, state: X190Values) -> X190Values:
  match state:
    case X190Values{aliases,widths}:
      X190Values{x186_e_kill_aliases(aliases,name),p111v_put(widths,name,"X190Zero32",nt_choose(U32,known,u => 1,u => 0),0)}

@unsafe
def x190_v_alias(+name: String, +value: N111Value, state: X190Values) -> X190Values:
  match state:
    case X190Values{+aliases,widths}:
      X190Values{nt_choose(List<&2,X186Alias>,Bool.not(x185_sf_source(value,name)) && U32.is_lt(nt_count(X186Alias,aliases),32),
        u => Con{X186Alias{name,value},aliases},u => aliases),widths}

@unsafe
def x190_v_set(+name: String, +typ: N111Type, +value: N111Value, +state: X190Values) -> X190ValueStep:
  +zero = x190_v_zero(value,state)
  +narrow = U32.is_eq(p111v_type(typ),1)
  +outType = nt_choose(N111Type,narrow && zero,u => N111U64{},u => typ)
  +written = x190_v_written(name,narrow || zero,state)
  X190ValueStep{P113DScalar{N111Set{name,outType,value}},nt_choose(X190Values,Bool.not(narrow) || zero,
    u => x190_v_alias(name,value,written),u => written)}

def x190_v_mask(value: N111Value) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(lo,4294967295) && U32.is_eq(hi,0)
    case _: False{}

# For any word, x & 0xffffffff equals its zero-extended U32 copy. If x is
# already canonical the copy is full-width and requires no extra truncation.
@unsafe
def x190_v_binary(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +state: X190Values) -> X190ValueStep:
  nt_choose(X190ValueStep,String.eq(op,"and") && x190_v_mask(right),
    u => x190_v_set(name,N111U32{},left,state),u =>
      X190ValueStep{P113DScalar{N111Bin{name,typ,op,left,right}},
        x190_v_written(name,U32.is_eq(p111v_type(typ),1) || p111v_comparison(op),state)})

@unsafe
def x190_v_scalar(stmt: N111Stmt, +state: X190Values) -> X190ValueStep:
  match stmt:
    case N111Set{name,typ,value}: x190_v_set(name,typ,x190_v_value(value,state),state)
    case N111Bin{name,typ,op,left,right}: x190_v_binary(name,typ,op,x190_v_value(left,state),x190_v_value(right,state),state)
    case N111Offset{+name,base,bytes}:
      X190ValueStep{P113DScalar{N111Offset{name,x190_v_value(base,state),x190_v_value(bytes,state)}},x190_v_written(name,False{},state)}
    case N111Load{+name,+typ,base,offset}:
      X190ValueStep{P113DScalar{N111Load{name,typ,x190_v_value(base,state),offset}},x190_v_written(name,U32.is_eq(p111v_type(typ),1),state)}
    case N111Store{typ,base,offset,value}:
      X190ValueStep{P113DScalar{N111Store{typ,x190_v_value(base,state),offset,x190_v_value(value,state)}},state}
    case N111Call{name,typ,symbol,args}:
      X190ValueStep{P113DScalar{N111Call{name,typ,symbol,x190_v_args(args,state)}},x190_v_empty()}
    case N111Alloca{+name,bytes,align}:
      X190ValueStep{P113DScalar{N111Alloca{name,bytes,align}},x190_v_written(name,False{},state)}
    case N111Return{value}: X190ValueStep{P113DScalar{N111Return{x190_v_value(value,state)}},x190_v_empty()}
    case _: X190ValueStep{P113DScalar{stmt},x190_v_empty()}

# Modulo-2^32 arithmetic commutes with truncation for these operations only.
# In particular, shifts keep the original 64-bit count and intermediate bits.
@unsafe
def x190_v_narrow_op(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
    String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor")

law x190_v_body:
  for +body: List<&2,P113DStmt>
  for +state: X190Values
  List<&2,P113DStmt>

@unsafe
def x190_v_after(rest: List<&2,P113DStmt>, step: X190ValueStep) -> List<&2,P113DStmt>:
  match step:
    case X190ValueStep{stmt,state}: Con{stmt,x190_v_body(rest,state)}

@unsafe
def x190_v_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  Con{P113DIf{condition,x190_v_body(yes,x190_v_empty()),x190_v_body(no,x190_v_empty())},x190_v_body(rest,x190_v_empty())}

@unsafe
def x190_v_plain(body: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x190_v_if(x190_v_value(condition,state),yes,no,rest)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x190_v_if(x190_v_value(condition,state),x181_scalar_rows(yes),x181_scalar_rows(no),rest)
    case Con{P113DScalar{stmt},rest}: x190_v_after(rest,x190_v_scalar(stmt,state))
    case Con{P113DCall{names,target,args},rest}:
      Con{P113DCall{names,target,x190_v_values(args,state)},x190_v_body(rest,x190_v_empty())}
    case Con{P113DResult{values},rest}: Con{P113DResult{x190_v_values(values,state)},x190_v_body(rest,x190_v_empty())}
    case Con{P113DAgain{values},rest}: Con{P113DAgain{x190_v_values(values,state)},x190_v_body(rest,x190_v_empty())}

@unsafe
def x190_v_body(body,state):
  match body:
    case Con{P113DScalar{N111Bin{+name,N111U64{},+op,left,right}},
      Con{P113DScalar{N111Bin{other,N111U64{},maskOp,N111Local{source},N111Const{4294967295,0}}},rest}}:
        nt_choose(List<&2,P113DStmt>,String.eq(maskOp,"and") && String.eq(name,other) && String.eq(name,source) && x190_v_narrow_op(op),
          u => x190_v_after(rest,x190_v_scalar(N111Bin{name,N111U32{},op,left,right},state)),u => x190_v_plain(body,state))
    case _: x190_v_plain(body,state)

@unsafe
def x190_local_values_body(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x190_local_values_enabled() && U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),512),
    u => x190_v_body(body,x190_v_empty()),u => body)
