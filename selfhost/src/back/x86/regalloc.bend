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

# Whole-body stable copies. Parameters count as definitions, so a parameter
# source is stable only with zero explicit assignments. Every branch and call
# result contributes; two writes saturate the counter and forbid an alias.
# Setup is counted but never rewritten: its entry snapshots must survive Again.
def x185_copy_enabled() -> Bool: True{}

@unsafe
def x185_copy_write(+name: String, +counts: KDef) -> KDef:
  p111v_put(counts,name,"X185Writes",U32.min(2,U32.inc(da(p111v_get(counts,name)))),0)

@unsafe
def x185_copy_writes_names(names: List<&2,String>, counts: KDef) -> KDef:
  match names:
    case Nil{}: counts
    case Con{name,rest}: x185_copy_writes_names(rest,x185_copy_write(name,counts))

@unsafe
def x185_copy_writes_scalar(stmt: N111Stmt, counts: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: x185_copy_write(name,counts)
    case N111Bin{name,typ,op,left,right}: x185_copy_write(name,counts)
    case N111Call{name,typ,symbol,args}: x185_copy_write(name,counts)
    case N111If{condition,yes,no}: x185_copy_writes_scalars(no,x185_copy_writes_scalars(yes,counts))
    case N111Load{name,typ,base,offset}: x185_copy_write(name,counts)
    case N111Offset{name,base,bytes}: x185_copy_write(name,counts)
    case N111Alloca{name,bytes,align}: x185_copy_write(name,counts)
    case _: counts

@unsafe
def x185_copy_writes_scalars(body: List<&2,N111Stmt>, counts: KDef) -> KDef:
  match body:
    case Nil{}: counts
    case Con{head,rest}: x185_copy_writes_scalars(rest,x185_copy_writes_scalar(head,counts))

@unsafe
def x185_copy_writes(body: List<&2,P113DStmt>, counts: KDef) -> KDef:
  match body:
    case Nil{}: counts
    case Con{P113DScalar{stmt},rest}: x185_copy_writes(rest,x185_copy_writes_scalar(stmt,counts))
    case Con{P113DIf{condition,yes,no},rest}: x185_copy_writes(rest,x185_copy_writes(no,x185_copy_writes(yes,counts)))
    case Con{P113DCall{destinations,target,args},rest}: x185_copy_writes(rest,x185_copy_writes_names(destinations,counts))
    case Con{head,rest}: x185_copy_writes(rest,counts)

@unsafe
def x185_copy_name(+name: String, +aliases: KDef) -> String:
  +entry = p111v_get(aliases,name)
  nt_choose(String,String.eq(dk(entry),"X185Alias"),u => nm(dv(entry)),u => name)

# The unchanged verifier requires each local definition before its reads.
# Unique definitions therefore dominate their copies; prior aliases already
# point to their canonical source. A single lookup suffices, with no recursive
# traversal or aliases to mutable homes. U32 copies retain their truncation.
@unsafe
def x185_copy_record(+name: String, +typ: N111Type, +source: String, +counts: KDef,
    +params: List<&2,String>, +aliases: KDef) -> KDef:
  nt_choose(KDef,Bool.not(U32.is_eq(p111v_type(typ),1)) && Bool.not(String.eq(name,source)) &&
      Bool.not(nb_contains(params,name)) && U32.is_eq(da(p111v_get(counts,name)),1) &&
      U32.is_eq(da(p111v_get(counts,source)),1),
    u => index_set(aliases,KDef{name,"X185Alias",0,0,atom("Absent"),
      kt("X185Local",x185_copy_name(source,aliases),0,0,[]),[],False{},False{}},index_hash(name,2166136261),32),
    u => aliases)

@unsafe
def x185_copy_alias_scalar(stmt: N111Stmt, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,N111Local{source}}: x185_copy_record(name,typ,source,counts,params,aliases)
    case N111If{condition,yes,no}: x185_copy_alias_scalars(no,counts,params,x185_copy_alias_scalars(yes,counts,params,aliases))
    case _: aliases

@unsafe
def x185_copy_alias_scalars(body: List<&2,N111Stmt>, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match body:
    case Nil{}: aliases
    case Con{head,rest}: x185_copy_alias_scalars(rest,counts,params,x185_copy_alias_scalar(head,counts,params,aliases))

@unsafe
def x185_copy_aliases(body: List<&2,P113DStmt>, +counts: KDef, +params: List<&2,String>, aliases: KDef) -> KDef:
  match body:
    case Nil{}: aliases
    case Con{P113DScalar{stmt},rest}: x185_copy_aliases(rest,counts,params,x185_copy_alias_scalar(stmt,counts,params,aliases))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_copy_aliases(rest,counts,params,x185_copy_aliases(no,counts,params,x185_copy_aliases(yes,counts,params,aliases)))
    case Con{head,rest}: x185_copy_aliases(rest,counts,params,aliases)

@unsafe
def x185_copy_value(value: N111Value, aliases: KDef) -> N111Value:
  match value:
    case N111Local{name}: N111Local{x185_copy_name(name,aliases)}
    case _: value

@unsafe
def x185_copy_values(values: List<&2,N111Value>, +aliases: KDef) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{x185_copy_value(head,aliases),x185_copy_values(rest,aliases)}

@unsafe
def x185_copy_args(args: List<&2,N111Arg>, +aliases: KDef) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,x185_copy_value(value,aliases)},x185_copy_args(rest,aliases)}

@unsafe
def x185_copy_scalar(stmt: N111Stmt, +aliases: KDef) -> List<&2,N111Stmt>:
  match stmt:
    case N111Set{+name,typ,value}:
      nt_choose(List<&2,N111Stmt>,String.eq(dk(p111v_get(aliases,name)),"X185Alias"),u => [],
        u => [N111Set{name,typ,x185_copy_value(value,aliases)}])
    case N111Bin{name,typ,op,left,right}: [N111Bin{name,typ,op,x185_copy_value(left,aliases),x185_copy_value(right,aliases)}]
    case N111Call{name,typ,symbol,args}: [N111Call{name,typ,symbol,x185_copy_args(args,aliases)}]
    case N111If{condition,yes,no}: [N111If{x185_copy_value(condition,aliases),x185_copy_scalars(yes,aliases),x185_copy_scalars(no,aliases)}]
    case N111Return{value}: [N111Return{x185_copy_value(value,aliases)}]
    case N111Load{name,typ,base,offset}: [N111Load{name,typ,x185_copy_value(base,aliases),offset}]
    case N111Store{typ,base,offset,value}: [N111Store{typ,x185_copy_value(base,aliases),offset,x185_copy_value(value,aliases)}]
    case N111Offset{name,base,bytes}: [N111Offset{name,x185_copy_value(base,aliases),x185_copy_value(bytes,aliases)}]
    case N111Alloca{name,bytes,align}: [N111Alloca{name,bytes,align}]

@unsafe
def x185_copy_scalars(body: List<&2,N111Stmt>, +aliases: KDef) -> List<&2,N111Stmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: nt_append(N111Stmt,x185_copy_scalar(head,aliases),x185_copy_scalars(rest,aliases))

@unsafe
def x185_copy_body(body: List<&2,P113DStmt>, +aliases: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DScalar{stmt},rest}: nt_append(P113DStmt,x181_scalar_rows(x185_copy_scalar(stmt,aliases)),x185_copy_body(rest,aliases))
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{x185_copy_value(condition,aliases),x185_copy_body(yes,aliases),x185_copy_body(no,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DCall{destinations,target,args},rest}:
      Con{P113DCall{destinations,target,x185_copy_values(args,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DResult{values},rest}: Con{P113DResult{x185_copy_values(values,aliases)},x185_copy_body(rest,aliases)}
    case Con{P113DAgain{values},rest}: Con{P113DAgain{x185_copy_values(values,aliases)},x185_copy_body(rest,aliases)}

@unsafe
def x185_copy_function(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_copy_body(body,x185_copy_aliases(body,
      x185_copy_writes(body,x185_copy_writes(setup,x185_copy_writes_names(params,missing()))),params,missing())),
    u => body)

# Reuse the established word-width/constant facts after aliases have gone.
# Facts start empty at the loop body: entry-only setup facts must not assert
# properties of parameters changed by Again. The second copy pass removes
# identities introduced by the existing simplifier, under the same restrictions.
def x185_fact_enabled() -> Bool: True{}

def x185_fact_result(scan: P113KBody) -> List<&2,P113DStmt>:
  match scan:
    case P113KBody{body,facts,terminal}: body

# p113k is a private-body pass: scalar Return is outside its terminal model.
# Public segments can contain Return in either branch form and must retain the
# original statement sequence instead of using that private-only simplifier.
@unsafe
def x185_fact_scalar_returns(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Return{value},rest}: True{}
    case Con{N111If{condition,yes,no},rest}:
      x185_fact_scalar_returns(yes) || x185_fact_scalar_returns(no) || x185_fact_scalar_returns(rest)
    case Con{head,rest}: x185_fact_scalar_returns(rest)

@unsafe
def x185_fact_returns(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{stmt},rest}: x185_fact_scalar_returns([stmt]) || x185_fact_returns(rest)
    case Con{P113DIf{condition,yes,no},rest}: x185_fact_returns(yes) || x185_fact_returns(no) || x185_fact_returns(rest)
    case Con{head,rest}: x185_fact_returns(rest)

@unsafe
def x185_fact_body(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x185_fact_enabled() && U32.is_lt(p113i_size(body),4096) && Bool.not(x185_fact_returns(body)),
    u => x185_fact_result(p113k_body(body,missing())),u => body)

@unsafe
def x185_prepare_body(+params: List<&2,String>, +setup: List<&2,P113DStmt>, body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  x185_dead_body(setup,x185_copy_function(params,setup,x185_fact_body(x185_copy_function(params,setup,body))))
