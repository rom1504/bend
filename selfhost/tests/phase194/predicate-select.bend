# Experimental compare/copy/select fusion. No new whole-function traversal:
# the existing branch-pair walk collects independent counts in dx, leaving
# its original adjacent-branch count in da. The original allocation stays.
type X194Select is Data:
  X194Select{+rest: List<&2,P113DStmt>, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +invert: Bool,
    +select: X191SelectPlan, +names: List<&2,String>}

def x194_ps_enabled() -> Bool: True{}

@unsafe
def x194_ps_member(names: List<&2,String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,rest}: String.eq(head,name) || x194_ps_member(rest,name)

@unsafe
def x194_ps_source(names: List<&2,String>, value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x194_ps_member(names,name)
    case _: False{}

@unsafe
def x194_ps_disjoint(names: List<&2,String>, +other: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: Bool.not(x194_ps_member(other,name)) && x194_ps_disjoint(rest,other)

@unsafe
def x194_ps_finish(plan: Maybe<&2,X191SelectPlan>, condition: N111Value,
    rest: List<&2,P113DStmt>, +typ: N111Type, +op: String, +left: N111Value,
    +right: N111Value, +current: String, invert: Bool, +names: List<&2,String>) -> Maybe<&2,X194Select>:
  match plan:
    case Some{+selected}:
      match selected:
        case X191SelectPlan{st,yes,no,destinations}:
          nt_choose(Maybe<&2,X194Select>,x185_sf_source(condition,current) &&
              Bool.not(x194_ps_source(names,left) || x194_ps_source(names,right) ||
                x194_ps_source(names,yes) || x194_ps_source(names,no)) &&
              x194_ps_disjoint(destinations,names),
            u => Some{X194Select{rest,typ,op,left,right,invert,selected,names}},u => None{})
    case None{}: None{}

# Only exact 0/1 copies and xor1 are crossed. Any other row, including a source
# overwrite, memory access, call, allocation or control edge, refuses the plan.
@unsafe
def x194_ps_scan(body: List<&2,P113DStmt>, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +current: String, +invert: Bool,
    +names: List<&2,String>, +fuel: U32) -> Maybe<&2,X194Select>:
  match body:
    case Con{P113DIf{condition,yes,no},rest}:
      x194_ps_finish(x191_select_plan(yes,no),condition,rest,typ,op,left,right,current,invert,names)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x194_ps_finish(x191_select_plan(x181_scalar_rows(yes),x181_scalar_rows(no)),condition,rest,typ,op,left,right,current,invert,names)
    case Con{P113DScalar{N111Set{+name,width,value}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x190_branch_width(width) &&
          Bool.not(x181_register_reserved(name)) && x185_sf_source(value,current),
        u => x194_ps_scan(rest,typ,op,left,right,name,invert,Con{name,names},U32.sub(fuel,1)),u => None{})
    case Con{P113DScalar{N111Bin{+name,width,operation,value,N111Const{1,0}}},rest}:
      nt_choose(Maybe<&2,X194Select>,U32.is_gt(fuel,0) && x190_branch_width(width) &&
          Bool.not(x181_register_reserved(name)) && String.eq(operation,"xor") && x185_sf_source(value,current),
        u => x194_ps_scan(rest,typ,op,left,right,name,Bool.not(invert),Con{name,names},U32.sub(fuel,1)),u => None{})
    case _: None{}

@unsafe
def x194_ps_shape(body: List<&2,P113DStmt>) -> Maybe<&2,X194Select>:
  match body:
    case Con{P113DScalar{N111Bin{+name,+typ,+op,left,right}},rest}:
      nt_choose(Maybe<&2,X194Select>,x190_branch_width(typ) &&
          Bool.not(String.is_empty(x181_condition(op)) || x181_register_reserved(name)),
        u => x194_ps_scan(rest,typ,op,left,right,name,False{},[name],8),u => None{})
    case _: None{}

@unsafe
def x194_ps_pick(body: List<&2,P113DStmt>) -> Maybe<&2,X194Select>:
  nt_choose(Maybe<&2,X194Select>,x194_ps_enabled(),u => x194_ps_shape(body),u => None{})

@unsafe
def x194_ps_count(names: List<&2,String>, +pairs: KDef) -> KDef:
  match names:
    case Nil{}: pairs
    case Con{+name,rest}:
      +old = p111v_get(pairs,name)
      x194_ps_count(rest,p111v_put(pairs,name,"X190BranchPairs",da(old),x181_read_increment(dx(old))))

@unsafe
def x194_ps_count_pick(pick: Maybe<&2,X194Select>, pairs: KDef) -> KDef:
  match pick:
    case Some{X194Select{rest,typ,op,left,right,invert,selected,names}}: x194_ps_count(names,pairs)
    case None{}: pairs

# Every actual read of each removed local must be accounted for by one of
# these exact comparison corridors. Parameters and setup definitions refuse.
# Repeated mutable names are allowed only under that complete-use certificate.
@unsafe
def x194_ps_allowed(names: List<&2,String>, +facts: X190BranchFacts) -> Bool:
  match names facts:
    case Nil{} _: True{}
    case Con{+name,rest} X190BranchFacts{reads,writes,pairs,protected}:
      U32.is_gt(dx(p111v_get(pairs,name)),0) &&
        U32.is_eq(da(p111v_get(reads,name)),dx(p111v_get(pairs,name))) &&
        U32.is_eq(da(p111v_get(protected,name)),0) && x194_ps_allowed(rest,facts)

# CMP stays at the original producer point. All removed writes are private
# Boolean temporaries; the selected inputs are unchanged throughout the window.
# Loads of selected Local/Const values and U32 MOV truncations preserve flags.
# Reserved RAX/R10/R11 are never allocated homes. Snapshot inputs before output.
@unsafe
def x194_ps_emit(plan: X194Select, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
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
def x194_ps_step(pick: Maybe<&2,X194Select>, +body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match pick:
    case Some{+plan}:
      match plan:
        case X194Select{rest,typ,op,left,right,invert,selected,+names}:
          nt_choose(X181Code,x194_ps_allowed(names,facts),
            u => x190_stmts(rest,facts,ids,frame,x181_add(x194_ps_emit(plan,ids,frame),code)),
            u => x194_ps_previous(body,facts,ids,frame,code))
    case None{}: x194_ps_previous(body,facts,ids,frame,code)

@unsafe
def x194_ps_previous(+body: List<&2,P113DStmt>, +facts: X190BranchFacts,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  nt_choose(X181Code,x191_address_enabled() || x191_memory_alu_enabled() || x192_shared_address_enabled(),
    u => x192_shared_step(x192_shared_pick(body,facts),body,facts,ids,frame,code),
    u => x191_branch_step(body,facts,ids,frame,code))
