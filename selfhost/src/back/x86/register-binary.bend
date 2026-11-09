# Direct register destinations for scalar binary operations. Right operands
# are snapshotted into reserved r11 BEFORE the destination is overwritten;
# left/right/destination may otherwise share any admitted physical home.

def x185_register_binary_enabled() -> Bool: True{}

@unsafe
def x188_physical(+index: U32) -> X185Physical:
  X185Physical{x188_reg(index,64),x188_reg(index,32),x188_reg(index,8)}

def x185_physical_callee(index: U32) -> X185Physical:
  match index:
    case 0: x188_physical(12)
    case 1: x188_physical(3)
    case 2: x188_physical(13)
    case 3: x188_physical(14)
    case _: x188_physical(15)

def x185_physical_transient(index: U32) -> X185Physical:
  match index:
    case 0: x188_physical(7)
    case 1: x188_physical(6)
    case 2: x188_physical(2)
    case 3: x188_physical(8)
    case _: x188_physical(9)

def x188_physical_width(typ: N111Type, wide: X187Operand, narrow: X187Operand) -> X187Operand:
  match typ:
    case N111U32{}: narrow
    case _: wide

@unsafe
def x185_physical_slot(+slot: KDef) -> X185Physical:
  nt_choose(X185Physical,String.eq(dk(slot),"X181Register"),u => x185_physical_callee(da(slot)),
    u => nt_choose(X185Physical,String.eq(dk(slot),"X185Transient"),u => x185_physical_transient(da(slot)),
      u => X185PhysicalNone{}))

@unsafe
def x185_physical_home(name: String, frame: X181Frame) -> X185Physical:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: x185_physical_slot(p111v_get(slots,name))

@unsafe
def x185_physical_same(reg: X185Physical, name: X187Operand) -> Bool:
  match reg:
    case X185Physical{wide,narrow,byte}: x188_operand_same(wide,name)
    case _: False{}

@unsafe
def x185_physical_source(value: N111Value, frame: X181Frame, reg: X187Operand) -> Bool:
  match value:
    case N111Local{name}: x185_physical_same(x185_physical_home(name,frame),reg)
    case _: False{}

@unsafe
def x185_physical_load(+value: N111Value, +ids: N111Ids, +frame: X181Frame, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,x185_physical_source(value,frame,reg),u => X188Empty{},u => x181_load(value,ids,frame,reg))

@unsafe
def x185_physical_instruction(+typ: N111Type, +op: String,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  +left = x188_physical_width(typ,wide,narrow)
  +right = x188_width_reg(typ,11)
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(X188Seq,Bool.not(String.is_empty(condition)),u =>
    x188_many([x188_i2("cmp" ++ suffix,right,left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),u =>
    nt_choose(X188Seq,String.is_empty(alu),v => X188Empty{},v =>
      nt_choose(X188Seq,x181_shift(op),w =>
        x188_many([x188_i2("movl",x188_reg(11,32),x188_reg(1,32)),x188_i2(alu ++ suffix,x188_reg(1,8),left)]),
        w => x188_i2(alu ++ suffix,right,left))))

@unsafe
def x185_physical_immediate(+typ: N111Type, +op: String, value: N111Value,
    +wide: X187Operand, +narrow: X187Operand, +byte: X187Operand) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_physical_width(typ,wide,narrow)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,String.eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",narrow,narrow),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,byte),x188_i2("movzbl",byte,narrow)]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))
    case _: X188Empty{}

@unsafe
def x185_physical_selected(+typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, reg: X185Physical) -> X188Seq:
  match reg:
    case X185Physical{+wide,+narrow,+byte}:
      +instruction = x185_physical_instruction(typ,op,wide,narrow,byte)
      +immediate = nt_choose(X188Seq,x185_machine_enabled(),
        u => x185_physical_immediate(typ,op,right,wide,narrow,byte),u => X188Empty{})
      nt_choose(X188Seq,x188_empty(instruction),u => X188Empty{},u =>
        nt_choose(X188Seq,x188_empty(immediate),v =>
          x188_many([x181_load(right,ids,frame,x188_reg(11,64)),x185_physical_load(left,ids,frame,wide),instruction]),
          v => x188_cat(x185_physical_load(left,ids,frame,wide),immediate)))
    case _: X188Empty{}

@unsafe
def x185_physical_binary(name,typ,op,left,right,ids,frame):
  nt_choose(X188Seq,x185_register_binary_enabled(),
    u => x185_physical_selected(typ,op,left,right,ids,frame,x185_physical_home(name,frame)),u => X188Empty{})
