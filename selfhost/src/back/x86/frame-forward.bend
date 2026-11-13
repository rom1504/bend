# Adjacent typed frame transport only. Keep the original movq store and use
# its source for the immediately following equal-slot movq load. No dataflow
# fact survives another item, including a label, directive, call or empty item.
# Only aligned negative RBP slots and ordinary 64-bit GPRs are admitted.
# The original IR liveness, frame layout, memory effects and flags are unchanged.
def x191_frame_forward_enabled() -> Bool: True{}

type X191FrameStore is Data:
  X191FrameStore{+source: U32, +displacement: U32}
  X191FrameStoreNone{}

def x191_ff_register(+register: U32) -> Bool:
  U32.is_lt(register,16) && Bool.not(U32.is_eq(register,4)) && Bool.not(U32.is_eq(register,5))

def x191_ff_private(+displacement: U32) -> Bool:
  U32.is_ge(displacement,2147483648) && U32.is_le(displacement,4294967288) &&
    U32.is_eq(U32.mod(displacement,8),0)

@unsafe
def x191_ff_store(item: X187Parsed) -> X191FrameStore:
  match item:
    case PInst{X187Instruction{op,[X187Reg{+source,64,False{}},X187Mem{5,+displacement}]}}:
      nt_choose(X191FrameStore,String.eq(op,"movq") && x191_ff_register(source) && x191_ff_private(displacement),
        u => X191FrameStore{source,displacement},u => X191FrameStoreNone{})
    case _: X191FrameStoreNone{}

@unsafe
def x191_ff_item(+item: X187Parsed, previous: X191FrameStore) -> X188Seq:
  match item previous:
    case PInst{X187Instruction{op,[X187Mem{5,offset},X187Reg{+destination,64,False{}}]}} X191FrameStore{+source,displacement}:
      nt_choose(X188Seq,String.eq(op,"movq") && U32.is_eq(offset,displacement) && x191_ff_register(destination),
        u => nt_choose(X188Seq,U32.is_eq(source,destination),v => X188Empty{},
          v => x188_i2("movq",x188_reg(source,64),x188_reg(destination,64))),
        u => X188One{item})
    case _ _: X188One{item}

# Explicit fragment work list and reversed output chunks avoid recursive host
# stack growth on either association of X188Join. Each fragment is visited once;
# a one-store window is the entire optimization state. Structural empty nodes
# carry no item and may be crossed; PEmpty is an item and clears the window.
@unsafe
def x191_ff_work(todo: List<&2,X188Seq>, previous: X191FrameStore, output: List<&2,X188Seq>) -> X188Seq:
  match todo:
    case Nil{}: x188_finish(output)
    case Con{X188Empty{},rest}: x191_ff_work(rest,previous,output)
    case Con{X188Join{left,right},rest}: x191_ff_work(Con{left,Con{right,rest}},previous,output)
    case Con{X188One{+item},rest}:
      x191_ff_work(rest,x191_ff_store(item),Con{x191_ff_item(item,previous),output})

@unsafe
def x191_frame_forward_when(enabled: Bool, +code: X188Seq) -> X188Seq:
  nt_choose(X188Seq,enabled,u => x191_ff_work([code],X191FrameStoreNone{},[]),u => code)

@unsafe
def x191_frame_forward(code: X188Seq) -> X188Seq:
  x191_frame_forward_when(x191_frame_forward_enabled(),code)
