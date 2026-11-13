# Globally unobserved cells of private fixed frame buffers. Any use of a buffer
# address outside direct bounded loads/stores (or the exact inline-F32 summary)
# excludes that whole buffer. Read footprints include setup and every branch,
# so no control-flow or loop-carried memory assumption is needed.
type X186Memory is Data:
  X186Memory{+buffers: KDef, +reads: KDef, +used: KDef}

def x186_private_enabled() -> Bool: True{}

# The decimal offset prefix ends at the first colon; arbitrary buffer text
# cannot collide with a different offset/name pair.
def x186_m_key(buffer: String, offset: U32) -> String:
  U32.show(offset) ++ ":" ++ buffer

@unsafe
def x186_m_escape(name: String, scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{buffers,reads,used}: X186Memory{x185_sf_block(name,buffers),reads,used}

@unsafe
def x186_m_value(value: N111Value, scan: X186Memory) -> X186Memory:
  match value:
    case N111Local{name}: x186_m_escape(name,scan)
    case _: scan

@unsafe
def x186_m_values(values: List<&2,N111Value>, scan: X186Memory) -> X186Memory:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x186_m_values(rest,x186_m_value(head,scan))

@unsafe
def x186_m_args(args: List<&2,N111Arg>, scan: X186Memory) -> X186Memory:
  match args:
    case Nil{}: scan
    case Con{N111Arg{typ,value},rest}: x186_m_args(rest,x186_m_value(value,scan))

@unsafe
def x186_m_cell(+name: String, +offset: U32, +typ: N111Type, +buffers: KDef) -> Bool:
  x185_sf_cell(name,offset,typ,buffers) && U32.is_eq(U32.mod(offset,4),0)

@unsafe
def x186_m_read(+name: String, +offset: U32, +typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{+buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),
        u => x186_m_read_second(name,offset,typ,buffers,
          p111v_put(reads,x186_m_key(name,offset),"X186Read",1,0),p111v_put(used,name,"X186Used",1,0)),
        u => x186_m_escape(name,scan))

@unsafe
def x186_m_read_second(+name: String, +offset: U32, typ: N111Type, buffers: KDef, +reads: KDef, used: KDef) -> X186Memory:
  X186Memory{buffers,nt_choose(KDef,U32.is_eq(x185_sf_width(typ),8),
    u => p111v_put(reads,x186_m_key(name,U32.add(offset,4)),"X186Read",1,0),u => reads),used}

@unsafe
def x186_m_store(+name: String, offset: U32, typ: N111Type, +scan: X186Memory) -> X186Memory:
  match scan:
    case X186Memory{buffers,reads,used}:
      nt_choose(X186Memory,x186_m_cell(name,offset,typ,buffers),u => scan,u => x186_m_escape(name,scan))

@unsafe
def x186_m_unknown_call(stmt: N111Stmt, scan: X186Memory) -> X186Memory:
  match stmt:
    case N111Call{name,typ,symbol,args}: x186_m_args(args,scan)
    case _: scan

@unsafe
def x186_m_call(stmt: N111Stmt, +scan: X186Memory, effect: X186InlineOp) -> X186Memory:
  match effect:
    case X186InlineF32{destination,+id,+buffer}:
      nt_choose(X186Memory,x192_float_unary(id),
        u => x186_m_read(buffer,0,N111U64{},scan),
        u => x186_m_read(buffer,8,N111U64{},x186_m_read(buffer,0,N111U64{},scan)))
    case _: x186_m_unknown_call(stmt,scan)

law x186_m_scan:
  for body: List<&2,P113DStmt>
  for scan: X186Memory
  X186Memory

@unsafe
def x186_m_scalar(+stmt: N111Stmt, scan: X186Memory) -> X186Memory:
  match stmt:
    case N111Load{name,typ,N111Local{buffer},offset}: x186_m_read(buffer,offset,typ,scan)
    case N111Load{name,typ,base,offset}: x186_m_value(base,scan)
    case N111Store{typ,N111Local{buffer},offset,value}: x186_m_store(buffer,offset,typ,x186_m_value(value,scan))
    case N111Store{typ,base,offset,value}: x186_m_value(value,x186_m_value(base,scan))
    case N111Set{name,typ,value}: x186_m_value(value,scan)
    case N111Bin{name,typ,op,left,right}: x186_m_value(right,x186_m_value(left,scan))
    case N111Offset{name,base,bytes}: x186_m_value(bytes,x186_m_value(base,scan))
    case N111Call{name,typ,symbol,args}: x186_m_call(stmt,scan,x186_inline_op(stmt))
    case N111If{condition,yes,no}:
      x186_m_scan(x181_scalar_rows(no),x186_m_scan(x181_scalar_rows(yes),x186_m_value(condition,scan)))
    case N111Return{value}: x186_m_value(value,scan)
    case N111Alloca{name,bytes,align}: scan

@unsafe
def x186_m_scan(body,scan):
  match body:
    case Nil{}: scan
    case Con{P113DScalar{stmt},rest}: x186_m_scan(rest,x186_m_scalar(stmt,scan))
    case Con{P113DIf{condition,yes,no},rest}:
      x186_m_scan(rest,x186_m_scan(no,x186_m_scan(yes,x186_m_value(condition,scan))))
    case Con{P113DCall{names,target,args},rest}: x186_m_scan(rest,x186_m_values(args,scan))
    case Con{P113DResult{values},rest}: x186_m_scan(rest,x186_m_values(values,scan))
    case Con{P113DAgain{values},rest}: x186_m_scan(rest,x186_m_values(values,scan))

@unsafe
def x186_m_dead_cell(+name: String, +offset: U32, +typ: N111Type, scan: X186Memory) -> Bool:
  match scan:
    case X186Memory{buffers,+reads,used}:
      x186_m_cell(name,offset,typ,buffers) && U32.is_eq(da(p111v_get(reads,x186_m_key(name,offset))),0) &&
        (U32.is_eq(x185_sf_width(typ),4) || U32.is_eq(da(p111v_get(reads,x186_m_key(name,U32.add(offset,4)))),0))

@unsafe
def x186_m_dead_buffer(+name: String, scan: X186Memory) -> Bool:
  match scan:
    case X186Memory{buffers,reads,used}:
      String.eq(dk(p111v_get(buffers,name)),"X185ScratchBuffer") && U32.is_eq(da(p111v_get(used,name)),0)

law x186_m_body:
  for body: List<&2,P113DStmt>
  for +scan: X186Memory
  List<&2,P113DStmt>

@unsafe
def x186_m_body(body,scan):
  match body:
    case Nil{}: []
    case Con{P113DScalar{N111Store{+typ,N111Local{+buffer},+offset,+value}},+rest}:
      nt_choose(List<&2,P113DStmt>,x186_m_dead_cell(buffer,offset,typ,scan),
        u => x186_m_body(rest,scan),
        u => Con{P113DScalar{N111Store{typ,N111Local{buffer},offset,value}},x186_m_body(rest,scan)})
    case Con{P113DScalar{N111Alloca{+name,+bytes,+align}},+rest}:
      nt_choose(List<&2,P113DStmt>,x186_m_dead_buffer(name,scan),u => x186_m_body(rest,scan),
        u => Con{P113DScalar{N111Alloca{name,bytes,align}},x186_m_body(rest,scan)})
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      Con{P113DIf{condition,x186_m_body(x181_scalar_rows(yes),scan),x186_m_body(x181_scalar_rows(no),scan)},x186_m_body(rest,scan)}
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,x186_m_body(yes,scan),x186_m_body(no,scan)},x186_m_body(rest,scan)}
    case Con{head,rest}: Con{head,x186_m_body(rest,scan)}

@unsafe
def x186_private_body(params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x186_private_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_m_body(body,x186_m_scan(body,x186_m_scan(setup,X186Memory{
      x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
        p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),missing(),missing()}))),u => body)
