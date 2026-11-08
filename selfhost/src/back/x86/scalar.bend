# Scalar selection uses only caller-saved scratch registers. Frame variables
# have 64-bit homes; each U32 producer clears the upper half before publication.

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
    u => ".error \"x181: missing local slot\"\n")))

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
    u => ".error \"x181: invalid destination slot\"\n"))

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

@unsafe
def x181_binary(+name: String, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +ids: N111Ids,
    +frame: X181Frame, +code: X181Code) -> X181Code:
  +instruction = x181_bin_instruction(typ,op)
  nt_choose(X181Code,String.is_empty(instruction),
    u => x181_error("unsupported x181 binary operation: " ++ op,code),
    u => x181_add(x181_load(left,ids,frame,"%r10") ++
      x181_load(right,ids,frame,"%r11") ++ instruction ++ x181_store(name,frame,"%r10"),code))

# Local homes are rbp-relative stack/buffer slots or callee-saved registers.
# They are disjoint from ABI argument registers and the outgoing rsp area.
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
  x181_call_arguments(args,ids,frame,0) ++ "  xorl %eax, %eax\n  call " ++ symbol ++ "\n"

# Materialize an unsigned byte offset explicitly; x86 memory displacements are
# signed 32-bit values, while N111Load/Store offsets are U32.
@unsafe
def x181_address(base: N111Value, +offset: U32, ids: N111Ids, frame: X181Frame) -> String:
  x181_load(base,ids,frame,"%r10") ++
    nt_choose(String,U32.is_eq(offset,0),u => "",
      u => "  movabsq $" ++ U32.show(offset) ++ ", %r11\n  addq %r11, %r10\n")

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

@unsafe
def x181_scalar(stmt,ids,frame,code):
  match stmt:
    case N111Set{name,typ,value}:
      x181_add(x181_load(value,ids,frame,"%r10") ++ x181_mask(typ,"%r10d") ++
        x181_store(name,frame,"%r10"),code)
    case N111Bin{name,typ,op,left,right}:
      x181_binary(name,typ,op,left,right,ids,frame,code)
    case N111Call{name,typ,symbol,args}:
      x181_add(x181_call_text(symbol,args,ids,frame) ++ x181_mask(typ,"%eax") ++
        x181_store(name,frame,"%rax"),code)
    case N111If{condition,yes,no}:
      x181_stmts([P113DIf{condition,x181_scalar_rows(yes),x181_scalar_rows(no)}],ids,frame,code)
    case N111Return{value}:
      x181_return(x181_load(value,ids,frame,"%rax"),code)
    case N111Load{name,typ,base,offset}:
      x181_add(x181_address(base,offset,ids,frame) ++
        x181_width(typ,"  movq (%r10), %r10\n","  movl (%r10), %r10d\n") ++
        x181_store(name,frame,"%r10"),code)
    case N111Store{typ,base,offset,value}:
      x181_add(x181_address(base,offset,ids,frame) ++ x181_load(value,ids,frame,"%r11") ++
        x181_width(typ,"  movq %r11, (%r10)\n","  movl %r11d, (%r10)\n"),code)
    case N111Offset{name,base,bytes}:
      x181_add(x181_load(base,ids,frame,"%r10") ++ x181_load(bytes,ids,frame,"%r11") ++
        "  addq %r11, %r10\n" ++ x181_store(name,frame,"%r10"),code)
    case N111Alloca{name,bytes,align}: code
