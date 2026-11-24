# bend5k/main.bend — Milestone 4 End-to-End Compiler Driver (-O0 / -O2)
# =====================================================================
# CLI:
#   bend5k [-O0 | -O2 | --opt O0|O2] <src.bend> [<base.bend>] <out.o>
#   bend5k --check-only <src.bend>

type B5kIoRes<-A: Data> is Data:
  B5kErr{msg: String}
  B5kOk{val: A}

def b5k_die(msg: String) -> IO(Unit):
  IO.bind(Unit, Unit, IO.print_err(msg), u => IO.exit(1))

def b5k_usage() -> IO(Unit):
  b5k_die("usage: bend5k [-O0|-O2|--opt O0|O2|--check-only] <src.bend> [<base.bend>] <out.o>")

def b5k_close_err(-A: Data, f: File, msg: String) -> IO(B5kIoRes<A>):
  IO.bind(Unit, B5kIoRes<A>, File.close(f), u => IO.pure(B5kIoRes<A>, B5kErr{msg}))

def b5k_close_ok(-A: Data, f: File, v: A) -> IO(B5kIoRes<A>):
  IO.bind(Unit, B5kIoRes<A>, File.close(f), u => IO.pure(B5kIoRes<A>, B5kOk{v}))

def b5k_read_done(path: String, got: File & Result<&1, &1, U32 & String, String>) -> IO(B5kIoRes<String>):
  (f, res) = got
  match res:
    case Fail{(_, msg)}: b5k_close_err(String, f, "read failed: " ++ path ++ ": " ++ msg)
    case Done{txt}: b5k_close_ok(String, f, String.reverse(String.reverse(txt)))

def b5k_read_sized(path: String, got: File & Result<&1, &1, U32 & String, U32>) -> IO(B5kIoRes<String>):
  (f, res) = got
  match res:
    case Fail{(_, msg)}: b5k_close_err(String, f, "stat failed: " ++ path ++ ": " ++ msg)
    case Done{sz}:
      IO.bind(File & Result<&1, &1, U32 & String, String>, B5kIoRes<String>,
        File.read(f, U32.add(sz, 1)),
        r => b5k_read_done(path, r))

def b5k_read_opened(path: String, res: Result<&1, &1, U32 & String, File>) -> IO(B5kIoRes<String>):
  match res:
    case Fail{(_, msg)}: IO.pure(B5kIoRes<String>, B5kErr{"open failed: " ++ path ++ ": " ++ msg})
    case Done{f}:
      IO.bind(File & Result<&1, &1, U32 & String, U32>, B5kIoRes<String>,
        File.size(f),
        r => b5k_read_sized(path, r))

def b5k_read_file(+path: String) -> IO(B5kIoRes<String>):
  IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<String>,
    File.open(path, "r"),
    r => b5k_read_opened(path, r))

def b5k_write_done(path: String, got: File & Result<&1, &1, U32 & String, Unit>) -> IO(B5kIoRes<Unit>):
  (f, res) = got
  match res:
    case Fail{(_, msg)}: b5k_close_err(Unit, f, "write failed: " ++ path ++ ": " ++ msg)
    case Done{u}: b5k_close_ok(Unit, f, u)

def b5k_write_opened(path: String, bs: List<&2, U32>, res: Result<&1, &1, U32 & String, File>) -> IO(B5kIoRes<Unit>):
  match res:
    case Fail{(_, msg)}: IO.pure(B5kIoRes<Unit>, B5kErr{"open failed: " ++ path ++ ": " ++ msg})
    case Done{f}:
      IO.bind(File & Result<&1, &1, U32 & String, Unit>, B5kIoRes<Unit>,
        File.write_bytes(f, bs),
        r => b5k_write_done(path, r))

def b5k_write_file(+path: String, bs: List<&2, U32>) -> IO(B5kIoRes<Unit>):
  IO.bind(Result<&1, &1, U32 & String, File>, B5kIoRes<Unit>,
    File.open(path, "w"),
    r => b5k_write_opened(path, bs, r))

def b5k_compile_lower(is_o2: Bool, lr: LowerRes) -> B5kIoRes<List<&2, U32>>:
  match is_o2 lr:
    case _ LowerRes{False{}, err, _}: B5kErr{err}
    case False{} LowerRes{True{}, _, +prog}:
      fns = b5k_codegen(prog)
      B5kOk{bb_to_bytes(b5k_emit_elf(prog, fns))}
    case True{} LowerRes{True{}, _, prog}:
      +prog2 = b5k_opt(prog)
      fns = b5k_peep(b5k_codegen_o2(prog2))
      B5kOk{bb_to_bytes(b5k_emit_elf(prog2, fns))}

def b5k_compile_check(is_o2: Bool, check_only: Bool, cr: CheckRes) -> B5kIoRes<List<&2, U32>>:
  match check_only cr:
    case _ CheckRes{False{}, err, _}: B5kErr{err}
    case True{} CheckRes{True{}, _, _}: B5kOk{Nil{}}
    case False{} CheckRes{True{}, _, book}: b5k_compile_lower(is_o2, b5k_lower(book))

def b5k_compile_parse(is_o2: Bool, check_only: Bool, pr: ParseRes) -> B5kIoRes<List<&2, U32>>:
  match pr:
    case ParseRes{False{}, err, _}: B5kErr{err}
    case ParseRes{True{}, _, book}: b5k_compile_check(is_o2, check_only, b5k_check(book))

def b5k_compile_src(is_o2: Bool, check_only: Bool, src: String) -> B5kIoRes<List<&2, U32>>:
  b5k_compile_parse(is_o2, check_only, b5k_parse(src, symtab_new()))

def b5k_finish_write(res: B5kIoRes<Unit>) -> IO(Unit):
  match res:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{_}: IO.pure(Unit, Unit{})

def b5k_run_emit(out_path: String, res: B5kIoRes<List<&2, U32>>) -> IO(Unit):
  match res:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{bs}:
      IO.bind(B5kIoRes<Unit>, Unit, b5k_write_file(out_path, bs), r => b5k_finish_write(r))

def b5k_run_check_res(res: B5kIoRes<List<&2, U32>>) -> IO(Unit):
  match res:
    case B5kErr{msg}: b5k_die(msg)
    case B5kOk{_}: IO.print("ALL PROOFS CHECK")

def b5k_run_loaded(is_o2: Bool, check_only: Bool, out_path: String, loaded: B5kIoRes<String>) -> IO(Unit):
  match check_only loaded:
    case _ B5kErr{msg}: b5k_die(msg)
    case True{} B5kOk{src}: b5k_run_check_res(b5k_compile_src(is_o2, True{}, src))
    case False{} B5kOk{src}: b5k_run_emit(out_path, b5k_compile_src(is_o2, False{}, src))

def b5k_run_driver(is_o2: Bool, check_only: Bool, src_path: String, out_path: String) -> IO(Unit):
  IO.bind(B5kIoRes<String>, Unit, b5k_read_file(src_path), r => b5k_run_loaded(is_o2, check_only, out_path, r))

def b5k_dispatch_pos(is_o2: Bool, check_only: Bool, a1: String, rest: List<String>) -> IO(Unit):
  match check_only rest:
    case True{} Nil{}: b5k_run_driver(is_o2, True{}, a1, "")
    case True{} Con{_, _}: b5k_usage()
    case False{} Nil{}: b5k_usage()
    case False{} Con{a2, Nil{}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a2)))
    case False{} Con{_, Con{a3, Nil{}}}: b5k_run_driver(is_o2, False{}, a1, String.reverse(String.reverse(a3)))
    case False{} Con{_, Con{_, Con{_, _}}}: b5k_usage()

type B5kFlagStep is Type:
  FlagErr{}
  FlagCont{is_o2: Bool, check_only: Bool, rest: List<String>}
  FlagDone{is_o2: Bool, check_only: Bool, a1: String, rest: List<String>}

def b5k_step_opt(check_only: Bool, rest: List<String>) -> B5kFlagStep:
  match rest:
    case Nil{}: FlagErr{}
    case Con{lvl, more}: FlagCont{b5k_str_eq(String.reverse(String.reverse(lvl)), "O2"), check_only, more}

def b5k_step_s4(is_opt: Bool, is_o2: Bool, check_only: Bool, a1: String, rest: List<String>) -> B5kFlagStep:
  match is_opt:
    case True{}: b5k_step_opt(check_only, rest)
    case False{}: FlagDone{is_o2, check_only, a1, rest}

def b5k_step_s3(is_chk: Bool, is_o2: Bool, check_only: Bool, +a1: String, rest: List<String>) -> B5kFlagStep:
  match is_chk:
    case True{}: FlagCont{is_o2, True{}, rest}
    case False{}: b5k_step_s4(b5k_str_eq(a1, "--opt"), is_o2, check_only, a1, rest)

def b5k_step_s2(is_o0: Bool, is_o2: Bool, check_only: Bool, +a1: String, rest: List<String>) -> B5kFlagStep:
  match is_o0:
    case True{}: FlagCont{False{}, check_only, rest}
    case False{}: b5k_step_s3(b5k_str_eq(a1, "--check-only"), is_o2, check_only, a1, rest)

def b5k_step_s1(set_o2: Bool, is_o2: Bool, check_only: Bool, +a1: String, rest: List<String>) -> B5kFlagStep:
  match set_o2:
    case True{}: FlagCont{True{}, check_only, rest}
    case False{}: b5k_step_s2(b5k_str_eq(a1, "-O0"), is_o2, check_only, a1, rest)

def b5k_parse_step(is_o2: Bool, check_only: Bool, args: List<String>) -> B5kFlagStep:
  match args:
    case Nil{}: FlagErr{}
    case Con{a1, rest}:
      +s1 = String.reverse(String.reverse(a1))
      b5k_step_s1(b5k_str_eq(s1, "-O2"), is_o2, check_only, s1, rest)

def b5k_parse_flags(fuel: Nat, st: B5kFlagStep) -> IO(Unit):
  match fuel st:
    case 0n _: b5k_usage()
    case _ FlagErr{}: b5k_usage()
    case _ FlagDone{is_o2, check_only, a1, rest}: b5k_dispatch_pos(is_o2, check_only, a1, rest)
    case 1n+p FlagCont{is_o2, check_only, rest}: b5k_parse_flags(p, b5k_parse_step(is_o2, check_only, rest))

def b5k_clone_args(xs: List<String>) -> List<String>:
  match xs:
    case Nil{}: Nil{}
    case Con{s, t}: Con{String.reverse(String.reverse(s)), b5k_clone_args(t)}

def b5k_main_args(argv: List<String>) -> IO(Unit):
  match argv:
    case Nil{}: b5k_usage()
    case Con{_, rest}: b5k_parse_flags(16n, FlagCont{False{}, False{}, b5k_clone_args(rest)})

def main() -> IO(Unit):
  IO.bind(List<String>, Unit, IO.args(), argv => b5k_main_args(argv))
