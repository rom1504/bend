# Bounded two-process correctness pilot. Compile with --legacy-js: its existing
# Process.run provider is asynchronous. The direct-JS provider is synchronous.
# One outer build-retention guard owns memory, disk, deadlines and descendants.
# This is a scheduling experiment, never a generated-program timing runner.
import Base

def p150pv_summary(+stdout: String) -> Bool:
  Bool.and(String.starts_with(stdout,
    "{\n  \"complete\": true,\n  \"passed\": true,\n  \"counts\": {\n    \"pass\": 1,\n    \"fail\": 0,\n    \"unsupported\": 0\n  },\n  \"seconds\": "),
    String.ends_with(stdout, "\n}\n"))

def p150pv_answer(r: Result<&1, &1, U32 & String, U32 & (String & String)>,
  want: String) -> Bool:
  match r:
    case Fail{error}: False{}
    case Done{(code, (out, err))}:
      Bool.and(U32.is_eq(code, 0),
        Bool.and(String.eq(out, want), String.eq(err, "")))

def p150pv_timeout(r: Result<&1, &1, U32 & String, U32 & (String & String)>) -> Bool:
  match r:
    case Fail{(code, message)}: U32.is_eq(code, 110)
    case Done{value}: False{}

def p150pv_finish(ok: Bool, label: String) -> IO(Unit):
  match ok:
    case True{}: IO.print(label ++ " pass")
    case False{}: IO.die(Unit, 1, label ++ " fail")

def p150pv_output(+name: String, +code: U32, +out: String, +err: String) -> IO(Bool):
  do IO<Bool>:
    IO.print("task=" ++ name ++ " exit=" ++ U32.show(code))
    IO.print("task=" ++ name ++ " stdout-begin\n" ++ out ++ "stdout-end")
    IO.print("task=" ++ name ++ " stderr-begin\n" ++ err ++ "stderr-end")
    IO.pure(Bool, Bool.and(U32.is_eq(code, 0),
      Bool.and(p150pv_summary(out), String.eq(err, ""))))

def p150pv_observe(name: String,
  r: Result<&1, &1, U32 & String, U32 & (String & String)>) -> IO(Bool):
  match r:
    case Fail{(code, message)}:
      do IO<Bool>:
        IO.print("task=" ++ name ++ " process-error=" ++ U32.show(code)
          ++ " message=" ++ message)
        IO.pure(Bool, False{})
    case Done{(code, (out, err))}:
      p150pv_output(name, code, out, err)

def p150pv_job(+cpu: String, +name: String, root: String) -> IO(Bool):
  do IO<Bool>:
    +begin : Nat <- IO.now()
    IO.print("task=" ++ name ++ " cpu=" ++ cpu ++ " startedMs=" ++ Nat.show(begin))
    got : Result<&1, &1, U32 & String, U32 & (String & String)> <-
      Process.run("/usr/bin/taskset", ["-c", cpu, "/usr/bin/python3", "-B",
        "selfhost/tools/build/qualification.py",
        "--assets", "selfhost/manifests/assets-native.json",
        "--image-key", "qbe-n2", "--host", "native", "--stage", "N2",
        "--target", "qbe", "--mode", "cache", "--suite", "focused",
        "--case", name, "--seconds", "20", "--build-seconds", "20",
        "--execute-seconds", "10", "--out", root ++ "/" ++ name],
        "", 65536, 75000)
    +end : Nat <- IO.now()
    IO.print("task=" ++ name ++ " finishedMs=" ++ Nat.show(end)
      ++ " elapsedMs=" ++ Nat.show(Nat.sub(end, begin)))
    p150pv_observe(name, got)

def p150pv_serial(+root: String) -> IO(Unit):
  do IO<Unit>:
    a : Bool <- p150pv_job("0", "nt-reverse", root)
    b : Bool <- p150pv_job("1", "lexer-scan", root)
    p150pv_finish(Bool.and(a, b), "serial")

def p150pv_parallel(+root: String) -> IO(Unit):
  do IO<Unit>:
    a : Chan(Bool) <- IO.fork(Bool, p150pv_job("0", "nt-reverse", root))
    b : Chan(Bool) <- IO.fork(Bool, p150pv_job("1", "lexer-scan", root))
    x : Bool <- IO.join(Bool, a)
    y : Bool <- IO.join(Bool, b)
    p150pv_finish(Bool.and(x, y), "parallel")

def p150pv_pipe_output(+name: String, +code: U32, +out: String, +err: String,
  want: String) -> IO(Bool):
  do IO<Bool>:
    IO.print("control=" ++ name ++ " exit=" ++ U32.show(code)
      ++ " stdout=[" ++ out ++ "] stderr=[" ++ err ++ "]")
    IO.pure(Bool, Bool.and(U32.is_eq(code, 0),
      Bool.and(String.eq(out, want), String.eq(err, ""))))

def p150pv_pipe(name: String, want: String,
  r: Result<&1, &1, U32 & String, U32 & (String & String)>) -> IO(Bool):
  match r:
    case Fail{(code, message)}:
      do IO<Bool>:
        IO.print("control=" ++ name ++ " error=" ++ U32.show(code)
          ++ " message=[" ++ message ++ "]")
        IO.pure(Bool, False{})
    case Done{(code, (out, err))}: p150pv_pipe_output(name, code, out, err, want)

def p150pv_timeout_error(+code: U32, message: String) -> IO(Bool):
  do IO<Bool>:
    IO.print("control=timeout error=" ++ U32.show(code) ++ " message=[" ++ message ++ "]")
    IO.pure(Bool, U32.is_eq(code, 110))

def p150pv_timeout_probe(
  r: Result<&1, &1, U32 & String, U32 & (String & String)>) -> IO(Bool):
  match r:
    case Fail{(code, message)}: p150pv_timeout_error(code, message)
    case Done{(code, (out, err))}:
      do IO<Bool>:
        IO.print("control=timeout unexpected-exit=" ++ U32.show(code)
          ++ " stdout=[" ++ out ++ "] stderr=[" ++ err ++ "]")
        IO.pure(Bool, False{})

def p150pv_control() -> IO(Unit):
  do IO<Unit>:
    a : Chan(Result<&1, &1, U32 & String, U32 & (String & String)>) <-
      IO.fork(Result<&1, &1, U32 & String, U32 & (String & String)>,
        Process.run("/bin/cat", [], "alpha", 128, 1000))
    b : Chan(Result<&1, &1, U32 & String, U32 & (String & String)>) <-
      IO.fork(Result<&1, &1, U32 & String, U32 & (String & String)>,
        Process.run("/bin/cat", [], "beta", 128, 1000))
    x : Result<&1, &1, U32 & String, U32 & (String & String)> <-
      IO.join(Result<&1, &1, U32 & String, U32 & (String & String)>, a)
    y : Result<&1, &1, U32 & String, U32 & (String & String)> <-
      IO.join(Result<&1, &1, U32 & String, U32 & (String & String)>, b)
    late : Result<&1, &1, U32 & String, U32 & (String & String)> <-
      Process.run("/bin/sleep", ["1"], "", 128, 30)
    x_ok : Bool <- p150pv_pipe("alpha", "alpha", x)
    y_ok : Bool <- p150pv_pipe("beta", "beta", y)
    late_ok : Bool <- p150pv_timeout_probe(late)
    IO.print("empty-summary-rejected=" ++ Bool.show(Bool.not(p150pv_summary(""))))
    p150pv_finish(Bool.and(Bool.not(p150pv_summary("")),
      Bool.and(x_ok, Bool.and(y_ok, late_ok))), "control")

def p150pv_cancel() -> IO(Unit):
  do IO<Unit>:
    IO.print("cancel-control child-start")
    got : Result<&1, &1, U32 & String, U32 & (String & String)> <-
      Process.run("/bin/sleep", ["60"], "", 128, 120000)
    IO.die(Unit, 1, "cancel control was not stopped by the outer guard")

def p150pv_dispatch(mode: String, root: String) -> IO(Unit):
  match mode:
    case "serial": p150pv_serial(root)
    case "parallel": p150pv_parallel(root)
    case "control": p150pv_control()
    case "cancel": p150pv_cancel()
    case _: IO.die(Unit, 1, "expected serial, parallel, control or cancel")

def p150pv_args(args: List<String>) -> IO(Unit):
  match args:
    case [program, mode, root]: p150pv_dispatch(mode, root)
    case _: IO.die(Unit, 1, "expected MODE FRESH_OUTPUT_ROOT")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p150pv_args(args)
