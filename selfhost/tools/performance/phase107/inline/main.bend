# Standalone optional control producer. Do not concatenate Phase106/main.bend.
@unsafe
def nx_i_emit(+mode: String, +original: NxProgram, +optimized: NxProgram, +budget: U32) -> IO(U32):
  nx_choose(IO(U32), nx_verify(optimized) && U32.is_le(nx_inline_nodes(optimized), U32.add(nx_inline_nodes(original), nx_inline_budget(budget))),
    u => nx_choose(IO(U32), String.eq(mode, "json"),
      u => do IO<U32>:
        Unit <- IO.print(nx_json_program(optimized))
        IO.pure(U32, 0),
      u => nx_choose(IO(U32), String.eq(mode, "c"),
        u => do IO<U32>:
          Unit <- IO.print(nx_c_program(optimized))
          IO.pure(U32, 0),
        u => nx_choose(IO(U32), String.eq(mode, "stats"),
          u => do IO<U32>:
            Unit <- IO.print("{\"before\":" ++ U32.show(nx_inline_nodes(original)) ++ ",\"after\":" ++ U32.show(nx_inline_nodes(optimized)) ++ ",\"budget\":" ++ U32.show(nx_inline_budget(budget)) ++ ",\"verified\":true}")
            IO.pure(U32, 0),
          u => IO.die(U32, 2, "Expected json, c or stats")))),
    u => IO.die(U32, 3, "Inliner output failed verifier or growth bound"))

@unsafe
def nx_i_dispatch(+mode: String, +program: Maybe<&2, NxProgram>, +budget: Maybe<&2, U32>) -> IO(U32):
  match program budget:
    case Some{p} Some{fuel}: nx_i_request(mode, p, fuel)
    case _ _: IO.die(U32, 2, "Unknown fixture or invalid budget")

@unsafe
def nx_i_request(+mode: String, +p: NxProgram, +fuel: U32) -> IO(U32):
  nx_choose(IO(U32), String.eq(mode, "tail-json"), u => nx_i_emit("json", p, nx_tail_optimize(p), 4096), u =>
  nx_choose(IO(U32), String.eq(mode, "tail-c"), u => nx_i_emit("c", p, nx_tail_optimize(p), 4096), u =>
  nx_choose(IO(U32), String.eq(mode, "tail-stats"), u => nx_i_emit("stats", p, nx_tail_optimize(p), 4096), u =>
  nx_choose(IO(U32), String.eq(mode, "deep-json"), u => nx_i_emit("json", p, nx_inline_deep(p, fuel), fuel), u =>
  nx_choose(IO(U32), String.eq(mode, "deep-c"), u => nx_i_emit("c", p, nx_inline_deep(p, fuel), fuel), u =>
  nx_choose(IO(U32), String.eq(mode, "deep-stats"), u => nx_i_emit("stats", p, nx_inline_deep(p, fuel), fuel), u =>
    nx_i_emit(mode, p, nx_inline(p, fuel), fuel)))))))

@unsafe
def nx_i_cli(args: List<&1, String>) -> IO(U32):
  match args:
    case Con{program, Con{mode, Con{name, Con{budget, Nil{}}}}}:
      nx_i_dispatch(mode, nx_i_fixture(name), U32.read(budget))
    case _: IO.die(U32, 2, "Usage: inline-producer [deep-|tail-]json|c|stats WORKLOAD BUDGET")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1, String> <- IO.args()
    nx_i_cli(args)
