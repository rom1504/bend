# ============================================================================
# W13-C: Fast `x187_pub` — Fused Direct-to-X187Build Public Segment Emission
# + Fast `x185_late_stmts` (skip non-Call) + Single-Hash `x181_frame_home`
# ============================================================================

type W13cSt is Data:
  W13cSt{+build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>, +next: U32, +terminal: Bool}

# Base-32 ASCII tag (chars 65..96: 'A'..'`') prefixed with ".L#" (35) so it
# never collides with ".L_b..." from agy_rt_inline_try and needs zero U32.show.
@unsafe
def w13c_tag(+n: U32) -> String:
  +ch = Char.from_u32(U32.add(65,U32.and(n,31)))
  +hi = U32.shrn(n,5n)
  nt_choose(String,U32.is_eq(hi,0),u => SCon{ch,SNil{}},u => SCon{ch,w13c_tag(hi)})

@unsafe
def w13c_lbl(+n: U32) -> String:
  SCon{Char.from_u32(46),SCon{Char.from_u32(76),SCon{Char.from_u32(35),w13c_tag(n)}}}

# --- Direct x86-64 byte emitters onto X187Build (section 1) ---

@unsafe
def w13c_push_mem32(+rex: U32, +opcode: U32, +reg: U32, +base: U32, +disp: U32,
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
  w7c_push_mem_mode(mode,disp,t1,r,d,ts,n1,rs,ds,symbols,names,relocs,error)

@unsafe
def w13c_b_movq_rr(+s: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => X187Build{1,
          Con{U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7))),
          Con{137,Con{U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n))),t}}},
          r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movl_rr(+s: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +rex = U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(dd,3n)))
          +modrm = U32.add(192,U32.add(U32.mul(U32.and(s,7),8),U32.and(dd,7)))
          nt_choose(X187Build,U32.is_gt(rex,64),
            v => X187Build{1,Con{modrm,Con{137,Con{rex,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,Con{modrm,Con{137,t}},r,d,U32.add(ts,2),rs,ds,symbols,names,relocs,error}),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movq_mr(+b: U32, +disp: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movq_rm(+s: U32, +b: U32, +disp: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movl_mr(+b: U32, +disp: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w13c_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),139,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movl_rm(+s: U32, +b: U32, +disp: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w13c_push_mem32(U32.add(64,U32.add(U32.mul(U32.shrn(s,3n),4),U32.shrn(b,3n))),137,s,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_leaq_mr(+b: U32, +disp: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => w7c_push_mem(U32.add(72,U32.add(U32.mul(U32.shrn(dd,3n),4),U32.shrn(b,3n))),141,dd,b,disp,
          t,r,d,ts,rs,ds,symbols,names,relocs,error),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_movabsq(+lo: U32, +hi: U32, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u => X187Build{1,w7c_u32_rev(hi,w7c_u32_rev(lo,Con{U32.add(184,U32.and(dd,7)),Con{U32.add(72,U32.shrn(dd,3n)),t}})),
          r,d,U32.add(ts,10),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_leaq_rip(+sym: String, +dd: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712) && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.add(ts,3),2,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{U32.add(5,U32.mul(U32.and(dd,7),8)),
            Con{141,Con{U32.add(72,U32.mul(U32.shrn(dd,3n),4)),t}}}}}}},
            r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error}),
        u => x187_build_error("x86 invalid rip load",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_xorl_eax_call(+sym: String, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712) && Bool.not(String.is_empty(sym)),
        u => x187_build_relocation(X187Relocation{1,U32.add(ts,3),4,sym,4294967292,4294967295},
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{232,Con{192,Con{49,t}}}}}}},
            r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error}),
        u => x187_build_error("x86 invalid call",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_prologue_go(+frame_sz: U32, +uses_state: Bool, +b1: X187Build) -> X187Build:
  match b1:
    case X187Build{1,+t,+r,+d,+ts,+rs,+ds,+symbols,+names,+relocs,+error}:
      nt_choose(X187Build,U32.is_le(ts,134217700),
        u =>
          +t0 = w7c_u32_rev(frame_sz,Con{236,Con{129,Con{72,Con{229,Con{137,Con{72,Con{85,t}}}}}}})
          nt_choose(X187Build,uses_state,
            v => X187Build{1,Con{252,Con{137,Con{73,Con{240,Con{101,Con{137,Con{76,t0}}}}}}},
              r,d,U32.add(ts,18),rs,ds,symbols,names,relocs,error},
            v => X187Build{1,t0,r,d,U32.add(ts,11),rs,ds,symbols,names,relocs,error}),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",b1))
    case _: x187_build_error("instruction outside text",b1)

@unsafe
def w13c_b_prologue(+sym: String, +frame_sz: U32, +uses_state: Bool, +build: X187Build) -> X187Build:
  w13c_b_prologue_go(frame_sz,uses_state,
    x187_build_symbol(sym,1,0,x187_build_symbol(sym,3,2,x187_build_symbol(sym,2,0,x187_build_switch(1,build)))))

@unsafe
def w13c_b_epilogue(+uses_state: Bool, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +t0 : List<&2,U32> = nt_choose(List<&2,U32>,uses_state,
            v => Con{240,Con{101,Con{139,Con{76,t}}}},
            v => t)
          +n0 : U32 = nt_choose(U32,uses_state,v => 9,v => 5)
          X187Build{1,Con{195,Con{93,Con{236,Con{137,Con{72,t0}}}}},
            r,d,U32.add(ts,n0),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

# Direct x202k_template emission (zero X188Seq, zero lsyms)
@unsafe
def w13c_emit_x202k_go(+sym: String, +b1: X187Build) -> X187Build:
  match b1:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217696),
        u =>
          +t1 : List<&2,U32> =
            Con{0,Con{0,Con{0,Con{0,Con{233,
            Con{192,Con{49,Con{40,Con{119,Con{139,Con{72,Con{16,Con{139,Con{72,
            Con{16,Con{71,Con{137,Con{72,Con{8,Con{232,Con{131,Con{72,
            Con{16,Con{71,Con{139,Con{72,t}}}}}}}}}}}}}}}}}}}}}}}}}}
          +b2 = x187_build_relocation(X187Relocation{1,U32.add(ts,22),2,"p111_rt_apply",4294967292,4294967295},
            X187Build{1,t1,r,d,U32.add(ts,26),rs,ds,symbols,names,relocs,error})
          x187_build_symbol(sym,4,0,b2),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",b1))
    case _: x187_build_error("instruction outside text",b1)

@unsafe
def w13c_emit_x202k(+sym: String, +build: X187Build) -> X187Build:
  w13c_emit_x202k_go(sym,
    x187_build_symbol(sym,1,0,x187_build_symbol(sym,3,2,x187_build_symbol(sym,2,0,x187_build_switch(1,build)))))

# --- Direct local load/store onto X187Build ---

def w13c_reg_num(n: U32) -> U32:
  match n:
    case 0: 12
    case 1: 3
    case 2: 13
    case 3: 14
    case _: 15

def w13c_argreg_num(n: U32) -> U32:
  match n:
    case 0: 7
    case 1: 6
    case 2: 2
    case 3: 1
    case 4: 8
    case _: 9

@unsafe
def w13c_load_slot(+slot: KDef, +dd: U32, +build: X187Build) -> X187Build:
  +k = dk(slot)
  nt_choose(X187Build,agy_str_eq(k,"X181Stack"),
    u => w13c_b_movq_mr(5,U32.sub(0,da(slot)),dd,build),u =>
  nt_choose(X187Build,agy_str_eq(k,"X181Buffer"),
    u => w13c_b_leaq_mr(5,U32.sub(0,da(slot)),dd,build),u =>
  nt_choose(X187Build,agy_str_eq(k,"X181Register"),
    u => w13c_b_movq_rr(w13c_reg_num(da(slot)),dd,build),
    u => x187_build_error("x181: missing local slot",build))))

@unsafe
def w13c_load_id(tree: KDef, +name: String, +dd: U32, +build: X187Build) -> X187Build:
  +found = index_find(tree,name,index_hash(name,2166136261),32)
  nt_choose(X187Build,agy_str_eq(dk(found),"N111Id"),
    u => w13c_b_movabsq(da(found),0,dd,build),
    u => x187_build_error("x181: missing native ID",build))

@unsafe
def w13c_load_local(+name: String, frame: X181Frame, +dd: U32, +build: X187Build) -> X187Build:
  match frame:
    case X181Frame{slots,_,_,_,_}:
      w13c_load_slot(index_find(slots,name,index_hash(name,2166136261),32),dd,build)

@unsafe
def w13c_load_fid(ids: N111Ids, +name: String, +dd: U32, +build: X187Build) -> X187Build:
  match ids:
    case N111Ids{functions,_}: w13c_load_id(functions,name,dd,build)

@unsafe
def w13c_load_cid(ids: N111Ids, +name: String, +dd: U32, +build: X187Build) -> X187Build:
  match ids:
    case N111Ids{_,constructors}: w13c_load_id(constructors,name,dd,build)

@unsafe
def w13c_load_val(value: N111Value, ids: N111Ids, frame: X181Frame, +dd: U32, +build: X187Build) -> X187Build:
  match value:
    case N111Local{name}: w13c_load_local(name,frame,dd,build)
    case N111Const{lo,hi}: w13c_b_movabsq(lo,hi,dd,build)
    case N111Symbol{name}: w13c_b_leaq_rip(name,dd,build)
    case N111FuncId{name}: w13c_load_fid(ids,name,dd,build)
    case N111CtorId{name}: w13c_load_cid(ids,name,dd,build)

@unsafe
def w13c_store_slot(+slot: KDef, +s: U32, +build: X187Build) -> X187Build:
  +k = dk(slot)
  nt_choose(X187Build,agy_str_eq(k,"X181Stack"),
    u => w13c_b_movq_rm(s,5,U32.sub(0,da(slot)),build),u =>
  nt_choose(X187Build,agy_str_eq(k,"X181UnusedState"),
    u => build,u =>
  nt_choose(X187Build,agy_str_eq(k,"X181Register"),
    u => w13c_b_movq_rr(s,w13c_reg_num(da(slot)),build),
    u => x187_build_error("x181: invalid destination slot",build))))

@unsafe
def w13c_store_reg(+name: String, frame: X181Frame, +s: U32, +build: X187Build) -> X187Build:
  match frame:
    case X181Frame{slots,_,_,_,_}:
      w13c_store_slot(index_find(slots,name,index_hash(name,2166136261),32),s,build)

# --- Direct binary ALU / compare / shift onto X187Build (on %r10 / %r11) ---

@unsafe
def w13c_cmp_setcc(+op: String) -> U32:
  nt_choose(U32,agy_str_eq(op,"eq"),u => 148,u =>
  nt_choose(U32,agy_str_eq(op,"ne"),u => 149,u =>
  nt_choose(U32,agy_str_eq(op,"ult"),u => 146,u =>
  nt_choose(U32,agy_str_eq(op,"ule"),u => 150,u =>
  nt_choose(U32,agy_str_eq(op,"ugt"),u => 151,u =>
  nt_choose(U32,agy_str_eq(op,"uge"),u => 147,u =>
  nt_choose(U32,agy_str_eq(op,"slt"),u => 156,u =>
  nt_choose(U32,agy_str_eq(op,"sle"),u => 158,u =>
  nt_choose(U32,agy_str_eq(op,"sgt"),u => 159,u =>
  nt_choose(U32,agy_str_eq(op,"sge"),u => 157,u => 0))))))))))

@unsafe
def w13c_alu_kind(+op: String) -> U32:
  nt_choose(U32,agy_str_eq(op,"add"),u => 10,u =>
  nt_choose(U32,agy_str_eq(op,"sub"),u => 15,u =>
  nt_choose(U32,agy_str_eq(op,"and"),u => 14,u =>
  nt_choose(U32,agy_str_eq(op,"or"),u => 11,u =>
  nt_choose(U32,agy_str_eq(op,"xor"),u => 16,u =>
  nt_choose(U32,agy_str_eq(op,"shr"),u => 25,u =>
  nt_choose(U32,agy_str_eq(op,"shl"),u => 24,u =>
  nt_choose(U32,agy_str_eq(op,"sar"),u => 27,u => 0))))))))

@unsafe
def w13c_b_cmp_imm(+w64: Bool, +lo: U32, +cc: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217700),
        u =>
          +rex = nt_choose(U32,w64,v => 73,v => 65)
          +t1 = w7c_u32_rev(lo,Con{250,Con{129,Con{rex,t}}})
          +t2 : List<&2,U32> = Con{210,Con{182,Con{15,Con{69,Con{194,Con{cc,Con{15,Con{65,t1}}}}}}}}
          X187Build{1,t2,r,d,U32.add(ts,15),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_cmp_rr(+w64: Bool, +cc: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217700),
        u =>
          +rex = nt_choose(U32,w64,v => 77,v => 69)
          +t2 : List<&2,U32> = Con{210,Con{182,Con{15,Con{69,Con{194,Con{cc,Con{15,Con{65,Con{218,Con{57,Con{rex,t}}}}}}}}}}}
          X187Build{1,t2,r,d,U32.add(ts,11),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_alu_imm(+w64: Bool, +ext: U32, +lo: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +rex = nt_choose(U32,w64,v => 73,v => 65)
          +modrm = U32.add(194,U32.mul(ext,8))
          X187Build{1,w7c_u32_rev(lo,Con{modrm,Con{129,Con{rex,t}}}),
            r,d,U32.add(ts,7),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_alu_rr(+w64: Bool, +ext: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +rex = nt_choose(U32,w64,v => 77,v => 69)
          +op = U32.inc(U32.mul(ext,8))
          X187Build{1,Con{218,Con{op,Con{rex,t}}},r,d,U32.add(ts,3),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_shift_imm(+w64: Bool, +ext: U32, +sh: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +rex = nt_choose(U32,w64,v => 73,v => 65)
          +modrm = U32.add(194,U32.mul(ext,8))
          X187Build{1,Con{sh,Con{modrm,Con{193,Con{rex,t}}}},r,d,U32.add(ts,4),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_shift_cl(+w64: Bool, +ext: U32, +build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217712),
        u =>
          +rex = nt_choose(U32,w64,v => 73,v => 65)
          +modrm = U32.add(194,U32.mul(ext,8))
          X187Build{1,Con{modrm,Con{211,Con{rex,Con{217,Con{137,Con{68,t}}}}}},
            r,d,U32.add(ts,6),rs,ds,symbols,names,relocs,error},
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_emit_bin_rc(rc: N111Value, +w64: Bool, +cc: U32, +ak: U32, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +build: X187Build) -> X187Build:
  match rc:
    case N111Const{+lo,+hi}:
      nt_choose(X187Build,U32.is_ge(ak,20),
        u => w13c_b_shift_imm(w64,U32.sub(ak,20),U32.mod(lo,nt_choose(U32,w64,v => 64,v => 32)),build),
      u => nt_choose(X187Build,U32.is_eq(ak,14) && U32.is_eq(hi,0) && U32.is_eq(lo,4294967295),
        v => w13c_b_movl_rr(10,10,build),
      v => nt_choose(X187Build,U32.is_eq(hi,0) && (Bool.not(w64) || U32.is_le(lo,2147483647)),
        w => nt_choose(X187Build,U32.is_gt(cc,0),
          z => w13c_b_cmp_imm(w64,lo,cc,build),
          z => w13c_b_alu_imm(w64,U32.sub(ak,10),lo,build)),
        w =>
          +b1 = w13c_load_val(right,ids,frame,11,build)
          nt_choose(X187Build,U32.is_gt(cc,0),
            z => w13c_b_cmp_rr(w64,cc,b1),
            z => w13c_b_alu_rr(w64,U32.sub(ak,10),b1)))))
    case _:
      +b1 = w13c_load_val(right,ids,frame,11,build)
      nt_choose(X187Build,U32.is_gt(cc,0),
        u => w13c_b_cmp_rr(w64,cc,b1),
        u => nt_choose(X187Build,U32.is_ge(ak,20),
          v => w13c_b_shift_cl(w64,U32.sub(ak,20),b1),
          v => w13c_b_alu_rr(w64,U32.sub(ak,10),b1)))

@unsafe
def w13c_emit_bin_op(+w64: Bool, +cc: U32, +ak: U32, +right: N111Value,
    +ids: N111Ids, +frame: X181Frame, +build: X187Build) -> X187Build:
  w13c_emit_bin_rc(x185_id_to_const(right,ids),w64,cc,ak,right,ids,frame,build)

# --- Direct call arguments onto X187Build ---

@unsafe
def w13c_call_args(args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame, +index: U32, +build: X187Build) -> X187Build:
  match args:
    case Nil{}: build
    case Con{N111Arg{+typ,+val},+rest}:
      +is32 = U32.is_eq(p111v_type(typ),1)
      nt_choose(X187Build,U32.is_lt(index,6),
        u =>
          +rn = w13c_argreg_num(index)
          +b1 = w13c_load_val(val,ids,frame,rn,build)
          +b2 = nt_choose(X187Build,is32,v => w13c_b_movl_rr(rn,rn,b1),v => b1)
          w13c_call_args(rest,ids,frame,U32.inc(index),b2),
        u =>
          +b1 = w13c_load_val(val,ids,frame,10,build)
          +b2 = nt_choose(X187Build,is32,v => w13c_b_movl_rr(10,10,b1),v => b1)
          +b3 = w13c_b_movq_rm(10,4,U32.mul(U32.sub(index,6),8),b2)
          w13c_call_args(rest,ids,frame,U32.inc(index),b3))

@unsafe
def w13c_call_is_special(+sym: String) -> Bool:
  agy_str_eq(sym,"p111_rt_op") || agy_str_eq(sym,"p118_rt_borrow_scalar_safe") || String.starts_with(sym,"agy_rt_")

# Pre-assembled 150-byte agy_rt_sink_skip_text template (constant internal branch offsets)
def w13c_sink_tpl_bytes() -> List<&2,U32>:
  [72,133,246,15,141,59,0,0,0,76,139,15,73,137,240,73,193,224,24,73,193,232,24,79,141,20,193,77,139,26,
   68,137,216,129,224,255,255,255,0,129,248,1,0,0,0,15,134,92,0,0,0,73,129,235,1,0,0,0,77,137,26,49,192,
   233,82,0,0,0,72,137,240,72,193,232,56,72,129,248,2,0,0,0,15,130,48,0,0,0,73,137,240,73,193,224,24,73,
   193,232,24,76,139,13,0,0,0,0,73,129,193,127,0,0,0,73,129,225,128,255,255,255,73,129,193,0,130,16,3,77,
   57,200,15,131,7,0,0,0,49,192,233,7,0,0,0,49,192,232,0,0,0,0]

# Pre-assembled 152-byte agy_rt_keep_fast_text template (constant internal branch offsets)
def w13c_keep_tpl_bytes() -> List<&2,U32>:
  [72,133,246,15,141,60,0,0,0,76,139,15,73,137,240,73,193,224,24,73,193,232,24,79,141,20,193,77,139,26,
   68,137,216,129,224,255,255,255,0,129,248,254,255,255,0,15,131,94,0,0,0,73,129,195,1,0,0,0,77,137,26,
   72,137,240,233,83,0,0,0,72,137,240,72,193,232,56,72,129,248,2,0,0,0,15,130,48,0,0,0,73,137,240,73,193,
   224,24,73,193,232,24,76,139,13,0,0,0,0,73,129,193,127,0,0,0,73,129,225,128,255,255,255,73,129,193,0,
   130,16,3,77,57,200,15,131,8,0,0,0,72,137,240,233,7,0,0,0,49,192,232,0,0,0,0]

@unsafe
def w13c_b_sink_tpl(+build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217550),
        u =>
          +b1 : X187Build = X187Build{1,nt_reverse(U32,w13c_sink_tpl_bytes(),t),r,d,U32.add(ts,150),rs,ds,symbols,names,relocs,error}
          +b2 = x187_build_relocation(X187Relocation{1,U32.add(ts,102),2,"p111_program",60,0},b1)
          x187_build_relocation(X187Relocation{1,U32.add(ts,146),4,"p111_rt_sink",4294967292,4294967295},b2),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_b_keep_tpl(+build: X187Build) -> X187Build:
  match build:
    case X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error}:
      nt_choose(X187Build,U32.is_le(ts,134217550),
        u =>
          +b1 : X187Build = X187Build{1,nt_reverse(U32,w13c_keep_tpl_bytes(),t),r,d,U32.add(ts,152),rs,ds,symbols,names,relocs,error}
          +b2 = x187_build_relocation(X187Relocation{1,U32.add(ts,103),2,"p111_program",60,0},b1)
          x187_build_relocation(X187Relocation{1,U32.add(ts,148),4,"p111_rt_keep",4294967292,4294967295},b2),
        u => x187_build_error("x86 object section exceeds 128 MiB bound",build))
    case _: x187_build_error("instruction outside text",build)

@unsafe
def w13c_emit_call_direct(+name: String, +typ: N111Type, +sym: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>,
    +next: U32, +term: Bool) -> W13cSt:
  +b1 = w13c_call_args(args,ids,frame,0,build)
  +b2 = w13c_b_xorl_eax_call(sym,b1)
  +b3 = nt_choose(X187Build,U32.is_eq(p111v_type(typ),1),v => w13c_b_movl_rr(0,0,b2),v => b2)
  +b4 = w13c_store_reg(name,frame,0,b3)
  W13cSt{b4,lsyms,lrelocs,next,term}

@unsafe
def w13c_emit_call_sink_keep(+is_sink: Bool, +name: String, +typ: N111Type, +sym: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>,
    +next: U32, +term: Bool) -> W13cSt:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term_v},Nil{}}}:
      nt_choose(W13cSt,agy_str_eq(state,"state") && U32.is_le(next,4294967291),
        u =>
          +b1 = w13c_call_args(args,ids,frame,0,build)
          +b2 = nt_choose(X187Build,is_sink,v => w13c_b_sink_tpl(b1),v => w13c_b_keep_tpl(b1))
          +b3 = w13c_store_reg(name,frame,0,b2)
          W13cSt{b3,lsyms,lrelocs,U32.add(next,4),term},
        u => w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term))
    case _ _: w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term)

@unsafe
def w13c_emit_call_ctor0(+name: String, +typ: N111Type, +sym: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +build: X187Build, +lsyms: KDef, +lrelocs: List<&2,X187Relocation>,
    +next: U32, +term: Bool) -> W13cSt:
  match typ args:
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}}:
      nt_choose(W13cSt,agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u =>
          +b1 = w13c_b_movabsq(0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256)),0,build)
          +b2 = w13c_store_reg(name,frame,0,b1)
          W13cSt{b2,lsyms,lrelocs,next,term},
        u => w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term))
    case _ _: w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term)

@unsafe
def w13c_apply_fn_st(fn_st: W10fFnBuild, next: U32, term: Bool) -> W13cSt:
  match fn_st:
    case W10fFnBuild{b2,ls2,lr2}: W13cSt{b2,ls2,lr2,next,term}

@unsafe
def w13c_apply_code(code: X181Code, +st: W13cSt) -> W13cSt:
  match code st:
    case X181Code{chunks,+next,+term,+err} W13cSt{+build,+lsyms,+lrelocs,_,_}:
      nt_choose(W13cSt,String.is_empty(err),
        u => w13c_apply_fn_st(w10f_fn_chunks(nt_reverse(X188Seq,chunks,[]),W10fFnBuild{build,lsyms,lrelocs}),next,term),
        u => W13cSt{x187_build_error(err,build),lsyms,lrelocs,next,term})

# --- Direct local branch & label helpers on W13cSt ---

@unsafe
def w13c_emit_test_jz(+lbl: String, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error},+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,U32.is_le(ts,134217700),
        u =>
          +t1 : List<&2,U32> = Con{0,Con{0,Con{0,Con{0,Con{132,Con{15,Con{210,Con{133,Con{69,t}}}}}}}}}
          W13cSt{
            X187Build{1,t1,r,d,U32.add(ts,9),rs,ds,symbols,names,relocs,error},
            lsyms,
            Con{X187Relocation{1,U32.add(ts,5),130,lbl,4294967292,4294967295},lrelocs},
            next,term},
        u => W13cSt{x187_build_error("x86 object section exceeds 128 MiB bound",
          X187Build{1,t,r,d,ts,rs,ds,symbols,names,relocs,error}),lsyms,lrelocs,next,term})
    case W13cSt{build,lsyms,lrelocs,next,term}:
      W13cSt{x187_build_error("instruction outside text",build),lsyms,lrelocs,next,term}

@unsafe
def w13c_emit_jmp_lbl(+lbl: String, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{X187Build{1,+t,r,d,+ts,rs,ds,symbols,names,relocs,error},+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,U32.is_le(ts,134217712),
        u => W13cSt{
          X187Build{1,Con{0,Con{0,Con{0,Con{0,Con{233,t}}}}},r,d,U32.add(ts,5),rs,ds,symbols,names,relocs,error},
          lsyms,
          Con{X187Relocation{1,U32.inc(ts),130,lbl,4294967292,4294967295},lrelocs},
          next,term},
        u => W13cSt{x187_build_error("x86 object section exceeds 128 MiB bound",
          X187Build{1,t,r,d,ts,rs,ds,symbols,names,relocs,error}),lsyms,lrelocs,next,term})
    case W13cSt{build,lsyms,lrelocs,next,term}:
      W13cSt{x187_build_error("instruction outside text",build),lsyms,lrelocs,next,term}

@unsafe
def w13c_def_lbl(+lbl: String, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      +ts = x187_build_offset(build)
      +h = index_hash(lbl,2166136261)
      W13cSt{build,p111v_put_h(lsyms,lbl,h,"W10fL",ts,0),lrelocs,next,term}

# --- Main fused statement emitter for public segments ---

law w13c_emit_stmts:
  for body: List<&2,P113DStmt>
  for +ids: N111Ids
  for +frame: X181Frame
  for +uses_state: Bool
  for +st: W13cSt
  W13cSt

@unsafe
def w13c_emit_if_no(+lbl_end: String, +yt: Bool, st_no: W13cSt) -> W13cSt:
  match st_no:
    case W13cSt{+bn,+lsn,+lrn,+nn,+nt}:
      nt_choose(W13cSt,yt && nt,
        u => W13cSt{bn,lsn,lrn,nn,True{}},
        u => w13c_def_lbl(lbl_end,W13cSt{bn,lsn,lrn,nn,False{}}))

@unsafe
def w13c_emit_if_yes(+lbl_else: String, +lbl_end: String, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, st_yes: W13cSt) -> W13cSt:
  match st_yes:
    case W13cSt{+by,+lsy,+lry,+ny,+yt}:
      +st_mid = w13c_def_lbl(lbl_else,nt_choose(W13cSt,yt,
        u => W13cSt{by,lsy,lry,ny,False{}},
        u => w13c_emit_jmp_lbl(lbl_end,W13cSt{by,lsy,lry,ny,False{}})))
      w13c_emit_if_no(lbl_end,yt,w13c_emit_stmts(no,ids,frame,uses_state,st_mid))

@unsafe
def w13c_emit_if(+cond: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match st:
    case W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +lbl_else = w13c_lbl(next)
      +lbl_end = w13c_lbl(U32.inc(next))
      +b1 = w13c_load_val(cond,ids,frame,10,build)
      +st1 = w13c_emit_test_jz(lbl_else,W13cSt{b1,lsyms,lrelocs,U32.add(next,2),False{}})
      w13c_emit_if_yes(lbl_else,lbl_end,no,ids,frame,uses_state,w13c_emit_stmts(yes,ids,frame,uses_state,st1))

@unsafe
def w13c_is_state_val(v: N111Value) -> Bool:
  match v:
    case N111Local{n}: agy_str_eq(n,"state")
    case _: False{}

@unsafe
def w13c_emit_scalar(+stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +st: W13cSt) -> W13cSt:
  match stmt st:
    case N111Alloca{_,_,_} _: st
    case N111Set{+name,+typ,+value} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,agy_str_eq(name,"state"),
        u => w13c_apply_code(x181_add(x186_set_text(name,typ,value,ids,frame),X181Code{[],next,term,""}),st),
        u =>
          +b1 = w13c_load_val(value,ids,frame,10,build)
          +b2 = nt_choose(X187Build,U32.is_eq(p111v_type(typ),1),v => w13c_b_movl_rr(10,10,b1),v => b1)
          +b3 = w13c_store_reg(name,frame,10,b2)
          W13cSt{b3,lsyms,lrelocs,next,term})
    case N111Load{+name,+typ,+base,+offset} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,U32.is_le(offset,2147483647) && Bool.not(agy_str_eq(name,"state")),
        u =>
          +b1 = w13c_load_val(base,ids,frame,10,build)
          +b2 = nt_choose(X187Build,U32.is_eq(p111v_type(typ),1),
            v => w13c_b_movl_mr(10,offset,10,b1),
            v => w13c_b_movq_mr(10,offset,10,b1))
          +b3 = w13c_store_reg(name,frame,10,b2)
          W13cSt{b3,lsyms,lrelocs,next,term},
        u => w13c_apply_code(x181_add(x186_load_text(name,typ,base,offset,ids,frame),X181Code{[],next,term,""}),st))
    case N111Store{+typ,+base,+offset,+value} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,U32.is_le(offset,2147483647) && Bool.not(w13c_is_state_val(base) && w13c_is_state_val(value)),
        u =>
          +b1 = w13c_load_val(base,ids,frame,10,build)
          +b2 = w13c_load_val(value,ids,frame,11,b1)
          +b3 = nt_choose(X187Build,U32.is_eq(p111v_type(typ),1),
            v => w13c_b_movl_rm(11,10,offset,b2),
            v => w13c_b_movq_rm(11,10,offset,b2))
          W13cSt{b3,lsyms,lrelocs,next,term},
        u => w13c_apply_code(x181_add(x190_store_memory(typ,base,offset,value,ids,frame),X181Code{[],next,term,""}),st))
    case N111Bin{+name,+typ,+op,+left,+right} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      +cc = w13c_cmp_setcc(op)
      +ak = nt_choose(U32,U32.is_gt(cc,0),u => 0,u => w13c_alu_kind(op))
      nt_choose(W13cSt,(U32.is_gt(cc,0) || U32.is_gt(ak,0)) && Bool.not(agy_str_eq(name,"state")),
        u =>
          +w64 = Bool.not(U32.is_eq(p111v_type(typ),1))
          +b1 = w13c_load_val(left,ids,frame,10,build)
          +b2 = w13c_emit_bin_op(w64,cc,ak,right,ids,frame,b1)
          +b3 = w13c_store_reg(name,frame,10,b2)
          W13cSt{b3,lsyms,lrelocs,next,term},
        u => w13c_apply_code(x181_binary(name,typ,op,left,right,ids,frame,X181Code{[],next,term,""}),st))
    case N111Offset{+name,+base,+bytes} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,Bool.not(agy_str_eq(name,"state")),
        u =>
          +b1 = w13c_load_val(base,ids,frame,10,build)
          +b2 = w13c_emit_bin_op(True{},0,10,bytes,ids,frame,b1)
          +b3 = w13c_store_reg(name,frame,10,b2)
          W13cSt{b3,lsyms,lrelocs,next,term},
        u => w13c_apply_code(x181_binary(name,N111Ptr{},"add",base,bytes,ids,frame,X181Code{[],next,term,""}),st))
    case N111Return{+value} W13cSt{+build,+lsyms,+lrelocs,+next,_}:
      +b1 = w13c_load_val(value,ids,frame,0,build)
      +b2 = w13c_b_epilogue(uses_state,b1)
      W13cSt{b2,lsyms,lrelocs,next,True{}}
    case N111If{cond,yes,no} _:
      w13c_emit_if(cond,x181_scalar_rows(yes),x181_scalar_rows(no),ids,frame,uses_state,st)
    case N111Call{+name,+typ,+sym,+args} W13cSt{+build,+lsyms,+lrelocs,+next,+term}:
      nt_choose(W13cSt,agy_str_eq(sym,"p111_rt_sink"),
        u => w13c_emit_call_sink_keep(True{},name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term),u =>
      nt_choose(W13cSt,agy_str_eq(sym,"p111_rt_keep"),
        u => w13c_emit_call_sink_keep(False{},name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term),u =>
      nt_choose(W13cSt,agy_str_eq(sym,"p111_rt_ctor"),
        u => w13c_emit_call_ctor0(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term),u =>
      nt_choose(W13cSt,w13c_call_is_special(sym),
        u => w13c_apply_code(agy_rt_inline_try(name,typ,sym,args,ids,frame,X181Code{[],next,term,""}),st),
        u => w13c_emit_call_direct(name,typ,sym,args,ids,frame,build,lsyms,lrelocs,next,term)))))

@unsafe
def w13c_emit_one(head: P113DStmt, +ids: N111Ids, +frame: X181Frame, +uses_state: Bool, +next: U32, +term: Bool, +st: W13cSt) -> W13cSt:
  match head:
    case P113DScalar{scalar}: w13c_emit_scalar(scalar,ids,frame,uses_state,st)
    case P113DIf{cond,yes,no}: w13c_emit_if(cond,yes,no,ids,frame,uses_state,st)
    case other: w13c_apply_code(x181_stmt(other,ids,frame,X181Code{[],next,term,""}),st)

@unsafe
def w13c_emit_stmts(body,ids,frame,uses_state,st):
  match body st:
    case Nil{} _: st
    case Con{head,rest} W13cSt{X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,SNil{}},lsyms,lrelocs,+next,False{}}:
      w13c_emit_stmts(rest,ids,frame,uses_state,w13c_emit_one(head,ids,frame,uses_state,next,False{},st))
    case Con{_,_} W13cSt{X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,SNil{}},lsyms,lrelocs,next,True{}}:
      W13cSt{x187_build_error("x86 statement after terminal",X187Build{s,t,r,d,ts,rs,ds,symbols,names,relocs,""}),lsyms,lrelocs,next,True{}}
    case Con{_,_} _: st

@unsafe
def w13c_pub_emit_done(+sym: String, st_end: W13cSt) -> X187Build:
  match st_end:
    case W13cSt{+b_end,+lsyms,+lrelocs,_,+term}:
      +b_chk = nt_choose(X187Build,String.is_empty(x187_build_message(b_end)) && Bool.not(term),
        u => x187_build_error("x86 unterminated function",b_end),
        u => x187_build_symbol(sym,4,0,b_end))
      w10f_fn_finish(W10fFnBuild{b_chk,lsyms,lrelocs})

@unsafe
def w13c_pub_emit_framed(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +uses_state: Bool, +build: X187Build, +frame: X181Frame) -> X187Build:
  match frame:
    case X181Frame{_,+bytes,+calls,_,_}:
      +frame_sz = U32.add(U32.mul(U32.div(U32.add(U32.add(bytes,calls),15),16),16),48)
      +b0 = w13c_b_prologue(sym,frame_sz,uses_state,build)
      w13c_pub_emit_done(sym,w13c_emit_stmts(body,ids,frame,uses_state,W13cSt{b0,missing(),[],0,False{}}))

@unsafe
def w13c_pub_emit_body(+sym: String, +body: List<&2,P113DStmt>, +ids: N111Ids, +build: X187Build) -> X187Build:
  +uses_state = w4_body_uses_state(body)
  +stateKind = nt_choose(String,uses_state,u => "X181Register",u => "X181UnusedState")
  +savedMask = nt_choose(U32,uses_state,u => 1,u => 0)
  +s0 = p111v_put(p111v_put(missing(),"state",stateKind,0,8),"__x181_saved_mask","X186SavedMask",savedMask,0)
  +init : X181Frame = X181Frame{s0,40,0,["state"],""}
  +f1 = x181_frame_buffer("scratch",2048,16,init)
  +f2 = x181_frame_buffer("__x181_results",64,16,f1)
  +f3 = x181_frame_buffer("__x181_tail",8,8,f2)
  w13c_pub_emit_framed(sym,body,ids,uses_state,build,x181_frame_stmts(body,f3))

@unsafe
def w13c_pub_emit_late(+sym: String, +ids: N111Ids, +build: X187Build, late: P113ABody) -> X187Build:
  match late:
    case P113ABody{ready,_}: w13c_pub_emit_body(sym,ready,ids,build)

@unsafe
def w13c_pub_emit_seg(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,+body} P134Context{+ids,index,direct,ready,view,lookups,heap,mode}:
      +error = w7c_pub_check_scalars(body,available)
      nt_choose(X187Build,String.is_empty(error),
        v =>
          +sym = p111q_symbol(name)
          nt_choose(X187Build,x202k_shape(body),
            w => w13c_emit_x202k(sym,build),
            w =>
              +rows = x181_scalar_rows(body)
              nt_choose(X187Build,x185_late_enabled() && p114t_scalar_list_names(body),
                z => w13c_pub_emit_late(sym,ids,build,x185_late_stmts(rows,ids,0)),
                z => w13c_pub_emit_body(sym,rows,ids,build))),
        v => x187_build_error(error,build))

@unsafe
def w13c_pub_emit_fast(+segment: N111Segment, context: P134Context, +available: KDef, +build: X187Build) -> X187Build:
  nt_choose(X187Build,String.is_empty(x187_build_message(build)),
    u => w13c_pub_emit_seg(segment,context,available,build),
    u => build)
