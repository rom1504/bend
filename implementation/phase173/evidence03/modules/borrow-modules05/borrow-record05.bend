# Phase173: postverification whole record-update regions.
# Experimental only. Original P113D IR and its final verifier remain unchanged.
type P173BOrigin is Data:
  P173BField{+index: U32}
  P173BExternal{+value: N111Value}
  P173BInvalid{}

type P173BBinding is Data:
  P173BBinding{+name: String, +origin: P173BOrigin}

type P173BSlot is Data:
  P173BSlot{+index: U32, +origin: P173BOrigin}

type P173BPlan is Data:
  P173BNone{}
  P173BPlan{+root: N111Value, +ctor: String, +width: U32,
    +slots: List<&2,P173BSlot>, +drops: List<&2,U32>}

law p173b_scan:
  for +body: List<&2,P113DStmt>
  for +root: N111Value
  for +buffer: String
  for +width: U32
  for +env: List<&2,P173BBinding>
  for +slots: List<&2,P173BSlot>
  for +drops: List<&2,U32>
  for +ids: N111Ids
  for +fuel: U32
  P173BPlan

law p173b_sink:
  for +rest: List<&2,P113DStmt>
  for +root: N111Value
  for +buffer: String
  for +width: U32
  for +env: List<&2,P173BBinding>
  for +slots: List<&2,P173BSlot>
  for +drops: List<&2,U32>
  for +ids: N111Ids
  for +fuel: U32
  for +name: String
  for origin: P173BOrigin
  P173BPlan

@unsafe
def p173b_has(+needle: U32, values: List<&2,U32>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{value,rest}: U32.is_eq(needle,value) || p173b_has(needle,rest)

@unsafe
def p173b_bound(+name: String, env: List<&2,P173BBinding>) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{P173BBinding{key,origin},rest}: String.eq(name,key) || p173b_bound(name,rest)

@unsafe
def p173b_local(+name: String, env: List<&2,P173BBinding>) -> P173BOrigin:
  match env:
    case Nil{}: P173BExternal{N111Local{name}}
    case Con{P173BBinding{key,+origin},rest}:
      nt_choose(P173BOrigin,String.eq(name,key),u => origin,u => p173b_local(name,rest))

@unsafe
def p173b_origin(value: N111Value, env: List<&2,P173BBinding>) -> P173BOrigin:
  match value:
    case N111Local{name}: p173b_local(name,env)
    case N111Const{lo,hi}: P173BExternal{value}
    case _: P173BInvalid{}

@unsafe
def p173b_slot(+index: U32, slots: List<&2,P173BSlot>) -> P173BOrigin:
  match slots:
    case Nil{}: P173BInvalid{}
    case Con{P173BSlot{at,+origin},rest}:
      nt_choose(P173BOrigin,U32.is_eq(index,at),u => origin,u => p173b_slot(index,rest))

@unsafe
def p173b_slot_used(+index: U32, slots: List<&2,P173BSlot>) -> Bool:
  match slots:
    case Nil{}: False{}
    case Con{P173BSlot{at,origin},rest}: U32.is_eq(index,at) || p173b_slot_used(index,rest)

@unsafe
def p173b_external_ok(+value: N111Value, +root: N111Value,
  env: List<&2,P173BBinding>) -> Bool:
  match value:
    case N111Local{+name}:
      Bool.not(p134v_value(value,root) || p173b_bound(name,env) || String.eq(name,"state") || String.eq(name,"scratch"))
    case N111Const{lo,hi}: True{}
    case _: False{}

# Legality is structural; zero changed fields is legal but unprofitable.
# A replaced field without an explicit sink must dynamically prove trivial.
@unsafe
def p173b_slots_ok(slots: List<&2,P173BSlot>, +root: N111Value,
  +env: List<&2,P173BBinding>, +drops: List<&2,U32>) -> Bool:
  match slots:
    case Nil{}: True{}
    case Con{P173BSlot{+index,origin},rest}:
      match origin:
        case P173BField{old}:
          U32.is_eq(index,old) && Bool.not(p173b_has(index,drops)) && p173b_slots_ok(rest,root,env,drops)
        case P173BExternal{value}:
          p173b_external_ok(value,root,env) && p173b_slots_ok(rest,root,env,drops)
        case P173BInvalid{}: False{}

@unsafe
def p173b_finish(+rest: List<&2,P113DStmt>, +dest: String, +ctor: String,
  +root: N111Value, +width: U32, +env: List<&2,P173BBinding>,
  +slots: List<&2,P173BSlot>, +drops: List<&2,U32>, +ids: N111Ids) -> P173BPlan:
  match rest:
    case Con{P113DResult{Con{N111Local{name},Nil{}}},Nil{}}:
      nt_choose(P173BPlan,String.eq(dest,name) && U32.is_eq(nt_count(P173BSlot,slots),width) &&
        p128bf_known(ctor,width,ids) && p173b_slots_ok(slots,root,env,drops),
        u => P173BPlan{root,ctor,width,slots,nt_reverse(U32,drops,[])},u => P173BNone{})
    case _: P173BNone{}

@unsafe
def p173b_name_ok(+name: String, +root: N111Value, +buffer: String) -> Bool:
  Bool.not(p134v_value(N111Local{name},root) || String.eq(name,buffer) || String.eq(name,"state"))

@unsafe
def p173b_step(+body: List<&2,P113DStmt>, +root: N111Value, +buffer: String,
  +width: U32, +env: List<&2,P173BBinding>, +slots: List<&2,P173BSlot>,
  +drops: List<&2,U32>, +ids: N111Ids, +fuel: U32) -> P173BPlan:
  match body:
    case Con{P113DScalar{N111Load{+name,N111U64{},N111Local{from},+offset}},+rest}:
      nt_choose(P173BPlan,String.eq(from,buffer) && U32.is_eq(U32.mod(offset,8),0) &&
        U32.is_lt(U32.div(offset,8),width) && List.is_empty(&2,P173BSlot,slots) &&
        p173b_name_ok(name,root,buffer) && Bool.not(p173b_bound(name,env)),
        u => p173b_scan(rest,root,buffer,width,Con{P173BBinding{name,P173BField{U32.div(offset,8)}},env},slots,drops,ids,fuel),u => P173BNone{})
    case Con{P113DScalar{N111Set{+name,N111U64{},+value}},+rest}:
      nt_choose(P173BPlan,p173b_name_ok(name,root,buffer) && Bool.not(p173b_bound(name,env)),
        u => p173b_scan(rest,root,buffer,width,Con{P173BBinding{name,p173b_origin(value,env)},env},slots,drops,ids,fuel),u => P173BNone{})
    case Con{P113DScalar{N111Store{N111U64{},N111Local{to},+offset,+value}},+rest}:
      nt_choose(P173BPlan,String.eq(to,buffer) && U32.is_eq(U32.mod(offset,8),0) &&
        U32.is_lt(U32.div(offset,8),width) && Bool.not(p173b_slot_used(U32.div(offset,8),slots)),
        u => p173b_scan(rest,root,buffer,width,env,Con{P173BSlot{U32.div(offset,8),p173b_origin(value,env)},slots},drops,ids,fuel),u => P173BNone{})
    case Con{P113DScalar{N111Call{+name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U64{},+value},Nil{}}}}},+rest}:
      nt_choose(P173BPlan,String.eq(symbol,"p111_rt_sink") && String.eq(state,"state") &&
        p173b_name_ok(name,root,buffer) && List.is_empty(&2,P173BSlot,slots),u =>
        p173b_sink(rest,root,buffer,width,env,slots,drops,ids,fuel,name,p173b_origin(value,env)),u => P173BNone{})
    case Con{P113DScalar{N111Call{+dest,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U32{},N111CtorId{+ctor}},
      Con{N111Arg{N111Ptr{},N111Local{from}},
      Con{N111Arg{N111U32{},N111Const{count,0}},Nil{}}}}}}},+rest}:
      nt_choose(P173BPlan,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") &&
        String.eq(from,buffer) && U32.is_eq(count,width),
        u => p173b_finish(rest,dest,ctor,root,width,env,slots,drops,ids),u => P173BNone{})
    case _: P173BNone{}

@unsafe
def p173b_sink(rest, root, buffer, width, env, slots, drops, ids, fuel, name, origin):
  match origin:
    case P173BField{+index}:
      nt_choose(P173BPlan,Bool.not(p173b_has(index,drops)),
        u => p173b_scan(rest,root,buffer,width,Con{P173BBinding{name,P173BInvalid{}},env},slots,Con{index,drops},ids,fuel),u => P173BNone{})
    case _: P173BNone{}

@unsafe
def p173b_scan(body, root, buffer, width, env, slots, drops, ids, fuel):
  nt_choose(P173BPlan,U32.is_gt(fuel,0),
    u => p173b_step(body,root,buffer,width,env,slots,drops,ids,U32.sub(fuel,1)),u => P173BNone{})

@unsafe
def p173b_plan(+body: List<&2,P113DStmt>, +ids: N111Ids) -> P173BPlan:
  match body:
    case Con{P113DScalar{N111Call{+name,N111U64{},symbol,
      Con{N111Arg{N111Ptr{},N111Local{state}},
      Con{N111Arg{N111U64{},+root},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+width,0}},Nil{}}}}}}},+rest}:
      nt_choose(P173BPlan,String.eq(symbol,"p111_rt_take") && String.eq(state,"state") &&
        U32.is_ge(width,2) && U32.is_le(width,16) && p114t_buffer(buffer) && p173b_name_ok(name,root,buffer),
        u => p173b_scan(rest,root,buffer,width,[P173BBinding{name,P173BInvalid{}}],[],[],ids,256),u => P173BNone{})
    case _: P173BNone{}

@unsafe
def p173b_changed(slots: List<&2,P173BSlot>) -> U32:
  match slots:
    case Nil{}: 0
    case Con{P173BSlot{index,origin},rest}:
      match origin:
        case P173BExternal{value}: U32.inc(p173b_changed(rest))
        case _: p173b_changed(rest)

# Revision05 profitability ablation: admit every legal nonempty update.
# All structural admission, alias/drop guards and emission remain unchanged.
@unsafe
def p173b_profitable(plan: P173BPlan) -> Bool:
  match plan:
    case P173BPlan{root,ctor,+width,slots,drops}:
      +changed = p173b_changed(slots)
      U32.is_gt(changed,0)
    case P173BNone{}: False{}
