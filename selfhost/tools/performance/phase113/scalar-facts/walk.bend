@unsafe
def p113k_scalar_append(prefix: List<&2,N111Stmt>, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{nt_append(N111Stmt,prefix,body),facts}

@unsafe
def p113k_scalar_next(result: P113KScalar, rest: List<&2,N111Stmt>) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: p113k_scalar_append(body,p113k_scalars(rest,facts))

@unsafe
def p113k_scalars(body: List<&2,N111Stmt>, facts: KDef) -> P113KScalar:
  match body:
    case Nil{}: P113KScalar{[],facts}
    case Con{stmt,rest}: p113k_scalar_next(p113k_scalar(stmt,facts),rest)

@unsafe
def p113k_scalar_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  +answer = p113k_bin_fact(typ,op,lf,rf)
  P113KScalar{[p113k_bin_stmt(name,typ,op,p113k_replace(left,facts),p113k_replace(right,facts),lf,rf,answer)],p113k_put(facts,name,answer)}

@unsafe
def p113k_scalar_join(condition: N111Value, yes: P113KScalar, no: P113KScalar) -> P113KScalar:
  match yes no:
    case P113KScalar{yb,yf} P113KScalar{nb,nf}: P113KScalar{[N111If{condition,yb,nb}],p113k_join(yf,nf,missing())}

@unsafe
def p113k_scalar_if(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +facts: KDef, fact: P113KFact) -> P113KScalar:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KScalar,exact,
        u => nt_choose(P113KScalar,U32.is_eq(lo,0),v => p113k_scalars(no,facts),v => p113k_scalars(yes,facts)),
        u => p113k_scalar_join(condition,p113k_scalars(yes,facts),p113k_scalars(no,facts)))

@unsafe
def p113k_scalar(stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  match stmt:
    case N111Set{+name,+typ,+value}:
      P113KScalar{[N111Set{name,typ,p113k_replace(value,facts)}],p113k_put(facts,name,p113k_limit(p113k_value(value,facts),p113k_width(typ)))}
    case N111Bin{name,typ,op,+left,+right}: p113k_scalar_bin(name,typ,op,left,right,facts,p113k_value(left,facts),p113k_value(right,facts))
    case N111Call{+name,typ,symbol,args}: P113KScalar{[N111Call{name,typ,symbol,p113k_args(args,facts)}],p113k_put(facts,name,p113k_bound(64))}
    case N111If{+condition,yes,no}: p113k_scalar_if(condition,yes,no,facts,p113k_value(condition,facts))
    case N111Load{+name,typ,base,offset}: P113KScalar{[N111Load{name,typ,base,offset}],p113k_put(facts,name,p113k_bound(64))}
    case N111Store{typ,base,offset,value}: P113KScalar{[N111Store{typ,base,offset,p113k_replace(value,facts)}],facts}
    case N111Offset{+name,base,bytes}: P113KScalar{[N111Offset{name,base,bytes}],p113k_put(facts,name,p113k_bound(64))}
    case N111Alloca{+name,bytes,align}: P113KScalar{[N111Alloca{name,bytes,align}],p113k_put(facts,name,p113k_bound(64))}
    case N111Return{value}: P113KScalar{[N111Return{value}],facts}

@unsafe
def p113k_body_append(prefix: List<&2,P113DStmt>, result: P113KBody) -> P113KBody:
  match result:
    case P113KBody{body,facts,terminal}: P113KBody{nt_append(P113DStmt,prefix,body),facts,terminal}

@unsafe
def p113k_body_next(+result: P113KBody, +rest: List<&2,P113DStmt>) -> P113KBody:
  match result:
    case P113KBody{+body,+facts,+terminal}:
      nt_choose(P113KBody,terminal,u => result,u => p113k_body_append(body,p113k_body(rest,facts)))

@unsafe
def p113k_body(body: List<&2,P113DStmt>, facts: KDef) -> P113KBody:
  match body:
    case Nil{}: P113KBody{[],facts,False{}}
    case Con{stmt,rest}: p113k_body_next(p113k_stmt(stmt,facts),rest)

@unsafe
def p113k_scalar_body(result: P113KScalar) -> P113KBody:
  match result:
    case P113KScalar{body,facts}: P113KBody{p113d_scalars(body),facts,False{}}

@unsafe
def p113k_body_join(condition: N111Value, yes: P113KBody, no: P113KBody) -> P113KBody:
  match yes no:
    case P113KBody{yb,+yf,+yt} P113KBody{nb,+nf,+nt}:
      P113KBody{[P113DIf{condition,yb,nb}],
        nt_choose(KDef,yt,u => nf,u => nt_choose(KDef,nt,v => yf,v => p113k_join(yf,nf,missing()))),yt && nt}

@unsafe
def p113k_body_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>, +facts: KDef, fact: P113KFact) -> P113KBody:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P113KBody,exact,
        u => nt_choose(P113KBody,U32.is_eq(lo,0),v => p113k_body(no,facts),v => p113k_body(yes,facts)),
        u => p113k_body_join(condition,p113k_body(yes,facts),p113k_body(no,facts)))

@unsafe
def p113k_stmt(stmt: P113DStmt, +facts: KDef) -> P113KBody:
  match stmt:
    case P113DScalar{scalar}: p113k_scalar_body(p113k_scalar(scalar,facts))
    case P113DIf{+condition,yes,no}: p113k_body_if(condition,yes,no,facts,p113k_value(condition,facts))
    case P113DCall{+destinations,target,args}: P113KBody{[P113DCall{destinations,target,p113k_values(args,facts)}],p113k_kill(destinations,facts),False{}}
    case P113DResult{values}: P113KBody{[P113DResult{p113k_values(values,facts)}],facts,True{}}
    case P113DAgain{values}: P113KBody{[P113DAgain{p113k_values(values,facts)}],facts,True{}}
