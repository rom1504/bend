# Spend the same growth budget on the public entry before retained helpers.
# Only a checked, acyclic purity certificate enables the deeper expansion.
@unsafe
def nx_e_without(+name: String, +fs: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match fs:
    case Nil{}: []
    case Con{NxFunction{key, params, result, locals, body}, rest}:
      nx_choose(List<&2, NxFunction>, String.eq(key, name), u => rest,
        u => Con{NxFunction{key, params, result, locals, body}, nx_e_without(name, rest)})

@unsafe
def nx_e_first(+found: Maybe<&2, NxFunction>, +name: String, +fs: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match found:
    case None{}: fs
    case Some{function}: Con{function, nx_e_without(name, fs)}

@unsafe
def nx_e_restore(+original: List<&2, NxFunction>, +optimized: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match original:
    case Nil{}: []
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      Con{nx_e_restored(nx_find(name, optimized), NxFunction{name, params, result, locals, body}), nx_e_restore(rest, optimized)}

def nx_e_restored(+found: Maybe<&2, NxFunction>, +original: NxFunction) -> NxFunction:
  match found:
    case None{}: original
    case Some{function}: function

@unsafe
def nx_e_program(+program: NxProgram, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256),
        u => nx_e_facts(program, nx_i_facts(fs), budget), u => program)

@unsafe
def nx_e_facts(+program: NxProgram, +facts: List<&2, NxIFact>, +budget: U32) -> NxProgram:
  nx_e_certified(program, nx_i_eligible(nx_i_prove_all(facts, facts, [])), budget)

@unsafe
def nx_e_certified(+program: NxProgram, +eligible: List<&2, String>, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_e_done(entry, fs, nx_i_functions(nx_e_first(nx_find(entry, fs), entry, fs), fs, budget, Some{eligible}, 128))

@unsafe
def nx_e_done(+entry: String, +original: List<&2, NxFunction>, +result: NxIFunctions) -> NxProgram:
  match result:
    case NxIFunctions{functions, fuel}: NxProgram{entry, nx_e_restore(original, functions)}

@unsafe
def nx_inline_entry(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_choose(NxProgram, U32.is_eq(budget, 0), u => program,
    u => nx_choose(NxProgram, nx_verify(program),
      u => nx_e_program(program, nx_inline_budget(budget)), u => program))
