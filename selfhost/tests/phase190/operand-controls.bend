# Forced homes isolate operand selection from allocator and earlier optimization.
# Modes: destination separate, destination=left, destination=right, all equal.
def p190oc_v(name: String) -> N111Value: N111Local{name}

@unsafe
def p190oc_frame(symbol: String, +mode: U32) -> X181Frame:
  +slots = p111v_put(p111v_put(p111v_put(missing(),"state","X181Register",0,8),
    "a","X185Transient",0,8),"b","X185Transient",1,8)
  X181Frame{p111v_put(slots,"d","X185Transient",
    nt_choose(U32,U32.is_eq(mode,0),u => 2,u => nt_choose(U32,U32.is_eq(mode,2),v => 1,v => 0)),8),40,0,["state"],symbol}

@unsafe
def p190oc_body(+typ: N111Type, op: String, mode: U32) -> List<&2,P113DStmt>:
  [P113DScalar{N111Load{"a",N111U64{},p190oc_v("state"),0}},
   P113DScalar{N111Load{"b",N111U64{},p190oc_v("state"),8}},
   P113DScalar{N111Bin{"d",typ,op,p190oc_v("a"),
     p190oc_v(nt_choose(String,U32.is_eq(mode,3),u => "a",u => "b"))}},
   P113DResult{[p190oc_v("d")]}]

@unsafe
def p190oc_modes(+typ: N111Type, +width: String, +op: String, +mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,4),u => X181Output{[],""},u =>
    x181_program_join(p190oc_one(typ,width,op,mode),p190oc_modes(typ,width,op,U32.inc(mode))))

@unsafe
def p190oc_one(typ: N111Type, width: String, +op: String, +mode: U32) -> X181Output:
  +symbol = "p190o_" ++ width ++ "_" ++ op ++ "_" ++ U32.show(mode)
  x185_function_frame(symbol,[],p190oc_body(typ,op,mode),N111Ids{missing(),missing()},p190oc_frame(symbol,mode))

@unsafe
def p190oc_ops(ops: List<&2,String>, +typ: N111Type, +width: String) -> X181Output:
  match ops:
    case Nil{}: X181Output{[],""}
    case Con{+op,rest}: x181_program_join(p190oc_modes(typ,width,op,0),p190oc_ops(rest,typ,width))

def p190oc_operations() -> List<&2,String>:
  ["add","sub","mul","and","or","xor","shl","shr","sar","eq","ne","ult","ule","ugt","uge","slt","sle","sgt","sge"]

@unsafe
def p190oc_memory(+typ: N111Type, +width: String) -> X181Output:
  +load = "p190o_load_" ++ width
  +store = "p190o_store_" ++ width
  +same = "p190o_store_same_" ++ width
  x181_program_join(x185_function_frame(load,[],
    [P113DScalar{N111Load{"a",N111Ptr{},p190oc_v("state"),0}},
     P113DScalar{N111Load{"a",typ,p190oc_v("a"),8}},P113DResult{[p190oc_v("a")]}],
    N111Ids{missing(),missing()},p190oc_frame(load,0)),
  x181_program_join(x185_function_frame(store,[],
    [P113DScalar{N111Load{"a",N111U64{},p190oc_v("state"),0}},
     P113DScalar{N111Store{typ,p190oc_v("state"),16,p190oc_v("a")}},P113DResult{[p190oc_v("a")]}],
    N111Ids{missing(),missing()},p190oc_frame(store,0)),
    x185_function_frame(same,[],
    [P113DScalar{N111Store{typ,p190oc_v("state"),16,p190oc_v("state")}},P113DResult{[p190oc_v("state")]}],
    N111Ids{missing(),missing()},p190oc_frame(same,0))))

@unsafe
def p190oc_emit() -> X181Output:
  x181_program_join(p190oc_ops(p190oc_operations(),N111U32{},"32"),
  x181_program_join(p190oc_ops(p190oc_operations(),N111U64{},"64"),
  x181_program_join(p190oc_memory(N111U32{},"32"),p190oc_memory(N111U64{},"64"))))

# Out-of-signed32 offsets must retain unsigned address materialization.
@unsafe
def p190oc_large_offset(+offset: U32) -> Bool:
  +frame = p190oc_frame("offset",0)
  +ids: N111Ids = N111Ids{missing(),missing()}
  +base = p190oc_v("a")
  +value = p190oc_v("b")
  String.eq(x188_render(x190_store_memory(N111U64{},base,offset,value,ids,frame)),
    x188_render(x185_store_memory(N111U64{},base,offset,value,ids,frame))) &&
  String.eq(x188_render(x186_load_text("a",N111U32{},base,offset,ids,frame)),
    x188_render(x188_cat(x181_address(base,offset,ids,frame),x188_i2("movl",X187Mem{10,0},x188_reg(7,32)))))

@unsafe
def p190oc_controls() -> List<&2,String>:
  ["operand-large-offset=" ++ nt_choose(String,p190oc_large_offset(2147483648) && p190oc_large_offset(4294967295),u => "1",u => "0")]
