# bend5k/main.bend — Milestone 1 End-to-End Compiler Driver
# =========================================================
# CLI:
#   bend5k <src.bend> <out.o>
#   bend5k --check-only <src.bend>
#   bend5k <src.bend> <base.bend> <out.o>

type B5kIoRes<-A: Data> is Data:
  B5kErr{msg: String}
  B5kOk{val: A}

def b5k_die(msg: String) -> IO(Unit):
  IO.bind(Unit, Unit, IO.print_err(msg), u => IO.exit(1))

def b5k_close_err(-A: Data, f: File, msg: String) -> IO(B5kIoRes<A>):
  IO.bind(Unit, B5kIoRes<A>, File.close(f), u => IO.pure(B5kIoRes<A>, B5kErr{msg}))

def b5k_close_ok(-A: Data, f: File, v: A) -> IO(B5kIoRes<A>):
  IO.bind(Unit, B5kIoRes<A>, File.close(f), u => IO.pure(B5kIoRes<A>, B5kOk{v}))

def b5k_read_done(path: String, got: File & Result<&1, &1, U32 & String, String>) -> IO(B5kIoRes<String>):
  (f, res) = got
  match res:
    case Fail{(_, msg)}: b5k_close_err(String, f, "read failed: " ++ path ++ ": " ++ msg)
    case Done{txt}: b5k_close_ok(String, f, txt)

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

def b5k_compile_lower(lr: LowerRes) -> B5kIoRes<List<&2, U32>>:
  match lr:
    case LowerRes{False{}, err, _}: B5kErr{err}
    case LowerRes{True{}, _, +prog}:
      fns = b5k_codegen(prog)
      B5kOk{bb_to_bytes(b5k_emit_elf(prog, fns))}

def b5k_compile_check(check_only: Bool, cr: CheckRes) -> B5kIoRes<List<&2, U32>>:
  match check_only cr:
    case _ CheckRes{False{}, err, _}: B5kErr{err}
    case True{} CheckRes{True{}, _, _}: B5kOk{Nil{}}
    case False{} CheckRes{True{}, _, book}: b5k_compile_lower(b5k_lower(book))

def b5k_compile_parse(check_only: Bool, pr: ParseRes) -> B5kIoRes<List<&2, U32>>:
  match pr:
    case ParseRes{False{}, err, _}: B5kErr{err}
    case ParseRes{True{}, _, book}: b5k_compile_check(check_only, b5k_check(book))

def b5k_compile_src(check_only: Bool, src: String) -> B5kIoRes<List<&2, U32>>:
  b5k_compile_parse(check_only, b5k_parse(src, symtab_new()))

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

def b5k_run_loaded(check_only: Bool, out_path: String, loaded: B5kIoRes<String>) -> IO(Unit):
  match check_only loaded:
    case _ B5kErr{msg}: b5k_die(msg)
    case True{} B5kOk{src}: b5k_run_check_res(b5k_compile_src(True{}, src))
    case False{} B5kOk{src}: b5k_run_emit(out_path, b5k_compile_src(False{}, src))

def b5k_run_driver(check_only: Bool, src_path: String, out_path: String) -> IO(Unit):
  IO.bind(B5kIoRes<String>, Unit, b5k_read_file(src_path), r => b5k_run_loaded(check_only, out_path, r))

def b5k_dispatch_2(is_chk: Bool, a1: String, a2: String) -> IO(Unit):
  match is_chk:
    case True{}: b5k_run_driver(True{}, a2, "")
    case False{}: b5k_run_driver(False{}, a1, a2)

def b5k_dispatch_args(args: List<String>) -> IO(Unit):
  match args:
    case Con{+a1, Con{a2, Nil{}}}: b5k_dispatch_2(b5k_str_eq(a1, "--check-only"), a1, a2)
    case Con{a1, Con{_, Con{a3, Nil{}}}}: b5k_run_driver(False{}, a1, a3)
    case _: b5k_die("usage: bend5k [--check-only] <src.bend> [<base.bend>] <out.o>")

def b5k_main_args(argv: List<String>) -> IO(Unit):
  match argv:
    case Nil{}: b5k_die("usage: bend5k [--check-only] <src.bend> [<base.bend>] <out.o>")
    case Con{_, rest}: b5k_dispatch_args(rest)

def main() -> IO(Unit):
  IO.bind(List<String>, Unit, IO.args(), argv => b5k_main_args(argv))
