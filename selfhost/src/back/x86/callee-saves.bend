# Keep the existing frame offsets and outgoing alignment, but preserve only
# callee-saved registers actually assigned a home. Unknown/unprepared frames
# retain the complete save set. The reserved key cannot originate in a public
# local: the existing __x181 hygiene gate rejects it.
def x186_saves_enabled() -> Bool: True{}

law x186_saves_tree:
  for slots: KDef
  U32

@unsafe
def x186_saves_bucket(slots: List<&2,KDef>) -> U32:
  match slots:
    case Nil{}: 0
    case Con{head,rest}: U32.or(x186_saves_tree(head),x186_saves_bucket(rest))

@unsafe
def x186_saves_tree(slots):
  match slots:
    case KIndexLeaf{hash,bucket}: x186_saves_bucket(bucket)
    case KIndexNode{hash,mask,left,right}: U32.or(x186_saves_tree(left),x186_saves_tree(right))
    case KDef{name,+kind,+reg,bytes,typ,value,children,native,uns}:
      nt_choose(U32,String.eq(kind,"X181Register"),
        u => nt_choose(U32,U32.is_lt(reg,5),v => U32.shln(1,U32.to_nat(reg)),v => 31),u =>
          nt_choose(U32,String.eq(kind,"X181Stack") || String.eq(kind,"X181Buffer") ||
            String.eq(kind,"X185Transient") || String.eq(kind,"X186SavedMask") || String.eq(kind,"Absent"),
            v => 0,v => 31))
    case _: 0

@unsafe
def x186_saves_frame(frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{+slots,bytes,calls,params,symbol}:
      X181Frame{p111v_put(slots,"__x181_saved_mask","X186SavedMask",
        nt_choose(U32,x186_saves_enabled(),u => x186_saves_tree(slots),u => 31),0),
        bytes,calls,params,symbol}

@unsafe
def x186_saves_mask(frame: X181Frame) -> U32:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +entry = p111v_get(slots,"__x181_saved_mask")
      nt_choose(U32,String.eq(dk(entry),"X186SavedMask") && U32.is_le(da(entry),31),
        u => da(entry),u => 31)

def x186_saves_offset(reg: U32) -> U32:
  match reg:
    case 0: 16
    case 1: 8
    case 2: 24
    case 3: 32
    case _: 40

@unsafe
def x186_saves_text(+mask: U32, +reg: U32, +restore: Bool) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(reg,5),u => X188Empty{},u =>
    x188_cat(nt_choose(X188Seq,U32.is_eq(U32.and(mask,U32.shln(1,U32.to_nat(reg))),0),v => X188Empty{},v =>
      nt_choose(X188Seq,restore,
        w => x188_i2("movq",X187Mem{5,U32.sub(0,x186_saves_offset(reg))},x181_reg(reg)),
        w => x188_i2("movq",x181_reg(reg),X187Mem{5,U32.sub(0,x186_saves_offset(reg))}))),
      x186_saves_text(mask,U32.inc(reg),restore)))
