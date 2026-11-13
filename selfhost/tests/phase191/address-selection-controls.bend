# Compiler-data controls. Selection expectations explicitly depend on the two
# parameterless experimental flags, so the same source covers all four cells.
def p191sc_v(name: String) -> N111Value: N111Local{name}
def p191sc_c(n: U32) -> N111Value: N111Const{n,0}

def p191sc_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

def p191sc_present(pick: Maybe<&2,X191Pick>) -> Bool:
  match pick:
    case Some{p}: True{}
    case None{}: False{}

@unsafe
def p191sc_selected(+body: List<&2,P113DStmt>, params: List<&2,String>, setup: List<&2,P113DStmt>) -> Bool:
  p191sc_present(x191_pick(body,x190_branch_facts(params,setup,body)))

@unsafe
def p191sc_is_load(pick: Maybe<&2,X191Pick>) -> Bool:
  match pick:
    case Some{X191Pick{rest,X191Load{name,typ,X191Address{base,index,4,8}}}}: True{}
    case _: False{}

@unsafe
def p191sc_is_alu(pick: Maybe<&2,X191Pick>) -> Bool:
  match pick:
    case Some{X191Pick{rest,X191MemoryAlu{name,typ,op,left,address}}}: True{}
    case _: False{}

def p191sc_address(typ: N111Type, offset: U32) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"scaled",typ,"mul",p191sc_v("index"),p191sc_c(4)}},
   P113DScalar{N111Offset{"pointer",p191sc_v("base"),p191sc_v("scaled")}},
   P113DScalar{N111Load{"loaded",N111U32{},p191sc_v("pointer"),offset}},
   P113DResult{[p191sc_v("loaded")]}]

def p191sc_memory(typ: N111Type, op: String, +swap: Bool) -> List<&2,P113DStmt>:
  [P113DScalar{N111Load{"loaded",N111U32{},p191sc_v("base"),0}},
   P113DScalar{N111Bin{"result",typ,op,
     nt_choose(N111Value,swap,u => p191sc_v("loaded"),u => p191sc_v("left")),
     nt_choose(N111Value,swap,u => p191sc_v("left"),u => p191sc_v("loaded"))}},
   P113DResult{[p191sc_v("result")]}]

@unsafe
def p191sc_more(+body: List<&2,P113DStmt>, suffix: List<&2,P113DStmt>) -> Bool:
  p191sc_selected(nt_append(P113DStmt,body,suffix),[],[])

@unsafe
def p191sc_controls() -> List<&2,String>:
  +address = p191sc_address(N111U64{},8)
  +memory = p191sc_memory(N111U32{},"add",False{})
  +facts = x190_branch_facts([],[],address)
  [p191sc_row("scale-mul-eight",U32.is_eq(x191_scale("mul",p191sc_c(8)),8)),
   p191sc_row("scale-shift-three",U32.is_eq(x191_scale("shl",p191sc_c(3)),8)),
   p191sc_row("scale-mul-three-refused",U32.is_eq(x191_scale("mul",p191sc_c(3)),0)),
   p191sc_row("scale-shift-four-refused",U32.is_eq(x191_scale("shl",p191sc_c(4)),0)),
   p191sc_row("scale-high-word-refused",U32.is_eq(x191_scale("mul",N111Const{4,1}),0)),
   p191sc_row("address-selected",Bool.not(Bool.xor(p191sc_is_load(x191_pick(address,facts)),x191_address_enabled()))),
   p191sc_row("u32-scaled-refused",Bool.not(p191sc_selected(p191sc_address(N111U32{},8),[],[]))),
   p191sc_row("large-offset-refused",Bool.not(p191sc_selected(p191sc_address(N111U64{},2147483648),[],[]))),
   p191sc_row("parameter-refused",Bool.not(p191sc_selected(address,["pointer"],[]))),
   p191sc_row("setup-refused",Bool.not(p191sc_selected(address,[],
     [P113DScalar{N111Set{"pointer",N111Ptr{},p191sc_v("base")}}]))),
   p191sc_row("extra-index-read-refused",Bool.not(p191sc_more(address,[P113DResult{[p191sc_v("scaled")]}]))),
   p191sc_row("again-address-read-refused",Bool.not(p191sc_more(address,[P113DAgain{[p191sc_v("pointer")]}]))),
   p191sc_row("branch-address-read-refused",Bool.not(p191sc_more(address,
     [P113DIf{p191sc_v("condition"),[P113DResult{[p191sc_v("pointer")]}],[]}]))),
   p191sc_row("memory-add-selected",Bool.not(Bool.xor(p191sc_is_alu(x191_pick(memory,
     x190_branch_facts([],[],memory))),x191_memory_alu_enabled()))),
   p191sc_row("memory-commutative-swap",Bool.not(Bool.xor(p191sc_selected(
     p191sc_memory(N111U32{},"xor",True{}),[],[]),x191_memory_alu_enabled()))),
   p191sc_row("memory-sub-left-refused",Bool.not(p191sc_selected(p191sc_memory(N111U32{},"sub",True{}),[],[]))),
   p191sc_row("memory-width-refused",Bool.not(p191sc_selected(p191sc_memory(N111U64{},"add",False{}),[],[]))),
   p191sc_row("memory-shift-refused",Bool.not(p191sc_selected(p191sc_memory(N111U32{},"shl",False{}),[],[]))),
   p191sc_row("memory-extra-use-refused",Bool.not(p191sc_more(memory,[P113DResult{[p191sc_v("loaded")]}])))]

# Forced ABI homes exercise selected emission independently of the allocator.
# rdi=base, rsi=index, rdx=left/value. Modes 0/1/2/3 place the destination
# in base/index/left/r8; mode4 puts all operands and the result on the stack.
@unsafe
def p191sc_slot(slots: KDef, name: String, +stack: Bool, reg: U32, offset: U32) -> KDef:
  p111v_put(slots,name,nt_choose(String,stack,u => "X181Stack",u => "X185Transient"),
    nt_choose(U32,stack,u => offset,u => reg),8)

@unsafe
def p191sc_frame(symbol: String, +mode: U32) -> X181Frame:
  +stack = U32.is_eq(mode,4)
  +slots = p191sc_slot(p191sc_slot(p191sc_slot(missing(),"base",stack,0,8),"index",stack,1,16),"left",stack,2,24)
  X181Frame{p191sc_slot(slots,"out",stack,mode,32),64,0,[],symbol}

@unsafe
def p191sc_prefix(mode: U32) -> X188Seq:
  x188_many([x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{64,0},x188_reg(4,64)),
    nt_choose(X188Seq,U32.is_eq(mode,4),u => x188_many([
      x188_i2("movq",x188_reg(7,64),X187Mem{5,4294967288}),
      x188_i2("movq",x188_reg(6,64),X187Mem{5,4294967280}),
      x188_i2("movq",x188_reg(2,64),X187Mem{5,4294967272})]),u => X188Empty{})])

@unsafe
def p191sc_address_operand(+typ: N111Type) -> X191Address:
  +bytes = x181_width(typ,"8","4")
  +scale = nt_choose(U32,String.eq(bytes,"8"),u => 8,u => 4)
  X191Address{p191sc_v("base"),p191sc_v("index"),scale,scale}

@unsafe
def p191sc_operation(+typ: N111Type, +kind: String, +mode: U32) -> X191Operation:
  +address = p191sc_address_operand(typ)
  nt_choose(X191Operation,String.eq(kind,"load"),u => X191Load{"out",typ,address},u =>
    nt_choose(X191Operation,String.eq(kind,"store"),u =>
      X191Store{typ,address,p191sc_v(nt_choose(String,U32.is_eq(mode,0),v => "base",
        v => nt_choose(String,U32.is_eq(mode,1),w => "index",w => "left")))},
      u => X191MemoryAlu{"out",typ,kind,p191sc_v("left"),address}))

@unsafe
def p191sc_function(+typ: N111Type, +kind: String, +mode: U32) -> X188Seq:
  +symbol = "p191sc_" ++ kind ++ "_" ++ x181_width(typ,"64","32") ++ "_" ++ U32.show(mode)
  +frame = p191sc_frame(symbol,mode)
  +ids: N111Ids = N111Ids{missing(),missing()}
  x188_many([X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    p191sc_prefix(mode),x191_emit(p191sc_operation(typ,kind,mode),ids,frame),
    nt_choose(X188Seq,String.eq(kind,"store"),u => x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      u => x181_load(p191sc_v("out"),ids,frame,x188_reg(0,64))),
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),X188One{PSize{symbol}}])

@unsafe
def p191sc_modes(+typ: N111Type, +kind: String, +mode: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(mode,5),u => X188Empty{},u =>
    x188_cat(p191sc_function(typ,kind,mode),p191sc_modes(typ,kind,U32.inc(mode))))

@unsafe
def p191sc_operations(ops: List<&2,String>) -> X188Seq:
  match ops:
    case Nil{}: X188Empty{}
    case Con{+op,rest}: x188_many([p191sc_modes(N111U32{},op,0),p191sc_modes(N111U64{},op,0),p191sc_operations(rest)])

@unsafe
def p191sc_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},
    p191sc_operations(["load","add","sub","mul","and","or","xor","store"]),X188One{PSection{4}}])],""}
