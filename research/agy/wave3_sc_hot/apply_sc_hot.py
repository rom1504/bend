#!/usr/bin/env python3
"""Apply Wave 3 Track S2 hot-loop compiler optimizations to wave2_unified/compiler.bend:
  - C1: Inline P111_SPECIAL_FALSE (1->0), P111_SPECIAL_TRUE (2->1), P111_SPECIAL_ZERO (3->0) in p186ch_expand
  - C2: Single 64-bit load in p128bf_rfc + remove redundant borrow_is_rfc in p128bf_fast
  - C3: Early-exit p88_string_eq_go (check same/char-eq before unpacking next SCon)
"""
import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave2_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave3_sc_hot/compiler.bend"


def replace_once(text: str, old: str, new: str, label: str) -> str:
    n = text.count(old)
    assert n == 1, f"{label}: expected 1 occurrence, got {n}"
    return text.replace(old, new, 1)


def apply_all(src: str) -> str:
    # C1: Inline P111_SPECIAL_FALSE (1->0), P111_SPECIAL_TRUE (2->1), P111_SPECIAL_ZERO (3->0) in p186ch_expand
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

    # C2a: Fuse borrow_guard (tag==2 && aux==ctor) into single ((word>>40)&0x7fffff)-0x20000 == ctor
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
        "C2a: p128bf_rfc single 64-bit load",
    )

    src = replace_once(
        src,
        """     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111Bin{p114t_name(site,"borrow_is_rfc"),N111U64{},"ne",p114t_local(site,"borrow_rfc_bit"),N111Const{0,0}},
     N111If{p114t_local(site,"borrow_is_rfc"),p128bf_rfc(site),[]},""",
        """     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111If{p114t_local(site,"borrow_rfc_bit"),p128bf_rfc(site),[]},""",
        "C2b: p128bf_fast branch directly on borrow_rfc_bit",
    )

    # C3: Early-exit @unsafe p88_string_eq_go (check same first so mismatch exits immediately without unpacking next SCon)
    src = replace_once(
        src,
        """def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)""",
        """@unsafe
def p88_string_eq_go(same: Bool, a: String, b: String) -> Bool:
  match same:
    case False{}: False{}
    case True{}:
      match a b:
        case SNil{} SNil{}: True{}
        case SNil{} SCon{h, t}: False{}
        case SCon{h, t} SNil{}: False{}
        case SCon{h1, t1} SCon{h2, t2}:
          p88_string_eq_go(Char.is_eq(h1, h2), t1, t2)

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(True{}, a, b), a, b)""",
        "C3a: p88_string_eq_go early exit",
    )

    src = replace_once(
        src,
        "      p88_string_eq_go(tag, key, True{})",
        "      p88_string_eq_go(True{}, tag, key)",
        "C3b: p98_tag_eq_read call site",
    )

    # C4: Inline x86 fast paths for p111_rt_sink (4.48%) and p111_rt_keep (2.71%) in hot frames
    # Fast-paths shared RFC (cnt > 1 / cnt < RFC_CNT-1) and trivial terms (tag < 2) without C call.
    src = replace_once(
        src,
        """@unsafe
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
    x181_store(name,frame,x188_reg(0,64))])""",
        """@unsafe
def agy_rt_sink_skip_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +slow = x181_label(U32.inc(site),frame)
  +done = x181_label(U32.add(site,2),frame)
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
    x188_i1("je",X187Target{slow}),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(triv),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow}),
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
  +slow = x181_label(U32.inc(site),frame)
  +done = x181_label(U32.add(site,2),frame)
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
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])""",
        "C4a: agy_rt_sink_skip_text + agy_rt_keep_fast_text",
    )

    src = replace_once(
        src,
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_sink_skip_enabled() && String.eq(symbol,"p111_rt_sink") &&
          String.eq(state,"state") && U32.is_le(next,4294967294),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.inc(next),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))""",
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Nil{}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_frame_ctor_ok(frame) && String.eq(symbol,"p111_rt_sink") &&
          String.eq(state,"state") && U32.is_le(next,4294967292),
        u => X181Code{Con{agy_rt_sink_skip_text(name,args,ids,frame,next),chunks},U32.add(next,3),terminal,error},
        u => nt_choose(X181Code,agy_frame_ctor_ok(frame) && String.eq(symbol,"p111_rt_keep") &&
          String.eq(state,"state") && U32.is_le(next,4294967292),
        v => X181Code{Con{agy_rt_keep_fast_text(name,args,ids,frame,next),chunks},U32.add(next,3),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))""",
        "C4b: hook p111_rt_sink and p111_rt_keep fast paths in agy_rt_inline_try",
    )

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
