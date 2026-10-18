# IR-only optimization/emission kernel. It does not parse or check Bend source.
@unsafe
def nx_kernel_checked(+program: NxProgram) -> NxProgram:
  nx_optimize(nx_memory_forward(nx_reachable(nx_inline_leaf(nx_reachable(nx_inline_demand(nx_tail_optimize(program), 4096)), 4096))))

@unsafe
def nx_kernel_policy(+program: NxProgram, +policy: String) -> NxProgram:
  nx_choose(NxProgram, String.eq(policy, "raw"), u => program,
    u => nx_choose(NxProgram, String.eq(policy, "pure"),
      v => nx_reachable(nx_optimize(nx_inline_entry(nx_tail_optimize(program), 4096))),
      v => nx_choose(NxProgram, String.eq(policy, "memory"),
        w => nx_reachable(nx_optimize(nx_inline_leaf(nx_reachable(nx_inline_entry(nx_tail_optimize(program), 4096)), 4096))),
        w => nx_choose(NxProgram, String.eq(policy, "checked"), x => nx_kernel_checked(program),
          x => nx_choose(NxProgram, String.eq(policy, "fast"), y => nx_pipeline_fast(program),
            y => nx_choose(NxProgram, String.eq(policy, "promote"), z => nx_scalar_promote(nx_pipeline_fast(program)),
              z => nx_constant_propagate(nx_scalar_promote(nx_pipeline_fast(program)))))))))

def nx_kernel_valid_policy(+policy: String) -> Bool:
  String.eq(policy, "raw") || String.eq(policy, "pure") || String.eq(policy, "memory") ||
  String.eq(policy, "checked") || String.eq(policy, "fast") || String.eq(policy, "promote") || String.eq(policy, "constant")

@unsafe
def nx_kernel_text(+program: NxProgram, +format: String, +fused: Bool) -> String:
  nx_choose(String, String.eq(format, "json"), u => nx_json_program(program),
    u => nx_choose(String, fused, v => nxq_program_fused(program), v => nxq_program(program)))

@unsafe
def nx_kernel_emit(+program: NxProgram, +policy: String, +format: String) -> IO(U32):
  nx_choose(IO(U32), nx_verify(program),
    u => do IO<U32>:
      Unit <- IO.print(nx_kernel_text(program, format, Bool.not(String.eq(policy, "raw"))))
      IO.pure(U32, 0),
    u => IO.die(U32, 3, "Kernel IR verifier refused program"))

@unsafe
def nx_kernel_selected(+selected: Maybe<&2,NxProgram>, +policy: String, +format: String) -> IO(U32):
  match selected:
    case None{}: IO.die(U32, 2, "Unknown workload")
    case Some{program}: nx_kernel_emit(nx_kernel_policy(program, policy), policy, format)

@unsafe
def nx_kernel_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{exe, Con{+name, Con{+policy, Con{+format, Nil{}}}}}:
      nx_choose(IO(U32), nx_kernel_valid_policy(policy) &&
        (String.eq(format, "json") || String.eq(format, "qbe")),
        u => nx_kernel_selected(nx_workload(name), policy, format),
        u => IO.die(U32, 2, "Expected raw|pure|memory|checked|fast|promote|constant and json|qbe"))
    case _: IO.die(U32, 2, "Usage: kernel WORKLOAD raw|pure|memory|checked|fast|promote|constant json|qbe")

def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    nx_kernel_args(args)
