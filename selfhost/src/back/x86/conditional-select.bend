# Final selection over already verified, effect-free copy arms. Keep the
# original allocation graph and every original write. Both input values and
# the condition are snapshotted before any destination can overwrite a source.
type X191SelectPlan is Data:
  X191SelectPlan{+typ: N111Type, +yes: N111Value, +no: N111Value, +names: List<&2,String>}

def x191_conditional_select_enabled() -> Bool: True{}

def x191_select_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: True{}
    case N111Const{lo,hi}: True{}
    case _: False{}

def x191_select_width(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}

@unsafe
def x191_select_names(name: String, rest: Maybe<&2,List<&2,String>>) -> Maybe<&2,List<&2,String>>:
  match rest:
    case Some{names}: Some{Con{name,names}}
    case None{}: None{}

# Every subsequent copy must read its immediately preceding destination.
# Mixed widths, unequal writes, calls, loads, stores and control flow refuse.
@unsafe
def x191_select_tail(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    +typ: N111Type, +previous: String, +fuel: U32) -> Maybe<&2,List<&2,String>>:
  match yes no:
    case Nil{} Nil{}: Some{[]}
    case Con{P113DScalar{N111Set{+a,ta,N111Local{sa}}},ar}
         Con{P113DScalar{N111Set{b,tb,N111Local{sb}}},br}:
      nt_choose(Maybe<&2,List<&2,String>>,U32.is_gt(fuel,0) && String.eq(a,b) &&
          Bool.not(x181_register_reserved(a)) && String.eq(sa,previous) && String.eq(sb,previous) &&
          U32.is_eq(p111v_type(ta),p111v_type(typ)) && U32.is_eq(p111v_type(tb),p111v_type(typ)),
        u => x191_select_names(a,x191_select_tail(ar,br,typ,a,U32.sub(fuel,1))),u => None{})
    case _ _: None{}

@unsafe
def x191_select_ready(typ: N111Type, yes: N111Value, no: N111Value,
    names: Maybe<&2,List<&2,String>>) -> Maybe<&2,X191SelectPlan>:
  match names:
    case Some{destinations}: Some{X191SelectPlan{typ,yes,no,destinations}}
    case None{}: None{}

@unsafe
def x191_select_plan(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>) -> Maybe<&2,X191SelectPlan>:
  match yes no:
    case Con{P113DScalar{N111Set{+a,+ta,+va}},ar}
         Con{P113DScalar{N111Set{b,tb,+vb}},br}:
      nt_choose(Maybe<&2,X191SelectPlan>,String.eq(a,b) && Bool.not(x181_register_reserved(a)) &&
          x191_select_width(ta) && U32.is_eq(p111v_type(ta),p111v_type(tb)) &&
          x191_select_value(va) && x191_select_value(vb),u =>
        x191_select_ready(ta,va,vb,x191_select_names(a,x191_select_tail(ar,br,ta,a,3))),u => None{})
    case _ _: None{}

@unsafe
def x191_select_publish(names: List<&2,String>, +frame: X181Frame) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{name,rest}:
      x188_cat(x181_store(name,frame,x188_reg(11,64)),x191_select_publish(rest,frame))

@unsafe
def x191_select_emit(condition: N111Value, plan: X191SelectPlan,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match plan:
    case X191SelectPlan{+typ,yes,no,names}:
      x188_many([x181_load(condition,ids,frame,x188_reg(0,64)),
        x181_load(yes,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),
        x181_load(no,ids,frame,x188_reg(11,64)),x181_mask(typ,x188_reg(11,32)),
        x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
        x188_i2(x181_width(typ,"cmovneq","cmovnel"),x188_width_reg(typ,10),x188_width_reg(typ,11)),
        x191_select_publish(names,frame)])

@unsafe
def x191_select_chosen(plan: Maybe<&2,X191SelectPlan>, condition: N111Value,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  match plan:
    case Some{selected}: Some{x191_select_emit(condition,selected,ids,frame)}
    case None{}: None{}

# An empty pair has no effects. Its already evaluated Local/Const condition
# need not be loaded or tested; any preceding Boolean producer stays intact.
@unsafe
def x191_select_arms(condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  nt_choose(Maybe<&2,X188Seq>,List.is_empty(&2,P113DStmt,yes) && List.is_empty(&2,P113DStmt,no),
    u => Some{X188Empty{}},u => x191_select_chosen(x191_select_plan(yes,no),condition,ids,frame))

@unsafe
def x191_conditional_select(+condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    ids: N111Ids, frame: X181Frame) -> Maybe<&2,X188Seq>:
  nt_choose(Maybe<&2,X188Seq>,x191_conditional_select_enabled() && x191_select_value(condition),
    u => x191_select_arms(condition,yes,no,ids,frame),u => None{})
