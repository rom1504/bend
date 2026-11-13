# Copy-width controls keep the earlier operand fixture byte-identical. Modes
# force separate registers, the same register, a stack source, and a stack dest.
def p190wc_v(name: String) -> N111Value: N111Local{name}

@unsafe
def p190wc_frame(symbol: String, +mode: U32) -> X181Frame:
  +slots = p111v_put(missing(),"state","X181Register",0,8)
  +source = nt_choose(KDef,U32.is_eq(mode,2),u => p111v_put(slots,"source","X181Stack",48,8),
    u => p111v_put(slots,"source","X185Transient",0,8))
  X181Frame{nt_choose(KDef,U32.is_eq(mode,3),u => p111v_put(source,"dest","X181Stack",56,8),
    u => p111v_put(source,"dest","X185Transient",nt_choose(U32,U32.is_eq(mode,1),v => 0,v => 1),8)),64,0,["state"],symbol}

@unsafe
def p190wc_one(typ: N111Type, width: String, +mode: U32) -> X181Output:
  +symbol = "p190w_" ++ width ++ "_" ++ U32.show(mode)
  x185_function_frame(symbol,[],
    [P113DScalar{N111Load{"source",N111U64{},p190wc_v("state"),0}},
     P113DScalar{N111Set{"dest",typ,p190wc_v("source")}},P113DResult{[p190wc_v("dest")]}],
    N111Ids{missing(),missing()},p190wc_frame(symbol,mode))

@unsafe
def p190wc_modes(+typ: N111Type, +width: String, +mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_ge(mode,4),u => X181Output{[],""},u =>
    x181_program_join(p190wc_one(typ,width,mode),p190wc_modes(typ,width,U32.inc(mode))))

@unsafe
def p190wc_constant(+index: U32, lo: U32) -> X181Output:
  +symbol = "p190w_const_" ++ U32.show(index)
  x185_function_frame(symbol,[],
    [P113DScalar{N111Set{"dest",N111U32{},N111Const{lo,4294967295}}},P113DResult{[p190wc_v("dest")]}],
    N111Ids{missing(),missing()},p190wc_frame(symbol,0))

@unsafe
def p190wc_constants(words: List<&2,U32>, +index: U32) -> X181Output:
  match words:
    case Nil{}: X181Output{[],""}
    case Con{head,rest}: x181_program_join(p190wc_constant(index,head),p190wc_constants(rest,U32.inc(index)))

@unsafe
def p190wc_symbol() -> X181Output:
  x185_function_frame("p190w_symbol",[],
    [P113DScalar{N111Set{"dest",N111U32{},N111Symbol{"p190w_global"}}},P113DResult{[p190wc_v("dest")]}],
    N111Ids{missing(),missing()},p190wc_frame("p190w_symbol",0))

@unsafe
def p190wc_emit() -> X181Output:
  x181_program_join(p190wc_modes(N111U32{},"32",0),
  x181_program_join(p190wc_modes(N111U64{},"64",0),
  x181_program_join(p190wc_constants([0,1,2147483647,2147483648,4294967295],0),p190wc_symbol())))

# This group uses independent machine observations, with no metadata rows.
def p190wc_controls() -> List<&2,String>: []
