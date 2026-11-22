#!/usr/bin/env python3
"""Wave 2C Track A Pass (composable cleanly on top of Wave 2B compiler_w2b.bend):
  1. Strip empty P113DIf{_, Nil{}, Nil{}} in w2_asr_strip_self (deletes 18 dead insns/iter in Mandelbrot mit).
  2. Direct Table-to-XMM (movd (%r11,%r10,8), %xmm) for x195t table lookups in w2b_x_scan + w2_tbl_store
     (eliminates 4 stack spills + 5 stack reloads per sphere in nearest & nearest.t).
  3. Direct memory-operand SSE (addss/subss/mulss/divss disp(%rbp), %xmm) in w2b_x_arith_emit.
  4. Redundant `movd %xmmA, %r32; movd %r32, %xmmA` elimination in x198qm_item.
"""
import sys
from pathlib import Path


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    n = src.count(old)
    if n != 1:
        raise RuntimeError(f"{label}: expected 1 match, got {n}")
    return src.replace(old, new, 1)


def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()

    # 1. Drop empty P113DIf{_, Nil{}, Nil{}} bottom-up in x185_d_if (so dead conds & branches vanish in one pass!)
    #    and strength-reduce mul by 2 -> add(x, x) in w2_asr_strip_self.
    src = replace_exact(
        src,
        "    case X185Dead{yb,yl} X185Dead{nb,nl}:\n"
        "      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}",
        "    case X185Dead{Nil{},yl} X185Dead{Nil{},nl}:\n"
        "      X185Dead{rest,x185_d_union(yl,nl)}\n"
        "    case X185Dead{yb,yl} X185Dead{nb,nl}:\n"
        "      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}",
        "drop empty P113DIf bottom-up in x185_d_if",
    )

    src = replace_exact(
        src,
        "    case Con{P113DIf{c,yes,no},rest}:\n"
        "      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}",
        "    case Con{P113DIf{c,yes,no},rest}:\n"
        "      Con{P113DIf{c,w2_asr_strip_self(yes),w2_asr_strip_self(no)},w2_asr_strip_self(rest)}\n"
        "    case Con{P113DScalar{N111Bin{+d,+t,+op,N111Const{2,0},+x}},+rest}:\n"
        "      nt_choose(List<&2,P113DStmt>,String.eq(op,\"mul\"),\n"
        "        u => Con{P113DScalar{N111Bin{d,t,\"add\",x,x}},w2_asr_strip_self(rest)},\n"
        "        u => Con{P113DScalar{N111Bin{d,t,op,N111Const{2,0},x}},w2_asr_strip_self(rest)})\n"
        "    case Con{P113DScalar{N111Bin{+d,+t,+op,+x,N111Const{2,0}}},+rest}:\n"
        "      nt_choose(List<&2,P113DStmt>,String.eq(op,\"mul\"),\n"
        "        u => Con{P113DScalar{N111Bin{d,t,\"add\",x,x}},w2_asr_strip_self(rest)},\n"
        "        u => Con{P113DScalar{N111Bin{d,t,op,x,N111Const{2,0}}},w2_asr_strip_self(rest)})",
        "strength-reduce mul*2 in w2_asr_strip_self",
    )

    # 1b. Preserve XMM homes across X186FloatBranch in w2b_x_scan_node (clear canonical, forbid cond, keep region)
    src = replace_exact(
        src,
        "    case X186FloatBranch{c,y,n} X186XScan{ranges,canonical}:\n"
        "      x186_x_cut(w2b_x_scan(n,cidx,x186_x_cut(w2b_x_scan(y,cidx,\n"
        "        X186XScan{x185_t_cut(x185_t_read(c,x185_t_cut(ranges))),missing()}))))",
        "    case X186FloatBranch{c,y,n} X186XScan{ranges,canonical}:\n"
        "      w2c_x_clear_canon(w2b_x_scan(n,cidx,w2c_x_clear_canon(w2b_x_scan(y,cidx,\n"
        "        X186XScan{x185_t_next(w2_x_forbid_val(c,ranges)),missing()}))))",
        "preserve XMM homes across X186FloatBranch in w2b_x_scan_node",
    )

    src = replace_exact(
        src,
        "law w2b_x_scan:",
        "@unsafe\ndef w2c_x_clear_canon(scan: X186XScan) -> X186XScan:\n"
        "  match scan:\n"
        "    case X186XScan{ranges,canonical}: X186XScan{ranges,missing()}\n\n"
        "law w2b_x_scan:",
        "add w2c_x_clear_canon helper",
    )

    # 2. Direct memory-operand SSE in w2b_x_arith_emit when right is a stack slot (X187Mem)
    src = replace_exact(
        src,
        "@unsafe\ndef w2b_x_arith_emit(+name: String, id: U32, +left: N111Value, +right: N111Value,\n"
        "    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +destination: Maybe<&2,X187Operand>, +target: X187Operand) -> X188Seq:\n"
        "  +source = x186_x_source(right,homes)\n"
        "  +direct = x186_x_direct(source,target)\n"
        "  x188_many([\n"
        "    nt_choose(X188Seq,direct,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),\n"
        "    x186_x_load(left,ids,frame,homes,target),\n"
        "    x188_i2(x185_float_arithmetic(id),\n"
        "      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),u => x188_xmm(1)),target),\n"
        "    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])",
        "@unsafe\ndef w2c_is_mem(op: Maybe<&2,X187Operand>) -> Bool:\n"
        "  match op:\n"
        "    case Some{X187Mem{b,d}}: True{}\n"
        "    case _: False{}\n\n"
        "@unsafe\ndef w2b_x_arith_emit(+name: String, id: U32, +left: N111Value, +right: N111Value,\n"
        "    +ids: N111Ids, +frame: X181Frame, +homes: KDef, +destination: Maybe<&2,X187Operand>, +target: X187Operand) -> X188Seq:\n"
        "  +source = x186_x_source(right,homes)\n"
        "  +direct = x186_x_direct(source,target)\n"
        "  +fmem = x186_float_source(right,frame)\n"
        "  +use_mem = Bool.not(x186_float_present(source)) && w2c_is_mem(fmem)\n"
        "  x188_many([\n"
        "    nt_choose(X188Seq,direct || use_mem,u => X188Empty{},u => x186_x_load(right,ids,frame,homes,x188_xmm(1))),\n"
        "    x186_x_load(left,ids,frame,homes,target),\n"
        "    x188_i2(x185_float_arithmetic(id),\n"
        "      nt_choose(X187Operand,direct,u => x186_float_operand(source,x188_xmm(1)),\n"
        "        u => nt_choose(X187Operand,use_mem,v => x186_float_operand(fmem,x188_xmm(1)),v => x188_xmm(1))),target),\n"
        "    nt_choose(X188Seq,x186_float_present(destination),u => X188Empty{},u => x186_float_result(name,frame))])",
        "direct memory-operand SSE in w2b_x_arith_emit",
    )

    # 3. Direct Table-to-XMM:
    #    - Recognize x195t 5-node sequence in w2b_x_scan so dest can receive an XMM home without cutting XMM region!
    #    - Emit movd (%r11,%r10,8), %xmm_dest in w2_tbl_store when x186_x_home(dest, homes) is Some{xmm}!
    src = replace_exact(
        src,
        "law w2b_x_scan:\n"
        "  for nodes: List<&2,X186FloatNode>\n"
        "  for +cidx: U32\n"
        "  for scan: X186XScan\n"
        "  X186XScan",
        "law w2b_x_scan:\n"
        "  for nodes: List<&2,X186FloatNode>\n"
        "  for +cidx: U32\n"
        "  for +scan: X186XScan\n"
        "  X186XScan",
        "mark +scan in law w2b_x_scan",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef w2b_x_scan(nodes,cidx,scan):\n"
        "  match nodes:\n"
        "    case Nil{}: scan\n"
        "    case Con{h,rest}: w2b_x_scan(rest,cidx,w2b_x_scan_node(h,cidx,scan))",
        "@unsafe\ndef w2c_scan_val_eq(a: N111Value, b: N111Value) -> Bool:\n"
        "  match a b:\n"
        "    case N111Local{x} N111Local{y}: String.eq(x,y)\n"
        "    case N111Const{la,ha} N111Const{lb,hb}: U32.is_eq(la,lb) && U32.is_eq(ha,hb)\n"
        "    case _ _: False{}\n\n"
        "@unsafe\ndef w2c_x_scan_tbl(+dest: String, val: N111Value, scan: X186XScan) -> X186XScan:\n"
        "  match scan:\n"
        "    case X186XScan{ranges,canonical}:\n"
        "      X186XScan{x185_t_next(x185_t_event(dest,True{},w2_x_forbid_val(val,ranges))),\n"
        "        p111v_put(canonical,dest,\"X186Canonical\",1,0)}\n\n"
        "@unsafe\ndef w2b_x_scan(nodes,cidx,scan):\n"
        "  match nodes:\n"
        "    case Nil{}: scan\n"
        "    case Con{X186FloatPlain{P113DScalar{N111Bin{+inside,N111U64{},+op,+val,N111Const{+last,0}}}},\n"
        "         Con{X186FloatBranch{N111Local{+inside2},\n"
        "               Con{X186FloatPlain{P113DScalar{N111Set{+idx1,N111U64{},+val2}}},Nil{}},\n"
        "               Con{X186FloatPlain{P113DScalar{N111Set{+idx2,N111U64{},N111Const{+last2,0}}}},Nil{}}},\n"
        "         Con{X186FloatPlain{P113DScalar{N111Bin{+bytes,N111U64{},+shlop,N111Local{+idx3},N111Const{3,0}}}},\n"
        "         Con{X186FloatPlain{P113DScalar{N111Offset{+addr,N111Symbol{+sym},N111Local{+bytes2}}}},\n"
        "         Con{X186FloatPlain{P113DScalar{N111Load{+dest,N111U64{},N111Local{+addr2},0}}},+rest}}}}}:\n"
        "      nt_choose(X186XScan,\n"
        "        String.eq(inside,\"p195t_inside\") && String.eq(inside2,\"p195t_inside\") &&\n"
        "        String.eq(op,\"ult\") && String.eq(idx1,\"p195t_index\") && String.eq(idx2,\"p195t_index\") &&\n"
        "        String.eq(idx3,\"p195t_index\") && String.eq(bytes,\"p195t_bytes\") && String.eq(bytes2,\"p195t_bytes\") &&\n"
        "        String.eq(shlop,\"shl\") && String.eq(addr,\"p195t_address\") && String.eq(addr2,\"p195t_address\") &&\n"
        "        U32.is_eq(last,last2) && w2c_scan_val_eq(val,val2),\n"
        "        u => w2b_x_scan(rest,cidx,w2c_x_scan_tbl(dest,val,scan)),\n"
        "        u => w2b_x_scan(Con{X186FloatBranch{N111Local{inside2},\n"
        "               Con{X186FloatPlain{P113DScalar{N111Set{idx1,N111U64{},val2}}},Nil{}},\n"
        "               Con{X186FloatPlain{P113DScalar{N111Set{idx2,N111U64{},N111Const{last2,0}}}},Nil{}}},\n"
        "             Con{X186FloatPlain{P113DScalar{N111Bin{bytes,N111U64{},shlop,N111Local{idx3},N111Const{3,0}}}},\n"
        "             Con{X186FloatPlain{P113DScalar{N111Offset{addr,N111Symbol{sym},N111Local{bytes2}}}},\n"
        "             Con{X186FloatPlain{P113DScalar{N111Load{dest,N111U64{},N111Local{addr2},0}}},rest}}}},cidx,\n"
        "             w2b_x_scan_node(X186FloatPlain{P113DScalar{N111Bin{inside,N111U64{},op,val,N111Const{last,0}}}},cidx,scan)))\n"
        "    case Con{h,rest}: w2b_x_scan(rest,cidx,w2b_x_scan_node(h,cidx,scan))",
        "recognize x195t table loads in w2b_x_scan",
    )

    src = replace_exact(
        src,
        "@unsafe\ndef w2_tbl_store(dest: String, sym: String, +frame: X181Frame) -> X188Seq:\n"
        "  x188_many([\n"
        "    x188_i2(\"leaq\",X187Rip{sym,0,0},x188_reg(11,64)),\n"
        "    x188_i2(\"movq\",X187Indexed{11,10,8,0},x188_reg(11,64)),\n"
        "    x181_store(dest,frame,x188_reg(11,64))])",
        "@unsafe\ndef w2_tbl_store_to(home: Maybe<&2,X187Operand>, dest: String, sym: String, +frame: X181Frame) -> X188Seq:\n"
        "  match home:\n"
        "    case Some{xmm}:\n"
        "      x188_many([\n"
        "        x188_i2(\"leaq\",X187Rip{sym,0,0},x188_reg(11,64)),\n"
        "        x188_i2(\"movd\",X187Indexed{11,10,8,0},xmm)])\n"
        "    case None{}:\n"
        "      x188_many([\n"
        "        x188_i2(\"leaq\",X187Rip{sym,0,0},x188_reg(11,64)),\n"
        "        x188_i2(\"movq\",X187Indexed{11,10,8,0},x188_reg(11,64)),\n"
        "        x181_store(dest,frame,x188_reg(11,64))])\n\n"
        "@unsafe\ndef w2_tbl_store(+dest: String, sym: String, +frame: X181Frame, homes: KDef) -> X188Seq:\n"
        "  w2_tbl_store_to(x186_x_home(dest,homes),dest,sym,frame)",
        "direct Table-to-XMM in w2_tbl_store",
    )

    src = replace_exact(
        src,
        "          v => x186_x_emit_nodes(rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame),code)),\n"
        "          v => w2_tbl_chain(val,last,rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame),code))),",
        "          v => x186_x_emit_nodes(rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame,homes),code)),\n"
        "          v => w2_tbl_chain(val,last,rest,ids,frame,homes,x181_add(w2_tbl_store(dest,sym,frame,homes),code))),",
        "pass homes to w2_tbl_store in w2_tbl_chain_go",
    )

    src = replace_exact(
        src,
        "      +code1 = x181_add(x188_cat(w2_tbl_clamp(val,last,ids,frame),w2_tbl_store(dest,sym,frame)),code)",
        "      +code1 = x181_add(x188_cat(w2_tbl_clamp(val,last,ids,frame),w2_tbl_store(dest,sym,frame,homes)),code)",
        "pass homes to w2_tbl_store in w2_x_emit_step_go",
    )

    # 4. Redundant `movd %xmmA, %r32; movd %r32, %xmmA` elimination in x198qm_item
    src = replace_exact(
        src,
        "@unsafe\ndef x198qm_item(+item: X187Parsed, +previous: X191FrameStore, +output: List<&2,X188Seq>) -> List<&2,X188Seq>:\n"
        "  match item:\n"
        "    case PInst{X187Instruction{op,[X187Target{name}]}}:\n"
        "      nt_choose(List<&2,X188Seq>,String.eq(op,\"call\") && String.eq(name,\"p111_rt_op\"),\n"
        "        u => x198qm_window(output,X188One{item}),u => Con{x191_ff_item(item,previous),output})\n"
        "    case _: Con{x191_ff_item(item,previous),output}",
        "@unsafe\ndef w2c_movd_inverse(prev: X188Seq, +r: U32, +x: U32) -> Bool:\n"
        "  match prev:\n"
        "    case X188One{PInst{X187Instruction{op,[X187Reg{px,128,True{}},X187Reg{pr,32,False{}}]}}}:\n"
        "      String.eq(op,\"movd\") && U32.is_eq(pr,r) && U32.is_eq(px,x)\n"
        "    case _: False{}\n\n"
        "@unsafe\ndef w2c_drop_movd_roundtrip(output: List<&2,X188Seq>, +r: U32, +x: U32) -> Bool:\n"
        "  match output:\n"
        "    case Con{prev,rest}: w2c_movd_inverse(prev,r,x)\n"
        "    case Nil{}: False{}\n\n"
        "@unsafe\ndef x198qm_item(+item: X187Parsed, +previous: X191FrameStore, +output: List<&2,X188Seq>) -> List<&2,X188Seq>:\n"
        "  match item:\n"
        "    case PInst{X187Instruction{op,[X187Target{name}]}}:\n"
        "      nt_choose(List<&2,X188Seq>,String.eq(op,\"call\") && String.eq(name,\"p111_rt_op\"),\n"
        "        u => x198qm_window(output,X188One{item}),u => Con{x191_ff_item(item,previous),output})\n"
        "    case PInst{X187Instruction{op,[X187Reg{r,32,False{}},X187Reg{x,128,True{}}]}}:\n"
        "      nt_choose(List<&2,X188Seq>,String.eq(op,\"movd\") && w2c_drop_movd_roundtrip(output,r,x),\n"
        "        u => output,u => Con{x191_ff_item(item,previous),output})\n"
        "    case _: Con{x191_ff_item(item,previous),output}",
        "drop redundant movd %xmmA,%r32; movd %r32,%xmmA in x198qm_item",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(src)
    print(f"Wrote {out_path} ({len(src)} bytes)")


if __name__ == "__main__":
    main()
