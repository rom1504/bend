# Wave 9: 100% Pure-Bend Incremental & Parallel Module Build Driver
# =================================================================
# Native ABI11102 edition: uses ONLY effects supported by `wave8-native-self/n1`
# (`IO.args`, `IO.now`, `IO.print`, `IO.print_err`, `File.open/read/write/close`),
# so it compiles to a standalone native x86-64 ELF binary with zero Python/JS!
#
# Manifest format (one module per line, '#' comments and blank lines ignored):
#   <name> <src_path> <fid_base> <out_o_path>
#
# CLI usage:
#   bend_build <manifest> <compiler_bin> <base_bend> <carrier_p130> <stamp> \
#              <merge_c> <runtime_o> <entry_mod> <out_exe>
#
# Outputs:
#   stderr: live millisecond-timed progress & cache hit/miss summary
#   stdout: exact parallel shell build plan (pipe to `sh -e` to execute)

import Base

type ModSpec is Data:
  ModSpec{
    +name: String,
    +src: String,
    +fid_base: String,
    +out_o: String
  }

type BuildCfg is Data:
  BuildCfg{
    +compiler: String,
    +base_bend: String,
    +carrier: String,
    +stamp: String,
    +merge_c: String,
    +runtime_o: String,
    +entry_mod: String,
    +out_exe: String
  }

type BuildAcc is Data:
  BuildAcc{
    +cmds: String,
    +rebuilt: U32,
    +cached: U32
  }

# Dual 32-bit FNV-1a content hash in pure Bend (fast native U32 xor + mul)
# ------------------------------------------------------------------------

def fnv1a_step(h: U32, c: U32, prime: U32) -> U32:
  U32.mul(U32.xor(h, c), prime)

def fnv1a_go(s: String, h: U32, +prime: U32) -> U32:
  match s:
    case SNil{}:
      h
    case SCon{c, rest}:
      fnv1a_go(rest, fnv1a_step(h, Char.to_u32(c), prime), prime)

def content_hash(+src: String, +stamp: String, +fid_base: String, +name: String) -> String:
  +h1a = fnv1a_go(src, 2166136261, 16777619)
  +h1b = fnv1a_go(stamp, fnv1a_step(h1a, 10, 16777619), 16777619)
  +h1c = fnv1a_go(fid_base, fnv1a_step(h1b, 10, 16777619), 16777619)
  +h1  = fnv1a_go(name, fnv1a_step(h1c, 10, 16777619), 16777619)
  +h2a = fnv1a_go(src, 3759247821, 2246822519)
  +h2b = fnv1a_go(stamp, fnv1a_step(h2a, 10, 2246822519), 2246822519)
  +h2c = fnv1a_go(fid_base, fnv1a_step(h2b, 10, 2246822519), 2246822519)
  +h2  = fnv1a_go(name, fnv1a_step(h2c, 10, 2246822519), 2246822519)
  U32.hex(h1) ++ ":" ++ U32.hex(h2)

# Safe, total file IO helpers (Nat fuel = 256 chunks x 65536B = 16 MiB max)
# -------------------------------------------------------------------------

def read_chunks_empty(empty: Bool, f2: File, acc: String, chunk: String, cont: File -> String -> IO(Result<&1, &1, String, String>)) -> IO(Result<&1, &1, String, String>):
  match empty:
    case True{}:
      do IO<Result<&1, &1, String, String>>:
        _ : Unit <- File.close(f2)
        IO.pure(Result<&1, &1, String, String>, Done{acc})
    case False{}:
      cont(f2, acc ++ chunk)

def read_chunks_res(f2: File, acc: String, res: Result<&1, &1, U32 & String, String>, cont: File -> String -> IO(Result<&1, &1, String, String>)) -> IO(Result<&1, &1, String, String>):
  match res:
    case Fail{(code, msg)}:
      do IO<Result<&1, &1, String, String>>:
        _ : Unit <- File.close(f2)
        IO.pure(Result<&1, &1, String, String>, Fail{msg})
    case Done{+chunk}:
      read_chunks_empty(String.is_empty(chunk), f2, acc, chunk, cont)

def read_chunks_got(acc: String, got: File & Result<&1, &1, U32 & String, String>, cont: File -> String -> IO(Result<&1, &1, String, String>)) -> IO(Result<&1, &1, String, String>):
  match got:
    case (f2, res):
      read_chunks_res(f2, acc, res, cont)

def read_chunks(fuel: Nat, file: File, acc: String) -> IO(Result<&1, &1, String, String>):
  match fuel:
    case 0n:
      do IO<Result<&1, &1, String, String>>:
        _ : Unit <- File.close(file)
        IO.pure(Result<&1, &1, String, String>, Done{acc})
    case 1n+p:
      do IO<Result<&1, &1, String, String>>:
        got : File & Result<&1, &1, U32 & String, String> <- File.read(file, 65536)
        read_chunks_got(acc, got, f2 => acc2 => read_chunks(p, f2, acc2))

def read_file_done(r: Result<&1, &1, String, String>) -> IO(Maybe<&2, String>):
  match r:
    case Fail{err}:
      IO.pure(Maybe<&2, String>, None{})
    case Done{txt}:
      IO.pure(Maybe<&2, String>, Some{txt})

def read_file_opened(opened: Result<&1, &1, U32 & String, File>) -> IO(Maybe<&2, String>):
  match opened:
    case Fail{(code, msg)}:
      IO.pure(Maybe<&2, String>, None{})
    case Done{f}:
      do IO<Maybe<&2, String>>:
        r : Result<&1, &1, String, String> <- read_chunks(256n, f, "")
        read_file_done(r)

def read_file_opt(path: String) -> IO(Maybe<&2, String>):
  do IO<Maybe<&2, String>>:
    opened : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    read_file_opened(opened)

def file_exists_opened(opened: Result<&1, &1, U32 & String, File>) -> IO(Bool):
  match opened:
    case Fail{(code, msg)}:
      IO.pure(Bool, False{})
    case Done{f}:
      do IO<Bool>:
        _ : Unit <- File.close(f)
        IO.pure(Bool, True{})

def file_exists(path: String) -> IO(Bool):
  do IO<Bool>:
    opened : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    file_exists_opened(opened)

def read_file_req_got(+path: String, got: Maybe<&2, String>) -> IO(String):
  match got:
    case Some{txt}:
      IO.pure(String, txt)
    case None{}:
      IO.die(String, 1, "[bend-build] ERROR: cannot read file: " ++ path)

def read_file_req(+path: String) -> IO(String):
  do IO<String>:
    got : Maybe<&2, String> <- read_file_opt(path)
    read_file_req_got(path, got)

# Manifest parsing: "name src fid_base out_o"
# -------------------------------------------

def drop_empty_step(empty: Bool, h: String, t: List<&2, String>) -> List<&2, String>:
  match empty:
    case True{}:
      t
    case False{}:
      Con{h, t}

def drop_empty(xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{+h, t}:
      drop_empty_step(String.is_empty(h), h, drop_empty(t))

def parse_toks(toks: List<&2, String>) -> Maybe<&2, ModSpec>:
  match toks:
    case Con{name, Con{src, Con{fid_base, Con{out_o, Nil{}}}}}:
      Some{ModSpec{name, src, fid_base, out_o}}
    case _:
      None{}

def parse_line_skip(skip: Bool, +trimmed: String) -> Maybe<&2, ModSpec>:
  match skip:
    case True{}:
      None{}
    case False{}:
      parse_toks(drop_empty(String.split(trimmed, ' ')))

def parse_line(+line: String) -> Maybe<&2, ModSpec>:
  +trimmed = String.trim(line)
  parse_line_skip(String.is_empty(trimmed) || String.starts_with(trimmed, "#"), trimmed)

def parse_manifest_push(m: Maybe<&2, ModSpec>, rest: List<&2, ModSpec>) -> List<&2, ModSpec>:
  match m:
    case None{}:
      rest
    case Some{spec}:
      Con{spec, rest}

def parse_manifest_lines(lines: List<&2, String>) -> List<&2, ModSpec>:
  match lines:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      parse_manifest_push(parse_line(h), parse_manifest_lines(t))

def count_mods(mods: List<&2, ModSpec>) -> U32:
  match mods:
    case Nil{}:
      0
    case Con{_, t}:
      U32.inc(count_mods(t))

# Shell command emitters
# ----------------------

def sh_quote(+s: String) -> String:
  "'" ++ s ++ "'"

def build_compile_finalize(is_entry: Bool, +tmp_o: String, +out_o: String) -> String:
  match is_entry:
    case True{}:
      "mv " ++ sh_quote(tmp_o) ++ " " ++ sh_quote(out_o)
    case False{}:
      "objcopy -L p111_FID_109_97_105_110_ -L p113d_FID_109_97_105_110_ " ++ sh_quote(tmp_o) ++ " " ++ sh_quote(out_o) ++ " && rm -f " ++ sh_quote(tmp_o)

def build_compile_cmd_m(+compiler: String, +base_bend: String, +carrier: String, +stamp: String, +entry_mod: String, m: ModSpec, +hash: String) -> String:
  match m:
    case ModSpec{+name, +src, +fid_base, +out_o}:
      +tmp_o = out_o ++ ".tmp"
      +hash_f = out_o ++ ".hash"
      +finalize = build_compile_finalize(String.eq(name, entry_mod), tmp_o, out_o)
      "(" ++ sh_quote(compiler) ++ " x86-module " ++ sh_quote(src) ++ " " ++ sh_quote(base_bend) ++ " cache " ++ sh_quote(carrier) ++ " " ++ sh_quote(stamp) ++ " " ++ fid_base ++ " " ++ name ++ " > " ++ sh_quote(tmp_o) ++ " && " ++ finalize ++ " && printf '%s\\n' " ++ sh_quote(hash) ++ " > " ++ sh_quote(hash_f) ++ ") &\n"

def build_compile_cmd(cfg: BuildCfg, m: ModSpec, +hash: String) -> String:
  match cfg:
    case BuildCfg{compiler, base_bend, carrier, stamp, _, _, entry_mod, _}:
      build_compile_cmd_m(compiler, base_bend, carrier, stamp, entry_mod, m, hash)

def fmt_w8_modules(mods: List<&2, ModSpec>) -> String:
  match mods:
    case Nil{}:
      ""
    case Con{ModSpec{name, _, _, _}, Nil{}}:
      "X(" ++ name ++ ")"
    case Con{ModSpec{name, _, _, _}, rest}:
      "X(" ++ name ++ ") " ++ fmt_w8_modules(rest)

def fmt_obj_list(mods: List<&2, ModSpec>) -> String:
  match mods:
    case Nil{}:
      ""
    case Con{ModSpec{_, _, _, out_o}, rest}:
      " " ++ sh_quote(out_o) ++ fmt_obj_list(rest)

def build_link_cmds(cfg: BuildCfg, +mods: List<&2, ModSpec>) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, +merge_c, +runtime_o, +entry_mod, +out_exe}:
      +merge_o = out_exe ++ ".merge.o"
      +w8_mods = fmt_w8_modules(mods)
      +objs = fmt_obj_list(mods)
      +c1 = "gcc-10 -O2 -c " ++ sh_quote(merge_c) ++ " -DW8_ENTRY_MOD=" ++ entry_mod ++ " " ++ sh_quote("-DW8_MODULES(X)=" ++ w8_mods) ++ " -o " ++ sh_quote(merge_o) ++ "\n"
      +c2 = "gcc-10 -no-pie -Wl,--allow-multiple-definition " ++ sh_quote(merge_o) ++ objs ++ " " ++ sh_quote(runtime_o) ++ " -o " ++ sh_quote(out_exe) ++ " -lm -lpthread\n"
      c1 ++ c2

# Cache hit check & live stderr progress
# --------------------------------------

def check_hash_opt(old_hash_m: Maybe<&2, String>, +hash: String) -> Bool:
  match old_hash_m:
    case None{}:
      False{}
    case Some{old_h}:
      String.eq(String.trim(old_h), hash)

def check_cache_hit(obj_ok: Bool, old_hash_m: Maybe<&2, String>, +hash: String) -> Bool:
  match obj_ok:
    case False{}:
      False{}
    case True{}:
      check_hash_opt(old_hash_m, hash)

def process_mod_finish(is_hit: Bool, +cfg: BuildCfg, +m: ModSpec, +name: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +ms: String, +cmds: String, +rebuilt: U32, +cached: U32) -> IO(BuildAcc):
  match is_hit:
    case True{}:
      do IO<BuildAcc>:
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [cache HIT] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        IO.pure(BuildAcc, BuildAcc{cmds, rebuilt, U32.inc(cached)})
    case False{}:
      do IO<BuildAcc>:
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [MISS] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        +cmd : String = build_compile_cmd(cfg, m, hash)
        IO.pure(BuildAcc, BuildAcc{cmds ++ cmd, U32.inc(rebuilt), cached})

def process_mod_run(+cfg: BuildCfg, +stamp: String, +m: ModSpec, +name: String, +src: String, +fid_base: String, +out_o: String, +idx: U32, +total: U32, acc: BuildAcc) -> IO(BuildAcc):
  match acc:
    case BuildAcc{+cmds, +rebuilt, +cached}:
      do IO<BuildAcc>:
        +t0 : Nat <- IO.now()
        +src_txt : String <- read_file_req(src)
        +hash : String = content_hash(src_txt, stamp, fid_base, name)
        +obj_ok : Bool <- file_exists(out_o)
        +old_hash_m : Maybe<&2, String> <- read_file_opt(out_o ++ ".hash")
        +is_hit : Bool = check_cache_hit(obj_ok, old_hash_m, hash)
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        process_mod_finish(is_hit, cfg, m, name, out_o, hash, idx, total, ms, cmds, rebuilt, cached)

def process_mod_spec(+cfg: BuildCfg, +stamp: String, +m: ModSpec, +idx: U32, +total: U32, acc: BuildAcc) -> IO(BuildAcc):
  match m:
    case ModSpec{+name, +src, +fid_base, +out_o}:
      process_mod_run(cfg, stamp, m, name, src, fid_base, out_o, idx, total, acc)

def cfg_stamp(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, stamp, _, _, _, _}:
      stamp

def cfg_entry(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, entry_mod, _}:
      entry_mod

def cfg_out_exe(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, _, out_exe}:
      out_exe

def process_mods(+cfg: BuildCfg, mods: List<&2, ModSpec>, +idx: U32, +total: U32, acc: BuildAcc) -> IO(BuildAcc):
  match mods:
    case Nil{}:
      IO.pure(BuildAcc, acc)
    case Con{m, rest}:
      do IO<BuildAcc>:
        acc2 : BuildAcc <- process_mod_spec(cfg, cfg_stamp(cfg), m, idx, total, acc)
        process_mods(cfg, rest, U32.inc(idx), total, acc2)

# Plan emission & driver entry point
# ----------------------------------

def emit_plan_str(has_rebuilt: Bool, need_link: Bool, +cmds: String, +link_cmds: String) -> String:
  match has_rebuilt:
    case True{}:
      "set -euo pipefail\n" ++ cmds ++ "wait\n" ++ link_cmds
    case False{}:
      Bool.pick(String, need_link, "set -euo pipefail\n" ++ link_cmds, "# [bend-build] all modules cached and output binary up-to-date\n")

def finish_driver(+cfg: BuildCfg, +mods: List<&2, ModSpec>, +total: U32, +t_start: Nat, res: BuildAcc) -> IO(U32):
  match res:
    case BuildAcc{+cmds, +rebuilt, +cached}:
      do IO<U32>:
        +exe_ok : Bool <- file_exists(cfg_out_exe(cfg))
        +has_rebuilt : Bool = U32.is_gt(rebuilt, 0)
        +need_link : Bool = has_rebuilt || Bool.not(exe_ok)
        +plan : String = emit_plan_str(has_rebuilt, need_link, cmds, build_link_cmds(cfg, mods))
        _ : Unit <- IO.print(plan)
        +t_end : Nat <- IO.now()
        +elapsed : String = Nat.show(Nat.sub(t_end, t_start))
        _ : Unit <- IO.print_err("[bend-build] plan ready: total=" ++ U32.show(total) ++ " rebuilt=" ++ U32.show(rebuilt) ++ " cached=" ++ U32.show(cached) ++ " link=" ++ Bool.pick(String, need_link, "yes", "no") ++ " (" ++ elapsed ++ "ms)")
        IO.pure(U32, 0)

def run_driver(+manifest_path: String, +cfg: BuildCfg) -> IO(U32):
  do IO<U32>:
    +t_start : Nat <- IO.now()
    +manifest_txt : String <- read_file_req(manifest_path)
    +mods : List<&2, ModSpec> = parse_manifest_lines(String.lines(manifest_txt))
    +total : U32 = count_mods(mods)
    _ : Unit <- IO.print_err("[bend-build] manifest=" ++ manifest_path ++ " modules=" ++ U32.show(total) ++ " entry=" ++ cfg_entry(cfg))
    res : BuildAcc <- process_mods(cfg, mods, 1, total, BuildAcc{"", 0, 0})
    finish_driver(cfg, mods, total, t_start, res)

def dispatch(args: List<&1, String>) -> IO(U32):
  match args:
    case Con{manifest, Con{compiler, Con{base_bend, Con{carrier, Con{stamp, Con{merge_c, Con{runtime_o, Con{entry_mod, Con{out_exe, Nil{}}}}}}}}}}:
      run_driver(manifest, BuildCfg{compiler, base_bend, carrier, stamp, merge_c, runtime_o, entry_mod, out_exe})
    case _:
      IO.die(U32, 2, "usage: bend_build <manifest> <compiler> <base_bend> <carrier_p130> <stamp> <merge_c> <runtime_o> <entry_mod> <out_exe>")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    dispatch(List.tail(&1, String, args))
