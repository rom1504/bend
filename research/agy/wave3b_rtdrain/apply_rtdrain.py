#!/usr/bin/env python3
"""Wave 3B Track B1: Runtime Drainer patcher for wave2_unified/compiler.bend.

Drains the hottest C runtime calls OUT of runtime-agy.o and INTO Bend-emitted x86-64
while keeping unified/runtime-agy.o completely unchanged:
  - C1: Inline p111_rt_special_ctor for FALSE (1->0), TRUE (2->1), ZERO (3->0)
  - C2: Fuse borrow_guard + single 64-bit load in p128bf_rfc + remove borrow_is_rfc
  - D1: Broadened inline x86-64 fast paths for p111_rt_sink and p111_rt_keep
        (shared RFC dec/inc, trivial tag < 2, AND static loc < HEAP_OFF) on all frames
  - D2: Inline x86-64 RFC fast path in agy_rt_take_text (p125_rt_take1..4) for BOTH
        unique RFC (cnt == 1: unpack + free r & src) AND shared RFC (cnt > 1:
        two-phase validate + bump child RFCs + dec H[r], draining p198_rfc_take* + span_fade!)
  - D3: Inline x86-64 fast path for p118_rt_borrow_scalar_safe (count == 1 and 2)
  - D4: Broaden agy_mark_bounded_frame threshold from 256 to 512 statements
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave2_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave3b_rtdrain/compiler.bend"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    assert n == 1, f"{label}: expected 1 occurrence, got {n}"
    return text.replace(old, new, 1)


def apply_all(src: str) -> str:
    # C1: Inline P111_SPECIAL_FALSE (1->0), P111_SPECIAL_TRUE (2->1), P111_SPECIAL_ZERO (3->0)
    src = replace_once(
        src,
        """    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_ctor") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}""",
        """    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{5,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_ctor") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")),
          u => P114TExpansion{[N111Load{dest,N111U64{},N111Local{buffer},0}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111Const{+kind,0}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}}:
        nt_choose(P114TExpansion,String.eq(symbol,"p111_rt_special_ctor") && String.eq(state,"state") &&
          Bool.not(String.eq(buffer,"state")) && U32.is_ge(kind,1) && U32.is_le(kind,3),
          u => P114TExpansion{[N111Set{dest,N111U64{},N111Const{Bool.to_u32(U32.is_eq(kind,2)),0}}],True{}},
          u => P114TExpansion{[stmt],False{}})
    case _: P114TExpansion{[stmt],False{}}""",
        "C1: p186ch_expand inline FALSE/TRUE/ZERO",
    )

    # C2a: Fuse borrow_guard (tag==2 && aux==ctor)
    src = replace_once(
        src,
        """   N111Bin{p114t_name(site,"borrow_tag_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{56,0}},
   N111Bin{p114t_name(site,"borrow_tag"),N111U64{},"and",p114t_local(site,"borrow_tag_bits"),N111Const{127,0}},
   N111Bin{p114t_name(site,"borrow_is_ctr"),N111U64{},"eq",p114t_local(site,"borrow_tag"),N111Const{2,0}},
   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{65535,0}},
   N111Bin{p114t_name(site,"borrow_is_ctor"),N111U64{},"eq",p114t_local(site,"borrow_aux"),N111CtorId{ctor}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"and",p114t_local(site,"borrow_is_ctr"),p114t_local(site,"borrow_is_ctor")}]""",
        """   N111Bin{p114t_name(site,"borrow_aux_bits"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{40,0}},
   N111Bin{p114t_name(site,"borrow_tag_aux"),N111U64{},"and",p114t_local(site,"borrow_aux_bits"),N111Const{8388607,0}},
   N111Bin{p114t_name(site,"borrow_aux_sub"),N111U64{},"sub",p114t_local(site,"borrow_tag_aux"),N111Const{131072,0}},
   N111Bin{p114t_name(site,"borrow_guard"),N111U32{},"eq",p114t_local(site,"borrow_aux_sub"),N111CtorId{ctor}}]""",
        "C2a: fuse borrow_guard tag+aux check",
    )

    # C2b: Single 64-bit load in p128bf_rfc + eliminate borrow_is_rfc in p128bf_fast
    src = replace_once(
        src,
        """@unsafe
def p128bf_rfc(+site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
   N111Offset{p114t_name(site,"borrow_header"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_header_bytes")},
   N111Load{p114t_name(site,"borrow_low"),N111U32{},p114t_local(site,"borrow_header"),0},
   N111Load{p114t_name(site,"borrow_high"),N111U32{},p114t_local(site,"borrow_header"),4},
   N111Bin{p114t_name(site,"borrow_high_shift"),N111U64{},"shl",p114t_local(site,"borrow_high"),N111Const{32,0}},
   N111Bin{p114t_name(site,"borrow_header_word"),N111U64{},"or",p114t_local(site,"borrow_low"),p114t_local(site,"borrow_high_shift")},
   N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}]""",
        """@unsafe
def p128bf_rfc(+site: U32) -> List<&2,N111Stmt>:
  [N111Bin{p114t_name(site,"borrow_header_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
   N111Offset{p114t_name(site,"borrow_header"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_header_bytes")},
   N111Load{p114t_name(site,"borrow_header_word"),N111U64{},p114t_local(site,"borrow_header"),0},
   N111Bin{p114t_name(site,"borrow_location"),N111U64{},"shr",p114t_local(site,"borrow_header_word"),N111Const{24,0}}]""",
        "C2b: p128bf_rfc single 64-bit load",
    )

    src = replace_once(
        src,
        """     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111Bin{p114t_name(site,"borrow_is_rfc"),N111U64{},"ne",p114t_local(site,"borrow_rfc_bit"),N111Const{0,0}},
     N111If{p114t_local(site,"borrow_is_rfc"),p128bf_rfc(site),[]},""",
        """     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111If{p114t_local(site,"borrow_rfc_bit"),p128bf_rfc(site),[]},""",
        "C2c: p128bf_fast branch directly on borrow_rfc_bit",
    )

    # D4: Broaden agy_mark_bounded_frame threshold from 256 to 512 statements
    src = replace_once(
        src,
        """      nt_choose(X181Frame,(String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
          U32.is_le(p113i_size(body),256),""",
        """      nt_choose(X181Frame,(String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
          U32.is_le(p113i_size(body),512),""",
        "D4: broaden agy_mark_bounded_frame to 512",
    )

    # D2: Upgrade agy_rt_take_text to also inline RFC takes (unique cnt==1 AND shared cnt>1 span_fade!)
    old_take = """@unsafe
def agy_rt_take_text(+name: String, +symbol: String, +args: List<&2,N111Arg>,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,lenOff},x188_reg(11,64)),
    x188_i2("addq",X187Imm{words,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,1,count,0),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,atOff}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,lenOff}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])"""

    new_take = """@unsafe
def agy_rfc_check_fields(+count: U32, +index: U32, +frame: X181Frame, +lbase: U32, +slow: String) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    +off = U32.mul(index,8)
    +ltriv = x181_label(U32.add(lbase,U32.mul(index,3)),frame)
    +lok = x181_label(U32.add(lbase,U32.add(U32.mul(index,3),1)),frame)
    x188_many([
      x188_i2("movq",X187Mem{10,off},x188_reg(0,64)),
      x188_i2("movq",x188_reg(0,64),X187Mem{2,off}),
      x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
      x188_i1("jge",X187Target{ltriv}),
      x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(8,64)),
      x188_i2("andl",X187Imm{16777215,0},x188_reg(8,32)),
      x188_i2("cmpl",X187Imm{16777210,0},x188_reg(8,32)),
      x188_i1("jae",X187Target{slow}),
      x188_i1("jmp",X187Target{lok}),
      x188_label(ltriv),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jae",X187Target{slow}),
      x188_label(lok),
      agy_rfc_check_fields(count,U32.inc(index),frame,lbase,slow)]))

@unsafe
def agy_rfc_bump_fields(+count: U32, +index: U32, +frame: X181Frame, +lbase: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    +off = U32.mul(index,8)
    +lbump = x181_label(U32.add(lbase,U32.add(U32.mul(index,3),2)),frame)
    x188_many([
      x188_i2("movq",X187Mem{2,off},x188_reg(0,64)),
      x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
      x188_i1("jge",X187Target{lbump}),
      x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
      x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(8,64)),
      x188_i2("addq",X187Imm{1,0},x188_reg(8,64)),
      x188_i2("movq",x188_reg(8,64),X187Indexed{9,0,8,0}),
      x188_label(lbump),
      agy_rfc_bump_fields(count,U32.inc(index),frame,lbase)]))

@unsafe
def agy_rfc_unique_free(+cls: U32, +atOff: U32, +lenOff: U32, +words: U32, +count: U32, +slow: String) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(cls,0),
    u => x188_many([
      x188_i2("movq",X187Mem{8,256},x188_reg(11,64)),
      x188_i2("addq",X187Imm{2,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      agy_copy_words(10,2,11,count,0),
      x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
      x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
      x188_i2("movq",x188_reg(0,64),X187Mem{8,0}),
      x188_i2("addq",X187Imm{2,0},X187Mem{8,256})]),
    u => x188_many([
      x188_i2("movq",X187Mem{8,256},x188_reg(11,64)),
      x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      x188_i2("movq",X187Mem{8,lenOff},x188_reg(11,64)),
      x188_i2("addq",X187Imm{words,0},x188_reg(11,64)),
      x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
      x188_i1("jae",X187Target{slow}),
      agy_copy_words(10,2,11,count,0),
      x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
      x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
      x188_i2("addq",X187Imm{1,0},X187Mem{8,256}),
      x188_i2("movq",X187Mem{8,atOff},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
      x188_i2("movq",x188_reg(0,64),X187Mem{8,atOff}),
      x188_i2("addq",X187Imm{words,0},X187Mem{8,lenOff})]))

@unsafe
def agy_rt_take_text(+name: String, +symbol: String, +args: List<&2,N111Arg>,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  +rfc = x181_label(U32.add(site,2),frame)
  +shared = x181_label(U32.add(site,3),frame)
  +lbase = U32.add(site,4)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("andl",X187Imm{127,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jl",X187Target{rfc}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,lenOff},x188_reg(11,64)),
    x188_i2("addq",X187Imm{words,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,1,count,0),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,atOff}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,lenOff}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(rfc),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",X187Indexed{9,1,8,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(8,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("ja",X187Target{shared}),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jb",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    agy_rfc_unique_free(cls,atOff,lenOff,words,count,slow),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(shared),
    agy_rfc_check_fields(count,0,frame,lbase,slow),
    agy_rfc_bump_fields(count,0,frame,lbase),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Indexed{9,1,8,0}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])"""

    src = replace_once(src, old_take, new_take, "D2a: agy_rt_take_text RFC unique + shared fast paths")

    # D1 + D3: Inline p111_rt_sink, p111_rt_keep (with static + shared-RFC), and p118_rt_borrow_scalar_safe
    old_sink_and_try = """@unsafe
def agy_rt_sink_skip_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +done = x181_label(site,frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jb",X187Target{done}),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_reuse_text(name,n,args,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U64{},rval},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967292),
        u => X181Code{Con{agy_rt_ctor_reuse_text(name,n,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,3),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_arity(symbol)
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_text(name,symbol,args,n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_sink_skip_enabled() && String.eq(symbol,"p111_rt_sink") &&
          String.eq(state,"state") && U32.is_le(next,4294967294),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.inc(next),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)"""

    new_sink_and_try = """@unsafe
def agy_rt_sink_skip_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +triv_ok = x181_label(U32.inc(site),frame)
  +slow = x181_label(U32.add(site,2),frame)
  +done = x181_label(U32.add(site,3),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jbe",X187Target{slow}),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{triv_ok}),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("jae",X187Target{slow}),
    x188_label(triv_ok),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_keep_fast_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +triv_ok = x181_label(U32.inc(site),frame)
  +slow = x181_label(U32.add(site,2),frame)
  +done = x181_label(U32.add(site,3),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{16777214,0},x188_reg(0,32)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{triv_ok}),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("jae",X187Target{slow}),
    x188_label(triv_ok),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_borrow_safe_text(+name: String, +count: U32, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv1 = x181_label(site,frame)
  +chk2 = x181_label(U32.inc(site),frame)
  +triv2 = x181_label(U32.add(site,2),frame)
  +ret0 = x181_label(U32.add(site,3),frame)
  +slow = x181_label(U32.add(site,4),frame)
  +done = x181_label(U32.add(site,5),frame)
  +check_second = nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => x188_many([
    x188_i2("testq",x188_reg(2,64),x188_reg(2,64)),
    x188_i1("jge",X187Target{triv2}),
    x188_i2("movq",x188_reg(2,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{chk2}),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(10,64)),
    x188_i1("je",X187Target{ret0}),
    x188_label(chk2),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",X187Indexed{9,10,8,0},x188_reg(11,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(11,32)),
    x188_i1("jbe",X187Target{ret0}),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv2),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow})]))
  +after1 = nt_choose(String,U32.is_eq(count,1),u => done,u => chk2)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv1}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Indexed{9,8,8,0},x188_reg(11,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(11,32)),
    x188_i1("jbe",X187Target{ret0}),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    nt_choose(X188Seq,U32.is_eq(count,1),u => x188_i1("jmp",X187Target{done}),u => X188Empty{}),
    nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => check_second),
    nt_choose(X188Seq,U32.is_eq(count,1),u => X188Empty{},u => x188_many([
      x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
      x188_i1("jmp",X187Target{done})])),
    x188_label(triv1),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow}),
    nt_choose(X188Seq,U32.is_eq(count,1),
      u => x188_many([x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),x188_i1("jmp",X187Target{done})]),
      u => x188_i1("jmp",X187Target{slow})),
    x188_label(ret0),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p118_rt_borrow_scalar_safe"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_take_reuse_text(name,n,args,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U64{},rval},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_reuse_arity(symbol)
      nt_choose(X181Code,U32.is_gt(n,0) && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967292),
        u => X181Code{Con{agy_rt_ctor_reuse_text(name,n,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,3),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_take_arity(symbol)
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          String.eq(state,"state") && U32.is_le(next,4294967279),
        u => X181Code{Con{agy_rt_take_text(name,symbol,args,n,ids,frame,next),chunks},U32.add(next,16),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,String.eq(symbol,"p111_rt_ctor") && String.eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},a},Con{N111Arg{N111U64{},b},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,String.eq(symbol,"p118_rt_borrow_scalar_safe") && String.eq(state,"state") &&
          (U32.is_eq(cnt,1) || U32.is_eq(cnt,2)) && U32.is_le(next,4294967289),
        u => X181Code{Con{agy_rt_borrow_safe_text(name,cnt,args,ids,frame,next),chunks},U32.add(next,6),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,String.eq(symbol,"p111_rt_sink") &&
          String.eq(state,"state") && U32.is_le(next,4294967291),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.add(next,4),terminal,error},
        u => nt_choose(X181Code,String.eq(symbol,"p111_rt_keep") &&
          String.eq(state,"state") && U32.is_le(next,4294967291),
        v => X181Code{Con{agy_rt_keep_fast_text(name,args,ids,frame,next),chunks},U32.add(next,4),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)"""

    src = replace_once(src, old_sink_and_try, new_sink_and_try, "D1+D3: inline sink, keep, borrow_scalar_safe + hook take16")
    return src


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    out = apply_all(a.src.read_text())
    a.dst.write_text(out)
    print(f"Wrote {a.dst} ({len(out)} bytes)")


if __name__ == "__main__":
    main()
