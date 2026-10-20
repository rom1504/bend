# Optional bottom-up leaf inlining. The table indexes already processed,
# verified-order callees; semantic lowering remains unchanged.
type P113ITable is Data:
  P113IEmpty{}
  P113IBucket{+values: List<&2,P113DFunction>}
  P113INode{+zero: P113ITable, +one: P113ITable}

type P113IScan is Data:
  P113IScan{+body: List<&2,P113DStmt>, +next: U32, +budget: U32}

@unsafe
def p113i_bucket(name: String, values: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match values:
    case Nil{}: None{}
    case Con{+head,rest}: p113i_bucket_head(name,head,rest)

@unsafe
def p113i_bucket_head(+name: String, +head: P113DFunction, rest: List<&2,P113DFunction>) -> Maybe<&2,P113DFunction>:
  match head:
    case P113DFunction{key,params,result,public,body}:
      nt_choose(Maybe<&2,P113DFunction>,String.eq(name,key),u => Some{head},u => p113i_bucket(name,rest))

@unsafe
def p113i_get(table: P113ITable, +name: String, +hash: U32, +depth: U32) -> Maybe<&2,P113DFunction>:
  match table:
    case P113IEmpty{}: None{}
    case P113IBucket{values}: p113i_bucket(name,values)
    case P113INode{zero,one}:
      nt_choose(Maybe<&2,P113DFunction>,U32.is_eq(U32.and(hash,1),0),
        u => p113i_get(zero,name,U32.shr(hash),U32.inc(depth)),
        u => p113i_get(one,name,U32.shr(hash),U32.inc(depth)))

@unsafe
def p113i_put(+table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(depth,32),u => p113i_put_leaf(table,function),
    u => p113i_put_node(table,function,hash,depth))

@unsafe
def p113i_put_leaf(table: P113ITable, function: P113DFunction) -> P113ITable:
  match table:
    case P113IBucket{values}: P113IBucket{Con{function,values}}
    case _: P113IBucket{[function]}

@unsafe
def p113i_put_node(table: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  match table:
    case P113INode{+zero,+one}: p113i_put_branch(zero,one,function,hash,depth)
    case _: p113i_put_branch(P113IEmpty{},P113IEmpty{},function,hash,depth)

@unsafe
def p113i_put_branch(+zero: P113ITable, +one: P113ITable, +function: P113DFunction, +hash: U32, +depth: U32) -> P113ITable:
  nt_choose(P113ITable,U32.is_eq(U32.and(hash,1),0),
    u => P113INode{p113i_put(zero,function,U32.shr(hash),U32.inc(depth)),one},
    u => P113INode{zero,p113i_put(one,function,U32.shr(hash),U32.inc(depth))})
