# Optional placement after x181_frame, before emitting either prologue or body.
# Input is a fresh stack frame: register 0 is state, registers 1..4 are unused.
# Every chosen name keeps one global callee-saved home; there is no liveness,
# register sharing, stack compaction, or change to call/tail staging.
type X181ReadCounts is Data:
  X181ReadCounts{+counts: KDef, +reversedNames: List<&2,String>}

type X181RegisterChoice is Data:
  X181RegisterChoice{+name: String, +reads: U32}

law x181_reads_scalars:
  for body: List<&2,N111Stmt>
  for counts: X181ReadCounts
  X181ReadCounts

law x181_reads_stmts:
  for body: List<&2,P113DStmt>
  for counts: X181ReadCounts
  X181ReadCounts

law x181_register_place:
  for +names: List<&2,String>
  for +counts: KDef
  for +frame: X181Frame
  for +register: U32
  X181Frame

@unsafe
def x181_register_reserved(+name: String) -> Bool:
  String.eq(name,"state") || String.eq(name,"scratch") || String.starts_with(name,"__x181")

def x181_read_increment(+count: U32) -> U32:
  nt_choose(U32,U32.is_eq(count,4294967295),u => count,u => U32.inc(count))

# The ordered list grows once per distinct name. Every subsequent read updates
# the indexed count, without searching the name list or any candidate list.
@unsafe
def x181_reads_record(+name: String, reads: X181ReadCounts) -> X181ReadCounts:
  match reads:
    case X181ReadCounts{+counts,+reversedNames}:
      +old = p111v_get(counts,name)
      +fresh = String.eq(dk(old),"Absent")
      X181ReadCounts{p111v_put(counts,name,"X181Reads",
        nt_choose(U32,fresh,u => 1,u => x181_read_increment(da(old))),0),
        nt_choose(List<&2,String>,fresh,u => Con{name,reversedNames},u => reversedNames)}

@unsafe
def x181_reads_name(+name: String, +counts: X181ReadCounts) -> X181ReadCounts:
  nt_choose(X181ReadCounts,x181_register_reserved(name),
    u => counts,u => x181_reads_record(name,counts))

@unsafe
def x181_reads_value(value: N111Value, counts: X181ReadCounts) -> X181ReadCounts:
  match value:
    case N111Local{name}: x181_reads_name(name,counts)
    case _: counts

@unsafe
def x181_reads_values(values: List<&2,N111Value>, counts: X181ReadCounts) -> X181ReadCounts:
  match values:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_values(rest,x181_reads_value(head,counts))

@unsafe
def x181_reads_args(args: List<&2,N111Arg>, counts: X181ReadCounts) -> X181ReadCounts:
  match args:
    case Nil{}: counts
    case Con{N111Arg{typ,value},rest}: x181_reads_args(rest,x181_reads_value(value,counts))

# Encounter order is source order, operands left-to-right, then condition,
# yes branch and no branch. Each syntactic read counts once, even in a loop.
@unsafe
def x181_reads_scalar(stmt: N111Stmt, counts: X181ReadCounts) -> X181ReadCounts:
  match stmt:
    case N111Set{name,typ,value}: x181_reads_value(value,counts)
    case N111Bin{name,typ,op,left,right}:
      x181_reads_value(right,x181_reads_value(left,counts))
    case N111Call{name,typ,symbol,args}: x181_reads_args(args,counts)
    case N111If{condition,yes,no}:
      x181_reads_scalars(no,x181_reads_scalars(yes,x181_reads_value(condition,counts)))
    case N111Return{value}: x181_reads_value(value,counts)
    case N111Load{name,typ,base,offset}: x181_reads_value(base,counts)
    case N111Store{typ,base,offset,value}:
      x181_reads_value(value,x181_reads_value(base,counts))
    case N111Offset{name,base,bytes}:
      x181_reads_value(bytes,x181_reads_value(base,counts))
    case N111Alloca{name,bytes,align}: counts

@unsafe
def x181_reads_scalars(body,counts):
  match body:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_scalars(rest,x181_reads_scalar(head,counts))

@unsafe
def x181_reads_stmt(stmt: P113DStmt, counts: X181ReadCounts) -> X181ReadCounts:
  match stmt:
    case P113DScalar{scalar}: x181_reads_scalar(scalar,counts)
    case P113DIf{condition,yes,no}:
      x181_reads_stmts(no,x181_reads_stmts(yes,x181_reads_value(condition,counts)))
    case P113DCall{destinations,target,args}: x181_reads_values(args,counts)
    case P113DResult{values}: x181_reads_values(values,counts)
    case P113DAgain{values}: x181_reads_values(values,counts)

@unsafe
def x181_reads_stmts(body,counts):
  match body:
    case Nil{}: counts
    case Con{head,rest}: x181_reads_stmts(rest,x181_reads_stmt(head,counts))

# A score of two is the empty choice: only three-or-more reads can replace it.
# Strict comparison leaves the earlier encountered name in place on ties.
@unsafe
def x181_register_consider(name: String, +reads: U32, slot: KDef,
  +best: X181RegisterChoice) -> X181RegisterChoice:
  match best:
    case X181RegisterChoice{oldName,oldReads}:
      nt_choose(X181RegisterChoice,U32.is_gt(reads,oldReads) && String.eq(dk(slot),"X181Stack"),
        u => X181RegisterChoice{name,reads},u => best)

@unsafe
def x181_register_best(names: List<&2,String>, +counts: KDef, +slots: KDef,
  best: X181RegisterChoice) -> X181RegisterChoice:
  match names:
    case Nil{}: best
    case Con{+name,rest}:
      x181_register_best(rest,counts,slots,
        x181_register_consider(name,da(p111v_get(counts,name)),p111v_get(slots,name),best))

# Preserve the slot payload exactly apart from kind and physical location.
@unsafe
def x181_register_slot(+slot: KDef, register: U32) -> KDef:
  match slot:
    case KDef{name,kind,arity,bytes,typ,value,children,native,uns}:
      KDef{name,"X181Register",register,bytes,typ,value,children,native,uns}
    case _: slot

@unsafe
def x181_register_install(+name: String, register: U32, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{index_set(slots,x181_register_slot(p111v_get(slots,name),register),
        index_hash(name,2166136261),32),bytes,calls,params,symbol}

@unsafe
def x181_register_chosen(names: List<&2,String>, counts: KDef, +frame: X181Frame,
  +register: U32, choice: X181RegisterChoice) -> X181Frame:
  match choice:
    case X181RegisterChoice{name,reads}:
      nt_choose(X181Frame,U32.is_ge(reads,3),
        u => x181_register_place(names,counts,x181_register_install(name,register,frame),U32.inc(register)),
        u => frame)

# At most four scans of distinct names. Once promoted, a slot is not Stack,
# so subsequent scans cannot select it again. No scan occurs per read.
@unsafe
def x181_register_place(names,counts,frame,register):
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      nt_choose(X181Frame,U32.is_gt(register,4),u => frame,
        u => x181_register_chosen(names,counts,frame,register,
          x181_register_best(names,counts,slots,X181RegisterChoice{"",2})))

@unsafe
def x181_register_counted(frame: X181Frame, reads: X181ReadCounts) -> X181Frame:
  match reads:
    case X181ReadCounts{counts,reversedNames}:
      x181_register_place(nt_reverse(String,reversedNames,[]),counts,frame,1)

@unsafe
def x181_register_frame(frame: X181Frame, body: List<&2,P113DStmt>) -> X181Frame:
  x181_register_counted(frame,x181_reads_stmts(body,X181ReadCounts{missing(),[]}))
