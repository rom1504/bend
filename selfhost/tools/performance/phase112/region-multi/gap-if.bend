# Local condition width/definite assignment is established by the mandatory
# original p111v_stmt condition check (U32). Preserve that exact condition.
@unsafe
def p112h_condition(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: U32.is_eq(hi,0)
    case _: False{}

@unsafe
def p112h_candidate(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{+condition,+yes,+no}: True{}
    case _: p112g_pure(stmt)

# A successful result is the remaining shared budget. Every statement node,
# including If and both branches (even the unselected branch), costs one.
@unsafe
def p112h_stmt(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,U32.is_eq(left,0),u => None{},u => p112h_stmt_room(stmt,U32.sub(left,1)))

@unsafe
def p112h_stmt_room(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  match stmt:
    case N111If{+condition,+yes,+no}:
      nt_choose(Maybe<&2,U32>,p112h_condition(condition),u => p112h_rest(no,p112h_nodes(yes,left)),u => None{})
    case _: nt_choose(Maybe<&2,U32>,p112g_pure(stmt),u => Some{left},u => None{})

@unsafe
def p112h_nodes(body: List<&2,N111Stmt>, +left: U32) -> Maybe<&2,U32>:
  match body:
    case Nil{}: Some{left}
    case Con{+stmt,+rest}: p112h_rest(rest,p112h_stmt(stmt,left))

@unsafe
def p112h_rest(+body: List<&2,N111Stmt>, result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{+left}: p112h_nodes(body,left)

@unsafe
def p112h_accept(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +acc: List<&2,N111Stmt>, result: Maybe<&2,U32>) -> Maybe<&2,P112PureGap>:
  match result:
    case None{}: None{}
    case Some{+left}: p112g_split(rest,U32.sub(32,left),Con{stmt,acc})

@unsafe
def p112h_split(+body: List<&2,N111Stmt>, +count: U32, +acc: List<&2,N111Stmt>) -> Maybe<&2,P112PureGap>:
  match body:
    case Nil{}: Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}}
    case Con{+stmt,+rest}:
      nt_choose(Maybe<&2,P112PureGap>,p112h_candidate(stmt),
        u => p112h_accept(stmt,rest,acc,p112h_stmt(stmt,U32.sub(32,count))),
        u => Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}})
