# Wave 10 M1: 100% Pure-Bend Link-Time Segment Table Merge Object Emitter (`x86-merge-obj`)
#
# Replaces `research/agy/w8_fid_base/p111_link_merge.c` completely with zero C,
# emitting a relocatable x86-64 ELF `.o` via `compiler.bend`'s existing
# `x188_*` x86-64 encoder and `x187_*` / `x202p_x201f_finish` ELF emitter.
#
# CLI mode (dispatched from `w8_dispatch_args`):
#   x86-merge-obj ENTRY_MOD MOD0 [MOD1 ...]
#
# Emits:
#   .data (section 3):
#     - global p111_program           (192 bytes, ABI11102 P111Program)
#     - local  w8_merged_segments     (65532 * 8 = 524256 bytes)
#     - local  w8_merged_fid_arity    (65532 bytes)
#     - local  w8_merged_fid_flags    (65532 bytes)
#     - local  w8_merged_fid_results  (65532 bytes)
#   .text (section 1):
#     - local  w8_unused_seg          (`ret`)
#     - global main(argc, argv):
#         preserves %edi (argc) and %rsi (argv) across all loops using only
#         caller-saved scratch registers (%rax, %rcx, %rdx, %r8..%r11), merges
#         all module segment tables at `p111_mod_<M>_fid_base`, sets `main_fid`
#         from `p111_mod_<ENTRY_MOD>_program`, and tail-calls `p111_rt_main`.

@unsafe
def w10_merge_zero_data(+name: String, +exported: Bool, +bytes: U32) -> X188Seq:
  x188_many([
    X188One{PSection{3}},
    X188One{PAlign{8}},
    nt_choose(X188Seq,exported,u => X188One{PGlobal{name}},u => X188Empty{}),
    X188One{PType{name,1}},
    x188_label(name),
    X188One{PDatum{P111QZeros{bytes}}},
    X188One{PSize{name}}])

@unsafe
def w10_merge_data() -> X188Seq:
  x188_many([
    w10_merge_zero_data("p111_program",True{},192),
    w10_merge_zero_data("w8_merged_segments",False{},524256),
    w10_merge_zero_data("w8_merged_fid_arity",False{},65532),
    w10_merge_zero_data("w8_merged_fid_flags",False{},65532),
    w10_merge_zero_data("w8_merged_fid_results",False{},65532)])

@unsafe
def w10_merge_unused_seg() -> X188Seq:
  x188_many([
    X188One{PSection{1}},
    X188One{PAlign{16}},
    X188One{PType{"w8_unused_seg",2}},
    x188_label("w8_unused_seg"),
    x188_i0("ret"),
    X188One{PSize{"w8_unused_seg"}}])

@unsafe
def w10_merge_copy_root(+first_mod: String) -> X188Seq:
  +prog_sym = "p111_mod_" ++ first_mod ++ "_program"
  x188_many([
    x188_i2("leaq",X187Rip{prog_sym,0,0},x188_reg(8,64)),
    x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(9,64)),
    x188_i2("movl",X187Imm{24,0},x188_reg(1,32)),
    x188_label(".Lm_hdr_loop"),
    x188_i2("movq",X187Mem{8,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{9,0}),
    x188_i2("addq",X187Imm{8,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{8,0},x188_reg(9,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{".Lm_hdr_loop"})])

@unsafe
def w10_merge_total_one(+mod_name: String, +idx: U32) -> X188Seq:
  +base_sym = "p111_mod_" ++ mod_name ++ "_fid_base"
  +prog_sym = "p111_mod_" ++ mod_name ++ "_program"
  +lbl_skip = ".Lm_tot_" ++ U32.show(idx)
  x188_many([
    x188_i2("movq",X187Rip{base_sym,0,0},x188_reg(0,64)),
    x188_i2("leaq",X187Rip{prog_sym,0,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,16},x188_reg(1,64)),
    x188_i2("addq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{65532,0},x188_reg(0,64)),
    x188_i1("ja",X187Target{".Lm_overflow"}),
    x188_i2("cmpq",x188_reg(11,64),x188_reg(0,64)),
    x188_i1("jbe",X187Target{lbl_skip}),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_label(lbl_skip)])

@unsafe
def w10_merge_totals(mods: List<&1,String>, +idx: U32) -> X188Seq:
  match mods:
    case Nil{}: X188Empty{}
    case Con{+head,rest}:
      x188_cat(w10_merge_total_one(head,idx),w10_merge_totals(rest,U32.inc(idx)))

@unsafe
def w10_merge_fill_sentinel() -> X188Seq:
  x188_many([
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("je",X187Target{".Lm_fill_done"}),
    x188_i2("leaq",X187Rip{"w8_unused_seg",0,0},x188_reg(0,64)),
    x188_i2("leaq",X187Rip{"w8_merged_segments",0,0},x188_reg(8,64)),
    x188_i2("leaq",X187Rip{"w8_merged_fid_arity",0,0},x188_reg(9,64)),
    x188_i2("leaq",X187Rip{"w8_merged_fid_flags",0,0},x188_reg(10,64)),
    x188_i2("leaq",X187Rip{"w8_merged_fid_results",0,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(1,64)),
    x188_label(".Lm_fill_loop"),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,0}),
    x188_i2("movb",X187Imm{0,0},X187Mem{9,0}),
    x188_i2("movb",X187Imm{0,0},X187Mem{10,0}),
    x188_i2("movb",X187Imm{0,0},X187Mem{2,0}),
    x188_i2("addq",X187Imm{8,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(10,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(2,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{".Lm_fill_loop"}),
    x188_label(".Lm_fill_done")])

@unsafe
def w10_merge_copy_bytes(+field_off: U32, +dst_sym: String, +lbl: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Mem{8,field_off},x188_reg(9,64)),
    x188_i2("leaq",X187Rip{dst_sym,0,0},x188_reg(10,64)),
    x188_i2("addq",x188_reg(2,64),x188_reg(10,64)),
    x188_i2("movq",X187Mem{8,16},x188_reg(1,64)),
    x188_label(lbl),
    x188_i2("movb",X187Mem{9,0},x188_reg(0,8)),
    x188_i2("movb",x188_reg(0,8),X187Mem{10,0}),
    x188_i2("addq",X187Imm{1,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(10,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{lbl})])

@unsafe
def w10_merge_copy_one(+mod_name: String, +idx: U32) -> X188Seq:
  +s = U32.show(idx)
  +base_sym = "p111_mod_" ++ mod_name ++ "_fid_base"
  +prog_sym = "p111_mod_" ++ mod_name ++ "_program"
  +lbl_rw = ".Lm_rw_" ++ s
  +lbl_resw = ".Lm_resw_" ++ s
  +lbl_cseg = ".Lm_cseg_" ++ s
  +lbl_done = ".Lm_done_" ++ s
  x188_many([
    x188_i2("movq",X187Rip{base_sym,0,0},x188_reg(2,64)),
    x188_i2("leaq",X187Rip{prog_sym,0,0},x188_reg(8,64)),
    x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(9,64)),
    x188_i2("movq",X187Mem{8,48},x188_reg(0,64)),
    x188_i2("cmpq",X187Mem{9,48},x188_reg(0,64)),
    x188_i1("jbe",X187Target{lbl_rw}),
    x188_i2("movq",x188_reg(0,64),X187Mem{9,48}),
    x188_label(lbl_rw),
    x188_i2("movq",X187Mem{8,56},x188_reg(0,64)),
    x188_i2("cmpq",X187Mem{9,56},x188_reg(0,64)),
    x188_i1("jbe",X187Target{lbl_resw}),
    x188_i2("movq",x188_reg(0,64),X187Mem{9,56}),
    x188_label(lbl_resw),
    x188_i2("movq",X187Mem{8,16},x188_reg(1,64)),
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("je",X187Target{lbl_done}),
    x188_i2("movq",X187Mem{8,96},x188_reg(9,64)),
    x188_i2("leaq",X187Rip{"w8_merged_segments",0,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{3,0},x188_reg(0,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(10,64)),
    x188_label(lbl_cseg),
    x188_i2("movq",X187Mem{9,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{10,0}),
    x188_i2("addq",X187Imm{8,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{8,0},x188_reg(10,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{lbl_cseg}),
    w10_merge_copy_bytes(104,"w8_merged_fid_arity",".Lm_car_" ++ s),
    w10_merge_copy_bytes(112,"w8_merged_fid_flags",".Lm_cfl_" ++ s),
    w10_merge_copy_bytes(120,"w8_merged_fid_results",".Lm_crs_" ++ s),
    x188_label(lbl_done)])

@unsafe
def w10_merge_copies(mods: List<&1,String>, +idx: U32) -> X188Seq:
  match mods:
    case Nil{}: X188Empty{}
    case Con{+head,rest}:
      x188_cat(w10_merge_copy_one(head,idx),w10_merge_copies(rest,U32.inc(idx)))

@unsafe
def w10_merge_main(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> X188Seq:
  +entry_sym = "p111_mod_" ++ entry_mod ++ "_program"
  x188_many([
    X188One{PSection{1}},
    X188One{PAlign{16}},
    X188One{PGlobal{"main"}},
    X188One{PType{"main",2}},
    x188_label("main"),
    w10_merge_copy_root(first_mod),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    w10_merge_totals(mods,0),
    w10_merge_fill_sentinel(),
    w10_merge_copies(mods,0),
    x188_i2("leaq",X187Rip{"p111_program",0,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{2,16}),
    x188_i2("leaq",X187Rip{entry_sym,0,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,32},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,32}),
    x188_i2("leaq",X187Rip{"w8_merged_segments",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,96}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_arity",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,104}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_flags",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,112}),
    x188_i2("leaq",X187Rip{"w8_merged_fid_results",0,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{2,120}),
    x188_i1("jmp",X187Target{"p111_rt_main"}),
    x188_label(".Lm_overflow"),
    x188_i2("movl",X187Imm{2,0},x188_reg(0,32)),
    x188_i0("ret"),
    X188One{PSize{"main"}}])

@unsafe
def w10_merge_names_ok(mods: List<&1,String>) -> Bool:
  match mods:
    case Nil{}: True{}
    case Con{+head,rest}: Bool.not(String.is_empty(head)) && w10_merge_names_ok(rest)

@unsafe
def w10_merge_seq(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> X188Seq:
  x188_many([
    w10_merge_data(),
    w10_merge_unused_seg(),
    w10_merge_main(entry_mod,first_mod,mods)])

@unsafe
def w10_merge_run(+entry_mod: String, +first_mod: String, +mods: List<&1,String>) -> IO(U32):
  nt_choose(IO(U32),Bool.not(String.is_empty(entry_mod)) && w10_merge_names_ok(mods),
    u => x202p_x201f_finish(x187_build_seq(w10_merge_seq(entry_mod,first_mod,mods),x187_build_empty())),
    u => IO.die(U32,2,"x86-merge-obj: module names must be non-empty"))

@unsafe
def w10_merge_entry(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+entry_mod,Con{+first_mod,+more_mods}}:
      w10_merge_run(entry_mod,first_mod,Con{first_mod,more_mods})
    case _: IO.die(U32,2,"usage: x86-merge-obj ENTRY_MOD MOD0 [MOD1 ...]")
