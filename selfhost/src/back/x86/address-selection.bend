# A bounded selection window over verified scalar rows. The same matcher drives
# allocation metadata and final emission; metadata rows are never emitted or
# optimized. Eliminated names have one whole-function read and one definition,
# including parameters, setup, branches, continuations and backedges.
def x191_address_enabled() -> Bool: True{}
def x191_memory_alu_enabled() -> Bool: True{}

@unsafe
def x191_single(+name: String, facts: X190BranchFacts) -> Bool:
  match facts:
    case X190BranchFacts{reads,writes,pairs,protected}:
      Bool.not(x181_register_reserved(name)) && U32.is_eq(da(p111v_get(reads,name)),1) &&
        U32.is_eq(da(p111v_get(writes,name)),1) && U32.is_eq(da(p111v_get(protected,name)),0)

# Only full-width multiplication/left shift matches 64-bit effective-address
# arithmetic. A U32 intermediate must retain its wrap and zero extension.
def x191_shift_scale(n: U32) -> U32:
  match n:
    case 0: 1
    case 1: 2
    case 2: 4
    case _: 8

@unsafe
def x191_scale(+op: String, value: N111Value) -> U32:
  match value:
    case N111Const{+lo,0}:
      nt_choose(U32,String.eq(op,"mul") &&
          (U32.is_eq(lo,1) || U32.is_eq(lo,2) || U32.is_eq(lo,4) || U32.is_eq(lo,8)),
        u => lo,u => nt_choose(U32,String.eq(op,"shl") && U32.is_le(lo,3),
          v => x191_shift_scale(lo),v => 0))
    case _: 0

@unsafe
def x191_alu(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"sub") || String.eq(op,"and") ||
    String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"mul")

@unsafe
def x191_commutative(+op: String) -> Bool:
  x191_alu(op) && Bool.not(String.eq(op,"sub"))

@unsafe
def x191_alu_left(+name: String, +op: String, +left: N111Value, +right: N111Value) -> Maybe<&2,N111Value>:
  nt_choose(Maybe<&2,N111Value>,x185_sf_source(right,name) && Bool.not(x185_sf_source(left,name)),
    u => Some{left},u => nt_choose(Maybe<&2,N111Value>,x191_commutative(op) &&
      x185_sf_source(left,name) && Bool.not(x185_sf_source(right,name)),u => Some{right},u => None{}))

@unsafe
def x191_alu_found(found: Maybe<&2,N111Value>, rest: List<&2,P113DStmt>, name: String,
    typ: N111Type, op: String, address: X191Address) -> Maybe<&2,X191Pick>:
  match found:
    case Some{left}: Some{X191Pick{rest,X191MemoryAlu{name,typ,op,left,address}}}
    case None{}: None{}

# The load moves only across its immediately following ALU. No stores, calls,
# branches or other observable effects are crossed. Widths agree exactly.
@unsafe
def x191_load_alu(+loaded: String, +typ: N111Type, address: X191Address,
    body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Bin{name,+other,+op,left,right}},rest}:
      nt_choose(Maybe<&2,X191Pick>,x191_memory_alu_enabled() && x191_single(loaded,facts) &&
          U32.is_eq(p111v_type(typ),p111v_type(other)) && x191_alu(op),
        u => x191_alu_found(x191_alu_left(loaded,op,left,right),rest,name,other,op,address),u => None{})
    case _: None{}

@unsafe
def x191_load_chosen(fused: Maybe<&2,X191Pick>, rest: List<&2,P113DStmt>, name: String,
    typ: N111Type, address: X191Address) -> Maybe<&2,X191Pick>:
  match fused:
    case Some{pick}: Some{pick}
    case None{}: Some{X191Pick{rest,X191Load{name,typ,address}}}

@unsafe
def x191_access(+address: X191Address, +pointer: String, body: List<&2,P113DStmt>,
    +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match address body:
    case X191Address{+base,+index,+scale,disp} Con{P113DScalar{N111Load{+name,+typ,N111Local{source},+offset}},+rest}:
      nt_choose(Maybe<&2,X191Pick>,String.eq(pointer,source) && U32.is_le(offset,2147483647),u =>
        x191_load_chosen(x191_load_alu(name,typ,X191Address{base,index,scale,offset},rest,facts),
          rest,name,typ,X191Address{base,index,scale,offset}),u => None{})
    case X191Address{base,index,scale,disp} Con{P113DScalar{N111Store{typ,N111Local{source},+offset,value}},rest}:
      nt_choose(Maybe<&2,X191Pick>,String.eq(pointer,source) && U32.is_le(offset,2147483647),
        u => Some{X191Pick{rest,X191Store{typ,X191Address{base,index,scale,offset},value}}},u => None{})
    case _ _: None{}

@unsafe
def x191_indexed(+body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Bin{+scaled,N111U64{},op,index,factor}},
      Con{P113DScalar{N111Offset{+pointer,base,N111Local{source}}},rest}}:
      +scale = x191_scale(op,factor)
      nt_choose(Maybe<&2,X191Pick>,x191_address_enabled() && U32.is_gt(scale,0) &&
          String.eq(scaled,source) && x191_single(scaled,facts) && x191_single(pointer,facts),
        u => x191_access(X191Address{base,index,scale,0},pointer,rest,facts),u => None{})
    case Con{P113DScalar{N111Offset{+pointer,base,index}},rest}:
      nt_choose(Maybe<&2,X191Pick>,x191_address_enabled() && x191_single(pointer,facts),
        u => x191_access(X191Address{base,index,1,0},pointer,rest,facts),u => None{})
    case _: None{}

@unsafe
def x191_pick(+body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> Maybe<&2,X191Pick>:
  match body:
    case Con{P113DScalar{N111Load{name,typ,base,+offset}},rest}:
      nt_choose(Maybe<&2,X191Pick>,U32.is_le(offset,2147483647),
        u => x191_load_alu(name,typ,X191Address{base,N111Const{0,0},0,offset},rest,facts),u => None{})
    case _: x191_indexed(body,facts)

# Placement rows preserve each actual input, output and call barrier. A store
# has no definition. Splitting its three reads into two rows is conservative:
# base and value remain live through the first row, overlapping the index.
# No metadata row escapes to source verification, memory analysis or emission.
@unsafe
def x191_reads(address: X191Address) -> List<&2,P113DStmt>:
  match address:
    case X191Address{base,index,scale,disp}: [P113DScalar{N111Store{N111U64{},base,0,index}}]

@unsafe
def x191_rows(operation: X191Operation) -> List<&2,P113DStmt>:
  match operation:
    case X191Load{name,typ,X191Address{base,index,scale,disp}}:
      [P113DScalar{N111Bin{name,typ,"add",base,index}}]
    case X191Store{typ,+address,value}:
      match address:
        case X191Address{base,index,scale,disp}:
          nt_append(P113DStmt,x191_reads(address),[P113DScalar{N111Store{typ,base,0,value}}])
    case X191MemoryAlu{name,typ,op,left,+address}:
      match address:
        case X191Address{base,index,scale,disp}:
          nt_append(P113DStmt,x191_reads(address),[P113DScalar{N111Bin{name,typ,op,left,base}}])

law x191_placement:
  for +body: List<&2,P113DStmt>
  for +facts: X190BranchFacts
  List<&2,P113DStmt>

@unsafe
def x191_placement_plain(body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,x191_placement(yes,facts),x191_placement(no,facts)},x191_placement(rest,facts)}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      Con{P113DIf{condition,x191_placement(x181_scalar_rows(yes),facts),
        x191_placement(x181_scalar_rows(no),facts)},x191_placement(rest,facts)}
    case Con{head,rest}: Con{head,x191_placement(rest,facts)}

@unsafe
def x191_placement_pick(pick: Maybe<&2,X191Pick>, body: List<&2,P113DStmt>, +facts: X190BranchFacts) -> List<&2,P113DStmt>:
  match pick:
    case Some{X191Pick{rest,operation}}: nt_append(P113DStmt,x191_rows(operation),x191_placement(rest,facts))
    case None{}: x191_placement_plain(body,facts)

@unsafe
def x191_placement(body,facts):
  x191_placement_pick(x191_pick(body,facts),body,facts)

# Frame homes never use reserved r10/r11/rax. Evaluate both address components
# before writing any destination. A load may alias either address register;
# an ALU must use rax when its destination aliases an address register.
@unsafe
def x191_reg_home(home: X185Physical, fallback: U32) -> U32:
  match home:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}: index
    case _: fallback

@unsafe
def x191_reg(value: N111Value, frame: X181Frame, fallback: U32) -> U32:
  x191_reg_home(x190_value_home(value,frame),fallback)

@unsafe
def x191_address_code(address: X191Address, +ids: N111Ids, +frame: X181Frame) -> X191AddressCode:
  match address:
    case X191Address{+base,+index,+scale,disp}:
      +br = x191_reg(base,frame,10)
      +ir = x191_reg(index,frame,11)
      X191AddressCode{x188_cat(x185_physical_load(base,ids,frame,x188_reg(br,64)),
        nt_choose(X188Seq,U32.is_eq(scale,0),u => X188Empty{},
          u => x185_physical_load(index,ids,frame,x188_reg(ir,64)))),
        nt_choose(X187Operand,U32.is_eq(scale,0),u => X187Mem{br,disp},
          u => X187Indexed{br,ir,scale,disp})}

@unsafe
def x191_destination(name: String, frame: X181Frame) -> U32:
  x191_reg_home(x185_physical_home(name,frame),0)

@unsafe
def x191_aliases(+reg: U32, memory: X187Operand) -> Bool:
  match memory:
    case X187Mem{base,disp}: U32.is_eq(reg,base)
    case X187Indexed{base,index,scale,disp}: U32.is_eq(reg,base) || U32.is_eq(reg,index)
    case _: True{}

@unsafe
def x191_publish(+name: String, +reg: U32, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(reg,x191_destination(name,frame)) && Bool.not(U32.is_eq(reg,0)),
    u => X188Empty{},u => x181_store(name,frame,x188_reg(reg,64)))

@unsafe
def x191_emit_address(operation: X191Operation, address: X191AddressCode, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation address:
    case X191Load{+name,+typ,a} X191AddressCode{prefix,operand}:
      +dest = x191_destination(name,frame)
      x188_many([prefix,x188_i2(x181_width(typ,"movq","movl"),operand,x188_width_reg(typ,dest)),
        x191_publish(name,dest,frame)])
    case X191Store{+typ,a,+value} X191AddressCode{prefix,operand}:
      +source = x191_reg(value,frame,0)
      x188_many([prefix,x185_physical_load(value,ids,frame,x188_reg(source,64)),
        x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,source),operand)])
    case X191MemoryAlu{+name,+typ,op,left,a} X191AddressCode{prefix,+operand}:
      +home = x191_destination(name,frame)
      +dest = nt_choose(U32,x191_aliases(home,operand),u => 0,u => home)
      x188_many([prefix,x185_physical_load(left,ids,frame,x188_reg(dest,64)),
        x188_i2(x181_alu(op) ++ x181_width(typ,"q","l"),operand,x188_width_reg(typ,dest)),
        x191_publish(name,dest,frame)])

@unsafe
def x191_emit(+operation: X191Operation, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match operation:
    case X191Load{name,typ,address}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)
    case X191Store{typ,address,value}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)
    case X191MemoryAlu{name,typ,op,left,address}: x191_emit_address(operation,x191_address_code(address,ids,frame),ids,frame)

# Original rows determine facts and fallback frame storage. The independent
# liveness plan sees exact selected inputs/outputs; only original rows and the
# same selection matcher reach emission. Float/XMM node paths stay separate.
@unsafe
def x191_function_saved(+symbol: String, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>,
    facts: X190BranchFacts, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  x181_function_done(symbol,x190_stmts(body,facts,ids,frame,x181_add(x188_label(x181_loop_label(frame)),
    x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))))

@unsafe
def x191_ordinary_facts(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids, +facts: X190BranchFacts) -> X181Output:
  +placement = x191_placement(body,facts)
  x191_function_saved(symbol,setup,body,facts,ids,x186_saves_frame(x190_allocate_frame(
    x181_frame(symbol,params,nt_append(P113DStmt,setup,body)),params,setup,placement,
      nt_choose(List<&2,P113DStmt>,x185_loop_registers_enabled(),u => placement,
        u => nt_append(P113DStmt,setup,placement)))))

@unsafe
def x191_ordinary(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, ids: N111Ids) -> X181Output:
  x191_ordinary_facts(symbol,params,setup,body,ids,x190_branch_facts(params,setup,body))
