# Experimental physical right-home selection for integer commutative ALU.
# No expression/value motion, allocation change, or additional analysis walk.
def x194_cr_enabled() -> Bool: True{}
def x194_cr_op(+op: String) -> Bool:
  String.eq(op,"add") || String.eq(op,"mul") || String.eq(op,"and") ||
    String.eq(op,"or") || String.eq(op,"xor")

@unsafe
def x194_cr_select(+typ: N111Type, +op: String, +wide: X187Operand,
    +narrow: X187Operand, +byte: X187Operand, right: X185Physical, left: X185Physical) -> X188Seq:
  match right left:
    case X185Physical{rw,rn,rb} X185Physical{lw,ln,lb}:
      nt_choose(X188Seq,x194_cr_enabled() && x190_branch_width(typ) && x194_cr_op(op) &&
          x188_operand_same(rw,wide),
        u => x190_operand_instruction(typ,op,wide,narrow,byte,x188_physical_width(typ,lw,ln)),
        u => X188Empty{})
    case _ _: X188Empty{}

@unsafe
def x194_cr_direct(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    +narrow: X187Operand, +byte: X187Operand, +right: X185Physical) -> X188Seq:
  +commuted = x194_cr_select(typ,op,wide,narrow,byte,right,x190_value_home(left,frame))
  nt_choose(X188Seq,x188_empty(commuted),
    u => x194_cr_previous(typ,op,left,ids,frame,wide,narrow,byte,right),u => commuted)

# Exact previous direct-operand selection, retained as the refusal path.
@unsafe
def x194_cr_previous(+typ: N111Type, +op: String, +left: N111Value,
    +ids: N111Ids, +frame: X181Frame, +wide: X187Operand,
    narrow: X187Operand, byte: X187Operand, right: X185Physical) -> X188Seq:
  match right:
    case X185Physical{+rw,rn,rb}:
      nt_choose(X188Seq,Bool.not(x181_shift(op)) &&
          (Bool.not(x188_operand_same(rw,wide)) || x185_physical_source(left,frame,wide)),u =>
        x188_cat(x185_physical_load(left,ids,frame,wide),
          x190_operand_instruction(typ,op,wide,narrow,byte,x188_physical_width(typ,rw,rn))),u => X188Empty{})
    case _: X188Empty{}
