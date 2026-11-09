# Scalar selection reserves r10/r11/rax/rcx as scratch. Frame variables have
# 64-bit homes; each U32 producer clears the upper half before publication.

@unsafe
def x181_width(typ: N111Type, wide: String, narrow: String) -> String:
  match typ:
    case N111U32{}: narrow
    case _: wide

@unsafe
def x181_mask(typ: N111Type, +reg32: String) -> String:
  match typ:
    case N111U32{}: "  movl " ++ reg32 ++ ", " ++ reg32 ++ "\n"
    case _: ""

@unsafe
def x181_load_slot(+slot: KDef, +reg: String) -> String:
  nt_choose(String,String.eq(dk(slot),"X181Stack"),
    u => "  movq -" ++ U32.show(da(slot)) ++ "(%rbp), " ++ reg ++ "\n",u =>
  nt_choose(String,String.eq(dk(slot),"X181Buffer"),
    u => "  leaq -" ++ U32.show(da(slot)) ++ "(%rbp), " ++ reg ++ "\n",u =>
  nt_choose(String,String.eq(dk(slot),"X181Register"),
    u => "  movq " ++ x181_reg(da(slot)) ++ ", " ++ reg ++ "\n",
    u => nt_choose(String,String.eq(dk(slot),"X185Transient"),
      v => "  movq " ++ x185_transient_reg(da(slot)) ++ ", " ++ reg ++ "\n",
      v => ".error \"x181: missing local slot\"\n"))))

@unsafe
def x181_local_load(+name: String, frame: X181Frame, reg: String) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x181_load_slot(index_find(slots,name,index_hash(name,2166136261),32),reg)

@unsafe
def x181_function_id(ids: N111Ids, name: String, reg: String) -> String:
  match ids:
    case N111Ids{functions,constructors}:
      "  movabsq $" ++ p111q_id(functions,name) ++ ", " ++ reg ++ "\n"

@unsafe
def x181_constructor_id(ids: N111Ids, name: String, reg: String) -> String:
  match ids:
    case N111Ids{functions,constructors}:
      "  movabsq $" ++ p111q_id(constructors,name) ++ ", " ++ reg ++ "\n"

@unsafe
def x181_load(value,ids,frame,reg):
  match value:
    case N111Local{name}: x181_local_load(name,frame,reg)
    case N111Const{lo,hi}: "  movabsq $" ++ p111q_u64(lo,hi) ++ ", " ++ reg ++ "\n"
    case N111Symbol{name}: "  leaq " ++ name ++ "(%rip), " ++ reg ++ "\n"
    case N111FuncId{name}: x181_function_id(ids,name,reg)
    case N111CtorId{name}: x181_constructor_id(ids,name,reg)

@unsafe
def x181_store_slot(+slot: KDef, +reg: String) -> String:
  nt_choose(String,String.eq(dk(slot),"X181Stack"),
    u => "  movq " ++ reg ++ ", -" ++ U32.show(da(slot)) ++ "(%rbp)\n",u =>
  nt_choose(String,String.eq(dk(slot),"X181Register"),
    u => "  movq " ++ reg ++ ", " ++ x181_reg(da(slot)) ++ "\n",
    u => nt_choose(String,String.eq(dk(slot),"X185Transient"),
      v => "  movq " ++ reg ++ ", " ++ x185_transient_reg(da(slot)) ++ "\n",
      v => ".error \"x181: invalid destination slot\"\n")))

@unsafe
def x181_store(name,frame,reg):
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x181_store_slot(index_find(slots,name,index_hash(name,2166136261),32),reg)

@unsafe
def x181_condition(+op: String) -> String:
  nt_choose(String,String.eq(op,"eq"),u => "e",u =>
  nt_choose(String,String.eq(op,"ne"),u => "ne",u =>
  nt_choose(String,String.eq(op,"ult"),u => "b",u =>
  nt_choose(String,String.eq(op,"ule"),u => "be",u =>
  nt_choose(String,String.eq(op,"ugt"),u => "a",u =>
  nt_choose(String,String.eq(op,"uge"),u => "ae",u =>
  nt_choose(String,String.eq(op,"slt"),u => "l",u =>
  nt_choose(String,String.eq(op,"sle"),u => "le",u =>
  nt_choose(String,String.eq(op,"sgt"),u => "g",u =>
  nt_choose(String,String.eq(op,"sge"),u => "ge",u => ""))))))))))

@unsafe
def x181_shift(+op: String) -> Bool:
  String.eq(op,"shl") || String.eq(op,"shr") || String.eq(op,"sar")

@unsafe
def x181_alu(+op: String) -> String:
  nt_choose(String,String.eq(op,"mul"),u => "imul",u =>
    nt_choose(String,String.eq(op,"add") || String.eq(op,"sub") ||
      String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor") || x181_shift(op),
      u => op,u => ""))

@unsafe
def x181_bin_instruction(+typ: N111Type, +op: String) -> String:
  +suffix = x181_width(typ,"q","l")
  +left = x181_width(typ,"%r10","%r10d")
  +right = x181_width(typ,"%r11","%r11d")
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(String,Bool.not(String.is_empty(condition)),
    u => "  cmp" ++ suffix ++ " " ++ right ++ ", " ++ left ++ "\n  set" ++ condition ++
      " %r10b\n  movzbl %r10b, %r10d\n",u =>
    nt_choose(String,String.is_empty(alu),u => "",u =>
      nt_choose(String,x181_shift(op),
        v => "  movl %r11d, %ecx\n  " ++ alu ++ suffix ++ " %cl, " ++ left ++ "\n",
        v => "  " ++ alu ++ suffix ++ " " ++ right ++ ", " ++ left ++ "\n")))

def x185_machine_enabled() -> Bool: True{}

# Immediate forms keep the original operand width and comparison signedness.
# A 64-bit arithmetic immediate must fit signed32; larger values stay on the
# original materialization path. Shift immediates use the same x86 count mask.
@unsafe
def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> String:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x181_width(typ,"%r10","%r10d")
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(String,x181_shift(op),
        u => "  " ++ alu ++ suffix ++ " $" ++ U32.show(U32.mod(lo,
          nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64))) ++ ", " ++ left ++ "\n",u =>
      nt_choose(String,String.eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => "  movl %r10d, %r10d\n",u =>
      nt_choose(String,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(String,Bool.not(String.is_empty(condition)),
          v => "  cmp" ++ suffix ++ " $" ++ U32.show(lo) ++ ", " ++ left ++ "\n  set" ++ condition ++
            " %r10b\n  movzbl %r10b, %r10d\n",
          v => nt_choose(String,String.is_empty(alu),w => "",
            w => "  " ++ alu ++ suffix ++ " $" ++ U32.show(lo) ++ ", " ++ left ++ "\n")),u => "")))
    case _: ""

@unsafe
def x181_binary(+name: String, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +ids: N111Ids,
    +frame: X181Frame, +code: X181Code) -> X181Code:
  +instruction = x181_bin_instruction(typ,op)
  +immediate = nt_choose(String,x185_machine_enabled(),u => x185_immediate(typ,op,right),u => "")
  +physical = x185_physical_binary(name,typ,op,left,right,ids,frame)
  nt_choose(X181Code,String.is_empty(instruction),
    u => x181_error("unsupported x181 binary operation: " ++ op,code),
    u => nt_choose(X181Code,Bool.not(String.is_empty(physical)),v => x181_add(physical,code),
      v => x181_add(x181_load(left,ids,frame,"%r10") ++
        nt_choose(String,String.is_empty(immediate),
          w => x181_load(right,ids,frame,"%r11") ++ instruction,w => immediate) ++ x181_store(name,frame,"%r10"),code)))

# Call argument homes are rbp-relative stack/buffer slots or callee-saved
# registers. Transient placement excludes every call-argument local globally,
# so these sources are disjoint from ABI registers and the outgoing rsp area.
# Loading an N111Value only reads one such home or materializes a constant,
# ID or symbol, so placing one argument cannot overwrite a later source.
# Keep r10 as the only scratch and preserve U32 truncation before placement.
# Again updates parameter homes and still requires its separate snapshot.
@unsafe
def x181_call_arguments(args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, +n: U32) -> String:
  match args:
    case Nil{}: ""
    case Con{N111Arg{typ,value},rest}:
      x181_load(value,ids,frame,"%r10") ++ x181_mask(typ,"%r10d") ++
      nt_choose(String,U32.is_lt(n,6),
        u => "  movq %r10, " ++ x181_argreg(n) ++ "\n",
        u => "  movq %r10, " ++
          U32.show(U32.mul(U32.sub(n,6),8)) ++ "(%rsp)\n") ++
        x181_call_arguments(rest,ids,frame,U32.inc(n))

@unsafe
def x181_call_text(symbol,args,ids,frame):
  x186_call_arguments(args,ids,frame) ++ "  xorl %eax, %eax\n  call " ++ symbol ++ "\n"

# Materialize an unsigned byte offset explicitly; x86 memory displacements are
# signed 32-bit values, while N111Load/Store offsets are U32.
@unsafe
def x181_address(base: N111Value, +offset: U32, ids: N111Ids, frame: X181Frame) -> String:
  x181_load(base,ids,frame,"%r10") ++
    nt_choose(String,U32.is_eq(offset,0),u => "",
      u => "  movabsq $" ++ U32.show(offset) ++ ", %r11\n  addq %r11, %r10\n")

@unsafe
def x185_load_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame) -> String:
  nt_choose(String,x185_machine_enabled() && U32.is_le(offset,2147483647),
    u => x181_load(base,ids,frame,"%r10") ++
      x181_width(typ,"  movq ","  movl ") ++ U32.show(offset) ++
      x181_width(typ,"(%r10), %r10\n","(%r10), %r10d\n"),
    u => x181_address(base,offset,ids,frame) ++
      x181_width(typ,"  movq (%r10), %r10\n","  movl (%r10), %r10d\n")) ++ x181_store(name,frame,"%r10")

@unsafe
def x185_store_memory(+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> String:
  nt_choose(String,x185_machine_enabled() && U32.is_le(offset,2147483647),
    u => x181_load(base,ids,frame,"%r10") ++ x181_load(value,ids,frame,"%r11") ++
      x181_width(typ,"  movq %r11, ","  movl %r11d, ") ++ U32.show(offset) ++ "(%r10)\n",
    u => x181_address(base,offset,ids,frame) ++ x181_load(value,ids,frame,"%r11") ++
      x181_width(typ,"  movq %r11, (%r10)\n","  movl %r11d, (%r10)\n"))

law x181_scalar_rows:
  for +rows: List<&2,N111Stmt>
  List<&2,P113DStmt>

@unsafe
def x181_scalar_row(stmt: N111Stmt) -> P113DStmt:
  match stmt:
    case N111If{condition,yes,no}: P113DIf{condition,x181_scalar_rows(yes),x181_scalar_rows(no)}
    case _: P113DScalar{stmt}

@unsafe
def x181_scalar_rows(rows):
  match rows:
    case Nil{}: []
    case Con{head,rest}: Con{x181_scalar_row(head),x181_scalar_rows(rest)}

# Existing late runtime templates expressed as the same structured statements.
# A fresh site is reserved for every original scalar; generated fallbacks are
# copied once and never fed back through this expansion hook.
def x185_late_enabled() -> Bool: True{}

# Independent admission switch for the shared cold-constructor experiment.
def x185_ctor_enabled() -> Bool: False{}

@unsafe
def x185_late_accessors(rows: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match rows:
    case Nil{}: []
    case Con{head,rest}: nt_append(N111Stmt,p112a_expand(3,head),x185_late_accessors(rest))

@unsafe
def x185_late_transport(expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}: x185_late_accessors(body)

@unsafe
def x185_late_previous(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_constructor(stmt,ids,site,
          nt_choose(P114TExpansion,x185_ctor_enabled(),
            v => p185cc_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x185_late_constructor(+stmt: N111Stmt, ids: N111Ids, site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,+changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_transport(p114t_expand(p118q_sized(stmt),ids,site)))

@unsafe
def x185_late_borrow(+stmt: N111Stmt, +ids: N111Ids, +site: U32, read: P128BFRead) -> List<&2,N111Stmt>:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}:
      nt_append(N111Stmt,p128bf_guard(term,ctor,site),
        [N111If{p114t_local(site,"borrow_guard"),p128bf_fast(dest,buffer,count,site),[stmt]}])
    case _: x185_late_previous(stmt,ids,site,p126nt_expand(stmt,site))

@unsafe
def x185_late_scalar(+stmt: N111Stmt, +ids: N111Ids, +site: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
    u => x186_late_char(stmt,ids,site,p186ch_expand(stmt)),u => p112a_expand(3,stmt))

def x186_transport_enabled() -> Bool: True{}

@unsafe
def x186_late_char(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        x186_late_registers(stmt,ids,site,nt_choose(P114TExpansion,x186_transport_enabled(),
          v => p186rt_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x186_late_registers(+stmt: N111Stmt, +ids: N111Ids, +site: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_borrow(stmt,ids,site,p128bf_match(stmt,ids,site)))

@unsafe
def x185_late_stmts(body: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes(condition,x181_scalar_rows(no),rest,ids,x185_late_stmts(x181_scalar_rows(yes),ids,site))
    case Con{P113DScalar{stmt},rest}:
      p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site)),
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))
    case Con{P113DIf{condition,yes,no},rest}:
      x185_late_yes(condition,no,rest,ids,x185_late_stmts(yes,ids,site))
    case Con{head,rest}: p113a_prefix([head],x185_late_stmts(rest,ids,site))

@unsafe
def x185_late_yes(condition: N111Value, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, yes: P113ABody) -> P113ABody:
  match yes:
    case P113ABody{body,next}: x185_late_no(condition,body,rest,ids,x185_late_stmts(no,ids,next))

@unsafe
def x185_late_no(condition: N111Value, yes: List<&2,P113DStmt>, rest: List<&2,P113DStmt>,
    +ids: N111Ids, no: P113ABody) -> P113ABody:
  match no:
    case P113ABody{body,next}: p113a_prefix([P113DIf{condition,yes,body}],x185_late_stmts(rest,ids,next))

@unsafe
def x181_scalar(stmt,ids,frame,code):
  match stmt:
    case N111Set{name,typ,value}:
      x181_add(x186_set_text(name,typ,value,ids,frame),code)
    case N111Bin{name,typ,op,left,right}:
      x181_binary(name,typ,op,left,right,ids,frame,code)
    case N111Call{name,typ,symbol,args}:
      x185_float_call(name,typ,symbol,args,ids,frame,code)
    case N111If{condition,yes,no}:
      x181_stmts([P113DIf{condition,x181_scalar_rows(yes),x181_scalar_rows(no)}],ids,frame,code)
    case N111Return{value}:
      x181_return(x181_load(value,ids,frame,"%rax"),frame,code)
    case N111Load{name,typ,base,offset}:
      x181_add(x186_load_text(name,typ,base,offset,ids,frame),code)
    case N111Store{typ,base,offset,value}:
      x181_add(x185_store_memory(typ,base,offset,value,ids,frame),code)
    case N111Offset{name,base,bytes}:
      x181_binary(name,N111Ptr{},"add",base,bytes,ids,frame,code)
    case N111Alloca{name,bytes,align}: code
