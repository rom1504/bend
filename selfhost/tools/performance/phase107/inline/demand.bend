# Optional CLOSED-PROGRAM policy: program.entry is the sole external root.
# Use original callees and one growth budget; do not optimize definitions that
# entry expansion makes unreachable. NxFunc address references remain roots.
# Zero budget, invalid input and the outer capacity limits preserve input.
@unsafe
def nx_d_program(+program: NxProgram, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_d_facts(program, nx_i_facts(fs), budget),
        u => program)

@unsafe
def nx_d_facts(+program: NxProgram, +facts: List<&2, NxIFact>, +budget: U32) -> NxProgram:
  nx_d_certified(program, nx_i_eligible(nx_i_prove_all(facts, facts, [])), budget)

@unsafe
def nx_d_certified(+program: NxProgram, +eligible: List<&2, String>, +budget: U32) -> NxProgram:
  match program:
    case NxProgram{entry, fs}: nx_d_found(nx_find(entry, fs), program, eligible, budget)

@unsafe
def nx_d_found(+found: Maybe<&2, NxFunction>, +original: NxProgram, +eligible: List<&2, String>, +budget: U32) -> NxProgram:
  match found original:
    case None{} _: original
    case Some{function} NxProgram{entry, fs}:
      nx_d_first(nx_i_function(function, fs, budget, Some{eligible}, 128), original, eligible)

@unsafe
def nx_d_first(+done: NxIFunction, +original: NxProgram, +eligible: List<&2, String>) -> NxProgram:
  match done original:
    case NxIFunction{function, fuel} NxProgram{entry, fs}:
      nx_d_remaining(nx_reachable(NxProgram{entry, nx_e_restore(fs, [function])}), fs, fuel, eligible, original)

# The retained non-entry bodies are still original. Thus their original callee
# dependencies are present. Do not prune between remaining functions: a later
# expansion of an original callee can refer to a definition an earlier expansion
# stopped using. A final reachability pass safely removes those leftovers.
@unsafe
def nx_d_remaining(+pruned: NxProgram, +original_fs: List<&2, NxFunction>, +fuel: U32, +eligible: List<&2, String>, +original: NxProgram) -> NxProgram:
  match pruned:
    case NxProgram{entry, kept}:
      nx_d_finish(pruned, original,
        nx_i_functions(nx_e_without(entry, kept), original_fs, fuel, Some{eligible}, 128))

@unsafe
def nx_d_finish(+pruned: NxProgram, +original: NxProgram, +done: NxIFunctions) -> NxProgram:
  match pruned done:
    case NxProgram{entry, kept} NxIFunctions{functions, fuel}:
      nx_r_finish(nx_reachable(NxProgram{entry, nx_e_restore(kept, functions)}), original)

@unsafe
def nx_inline_demand(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_choose(NxProgram, U32.is_eq(budget, 0), u => program,
    u => nx_choose(NxProgram, nx_verify(program),
      u => nx_d_program(program, nx_inline_budget(budget)), u => program))
