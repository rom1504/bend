# Physical selection only: retain original facts, allocation and result writes.
def x195_pm_enabled() -> Bool: True{}

@unsafe
def x195_pm_inverse(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "ne",u =>
  nt_choose(String,String.eq(op,"ne"),u => "e",u =>
  nt_choose(String,String.eq(op,"ult"),u => "ae",u =>
  nt_choose(String,String.eq(op,"ule"),u => "a",u =>
  nt_choose(String,String.eq(op,"ugt"),u => "be",u =>
  nt_choose(String,String.eq(op,"uge"),u => "b",u =>
  nt_choose(String,String.eq(op,"slt"),u => "ge",u =>
  nt_choose(String,String.eq(op,"sle"),u => "g",u =>
  nt_choose(String,String.eq(op,"sgt"),u => "le",u => "l")))))))))

@unsafe
def x195_pm_destination(names: List<&2,String>, frame: X181Frame) -> U32:
  match names:
    case Con{name,rest}: x191_reg_home(x185_physical_home(name,frame),11)
    case Nil{}: 11

@unsafe
def x195_pm_load(+value: N111Value, +typ: N111Type, +ids: N111Ids, +frame: X181Frame, +reg: U32) -> X188Seq:
  +narrow = nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1),
    u => x190_narrow_value(value,frame,x188_reg(reg,32)),u => X188Empty{})
  nt_choose(X188Seq,x188_empty(narrow),
    u => x188_cat(x185_physical_load(value,ids,frame,x188_reg(reg,64)),x181_mask(typ,x188_reg(reg,32))),u => narrow)

@unsafe
def x195_pm_operand_slot(+slot: KDef, typ: N111Type, physical: X185Physical) -> Maybe<&2,X187Operand>:
  match physical:
    case X185Physical{wide,narrow,byte}: Some{x188_physical_width(typ,wide,narrow)}
    case X185PhysicalNone{}:
      nt_choose(Maybe<&2,X187Operand>,String.eq(dk(slot),"X181Stack"),
        u => Some{X187Mem{5,U32.sub(0,da(slot))}},u => None{})

@unsafe
def x195_pm_operand(value: N111Value, +typ: N111Type, frame: X181Frame) -> Maybe<&2,X187Operand>:
  match value frame:
    case N111Local{name} X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      x195_pm_operand_slot(slot,typ,x185_physical_slot(slot))
    case _ _: None{}

@unsafe
def x195_pm_compare(+typ: N111Type, +left: N111Value, +right: N111Value, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +lr = x191_reg(left,frame,10)
  +rr = x191_reg(right,frame,11)
  +immediate = x190_branch_immediate_to(typ,right,x188_width_reg(typ,lr))
  x188_cat(x185_physical_load(left,ids,frame,x188_reg(lr,64)),
    nt_choose(X188Seq,x188_empty(immediate),u =>
      x188_cat(x185_physical_load(right,ids,frame,x188_reg(rr,64)),
        x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,rr),x188_width_reg(typ,lr))),u => immediate))

@unsafe
def x195_pm_cmov(operand: Maybe<&2,X187Operand>, +value: N111Value, +typ: N111Type,
    +cc: String, +destination: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match operand:
    case Some{source}: x188_i2("cmov" ++ cc ++ x181_width(typ,"q","l"),source,x188_width_reg(typ,destination))
    case None{}: x188_many([x195_pm_load(value,typ,ids,frame,0),
      x188_i2("cmov" ++ cc ++ x181_width(typ,"q","l"),x188_width_reg(typ,0),x188_width_reg(typ,destination))])

@unsafe
def x195_pm_publish(names: List<&2,String>, +destination: U32, +frame: X181Frame) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{+name,rest}: x188_cat(
      nt_choose(X188Seq,x185_physical_same(x185_physical_home(name,frame),x188_reg(destination,64)),
        u => X188Empty{},u => x181_store(name,frame,x188_reg(destination,64))),x195_pm_publish(rest,destination,frame))

# CMP has already consumed its inputs. All instructions below preserve flags.
# If destination holds yes, retain it and invert the condition to take no.
# Otherwise destination does not hold yes, so initializing no cannot destroy yes.
@unsafe
def x195_pm_general(+typ: N111Type, +op: String, +yes: N111Value, +no: N111Value,
    +destination: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,x185_physical_source(yes,frame,x188_reg(destination,64)),
    u => x188_cat(x181_mask(typ,x188_reg(destination,32)),
      x195_pm_cmov(x195_pm_operand(no,typ,frame),no,typ,x195_pm_inverse(op),destination,ids,frame)),
    u => x188_cat(x195_pm_load(no,typ,ids,frame,destination),
      x195_pm_cmov(x195_pm_operand(yes,typ,frame),yes,typ,x181_condition(op),destination,ids,frame)))

# Selected constants 0/1 need no 64-bit immediate snapshots or CMOV. SETcc then
# MOVZX publishes the exact full word for both U32 and U64 selected widths.
@unsafe
def x195_pm_result(+typ: N111Type, +op: String, +yes: N111Value, +no: N111Value,
    +destination: U32, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,(x192_p_constant(yes,1) && x192_p_constant(no,0)) ||
      (x192_p_constant(yes,0) && x192_p_constant(no,1)),
    u => x188_many([x188_i1("set" ++ nt_choose(String,x192_p_constant(yes,1),
      v => x181_condition(op),v => x195_pm_inverse(op)),x188_reg(destination,8)),
      x188_i2("movzbl",x188_reg(destination,8),x188_reg(destination,32))]),
    u => x195_pm_general(typ,op,yes,no,destination,ids,frame))

@unsafe
def x195_pm_emit(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,typ,+op,left,right,+invert,X191SelectPlan{st,+yes,+no,+names},removed}:
      +destination = x195_pm_destination(names,frame)
      x188_many([x195_pm_compare(typ,left,right,ids,frame),
        x195_pm_result(st,op,nt_choose(N111Value,invert,u => no,u => yes),
          nt_choose(N111Value,invert,u => yes,u => no),destination,ids,frame),x195_pm_publish(names,destination,frame)])

@unsafe
def x195_pm_previous(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,+typ,+op,left,right,invert,X191SelectPlan{+st,+yes,+no,names},removed}:
      x188_many([x181_load(left,ids,frame,x188_reg(10,64)),
        x181_load(right,ids,frame,x188_reg(11,64)),
        x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,11),x188_width_reg(typ,10)),
        x181_load(nt_choose(N111Value,invert,u => no,u => yes),ids,frame,x188_reg(0,64)),x181_mask(st,x188_reg(0,32)),
        x181_load(nt_choose(N111Value,invert,u => yes,u => no),ids,frame,x188_reg(11,64)),x181_mask(st,x188_reg(11,32)),
        x188_i2("cmov" ++ x181_condition(op) ++ x181_width(st,"q","l"),x188_width_reg(st,0),x188_width_reg(st,11)),
        x191_select_publish(names,frame)])
