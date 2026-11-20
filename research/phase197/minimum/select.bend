# Register-aware selection only after the existing X194Select proof has
# accounted for all removed Boolean reads and every effect-free copy arm.
# No new liveness assumptions, names, frame homes, IR motion or clobbers.
def x197ms_enabled() -> Bool: True{}

@unsafe
def x197ms_inverse(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "ne",u =>
  nt_choose(String,String.eq(op,"ne"),u => "e",u =>
  nt_choose(String,String.eq(op,"ult"),u => "ae",u =>
  nt_choose(String,String.eq(op,"ule"),u => "a",u =>
  nt_choose(String,String.eq(op,"ugt"),u => "be",u =>
  nt_choose(String,String.eq(op,"uge"),u => "b",u =>
  nt_choose(String,String.eq(op,"slt"),u => "ge",u =>
  nt_choose(String,String.eq(op,"sle"),u => "g",u =>
  nt_choose(String,String.eq(op,"sgt"),u => "le",u =>
  nt_choose(String,String.eq(op,"sge"),u => "l",u => ""))))))))))

@unsafe
def x197ms_destination(names: List<&2,String>, frame: X181Frame) -> X185Physical:
  match names:
    case Con{name,rest}: x185_physical_home(name,frame)
    case Nil{}: X185PhysicalNone{}

# A store never changes its source register. Skipping a same-home publication
# preserves the actual assigned value; stack publications are always emitted.
@unsafe
def x197ms_publish(names: List<&2,String>, +frame: X181Frame, +result: X187Operand) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{+name,rest}:
      x188_cat(nt_choose(X188Seq,x185_physical_same(x185_physical_home(name,frame),result),
        u => X188Empty{},u => x181_store(name,frame,result)),x197ms_publish(rest,frame,result))

# CMP has already read both original operands. If result aliases yes, preserve
# that value and select no under the complementary predicate. Otherwise result
# either already holds no, or receives a width-correct MOV before CMOV yes.
# Explicit MOVL normalization covers a not-taken CMOV and noncanonical high bits.
@unsafe
def x197ms_select(+typ: N111Type, +op: String, +names: List<&2,String>, +frame: X181Frame,
    +yw: X187Operand, +yn: X187Operand, +nw: X187Operand, +nn: X187Operand,
    +dw: X187Operand, +dn: X187Operand) -> X188Seq:
  x188_many([
    nt_choose(X188Seq,x188_operand_same(dw,yw),u =>
      x188_many([x181_mask(typ,dn),
        x188_i2("cmov" ++ x197ms_inverse(op) ++ x181_width(typ,"q","l"),
          x188_physical_width(typ,nw,nn),x188_physical_width(typ,dw,dn))]),u =>
      x188_many([
        nt_choose(X188Seq,x188_operand_same(dw,nw),v => x181_mask(typ,dn),v =>
          x188_i2(x181_width(typ,"movq","movl"),x188_physical_width(typ,nw,nn),x188_physical_width(typ,dw,dn))),
        x188_i2("cmov" ++ x181_condition(op) ++ x181_width(typ,"q","l"),
          x188_physical_width(typ,yw,yn),x188_physical_width(typ,dw,dn))])),
    x197ms_publish(names,frame,dw)])

@unsafe
def x197ms_result(+typ: N111Type, +op: String, +names: List<&2,String>, +frame: X181Frame,
    +yw: X187Operand, +yn: X187Operand, +nw: X187Operand, +nn: X187Operand,
    destination: X185Physical) -> X188Seq:
  match destination:
    case X185Physical{dw,dn,db}: x197ms_select(typ,op,names,frame,yw,yn,nw,nn,dw,dn)
    case X185PhysicalNone{}: x197ms_select(typ,op,names,frame,yw,yn,nw,nn,x188_reg(11,64),x188_reg(11,32))

@unsafe
def x197ms_registers(+typ: N111Type, +op: String, +st: N111Type,
    +names: List<&2,String>, +frame: X181Frame,
    left: X185Physical, right: X185Physical, yes: X185Physical, no: X185Physical) -> X188Seq:
  match left right yes no:
    case X185Physical{lw,ln,lb} X185Physical{rw,rn,rb}
         X185Physical{yw,yn,yb} X185Physical{nw,nn,nb}:
      x188_cat(x188_i2(x181_width(typ,"cmpq","cmpl"),x188_physical_width(typ,rw,rn),x188_physical_width(typ,lw,ln)),
        x197ms_result(st,op,names,frame,yw,yn,nw,nn,x197ms_destination(names,frame)))
    case _ _ _ _: X188Empty{}

@unsafe
def x197ms_pick(plan: X194Select, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,typ,+op,left,right,+invert,X191SelectPlan{st,+yes,+no,names},removed}:
      nt_choose(X188Seq,x197ms_enabled() && Bool.not(String.is_empty(x197ms_inverse(op))),u =>
        x197ms_registers(typ,op,st,names,frame,x190_value_home(left,frame),x190_value_home(right,frame),
          x190_value_home(nt_choose(N111Value,invert,v => no,v => yes),frame),
          x190_value_home(nt_choose(N111Value,invert,v => yes,v => no),frame)),u => X188Empty{})
