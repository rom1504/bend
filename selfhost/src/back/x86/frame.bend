# Placement for already verified native statements. Offsets are positive rbp
# displacements; the first forty bytes belong to the five saved registers.
# The caller reserves outgoing space separately and aligns the complete frame.

law x181_frame_scalars:
  for body: List<&2,N111Stmt>
  for frame: X181Frame
  X181Frame

law x181_frame_stmts:
  for body: List<&2,P113DStmt>
  for frame: X181Frame
  X181Frame

def x181_frame_alignment(+alignment: U32) -> U32:
  nt_choose(U32,U32.is_eq(alignment,4),u => 4,
    u => nt_choose(U32,U32.is_eq(alignment,8),v => 8,v => 16))

def x181_frame_align(bytes: U32, +alignment: U32) -> U32:
  U32.mul(U32.div(U32.add(bytes,U32.sub(alignment,1)),alignment),alignment)

@unsafe
def x181_frame_home(+name: String, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,+bytes,calls,params,symbol}:
      nt_choose(X181Frame,String.eq(dk(p111v_get(slots,name)),"Absent"),
        u => X181Frame{p111v_put(slots,name,"X181Stack",x181_frame_align(U32.add(bytes,8),8),8),
          x181_frame_align(U32.add(bytes,8),8),calls,params,symbol},
        u => frame)

@unsafe
def x181_frame_names(names: List<&2,String>, frame: X181Frame) -> X181Frame:
  match names:
    case Nil{}: frame
    case Con{name,rest}: x181_frame_names(rest,x181_frame_home(name,frame))

# A buffer address is rbp-da and its accessible size is dx. Reuse only when
# both capacity and alignment suffice; implicit scratch can therefore share
# the same region with its explicit, verified alloca declaration.
@unsafe
def x181_frame_buffer(+name: String, +bytes: U32, alignment: U32,
  +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,used,calls,params,symbol}:
      +old = p111v_get(slots,name)
      +size = nt_choose(U32,U32.is_eq(bytes,0),u => 1,u => bytes)
      +align = x181_frame_alignment(alignment)
      +end = x181_frame_align(U32.add(used,size),align)
      nt_choose(X181Frame,String.eq(dk(old),"X181Buffer") &&
        U32.is_ge(dx(old),size) && U32.is_eq(U32.mod(da(old),align),0),
        u => frame,
        u => X181Frame{p111v_put(slots,name,"X181Buffer",end,size),end,calls,params,symbol})

# Staging every argument and reserving another word per argument covers both
# register arguments and the stack-argument copy. It is deliberately generous.
@unsafe
def x181_frame_outgoing(count: U32, +frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,+calls,params,symbol}:
      +needed = U32.mul(count,16)
      nt_choose(X181Frame,U32.is_gt(needed,calls),
        u => X181Frame{slots,bytes,needed,params,symbol},u => frame)

@unsafe
def x181_frame_scalar(stmt: N111Stmt, frame: X181Frame) -> X181Frame:
  match stmt:
    case N111Set{name,typ,value}: x181_frame_home(name,frame)
    case N111Bin{name,typ,op,left,right}: x181_frame_home(name,frame)
    case N111Call{name,typ,symbol,args}:
      x181_frame_outgoing(nt_count(N111Arg,args),x181_frame_home(name,frame))
    case N111If{condition,yes,no}:
      x181_frame_scalars(no,x181_frame_scalars(yes,frame))
    case N111Return{value}: frame
    case N111Load{name,typ,base,offset}: x181_frame_home(name,frame)
    case N111Store{typ,base,offset,value}: frame
    case N111Offset{name,base,bytes}: x181_frame_home(name,frame)
    case N111Alloca{name,bytes,align}: x181_frame_buffer(name,bytes,align,frame)

@unsafe
def x181_frame_scalars(body,frame):
  match body:
    case Nil{}: frame
    case Con{head,rest}: x181_frame_scalars(rest,x181_frame_scalar(head,frame))

@unsafe
def x181_frame_stmt(stmt: P113DStmt, frame: X181Frame) -> X181Frame:
  match stmt:
    case P113DScalar{scalar}: x181_frame_scalar(scalar,frame)
    case P113DIf{condition,yes,no}:
      x181_frame_stmts(no,x181_frame_stmts(yes,frame))
    case P113DCall{+destinations,target,args}:
      x181_frame_outgoing(U32.add(U32.inc(nt_count(N111Value,args)),
        nt_choose(U32,U32.is_eq(nt_count(String,destinations),1),u => 0,u => 1)),
        x181_frame_names(destinations,frame))
    case P113DResult{values}: frame
    case P113DAgain{values}: frame

@unsafe
def x181_frame_stmts(body,frame):
  match body:
    case Nil{}: frame
    case Con{head,rest}: x181_frame_stmts(rest,x181_frame_stmt(head,frame))

@unsafe
def x181_frame(symbol,params,body):
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state","X181Register",0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))
