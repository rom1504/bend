@unsafe
def x197ms_previous(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X194Select{rest,+typ,+op,left,right,invert,X191SelectPlan{+st,+yes,+no,names},removed}:
      x188_many([x181_load(left,ids,frame,x188_reg(10,64)),
        x181_load(right,ids,frame,x188_reg(11,64)),
        x188_i2(x181_width(typ,"cmpq","cmpl"),x188_width_reg(typ,11),x188_width_reg(typ,10)),
        x181_load(nt_choose(N111Value,invert,u => no,u => yes),ids,frame,x188_reg(0,64)),x181_mask(st,x188_reg(0,32)),
        x181_load(nt_choose(N111Value,invert,u => yes,u => no),ids,frame,x188_reg(11,64)),x181_mask(st,x188_reg(11,32)),
        x188_i2("cmov" ++ x181_condition(op) ++ x181_width(st,"q","l"),x188_width_reg(st,0),x188_width_reg(st,11)),
        x191_select_publish(names,frame)])


@unsafe
def x194_ps_emit(+plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +selected = x197ms_pick(plan,frame)
  nt_choose(X188Seq,x188_empty(selected),u => x197ms_previous(plan,ids,frame),u => selected)
