# Ordinary argument loads have no scratch side effects: each reads a home or
# materializes one constant/ID/address into its destination. Callee/stack/buffer
# homes are disjoint from ABI argument registers. Custom transient-source calls
# instead snapshot every value before writing any ABI register or stack arg.
# The maintained frame reserves 16 bytes per argument. Its upper half holds
# snapshots; the lower half holds outgoing stack arguments. Both are below all
# rbp-relative locals. No new allocation, spill or call ABI is introduced.

type X186CallPlan is Data:
  X186CallPlan{+kind: U32, +count: U32}

def x186_call_arguments_enabled() -> Bool: True{}

def x186_call_reg32(index: U32) -> String:
  match index:
    case 0: "%edi"
    case 1: "%esi"
    case 2: "%edx"
    case 3: "%ecx"
    case 4: "%r8d"
    case _: "%r9d"

@unsafe
def x186_call_mask(typ: N111Type, +reg: String) -> String:
  match typ:
    case N111U32{}: "  movl " ++ reg ++ ", " ++ reg ++ "\n"
    case _: ""

# kind 0 refuses a malformed placement, 1 uses direct loads, 2 snapshots.
@unsafe
def x186_call_slot(+slot: KDef, +bytes: U32) -> U32:
  nt_choose(U32,String.eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) &&
      U32.is_le(da(slot),bytes) && U32.is_eq(dx(slot),8),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X181Buffer") && U32.is_gt(da(slot),40) &&
      U32.is_le(da(slot),bytes) && U32.is_gt(dx(slot),0) &&
      U32.is_le(dx(slot),U32.sub(da(slot),40)),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X181Register") && U32.is_lt(da(slot),5),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5),u => 2,u => 0))))

@unsafe
def x186_call_value(value: N111Value, +slots: KDef, +bytes: U32) -> U32:
  match value:
    case N111Local{name}: x186_call_slot(p111v_get(slots,name),bytes)
    case _: 1

@unsafe
def x186_call_scan(args: List<&2,N111Arg>, +slots: KDef, +bytes: U32,
    +count: U32, +kind: U32) -> X186CallPlan:
  match args:
    case Nil{}: X186CallPlan{kind,count}
    case Con{N111Arg{typ,value},rest}:
      +value_kind = x186_call_value(value,slots,bytes)
      nt_choose(X186CallPlan,U32.is_ge(count,512),u => X186CallPlan{0,513},u =>
        nt_choose(X186CallPlan,U32.is_eq(value_kind,0),v => X186CallPlan{0,0},v =>
          x186_call_scan(rest,slots,bytes,U32.inc(count),U32.max(kind,value_kind))))

@unsafe
def x186_call_capacity(plan: X186CallPlan, +bytes: U32, +calls: U32) -> X186CallPlan:
  match plan:
    case X186CallPlan{kind,+count}:
      nt_choose(X186CallPlan,U32.is_ge(bytes,40) && U32.is_le(calls,2147483000) &&
          U32.is_le(bytes,U32.sub(2147483583,calls)) && U32.is_ge(calls,U32.mul(count,16)),
        u => X186CallPlan{kind,count},u => X186CallPlan{0,count})

@unsafe
def x186_call_plan(args: List<&2,N111Arg>, frame: X181Frame) -> X186CallPlan:
  match frame:
    case X181Frame{slots,+bytes,+calls,params,symbol}:
      x186_call_capacity(x186_call_scan(args,slots,bytes,0,1),bytes,calls)

@unsafe
def x186_call_direct(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{+typ,+value},rest}:
      nt_choose(String,U32.is_lt(index,6),
        u => x181_load(value,ids,frame,x181_argreg(index)) ++ x186_call_mask(typ,x186_call_reg32(index)),
        u => x181_load(value,ids,frame,"%r10") ++ x186_call_mask(typ,"%r10d") ++
          "  movq %r10, " ++ U32.show(U32.mul(U32.sub(index,6),8)) ++ "(%rsp)\n") ++
      x186_call_direct(rest,ids,frame,U32.inc(index))

@unsafe
def x186_call_snapshot(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame,
    +base: U32, +index: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{typ,value},rest}:
      x181_load(value,ids,frame,"%r10") ++ x186_call_mask(typ,"%r10d") ++
        "  movq %r10, " ++ U32.show(U32.add(base,U32.mul(index,8))) ++ "(%rsp)\n" ++
      x186_call_snapshot(rest,ids,frame,base,U32.inc(index))

@unsafe
def x186_call_place(+count: U32, +base: U32, +index: U32) -> String:
  nt_choose(String,U32.is_eq(index,count),u => "",u =>
    nt_choose(String,U32.is_lt(index,6),
      v => "  movq " ++ U32.show(U32.add(base,U32.mul(index,8))) ++ "(%rsp), " ++ x181_argreg(index) ++ "\n",
      v => "  movq " ++ U32.show(U32.add(base,U32.mul(index,8))) ++ "(%rsp), %r10\n" ++
        "  movq %r10, " ++ U32.show(U32.mul(U32.sub(index,6),8)) ++ "(%rsp)\n") ++
    x186_call_place(count,base,U32.inc(index)))

@unsafe
def x186_call_selected(+enabled: Bool, +args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, plan: X186CallPlan) -> String:
  match plan:
    case X186CallPlan{+kind,+count}:
      nt_choose(String,U32.is_eq(kind,0),u => ".error \"x186: invalid call argument frame\"\n",u =>
        nt_choose(String,enabled && U32.is_eq(kind,1),u => x186_call_direct(args,ids,frame,0),
          u => x186_call_snapshot(args,ids,frame,U32.mul(count,8),0) ++
            x186_call_place(count,U32.mul(count,8),0)))

@unsafe
def x186_call_arguments(+args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> String:
  x186_call_selected(x186_call_arguments_enabled(),args,ids,frame,x186_call_plan(args,frame))
