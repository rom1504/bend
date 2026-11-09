# Exact opcode23 admission plus isolated custom machine placements. The public
# segment verifier is checked separately; forced home aliases are emitter-only
# controls. No other optimizer or production call hook is needed by this file.

def p186uf_call(name: String, typ: N111Type, symbol: String, state: String,
    id: N111Value, buffer: N111Value, count: N111Value) -> N111Stmt:
  N111Call{name,typ,symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},id},
    N111Arg{N111Ptr{},buffer},N111Arg{N111U32{},count}]}

def p186uf_standard(name: String, buffer: String) -> N111Stmt:
  p186uf_call(name,N111U64{},"p111_rt_op","state",N111Const{23,0},N111Local{buffer},N111Const{1,0})

@unsafe
def p186uf_destination(+mode: U32) -> String:
  nt_choose(String,U32.is_eq(mode,4),u => "address",u => "result")

@unsafe
def p186uf_buffer(+mode: U32) -> String:
  nt_choose(String,U32.is_eq(mode,4),u => "address",u => "buffer")

@unsafe
def p186uf_frame(+mode: U32) -> X181Frame:
  +slots = p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(missing(),
    "state","X181Register",0,8),"out","X181Stack",48,8),"input","X181Stack",56,8),
    "saved","X181Stack",64,8),"result","X181Stack",72,8),"buffer","X181Buffer",96,16)
  X181Frame{nt_choose(KDef,U32.is_eq(mode,1),u => p111v_put(slots,"result","X181Register",1,8),u =>
    nt_choose(KDef,U32.is_eq(mode,2),v => p111v_put(slots,"result","X185Transient",4,8),v =>
    nt_choose(KDef,U32.is_eq(mode,3),w => p111v_put(slots,"result","X181Stack",56,8),w =>
    nt_choose(KDef,U32.is_eq(mode,4),z => p111v_put(slots,"address","X185Transient",0,8),z => slots)))),
    96,0,["state","out","input"],"p186uf_" ++ U32.show(mode)}

@unsafe
def p186uf_one(+mode: U32) -> String:
  +frame = p186uf_frame(mode)
  +ids: N111Ids = N111Ids{missing(),missing()}
  x181_prologue(frame) ++
    x181_load(N111Local{"input"},ids,frame,"%r10") ++ x181_store("saved",frame,"%r10") ++
    x181_load(N111Local{"buffer"},ids,frame,"%r11") ++ "  movq %r10, (%r11)\n" ++
    nt_choose(String,U32.is_eq(mode,4),u => x181_store("address",frame,"%r11"),u =>
      x181_load(N111Const{4294967295,4294967295},ids,frame,"%r10") ++
        x181_store("result",frame,"%r10")) ++
    x186_u32_float_probe(p186uf_standard(p186uf_destination(mode),p186uf_buffer(mode)),ids,frame) ++
    x181_load(N111Local{p186uf_destination(mode)},ids,frame,"%r10") ++
    x181_load(N111Local{"out"},ids,frame,"%r11") ++ "  movq %r10, 0(%r11)\n" ++
    x181_load(N111Local{"saved"},ids,frame,"%r10") ++ "  movq %r10, 8(%r11)\n" ++
    x181_load(N111Local{"buffer"},ids,frame,"%r10") ++ "  movq 0(%r10), %r10\n  movq %r10, 16(%r11)\n" ++
    "  xorl %eax, %eax\n" ++ x181_epilogue(frame)

@unsafe
def p186uf_emit() -> X181Output:
  X181Output{[p186uf_one(0),p186uf_one(1),p186uf_one(2),p186uf_one(3),p186uf_one(4)],""}

@unsafe
def p186uf_admitted(stmt: N111Stmt) -> Bool:
  Bool.not(String.is_empty(x186_u32_float_probe(stmt,N111Ids{missing(),missing()},p186uf_frame(0))))

@unsafe
def p186uf_verified(bytes: U32) -> String:
  p111v_segment(N111Segment{"u32float",0,1,0,0,[N111Alloca{"buffer",bytes,8},
    N111Store{N111U64{},N111Local{"buffer"},0,N111Const{4294967295,4294967295}},
    p186uf_standard("result","buffer"),N111Return{N111Local{"result"}}]},N111Ids{missing(),missing()})

def p186uf_barrier(operation: X186InlineOp) -> Bool:
  match operation:
    case X186InlineNone{}: True{}
    case _: False{}

@unsafe
def p186uf_row(+name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")

@unsafe
def p186uf_controls() -> List<&2,String>:
  +text = x186_u32_float_probe(p186uf_standard("result","buffer"),N111Ids{missing(),missing()},p186uf_frame(0))
  +alias = x186_u32_float_probe(p186uf_standard("address","address"),N111Ids{missing(),missing()},p186uf_frame(4))
  [p186uf_row("exact-unary",p186uf_admitted(p186uf_standard("result","buffer"))),
   p186uf_row("unsigned64-conversion",String.contains(text,"movl %r10d, %r10d\n  pxor %xmm0, %xmm0\n  cvtsi2ssq %r10, %xmm0")),
   p186uf_row("fullword-publication",String.contains(text,"movd %xmm0, %r10d\n  movq %r10, -72(%rbp)")),
   p186uf_row("read-before-pointer-overwrite",String.contains(alias,"movq %rdi, %r10\n  movq 0(%r10), %r10") &&
     String.contains(alias,"movd %xmm0, %r10d\n  movq %r10, %rdi")),
   p186uf_row("disabled",String.is_empty(x186_u32_float_probe_when(False{},p186uf_standard("result","buffer"),N111Ids{missing(),missing()},p186uf_frame(0)))),
   p186uf_row("wrong-id",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Const{24,0},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("high-id",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Const{23,1},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("wrong-count",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Const{23,0},N111Local{"buffer"},N111Const{2,0})))),
   p186uf_row("high-count",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Const{23,0},N111Local{"buffer"},N111Const{1,1})))),
   p186uf_row("wrong-state",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","other",N111Const{23,0},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("state-buffer-refused",Bool.not(p186uf_admitted(p186uf_standard("result","state")))),
   p186uf_row("wrong-import",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"other","state",N111Const{23,0},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("wrong-result",Bool.not(p186uf_admitted(p186uf_call("result",N111U32{},"p111_rt_op","state",N111Const{23,0},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("nonlocal-buffer",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Const{23,0},N111Const{0,0},N111Const{1,0})))),
   p186uf_row("dynamic-id",Bool.not(p186uf_admitted(p186uf_call("result",N111U64{},"p111_rt_op","state",N111Local{"input"},N111Local{"buffer"},N111Const{1,0})))),
   p186uf_row("verified-eight-byte-buffer",String.is_empty(p186uf_verified(8))),
   p186uf_row("short-buffer-rejected",Bool.not(String.is_empty(p186uf_verified(4)))),
   p186uf_row("conservative-call-barrier",p186uf_barrier(x186_inline_op(p186uf_standard("result","buffer"))))]
