# Wave 12-C: 100% Pure-Bend Pipelined Incremental & Parallel Module Build Driver
# ==============================================================================
# Zero Python, zero JS at runtime, zero `@unsafe` (ALL PROOFS CHECK).
# Uses native `IO.fork`, `IO.join`, `Chan.*`, `Process.run`, `File.*`, `IO.now`.
#
# Features:
#   1. Reads a topological module manifest (`<name> <src> <fid_base> <out_o>`).
#   2. Dual 32-bit FNV-1a content + `.p130` interface stamp caching:
#      - Skips `x86-iface` when `(src, in_stamp, "iface", name)` is unchanged.
#      - Skips `x86-module-fast` when `(src, in_stamp, fid_base, name)` is unchanged.
#      - Mid-stack body-only edits keep `.p130` stamp identical -> downstream
#        modules get the exact same `in_stamp` and CACHE HIT (1/K rebuild!).
#      - Interface-changing edits change `.p130` stamp -> downstream modules
#        automatically miss and rebuild!
#   3. Pipelined 1-iface + N-compile (`--jobs N`) execution:
#      - Spawns N parallel worker threads via `IO.fork` reading from `work_ch`.
#      - As soon as `m_{i-1}.p130` lands, `m_i` is enqueued for `x86-module-fast`
#        while the iface stage immediately advances to `m_i.p130`.
#   4. Automatic native `x86-merge-obj` (entry module first!) + `gcc-10 -O2 -no-pie`
#      link, printing live per-stage millisecond timing summary.
#
# CLI usage:
#   bend_build_pipe [--jobs N] <manifest> <compiler> <base_bend> \
#     <base_carrier_p130> <base_stamp> <iface_dir> <runtime_o> <entry_mod> <out_exe>

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
    +jobs: U32,
    +compiler: String,
    +base_bend: String,
    +base_carrier: String,
    +base_stamp: String,
    +iface_dir: String,
    +runtime_o: String,
    +entry_mod: String,
    +out_exe: String
  }

type CompileTask is Data:
  CompileTask{
    +spec: ModSpec,
    +src_txt: String,
    +in_carrier: String,
    +in_stamp: String,
    +idx: U32,
    +total: U32
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

type IfaceRes is Data:
  IfaceRes{
    +ok: Bool,
    +err: String,
    +sent: U32,
    +iface_rebuilt: U32,
    +iface_cached: U32
  }

type LinkTiming is Data:
  LinkTiming{
    +merge_ms: Nat,
    +link_ms: Nat
  }

# Dual 32-bit FNV-1a content hash in pure Bend
# --------------------------------------------

def fnv1a_step(h: U32, c: U32, prime: U32) -> U32:
  U32.mul(U32.xor(h, c), prime)

def fnv1a_go(s: String, h: U32, +prime: U32) -> U32:
  match s:
    case SNil{}:
      h
    case SCon{c, rest}:
      fnv1a_go(rest, fnv1a_step(h, Char.to_u32(c), prime), prime)

def content_hash(+src: String, +stamp: String, +tag: String, +name: String) -> String:
  +h1a = fnv1a_go(src, 2166136261, 16777619)
  +h1b = fnv1a_go(stamp, fnv1a_step(h1a, 10, 16777619), 16777619)
  +h1c = fnv1a_go(tag, fnv1a_step(h1b, 10, 16777619), 16777619)
  +h1  = fnv1a_go(name, fnv1a_step(h1c, 10, 16777619), 16777619)
  +h2a = fnv1a_go(src, 3759247821, 2246822519)
  +h2b = fnv1a_go(stamp, fnv1a_step(h2a, 10, 2246822519), 2246822519)
  +h2c = fnv1a_go(tag, fnv1a_step(h2b, 10, 2246822519), 2246822519)
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
      IO.die(String, 1, "[bend-build-pipe] ERROR: cannot read file: " ++ path)

def read_file_req(+path: String) -> IO(String):
  do IO<String>:
    got : Maybe<&2, String> <- read_file_opt(path)
    read_file_req_got(path, got)

# Manifest & string helpers
# -------------------------

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

def last_nonempty_pick(empty: Bool, +trimmed: String, +acc: String) -> String:
  match empty:
    case True{}:
      acc
    case False{}:
      trimmed

def last_nonempty_go(lines: List<&2, String>, +acc: String) -> String:
  match lines:
    case Nil{}:
      acc
    case Con{h, t}:
      +tr = String.trim(h)
      last_nonempty_go(t, last_nonempty_pick(String.is_empty(tr), tr, acc))

def last_nonempty_line(s: String) -> String:
  last_nonempty_go(String.lines(s), "")

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

def unwrap_nonempty_opt(m: Maybe<&2, String>) -> String:
  match m:
    case None{}:
      ""
    case Some{s}:
      String.trim(s)

# Config field accessors
# ----------------------

def cfg_jobs(cfg: BuildCfg) -> U32:
  match cfg:
    case BuildCfg{jobs, _, _, _, _, _, _, _, _}:
      jobs

def cfg_compiler(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, compiler, _, _, _, _, _, _, _}:
      compiler

def cfg_base_bend(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, base_bend, _, _, _, _, _, _}:
      base_bend

def cfg_base_carrier(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, base_carrier, _, _, _, _, _}:
      base_carrier

def cfg_base_stamp(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, base_stamp, _, _, _, _}:
      base_stamp

def cfg_iface_dir(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, iface_dir, _, _, _}:
      iface_dir

def cfg_runtime_o(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, runtime_o, _, _}:
      runtime_o

def cfg_entry(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, _, entry_mod, _}:
      entry_mod

def cfg_out_exe(cfg: BuildCfg) -> String:
  match cfg:
    case BuildCfg{_, _, _, _, _, _, _, _, out_exe}:
      out_exe

# Worker pool: parallel `x86-module-fast` compilation via IO.fork + Chan
# ----------------------------------------------------------------------

def compile_rc(ok_rc: Bool, +rc: U32, +err_s: String, +name: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +ms: String) -> IO(ModJob):
  match ok_rc:
    case True{}:
      do IO<ModJob>:
        _ : Bool <- write_file_str(out_o ++ ".hash", hash ++ "\n")
        _ : Unit <- IO.print_err("[bend-build-pipe] [compile " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [REBUILT] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, True{}, ""})
    case False{}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build-pipe] [compile " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED rc=" ++ U32.show(rc) ++ ": " ++ err_s)
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, False{}, err_s})

def compile_pr(pr: Result<&1, &1, U32 & String, U32 & (String & String)>, +name: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +ms: String) -> IO(ModJob):
  match pr:
    case Fail{(ec, +emsg)}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build-pipe] [compile " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED: " ++ emsg ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, True{}, False{}, emsg})
    case Done{(+rc, io_pair)}:
      compile_rc(U32.is_eq(rc, 0), rc, Pair.snd(String, String, io_pair), name, out_o, hash, idx, total, ms)

def compile_branch(is_hit: Bool, +compiler: String, +base_bend: String, +in_carrier: String, +in_stamp: String, +name: String, +src: String, +fid_base: String, +out_o: String, +hash: String, +idx: U32, +total: U32, +t0: Nat) -> IO(ModJob):
  match is_hit:
    case True{}:
      do IO<ModJob>:
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        _ : Unit <- IO.print_err("[bend-build-pipe] [compile " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") [cache HIT] hash=" ++ hash ++ " (" ++ ms ++ "ms)")
        IO.pure(ModJob, ModJob{name, out_o, hash, False{}, True{}, ""})
    case False{}:
      do IO<ModJob>:
        _ : Unit <- IO.print_err("[bend-build-pipe] [compile " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_o ++ ") compiling ...")
        +tmp_o : String = out_o ++ ".tmp"
        +sh_cmd : String = sh_quote(compiler) ++ " x86-module-fast " ++ sh_quote(src) ++ " " ++ sh_quote(base_bend) ++ " cache " ++ sh_quote(in_carrier) ++ " " ++ sh_quote(in_stamp) ++ " " ++ fid_base ++ " " ++ name ++ " > " ++ sh_quote(tmp_o) ++ " && mv " ++ sh_quote(tmp_o) ++ " " ++ sh_quote(out_o)
        pr : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("/bin/sh", ["-c", sh_cmd], "", 65536, 600000)
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        compile_pr(pr, name, out_o, hash, idx, total, ms)

def run_compile_task(+cfg: BuildCfg, task: CompileTask) -> IO(ModJob):
  match task:
    case CompileTask{ModSpec{+name, +src, +fid_base, +out_o}, +src_txt, +in_carrier, +in_stamp, +idx, +total}:
      do IO<ModJob>:
        +t0 : Nat <- IO.now()
        +hash : String = content_hash(src_txt, in_stamp, fid_base, name)
        +obj_ok : Bool <- file_exists(out_o)
        +old_hash_m : Maybe<&2, String> <- read_file_opt(out_o ++ ".hash")
        +is_hit : Bool = check_cache_hit(obj_ok, old_hash_m, hash)
        compile_branch(is_hit, cfg_compiler(cfg), cfg_base_bend(cfg), in_carrier, in_stamp, name, src, fid_base, out_o, hash, idx, total, t0)

def worker_step(got: Maybe<&1, CompileTask>, +cfg: BuildCfg, +work_ch: Chan(CompileTask), +res_ch: Chan(ModJob), cont: IO(Unit)) -> IO(Unit):
  match got:
    case None{}:
      IO.pure(Unit, Unit{})
    case Some{task}:
      do IO<Unit>:
        job : ModJob <- run_compile_task(cfg, task)
        _ : Result<&1, &1, ModJob, Unit> <- Chan.send(ModJob, res_ch, job)
        cont

def worker_loop(fuel: Nat, +cfg: BuildCfg, +work_ch: Chan(CompileTask), +res_ch: Chan(ModJob)) -> IO(Unit):
  match fuel:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      do IO<Unit>:
        got : Maybe<&1, CompileTask> <- Chan.recv(CompileTask, work_ch)
        worker_step(got, cfg, work_ch, res_ch, worker_loop(p, cfg, work_ch, res_ch))

def spawn_workers(n: Nat, +fuel: Nat, +cfg: BuildCfg, +work_ch: Chan(CompileTask), +res_ch: Chan(ModJob)) -> IO(List<&1, Chan(Unit)>):
  match n:
    case 0n:
      IO.pure(List<&1, Chan(Unit)>, Nil{})
    case 1n+p:
      do IO<List<&1, Chan(Unit)>>:
        ch : Chan(Unit) <- IO.fork(Unit, worker_loop(fuel, cfg, work_ch, res_ch))
        chs : List<&1, Chan(Unit)> <- spawn_workers(p, fuel, cfg, work_ch, res_ch)
        IO.pure(List<&1, Chan(Unit)>, Con{ch, chs})

def join_workers(chs: List<&1, Chan(Unit)>) -> IO(Unit):
  match chs:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{ch, rest}:
      do IO<Unit>:
        _ : Unit <- IO.join(Unit, ch)
        join_workers(rest)

def drain_step(got: Maybe<&1, ModJob>, rest: IO(List<&2, ModJob>)) -> IO(List<&2, ModJob>):
  match got:
    case None{}:
      IO.pure(List<&2, ModJob>, Nil{})
    case Some{job}:
      do IO<List<&2, ModJob>>:
        jobs : List<&2, ModJob> <- rest
        IO.pure(List<&2, ModJob>, Con{job, jobs})

def drain_jobs(n: Nat, +res_ch: Chan(ModJob)) -> IO(List<&2, ModJob>):
  match n:
    case 0n:
      IO.pure(List<&2, ModJob>, Nil{})
    case 1n+p:
      do IO<List<&2, ModJob>>:
        got : Maybe<&1, ModJob> <- Chan.recv(ModJob, res_ch)
        drain_step(got, drain_jobs(p, res_ch))

# Producer stage: pipelined `x86-iface` with dual FNV-1a + stamp cache
# --------------------------------------------------------------------

def iface_finish_stamp(empty_stamp: Bool, +new_stamp: String, +name: String, +out_p130: String, +iface_key: String, +idx: U32, +total: U32, +ms: String) -> IO(Result<&2, &2, String, String>):
  match empty_stamp:
    case True{}:
      do IO<Result<&2, &2, String, String>>:
        +emsg : String = "x86-iface produced empty stamp for " ++ name
        _ : Unit <- IO.print_err("[bend-build-pipe] [iface " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED: " ++ emsg)
        IO.pure(Result<&2, &2, String, String>, Fail{emsg})
    case False{}:
      do IO<Result<&2, &2, String, String>>:
        _ : Bool <- write_file_str(out_p130 ++ ".ikey", iface_key ++ "\n")
        _ : Bool <- write_file_str(out_p130 ++ ".stamp", new_stamp ++ "\n")
        _ : Unit <- IO.print_err("[bend-build-pipe] [iface " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_p130 ++ ") [REBUILT] stamp=" ++ new_stamp ++ " (" ++ ms ++ "ms)")
        IO.pure(Result<&2, &2, String, String>, Done{new_stamp})

def iface_rc(ok_rc: Bool, +rc: U32, +err_s: String, +name: String, +out_p130: String, +iface_key: String, +idx: U32, +total: U32, +ms: String) -> IO(Result<&2, &2, String, String>):
  match ok_rc:
    case True{}:
      +new_stamp : String = last_nonempty_line(err_s)
      iface_finish_stamp(String.is_empty(new_stamp), new_stamp, name, out_p130, iface_key, idx, total, ms)
    case False{}:
      do IO<Result<&2, &2, String, String>>:
        _ : Unit <- IO.print_err("[bend-build-pipe] [iface " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED rc=" ++ U32.show(rc) ++ ": " ++ err_s)
        IO.pure(Result<&2, &2, String, String>, Fail{"x86-iface " ++ name ++ " rc=" ++ U32.show(rc) ++ ": " ++ err_s})

def iface_pr(pr: Result<&1, &1, U32 & String, U32 & (String & String)>, +name: String, +out_p130: String, +iface_key: String, +idx: U32, +total: U32, +ms: String) -> IO(Result<&2, &2, String, String>):
  match pr:
    case Fail{(ec, +emsg)}:
      do IO<Result<&2, &2, String, String>>:
        _ : Unit <- IO.print_err("[bend-build-pipe] [iface " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " FAILED: " ++ emsg ++ " (" ++ ms ++ "ms)")
        IO.pure(Result<&2, &2, String, String>, Fail{emsg})
    case Done{(+rc, io_pair)}:
      iface_rc(U32.is_eq(rc, 0), rc, Pair.snd(String, String, io_pair), name, out_p130, iface_key, idx, total, ms)

def run_iface_miss(+cfg: BuildCfg, +name: String, +src: String, +in_carrier: String, +in_stamp: String, +out_p130: String, +iface_key: String, +idx: U32, +total: U32, +t0: Nat) -> IO(Result<&2, &2, String, String>):
  do IO<Result<&2, &2, String, String>>:
    +tmp_p130 : String = out_p130 ++ ".tmp"
    +sh_cmd : String = sh_quote(cfg_compiler(cfg)) ++ " x86-iface " ++ sh_quote(src) ++ " " ++ sh_quote(cfg_base_bend(cfg)) ++ " cache " ++ sh_quote(in_carrier) ++ " " ++ sh_quote(in_stamp) ++ " > " ++ sh_quote(tmp_p130) ++ " && mv " ++ sh_quote(tmp_p130) ++ " " ++ sh_quote(out_p130)
    pr : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("/bin/sh", ["-c", sh_cmd], "", 65536, 180000)
    +t1 : Nat <- IO.now()
    +ms : String = Nat.show(Nat.sub(t1, t0))
    iface_pr(pr, name, out_p130, iface_key, idx, total, ms)

def run_iface_step(is_hit: Bool, +cfg: BuildCfg, +name: String, +src: String, +in_carrier: String, +in_stamp: String, +out_p130: String, +iface_key: String, +cached_stamp: String, +idx: U32, +total: U32, +t0: Nat) -> IO(Bool & Result<&2, &2, String, String>):
  match is_hit:
    case True{}:
      do IO<Bool & Result<&2, &2, String, String>>:
        +t1 : Nat <- IO.now()
        +ms : String = Nat.show(Nat.sub(t1, t0))
        _ : Unit <- IO.print_err("[bend-build-pipe] [iface " ++ U32.show(idx) ++ "/" ++ U32.show(total) ++ "] " ++ name ++ " (" ++ out_p130 ++ ") [cache HIT] stamp=" ++ cached_stamp ++ " (" ++ ms ++ "ms)")
        IO.pure(Bool & Result<&2, &2, String, String>, (False{}, Done{cached_stamp}))
    case False{}:
      do IO<Bool & Result<&2, &2, String, String>>:
        res : Result<&2, &2, String, String> <- run_iface_miss(cfg, name, src, in_carrier, in_stamp, out_p130, iface_key, idx, total, t0)
        IO.pure(Bool & Result<&2, &2, String, String>, (True{}, res))

def ensure_iface(+cfg: BuildCfg, +name: String, +src: String, +src_txt: String, +in_carrier: String, +in_stamp: String, +out_p130: String, +idx: U32, +total: U32) -> IO(Bool & Result<&2, &2, String, String>):
  do IO<Bool & Result<&2, &2, String, String>>:
    +t0 : Nat <- IO.now()
    +iface_key : String = content_hash(src_txt, in_stamp, "iface", name)
    +p130_ok : Bool <- file_exists(out_p130)
    +old_ikey : Maybe<&2, String> <- read_file_opt(out_p130 ++ ".ikey")
    +old_stamp_m : Maybe<&2, String> <- read_file_opt(out_p130 ++ ".stamp")
    +cached_stamp : String = unwrap_nonempty_opt(old_stamp_m)
    +is_hit : Bool = check_cache_hit(p130_ok, old_ikey, iface_key) && Bool.not(String.is_empty(cached_stamp))
    run_iface_step(is_hit, cfg, name, src, in_carrier, in_stamp, out_p130, iface_key, cached_stamp, idx, total, t0)

def pipeline_after_iface(+was_rebuilt: Bool, res: Result<&2, &2, String, String>, +sent: U32, +ir: U32, +ic: U32, cont: String -> U32 -> U32 -> IO(IfaceRes)) -> IO(IfaceRes):
  match res:
    case Fail{emsg}:
      IO.pure(IfaceRes, IfaceRes{False{}, emsg, sent, Bool.pick(U32, was_rebuilt, U32.inc(ir), ir), Bool.pick(U32, was_rebuilt, ic, U32.inc(ic))})
    case Done{out_stamp}:
      cont(out_stamp, Bool.pick(U32, was_rebuilt, U32.inc(ir), ir), Bool.pick(U32, was_rebuilt, ic, U32.inc(ic)))

def pipeline_pair(pair: Bool & Result<&2, &2, String, String>, +sent: U32, +ir: U32, +ic: U32, cont: String -> U32 -> U32 -> IO(IfaceRes)) -> IO(IfaceRes):
  match pair:
    case (was_rebuilt, res):
      pipeline_after_iface(was_rebuilt, res, sent, ir, ic, cont)

def pipeline_next(+cfg: BuildCfg, +name: String, +src: String, +src_txt: String, +in_carrier: String, +in_stamp: String, rest: List<&2, ModSpec>, +idx: U32, +total: U32, +sent: U32, +ir: U32, +ic: U32, cont: String -> String -> U32 -> U32 -> IO(IfaceRes)) -> IO(IfaceRes):
  match rest:
    case Nil{}:
      IO.pure(IfaceRes, IfaceRes{True{}, "", sent, ir, ic})
    case Con{_, _}:
      do IO<IfaceRes>:
        +out_p130 : String = cfg_iface_dir(cfg) ++ "/" ++ name ++ ".p130"
        pair : Bool & Result<&2, &2, String, String> <- ensure_iface(cfg, name, src, src_txt, in_carrier, in_stamp, out_p130, idx, total)
        pipeline_pair(pair, sent, ir, ic, out_stamp => ir2 => ic2 => cont(out_p130, out_stamp, ir2, ic2))

def run_pipeline(+cfg: BuildCfg, mods: List<&2, ModSpec>, +idx: U32, +total: U32, +in_carrier: String, +in_stamp: String, +work_ch: Chan(CompileTask), +sent: U32, +ir: U32, +ic: U32) -> IO(IfaceRes):
  match mods:
    case Nil{}:
      IO.pure(IfaceRes, IfaceRes{True{}, "", sent, ir, ic})
    case Con{m, +rest}:
      match m:
        case ModSpec{+name, +src, +fid_base, +out_o}:
          do IO<IfaceRes>:
            +src_txt : String <- read_file_req(src)
            +task : CompileTask = CompileTask{ModSpec{name, src, fid_base, out_o}, src_txt, in_carrier, in_stamp, idx, total}
            _ : Result<&1, &1, CompileTask, Unit> <- Chan.send(CompileTask, work_ch, task)
            pipeline_next(cfg, name, src, src_txt, in_carrier, in_stamp, rest, idx, total, U32.inc(sent), ir, ic, next_carrier => next_stamp => ir2 => ic2 => run_pipeline(cfg, rest, U32.inc(idx), total, next_carrier, next_stamp, work_ch, U32.inc(sent), ir2, ic2))

# Result aggregation
# ------------------

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

# Native `x86-merge-obj` (entry module first!) + `gcc-10 -O2 -no-pie` link
# ------------------------------------------------------------------------

def fmt_other_mods(mods: List<&2, ModSpec>, +entry_mod: String) -> String:
  match mods:
    case Nil{}:
      ""
    case Con{ModSpec{+name, _, _, _}, rest}:
      +tail : String = fmt_other_mods(rest, entry_mod)
      Bool.pick(String, String.eq(name, entry_mod), tail, " " ++ name ++ tail)

def collect_objs(mods: List<&2, ModSpec>, tail: List<&1, String>) -> List<&1, String>:
  match mods:
    case Nil{}:
      tail
    case Con{ModSpec{_, _, _, out_o}, rest}:
      Con{out_o, collect_objs(rest, tail)}

def link_step2_rc(ok: Bool, +err2: String, +out_exe: String, +merge_ms: Nat, +t_lk0: Nat) -> IO(LinkTiming):
  match ok:
    case False{}:
      IO.die(LinkTiming, 1, "[bend-build-pipe] gcc-10 link error: " ++ err2)
    case True{}:
      do IO<LinkTiming>:
        +t_lk1 : Nat <- IO.now()
        +link_ms : Nat = Nat.sub(t_lk1, t_lk0)
        _ : Unit <- IO.print_err("[bend-build-pipe] linked " ++ out_exe ++ " (merge=" ++ Nat.show(merge_ms) ++ "ms link=" ++ Nat.show(link_ms) ++ "ms)")
        IO.pure(LinkTiming, LinkTiming{merge_ms, link_ms})

def link_step2_res(r2: Result<&1, &1, U32 & String, U32 & (String & String)>, +out_exe: String, +merge_ms: Nat, +t_lk0: Nat) -> IO(LinkTiming):
  match r2:
    case Fail{(ec, emsg)}:
      IO.die(LinkTiming, 1, "[bend-build-pipe] gcc-10 link failed: " ++ emsg)
    case Done{(rc2, io_pair)}:
      link_step2_rc(U32.is_eq(rc2, 0), Pair.snd(String, String, io_pair), out_exe, merge_ms, t_lk0)

def merge_step_rc(ok: Bool, +err1: String, +merge_o: String, +runtime_o: String, +out_exe: String, +mods: List<&2, ModSpec>, +merge_ms: Nat) -> IO(LinkTiming):
  match ok:
    case False{}:
      IO.die(LinkTiming, 1, "[bend-build-pipe] x86-merge-obj error: " ++ err1)
    case True{}:
      do IO<LinkTiming>:
        +t_lk0 : Nat <- IO.now()
        link_tail : List<&1, String> = [runtime_o, "-o", out_exe, "-lm", "-lpthread"]
        c2_args : List<&1, String> = Con{"-O2", Con{"-no-pie", Con{merge_o, collect_objs(mods, link_tail)}}}
        r2 : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("gcc-10", c2_args, "", 65536, 120000)
        link_step2_res(r2, out_exe, merge_ms, t_lk0)

def merge_step_res(r1: Result<&1, &1, U32 & String, U32 & (String & String)>, +merge_o: String, +runtime_o: String, +out_exe: String, +mods: List<&2, ModSpec>, +t_m0: Nat) -> IO(LinkTiming):
  match r1:
    case Fail{(ec, emsg)}:
      IO.die(LinkTiming, 1, "[bend-build-pipe] x86-merge-obj failed: " ++ emsg)
    case Done{(rc1, io_pair)}:
      do IO<LinkTiming>:
        +t_m1 : Nat <- IO.now()
        +merge_ms : Nat = Nat.sub(t_m1, t_m0)
        merge_step_rc(U32.is_eq(rc1, 0), Pair.snd(String, String, io_pair), merge_o, runtime_o, out_exe, mods, merge_ms)

def run_merge_and_link(+cfg: BuildCfg, +mods: List<&2, ModSpec>) -> IO(LinkTiming):
  do IO<LinkTiming>:
    +t_m0 : Nat <- IO.now()
    +out_exe : String = cfg_out_exe(cfg)
    +entry_mod : String = cfg_entry(cfg)
    +merge_o : String = out_exe ++ ".merge.o"
    +tmp_m : String = merge_o ++ ".tmp"
    +others : String = fmt_other_mods(mods, entry_mod)
    +sh_cmd : String = sh_quote(cfg_compiler(cfg)) ++ " x86-merge-obj " ++ entry_mod ++ " " ++ entry_mod ++ others ++ " > " ++ sh_quote(tmp_m) ++ " && mv " ++ sh_quote(tmp_m) ++ " " ++ sh_quote(merge_o)
    r1 : Result<&1, &1, U32 & String, U32 & (String & String)> <- Process.run("/bin/sh", ["-c", sh_cmd], "", 65536, 120000)
    merge_step_res(r1, merge_o, cfg_runtime_o(cfg), out_exe, mods, t_m0)

def maybe_link(need_link: Bool, +cfg: BuildCfg, +mods: List<&2, ModSpec>) -> IO(LinkTiming):
  match need_link:
    case True{}:
      run_merge_and_link(cfg, mods)
    case False{}:
      IO.pure(LinkTiming, LinkTiming{0n, 0n})

# Driver completion & summary
# ---------------------------

def finish_driver_summary(lt: LinkTiming, +cfg: BuildCfg, +rebuilt: U32, +cached: U32, +total: U32, +iface_rebuilt: U32, +iface_cached: U32, +iface_ms: Nat, +compile_ms: Nat, +t_start: Nat) -> IO(U32):
  match lt:
    case LinkTiming{+merge_ms, +link_ms}:
      do IO<U32>:
        +t_end : Nat <- IO.now()
        +total_ms : Nat = Nat.sub(t_end, t_start)
        _ : Unit <- IO.print_err("[bend-build-pipe] summary: iface_ms=" ++ Nat.show(iface_ms) ++ " compile_ms=" ++ Nat.show(compile_ms) ++ " merge_ms=" ++ Nat.show(merge_ms) ++ " link_ms=" ++ Nat.show(link_ms) ++ " total_ms=" ++ Nat.show(total_ms) ++ " rebuilt=" ++ U32.show(rebuilt) ++ "/" ++ U32.show(total) ++ " cached=" ++ U32.show(cached) ++ "/" ++ U32.show(total) ++ " iface_rebuilt=" ++ U32.show(iface_rebuilt) ++ " iface_cached=" ++ U32.show(iface_cached) ++ " jobs=" ++ U32.show(cfg_jobs(cfg)))
        IO.pure(U32, 0)

def finish_driver_comp(comp_ok: Bool, +comp_err: String, +cfg: BuildCfg, +mods: List<&2, ModSpec>, +jobs_res: List<&2, ModJob>, +total: U32, +iface_rebuilt: U32, +iface_cached: U32, +iface_ms: Nat, +compile_ms: Nat, +t_start: Nat) -> IO(U32):
  match comp_ok:
    case False{}:
      IO.die(U32, 1, "[bend-build-pipe] compile stage failed: " ++ comp_err)
    case True{}:
      do IO<U32>:
        +rebuilt : U32 = count_rebuilt(jobs_res)
        +cached : U32 = U32.sub(total, rebuilt)
        +exe_ok : Bool <- file_exists(cfg_out_exe(cfg))
        +need_link : Bool = U32.is_gt(rebuilt, 0) || Bool.not(exe_ok)
        lt : LinkTiming <- maybe_link(need_link, cfg, mods)
        finish_driver_summary(lt, cfg, rebuilt, cached, total, iface_rebuilt, iface_cached, iface_ms, compile_ms, t_start)

def finish_driver(iface_ok: Bool, +iface_err: String, +comp_err: String, +cfg: BuildCfg, +mods: List<&2, ModSpec>, +jobs_res: List<&2, ModJob>, +total: U32, +iface_rebuilt: U32, +iface_cached: U32, +iface_ms: Nat, +compile_ms: Nat, +t_start: Nat) -> IO(U32):
  match iface_ok:
    case False{}:
      IO.die(U32, 1, "[bend-build-pipe] iface stage failed: " ++ iface_err)
    case True{}:
      finish_driver_comp(String.is_empty(comp_err), comp_err, cfg, mods, jobs_res, total, iface_rebuilt, iface_cached, iface_ms, compile_ms, t_start)

def run_driver_after(ires: IfaceRes, +cfg: BuildCfg, +mods: List<&2, ModSpec>, +total: U32, +res_ch: Chan(ModJob), +iface_ms: Nat, +compile_ms: Nat, +t_start: Nat) -> IO(U32):
  match ires:
    case IfaceRes{+iface_ok, +iface_err, +sent, +ir, +ic}:
      do IO<U32>:
        +jobs_res : List<&2, ModJob> <- drain_jobs(U32.to_nat(sent), res_ch)
        _ : Unit <- Chan.close(ModJob, res_ch)
        +comp_err : String = first_error(jobs_res)
        finish_driver(iface_ok, iface_err, comp_err, cfg, mods, jobs_res, total, ir, ic, iface_ms, compile_ms, t_start)

def run_driver(+manifest_path: String, +cfg: BuildCfg) -> IO(U32):
  do IO<U32>:
    +t_start : Nat <- IO.now()
    +manifest_txt : String <- read_file_req(manifest_path)
    +mods : List<&2, ModSpec> = parse_manifest_lines(String.lines(manifest_txt))
    +total : U32 = count_mods(mods)
    _ : Unit <- IO.print_err("[bend-build-pipe] manifest=" ++ manifest_path ++ " modules=" ++ U32.show(total) ++ " entry=" ++ cfg_entry(cfg) ++ " jobs=" ++ U32.show(cfg_jobs(cfg)))
    +work_ch : Chan(CompileTask) <- Chan.new(CompileTask, 64)
    +res_ch : Chan(ModJob) <- Chan.new(ModJob, 64)
    +fuel : Nat = Nat.add(U32.to_nat(total), 1n)
    wchs : List<&1, Chan(Unit)> <- spawn_workers(U32.to_nat(cfg_jobs(cfg)), fuel, cfg, work_ch, res_ch)
    +t_pipe0 : Nat <- IO.now()
    ires : IfaceRes <- run_pipeline(cfg, mods, 1, total, cfg_base_carrier(cfg), cfg_base_stamp(cfg), work_ch, 0, 0, 0)
    +t_iface1 : Nat <- IO.now()
    +iface_ms : Nat = Nat.sub(t_iface1, t_pipe0)
    _ : Unit <- Chan.close(CompileTask, work_ch)
    _ : Unit <- join_workers(wchs)
    +t_comp1 : Nat <- IO.now()
    +compile_ms : Nat = Nat.sub(t_comp1, t_pipe0)
    run_driver_after(ires, cfg, mods, total, res_ch, iface_ms, compile_ms, t_start)

# CLI argument parsing (`--jobs N` optional before positional args)
# -----------------------------------------------------------------

def parse_jobs_val(m: Maybe<&2, U32>) -> U32:
  match m:
    case None{}:
      4
    case Some{+n}:
      Bool.pick(U32, U32.is_eq(n, 0), 1, n)

def dispatch_pos(+jobs: U32, args: List<&1, String>) -> IO(U32):
  match args:
    case Con{manifest, Con{compiler, Con{base_bend, Con{base_carrier, Con{base_stamp, Con{iface_dir, Con{runtime_o, Con{entry_mod, Con{out_exe, Nil{}}}}}}}}}}:
      run_driver(manifest, BuildCfg{jobs, compiler, base_bend, base_carrier, base_stamp, iface_dir, runtime_o, entry_mod, out_exe})
    case _:
      IO.die(U32, 2, "usage: bend_build_pipe [--jobs N] <manifest> <compiler> <base_bend> <base_carrier_p130> <base_stamp> <iface_dir> <runtime_o> <entry_mod> <out_exe>")

def dispatch_flag(is_jobs: Bool, +flag: String, rest: List<&1, String>) -> IO(U32):
  match is_jobs:
    case True{}:
      match rest:
        case Con{n_str, rest2}:
          dispatch_pos(parse_jobs_val(U32.read(n_str)), rest2)
        case Nil{}:
          IO.die(U32, 2, "usage: --jobs requires a positive integer")
    case False{}:
      dispatch_pos(4, Con{flag, rest})

def dispatch(args: List<&1, String>) -> IO(U32):
  match args:
    case Nil{}:
      dispatch_pos(4, Nil{})
    case Con{+first, rest}:
      dispatch_flag(String.eq(first, "--jobs") || String.eq(first, "-j"), first, rest)

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    dispatch(List.tail(&1, String, args))
