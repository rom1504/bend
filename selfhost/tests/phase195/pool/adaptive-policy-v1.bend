# Profitability only. The same independent eleven-color validator authorizes
# either result. Costs are weighted syntactic frame reads/writes, not timings.
type X195APCost is Data:
  X195APCost{+gain: U32, +loss: U32, +state: U32}
type X195APEnv is Data:
  X195APEnv{+ids: KDef, +gained: U32, +lost: U32, +parameters: List<&2,String>, +weighted: Bool}
type X195APFlow is Data:
  X195APFlow{+cost: X195APCost, +reaches: Bool, +falls: Bool}

# False reconstructs the original eleven-color policy without cost walks.
def x195_ap_enabled() -> Bool: True{}
def x195_ap_zero() -> X195APCost: X195APCost{0,0,0}
def x195_ap_add(+a: U32, +b: U32) -> U32:
  nt_choose(U32,U32.is_gt(b,U32.sub(4294967295,a)),u => 4294967295,u => U32.add(a,b))
def x195_ap_eight(+a: U32) -> U32:
  nt_choose(U32,U32.is_gt(a,536870911),u => 4294967295,u => U32.mul(a,8))
def x195_ap_sum(a: X195APCost, b: X195APCost) -> X195APCost:
  match a b:
    case X195APCost{ag,al,ast} X195APCost{bg,bl,bst}:
      X195APCost{x195_ap_add(ag,bg),x195_ap_add(al,bl),x195_ap_add(ast,bst)}
def x195_ap_scale(+cost: X195APCost, hot: Bool, env: X195APEnv) -> X195APCost:
  match cost env:
    case X195APCost{gain,loss,state} X195APEnv{ids,gained,lost,parameters,weighted}:
      nt_choose(X195APCost,hot && weighted,
        u => X195APCost{x195_ap_eight(gain),x195_ap_eight(loss),x195_ap_eight(state)},u => cost)
def x195_ap_take(cost: X195APCost) -> Bool:
  match cost:
    case X195APCost{gain,loss,state}: U32.is_gt(gain,x195_ap_add(loss,state))

@unsafe
def x195_ap_name(+name: String, env: X195APEnv) -> X195APCost:
  match env:
    case X195APEnv{ids,gained,lost,parameters,weighted}:
      +bit = x190_l_bit(name,ids)
      X195APCost{nt_choose(U32,U32.is_eq(U32.and(bit,gained),0),u => 0,u => 1),
        nt_choose(U32,U32.is_eq(U32.and(bit,lost),0),u => 0,u => 1),
        nt_choose(U32,String.eq(name,"state"),u => 1,u => 0)}
@unsafe
def x195_ap_value(value: N111Value, env: X195APEnv) -> X195APCost:
  match value:
    case N111Local{name}: x195_ap_name(name,env)
    case _: x195_ap_zero()
@unsafe
def x195_ap_values(values: List<&2,N111Value>, +env: X195APEnv) -> X195APCost:
  match values:
    case Nil{}: x195_ap_zero()
    case Con{value,rest}: x195_ap_sum(x195_ap_value(value,env),x195_ap_values(rest,env))
@unsafe
def x195_ap_names(names: List<&2,String>, +env: X195APEnv) -> X195APCost:
  match names:
    case Nil{}: x195_ap_zero()
    case Con{name,rest}: x195_ap_sum(x195_ap_name(name,env),x195_ap_names(rest,env))
@unsafe
def x195_ap_args(args: List<&2,N111Arg>, +env: X195APEnv) -> X195APCost:
  match args:
    case Nil{}: x195_ap_zero()
    case Con{N111Arg{typ,value},rest}: x195_ap_sum(x195_ap_value(value,env),x195_ap_args(rest,env))
@unsafe
def x195_ap_again(params: List<&2,String>, values: List<&2,N111Value>, +env: X195APEnv) -> X195APCost:
  match params values:
    case Con{+name,rest} Con{+value,more}:
      x195_ap_sum(nt_choose(X195APCost,x191_again_identity(name,value),u => x195_ap_zero(),
        u => x195_ap_sum(x195_ap_name(name,env),x195_ap_value(value,env))),x195_ap_again(rest,more,env))
    case _ _: x195_ap_zero()

# Inline F32 does not read its syntactic state argument. Ordinary scalar calls
# use explicit args; product calls additionally inject one state argument.
@unsafe
def x195_ap_call(operation: X186InlineOp, name: String, args: List<&2,N111Arg>, +env: X195APEnv) -> X195APCost:
  match operation:
    case X186InlineF32{destination,id,buffer}: x195_ap_sum(x195_ap_name(destination,env),x195_ap_name(buffer,env))
    case _: x195_ap_sum(x195_ap_name(name,env),x195_ap_args(args,env))
@unsafe
def x195_ap_scalar(+stmt: N111Stmt, +env: X195APEnv) -> X195APCost:
  match stmt:
    case N111Set{name,typ,value}: x195_ap_sum(x195_ap_name(name,env),x195_ap_value(value,env))
    case N111Bin{name,typ,op,left,right}:
      x195_ap_sum(x195_ap_name(name,env),x195_ap_sum(x195_ap_value(left,env),x195_ap_value(right,env)))
    case N111Load{name,typ,base,offset}: x195_ap_sum(x195_ap_name(name,env),x195_ap_value(base,env))
    case N111Store{typ,base,offset,value}: x195_ap_sum(x195_ap_value(base,env),x195_ap_value(value,env))
    case N111Offset{name,base,bytes}:
      x195_ap_sum(x195_ap_name(name,env),x195_ap_sum(x195_ap_value(base,env),x195_ap_value(bytes,env)))
    case N111Call{name,typ,symbol,args}: x195_ap_call(x186_inline_op(stmt),name,args,env)
    case N111Return{value}: x195_ap_value(value,env)
    case _: x195_ap_zero()
@unsafe
def x195_ap_event(stmt: P113DStmt, +env: X195APEnv) -> X195APCost:
  match stmt env:
    case P113DScalar{scalar} _: x195_ap_scalar(scalar,env)
    case P113DCall{names,target,args} _:
      x195_ap_sum(x195_ap_name("state",env),x195_ap_sum(x195_ap_names(names,env),x195_ap_values(args,env)))
    case P113DResult{values} _: x195_ap_values(values,env)
    case P113DAgain{values} X195APEnv{ids,gained,lost,parameters,weighted}: x195_ap_again(parameters,values,env)
    case _ _: x195_ap_zero()

law x195_ap_body:
  for body: List<&2,P113DStmt>
  for +env: X195APEnv
  for after: Bool
  X195APFlow

# Same reaches/falls equations as x191_loop_reads. Setup uses weighted=False;
# repeated body paths cost8, while setup, exit-only paths and imports cost1.
@unsafe
def x195_ap_join(condition: N111Value, +env: X195APEnv, yes: X195APFlow, no: X195APFlow) -> X195APFlow:
  match yes no:
    case X195APFlow{a,+hotA,fallA} X195APFlow{b,+hotB,fallB}:
      X195APFlow{x195_ap_sum(x195_ap_scale(x195_ap_value(condition,env),hotA || hotB,env),
        x195_ap_sum(a,b)),hotA || hotB,fallA || fallB}
@unsafe
def x195_ap_stmt(+stmt: P113DStmt, +env: X195APEnv, +after: Bool) -> X195APFlow:
  match stmt:
    case P113DAgain{values}: X195APFlow{x195_ap_scale(x195_ap_event(stmt,env),True{},env),True{},False{}}
    case P113DResult{values}: X195APFlow{x195_ap_event(stmt,env),False{},False{}}
    case P113DScalar{N111Return{value}}: X195APFlow{x195_ap_event(stmt,env),False{},False{}}
    case P113DIf{condition,yes,no}: x195_ap_join(condition,env,x195_ap_body(yes,env,after),x195_ap_body(no,env,after))
    case P113DScalar{N111If{condition,yes,no}}:
      x195_ap_join(condition,env,x195_ap_body(x181_scalar_rows(yes),env,after),x195_ap_body(x181_scalar_rows(no),env,after))
    case _: X195APFlow{x195_ap_scale(x195_ap_event(stmt,env),after,env),after,True{}}
def x195_ap_cons(head: X195APFlow, rest: X195APFlow) -> X195APFlow:
  match head rest:
    case X195APFlow{a,hot,+falls} X195APFlow{b,restHot,restFalls}:
      X195APFlow{x195_ap_sum(a,nt_choose(X195APCost,falls,u => b,u => x195_ap_zero())),hot,falls && restFalls}
@unsafe
def x195_ap_head(head: P113DStmt, env: X195APEnv, +rest: X195APFlow) -> X195APFlow:
  match rest:
    case X195APFlow{cost,hot,falls}: x195_ap_cons(x195_ap_stmt(head,env,hot),rest)
@unsafe
def x195_ap_body(body,env,after):
  match body:
    case Nil{}: X195APFlow{x195_ap_zero(),after,True{}}
    case Con{head,rest}: x195_ap_head(head,env,x195_ap_body(rest,env,after))
def x195_ap_cost(flow: X195APFlow) -> X195APCost:
  match flow:
    case X195APFlow{cost,hot,falls}: cost
@unsafe
def x195_ap_union(groups: List<&2,U32>) -> U32:
  match groups:
    case Nil{}: 0
    case Con{mask,rest}: U32.or(mask,x195_ap_union(rest))

@unsafe
def x195_ap_score(frame: X181Frame, params: List<&2,String>, setup: List<&2,P113DStmt>,
    body: List<&2,P113DStmt>, +ids: KDef, groups10: List<&2,U32>, groups11: List<&2,U32>) -> X195APCost:
  +ten = x195_ap_union(groups10)
  +eleven = x195_ap_union(groups11)
  +gained = U32.and(eleven,U32.not(ten))
  +lost = U32.and(ten,U32.not(eleven))
  +tail = x181_tail_args(frame)
  +cold: X195APEnv = X195APEnv{ids,gained,lost,tail,False{}}
  +hot: X195APEnv = X195APEnv{ids,gained,lost,tail,True{}}
  x195_ap_sum(x195_ap_names(params,cold),
    x195_ap_sum(x195_ap_cost(x195_ap_body(setup,cold,False{})),x195_ap_cost(x195_ap_body(body,hot,False{}))))

@unsafe
def x195_ap_selected(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, names: List<&2,String>, rows: List<&2,U32>,
    ids: KDef, +groups10: List<&2,U32>, +groups11: List<&2,U32>, shifts: U32) -> X181Frame:
  +cost = x195_ap_score(frame,params,setup,body,ids,groups10,groups11)
  x195_p_checked(frame,params,setup,body,registerBody,names,rows,
    nt_choose(List<&2,U32>,x195_ap_take(cost),u => groups11,u => groups10),shifts)
@unsafe
def x195_ap_eleven(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +rows: List<&2,U32>,
    +ids: KDef, affinities: KDef, +groups11: List<&2,U32>, +shifts: U32) -> X181Frame:
  nt_choose(X181Frame,x195_ap_enabled() && Bool.not(U32.is_eq(x195_p_group(groups11,10),0)),
    u => x195_ap_selected(frame,params,setup,body,registerBody,names,rows,ids,
      x195_pc_color(names,rows,params,1,[0,0,0,0,0,0,0,0,0,0,0],affinities,shifts,10),groups11,shifts),
    u => x195_p_checked(frame,params,setup,body,registerBody,names,rows,groups11,shifts))

# Sole adaptive override: choose a profitable color construction, then use the
# unchanged checker/state transaction. No extra CFG/graph/fixed-point solve.
@unsafe
def x195_p_graphed(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, +names: List<&2,String>, +ids: KDef,
    +shifts: U32, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,+graph}:
      +affinities = x190_a_body(body,ids,x181_tail_args(frame),x190_a_body(setup,ids,x181_tail_args(frame),missing()))
      x195_ap_eleven(frame,params,setup,body,registerBody,names,graph,ids,affinities,
        x195_pc_color(names,graph,params,1,[0,0,0,0,0,0,0,0,0,0,0],affinities,shifts,11),shifts)
