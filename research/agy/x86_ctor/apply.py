#!/usr/bin/env python3
"""Patch p205-compiler.bend with AGY-003 x86 optimizations:
1. Replace blanket x186_call_arguments stack-snapshot staging with register-only
   parallel move scheduling (using r10 to break cycles, zero stack spills).
2. Inline p125_rt_ctor{1..4} and p125_rt_take{1..4} fast paths in bounded
   p113d_/p114r_ direct workers (<= 256 stmts) with live descriptor checks.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/bootstrap/p205-compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/x86_ctor/compiler.bend")

FRAME_OLD = """@unsafe
def x181_frame(symbol,params,body):
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state","X181Register",0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))"""

FRAME_NEW = """@unsafe
def agy_mark_bounded_frame(+symbol: String, body: List<&2,P113DStmt>, frame: X181Frame) -> X181Frame:
  match frame:
    case X181Frame{slots,bytes,calls,params,sym}:
      nt_choose(X181Frame,(String.starts_with(symbol,"p113d_") || String.starts_with(symbol,"p114r_")) &&
          U32.is_le(p113i_size(body),256),
        u => X181Frame{p111v_put(slots,"__agy_ctor_ok","X186SavedMask",1,0),bytes,calls,params,sym},
        u => frame)

@unsafe
def x181_frame(symbol,params,body):
  +initial: X181Frame = X181Frame{p111v_put(missing(),"state","X181Register",0,8),40,0,params,symbol}
  +homes = x181_frame_names(params,initial)
  +scratch = x181_frame_buffer("scratch",2048,16,homes)
  +results = x181_frame_buffer("__x181_results",64,16,scratch)
  +framed = x181_frame_stmts(body,x181_frame_buffer("__x181_tail",
    nt_choose(U32,List.is_empty(&2,String,params),u => 8,u => U32.mul(nt_count(String,params),8)),8,results))
  agy_mark_bounded_frame(symbol,body,framed)"""

CALL_ARGS_OLD = """@unsafe
def x186_call_selected(+enabled: Bool, +args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, plan: X186CallPlan) -> X188Seq:
  match plan:
    case X186CallPlan{+kind,+count}:
      nt_choose(X188Seq,U32.is_eq(kind,0),u => x188_error("x186: invalid call argument frame"),u =>
        nt_choose(X188Seq,enabled && U32.is_eq(kind,1),u => x186_call_direct(args,ids,frame,0),
          u => x188_cat(x186_call_snapshot(args,ids,frame,U32.mul(count,8),0),
            x186_call_place(count,U32.mul(count,8),0))))"""

CALL_ARGS_NEW = """type AgyCallMove is Data:
  AgyCallMove{+dstIdx: U32, +dstReg: U32, +srcReg: U32, +typ: N111Type, +value: N111Value}

type AgyCallPick is Data:
  AgyCallPick{+move: AgyCallMove, +rest: List<&2,AgyCallMove>}
  AgyCallPickNone{}

def agy_call_phys_reg(index: U32) -> U32:
  match index:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 1
    case 4: 8
    case _: 9

def agy_call_treg(index: U32) -> U32:
  match index:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 8
    case _: 9

@unsafe
def agy_call_src_reg(value: N111Value, slots: KDef) -> U32:
  match value:
    case N111Local{name}:
      +slot = p111v_get(slots,name)
      nt_choose(U32,String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5),
        u => agy_call_treg(da(slot)),u => 0)
    case _: 0

@unsafe
def agy_call_stack_args(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32) -> X188Seq:
  match args:
    case Nil{}: X188Empty{}
    case Con{N111Arg{typ,value},rest}:
      x188_cat(nt_choose(X188Seq,U32.is_ge(index,6),
        u => x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x186_call_mask(typ,x188_reg(10,32)),
          x188_i2("movq",x188_reg(10,64),X187Mem{4,U32.mul(U32.sub(index,6),8)})]),
        u => X188Empty{}),
        agy_call_stack_args(rest,ids,frame,U32.inc(index)))

law agy_call_reg_moves:
  for args: List<&2,N111Arg>
  for +slots: KDef
  for +index: U32
  List<&2,AgyCallMove>

@unsafe
def agy_call_reg_move_one(+index: U32, +typ: N111Type, +value: N111Value,
    +rest: List<&2,N111Arg>, +slots: KDef) -> List<&2,AgyCallMove>:
  +dst = agy_call_phys_reg(index)
  +src = agy_call_src_reg(value,slots)
  nt_choose(List<&2,AgyCallMove>,U32.is_eq(src,dst) && Bool.not(U32.is_eq(p111v_type(typ),1)),
    v => agy_call_reg_moves(rest,slots,U32.inc(index)),
    v => Con{AgyCallMove{index,dst,src,typ,value},agy_call_reg_moves(rest,slots,U32.inc(index))})

@unsafe
def agy_call_reg_moves(args,slots,index):
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}:
      nt_choose(List<&2,AgyCallMove>,U32.is_ge(index,6),u => [],
        u => agy_call_reg_move_one(index,typ,value,rest,slots))

@unsafe
def agy_call_other_reads(+reg: U32, +skipIdx: U32, moves: List<&2,AgyCallMove>) -> Bool:
  match moves:
    case Nil{}: False{}
    case Con{AgyCallMove{dstIdx,dstReg,srcReg,typ,value},rest}:
      (Bool.not(U32.is_eq(dstIdx,skipIdx)) && U32.is_eq(srcReg,reg)) || agy_call_other_reads(reg,skipIdx,rest)

def agy_call_pick_cons(m: AgyCallMove, p: AgyCallPick) -> AgyCallPick:
  match p:
    case AgyCallPick{chosen,rest}: AgyCallPick{chosen,Con{m,rest}}
    case _: AgyCallPickNone{}

@unsafe
def agy_call_pick_ready(todo: List<&2,AgyCallMove>, +all: List<&2,AgyCallMove>) -> AgyCallPick:
  match todo:
    case Nil{}: AgyCallPickNone{}
    case Con{+m,+rest}:
      match m:
        case AgyCallMove{dstIdx,dstReg,srcReg,typ,value}:
          nt_choose(AgyCallPick,Bool.not(agy_call_other_reads(dstReg,dstIdx,all)),
            u => AgyCallPick{m,rest},
            u => agy_call_pick_cons(m,agy_call_pick_ready(rest,all)))

@unsafe
def agy_call_rewrite_src(moves: List<&2,AgyCallMove>, +oldReg: U32, +newReg: U32) -> List<&2,AgyCallMove>:
  match moves:
    case Nil{}: []
    case Con{AgyCallMove{dstIdx,dstReg,+srcReg,typ,value},rest}:
      Con{AgyCallMove{dstIdx,dstReg,nt_choose(U32,U32.is_eq(srcReg,oldReg),u => newReg,u => srcReg),typ,value},
        agy_call_rewrite_src(rest,oldReg,newReg)}

@unsafe
def agy_call_emit_move(m: AgyCallMove, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match m:
    case AgyCallMove{+dstIdx,+dstReg,+srcReg,+typ,value}:
      nt_choose(X188Seq,U32.is_eq(srcReg,10),
        u => x188_cat(x188_i2("movq",x188_reg(10,64),x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx))),
        u => nt_choose(X188Seq,U32.is_eq(srcReg,dstReg),
          v => x186_call_mask(typ,x186_call_reg32(dstIdx)),
          v => x188_cat(x181_load(value,ids,frame,x181_argreg(dstIdx)),x186_call_mask(typ,x186_call_reg32(dstIdx)))))

law agy_call_schedule:
  for +moves: List<&2,AgyCallMove>
  for +ids: N111Ids
  for +frame: X181Frame
  for +fuel: U32
  X188Seq

@unsafe
def agy_call_step(picked: AgyCallPick, +moves: List<&2,AgyCallMove>, +ids: N111Ids, +frame: X181Frame, +fuel: U32) -> X188Seq:
  match picked:
    case AgyCallPick{chosen,rest}:
      x188_cat(agy_call_emit_move(chosen,ids,frame),agy_call_schedule(rest,ids,frame,fuel))
    case AgyCallPickNone{}:
      match moves:
        case Con{AgyCallMove{dstIdx,+dstReg,srcReg,typ,value},rest}:
          x188_cat(x188_i2("movq",x188_reg(dstReg,64),x188_reg(10,64)),
            agy_call_schedule(agy_call_rewrite_src(moves,dstReg,10),ids,frame,fuel))
        case Nil{}: X188Empty{}

@unsafe
def agy_call_schedule(moves,ids,frame,fuel):
  match moves:
    case Nil{}: X188Empty{}
    case Con{head,rest}:
      nt_choose(X188Seq,U32.is_gt(fuel,0),
        u => agy_call_step(agy_call_pick_ready(moves,moves),moves,ids,frame,U32.sub(fuel,1)),
        u => x188_error("agy: call arg schedule overflow"))

@unsafe
def agy_call_parallel(+args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      x188_cat(agy_call_stack_args(args,ids,frame,0),
        agy_call_schedule(agy_call_reg_moves(args,slots,0),ids,frame,16))

@unsafe
def x186_call_selected(+enabled: Bool, +args: List<&2,N111Arg>, +ids: N111Ids,
    +frame: X181Frame, plan: X186CallPlan) -> X188Seq:
  match plan:
    case X186CallPlan{+kind,+count}:
      nt_choose(X188Seq,U32.is_eq(kind,0),u => x188_error("x186: invalid call argument frame"),u =>
        nt_choose(X188Seq,enabled && U32.is_eq(kind,1),u => x186_call_direct(args,ids,frame,0),
          u => nt_choose(X188Seq,enabled && U32.is_eq(kind,2),
            v => agy_call_parallel(args,ids,frame),
            v => x188_cat(x186_call_snapshot(args,ids,frame,U32.mul(count,8),0),
              x186_call_place(count,U32.mul(count,8),0)))))"""

CTOR_CALL_OLD = """@unsafe
def x185_float_call(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  +stmt: N111Stmt = N111Call{name,typ,symbol,args}
  x195s_selected(x195s_pick(x195s_enabled(),stmt),stmt,ids,frame,code)"""

CTOR_CALL_NEW = """law x186_call_arguments:
  for +args: List<&2,N111Arg>
  for +ids: N111Ids
  for +frame: X181Frame
  X188Seq

def agy_ctor_cid(ctor: String, ids: N111Ids) -> U32:
  match ids:
    case N111Ids{functions,ctors}: da(p111v_get(ctors,ctor))

def agy_ctor_inline_enabled() -> Bool: True{}
def agy_take_inline_enabled() -> Bool: True{}

@unsafe
def agy_frame_ctor_ok(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      U32.is_eq(da(p111v_get(slots,"__agy_ctor_ok")),1)

def agy_rt_ctor_arity(+symbol: String) -> U32:
  nt_choose(U32,String.eq(symbol,"p125_rt_ctor1"),u => 1,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_ctor2"),u => 2,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_ctor3"),u => 3,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_ctor4"),u => 4,u => 0))))

def agy_rt_take_arity(+symbol: String) -> U32:
  nt_choose(U32,String.eq(symbol,"p125_rt_take1"),u => 1,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_take2"),u => 2,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_take3"),u => 3,u =>
  nt_choose(U32,String.eq(symbol,"p125_rt_take4"),u => 4,u => 0))))

def agy_cls_words(+cls: U32) -> U32:
  nt_choose(U32,U32.is_eq(cls,0),u => 1,u => nt_choose(U32,U32.is_eq(cls,1),v => 2,v => 4))

@unsafe
def agy_copy_words(+srcReg: U32, +dstReg: U32, +tmpReg: U32, +count: U32, +index: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(index,count),u => X188Empty{},u =>
    x188_many([
      x188_i2("movq",X187Mem{srcReg,U32.mul(index,8)},x188_reg(tmpReg,64)),
      x188_i2("movq",x188_reg(tmpReg,64),X187Mem{dstReg,U32.mul(index,8)}),
      agy_copy_words(srcReg,dstReg,tmpReg,count,U32.inc(index))]))

@unsafe
def agy_rt_ctor_text(+name: String, +symbol: String, +args: List<&2,N111Arg>, +cid: U32,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +cls = p185cc_class(count)
  +atOff = U32.mul(cls,8)
  +lenOff = U32.add(256,atOff)
  +words = agy_cls_words(cls)
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(1,64)),
    x188_i2("movzbl",X187Indexed{1,6,1,0},x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,atOff},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,atOff}),
    x188_i2("subq",X187Imm{words,0},X187Mem{8,lenOff}),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{symbol}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
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
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def agy_rt_inline_fallback(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  +stmt: N111Stmt = N111Call{name,typ,symbol,args}
  x195s_selected(x195s_pick(x195s_enabled(),stmt),stmt,ids,frame,code)

@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ args code:
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
    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)

@unsafe
def x185_float_call(name: String, typ: N111Type, symbol: String, args: List<&2,N111Arg>,
    ids: N111Ids, frame: X181Frame, code: X181Code) -> X181Code:
  agy_rt_inline_try(name,typ,symbol,args,ids,frame,code)"""

def patch(text: str, mode: str) -> str:
    if mode in ("all", "args", "args_ctor"):
        assert text.count(CALL_ARGS_OLD) == 1, "CALL_ARGS_OLD not unique"
        text = text.replace(CALL_ARGS_OLD, CALL_ARGS_NEW, 1)
    if mode in ("all", "ctor", "args_ctor"):
        assert text.count(FRAME_OLD) == 1, "FRAME_OLD not unique"
        assert text.count(CTOR_CALL_OLD) == 1, "CTOR_CALL_OLD not unique"
        text = text.replace(FRAME_OLD, FRAME_NEW, 1)
        ctor_new = CTOR_CALL_NEW
        if mode == "args_ctor":
            ctor_new = ctor_new.replace("def agy_take_inline_enabled() -> Bool: True{}", "def agy_take_inline_enabled() -> Bool: False{}")
        text = text.replace(CTOR_CALL_OLD, ctor_new, 1)
        sig = "def x186_call_arguments(+args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> X188Seq:"
        assert text.count(sig) == 1, "x186_call_arguments signature not unique"
        text = text.replace(sig, "def x186_call_arguments(args,ids,frame):", 1)
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    ap.add_argument("--mode", choices=["all", "args", "ctor", "args_ctor"], default="all")
    a = ap.parse_args()
    out = patch(a.src.read_text(), a.mode)
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched ({a.mode}) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
