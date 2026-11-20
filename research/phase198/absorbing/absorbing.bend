# A positive countdown may enter an absorbing state before it exhausts its fuel.
# Certify one predecessor of a shared Again, then set only its next fuel to zero.
# All original copies, the other predecessor, and the zero-fuel result stay live.
def x198a_enabled() -> Bool: True{}

type X198ACountdown is Data:
  X198ACountdown{+params: List<&2,String>, +fuel: String, +pred: String, +buffer: String, +ids: N111Ids}

@unsafe
def x198a_temp(+name: String, +params: List<&2,String>) -> Bool:
  Bool.not(String.is_empty(name) || x181_register_reserved(name) || nb_contains(params,name))

@unsafe
def x198a_word(value: N111Value, +params: List<&2,String>) -> Bool:
  match value:
    case N111Const{lo,hi}: True{}
    case N111Local{name}: nb_contains(params,name)
    case _: False{}

@unsafe
def x198a_outputs(values: List<&2,N111Value>, +params: List<&2,String>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x198a_word(value,params) && x198a_outputs(rest,params)

@unsafe
def x198a_free(+name: String, loop: X198ACountdown) -> Bool:
  match loop:
    case X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_temp(name,params) && Bool.not(String.eq(name,pred) || String.eq(name,buffer))

# Resolve every taken-arm copy to a constant or incoming parameter. A lookup
# never points at another temporary, even when the arm reassigns a prior name.
@unsafe
def x198a_copies(body: List<&2,P113DStmt>, +loop: X198ACountdown, +bindings: List<&2,X186Alias>,
    +budget: U32) -> Maybe<&2,List<&2,X186Alias>>:
  match body loop:
    case Nil{} _: Some{bindings}
    case Con{P113DScalar{N111Set{+name,N111U64{},value}},rest} X198ACountdown{+params,+fuel,pred,buffer,ids}:
      +resolved = x186_e_value(value,bindings)
      nt_choose(Maybe<&2,List<&2,X186Alias>>,U32.is_gt(budget,0) && x198a_free(name,loop) &&
        x198a_word(resolved,params) && Bool.not(x185_sf_source(resolved,fuel)),
        u => x198a_copies(rest,loop,Con{X186Alias{name,resolved},bindings},U32.sub(budget,1)),u => None{})
    case _ _: None{}

# Every non-fuel component must be its own incoming word or a constant.
# Parallel rebound inputs can thus be used again without reordering moves.
@unsafe
def x198a_back(params: List<&2,String>, values: List<&2,N111Value>, +fuel: String, +pred: String,
    +bindings: List<&2,X186Alias>, +facts: KDef) -> Maybe<&2,KDef>:
  match params values:
    case Nil{} Nil{}: Some{facts}
    case Con{+param,+ps} Con{+value,+vs}:
      nt_choose(Maybe<&2,KDef>,String.eq(param,fuel),u =>
        nt_choose(Maybe<&2,KDef>,x185_sf_source(value,pred),
          v => x198a_back(ps,vs,fuel,pred,bindings,facts),v => None{}),u =>
        x198a_back_word(param,x186_e_value(value,bindings),ps,vs,fuel,pred,bindings,facts))
    case _ _: None{}

@unsafe
def x198a_back_word(+param: String, value: N111Value, ps: List<&2,String>, vs: List<&2,N111Value>,
    +fuel: String, +pred: String, +bindings: List<&2,X186Alias>, +facts: KDef) -> Maybe<&2,KDef>:
  match value:
    case N111Const{lo,hi}:
      x198a_back(ps,vs,fuel,pred,bindings,p113k_put(facts,param,p113k_exact(lo,hi)))
    case N111Local{name}: nt_choose(Maybe<&2,KDef>,String.eq(name,param),
      u => x198a_back(ps,vs,fuel,pred,bindings,facts),u => None{})
    case _: None{}

@unsafe
def x198a_id(+record: KDef) -> P113KFact:
  nt_choose(P113KFact,String.eq(dk(record),"N111Id"),u => p113k_exact(da(record),0),u => p113k_bound(64))

@unsafe
def x198a_fact(+value: N111Value, +facts: KDef, ids: N111Ids) -> P113KFact:
  match value ids:
    case N111CtorId{name} N111Ids{functions,ctors}: x198a_id(p111v_get(ctors,name))
    case _ _: p113k_value(value,facts)

def x198a_exact(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact

@unsafe
def x198a_op(+op: String, right: P113KFact, typ: N111Type) -> Bool:
  match right:
    case P113KFact{bits,exact,lo,hi}:
      String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"and") || String.eq(op,"or") ||
        String.eq(op,"xor") || ((String.eq(op,"shr") || String.eq(op,"shl")) &&
          U32.is_eq(hi,0) && U32.is_lt(lo,p113k_width(typ)))

def x198a_truth(fact: P113KFact, truth: Bool) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(hi,0) && U32.is_eq(lo,Bool.to_u32(truth))

# Interpret just the guard prefix on the next state's constants. Unknown
# inputs (including fuel) refuse even when an unrelated fact could bound them.
@unsafe
def x198a_eval(prefix: List<&2,P113DStmt>, +condition: N111Value, +truth: Bool,
    +loop: X198ACountdown, +facts: KDef) -> Bool:
  match prefix loop:
    case Nil{} X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_truth(x198a_fact(condition,facts,ids),truth)
    case Con{P113DScalar{N111Bin{+name,+typ,+op,l,r}},rest} X198ACountdown{params,fuel,pred,buffer,+ids}:
      +left = x198a_fact(l,facts,ids)
      +right = x198a_fact(r,facts,ids)
      x198a_free(name,loop) && x190_branch_width(typ) && x198a_exact(left) && x198a_exact(right) &&
        x198a_op(op,right,typ) && x198a_eval(rest,condition,truth,loop,
          p113k_put(facts,name,p113k_bin_fact(typ,op,left,right)))
    case _ _: False{}

@unsafe
def x198a_cert(facts: Maybe<&2,KDef>, prefix: List<&2,P113DStmt>, condition: N111Value,
    truth: Bool, loop: X198ACountdown) -> Bool:
  match facts:
    case Some{table}: x198a_eval(prefix,condition,truth,loop,table)
    case None{}: False{}

@unsafe
def x198a_arm_allowed(copies: Maybe<&2,List<&2,X186Alias>>, +loop: X198ACountdown,
    prefix: List<&2,P113DStmt>, condition: N111Value, truth: Bool, args: List<&2,N111Value>) -> Bool:
  match copies loop:
    case Some{bindings} X198ACountdown{params,fuel,pred,buffer,ids}:
      x198a_cert(x198a_back(params,args,fuel,pred,bindings,missing()),prefix,condition,truth,loop)
    case _ _: False{}

@unsafe
def x198a_arm(+arm: List<&2,P113DStmt>, +loop: X198ACountdown, prefix: List<&2,P113DStmt>,
    condition: N111Value, truth: Bool, args: List<&2,N111Value>) -> List<&2,P113DStmt>:
  match loop:
    case X198ACountdown{params,fuel,pred,buffer,ids}:
      nt_choose(List<&2,P113DStmt>,x198a_arm_allowed(x198a_copies(arm,loop,[],16),loop,prefix,condition,truth,args),
        u => nt_append(P113DStmt,arm,[P113DScalar{N111Set{pred,N111U64{},N111Const{0,0}}}]),u => arm)

# The only continuation after the branch must be the shared, arity-checked
# backedge. No skipped statement can observe the new predecessor value.
@unsafe
def x198a_scan(+body: List<&2,P113DStmt>, +loop: X198ACountdown, +reverse: List<&2,P113DStmt>,
    +budget: U32) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DIf{+condition,yes,no},Con{P113DAgain{+args},Nil{}}}:
      +prefix = nt_reverse(P113DStmt,reverse,[])
      [P113DIf{condition,x198a_arm(yes,loop,prefix,condition,True{},args),
        x198a_arm(no,loop,prefix,condition,False{},args)},P113DAgain{args}]
    case Con{P113DScalar{N111Bin{+name,+typ,+op,+l,+r}},rest}:
      +row = {P113DScalar{N111Bin{name,typ,op,l,r}} : P113DStmt}
      nt_choose(List<&2,P113DStmt>,U32.is_gt(budget,0),u =>
        Con{row,x198a_scan(rest,loop,Con{row,reverse},U32.sub(budget,1))},u => body)
    case _: body

@unsafe
def x198a_after_sub(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String,
    +pred: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Alloca{+buffer,bytes,align}},rest}:
      nt_choose(List<&2,P113DStmt>,x198a_temp(buffer,params) && Bool.not(String.eq(buffer,pred)),u =>
        Con{P113DScalar{N111Alloca{buffer,bytes,align}},
          x198a_scan(rest,X198ACountdown{params,fuel,pred,buffer,ids},[],8)},u => body)
    case _: x198a_scan(body,X198ACountdown{params,fuel,pred,"",ids},[],8)

@unsafe
def x198a_sub(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+pred,N111U64{},+op,+left,+right}},rest}:
      nt_choose(List<&2,P113DStmt>,String.eq(op,"sub") && x185_sf_source(left,fuel) &&
        x192_p_constant(right,1) && x198a_temp(pred,params),u =>
          Con{P113DScalar{N111Bin{pred,N111U64{},op,left,right}},x198a_after_sub(rest,params,fuel,pred,ids)},u => body)
    case _: body

@unsafe
def x198a_positive(+body: List<&2,P113DStmt>, +params: List<&2,String>, +fuel: String, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body:
    case Con{P113DScalar{N111Bin{+name,N111U64{},+op,+left,+right}},Con{P113DIf{+cond,yes,no},Nil{}}}:
      nt_choose(List<&2,P113DStmt>,String.eq(op,"ne") && x185_sf_source(left,fuel) && x192_p_constant(right,0) &&
        x185_sf_source(cond,name) && x198a_temp(name,params),u =>
          [P113DScalar{N111Bin{name,N111U64{},op,left,right}},P113DIf{cond,x198a_sub(yes,params,fuel,ids),no}],
          u => body)
    case _: x198a_sub(body,params,fuel,ids)

@unsafe
def x198a_body(+body: List<&2,P113DStmt>, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +ids: N111Ids) -> List<&2,P113DStmt>:
  match body params setup:
    case Con{P113DScalar{N111Bin{+name,N111U64{},+op,N111Local{+fuel},+zero}},
        Con{P113DIf{+cond,Con{P113DResult{+values},Nil{}},positive},Nil{}}} Con{+state,extra} Nil{}:
      +args = x181_tail_skip(extra)
      nt_choose(List<&2,P113DStmt>,x198a_enabled() && String.eq(state,"state") && String.eq(op,"eq") &&
        x198a_temp(name,params) && x185_sf_source(cond,name) && x192_p_constant(zero,0) &&
        nb_contains(args,fuel) && U32.is_le(nt_count(String,args),16) && p113e_distinct(params) &&
        x198a_outputs(values,args),u =>
          [P113DScalar{N111Bin{name,N111U64{},op,N111Local{fuel},zero}},
           P113DIf{cond,[P113DResult{values}],x198a_positive(positive,args,fuel,ids)}],u => body)
    case _ _ _: body
