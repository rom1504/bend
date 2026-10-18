@unsafe
def nx_emit_selected(+mode: String, +program: NxProgram) -> IO(U32):
  nx_choose(IO(U32), nx_verify(program),
    u => nx_choose(IO(U32), String.eq(mode, "json"),
      u => do IO<U32>:
        Unit <- IO.print(nx_json_program(program))
        IO.pure(U32, 0),
      u => nx_choose(IO(U32), String.eq(mode, "c"),
        u => do IO<U32>:
          Unit <- IO.print(nx_c_program(program))
          IO.pure(U32, 0),
        u => nx_choose(IO(U32), String.eq(mode, "verify"),
          u => do IO<U32>:
            Unit <- IO.print("verified")
            IO.pure(U32, 0),
          u => IO.die(U32, 2, "Expected mode: json, c or verify")))),
    u => IO.die(U32, 3, "IR verifier refused program"))

@unsafe
def nx_dispatch(+mode: String, +name: String, +optimization: String) -> IO(U32):
  nx_dispatch_selected(mode, optimization, nx_workload(name))

@unsafe
def nx_dispatch_selected(+mode: String, +optimization: String, +selected: Maybe<&2, NxProgram>) -> IO(U32):
  match selected:
    case None{}: IO.die(U32, 2, "Unknown workload")
    case Some{program}:
      nx_choose(IO(U32), String.eq(optimization, "raw"), u => nx_emit_selected(mode, program),
        u => nx_choose(IO(U32), String.eq(optimization, "fold"), u => nx_emit_selected(mode, nx_optimize(program)),
          u => IO.die(U32, 2, "Expected optimizer: raw or fold")))

@unsafe
def nx_args(args: List<&1, String>) -> IO(U32):
  match args:
    case Con{program, Con{mode, Con{name, Con{optimization, Nil{}}}}}:
      nx_dispatch(mode, name, optimization)
    case _: IO.die(U32, 2, "Usage: producer MODE WORKLOAD raw|fold")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    nx_args(args)
