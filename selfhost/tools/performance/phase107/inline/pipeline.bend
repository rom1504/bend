# Optional closed-program pipeline: only program.entry is externally callable.
# Internal helpers require valid IR and must not be exported independently.
# Reuse bounded pass cores; verify once at admission and once before returning.
@unsafe
def nx_pf_reach(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_pf_reached(nx_r_work([entry], [], fs, 256), program), u => program)

@unsafe
def nx_pf_reached(+found: Maybe<&2, List<&2, String>>, +program: NxProgram) -> NxProgram:
  match found program:
    case None{} _: program
    case Some{names} NxProgram{entry, fs}: NxProgram{entry, nx_r_filter(fs, names)}

@unsafe
def nx_pf_demand(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_pf_facts(program, nx_i_facts(fs)), u => program)

@unsafe
def nx_pf_facts(+program: NxProgram, +facts: List<&2, NxIFact>) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_pf_entry(nx_find(entry, fs), program, nx_i_eligible(nx_i_prove_all(facts, facts, [])))

@unsafe
def nx_pf_entry(+found: Maybe<&2, NxFunction>, +original: NxProgram, +eligible: List<&2, String>) -> NxProgram:
  match found original:
    case None{} _: original
    case Some{function} NxProgram{entry, fs}:
      nx_pf_first(nx_i_function(function, fs, 4096, Some{eligible}, 128), original, eligible)

@unsafe
def nx_pf_first(+done: NxIFunction, +original: NxProgram, +eligible: List<&2, String>) -> NxProgram:
  match done original:
    case NxIFunction{function, fuel} NxProgram{entry, fs}:
      nx_pf_remaining(nx_pf_reach(NxProgram{entry, nx_e_restore(fs, [function])}), fs, fuel, eligible)

# Preserve original callee bodies and the returned shared fuel. Pruning between
# remaining functions could lose a dependency reintroduced by a later expansion.
@unsafe
def nx_pf_remaining(+pruned: NxProgram, +original_fs: List<&2, NxFunction>, +fuel: U32, +eligible: List<&2, String>) -> NxProgram:
  match pruned:
    case NxProgram{entry, kept}:
      nx_pf_done(pruned, nx_i_functions(nx_e_without(entry, kept), original_fs, fuel, Some{eligible}, 128))

@unsafe
def nx_pf_done(+pruned: NxProgram, +done: NxIFunctions) -> NxProgram:
  match pruned done:
    case NxProgram{entry, kept} NxIFunctions{functions, fuel}:
      nx_pf_reach(NxProgram{entry, nx_e_restore(kept, functions)})

@unsafe
def nx_pf_leaf(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_e_certified(program, nx_l_eligible(fs), 4096), u => program)

@unsafe
def nx_pf_memory(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => NxProgram{entry, nx_m_functions(fs)}, u => program)

# Keep the public pipeline order, including the explicit reach after demand.
# Public standalone passes and their verifier/refusal behavior are unchanged.
@unsafe
def nx_pf_run(+program: NxProgram) -> NxProgram:
  nx_optimize(nx_pf_memory(nx_pf_reach(nx_pf_leaf(nx_pf_reach(nx_pf_demand(nx_t_program(program)))))))

@unsafe
def nx_pipeline_fast(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(program),
    u => nx_r_finish(nx_pf_run(program), program), u => program)
