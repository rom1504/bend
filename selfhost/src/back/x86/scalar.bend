# Scalar selection reserves r10/r11/rax/rcx as scratch. Frame variables have
# 64-bit homes; each U32 producer clears the upper half before publication.
# Typed instructions are the shared product of selection; text is a renderer.

@unsafe
def x181_width(typ: N111Type, wide: String, narrow: String) -> String:
  match typ:
    case N111U32{}: narrow
    case _: wide

@unsafe
def x181_mask(typ: N111Type, +reg32: X187Operand) -> X188Seq:
  match typ:
    case N111U32{}: x188_i2("movl",reg32,reg32)
    case _: X188Empty{}

@unsafe
def x181_load_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,String.eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",X187Mem{5,U32.sub(0,da(slot))},reg),u =>
  nt_choose(X188Seq,String.eq(dk(slot),"X181Buffer"),
    u => x188_i2("leaq",X187Mem{5,U32.sub(0,da(slot))},reg),u =>
  nt_choose(X188Seq,String.eq(dk(slot),"X181Register"),
    u => x188_i2("movq",x181_reg(da(slot)),reg),u =>
  nt_choose(X188Seq,String.eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",x185_transient_reg(da(slot)),reg),
    v => x188_error("x181: missing local slot")))))

@unsafe
def x181_local_load(+name: String, frame: X181Frame, reg: X187Operand) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x181_load_slot(index_find(slots,name,index_hash(name,2166136261),32),reg)

@unsafe
def x188_id_found(+found: KDef, reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,String.eq(dk(found),"N111Id"),
    u => x188_i2("movabsq",X187Imm{da(found),0},reg),u => x188_error("x181: missing native ID"))

@unsafe
def x188_id_load(tree: KDef, +name: String, reg: X187Operand) -> X188Seq:
  x188_id_found(index_find(tree,name,index_hash(name,2166136261),32),reg)

@unsafe
def x181_function_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(functions,name,reg)

@unsafe
def x181_constructor_id(ids: N111Ids, name: String, reg: X187Operand) -> X188Seq:
  match ids:
    case N111Ids{functions,constructors}: x188_id_load(constructors,name,reg)

@unsafe
def x181_load(value,ids,frame,reg):
  match value:
    case N111Local{name}: x181_local_load(name,frame,reg)
    case N111Const{lo,hi}: x188_i2("movabsq",X187Imm{lo,hi},reg)
    case N111Symbol{name}: x188_i2("leaq",X187Rip{name,0,0},reg)
    case N111FuncId{name}: x181_function_id(ids,name,reg)
    case N111CtorId{name}: x181_constructor_id(ids,name,reg)

@unsafe
def x181_store_slot(+slot: KDef, +reg: X187Operand) -> X188Seq:
  nt_choose(X188Seq,String.eq(dk(slot),"X181Stack"),
    u => x188_i2("movq",reg,X187Mem{5,U32.sub(0,da(slot))}),u =>
  nt_choose(X188Seq,String.eq(dk(slot),"X181Register"),
    u => x188_i2("movq",reg,x181_reg(da(slot))),u =>
  nt_choose(X188Seq,String.eq(dk(slot),"X185Transient"),
    v => x188_i2("movq",reg,x185_transient_reg(da(slot))),
    v => x188_error("x181: invalid destination slot"))))

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
def x181_bin_instruction(+typ: N111Type, +op: String) -> X188Seq:
  +suffix = x181_width(typ,"q","l")
  +left = x188_width_reg(typ,10)
  +right = x188_width_reg(typ,11)
  +condition = x181_condition(op)
  +alu = x181_alu(op)
  nt_choose(X188Seq,Bool.not(String.is_empty(condition)),u =>
    x188_many([x188_i2("cmp" ++ suffix,right,left),x188_i1("set" ++ condition,x188_reg(10,8)),
      x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),u =>
    nt_choose(X188Seq,String.is_empty(alu),u => X188Empty{},u =>
      nt_choose(X188Seq,x181_shift(op),v =>
        x188_many([x188_i2("movl",x188_reg(11,32),x188_reg(1,32)),x188_i2(alu ++ suffix,x188_reg(1,8),left)]),
        v => x188_i2(alu ++ suffix,right,left))))

def x185_machine_enabled() -> Bool: True{}

# Immediate forms keep operand width, comparison signedness and x86 shift masks.
# Full-width constants that cannot use signed32 retain the materialization path.
@unsafe
def x185_immediate(+typ: N111Type, +op: String, value: N111Value) -> X188Seq:
  match value:
    case N111Const{+lo,+hi}:
      +suffix = x181_width(typ,"q","l")
      +left = x188_width_reg(typ,10)
      +condition = x181_condition(op)
      +alu = x181_alu(op)
      nt_choose(X188Seq,x181_shift(op),u =>
        x188_i2(alu ++ suffix,X187Imm{U32.mod(lo,nt_choose(U32,U32.is_eq(p111v_type(typ),1),v => 32,v => 64)),0},left),u =>
      nt_choose(X188Seq,String.eq(op,"and") && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        u => x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),u =>
      nt_choose(X188Seq,U32.is_eq(hi,0) &&
          (U32.is_eq(p111v_type(typ),1) || U32.is_le(lo,2147483647)),u =>
        nt_choose(X188Seq,Bool.not(String.is_empty(condition)),v =>
          x188_many([x188_i2("cmp" ++ suffix,X187Imm{lo,0},left),x188_i1("set" ++ condition,x188_reg(10,8)),
            x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32))]),v =>
          nt_choose(X188Seq,String.is_empty(alu),w => X188Empty{},w => x188_i2(alu ++ suffix,X187Imm{lo,0},left))),u => X188Empty{})))
    case _: X188Empty{}

@unsafe
def x181_binary(+name: String, +typ: N111Type, +op: String,
    +left: N111Value, +right: N111Value, +ids: N111Ids,
    +frame: X181Frame, +code: X181Code) -> X181Code:
  +instruction = x181_bin_instruction(typ,op)
  +immediate = nt_choose(X188Seq,x185_machine_enabled(),u => x185_immediate(typ,op,right),u => X188Empty{})
  +physical = x185_physical_binary(name,typ,op,left,right,ids,frame)
  nt_choose(X181Code,x188_empty(instruction),u => x181_error("unsupported x181 binary operation: " ++ op,code),u =>
    nt_choose(X181Code,Bool.not(x188_empty(physical)),v => x181_add(physical,code),v =>
      x181_add(x188_many([x181_load(left,ids,frame,x188_reg(10,64)),
        nt_choose(X188Seq,x188_empty(immediate),w => x188_cat(x181_load(right,ids,frame,x188_reg(11,64)),instruction),w => immediate),
        x181_store(name,frame,x188_reg(10,64))]),code)))

# The legacy all-r10 argument path remains available to callers of this helper.
# The selected call path uses x186_call_arguments and preserves its snapshots.
@unsafe
def x181_call_arguments(args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, +n: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),
        nt_choose(X188Seq,U32.is_lt(n,6),u => x188_i2("movq",x188_reg(10,64),x181_argreg(n)),
          u => x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(n,6),8)})),
        x181_call_arguments(rest,ids,frame,U32.inc(n))])

@unsafe
def x181_call_text(symbol,args,ids,frame):
  x188_many([x186_call_arguments(args,ids,frame),x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol})])

# Unsigned offsets above INT32_MAX must not become signed displacements.
@unsafe
def x181_address(base: N111Value, +offset: U32, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),nt_choose(X188Seq,U32.is_eq(offset,0),u => X188Empty{},u =>
    x188_many([x188_i2("movabsq",X187Imm{offset,0},x188_reg(11,64)),x188_i2("addq",x188_reg(11,64),x188_reg(10,64))])))

@unsafe
def x185_load_memory(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_cat(nt_choose(X188Seq,x185_machine_enabled() && U32.is_le(offset,2147483647),u =>
    x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,offset},x188_width_reg(typ,10))),u =>
    x188_cat(x181_address(base,offset,ids,frame),x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,0},x188_width_reg(typ,10)))),
    x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x185_store_memory(+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,x185_machine_enabled() && U32.is_le(offset,2147483647),u =>
    x188_many([x181_load(base,ids,frame,x188_reg(10,64)),x181_load(value,ids,frame,x188_reg(11,64)),
      x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,11),X187Mem{10,offset})]),u =>
    x188_many([x181_address(base,offset,ids,frame),x181_load(value,ids,frame,x188_reg(11,64)),
      x188_i2(x181_width(typ,"movq","movl"),x188_width_reg(typ,11),X187Mem{10,0})]))
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
      x181_return(x181_load(value,ids,frame,x188_reg(0,64)),frame,code)
    case N111Load{name,typ,base,offset}:
      x181_add(x186_load_text(name,typ,base,offset,ids,frame),code)
    case N111Store{typ,base,offset,value}:
      x181_add(x185_store_memory(typ,base,offset,value,ids,frame),code)
    case N111Offset{name,base,bytes}:
      x181_binary(name,N111Ptr{},"add",base,bytes,ids,frame,code)
    case N111Alloca{name,bytes,align}: code
