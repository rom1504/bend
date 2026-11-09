# Direct register destinations for scalar binary operations. Right operands
# are snapshotted into reserved r11 BEFORE the destination is overwritten;
# left/right/destination may otherwise share any admitted physical home.

def x185_register_binary_enabled() -> Bool: True{}

def x185_physical_callee(index: U32) -> X185Physical:
  match index:
    case 0: X185Physical{"%r12","%r12d","%r12b"}
    case 1: X185Physical{"%rbx","%ebx","%bl"}
    case 2: X185Physical{"%r13","%r13d","%r13b"}
    case 3: X185Physical{"%r14","%r14d","%r14b"}
    case _: X185Physical{"%r15","%r15d","%r15b"}

def x185_physical_transient(index: U32) -> X185Physical:
  match index:
    case 0: X185Physical{"%rdi","%edi","%dil"}
    case 1: X185Physical{"%rsi","%esi","%sil"}
    case 2: X185Physical{"%rdx","%edx","%dl"}
    case 3: X185Physical{"%r8","%r8d","%r8b"}
    case _: X185Physical{"%r9","%r9d","%r9b"}

@unsafe
def x185_physical_slot(+slot: KDef) -> X185Physical:
  nt_choose(X185Physical,String.eq(dk(slot),"X181Register"),u => x185_physical_callee(da(slot)),
    u => nt_choose(X185Physical,String.eq(dk(slot),"X185Transient"),u => x185_physical_transient(da(slot)),
      u => X185PhysicalNone{}))

@unsafe
def x185_physical_home(name: String, frame: X181Frame) -> X185Physical:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: x185_physical_slot(p111v_get(slots,name))

def x185_physical_same(reg: X185Physical, name: String) -> Bool:
  match reg:
    case X185Physical{wide,narrow,byte}: String.eq(wide,name)
    case _: False{}

@unsafe
def x185_physical_source(value: N111Value, frame: X181Frame, reg: String) -> Bool:
  match value:
    case N111Local{name}: x185_physical_same(x185_physical_home(name,frame),reg)
    case _: False{}

@unsafe
def x185_physical_load(+value: N111Value, +ids: N111Ids, +frame: X181Frame, +reg: String) -> String:
  nt_choose(String,x185_physical_source(value,frame,reg),u => "",u => x181_load(value,ids,frame,reg))

@unsafe
def x185_physical_instruction(+typ: N111Type, +op: String, +wide: String, +narrow: String, +byte: String) -> String:
  +suffix = x181_width(typ,"q","l")
  +left = x181_width(typ,wide,narrow)
  +right = x181_width(typ,"%r11","%r11d")
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(String,Bool.not(String.is_empty(condition)),
    u => "  cmp" ++ suffix ++ " " ++ right ++ ", " ++ left ++ "\n  set" ++ condition ++ " " ++ byte ++
      "\n  movzbl " ++ byte ++ ", " ++ narrow ++ "\n",
    u => nt_choose(String,String.is_empty(alu),v => "",v =>
      nt_choose(String,x181_shift(op),
        w => "  movl %r11d, %ecx\n  " ++ alu ++ suffix ++ " %cl, " ++ left ++ "\n",
        w => "  " ++ alu ++ suffix ++ " " ++ right ++ ", " ++ left ++ "\n")))

@unsafe
def x185_physical_immediate(+typ: N111Type, +op: String, value: N111Value,
    +wide: String, +narrow: String, +byte: String) -> String:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x181_width(typ,wide,narrow)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(String,x181_shift(op),
        u => "  " ++ alu ++ suffix ++ " $" ++ U32.show(U32.mod(lo,
          nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64))) ++ ", " ++ left ++ "\n",u =>
      nt_choose(String,String.eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => "  movl " ++ narrow ++ ", " ++ narrow ++ "\n",u =>
      nt_choose(String,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(String,Bool.not(String.is_empty(condition)),
          v => "  cmp" ++ suffix ++ " $" ++ U32.show(lo) ++ ", " ++ left ++ "\n  set" ++ condition ++ " " ++ byte ++
            "\n  movzbl " ++ byte ++ ", " ++ narrow ++ "\n",
          v => nt_choose(String,String.is_empty(alu),w => "",
            w => "  " ++ alu ++ suffix ++ " $" ++ U32.show(lo) ++ ", " ++ left ++ "\n")),u => "")))
    case _: ""

@unsafe
def x185_physical_selected(+typ: N111Type, +op: String, +left: N111Value, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, reg: X185Physical) -> String:
  match reg:
    case X185Physical{+wide,+narrow,+byte}:
      +instruction = x185_physical_instruction(typ,op,wide,narrow,byte)
      +immediate = nt_choose(String,x185_machine_enabled(),
        u => x185_physical_immediate(typ,op,right,wide,narrow,byte),u => "")
      nt_choose(String,String.is_empty(instruction),u => "",u =>
        nt_choose(String,String.is_empty(immediate),
          v => x181_load(right,ids,frame,"%r11") ++ x185_physical_load(left,ids,frame,wide) ++ instruction,
          v => x185_physical_load(left,ids,frame,wide) ++ immediate))
    case _: ""

@unsafe
def x185_physical_binary(name,typ,op,left,right,ids,frame):
  nt_choose(String,x185_register_binary_enabled(),
    u => x185_physical_selected(typ,op,left,right,ids,frame,x185_physical_home(name,frame)),u => "")
