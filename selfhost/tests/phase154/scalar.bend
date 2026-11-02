# Numeric local facts for the Phase154 producer experiment. Arithmetic transfer
# functions remain the existing P113KFact helpers; no KDef/KTerm records are
# manufactured by this consumer. The trie uses exact tagged-name equality.
type P154Relation is Data:
  P154NoRelation{}
  P154Relation{+subject: P154Name, +version: U32, +epoch: U32, +truth: U32}

type P154Predicate is Data:
  P154NoPredicate{}
  P154Predicate{+root: P154Name, +version: U32, +epoch: U32, +invert: U32}

type P154Test is Data:
  P154NoTest{}
  P154Test{+root: P154Name, +invert: U32}

type P154FCell is Data:
  P154FAbsent{}
  P154FCell{+name: P154Name, +present: Bool, +value: P113KFact, +version: U32, +relation: P154Relation, +predicate: P154Predicate}

type P154Facts is Data:
  P154FEmpty{}
  P154FLeaf{+hash: U32, +cells: List<&2,P154FCell>}
  P154FNode{+prefix: U32, +mask: U32, +left: P154Facts, +right: P154Facts}

type P154KScalar is Data:
  P154KScalar{+body: List<&2,P154Stmt>, +facts: P154Facts}

type P154KBody is Data:
  P154KBody{+body: List<&2,P154DStmt>, +facts: P154Facts, +terminal: Bool}

type P154BQDiamond is Data:
  P154BQNo{}
  P154BQYes{+name: P154Name, +invert: Bool}

@unsafe
def p154f_bucket(cells: List<&2,P154FCell>, +name: P154Name) -> P154FCell:
  match cells:
    case Nil{}: P154FAbsent{}
    case Con{+head,rest}: p154f_bucket_head(head,rest,name)

@unsafe
def p154f_bucket_head(+cell: P154FCell, rest: List<&2,P154FCell>, +name: P154Name) -> P154FCell:
  match cell:
    case P154FCell{key,present,value,version,relation,predicate}:
      nt_choose(P154FCell,p154n_eq(key,name),u => cell,u => p154f_bucket(rest,name))
    case _: p154f_bucket(rest,name)

@unsafe
def p154f_lookup(tree: P154Facts, +name: P154Name, +hash: U32) -> P154FCell:
  match tree:
    case P154FEmpty{}: P154FAbsent{}
    case P154FLeaf{stored,cells}:
      nt_choose(P154FCell,U32.is_eq(stored,hash),u => p154f_bucket(cells,name),u => P154FAbsent{})
    case P154FNode{prefix,mask,left,right}:
      nt_choose(P154FCell,U32.is_eq(U32.and(U32.xor(prefix,hash),U32.sub(mask,1)),0),
        u => nt_choose(P154FCell,U32.is_eq(U32.and(hash,mask),0),v => p154f_lookup(left,name,hash),v => p154f_lookup(right,name,hash)),
        u => P154FAbsent{})

@unsafe
def p154f_get(+tree: P154Facts, +name: P154Name) -> P154FCell:
  p154f_lookup(tree,name,p154n_hash(name))

@unsafe
def p154f_remove(cells: List<&2,P154FCell>, +name: P154Name) -> List<&2,P154FCell>:
  match cells:
    case Nil{}: []
    case Con{+head,rest}: p154f_remove_head(head,rest,name)

@unsafe
def p154f_remove_head(+cell: P154FCell, +rest: List<&2,P154FCell>, +name: P154Name) -> List<&2,P154FCell>:
  match cell:
    case P154FCell{key,present,value,version,relation,predicate}:
      nt_choose(List<&2,P154FCell>,p154n_eq(key,name),u => p154f_remove(rest,name),u => Con{cell,p154f_remove(rest,name)})
    case _: p154f_remove(rest,name)

@unsafe
def p154f_fork(+tree: P154Facts, +prefix: U32, +hash: U32, +mask: U32, +cell: P154FCell) -> P154Facts:
  nt_choose(P154Facts,U32.is_eq(U32.and(hash,mask),0),
    u => P154FNode{prefix,mask,P154FLeaf{hash,[cell]},tree},
    u => P154FNode{prefix,mask,tree,P154FLeaf{hash,[cell]}})

@unsafe
def p154f_insert(+tree: P154Facts, +name: P154Name, +hash: U32, +cell: P154FCell) -> P154Facts:
  match tree:
    case P154FEmpty{}: P154FLeaf{hash,[cell]}
    case P154FLeaf{+stored,cells}:
      nt_choose(P154Facts,U32.is_eq(stored,hash),
        u => P154FLeaf{hash,Con{cell,p154f_remove(cells,name)}},
        u => p154f_fork(tree,stored,hash,index_split_bit(U32.xor(stored,hash)),cell))
    case P154FNode{+prefix,+mask,left,right}:
      nt_choose(P154Facts,U32.is_eq(U32.and(U32.xor(prefix,hash),U32.sub(mask,1)),0),
        u => nt_choose(P154Facts,U32.is_eq(U32.and(hash,mask),0),
          v => P154FNode{prefix,mask,p154f_insert(left,name,hash,cell),right},
          v => P154FNode{prefix,mask,left,p154f_insert(right,name,hash,cell)}),
        u => p154f_fork(tree,prefix,hash,index_split_bit(U32.xor(prefix,hash)),cell))

@unsafe
def p154f_put(tree: P154Facts, +name: P154Name, cell: P154FCell) -> P154Facts:
  p154f_insert(tree,name,p154n_hash(name),cell)

@unsafe
def p154f_value(cell: P154FCell) -> P113KFact:
  match cell:
    case P154FCell{name,present,value,version,relation,predicate}:
      nt_choose(P113KFact,present,u => value,u => p113k_bound(64))
    case _: p113k_bound(64)

@unsafe
def p154f_version(cell: P154FCell) -> U32:
  match cell:
    case P154FCell{name,present,value,version,relation,predicate}: version
    case _: 0

@unsafe
def p154f_relation(cell: P154FCell) -> P154Relation:
  match cell:
    case P154FCell{name,present,value,version,relation,predicate}: relation
    case _: P154NoRelation{}

@unsafe
def p154f_predicate(cell: P154FCell) -> P154Predicate:
  match cell:
    case P154FCell{name,present,value,version,relation,predicate}: predicate
    case _: P154NoPredicate{}

@unsafe
def p154k_get(+facts: P154Facts, name: P154Name) -> P113KFact:
  p154f_value(p154f_get(facts,name))

@unsafe
def p154k_put(+facts: P154Facts, +name: P154Name, value: P113KFact) -> P154Facts:
  p154k_put_cell(facts,name,value,p154f_get(facts,name))

@unsafe
def p154k_put_cell(facts: P154Facts, +name: P154Name, value: P113KFact, cell: P154FCell) -> P154Facts:
  match cell:
    case P154FCell{old,present,prior,version,relation,predicate}:
      p154f_put(facts,name,P154FCell{name,True{},value,U32.inc(version),relation,predicate})
    case _:
      p154f_put(facts,name,P154FCell{name,True{},value,1,P154NoRelation{},P154NoPredicate{}})

@unsafe
def p154l_version(facts: P154Facts, name: P154Name) -> U32:
  p154f_version(p154f_get(facts,name))

# Joining continuing arms matches p113k_join: retain only ordinary facts
# present in both arms, restart epochs at one, and discard both provenances.
@unsafe
def p154k_join_bucket(cells: List<&2,P154FCell>, +right: P154Facts, out: P154Facts) -> P154Facts:
  match cells:
    case Nil{}: out
    case Con{head,rest}: p154k_join_bucket(rest,right,p154k_join_record(head,right,out))

@unsafe
def p154k_join_record(cell: P154FCell, +right: P154Facts, +out: P154Facts) -> P154Facts:
  match cell:
    case P154FCell{+name,present,value,version,relation,predicate}:
      nt_choose(P154Facts,present,u => p154k_join_pair(name,value,p154f_get(right,name),out),u => out)
    case _: out

@unsafe
def p154k_join_pair(name: P154Name, left: P113KFact, cell: P154FCell, +out: P154Facts) -> P154Facts:
  match cell:
    case P154FCell{key,present,right,version,relation,predicate}:
      nt_choose(P154Facts,present,u => p154k_put(out,name,p113k_join_fact(left,right)),u => out)
    case _: out

@unsafe
def p154k_join(left: P154Facts, +right: P154Facts, out: P154Facts) -> P154Facts:
  match left:
    case P154FLeaf{hash,cells}: p154k_join_bucket(cells,right,out)
    case P154FNode{prefix,mask,a,b}: p154k_join(b,right,p154k_join(a,right,out))
    case _: out



# The following walkers preserve the mature scalar transfer and cutoff rules.

@unsafe
def p154k_value(value: P154Value, +facts: P154Facts) -> P113KFact:
  match value:
    case P154Const{lo,hi}: p113k_exact(lo,hi)
    case P154Local{name}: p154k_get(facts,name)
    case _: p113k_bound(64)

@unsafe
def p154k_atom(+value: P154Value, fact: P113KFact) -> P154Value:
  match fact:
    case P113KFact{bits,+exact,lo,hi}: nt_choose(P154Value,exact,u => P154Const{lo,hi},u => value)

@unsafe
def p154k_replace(+value: P154Value, +facts: P154Facts) -> P154Value:
  p154k_atom(value,p154k_value(value,facts))

@unsafe
def p154k_values(values: List<&2,P154Value>, +facts: P154Facts) -> List<&2,P154Value>:
  match values:
    case Nil{}: []
    case Con{value,rest}: Con{p154k_replace(value,facts),p154k_values(rest,facts)}

@unsafe
def p154k_args(args: List<&2,P154Arg>, +facts: P154Facts) -> List<&2,P154Arg>:
  match args:
    case Nil{}: []
    case Con{P154Arg{N111Ptr{},value},rest}: Con{P154Arg{N111Ptr{},value},p154k_args(rest,facts)}
    case Con{P154Arg{typ,value},rest}: Con{P154Arg{typ,p154k_replace(value,facts)},p154k_args(rest,facts)}

@unsafe
def p154k_kill(names: List<&2,P154Name>, facts: P154Facts) -> P154Facts:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p154k_kill(rest,p154k_put(facts,name,p113k_bound(64)))

@unsafe
def p154k_bin_stmt(+name: P154Name, +typ: N111Type, +op: String, +left: P154Value, +right: P154Value, +lf: P113KFact, +rf: P113KFact, answer: P113KFact) -> P154Stmt:
  match answer:
    case P113KFact{bits,+exact,lo,hi}:
      nt_choose(P154Stmt,exact,u => P154Set{name,p113k_result_type(typ,op),P154Const{lo,hi}},u =>
      nt_choose(P154Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(lf),rf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add") || String.eq(op,"sub")) && p113k_zero(rf)),
        u => P154Set{name,typ,left},u =>
      nt_choose(P154Stmt,(String.eq(op,"and") && p113k_mask_covers(p113k_bits_of(rf),lf)) ||
          ((String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(lf)),
        u => P154Set{name,typ,right},u => P154Bin{name,typ,op,left,right})))

@unsafe
def p154k_scalar_append(prefix: List<&2,P154Stmt>, result: P154KScalar) -> P154KScalar:
  match result:
    case P154KScalar{body,facts}: P154KScalar{nt_append(P154Stmt,prefix,body),facts}

@unsafe
def p154k_scalar_next(result: P154KScalar, rest: List<&2,P154Stmt>) -> P154KScalar:
  match result:
    case P154KScalar{body,facts}: p154k_scalar_append(body,p154k_scalars(rest,facts))

@unsafe
def p154k_scalars(body: List<&2,P154Stmt>, facts: P154Facts) -> P154KScalar:
  match body:
    case Nil{}: P154KScalar{[],facts}
    case Con{stmt,rest}: p154k_scalar_next(p154k_scalar(stmt,facts),rest)

@unsafe
def p154k_scalar_bin(+name: P154Name, +typ: N111Type, +op: String, +left: P154Value, +right: P154Value, +facts: P154Facts, +lf: P113KFact, +rf: P113KFact) -> P154KScalar:
  p154p_bin(name,typ,op,left,right,facts,lf,rf,p154p_pick(op,left,right,facts))

@unsafe
def p154k_scalar_join(condition: P154Value, yes: P154KScalar, no: P154KScalar) -> P154KScalar:
  match yes no:
    case P154KScalar{yb,yf} P154KScalar{nb,nf}: P154KScalar{[P154If{condition,yb,nb}],p154k_join(yf,nf,P154FEmpty{})}

@unsafe
def p154k_scalar_if(+condition: P154Value, +yes: List<&2,P154Stmt>, +no: List<&2,P154Stmt>, +facts: P154Facts, fact: P113KFact) -> P154KScalar:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P154KScalar,exact,
        u => nt_choose(P154KScalar,U32.is_eq(lo,0),v => p154k_scalars(no,facts),v => p154k_scalars(yes,facts)),
        u => p154k_scalar_join(condition,p154k_scalars(yes,p154l_assume(facts,condition,True{})),p154k_scalars(no,p154l_assume(facts,condition,False{}))))

@unsafe
def p154k_scalar(+stmt: P154Stmt, +facts: P154Facts) -> P154KScalar:
  p154l_scalar_done(stmt,facts,p154l_base_scalar(stmt,facts))

@unsafe
def p154k_body_append(prefix: List<&2,P154DStmt>, result: P154KBody) -> P154KBody:
  match result:
    case P154KBody{body,facts,terminal}: P154KBody{nt_append(P154DStmt,prefix,body),facts,terminal}

@unsafe
def p154k_body_next(+result: P154KBody, +rest: List<&2,P154DStmt>) -> P154KBody:
  match result:
    case P154KBody{+body,+facts,+terminal}:
      nt_choose(P154KBody,terminal,u => result,u => p154k_body_append(body,p154k_body(rest,facts)))

@unsafe
def p154k_body(body: List<&2,P154DStmt>, facts: P154Facts) -> P154KBody:
  match body:
    case Nil{}: P154KBody{[],facts,False{}}
    case Con{stmt,rest}: p154k_body_next(p154k_stmt(stmt,facts),rest)

@unsafe
def p154k_scalar_body(result: P154KScalar) -> P154KBody:
  match result:
    case P154KScalar{body,facts}: P154KBody{p154d_scalars(body),facts,False{}}

@unsafe
def p154k_body_join(condition: P154Value, yes: P154KBody, no: P154KBody) -> P154KBody:
  match yes no:
    case P154KBody{yb,+yf,+yt} P154KBody{nb,+nf,+nt}:
      P154KBody{[P154DIf{condition,yb,nb}],
        nt_choose(P154Facts,yt,u => nf,u => nt_choose(P154Facts,nt,v => yf,v => p154k_join(yf,nf,P154FEmpty{}))),yt && nt}

@unsafe
def p154k_body_if(+condition: P154Value, +yes: List<&2,P154DStmt>, +no: List<&2,P154DStmt>, +facts: P154Facts, fact: P113KFact) -> P154KBody:
  match fact:
    case P113KFact{bits,+exact,+lo,hi}:
      nt_choose(P154KBody,exact,
        u => nt_choose(P154KBody,U32.is_eq(lo,0),v => p154k_body(no,facts),v => p154k_body(yes,facts)),
        u => p154k_body_join(condition,p154k_body(yes,p154l_assume(facts,condition,True{})),p154k_body(no,p154l_assume(facts,condition,False{}))))

@unsafe
def p154k_stmt(stmt: P154DStmt, +facts: P154Facts) -> P154KBody:
  match stmt:
    case P154DScalar{scalar}: p154k_scalar_body(p154k_scalar(scalar,facts))
    case P154DIf{+condition,yes,no}: p154k_body_if(condition,yes,no,facts,p154k_value(condition,facts))
    case P154DCall{+destinations,target,args}: P154KBody{[P154DCall{destinations,target,p154k_values(args,facts)}],p154k_kill(destinations,facts),False{}}
    case P154DResult{values}: P154KBody{[P154DResult{p154k_values(values,facts)}],facts,True{}}
    case P154DAgain{values}: P154KBody{[P154DAgain{p154k_values(values,facts)}],facts,True{}}

@unsafe
def p154k_function_done(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P154KBody) -> P154DFunction:
  match scan:
    case P154KBody{body,facts,terminal}: P154DFunction{name,params,result,public,body}

@unsafe
def p154k_function(+function: P154DFunction) -> P154DFunction:
  match function:
    case P154DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P154DFunction,U32.is_lt(p154i_size(body),4096),
        u => p154k_function_done(name,params,result,public,p154k_body(body,P154FEmpty{})),u => function)

@unsafe
def p154l_base_scalar(stmt: P154Stmt, +facts: P154Facts) -> P154KScalar:
  match stmt:
    case P154Set{+name,+typ,+value}:
      P154KScalar{[P154Set{name,typ,p154k_replace(value,facts)}],p154k_put(facts,name,p113k_limit(p154k_value(value,facts),p113k_width(typ)))}
    case P154Bin{name,typ,op,+left,+right}: p154k_scalar_bin(name,typ,op,left,right,facts,p154k_value(left,facts),p154k_value(right,facts))
    case P154Call{+name,typ,symbol,args}: P154KScalar{[P154Call{name,typ,symbol,p154k_args(args,facts)}],p154k_put(facts,name,p113k_bound(64))}
    case P154If{+condition,yes,no}: p154k_scalar_if(condition,yes,no,facts,p154k_value(condition,facts))
    case P154Load{+name,typ,base,offset}: P154KScalar{[P154Load{name,typ,base,offset}],p154k_put(facts,name,p113k_bound(64))}
    case P154Store{typ,base,offset,value}: P154KScalar{[P154Store{typ,base,offset,p154k_replace(value,facts)}],facts}
    case P154Offset{+name,base,bytes}: P154KScalar{[P154Offset{name,base,bytes}],p154k_put(facts,name,p113k_bound(64))}
    case P154Alloca{+name,bytes,align}: P154KScalar{[P154Alloca{name,bytes,align}],p154k_put(facts,name,p113k_bound(64))}
    case P154Return{value}: P154KScalar{[P154Return{value}],facts}

@unsafe
def p154l_comparison(+before: P154Facts, +after: P154Facts, +name: P154Name, +op: String, left: P154Value, right: P154Value) -> P154Facts:
  match left right:
    case P154Local{+subject} P154Const{+lo,+hi}:
      nt_choose(P154Facts,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p154k_get(before,subject)),1),
        u => p154l_relate(after,name,subject,p154l_version(before,subject),U32.xor(lo,Bool.to_u32(String.eq(op,"ne")))),u => after)
    case _ _: after

@unsafe
def p154l_bin_relation(+before: P154Facts, +after: P154Facts, +name: P154Name, +op: String, +left: P154Value, +right: P154Value) -> P154Facts:
  nt_choose(P154Facts,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p154k_value(right,before)),
    u => p154l_copy_relation(before,after,name,left,False{}),u =>
  nt_choose(P154Facts,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p154k_value(left,before)),
    u => p154l_copy_relation(before,after,name,right,False{}),u =>
  nt_choose(P154Facts,String.eq(op,"xor") && p113l_exact_one(p154k_value(right,before)),
    u => p154l_copy_relation(before,after,name,left,True{}),u =>
    p154l_comparison(before,after,name,op,p154k_replace(left,before),p154k_replace(right,before)))))

@unsafe
def p154l_scalar_done(stmt: P154Stmt, before: P154Facts, result: P154KScalar) -> P154KScalar:
  match result:
    case P154KScalar{body,facts}: P154KScalar{body,p154l_record(stmt,before,facts)}

@unsafe
def p154p_old_record(stmt: P154Stmt, before: P154Facts, after: P154Facts) -> P154Facts:
  match stmt:
    case P154Set{name,typ,value}: p154l_copy_relation(before,after,name,value,False{})
    case P154Bin{name,typ,op,left,right}: p154l_bin_relation(before,after,name,op,left,right)
    case _: after

@unsafe
def p154p_old_bin(+name: P154Name, +typ: N111Type, +op: String, +left: P154Value, +right: P154Value, +facts: P154Facts, +lf: P113KFact, +rf: P113KFact) -> P154KScalar:
  +answer = p113k_bin_fact(typ,op,lf,rf)
  P154KScalar{[p154k_bin_stmt(name,typ,op,p154k_replace(left,facts),p154k_replace(right,facts),lf,rf,answer)],p154k_put(facts,name,answer)}

@unsafe
def p154p_record(stmt: P154Stmt, +before: P154Facts, +after: P154Facts) -> P154Facts:
  match stmt:
    case P154Set{name,typ,value}: p154p_copy(before,after,name,value)
    case P154Bin{+name,typ,op,left,right}:
      nt_choose(P154Facts,p111v_comparison(op),u => p154p_put(after,name,name,0),u => after)
    case P154If{condition,yes,no}: p154p_diamond(before,after,condition,p154bq_scalar(yes,no))
    case _: after

@unsafe
def p154bq_scalar(yes: List<&2,P154Stmt>, no: List<&2,P154Stmt>) -> P154BQDiamond:
  match yes no:
    case Con{P154Set{+a,N111U64{},P154Const{1,0}},Nil{}} Con{P154Set{b,N111U64{},P154Const{0,0}},Nil{}}:
      nt_choose(P154BQDiamond,p154n_eq(a,b),u => P154BQYes{a,False{}},u => P154BQNo{})
    case Con{P154Set{+a,N111U64{},P154Const{0,0}},Nil{}} Con{P154Set{b,N111U64{},P154Const{1,0}},Nil{}}:
      nt_choose(P154BQDiamond,p154n_eq(a,b),u => P154BQYes{a,True{}},u => P154BQNo{})
    case _ _: P154BQNo{}

@unsafe
def p154i_scalar_size(stmt: P154Stmt) -> U32:
  match stmt:
    case P154If{condition,yes,no}: p113i_add(1,p113i_add(p154i_scalars_size(yes),p154i_scalars_size(no)))
    case _: 1

@unsafe
def p154i_scalars_size(body: List<&2,P154Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head,rest}: p113i_add(p154i_scalar_size(head),p154i_scalars_size(rest))

@unsafe
def p154i_size(body: List<&2,P154DStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{P154DScalar{stmt},rest}: p113i_add(p154i_scalar_size(stmt),p154i_size(rest))
    case Con{P154DIf{condition,yes,no},rest}: p113i_add(1,p113i_add(p154i_size(yes),p113i_add(p154i_size(no),p154i_size(rest))))
    case Con{stmt,rest}: p113i_add(1,p154i_size(rest))

@unsafe
def p154l_relation(+facts: P154Facts, +name: P154Name) -> P154Relation:
  p154l_relation_valid(facts,name,p154f_relation(p154f_get(facts,name)))

@unsafe
def p154l_relation_valid(+facts: P154Facts, +name: P154Name, +relation: P154Relation) -> P154Relation:
  match relation:
    case P154Relation{subject,version,epoch,truth}:
      nt_choose(P154Relation,U32.is_eq(version,p154l_version(facts,subject)) && U32.is_eq(epoch,p154l_version(facts,name)),
        u => relation,u => P154NoRelation{})
    case _: P154NoRelation{}

@unsafe
def p154l_relate(+facts: P154Facts, +name: P154Name, subject: P154Name, version: U32, truth: U32) -> P154Facts:
  p154l_relate_cell(facts,name,subject,version,truth,p154f_get(facts,name))

@unsafe
def p154l_relate_cell(facts: P154Facts, +name: P154Name, subject: P154Name, version: U32, truth: U32, cell: P154FCell) -> P154Facts:
  match cell:
    case P154FCell{old,present,value,+epoch,relation,predicate}:
      p154f_put(facts,name,P154FCell{name,present,value,epoch,P154Relation{subject,version,epoch,truth},predicate})
    case _:
      p154f_put(facts,name,P154FCell{name,False{},p113k_bound(64),0,P154Relation{subject,version,0,truth},P154NoPredicate{}})

@unsafe
def p154l_copy_relation(+before: P154Facts, +after: P154Facts, +name: P154Name, value: P154Value, +invert: Bool) -> P154Facts:
  match value:
    case P154Local{source}: p154l_copy_found(after,name,invert,p154l_relation(before,source))
    case _: after

@unsafe
def p154l_copy_found(+after: P154Facts, name: P154Name, invert: Bool, relation: P154Relation) -> P154Facts:
  match relation:
    case P154Relation{subject,version,epoch,truth}:
      p154l_relate(after,name,subject,version,U32.xor(truth,Bool.to_u32(invert)))
    case _: after

@unsafe
def p154l_record(+stmt: P154Stmt, +before: P154Facts, after: P154Facts) -> P154Facts:
  p154p_record(stmt,before,p154p_old_record(stmt,before,after))

@unsafe
def p154l_assume(+facts: P154Facts, condition: P154Value, +truth: Bool) -> P154Facts:
  match condition:
    case P154Local{name}: p154l_assume_found(facts,truth,p154l_relation(facts,name))
    case _: facts

@unsafe
def p154l_assume_found(+facts: P154Facts, +truth: Bool, relation: P154Relation) -> P154Facts:
  match relation:
    case P154Relation{+subject,version,epoch,value}:
      nt_choose(P154Facts,U32.is_le(p113k_bits_of(p154k_get(facts,subject)),1),
        u => p154k_put(facts,subject,p113k_exact(U32.xor(value,Bool.to_u32(Bool.not(truth))),0)),u => facts)
    case _: facts

@unsafe
def p154p_get(+facts: P154Facts, +name: P154Name) -> P154Predicate:
  p154p_valid(facts,name,p154f_predicate(p154f_get(facts,name)))

@unsafe
def p154p_valid(+facts: P154Facts, +name: P154Name, +predicate: P154Predicate) -> P154Predicate:
  match predicate:
    case P154Predicate{root,version,epoch,invert}:
      nt_choose(P154Predicate,U32.is_eq(version,p154l_version(facts,root)) && U32.is_eq(epoch,p154l_version(facts,name)),
        u => predicate,u => P154NoPredicate{})
    case _: P154NoPredicate{}

@unsafe
def p154p_put(+facts: P154Facts, +name: P154Name, +root: P154Name, invert: U32) -> P154Facts:
  p154p_put_cell(facts,name,root,p154l_version(facts,root),invert,p154f_get(facts,name))

@unsafe
def p154p_put_cell(facts: P154Facts, +name: P154Name, root: P154Name, version: U32, invert: U32, cell: P154FCell) -> P154Facts:
  match cell:
    case P154FCell{old,present,value,+epoch,relation,predicate}:
      p154f_put(facts,name,P154FCell{name,present,value,epoch,relation,P154Predicate{root,version,epoch,invert}})
    case _:
      p154f_put(facts,name,P154FCell{name,False{},p113k_bound(64),0,P154NoRelation{},P154Predicate{root,version,0,invert}})

@unsafe
def p154p_copy(+before: P154Facts, +after: P154Facts, +name: P154Name, value: P154Value) -> P154Facts:
  match value:
    case P154Local{source}: p154p_copy_found(after,name,p154p_get(before,source))
    case _: after

@unsafe
def p154p_copy_found(+after: P154Facts, name: P154Name, predicate: P154Predicate) -> P154Facts:
  match predicate:
    case P154Predicate{+root,version,epoch,invert}:
      nt_choose(P154Facts,U32.is_eq(version,p154l_version(after,root)),u => p154p_put(after,name,root,invert),u => after)
    case _: after

@unsafe
def p154p_diamond(+before: P154Facts, +after: P154Facts, condition: P154Value, diamond: P154BQDiamond) -> P154Facts:
  match condition diamond:
    case P154Local{source} P154BQYes{name,invert}: p154p_diamond_found(after,name,invert,p154p_get(before,source))
    case _ _: after

@unsafe
def p154p_diamond_found(+after: P154Facts, +name: P154Name, invert: Bool, predicate: P154Predicate) -> P154Facts:
  match predicate:
    case P154Predicate{+root,version,epoch,value}:
      nt_choose(P154Facts,Bool.not(p154n_eq(name,root)),u => p154p_put(after,name,root,U32.xor(value,Bool.to_u32(invert))),u => after)
    case _: after

@unsafe
def p154p_test_origin(op: String, lo: U32, predicate: P154Predicate) -> P154Test:
  match predicate:
    case P154Predicate{root,version,epoch,invert}:
      P154Test{root,U32.xor(invert,U32.xor(lo,Bool.to_u32(String.eq(op,"eq"))))}
    case _: P154NoTest{}

@unsafe
def p154p_test(+op: String, value: P154Value, constant: P154Value, +facts: P154Facts) -> P154Test:
  match value constant:
    case P154Local{source} P154Const{+lo,+hi}:
      nt_choose(P154Test,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1),
        u => p154p_test_origin(op,lo,p154p_get(facts,source)),u => P154NoTest{})
    case _ _: P154NoTest{}

@unsafe
def p154p_pick(+op: String, +left: P154Value, +right: P154Value, +facts: P154Facts) -> P154Test:
  p154p_pick_forward(op,left,right,facts,p154p_test(op,left,right,facts))

@unsafe
def p154p_pick_forward(op: String, left: P154Value, right: P154Value, facts: P154Facts, +forward: P154Test) -> P154Test:
  match forward:
    case P154Test{root,invert}: forward
    case _: p154p_test(op,right,left,facts)

@unsafe
def p154p_bin(+name: P154Name, +typ: N111Type, +op: String, +left: P154Value, +right: P154Value, +facts: P154Facts,
    +lf: P113KFact, +rf: P113KFact, record: P154Test) -> P154KScalar:
  match record:
    case P154Test{+root,invert}:
      P154KScalar{[nt_choose(P154Stmt,U32.is_eq(invert,0),
        u => P154Set{name,N111U32{},P154Local{root}},
        u => P154Bin{name,N111U32{},"xor",P154Local{root},P154Const{1,0}})],
        p154k_put(facts,name,p113k_bin_fact(typ,op,lf,rf))}
    case _: p154p_old_bin(name,typ,op,left,right,facts,lf,rf)

