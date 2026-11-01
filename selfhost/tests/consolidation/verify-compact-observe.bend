# Test-only projections into the original verifier's representation.
# Compare semantic rows, not Patricia-tree shape or collision-bucket order.
# These observers are excluded from every timed candidate entry.

def p147test_kind(+kind: U32) -> String:
  nt_choose(String,U32.is_eq(kind,1),u => "alloca",u =>
    nt_choose(String,U32.is_eq(kind,2),v => "parameter",v => "local"))

@unsafe
def p147test_schema_bucket(bucket: List<&2,P147VFact>, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{P147VAbsent{},rest}: p147test_schema_bucket(rest,out)
    case Con{P147VFact{name,id,kind,width,capacity},rest}:
      p147test_schema_bucket(rest,p111v_put(out,name,p147test_kind(kind),width,capacity))

@unsafe
def p147test_schema_rows(table: P147VTable, out: KDef) -> KDef:
  match table:
    case P147VEmpty{}: out
    case P147VLeaf{hash,bucket}: p147test_schema_bucket(bucket,out)
    case P147VNode{prefix,mask,left,right}: p147test_schema_rows(right,p147test_schema_rows(left,out))

@unsafe
def p147test_scan(scan: P147VScan) -> P111VScan:
  match scan:
    case P147VScan{schema,error,count}: P111VScan{p147test_schema_rows(schema,missing()),error,count}

@unsafe
def p147test_live_bucket(bucket: List<&2,P147VFact>, +assigned: P147VLive, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{P147VAbsent{},rest}: p147test_live_bucket(rest,assigned,out)
    case Con{P147VFact{+name,id,+kind,+width,old},+rest}:
      p147test_live_bucket_found(p147n_get(assigned,id),name,kind,width,rest,assigned,out)

@unsafe
def p147test_live_bucket_found(found: P147VLive, name: String, kind: U32, width: U32, rest: List<&2,P147VFact>, assigned: P147VLive, out: KDef) -> KDef:
  match found:
    case P147VCell{key,capacity}:
      p147test_live_bucket(rest,assigned,p111v_put(out,name,p147test_kind(kind),width,capacity))
    case _: p147test_live_bucket(rest,assigned,out)

@unsafe
def p147test_live_rows(schema: P147VTable, +assigned: P147VLive, out: KDef) -> KDef:
  match schema:
    case P147VEmpty{}: out
    case P147VLeaf{hash,bucket}: p147test_live_bucket(bucket,assigned,out)
    case P147VNode{prefix,mask,left,right}: p147test_live_rows(right,assigned,p147test_live_rows(left,assigned,out))

@unsafe
def p147test_env(env: P147VEnv) -> KDef:
  match env:
    case P147VEnv{schema,assigned}: p147test_live_rows(schema,assigned,missing())

@unsafe
def p147test_flow(flow: P147VFlow) -> P111VFlow:
  match flow:
    case P147VFlow{env,terminal,error}: P111VFlow{p147test_env(env),terminal,error}

# Test-only full raw entry and the stable function experiment adapter.

@unsafe
def p147v_segment_flow(+body: List<&2,N111Stmt>, +scan: P147VScan, +seed: P147VTable, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match scan:
    case P147VScan{index,+error,count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        p147v_finish(p147v_body(body,index,P147VFlow{P147VEnv{index,p147n_seed(seed,P147VNone{})},False{},""},ids,arity,incoming,result)))

@unsafe
def p147v_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      +seed = p147v_put(P147VEmpty{},"state",0,2,3,2088)
      p147v_segment_flow(body,p147v_schema(body,P147VScan{seed,"",1}),seed,ids,arity,incoming,result)

@unsafe
def p147v_function(function: P113DFunction, ids: N111Ids, ready: KDef) -> String:
  p147d_function(function,ids,ready)
