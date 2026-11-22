#!/usr/bin/env python3
"""Wave 4 Track W4-3: General Scalar F32 XMM Regalloc + Product Unboxing + Borrow Dead-Field Elimination.

Composable, 100% general compiler patcher:
  1. Direct 64-bit XMM->mem64 spill (`movq %xmm, disp(%rbp)`, SSE2 66 0F D6 /r)
     in x187/x186_float_publish + zero-movd U32.to_f32 in x192_float_conversion
     + raised w2b_coalesce/w2_fc_prune fuel (512) + multi-carried F32 XMM loop
     allocation in w2_xl_*.
  2. Unboxed NQBundle alias propagation in p113px_known when a virtual bundle
     binding has 0 or 2+ uses, unlocking `$product.*` workers for tail-recursive
     product-returning functions with shared product params (e.g. `columns`).
  3. Dead-field copy elimination in `$p118borrow.read.*` (`p118b_field_loads`)
     and `p128bf_fast` (`p128bf_fields`), skipping unused constructor fields.

Usage:
  python3 -B research/agy/wave4_regunbox/apply_regunbox.py [--src <in.bend>] [--dst <out.bend>]
"""

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave3b_unified/compiler.bend"
DEFAULT_DST = ROOT / "selfhost/build/agy/wave4_regunbox/compiler.bend"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {count}")
    return text.replace(old, new, 1)


def apply_all(src_text: str) -> str:
    text = src_text

    # =========================================================================
    # PASS 1: Direct 64-bit XMM->mem64 spill (SSE2 movq %xmm, m64: 66 0F D6 /r),
    #         canonicalize cold sqrtf ABI return, zero-movd U32.to_f32,
    #         raised w2b_coalesce/w2_fc_prune fuel, and multi-carried w2_xl_*.
    # =========================================================================

    # 1a. x187_e_mov: encode `movq %xmm, m64` as SSE2 `66 0F D6 /r`.
    text = replace_exact(
        text,
        '''@unsafe
def x187_e_mov(+src: X187Operand, +dst: X187Operand, +width: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{lo,hi}: x187_e_mov_immediate(dst,lo,hi,width,offset)
    case _:
      nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 136,v => 137)],U32.is_eq(width,64),
          x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u =>
      nt_choose(X187Encoded,x187_e_rm(src,width,False{}) && x187_e_reg(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 138,v => 139)],U32.is_eq(width,64),
          x187_e_index(dst),src,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error()))''',
        '''@unsafe
def x187_e_mov(+src: X187Operand, +dst: X187Operand, +width: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{lo,hi}: x187_e_mov_immediate(dst,lo,hi,width,offset)
    case _:
      nt_choose(X187Encoded,U32.is_eq(width,64) && x187_e_reg(src,128,True{}) &&
          x187_e_rm(dst,64,False{}) && Bool.not(x187_e_reg(dst,64,False{})),u =>
        x187_e_modrm(102,[15,214],False{},x187_e_index(src),dst,False{},[],offset),u =>
      nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 136,v => 137)],U32.is_eq(width,64),
          x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u =>
      nt_choose(X187Encoded,x187_e_rm(src,width,False{}) && x187_e_reg(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 138,v => 139)],U32.is_eq(width,64),
          x187_e_index(dst),src,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error())))''',
        "1a:x187_e_mov",
    )

    # 1b. x186_float_publish: direct `movq %xmm, disp(%rbp)` for stack homes (0 GPR bounce!).
    text = replace_exact(
        text,
        '''@unsafe
def x186_float_publish_to(home: Maybe<&2,X187Operand>, name: String,
    source: X187Operand, frame: X181Frame) -> X188Seq:
  match home:
    case Some{operand}: x188_i2("movd",source,operand)
    case None{}: x188_cat(x188_i2("movd",source,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x186_float_publish(+name: String, source: X187Operand, +frame: X181Frame) -> X188Seq:
  x186_float_publish_to(x186_float_home(name,frame,False{}),name,source,frame)''',
        '''@unsafe
def x186_float_publish_to(home: Maybe<&2,X187Operand>, name: String,
    source: X187Operand, frame: X181Frame) -> X188Seq:
  match home:
    case Some{X187Mem{base,disp}}: x188_i2("movq",source,X187Mem{base,disp})
    case Some{operand}: x188_i2("movd",source,operand)
    case None{}: x188_cat(x188_i2("movd",source,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x186_float_publish(+name: String, source: X187Operand, +frame: X181Frame) -> X188Seq:
  x186_float_publish_to(x186_float_home(name,frame,True{}),name,source,frame)''',
        "1b:x186_float_publish",
    )

    # 1c. Canonicalize upper 32 bits of xmm0 after cold C ABI call p200_rt_f32_sqrt_keep.
    text = replace_exact(
        text,
        '''@unsafe
def x200r_sqrt_buffer(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),x186_float_result(name,frame)])''',
        '''@unsafe
def x200r_sqrt_buffer(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x186_float_result(name,frame)])''',
        "1c:x200r_sqrt_buffer",
    )

    text = replace_exact(
        text,
        '''    x188_label(x181_label(site,frame)),x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_label(x181_label(U32.inc(site),frame)),x186_float_result(name,frame)])''',
        '''    x188_label(x181_label(site,frame)),x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_label(x181_label(U32.inc(site),frame)),x186_float_result(name,frame)])''',
        "1c:x195s_text",
    )

    text = replace_exact(
        text,
        '''@unsafe
def x200r_sqrt_values(name: String, left: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_label(x181_label(U32.inc(site),frame)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])''',
        '''@unsafe
def x200r_sqrt_values(name: String, left: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])

@unsafe
def x200r_sqrt_core(name: String, left: N111Value, ids: N111Ids,
    +frame: X181Frame, +homes: KDef, +site: U32) -> X188Seq:
  x188_many([x186_x_load(left,ids,frame,homes,x188_xmm(0)),
    x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("ucomiss",x188_xmm(0),x188_xmm(1)),
    x188_i1("ja",X187Target{x181_label(site,frame)}),
    x188_i2("sqrtss",x188_xmm(0),x188_xmm(0)),
    x188_i1("jmp",X187Target{x181_label(U32.inc(site),frame)}),
    x188_label(x181_label(site,frame)),
    x188_i1("call",X187Target{"p200_rt_f32_sqrt_keep"}),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_label(x181_label(U32.inc(site),frame)),
    x186_x_publish(name,x188_xmm(0),frame,homes)])''',
        "1c:x200r_sqrt_values_core",
    )

    # 1d. Eliminate 4x movd round-trip in U32.to_f32 (id==23) in x192_float_conversion & x186_u32_float_text.
    text = replace_exact(
        text,
        '''@unsafe
def x186_u32_float_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(10,32),x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))])''',
        '''@unsafe
def x186_u32_float_text(name: String, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movl",X187Mem{10,0},x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x186_float_result(name,frame)])''',
        "1d:x186_u32_float_text",
    )

    text = replace_exact(
        text,
        '''@unsafe
def x192_float_conversion(+name: String, id: U32, value: N111Value,
    ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(value,ids,frame,homes,x188_xmm(0)),
    x192_float_conversion_core(id),x186_x_compare_result(x186_x_home(name,homes),name,frame)])''',
        '''@unsafe
def w4_u32_to_r10(source: Maybe<&2,X187Operand>, value: N111Value, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match source:
    case Some{operand}: x188_i2("movd",operand,x188_reg(10,32))
    case None{}: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movl",x188_reg(10,32),x188_reg(10,32)))

@unsafe
def w4_u32_to_f32(+name: String, +value: N111Value, ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  +dest = x186_x_home(name,homes)
  +target = x186_float_operand(dest,x188_xmm(0))
  x188_many([w4_u32_to_r10(x186_x_source(value,homes),value,ids,frame),
    x188_i2("pxor",target,target),
    x188_i2("cvtsi2ssq",x188_reg(10,64),target),
    nt_choose(X188Seq,x186_float_present(dest),u => X188Empty{},u => x186_float_publish(name,target,frame))])

@unsafe
def x192_float_conversion(+name: String, +id: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,23),
    u => w4_u32_to_f32(name,value,ids,frame,homes),
    u => x188_many([x186_x_load(value,ids,frame,homes,x188_xmm(0)),
      x192_float_conversion_core(id),x186_x_compare_result(x186_x_home(name,homes),name,frame)]))''',
        "1d:x192_float_conversion",
    )

    # 1e. Raise w2_fc_prune and w2b_coalesce fuel from 128/64 to 512 so large
    #     float kernels (like nbody's loop3) don't disable copy coalescing.
    text = replace_exact(
        text,
        '''    case Con{X186FloatPlain{P113DScalar{N111Set{+dest,N111U64{},N111Const{+lo,+hi}}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,w2_dead_in(dest,rest,tail,128),''',
        '''    case Con{X186FloatPlain{P113DScalar{N111Set{+dest,N111U64{},N111Const{+lo,+hi}}}},+rest}:
      nt_choose(List<&2,X186FloatNode>,w2_dead_in(dest,rest,tail,512),''',
        "1e:w2_fc_prune_fuel",
    )

    text = replace_exact(
        text,
        '''      nt_choose(List<&2,X186FloatNode>,agy_str_eq(tmp,tmp2) && Bool.not(w2_names_has(dst,params)) &&
          Bool.not(x181_register_reserved(dst)) && w2_dead_in(tmp,rest,tail,64),''',
        '''      nt_choose(List<&2,X186FloatNode>,agy_str_eq(tmp,tmp2) && Bool.not(w2_names_has(dst,params)) &&
          Bool.not(x181_register_reserved(dst)) && w2_dead_in(tmp,rest,tail,512),''',
        "1e:w2b_coalesce_fuel",
    )

    # 1f. Multi-carried F32 XMM loop register allocation in w2_xl_*.
    #     Extends w2_xl_pick_carried from 1 carried float param to all independent
    #     carried float params that fit in remaining XMM registers (xmm10..xmm15).
    text = replace_exact(
        text,
        '''        case P113DAgain{+vals}:
          +ce = p111v_get(homes,"$w2_carried_xmm")
          +cn = p111v_get(homes,"$w2_carried_name")
          +has_c = agy_str_eq(dk(ce),"W2Carried")
          +code2 = nt_choose(X181Code,has_c,
                     u => x181_add(w2_xl_again_update(w2_xl_nth(vals,da(ce)),dx(ce),ids,frame,homes),code),
                     u => code)
          +stmt2 = nt_choose(P113DStmt,has_c,
                     u => P113DAgain{w2b_replace_nth(vals,da(ce),N111Local{dk(cn)})},
                     u => stmt)
          x181_stmt(stmt2,ids,frame,code2)''',
        '''        case P113DAgain{+vals}:
          +cnt = da(p111v_get(homes,"$w4_carried_count"))
          +code2 = nt_choose(X181Code,U32.is_gt(cnt,0),
                     u => x181_add(w4_xl_again_updates(0,cnt,vals,ids,frame,homes),code),
                     u => code)
          +stmt2 = nt_choose(P113DStmt,U32.is_gt(cnt,0),
                     u => P113DAgain{w4_xl_again_rewrite(0,cnt,vals,homes)},
                     u => stmt)
          x181_stmt(stmt2,ids,frame,code2)''',
        "1f:P113DAgain_multi",
    )

    text = replace_exact(
        text,
        '''@unsafe
def w2_xl_again_update(found: Maybe<&2,N111Value>, +xmm: U32, ids: N111Ids, frame: X181Frame, homes: KDef) -> X188Seq:
  match found:
    case Some{val}: x186_x_load(val,ids,frame,homes,x188_xmm(xmm))
    case None{}: X188Empty{}''',
        '''@unsafe
def w2_xl_again_update(found: Maybe<&2,N111Value>, +xmm: U32, ids: N111Ids, frame: X181Frame, homes: KDef) -> X188Seq:
  match found:
    case Some{val}: x186_x_load(val,ids,frame,homes,x188_xmm(xmm))
    case None{}: X188Empty{}

law w4_xl_again_updates:
  for +i: U32
  for +cnt: U32
  for +vals: List<&2,N111Value>
  for +ids: N111Ids
  for +frame: X181Frame
  for +homes: KDef
  X188Seq

@unsafe
def w4_xl_again_step(+i: U32, +cnt: U32, +vals: List<&2,N111Value>,
    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +ce: KDef) -> X188Seq:
  x188_cat(w2_xl_again_update(w2_xl_nth(vals,da(ce)),dx(ce),ids,frame,homes),
    w4_xl_again_updates(U32.inc(i),cnt,vals,ids,frame,homes))

@unsafe
def w4_xl_again_updates(i,cnt,vals,ids,frame,homes):
  nt_choose(X188Seq,U32.is_ge(i,cnt),u => X188Empty{},
    u => w4_xl_again_step(i,cnt,vals,ids,frame,homes,p111v_get(homes,"$w4_cx_" ++ U32.show(i))))

law w4_xl_again_rewrite:
  for +i: U32
  for +cnt: U32
  for +vals: List<&2,N111Value>
  for +homes: KDef
  List<&2,N111Value>

@unsafe
def w4_xl_again_rewrite_step(+i: U32, +cnt: U32, +vals: List<&2,N111Value>, +homes: KDef,
    +ce: KDef, +cn: KDef) -> List<&2,N111Value>:
  w4_xl_again_rewrite(U32.inc(i),cnt,w2b_replace_nth(vals,da(ce),N111Local{dk(cn)}),homes)

@unsafe
def w4_xl_again_rewrite(i,cnt,vals,homes):
  nt_choose(List<&2,N111Value>,U32.is_ge(i,cnt),u => vals,
    u => w4_xl_again_rewrite_step(i,cnt,vals,homes,
      p111v_get(homes,"$w4_cx_" ++ U32.show(i)),p111v_get(homes,"$w4_cn_" ++ U32.show(i))))''',
        "1f:w4_xl_again_helpers",
    )

    text = replace_exact(
        text,
        '''type W2XLoopPlan is Data:
  W2XLoopPlan{+homes: KDef, +pre: X188Seq, +carried: String, +carriedIdx: U32, +carriedXmm: U32, +active: Bool}''',
        '''type W4Carried is Data:
  W4Carried{+name: String, +idx: U32, +xmm: U32}

type W2XLoopPlan is Data:
  W2XLoopPlan{+homes: KDef, +pre: X188Seq, +carried: List<&2,W4Carried>, +active: Bool}''',
        "1f:W2XLoopPlan_type",
    )

    text = replace_exact(
        text,
        '''@unsafe
def w2b_x_again_reads(vals: List<&2,N111Value>, +idx: U32, +cidx: U32, +ranges: X185TScan) -> X185TScan:
  match vals:
    case Nil{}: ranges
    case Con{+v,rest}:
      +r1 = nt_choose(X185TScan,U32.is_eq(idx,cidx),
              u => x185_t_read(v,ranges),
              u => w2_x_forbid_val(v,ranges))
      w2b_x_again_reads(rest,U32.inc(idx),cidx,r1)''',
        '''@unsafe
def w4_u32_mem(+x: U32, xs: List<&2,U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h,rest}: U32.is_eq(x,h) || w4_u32_mem(x,rest)

@unsafe
def w2b_x_again_reads(vals: List<&2,N111Value>, +idx: U32, +cidxs: List<&2,U32>, +ranges: X185TScan) -> X185TScan:
  match vals:
    case Nil{}: ranges
    case Con{+v,rest}:
      +r1 = nt_choose(X185TScan,w4_u32_mem(idx,cidxs),
              u => x185_t_read(v,ranges),
              u => w2_x_forbid_val(v,ranges))
      w2b_x_again_reads(rest,U32.inc(idx),cidxs,r1)''',
        "1f:w2b_x_again_reads",
    )

    text = replace_exact(
        text,
        '''law w2b_x_scan:
  for nodes: List<&2,X186FloatNode>
  for +cidx: U32
  for +scan: X186XScan
  X186XScan

@unsafe
def w2b_x_scan_node(node: X186FloatNode, +cidx: U32, +scan: X186XScan) -> X186XScan:''',
        '''law w2b_x_scan:
  for nodes: List<&2,X186FloatNode>
  for +cidx: List<&2,U32>
  for +scan: X186XScan
  X186XScan

@unsafe
def w2b_x_scan_node(node: X186FloatNode, +cidx: List<&2,U32>, +scan: X186XScan) -> X186XScan:''',
        "1f:w2b_x_scan_sig",
    )

    text = replace_exact(
        text,
        '''@unsafe
def x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: U32) -> KDef:''',
        '''@unsafe
def x186_x_homes_capped(params: List<&2,String>, setup: List<&2,P113DStmt>, nodes: List<&2,X186FloatNode>, +cidx: List<&2,U32>) -> KDef:''',
        "1f:x186_x_homes_capped_sig",
    )

    text = replace_exact(
        text,
        '''@unsafe
def w2_xl_pick_carried(params: List<&2,String>, +idx: U32, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +st: W2XLAlloc) -> W2XLoopPlan:
  match params st:
    case Nil{} W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,"",0,0,True{}}
    case Con{+p,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLoopPlan,U32.is_lt(reg,16) && Bool.not(w2_xl_param_inv(p,idx,nodes)) &&
          w2_xl_param_nowrite(p,nodes) && w2_xl_float_used(p,nodes) && w2_xl_only_float(p,nodes),
        u => W2XLoopPlan{p111v_put(homes,p,"X186Xmm",U32.sub(reg,2),0),
               x188_cat(pre,x186_float_load(N111Local{p},ids,frame,x188_xmm(reg))),p,idx,reg,True{}},
        u => w2_xl_pick_carried(rest,U32.inc(idx),nodes,ids,frame,st))

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def w2_xl_tail_params(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{state,rest}: w2_xl_tail_skip(rest)

@unsafe
def w2b_find_carried_idx(params: List<&2,String>, +idx: U32, +nodes: List<&2,X186FloatNode>) -> U32:
  match params:
    case Nil{}: 999999
    case Con{+p,rest}:
      nt_choose(U32,Bool.not(w2_xl_param_inv(p,idx,nodes)) && w2_xl_param_nowrite(p,nodes) &&
          w2_xl_float_used(p,nodes) && w2_xl_only_float(p,nodes),
        u => idx,u => w2b_find_carried_idx(rest,U32.inc(idx),nodes))

@unsafe
def w2b_finish_plan(carried: String, cidx: U32, cxmm: U32, st: W2XLAlloc) -> W2XLoopPlan:
  match st:
    case W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,carried,cidx,cxmm,True{}}

@unsafe
def w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  match plan:
    case W2XLoopPlan{homes,pre,carried,cidx,+cxmm,active}:
      +next_reg = nt_choose(U32,U32.is_gt(cxmm,0),u => U32.inc(cxmm),u => 10)
      w2b_finish_plan(carried,cidx,cxmm,
        w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
          w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,next_reg})))

@unsafe
def w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +tparams = w2_xl_tail_params(params)
  +cidx_pre = w2b_find_carried_idx(tparams,0,nodes)
  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),
    u => w2b_plan_after_carried(
           w2_xl_pick_carried(tparams,0,nodes,ids,frame,
             W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidx_pre),X188Empty{},10}),
           tparams,nodes,ids,frame),
    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},"",0,0,False{}})

@unsafe
def w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  match plan:
    case W2XLoopPlan{+homes,pre,+carried,cidx,+cxmm,active}:
      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),
                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))
      +homes2 = nt_choose(KDef,U32.is_gt(cxmm,0),
                  u => p111v_put(p111v_put(homes,"$w2_carried_xmm","W2Carried",cidx,cxmm),"$w2_carried_name",carried,0,0),
                  u => homes)
      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))''',
        '''@unsafe
def w4_xl_val_not_other_param(found: Maybe<&2,N111Value>, +self: String, +tparams: List<&2,String>) -> Bool:
  match found:
    case Some{N111Local{+x}}: agy_str_eq(x,self) || Bool.not(w2_names_has(x,tparams))
    case _: True{}

law w4_xl_again_indep:
  for +self: String
  for +idx: U32
  for +tparams: List<&2,String>
  for nodes: List<&2,X186FloatNode>
  Bool

@unsafe
def w4_xl_again_indep(self,idx,tparams,nodes):
  match nodes:
    case Nil{}: True{}
    case Con{X186FloatPlain{P113DAgain{vals}},rest}:
      w4_xl_val_not_other_param(w2_xl_nth(vals,idx),self,tparams) && w4_xl_again_indep(self,idx,tparams,rest)
    case Con{X186FloatBranch{c,y,n},rest}:
      w4_xl_again_indep(self,idx,tparams,y) && w4_xl_again_indep(self,idx,tparams,n) && w4_xl_again_indep(self,idx,tparams,rest)
    case Con{h,rest}: w4_xl_again_indep(self,idx,tparams,rest)

@unsafe
def w4_xl_carried_ok(+p: String, +idx: U32, +first: Bool, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>) -> Bool:
  Bool.not(w2_xl_param_inv(p,idx,nodes)) && w2_xl_param_nowrite(p,nodes) &&
    w2_xl_float_used(p,nodes) && w2_xl_only_float(p,nodes) &&
    (first || w4_xl_again_indep(p,idx,tparams,nodes))

@unsafe
def w2_xl_tail_skip(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,agy_str_eq(head,"__x181_result_out"),u => rest,u => params)

@unsafe
def w2_xl_tail_params(params: List<&2,String>) -> List<&2,String>:
  match params:
    case Nil{}: []
    case Con{state,rest}: w2_xl_tail_skip(rest)

@unsafe
def w4_carried_idxs(cs: List<&2,W4Carried>) -> List<&2,U32>:
  match cs:
    case Nil{}: []
    case Con{W4Carried{n,idx,xmm},rest}: Con{idx,w4_carried_idxs(rest)}

@unsafe
def w4_plan_carried(plan: W2XLoopPlan) -> List<&2,W4Carried>:
  match plan:
    case W2XLoopPlan{homes,pre,carried,active}: carried

@unsafe
def w4_xl_pick_first(params: List<&2,String>, +idx: U32, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +st: W2XLAlloc) -> W2XLoopPlan:
  match params st:
    case Nil{} W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,[],True{}}
    case Con{+p,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLoopPlan,U32.is_lt(reg,16) && w4_xl_carried_ok(p,idx,True{},tparams,nodes),
        u => W2XLoopPlan{p111v_put(homes,p,"X186Xmm",U32.sub(reg,2),0),
               x188_cat(pre,x186_float_load(N111Local{p},ids,frame,x188_xmm(reg))),[W4Carried{p,idx,reg}],True{}},
        u => w4_xl_pick_first(rest,U32.inc(idx),tparams,nodes,ids,frame,st))

@unsafe
def w4_xl_pick_more(params: List<&2,String>, +idx: U32, +skipIdx: U32, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame, +st: W2XLAlloc, +acc: List<&2,W4Carried>) -> W2XLoopPlan:
  match params st:
    case Nil{} W2XLAlloc{homes,pre,reg}: W2XLoopPlan{homes,pre,nt_reverse(W4Carried,acc,[]),True{}}
    case Con{+p,+rest} W2XLAlloc{+homes,+pre,+reg}:
      nt_choose(W2XLoopPlan,U32.is_lt(reg,16) && Bool.not(U32.is_eq(idx,skipIdx)) &&
          w4_xl_carried_ok(p,idx,False{},tparams,nodes),
        u => w4_xl_pick_more(rest,U32.inc(idx),skipIdx,tparams,nodes,ids,frame,
               W2XLAlloc{p111v_put(homes,p,"X186Xmm",U32.sub(reg,2),0),
                 x188_cat(pre,x186_float_load(N111Local{p},ids,frame,x188_xmm(reg))),U32.inc(reg)},
               Con{W4Carried{p,idx,reg},acc}),
        u => w4_xl_pick_more(rest,U32.inc(idx),skipIdx,tparams,nodes,ids,frame,st,acc))

@unsafe
def w4_xl_alloc_plan(st: W2XLAlloc) -> W2XLoopPlan:
  match st:
    case W2XLAlloc{h1,p1,r1}: W2XLoopPlan{h1,p1,[],True{}}

@unsafe
def w2b_plan_after_carried(plan: W2XLoopPlan, +tparams: List<&2,String>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  match plan:
    case W2XLoopPlan{homes,pre,carried,active}:
      match carried:
        case Con{W4Carried{+cname,+cidx,+cxmm},Nil{}}:
          +st1 = w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
                   w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,U32.inc(cxmm)}))
          w4_xl_pick_more(tparams,0,cidx,tparams,nodes,ids,frame,st1,[W4Carried{cname,cidx,cxmm}])
        case _:
          w4_xl_alloc_plan(w2_xl_assign_consts(nt_reverse(U32,w2_xl_consts(nodes,[]),[]),
            w2_xl_assign_inv(tparams,0,nodes,ids,frame,W2XLAlloc{homes,pre,10})))

@unsafe
def w4_xl_build_loop(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +tparams: List<&2,String>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +probe = w2b_plan_after_carried(
             w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,W2XLAlloc{missing(),X188Empty{},10}),
             tparams,nodes,ids,frame)
  +cidxs = w4_carried_idxs(w4_plan_carried(probe))
  w2b_plan_after_carried(
    w4_xl_pick_first(tparams,0,tparams,nodes,ids,frame,
      W2XLAlloc{x186_x_homes_capped(params,setup,nodes,cidxs),X188Empty{},10}),
    tparams,nodes,ids,frame)

@unsafe
def w2_xl_plan(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +nodes: List<&2,X186FloatNode>,
    +ids: N111Ids, +frame: X181Frame) -> W2XLoopPlan:
  +tparams = w2_xl_tail_params(params)
  nt_choose(W2XLoopPlan,w2_xl_safe_nodes(nodes) && w2_xl_has_again(nodes),
    u => w4_xl_build_loop(params,setup,tparams,nodes,ids,frame),
    u => W2XLoopPlan{x186_x_homes(params,setup,nodes),X188Empty{},[],False{}})

@unsafe
def w4_xl_store_carried(cs: List<&2,W4Carried>, +i: U32, +homes: KDef) -> KDef:
  match cs:
    case Nil{}: p111v_put(homes,"$w4_carried_count","W4CarriedCnt",i,0)
    case Con{W4Carried{cname,cidx,cxmm},rest}:
      w4_xl_store_carried(rest,U32.inc(i),
        p111v_put(p111v_put(homes,"$w4_cx_" ++ U32.show(i),"W4Carried",cidx,cxmm),"$w4_cn_" ++ U32.show(i),cname,0,0))

@unsafe
def w2_xl_emit_with_plan(plan: W2XLoopPlan, +symbol: String, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>, +ids: N111Ids, +frame: X181Frame) -> X181Output:
  match plan:
    case W2XLoopPlan{+homes,pre,+carried,active}:
      +start = x181_add(x188_cat(pre,x188_label(x181_loop_label(frame))),
                 x181_stmts(setup,ids,frame,X181Code{[x181_prologue(frame)],0,False{},""}))
      +homes2 = w4_xl_store_carried(carried,0,homes)
      x181_function_done(symbol,x186_x_emit_nodes(nodes,ids,frame,homes2,start))''',
        "1f:w2_xl_multi_carried",
    )

    # =========================================================================
    # PASS 2: Unboxed NQBundle alias propagation in p113px_known.
    #         When `let id = NQBundle(ctor, [Var...])` has 0 or 2+ uses,
    #         substitute the virtual NQBundle directly into `body` instead of
    #         boxing it onto the heap. Ownership (keep/drop) is handled
    #         automatically on the individual fields by p113pl_partition.
    # =========================================================================
    text = replace_exact(
        text,
        '''@unsafe
def p113px_known(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +body = kt("NSeqLet","",0,0,p113px_terms(rest))
  nt_choose(P113DCode,p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => p113px_boxed(book,value,rest,env,id,target,n))''',
        '''@unsafe
def p113px_known(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +target: P113PTarget, +n: U32, +shape: KTerm) -> P113DCode:
  +body = kt("NSeqLet","",0,0,p113px_terms(rest))
  nt_choose(P113DCode,p113p_bindable(body,id),
    u => p113pl_bind_flat(book,value,body,env,id,target,n,shape),
    u => nt_choose(P113DCode,agy_str_eq(tg(value),"NQBundle") && p113df_vars(ks(value)),
      v => p113pl_lower(book,subst(body,id,value),env,target,n),
      v => p113px_boxed(book,value,rest,env,id,target,n)))''',
        "2:p113px_known_bundle_alias",
    )

    # =========================================================================
    # PASS 3: Eliminate Dead-Field Copies in `$p118borrow.read.*` & `p128bf_fast`.
    #         (a) In `p118b_field_loads`, only load fields actually used in `yes`.
    #         (b) In `x185_late_stmts`, compute exact bitmask of `scratch` field
    #             offsets loaded immediately after `p118_rt_borrow_fields` (when
    #             `scratch` is not read later) and only copy those fields in
    #             `p128bf_fields`.
    # =========================================================================
    text = replace_exact(
        text,
        '''@unsafe
def p118b_field_loads(fields: List<&2,KTerm>, +i: U32) -> List<&2,N111Stmt>:
  match fields:
    case Nil{}: []
    case Con{field,rest}: Con{N111Load{"v_" ++ U32.show(ix(field)),N111U64{},N111Local{"scratch"},U32.mul(i,8)},p118b_field_loads(rest,U32.inc(i))}


@unsafe
def p118b_reads(+layout: NO_Layout, +fields: List<&2,KTerm>, +word: N111Value) -> List<&2,N111Stmt>:
  match layout:
    case NO_Layout{key,+ctor,+storage,+width}:
      nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Boxed"),
        u => Con{N111Call{"p118b_read_status",N111U64{},"p118_rt_borrow_fields",
          [p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(width)]},p118b_field_loads(fields,0)},
        u => nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Nullary"),v => [],v =>
          nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Succ"),
            w => [N111Bin{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},"sub",word,N111Const{1,0}}],
            w => [N111Set{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},word}])) )


@unsafe
def p118b_match(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32, found: Maybe<&2,NO_Layout>) -> P113DCode:
  match found:
    case None{}: p113d_fail("borrowed residual: absent layout",n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key,+ctor,storage,width}:
          +word : N111Value = N111Local{nc_word(ix(kid(t,0)),env)}
          +fields = ks(kid(t,1))
          +yes = p118b_lower(kid(t,2),no_bind_fields(fields,env),params,layouts,n)
          +no = p118b_lower(kid(t,3),env,params,layouts,p113d_fresh(yes))
          p113d_prepend(p111_test(ctor,word),p113d_branch(N111Local{"match_condition"},
            p113d_prepend(p118b_reads(layout,fields,word),yes),no))''',
        '''@unsafe
def p118b_field_loads(fields: List<&2,KTerm>, +yesTerm: KTerm, +i: U32) -> List<&2,N111Stmt>:
  match fields:
    case Nil{}: []
    case Con{+field,+rest}:
      nt_choose(List<&2,N111Stmt>,U32.is_gt(nq_uses(yesTerm,ix(field)),0),
        u => Con{N111Load{"v_" ++ U32.show(ix(field)),N111U64{},N111Local{"scratch"},U32.mul(i,8)},p118b_field_loads(rest,yesTerm,U32.inc(i))},
        u => p118b_field_loads(rest,yesTerm,U32.inc(i)))


@unsafe
def p118b_reads(+layout: NO_Layout, +fields: List<&2,KTerm>, +yesTerm: KTerm, +word: N111Value) -> List<&2,N111Stmt>:
  match layout:
    case NO_Layout{key,+ctor,+storage,+width}:
      nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Boxed"),
        u => Con{N111Call{"p118b_read_status",N111U64{},"p118_rt_borrow_fields",
          [p111_state(),p111_word(word),p111_scratch(),N111Arg{N111U32{},N111CtorId{ctor}},p111_u32(width)]},p118b_field_loads(fields,yesTerm,0)},
        u => nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Nullary"),v => [],v =>
          nt_choose(List<&2,N111Stmt>,agy_str_eq(storage,"Succ"),
            w => [N111Bin{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},"sub",word,N111Const{1,0}}],
            w => [N111Set{"v_" ++ U32.show(ix(kid(kt("","",0,0,fields),0))),N111U64{},word}])) )


@unsafe
def p118b_match(+t: KTerm, +env: List<&2,NC_Binding>, +params: List<&2,NC_Binding>, +layouts: List<&2,NO_Layout>, +n: U32, found: Maybe<&2,NO_Layout>) -> P113DCode:
  match found:
    case None{}: p113d_fail("borrowed residual: absent layout",n)
    case Some{+layout}:
      match layout:
        case NO_Layout{key,+ctor,storage,width}:
          +word : N111Value = N111Local{nc_word(ix(kid(t,0)),env)}
          +fields = ks(kid(t,1))
          +yesTerm = kid(t,2)
          +yes = p118b_lower(yesTerm,no_bind_fields(fields,env),params,layouts,n)
          +no = p118b_lower(kid(t,3),env,params,layouts,p113d_fresh(yes))
          p113d_prepend(p111_test(ctor,word),p113d_branch(N111Local{"match_condition"},
            p113d_prepend(p118b_reads(layout,fields,yesTerm,word),yes),no))''',
        "3a:p118b_field_loads",
    )

    text = replace_exact(
        text,
        '''@unsafe
def p128bf_fields(+buffer: String, +count: U32, +site: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    Con{N111Load{p114t_name(site,"borrow_field_" ++ U32.show(index)),N111U64{},p114t_local(site,"borrow_fields"),U32.mul(index,8)},
    Con{N111Store{N111U64{},N111Local{buffer},U32.mul(index,8),p114t_local(site,"borrow_field_" ++ U32.show(index))},
      p128bf_fields(buffer,count,site,U32.inc(index))}})


@unsafe
def p128bf_fast(+dest: String, +buffer: String, +count: U32, +site: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}},
     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111If{p114t_local(site,"borrow_rfc_bit"),p128bf_rfc(site),[]},
     N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
     N111Offset{p114t_name(site,"borrow_fields"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_field_bytes")}],
    nt_append(N111Stmt,p128bf_fields(buffer,count,site,0),[N111Set{dest,N111U64{},N111Const{count,0}}]))''',
        '''@unsafe
def p128bf_fields(+buffer: String, +count: U32, +site: U32, +index: U32, +mask: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(index,count),u => [],u =>
    nt_choose(List<&2,N111Stmt>,U32.is_ne(U32.and(mask,U32.shln(1,U32.to_nat(index))),0),
      v => Con{N111Load{p114t_name(site,"borrow_field_" ++ U32.show(index)),N111U64{},p114t_local(site,"borrow_fields"),U32.mul(index,8)},
           Con{N111Store{N111U64{},N111Local{buffer},U32.mul(index,8),p114t_local(site,"borrow_field_" ++ U32.show(index))},
             p128bf_fields(buffer,count,site,U32.inc(index),mask)}},
      v => p128bf_fields(buffer,count,site,U32.inc(index),mask)))


@unsafe
def p128bf_fast(+dest: String, +buffer: String, +count: U32, +site: U32, +mask: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,
    [N111Load{p114t_name(site,"borrow_heap"),N111Ptr{},N111Local{"state"},0},
     N111Bin{p114t_name(site,"borrow_location"),N111U64{},"and",p114t_local(site,"borrow_word"),N111Const{4294967295,255}},
     N111Bin{p114t_name(site,"borrow_rfc_bit"),N111U64{},"shr",p114t_local(site,"borrow_word"),N111Const{63,0}},
     N111If{p114t_local(site,"borrow_rfc_bit"),p128bf_rfc(site),[]},
     N111Bin{p114t_name(site,"borrow_field_bytes"),N111U64{},"shl",p114t_local(site,"borrow_location"),N111Const{3,0}},
     N111Offset{p114t_name(site,"borrow_fields"),p114t_local(site,"borrow_heap"),p114t_local(site,"borrow_field_bytes")}],
    nt_append(N111Stmt,p128bf_fields(buffer,count,site,0,mask),[N111Set{dest,N111U64{},N111Const{count,0}}]))''',
        "3b:p128bf_fields_mask",
    )

    text = replace_exact(
        text,
        '''@unsafe
def x185_late_borrow(+stmt: N111Stmt, +ids: N111Ids, +site: U32, read: P128BFRead) -> List<&2,N111Stmt>:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}:
      nt_append(N111Stmt,p128bf_guard(term,ctor,site),
        [N111If{p114t_local(site,"borrow_guard"),p128bf_fast(dest,buffer,count,site),[stmt]}])
    case _: x185_late_previous(stmt,ids,site,p126nt_expand(stmt,site))''',
        '''law w4_bf_no_buf_load_scalars:
  for +buf: String
  for body: List<&2,N111Stmt>
  Bool

@unsafe
def w4_bf_no_buf_load_scalar(+buf: String, stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Load{d,t,N111Local{b},off}: Bool.not(agy_str_eq(b,buf))
    case N111If{c,yes,no}: w4_bf_no_buf_load_scalars(buf,yes) && w4_bf_no_buf_load_scalars(buf,no)
    case _: True{}

@unsafe
def w4_bf_no_buf_load_scalars(buf,body):
  match body:
    case Nil{}: True{}
    case Con{h,rest}: w4_bf_no_buf_load_scalar(buf,h) && w4_bf_no_buf_load_scalars(buf,rest)

law w4_bf_no_buf_load:
  for +buf: String
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def w4_bf_no_buf_load(buf,body):
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{N111Call{d,t,sym,args}},+rest}:
      nt_choose(Bool,agy_str_eq(sym,"p118_rt_borrow_fields"),u => True{},u => w4_bf_no_buf_load(buf,rest))
    case Con{P113DScalar{s},rest}: w4_bf_no_buf_load_scalar(buf,s) && w4_bf_no_buf_load(buf,rest)
    case Con{P113DIf{c,y,n},rest}:
      w4_bf_no_buf_load(buf,y) && w4_bf_no_buf_load(buf,n) && w4_bf_no_buf_load(buf,rest)
    case Con{h,rest}: w4_bf_no_buf_load(buf,rest)

@unsafe
def w4_bf_scan_loads(+buf: String, +count: U32, body: List<&2,P113DStmt>, +mask: U32) -> U32:
  match body:
    case Con{P113DScalar{N111Load{+d,N111U64{},N111Local{+b},+off}},+rest}:
      nt_choose(U32,agy_str_eq(b,buf) && U32.is_eq(U32.mod(off,8),0) && U32.is_lt(U32.div(off,8),count),
        u => w4_bf_scan_loads(buf,count,rest,U32.or(mask,U32.shln(1,U32.to_nat(U32.div(off,8))))),
        u => nt_choose(U32,w4_bf_no_buf_load(buf,Con{P113DScalar{N111Load{d,N111U64{},N111Local{b},off}},rest}),u2 => mask,u2 => 255))
    case _:
      nt_choose(U32,w4_bf_no_buf_load(buf,body),u => mask,u => 255)

@unsafe
def x185_late_borrow(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +mask: U32, read: P128BFRead) -> List<&2,N111Stmt>:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}:
      nt_append(N111Stmt,p128bf_guard(term,ctor,site),
        [N111If{p114t_local(site,"borrow_guard"),p128bf_fast(dest,buffer,count,site,mask),[stmt]}])
    case _: x185_late_previous(stmt,ids,site,p126nt_expand(stmt,site))''',
        "3b:x185_late_borrow_mask",
    )

    text = replace_exact(
        text,
        '''@unsafe
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
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))''',
        '''@unsafe
def w4_bf_mask_read(+rest: List<&2,P113DStmt>, read: P128BFRead) -> U32:
  match read:
    case P128BFRead{dest,term,buffer,ctor,count}: w4_bf_scan_loads(buffer,count,rest,0)
    case _: 255

@unsafe
def w4_bf_mask_for(+stmt: N111Stmt, +rest: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> U32:
  w4_bf_mask_read(rest,p128bf_match(stmt,ids,site))

@unsafe
def x185_late_scalar(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_lt(site,4294967200),
    u => x186_late_char(stmt,ids,site,bfMask,p186ch_expand(stmt)),u => p112a_expand(3,stmt))

def x186_transport_enabled() -> Bool: True{}

@unsafe
def x186_late_char(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),u =>
        x186_late_registers(stmt,ids,site,bfMask,nt_choose(P114TExpansion,x186_transport_enabled(),
          v => p186rt_expand(stmt,ids,site),v => P114TExpansion{[stmt],False{}})))

@unsafe
def x186_late_registers(+stmt: N111Stmt, +ids: N111Ids, +site: U32, +bfMask: U32, expansion: P114TExpansion) -> List<&2,N111Stmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      nt_choose(List<&2,N111Stmt>,changed,u => x185_late_accessors(body),
        u => x185_late_borrow(stmt,ids,site,bfMask,p128bf_match(stmt,ids,site)))

@unsafe
def x185_late_stmts(body: List<&2,P113DStmt>, +ids: N111Ids, +site: U32) -> P113ABody:
  match body:
    case Nil{}: P113ABody{[],site}
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x185_late_yes(condition,x181_scalar_rows(no),rest,ids,x185_late_stmts(x181_scalar_rows(yes),ids,site))
    case Con{P113DScalar{+stmt},+rest}:
      p113a_prefix(x181_scalar_rows(x185_late_scalar(stmt,ids,site,w4_bf_mask_for(stmt,rest,ids,site))),
        x185_late_stmts(rest,ids,nt_choose(U32,U32.is_lt(site,4294967200),u => U32.inc(site),u => site)))''',
        "3b:x185_late_stmts_mask",
    )

    return text


def main():
    ap = argparse.ArgumentParser(description="Apply Wave 4 Track W4-3 general optimizations")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    args = ap.parse_args()

    src_text = args.src.read_text()
    out_text = apply_all(src_text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out_text)
    print(f"Wrote {args.dst} ({len(out_text)} bytes, delta={len(out_text) - len(src_text):+d} bytes)")


if __name__ == "__main__":
    main()
