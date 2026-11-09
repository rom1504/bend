# Transient machine homes, after the existing callee-saved placement. Every
# admitted name is confined to one call-free region and starts with a write.
# All reads AND writes extend its interval; no value is spilled or moved when
# a home is reused. Parameters/setup definitions retain their original homes.
type X185TScan is Data:
  X185TScan{+ranges: KDef, +reversedNames: List<&2,String>, +position: U32, +region: U32}

law x185_t_body:
  for body: List<&2,P113DStmt>
  for scan: X185TScan
  X185TScan

def x185_transient_enabled() -> Bool: True{}

def x185_transient_reg(index):
  match index:
    case 0: x188_reg(7,64)
    case 1: x188_reg(6,64)
    case 2: x188_reg(2,64)
    case 3: x188_reg(8,64)
    case _: x188_reg(9,64)

@unsafe
def x185_t_range(+name: String, first: U32, last: U32, region: U32, ranges: KDef) -> KDef:
  index_set(ranges,KDef{name,"X185TRange",first,last,kt("X185TRegion","",region,0,[]),
    atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def x185_t_forbid(name: String, scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{p111v_put(ranges,name,"X185TBlocked",0,0),names,position,region}

@unsafe
def x185_t_event(+name: String, +write: Bool, +scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{+ranges,+names,+position,+region}:
      +old = p111v_get(ranges,name)
      nt_choose(X185TScan,x181_register_reserved(name),u => scan,u =>
        nt_choose(X185TScan,String.eq(dk(old),"Absent"),
          v => nt_choose(X185TScan,write,
            w => X185TScan{x185_t_range(name,position,position,region,ranges),Con{name,names},position,region},
            w => x185_t_forbid(name,scan)),
          v => nt_choose(X185TScan,String.eq(dk(old),"X185TRange"),
            w => nt_choose(X185TScan,U32.is_eq(ix(dt(old)),region),
              z => X185TScan{x185_t_range(name,da(old),position,region,ranges),names,position,region},
              z => x185_t_forbid(name,scan)),w => scan)))

@unsafe
def x185_t_read(value: N111Value, scan: X185TScan) -> X185TScan:
  match value:
    case N111Local{name}: x185_t_event(name,False{},scan)
    case _: scan

@unsafe
def x185_t_reads(values: List<&2,N111Value>, scan: X185TScan) -> X185TScan:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x185_t_reads(rest,x185_t_read(head,scan))

@unsafe
def x185_t_forbid_value(value: N111Value, scan: X185TScan) -> X185TScan:
  match value:
    case N111Local{name}: x185_t_forbid(name,scan)
    case _: scan

@unsafe
def x185_t_forbid_values(values: List<&2,N111Value>, scan: X185TScan) -> X185TScan:
  match values:
    case Nil{}: scan
    case Con{head,rest}: x185_t_forbid_values(rest,x185_t_forbid_value(head,scan))

@unsafe
def x185_t_forbid_args(args: List<&2,N111Arg>, scan: X185TScan) -> X185TScan:
  match args:
    case Nil{}: scan
    case Con{N111Arg{typ,value},rest}: x185_t_forbid_args(rest,x185_t_forbid_value(value,scan))

@unsafe
def x185_t_forbid_names(names: List<&2,String>, scan: X185TScan) -> X185TScan:
  match names:
    case Nil{}: scan
    case Con{name,rest}: x185_t_forbid_names(rest,x185_t_forbid(name,scan))

# Statement endpoints are inclusive. All operand reads precede the write at
# the same position, so even an ending source cannot share this destination.
def x185_t_next(scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{ranges,names,U32.inc(position),region}

def x185_t_cut(scan: X185TScan) -> X185TScan:
  match scan:
    case X185TScan{ranges,names,position,region}:
      X185TScan{ranges,names,U32.inc(position),U32.inc(region)}

# A condition belongs to the preceding region. Each arm and the continuation
# then receives a distinct region; any name crossing one of these is blocked.
@unsafe
def x185_t_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, scan: X185TScan) -> X185TScan:
  x185_t_cut(x185_t_body(no,x185_t_cut(x185_t_body(yes,x185_t_cut(x185_t_read(condition,scan))))))

# The shared F32 expansion only clobbers reserved selector temporaries. Its
# buffer is read before the destination write at this same inclusive endpoint;
# ordinary calls still exclude all arguments/results and cut the region.
@unsafe
def x186_t_inline_call(name: String, args: List<&2,N111Arg>, scan: X185TScan, operation: X186InlineOp) -> X185TScan:
  match operation:
    case X186InlineNone{}: x185_t_cut(x185_t_forbid(name,x185_t_forbid_args(args,scan)))
    case X186InlineF32{destination,id,buffer}:
      x185_t_next(x185_t_event(destination,True{},x185_t_read(N111Local{buffer},scan)))

@unsafe
def x185_t_scalar(stmt: N111Stmt, scan: X185TScan) -> X185TScan:
  match stmt:
    case N111Set{name,typ,value}: x185_t_next(x185_t_event(name,True{},x185_t_read(value,scan)))
    case N111Bin{name,typ,op,left,right}:
      x185_t_next(x185_t_event(name,True{},x185_t_read(right,x185_t_read(left,scan))))
    case N111Load{name,typ,base,offset}: x185_t_next(x185_t_event(name,True{},x185_t_read(base,scan)))
    case N111Store{typ,base,offset,value}: x185_t_next(x185_t_read(value,x185_t_read(base,scan)))
    case N111Offset{name,base,bytes}:
      x185_t_next(x185_t_event(name,True{},x185_t_read(bytes,x185_t_read(base,scan))))
    case N111Alloca{name,bytes,align}: x185_t_next(x185_t_forbid(name,scan))
    case N111Call{+name,typ,symbol,+args}:
      x186_t_inline_call(name,args,scan,x186_inline_op(N111Call{name,typ,symbol,args}))
    case N111If{condition,yes,no}: x185_t_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),scan)
    case N111Return{value}: x185_t_cut(x185_t_read(value,scan))

@unsafe
def x185_t_stmt(stmt: P113DStmt, scan: X185TScan) -> X185TScan:
  match stmt:
    case P113DScalar{scalar}: x185_t_scalar(scalar,scan)
    case P113DIf{condition,yes,no}: x185_t_if(condition,yes,no,scan)
    case P113DCall{names,target,args}: x185_t_cut(x185_t_forbid_names(names,x185_t_forbid_values(args,scan)))
    case P113DResult{values}: x185_t_cut(x185_t_reads(values,scan))
    case P113DAgain{values}: x185_t_cut(x185_t_reads(values,scan))

@unsafe
def x185_t_body(body,scan):
  match body:
    case Nil{}: scan
    case Con{head,rest}: x185_t_body(rest,x185_t_stmt(head,scan))

# First definition encounter order is interval-start order. The fixed five
# endpoint slots give constant work per candidate; full pressure keeps Stack.
@unsafe
def x185_t_pick(ends: List<&2,U32>, +first: U32, +index: U32) -> U32:
  match ends:
    case Nil{}: 5
    case Con{last,rest}: nt_choose(U32,U32.is_lt(last,first),
      u => index,u => x185_t_pick(rest,first,U32.inc(index)))

@unsafe
def x185_t_end(ends: List<&2,U32>, +index: U32, +last: U32) -> List<&2,U32>:
  match ends:
    case Nil{}: []
    case Con{head,+rest}: nt_choose(List<&2,U32>,U32.is_eq(index,0),
      u => Con{last,rest},u => Con{head,x185_t_end(rest,U32.sub(index,1),last)})

def x185_t_slot(slot: KDef, register: U32) -> KDef:
  match slot:
    case KDef{name,kind,arity,bytes,typ,value,children,native,uns}:
      KDef{name,"X185Transient",register,bytes,typ,value,children,native,uns}
    case _: slot

@unsafe
def x185_t_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x185_t_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

law x185_t_place:
  for names: List<&2,String>
  for +ranges: KDef
  for +frame: X181Frame
  for +ends: List<&2,U32>
  X181Frame

@unsafe
def x185_t_chosen(name: String, +rest: List<&2,String>, +ranges: KDef, +frame: X181Frame,
    +ends: List<&2,U32>, +index: U32, +last: U32) -> X181Frame:
  nt_choose(X181Frame,U32.is_lt(index,5),
    u => x185_t_place(rest,ranges,x185_t_install(name,index,frame),x185_t_end(ends,index,last)),
    u => x185_t_place(rest,ranges,frame,ends))

@unsafe
def x185_t_place(names,ranges,frame,ends):
  match names frame:
    case Nil{} _: frame
    case Con{+name,+rest} X181Frame{+slots,bytes,calls,params,symbol}:
      +range = p111v_get(ranges,name)
      nt_choose(X181Frame,String.eq(dk(range),"X185TRange") &&
          String.eq(dk(p111v_get(slots,name)),"X181Stack"),
        u => x185_t_chosen(name,rest,ranges,frame,ends,x185_t_pick(ends,da(range),0),dx(range)),
        u => x185_t_place(rest,ranges,frame,ends))

@unsafe
def x185_t_scanned(frame: X181Frame, scan: X185TScan) -> X181Frame:
  match scan:
    case X185TScan{ranges,names,position,region}:
      x185_t_place(nt_reverse(String,names,[]),ranges,frame,[0,0,0,0,0])

# Setup is scanned only to exclude its definitions. Such values can survive
# every Again even after their last lexical body read. No entry or call moves
# are changed, and the existing four unique callee-saved homes stay reserved.
@unsafe
def x185_transient_frame(frame,params,setup,body):
  nt_choose(X181Frame,x185_transient_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_t_scanned(frame,x185_t_body(body,
      X185TScan{x185_copy_writes_names(params,x185_copy_writes(setup,missing())),[],1,0})),u => frame)
