# Native experimental frontend. Source assembly provides the exact selected
# frontend and p107_plan chain, plus pinned Base/cache path and stamp constants.
# The external research launcher authenticates those files before invocation.
type P107Plan is Data:
  P107PlanError{+error: String}
  P107PlanReady{+annotated: List<&2,KDef>, +verdict: String}

@unsafe
def p107_unit_json(+unit: NxqUnit) -> String:
  match unit:
    case NxqUnit{name, text}: "{\"name\":" ++ nx_quote(name) ++ ",\"text\":" ++ nx_quote(text) ++ "}"

@unsafe
def p107_unit_items(+units: List<&2,NxqUnit>) -> String:
  match units:
    case Nil{}: ""
    case Con{head, Nil{}}: p107_unit_json(head)
    case Con{head, rest}: p107_unit_json(head) ++ "," ++ p107_unit_items(rest)

def p107_print(text: String) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print(text)
    IO.pure(U32, 0)

@unsafe
def p107_units_print(+program: NxProgram, +result: NxqUnits) -> IO(U32):
  match result:
    case NxqUnits{units, +error}:
      nx_choose(IO(U32), String.is_empty(error),
        u => p107_print("{\"program\":" ++ nx_json_program(program) ++ ",\"units\":[" ++ p107_unit_items(units) ++ "]}"),
        u => IO.die(U32, 1, error))

@unsafe
def p107_emit(+program: NxProgram, +format: String, +fast: Bool) -> IO(U32):
  nx_choose(IO(U32), nx_verify(program),
    u => nx_choose(IO(U32), String.eq(format, "json"),
      v => p107_print(nx_json_program(program)),
      v => nx_choose(IO(U32), String.eq(format, "qbe"),
        w => p107_print(nx_choose(String, fast, x => nxq_program_fused(program), x => nxq_program(program))),
        w => p107_units_print(program, nxq_units(program, fast)))),
    u => IO.die(U32, 1, "IR verifier refused lowered program"))

@unsafe
def p107_lowered(+format: String, +fast: Bool, result: NxkResult) -> IO(U32):
  match result:
    case NxkResult{program, +error}:
      nx_choose(IO(U32), String.is_empty(error),
        u => p107_emit(nx_choose(NxProgram, fast,
          v => nx_optimize(nx_inline_entry(nx_tail_optimize(program), 4096)),
          v => program), format, fast),
        u => IO.die(U32, 1, "native subset: " ++ error))

@unsafe
def p107_planned(+entry: String, +format: String, +fast: Bool, plan: P107Plan) -> IO(U32):
  match plan:
    case P107PlanError{error}: IO.die(U32, 1, error)
    case P107PlanReady{annotated, verdict}:
      p107_lowered(format, fast, nxk_lower(annotated, entry))

@unsafe
def p107_prepared(+input: String, +text: String, +entry: String, +format: String, +fast: Bool, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32, 1, error)
    case P86PreparationReady{seed}: p107_planned(entry, format, fast, p107_plan(seed, input, text))

@unsafe
def p107_request(+input: String, +entry: String, +format: String, +fast: Bool, cached: Bool) -> IO(U32):
  do IO<U32>:
    +text : String <- p86_read_file(input)
    +base : String <- p86_read_file(p107_base_path())
    nx_choose(IO(U32), cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(p107_cache_path())
        p107_prepared(input, text, entry, format, fast,
          p88_cache_prepare(p107_base_path(), base, carrier, p107_cache_stamp())),
      u => p107_prepared(input, text, entry, format, fast,
        p86_prepare(p107_base_path(), base)))

@unsafe
def p107_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program, Con{+input, Con{+entry, Con{+format, Con{+policy, Con{+base_mode, Nil{}}}}}}}:
      nx_choose(IO(U32), String.starts_with(input, "/") && Bool.not(String.is_empty(entry)) &&
        (String.eq(format, "json") || String.eq(format, "qbe") || String.eq(format, "units")) &&
        (String.eq(policy, "raw") || String.eq(policy, "fast")) &&
        (String.eq(base_mode, "cache") || String.eq(base_mode, "live")),
        u => p107_request(input, entry, format, String.eq(policy, "fast"), String.eq(base_mode, "cache")),
        u => IO.die(U32, 2, "invalid native experiment arguments"))
    case _: IO.die(U32, 2, "usage: native-frontend ABS_INPUT ENTRY json|qbe|units raw|fast cache|live")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p107_args(args)
