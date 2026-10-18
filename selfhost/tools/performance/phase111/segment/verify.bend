# Structural/type boundary for the sequential runtime ABI. Persistent exact-name
# tries avoid scanning all functions/constructors for every reference. This is
# not an ownership proof or a proof that foreign/runtime implementations are safe.
type P111VScan is Data:
  P111VScan{+index: KDef, +error: String, +count: U32}

type P111VFlow is Data:
  P111VFlow{+live: KDef, +terminal: Bool, +error: String}

@unsafe
def p111v_get(+tree: KDef, +name: String) -> KDef:
  index_find(tree,name,index_hash(name,2166136261),32)

@unsafe
def p111v_put(+tree: KDef, +name: String, +kind: String, +width: U32, +capacity: U32) -> KDef:
  index_set(tree,KDef{name,kind,width,capacity,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

def p111v_type(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 1
    case N111U64{}: 2
    case N111Ptr{}: 3

@unsafe
def p111v_name_chars(+name: String, +n: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(n,0)
    case SCon{h,t}:
      +c = Char.to_u32(h)
      U32.is_lt(n,128) && ((U32.is_ge(c,65) && U32.is_le(c,90)) ||
        (U32.is_ge(c,97) && U32.is_le(c,122)) || U32.is_eq(c,95) ||
        (U32.is_gt(n,0) && U32.is_ge(c,48) && U32.is_le(c,57))) && p111v_name_chars(t,U32.inc(n))

@unsafe
def p111v_raw_name_chars(+name: String, +count: U32) -> Bool:
  match name:
    case SNil{}: U32.is_gt(count,0)
    case SCon{head,rest}: U32.is_lt(count,4096) && Bool.not(U32.is_eq(Char.to_u32(head),0)) && p111v_raw_name_chars(rest,U32.inc(count))

@unsafe
def p111v_raw_name(+name: String) -> Bool:
  p111v_raw_name_chars(name,0)

@unsafe
def p111v_comparison(+op: String) -> Bool:
  String.eq(op,"eq") || String.eq(op,"ne") || String.eq(op,"ult") || String.eq(op,"ule") ||
  String.eq(op,"ugt") || String.eq(op,"uge") || String.eq(op,"slt") || String.eq(op,"sle") ||
  String.eq(op,"sgt") || String.eq(op,"sge")

@unsafe
def p111v_operator(+op: String) -> Bool:
  p111v_comparison(op) || String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"mul") ||
  String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"shl") ||
  String.eq(op,"shr") || String.eq(op,"sar")

@unsafe
def p111v_decl(+name: String, +width: U32, +capacity: U32, +alloca: Bool, +scan: P111VScan) -> P111VScan:
  match scan:
    case P111VScan{+index,+error,+count}:
      +old = p111v_get(index,name)
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,Bool.not(p111v_name_chars(name,0)) || String.eq(name,"state"),u => P111VScan{index,"invalid/reserved local name: " ++ name,count},u =>
      nt_choose(P111VScan,Bool.not(String.eq(dk(old),"Absent")) && (alloca || String.eq(dk(old),"alloca") || Bool.not(U32.is_eq(da(old),width))),
        u => P111VScan{index,"local width/allocation changes: " ++ name,count},
        u => P111VScan{p111v_put(index,name,nt_choose(String,alloca,v => "alloca",v => "local"),width,capacity),"",
          nt_choose(U32,String.eq(dk(old),"Absent"),v => U32.inc(count),v => count)})))

@unsafe
def p111v_schema_stmt(+stmt: N111Stmt, +scan: P111VScan) -> P111VScan:
  match stmt:
    case N111Set{name,typ,value}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Bin{name,typ,op,left,right}: p111v_decl(name,nt_choose(U32,p111v_comparison(op),u => 1,u => p111v_type(typ)),0,False{},scan)
    case N111Call{name,typ,symbol,args}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Load{name,typ,base,offset}: p111v_decl(name,p111v_type(typ),0,False{},scan)
    case N111Offset{name,base,bytes}: p111v_decl(name,3,0,False{},scan)
    case N111Alloca{name,bytes,align}: p111v_decl(name,3,bytes,True{},scan)
    case N111If{condition,yes,no}: p111v_schema(no,p111v_schema(yes,scan))
    case _: scan

@unsafe
def p111v_schema(+body: List<&2,N111Stmt>, +scan: P111VScan) -> P111VScan:
  match body scan:
    case Nil{} _: scan
    case Con{head,rest} P111VScan{index,+error,+count}:
      nt_choose(P111VScan,String.is_empty(error) && U32.is_le(count,65535),u => p111v_schema(rest,p111v_schema_stmt(head,scan)),
        u => P111VScan{index,nt_choose(String,String.is_empty(error),v => "too many segment locals",v => error),count})

@unsafe
def p111v_value(+value: N111Value, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  match value ids:
    case N111Local{name} _:
      +found = p111v_get(live,name)
      Bool.not(String.eq(dk(found),"Absent")) && U32.is_eq(da(found),width)
    case N111Const{lo,hi} _:
      nt_choose(Bool,U32.is_eq(width,1),u => U32.is_eq(hi,0),u =>
        nt_choose(Bool,U32.is_eq(width,3),v => U32.is_eq(lo,0) && U32.is_eq(hi,0),v => U32.is_eq(width,2)))
    case N111FuncId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(functions,name)),"Absent"))
    case N111CtorId{name} N111Ids{functions,constructors}:
      U32.is_le(width,2) && Bool.not(String.eq(dk(p111v_get(constructors,name)),"Absent"))
    case N111Symbol{name} _: False{}

@unsafe
def p111v_assign(+name: String, +schema: KDef, +live: KDef) -> KDef:
  +found = p111v_get(schema,name)
  p111v_put(live,name,dk(found),da(found),dx(found))

@unsafe
def p111v_step(+ok: Bool, +name: String, +schema: KDef, +live: KDef, +message: String) -> P111VFlow:
  nt_choose(P111VFlow,ok,u => P111VFlow{nt_choose(KDef,String.is_empty(name),v => live,v => p111v_assign(name,schema,live)),False{},""},
    u => P111VFlow{live,False{},message})

@unsafe
def p111v_capacity(+value: N111Value, +live: KDef) -> U32:
  match value:
    case N111Local{name}: dx(p111v_get(live,name))
    case _: 0

@unsafe
def p111v_memory(+base: N111Value, +offset: U32, +width: U32, +live: KDef, +ids: N111Ids) -> Bool:
  +bytes = nt_choose(U32,U32.is_eq(width,1),u => 4,u => 8)
  +capacity = p111v_capacity(base,live)
  p111v_value(base,3,live,ids) && U32.is_ge(capacity,bytes) &&
    U32.is_le(offset,U32.sub(capacity,bytes)) && U32.is_eq(U32.mod(offset,bytes),0)

@unsafe
def p111v_intersection_bucket(+bucket: List<&2,KDef>, +other: KDef, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      +found = p111v_get(other,dn(head))
      p111v_intersection_bucket(rest,other,nt_choose(KDef,String.eq(dk(found),"Absent"),u => out,
        u => p111v_put(out,dn(head),dk(head),da(head),nt_choose(U32,U32.is_eq(dx(head),dx(found)),v => dx(head),v => 0))))

@unsafe
def p111v_intersection(+left: KDef, +right: KDef, +out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p111v_intersection_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p111v_intersection(b,right,p111v_intersection(a,right,out))
    case _: out

@unsafe
def p111v_join(+yes: P111VFlow, +no: P111VFlow) -> P111VFlow:
  match yes no:
    case P111VFlow{+yl,yt,+ye} P111VFlow{nl,+nt,+ne}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(ye)),u => yes,u =>
      nt_choose(P111VFlow,Bool.not(String.is_empty(ne)),u => no,u =>
      nt_choose(P111VFlow,yt,u => nt_choose(P111VFlow,nt,v => P111VFlow{yl,True{},""},v => no),u =>
      nt_choose(P111VFlow,nt,u => yes,u => P111VFlow{p111v_intersection(yl,nl,missing()),False{},""}))))

# Exact signatures from runtime/runtime.h and runtime/primitives.h. All results
# in this segment API are U64; process entry p111_rt_main is not callable here.
@unsafe
def p111v_signature(+symbol: String) -> List<&2,U32>:
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_keep"),u => [3,2],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_sink"),u => [3,2],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_ctor"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_take"),u => [3,2,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_closure"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_tag"),u => [3,2],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_frame"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_jump"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_return"),u => [3,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_apply"),u => [3,2,2],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_stack_pop"),u => [3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_stack_get"),u => [3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_reg_get"),u => [3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_fail"),u => [3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_op"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_special_ctor"),u => [3,1,3,1],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_special_test"),u => [3,1,2],u =>
  nt_choose(List<&2,U32>,String.eq(symbol,"p111_rt_special_take"),u => [3,1,2,3,1],u => []))))))))))))))))))

def p111v_primitive_arities() -> List<&2,U32>:
  [0,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,2,2,2,2,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,1,1,1,2,2,2,1,2,2,2,2,2,2,2,3,3,1,1,3,3,3,3,3,3,3,4,3]

@unsafe
def p111v_at(+values: List<&2,U32>, +index: U32) -> U32:
  match values:
    case Nil{}: 4294967295
    case Con{head,rest}: nt_choose(U32,U32.is_eq(index,0),u => head,u => p111v_at(rest,U32.sub(index,1)))

@unsafe
def p111v_arg(+args: List<&2,N111Arg>, +index: U32) -> N111Value:
  match args:
    case Nil{}: N111Symbol{"invalid"}
    case Con{N111Arg{typ,value},rest}: nt_choose(N111Value,U32.is_eq(index,0),u => value,u => p111v_arg(rest,U32.sub(index,1)))

def p111v_literal(value: N111Value) -> U32:
  match value:
    case N111Const{lo,hi}: nt_choose(U32,U32.is_eq(hi,0),u => lo,u => 4294967295)
    case _: 4294967295

@unsafe
def p111v_args(+args: List<&2,N111Arg>, +sig: List<&2,U32>, +live: KDef, +ids: N111Ids) -> Bool:
  match args sig:
    case Nil{} Nil{}: True{}
    case Con{N111Arg{typ,value},rest} Con{width,more}:
      U32.is_eq(p111v_type(typ),width) && p111v_value(value,width,live,ids) && p111v_args(rest,more,live,ids)
    case _ _: False{}

@unsafe
def p111v_target(+value: N111Value, +ids: N111Ids, +constructor: Bool) -> KDef:
  match value ids:
    case N111CtorId{name} N111Ids{functions,constructors}:
      nt_choose(KDef,constructor,u => p111v_get(constructors,name),u => missing())
    case N111FuncId{name} N111Ids{functions,constructors}:
      nt_choose(KDef,constructor,u => missing(),u => p111v_get(functions,name))
    case _ _: missing()

@unsafe
def p111v_buffer(+args: List<&2,N111Arg>, +position: U32, +count: U32, +live: KDef) -> Bool:
  U32.is_le(count,255) && U32.is_ge(p111v_capacity(p111v_arg(args,position),live),U32.mul(count,8))

@unsafe
def p111v_counted_call(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids) -> Bool:
  +count = p111v_literal(p111v_arg(args,3))
  +target = p111v_target(p111v_arg(args,1),ids,String.eq(symbol,"p111_rt_ctor"))
  p111v_buffer(args,2,count,live) &&
    nt_choose(Bool,String.eq(symbol,"p111_rt_ctor"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_jump"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(count,da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_closure"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_eq(dx(target),0) && U32.is_eq(U32.inc(count),da(target)),u =>
    nt_choose(Bool,String.eq(symbol,"p111_rt_frame"),u => Bool.not(String.eq(dk(target),"Absent")) && U32.is_gt(dx(target),0) && U32.is_eq(U32.add(count,dx(target)),da(target)),u => True{}))))

@unsafe
def p111v_special_arity(+kind: U32) -> U32:
  nt_choose(U32,U32.is_gt(kind,0) && U32.is_lt(kind,10),u => p111v_at([0,0,0,0,1,1,1,1,1,2],kind),u => 4294967295)

@unsafe
def p111v_contract(+symbol: String, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +id = p111v_literal(p111v_arg(args,1))
  +count = p111v_literal(p111v_arg(args,3))
  nt_choose(Bool,String.eq(symbol,"p111_rt_ctor") || String.eq(symbol,"p111_rt_take") || String.eq(symbol,"p111_rt_closure") || String.eq(symbol,"p111_rt_frame") || String.eq(symbol,"p111_rt_jump"),
    u => p111v_counted_call(symbol,args,live,ids),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_return"),u => U32.is_eq(p111v_literal(p111v_arg(args,2)),result) && p111v_buffer(args,1,result,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_reg_get"),u => U32.is_lt(id,nt_choose(U32,U32.is_gt(incoming,0),v => incoming,v => arity)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_get"),u => U32.is_gt(incoming,0) && U32.is_lt(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_stack_pop"),u => U32.is_gt(incoming,0) && U32.is_eq(id,U32.sub(arity,incoming)),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_op"),u => U32.is_gt(id,0) && U32.is_lt(id,86) && U32.is_eq(count,p111v_at(p111v_primitive_arities(),id)) && p111v_buffer(args,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_ctor"),u => U32.is_eq(count,p111v_special_arity(id)) && p111v_buffer(args,2,count,live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_take"),u => U32.is_eq(p111v_literal(p111v_arg(args,4)),p111v_special_arity(id)) && p111v_buffer(args,3,p111v_literal(p111v_arg(args,4)),live),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_special_test"),u => U32.is_gt(id,0) && U32.is_lt(id,10),u =>
  nt_choose(Bool,String.eq(symbol,"p111_rt_fail"),u => U32.is_gt(id,0) && U32.is_le(id,8),u => True{}))))))))))

def p111v_state_argument(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{name}},rest}: String.eq(name,"state")
    case _: False{}

@unsafe
def p111v_call(+symbol: String, +typ: N111Type, +args: List<&2,N111Arg>, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> Bool:
  +sig = p111v_signature(symbol)
  Bool.not(U32.is_eq(nt_count(U32,sig),0)) && U32.is_eq(p111v_type(typ),2) &&
    p111v_state_argument(args) && p111v_args(args,sig,live,ids) && p111v_contract(symbol,args,live,ids,arity,incoming,result)

@unsafe
def p111v_offset(+name: String, +base: N111Value, +bytes: N111Value, +live: KDef, +ids: N111Ids) -> P111VFlow:
  +offset = p111v_literal(bytes)
  +capacity = p111v_capacity(base,live)
  nt_choose(P111VFlow,p111v_value(base,3,live,ids) && p111v_value(bytes,2,live,ids) && U32.is_le(offset,capacity),
    u => P111VFlow{p111v_put(live,name,"local",3,U32.sub(capacity,offset)),False{},""},
    u => P111VFlow{live,False{},"unbounded or ill-typed pointer offset"})

@unsafe
def p111v_stmt(+stmt: N111Stmt, +schema: KDef, +live: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match stmt:
    case N111Set{name,typ,value}: p111v_step(p111v_value(value,p111v_type(typ),live,ids),name,schema,live,"ill-typed or undefined assignment")
    case N111Bin{name,typ,op,left,right}:
      +width = p111v_type(typ)
      p111v_step(U32.is_le(width,2) && p111v_operator(op) && p111v_value(left,width,live,ids) && p111v_value(right,width,live,ids),name,schema,live,"invalid binary operation or operand")
    case N111Call{name,typ,symbol,args}:
      p111v_step(p111v_call(symbol,typ,args,live,ids,arity,incoming,result),name,schema,live,"runtime import signature/count/capacity mismatch: " ++ symbol)
    case N111If{condition,yes,no}:
      nt_choose(P111VFlow,p111v_value(condition,1,live,ids),
        u => p111v_join(p111v_body(yes,schema,P111VFlow{live,False{},""},ids,arity,incoming,result),p111v_body(no,schema,P111VFlow{live,False{},""},ids,arity,incoming,result)),
        u => P111VFlow{live,False{},"condition must be a definitely assigned U32"})
    case N111Return{value}:
      nt_choose(P111VFlow,p111v_value(value,2,live,ids),u => P111VFlow{live,True{},""},u => P111VFlow{live,False{},"segment return must be U64"})
    case N111Load{name,typ,base,offset}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids),name,schema,live,"unbounded, unaligned or ill-typed load")
    case N111Store{typ,base,offset,value}:
      p111v_step(p111v_memory(base,offset,p111v_type(typ),live,ids) && p111v_value(value,p111v_type(typ),live,ids),"",schema,live,"unbounded, unaligned or ill-typed store")
    case N111Offset{name,base,bytes}: p111v_offset(name,base,bytes,live,ids)
    case N111Alloca{name,bytes,align}:
      p111v_step(U32.is_gt(bytes,0) && U32.is_le(bytes,2048) && (U32.is_eq(align,4) || U32.is_eq(align,8) || U32.is_eq(align,16)),name,schema,live,"unsupported stack allocation size/alignment")

@unsafe
def p111v_body(+body: List<&2,N111Stmt>, +schema: KDef, +flow: P111VFlow, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> P111VFlow:
  match body flow:
    case Nil{} _: flow
    case Con{head,rest} P111VFlow{live,terminal,+error}:
      nt_choose(P111VFlow,Bool.not(String.is_empty(error)),u => flow,u =>
      nt_choose(P111VFlow,terminal,u => P111VFlow{live,True{},"statement follows terminal path"},u =>
        p111v_body(rest,schema,p111v_stmt(head,schema,live,ids,arity,incoming,result),ids,arity,incoming,result)))

@unsafe
def p111v_functions(+segments: List<&2,N111Segment>, +scan: P111VScan) -> P111VScan:
  match segments scan:
    case Nil{} _: scan
    case Con{N111Segment{+name,+arity,result,+incoming,flags,body},rest} P111VScan{+index,+error,+count}:
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,U32.is_ge(count,65532),u => P111VScan{index,"segment count exceeds 16-bit FID capacity with four runtime IDs",count},u =>
      nt_choose(P111VScan,Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(p111v_get(index,name)),"Absent")),
        u => P111VScan{index,"invalid/duplicate segment name: " ++ name,count},u =>
      nt_choose(P111VScan,U32.is_gt(arity,255) || U32.is_gt(result,255) || U32.is_gt(incoming,arity) || U32.is_gt(flags,255),
        u => P111VScan{index,"segment metadata exceeds ABI capacity: " ++ name,count},u =>
        p111v_functions(rest,P111VScan{p111v_put(index,name,"function",arity,incoming),"",U32.inc(count)})))))

@unsafe
def p111v_constructors(+constructors: List<&2,N_Constructor>, +scan: P111VScan) -> P111VScan:
  match constructors scan:
    case Nil{} _: scan
    case Con{N_Constructor{+name,+arity,hot},rest} P111VScan{+index,+error,+count}:
      nt_choose(P111VScan,Bool.not(String.is_empty(error)),u => scan,u =>
      nt_choose(P111VScan,U32.is_ge(count,65535),u => P111VScan{index,"constructor count exceeds 16-bit CID capacity",count},u =>
      nt_choose(P111VScan,Bool.not(p111v_raw_name(name)) || Bool.not(String.eq(dk(p111v_get(index,name)),"Absent")),
        u => P111VScan{index,"invalid/duplicate constructor name: " ++ name,count},u =>
      nt_choose(P111VScan,U32.is_gt(arity,255),u => P111VScan{index,"constructor arity exceeds ABI capacity: " ++ name,count},u =>
        p111v_constructors(rest,P111VScan{p111v_put(index,name,"constructor",arity,0),"",U32.inc(count)})))))

@unsafe
def p111v_segment_flow(+body: List<&2,N111Stmt>, +schema: P111VScan, +seed: KDef, +ids: N111Ids, +arity: U32, +incoming: U32, +result: U32) -> String:
  match schema:
    case P111VScan{index,+error,+count}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        p111v_finish(p111v_body(body,index,P111VFlow{seed,False{},""},ids,arity,incoming,result)))

@unsafe
def p111v_finish(flow: P111VFlow) -> String:
  match flow:
    case P111VFlow{live,terminal,+error}:
      nt_choose(String,Bool.not(String.is_empty(error)),u => error,u =>
        nt_choose(String,terminal,v => "",v => "segment has a nonterminal path"))

@unsafe
def p111v_segment(+segment: N111Segment, +ids: N111Ids) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      +seed = p111v_put(missing(),"state","parameter",3,2088)
      p111v_segment_flow(body,p111v_schema(body,P111VScan{seed,"",1}),seed,ids,arity,incoming,result)

@unsafe
def p111v_segments(+segments: List<&2,N111Segment>, +ids: N111Ids) -> String:
  match segments:
    case Nil{}: ""
    case Con{+segment,rest}:
      +error = p111v_segment(segment,ids)
      nt_choose(String,String.is_empty(error),u => p111v_segments(rest,ids),u => p111v_segment_error(segment,error))

def p111v_segment_error(segment: N111Segment, error: String) -> String:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: name ++ ": " ++ error

@unsafe
def p111v_program_indexed(+program: P111Program, +functions: P111VScan, +constructors: P111VScan) -> String:
  match program functions constructors:
    case P111Program{segments,ctors,show,show_names,effects,pure} P111VScan{+fs,+fe,fc} P111VScan{cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(String,Bool.not(String.is_empty(fe)),u => fe,u =>
      nt_choose(String,Bool.not(String.is_empty(ce)),u => ce,u =>
      nt_choose(String,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => "program requires a direct, zero-argument main segment",u =>
        p111v_segments(segments,N111Ids{fs,cs}))))

# Validate before emission. Show/effect descriptors retain the mature backend's
# formats and are checked by the runtime adapter; this gate checks segment IR.
@unsafe
def p111_verify_program(+program: P111Program) -> String:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      p111v_program_indexed(program,p111v_functions(segments,P111VScan{missing(),"",0}),p111v_constructors(constructors,P111VScan{missing(),"",0}))
