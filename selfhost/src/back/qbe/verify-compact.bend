# Optimized direct-admission verifier. The original raw and final verifiers
# remain independent and unchanged. Schema facts are private to each call.
# Exact spellings map to dense IDs; numeric flow tracks assignment/capacity.

type P147VFact is Data:
  P147VAbsent{}
  P147VFact{+name: String, +id: U32, +kind: U32, +width: U32, +capacity: U32}

type P147VTable is Data:
  P147VEmpty{}
  P147VLeaf{+hash: U32, +bucket: List<&2,P147VFact>}
  P147VNode{+prefix: U32, +mask: U32, +left: P147VTable, +right: P147VTable}

type P147VLive is Data:
  P147VNone{}
  P147VCell{+id: U32, +capacity: U32}
  P147VFork{+prefix: U32, +mask: U32, +left: P147VLive, +right: P147VLive}

type P147VEnv is Data:
  P147VEnv{+schema: P147VTable, +assigned: P147VLive}

type P147VScan is Data:
  P147VScan{+index: P147VTable, +error: String, +count: U32}

type P147VFlow is Data:
  P147VFlow{+live: P147VEnv, +terminal: Bool, +error: String}

def p147v_present(fact: P147VFact) -> Bool:
  match fact:
    case P147VAbsent{}: False{}
    case _: True{}

def p147v_kind(fact: P147VFact) -> U32:
  match fact:
    case P147VFact{name,id,kind,width,capacity}: kind
    case _: 0

def p147v_width(fact: P147VFact) -> U32:
  match fact:
    case P147VFact{name,id,kind,width,capacity}: width
    case _: 0

@unsafe
def p147v_bucket(+bucket: List<&2,P147VFact>, +name: String) -> P147VFact:
  match bucket:
    case Nil{}: P147VAbsent{}
    case Con{+head,rest}:
      match head:
        case P147VFact{+word,id,kind,width,capacity}:
          nt_choose(P147VFact,String.eq(word,name),u => head,u => p147v_bucket(rest,name))
        case _: p147v_bucket(rest,name)

@unsafe
def p147v_lookup(+tree: P147VTable, +name: String, +hash: U32) -> P147VFact:
  match tree:
    case P147VEmpty{}: P147VAbsent{}
    case P147VLeaf{stored,bucket}:
      nt_choose(P147VFact,U32.is_eq(stored,hash),u => p147v_bucket(bucket,name),u => P147VAbsent{})
    case P147VNode{prefix,mask,left,right}:
      nt_choose(P147VFact,U32.is_eq(U32.and(U32.xor(prefix,hash),U32.sub(mask,1)),0),
        u => nt_choose(P147VFact,U32.is_eq(U32.and(hash,mask),0),v => p147v_lookup(left,name,hash),v => p147v_lookup(right,name,hash)),
        u => P147VAbsent{})

@unsafe
def p147v_get(+tree: P147VTable, +name: String) -> P147VFact:
  p147v_lookup(tree,name,index_hash(name,2166136261))

@unsafe
def p147v_remove(+bucket: List<&2,P147VFact>, +name: String) -> List<&2,P147VFact>:
  match bucket:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case P147VFact{word,id,kind,width,capacity}:
          nt_choose(List<&2,P147VFact>,String.eq(word,name),u => p147v_remove(rest,name),u => Con{head,p147v_remove(rest,name)})
        case _: p147v_remove(rest,name)

@unsafe
def p147v_table_join(+old: P147VTable, +prefix: U32, +hash: U32, +mask: U32, +fact: P147VFact) -> P147VTable:
  nt_choose(P147VTable,U32.is_eq(U32.and(hash,mask),0),
    u => P147VNode{prefix,mask,P147VLeaf{hash,[fact]},old},
    u => P147VNode{prefix,mask,old,P147VLeaf{hash,[fact]}})

@unsafe
def p147v_insert(+tree: P147VTable, +name: String, +hash: U32, +fact: P147VFact) -> P147VTable:
  match tree:
    case P147VEmpty{}: P147VLeaf{hash,[fact]}
    case P147VLeaf{+stored,bucket}:
      nt_choose(P147VTable,U32.is_eq(stored,hash),
        u => P147VLeaf{hash,Con{fact,p147v_remove(bucket,name)}},
        u => p147v_table_join(tree,stored,hash,index_split_bit(U32.xor(stored,hash)),fact))
    case P147VNode{+prefix,+mask,left,right}:
      nt_choose(P147VTable,U32.is_eq(U32.and(U32.xor(prefix,hash),U32.sub(mask,1)),0),
        u => nt_choose(P147VTable,U32.is_eq(U32.and(hash,mask),0),
          v => P147VNode{prefix,mask,p147v_insert(left,name,hash,fact),right},
          v => P147VNode{prefix,mask,left,p147v_insert(right,name,hash,fact)}),
        u => p147v_table_join(tree,prefix,hash,index_split_bit(U32.xor(prefix,hash)),fact))

@unsafe
def p147v_put(+tree: P147VTable, +name: String, +id: U32, +kind: U32, +width: U32, +capacity: U32) -> P147VTable:
  p147v_insert(tree,name,index_hash(name,2166136261),P147VFact{name,id,kind,width,capacity})

@unsafe
def p147n_get(+tree: P147VLive, +id: U32) -> P147VLive:
  match tree:
    case P147VNone{}: tree
    case P147VCell{stored,capacity}: nt_choose(P147VLive,U32.is_eq(stored,id),u => tree,u => P147VNone{})
    case P147VFork{prefix,mask,left,right}:
      nt_choose(P147VLive,U32.is_eq(U32.and(id,mask),0),u => p147n_get(left,id),u => p147n_get(right,id))

# Scalar consumers do not need to reconstruct the P147VCell returned by get.
# Presence is separate from capacity: an assigned zero-capacity pointer exists.
@unsafe
def p147n_has(+tree: P147VLive, +id: U32) -> Bool:
  match tree:
    case P147VNone{}: False{}
    case P147VCell{stored,capacity}: U32.is_eq(stored,id)
    case P147VFork{prefix,mask,left,right}:
      nt_choose(Bool,U32.is_eq(U32.and(id,mask),0),u => p147n_has(left,id),u => p147n_has(right,id))

@unsafe
def p147n_capacity_at(+tree: P147VLive, +id: U32) -> U32:
  match tree:
    case P147VNone{}: 0
    case P147VCell{stored,capacity}: nt_choose(U32,U32.is_eq(stored,id),u => capacity,u => 0)
    case P147VFork{prefix,mask,left,right}:
      nt_choose(U32,U32.is_eq(U32.and(id,mask),0),u => p147n_capacity_at(left,id),u => p147n_capacity_at(right,id))

@unsafe
def p147n_memory_at(+tree: P147VLive, +id: U32, +offset: U32, +bytes: U32) -> Bool:
  match tree:
    case P147VNone{}: False{}
    case P147VCell{stored,+capacity}:
      U32.is_eq(stored,id) && U32.is_ge(capacity,bytes) &&
        U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)
    case P147VFork{prefix,mask,left,right}:
      nt_choose(Bool,U32.is_eq(U32.and(id,mask),0),
        u => p147n_memory_at(left,id,offset,bytes),u => p147n_memory_at(right,id,offset,bytes))

@unsafe
def p147n_join(+tree: P147VLive, +prefix: U32, +id: U32, +capacity: U32, +mask: U32) -> P147VLive:
  nt_choose(P147VLive,U32.is_eq(U32.and(id,mask),0),
    u => P147VFork{prefix,mask,P147VCell{id,capacity},tree},
    u => P147VFork{prefix,mask,tree,P147VCell{id,capacity}})

@unsafe
def p147n_put(+tree: P147VLive, +id: U32, +capacity: U32) -> P147VLive:
  match tree:
    case P147VNone{}: P147VCell{id,capacity}
    case P147VCell{+stored,old}:
      nt_choose(P147VLive,U32.is_eq(stored,id),u => P147VCell{id,capacity},
        u => p147n_join(tree,stored,id,capacity,index_split_bit(U32.xor(stored,id))))
    case P147VFork{+prefix,+mask,left,right}:
      nt_choose(P147VLive,U32.is_eq(U32.and(U32.xor(prefix,id),U32.sub(mask,1)),0),
        u => nt_choose(P147VLive,U32.is_eq(U32.and(id,mask),0),
          v => P147VFork{prefix,mask,p147n_put(left,id,capacity),right},
          v => P147VFork{prefix,mask,left,p147n_put(right,id,capacity)}),
        u => p147n_join(tree,prefix,id,capacity,index_split_bit(U32.xor(prefix,id))))

@unsafe
def p147n_node(prefix: U32, mask: U32, left: P147VLive, right: P147VLive) -> P147VLive:
  match left right:
    case P147VNone{} _: right
    case _ P147VNone{}: left
    case _ _: P147VFork{prefix,mask,left,right}

@unsafe
def p147n_equal_capacity(id: U32, +capacity: U32, other: P147VLive) -> P147VLive:
  match other:
    case P147VCell{stored,found}:
      P147VCell{id,nt_choose(U32,U32.is_eq(capacity,found),u => capacity,u => 0)}
    case _: P147VNone{}

@unsafe
def p147n_intersection(+left: P147VLive, +right: P147VLive) -> P147VLive:
  match left right:
    case P147VNone{} _: P147VNone{}
    case _ P147VNone{}: P147VNone{}
    case P147VCell{id,capacity} _: p147n_equal_capacity(id,capacity,p147n_get(right,id))
    case _ P147VCell{id,capacity}: p147n_equal_capacity(id,capacity,p147n_get(left,id))
    case P147VFork{+lp,+lm,la,lb} P147VFork{+rp,+rm,ra,rb}:
      nt_choose(P147VLive,U32.is_eq(lm,rm),
        u => nt_choose(P147VLive,U32.is_eq(U32.and(U32.xor(lp,rp),U32.sub(lm,1)),0),
          v => p147n_node(lp,lm,p147n_intersection(la,ra),p147n_intersection(lb,rb)),v => P147VNone{}),
        u => nt_choose(P147VLive,U32.is_lt(lm,rm),
          v => nt_choose(P147VLive,U32.is_eq(U32.and(U32.xor(lp,rp),U32.sub(lm,1)),0),
            w => nt_choose(P147VLive,U32.is_eq(U32.and(rp,lm),0),x => p147n_intersection(la,right),x => p147n_intersection(lb,right)),
            w => P147VNone{}),
          v => nt_choose(P147VLive,U32.is_eq(U32.and(U32.xor(lp,rp),U32.sub(rm,1)),0),
            w => nt_choose(P147VLive,U32.is_eq(U32.and(lp,rm),0),x => p147n_intersection(left,ra),x => p147n_intersection(left,rb)),
            w => P147VNone{})))

@unsafe
def p147n_seed_bucket(bucket: List<&2,P147VFact>, live: P147VLive) -> P147VLive:
  match bucket:
    case Nil{}: live
    case Con{P147VFact{name,id,kind,width,capacity},rest}: p147n_seed_bucket(rest,p147n_put(live,id,capacity))
    case Con{P147VAbsent{},rest}: p147n_seed_bucket(rest,live)

@unsafe
def p147n_seed(schema: P147VTable, live: P147VLive) -> P147VLive:
  match schema:
    case P147VEmpty{}: live
    case P147VLeaf{hash,bucket}: p147n_seed_bucket(bucket,live)
    case P147VNode{prefix,mask,left,right}: p147n_seed(right,p147n_seed(left,live))

@unsafe
def p147v_live_put(+live: P147VEnv, +name: String, +capacity: U32) -> P147VEnv:
  match live:
    case P147VEnv{+schema,assigned}:
      p147v_live_put_fact(p147v_get(schema,name),schema,assigned,capacity)

@unsafe
def p147v_live_put_fact(fact: P147VFact, schema: P147VTable, assigned: P147VLive, capacity: U32) -> P147VEnv:
  match fact:
    case P147VFact{word,id,kind,width,old}: P147VEnv{schema,p147n_put(assigned,id,capacity)}
    case _: P147VEnv{schema,assigned}

@unsafe
def p147v_decl_id(fact: P147VFact, count: U32) -> U32:
  match fact:
    case P147VFact{name,id,kind,width,capacity}: id
    case _: count

@unsafe
def p147v_decl(+name: String, +width: U32, +capacity: U32, +alloca: Bool, +scan: P147VScan) -> P147VScan:
  match scan:
    case P147VScan{+index,+error,+count}:
      +old = p147v_get(index,name)
      nt_choose(P147VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P147VScan,Bool.not(p111v_name_chars(name,0)) || String.eq(name,"state"),u => P147VScan{index,"invalid/reserved local name: " ++ name,count},u =>
      nt_choose(P147VScan,p147v_present(old) && (alloca || U32.is_eq(p147v_kind(old),1) || Bool.not(U32.is_eq(p147v_width(old),width))),
        u => P147VScan{index,"local width/allocation changes: " ++ name,count},
        u => P147VScan{p147v_put(index,name,p147v_decl_id(old,count),nt_choose(U32,alloca,v => 1,v => 0),width,capacity),"",
          nt_choose(U32,p147v_present(old),v => count,v => U32.inc(count))})))

@unsafe
def p147v_local(+name: String, +width: U32, live: P147VEnv) -> Bool:
  match live:
    case P147VEnv{schema,assigned}:
      p147v_local_fact(p147v_get(schema,name),width,assigned)

@unsafe
def p147v_local_fact(fact: P147VFact, width: U32, assigned: P147VLive) -> Bool:
  match fact:
    case P147VFact{word,id,kind,found,capacity}: U32.is_eq(found,width) && p147n_has(assigned,id)
    case _: False{}

@unsafe
def p147v_assign(+name: String, +schema: P147VTable, live: P147VEnv) -> P147VEnv:
  match live:
    case P147VEnv{context,assigned}:
      p147v_assign_fact(p147v_get(schema,name),context,assigned)

@unsafe
def p147v_assign_fact(fact: P147VFact, context: P147VTable, assigned: P147VLive) -> P147VEnv:
  match fact:
    case P147VFact{word,id,kind,width,capacity}: P147VEnv{context,p147n_put(assigned,id,capacity)}
    case _: P147VEnv{context,assigned}

@unsafe
def p147v_intersection(left: P147VEnv, right: P147VEnv) -> P147VEnv:
  match left right:
    case P147VEnv{schema,a} P147VEnv{other,b}: P147VEnv{schema,p147n_intersection(a,b)}


# Existing verifier decisions below retain their original ordered predicates.

@unsafe
def p147v_schema_stmt(+stmt: N111Stmt, +scan: P147VScan) -> P147VScan:
  match stmt:
    case N111Set{name,typ,value}: p147v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Bin{name,typ,op,left,right}: p147v_decl(name,nt_choose(U32,p111v_comparison(op),u => 1,u => p111v_type(typ)),0,False{},scan)
    case N111Call{name,typ,symbol,args}: p147v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Load{name,typ,base,offset}: p147v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Offset{name,base,bytes}: p147v_decl(name,3,0,False{},scan)
    case N111Alloca{name,bytes,align}: p147v_decl(name,3,bytes,True{},scan)
    case N111If{condition,yes,no}: p147v_schema(no,p147v_schema(yes,scan))
    case _: scan

@unsafe
def p147v_schema(+body: List<&2,N111Stmt>, +scan: P147VScan) -> P147VScan:
  match body scan:
    case Nil{} _: scan
    case Con{head,rest} P147VScan{index,+error,+count}:
      nt_choose(P147VScan,String.is_empty(error) && U32.is_le(count,65535),u => p147v_schema(rest,p147v_schema_stmt(head,scan)),
        u => P147VScan{index,nt_choose(String,String.is_empty(error),v => "too many segment locals",v => error),count})

@unsafe
def p147v_value(+value: N111Value, +width: U32, +live: P147VEnv, +ids: N111Ids) -> Bool:
  match value ids:
    case N111Local{name} _:
      p147v_local(name,width,live)
    case N111Const{lo,hi} _:
      nt_choose(Bool,U32.is_eq(width,1),u => U32.is_eq(hi,0),u =>
        nt_choose(Bool,U32.is_eq(width,3),v => U32.is_eq(lo,0) && U32.is_eq(hi,0),v => U32.is_eq(width,2)))
    case N111FuncId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(functions,name)),"Absent"))
    case N111CtorId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(constructors,name)),"Absent"))
    case N111Symbol{name} _: False{}

@unsafe
def p147v_step(+ok: Bool, +name: String, +schema: P147VTable, +live: P147VEnv, +message: String) -> P147VFlow:
  nt_choose(P147VFlow,ok,u => P147VFlow{nt_choose(P147VEnv,String.is_empty(name),v => live,v => p147v_assign(name,schema,live)),False{},""},
    u => P147VFlow{live,False{},message})

@unsafe
def p147v_capacity(+value: N111Value, +live: P147VEnv) -> U32:
  match value:
    case N111Local{name}: p147v_capacity_local(name,live)
    case _: 0

@unsafe
def p147v_capacity_local(name: String, live: P147VEnv) -> U32:
  match live:
    case P147VEnv{schema,assigned}: p147v_capacity_fact(p147v_get(schema,name),assigned)

@unsafe
def p147v_capacity_fact(fact: P147VFact, assigned: P147VLive) -> U32:
  match fact:
    case P147VFact{name,id,kind,width,capacity}: p147n_capacity_at(assigned,id)
    case _: 0

# Only locals can have positive bounded capacity. The null pointer literal is
# well typed, but its capacity is zero, so every nonzero-width access rejects.
@unsafe
def p147v_memory(+base: N111Value, +offset: U32, +width: U32, +live: P147VEnv, +ids: N111Ids) -> Bool:
  match base live:
    case N111Local{name} P147VEnv{schema,assigned}:
      p147v_memory_fact(p147v_get(schema,name),assigned,offset,nt_choose(U32,U32.is_eq(width,1),u => 4,u => 8))
    case _ _: False{}

@unsafe
def p147v_memory_fact(fact: P147VFact, assigned: P147VLive, offset: U32, bytes: U32) -> Bool:
  match fact:
    case P147VFact{name,id,kind,width,capacity}:
      U32.is_eq(width,3) && p147n_memory_at(assigned,id,offset,bytes)
    case _: False{}

@unsafe
def p147v_join(+yes: P147VFlow, +no: P147VFlow) -> P147VFlow:
  match yes no:
    case P147VFlow{+yl,yt,+ye} P147VFlow{nl,+nt,+ne}:
      nt_choose(P147VFlow,Bool.not(String.is_empty(ye)),u => yes,u =>
      nt_choose(P147VFlow,Bool.not(String.is_empty(ne)),u => no,u =>
      nt_choose(P147VFlow,yt,u => nt_choose(P147VFlow,nt,v => P147VFlow{yl,True{},""},v => no),u =>
      nt_choose(P147VFlow,nt,u => yes,u => P147VFlow{p147v_intersection(yl,nl),False{},""}))))

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.

@unsafe
def p147v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: P147VEnv, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p147v_value(value,width,live,ids) && p147v_args(rest,more,live,ids)
    case _ _: False{}

@unsafe
def p147v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: P147VEnv) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p147v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

@unsafe
def p147v_counted_call(+symbol: String, +args: List<&2,N111Arg>, +live: P147VEnv, +ids: N111Ids) -> Bool:
  +count = p111v_literal(p111v_arg(args,3))
  +target = p111v_target(p111v_arg(args,1),ids,String.eq(symbol,"p111_rt_ctor"))
  p147v_buffer(args,2,count,live) &&
    nt_choose(Bool,String.eq(symbol,"p111_rt_ctor"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_jump"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_closure"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_frame"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target)),u => True{}))))

@unsafe
def p147v_contract(+symbol: String, +args: List<&2,N111Arg>, +live: P147VEnv, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +id = p111v_literal(p111v_arg(args,1))
  +count = p111v_literal(p111v_arg(args,3))
  nt_choose(Bool,String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_frame") || String.eq(symbol,"p111_rt_jump"),
    u => p147v_counted_call(symbol,args,live,ids),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_return"),u => U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p147v_buffer(args,1,result,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_reg_get"),u => U32.is_lt(id,nt_choose(U32,U32.is_gt(incoming,0),v => incoming,v => arity)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_get"),u => U32.is_gt(incoming,0) && U32.is_lt(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_pop"),u => U32.is_gt(incoming,0) && U32.is_eq(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_op"),u => U32.is_gt(id,0) && U32.is_lt(id,86) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p147v_buffer(args,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_ctor"),u => U32.is_eq(count,p111v_special_arity(id)) && p147v_buffer(args,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_take"),u => U32.is_eq(p111v_literal(p111v_arg(args,4)),p111v_special_arity(id)) && p147v_buffer(args,3,p111v_literal(p111v_arg(args,4)),live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_test"),u => U32.is_gt(id,0) && U32.is_lt(id,10),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_fail"),u => U32.is_gt(id,0) && U32.is_le(id,8),u => True{}))))))))))

@unsafe
def p147v_call(+symbol: String, +typ: N111Type, +args: List<&2,N111Arg>, +live: P147VEnv, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +sig = p111v_signature(symbol)
  Bool.not(U32.is_eq(nt_count(U32,sig),0)) && U32.is_eq(p111v_type(typ),2) &&
    p111v_state_argument(args) && p147v_args(args,sig,live,ids) && p147v_contract(symbol,args,live,ids,arity,incoming,result)

@unsafe
def p147v_offset(+name: String, +base: N111Value, +bytes: N111Value, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  +offset = p111v_literal(bytes)
  +capacity = p147v_capacity(base,live)
  nt_choose(P147VFlow,p147v_value(base,3,live,ids) && p147v_value(bytes,2,live,ids) && U32.is_le(offset,capacity),
    u => P147VFlow{p147v_live_put(live,name,U32.sub(capacity,offset)),False{},""},
    u => P147VFlow{live,False{},"unbounded or ill-typed pointer offset"})

@unsafe
def p147v_stmt(+stmt: N111Stmt, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P147VFlow:
  match stmt:
    case N111Set{name,typ,value}: p147v_step(p147v_value(value,p111v_type(typ),live,ids),name,schema,live,"ill-typed or undefined assignment")
    case N111Bin{name,typ,op,left,right}:
      +width = p111v_type(typ)
      p147v_step(U32.is_le(width,2) && p111v_operator(op) && p147v_value(left,width,live,ids) && p147v_value(right,width,live,ids),name,schema,live,"invalid binary operation or operand")
    case N111Call{name,typ,symbol,args}:
      p147v_step(p147v_call(symbol,typ,args,live,ids,arity,incoming,result),name,schema,live,"runtime import signature/count/capacity mismatch: " ++ symbol)
    case N111If{condition,yes,no}:
      nt_choose(P147VFlow,p147v_value(condition,1,live,ids),
        u => p147v_join(p147v_body(yes,schema,P147VFlow{live,False{},""},ids,arity,incoming,result),p147v_body(no,schema,P147VFlow{live,False{},""},ids,arity,incoming,result)),
        u => P147VFlow{live,False{},"condition must be a definitely assigned U32"})
    case N111Return{value}:
      nt_choose(P147VFlow,p147v_value(value,2,live,ids),u => P147VFlow{live,True{},""},u => P147VFlow{live,False{},"segment return must be U64"})
    case N111Load{name,typ,base,offset}:
      p147v_step(p147v_memory(base,offset,p111v_type(typ),live,ids),name,schema,live,"unbounded, unaligned or ill-typed load")
    case N111Store{typ,base,offset,value}:
      p147v_step(p147v_memory(base,offset,p111v_type(typ),live,ids) && p147v_value(value,p111v_type(typ),live,ids),"",schema,live,"unbounded, unaligned or ill-typed store")
    case N111Offset{name,base,bytes}: p147v_offset(name,base,bytes,live,ids)
    case N111Alloca{name,bytes,align}:
      p147v_step(U32.is_gt(bytes,0) && U32.is_le(bytes,2048) && (U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16)),name,schema,live,"unsupported stack allocation size/alignment")

@unsafe
def p147v_body(+body: List<&2,N111Stmt>, +schema: P147VTable, +flow: P147VFlow, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P147VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P147VFlow{live,terminal,+error}:
      nt_choose(P147VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
      nt_choose(P147VFlow,terminal,u => P147VFlow{live,True{},"statement follows terminal path"},u =>
        p147v_body(rest,schema,p147v_stmt(head,schema,live,ids,arity,incoming,result),ids,arity,incoming,result)))

@unsafe
def p147v_finish(flow: P147VFlow) -> String:
  match flow:
    case P147VFlow{live,terminal,+error}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,terminal,v => "",v => "segment has a nonterminal path"))

@unsafe
def p147d_declare_names(names: List<&2,String>, +scan: P147VScan) -> P147VScan:
  match names:
    case Nil{}: scan
    case Con{head,rest}: p147d_declare_names(rest,p147v_decl(head,2,0,False{},scan))

@unsafe
def p147d_schema(body: List<&2,P113DStmt>, +scan: P147VScan) -> P147VScan:
  match body:
    case Nil{}: scan
    case Con{head,rest}: p147d_schema(rest,p147d_schema_stmt(head,scan))

@unsafe
def p147d_schema_stmt(stmt: P113DStmt, +scan: P147VScan) -> P147VScan:
  match stmt:
    case P113DScalar{scalar}: p147v_schema_stmt(scalar,scan)
    case P113DIf{condition,yes,no}: p147d_schema(no,p147d_schema(yes,scan))
    case P113DCall{destinations,target,args}: p147d_declare_names(destinations,scan)
    case _: scan

@unsafe
def p147d_values(values: List<&2,N111Value>, +live: P147VEnv, +ids: N111Ids) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p147v_value(head,2,live,ids) && p147d_values(rest,live,ids)

@unsafe
def p147d_assign_names(names: List<&2,String>, +schema: P147VTable, live: P147VEnv) -> P147VEnv:
  match names:
    case Nil{}: live
    case Con{head,rest}: p147d_assign_names(rest,schema,p147v_assign(head,schema,live))

@unsafe
def p147d_call(+destinations: List<&2,String>, +target: String, +args: List<&2,N111Value>, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids, +ready: KDef) -> P147VFlow:
  +signature = p111v_get(ready,target)
  nt_choose(P147VFlow,String.eq(dk(signature),"P113Direct") && U32.is_eq(da(signature),nt_count(N111Value,args)) &&
    U32.is_eq(dx(signature),nt_count(String,destinations)) && p113e_distinct(destinations) && p147d_values(args,live,ids),
    u => P147VFlow{p147d_assign_names(destinations,schema,live),False{},""},
    u => P147VFlow{live,False{},"unknown/cyclic direct call or argument/result mismatch: " ++ target})

@unsafe
def p147d_vector(+values: List<&2,N111Value>, +count: U32, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  nt_choose(P147VFlow,U32.is_eq(nt_count(N111Value,values),count) && p147d_values(values,live,ids),
    u => P147VFlow{live,True{},""},u => P147VFlow{live,False{},"direct terminal vector has wrong arity/type or undefined value"})

@unsafe
def p147d_body(body: List<&2,P113DStmt>, +schema: P147VTable, +flow: P147VFlow, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P147VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P147VFlow{live,terminal,+error}:
      nt_choose(P147VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
        nt_choose(P147VFlow,terminal,u => P147VFlow{live,True{},"statement follows direct terminal edge"},
          u => p147d_body(rest,schema,p147d_stmt(head,schema,live,ids,ready,arity,result),ids,ready,arity,result)))

@unsafe
def p147d_flow(+body: List<&2,P113DStmt>, +seed: P147VTable, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, scan: P147VScan) -> String:
  match scan:
    case P147VScan{schema,+error,+count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,U32.is_gt(count,65535),u => "too many direct locals",
          u => p147v_finish(p147d_body(body,schema,P147VFlow{P147VEnv{schema,p147n_seed(seed,P147VNone{})},False{},""},ids,ready,arity,result))))

@unsafe
def p147d_seeded(+body: List<&2,P113DStmt>, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32, +scan: P147VScan) -> String:
  match scan:
    case P147VScan{seed,error,count}: p147d_flow(body,seed,ids,ready,arity,result,p147d_schema(body,scan))

@unsafe
def p147d_function(+function: P113DFunction, +ids: N111Ids, +ready: KDef) -> String:
  match function ids:
    case P113DFunction{+name,+params,+result,+public,+body} N111Ids{+original,constructors}:
      +old = p111v_get(original,name)
      nt_choose(String,Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(p111v_get(ready,name)),"Absent")),u => "invalid/duplicate direct function identity",u =>
      nt_choose(String,U32.is_gt(nt_count(NC_Binding,params),255) || U32.is_lt(result,1) || U32.is_gt(result,8),u => "direct signature exceeds ABI boundary",u =>
      nt_choose(String,public && (String.eq(dk(old),"Absent") || Bool.not(U32.is_eq(nt_count(NC_Binding,params),da(old))) || Bool.not(U32.is_eq(result,1)) || Bool.not(U32.is_eq(dx(old),0)) || Bool.not(U32.is_eq(ix(dv(old)),0)) || Bool.not(U32.is_eq(qt(dv(old)),1))),
        u => "public direct wrapper does not preserve original scalar ABI",
        u => p147d_seeded(body,ids,ready,nt_count(NC_Binding,params),result,p147d_seed(params)))))

@unsafe
def p147d_functions(functions: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef) -> String:
  match functions:
    case Nil{}: ""
    case Con{+function,rest}:
      +error = p147d_function(function,ids,ready)
      nt_choose(String,String.is_empty(error),u => p147d_functions(rest,ids,p113e_insert(ready,p113e_signature(function))),u => error)

@unsafe
def p147d_base_stmt(stmt: P113DStmt, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P147VFlow:
  match stmt:
    case P113DScalar{+scalar}:
      nt_choose(P147VFlow,p113e_scalar_safe(scalar),
        u => p147v_stmt(scalar,schema,live,ids,arity,0,result),
        u => P147VFlow{live,False{},"scheduler/state/terminal operation in direct scalar block"})
    case P113DIf{+condition,yes,no}:
      nt_choose(P147VFlow,p147v_value(condition,1,live,ids),
        u => p147v_join(p147d_body(yes,schema,P147VFlow{live,False{},""},ids,ready,arity,result),p147d_body(no,schema,P147VFlow{live,False{},""},ids,ready,arity,result)),
        u => P147VFlow{live,False{},"direct condition must be a definitely assigned U32"})
    case P113DCall{destinations,target,args}: p147d_call(destinations,target,args,schema,live,ids,ready)
    case P113DResult{values}: p147d_vector(values,result,live,ids)
    case P113DAgain{values}: p147d_vector(values,arity,live,ids)

@unsafe
def p147d_product_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  p147v_step(U32.is_eq(p111v_type(typ),2) && p113p_array_call(symbol,args) && p113e_runtime_args(args) &&
    p147v_args(args,[3,1,3,1,3,1],live,ids) && p147v_buffer(args,2,p111v_literal(p111v_arg(args,3)),live) &&
    p147v_memory(p111v_arg(args,4),8,2,live,ids),name,schema,live,"product array import signature/count/capacity mismatch")

@unsafe
def p147x_p118t_import_contract(+symbol: String, +args: List<&2,N111Arg>, +live: P147VEnv, +ids: N111Ids) -> Bool:
  nt_choose(Bool,String.eq(symbol,"p118_rt_extend"),u =>
    p147x_p118t_extend_contract(args,live,ids,p111v_target(p111v_arg(args,2),ids,True{})),u =>
    String.eq(symbol,"p118_rt_finish") && p147v_args(args,[3,2,2,2],live,ids))

@unsafe
def p147x_p118t_extend_contract(+args: List<&2,N111Arg>, +live: P147VEnv, +ids: N111Ids, +constructor: KDef) -> Bool:
  +count = p111v_literal(p111v_arg(args,4))
  p147v_args(args,[3,2,1,3,1],live,ids) && U32.is_ge(count,1) && U32.is_le(count,7) &&
    Bool.not(String.eq(dk(constructor),"Absent")) && U32.is_eq(da(constructor),U32.inc(count)) &&
    p147v_buffer(args,3,count,live)

@unsafe
def p147x_p118t_import_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  p147v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) && p147x_p118t_import_contract(symbol,args,live,ids),
    name,schema,live,"TRMC import signature/constructor/capacity mismatch")

@unsafe
def p147x_p125p_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  +empty = p111v_target(p111v_arg(args,3),ids,True{})
  +link = p111v_target(p111v_arg(args,4),ids,True{})
  p147v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p147v_args(args,[3,2,2,1,1],live,ids) &&
    Bool.not(String.eq(dk(empty),"Absent")) && U32.is_eq(da(empty),0) &&
    Bool.not(String.eq(dk(link),"Absent")) && U32.is_eq(da(link),2) &&
    Bool.not(String.eq(dn(empty),dn(link))),name,schema,live,"concat value import signature/constructor mismatch")

@unsafe
def p147x_p126dp_import(+name: String, +typ: N111Type, +args: List<&2,N111Arg>, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids) -> P147VFlow:
  p147v_step(U32.is_eq(p111v_type(typ),2) && p113e_runtime_args(args) &&
    p147v_args(args,[3,2,2,3],live,ids) && p147v_memory(p111v_arg(args,3),8,2,live,ids),
    name,schema,live,"Nat.divmod product import signature/output capacity mismatch")

@unsafe
def p147d_seed_params(params: List<&2,NC_Binding>, +scan: P147VScan) -> P147VScan:
  match params scan:
    case Nil{} _: scan
    case Con{NC_Binding{id,+word,kind},rest} P147VScan{+index,error,count}:
      nt_choose(P147VScan,p147v_present(p147v_get(index,word)),
        u => P147VScan{index,"duplicate/reserved direct parameter: " ++ word,count},
        u => p147d_seed_params(rest,p147v_decl(word,2,0,False{},scan)))

@unsafe
def p147d_seed(params: List<&2,NC_Binding>) -> P147VScan:
  +state = p147v_put(P147VEmpty{},"state",0,2,3,2088)
  +scratch = p147v_put(state,"scratch",1,1,3,2048)
  p147d_seed_params(params,P147VScan{scratch,"",2})

@unsafe
def p147d_stmt(+stmt: P113DStmt, +schema: P147VTable, +live: P147VEnv, +ids: N111Ids, +ready: KDef, +arity: U32, +result: U32) -> P147VFlow:
  match stmt:
    case P113DScalar{N111Call{+name,+typ,+symbol,+args}}:
      nt_choose(P147VFlow,String.eq(symbol,"p126_rt_nat_divmod"),u => p147x_p126dp_import(name,typ,args,schema,live,ids),u =>
      nt_choose(P147VFlow,String.eq(symbol,"p125_rt_concat_typed"),u => p147x_p125p_import(name,typ,args,schema,live,ids),u =>
      nt_choose(P147VFlow,p118t_import(symbol),u => p147x_p118t_import_call(name,typ,symbol,args,schema,live,ids),u =>
      nt_choose(P147VFlow,String.eq(symbol,"p113_rt_array_pair"),u => p147d_product_call(name,typ,symbol,args,schema,live,ids),
        u => p147d_base_stmt(stmt,schema,live,ids,ready,arity,result)))))
    case _: p147d_base_stmt(stmt,schema,live,ids,ready,arity,result)
