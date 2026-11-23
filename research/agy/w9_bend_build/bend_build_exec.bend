# Wave 9: 100% Pure-Bend Direct-Execution Parallel Module Build Driver
# =====================================================================
# Hosted Bend edition (`bend2/main.ts` C/JS backends): uses `Process.run`,
# `IO.fork`, and `IO.join` from `selfhost/dist/base.bend` to execute
# `x86-module` compilations in parallel and link with `gcc-10` directly
# inside Bend (zero Python, zero JS, zero external shell pipeline).
#
# Note: `Process.run`, `IO.fork`, and `IO.join` are NOT yet in `wave8-native-self/n1`'s
# ABI11102 fixed runtime (`p111_runtime_names()` in compiler.bend:34018).
# For native compilation via `wave8-native-self/n1`, use `bend_build.bend`.

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

type ModJob is Data:
  ModJob{
    +name: String,
    +out_o: String,
    +hash: String,
    +rebuilt: Bool,
    +ok: Bool,
    +err: String
  }

# Dual 32-bit FNV-1a content hash
# -------------------------------

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

# Safe file IO helpers
# --------------------

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

def write_file_ok(wres: Result<&1, &1, U32 & String, Unit>) -> IO(Bool):
  match wres:
    case Done{_}:
      IO.pure(Bool, True{})
    case Fail{_}:
      IO.pure(Bool, False{})

def write_file_got(res: File & Result<&1, &1, U32 & String, Unit>) -> IO(Bool):
  match res:
    case (f2, wres):
      do IO<Bool>:
        _ : Unit <- File.close(f2)
        write_file_ok(wres)

def write_file_opened(opened: Result<&1, &1, U32 & String, File>, +data: String) -> IO(Bool):
  match opened:
    case Fail{(code, msg)}:
      IO.pure(Bool, False{})
    case Done{f}:
      do IO<Bool>:
        res : File & Result<&1, &1, U32 & String, Unit> <- File.write(f, data)
        write_file_got(res)

def write_file_str(+path: String, +data: String) -> IO(Bool):
  do IO<Bool>:
    opened : Result<&1, &1, U32 & String, File> <- File.open(path, "w")
    write_file_opened(opened, data)

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

# Manifest parsing
# ----------------

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

def sh_quote(+s: String) -> String:
  "'" ++ s ++ "'"

def build_finalize(is_entry: Bool, +tmp_o: String, +out_o: String) -> String:
  match is_entry:
    case True{}:
      "mv " ++ sh_quote(tmp_o) ++ " " ++ sh_quote(out_o)
    case False{}:
      "objcopy -L p111_FID_109_97_105_110_ -L p113d_FID_109_97_105_110_ " ++ sh_quote(tmp_o) ++ " " ++ sh_quote(out_o) ++ " && rm -f " ++ sh_quote(tmp_o)

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

# Parallel module compilation via IO.fork + Process.run
# -----------------------------------------------------

def compile_rc(ok_rc: Bool, +rc: U32, +err_s: String, +name: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +ms: String) -> IO(ModJob):
  match ok_rc:
    case True{}:
      do IO<ModJob>:
        _ : Bool <- write_file_str(out_o ++ ".hash", hash ++ "\n")
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [REBUILT] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, True{}, ""})
    case False{}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED rc=" ++ U32.show(rc) ++ ": " ++ err_s)
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, False{}, err_s})

def compile_pr(pr: Result<&1, &1, U32 & String, U32 & (String & String)>, +name: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +ms: String) -> IO(ModJob):
  match pr:
    case Fail{(ec, +emsg)}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED: " ++ emsg ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, False{}, emsg})
    case Done{(+rc, io_pair)}:
      compile_rc(U32.is_eq(rc, 0), rc, Pair.snd(String, String, io_pair), name, out_o, hash, idx, total, ms)

def compile_branch(is_hit: Bool, +compiler: String, +base_bend: String, +carrier: String, +stamp: String, +entry_mod: String, +name: String, +src: String, +fid_base: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +t0: Nat) -> IO(ModJob):
  match is_hit:
    case True{}:
      do IO<ModJob>:
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [cache HIT] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, False{}, True{}, ""})
    case False{}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build] [" ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") compiling ...")
        +tmp_o : String = out_o ++ ".tmp"
        +finalize : String = build_finalize(String.eq(name, entry_mod), tmp_o, out_o)
        +sh_cmd : String = sh_quote(compiler) ++ " x86-module " ++ sh_quote(src) ++ " " ++ sh_quote(base_bend) ++ " cache " ++ sh_quote(carrier) ++ " " ++ sh_quote(stamp) ++ " " ++ fid_base ++ " " ++ name ++ " > " ++ sh_quote(tmp_o) ++ " && " ++ finalize
        pr : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("/bin/sh", ["-c", sh_cmd], "", 65536, 120000)
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        compile_pr(pr, name, out_o, hash, idx, total, ms)

def compile_one_m(+compiler: String, +base_bend: String, +carrier: String, +stamp: String, +entry_mod: String, m: ModSpec, +idx: U32, +total: U32) -> IO(ModJob):
  match m:
    case ModSpec{+name, +src, +fid_base, +out_o}:
      do IO<ModJob>:
        +t0 : Nat <- IO.now()
        +src_txt : String <- read_file_req(src)
        +hash : String = content_hash(src_txt, stamp, fid_base, name)
        +obj_ok : Bool <- file_exists(out_o)
        +old_hash_m : Maybe<&2, String> <- read_file_opt(out_o ++ ".hash")
        +is_hit : Bool = check_cache_hit(obj_ok, old_hash_m, hash)
        compile_branch(is_hit, compiler, base_bend, carrier, stamp, entry_mod, name, src, fid_base, out_o, hash, idx, total, t0)

def compile_one(cfg: BuildCfg, m: ModSpec, +idx: U32, +total: U32) -> IO(ModJob):
  match cfg:
    case BuildCfg{compiler, base_bend, carrier, stamp, _, _, entry_mod, _}:
      compile_one_m(compiler, base_bend, carrier, stamp, entry_mod, m, idx, total)

def fork_mods(+cfg: BuildCfg, mods: List<&2, ModSpec>, +idx: U32, +total: U32) -> IO(List<&1, Chan(ModJob)>):
  match mods:
    case Nil{}:
      IO.pure(List<&1, Chan(ModJob)>, Nil{})
    case Con{m, rest}:
      do IO<List<&1, Chan(ModJob)>>:
        ch : Chan(ModJob) <- IO.fork(ModJob, compile_one(cfg, m, idx, total))
        chs : List<&1, Chan(ModJob)> <- fork_mods(cfg, rest, U32.inc(idx), total)
        IO.pure(List<&1, Chan(ModJob)>, Con{ch, chs})

def join_mods(chs: List<&1, Chan(ModJob)>) -> IO(List<&2, ModJob>):
  match chs:
    case Nil{}:
      IO.pure(List<&2, ModJob>, Nil{})
    case Con{ch, rest}:
      do IO<List<&2, ModJob>>:
        job : ModJob <- IO.join(ModJob, ch)
        jobs : List<&2, ModJob> <- join_mods(rest)
        IO.pure(List<&2, ModJob>, Con{job, jobs})

def count_rebuilt_step(rebuilt: Bool, n: U32) -> U32:
  match rebuilt:
    case True{}:
      U32.inc(n)
    case False{}:
      n

def count_rebuilt(jobs: List<&2, ModJob>) -> U32:
  match jobs:
    case Nil{}:
      0
    case Con{ModJob{_, _, _, rebuilt, _, _}, rest}:
      count_rebuilt_step(rebuilt, count_rebuilt(rest))

def first_error_step(ok: Bool, +name: String, +err: String, rest: String) -> String:
  match ok:
    case True{}:
      rest
    case False{}:
      name ++ ": " ++ err

def first_error(jobs: List<&2, ModJob>) -> String:
  match jobs:
    case Nil{}:
      ""
    case Con{ModJob{name, _, _, _, ok, err}, rest}:
      first_error_step(ok, name, err, first_error(rest))

def fmt_w8_modules(mods: List<&2, ModSpec>) -> String:
  match mods:
    case Nil{}:
      ""
    case Con{ModSpec{name, _, _, _}, Nil{}}:
      "X(" ++ name ++ ")"
    case Con{ModSpec{name, _, _, _}, rest}:
      "X(" ++ name ++ ") " ++ fmt_w8_modules(rest)

def collect_objs(mods: List<&2, ModSpec>, tail: List<&1, String>) -> List<&1, String>:
  match mods:
    case Nil{}:
      tail
    case Con{ModSpec{_, _, _, out_o}, rest}:
      Con{out_o, collect_objs(rest, tail)}

def link_step2_rc(ok: Bool, +err2: String, +out_exe: String, +t0: Nat) -> IO(U32):
  match ok:
    case False{}:
      IO.die(U32, 1, "[bend-build] gcc-10 link error: " ++ err2)
    case True{}:
      do IO<U32>:
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        _ : Unit <- IO.print_err("[bend-build] linked " ++ out_exe ++ " (" ++ ms ++ "ms)")
        IO.pure(U32, 0)

def link_step2_res(r2: Result<&1, &1, U32 & String, U32 & (String & String)>, +out_exe: String, +t0: Nat) -> IO(U32):
  match r2:
    case Fail{(ec, emsg)}:
      IO.die(U32, 1, "[bend-build] gcc-10 link failed: " ++ emsg)
    case Done{(rc2, io_pair)}:
      link_step2_rc(U32.is_eq(rc2, 0), Pair.snd(String, String, io_pair), out_exe, t0)

def link_step1_rc(ok: Bool, +err1: String, +merge_o: String, +runtime_o: String, +out_exe: String, +mods: List<&2, ModSpec>, +t0: Nat) -> IO(U32):
  match ok:
    case False{}:
      IO.die(U32, 1, "[bend-build] gcc-10 merge compile error: " ++ err1)
    case True{}:
      do IO<U32>:
        link_tail : List<&1, String> = [runtime_o, "-o", out_exe, "-lm", "-lpthread"]
        c2_args : List<&1, String> = Con{"-no-pie", Con{"-Wl,--allow-multiple-definition", Con{merge_o, collect_objs(mods, link_tail)}}}
        r2 : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("gcc-10", c2_args, "", 65536, 60000)
        link_step2_res(r2, out_exe, t0)

def link_step1_res(r1: Result<&1, &1, U32 & String, U32 & (String & String)>, +merge_o: String, +runtime_o: String, +out_exe: String, +mods: List<&2, ModSpec>, +t0: Nat) -> IO(U32):
  match r1:
    case Fail{(ec, emsg)}:
      IO.die(U32, 1, "[bend-build] gcc-10 merge compile failed: " ++ emsg)
    case Done{(rc1, io_pair)}:
      link_step1_rc(U32.is_eq(rc1, 0), Pair.snd(String, String, io_pair), merge_o, runtime_o, out_exe, mods, t0)

def run_link(cfg: BuildCfg, +mods: List<&2, ModSpec>) -> IO(U32):
  match cfg:
    case BuildCfg{_, _, _, _, +merge_c, +runtime_o, +entry_mod, +out_exe}:
      do IO<U32>:
        +t0 : Nat <- IO.now()
        +merge_o : String = out_exe ++ ".merge.o"
        +w8_mods : String = fmt_w8_modules(mods)
        c1_args : List<&1, String> = ["-O2", "-c", merge_c, "-DW8_ENTRY_MOD=" ++ entry_mod, "-DW8_MODULES(X)=" ++ w8_mods, "-o", merge_o]
        r1 : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("gcc-10", c1_args, "", 65536, 60000)
        link_step1_res(r1, merge_o, runtime_o, out_exe, mods, t0)

def maybe_link(need_link: Bool, +cfg: BuildCfg, +mods: List<&2, ModSpec>) -> IO(U32):
  match need_link:
    case True{}:
      run_link(cfg, mods)
    case False{}:
      IO.pure(U32, 0)

def cfg_entry(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, entry_mod, _}:
      entry_mod

def cfg_out_exe(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, _, out_exe}:
      out_exe

def finish_exec(ok_err: Bool, +err: String, +cfg: BuildCfg, +mods: List<&2, ModSpec>, +jobs: List<&2, ModJob>, +total: U32, +t_start: Nat) -> IO(U32):
  match ok_err:
    case False{}:
      IO.die(U32, 1, "[bend-build] build failed: " ++ err)
    case True{}:
      do IO<U32>:
        +rebuilt : U32 = count_rebuilt(jobs)
        +cached : U32 = U32.sub(total, rebuilt)
        +exe_ok : Bool <- file_exists(cfg_out_exe(cfg))
        +need_link : Bool = U32.is_gt(rebuilt, 0) || Bool.not(exe_ok)
        _ : U32 <- maybe_link(need_link, cfg, mods)
        +t_end : Nat <- IO.now()
        +elapsed : String = Nat.show(Nat.sub(t_end, t_start))
        _ : Unit <- IO.print_err("[bend-build] done: total=" ++ U32.show(total) ++ " rebuilt=" ++ U32.show(rebuilt) ++ " cached=" ++ U32.show(cached) ++ " (" ++ elapsed ++ "ms)")
        IO.pure(U32, 0)

def run_driver(+manifest_path: String, +cfg: BuildCfg) -> IO(U32):
  do IO<U32>:
    +t_start : Nat <- IO.now()
    +manifest_txt : String <- read_file_req(manifest_path)
    +mods : List<&2, ModSpec> = parse_manifest_lines(String.lines(manifest_txt))
    +total : U32 = count_mods(mods)
    _ : Unit <- IO.print_err("[bend-build] (direct-exec) manifest=" ++ manifest_path ++ " modules=" ++ U32.show(total) ++ " entry=" ++ cfg_entry(cfg))
    chs : List<&1, Chan(ModJob)> <- fork_mods(cfg, mods, 1, total)
    +jobs : List<&2, ModJob> <- join_mods(chs)
    +err : String = first_error(jobs)
    finish_exec(String.is_empty(err), err, cfg, mods, jobs, total, t_start)

def dispatch(args: List<&1, String>) -> IO(U32):
  match args:
    case Con{manifest, Con{compiler, Con{base_bend, Con{carrier, Con{stamp, Con{merge_c, Con{runtime_o, Con{entry_mod, Con{out_exe, Nil{}}}}}}}}}}:
      run_driver(manifest, BuildCfg{compiler, base_bend, carrier, stamp, merge_c, runtime_o, entry_mod, out_exe})
    case _:
      IO.die(U32, 2, "usage: bend_build_exec <manifest> <compiler> <base_bend> <carrier_p130> <stamp> <merge_c> <runtime_o> <entry_mod> <out_exe>")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    dispatch(List.tail(&1, String, args))
