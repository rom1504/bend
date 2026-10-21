# Experimental exact entry-origin analysis. Only checked scalar/unshared array
# emission reaches this hook. Unknown facts lose opportunities, never guards.
# Origin 0 is unknown; origin i+1 is the full original parameter word i.
type P117HScan is Data:
  P117HScan{+facts: KDef, +slots: KDef, +mask: U32, +used: U32,
    +again: Bool, +left: U32, +next: U32, +sites: KDef}

@unsafe
def p117h_get(+facts: KDef, +name: String) -> U32:
  +found = p111v_get(facts,name)
  nt_choose(U32,String.eq(dk(found),"P117HOrigin"),u => da(found),u => 0)

@unsafe
def p117h_put(facts: KDef, +name: String, origin: U32) -> KDef:
  index_set(facts,KDef{name,"P117HOrigin",origin,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p117h_value(value: N111Value, +facts: KDef) -> U32:
  match value:
    case N111Local{name}: p117h_get(facts,name)
    case _: 0

@unsafe
def p117h_bit(+origin: U32) -> U32:
  nt_choose(U32,U32.is_eq(origin,0),u => 0,u => U32.shln(1,U32.to_nat(U32.sub(origin,1))))

@unsafe
def p117h_seed(params: List<&2,NC_Binding>, +origin: U32, facts: KDef) -> KDef:
  match params:
    case Nil{}: facts
    case Con{NC_Binding{id,name,kind},rest}: p117h_seed(rest,U32.inc(origin),p117h_put(facts,name,origin))

@unsafe
def p117h_params_clean(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,name,kind},rest}: Bool.not(p117h_buffer(name)) && p117h_params_clean(rest)

@unsafe
def p117h_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p113j_buffer_origin(name,False{})

@unsafe
def p117h_slot(+base: N111Value, +offset: U32) -> String:
  match base:
    case N111Local{+name}:
      nt_choose(String,p117h_buffer(name) && U32.is_eq(U32.and(offset,7),0),
        u => name ++ ":" ++ U32.show(offset),u => "")
    case _: ""

@unsafe
def p117h_load(+base: N111Value, +offset: U32, +slots: KDef) -> U32:
  +key = p117h_slot(base,offset)
  nt_choose(U32,String.eq(key,""),u => 0,u => p117h_get(slots,key))

@unsafe
def p117h_write(+base: N111Value, +offset: U32, +origin: U32, +slots: KDef) -> KDef:
  +key = p117h_slot(base,offset)
  nt_choose(KDef,String.eq(key,""),u => missing(),u => p117h_put(slots,key,origin))

@unsafe
def p117h_set(+name: String, origin: U32, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_put(facts,name,origin),slots,
        nt_choose(U32,p117h_buffer(name),u => 0,u => mask),used,again,left,next,sites}

def p117h_abort(scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{missing(),missing(),0,used,again,0,next,sites}

@unsafe
def p117h_kill(names: List<&2,String>, facts: KDef) -> KDef:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p117h_kill(rest,p117h_put(facts,name,0))

# Calls invalidate all scratch/output memory knowledge, even when their normal
# signature does not mention a buffer. Verified array helpers restore only their
# exact transfer identity, never payload knowledge or uniqueness.
@unsafe
def p117h_call(+name: String, +id: U32, +args: List<&2,N111Arg>, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,+slots,mask,used,again,left,next,sites}:
      +origin = nt_choose(U32,U32.is_eq(id,0),u => 0,u => p117h_load(p111v_arg(args,2),0,slots))
      P117HScan{p117h_put(facts,name,nt_choose(U32,U32.is_eq(id,73),u => origin,u => 0)),
        nt_choose(KDef,U32.is_eq(id,72) || U32.is_eq(id,74) || U32.is_eq(id,75),
          u => p117h_write(p111v_arg(args,4),0,origin,missing()),u => missing()),
        nt_choose(U32,p117h_buffer(name),u => 0,u => mask),U32.or(used,p117h_bit(origin)),again,left,
        nt_choose(U32,U32.is_eq(id,0),u => next,u => U32.inc(next)),
        nt_choose(KDef,U32.is_eq(id,0),u => sites,u => p117h_put(sites,U32.show(next),origin))}

@unsafe
def p117h_scalar(+stmt: N111Stmt, +scan: P117HScan) -> P117HScan:
  match stmt scan:
    case N111Set{name,N111Ptr{},value} _: p117h_abort(scan)
    case N111Set{name,N111U64{},value} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      p117h_set(name,p117h_value(value,facts),scan)
    case N111Set{name,typ,value} _: p117h_set(name,0,scan)
    case N111Load{name,N111U64{},base,offset} P117HScan{facts,+slots,mask,used,again,left,next,sites}:
      p117h_set(name,p117h_load(base,offset,slots),scan)
    case N111Load{name,typ,base,offset} _: p117h_set(name,0,scan)
    case N111Bin{name,typ,op,left,right} _: p117h_set(name,0,scan)
    case N111Offset{name,base,bytes} _: p117h_abort(scan)
    case N111Alloca{name,bytes,align} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_put(facts,name,0),slots,mask,used,again,left,next,sites}
    case N111Store{N111U64{},base,offset,value} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      P117HScan{facts,p117h_write(base,offset,p117h_value(value,facts),slots),mask,used,again,left,next,sites}
    case N111Store{typ,base,offset,value} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{facts,missing(),mask,used,again,left,next,sites}
    case N111Call{name,N111U64{},symbol,args} _: p117h_call(name,p113a_call_id(symbol,args),args,scan)
    case N111Call{name,typ,symbol,args} _: p117h_call(name,0,args,scan)
    case N111If{condition,yes,no} _: p117h_diamond(p113bq_scalar(yes,no),scan)
    case _ _: scan

@unsafe
def p117h_backedge(values: List<&2,N111Value>, +facts: KDef, +origin: U32, +count: U32) -> U32:
  match values:
    case Nil{}: nt_choose(U32,U32.is_eq(origin,U32.inc(count)),u => 65535,u => 0)
    case Con{value,rest}:
      U32.and(p117h_backedge(rest,facts,U32.inc(origin),count),
        nt_choose(U32,U32.is_eq(p117h_value(value,facts),origin),u => 65535,
          u => U32.xor(65535,p117h_bit(origin))))

@unsafe
def p117h_walk(body: List<&2,P113DStmt>, +count: U32, +scan: P117HScan) -> P117HScan:
  match body scan:
    case Nil{} _: scan
    case _ P117HScan{facts,slots,mask,used,again,0,next,sites}:
      P117HScan{facts,slots,0,used,again,0,next,sites}
    case Con{head,rest} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      p117h_walk(rest,count,p117h_head(head,count,P117HScan{facts,slots,mask,used,again,U32.sub(left,1),next,sites}))

@unsafe
def p117h_head(+stmt: P113DStmt, +count: U32, +scan: P117HScan) -> P117HScan:
  match stmt scan:
    case P113DScalar{scalar} _: p117h_scalar(scalar,scan)
    case P113DCall{names,target,args} P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_kill(names,facts),missing(),mask,used,again,left,next,sites}
    case P113DAgain{values} P117HScan{+facts,slots,mask,used,again,left,next,sites}:
      P117HScan{missing(),missing(),U32.and(mask,p117h_backedge(values,facts,1,count)),used,True{},left,next,sites}
    case P113DIf{condition,yes,no} P117HScan{+facts,+slots,mask,used,again,left,next,sites}:
      p117h_branches(no,count,facts,slots,p117h_walk(yes,count,scan))
    case _ _: scan

# Only the existing exact literal1/0 diamond is admitted. Both arms are one
# U64 assignment, so only that destination loses its origin. No sites/effects.
@unsafe
def p117h_diamond(diamond: P113BQDiamond, +scan: P117HScan) -> P117HScan:
  match diamond:
    case P113BQYes{name,invert}: p117h_set(name,0,scan)
    case P113BQNo{}: p117h_abort(scan)

# Exact immutable-origin intersection. Unknown/absent facts are not retained;
# equality of mutable variable names alone would not establish a shared origin.
@unsafe
def p117h_common_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      +name = dn(head)
      +origin = da(head)
      p117h_common_bucket(rest,right,nt_choose(KDef,
        String.eq(dk(head),"P117HOrigin") && U32.is_gt(origin,0) && U32.is_eq(origin,p117h_get(right,name)),
        u => p117h_put(out,name,origin),u => out))

@unsafe
def p117h_common(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p117h_common_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p117h_common(b,right,p117h_common(a,right,out))
    case _: out

# Each branch starts with the same incoming facts. Site records/backedge
# obligations accumulate across both arms; continuing facts must agree exactly.
# Including a terminal arm in the intersection is conservative.
@unsafe
def p117h_branches(no: List<&2,P113DStmt>, +count: U32, facts: KDef, slots: KDef, yes: P117HScan) -> P117HScan:
  match yes:
    case P117HScan{yf,ys,mask,used,again,left,next,sites}:
      p117h_join(yf,ys,p117h_walk(no,count,P117HScan{facts,slots,mask,used,again,left,next,sites}))

@unsafe
def p117h_join(yf: KDef, ys: KDef, scan: P117HScan) -> P117HScan:
  match scan:
    case P117HScan{facts,slots,mask,used,again,left,next,sites}:
      P117HScan{p117h_common(yf,facts,missing()),p117h_common(ys,slots,missing()),mask,used,again,left,next,sites}

# Layout projection hooks. Packed32 composition overrides these three helpers;
# bytebase always shifts location by3 because locations use heap-word units.
def p117h_raw_tag() -> U32: 4
def p117h_index_shift() -> U32: 2
def p117h_cell_type() -> N111Type: N111U32{}

@unsafe
def p117h_name(origin: U32, role: String) -> String:
  p113a_name(origin,"hoist_" ++ role)

@unsafe
def p117h_ref(origin: U32, role: String) -> N111Value:
  N111Local{p117h_name(origin,role)}

@unsafe
def p117h_metadata(+name: String, +origin: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  [N111Set{p117h_name(origin,"array"),N111U64{},N111Local{name}},
   N111Bin{p117h_name(origin,"tag"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{56,0}},
   N111Bin{p117h_name(origin,"raw"),N111U64{},"eq",p117h_ref(origin,"tag"),N111Const{p117h_raw_tag(),0}},
   N111Bin{p117h_name(origin,"location"),N111U64{},"and",p117h_ref(origin,"array"),N111Const{4294967295,255}},
   N111Bin{p117h_name(origin,"dynamic"),N111U64{},"uge",p117h_ref(origin,"location"),N111Const{heap_min,0}},
   N111Bin{p117h_name(origin,"admitted"),N111U32{},"and",p117h_ref(origin,"raw"),p117h_ref(origin,"dynamic")},
   N111Bin{p117h_name(origin,"class"),N111U64{},"shr",p117h_ref(origin,"array"),N111Const{40,0}},
   N111Bin{p117h_name(origin,"class"),N111U64{},"and",p117h_ref(origin,"class"),N111Const{31,0}},
   N111Bin{p117h_name(origin,"size"),N111U64{},"shl",N111Const{1,0},p117h_ref(origin,"class")},
   N111Bin{p117h_name(origin,"mask"),N111U64{},"sub",p117h_ref(origin,"size"),N111Const{1,0}},
   N111Bin{p117h_name(origin,"bytes"),N111U64{},"shl",p117h_ref(origin,"location"),N111Const{3,0}},
   N111Offset{p117h_name(origin,"base"),N111Local{"p113a_heap_base"},p117h_ref(origin,"bytes")}]

@unsafe
def p117h_prelude(params: List<&2,NC_Binding>, +origin: U32, +used: U32, +heap_min: U32) -> List<&2,N111Stmt>:
  match params:
    case Nil{}: []
    case Con{NC_Binding{id,name,kind},rest}:
      nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
        u => [],u => p117h_metadata(name,origin,heap_min)),p117h_prelude(rest,U32.inc(origin),used,heap_min))

@unsafe
def p117h_address(+id: U32, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,[
    N111Bin{p113a_name(n,"index"),N111U64{},"and",p113a_value(n,"index"),p117h_ref(origin,"mask")},
    N111Bin{p113a_name(n,"bytes"),N111U64{},"shl",p113a_value(n,"index"),N111Const{p117h_index_shift(),0}},
    N111Offset{p113a_name(n,"cell"),p117h_ref(origin,"base"),p113a_value(n,"bytes")}],
    nt_choose(List<&2,N111Stmt>,U32.is_eq(id,73),u => [],
      u => [N111Load{p113a_name(n,"old"),p117h_cell_type(),p113a_value(n,"cell"),0}]))

@unsafe
def p117h_template(+original: N111Stmt, +n: U32, +origin: U32) -> List<&2,N111Stmt>:
  match original:
    case N111Call{destination,N111U64{},symbol,+args}:
      +id = p113a_call_id(symbol,args)
      nt_append(N111Stmt,p113a_inputs(id,p111v_arg(args,2),n),[
        N111If{p117h_ref(origin,"admitted"),
          nt_choose(List<&2,N111Stmt>,U32.is_eq(id,75),
            u => p113a_pair_store(destination,p111v_arg(args,4),p117h_ref(origin,"size"),n),
            u => nt_append(N111Stmt,p117h_address(id,n,origin),p113a_success(id,destination,p111v_arg(args,4),n))),[original]}])
    case _: [original]

@unsafe
def p117h_rewrite(body: List<&2,P113DStmt>, +n: U32, +heap_min: U32, +used: U32, +sites: KDef) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],n}
    case Con{P113DScalar{+stmt},+rest}:
      +origin = p117h_get(sites,U32.show(n))
      nt_choose(P113ABody,U32.is_eq(p113a_stmt_id(stmt),0),
        u => p113a_prefix([P113DScalar{stmt}],p117h_rewrite(rest,n,heap_min,used,sites)),u =>
        p113a_prefix(p113d_scalars(nt_choose(List<&2,N111Stmt>,U32.is_eq(U32.and(used,p117h_bit(origin)),0),
          v => p113a_template(stmt,n,heap_min),v => p117h_template(stmt,n,origin))),
          p117h_rewrite(rest,U32.inc(n),heap_min,used,sites)))
    case Con{P113DIf{condition,yes,no},rest}:
      p117h_rewrite_yes(condition,no,rest,heap_min,used,sites,p117h_rewrite(yes,n,heap_min,used,sites))
    case Con{head,rest}: p113a_prefix([head],p117h_rewrite(rest,n,heap_min,used,sites))

@unsafe
def p117h_rewrite_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: p117h_rewrite_no(condition,body,rest,heap_min,used,sites,p117h_rewrite(no,next,heap_min,used,sites))

@unsafe
def p117h_rewrite_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +heap_min: U32, +used: U32, +sites: KDef, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],p117h_rewrite(rest,next,heap_min,used,sites))

@unsafe
def p117h_private(function: P113DFunction, +ids: N111Ids, prelude: List<&2,N111Stmt>) -> String:
  match function:
    case P113DFunction{name,+params,+result,public,+body}:
      +allocas = p113e_allocas(body,["%v_scratch =l alloc8 2048\n"])
      +allocas = nt_choose(List<&2,String>,p113e_multi(body),u => Con{"%p113_results =l alloc8 64\n",allocas},u => allocas)
      "function l $" ++ p113e_symbol(name) ++ "(" ++ p113e_formals(params,nt_choose(String,U32.is_eq(result,1),u => "l %state",u => "l %state, l %p113_result_out")) ++ ") {\n@entry\n" ++
        p111q_body_text(p113ah_loop(body,params,ids,p111q_stmts(
          Con{N111Load{"p113a_heap_base",N111Ptr{},N111Local{"state"},0},prelude},ids,P111QCode{allocas,0,False{},""}))) ++ "}\n"

@unsafe
def p117h_finish(+function: P113DFunction, +ids: N111Ids, +heap_min: U32, scan: P117HScan) -> String:
  match function scan:
    case P113DFunction{name,+params,result,public,body} P117HScan{facts,slots,+mask,+used,+again,left,next,+sites}:
      +used = U32.and(mask,used)
      nt_choose(String,again && U32.is_gt(used,0),u =>
        p117h_private(p113a_function_done(name,params,result,public,p117h_rewrite(body,0,heap_min,used,sites)),ids,
          p117h_prelude(params,1,used,heap_min)),
        u => p113ah_private(p113a_function(function,heap_min),ids))

@unsafe
def p113ah_function(+function: P113DFunction, +ids: N111Ids, +heap_min: U32) -> String:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      +count = nt_count(NC_Binding,params)
      nt_choose(String,U32.is_eq(p113a_count_body(body,0),0),u => p113e_private(function,ids),u =>
        nt_choose(String,U32.is_gt(count,16) || Bool.not(p117h_params_clean(params)),u => p113ah_private(p113a_function(function,heap_min),ids),u =>
          p117h_finish(function,ids,heap_min,p117h_walk(body,count,
            P117HScan{p117h_seed(params,1,missing()),missing(),U32.sub(U32.shln(1,U32.to_nat(count)),1),0,False{},8192,0,missing()}))))
