#!/usr/bin/env python3
"""Apply O2-E (`x187_priv` / `x187_pub` Core Codegen: `x181` / `x185` / `x187_encode`) speedups.

Idempotent surgical patch against `selfhost/build/agy/wave16_unified/compiler.bend`
(and supports `--partial` for individual `k10_wave16/m07|m08|m09` module builds).

Does NOT touch `w4_post_select` / `w7_post_select_full` (owned by O2-B) or
`w4b_reg_dead` / `w5b` (owned by O2-A).

Patches:
  1. O2E-1 (`w7c_fast_inst_c` in `x188_build_instruction`):
     Direct-to-`X187Build` fast-path encoding (100% bit-for-bit identical to `x187_encode`)
     for top-frequency x86-64 opcodes that previously fell through to `x187_encode`:
       - `movq $imm64, %reg`
       - `movl` (reg->reg, reg->mem, mem->reg, imm32->reg)
       - 64-bit & 32-bit ALU (`cmpq`/`cmpl`, `addq`/`addl`, `subq`/`subl`,
         `andq`/`andl`, `orq`/`orl`, `xorq`/`xorl` for reg->reg and imm32->reg)
       - `testq` / `testl` (reg->reg)
       - `shrq` / `shlq` / `shrl` / `shll` (imm8->reg)
  2. O2E-2 (`x186_private_body`, `x191_joint_reads`, `x190_j_selected`, `x190_joint_frame`):
     - Gate `x186_private_body` on `o2e_has_mem_body(body)` (100% bit-identical when no mem ops).
     - In `x191_joint_reads`: skip `x191_loop_reads` + `x191_loop_scores` when `!x190_register_loop(body)` (100% bit-identical).
     - In `x190_j_selected`: when `!x190_register_loop(body)`, skip `x190_l_fixed` (2 wasted AST passes)
       and compute `bodyLive` (= `header`) + `bodyGraph` in ONE single `x190_l_body` pass (100% bit-identical).
     - In `x190_joint_frame`: for trivial non-loop functions (`!hasLoop && sz < 8`), use lightweight
       `x185_transient_frame(x181_register_frame(...))` instead of full interference graph coloring.
  3. O2E-3 (`w8_tr_emit_pub`):
     - In `-O2` mode (`fast == False`), route cold public segments — weak cross-module stubs
       (`is_mod && w10_is_weak_sym(weak_set, p111q_symbol(name))`) and `is_direct == True`
       cold thunk wrappers (whose hot body is already compiled at full `-O2` in `x187_priv`) —
       through `s10c_pub_emit_fast`, while keeping all `is_direct == False` strong public
       segments on full `-O2` (`x193f_public` / `agy_map_*`).
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave16_unified/compiler.bend"
MARKER = "# === O2-E:"

# ---------------------------------------------------------------------------
# Patch 1: O2E-1 — Direct-to-X187Build fast-path encoder in w7c_fast_inst_c
# ---------------------------------------------------------------------------
P1_OLD = """@unsafe
def w7c_fast_movq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,64,False{}} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{137,Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Reg{+s,64,False{}} X187Mem{+b,+disp}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(b,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Mem{+b,+disp} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)"""

P1_NEW = """# === O2-E: Fast-Path Direct Instruction Encoder (O2E-1) ===
@unsafe
def o2e_push_mem_mode(mode: U32, +disp: U32, t1: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>,
    +ts: U32, +n1: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  match mode:
    case 0: X187Build{1,t1,r,d,U32.add(ts,n1),rs,ds,symbols,names,relocs,error}
    case 1: X187Build{1,Con{U32.and(disp,255),t1},r,d,U32.add(ts,U32.inc(n1)),rs,ds,symbols,names,relocs,error}
    case _: X187Build{1,w7c_u32_rev(disp,t1),r,d,U32.add(ts,U32.add(n1,4)),rs,ds,symbols,names,relocs,error}

@unsafe
def o2e_push_mem32(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
    +t: List<&2,U32>, r: List<&2,U32>, d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    symbols: KDef, names: List<&2,String>, relocs: List<&2,X187Relocation>, error: String) -> X187Build:
  +low = U32.and(base,7)
  +rlow = U32.mul(U32.and(reg,7),8)
  +zero = U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5))
  +short = U32.is_le(disp,127) || U32.is_ge(disp,4294967168)
  +mode = nt_choose(U32,zero,u => 0,u => nt_choose(U32,short,v => 1,v => 2))
  +modrm = U32.add(U32.mul(mode,64),U32.add(rlow,low))
  +has_rex = U32.is_gt(rex,64)
  +t_pre : List<&2,U32> = nt_choose(List<&2,U32>,has_rex,u => Con{rex,t},u => t)
  +n_pre : U32 = nt_choose(U32,has_rex,u => 3,u => 2)
  +t0 : List<&2,U32> = Con{modrm,Con{opcode,t_pre}}
  +t1 = nt_choose(List<&2,U32>,U32.is_eq(low,4),u => Con{36,t0},u => t0)
  +n1 = nt_choose(U32,U32.is_eq(low,4),u => U32.inc(n_pre),u => n_pre)
  o2e_push_mem_mode(mode,disp,t1,r,d,ts,n1,rs,ds,symbols,names,relocs,error)

@unsafe
def o2e_fast_movl(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,32,False{}} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u =>
          +rex = U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n)))
          +modrm = U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_gt(rex,64),
            v => X187Build{1,Con{modrm,Con{137,Con{rex,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,Con{modrm,Con{137,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Reg{+s,32,False{}} X187Mem{+b,+disp}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(b,16),
        u => o2e_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Mem{+b,+disp} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => o2e_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Imm{+lo,0} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16),
        u => nt_choose(X187Build,U32.is_ge(dd,8),
          v => X187Build{1,w7c_u32_rev(lo,Con{U32.add(184,U32.and(dd,7)),Con{65,t}}),r,d,U32.add(ts,6),rs,ds,symbols,names,relocs,error},
          v => X187Build{1,w7c_u32_rev(lo,Con{U32.add(184,dd),t}),r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_alu64(+ext: U32, src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,64,False{}} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{U32.add(U32.mul(ext,8),1),Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Imm{+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && ((U32.is_eq(hi,0) && U32.is_le(lo,2147483647)) || (U32.is_eq(hi,4294967295) && U32.is_ge(lo,2147483648))),
        u => X187Build{1,
          w7c_u32_rev(lo,Con{U32.add(192,U32.add(U32.mul(ext,8),U32.and(dd,7))),Con{129,Con{U32.add(72,U32.shrn(dd,3n)),t}}}),
          r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_alu32(+ext: U32, src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,32,False{}} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u =>
          +rex = U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n)))
          +code = U32.add(U32.mul(ext,8),1)
          +modrm = U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_gt(rex,64),
            v => X187Build{1,Con{modrm,Con{code,Con{rex,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,Con{modrm,Con{code,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Imm{+lo,0} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16),
        u =>
          +modrm = U32.add(192,U32.add(U32.mul(ext,8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_ge(dd,8),
            v => X187Build{1,w7c_u32_rev(lo,Con{modrm,Con{129,Con{65,t}}}),r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,w7c_u32_rev(lo,Con{modrm,Con{129,t}}),r,d,U32.add(ts,6),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_test64(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,64,False{}} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{133,Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_test32(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,32,False{}} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u =>
          +rex = U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n)))
          +modrm = U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_gt(rex,64),
            v => X187Build{1,Con{modrm,Con{133,Con{rex,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,Con{modrm,Con{133,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_shift64(+ext: U32, src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Imm{+lo,0} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && U32.is_le(lo,255),
        u => X187Build{1,
          Con{lo,Con{U32.add(192,U32.add(U32.mul(ext,8),U32.and(dd,7))),Con{193,Con{U32.add(72,U32.shrn(dd,3n)),t}}}},
          r,d,U32.add(ts,4),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def o2e_fast_shift32(+ext: U32, src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Imm{+lo,0} X187Reg{+dd,32,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && U32.is_le(lo,255),
        u =>
          +modrm = U32.add(192,U32.add(U32.mul(ext,8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_ge(dd,8),
            v => X187Build{1,Con{lo,Con{modrm,Con{193,Con{65,t}}}},r,d,U32.add(ts,4),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,Con{lo,Con{modrm,Con{193,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)

@unsafe
def w7c_fast_movq(src: X187Operand, dst: X187Operand, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match src dst:
    case X187Reg{+s,64,False{}} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(dd,16),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{137,Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Reg{+s,64,False{}} X187Mem{+b,+disp}:
      nt_choose(X187Build,U32.is_lt(s,16) && U32.is_lt(b,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Mem{+b,+disp} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(b,16) && U32.is_lt(dd,16),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case X187Imm{+lo,+hi} X187Reg{+dd,64,False{}}:
      nt_choose(X187Build,U32.is_lt(dd,16),
        u => X187Build{1,w7c_u32_rev(hi,w7c_u32_rev(lo,Con{U32.add(184,U32.and(dd,7)),Con{U32.add(72,U32.shrn(dd,3n)),t}})),
          r,d,U32.add(ts,10),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)"""

P1B_OLD = """@unsafe
def w7c_fast_inst_c(c0: U32, +tail: String, operands: List<&2,X187Operand>, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match c0 operands:
    case 109 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"ovq"),
        u => w7c_fast_movq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ovabsq"),
          v => w7c_fast_movabsq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 108 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"eaq"),
        u => w7c_fast_leaq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 99 Con{X187Target{+sym},Nil{}}:
      nt_choose(X187Build,agy_str_eq(tail,"all") && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.inc(ts),4,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{232,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 120 Con{X187Reg{+s,32,False{}},Con{X187Reg{+dd,32,False{}},Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"orl") && U32.is_lt(s,8) && U32.is_lt(dd,8),
        u => X187Build{1,Con{U32.add(192,U32.add(U32.mul(s,8),dd)),Con{49,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 114 Nil{}:
      nt_choose(X187Build,agy_str_eq(tail,"et"),
        u => X187Build{1,Con{195,t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 112 Con{X187Reg{+dd,64,False{}},Nil{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"ushq"),
        u => nt_choose(X187Build,U32.is_lt(dd,8),
          v => X187Build{1,Con{U32.add(80,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
          v => X187Build{1,Con{U32.add(80,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"opq"),
          v => nt_choose(X187Build,U32.is_lt(dd,8),
            w => X187Build{1,Con{U32.add(88,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
            w => X187Build{1,Con{U32.add(88,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)"""

P1B_NEW = """@unsafe
def w7c_fast_inst_c(c0: U32, +tail: String, operands: List<&2,X187Operand>, +inst: X187Instruction, +build: X187Build,
    +t: List<&2,U32>, +r: List<&2,U32>, +d: List<&2,U32>, +ts: U32, +rs: U32, +ds: U32,
    +symbols: KDef, +names: List<&2,String>, +relocs: List<&2,X187Relocation>, +error: String) -> X187Build:
  match c0 operands:
    case 109 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"ovq"),
        u => w7c_fast_movq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ovl"),
          v => o2e_fast_movl(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => nt_choose(X187Build,agy_str_eq(tail,"ovabsq"),
            w => w7c_fast_movabsq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
            w => w7_build_inst_enc(x187_encode(inst,ts),inst,build))))
    case 99 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"mpq"),
        u => o2e_fast_alu64(7,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"mpl"),
          v => o2e_fast_alu32(7,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 99 Con{X187Target{+sym},Nil{}}:
      nt_choose(X187Build,agy_str_eq(tail,"all") && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.inc(ts),4,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{232,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error}),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 97 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"ddq"),
        u => o2e_fast_alu64(0,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ndq"),
          v => o2e_fast_alu64(4,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => nt_choose(X187Build,agy_str_eq(tail,"ndl"),
            w => o2e_fast_alu32(4,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
            w => nt_choose(X187Build,agy_str_eq(tail,"ddl"),
              z => o2e_fast_alu32(0,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
              z => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))))
    case 115 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"hrq"),
        u => o2e_fast_shift64(5,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"ubq"),
          v => o2e_fast_alu64(5,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => nt_choose(X187Build,agy_str_eq(tail,"hlq"),
            w => o2e_fast_shift64(4,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
            w => nt_choose(X187Build,agy_str_eq(tail,"ubl"),
              z => o2e_fast_alu32(5,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
              z => nt_choose(X187Build,agy_str_eq(tail,"hrl"),
                q => o2e_fast_shift32(5,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
                q => nt_choose(X187Build,agy_str_eq(tail,"hll"),
                  p => o2e_fast_shift32(4,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
                  p => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))))))
    case 108 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"eaq"),
        u => w7c_fast_leaq(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 116 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"estq"),
        u => o2e_fast_test64(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"estl"),
          v => o2e_fast_test32(src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 120 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"orl"),
        u => o2e_fast_alu32(6,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"orq"),
          v => o2e_fast_alu64(6,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 111 Con{+src,Con{+dst,Nil{}}}:
      nt_choose(X187Build,agy_str_eq(tail,"rq"),
        u => o2e_fast_alu64(1,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => nt_choose(X187Build,agy_str_eq(tail,"rl"),
          v => o2e_fast_alu32(1,src,dst,inst,build,t,r,d,ts,rs,ds,symbols,names,relocs,error),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case 114 Nil{}:
      nt_choose(X187Build,agy_str_eq(tail,"et"),
        u => X187Build{1,Con{195,t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
        u => w7_build_inst_enc(x187_encode(inst,ts),inst,build))
    case 112 Con{X187Reg{+dd,64,False{}},Nil{}}:
      nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"ushq"),
        u => nt_choose(X187Build,U32.is_lt(dd,8),
          v => X187Build{1,Con{U32.add(80,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
          v => X187Build{1,Con{U32.add(80,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => nt_choose(X187Build,U32.is_lt(dd,16) && agy_str_eq(tail,"opq"),
          v => nt_choose(X187Build,U32.is_lt(dd,8),
            w => X187Build{1,Con{U32.add(88,dd),t},r,d,U32.inc(ts),rs,ds,symbols,names,relocs,error},
            w => X187Build{1,Con{U32.add(88,U32.and(dd,7)),Con{65,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
          v => w7_build_inst_enc(x187_encode(inst,ts),inst,build)))
    case _ _: w7_build_inst_enc(x187_encode(inst,ts),inst,build)"""

# ---------------------------------------------------------------------------
# Patch 2: O2E-2a (`m08`) — Gate x186_private_body on memory ops & skip
#          x191_loop_reads on non-loop functions in x191_joint_reads
# ---------------------------------------------------------------------------
P2A_OLD = """@unsafe
def x186_private_body(params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_m_body(body,x186_m_scan(body,x186_m_scan(setup,X186Memory{
      x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
        p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),missing(),missing()}))),u => body)"""

P2A_NEW = """# === O2-E: Gate x186_private_body on memory ops (O2E-2a) ===
@unsafe
def o2e_has_mem_scalars(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{N111Load{n,t,b,o},rest}: True{}
    case Con{N111Store{t,b,o,v},rest}: True{}
    case Con{N111Offset{n,b,by},rest}: True{}
    case Con{N111Alloca{n,by,al},rest}: True{}
    case Con{N111If{c,yes,no},rest}: o2e_has_mem_scalars(yes) || o2e_has_mem_scalars(no) || o2e_has_mem_scalars(rest)
    case Con{head,rest}: o2e_has_mem_scalars(rest)

@unsafe
def o2e_has_mem_body(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{P113DScalar{N111Load{n,t,b,o}},rest}: True{}
    case Con{P113DScalar{N111Store{t,b,o,v}},rest}: True{}
    case Con{P113DScalar{N111Offset{n,b,by}},rest}: True{}
    case Con{P113DScalar{N111Alloca{n,by,al}},rest}: True{}
    case Con{P113DScalar{N111If{c,yes,no}},rest}: o2e_has_mem_scalars(yes) || o2e_has_mem_scalars(no) || o2e_has_mem_body(rest)
    case Con{P113DIf{c,yes,no},rest}: o2e_has_mem_body(yes) || o2e_has_mem_body(no) || o2e_has_mem_body(rest)
    case Con{head,rest}: o2e_has_mem_body(rest)

@unsafe
def x186_private_body(params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,o2e_has_mem_body(body) && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x186_m_body(body,x186_m_scan(body,x186_m_scan(setup,X186Memory{
      x185_sf_buffers(body,x185_sf_buffers(setup,x185_sf_blocks(params,
        p111v_put(missing(),"scratch","X185ScratchBuffer",2048,0)))),missing(),missing()}))),u => body)"""

P2B_OLD = """@unsafe
def x191_joint_reads(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, params: List<&2,String>) -> X181ReadCounts:
  (x191_loop_counted(x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]})),
      x191_loop_reads(body,params,False{})))"""

P2B_NEW = """# === O2-E: Skip x191_loop_reads on non-loop functions (O2E-2b) ===
@unsafe
def x191_joint_reads(+setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>, params: List<&2,String>) -> X181ReadCounts:
  +base = x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]}))
  nt_choose(X181ReadCounts,x190_register_loop(body),
    u => x191_loop_counted(base,x191_loop_reads(body,params,False{})),
    u => base)"""

# ---------------------------------------------------------------------------
# Patch 3: O2E-2c (`m09`) — Single-pass liveness for non-loop x190_j_selected
#          + lightweight regalloc for trivial (< 8 stmts) non-loop functions
# ---------------------------------------------------------------------------
P3A_OLD = """@unsafe
def x190_j_selected(+frame: X181Frame, +params: List<&2,String>, setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, registerBody: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      x190_j_solved(frame,params,setup,body,registerBody,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33))"""

P3A_NEW = """# === O2-E: Single-pass liveness for non-loop x190_j_selected (O2E-2c) ===
@unsafe
def o2e_j_noloop_step(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, +names: List<&2,String>,
    +ids: KDef, +env: X190LEnv, bodyFlow: X190LFlow) -> X181Frame:
  match bodyFlow:
    case X190LFlow{+bodyLive,_}:
      x190_j_graphed(frame,params,setup,body,registerBody,names,ids,bodyLive,
        x190_l_incoming(params,x190_l_body(setup,bodyFlow,env),env))

@unsafe
def x190_j_selected(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>, candidates: X190LCandidates) -> X181Frame:
  match candidates:
    case X190LCandidates{+names,+ids}:
      +parameters = x190_l_names(x181_tail_args(frame),ids)
      nt_choose(X181Frame,x190_register_loop(body),
        u => x190_j_solved(frame,params,setup,body,registerBody,names,ids,parameters,x190_l_fixed(body,ids,parameters,0,33)),
        u =>
          +env: X190LEnv = X190LEnv{ids,parameters,0,True{}}
          o2e_j_noloop_step(frame,params,setup,body,registerBody,names,ids,env,
            x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},env)))"""

P3B_OLD = """@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(x190_register_loop(body)) && w7b_stmts_has_call(body),
    u => frame,
    u => nt_choose(X181Frame,U32.is_le(sz,2048) &&
      U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
      v => x190_j_counted(frame,params,setup,body,registerBody,
        x191_joint_reads(setup,body,x181_tail_args(frame))),
      v => x190_allocate_legacy(frame,params,setup,body,registerBody)))"""

P3B_NEW = """@unsafe
def x190_joint_frame(+frame: X181Frame, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +registerBody: List<&2,P113DStmt>) -> X181Frame:
  +sz = p113i_add(p113i_size(setup),p113i_size(body))
  +hasLoop = x190_register_loop(body)
  nt_choose(X181Frame,U32.is_gt(sz,128) && Bool.not(hasLoop) && w7b_stmts_has_call(body),
    u => frame,
    u => nt_choose(X181Frame,Bool.not(hasLoop) && U32.is_lt(sz,8),
      w => x185_transient_frame(x181_register_frame(frame,registerBody),params,setup,body),
      w => nt_choose(X181Frame,U32.is_le(sz,2048) &&
        U32.is_le(nt_count(String,params),64) && x190_l_safe_body(setup) && x190_l_safe_body(body),
        v => x190_j_counted(frame,params,setup,body,registerBody,
          x191_joint_reads(setup,body,x181_tail_args(frame))),
        v => x190_allocate_legacy(frame,params,setup,body,registerBody))))"""

# ---------------------------------------------------------------------------
# Patch 4: O2E-3 (`m09`) — Fast-path cold public segments in w8_tr_emit_pub
# ---------------------------------------------------------------------------
P4_OLD = """@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +b2 : X187Build = nt_choose(X187Build,fast,
      u => w13c_pub_emit_fast(head,ctx,avail,build),
      u => w10f_output_fn(nt_choose(X181Output,is_mod,
        v => w11_program_public_mod(head,ctx,avail,weak_set),
        v => x181_program_public(head,ctx,avail)),build))"""

P4_NEW = """# === O2-E: Fast-path cold public segments (weak stubs & is_direct wrappers) (O2E-3) ===
@unsafe
def o2e_pub_is_cold(+seg: N111Segment, ctx: P134Context, +is_mod: Bool, +weak_set: KDef) -> Bool:
  match seg ctx:
    case N111Segment{+name,_,_,_,_,_} P134Context{_,_,+direct,_,_,_,_,_}:
      nt_choose(Bool,is_mod && w10_is_weak_sym(weak_set,p111q_symbol(name)),
        u => True{},
        u =>
          +fn = p111v_get(direct,name)
          agy_str_eq(dk(fn),"P113Direct") && U32.is_eq(ix(dv(fn)),1))

@unsafe
def w8_tr_emit_pub(+trace: Bool, +fast: Bool, +is_mod: Bool, +weak_set: KDef, +t_start: Nat,
    +head: N111Segment, rest: List<&2,N111Segment>, +ctx: P134Context, next: P134Cursor,
    +avail: KDef, +build: X187Build, +priv_n: U32, +pub_n: U32, +total_segs: U32) -> IO(U32):
  do IO<U32>:
    +b2 : X187Build = nt_choose(X187Build,fast,
      u => w13c_pub_emit_fast(head,ctx,avail,build),
      u => nt_choose(X187Build,o2e_pub_is_cold(head,ctx,is_mod,weak_set),
        w => s10c_pub_emit_fast(head,ctx,avail,build),
        w => w10f_output_fn(nt_choose(X181Output,is_mod,
          v => w11_program_public_mod(head,ctx,avail,weak_set),
          v => x181_program_public(head,ctx,avail)),build)))"""

PATCHES = [
    ("O2E-1a (fast movq imm64 + helpers)", P1_OLD, P1_NEW),
    ("O2E-1b (w7c_fast_inst_c top-15 opcodes)", P1B_OLD, P1B_NEW),
    ("O2E-2a (x186_private_body mem gate)", P2A_OLD, P2A_NEW),
    ("O2E-2b (x191_joint_reads loop gate)", P2B_OLD, P2B_NEW),
    ("O2E-2c (x190_j_selected 1-pass noloop)", P3A_OLD, P3A_NEW),
    ("O2E-2d (x190_joint_frame trivial noloop)", P3B_OLD, P3B_NEW),
    ("O2E-3  (w8_tr_emit_pub cold fast-path)", P4_OLD, P4_NEW),
]


def apply_o2e(text: str, partial: bool = False) -> tuple[str, list[str]]:
    if MARKER in text and not partial:
        return text, ["already_applied"]
    applied: list[str] = []
    out = text
    for name, old, new in PATCHES:
        if new in out:
            applied.append(f"{name}:already")
            continue
        cnt = out.count(old)
        if cnt == 1:
            out = out.replace(old, new, 1)
            applied.append(f"{name}:applied")
        elif cnt == 0 and partial:
            continue
        else:
            raise RuntimeError(f"Patch {name} expected 1 occurrence, found {cnt}")
    return out, applied


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply O2-E core codegen speedups")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--partial", action="store_true", help="Allow applying subset of patches (e.g. single k10 module)")
    args = ap.parse_args()
    out_path = args.out if args.out is not None else args.src
    text = args.src.read_text(encoding="utf-8")
    patched, log = apply_o2e(text, partial=args.partial)
    out_path.write_text(patched, encoding="utf-8")
    print(f"[apply_o2e] {args.src} -> {out_path} ({len(text):,} -> {len(patched):,} B): {', '.join(log)}")


if __name__ == "__main__":
    main()
